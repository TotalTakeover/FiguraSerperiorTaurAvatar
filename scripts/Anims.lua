-- Required scripts
require("lib.GSAnimBlend")
local pokemonParts = require("lib.GroupIndex")(models.models.SerperiorTaur)
local ground       = require("lib.GroundCheck")
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")
local color        = require("scripts.ColorProperties")

-- Animations setup
local anims = animations["models.SerperiorTaur"]

-- Config setup
config:name("SerperiorTaur")
local wrap = config:load("AnimsWrap")
local idle = config:load("AnimsIdle")
if wrap == nil then wrap = true end
if idle == nil then idle = true end

-- Variable setup
local maxRoll = 225

-- Ingame modifying animations
local tailRot = {
	
	{
		seg = pokemonParts.Tail3,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail4,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail5,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail6,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail7,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail8,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	{
		seg = pokemonParts.Tail9,
		pitch = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		roll = {
			current    = 0,
			nextTick   = 0,
			target     = 0,
			currentPos = 0
		},
		timer = 0
	},
	
}

-- Parrot pivots
local parrots = {
	
	--[[
		pokemonParts.LeftParrotPivot,
		pokemonParts.RightParrotPivot
	--]]
	
}

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Set staticRoll to roll on init
local staticRoll = 0
function events.ENTITY_INIT()
	
	staticRoll = player:getBodyYaw()
	
end

function events.TICK()
	
	-- Player variables
	local vel      = player:getVelocity()
	local bodyRoll = player:getBodyYaw()
	local onGround = ground()
	
	-- Static roll
	staticRoll = math.clamp(staticRoll, bodyRoll - maxRoll, bodyRoll + maxRoll)
	staticRoll = math.lerp(staticRoll, bodyRoll, onGround and math.clamp(vel:length(), 0, 1) or 0.25)
	local fullRoll = bodyRoll - staticRoll
	
	-- Animation variables
	local walking = vel.xz:length() ~= 0
	
	-- Animation states
	local groundIdle = not walking and idle and not anims.coil:isPlaying()
	local groundWalk = (walking or not idle) and not (pose.swim or pose.elytra or pose.crawl) and not anims.coil:isPlaying()
	local swim       = pose.swim or pose.elytra or pose.crawl
	local jump       = vel.y > 0 and not swim
	local flatten    = onGround
	local sleep      = pose.sleep
	local breathe    = true
	
	-- Animations
	anims.groundIdle:playing(groundIdle)
	anims.groundWalk:playing(groundWalk)
	anims.swim:playing(swim)
	anims.jump:playing(jump)
	anims.flatten:playing(flatten)
	anims.sleep:playing(sleep)
	--anims.breathe:playing(breathe)
	
	-- Apply rots to tail
	for _, tail in ipairs(tailRot) do
		
		local pitchLerpSpeed = 0.75
		
		-- Pitch rotations
		if not wrap or not (pose.stand or pose.crouch) or effects.cF or vel:length() ~= 0 or anims.coil:isPlaying() then
			
			tail.pitch.target = 0
			pitchLerpSpeed = 0.1
			
		elseif onGround then
			
			local groundPos   = tail.seg:partToWorldMatrix():apply(0, -10, -1)
			local blockPos    = groundPos:copy():floor()
			local groundBlock = world.getBlockState(groundPos)
			local groundBoxes = groundBlock:getCollisionShape()
			
			local airPos   = tail.seg:partToWorldMatrix():apply(0, -10, -4)
			local airBlock = world.getBlockState(airPos)
			
			local inGround = false
			local inAir    = false
			if groundBoxes then
				for i = 1, #groundBoxes do
					local box = groundBoxes[i]
					if inBox(groundPos, blockPos + box[1], blockPos + box[2]) then
						
						inGround = true
						break
						
					end
				end
			end
			
			if not airBlock:hasCollision() or airBlock.id == "minecraft:snow" then
				
				inAir = true
				
			end
			
			if inGround or inAir then
				tail.timer = math.clamp(tail.timer + 1, 0, 25)
				local dir = inGround and -1 or 1
				tail.pitch.target = math.clamp(tail.seg:getRot().x + 0.05 * tail.timer^2 * dir, -90, 90)
			else
				tail.timer = 0
			end
			
		end
		
		-- Roll rotations
		--[[
		if _ ~= 1 then
			tail.roll.target = fullRoll / #tailRot
		end
		--]]
		
		-- Tick lerps
		tail.pitch.current = tail.pitch.nextTick
		tail.roll.current  = tail.roll.nextTick
		tail.pitch.nextTick = math.lerp(tail.pitch.nextTick, tail.pitch.target, pitchLerpSpeed)
		tail.roll.nextTick  = math.lerp(tail.roll.nextTick,  tail.roll.target,  1)
		
	end
	
end

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

function events.RENDER(delta, context)
	
	-- Player variables
	local vel = player:getVelocity()
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Animation speeds
	local moveSpeed = math.clamp(pose.climb and udVel * 4 or (fbVel < -0.05 and math.min(fbVel, math.abs(lrVel)) or math.max(fbVel, math.abs(lrVel))) * 4, -2, 2)
	anims.groundWalk:speed(moveSpeed)
	anims.swim:speed(moveSpeed)
	
	-- Apply rots to tail
	for _, tail in pairs(tailRot) do
		
		-- Render lerp
		tail.pitch.currentPos = math.lerp(tail.pitch.current, tail.pitch.nextTick, delta)
		tail.roll.currentPos  = math.lerp(tail.roll.current,  tail.roll.nextTick,  delta)
		
		-- Apply
		tail.seg:rot(tail.pitch.currentPos, 0, tail.roll.currentPos)
		
	end
	
	-- Sleep rotations
	if pose.sleep then
		
		-- Disable vanilla rotation
		renderer:rootRotationAllowed(false)
		
		-- Find block
		local block = world.getBlockState(player:getPos())
		local sleepRot = dirRot[block.properties["facing"]]
		
		-- Apply
		models:rot(0, sleepRot, 0)
		
	else
		
		-- Enable vanilla rotation
		renderer:rootRotationAllowed(true)
		
		-- Reset
		models:rot(0)
		
	end
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = 7 },
	{ anim = anims.groundWalk, ticks = 7 },
	{ anim = anims.swim,       ticks = 7 },
	{ anim = anims.jump,       ticks = 7 },
	{ anim = anims.coil,       ticks = 7 },
	{ anim = anims.flatten,    ticks = 7 }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(blend.ticks):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	pokemonParts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Wrap toggle
