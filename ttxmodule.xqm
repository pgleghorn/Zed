xquery version "1.0" encoding "UTF-8";
module namespace ttxmodule = "http://xproc.net/xproc/ttxmodule";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";

declare variable $ttxmodule:TTCGI := "http://energy.us.oracle.com/scripts/ttcgi.exe";
declare variable $ttxmodule:UNAME := "pgleghorn";
declare variable $ttxmodule:PWORD := "********";

declare function ttxmodule:login() as xs:string {
	let $url := concat($ttxmodule:TTCGI, "?uname=", $ttxmodule:UNAME, "&amp;pword=", $ttxmodule:PWORD, "&amp;Command=Login&amp;databaseid=3&amp;startat=Workbook&amp;Login.x=23&amp;Login.y=2&amp;Login=Login")
	let $r1 := httpclient:get(xs:anyURI($url), true(), ())
	let $cookieval := $r1//BODY/form/input[@NAME = "cookie"]/@VALUE
	return $cookieval
};

declare function ttxmodule:logout($cookieval as xs:string) as node()* {
	let $url := concat($ttxmodule:TTCGI, "?Command=Logout&amp;Cookie=", $cookieval)
	let $r3 := httpclient:get(xs:anyURI($url), true(), ())
	return $r3
};

(: TODO work on many bugs :)
declare function ttxmodule:fetchbug($bugno as xs:string) as node() {
    let $x := util:log-system-out(concat("fetching ", $bugno))
    (: for some insane reason, testtrack xmlexport gives you the bug(s) following the one(s) you want, so decrement first :)
    let $decrementedBugno := xs:integer($bugno) - 1
    let $cookieval := ttxmodule:login()
    let $exportfields :=
<httpclient:fields>
<httpclient:field name="Command" value="XMLExport"/>
<httpclient:field name="ReturnList" value="dfct"/>
<httpclient:field name="UseSelectedRecords" value="1"/>
<httpclient:field name="ExportHistLogInfo" value="1"/>
<httpclient:field name="OkBtn.x" value="51"/>
<httpclient:field name="OkBtn.y" value="11"/>
<httpclient:field name="SelectedRecords" value="{string($decrementedBugno)}"/>
<httpclient:field name="cookie" value="{$cookieval}"/>
</httpclient:fields>
	let $r4 := httpclient:post-form(xs:anyURI($ttxmodule:TTCGI), $exportfields, true(), ())
	let $bug := $r4//defect
	let $x := ttxmodule:logout($cookieval)
	return $bug
};

(: TODO work on many bugs :)
declare function ttxmodule:pushbug($bug as node()) as xs:string {
    (: a few bugs are broken, and dont have a date-entered, so lets stick them here :) 
	let $dateentered := if ($bug/date-entered/text()) then $bug/date-entered/text() else "1/1/1970"
	let $bugno := $bug/defect-number/text()
	let $dateSeq := text:groups($dateentered, "(.*)/(.*)/(.*)")
	let $month := xs:string(subsequence($dateSeq, 2, 1))
	let $date := xs:string(subsequence($dateSeq, 3, 1))
	let $year := xs:string(subsequence($dateSeq, 4, 1))
	(: TODO replace with real base64 encoding when existdb version supports is, this is username:password encoded :)
    let $basicauthheader := concat("Basic ", "********")
    let $headers := <headers><header name="Authorization" value="{$basicauthheader}"/></headers>
    let $puturl := concat("http://localhost:8080/exist/rest/db/supportx/testtrack/", $year, "/", $month, "/", $date, "/", $bugno, ".xml")
    let $x := httpclient:put(xs:anyURI($puturl), $bug, true(), $headers)
    let $x := util:log-system-out(concat("pushbug: ", $bugno, " (created ", concat($date, "/", $month, "/", $year), ")"))
    return $puturl
};


declare function ttxmodule:pushBugsByFilterToDB($filterno as xs:string) as node()* {
	let $cookieval := ttxmodule:login()
	let $url := concat($ttxmodule:TTCGI, "?Command=DefectListAction&amp;cookie=", $cookieval, "&amp;RecordsPerPage=1000&amp;TargetWindow=_self&amp;AltUseFilterBtn=1&amp;DFUS_L=Defect&amp;DFLS_L=defect&amp;DFLP_L=defects&amp;defectnumber=&amp;action=LoadEditDefect&amp;filter=", $filterno)
	let $x := util:log-system-out(concat("pushBugsByFilterToDB Url is ", $url))
	let $r2 := httpclient:get(xs:anyURI($url), false(), ())
	let $x := ttxmodule:logout($cookieval)
	let $buglist := $r2//TR[@CLASS = "listrow1" or @CLASS = "listrow2"]/TD[4]/descendant-or-self::*/text()
	let $count := count($buglist)
	for $bugno at $pos in $buglist
	    let $x := util:log-system-out(concat("processing bug ", $bugno, " (", $pos, " of ", count($buglist), ")"))
	    let $bug := ttxmodule:fetchbug($bugno)
	    let $r := ttxmodule:pushbug($bug)
	    return <p>{$x}</p>
};

