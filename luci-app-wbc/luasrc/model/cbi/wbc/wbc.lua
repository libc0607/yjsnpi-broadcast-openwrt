-- YJSNPI-Broadcast
-- Another EZ-WifiBroadcast Mod
-- Dirty mod by @libc0607 (libc0607@gmail.com)

m = Map("wbc", translate("YJSNPI-Broadcast"), 
			translate("Another <a href=\"https://github.com/rodizio1/EZ-WifiBroadcast\">rodizio1/EZ-WifiBroadcast</a> Mod")
			.."<br />"..translate("Kusai Digital HD Video Transmission")
			.."<br />"..translate("<a href=\"https://github.com/libc0607/YJSNPI-Broadcast\">Github Homepage</a>")
			)

require "luci.sys"
require "nixio.fs"

-- add all possible frequency to freq_list
local wlan_dev_list = {}
local freq_list = {}
for k, v in ipairs(luci.sys.net.devices()) do
	if string.match(v, "wlan") then
		wlan_dev_list[#wlan_dev_list+1] = v
		local iwi = luci.sys.wifi.getiwinfo(v)
		for i,j in ipairs(iwi.freqlist) do 
			freq_list[#freq_list+1] = iwi.freqlist[i].mhz 
		end
	end
end
-- Get all /dev/tty* to tty_list
local tty_list = {}
for e in nixio.fs.dir("/dev") do 
	if string.match(e, "tty") then
		tty_list[#tty_list+1] = "/dev/"..e
	end
end

-- wbc.wbc: Global settings
s_wbc = m:section(TypedSection, "wbc", translate("YJSNPI-Broadcast Settings"))
s_wbc.anonymous = true
s_wbc.addremove = false
-- wbc.wbc.enable: Enable
o_wbc_enable = s_wbc:option(Flag, "enable", translate("Enable YJSNPI-Broadcast"))
o_wbc_enable.rmempty = false
-- wbc.wbc.confpath: config file on HTTP
-- Note: 	this file is for raspi; will be link to /www 
--			e.g. when set to '/wbc-config.ini'
--			on raspi run 'wget 192.168.1.1/wbc-config.ini'
o_wbc_confpath = s_wbc:option(Value, "confpath", translate("Config file on HTTP"))
o_wbc_confpath.default = '/wbc-config.ini'
o_wbc_confpath:depends("enable", 1)


-- wbc.nic: Wi-Fi settings
s_nic = m:section(TypedSection, "nic", translate("Wi-Fi Settings"))
s_nic.anonymous = true
s_nic.addremove = false
-- wbc.nic.iface: Wireless Interface
o_nic_iface = s_nic:option(Value, "iface", translate("Wireless Interface"))
o_nic_iface.rmempty = false
for k,v in ipairs(wlan_dev_list) do 
	o_nic_iface:value(v) 
end
o_nic_iface.default = "wlan0"
-- wbc.nic.freq: Frequency
o_nic_freq = s_nic:option(Value, "freq", translate("Center Frequency"))
o_nic_freq.rmempty = false
for k,v in ipairs(freq_list) do 
	o_nic_freq:value(v, v.." MHz") 
end
o_nic_freq.default = 2437
-- wbc.nic.chanbw: Channel Bandwidth
o_nic_chanbw = s_nic:option(ListValue, "chanbw", translate("Channel Bandwidth"), translate("Note: ath9k only"))
o_nic_chanbw.rmempty = false
o_nic_chanbw:value(5,  "5 MHz")
o_nic_chanbw:value(10, "10 MHz")
o_nic_chanbw:value(20, "20 MHz")
o_nic_chanbw.default = 20

-- wbc.nic.txpower_custom: Use Custom TX Power
o_nic_txpower_custom = s_nic:option(Flag, "txpower_custom", translate("Use Custom TX Power (ath9k only)"), 
									translate("Note: ath9k only; Too high will cause high EVM and/or burn your card. "))
o_nic_txpower_custom.rmempty = false

-- wbc.nic.txpower_bh: High level TX Power for 802.11b (ath9k only)
o_nic_txpower_bh = s_nic:option(ListValue, "txpower_bh", translate("High level TX Power for 802.11b."))
o_nic_txpower_bh.rmempty = false
o_nic_txpower_bh.datatype = "range(0,30)"
o_nic_txpower_bh:depends("txpower_custom", 1)
for i = 0, 30 do 
	o_nic_txpower_bh:value(i, i.." dBm")
end
o_nic_txpower_bh.default = 20

-- wbc.nic.txpower_bl: Low level TX Power for 802.11b (ath9k only)
o_nic_txpower_bl = s_nic:option(ListValue, "txpower_bl", translate("Low level TX Power for 802.11b"), 
								translate("This value should less than the high power of 802.11b above."))
o_nic_txpower_bl.rmempty = false
o_nic_txpower_bl.datatype = "range(0,30)"
o_nic_txpower_bl:depends("txpower_custom", 1)
for i = 0, 30 do 
	o_nic_txpower_bl:value(i, i.." dBm")
end
o_nic_txpower_bl.default = 10

-- wbc.nic.txpower_bf: Set high TX power to the 802.11b rates less than or equal to this value: (ath9k only)
o_nic_txpower_bf = s_nic:option(ListValue, "txpower_bf", translate("Set high TX power to the 802.11b rates less than or equal to this value"))
o_nic_txpower_bf.rmempty = false
o_nic_txpower_bf:value(1,  "1 Mbps (802.11b, DSSS)")
o_nic_txpower_bf:value(2,  "2 Mbps (802.11b, DSSS)")
o_nic_txpower_bf:value(5,  "5.5 Mbps (802.11b, CCK)")
o_nic_txpower_bf:value(11, "11 Mbps (802.11b, CCK)")
o_nic_txpower_bf:depends("txpower_custom", 1)
o_nic_txpower_bf.default = 1

-- wbc.nic.txpower_gh: High level TX Power for 802.11g (ath9k only)
o_nic_txpower_gh = s_nic:option(ListValue, "txpower_gh", translate("High level TX Power for 802.11g."))
o_nic_txpower_gh.rmempty = false
o_nic_txpower_gh.datatype = "range(0,30)"
o_nic_txpower_gh:depends("txpower_custom", 1)
for i = 0, 30 do 
	o_nic_txpower_gh:value(i, i.." dBm")
end
o_nic_txpower_gh.default = 20

-- wbc.nic.txpower_gl: Low level TX Power for 802.11g (ath9k only)
o_nic_txpower_gl = s_nic:option(ListValue, "txpower_gl", translate("Low level TX Power for 802.11g"), 
								translate("This value should less than the high power of 802.11g above."))
o_nic_txpower_gl.rmempty = false
o_nic_txpower_gl.datatype = "range(0,30)"
for i = 0, 30 do 
	o_nic_txpower_gl:value(i, i.." dBm")
end
o_nic_txpower_gl:depends("txpower_custom", 1)
o_nic_txpower_gl.default = 10

-- wbc.nic.txpower_gf: Set high TX power to the 802.11g rates less than or equal to this value: (ath9k only)
o_nic_txpower_gf = s_nic:option(ListValue, "txpower_gf", translate("Set high TX power to the 802.11g rates less than or equal to this value"))
o_nic_txpower_gf.rmempty = false
o_nic_txpower_gf:depends("txpower_custom", 1)
o_nic_txpower_gf:value(6, "6 Mbps (802.11g, BPSK, 1/2)")
o_nic_txpower_gf:value(9, "9 Mbps (802.11g, BPSK, 3/4)")
o_nic_txpower_gf:value(12, "12 Mbps (802.11g, QPSK, 1/2)")
o_nic_txpower_gf:value(18, "18 Mbps (802.11g, QPSK, 3/4)")
o_nic_txpower_gf:value(24, "24 Mbps (802.11g, 16-QAM, 1/2)")
o_nic_txpower_gf:value(36, "36 Mbps (802.11g, 16-QAM, 3/4)")
o_nic_txpower_gf:value(48, "48 Mbps (802.11g, 64-QAM, 2/3)")
o_nic_txpower_gf.default = 6

-- wbc.nic.txpower_nh: High level TX Power for 802.11n (ath9k only)
o_nic_txpower_nh = s_nic:option(ListValue, "txpower_nh", translate("High level TX Power for 802.11n."))
o_nic_txpower_nh.rmempty = false
o_nic_txpower_nh.datatype = "range(0,30)"
o_nic_txpower_nh:depends("txpower_custom", 1)
for i = 0, 30 do 
	o_nic_txpower_nh:value(i, i.." dBm")
end
o_nic_txpower_nh.default = 20

-- wbc.nic.txpower_nl: Low level TX Power for 802.11n (ath9k only)
o_nic_txpower_nl = s_nic:option(ListValue, "txpower_nl", translate("Low level TX Power for 802.11n"), 
								translate("This value should less than the high power of 802.11n above."))
o_nic_txpower_nl.rmempty = false
o_nic_txpower_nl.datatype = "range(0,30)"
o_nic_txpower_nl:depends("txpower_custom", 1)
for i = 0, 30 do 
	o_nic_txpower_nl:value(i, i.." dBm")
end
o_nic_txpower_nl.default = 10

-- wbc.nic.txpower_nf: Set high TX power to the 802.11n rates less than or equal to this value: (ath9k only)
o_nic_txpower_nf = s_nic:option(ListValue, "txpower_nf", translate("Set high TX power to the 802.11n rates less than or equal to this value"))
o_nic_txpower_nf.rmempty = false
o_nic_txpower_nf:value(0, "MCS 0 (6.5 Mbps,  1x1, BPSK, 1/2)")
o_nic_txpower_nf:value(1, "MCS 1 (13.0 Mbps, 1x1, QPSK, 1/2)")
o_nic_txpower_nf:value(2, "MCS 2 (19.5 Mbps, 1x1, QPSK, 3/4)")
o_nic_txpower_nf:value(3, "MCS 3 (26.0 Mbps, 1x1, 16-QAM, 1/2)")
o_nic_txpower_nf:value(4, "MCS 4 (39.0 Mbps, 1x1, 16-QAM, 3/4)")
o_nic_txpower_nf:value(5, "MCS 5 (52.0 Mbps, 1x1, 64-QAM, 2/3)")
o_nic_txpower_nf:value(6, "MCS 6 (58.5 Mbps, 1x1, 64-QAM, 3/4)")
o_nic_txpower_nf:value(7, "MCS 7 (65.0 Mbps, 1x1, 64-QAM, 5/6)")
o_nic_txpower_nf:depends("txpower_custom", 1)
o_nic_txpower_nf.default = 1


-- wbc.video: Video transfer settings
s_video = m:section(TypedSection, "video", translate("Video Transfer Settings"))
s_video.anonymous = true
s_video.addremove = false
-- wbc.video.enable: Video Transfer Enable
o_video_enable = s_video:option(Flag, "enable", translate("Enable Video Transfer"))
o_video_enable.rmempty = false
-- wbc.video.mode: Video Transfer Mode
o_video_mode = s_video:option(ListValue, "mode", translate("Transfer Mode"))
o_video_mode.rmempty = false
o_video_mode:value("tx", translate("Transceiver"))
o_video_mode:value("rx", translate("Receiver"))
o_video_mode.default = "tx"
-- wbc.video.listen_port: Listen on port
o_video_listen_port = s_video:option(Value, "listen_port", translate("Listen On Local Port"))
o_video_listen_port.datatype = "portrange(1024,65535)"
o_video_listen_port:depends("mode", "tx")
o_video_listen_port.placeholder = 35000
o_video_listen_port.default = 35000
-- wbc.video.send_ip_port: Send Video Stream to IP:Port
o_video_send_ip_port = s_video:option(Value, "send_ip_port", translate("Send Video Stream to IP:Port"))
o_video_send_ip_port.datatype = "ipaddrport"
o_video_send_ip_port:depends("mode", "rx")
-- wbc.video.alive_send_ip_port: Send check alive msg to IP:Port
o_video_alive_send_ip_port = s_video:option(Value, "alive_send_ip_port", translate("Send Alive Msg to IP:Port"))
o_video_alive_send_ip_port.datatype = "ipaddrport"
o_video_alive_send_ip_port:depends("mode", "rx")
-- wbc.video.datanum: Data packets in a block
o_video_datanum = s_video:option(Value, "datanum", translate("Data packets in a block"))
o_video_datanum.default = 8
o_video_datanum.datatype = "range(1,32)"
o_video_datanum.placeholder = 8
-- wbc.video.fecnum: FEC packets in a block
o_video_fecnum = s_video:option(Value, "fecnum", translate("FEC packets in a block"))
o_video_fecnum.default = 4
o_video_fecnum.datatype = "range(1,32)"
o_video_fecnum.placeholder = 4
-- wbc.video.packetsize: Bytes per packet
o_video_packetsize = s_video:option(Value, "packetsize", translate("Bytes per packet"))
o_video_packetsize.default = 1024
o_video_packetsize.placeholder = 1024
o_video_packetsize.datatype = "range(32,1450)"
-- wbc.video.frametype: Frame Type
o_video_frametype = s_video:option(ListValue, "frametype", translate("Wireless Frame Type"))
o_video_frametype:value(0, "DATA Short")
o_video_frametype:value(1, "DATA Standard")
o_video_frametype:value(2, "RTS")
o_video_frametype.default = 0
-- wbc.video.wifimode: Wi-Fi mode (802.11g / 802.11n)
o_video_wifimode = s_video:option(ListValue, "wifimode", translate("Wi-Fi Mode"))
o_video_wifimode:value(0, "802.11abg")
o_video_wifimode:value(1, "802.11n (MCS)")
--o_video_wifimode:value(2, "802.11ac (VHT)")	-- 还没写
--o_video_wifimode:value(3, "802.11ax")			-- 有生之年
o_video_wifimode.default = 0
o_video_wifimode:depends("mode", "tx")
-- wbc.video.ldpc: LDPC encode (for 802.11n/802.11ac)
o_video_ldpc = s_video:option(Flag, "ldpc", translate("LDPC encode enable"), translate("Make sure that LDPC is supported by both tx & rx Wi-Fi card"))
o_video_ldpc.default = 0
o_video_ldpc:depends("wifimode", "1")
o_video_ldpc:depends("wifimode", "2")
o_video_ldpc:depends("wifimode", "3")
-- wbc.video.stbc: STBC encode (for 802.11n/802.11ac)
o_video_stbc = s_video:option(Flag, "stbc", translate("STBC encode enable"), translate("Make sure that STBC is supported by both tx & rx Wi-Fi card; Use at least 2x2 Wi-Fi card"))
o_video_stbc.default = 0
o_video_stbc:depends("wifimode", "1")
o_video_stbc:depends("wifimode", "2")
o_video_stbc:depends("wifimode", "3")
-- wbc.video.bitrate: Bit Rate (802.11abg)
o_video_bitrate = s_video:option(ListValue, "bitrate", translate("Bit Rate (802.11b/g)"), translate("Rate should divide by 2 when chanbw=10MHz; 4 for 5MHz. "))
o_video_bitrate:value(1, "1 Mbps (802.11b, DSSS)")
o_video_bitrate:value(2, "2 Mbps (802.11b, DSSS)")
o_video_bitrate:value(5, "5.5 Mbps (802.11b, CCK)")
o_video_bitrate:value(11, "11 Mbps (802.11b, CCK)")
o_video_bitrate:value(6, "6 Mbps (802.11g, BPSK, 1/2)")
o_video_bitrate:value(9, "9 Mbps (802.11g, BPSK, 3/4)")
o_video_bitrate:value(12, "12 Mbps (802.11g, QPSK, 1/2)")
o_video_bitrate:value(18, "18 Mbps (802.11g, QPSK, 3/4)")
o_video_bitrate:value(24, "24 Mbps (802.11g, 16-QAM, 1/2)")
o_video_bitrate:value(36, "36 Mbps (802.11g, 16-QAM, 3/4)")
o_video_bitrate:value(48, "48 Mbps (802.11g, 64-QAM, 2/3)")
o_video_bitrate.default = 12
o_video_bitrate:depends("wifimode", 0)
-- wbc.video.mcs: MCS index (802.11n/ac)
o_video_mcs = s_video:option(ListValue, "mcs", translate("MCS index (802.11n/ac)"), translate("Rate should divide by 2 when chanbw=10MHz; 4 for 5MHz. ")..translate("<br />In most cases you should choose MCS0~7."))
o_video_mcs:value(0, "MCS 0 (6.5 Mbps, 1x1, BPSK, 1/2)")
o_video_mcs:value(1, "MCS 1 (13.0 Mbps, 1x1, QPSK, 1/2)")
o_video_mcs:value(2, "MCS 2 (19.5 Mbps, 1x1, QPSK, 3/4)")
o_video_mcs:value(3, "MCS 3 (26.0 Mbps, 1x1, 16-QAM, 1/2)")
o_video_mcs:value(4, "MCS 4 (39.0 Mbps, 1x1, 16-QAM, 3/4)")
o_video_mcs:value(5, "MCS 5 (52.0 Mbps, 1x1, 64-QAM, 2/3)")
o_video_mcs:value(6, "MCS 6 (58.5 Mbps, 1x1, 64-QAM, 3/4)")
o_video_mcs:value(7, "MCS 7 (65.0 Mbps, 1x1, 64-QAM, 5/6)")
-- mcs 16~31 ignored
o_video_mcs.default = 1
o_video_mcs:depends("wifimode", 1)
--o_video_mcs:depends("wifimode", 2)
-- wbc.video.rxbuf: RX Buf Size
o_video_rxbuf = s_video:option(Value, "rxbuf", translate("RX Buf Size"))
o_video_rxbuf.default = 0
o_video_rxbuf.placeholder = 0
o_video_rxbuf.datatype = "range(0,32)"
o_video_rxbuf:depends("mode", "rx")
-- wbc.video.fps: Video FPS
o_video_fps = s_video:option(ListValue, "fps", translate("Video FPS"), translate("Make sure that both your screen and camera support that rate"))
o_video_fps.default = 48
o_video_fps.placeholder = 48
o_video_fps:value(30, "30 fps")
o_video_fps:value(40, "40 fps")
o_video_fps:value(48, "48 fps")
o_video_fps:value(59.9, "59.9 fps")
o_video_fps:value(60, "60 fps")
o_video_fps:value(90, "90 fps")
o_video_fps:value(120, "120 fps")
o_video_fps:value(144, "144 fps")
o_video_fps:value(240, "240 fps")
-- wbc.video.imgsize: Video resolution
o_video_imgsize = s_video:option(ListValue, "imgsize", translate("Img Size (resolution)"))
o_video_imgsize.default = "1280x720"
o_video_imgsize.placeholder = "1280x720"
o_video_imgsize:value("240x144")
o_video_imgsize:value("480x272")
o_video_imgsize:value("800x480")
o_video_imgsize:value("1280x720")
o_video_imgsize:value("1640x922")
o_video_imgsize:value("1920x1080")
o_video_imgsize:depends("mode", "tx")
-- wbc.video.bitrate_mode: Bitrate Mode
o_video_bitrate_mode = s_video:option(ListValue, "bitrate_mode", translate("Video Bitrate Mode"))
o_video_bitrate_mode.rmempty = false
o_video_bitrate_mode:value("auto", translate("Auto"))
o_video_bitrate_mode:value("manual", translate("Manual"))
o_video_bitrate_mode:depends("mode", "tx")
o_video_bitrate_mode.default = "auto"
-- wbc.video.bitrate_percent: Bitrate Percent
o_video_bitrate_percent = s_video:option(Value, "bitrate_percent", translate("Video Bitrate Percent"))
o_video_bitrate_percent.default = 65
o_video_bitrate_percent.placeholder = 65
o_video_bitrate_percent.datatype = "range(0,100)"
o_video_bitrate_percent:depends("bitrate_mode", "auto")
-- wbc.video.bitrate_manual: Bitrate Manual
o_video_bitrate_manual = s_video:option(Value, "bitrate_manual", translate("Video Bitrate Manual (kbit/s)"))
o_video_bitrate_manual.default = 5000
o_video_bitrate_manual.placeholder = 5000
o_video_bitrate_manual.datatype = "range(100,16000)"
o_video_bitrate_manual:depends("bitrate_mode", "manual")
-- wbc.video.keyframerate: Keyframe Rate
o_video_keyframerate = s_video:option(Value, "keyframerate", translate("Key Frame Rate"))
o_video_keyframerate.default = 5
o_video_keyframerate.placeholder = 5
o_video_keyframerate.datatype = "range(2,10)"
o_video_keyframerate:depends("mode", "tx")
-- wbc.video.extraparams: raspivid Extra Params
o_video_extraparams = s_video:option(Value, "extraparams", translate("raspivid Extra Params"), "<a href='https://github.com/rodizio1/EZ-WifiBroadcast/wiki/Expert-~-Raspivid-camera-settings'>Learn more</a>")
o_video_extraparams.default = '-cd H264 -n -fl -ih -pf high -if both -ex sports -mm average -awb horizon'
o_video_extraparams.placeholder = '-cd H264 -n -fl -ih -pf high -if both -ex sports -mm average -awb horizon'
o_video_extraparams:depends("mode", "tx")
-- wbc.video.save_enable: Video Save Enable
o_video_save_enable = s_video:option(Flag, "save_enable", translate("Enable Video Save"))
o_video_save_enable.rmempty = false
o_video_save_enable:depends("mode", "rx")
-- wbc.video.savepath: Save Raw Video To Path
o_video_savepath = s_video:option(Value, "savepath", translate("Save Raw Video To Path"))
o_video_savepath.default = '/mnt/sda1/wbc_video'
o_video_savepath.placeholder = '/mnt/sda1/wbc_video'
o_video_savepath:depends("save_enable", 1)
-- wbc.video.sysair_forward_port: shmem sysair forward listen udp port
o_video_sysair_forward_port = s_video:option(Value, "sysair_forward_port", translate("shmem sysair forward listen udp port"))
o_video_sysair_forward_port.rmempty = false
o_video_sysair_forward_port.datatype = "portrange(1024,65535)"
o_video_sysair_forward_port:depends("mode", "tx")
o_video_sysair_forward_port.placeholder = 34999
o_video_sysair_forward_port.default = 34999
-- wbc.video.encrypt_enable: Video Encrypt Enable
o_video_encrypt_enable = s_video:option(Flag, "encrypt_enable", translate("Encrypt"), translate("May cause high CPU load"))
o_video_encrypt_enable.rmempty = false
-- wbc.video.password: Encrypt Password
o_video_encrypt_password = s_video:option(Value, "encrypt_password", translate("Password"))
o_video_encrypt_password.rmempty = false
o_video_encrypt_password.password = true
o_video_encrypt_password:depends("encrypt_enable", 1)

-- wbc.rssi: RSSI settings
s_rssi = m:section(TypedSection, "rssi", translate("RSSI Settings"))
s_rssi.anonymous = true
s_rssi.addremove = false
-- wbc.rssi.enable: RSSI Enable
o_rssi_enable = s_rssi:option(Flag, "enable", translate("Enable RSSI"))
o_rssi_enable.rmempty = false
-- wbc.rssi.mode: RSSI Transfer Mode
o_rssi_mode = s_rssi:option(ListValue, "mode", translate("Transfer Mode"))
o_rssi_mode.rmempty = false
o_rssi_mode:value("tx", translate("Transceiver"))
o_rssi_mode:value("rx", translate("Receiver"))
o_rssi_mode.default = "tx"
-- wbc.rssi.send_ip_port: RSSI RX Data Send to IP:Port	
o_rssi_send_ip_port = s_rssi:option(Value, "send_ip_port", translate("Send RSSI Data to IP:Port"))
o_rssi_send_ip_port.datatype = "ipaddrport"
o_rssi_send_ip_port:depends("mode", "rx")
-- wbc.rssi.encrypt_enable: rssi Encrypt Enable
o_rssi_encrypt_enable = s_rssi:option(Flag, "encrypt_enable", translate("Encrypt"))
o_rssi_encrypt_enable.rmempty = false
-- wbc.rssi.password: Encrypt Password
o_rssi_encrypt_password = s_rssi:option(Value, "encrypt_password", translate("Password"))
o_rssi_encrypt_password.rmempty = false
o_rssi_encrypt_password.password = true
o_rssi_encrypt_password:depends("encrypt_enable", 1)


-- wbc.telemetry: Telemetry settings
s_telemetry = m:section(TypedSection, "telemetry", translate("Telemetry Settings"))
s_telemetry.anonymous = true
s_telemetry.addremove = false
-- wbc.telemetry.enable: Telemetry Enable
o_telemetry_enable = s_telemetry:option(Flag, "enable", translate("Enable Telemetry"))
o_telemetry_enable.rmempty = false
-- wbc.telemetry.mode: Telemetry Transfer Mode
o_telemetry_mode = s_telemetry:option(ListValue, "mode", translate("Transfer Mode"))
o_telemetry_mode.rmempty = false
o_telemetry_mode:value("tx", translate("Transceiver"))
o_telemetry_mode:value("rx", translate("Receiver"))
o_telemetry_mode.default = "tx"
-- wbc.telemetry.uart: Telemetry UART Interface
o_telemetry_uart = s_telemetry:option(ListValue, "uart", translate("Telemetry UART Interface"))
for k,v in ipairs(tty_list) do 
	o_telemetry_uart:value(v) 
end
o_telemetry_uart.default = "/dev/ttyUSB0"

-- wbc.telemetry.baud: Telemetry UART Baud rate
o_telemetry_baud = s_telemetry:option(ListValue, "baud", translate("Telemetry UART Baud Rate"))
o_telemetry_baud:value(9600, "9600 bps")
o_telemetry_baud:value(19200, "19200 bps")
o_telemetry_baud:value(38400, "38400 bps")
o_telemetry_baud:value(57600, "57600 bps")
o_telemetry_baud:value(115200, "115200 bps")
o_telemetry_baud:value(230400, "230400 bps")
o_telemetry_baud.default = 57600
o_telemetry_baud:depends("mode", "tx")
-- wbc.telemetry.cts: Telemetry TX CTS
o_telemetry_cts = s_telemetry:option(ListValue, "cts", translate("Telemetry TX CTS Mode"))
o_telemetry_cts:value(0, translate("CTS Protection Disabled"))
o_telemetry_cts:value(1, translate("CTS Protection Enabled"))
o_telemetry_cts.default = 0
o_telemetry_cts:depends("mode", "tx")
-- wbc.telemetry.retrans: Telemetry TX Retransmission Count
o_telemetry_retrans = s_telemetry:option(ListValue, "retrans", translate("Telemetry TX Retransmission Count"))
o_telemetry_retrans:value(1, translate("Send each frame once"))
o_telemetry_retrans:value(2, translate("Twice"))
o_telemetry_retrans:value(3, translate("Three times"))
o_telemetry_retrans.default = 2
o_telemetry_retrans:depends("mode", "tx")
-- wbc.telemetry.proto: Telemetry TX Protocol
o_telemetry_proto = s_telemetry:option(ListValue, "proto", translate("Telemetry Protocol"))
o_telemetry_proto:value(0, translate("Mavlink"))
o_telemetry_proto:value(1, translate("Generic"))
o_telemetry_proto.default = 0
o_telemetry_proto:depends("mode", "tx")
-- wbc.telemetry.bitrate: Telemetry TX Bit Rate (802.11abg)
o_telemetry_bitrate = s_telemetry:option(ListValue, "bitrate", translate("Telemetry TX Bit Rate (802.11b/g)"), translate("Rate should divide by 2 when chanbw=10MHz; 4 for 5MHz. "))
o_telemetry_bitrate:value(1, "1 Mbps (802.11b, DSSS)")
o_telemetry_bitrate:value(2, "2 Mbps (802.11b, DSSS)")
o_telemetry_bitrate:value(5, "5.5 Mbps (802.11b, CCK)")
o_telemetry_bitrate:value(11, "11 Mbps (802.11b, CCK)")
o_telemetry_bitrate:value(6, "6 Mbps (802.11g, BPSK, 1/2)")
o_telemetry_bitrate:value(9, "9 Mbps (802.11g, BPSK, 3/4)")
o_telemetry_bitrate:value(12, "12 Mbps (802.11g, QPSK, 1/2)")
o_telemetry_bitrate:value(18, "18 Mbps (802.11g, QPSK, 3/4)")
o_telemetry_bitrate:value(24, "24 Mbps (802.11g, 16-QAM, 1/2)")
o_telemetry_bitrate:value(36, "36 Mbps (802.11g, 16-QAM, 3/4)")
o_telemetry_bitrate:value(48, "48 Mbps (802.11g, 64-QAM, 2/3)")
o_telemetry_bitrate.default = 12
o_telemetry_bitrate:depends("wifimode", 0)
-- wbc.telemetry.mcs: MCS index (802.11n/ac)
o_telemetry_mcs = s_telemetry:option(ListValue, "mcs", translate("MCS index (802.11n/ac)"), translate("Rate should divide by 2 when chanbw=10MHz; 4 for 5MHz. ")..translate("<br />In most cases you should choose MCS0~7."))
o_telemetry_mcs:value(0, "MCS 0 (6.5 Mbps, 1x1, BPSK, 1/2)")
o_telemetry_mcs:value(1, "MCS 1 (13.0 Mbps, 1x1, QPSK, 1/2)")
o_telemetry_mcs:value(2, "MCS 2 (19.5 Mbps, 1x1, QPSK, 3/4)")
o_telemetry_mcs:value(3, "MCS 3 (26.0 Mbps, 1x1, 16-QAM, 1/2)")
o_telemetry_mcs:value(4, "MCS 4 (39.0 Mbps, 1x1, 16-QAM, 3/4)")
o_telemetry_mcs:value(5, "MCS 5 (52.0 Mbps, 1x1, 64-QAM, 2/3)")
o_telemetry_mcs:value(6, "MCS 6 (58.5 Mbps, 1x1, 64-QAM, 3/4)")
o_telemetry_mcs:value(7, "MCS 7 (65.0 Mbps, 1x1, 64-QAM, 5/6)")
o_telemetry_mcs:depends("wifimode", 1)
-- wbc.telemetry.wifimode: Wi-Fi mode (802.11g / 802.11n)
o_telemetry_wifimode = s_telemetry:option(ListValue, "wifimode", translate("Wi-Fi Mode"))
o_telemetry_wifimode:value(0, "802.11abg")
o_telemetry_wifimode:value(1, "802.11n (MCS)")
o_telemetry_wifimode.default = 0
o_telemetry_wifimode:depends("mode", "tx")
-- wbc.telemetry.ldpc: LDPC encode (for 802.11n/802.11ac)
o_telemetry_ldpc = s_telemetry:option(Flag, "ldpc", translate("LDPC encode enable"), translate("Make sure that LDPC is supported by both tx & rx Wi-Fi card"))
o_telemetry_ldpc.default = 0
o_telemetry_ldpc:depends("wifimode", "1")
o_telemetry_ldpc:depends("wifimode", "2")
o_telemetry_ldpc:depends("wifimode", "3")
-- wbc.telemetry.stbc: STBC encode (for 802.11n/802.11ac)
o_telemery_stbc = s_telemetry:option(Flag, "stbc", translate("STBC encode enable"), translate("Make sure that STBC is supported by both tx & rx Wi-Fi card; Use at least 2x2 Wi-Fi card"))
o_telemery_stbc.default = 0
o_telemery_stbc:depends("wifimode", "1")
o_telemery_stbc:depends("wifimode", "2")
o_telemery_stbc:depends("wifimode", "3")
-- wbc.telemetry.send_ip_port: Telemetry RX Send to IP:Port	
o_telemetry_send_ip_port = s_telemetry:option(Value, "send_ip_port", translate("Send Telemetry Data to IP:Port"))
o_telemetry_send_ip_port.datatype = "ipaddrport"
o_telemetry_send_ip_port:depends("mode", "rx")
-- wbc.telemetry.save_enable: Telemetry Save Enable
o_telemetry_save_enable = s_telemetry:option(Flag, "save_enable", translate("Enable Telemetry Save"))
o_telemetry_save_enable.rmempty = false
o_telemetry_save_enable:depends("mode", "rx")
-- wbc.telemetry.savepath: Save Telemetry Data To Path
o_telemetry_savepath = s_telemetry:option(Value, "telemetry", translate("Save Telemetry Data To Path"))
o_telemetry_savepath.default = '/mnt/sda1/wbc_telemetry'
o_telemetry_savepath.placeholder = '/mnt/sda1/wbc_telemetry'
o_telemetry_savepath:depends("save_enable", 1)
--[[
-- wbc.telemetry.osd_ini_enable: 
--	Use osd .ini in openwrt instead of the one in /boot/ in rpi 
o_telemetry_osd_ini_enable = s_telemetry:option(Flag, "osd_ini_enable", translate("RPi get osd config from OpenWrt"), translate("Or will use /boot/osdconfig.ini"))
o_telemetry_osd_ini_enable.rmempty = false
o_telemetry_osd_ini_enable:depends("mode", "rx")
]]--
-- wbc.telemetry.encrypt_enable: telemetry Encrypt Enable
o_telemetry_encrypt_enable = s_telemetry:option(Flag, "encrypt_enable", translate("Encrypt"))
o_telemetry_encrypt_enable.rmempty = false
-- wbc.telemetry.password: Encrypt Password
o_telemetry_encrypt_password = s_telemetry:option(Value, "encrypt_password", translate("Password"))
o_telemetry_encrypt_password.rmempty = false
o_telemetry_encrypt_password.password = true
o_telemetry_encrypt_password:depends("encrypt_enable", 1)


--[[
-- wbc.uplink: Uplink settings
s_uplink = m:section(TypedSection, "uplink", translate("Uplink Settings"))
s_uplink.anonymous = true
s_uplink.addremove = false
-- wbc.uplink.enable: Uplink Enable
o_uplink_enable = s_uplink:option(Flag, "enable", translate("Enable Uplink"))
o_uplink_enable.rmempty = false
-- wbc.uplink.mode: Uplink Transfer Mode
o_uplink_mode = s_uplink:option(ListValue, "mode", translate("Transfer Mode"))
o_uplink_mode.rmempty = false
o_uplink_mode:value("tx", translate("Transceiver"))
o_uplink_mode:value("rx", translate("Receiver"))
o_uplink_mode.default = "tx"
-- wbc.uplink.port: Uplink Port on Air
o_uplink_port = s_uplink:option(Value, "port", translate("Uplink Port on Air"))
o_uplink_port.default = 3
o_uplink_port.placeholder = 3
o_uplink_port.datatype = "range(0,127)"
-- wbc.uplink.cts: Uplink TX CTS
o_uplink_cts = s_uplink:option(ListValue, "cts", translate("Uplink TX CTS Mode"))
o_uplink_cts:value(0, translate("CTS Protection Disabled"))
o_uplink_cts:value(1, translate("CTS Protection Enabled"))
o_uplink_cts.default = 0
o_uplink_cts:depends("mode", "tx")
-- wbc.uplink.retrans: Uplink TX Retransmission Count
o_uplink_retrans = s_uplink:option(ListValue, "retrans", translate("Uplink TX Retransmission Count"))
o_uplink_retrans:value(1, translate("Send each frame once"))
o_uplink_retrans:value(2, translate("Twice"))
o_uplink_retrans:value(3, translate("Three times"))
o_uplink_retrans.default = 2
o_uplink_retrans:depends("mode", "tx")
-- wbc.uplink.bitrate: Uplink TX Bit Rate
o_uplink_bitrate = s_uplink:option(ListValue, "bitrate", translate("Uplink TX Bitrate"))
o_uplink_bitrate:value(6, "6 Mbps")
o_uplink_bitrate:value(12, "12 Mbps")
o_uplink_bitrate:value(18, "18 Mbps")
o_uplink_bitrate:value(24, "24 Mbps")
o_uplink_bitrate:value(36, "36 Mbps")
o_uplink_bitrate.default = 6
o_uplink_bitrate:depends("mode", "tx")
-- wbc.uplink.uart: Uplink UART Interface
o_uplink_uart = s_uplink:option(ListValue, "uart", translate("Uplink UART Interface"))
for k,v in ipairs(tty_list) do 
	o_uplink_uart:value(v) 
end
o_uplink_uart.default = "/dev/ttyUSB0"
-- wbc.uplink.baud: Uplink UART Baud rate
o_uplink_baud = s_uplink:option(ListValue, "baud", translate("Uplink UART Baud Rate"))
o_uplink_baud:value(9600, "9600 bps")
o_uplink_baud:value(19200, "19200 bps")
o_uplink_baud:value(38400, "38400 bps")
o_uplink_baud:value(57600, "57600 bps")
o_uplink_baud:value(115200, "115200 bps")
o_uplink_baud:value(230400, "230400 bps")
o_uplink_baud.default = 57600
o_uplink_baud:depends("mode", "rx")
-- wbc.uplink.proto: Uplink TX Protocol
o_uplink_proto = s_uplink:option(ListValue, "proto", translate("Uplink Protocol"))
o_uplink_proto:value(0, translate("Mavlink"))
o_uplink_proto:value(1, translate("Generic"))
o_uplink_proto.default = 0
o_uplink_proto:depends("mode", "tx")
-- wbc.uplink.rproto: Uplink RX Protocol
o_uplink_rproto = s_uplink:option(ListValue, "rproto", translate("Uplink RX Protocol"))
o_uplink_rproto:value(0, translate("MSP"))
o_uplink_rproto:value(1, translate("Mavlink"))
o_uplink_rproto:value(2, translate("SUMD"))
o_uplink_rproto:value(3, translate("IBUS"))
o_uplink_rproto:value(4, translate("SRXL/XBUS"))
o_uplink_rproto:value(99, translate("disable R/C"))
o_uplink_rproto.default = 0
o_uplink_rproto:depends("mode", "rx")
]]

-- wbc.rc: R/C settings
s_rc = m:section(TypedSection, "rc", translate("R/C Settings"))
s_rc.anonymous = true
s_rc.addremove = false
-- wbc.rc.enable: R/C Enable
o_rc_enable = s_rc:option(Flag, "enable", translate("Enable R/C"))
o_rc_enable.rmempty = false
-- wbc.rc.mode: R/C Transfer Mode
o_rc_mode = s_rc:option(ListValue, "mode", translate("Transfer Mode"))
o_rc_mode.rmempty = false
o_rc_mode:value("tx", translate("Transceiver"))
o_rc_mode:value("rx", translate("Receiver"))
o_rc_mode.default = "tx"
-- wbc.rc.uart: R/C UART Interface
o_rc_uart = s_rc:option(ListValue, "uart", translate("R/C UART Interface"))
for k,v in ipairs(tty_list) do 
	o_rc_uart:value(v) 
end
o_rc_uart.default = "/dev/ttyUSB0"
-- wbc.rc.proto: R/C TX Protocol
o_rc_proto = s_uplink:option(ListValue, "proto", translate("R/C Protocol"))
o_rc_proto:value("sbus", translate("S.BUS"))
--o_rc_proto:value(1, translate("Generic"))
o_rc_proto.default = 0

local apply = luci.http.formvalue("cbi.apply")
if apply then
	luci.sys.exec("/etc/init.d/ezwifibroadcast enable")
    luci.sys.exec("/etc/init.d/ezwifibroadcast restart")
end

return m
