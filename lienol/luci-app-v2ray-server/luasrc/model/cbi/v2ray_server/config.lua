local i = "v2ray_server"
local d = require "luci.dispatcher"
local a, t, e

local header_type = {"none", "srtp", "utp", "wechat-video", "dtls", "wireguard"}

a = Map(i, "V2ray " .. translate("Server Config"))
a.redirect = d.build_url("admin", "vpn", "v2ray_server")

t = a:section(NamedSection, arg[1], "user", "")
t.addremove = false
t.dynamic = false

e = t:option(Flag, "enable", translate("Enable"))
e.default = "1"
e.rmempty = false

e = t:option(Value, "remarks", translate("Remarks"))
e.default = translate("Remarks")
e.rmempty = false

e = t:option(Flag, "bind_local", translate("Bind Local"), translate(
                 "When selected, it can only be accessed locally,It is recommended to turn on when using reverse proxies."))
e.default = "0"
e.rmempty = false

e = t:option(Value, "port", translate("Port"))
e.datatype = "port"
e.rmempty = false

e = t:option(ListValue, "protocol", translate("Protocol"))
e:value("vmess", translate("Vmess"))
e:value("socks", translate("Socks"))
e:value("shadowsocks", translate("Shadowsocks"))

e = t:option(Value, "socks_username", translate("User name"))
e.rmempty = true
e:depends("protocol", "socks")

e = t:option(Value, "socks_password", translate("Password"))
e.rmempty = true
e.password = true
e:depends("protocol", "socks")

e = t:option(ListValue, "ss_method", translate("Encrypt Method"))
e:value("aes-128-cfb")
e:value("aes-256-cfb")
e:value("aes-128-gcm")
e:value("aes-256-gcm")
e:value("chacha20")
e:value("chacha20-ietf")
e:value("chacha20-poly1305")
e:value("chacha20-ietf-poly1305")
e:depends("protocol", "shadowsocks")

e = t:option(Value, "ss_password", translate("Password"))
e.rmempty = false
e:depends("protocol", "shadowsocks")

e = t:option(Value, "ss_level", translate("User Level"))
e.default = 1
e:depends("protocol", "shadowsocks")

e = t:option(ListValue, "ss_network", translate("Transport"))
e.default = "tcp,udp"
e:value("tcp", "TCP")
e:value("udp", "UDP")
e:value("tcp,udp", "TCP,UDP")
e:depends("protocol", "shadowsocks")

e = t:option(Flag, "ss_ota", translate("OTA"), translate(
                 "When OTA is enabled, V2Ray will reject connections that are not OTA enabled. This option is invalid when using AEAD encryption."))
e.default = "0"
e.rmempty = false
e:depends("protocol", "shadowsocks")

e = t:option(DynamicList, "VMess_id", translate("ID"))
e.default = luci.sys.exec("cat /proc/sys/kernel/random/uuid")
e.rmempty = false
e:depends("protocol", "vmess")

e = t:option(Value, "VMess_alterId", translate("Alter ID"))
e.default = 16
e.rmempty = false
e:depends("protocol", "vmess")

e = t:option(Value, "VMess_level", translate("User Level"))
e.default = 1
e:depends("protocol", "vmess")

e = t:option(ListValue, "transport", translate("Transport"))
e:value("tcp", "TCP")
e:value("mkcp", "mKCP")
e:value("ws", "WebSocket")
e:value("h2", "HTTP/2")
e:value("quic", "QUIC")
e:depends("protocol", "vmess")

-- [[ TCP部分 ]]--
-- TCP伪装
e = t:option(ListValue, "tcp_guise", translate("Camouflage Type"))
e:depends("transport", "tcp")
e:value("none", "none")
e:value("http", "http")

-- HTTP域名
e = t:option(DynamicList, "tcp_guise_http_host", translate("HTTP Host"))
e:depends("tcp_guise", "http")

-- HTTP路径
e = t:option(DynamicList, "tcp_guise_http_path", translate("HTTP Path"))
e:depends("tcp_guise", "http")

