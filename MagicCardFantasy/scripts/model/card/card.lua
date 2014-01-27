--[[
	@brief scripts/model/card/card.lua
]]
require 'utility/class'
require 'scripts/model/card/cardDefine'
require 'utility/delegate'
require 'scripts/model/damage'
require 'scripts/model/skill/skill'
require 'scripts/model/skill/skillFactory'

Card = class()

function Card:ctor()
end

function Card:init(id, lv)
	local info = CardDefine.getCardInfo(id)

	self.m_id = id
	self.m_lv = lv
	self.m_atk = info.atk + info.atkInc * lv
	self.m_additionAtk = 0
	self.m_hp = info.hp + info.hpInc * lv
	self.m_info = info
	self.m_cd = info.cd

	self.eventAddToDeck = delegate:new()
	self.eventAddToHand = delegate:new()
	self.eventAddToField = delegate:new()
	self.eventAddToGrave = delegate:new()

	self.eventBeforeAttack = delegate:new()
	self.eventAfterAttack = delegate:new()
	
	self.eventCostPhysicalDamage = delegate:new()

	self.eventBeforeDamage = delegate:new()
	self.eventAfterDamage = delegate:new()

	self.eventDied = delegate:new()


	self.m_skill = {}

	for i = 1, #info.skills do
		local skillinfo = info.skills[i]
		if self:lv() >= skillinfo.needLv then
			local skill = SkillFactory.createSkillById(skillinfo.id, skillinfo.lv)
			skill:setCard(self)
			
			table.insert(self.m_skill, skill)
		end
	end
end

function Card:hero()
	return self.m_hero
end

function Card:setHero(hero)
	self.m_hero = hero
end

function Card:id()
	return self.m_id
end

function Card:star()
	return self.m_info.star
end

function Card:atk()
	return self.m_atk + self.m_additionAtk
end

function Card:baseAtk()
	return self.m_atk
end

function Card:addBaseAtk(atk)
	self.m_atk = self.m_atk + atk
end

function Card:additionAtk()
	return self.m_additionAtk
end

function Card:addAdditionAtk(atk)
	self.m_additionAtk = self.m_additionAtk + atk
end

function Card:setHp(hp)
	self.m_hp = hp

	if self.m_hp <= 0 then
		self.eventDied(self)
	end
end

function Card:hp()
	return self.m_hp
end

function Card:lv()
	return self.m_lv
end

function Card:cd()
	return self.m_cd
end

function Card:reduceCd()
	if self.m_cd >= 1 then
		self.m_cd = self.m_cd - 1
	end
end

function Card:cost()
	return self.m_info.cost
end

function Card:name()
	return self.m_info.name
end

function Card:race()
	return self.m_info.race
end

function Card:enter(defend, dcard)
	for i = 1, #self.m_skill do
		self.m_skill[i]:enter(defend, dcard)
	end
end

function Card:leave()
	for i = 1, #self.m_skill do
		self.m_skill[i]:leave()
	end
end

function Card:attackCard(card)
	self.eventBeforeAttack(self)
	local dam = Damage:new()
	dam:init(DamageType_Physical, self:atk(), self)
	Game.log(string.format('[card][%s%i] attack [%s%i]', 
		self:name(), self:lv(), card:name(), card:lv()))
	
	dam = card:damage(dam)
	if dam > 0 then
		self.eventCostPhysicalDamage(self, dam)
	end
	self.eventAfterAttack(self)
end

function Card:toDeck()
	self.eventAddToDeck(self)
end

function Card:toHand()
	self.eventAddToHand(self)
end

function Card:toField()
	self.eventAddToField(self)
end

function Card:toGrave()
	self.eventAddToGrave(self)
end

function Card:damage(dam)
	self.eventBeforeDamage(self, dam)

	local new_hp = self:hp() - dam:value()
	local msg = string.format('[card][%s%i] %i-%i=%i', 
		self:name(), self:lv(), self:hp(), dam:value(), new_hp)

	Game.log(msg)

	self:setHp(new_hp)

	self.eventAfterDamage(self, dam)
	return dam:value()
end
