--[[
	@brief scripts/model/skill/skill_huo_qiang.lua
]]
local Log = require 'log'

local Damage = import '..damage'
local Skill  = import '.skill'

Skill_huo_qiang = class('Skill_huo_qiang', Skill)

function Skill_huo_qiang:ctor(properties)
	Skill_huo_qiang.super.ctor(self, properties)
	
	self.name_ = '火墙'
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

	self:triggerBegin()
	for i = 1, #selectCards do
		local card = selectCards[i]
		
		local min = self.lv_ * 25
		local max = self.lv_ * 50
		local value = math.floor(math.random(min, max))

		local dam = Damage.new({
				type = Damage.eType.Magical,
				subType = Damage.eSubType.Fire,
				value = value,
			})

		Log.write(string.format('[skill][%s%i] fire damage %i --> [card][%s%i]', 
			self:name(), self:lv(), value, card:name(), card:lv()))

		card:encounterSkill(self, dam)
	end
	self:triggerEnd()
end

return Skill_huo_qiang