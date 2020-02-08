mutation = nil

-- GPIO Wiring
-- INPUT (0 = Pressed, 1 = Released)
--   BUTTON UP   = GPIO 12 (Index 6)
--   BUTTON DOWN = GPIO 13 (Index 7)
-- OUTPUT (0 = Released , 1 = Pressed)
--   BUTTON UP   = GPIO 16 (Index 0)
--   BUTTON DOWN = GPIO 14 (Index 5)

function setOuputUpValue(val)
	debug_print("Setting up output to ".. val)
	gpio.write(0, val)
end
function setOuputDownValue(val)
	debug_print("Setting down output to ".. val)
	gpio.write(5, val)
end

function registerTransmutation(hook)
	mutation = hook
end

function transmute(outPin, inLevel)
	-- do the transmutation if one is defined
	if mutation ~= nil then
		mutation(outPin, inLevel)
	else -- otherwise passthrough
		gpio.write(outPin, inLevel)
	end
end

function uptransmute(level, when, count)
	debug_print("Up button pressed set to "..level)
	transmute(0, level)
end
function downtransmute(level, when, count)
	debug_print("Down button pressed set to "..level)
	transmute(5, level)
end

function gpio_config()
	-- setup the outputs
	gpio.mode(0, gpio.OUTPUT)
	gpio.mode(5, gpio.OUTPUT)
	setOuputUpValue(gpio.LOW)
	setOuputDownValue(gpio.LOW)

	-- setup the inputs
	gpio.mode(6, gpio.INT)
	gpio.trig(6, "both", uptransmute) 
	gpio.mode(7, gpio.INT)
	gpio.trig(7, "both", downtransmute) 
end

gpio_config()
