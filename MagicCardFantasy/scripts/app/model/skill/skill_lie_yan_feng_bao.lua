--[[
	@brief scripts/model/skill/skill_lie_yan_feng_bao.lua
]]
local Log = require 'log'

local Damage = import '..damage'
local Skill  = import '.skill'

Skill_lie_yan_feng_bao = class('Skill_lie_yan_feng_bao', Skill)

function Skill_lie_yan_feng_bao:ctor()
	self.name_ = '烈焰风暴'
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
			local dam = Damage.new()
		
			local min = self.lv_ * 25
			local max = self.lv_ * 50
			local value = math.floor(math.random(min, max))

			dam:init(Damage.eType.Magical, value, self.card_)
			Log.write(string.format('[skill][%s%i] fire damage %i --> [card][%s%i]', 
				self:name(), self:lv(), value, card:name(), card:lv()))

			card:damage(dam)
		end
	end
end

return Skill_lie_yan_feng_bao