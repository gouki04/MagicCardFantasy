--[[
	@brief skill/skillFactory.lua
]]
local function createSkillById(id, lv)
	local def = db.skill[id]
	local skill_t = require(def.file)
	local skill = skill_t.new()
	skill:init(id, lv)

	return skill
end

local SkillFactory = {
	createSkillById = createSkillById,
}

return SkillFactory