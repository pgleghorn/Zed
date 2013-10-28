xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";
let $iKbNumber := request:get-parameter("iKbNumber", "")
return
<html>
<head><title></title></head>
<body>
{pgglobals:navbar()}
<form method="get" enctype="multipart/form-data" action="kb-detail.xql">
<table>
<tr><td>KB number:</td><td><input name="iKbNumber" value="{$iKbNumber}" size="20"/>
<input type="submit"/>
</td></tr>
</table>
</form>
{
if ($iKbNumber != "") then
for $kb in collection($pgglobals:KBCOLL)//Article[@id = $iKbNumber]
return
<p>
<h2>{string($kb/@id)} - {$kb/Question/text()} </h2>
<table border="1">
<tr><td>Created by:</td><td>{$kb/Created_By/Csr/Full_Name/text()}
({$kb/Date_Created/text()})<p/></td></tr>
<tr><td>Modified by:</td><td>{$kb/Modified_By/Csr/Full_Name/text()}
({$kb/Date_Updated/text()})<p/></td></tr>
<tr><td>Folders:</td><td>{$kb/Folders/ArticleFolder/Name/text()}</td></tr>
<tr><td>Permissions:</td><td>{$kb/Permissions/Sla/Name/text()}</td></tr>
<tr><td>Question:</td><td>{util:parse-html($kb/Question)}</td></tr>
<tr><td>Answer:</td><td>{util:parse-html($kb/Answer)}</td></tr> 
<!-- <tr><td>Answer:</td><td><textarea>{util:parse-html($kb/Answer/text())}</textarea></td></tr> -->
</table>
<div>
</div>

<!--
<script language="text/javascript"><![CDATA[
function setVisibility(id, visibility) {
document.all[id].style.display = visibility;
}
]]></script> 

<form name="Teste">
<div id="main" style="display:inline">
<input value="show raw xml" type="button" onClick="setVisibility('main', 'none');setVisibility('sub', 'inline');"/>
</div>
<div id="sub" style="display:none">
<input value="hide raw xml" type="button" onClick="setVisibility('main', 'inline');setVisibility('sub', 'none');"/>
<textarea rows="80" cols="160">{$kb}</textarea>
</div>
</form>
-->
</p>
else ()
}
{pgglobals:footer()}
</body>
</html>
