--[[
	@brief scripts/model/card/card.lua
]]
local Log = require 'log'

local CardDefine   = import '.cardDefine'
local Damage       = import '..damage'
local Skill        = import '..skill.skill'
local SkillFactory = import '..skill.skillFactory'

local Card = class("Card", cc.mvc.ModelBase)

-- 定义事件
Card.ADD_TO_DECK_EVENT       = "ADD_TO_DECK_EVENT"
Card.ADD_TO_HAND_EVENT       = "ADD_TO_HAND_EVENT"
Card.ADD_TO_FIELD_EVENT      = "ADD_TO_FIELD_EVENT"
Card.ADD_TO_GRAVE_EVENT      = "ADD_TO_GRAVE_EVENT"
Card.BEFORE_ATTACK_EVENT     = "BEFORE_ATTACK_EVENT"
Card.AFTER_ATTACK_EVENT      = "AFTER_ATTACK_EVENT"
Card.COST_PHYSICAL_DAM_EVENT = "COST_PHYSICAL_DAM_EVENT"
Card.BEFORE_DAM_EVENT        = "BEFORE_DAM_EVENT"
Card.AFTER_DAM_EVENT         = "AFTER_DAM_EVENT"
Card.DIED_EVENT              = "DIED_EVENT"

-- 定义属性
Card.schema = {}

Card.schema["id"] = {"number"}
Card.schema["lv"] = {"number"}

function Card:ctor(properties)
	Card.super.ctor(self, properties)

	if self.id_ ~= nil and self.lv_ ~= nil then
		self:init(self.id_, self.lv_)
	end
end

function Card:init(id, lv)
	self.id_ = id
	self.lv_ = lv

	self.info_ = CardDefine.getCardInfo(self.id_)

	self.atk_ = self.info_.atk + self.info_.atkInc * self.lv_
	self.additionAtk_ = 0
	self.hp_ = self.info_.hp + self.info_.hpInc * self.lv_
	self.cd_ = self.info_.cd

	self.skill_ = {}

	for i = 1, #self.info_.skills do
		local skillinfo = self.info_.skills[i]
		if self.lv_ >= skillinfo.needLv then
			local skill = SkillFactory.createSkillById(skillinfo.id, skillinfo.lv)
			skill:setCard(self)
			
			table.insert(self.skill_, skill)
		end
	end
end

function Card:hero()
	return self.hero_
end

function Card:setHero(hero)
	self.hero_ = hero
end

function Card:id()
	return self.id_
end

function Card:star()
	return self.info_.star
end

function Card:atk()
	return self.atk_ + self.additionAtk_
end

function Card:baseAtk()
	return self.atk_
end

function Card:addBaseAtk(atk)
	self.atk_ = self.atk_ + atk
end

function Card:additionAtk()
	return self.additionAtk_
end

function Card:addAdditionAtk(atk)
	self.additionAtk_ = self.additionAtk_ + atk
end

function Card:setHp(hp)
	self.hp_ = hp

	if self.hp_ <= 0 then
		self:dispatchEvent({name = Card.DIED_EVENT, card = self})
	end
end

function Card:hp()
	return self.hp_
end

function Card:lv()
	return self.lv_
end

function Card:cd()
	return self.cd_
end

function Card:reduceCd()
	if self.cd_ >= 1 then
		self.cd_ = self.cd_ - 1
	end
end

function Card:cost()
	return self.info_.cost
end

function Card:name()
	return self.info_.name
end

function Card:race()
	return self.info_.race
end

function Card:enter(defend, dcard)
	for i = 1, #self.skill_ do
		self.skill_[i]:enter(defend, dcard)
	end
end

function Card:leave()
	for i = 1, #self.skill_ do
		self.skill_[i]:leave()
	end
end

function Card:attackCard(card)
	self:dispatchEvent({name = Card.BEFORE_ATTACK_EVENT, card = self, target = card})

	local dam = Damage:new()
	dam:init(Damage.eType.Physical, self:atk(), self)
	Log.write(string.format('[card][%s%i] attack [%s%i]', 
		self:name(), self:lv(), card:name(), card:lv()))
	
	dam = card:damage(dam)
	if dam > 0 then
		self:dispatchEvent({name = Card.COST_PHYSICAL_DAM_EVENT, card = self, target = card, damage = dam})
	end

	self:dispatchEvent({name = Card.AFTER_ATTACK_EVENT, card = self, target = card})
end

function Card:toDeck()
	self:dispatchEvent({name = Card.ADD_TO_DECK_EVENT, card = self})
end

function Card:toHand()
	self:dispatchEvent({name = Card.ADD_TO_HAND_EVENT, card = self})
end

function Card:toField()
	self:dispatchEvent({name = Card.ADD_TO_FIELD_EVENT, card = self})
end

function Card:toGrave()
	self:dispatchEvent({name = Card.ADD_TO_GRAVE_EVENT, card = self})
end

function Card:damage(dam)
	self:dispatchEvent({name = Card.BEFORE_DAM_EVENT, card = self, damage = dam})

	local new_hp = self:hp() - dam:value()
	local msg = string.format('[card][%s%i] %i-%i=%i', 
		self:name(), self:lv(), self:hp(), dam:value(), new_hp)

	Log.write(msg)

	self:setHp(new_hp)

	self:dispatchEvent({name = Card.AFTER_DAM_EVENT, card = self, damage = dam})

	return dam:value()
end

return Card