-- Required scripts
require("lib.GSAnimBlend")
local parts      = require("lib.GroupIndex")(models)
--[[
local waterTicks = require("scripts.WaterTicks")
--]]
local pose       = require("scripts.Posing")
local ground     = require("lib.GroundCheck")

-- Animations setup
local anims = animations["models.SerperiorTaur"]

-- Parrot pivots
local parrots = {
	
	--[[
	parts.LeftParrotPivot,
	parts.RightParrotPivot
	--]]
	
}

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

function events.TICK()
	
	-- Player variables
	local vel      = player:getVelocity()
	local onGround = ground()
	
	-- Animation variables
	
	
	-- Animation states
	
	
	-- Animations
	anims.groundIdle:playing(true)
	anims.groundWalk:playing(false)
	anims.sleep:playing(false)
	
end

function events.RENDER(delta, context)
	
	-- Player variables
	local vel = player:getVelocity()
	local dir = player:getLookDir()
	
	-- Directional velocity
	local fbVel = player:getVelocity():dot((dir.x_z):normalize())
	local lrVel = player:getVelocity():cross(dir.x_z:normalize()).y
	local udVel = player:getVelocity().y
	
	-- Animation speeds
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.groundIdle, ticks = 7 },
	{ anim = anims.groundWalk, ticks = 7 }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(blend.ticks):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.UpperBody.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end