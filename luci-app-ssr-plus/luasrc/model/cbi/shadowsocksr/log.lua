f = SimpleForm("shadowsocksr")
f.reset = false
f.submit = false
f:append(Template("shadowsocksr/ssrplus_log"))
return f
