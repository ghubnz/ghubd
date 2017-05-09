local cfgCiviCRM = RISK.CiviCRM
function getContactByExtID(eid)
	local params = {
		entity="contact",
		action="get",
		key=cfgCiviCRM.siteKey,
		api_key=cfgCiviCRM.userKey,
		json=1,
		external_identifier=eid,
	}
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
	if data.count > 1 then
		return nil, string.format("The external identifier is duplicated: %s", eid)
	end
	local key = next(data.values)
	return data.values[key], nil
end
