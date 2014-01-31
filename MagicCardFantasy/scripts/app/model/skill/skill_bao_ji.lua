--[[
	@brief scripts/model/skill/skill_bao_ji.lua
]]
local Log = require 'log'

local Skill = import '.skill'

Skill_bao_ji = class('Skill_bao_ji', Skill)

function Skill_bao_ji:ctor()
	self.name_ = '暴击'
end

function Skill_bao_ji:enter(defend, dcard)
	if dcard == nil then
		return
	end

	local rate = 0.5
	if math.random(0, 1) < rate then
		local oldAtk = self.card_:atk()
		self.additionAtk_ = self.card_:baseAtk() * (0.2 * self.lv_)
		self.card_:addAdditionAtk(self.additionAtk_)

		Log.write(string.format('[skill][%s] atk %i --> %i', self.name_, oldAtk, self.card_:atk()))	
	end
end

function Skill_bao_ji:leave()
	if self.additionAtk_ ~= nil and self.additionAtk_ > 0 then
		self.card_:addAdditionAtk(-self.additionAtk_)

		self.additionAtk_ = nil
	end
end

return Skill_bao_ji