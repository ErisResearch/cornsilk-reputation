function debug_print(outstr)
	--only print if GPIO4 is set to low
	--do nothing if set to high
	--note: Eagle schematic has GPIO 4/5 swapped
	if gpio.read(2) == gpio.LOW then
		print("DEBUG: "..outstr)
	end
end

function finish_startup(val_table)
	debug_print("In finish_startup: IP = "..val_table.IP)
	--sntp.sync()
    dofile("mqtt_command.lua")
	debug_print("starting up telnet")
    dofile("telnet.lua")
    wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
	debug_print("done")
    end

function wifi_connect()

	ssid = getconfigvalue("ssid")
	wifi_password = getconfigvalue("wifikey")
	hostname = getconfigvalue("hostname")

    debug_print ("Connecting to "..ssid.." as "..hostname)
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
	debug_print("Waiting on an IP")
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
	--setup GPIO 4 for debug info
	gpio.mode(2, gpio.INPUT)
	--restart every 24 hours
--	cron.schedule("0 13 * * *", daily_restart)
--	tmr.register(6,3600000,tmr.ALARM_AUTO, daily_restart )
--	tmr.start(6)
	dofile("config.lua")
	loadconfig("config.json")
    wifi_connect()
    end

-- Wait 5 seconds before actually doing anythin
-- That way you don't end up in a panic loop that
-- is faster than you can upload a replacement file for
hours_ticked = 0
startupTimer = tmr.create()
startupTimer:register(5000, tmr.ALARM_SINGLE,startup)
startupTimer:start()
dofile("controlhook.lua")
