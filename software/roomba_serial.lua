serial_bytes_table = {}
status_bytes_table = {}

current_status = nil
function update_status(new_status)

	if new_status == nil and current_status == nil then
		--default to charging
		current_status = "CHARGE"
	elseif new_status ~=nil then
		current_status = new_status
		end
	mqtt_send(current_status)
	end

function roomba_command_register(command, serial_bytes, status_bytes)
	serial_bytes_table[command] = serial_bytes
	status_bytes_table[command] = status_bytes
	end
function roomba_serial_enable()
	--GPIO 16 (0) and 14 (5),
	gpio.write(0,gpio.HIGH)
	gpio.write(5,gpio.LOW)
    end

function roomba_serial_disable()
	--GPIO 16 (0) and 14 (5),
	gpio.write(0,gpio.LOW)
	gpio.write(5,gpio.LOW)
    end


require 'string'
charging_source = -1
charging_status = -1

function roomba_parse_sensor_response(data)
    charging_source, charging_status = struct.unpack("BB",data)
end

function roomba_update_sensors()
    uart.write(0,149,2,34,21)
end

function roomba_start_sensor_stream() 
    uart.on("data",2,roomba_parse_sensor_response,0)
    tmr.start(2) 
end

function roomba_stop_sensor_stream()
    tmr.stop(2)
end

function roomba_serial_send( a )
    roomba_serial_enable()
    print (a)
    end

function roomba_debug_print( text)
	roomba_serial_disable()
	print(text)
	roomba_serial_enable()
	end

function roomba_set_status( new_status )
    tmr.stop(1)
    roomba_stop_sensor_stream() 
    roomba_update_sensors()
	sbytes = serial_bytes_table[new_status]
	mbytes = status_bytes_table[new_status]
	if sbytes ~= nil and mbytes~=nil then
        sbytes()
	    --roomba_serial_send(sbytes)
		--mqtt_send(mbytes)
		update_status(new_status)
	else
		--roomba_debug_print("Unregistered status"..new_status)
		end
    end

uart_tval = 16
uart_waiting = false
uart_buffer = ""
uart_parse_wait = true
uart_waiting_bytes = -1

function roomba_is_charging()
    -- determine if charging
    return charging_source > 0 and charging_source < 4
    end

function roomba_monitor_until_charging_body()
    -- todo: see if your charging
    if roomba_is_charging() then
        roomba_set_status("CHARGE")
    -- todo: make sure you aren't stuck
    end
    end


function roomba_monitor_until_charging()
    -- repeat every 100 ms until one of the two is the case
    roomba_start_sensor_stream()
    tmr.start(1)
    end

function roomba_charge()
    --print "Charging status"
    --this function needs to check if the roomba is charging
    if not roomba_is_charging() then
    -- if it is not, initiate docking
        roomba_set_status("DOCK")
        end
    end

function roomba_dock()
    --print "seeking out dock"
    -- todo: check if charging, do nothing if you are
    if not roomba_is_charging() then
        -- send dock bytes
        uart.write(0,128,143)
        -- watch moving roomba until charging
        roomba_monitor_until_charging()
    else
        roomba_set_status("CHARGE")
        end
    end

function roomba_clean()
    --start cleaning mode
    -- watch moving roomba until charging
    --print "Set in cleaning mode"
    uart.write(0,128,135)
    roomba_monitor_until_charging()
    end

function roomba_stuck()
    -- todo : play a song every 10 seconds until you're charging again
    print "I'm stuck!"
    end

function roomba_reset()
    -- todo : play a song every 10 seconds until you're charging again
    end


function roomba_initialize()
    --print("Configuring roomba.....")
	--print("IP Stats: "..wifi.sta.getip())

	roomba_command_register("CHARGE",roomba_charge,"CHARGE")
	roomba_command_register("CLEAN",roomba_clean,"CLEAN")
	roomba_command_register("DOCK",roomba_dock,"DOCK")
	roomba_command_register("STUCK",roomba_stuck,"STUCK")
	roomba_command_register("RESET",roomba_reset,"RESET")

	--update_status(nil)
	--enable the serial output
	--gpio.mode(1,gpio.OUTPUT)
	gpio.mode(0,gpio.OUTPUT)
	gpio.mode(5,gpio.OUTPUT)
    roomba_serial_enable()
    uart.setup(0,115200,8,uart.PARITY_NONE,uart.STOPBITS_1,0)
    -- and set in passive mode just to be sure
    uart.write(0,128)
    --set up sensor monitoring
	--At this rate, we really only need to check for dockin every three seconds
    tmr.register(1,3000,tmr.ALARM_AUTO, roomba_monitor_until_charging_body)
    tmr.register(2,50,tmr.ALARM_AUTO, roomba_update_sensors)
    roomba_start_sensor_stream()
    end

roomba_initialize()
