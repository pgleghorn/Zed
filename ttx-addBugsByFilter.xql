xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
import module namespace ttxmodule="http://xproc.net/xproc/ttxmodule" at "ttxmodule.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";

let $x := "hello world"
return
<html>
{
(: ttxmodule:addBugsToWorklistByFilter(request:get-parameter("filterno", "2328")) :)
ttxmodule:pushBugsByFilterToDB(request:get-parameter("filterno", "2328"))
}
<!--

filters
2328 is !bugs created between range
2522 is ! only one bug
-->
</html>


