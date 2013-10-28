xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";
declare option exist:timeout "60000";
declare function local:ticketsReferencingPR($prnumber as xs:string*) as xs:string* {
  collection($pgglobals:PCOLL)/Ticket/Custom_Field[@display-name="PR Number"]/text()[contains(.,$prnumber)]/ancestor::Ticket/Ticket_Number/text()
};
let $iFreeText := request:get-parameter("iFreeText", "")
let $iCaseRefs := request:get-parameter("iCaseRefs", "")
let $iBugSummary := request:get-parameter("iBugSummary", "")
let $iBugPriority := request:get-parameter("iBugPriority", "")
let $iBugType := request:get-parameter("iBugType", "")
let $iBugProduct := request:get-parameter("iBugProduct", "")
let $iBugComponent := request:get-parameter("iBugComponent", "")
let $iBugSeverity := request:get-parameter("iBugSeverity", "")
let $iBugDisposition := request:get-parameter("iBugDisposition", "")
let $iBugStatus := request:get-parameter("iBugStatus", "")
let $iBugNumber := request:get-parameter("iBugNumber", "")
let $iResultsPerPage := xs:integer(request:get-parameter("iResultsPerPage", "10"))
let $iOrderResultsBy := request:get-parameter("iOrderResultsBy", "")
let $iPageNo := xs:integer(request:get-parameter("iPageNo", "1"))
let $concati := concat("iFreeText=", $iFreeText, "&amp;iCaseRefs=", $iCaseRefs, "&amp;iBugSummary=", $iBugSummary, "&amp;iBugPriority=", $iBugPriority, "&amp;iBugType=", $iBugType, "&amp;iBugProduct=", $iBugProduct, "&amp;iBugComponent=", $iBugComponent, "&amp;iBugSeverity=", $iBugSeverity, "&amp;iBugDisposition=", $iBugDisposition, "&amp;iBugStatus=", $iBugStatus, "&amp;iResultsPerPage=", $iResultsPerPage, "&amp;iOrderResultsBy=", $iOrderResultsBy) 
let $q1 := if ($iFreeText != "") then "[ft:query(., $iFreeText)]" else ""
let $q2 := if ($iBugSummary != "") then "[ft:query(summary, $iBugSummary)]" else ""
let $q3 := if ($iBugPriority != "") then "[priority = $iBugPriority]" else ""
let $q4 := if ($iBugType != "") then "[type = $iBugType]" else ""
let $q5 := if ($iBugProduct != "") then "[product = $iBugProduct]" else ""
let $q6 := if ($iBugComponent != "") then "[component = $iBugComponent]" else ""
let $q7 := if ($iBugSeverity != "") then "[severity = $iBugSeverity]" else ""
let $q8 := if ($iBugDisposition != "") then "[disposition = $iBugDisposition]" else ""
let $q9 := if ($iBugStatus != "") then "[defect-status = $iBugStatus]" else ""
let $concatq := concat($q1, $q2, $q3, $q4, $q5, $q6, $q7, $q8, $q9)
return
<html>
<head><title>testtrack query</title></head>
<body>
{pgglobals:navbar()}
<form method="get" enctype="multipart/form-data" action="ttx-detail.xql">
Jump to a bug number: <input name="iBugNumber" value="{$iBugNumber}" size="20"/>
<input type="submit" value="go"/>
</form>
Or search...<p/>
<form method="get" enctype="multipart/form-data" action="ttx-query.xql">
<table>
<tr><td>search text:</td><td colspan="3"><input name="iFreeText" value="{$iFreeText}" size="100"/>
<br/><i>Uses <a href="http://lucene.apache.org/java/2_4_0/queryparsersyntax.html">lucene query parser</a> syntax. Use "" for phrases, boolean AND / OR, and parenthesis, for example: lucene AND ( "iplanet webserver" OR "apache webserver" )</i></td></tr>
<tr>
<td>summary:</td><td><input name="iBugSummary" value="{$iBugSummary}" size="40"/></td>
<td>priority:</td><td><select name="iBugPriority">{
for $priority in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//priority/text()))
order by $priority
return <option value="{$priority}"> {if ($iBugPriority = $priority) then attribute selected {$priority} else ()}{$priority}</option>
}</select></td>
</tr>
<tr>
<td>type:</td><td><select name="iBugType">{
for $type in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//type/text()))
order by $type
return <option value="{$type}"> {if ($iBugType = $type) then attribute selected {$type} else ()}{$type}</option>
}</select></td>
<td>product:</td><td><select name="iBugProduct">{
for $prod in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//product/text()))
order by $prod
return <option value="{$prod}"> {if ($iBugProduct = $prod) then attribute selected {$prod} else ()}{$prod}</option>
}</select></td>
</tr>
<tr>
<td>component:</td><td><select name="iBugComponent">{
for $comp in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//component/text()))
order by $comp
return <option value="{$comp}"> {if ($iBugComponent = $comp) then attribute selected {$comp} else ()}{$comp}</option>
}</select></td>
<td>severity:</td><td><select name="iBugSeverity">{
for $sev in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//severity/text()))
order by $sev
return <option value="{$sev}"> {if ($iBugSeverity = $sev) then attribute selected {$sev} else ()}{$sev}</option>
}</select></td>
</tr>
<tr>
<td>disposition:</td><td><select name="iBugDisposition">{
for $disp in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//disposition/text()))
order by $disp
return <option value="{$disp}"> {if ($iBugDisposition = $disp) then attribute selected {$disp} else ()}{$disp}</option>
}</select></td>
<td>status:</td><td><select name="iBugStatus">{
for $status in ("", distinct-values(collection("/db/supportx/testtrack_distinct_fields")//status/text()))
order by $status
return <option values="{$status}"> {if ($iBugStatus = $status) then attribute selected {$status} else ()}{$status}</option>
}</select></td>
</tr>
<tr>
<td>results per page</td><td><select name="iResultsPerPage">
<option value="10"> {if ($iResultsPerPage = xs:integer(10)) then attribute selected { 10 } else ()} 10</option>
<option value="20"> {if ($iResultsPerPage = xs:integer(20)) then attribute selected { 20 } else ()} 20</option>
<option value="30"> {if ($iResultsPerPage = xs:integer(30)) then attribute selected { 30 } else ()} 30</option>
<option value="40"> {if ($iResultsPerPage = xs:integer(40)) then attribute selected { 40 } else ()} 40</option>
</select>
</td>
<!--
<td>order results by</td><td><select name="iOrderResultsBy">
<option value="rank">rank</option>
<option value="bug number">case number</option>
<option value="date created">date created</option>
<option value="date updated">date updated</option>
<option value="severity">severity</option>
</select> (not enabled yet)</td>
-->
</tr>
<tr><td><input type="submit" value="search"/></td></tr>
</table>
</form>
{
if ($concatq != "") then
	let $t1 := current-dateTime()
	let $results := util:eval(concat("collection($pgglobals:TTCOLL)/defect", $concatq))
    let $t2 := current-dateTime()
	let $startRange := if ($iPageNo = 1) then 1 else (($iPageNo - 1) * $iResultsPerPage)
	let $endRange := $iPageNo * $iResultsPerPage
	let $maxPage := xs:integer(ceiling(count($results) div $iResultsPerPage))
	let $x := util:log-system-out(concat(request:get-remote-addr(), " searching for ", $concatq, " -- numbugs=", count($results), " iPageNo=", $iPageNo, " startRange=", $startRange, " endRange=", $endRange, " maxPage=", $maxPage))
    let $subsequence := subsequence($results, $startRange, $iResultsPerPage)
    return 
<div>
Found {count($results)} hits for search string {$concatq}, showing page {$iPageNo} of {$maxPage} <font color="white">{$concatq}</font><p/>
{
for $p in (1 to $maxPage)
return <a href="ttx-query.xql?{$concati}&amp;iPageNo={$p}">{$p}</a>
}
<table>
<tr>
<td>number</td>
<td>summary</td>
<td>disposition</td>
<td>version-fixed-in</td>
<td>resolution</td>
<td>status</td>
<td>type</td>
<td>last-modified</td>
<td>date-entered</td>
<td>cases that refer to this bug</td>
<td>cases this bug refer to</td>
</tr>
{
for $bug in $subsequence
return
<tr>
<td><a href="ttx-detail.xql?iBugNumber={$bug/defect-number/string()}">{$bug/defect-number/string()}</a></td>
<td>{$bug/summary/string()}</td>
<td>{$bug/disposition/string()}</td>
<td>{$bug/fix-event/version-fixed-in/string()}</td>
<td>{$bug/fix-event/resolution/string()}</td>
<td>{$bug/defect-status/string()}</td>
<td>{$bug/type/string()}</td>
<td>{$bug/date-last-modified/string()}</td>
<td>{$bug/date-entered/string()}</td>
<td>(not enabled yet)</td>
<td><a href="px-detail.xql?iCaseNumber={$bug/reference/string()}">{$bug/reference/string()}</a></td>
</tr>
}
</table></div>
else ()
}
{pgglobals:footer()}
</body>
</html>
