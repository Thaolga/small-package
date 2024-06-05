module("luci.controller.shadowsocksr",package.seeall)
function index()
if not nixio.fs.access("/etc/config/shadowsocksr")then
call("act_reset")
end
local e
e=entry({"admin","services","shadowsocksr"},alias("admin","services","shadowsocksr","client"),_("ShadowSocksR Plus+"),10)
e.dependent=true
e.acl_depends={"luci-app-ssr-plus"}
entry({"admin","services","shadowsocksr","client"},cbi("shadowsocksr/client"),_("SSR Client"),10).leaf=true
entry({"admin","services","shadowsocksr","servers"},arcombine(cbi("shadowsocksr/servers",{autoapply=true}),cbi("shadowsocksr/client-config")),_("Servers Nodes"),20).leaf=true
entry({"admin","services","shadowsocksr","subscription"},cbi("shadowsocksr/subscription"),_("Node Subscribe"),25).leaf=true	
entry({"admin","services","shadowsocksr","control"},cbi("shadowsocksr/control"),_("Access Control"),30).leaf=true
entry({"admin","services","shadowsocksr","advanced"},cbi("shadowsocksr/advanced"),_("Advanced Settings"),50).leaf=true
entry({"admin","services","shadowsocksr","server"},arcombine(cbi("shadowsocksr/server"),cbi("shadowsocksr/server-config")),_("SSR Server"),60).leaf=true
entry({"admin","services","shadowsocksr","status"},form("shadowsocksr/status"),_("Status"),70).leaf=true
entry({"admin","services","shadowsocksr","check"},call("check_status"))
entry({"admin","services","shadowsocksr","refresh"},call("refresh_data"))
entry({"admin","services","shadowsocksr","subscribe"},call("subscribe"))
entry({"admin","services","shadowsocksr","checkport"},call("check_port"))
entry({"admin","services","shadowsocksr","log"},form("shadowsocksr/log"),_("Log"),80).leaf=true
entry({"admin","services","shadowsocksr","get_log"},call("get_log")).leaf = true
entry({"admin","services","shadowsocksr","clear_log"},call("clear_log")).leaf = true
entry({"admin","services","shadowsocksr","run"},call("act_status"))
entry({"admin","services","shadowsocksr","ping"},call("act_ping"))
entry({"admin","services","shadowsocksr","reset"},call("act_reset"))
entry({"admin","services","shadowsocksr","restart"},call("act_restart"))
entry({"admin","services","shadowsocksr","delete"},call("act_delete"))
end
function subscribe()
luci.sys.call("/usr/bin/lua /usr/share/shadowsocksr/subscribe.lua >>/var/log/ssrplus.log")
luci.http.prepare_content("application/json")
luci.http.write_json({ret=1})
end
function act_status()
local e={}
e.running=luci.sys.call("busybox ps -w | grep ssr-retcp | grep -v grep >/dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function act_ping()
local e={}
local t=luci.http.formvalue("domain")
local o=luci.http.formvalue("port")
local i=luci.http.formvalue("transport")
local s=luci.http.formvalue("wsPath")
local a=luci.http.formvalue("tls")
e.index=luci.http.formvalue("index")
local n=luci.sys.call("ipset add ss_spec_wan_ac "..t.." 2>/dev/null")
if i=="ws"then
local a=a=='1'and"https://"or"http://"
local t=a..t..':'..o..s
local t=luci.sys.exec("curl --http1.1 -m 2 -ksN -o /dev/null -w 'time_connect=%{time_connect}\nhttp_code=%{http_code}' -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==' -H 'Sec-WebSocket-Version: 13' "..t)
e.socket=string.match(t,"http_code=(%d+)")=="101"
e.ping=tonumber(string.match(t,"time_connect=(%d+.%d%d%d)"))*1000
else
local a=nixio.socket("inet","stream")
a:setopt("socket","rcvtimeo",3)
a:setopt("socket","sndtimeo",3)
e.socket=a:connect(t,o)
a:close()
e.ping=luci.sys.exec(string.format("echo -n $(tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | grep -o 'time=[0-9]*' | awk -F '=' '{print $2}') 2>/dev/null",o,t))
end
if(n==0)then
luci.sys.call(" ipset del ss_spec_wan_ac "..t)
end
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function check_status()
local e={}
e.ret=luci.sys.call("/usr/bin/ssr-check www."..luci.http.formvalue("set")..".com 80 3 1")
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function refresh_data()
local e=luci.http.formvalue("set")
local e=loadstring("return "..luci.sys.exec("/usr/bin/lua /usr/share/shadowsocksr/update.lua "..e))()
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end
function check_port()
local t="<br /><br />"
local e
local a=""
local e=luci.model.uci.cursor()
local o=1
e:foreach("shadowsocksr","servers",function(e)
if e.alias then
a=e.alias
elseif e.server and e.server_port then
a="%s:%s"%{e.server,e.server_port}
end
o=luci.sys.call("ipset add ss_spec_wan_ac "..e.server.." 2>/dev/null")
socket=nixio.socket("inet","stream")
socket:setopt("socket","rcvtimeo",3)
socket:setopt("socket","sndtimeo",3)
ret=socket:connect(e.server,e.server_port)
if tostring(ret)=="true"then
socket:close()
t=t.."<font color = 'green'>["..a.."] OK.</font><br />"
else
t=t.."<font color = 'red'>["..a.."] Error.</font><br />"
end
if o==0 then
luci.sys.call("ipset del ss_spec_wan_ac "..e.server)
end
end)
luci.http.prepare_content("application/json")
luci.http.write_json({ret=t})
end
function get_log()
	luci.http.write(luci.sys.exec(
		"[ -f '/var/log/ssrplus.log' ] && cat /var/log/ssrplus.log"))
end
function clear_log()
	luci.sys.call("echo '' > /var/log/ssrplus.log")
end
function act_reset()
luci.sys.call("/etc/init.d/shadowsocksr reset &")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr"))
end
function act_restart()
luci.sys.call("/etc/init.d/shadowsocksr restart &")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr"))
end
function act_delete()
luci.sys.call("/etc/init.d/shadowsocksr restart &")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","servers"))
end
