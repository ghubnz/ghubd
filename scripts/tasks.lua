cache = require("cache")
slack = require("slack")

local _M = {}

function _M.RFID(client, msg) 
	-- {"uid":"","topic":"","token":""}
	logf("RFID tag on: %s", msg.Payload)
	local payload = json.decode(msg.Payload)
	-- load from cache
	data, err = cache.getContactByExtID(payload.uid)

	local displayName = ''
	if err == nil then
		local topic = payload.topic
		local token = ''
		if data ~= nil then
			token = payload.token
			displayName = data.display_name
		end	
		token = client:Publish(topic, 0, false, token)
		if token:Wait() and token:Error() ~= nil then
			Log(token.Error())
		end
	else
		logf("Error(%s+%s): %s", msg.Topic, msg.MessageID, err)
	end

	-- backward old version
	if payload.device == nil then
		payload.device = "Old Box"
	end
	slack.swapEvent(displayName, payload.device, payload.uid, err)
end

beats = {}

function _M.Heartbeat(client, msg) 
	-- record heartbeat timestamp
	if beats[msg.Payload] == nil then
		local txt = string.format("`%s` initialised", msg.Payload)	
		log(txt)
		slack.postMessage(RISK.Slack.RFIDHook, txt)		
	else
		if beats[msg.Payload].lastNotice ~= "" then
			local txt = string.format("`%s` recovered", msg.Payload)	
			log(txt)
			slack.postMessage(RISK.Slack.RFIDHook, txt)
		end
	end
	beats[msg.Payload] = {
		timestamp = os.time(),
		lastNotice = ""
	}
	logf("Heartbeat(%s)", msg.Payload)
end

function _M.Notification(client, ctx)
	-- based on heartbeat to send out notification
	for device, t in pairs(beats) do
		if type(beats[device]) ~= "table" then
			beats[device] = {}
		end
		beats[device].lastNotice = slack.noHeartBeats(device, t)
	end
end

return _M
