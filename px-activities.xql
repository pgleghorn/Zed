xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
declare option exist:timeout "60000";
declare option exist:serialize "method=xhtml media-type=text/html";
let $who := request:get-parameter("who", "Max Power")
let $begindate := request:get-parameter("begin", "2009-12-14")
let $enddate := request:get-parameter("end", "2009-12-31")
return
<html>
<head></head>
<body>
<table border="2">
<tr>
<th>action type</th>
<th>ticket</th>
<th>performer</th>
<th>show to customer</th>
<th>date</th>
<th>comment</th>
</tr>
{
for $i in //Ticket/ActionHistory/History[//Action_Performer/Csr/Full_Name = $who]
let $ticket := $i/ancestor::Ticket
where $i/Action_Date > $begindate
and $i/Action_Date < $enddate
order by $i/Action_Date/text()
return
<tr>
<td>{string($i/Action/@name)}</td>
<td>{string($ticket/Ticket_Number)}</td>
<td>{string($i/Action_Performer/Csr/Full_Name)}</td>
<td>{$i/Show_To_Customer/text()}</td>
<td>{$i/Action_Date/text()}</td>
<td>{string(util:parse-html($i/Comments/text()))}</td>
</tr>
}
</table>
</body>
</html>
