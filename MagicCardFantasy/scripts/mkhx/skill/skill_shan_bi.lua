--[[
	@brief skill/skill_shan_bi.lua
]]
require 'skill/skill'

Skill_shan_bi = class(Skill)

function Skill_shan_bi:ctor()
	self.m_name = '闪避'

	self.m_onBeforePhysicalDamage = function(card, dam)
		if dam:type() == DamageType_Physical then
			local rate = 0.2 + self:lv() * 0.05
			if math.random(0, 1) < rate then
				Game.log(string.format('[skill][%s%i] %i --> %i', 
					self.m_name, self:lv(), dam:value(), 0))

				dam:setValue(0)
			end
		end
	end
end

function Skill_shan_bi:setCard(card)
	self.m_card = card

	card.eventBeforeDamage:regist(self.m_onBeforePhysicalDamage)
end

return Skill_shan_bi