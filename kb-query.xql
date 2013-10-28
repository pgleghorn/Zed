xquery version "1.0";

import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";

declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";

let $iFreeText := request:get-parameter("iFreeText", "")
let $iKbPublished := request:get-parameter("iKbPublished", "")
let $iKbCreatedBy := request:get-parameter("iKbCreatedBy", "")
let $iKbModifiedBy := request:get-parameter("iKbModifiedBy", "")
let $iKbFolder := request:get-parameter("iKbFolder", "")
let $iKbPermissions := request:get-parameter("iKbPermissions", "")
let $iShowAnswer := request:get-parameter("iShowAnswer", "")

let $iKbNumber := request:get-parameter("iKbNumber", "")

let $iResultsPerPage := xs:integer(request:get-parameter("iResultsPerPage", "10"))
let $iOrderResultsBy := request:get-parameter("iOrderResultsBy", "")
let $iAscendingOrDescending := request:get-parameter("iAscendingOrDescending", "")
let $iPageNo := xs:integer(request:get-parameter("iPageNo", "1"))

let $orderByLookups :=
<orderbylookups>
  <orderby key="rating" value="Rating/number()"/>
  <orderby key="views" value="Times_Viewed/number()"/>
  <orderby key="date created" value="Date_Created/string()"/>
  <orderby key="date updated" value="Date_Updated/string()"/>
  <orderby key="kb number" value="@id/number()"/>
</orderbylookups>

let $concati := concat("iFreeText=", $iFreeText, "&amp;iKbPublished=", $iKbPublished, "&amp;iKbCreatedBy=", $iKbCreatedBy, "&amp;iKbModifiedBy=", $iKbModifiedBy, "&amp;iKbFolder=", $iKbFolder, "&amp;iKbPermissions=", $iKbPermissions, "&amp;iShowAnswer=", $iShowAnswer, "&amp;iResultsPerPage=", $iResultsPerPage, "&amp;iOrderResultsBy=", $iOrderResultsBy) 

let $q1 := if ($iFreeText != "") then "[ft:query(., $iFreeText)]" else ""
let $q2 := if ($iKbPublished != "") then "[Published = $iKbPublished]" else ""
let $q3 := if ($iKbCreatedBy != "") then "[Created_By/Csr/Full_Name = $iKbCreatedBy]" else ""
let $q4 := if ($iKbModifiedBy != "") then "[Modified_By/Csr/Full_Name = $iKbModifiedBy]" else ""
let $q5 := if ($iKbFolder != "") then "[Folders/ArticleFolder/Name = $iKbFolder]" else ""

(: let $concatq := concat($q1, $q2, $q3, $q4, $q5) :)
let $concatq := concat($q1, $q2, $q3, $q4, $q5)

return
<html>
<head><title>kb query</title></head>
<body>
{pgglobals:navbar()}

<form method="get" enctype="multipart/form-data" action="kb-detail.xql">
Jump to a kb entry number: <input name="iKbNumber" value="{$iKbNumber}" size="20"/>
<input type="submit" value="go"/>
</form>

Or search... <p/>

<form method="get" enctype="multipart/form-data" action="kb-query.xql">
<table>
<tr>
<td>search text:</td><td colspan="3"><input name="iFreeText" value="{$iFreeText}" size="100"/>
<br/><i>Uses <a href="http://lucene.apache.org/java/2_4_0/queryparsersyntax.html">lucene query parser</a> syntax. Use "" for phrases, boolean AND / OR, and parenthesis, for example: lucene AND ( "iplanet webserver" OR "apache webserver" )</i></td></tr>

<tr>

