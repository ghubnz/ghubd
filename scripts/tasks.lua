civi = require("civicrm")
slack = require("slack")

local _M = {}

function _M.RFID(client, msg) 
	-- {"uid":"","topic":"","token":""}
	logf("RFID tag on: %s", msg.Payload)
	local payload = json.decode(msg.Payload)
	data, err = civi.getContactByExtID(payload.uid)
	local rslt = "0"
	if err ~= nil then
		logf("Error(%s+%s): %s", msg.Topic, msg.MessageID, err)
	end
	if data ~= nil then
		token = client:Publish(payload.topic, 0, false, payload.token)
		if token:Wait() and token:Error() ~= nil then
			Log(token.Error())	
		end
		-- backward old version
		if payload.device == nil then
			payload.device = "Old Box"
		end
		slack.swapEvent(data.display_name, payload.device, payload.uid)
	end
end

beats = {}

function _M.Heartbeat(client, msg) 
	-- record heartbeat timestamp
	beats[msg.Payload] = {
		timestamp = os.time(),
		lastNotice = ""
	}
end

function _M.Notification(client, ctx)
	-- based on heartbeat to send out notification
	for device, t in pairs(beats) do
		beats[device][lastNotice] = slack.noHeartBeats(device, t)
	end
end

return _M
