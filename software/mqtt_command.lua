m= nil
host = getconfigvalue("mqtt_server")
user = getconfigvalue("mqtt_user")
client_name = getconfigvalue("mqttt_name")
password = getconfigvalue("mqtt_password")
command_topic = getconfigvalue("mqtt_command_topic")
status_topic = getconfigvalue("mqtt_status_topic")

previous_message = nil

function receive_message(client, topic, data)
	if topic == command_topic then
		debug_print("MQTT Received command "..data)
	end
end

function mqtt_send(text)
    previous_message = text
    m:publish(status_topic,text,0,0, function(client) debug_print ("sent "..text) end)
    end

function on_connect(client)
	debug_print("MQTT Connected")
    client:subscribe(command_topic,0,function(client) debug_print("subscribe success") end)
	mqtt_send("Hello!")
    end

function on_offline(client)
    debug_print("MQTT offline")
    end

function on_failure(client, reason)
    debug_print("MQTT Failed reason: "..reason)
    end


function setup_mqtt_command(host, user, password, client_name, command_topic)
    --debug_print("Connecting to "..host.." as "..user)
    m = mqtt.Client(client_name,120,user,password)
    m:lwt("/lwt","offline",0,0)
    m:on("connect",on_connect)
    m:on("offline",on_offline)
    m:on("message",receive_message)
    m:connect(host,1883,false, on_connect, on_failure)
    end


setup_mqtt_command(host, user, password, client_name, command_topic)
