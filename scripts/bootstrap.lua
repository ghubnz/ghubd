-- RISK is the danger zone and has to be loaded first
RISK = require("RISK")

http = require("http")
url = require("url")
json = require("json")
tasks = require("tasks")
utils = require("utils")
slack = require("slack")

-- global variables
Prefix = "iot"

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

config.Tasks["tasks.Heartbeat"] = {}
config.Tasks["tasks.Heartbeat"]["hub:heartbeat"] = 0 -- backwards
config.Tasks["tasks.Heartbeat"][Prefix .. ":heartbeat"] = 0


config.Schedule.Tick = 1000
-- fn: tick
config.Schedule.Tasks = {}
config.Schedule.Tasks["tasks.Notification"] = 5 * 60 * 1000

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
	slack.postMessage(RISK.Slack.RFIDHook, string.format("%s initialised", config.ClientId))
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

function onError(e, ctx)
	logf("%s: %s", ctx.Id, e)
end

function err(e)
	if type(e.Error) == "function" then
		return e:Error()
	end
	return e
end

tmp = require("slack")
tmp.swapEvent("Test", "Dev", "000000", "Exp")
error("Testing")
