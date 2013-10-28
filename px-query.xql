xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";
let $iFreeText := request:get-parameter("iFreeText", "")
let $iCaseSeverity := request:get-parameter("iCaseSeverity", "")
let $iCaseStatus := request:get-parameter("iCaseStatus", "")
let $iCaseSummary := request:get-parameter("iCaseSummary", "")
let $iCaseOwner := request:get-parameter("iCaseOwner", "")
let $iCaseNumber := request:get-parameter("iCaseNumber", "")
let $iResultsPerPage := xs:integer(request:get-parameter("iResultsPerPage", "10"))
let $iOrderResultsBy := request:get-parameter("iOrderResultsBy", "")
let $iPageNo := xs:integer(request:get-parameter("iPageNo", "1"))
let $concati := concat("iFreeText=", $iFreeText, "&amp;iCaseSeverity=", $iCaseSeverity, "&amp;iCaseStatus=", $iCaseStatus, "&amp;iCaseSummary=", $iCaseSummary, "&amp;iCaseOwner=", $iCaseOwner, "&amp;iResultsPerPage=", $iResultsPerPage, "&amp;iOrderResultsBy=", $iOrderResultsBy) 
let $q1 := if ($iFreeText != "") then "[ft:query(ftc_catenatedfields, $iFreeText)]" else ""
let $q2 := if ($iCaseSummary != "") then "[ft:query(ftc_summary, $iCaseSummary)]" else ""
let $q3 := if ($iCaseSeverity != "") then "[ftc_severity = $iCaseSeverity]" else ""
let $q4 := if ($iCaseStatus != "") then "[ftc_status = $iCaseStatus]" else ""
let $q5 := if ($iCaseOwner != "") then "[ftc_assignedto = $iCaseOwner]" else ""
let $concatq := concat($q1, $q2, $q3, $q4, $q5)
return
<html>
<head><title>case query</title></head>
<body>
{pgglobals:navbar()}
<form method="get" enctype="multipart/form-data" action="px-detail.xql">
Jump to a case number: <input name="iCaseNumber" value="{$iCaseNumber}" size="20"/>
<input type="submit" value="go"/>
</form>
Or search...<p/>
<form method="get" enctype="multipart/form-data" action="px-query.xql">
<table>
<tr><td>search text:</td><td colspan="3"><input name="iFreeText" value="{$iFreeText}" size="100"/>
<br/><i>Uses <a href="http://lucene.apache.org/java/2_4_0/queryparsersyntax.html">lucene query parser</a> syntax. Use "" for phrases, boolean AND / OR, and parenthesis, for example: lucene AND ( "iplanet webserver" OR "apache webserver" )</i></td></tr>
<tr>
<td>summary:</td><td><input name="iCaseSummary" value="{$iCaseSummary}" size="40"/></td>
<td>owner:</td><td><select name="iCaseOwner">{
for $csr in ("", collection("/db/supportx/parature_distinct_fields")//assignedto/text())
order by $csr
return <option value="{$csr}"> {if ($iCaseOwner = $csr) then attribute selected {$csr} else ()}{$csr}</option>
}</select></td>
</tr>
<tr>
<td>status:</td><td><select name="iCaseStatus">{
for $status in ("", collection("/db/supportx/parature_distinct_fields")//status/text())
order by $status
return <option value="{$status}"> {if ($iCaseStatus = $status) then attribute selected {$status} else ()}{$status}</option>
}</select></td>
<td>severity:</td><td><select name="iCaseSeverity">{
for $severity in ("", collection("/db/supportx/parature_distinct_fields")//severity/text())
order by $severity
return <option value="{$severity}"> {if ($iCaseSeverity = $severity) then attribute selected {$severity} else ()} {$severity}</option>
}</select></td>
</tr>
<!--
<td>account:</td><td><input name="iCaseAccount" value="" size="40"/></td>
<td>contact name:</td><td><input name="iCaseContact" value="" size="40"/></td>
<td>number:</td><td><input name="iCaseNumber" value="" size="40"/></td>
-->
<tr>
<!--
<td>find pr->case backreferences</td><td><input type="checkbox" name="iCaseBackrefs"/> (not enabled yet)</td>
<td></td><td></td>
-->
</tr>
<tr><td>results per page</td><td><select name="iResultsPerPage">
<option value="10"> {if ($iResultsPerPage = xs:integer(10)) then attribute selected { 10 } else ()} 10</option>
<option value="20"> {if ($iResultsPerPage = xs:integer(20)) then attribute selected { 20 } else ()} 20</option>
<option value="30"> {if ($iResultsPerPage = xs:integer(30)) then attribute selected { 30 } else ()} 30</option>
<option value="40"> {if ($iResultsPerPage = xs:integer(40)) then attribute selected { 40 } else ()} 40</option>
</select>
</td>
<!--
<td>order results by</td><td><select name="iOrderResultsBy">
<option value="rank">rank</option>
<option value="case number">case number</option>
<option value="date created">date created</option>
<option value="date updated">date updated</option>
<option value="severity">severity</option>
</select> (not enabled yet)</td>
-->
</tr>
<tr><td><input type="submit" value="search"/> </td> </tr>
</table>
</form>
{
if ($concatq != "") then
	let $t1 := current-dateTime()
	let $results := util:eval(concat("collection($pgglobals:PCOLL_FTC)/ftc_ticket", $concatq))
    let $t2 := current-dateTime()
	let $startRange := if ($iPageNo = 1) then 1 else (($iPageNo - 1) * $iResultsPerPage)
	let $endRange := $iPageNo * $iResultsPerPage
	let $maxPage := xs:integer(ceiling(count($results) div $iResultsPerPage))
	let $x := util:log-system-out(concat(request:get-remote-addr(), " searching for ", $concatq, " -- numtickets=", count($results), " iPageNo=", $iPageNo, " startRange=", $startRange, " endRange=", $endRange, " maxPage=", $maxPage))
    let $subsequence := subsequence($results, $startRange, $iResultsPerPage)
    return 
<div>
Found {count($results)} hits for search string {$concatq}, showing page {$iPageNo} of {$maxPage} <font color="white">{$concatq}</font><p/>
{
for $p in (1 to $maxPage)
return <a href="px-query.xql?{$concati}&amp;iPageNo={$p}">{$p}</a>
}
<table border="1">
<tr>
<td>number</td>
<td>summary</td>
<td>customer</td>
<td>contact</td>
<td>assigned to</td>
<td>status</td>
<td>severity</td>
<td>created</td>
<td>updated</td>
<td>subcase</td>
<td>case type</td>
<td>PRs</td>
<td>enhancements</td>
</tr>
{
	for $t in $subsequence
		let $dateSeq := text:groups($t//ftc_datecreated, "(.*)-(.*)-(.*)T")
    	let $year := xs:string(subsequence($dateSeq, 2, 1))
    	let $month := xs:string(subsequence($dateSeq, 3, 1))
    	let $date := xs:string(subsequence($dateSeq, 4, 1))
        let $shortTicketNum := substring-after($t//ftc_ticketnumber, "-")
    	let $thedoc := concat($pgglobals:PCOLL, "/", $year, "/", $month, "/", $date, "/", $shortTicketNum, ".xml" )
    	let $ticket := doc($thedoc)/Ticket
    	(: let $customer := () :)
    	let $customerid := $ticket/Ticket_Customer/Customer/@id/string()
    	let $customer := collection("/db/supportx/parature_customers")/Customer[@id = $customerid]
    	let $prs := text:groups($ticket/Custom_Field[@display-name = "PR Number"]/string(), ",")
    	let $prs2 := tokenize($ticket/Custom_Field[@display-name = "PR Number"]/string(), "[ ,]")
		return
		<tr>
		<td nowrap="true"><a href="px-detail.xql?iCaseNumber={$ticket/Ticket_Number/string()}">{$ticket/Ticket_Number/string()}</a> <a href="https://s3.parature.com/ics/tt/ticketDetail.asp?ticketNum={$ticket/Ticket_Number/string()}">p</a></td>
		<td>{$ticket/Custom_Field[@display-name = "Summary"]/string()}</td>
		<td>{$customer//Account_Name/string()}</td>
		<td>{$customer//First_Name} {$customer//Last_Name/string()}</td>
		<td nowrap="true">{$ticket/Assigned_To/Csr/Full_Name/string()}</td>
		<td nowrap="true">{$ticket/Ticket_Status/Status/Name/string()}</td>
		<td nowrap="true">{$ticket/Custom_Field[@display-name = "Severity"]/Option[@selected = "true"]/string()}</td>
		<td>{$ticket/Date_Created/string()}</td>
		<td>{$ticket/Date_Updated/string()}</td>
		<td>{$ticket/Custom_Field[@display-name = "Subcase Group"]/Option[@selected = "true"]/Value/string()}</td>
		<td>{$ticket/Custom_Field[@display-name = "Case Type"]/Option[@selected = "true"]/Value/string()}</td>
		<td>{
		for $pr in ($prs2)
		return <a href="ttx-detail.xql?iBugNumber={$pr}">{$pr}</a>
		}</td>
		<td>{$ticket/Custom_Field[@display-name = "Enhancement Number"]/string()}</td>
		</tr>
		}
		</table></div>
else ()
}
{pgglobals:footer()}
</body>
</html>
