-- {"uid":"","topic":"","token":""}
Logf("RFID tag on: %s", Message.Payload)
local payload = json.decode(Message.Payload)
data, err = getContactByExtID(payload.uid)
local rslt = "0"
if err ~= nil then
	Logf("Error(%s+%s): %s", Message.Topic, Message.MessageID, err)
end
if data ~= nil then
	token = Client:Publish(payload.topic, 0, false, payload.token)
	if token:Wait() and token:Error() ~= nil then
		Log(token.Error())	
	end
end
