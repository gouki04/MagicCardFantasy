--[[
	@brief scripts/model/card/card.lua
]]
local Log = require 'log'

local Card         = import '.card'
local CardDefine   = import '.cardDefine'
local Damage       = import '..damage'
local Skill        = import '..skill.skill'
local SkillFactory = import '..skill.skillFactory'

local FieldCard = class("Card", Card)

function FieldCard:ctor(properties)
	FieldCard.super.ctor(self, properties)

	if self.cardId_ ~= nil and self.lv_ ~= nil then
		self:init(self.cardId_, self.lv_)
	end
end

function FieldCard:init(id, lv)
	self.cardId_ = id
	self.lv_ = lv

	self.atk_ = self.info_.atk + self.info_.atkInc * self.lv_
	self.additionAtk_ = 0
	self.hp_ = self.info_.hp + self.info_.hpInc * self.lv_
	self.cd_ = self.info_.cd

	self:initSkill()
end

function FieldCard:atk()
	return self.atk_ + self.additionAtk_
end

function FieldCard:baseAtk()
	return self.atk_
end

function FieldCard:addBaseAtk(atk)
	self.atk_ = self.atk_ + atk

	self:dispatchEvent({name = Card.ATK_CHANGED_EVENT, card = self, atk = self:atk()})
end

function FieldCard:additionAtk()
	return self.additionAtk_
end

function FieldCard:addAdditionAtk(atk)
	self.additionAtk_ = self.additionAtk_ + atk

	self:dispatchEvent({name = Card.ATK_CHANGED_EVENT, card = self, atk = self:atk()})
end

function FieldCard:setHp(hp)
	self.hp_ = hp

	self:dispatchEvent({name = Card.HP_CHANGED_EVENT, card = self, hp = self.hp_})

	if self.hp_ <= 0 then
		self:dispatchEvent({name = Card.DIED_EVENT, card = self})
	end
end

function FieldCard:hp()
	return self.hp_
end

function FieldCard:enter(defend, dcard)
	self:dispatchEvent({name = Card.ENTER_EVENT, card = self})
	
	for i = 1, #self.skill_ do
		self.skill_[i]:enter(defend, dcard)
	end
end

function FieldCard:leave()
	for i = 1, #self.skill_ do
		self.skill_[i]:leave()
	end

	self:dispatchEvent({name = Card.LEAVE_EVENT, card = self})
end

function FieldCard:attackCard(card)
	self:dispatchEvent({name = Card.BEFORE_ATTACK_TO_CARD_EVENT, card = self, target = card})

	local dam = Damage.new({
			type = Damage.eType.Physical,
			value = self:atk(),
		})
	
	Log.write(string.format('[card][%s%i] attack [%s%i]', 
		self:name(), self:lv(), card:name(), card:lv()))
	
	dam = card:damage(dam)
	if dam > 0 then
		self:dispatchEvent({name = Card.COST_PHYSICAL_DAM_TO_CARD_EVENT, card = self, target = card, damage = dam})
	end

	self:dispatchEvent({name = Card.AFTER_ATTACK_TO_CARD_EVENT, card = self, target = card})
end

function FieldCard:attackHero(hero)
	self:dispatchEvent({name = Card.BEFORE_ATTACK_TO_HERO_EVENT, card = self, target = hero})

	local dam = Damage.new({
			type = Damage.eType.Physical,
			value = self:atk(),
		})
	
	Log.write(string.format('[card][%s%i] attack [%s]', 
		self:name(), self:lv(), hero:name()))
	
	dam = hero:damage(dam)
	if dam > 0 then
		self:dispatchEvent({name = Card.COST_PHYSICAL_DAM_TO_HERO_EVENT, card = self, target = hero, damage = dam})
	end

	self:dispatchEvent({name = Card.AFTER_ATTACK_TO_HERO_EVENT, card = self, target = hero})
end

function FieldCard:damage(dam)
	self:dispatchEvent({name = Card.BEFORE_DAM_EVENT, card = self, damage = dam})

	local new_hp = self:hp() - dam:value()
	
	Log.write(string.format('[card][%s%i] %i-%i=%i', 
		self:name(), self:lv(), self:hp(), dam:value(), new_hp))

	self:setHp(new_hp)

	self:dispatchEvent({name = Card.AFTER_DAM_EVENT, card = self, damage = dam})

	return dam:value()
end

return FieldCard