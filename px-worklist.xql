xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
import module namespace ttxmodule="http://xproc.net/xproc/ttxmodule" at "ttxmodule.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";
declare function local:processItem($itemDoc as xs:string) as xs:string* {
    let $path := concat($pgglobals:WORKLIST, "/", $itemDoc)
    let $item := doc($path)/item
    let $arg := $item/@arg
    let $qry := concat($item/@command, "($arg)") 
    (: let $x := util:log-system-out(concat("eval ", $qry, " where arg=", $arg)) :)
    let $r := util:catch("*", util:eval($qry, true()), local:errorHandler())
    let $x := util:log-system-out($r)
    return if ($r = "EVAL FAILED") then $r else xmldb:remove($pgglobals:WORKLIST, $itemDoc)
(:     let $x := xmldb:remove($pgglobals:WORKLIST, $itemDoc) 
    return $itemDoc :)
};
declare function local:errorHandler() as xs:string {
    let $x := util:log-system-out(concat("***FAILED***: [exception=", $util:exception, "] [message=", $util:exception-message, "]"))
    return "EVAL FAILED"
};
let $batch := xs:integer(request:get-parameter("batch", "10"))
let $x := xmldb:login($pgglobals:PCOLL, $pgglobals:ADMINUSER, $pgglobals:ADMINPASS)
let $itemDocs := xmldb:get-child-resources($pgglobals:WORKLIST)
let $itemDocsSubsequence := subsequence($itemDocs, 1, $batch)
let $x := util:log-system-out(concat("px-worklist running, found ", count($itemDocs), " items to process, selected a subsequence of ", count($itemDocsSubsequence)))
for $itemDoc at $pos in $itemDocsSubsequence
    let $path := concat($pgglobals:WORKLIST, "/", $itemDoc)
    let $item := doc($path)/item
    let $x := util:log-system-out(concat("found item: ", $item/@command, " ", $item/@arg, " (", $pos, " of ", count($itemDocsSubsequence), ")"))
    let $z := local:processItem($itemDoc) 
    return <p>{$z}</p>
