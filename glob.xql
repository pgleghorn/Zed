xquery version "1.0" encoding "UTF-8";
declare option exist:serialize "method=xhtml media-type=text/html";

declare variable $local:PARATUREBASEURL := "https://s3.parature.com/api/v1/5479/5508";
declare variable $local:PARATURETOKEN := "********";
declare variable $local:ADMINUSER := "admin";
declare variable $local:ADMINPASS := "********";
declare variable $local:APPBASE := "/db/supportx";
declare variable $local:COLL_PARATURE_FTC := "/db/supportx/parature_tickets_ftc";

declare function local:contains-case-insensitive( $arg as xs:string?, $substring as xs:string) as xs:boolean? {
   contains(upper-case($arg), upper-case($substring))
};

declare function local:grabLongCommentsNewStyle($ticket as item()) as xs:string* {
    for $comment in $ticket//ActionHistory/History/Comments[local:contains-case-insensitive(., '[Click here for Details]')][local:contains-case-insensitive(., 'class=''link2'' target=''_blank''')]/text()
    let $x := util:log-system-out(concat("comment = ", $comment))
    let $ticketnum := $ticket/Ticket_Number/text()
(: new style, tokenize doesnt like single quotes.. :)
let $ca := substring-after($comment, '''')
let $cb := substring-after($ca, '''')
let $cc := substring-after($cb, '''')
let $cd := substring-after($cc, '''')
let $ce := substring-after($cd, '''')
let $cf := substring-after($ce, '''')
let $cg := substring-after($cf, '''')
let $ch := substring-before($cg, '''')
    let $commenturl := concat("https://s3.parature.com", $ch)
    let $commentfile := substring-before(tokenize($comment, "/")[4], "?")
    let $x := util:log-system-out(concat("commenturl = ", $commenturl))
    let $x := util:log-system-out(concat("commentfile = ", $commentfile))
    let $commentbody := httpclient:get(xs:anyURI($commenturl), false(), ())
    let $x := file:serialize($commentbody, concat("/home/phil/existcomments/", $ticketnum, "_", $commentfile), "")
    let $x := util:log-system-out(" ")
    let $x := util:log-system-out(" ")
    return $commentfile
};

declare function local:grabLongCommentsOldStyle($ticket as item()) as xs:string* {
    for $comment in $ticket//ActionHistory/History/Comments[local:contains-case-insensitive(., '[Click here for Details]')][local:contains-case-insensitive(., 'class=''link2'' target=''_blank''')]/text()
    let $x := util:log-system-out(concat("comment = ", $comment))
    let $ticketnum := $ticket/Ticket_Number/text()
(: old style :)
    let $commenturl := tokenize($comment, """")[2]
    let $commentfile := tokenize(tokenize($comment, '&amp;')[2], '=')[2]
    let $x := util:log-system-out(concat("commenturl = ", $commenturl))
    let $x := util:log-system-out(concat("commentfile = ", $commentfile))
    let $commentbody := httpclient:get(xs:anyURI($commenturl), false(), ())
    let $x := file:serialize($commentbody, concat("/home/phil/existcomments/", $ticketnum, "_", $commentfile), "")
    let $x := util:log-system-out(" ")
    let $x := util:log-system-out(" ")
    return $commentfile
};

declare function local:storeObjectsByDateCreated($baseColl as xs:string, $creationDate as xs:string, $objectid as xs:string, $objects as item()*) as xs:string* {
for $object in $objects
    let $dateSeq := text:groups($creationDate, "(.*)-(.*)-(.*)T")
    let $year := xs:string(subsequence($dateSeq, 2, 1))
    let $month := xs:string(subsequence($dateSeq, 3, 1))
    let $date := xs:string(subsequence($dateSeq, 4, 1))

    let $x := xmldb:create-collection($baseColl, $year)
    let $x := xmldb:create-collection(concat($baseColl, "/", $year), $month)
    let $x := xmldb:create-collection(concat($baseColl, "/", $year, "/", $month), $date)
    
    let $dateColl := concat($baseColl, "/", $year, "/", $month, "/", $date)
    let $r := xmldb:store($dateColl, concat($objectid, ".xml"), $object)
    let $x := util:log-system-out(concat("storeObjectByDateCreated: ", $objectid, " (created ", $creationDate, ") at ", $r))
    return
    concat($dateColl, "/", $objectid)
};

declare function local:getParatureObjectsByQuery2($baseurl as xs:string, $constraint as xs:string, $collection as xs:string, $objecttype as xs:string, $idref as xs:string, $dateref as xs:string, $callout as xs:string, $lookdonttouch as xs:string) as item()* {
    let $startPage := "1"
    let $url := concat($baseurl, "/", $objecttype, "?", $constraint, "&amp;_startPage_=", $startPage, "&amp;_token_=", $local:PARATURETOKEN)
    (: we get the first page of results, to know how many there are :)
    let $response := httpclient:get(xs:anyURI($url), false(), ())
    (: let $x := util:log-system-out($response) :)
    let $rTotal := xs:integer($response//Entities/@total)
    let $rResults := xs:integer($response//Entities/@results)
    let $rPage := xs:integer($response//Entities/@page)
    let $rPageSize := xs:integer($response//Entities/@page-size)
    let $topPage := xs:integer(ceiling($rTotal div $rPageSize))
    let $x := util:log-system-out(concat("topPage=", $topPage))
    return
    <object-by-query baseurl="{$baseurl}" objecttype="{$objecttype}" constraint="{$constraint}" collection="$collection" total="{$rTotal}" results="{$rResults}" page="{$rPage}" page-size="{$rPageSize}" top-page="{$topPage}">
    {
        (: get every page of results :)
        for $pg in (1 to $topPage)
        let $x := util:log-system-out(concat("pg=", $pg, " of ", $topPage))
        let $urlb := concat($baseurl, "/", $objecttype, "?", $constraint, "&amp;_startPage_=", $pg, "&amp;_token_=", $local:PARATURETOKEN)
        let $responseb := httpclient:get(xs:anyURI($urlb), false(), ())
        return
            (: loop through every object on this page :)
            for $obj in util:eval(concat("$responseb//Entities/", $objecttype))
            let $objid := util:eval(concat("$obj/", $idref))
            let $objDateCreated := util:eval(concat("$obj/", $dateref))
            return
                (: now we get the actual item, this is so we can retrieve everything with _history_=true :)
                let $urlc := concat($baseurl, "/", $objecttype, "/", $objid, "?_history_=true&amp;_token_=", $local:PARATURETOKEN)
                (: let $x := util:log-system-out(concat("grabbing ", $urlc)) :) 
                let $responsec := httpclient:get(xs:anyURI($urlc), false(), ())
                (: let $x := util:log-system-out("RESPONSEC DEBUG") :)
                (: let $x := util:log-system-out($responsec) :)
                (: Tickets can contain other Tickets (subcases), focus on the top level Ticket :)
                let $finalObj := util:eval(concat("$responsec/descendant::", $objecttype, "[1]"))
                let $x := util:log-system-out(concat("getParatureObjectsByQuery writing item for ", $objid))
                (: should use lookdonttouch as a conditional here :)
                let $calloutResult := util:eval(concat($callout, "($finalObj)"))
                let $storeResult := local:storeObjectsByDateCreated($collection, $objDateCreated, $objid, $finalObj)
                (: let $x := util:log-system-out(concat("urk, no object found when querying for ", $objid)) :)
(:
		let $x := local:grabLongCommentsNewStyle($finalObj)
		let $x := local:grabLongCommentsOldStyle($finalObj)
:)
                return
                <object id="{$objid}" status="{$responsec/@statusCode}" collection="{$storeResult}" callout="{$calloutResult}"/>
    }</object-by-query>
};

declare function local:grabAndStoreSingleTicket($baseurl as xs:string, $objid as xs:string, $objecttype as xs:string, $collection as xs:string, $callout as xs:string, $dateref as xs:string) as item()* {
                (: now we get the actual item, this is so we can retrieve everything with _history_=true :)
                let $urlc := concat($baseurl, "/", $objecttype, "/", $objid, "?_history_=true&amp;_token_=", $local:PARATURETOKEN)
                (: let $x := util:log-system-out(concat("grabbing ", $urlc)) :) 
                let $responsec := httpclient:get(xs:anyURI($urlc), false(), ())
                (: let $x := util:log-system-out("RESPONSEC DEBUG") :)
                (: let $x := util:log-system-out($responsec) :)
                (: Tickets can contain other Tickets (subcases), focus on the top level Ticket :)
                let $finalObj := util:eval(concat("$responsec/descendant::", $objecttype, "[1]"))
                let $x := util:log-system-out(concat("grabAndStoreSingleTicket writing item for ", $objid))
                let $calloutResult := util:eval(concat($callout, "($finalObj)"))
		let $objDateCreated := util:eval(concat("$finalObj/", $dateref))
		let $x := util:log-system-out(concat("dateref is ", $objDateCreated))
                let $storeResult := local:storeObjectsByDateCreated($collection, $objDateCreated, $objid, $finalObj)
                (: let $x := util:log-system-out(concat("urk, no object found when querying for ", $objid)) :)
		let $x := local:grabLongCommentsNewStyle($finalObj)
		let $x := local:grabLongCommentsOldStyle($finalObj)
                return
                <object id="{$objid}" status="{$responsec/@statusCode}" collection="{$storeResult}" callout="{$calloutResult}"/>
};

declare function local:condenseTicket($ticket as node()) as node()* {
let $x := "hello world"
return
<ftc_ticket>
<ftc_ticketnumber>{$ticket/Ticket_Number/text()}</ftc_ticketnumber>
<ftc_status>{$ticket/Ticket_Status/Status/Name/text()}</ftc_status>
<ftc_datecreated>{$ticket/Date_Created/text()}</ftc_datecreated>
<ftc_dateupdated>{$ticket/Date_Updated/text()}</ftc_dateupdated>
<ftc_assignedto>{$ticket/Assigned_To/Csr/Full_Name/text()}</ftc_assignedto>
<ftc_priority>{$ticket/Custom_Field[@display-name = "Priority"]/Option[@selected = "true"]/Value/text()}</ftc_priority>
<ftc_severity>{$ticket/Custom_Field[@display-name = "Severity"]/Option[@selected = "true"]/Value/text()}</ftc_severity>
<ftc_summary>{$ticket/Custom_Field[@display-name = "Summary"]/text()}</ftc_summary>
<ftc_catenatedfields>{
for $cf in $ticket/Custom_Field[@display-name = "Account" or @display-name = "Application Server" or @display-name = "3rd Party Products" or @display-name = "Details" or @display-name = "Enhancement Number" or @display-name = "JDK Version" or @display-name = "Platform" or @display-name = "PR Number" or @display-name = "Product Name" or @display-name = "Summary"]/text()
| $ticket//Action[@name = "Need More Info" or @name = "Accept Solution" or @name = "Add Notes" or @name = "Assign to CSR" or @name = "Assign to Queue" or @name = "Close (Admin)" or @name = "Close Ticket" or @name = "Customer No Response" or @name = "Customer Requested Hold" or @name = "Decline Solution" or @name = "External Comment" or @name = "Grab Ticket" or @name = "Info Provided" or @name = "Internal Comment" or @name = "L2/L3 Need Info" or @name = "L2/L3 Provide Info" or @name = "L3 PR Created" or @name = "Need More Info" or @name = "Provide Additional Info" or @name = "Reopen Ticket" or @name = "Send to L2" or @name = "Send to L3" or @name = "Send to Services" or @name = "Suggest Solution" or @name = "Waiting on Customer" or @name = "Waiting on L2" or @name = "Waiting on L3" or @name = "Waiting on Services"]/parent::History/Comments/text()
return
string($cf)
}
</ftc_catenatedfields>
</ftc_ticket>
};

declare function local:makeTicketsIndexable($tickets as node()*) as xs:string* {
for $ticket in $tickets
    let $condensed := local:condenseTicket($ticket)
    let $x := local:storeObjectsByDateCreated($local:COLL_PARATURE_FTC, $ticket/Date_Created/string(), $ticket/@id/string(), $condensed)
    return $x 
};

declare function local:doNothing($obj as node()*) as xs:string {
let $x := "hello world"
return ""
};


let $ticketid := request:get-parameter("ticketid", "")

let $start := request:get-parameter("start", "2010-10-01T00:00:00.000Z")
let $end := request:get-parameter("end", "2010-11-01T23:59:59.999Z")
let $starttype := request:get-parameter("starttype", "Date_Updated_min_")
let $endtype := request:get-parameter("endtype", "Date_Updated_max_")
let $objecttype := request:get-parameter("objecttype", "")
let $collection := request:get-parameter("collection", "")
let $idref := request:get-parameter("idref", "@id/string()")
let $dateref := request:get-parameter("dateref", "Date_Created/string()")
let $callout := request:get-parameter("callout", "")
let $lookdonttouch := request:get-parameter("lookdonttouch", "")
let $doit := request:get-parameter("doit", "")
return
<html>
<head>
<title>glob</title>
</head>
<body>
<form action="glob.xql">
ticketid <input size="40" name="ticketid" value="{$ticketid}"/> <p/>

start <input size="40" name="start" value="{$start}"/> <br/>
starttype <input size="40" name="starttype" value="{$starttype}"/> <br/>
end <input size="40" name="end" value="{$end}"/> <br/>
endtype <input size="40" name="endtype" value="{$endtype}"/> <br/>
objecttype
<select name="objecttype">
<option value="Account">Account</option>
<option value="Article">Article</option>
<option value="Customer">Customer</option>
<option value="Article">Article</option>
<option value="Customer">Customer</option>
<option value="Ticket">Ticket</option>
</select>
<!-- input size="40" name="objecttype" value="{$objecttype}" --> <br/>

collection
<select name="collection">
<option value="/db/supportx/parature_accounts">/db/supportx/parature_accounts</option>
<option value="/db/supportx/parature_articles">/db/supportx/parature_articles</option>
<option value="/db/supportx/parature_customers">/db/supportx/parature_customers</option>
<option value="/db/supportx/parature_tickets">/db/supportx/parature_tickets</option>
</select>
<!-- input size="40" name="collection" value="{$collection}" --> <br/>

idref <input size="40" name="idref" value="{$idref}"/> <br/>
dateref <input size="40" name="dateref" value="{$dateref}"/> <br/>
callout 
<select name="callout">
<option value="local:doNothing">local:doNothing</option>
<option value="local:makeTicketsIndexable">local:makeTicketsIndexable</option>
</select>
<!-- input size="40" name="callout" value="{$callout}" --> <br/>
look dont touch? <input size="40" name="lookdonttouch" value="{$lookdonttouch}"/> <br/>
do it? <input size="40" name="doit" value=""/> <br/>
<input type="submit"/>
<input type="reset"/>
</form>

{
if ($doit != "") then
    let $x := xmldb:login($local:APPBASE, $local:ADMINUSER, $local:ADMINPASS)
    let $constraint := concat($starttype, "=", $start, "&amp;", $endtype, "=", $end)
    let $queriedobjects := local:getParatureObjectsByQuery2($local:PARATUREBASEURL, $constraint, $collection, $objecttype, $idref, $dateref, $callout, $lookdonttouch) 

(:    let $queriedobjects := local:grabAndStoreSingleTicket($local:PARATUREBASEURL, $ticketid, $objecttype, $collection, $callout, $dateref) :)

    return
    <textarea rows="30" cols="100">{$queriedobjects}</textarea>
else ()
}

</body>
</html>

