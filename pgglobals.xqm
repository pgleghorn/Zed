xquery version "1.0" encoding "UTF-8";
module namespace pgglobals = "http://xproc.net/xproc/pgglobals";
declare variable $pgglobals:PCOLL := "/db/supportx/parature_tickets";
declare variable $pgglobals:PCOLL_FTC := "/db/supportx/parature_tickets_ftc";
declare variable $pgglobals:KBCOLL := "/db/supportx/parature_articles";
declare variable $pgglobals:TTCOLL := "/db/supportx/testtrack";
declare variable $pgglobals:ADMINUSER := "admin";
declare variable $pgglobals:ADMINPASS := "********";
declare variable $pgglobals:PARATURETOKEN := "********";
declare variable $pgglobals:PARATUREBASEURL := "https://s3.parature.com/api/v1/5479/5508/";
declare variable $pgglobals:WORKLIST := "/db/supportx/worklist";
declare function pgglobals:sortableuuid() as xs:string {
  let $x := util:system-dateTime()
  return
    concat(replace(replace(replace($x, "-", ""), ":", ""), "\.", ""), "_", util:uuid())
};
declare function pgglobals:ticketsReferencingPRs($prnumber as xs:string*) as element()* {
  let $ticketList := collection($pgglobals:PCOLL)/Ticket/Custom_Field[ft:query(., $prnumber)]/ancestor::Ticket/Ticket_Number/text()
  for $ticket in $ticketList
  return <div><a href="px-detail.xql?iCaseNumber={$ticket}">{$ticket}</a></div>
};
declare function pgglobals:ticketsReferencedByPR($prnumber as xs:string*) as element()* {
  let $ticketList := collection($pgglobals:PCOLL)/Ticket/Custom_Field[ft:query(., $prnumber)]/ancestor::Ticket/Ticket_Number/text()
  for $ticket in $ticketList
  return <div>{$ticket}</div>
(:  return <div><a href="px-detail.xql?iCaseNumber={$ticket}">{$ticket}</a></div> :)
};
declare function pgglobals:findPRsOnTicket($ticket as node()) as xs:string* { 
      let $z1 := $ticket/Custom_Field[@display-name = 'PR Number']/text()
      let $z2 := $ticket/Custom_Field[@display-name = "Summary"]/text()
      let $zz1 := tokenize($z1, ",")
      let $zz2 := subsequence(text:groups($z2, ".*[^A-Za-z][Pp][Rr][^A-Za-z].*([0-9][0-9][0-9][0-9][0-9])[^0-9]"), 2,1)
      return distinct-values(($zz2,$zz1))
};
declare function pgglobals:buildPRUrls($prs as xs:string*) as node()* {
    for $i in $prs
    return
    <a href="ttx-detail.xql?iNumber={$i}">{$i}</a>
};
declare function pgglobals:parseGetFile($ss as item()*) as item()* {
    let $z := $ss
    let $link := $ss/HTML/BODY/P/A
    return
    $z
};

declare function pgglobals:navbar-hidden() as node()  {
let $x := ()
return
<table border="0" width="100%"><tr width="100%"><td align="left"></td><td align="right">
<a href="kb-query.xql">knowledgebase</a>
<br/>
Logged in as {xmldb:get-current-user()}
</td></tr></table>
};

declare function pgglobals:navbar() as node()  {
let $x := ()
return
<table border="0" width="100%"><tr width="100%"><td align="left"></td><td align="right">
<a href="px-query.xql">cases</a> |
<a href="ttx-query.xql">bugs</a> |
<a href="kb-query.xql">knowledgebase</a> |
<a href="status.xql">status</a>
<br/>
Logged in as {xmldb:get-current-user()}
</td></tr></table>
};

declare function pgglobals:footer() as node()  {
let $x := ()
return
<div align="right"><hr/>
Zed v0.4</div>
};
