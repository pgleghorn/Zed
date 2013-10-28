xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";
let $iBugNumber := request:get-parameter("iBugNumber", "")
return
<html>
<head><title></title></head>
<body>
{pgglobals:navbar()}
<form method="get" enctype="multipart/form-data" action="ttx-detail.xql">
<table>
<tr><td>bug number:</td><td><input name="iBugNumber" value="{$iBugNumber}" size="20"/>
<input type="submit"/>
</td></tr>
</table>
</form>
{
if ($iBugNumber != "") then
for $bug in collection($pgglobals:TTCOLL)//defect[defect-number = $iBugNumber]
return
<p>
<h2>{$bug/defect-number/string()} - {$bug/summary/string()} </h2>
<table>
<tr><td>Cases which reference this PR:</td><td>
{pgglobals:ticketsReferencingPRs($bug/defect-number/string())}
</td></tr>
<tr><td>Cases this PR references:</td><td>{$bug/reference/string()}</td></tr>
<tr><td>Entered by:</td><td>{$bug/entered-by/first-name/string()} {$bug/entered-by/last-name/string()}
({$bug/date-entered})<p/></td></tr>
<tr><td>Product:</td><td>{$bug/product/string()}</td></tr>
<tr><td>Type:</td><td>{$bug/type/string()}</td></tr>
<tr><td>Component:</td><td>{$bug/component/string()}</td></tr>
<tr><td>Version found in:</td><td>{$bug/reported-by-record/version-found/string()}</td></tr>
<tr><td>Disposition:</td><td>{$bug/disposition/string()}</td></tr>
<tr><td>Priority:</td><td>{$bug/priority/string()}</td></tr>
<tr><td>Severity:</td><td>{$bug/severity/string()}</td></tr>
<tr><td>Status:</td><td>{$bug/defect-status/string()}</td></tr>
<tr><td>Currently assigned to:</td><td>{$bug/currently-assigned-to/first-name/string()} {$bug/currently-assigned-to/last-name/string()}</td></tr>
<tr><td>Last modified by:</td><td>{$bug/last-modified-by/first-name/string()} {$bug/last-modified-by/last-name/string()} ({$bug/date-last-modified/string()})</td></tr>
<tr><td>Description:</td><td><pre>{util:parse-html($bug/reported-by-record/description/string())}</pre></td></tr>
<tr><td>Steps to reproduce:</td><td><pre>{util:parse-html($bug/reported-by-record/steps-to-reproduce/string())}</pre></td></tr>
</table>
<div>
</div>
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
<textarea rows="80" cols="160">{$bug}</textarea>
</div>
</form>
</p>
else ()
}
{pgglobals:footer()}
</body>
</html>
