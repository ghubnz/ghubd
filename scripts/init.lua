-- RISK is the danger zone and has to be loaded first
RISK = require("RISK")

http = require("http")
url = require("url")
json = require("json")
civi = require("civicrm")

Logf("Initialisation")

config.MQTT = {
	{
		Addr = "tcp://api.ghub.nz:8883",
		Username = RISK.MQTT.Username,
		Password = RISK.MQTT.Password,
	}
}
config.Prefix = "iot"
config.ClientId = "hub"
config.Tasks = {}
-- Topic: iot/rfid
config.Tasks["rfid"] = 0
-- TODO
config.Schedule.Tick = 1000
config.Schedule.Tasks = {}
config.Schedule.Tasks["task1"] = 5000

function DefaultPublishHandler(c,m) 
	Log(m.Payload)
end