-- [[ mKCP部分 ]]--
e = t:option(ListValue, "mkcp_guise", translate("Camouflage Type"), translate(
                 '<br>none: default, no masquerade, data sent is packets with no characteristics.<br>srtp: disguised as an SRTP packet, it will be recognized as video call data (such as FaceTime).<br>utp: packets disguised as uTP will be recognized as bittorrent downloaded data.<br>wechat-video: packets disguised as WeChat video calls.<br>dtls: disguised as DTLS 1.2 packet.<br>wireguard: disguised as a WireGuard packet. (not really WireGuard protocol)'))
for a, t in ipairs(header_type) do e:value(t) end
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_mtu", translate("KCP MTU"))
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_tti", translate("KCP TTI"))
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_uplinkCapacity", translate("KCP uplinkCapacity"))
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_downlinkCapacity", translate("KCP downlinkCapacity"))
e:depends("transport", "mkcp")

e = t:option(Flag, "mkcp_congestion", translate("KCP Congestion"))
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_readBufferSize", translate("KCP readBufferSize"))
e:depends("transport", "mkcp")

e = t:option(Value, "mkcp_writeBufferSize", translate("KCP writeBufferSize"))
e:depends("transport", "mkcp")

-- [[ WebSocket部分 ]]--
e = t:option(Value, "ws_path", translate("WebSocket Path"))
e:depends("transport", "ws")

e = t:option(Value, "ws_host", translate("WebSocket Host"))
e:depends("transport", "ws")

-- [[ HTTP/2部分 ]]--
e = t:option(Value, "h2_path", translate("HTTP/2 Path"))
e:depends("transport", "h2")

e = t:option(DynamicList, "h2_host", translate("HTTP/2 Host"),
             translate("Camouflage Domain,you can not fill in"))
e:depends("transport", "h2")

-- [[ QUIC部分 ]]--
e = t:option(ListValue, "quic_security", translate("Encrypt Method"))
e:value("none")
e:value("aes-128-gcm")
e:value("chacha20-poly1305")
e:depends("transport", "quic")

e = t:option(Value, "quic_key", translate("Encrypt Method") .. translate("Key"))
e:depends("transport", "quic")

e = t:option(ListValue, "quic_guise", translate("Camouflage Type"))
for a, t in ipairs(header_type) do e:value(t) end
e:depends("transport", "quic")

-- [[ TLS部分 ]] --
e = t:option(Flag, "tls_enable", translate("Use HTTPS"))
e:depends("transport", "ws")
e:depends("transport", "h2")
e.default = "1"
e.rmempty = false

-- e = t:option(Value, "tls_serverName", translate("Domain"))
-- e:depends("transport", "ws")
-- e:depends("transport", "h2")

e = t:option(Value, "tls_certificateFile",
             translate("Public key absolute path"),
             translate("as:") .. "/etc/ssl/fullchain.pem")
e:depends("tls_enable", 1)

e = t:option(Value, "tls_keyFile",
             translate("Private key absolute path"),
             translate("as:") .. "/etc/ssl/private.key")
e:depends("tls_enable", 1)

-- [[ 反向代理部分 ]] --
e = t:option(Flag, "reverse_proxy_enable", translate("Reverse Proxy"))
e:depends("tls_enable", 1)
e.default = "0"
e.rmempty = false

e = t:option(ListValue, "reverse_proxy_type", translate("Reverse Proxy Type"),
             translate("Nginx does not support HTTP/2 reverse proxies"))
e:depends("reverse_proxy_enable", 1)
e:value("nginx", "Nginx")
e:value("caddy", "Caddy")

e = t:option(Value, "reverse_proxy_serverName", translate("Domain"))
e:depends("reverse_proxy_enable", 1)

e = t:option(Value, "reverse_proxy_port", translate("Port"),
             translate("can not has conflict"))
e.datatype = "port"
e.default = "443"
e:depends("reverse_proxy_enable", 1)

return a
