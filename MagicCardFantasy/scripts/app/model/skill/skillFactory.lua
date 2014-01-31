--[[
	@brief skill/skillFactory.lua
]]
local m_skillDefine = {}

m_skillDefine[1] = {
	file = 'app.model.skill.Skill_ge_dang'
}

m_skillDefine[2] = {
	file = 'app.model.skill.skill_shan_bi'
}

m_skillDefine[3] = {
	file = 'app.model.skill.skill_bao_ji'
}

m_skillDefine[4] = {
	file = 'app.model.skill.skill_bei_ci'
}

m_skillDefine[5] = {
	file = 'app.model.skill.skill_huo_qiu'
}

m_skillDefine[6] = {
	file = 'app.model.skill.skill_lie_yan_feng_bao'
}

m_skillDefine[7] = {
	file = 'app.model.skill.skill_huo_qiang'
}

local function createSkillById(id, lv)
	local def = m_skillDefine[id]
	local skill_t = require(def.file)
	local skill = skill_t.new()
	skill:init(id, lv)

	return skill
end

local SkillFactory = {
	createSkillById = createSkillById,
}

return SkillFactory