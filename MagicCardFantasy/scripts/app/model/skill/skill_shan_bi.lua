--[[
	@brief scripts/model/skill/skill_shan_bi.lua
]]
local Log = require 'log'

local Card  = import '..card.card'
local Skill = import '.skill'

Skill_shan_bi = class('Skill_shan_bi', Skill)

function Skill_shan_bi:ctor()
	self.m_name = '闪避'
end

function Skill_shan_bi:onBeforePhysicalDamage(evt)
	local dam = evt.damage
	local card = evt.card

	if dam:type() == DamageType_Physical then
		local rate = 0.2 + self:lv() * 0.05
		if math.random(0, 1) < rate then
			Log.write(string.format('[skill][%s%i] %i --> %i', 
				self.m_name, self:lv(), dam:value(), 0))

			dam:setValue(0)
		end
	end
end

function Skill_shan_bi:setCard(card)
	self.m_card = card

	self.m_card:addEventListener(Card.BEFORE_DAM_EVENT, self.onBeforePhysicalDamage, self)
end

return Skill_shan_bi