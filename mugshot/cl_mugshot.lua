--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to take a character photo of another player to be added to an arrest record
]]

CreateThread(function() 
    Config.LoadPlugin("mugshot", function(pluginConfig)

        if pluginConfig.enabled then	
			
			Keys = {
				["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
				["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
				["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
				["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
				["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
				["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
				["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
				["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
				["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
			}			
			
			-- functions used from dpemotes
			local AnimationDuration = -1
			local ChosenAnimation = ""
			local ChosenDict = ""
			local IsInAnimation = false
			local MostRecentChosenAnimation = ""
			local MostRecentChosenDict = ""
			local MovementType = 0
			local PlayerGender = "male"
			local PlayerHasProp = false
			local PlayerProps = {}
			local PlayerParticles = {}
			local SecondPropEmote = false
			local lang = Config.MenuLanguage
			local PtfxNotif = false
			local PtfxPrompt = false
			local PtfxWait = 500
			local PtfxNoProp = false
			local function PtfxStart()				
				if PtfxNoProp then
				  PtfxAt = PlayerPedId()
				else
				  PtfxAt = prop
				end
				UseParticleFxAssetNextCall(PtfxAsset)
				Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtfxName, PtfxAt, Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, GetEntityBoneIndexByName(PtfxName, "VFX"), 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
				SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0)
				table.insert(PlayerParticles, Ptfx)
			end
			local function PtfxStop()
			  for a,b in pairs(PlayerParticles) do
				StopParticleFxLooped(b, false)
				table.remove(PlayerParticles, a)
			  end
			end	
			local function PtfxThis(asset)
				while not HasNamedPtfxAssetLoaded(asset) do
					RequestNamedPtfxAsset(asset)
					Wait(10)
				end
				UseParticleFxAssetNextCall(asset)
			end
			local function LoadPropDict(model)
				while not HasModelLoaded(GetHashKey(model)) do
					RequestModel(GetHashKey(model))
					Wait(10)
				end
			end			
			local function LoadAnim(dict)
				while not HasAnimDictLoaded(dict) do
					RequestAnimDict(dict)
					Wait(10)
				end
			end
			local function DestroyAllProps()
				for _,v in pairs(PlayerProps) do
					DeleteEntity(v)
				end
				PlayerHasProp = false
			end			
			local function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
				local Player = PlayerPedId()
				local x,y,z = table.unpack(GetEntityCoords(Player))

				if not HasModelLoaded(prop1) then
					LoadPropDict(prop1)
				end

				prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
				AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
				table.insert(PlayerProps, prop)
				PlayerHasProp = true
				SetModelAsNoLongerNeeded(prop1)
			end			
			local function OnEmotePlay(EmoteName)
				if not DoesEntityExist(GetPlayerPed(-1)) then
					return false
				end
			
				SetCurrentPedWeapon(GetPlayerPed(-1), GetHashKey('WEAPON_UNARMED'), true)

				ChosenDict,ChosenAnimation,ename = table.unpack(EmoteName)
				AnimationDuration = -1

				if PlayerHasProp then
					DestroyAllProps()
				end

				LoadAnim(ChosenDict)

				if EmoteName.AnimationOptions then
					if EmoteName.AnimationOptions.EmoteLoop then
						MovementType = 1
						if EmoteName.AnimationOptions.EmoteMoving then
							MovementType = 51
						end

						elseif EmoteName.AnimationOptions.EmoteMoving then
							MovementType = 51
						elseif EmoteName.AnimationOptions.EmoteMoving == false then
							MovementType = 0
						elseif EmoteName.AnimationOptions.EmoteStuck then
							MovementType = 50
						end
					else
						MovementType = 0
					end

				if EmoteName.AnimationOptions then
					if EmoteName.AnimationOptions.EmoteDuration == nil then 
					  EmoteName.AnimationOptions.EmoteDuration = -1
					  AttachWait = 0
					else
					  AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
					  AttachWait = EmoteName.AnimationOptions.EmoteDuration
					end

					if EmoteName.AnimationOptions.PtfxAsset then
					  PtfxAsset = EmoteName.AnimationOptions.PtfxAsset
					  PtfxName = EmoteName.AnimationOptions.PtfxName
					  if EmoteName.AnimationOptions.PtfxNoProp then
						PtfxNoProp = EmoteName.AnimationOptions.PtfxNoProp
					  else
						PtfxNoProp = false
					  end
					  Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(EmoteName.AnimationOptions.PtfxPlacement)
					  PtfxInfo = EmoteName.AnimationOptions.PtfxInfo
					  PtfxWait = EmoteName.AnimationOptions.PtfxWait
					  PtfxNotif = false
					  PtfxPrompt = true
					  PtfxThis(PtfxAsset)
					else
					  PtfxPrompt = false
					end
				end

				TaskPlayAnim(GetPlayerPed(-1), ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
				RemoveAnimDict(ChosenDict)
				IsInAnimation = true
				MostRecentDict = ChosenDict
				MostRecentAnimation = ChosenAnimation

				if EmoteName.AnimationOptions then
					if EmoteName.AnimationOptions.Prop then
						PropName = EmoteName.AnimationOptions.Prop
						PropBone = EmoteName.AnimationOptions.PropBone
						PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(EmoteName.AnimationOptions.PropPlacement)
						if EmoteName.AnimationOptions.SecondProp then
						  SecondPropName = EmoteName.AnimationOptions.SecondProp
						  SecondPropBone = EmoteName.AnimationOptions.SecondPropBone
						  SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
						  SecondPropEmote = true
						else
						  SecondPropEmote = false
						end
						Wait(AttachWait)
						AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
						if SecondPropEmote then
						  AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6)
						end
					end
				end
				return true
			end
			local function EmoteCancel()
				PtfxNotif = false
				PtfxPrompt = false

				if IsInAnimation then
					PtfxStop()
					ClearPedTasks(GetPlayerPed(-1))
					DestroyAllProps()
					IsInAnimation = false
				end
			end
			AddEventHandler('onResourceStop', function(resource)
				if resource == GetCurrentResourceName() and IsInAnimation then
					DestroyAllProps()
					ClearPedTasksImmediately(GetPlayerPed(-1))
					ResetPedMovementClipset(PlayerPedId())
				end
			end)			
			
			----
			local function Draw3DText(x,y,z, text)
				local onScreen,_x,_y=World3dToScreen2d(x,y,z)
				local px,py,pz=table.unpack(GetGameplayCamCoords())
				SetTextScale(0.35, 0.35)
				SetTextFont(4)
				SetTextProportional(1)
				SetTextColour(255, 255, 255, 215)

				SetTextEntry("STRING")
				SetTextCentre(1)
				AddTextComponentString(text)
				DrawText(_x,_y)
				local factor = (string.len(text)) / 370
				DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
			end						
			local function isNearMugshotComputer()
				local playerCoords = GetEntityCoords(PlayerPedId())
				
				for k, mugshot in ipairs(pluginConfig.mugshotLocations) do
					if math.abs(#(playerCoords - mugshot.computerPos)) <= pluginConfig.drawDistance then
						return mugshot					
					end
				end
				
				return nil
			end
			local function isNearMugshotPhoto()
				local playerCoords = GetEntityCoords(PlayerPedId())
				
				for k, mugshot in ipairs(pluginConfig.mugshotLocations) do
					if math.abs(#(playerCoords - vector3(mugshot.photoPos.x, mugshot.photoPos.y, mugshot.photoPos.z))) <= pluginConfig.drawDistance then
						return mugshot					
					end
				end
				
				return nil
			end
			local function isFacingArrestee()
				local entityHeading = GetEntityHeading(PlayerPedId())
				
				if (entityHeading >= nearMugshot.photoPos.w - 15) and (entityHeading <= nearMugshot.photoPos.w + 15) then
					return true
				elseif (entityHeading >= nearMugshot.photoPos.w + 360 - 15) and (entityHeading <= nearMugshot.photoPos.w + 360 + 15) then
					return true
				else
					return false
				end
			end
			
			RegisterNetEvent("SonoranCAD::mugshot:FindMugshot")
			AddEventHandler("SonoranCAD::mugshot:FindMugshot", function(arresteePos)
				local playerCoords = GetEntityCoords(PlayerPedId())
				
				if math.abs(#(playerCoords - vector3(arresteePos.x, arresteePos.y, arresteePos.z))) <= pluginConfig.drawDistance then
					local result = exports[pluginConfig.headshotResourceName]:getBase64(PlayerPedId())
					if result.success then					
						TriggerServerEvent("SonoranCAD::mugshot:FoundMugshot", result.base64)
						debugLog("Saved character headshot: "..tostring(result.success))
					else
						debugLog("Character headshot error: "..tostring(result.error))					
					end				
				end
			end)
			
			mugshotRecieved = nil
			
			RegisterNetEvent("SonoranCAD::mugshot:RecieveMugshot")
			AddEventHandler("SonoranCAD::mugshot:RecieveMugshot", function(Mugshot, RecordId)		
				print(Mugshot, RecordId)
				mugshotRecieved = Mugshot
														
				if mugshotRecieved then
					PtfxStart()
					Citizen.Wait(PtfxWait)
					PtfxStop()
					
					Citizen.Wait(500)
					EmoteCancel()
				else
					
				end
			end)
			
			while pluginConfig.enabled do				
				if isNearMugshotComputer() then					
					Citizen.Wait(5)
					
					if nearMugshot == nil then 
						nearMugshot = isNearMugshotComputer() 
					end
					
					if IsInAnimation then
						Draw3DText(nearMugshot.computerPos.x, nearMugshot.computerPos.y, nearMugshot.computerPos.z, pluginConfig.computerInstruction2)
					else
						Draw3DText(nearMugshot.computerPos.x, nearMugshot.computerPos.y, nearMugshot.computerPos.z, pluginConfig.computerInstruction)
					end
					
					if IsControlJustPressed(0, Keys[pluginConfig.mugshotCameraKeybind]) then
						if not IsInAnimation then
							OnEmotePlay(pluginConfig.cameraAnimation)
						else
							EmoteCancel()
						end
					end
				elseif IsInAnimation then
					Citizen.Wait(5)					
					
					if isNearMugshotPhoto() then
						if isFacingArrestee() then
							Draw3DText(nearMugshot.photoPos.x, nearMugshot.photoPos.y, nearMugshot.photoPos.z, pluginConfig.photoInstruction3)
						else
							Draw3DText(nearMugshot.photoPos.x, nearMugshot.photoPos.y, nearMugshot.photoPos.z, pluginConfig.photoInstruction2)
						end
					else
						Draw3DText(nearMugshot.photoPos.x, nearMugshot.photoPos.y, nearMugshot.photoPos.z, pluginConfig.photoInstruction)
					end
					
					if IsControlJustPressed(0, Keys[pluginConfig.mugshotCameraKeybind]) then
						if isFacingArrestee() then
							TriggerServerEvent("SonoranCAD::mugshot:GetMugshot", nearMugshot.arresteePos)							
						end
					end
				else
					Citizen.Wait(500)
				end				
			end
			
        end
    end) 
end)