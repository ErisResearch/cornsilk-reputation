function finish_startup(val_table)
	print("In finish_startup: IP = "..val_table.IP)
--	sntp.sync()
--    dofile("mqtt_command.lua")
	print("starting up telnet")
    dofile("telnet.lua")
    wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
	print("done")
    end

function wifi_connect()

	ssid = getconfigvalue("ssid")
	wifi_password = getconfigvalue("wifikey")
	hostname = getconfigvalue("hostname")

    print ("Connecting to "..ssid.." as "..hostname)
    wifi.setmode(wifi.STATION)   
	wifi.setphymode(wifi.PHYMODE_N)
    wifi_config = {}
    wifi_config.ssid = getconfigvalue("ssid")
    wifi_config.pwd = getconfigvalue("wifikey")
	wifi_config.auto = true
	wifi_config.save = false

    hostname = getconfigvalue("hostname")

    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, finish_startup)
    wifi.sta.sethostname(hostname)
	wifi.sta.config(wifi_config)
	print("Waiting on an IP")
    end    

--function daily_restart()
--	roomba_serial_disable()
--	node.restart()
----	hours_ticked = hours_ticked + 1
----	if hours_ticked >= 24 then
----		node.restart()
----	end
--end

function startup()
    node.setcpufreq(node.CPU160MHZ)
	--restart every 24 hours
--	cron.schedule("0 13 * * *", daily_restart)
--	tmr.register(6,3600000,tmr.ALARM_AUTO, daily_restart )
--	tmr.start(6)
	dofile("config.lua")
	loadconfig("config.json")
	dofile("controlhook.lua")
    wifi_connect()
    end

hours_ticked = 0
startupTimer = tmr.create()
startupTimer:register(5000, tmr.ALARM_SINGLE,startup)
startupTimer:start()
