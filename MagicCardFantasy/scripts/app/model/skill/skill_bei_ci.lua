--[[
	@brief scripts/model/skill/skill_bei_ci.lua
]]
local Log = require 'log'

local Skill = import '.skill'

Skill_bei_ci = class('Skill_bei_ci', Skill)

function Skill_bei_ci:ctor(properties)
	Skill_bei_ci.super.ctor(self, properties)
	
	self.name_ = '背刺'
	self.first_ = true
end

function Skill_bei_ci:enter(defend, dcard)
	if self.first_ then
		self:triggerBegin()

		self.card_:encounterSkill(self)

		local oldAtk = self.card_:atk()
		self.additionAtk_ = 40 * self.lv_
		self.card_:addAdditionAtk(self.additionAtk_)

		Log.write(string.format('[skill][%s] atk %i --> %i', self.name_, oldAtk, self.card_:atk()))
		
		self.first_ = false
		
		self:triggerEnd()
	end
end

function Skill_bei_ci:leave()
	if self.additionAtk_ ~= nil and self.additionAtk_ > 0 then
		self.card_:addAdditionAtk(-self.additionAtk_)

		self.additionAtk_ = nil
	end
end

return Skill_bei_ci