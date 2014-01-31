--[[
	@brief scripts/model/skill/skill_ge_dang.lua
]]
local Log = require 'log'

local Card   = import '..card.card'
local Damage = import '..damage'
local Skill  = import '.skill'

Skill_ge_dang = class('Skill_ge_dang', Skill)

function Skill_ge_dang:ctor()
	self.name_ = '格挡'
end

function Skill_ge_dang:onBeforePhysicalDamage(evt)
	local card = evt.card
	local dam = evt.damage

	if dam:type() == Damage.eType.Physical then
		local value = dam:value() - 20 * self:lv()
		if value < 0 then
			value = 0
		end

		Log.write(string.format('[skill][%s%i] %i --> %i', 
			self:name(), self:lv(), dam:value(), value))

		dam:setValue(value)
	end
end

function Skill_ge_dang:setCard(card)
	self.card_ = card

	self.card_:addEventListener(Card.BEFORE_DAM_EVENT, self.onBeforePhysicalDamage, self)
end

return Skill_ge_dang