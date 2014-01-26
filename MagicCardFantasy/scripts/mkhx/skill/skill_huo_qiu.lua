--[[
	@brief skill/skill_huo_qiu.lua
]]
require 'skill/skill'

Skill_huo_qiu = class(Skill)

function Skill_huo_qiu:ctor()
	self.m_name = '火球'
end

function Skill_huo_qiu:enter(defend, dcard)
	local dfield = defend:field()

	local cnt = table.count(dfield)
	if cnt <= 0 then
		return
	end

	local i = 1
	local selectCard = nil
	for _, card in pairs(dfield) do
		local rate = i / cnt
		if math.random(0, 1) <= rate then
			selectCard = card
			break
		else
			i = i + 1
		end
	end

	if selectCard then
		local dam = Damage:new()
		
		local min = self.m_lv * 25
		local max = self.m_lv * 50
		local value = math.floor(math.random(min, max))

		dam:init(DamageType_Magical, value, self.m_card)
		Game.log(string.format('[skill][%s%i] fire damage %i --> [card][%s%i]', 
			self:name(), self:lv(), value, selectCard:name(), selectCard:lv()))

		selectCard:damage(dam)
	end
end

return Skill_huo_qiu