m= nil
host = ""
user = ""
password = ""
command_topic = "roomba/command"
status_topic = "roomba/status"

previous_message = nil

function receive_message(client, topic, data)
    -- print(topic ..":")
    if data == previous_message then
        --roomba_debug_print("Dropping echo")
        previous_message = nil
    elseif data ~=nil then
        roomba_set_status(data)
        end
    end

function post_connect(client)
    end

function mqtt_send(text)
    previous_message = text
    --m:publish(status_topic,text,0,0, function(client) roomba_debug_print ("sent "..text) end)
    m:publish(status_topic,text,0,0, function(client) end)
    end

function on_connect(client)
    --print("connected")
    --client:subscribe(command_topic,0,function(client) print("subscribe success") update_status(nil) end)
    client:subscribe(command_topic,0,function(client) update_status(nil) end)
    end

function on_offline(client)
    --print("offline")
    end

function on_failure(client, reason)
    --print("Failed reason: "..reason)
    end


function setup_mqtt_command(host, user, password, command_topic)
    --print("Connecting to "..host.." as "..user)
    m = mqtt.Client("catbot",120,user,password)
    m:lwt("/lwt","offline",0,0)
    m:on("connect",on_connect)
    m:on("offline",on_offline)
    m:on("message",receive_message)
    m:connect(host,1883,0, on_connect, on_failure)
    end


setup_mqtt_command(host, user, password, command_topic)
