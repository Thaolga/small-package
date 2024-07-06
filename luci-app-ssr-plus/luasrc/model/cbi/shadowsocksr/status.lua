require"nixio.fs"
require"luci.sys"
require"luci.model.uci"
local t,e,a
local i=0
local h=0
local n=0
local u=0
local l=0
local w=0
local a=0
local m=0
local f=0
local c=0
local d=0
local a=luci.sys.exec("busybox ps -w")
local r=luci.model.uci.cursor()
font_blue=[[<b style=color:green>]]
style_blue=[[<b style=color:red>]]
font_off=[[</b>]]
bold_on=[[<strong>]]
bold_off=[[</strong>]]
local o=translate("Unknown")
local s="/usr/bin/kcptun-client"
if not nixio.fs.access(s)then
o=translate("Not exist")
else
if not nixio.fs.access(s,"rwx","rx","rx")then
nixio.fs.chmod(s,755)
end
o="<b>"..luci.sys.exec(s.." -v | awk '{printf $3}'").."</b>"
if not o or o==""then
o=translate("Unknown")
end
end
if nixio.fs.access("/etc/ssrplus/gfw_list.conf")then
m=tonumber(luci.sys.exec("cat /etc/ssrplus/gfw_list.conf | wc -l"))/2
end
if nixio.fs.access("/etc/ssrplus/ad.conf")then
f=tonumber(luci.sys.exec("cat /etc/ssrplus/ad.conf | wc -l"))
end
if nixio.fs.access("/etc/ssrplus/china_ssr.txt")then
c=tonumber(luci.sys.exec("cat /etc/ssrplus/china_ssr.txt | wc -l"))
end
if nixio.fs.access("/etc/ssrplus/netflixip.list")then
d=tonumber(luci.sys.exec("cat /etc/ssrplus/netflixip.list | wc -l"))
end
if a:find("udp.only.ssr.reudp")then
h=1
end
if a:find("tcp.only.ssr.retcp")then
i=1
end
if a:find("tcp.udp.ssr.local")then
n=1
end
if a:find("tcp.udp.ssr.retcp")then
i=1
h=1
end
if a:find("local.ssr.retcp")then
i=1
n=1
end
if a:find("local.udp.ssr.retcp")then
h=1
i=1
n=1
end
if a:find("kcptun.client")then
w=1
end
if a:find("ssr.server")then
l=1
end
if a:find("ssrplus/bin/dns2tcp")or a:find("ssrplus/bin/mosdns")or(a:find("ssrplus.dns")and a:find("dns2socks.127.0.0.1.*127.0.0.1.5335"))then
pdnsd_run=1
end
if luci.sys.call("pidof privoxy >/dev/null")==0 then
u=1
end
t=SimpleForm("Version")
t.reset=false
t.submit=false
e=t:field(DummyValue,"redir_run",translate("Global Client"))
e.rawhtml=true
if i==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
e=t:field(DummyValue,"reudp_run",translate("Game Mode UDP Relay"))
e.rawhtml=true
if h==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
if r:get_first("shadowsocksr",'global','pdnsd_enable','0')~='0'then
e=t:field(DummyValue,"pdnsd_run",translate("DNS Anti-pollution"))
e.rawhtml=true
if pdnsd_run==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
end
e=t:field(DummyValue,"sock5_run",translate("Global SOCKS5 Proxy Server"))
e.rawhtml=true
if n==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
if nixio.fs.access("/usr/sbin/privoxy")then
e=t:field(DummyValue,"privoxy_run",translate("HTTP Proxy"))
e.rawhtml=true
if u==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
end
e=t:field(DummyValue,"server_run",translate("Local Servers"))
e.rawhtml=true
if l==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
if nixio.fs.access("/usr/bin/kcptun-client")then
e=t:field(DummyValue,"kcp_version",translate("KcpTun Version"))
e.rawhtml=true
e.value=o
e=t:field(DummyValue,"kcptun_run",translate("KcpTun"))
e.rawhtml=true
if w==1 then
e.value=font_blue..bold_on..translate("Running")..bold_off..font_off
else
e.value=style_blue..bold_on..translate("Not Running")..bold_off..font_off
end
end
e=t:field(DummyValue,"google",translate("Google Connectivity"))
e.value=translate("No Check")
e.template="shadowsocksr/check"
e=t:field(DummyValue,"baidu",translate("Baidu Connectivity"))
e.value=translate("No Check")
e.template="shadowsocksr/check"
e=t:field(DummyValue,"gfw_data",translate("GFW List Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=m.." "..translate("Records")
e=t:field(DummyValue,"ip_data",translate("China IP Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=c.." "..translate("Records")
if r:get_first("shadowsocksr",'global','netflix_enable','0')~='0'then
e=t:field(DummyValue,"nfip_data",translate("Netflix IP Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=d.." "..translate("Records")
end
if r:get_first("shadowsocksr",'global','adblock','0')=='1'then
e=t:field(DummyValue,"ad_data",translate("Advertising Data"))
e.rawhtml=true
e.template="shadowsocksr/refresh"
e.value=f.." "..translate("Records")
end
e=t:field(DummyValue,"check_port",translate("Check Server Port"))
e.template="shadowsocksr/checkport"
e.value=translate("No Check")
return t
