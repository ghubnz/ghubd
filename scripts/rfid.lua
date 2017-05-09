-- {"uid":"","topic":"","token":""}
local payload = json.decode(Message.Payload)
data, err = getContactByExtID(payload.uid)
local rslt = "0"
if err ~= nil then
	Logf("Error(%s+%s): %s", Message.Topic, Message.MessageID, err)
end
token = Client:Publish(payload.topic, 0, false, payload.token)
if token:Wait() and token:Error() ~= nil then
	Log(token.Error())	
end
