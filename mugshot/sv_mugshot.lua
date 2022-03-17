--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to take a character photo of another player to be added to an arrest record
]]

CreateThread(function() Config.LoadPlugin("mugshot", function(pluginConfig)

    if pluginConfig.enabled then	

		local function SendMessage(type, source, message)
			if type == "success" then
				TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2Success ^0] ", message}})
			elseif type == "error" then
				TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", message}})
			elseif type == "debug" and Config.debugMode then
				TriggerClientEvent("chat:addMessage", source, {args = {"[ Debug ] ", message}})
			end
		end
	
		local random = math.random
        local function uuid()
            math.randomseed(os.time())
            local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
            return string.gsub(template, '[xy]', function (c)
                local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
                return string.format('%x', v)
            end)
        end
		
		local function all_trim(s)
		   return s:match( "^%s*(.-)%s*$" )
		end	
		
		local function GetFullName(Record)
			for i, section in ipairs(Record.sections) do
				for ii, field in ipairs(section.fields) do
					if field.uid == "first" then
						firstName = all_trim(field.value)
					elseif field.uid == "last" then
						lastName = all_trim(field.value)
					elseif field.uid == "mi" then
						middleName = all_trim(field.value)
						if middleName == nil or middleName == "" then
							fullName = firstName .. " " .. lastName
							
							return fullName
						else
							fullName = firstName .. " " .. middleName .. ". " .. lastName
							
							return fullName																			
						end
					end												
				end	
			end
			
			return nil
		end
		
		RegisterServerEvent("SonoranCAD::mugshot:FoundMugshot")
		AddEventHandler("SonoranCAD::mugshot:FoundMugshot", function(mugshot)
			_from = tonumber(source)
			
			Mugshot = mugshot				
		end)

        RegisterServerEvent("SonoranCAD::mugshot:GetMugshot")
		AddEventHandler("SonoranCAD::mugshot:GetMugshot", function(arresteePos)	
			local _source = tonumber(source)
			
			TriggerClientEvent("SonoranCAD::mugshot:FindMugshot", -1, arresteePos)
			Wait(1000)

			if tonumber(_from) ~= tonumber(_source) and Mugshot ~= nil then 
				_from = nil	

				local photoName = uuid()..".bmp"
				local filenameToSave = ("%s/%s/%s"):format(GetResourcePath(GetCurrentResourceName()), "filestore/civimages", photoName)
				exports[GetCurrentResourceName()]:SaveBase64ToFile(Mugshot, filenameToSave)

				local cadUrl = Config.proxyUrl.."civimages/"..photoName
				debugLog(("Saving player %s photo as %s"):format(_from, cadUrl))	

				SendMessage("success", _source, "Getting most recent records...")
				
				local apiId = GetIdentifiers(_source)[Config.primaryIdentifier]
			
				local payload = {{["apiId"] = apiId, ["serverId"] = Config.serverId, ["searchType"] = 1, ["value"] = 1, ["types"] = {8}}}
				performApiRequest(payload, "LOOKUP_INT", function(resp)	
					debugLog("Lookup: "..tostring(json.decode(resp)))
					local Records = json.decode(resp)
					if Records then
						table.sort(Records, function(a,b) return tonumber(a.id) > tonumber(b.id) end)
						
						for i, Record in ipairs(Records) do
							for ii, recordType in ipairs(pluginConfig.recordsWithMugshot) do
								print(recordType, Record.recordTypeId)
								if recordType == Record.recordTypeId then																	
									local replaceValues = { [pluginConfig.mugshotRecordUid] = cadUrl }
									local payload = {
										{
											["user"] = apiId,
											["useDictionary"] = true,
											["recordId"] = Record.id,
											["replaceValues"] = replaceValues,
											["serverId"] = Config.serverId,
										}
									}									
									performApiRequest(payload, "EDIT_RECORD", function(resp)
										if GetFullName(Record) and cadUrl and Record.id then
											TriggerClientEvent("SonoranCAD::mugshot:RecieveMugshot", _source, cadUrl, Record.id)
											SendMessage("success", _source, GetFullName(Record) .. "'(s) photo uploaded to Record #" .. Record.id .. ".")
											debugLog("Sent photo: "..tostring(cadUrl).." to Record #" .. Record.id .. " " .. resp)	
										else
											SendMessage("error", _source, "Could not find record or obtain image.")
										end									
									end)
									
									doBreak = true
									if doBreak then return end
								end
							end
							if doBreak then return end
						end
					else
						SendMessage("error", _source, "No arrest records found in CAD.")
					end
				end)
			else
				SendMessage("error", _source, "No player found.")
			end
		end)
    end

end) end)