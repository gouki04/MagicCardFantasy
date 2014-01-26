--[[
	@brief skill/skill_lie_yan_feng_bao.lua
]]
require 'skill/skill'

Skill_lie_yan_feng_bao = class(Skill)

function Skill_lie_yan_feng_bao:ctor()
	self.m_name = '烈焰风暴'
end

function Skill_lie_yan_feng_bao:enter(defend, dcard)
	local dfield = defend:field()

	local cnt = table.count(dfield)
	if cnt <= 0 then
		return
	end

	for i = 1, 10 do
		local card = dfield[i]
		if card ~= nil then
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
end

return Skill_lie_yan_feng_bao