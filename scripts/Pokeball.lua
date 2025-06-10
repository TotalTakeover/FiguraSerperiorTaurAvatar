-- Required scripts
local pokemonParts  = require("lib.GroupIndex")(models.models.SerperiorTaur)
local pokeballParts = require("lib.GroupIndex")(models.models.Pokeball)
local squapi        = require("lib.SquAPI")
local itemCheck     = require("lib.ItemCheck")
local color         = require("scripts.ColorProperties")

-- Animations setup
local anims = animations["models.Pokeball"]

-- Config setup
config:name("SerperiorTaur")
local toggle = config:load("PokeballToggle") or false

-- Variables setup
local vehicle
local vType
local isRider
local hasRider
local isInBall  = toggle
local wasInBall = toggle
local staticYaw = 0

-- Lerp scale table
local scale = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	staticYaw = -player:getBodyYaw()
	
	local apply = toggle and 0 or 1
	for k, v in pairs(scale) do
		scale[k] = apply
	end
	
end

function events.TICK()
	
	-- Variables
	vehicle  = player:getVehicle() or false
	vType    = vehicle and vehicle:getType() or false
	isRider  = vehicle and vehicle:getControllingPassenger() and vehicle:getControllingPassenger():getName() ~= player:getName()
	hasRider = (vehicle and #vehicle:getPassengers() > 1 and not isRider) or #player:getPassengers() > 0
	
	-- Pokeball check
	isInBall =
		toggle and not hasRider
		or vehicle
		or isRider
	
	-- Compare states
	if isInBall ~= wasInBall then
		-- Pokeball sounds
		if isInBall     then sounds:stopSound() sounds:playSound("cobblemon:poke_ball.recall",   player:getPos(), 0.15) end
		if not isInBall then sounds:stopSound() sounds:playSound("cobblemon:poke_ball.send_out", player:getPos(), 0.15) end
		
		if isInBall then 
			staticYaw = -player:getBodyYaw()
		end
		
		-- Animations
		anims.open:playing(not isInBall)
		anims.close:playing(isInBall)
	end
	
	-- Scaling lerp
	scale.current  = scale.nextTick
	scale.nextTick = math.lerp(scale.nextTick, scale.target, 0.2)
	
	-- Store previous states
	wasInBall = isInBall
	
end

-- Rendering stuff
function events.RENDER(delta, context)
	
	-- Scaling target and lerp
	scale.target     = isInBall and 0 or 1
	scale.currentPos = math.lerp(scale.current, scale.nextTick, delta)
	
	local firstPerson = context == "FIRST_PERSON"
	local menus       = context == "PAPERDOLL" or context == "MINECRAFT_GUI" or context == "FIGURA_GUI"
	
	pokemonParts.SerperiorTaur
		:scale(scale.currentPos)
		:color(not firstPerson and vec(1, scale.currentPos, scale.currentPos) or 1)
	
	pokeballParts.Pokeball
		:rot(menus and 0 or vec(0, player:getBodyYaw(delta) + staticYaw, 0))
		:scale(math.map(scale.currentPos, 0, 1, vType == "minecraft:player" and 0.5 or 1, 0))
		:visible(menus or not renderer:isFirstPerson())
	
	renderer:shadowRadius(math.map(scale.currentPos, 0, 1, 0.2, 0.75))
	
end

-- Pokeball toggler
local function setPokeball(boolean)
	
	if player:isLoaded() and (toggle or player:getVelocity().xz:length() == 0) then
		toggle = boolean
		config:save("PokeballToggle", toggle)
	end
	
end

-- Sync variable
local function syncPokeball(a)
	
	toggle = a
	
end

-- Ping setup
pings.setPokeball  = setPokeball
pings.syncPokeball = syncPokeball

-- Keybind
local toggleBind   = config:load("PokeballToggleKeybind") or "key.keyboard.keypad.1"
local setToggleKey = keybinds:newKeybind("Pokeball Toggle"):onPress(function() pings.setPokeball(not toggle) end):key(toggleBind)

-- Keybind updater
function events.TICK()
	
	local key = setToggleKey:getKey()
	if key ~= toggleBind then
		toggleBind = key
		config:save("PokeballToggleKeybind", key)
	end
	
end

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncPokeball(toggle)
		end
	
	end
end

local lean        = 15
local leanForward = 0
local leanBack    = 0
local leanLeft    = 0
local leanRight   = 0

-- Keybind animations/blockers
local function forwardTilt(bool)
	
	leanForward = bool and lean or 0
	
end

local function backTilt(bool)
	
	leanBack = bool and lean or 0
	
end

local function leftTilt(bool)
	
	leanLeft = bool and lean or 0
	
end

local function rightTilt(bool)
	
	leanRight = bool and lean or 0
	
end

-- Keybind ping setup
pings.pokeballForwardTilt = forwardTilt
pings.pokeballBackTilt    = backTilt
pings.pokeballLeftTilt    = leftTilt
pings.pokeballRightTilt   = rightTilt

local stop
local kbForward = keybinds:newKeybind("Pokeball Tilt Forward") :onPress(function() pings.pokeballForwardTilt(true) return stop end):onRelease(function() pings.pokeballForwardTilt(false) end)
local kbBack    = keybinds:newKeybind("Pokeball Tilt Backward"):onPress(function() pings.pokeballBackTilt(true)    return stop end):onRelease(function() pings.pokeballBackTilt(false)    end)
local kbLeft    = keybinds:newKeybind("Pokeball Tilt Left")    :onPress(function() pings.pokeballLeftTilt(true)    return stop end):onRelease(function() pings.pokeballLeftTilt(false)    end)
local kbRight   = keybinds:newKeybind("Pokeball Tilt Right")   :onPress(function() pings.pokeballRightTilt(true)   return stop end):onRelease(function() pings.pokeballRightTilt(false)   end)
local kbJump    = keybinds:newKeybind("Pokeball Block Jump")   :onPress(function() return stop and player:isInWater() end)
local kbCrouch  = keybinds:newKeybind("Pokeball Block Crouch") :onPress(function() return toggle end)
local kbAttack  = keybinds:newKeybind("Pokeball Block Attack") :onPress(function() return stop end)
local kbUse     = keybinds:newKeybind("Pokeball Block Use")    :onPress(function() return stop end)

-- Keybind maintainer (Prevents changes)
function events.TICK()
	
	stop         = toggle or isRider
	local enable = scale.currentPos < 0.5
	
	kbForward:key(keybinds:getVanillaKey("key.forward")):enabled(enable)
	kbBack   :key(keybinds:getVanillaKey("key.back")   ):enabled(enable)
	kbRight  :key(keybinds:getVanillaKey("key.right")  ):enabled(enable)
	kbLeft   :key(keybinds:getVanillaKey("key.left")   ):enabled(enable)
	kbJump   :key(keybinds:getVanillaKey("key.jump")   ):enabled(enable)
	kbCrouch :key(keybinds:getVanillaKey("key.sneak")  ):enabled(enable)
	kbAttack :key(keybinds:getVanillaKey("key.attack") ):enabled(enable)
	kbUse    :key(keybinds:getVanillaKey("key.use")    ):enabled(enable)
	
end

-- Pokeball physics
squapi.pokeball = squapi.bounceObject:new()

function events.RENDER(delta, context)
	
	pokeballParts.Ball:offsetRot(squapi.pokeball.pos)
	
	local target = vec(leanBack - leanForward, 0, leanLeft - leanRight)
	
	squapi.pokeball:doBounce(target, 0.01, .075)
	
end

-- Activate action
setPokeball(toggle)

-- Table setup
local t = {}

-- Return action wheel page
t.togglePage = action_wheel:newAction()
	:item(itemCheck("cobblemon:nest_ball", "ender_pearl"))
	:onToggle(pings.setPokeball)

-- Update action page info
function events.TICK()
	
	t.togglePage
		:title(toJson(
			{
				"",
				{text = "Toggle Pokeball\n\n", bold = true, color = color.primary},
				{text = "Auto activates/deactivates on vehicles.", color = color.secondary}
			}
		))
		:hoverColor(color.hover)
		:toggleColor(color.active)
		:toggled(toggle)
	
end

-- Return action wheel page (and toggle)
return t