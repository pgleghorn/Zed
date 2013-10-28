xquery version "1.0";

import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";

declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";

let $x := ""
return
<html>
<body>
<table>
<tr><td>createdby</td><td>total</td><td>published</td><td>unpublished</td></tr>
{
for $createdby in for $who in ("", distinct-values(collection($pgglobals:KBCOLL)//Created_By))
order by $who
return $who
order by $createdby
return
<tr>
<td>{$createdby}</td>
<td>{count(collection($pgglobals:KBCOLL)/Article[Created_By = $createdby])}</td>
<td>{count(collection($pgglobals:KBCOLL)/Article[Created_By = $createdby][Published = "true"])}</td>
<td>{count(collection($pgglobals:KBCOLL)/Article[Created_By = $createdby][Published = "false"])}</td>
</tr>
}
</table>
</body>
</html>

