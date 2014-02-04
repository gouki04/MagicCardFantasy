local Log = require 'log'

local Card   = import '..card.card'
local Skill  = import '.skill'

Skill_sheng_guang = class('Skill_sheng_guang', Skill)

function Skill_sheng_guang:ctor(properties)
	Skill_sheng_guang.super.ctor(self, properties)
	
	self.name_ = '圣光'
end

function Skill_sheng_guang:onBeforeAttackToCard(evt)
	if evt.targetCard:race() == db.race.hell then
		self:triggerBegin()

		self.card_:encounterSkill(self)
		
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

function Skill_sheng_guang:onAfterAttackToCard(evt)
	if self.additionAtk_ ~= nil and self.additionAtk_ > 0 then
		self.card_:addAdditionAtk(-self.additionAtk_)

		self.additionAtk_ = nil
	end
end

function Skill_sheng_guang:enterField()
	if self.card_ then
		self.card_:addEventListener(Card.BEFORE_ATTACK_TO_CARD_EVENT, self.onBeforeAttackToCard, self)
		self.card_:addEventListener(Card.AFTER_ATTACK_TO_CARD_EVENT, self.onAfterAttackToCard, self)
	end
end

function Skill_sheng_guang:leaveField()
	if self.card_ then
		self.card_:removeEventListener(Card.BEFORE_ATTACK_TO_CARD_EVENT, self.onBeforeAttackToCard, self)
		self.card_:removeEventListener(Card.AFTER_ATTACK_TO_CARD_EVENT, self.onAfterAttackToCard, self)
	end
end

return Skill_sheng_guang