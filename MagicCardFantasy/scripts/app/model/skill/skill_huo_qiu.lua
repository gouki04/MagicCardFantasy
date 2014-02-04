--[[
	@brief scripts/model/skill/skill_huo_qiu.lua
]]
local Log = require 'log'

local Damage = import '..damage'
local Skill  = import '.skill'

Skill_huo_qiu = class('Skill_huo_qiu', Skill)

function Skill_huo_qiu:ctor(properties)
	Skill_huo_qiu.super.ctor(self, properties)
	
	self.name_ = '火球'
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

	self:triggerBegin()
	if selectCard then
		local min = self.lv_ * 25
		local max = self.lv_ * 50
		local value = math.floor(math.random(min, max))

		local dam = Damage.new({
				type = Damage.eType.Magical,
				subType = Damage.eSubType.Fire,
				value = value,
			})

		Log.write(string.format('[skill][%s%i] fire damage %i --> [card][%s%i]', 
			self:name(), self:lv(), value, selectCard:name(), selectCard:lv()))

		selectCard:encounterSkill(self, dam)
	end
	self:triggerEnd()
end

return Skill_huo_qiu