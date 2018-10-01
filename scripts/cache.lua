civi = require("civicrm")


local _M = {}

function _M.load(eid)
	local f = io.open(string.format("var/cache/contact/%s.json", eid), 'r')
	local data = ''
	if err == nil and f ~= nil then	
		data = f:read('*all') or ''
		f:close()		
	end
	return data
end

function _M.save(contact)	
	local fname = string.format("var/cache/contact/%s.json", contact.external_identifier)
	local f, err = io.open(fname, 'w')
	if err ~= nil then
		return
	end
	f:write(json.encode(contact))
	f:close()
end

function _M.getContactByExtID(eid)
	local data = _M.load(eid)
	if data == '' then
		data, err = civi.getContactByExtID(payload.uid)
		if err ~= nil then
			return nil, err
		end
		_M.save(data)
	end
	-- TODO Do we really want the expired function at the moment?
--[[
	if data.end_date ~= nil and data.end_date ~= "" then
		local year, month, day = splitDate(data.end_date)
		local endDate = os.time{year=year, month=month, day=day}
		if math.floor(os.difftime(os.time(), endDate) / (24 * 60 * 60)) < -10 then
			return data, "Expired"               
		end
	else
		return data, "Expired"
	end	
--]]
	return data, nil
end
