--[[
	@brief scripts/model/skill/skill_ge_dang.lua
]]
local Log = require 'log'

local Card   = import '..card.card'
local Damage = import '..damage'
local Skill  = import '.skill'

Skill_ge_dang = class('Skill_ge_dang', Skill)

function Skill_ge_dang:ctor(properties)
	Skill_ge_dang.super.ctor(self, properties)
	
	self.name_ = '格挡'
end

function Skill_ge_dang:destroy()
	if self.card_ then
		self.card_:removeEventListener(Card.BEFORE_DAM_EVENT, self.onBeforePhysicalDamage, self)
	end
end

function Skill_ge_dang:onBeforePhysicalDamage(evt)
	local card = evt.card
	local dam = evt.damage

	if dam:type() == Damage.eType.Physical then
		self:triggerBegin()

		self.card_:encounterSkill(self)
		
		local value = dam:value() - 20 * self:lv()
		if value < 0 then
			value = 0
		end

		Log.write(string.format('[skill][%s%i] %i --> %i', 
			self:name(), self:lv(), dam:value(), value))

		dam:setValue(value)
		
		self:triggerEnd()
	end
end

function Skill_ge_dang:setCard(card)
	self.card_ = card

	if self.card_ then
		self.card_:addEventListener(Card.BEFORE_DAM_EVENT, self.onBeforePhysicalDamage, self)
	end
end

return Skill_ge_dang