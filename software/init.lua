function finish_startup()
    dofile("roomba_serial.lua")
    dofile("mqtt_command.lua")
	dofile("telnet.lua")
    end

function wifi_connect()

	ssid = ""
	wifi_password = ""
	hostname = "catbot"

	--print ("Connecting to "..ssid.." as "..hostname)
    wifi.setmode(wifi.STATION)                                                          
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() wifi.sta.eventMonStop() finish_startup() end)
    wifi.sta.eventMonStart(100)
    wifi.sta.sethostname(hostname)
    wifi.sta.config(ssid,wifi_password)
    end    

function daily_restart()
	hours_ticked = hours_ticked + 1
	if hours_ticked >= 24 then
		node.restart()
	end
end

function startup()
    node.setcpufreq(node.CPU160MHZ)
	--restart every 24 hours
	tmr.register(6,3600000,tmr.ALARM_AUTO, daily_restart )
	tmr.start(6)
    wifi_connect()
    end

hours_ticked = 0
tmr.alarm(0,5000,0,startup)
