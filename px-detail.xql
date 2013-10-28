xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";
let $iCaseNumber := request:get-parameter("iCaseNumber", "")
return
<html>
<head><title>parature detail</title></head>
<body>
{pgglobals:navbar()}
<form method="get" enctype="multipart/form-data" action="px-detail.xql">
<table>
<tr><td>case number:</td><td><input name="iCaseNumber" value="{$iCaseNumber}" size="20"/>
<input type="submit"/>
</td></tr>
</table>
</form>
{
if ($iCaseNumber != "") then
for $ticket in collection($pgglobals:PCOLL)/Ticket[Ticket_Number eq $iCaseNumber]
return
<p>
<h2>{$ticket/Ticket_Number/text()} - {string($ticket/Custom_Field[@display-name = "Summary"])} </h2>
<table cellspacing="10">
<tr><td>Case-to-PR references:</td>
<td><a href="ttx-detail.xql?iBugNumber={$ticket/Custom_Field[@display-name = 'PR Number']/text()}">{$ticket/Custom_Field[@display-name = 'PR Number']/text()}</a></td>
<td>Date created:</td>
<td>{string($ticket/Date_Created)}</td></tr>
<tr><td>PR-to-Case references:</td>
<td>r3</td>
<td>Date updated:</td>
<td>{string($ticket/Date_Updated)}</td></tr>
<tr><td>Status:</td>
<td>{string($ticket/Ticket_Status/Status/Name)}</td>
<td>Subcases:</td>
<td><a href="px-detail.xql?iCaseNumber={$ticket/Ticket_Children/Ticket/Ticket_Number}">{$ticket/Ticket_Children/Ticket/Ticket_Number}</a></td></tr>
<tr><td>Currently assigned to:</td>
<td>{string($ticket/Assigned_To/Csr/Full_Name)}</td>
<td>Parent cases:</td>
<td>...</td></tr>
<tr><td>Details:</td>
<td colspan="5">{util:parse-html($ticket/Custom_Field[@display-name = "Details"]/text())}</td></tr>
{
for $history in $ticket/ActionHistory/History
order by $history/Action_Date
return
<tr bgcolor="#eeeeee"><td>{string($history/Action/@name)}:</td><td colspan="3">
    <table cellspacing="0" width="100%">
    <tr width="100%" bgcolor="#cccccc"><td width="30%">Show to customer: {string($history/Show_To_Customer)}</td><td width="30%">{string($history/Action_Date)}</td><td width="30%">{string($history/Action_Performer/Csr/Full_Name)}</td></tr>
    <tr><td colspan="3">{util:parse-html(pgglobals:parseGetFile($history/Comments))}</td></tr></table></td></tr>
}
</table>
<p/>
<script type="text/javascript">
<![CDATA[
function setVisibility(id, visibility) {
document.all[id].style.display = visibility;
}
]]>
</script> 
<form name="Teste">
<div id="main" style="display:block">
<input value="show raw xml" type="button" onClick="setVisibility('main', 'none');setVisibility('sub', 'inline');"/>
</div>
<div id="sub" style="display:none">
<input value="hide raw xml" type="button" onClick="setVisibility('main', 'inline');setVisibility('sub', 'none');"/>
<textarea rows="80" cols="160">{$ticket}</textarea>
</div>
</form>
</p>
else ()
}
{pgglobals:footer()}
</body>
</html>
