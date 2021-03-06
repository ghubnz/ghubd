local cfgSlack = RISK.Slack

local toleranceSeconds = 5 * 60

local _M = {}

function _M.swapEvent(name, device, rfid, msg)
	msg = err(msg)
	local txt
	if name == "" then
		txt = string.format("Unknown RFID `%s` tapped on `%s` [ %s ]", rfid, device, msg)	
	else
		txt = string.format("Member `%s` tapped on `%s` [ %s ]", name, device, msg)
	end
	_M.postMessage(cfgSlack.RFIDHook, txt)
end

function _M.noHeartBeats(device, t)
	if type(t.timestamp) ~= "number" then
		return ""
	end
	local now = os.time()
	local ts = now - t.timestamp
	log("TS:", ts, " LN:", t.lastNotice)

	if ts < toleranceSeconds then
		return ""
	end

	local tunit = "sec(s)"
	local a = ts / 60
	if a >= 1 then
		ts = a
		tunit = "min(s)"
		a = ts / 60
		if a >= 1 then
			ts = a
			tunit = "hour(s)"
			a = ts / 24
			if a >= 1 then
				ts = a
				tunit = "day(s)"
			end
		end
	end
	local txt = string.format("`%s` has been *%d %s* no heartbeat", device, ts, tunit)
	log(txt)
	local noticePrint = string.format("%d %s", ts, tunit)
	if t.lastNotice ~= noticePrint then
		_M.postMessage(cfgSlack.RFIDHook, txt)
	end
	return noticePrint
end

function _M.postMessage(hook, msg)
	if hook == nil or hook == "" then
		return nil, nil
	end
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
