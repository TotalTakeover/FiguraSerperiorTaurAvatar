-- Required scripts
local pokemonParts = require("lib.GroupIndex")(models.models.SerperiorTaur)
local squapi       = require("lib.SquAPI")
local pose         = require("scripts.Posing")

-- Animation setup
local anims = animations["models.SerperiorTaur"]

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

-- Squishy smooth Head + Neck
squapi.smoothHeadNeck(
	pokemonParts.UpperBody,
	pokemonParts.Neck,
	nil,
	0.4,
	false
)

-- Squishy crounch
squapi.crouch(anims.crouch)

function events.RENDER(delta, context)
	
	-- Set upper pivot to proper pos when crouching
	pokemonParts.UpperBody:offsetPivot(anims.crouch:isPlaying() and vec(0, 0, 5) or 0)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `pokemonParts.body` and when sleeping
	for _, group in ipairs(pokemonParts.UpperBody:getChildren()) do
		if group ~= pokemonParts.Body and not pose.sleep then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
end