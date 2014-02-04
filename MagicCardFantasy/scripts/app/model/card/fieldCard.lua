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

    self.buff_ = {}
    self.toRemoveBuff_ = {}
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

function FieldCard:addBuff(buff)
    buff:setCard(self)
    table.insert(self.buff_, buff)

    self:dispatchEvent({name = Card.ADD_BUFF_EVENT, card = self, buff = buff})
end

function FieldCard:removeBuff(buff)
    table.insert(self.toRemoveBuff_, buff)

    self:dispatchEvent({name = Card.REMOVE_BUFF_EVENT, card = self, buff = buff})
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

function FieldCard:checkCanEnter(defend, dcard)
	for _, buff in pairs(self.buff_) do
		if not buff:canEnter() then
			return false
		end
	end

	return true
end

function FieldCard:checkCanAttack()
	for _, buff in pairs(self.buff_) do
		if not buff:canAttack() then
			return false
		end
	end

	return true
end

function FieldCard:beforeEnter(defend, dcard)
	for _, v in pairs(self.toRemoveBuff_) do
		self:removeBuff(v)
	end
	self.toRemoveBuff_ = {}

	if not self:checkCanEnter() then
		return false
	end

	return true
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
	if not self:checkCanEnter() then
		return
	end

	self:dispatchEvent({name = Card.BEFORE_ATTACK_TO_CARD_EVENT, card = self, targetCard = card})

	local dam = Damage.new({
			type = Damage.eType.Physical,
			value = self:atk(),
		})
	
	Log.write(string.format('[card][%s%i] attack [%s%i]', 
		self:name(), self:lv(), card:name(), card:lv()))
	
	dam = card:damage(dam)
	if dam > 0 then
		self:dispatchEvent({name = Card.COST_PHYSICAL_DAM_TO_CARD_EVENT, card = self, targetCard = card, damage = dam})
	end

	self:dispatchEvent({name = Card.AFTER_ATTACK_TO_CARD_EVENT, card = self, targetCard = card})
end

function FieldCard:attackHero(hero)
	if not self:checkCanEnter() then
		return
	end
	
	self:dispatchEvent({name = Card.BEFORE_ATTACK_TO_HERO_EVENT, card = self, targetCard = hero})

	local dam = Damage.new({
			type = Damage.eType.Physical,
			value = self:atk(),
		})
	
	Log.write(string.format('[card][%s%i] attack [%s]', 
		self:name(), self:lv(), hero:name()))
	
	dam = hero:damage(dam)
	if dam > 0 then
		self:dispatchEvent({name = Card.COST_PHYSICAL_DAM_TO_HERO_EVENT, card = self, targetCard = hero, damage = dam})
	end

	self:dispatchEvent({name = Card.AFTER_ATTACK_TO_HERO_EVENT, card = self, targetCard = hero})
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

function FieldCard:encounterSkill(skill, dam, buffs)
	self:dispatchEvent({name = Card.ENCOUNTER_SKILL_EVENT, card = self, skill = skill})

	if dam then
		self:damage(dam)
	end

	if buffs then
		for _, v in pairs(buffs) do
			self:addBuff(v)
		end
	end
end

return FieldCard