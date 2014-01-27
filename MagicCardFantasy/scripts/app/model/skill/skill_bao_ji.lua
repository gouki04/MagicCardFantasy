--[[
	@brief scripts/model/skill/skill_bao_ji.lua
]]
import '.skill'

Skill_bao_ji = class(Skill)

function Skill_bao_ji:ctor()
	self.m_name = '暴击'
end

function Skill_bao_ji:enter(defend, dcard)
	if dcard == nil then
		return
	end

	local rate = 0.5
	if math.random(0, 1) < rate then
		local oldAtk = self.m_card:atk()
		self.m_additionAtk = self.m_card:baseAtk() * (0.2 * self.m_lv)
		self.m_card:addAdditionAtk(self.m_additionAtk)

		Game.log(string.format('[skill][%s] atk %i --> %i', self.m_name, oldAtk, self.m_card:atk()))	
	end
end

function Skill_bao_ji:leave()
	if self.m_additionAtk ~= nil and self.m_additionAtk > 0 then
		self.m_card:addAdditionAtk(-self.m_additionAtk)

		self.m_additionAtk = nil
	end
end

return Skill_bao_ji