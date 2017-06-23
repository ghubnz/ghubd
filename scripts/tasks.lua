civi = require("civicrm")

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
	end
end

return _M
