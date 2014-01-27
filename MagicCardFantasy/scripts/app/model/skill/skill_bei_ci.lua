--[[
	@brief scripts/model/skill/skill_bei_ci.lua
]]
import '.skill'

Skill_bei_ci = class(Skill)

function Skill_bei_ci:ctor()
	self.m_name = '背刺'
	self.m_first = true
end

function Skill_bei_ci:enter(defend, dcard)
	if self.m_first then
		local oldAtk = self.m_card:atk()
		self.m_additionAtk = 40 * self.m_lv
		self.m_card:addAdditionAtk(self.m_additionAtk)

		Game.log(string.format('[skill][%s] atk %i --> %i', self.m_name, oldAtk, self.m_card:atk()))
		
		self.m_first = false
	end
end

function Skill_bei_ci:leave()
	if self.m_additionAtk ~= nil and self.m_additionAtk > 0 then
		self.m_card:addAdditionAtk(-self.m_additionAtk)

		self.m_additionAtk = nil
	end
end

return Skill_bei_ci