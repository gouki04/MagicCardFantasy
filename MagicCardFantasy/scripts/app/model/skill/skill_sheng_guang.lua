local Log = require 'log'

local Skill = import '.skill'

Skill_sheng_guang = class('Skill_sheng_guang', Skill)

function Skill_sheng_guang:ctor(properties)
	Skill_sheng_guang.super.ctor(self, properties)
	
	self.name_ = '圣光'
end

function Skill_sheng_guang:enter(defend, dcard)
	if dcard == nil then
		return
	end

	if dcard:race() == db.race.hell then
		self:triggerBegin()

		local oldAtk = self.card_:atk()
		if self.lv_ < 10 then
			self.additionAtk_ = self.card_:baseAtk() * (0.15 + 0.15 * self.lv_)
		else
			self.additionAtk_ = self.card_:baseAtk() * 3
		end
		
		self.card_:addAdditionAtk(self.additionAtk_)

		Log.write(string.format('[skill][%s] atk %i --> %i', self.name_, oldAtk, self.card_:atk()))

		self:triggerEnd()
	end
end

function Skill_sheng_guang:leave()
	if self.additionAtk_ ~= nil and self.additionAtk_ > 0 then
		self.card_:addAdditionAtk(-self.additionAtk_)

		self.additionAtk_ = nil
	end
end

return Skill_sheng_guang