local function setWrap(boolean)
	
	wrap = boolean
	config:save("AnimsWrap", wrap)
	
end

-- Idle toggle
local function setIdle(boolean)
	
	idle = boolean
	config:save("AnimsIdle", idle)
	
end

-- Sync variables
local function syncAnims(a, b)
	
	wrap = a
	idle = b
	
end

-- Pings setup
pings.setAnimsWrap = setWrap
pings.setAnimsIdle = setIdle
pings.syncAnims    = syncAnims

-- Sync on tick
if host:isHost() then
	function events.TICK()
		
		if world.getTime() % 200 == 0 then
			pings.syncAnims(wrap, idle)
		end
		
	end
end

-- Activate actions
setWrap(wrap)
setIdle(idle)

-- Setup table
local t = {}

t.wrapPage = action_wheel:newAction()
	:item(itemCheck("bamboo"))
	:toggleItem(itemCheck("string"))
	:onToggle(pings.setAnimsWrap)
	:toggled(wrap)
	
t.idlePage = action_wheel:newAction()
	:item(itemCheck("music_disc_11"))
	:toggleItem(itemCheck("music_disc_far"))
	:onToggle(pings.setAnimsIdle)
	:toggled(idle)


-- Update action page info
function events.TICK()
	
	t.wrapPage
		:title(color.primary.."Toggle Wrapping\n\n"..color.secondary.."Toggles the ability for your tail to attempt to wrap around surfaces.")
		:hoverColor(color.hover)
	
	t.idlePage
		:title(color.primary.."Toggle Idle animation\n\n"..color.secondary.."Toggles the usage of the animation that plays when you stop moving.\nDisabling this allows you to have more control your tail's positioning.")
		:hoverColor(color.hover)
	
end

-- Returns animation variables/action wheel pages
return t