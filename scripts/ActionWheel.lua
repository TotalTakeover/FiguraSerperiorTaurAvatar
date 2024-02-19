-- Required scripts
local avatar   = require("scripts.Player")
local camera   = require("scripts.CameraControl")
local anims    = require("scripts.Anims")

-- Page setups
local mainPage      = action_wheel:newPage("MainPage")
local avatarPage    = action_wheel:newPage("AvatarPage")
local cameraPage    = action_wheel:newPage("CameraPage")
local animsPage     = action_wheel:newPage("AnimationPage")

-- Logs pages for navigation
local navigation = {}

-- Go forward a page
local function descend(page)
	
	navigation[#navigation + 1] = action_wheel:getCurrentPage() 
	action_wheel:setPage(page)
	
end

-- Go back a page
local function ascend()
	
	action_wheel:setPage(table.remove(navigation, #navigation))
	
end

-- Action back to previous page
local backPage = action_wheel:newAction()
	:title("§c§lGo Back?")
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item("minecraft:barrier")
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(mainPage)

-- Main actions
mainPage
	:action( -1,
		action_wheel:newAction()
			:title("§2§lAvatar Settings")
			:hoverColor(vectors.hexToRGB("21A64C"))
			:item("minecraft:armor_stand")
			:onLeftClick(function() descend(avatarPage) end))
	
	:action( -1,
		action_wheel:newAction()
			:title("§2§lAnimations")
			:hoverColor(vectors.hexToRGB("21A64C"))
			:item("minecraft:jukebox")
			:onLeftClick(function() descend(animsPage) end))

-- Avatar actions
avatarPage
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1,
		action_wheel:newAction()
			:title("§2§lCamera Settings")
			:hoverColor(vectors.hexToRGB("21A64C"))
			:item("minecraft:redstone")
			:onLeftClick(function() descend(cameraPage) end))
	:action( -1, backPage)

-- Camera actions
cameraPage
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backPage)

-- Animation actions
animsPage
	:action( -1, backPage)