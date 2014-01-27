--[[
	@brief scripts/model/skill/skill_huo_qiang.lua
]]
import '.skill'

Skill_huo_qiang = class(Skill)

function Skill_huo_qiang:ctor()
	self.m_name = '火墙'
end

function Skill_huo_qiang:enter(defend, dcard)
	local dfield = defend:field()

	local cnt = table.count(dfield)
	if cnt <= 0 then
		return
	end

	local i = 3
	local selectCards = {}
	for _, card in pairs(dfield) do
		local rate = i / cnt
		if math.random(0, 1) <= rate then
			table.insert(selectCards, card)
			i = i - 1

			if i <= 0 then
				break
			end
		end

		cnt = cnt - 1
		if cnt <= 0 then
			break
		end
	end

	for i = 1, #selectCards do
		local card = selectCards[i]
		local dam = Damage:new()
		
		local min = self.m_lv * 25
		local max = self.m_lv * 50
		local value = math.floor(math.random(min, max))

		dam:init(DamageType_Magical, value, self.m_card)
		Game.log(string.format('[skill][%s%i] fire damage %i --> [card][%s%i]', 
			self:name(), self:lv(), value, card:name(), card:lv()))

		card:damage(dam)
	end
end

return Skill_huo_qiang