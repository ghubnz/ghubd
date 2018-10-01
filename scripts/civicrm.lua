local cfgCiviCRM = RISK.CiviCRM

local _M = {}

function civiCall(params)
	local query = url.build_query_string(params)
	response, err = http.get(cfgCiviCRM.API, {
		query=query,
		headers = {
			Accept="application/json"
		}
	})
	if err ~= nil then
		return nil, err
	end
	local data = json.decode(response.body), nil
	if data.is_error ~= 0 then
		return nil, "" -- TODO extract error msg
	end
	return data, nil
end

function splitDate(d)
	local date = {}
	for i in d:gmatch("%d+") do
		table.insert(date, i)
	end
	return date[1], date[2], date[3]
end

function _M.getContactByExtID(eid)
	-- get contact
	local params = {
		entity="contact",
		action="get",
		key=cfgCiviCRM.siteKey,
		api_key=cfgCiviCRM.userKey,
		json=1,
		external_identifier=eid,
	}
	data, err = civiCall(params)
	if err ~= nil then
		return nil, err
	end
	if data.count > 1 then
		return nil, string.format("The external identifier is duplicated: %s", eid)
	end
	local key = next(data.values)
	local contact = data.values[key]
	if contact == nil then
		return nil, "Contact not found"
	end

	-- get membership
	local params = {
		entity="Membership",
		action="get",
		key=cfgCiviCRM.siteKey,
		api_key=cfgCiviCRM.userKey,
		json=1,
		contact_id = contact.contact_id,
	}
	data, err = civiCall(params)
	if err ~= nil then
		return nil, err
	end
	for i,v in pairs(data.values) do		
		if Expired and v.status_id == "4" then
			return contact, "Expired"
		end
		contact.end_date = v.end_date
		return contact, nil
	end
	return contact, "Membership not found"
end

return _M
