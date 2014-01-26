--[[
	@brief scripts/model/skill/skill_ge_dang.lua
]]
require 'scripts/model/skill/skill'

Skill_ge_dang = class(Skill)

function Skill_ge_dang:ctor()
	self.m_name = '格挡'

	self.m_onBeforePhysicalDamage = function(card, dam)
		if dam:type() == DamageType_Physical then
			local value = dam:value() - 20 * self:lv()
			if value < 0 then
				value = 0
			end

			Game.log(string.format('[skill][%s%i] %i --> %i', 
				self:name(), self:lv(), dam:value(), value))

			dam:setValue(value)
		end
	end
end

function Skill_ge_dang:setCard(card)
	self.m_card = card

	card.eventBeforePhysicalDamage:regist(self.m_onBeforePhysicalDamage)
end

return Skill_ge_dang