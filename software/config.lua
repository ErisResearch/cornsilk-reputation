config_table = nil

function loadconfig(filename)
    local decoder = sjson.decoder()
    if file.exists(filename) then
        file.open(filename)
        config_table = sjson.decode(file.read())
        file.close()
    end
    end

function getconfigvalue(name)
    if config_table ~=nil then
        return config_table[name]
    end
    end

function setconfigvalue(name,value)
    if config_table ~=nil then
        config_table[name] = value
    end
    end

function saveconfig(filename)
    if config_table ~=nil then
        ok, json = pcall(sjson.encode, config_table)
        if ok then
            if file.open(filename, "w+") then
                file.write(json)
                file.close()
            end
        end
    end
    end

