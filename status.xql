xquery version "1.0";
import module namespace pgglobals="http://xproc.net/xproc/pgglobals" at "pgglobals.xqm";
import module namespace ttxmodule="http://xproc.net/xproc/ttxmodule" at "ttxmodule.xqm";
declare option exist:serialize "method=xhtml media-type=text/html";
let $x := "hello world"
return
<html>
<head><title>status!</title></head>
<body>
{pgglobals:navbar()}
<table>
<tr><td>Number of parature tickets:</td><td>{count(collection($pgglobals:PCOLL)/Ticket)} (ftc {count(collection($pgglobals:PCOLL_FTC)/ftc_ticket)})</td></tr>
<tr><td>Last parature ticket created:</td><td>
{
let $max-date := (for $d in collection($pgglobals:PCOLL)//Ticket/Date_Created
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td>
</tr>
<tr><td>Last parature ticket updated:</td><td>
{
let $max-date := (for $d in collection($pgglobals:PCOLL)//Ticket/Date_Updated
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td></tr>
<tr><td>Number of parature tickets created by year</td>
<td>
{
for $i in (2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000)
return <div>{$i}: {count(collection(concat($pgglobals:PCOLL, "/", $i))//Ticket/Date_Created)} (ftc {count(collection(concat($pgglobals:PCOLL_FTC, "/", $i))//ftc_ticket)})<br/></div>
}
</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of kb entries:</td><td>{count(collection($pgglobals:KBCOLL)/Article)} (visible {count(collection($pgglobals:KBCOLL)/Article[Published = "true"])})</td></tr>
<tr><td>Last kb entry created:</td><td>
{
let $max-date := (for $d in collection($pgglobals:KBCOLL)/Article/Date_Created
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td>
</tr>
<tr><td>Last kb entry updated:</td><td>
{
let $max-date := (for $d in collection($pgglobals:KBCOLL)/Article/Date_Updated
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td></tr>
<tr><td>Number of kb entries created by year</td>
<td>
{
for $i in (2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000)
return <div>{$i}: {count(collection(concat($pgglobals:KBCOLL, "/", $i))/Article)} (visible {count(collection(concat($pgglobals:KBCOLL, "/", $i))/Article[Published = "true"])})<br/></div>
}
</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of Customer entries:</td><td>{count(collection("/db/supportx/parature_customers")//Customer)} </td></tr>
<tr><td>Last Customer created:</td><td>
{
let $max-date := (for $d in collection("/db/supportx/parature_customers")//Customer/Date_Created
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td>
</tr>
<tr><td>Last Customer updated:</td><td>
{
let $max-date := (for $d in collection("/db/supportx/parature_customers")//Customer/Date_Updated
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td></tr>
<tr><td>Number of Customer entries created by year</td>
<td>
{
for $i in (2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000)
return <div>{$i}: {count(collection(concat("/db/supportx/parature_customers/", $i))//Customer)} <br/></div>
}
</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of Account entries:</td><td>{count(collection("/db/supportx/parature_accounts")//Account)} </td></tr>
<tr><td>Last Account created:</td><td>
{
let $max-date := (for $d in collection("/db/supportx/parature_accounts")//Account/Date_Created
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td></tr>
<tr><td>Last Account updated:</td><td>
{
let $max-date := (for $d in collection("/db/supportx/parature_accounts")//Account/Date_Updated
  order by $d descending
  return $d)
return subsequence($max-date, 1, 1)/text()
}
</td></tr>
<tr><td>Number of Account entries created by year</td>
<td>
{
for $i in (2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000)
return <div>{$i}: {count(collection(concat("/db/supportx/parature_accounts/", $i))//Account)} <br/></div>
}
</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of testtrack bugs:</td><td>{count(collection($pgglobals:TTCOLL)//defect)} </td></tr>
<tr><td>Number of testtrack bugs created by year</td>
<td>
{
for $i in (2011, 2010, 2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000)
return <div>{$i}: {count(collection(concat($pgglobals:TTCOLL, "/", $i))//defect)}<br/></div>
}
</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of omkt-tech-questions messages:</td><td>{count(collection("/db/supportx/omkt-tech-questions")//message)} </td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of ips-link messages:</td><td>{count(collection("/db/supportx/ips-link")//message)} </td></tr>
<tr><td><hr/></td></tr>
<tr><td>accompa</td></tr>
<tr><td><hr/></td></tr>
<tr><td>Number of items in the worklist:</td><td>{count(collection($pgglobals:WORKLIST))} </td></tr>
<tr><td>eXist build:</td><td>{system:get-build()}</td></tr>
<tr><td>eXist version:</td><td>{system:get-version()}</td></tr>
<tr><td>system date/time:</td><td>{util:system-dateTime()}</td></tr>
<tr><td>Session attributes</td><td>
Session exists: {session:exists()} <br/>
Current user: {xmldb:get-current-user()} <br/>
User group: {xmldb:get-user-groups(xmldb:get-current-user())} <br/>
Is admin user: {xmldb:is-admin-user(xmldb:get-current-user())}
</td></tr>
</table>
<p/>
{xmldb:login($pgglobals:PCOLL, $pgglobals:ADMINUSER, $pgglobals:ADMINPASS)}
<p/>
Scheduled jobs:<br/>
<textarea cols="140" rows="20">{system:get-scheduled-jobs()}</textarea> <p/>
Running jobs:<br/>
<textarea cols="140" rows="5">{system:get-running-jobs()}</textarea> <p/>
Running xquery:<br/>
<textarea cols="141" rows="10" >{system:get-running-xqueries()}</textarea> <p/>
{xmldb:login($pgglobals:PCOLL, "guest", "guest")}
{pgglobals:footer()}
</body>
</html>
