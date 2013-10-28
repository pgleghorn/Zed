xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
import module namespace ttxmodule="http://xproc.net/xproc/ttxmodule" at "ttxmodule.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";
let $x := "hello world"
return
<html>
{
ttxmodule:addBugsToWorklist(request:get-parameter("reportnum", "327"))}
<!--
reports
332 is !TTX all bugs
327 is !TTX bugsmodified in last 7 days
333 is !TTX one bug
-->
</html>
