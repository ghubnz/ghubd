local cfgSlack = RISK.Slack

local _M = {}

function _M.swapEvent(name, device, rfid)
	local txt
	if name == "" then
		txt = string.format("Unknown RFID `%s` tapped on `%s`", rfid, device)	
	else
		txt = string.format("Member `%s` tapped on `%s`", name, device)
	end
	_M.postMessage(cfgSlack.RFIDHook, txt)
end

function _M.noHeartBeats(device, t)
	local tunit = "sec(s)"
	local a = t / 60
	if a >= 1 then
		t = a
		tunit = "min(s)"
		a = t / 60
		if a >= 1 then
			t = a
			tunit = "hour(s)"
			a = t / 24
			if a >= 1 then
				t = a
				tunit = "day(s)"
			end
		end
	end
	local txt = string.format("`%s` has been *%d %s* no heartbeat", device, t, tunit)
	log(txt)
	_M.postMessage(cfgSlack.RFIDHook, txt)
end

function _M.postMessage(hook, msg)
	response, err = http.post(hook, {
		headers = {Accept="application/json"},
		body = json.encode({
			text=msg
		})
	})
	if err ~= nil then
		return nil, err
	end
	log(response.body)
end

return _M
