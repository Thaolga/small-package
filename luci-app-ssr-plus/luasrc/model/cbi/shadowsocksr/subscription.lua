require"luci.http"
require"luci.dispatcher"
require"luci.model.uci"
local o,t,e
local a=luci.model.uci.cursor()
local i=0
a:foreach("shadowsocksr","servers",function(e)
i=i+1
end)
o=Map("shadowsocksr",translate("Servers subscription and manage"))
t=o:section(TypedSection,"server_subscribe")
t.anonymous=true
e=t:option(Flag,"auto_update",translate("Auto Update"))
e.rmempty=false
e.description=translate("Auto Update Server subscription, GFW list and CHN route")
e=t:option(ListValue,"auto_update_time",translate("Update time (every day)"))
for t=0,23 do
e:value(t,t..":00")
end
e.default=2
e.rmempty=false
e=t:option(DynamicList,"subscribe_url",translate("Subscribe URL"))
e.rmempty=true
e=t:option(Value,"filter_words",translate("Subscribe Filter Words"))
e.rmempty=true
e.description=translate("Filter Words splited by /")
e=t:option(Value,"save_words",translate("Subscribe Save Words"))
e.rmempty=true
e.description=translate("Save Words splited by /")
e=t:option(Button,"update_Sub",translate("Update Subscribe List"))
e.inputstyle="reload"
e.description=translate("Update subscribe url list first")
e.write=function()
a:commit("shadowsocksr")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","servers"))
end
e=t:option(Flag,"switch",translate("Subscribe Default Auto-Switch"))
e.rmempty=false
e.description=translate("Subscribe new add server default Auto-Switch on")
e.default="1"
e=t:option(Flag,"proxy",translate("Through proxy update"))
e.rmempty=false
e.description=translate("Through proxy update list, Not Recommended ")
e=t:option(Button,"subscribe",translate("Update All Subscribe Servers"))
e.rawhtml=true
e.template="shadowsocksr/subscribe"
e=t:option(Button,"delete",translate("Delete All Subscribe Servers"))
e.inputstyle="reset"
e.description=string.format(translate("Server Count")..": %d",i)
e.write=function()
a:delete_all("shadowsocksr","servers",function(e)
if e.hashkey or e.isSubscribe then
return true
else
return false
end
end)
a:save("shadowsocksr")
a:commit("shadowsocksr")
luci.http.redirect(luci.dispatcher.build_url("admin","services","shadowsocksr","delete"))
return
end
return o