<td>created by:</td><td><select name="iKbCreatedBy">{
for $createdby in for $who in ("", distinct-values(collection($pgglobals:KBCOLL)//Created_By))
order by $who
return $who
order by $createdby
return <option value="{$createdby}"> {if ($iKbCreatedBy = $createdby) then attribute selected {$createdby} else ()}{$createdby}</option>
}</select></td>

<td>modified by:</td><td><select name="iKbModifiedBy">{
for $modifiedby in for $who in ("", distinct-values(collection($pgglobals:KBCOLL)//Modified_By))
order by $who
return $who
order by $modifiedby
return <option value="{$modifiedby}"> {if ($iKbModifiedBy = $modifiedby) then attribute selected {$modifiedby} else ()}{$modifiedby}</option>
}</select></td>

</tr>


<tr>
<td>published:</td><td><select name="iKbPublished">{
for $published in ("", "true", "false")
order by $published
return <option value="{$published}"> {if ($iKbPublished = $published) then attribute selected {$published} else ()}{$published}</option>
}</select></td>

<td>folder:</td><td><select name="iKbFolder">{
for $folder in ("", distinct-values(//ArticleFolder//Name))
order by $folder
return <option value="{$folder}"> {if ($iKbFolder = $folder) then attribute selected {$folder} else ()}{$folder}</option>
}</select></td>

</tr>

<tr><td>results per page</td><td><select name="iResultsPerPage">
<option value="10"> {if ($iResultsPerPage = xs:integer(10)) then attribute selected { 10 } else ()} 10</option>
<option value="20"> {if ($iResultsPerPage = xs:integer(20)) then attribute selected { 20 } else ()} 20</option>
<option value="30"> {if ($iResultsPerPage = xs:integer(30)) then attribute selected { 30 } else ()} 30</option>
<option value="40"> {if ($iResultsPerPage = xs:integer(40)) then attribute selected { 40 } else ()} 40</option>
<option value="1000000"> {if ($iResultsPerPage = xs:integer(1000000)) then attribute selected { 1000000 } else ()} 1000000</option>
</select>
</td>

<td>order results by</td><td>
<select name="iOrderResultsBy">{
for $ordering in ("$article/@id/number()", "$article/Rating/number()", "$article/Times_Viewed/number()", "$article/Date_Created/string()", "$article/Date_Updated/string()")
order by $ordering
return <option value="{$ordering}"> {if ($iOrderResultsBy = $ordering) then attribute selected {$ordering} else ()}{$ordering}</option>
}</select>

<select name="iAscendingOrDescending">{
for $ascdec in ("ascending", "descending")
order by $ascdec
return <option value="{$ascdec}"> {if ($iAscendingOrDescending = $ascdec) then attribute selected {$ascdec} else ()}{$ascdec}</option>
}</select>
</td>

</tr>

<tr><td>Show Answer:</td><td><input type="checkbox" name="iShowAnswer" checked="{$iShowAnswer}"/></td></tr>

<tr><td><input type="submit" value="search"/> </td> </tr>
</table>
</form>


{
if ($concatq != "") then
	let $t1 := current-dateTime()
	
	let $expr1 := concat("for $article in collection(", $pgglobals:KBCOLL, ")/Article", $concatq, " ")
	let $expr2 := concat("order by ", $iOrderResultsBy, " ", $iAscendingOrDescending, " ")
	let $expr3:= "return $article"
	let $expr := concat($expr1, $expr2, $expr3)

	(: let $results := util:eval(concat("collection($pgglobals:KBCOLL)/Article", $concatq)) :)
	
	let $results := util:eval($expr)
	
    let $t2 := current-dateTime()
	let $startRange := if ($iPageNo = 1) then 1 else (($iPageNo - 1) * $iResultsPerPage)
	let $endRange := $iPageNo * $iResultsPerPage
	let $maxPage := xs:integer(ceiling(count($results) div $iResultsPerPage))
	let $x := util:log-system-out(concat(request:get-remote-addr(), " searching for ", $concatq, " -- numKbs=", count($results), " iPageNo=", $iPageNo, " startRange=", $startRange, " endRange=", $endRange, " maxPage=", $maxPage))

    let $subsequence := subsequence($results, $startRange, $iResultsPerPage)

    return 
<div>
Found {count($results)} hits for search string {$concatq}, showing page {$iPageNo} of {$maxPage} <font color="white">{$concatq}</font><p/>
{
for $p in (1 to $maxPage)
return <a href="kb-query.xql?{$concati}&amp;iPageNo={$p}">{$p}</a>
}
<table name="query_results" border="1">
<tr>
<td>parature solution number</td>
<td bgcolor="#ffff99">new oracle KM number</td>
<td>published</td>
<td>folders</td>
<td>question</td>
{
if ($iShowAnswer != "") then
<td>answer</td>
else ()
}
<td>created by</td>
<td>modified by</td>
<td>created</td>
<td>updated</td>
<!--
<td>viewed</td>
<td>rating</td>
-->
</tr>
{
	for $kb in $subsequence
	    let $kbid := $kb/@id/string()
		let $x := util:log("error", $kbid)
		return
		<tr>
<!--
		<td>{$kbid}</td>
-->
 		<td nowrap="true"><a href="kb-detail.xql?iKbNumber={$kbid}">{$kbid}</a> </td>
<!--
		<td nowrap="true"><a href="https://s3.parature.com/ics/km/kmRefEdit.asp?questionID={$kbid}">{$kbid}</a> </td>
-->
		<td bgcolor="#ffff99"> </td>
		<td>{$kb/Published/string()}</td>
		<td>{$kb/Folders//Name/string()}</td>
		<td>{util:parse-html($kb/Question/string())}</td>
{
if ($iShowAnswer != "") then
		<td>{util:parse-html($kb/Answer/string())}</td>
else ()
}
		<td>{$kb/Created_By//Full_Name/string()}</td>
		<td>{$kb/Modified_By//Full_Name/string()}</td>
		<td>{$kb/Date_Created/string()}</td>
		<td>{$kb/Date_Updated/string()}</td>
<!--
		<td>{$kb/Times_Viewed/string()}</td>
		<td>{$kb/Rating/string()}</td>
-->
		</tr>
		}
		</table></div>
else
<i>no query specified, please specify at least one criteria</i>
}
{pgglobals:footer()}

</body>
</html>



