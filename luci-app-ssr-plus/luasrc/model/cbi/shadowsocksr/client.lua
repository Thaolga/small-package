local i,t,a,e
local n=luci.model.uci.cursor()
local h=require"luci.cbi.datatypes"
local function s(e)
return luci.sys.exec('type -t -p "%s"'%e)~=""and true or false
end
i=Map("shadowsocksr")
i:section(SimpleSection).template="shadowsocksr/status"
local a={}
n:foreach("shadowsocksr","servers",function(e)
if e.alias then
a[e[".name"]]="[%s]:%s"%{string.upper(e.v2ray_protocol or e.type),e.alias}
elseif e.server and e.server_port then
a[e[".name"]]="[%s]:%s:%s"%{string.upper(e.v2ray_protocol or e.type),e.server,e.server_port}
end
end)
local o={}
for e,t in pairs(a)do
table.insert(o,e)
end
table.sort(o)
t=i:section(TypedSection,"global")
t.anonymous=true
e=t:option(ListValue,"global_server",translate("Main Server"))
e:value("nil",translate("Disable"))
for o,t in pairs(o)do
e:value(t,a[t])
end
e.default="nil"
e.rmempty=false
e=t:option(ListValue,"udp_relay_server",translate("Game Mode UDP Server"))
e:value("",translate("Disable"))
e:value("same",translate("Same as Global Server"))
for o,t in pairs(o)do
e:value(t,a[t])
end
if n:get_first("shadowsocksr",'global','netflix_enable','0')=='1'then
e=t:option(ListValue,"netflix_server",translate("Netflix Node"))
e:value("nil",translate("Disable"))
e:value("same",translate("Same as Global Server"))
for o,t in pairs(o)do
e:value(t,a[t])
end
e.default="nil"
e.rmempty=false
e=t:option(Flag,"netflix_proxy",translate("External Proxy Mode"))
e.rmempty=false
e.description=translate("Forward Netflix Proxy through Main Proxy")
e.default="0"
end
e=t:option(ListValue,"threads",translate("Multi Threads Option"))
e:value("0",translate("Auto Threads"))
e:value("1",translate("1 Thread"))
e:value("2",translate("2 Threads"))
e:value("4",translate("4 Threads"))
e:value("8",translate("8 Threads"))
e:value("16",translate("16 Threads"))
e:value("32",translate("32 Threads"))
e:value("64",translate("64 Threads"))
e:value("128",translate("128 Threads"))
e.default="0"
e.rmempty=false
e=t:option(ListValue,"run_mode",translate("Running Mode"))
e:value("gfw",translate("GFW List Mode"))
e:value("router",translate("IP Route Mode"))
e:value("all",translate("Global Mode"))
e:value("oversea",translate("Oversea Mode"))
e.default=gfw
e=t:option(ListValue,"dports",translate("Proxy Ports"))
e:value("1",translate("All Ports"))
e:value("2",translate("Only Common Ports"))
e:value("3",translate("Custom Ports"))
cp=t:option(Value,"custom_ports",translate("Enter Custom Ports"))
cp:depends("dports","3")
cp.placeholder="e.g., 80,443,8080"
e.default=1
e=t:option(ListValue,"pdnsd_enable",translate("Resolve Dns Mode"))
e:value("1",translate("Use DNS2TCP query"))
e:value("2",translate("Use DNS2SOCKS query and cache"))
if s("mosdns")then
e:value("3",translate("Use MOSDNS query (Not Support Oversea Mode)"))
end
e:value("0",translate("Use Local DNS Service listen port 5335"))
e.default=1
e=t:option(Value,"tunnel_forward",translate("Anti-pollution DNS Server"))
e:value("8.8.4.4:53",translate("Google Public DNS (8.8.4.4)"))
e:value("8.8.8.8:53",translate("Google Public DNS (8.8.8.8)"))
e:value("208.67.222.222:53",translate("OpenDNS (208.67.222.222)"))
e:value("208.67.220.220:53",translate("OpenDNS (208.67.220.220)"))
e:value("209.244.0.3:53",translate("Level 3 Public DNS (209.244.0.3)"))
e:value("209.244.0.4:53",translate("Level 3 Public DNS (209.244.0.4)"))
e:value("4.2.2.1:53",translate("Level 3 Public DNS (4.2.2.1)"))
e:value("4.2.2.2:53",translate("Level 3 Public DNS (4.2.2.2)"))
e:value("4.2.2.3:53",translate("Level 3 Public DNS (4.2.2.3)"))
e:value("4.2.2.4:53",translate("Level 3 Public DNS (4.2.2.4)"))
e:value("1.1.1.1:53",translate("Cloudflare DNS (1.1.1.1)"))
e:value("114.114.114.114:53",translate("Oversea Mode DNS-1 (114.114.114.114)"))
e:value("114.114.115.115:53",translate("Oversea Mode DNS-2 (114.114.115.115)"))
e:depends("pdnsd_enable","1")
e:depends("pdnsd_enable","2")
e.description=translate("Custom DNS Server format as IP:PORT (default: 8.8.4.4:53)")
e.datatype="ip4addrport"
e=t:option(ListValue,"tunnel_forward_mosdns",translate("Anti-pollution DNS Server"))
e:value("tcp://8.8.4.4:53,tcp://8.8.8.8:53",translate("Google Public DNS"))
e:value("tcp://208.67.222.222:53,tcp://208.67.220.220:53",translate("OpenDNS"))
e:value("tcp://209.244.0.3:53,tcp://209.244.0.4:53",translate("Level 3 Public DNS-1 (209.244.0.3-4)"))
e:value("tcp://4.2.2.1:53,tcp://4.2.2.2:53",translate("Level 3 Public DNS-2 (4.2.2.1-2)"))
e:value("tcp://4.2.2.3:53,tcp://4.2.2.4:53",translate("Level 3 Public DNS-3 (4.2.2.3-4)"))
e:value("tcp://1.1.1.1:53,tcp://1.0.0.1:53",translate("Cloudflare DNS"))
e:depends("pdnsd_enable","3")
e.description=translate("Custom DNS Server for mosdns")
e=t:option(Flag,"mosdns_ipv6",translate("Disable IPv6 in MOSDNS query mode"))
e:depends("pdnsd_enable","3")
e.rmempty=false
e.default="0"
if s("chinadns-ng")then
e=t:option(Value,"chinadns_forward",translate("Domestic DNS Server"))
e:value("",translate("Disable ChinaDNS-NG"))
e:value("wan",translate("Use DNS from WAN"))
e:value("wan_114",translate("Use DNS from WAN and 114DNS"))
e:value("114.114.114.114:53",translate("Nanjing Xinfeng 114DNS (114.114.114.114)"))
e:value("119.29.29.29:53",translate("DNSPod Public DNS (119.29.29.29)"))
e:value("223.5.5.5:53",translate("AliYun Public DNS (223.5.5.5)"))
e:value("180.76.76.76:53",translate("Baidu Public DNS (180.76.76.76)"))
e:value("101.226.4.6:53",translate("360 Security DNS (China Telecom) (101.226.4.6)"))
e:value("123.125.81.6:53",translate("360 Security DNS (China Unicom) (123.125.81.6)"))
e:value("1.2.4.8:53",translate("CNNIC SDNS (1.2.4.8)"))
e:depends({pdnsd_enable="1",run_mode="router"})
e:depends({pdnsd_enable="2",run_mode="router"})
e.description=translate("Custom DNS Server format as IP:PORT (default: disabled)")
e.validate=function(a,e,t)
if(t and e)then
if e=="wan"or e=="wan_114"then
return e
end
if h.ip4addrport(e)then
return e
end
return nil,translate("Expecting: %s"):format(translate("valid address:port"))
end
return e
end
end
return i
