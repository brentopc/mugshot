--[[
    Sonoran CAD Plugins

    Plugin Name: characterphoto
    Creator: Brentopc
    Description: Uses the Loaf headshot to base64 resource to take a character's photo of another player to be added to an arrest record
]]

local config = {
    enabled = true,    
    pluginName = "mugshot",
    pluginAuthor = "Brentopc",
	configVersion = "1.0",

    headshotResourceName = "loaf_headshot_base64", -- resource name of the loaf ped headshot to base64 resource https://github.com/loaf-scripts/loaf_headshot_base64
    mugshotCommandName = "mugshot", -- the command that sets your character photo on your current or most recently selected character in cad
	mugshotCameraKeybind = "E",
	recordsWithMugshot = {1},
	mugshotRecordUid = "bookingphoto",
	
	drawDistance = 1, -- draw distance of the instructional 3D text
	computerInstruction = "Press ~b~[E]~w~ to grab a ~y~Camera",
	computerInstruction2 = "Press ~b~[E]~w~ to put back ~y~Camera",
	photoInstruction = "Stand ~b~here~w~ take a ~y~Photo",
	photoInstruction2 = "Face the ~b~arrestee~w~ to take a ~y~Photo",
	photoInstruction3 = "Press ~b~[E]~w~ to take a ~y~Photo",
	
	mugshotLocations = {
		{computerPos = vector3(479.26, -990.47, 24.27), photoPos = vector4(480.97, -989.45, 24.27, 0.00), arresteePos = vector4(480.97, -985.65, 24.27, 180.00)}, -- mission row
		{computerPos = vector3(1857.78, 3687.39, 30.27), photoPos = vector4(1858.28, 3688.73, 30.27, 28.00), arresteePos = vector4(1857.18, 3690.51, 30.29, 210.00)}, -- sandy shores
	},
	
	-- camera animation and flased used from dpemotes
	cameraAnimation = {"amb@world_human_paparazzi@male@base", "base", "Camera", AnimationOptions =
	{
		Prop = 'prop_pap_camera_01',
		PropBone = 28422,
		PropPlacement = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
		EmoteLoop = true,
		EmoteMoving = true,
		PtfxAsset = "scr_bike_business",
		PtfxName = "scr_bike_cfid_camera_flash",
		PtfxPlacement = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0},
		PtfxInfo = "Press ~b~[E]~w~ to use camera flash.",
		PtfxWait = 200,
	}},
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end