-- Required scripts
local pokemonParts = require("lib.GroupIndex")(models.models.SerperiorTaur)
local itemCheck    = require("lib.ItemCheck")

-- Config setup
config:name("SerperiorTaur")
local shiny = config:load("ColorShiny") or false

-- All shiny parts
local shinyParts = {
	
	
	
}

-- Table setup
local t = {}

function events.TICK()
	
	-- Set colors
	t.hover     = vectors.hexToRGB(shiny and "FFFFFF" or "FFFFFF")
	t.active    = vectors.hexToRGB(shiny and "FFFFFF" or "FFFFFF")
	t.primary   = (shiny and "§r" or "§r").."§l"
	t.secondary = shiny and "§r" or "§r"
	
	-- Shiny textures
	local textureType = shiny and textures["textures.serperior_shiny"] or textures["textures.serperior"]
	for _, part in ipairs(shinyParts) do
		part:primaryTexture("Custom", textureType)
	end
	
	-- Glowing outline
	renderer:outlineColor(vectors.hexToRGB(shiny and "FFFFFF" or "FFFFFF"))
	
	-- Avatar color
	avatar:color(vectors.hexToRGB(shiny and "FFFFFF" or "FFFFFF"))
	
end

-- Shiny toggle
local function setShiny(boolean)
	
	shiny = boolean
	config:save("ColorShiny", shiny)
	if player:isLoaded() and shiny then
		sounds:playSound("block.amethyst_block.chime", player:getPos())
	end
	
end

-- Sync variables
local function syncColor(a)
	
	shiny = a
	
end

-- Pings setup
pings.setColorShiny = setShiny
pings.syncColor     = syncColor

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncColor(shiny)
		end
		
	end
end

-- Activate actions
setShiny(shiny)

t.shinyPage = action_wheel:newAction()
	:item(itemCheck("gunpowder"))
	:toggleItem(itemCheck("glowstone_dust"))
	:onToggle(pings.setColorShiny)
	:toggled(shiny)

-- Update action page info
function events.TICK()
	
	t.shinyPage
		:title(t.primary.."Toggle Shiny Textures\n\n"..t.secondary.."Set the lower body to use shiny textures over the default textures.")
		:hoverColor(t.hover)
		:toggleColor(t.active)
	
end

-- Return table
return t