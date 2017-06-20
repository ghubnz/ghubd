-- RISK is the danger zone and has to be loaded first
RISK = require("RISK")

http = require("http")
url = require("url")
json = require("json")
tasks = require("tasks")
utils = require("utils")

-- global variables
Prefix = "ghub"

config.MQTT = {
	{
		Addr = RISK.MQTT.Addr,
		Username = RISK.MQTT.Username,
		Password = RISK.MQTT.Password
	}
}

config.ClientId = utils.getClientId()

-- fn:topic:qos
config.Tasks = {}
config.Tasks["tasks.RFID"] = {}
config.Tasks["tasks.RFID"][Prefix .. ":rfid"] = 0

config.Schedule.Tick = 1000
-- fn: tick
config.Schedule.Tasks = {}

-- functions
function onDefaultMessage(client, msg) 
	logf("Default: %s", msg.Payload)
end

function afterInit(client)
	-- register the client to hub
	data = {
		M = "I",
		ID = config.ClientId,
	}
	token = client:Publish(Prefix .. ":hub", 0, true, json.encode(data))
	if token:Wait() and token:Error() ~= nil then
		logf("onAfterInit: %s", err(err(token)))
	end
end

function beforeFinalize(client)
	-- register the client to hub
	data = {
		M = "F",
		ID = config.ClientId,
	}
	token = client:Publish(Prefix .. ":hub", 0, true, json.encode(data))
	if token:Wait() and token:Error() ~= nil then
		logf("onAfterInit: %s", err(err(token)))
	end
end

function onError(ctx, e)
	logf("%s: %s", ctx.Id, err(e))
end

function err(e)
	return e:Error()
end
