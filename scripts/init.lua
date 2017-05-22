-- RISK is the danger zone and has to be loaded first
RISK = require("RISK")

http = require("http")
url = require("url")
json = require("json")
civi = require("civicrm")

Logf("Initialisation")

config.MQTT = {
	{
		Addr = RISK.MQTT.Addr,
		Username = RISK.MQTT.Username,
		Password = RISK.MQTT.Password,
	}
}
config.Prefix = "iot"
config.ClientId = "hub"

config.Tasks = {}
-- Topic: iot/rfid
config.Tasks["rfid"] = 0

config.Schedule.Tick = 1000
config.Schedule.Tasks = {}


function MQTTDefaultHandler(Client, Message) 
	Logf("Default: %s", Message.Payload)
end

function ScheduleDefaultFunc(ctx)
	Log("Scheduler")
end
