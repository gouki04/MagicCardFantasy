--[[
	@brief scripts/model/hero/hero.lua
]]
local Log = require 'log'

local Card       = import '..card.card'
local HandCard   = import '..card.handCard'
local DeckCard   = import '..card.deckCard'
local FieldCard  = import '..card.fieldCard'
local GraveCard  = import '..card.graveCard'

local Hero = class('Hero', cc.mvc.ModelBase)

-- 定义事件
Hero.DIED_EVENT             = "DIED_EVENT"
Hero.ADD_CARD_TO_DECK       = "ADD_CARD_TO_DECK"
Hero.ADD_CARD_TO_HAND       = "ADD_CARD_TO_HAND"
Hero.ADD_CARD_TO_FIELD      = "ADD_CARD_TO_FIELD"
Hero.ADD_CARD_TO_GRAVE      = "ADD_CARD_TO_GRAVE"
Hero.REMOVE_CARD_FROM_DECK  = "REMOVE_CARD_FROM_DECK"
Hero.REMOVE_CARD_FROM_HAND  = "REMOVE_CARD_FROM_HAND"
Hero.REMOVE_CARD_FROM_FIELD = "REMOVE_CARD_FROM_FIELD"
Hero.REMOVE_CARD_FROM_GRAVE = "REMOVE_CARD_FROM_GRAVE"
Hero.HP_CHANGED_EVENT       = "HP_CHANGED_EVENT"
Hero.BEFORE_DAM_EVENT       = "BEFORE_DAM_EVENT"
Hero.AFTER_DAM_EVENT        = "AFTER_DAM_EVENT"

-- 定义属性
Hero.schema = {}

Hero.schema["id"]   = {"number"}
Hero.schema["name"] = {"string"}
Hero.schema["lv"]   = {"number", 1}

function Hero:ctor(properties)
	Hero.super.ctor(self, properties)

	self.deck_ = {}
	self.hand_ = {}
	self.field_ = {}
	self.grave_ = {}

	self:init()
end

function Hero:init()
	self.hp_ = 1000 + self.lv_ * 70
end

function Hero:destroy()
	for k, v in pairs(self.deck_) do
		v:destroy()
	end

	for k, v in pairs(self.hand_) do
		v:destroy()
	end

	for k, v in pairs(self.field_) do
		v:destroy()
	end

	for k, v in pairs(self.grave_) do
		v:destroy()
	end
end

function Hero:notifyCardDied(evt)
	local card = evt.card

	local field = self:field()
	for i = 1, #field do
		if field[i] == card then
			self:removeCardFromFieldByIdx(i)
			self:addCardToGrave(card)
			break
		end
	end
end

function Hero:removeCardFromDeckByIdx(idx)
	local card = self:deck()[idx]
	card:leaveDeck()
	card:destroy()

	table.remove(self:deck(), idx)

	self:dispatchEvent({name = Hero.REMOVE_CARD_FROM_DECK, hero = self, card = card, idx = idx})
end

function Hero:addCardToDeck(id, cardId, lv)
	local deck_card = DeckCard.new({
			id     = id,
			cardId = cardId,
			lv     = lv,
			hero   = self,
		})

	table.insert(self.deck_, deck_card)

	deck_card:enterDeck(self)

	self:dispatchEvent({name = Hero.ADD_CARD_TO_DECK, hero = self, card = deck_card})

	return deck_card
end

function Hero:removeCardFromHandByIdx(idx)
	local card = self:hand()[idx]
	card:leaveHand()
	card:destroy()

	table.remove(self:hand(), idx)

	self:dispatchEvent({name = Hero.REMOVE_CARD_FROM_HAND, hero = self, card = card, idx = idx})
end

function Hero:addCardToHand(card)
	local hand_card = HandCard.new({
			id     = card:id(),
			cardId = card:cardId(),
			lv     = card:lv(),
			hero   = self,
		})

	table.insert(self.hand_, hand_card)

	hand_card:enterHand(self)

	self:dispatchEvent({name = Hero.ADD_CARD_TO_HAND, hero = self, card = hand_card})

	Log.write(string.format('[hero][%s] put card[%s%i] to hand', 
		self:name(), hand_card:name(), hand_card:lv()))

	return hand_card
end

function Hero:removeCardFromFieldByIdx(idx)
	local card = self:field()[idx]
	card:leaveField()
	card:destroy()

	self:field()[idx] = nil

	self:dispatchEvent({name = Hero.REMOVE_CARD_FROM_FIELD, hero = self, card = card, idx = idx})
end

function Hero:addCardToField(card)
	local field_card = FieldCard.new({
			id     = card:id(),
			cardId = card:cardId(),
			lv     = card:lv(),
			hero   = self,
		})

	table.insert(self.field_, field_card)

	field_card:addEventListener(Card.DIED_EVENT, self.notifyCardDied, self)

	field_card:enterField(self)

	self:dispatchEvent({name = Hero.ADD_CARD_TO_FIELD, hero = self, card = field_card, idx = #self.field_})

	Log.write(string.format('[hero][%s] put card[%s%i] to field', 
		self:name(), field_card:name(), field_card:lv()))

	return field_card
end

function Hero:removeCardFromGrave(card)
	self:removeCardFromGraveById(card:id())
end

function Hero:removeCardFromGraveById(id)
	local card = self:grave()[id]
	card:leaveGrave()
	card:destroy()

	self:grave()[id] = nil

	self:dispatchEvent({name = Hero.REMOVE_CARD_FROM_GRAVE, hero = self, card = card})
end

function Hero:addCardToGrave(card)
	local grave_card = GraveCard.new({
			id     = card:id(),
			cardId = card:cardId(),
			lv     = card:lv(),
			hero   = self,
		})

	self.grave_[grave_card:id()] = grave_card

	grave_card:enterGrave(self)

	self:dispatchEvent({name = Hero.ADD_CARD_TO_GRAVE, hero = self, card = grave_card})

	Log.write(string.format('[hero][%s] put card[%s%i] to grave', 
		self:name(), grave_card:name(), grave_card:lv()))

	return grave_card
end

function Hero:id()
	return self.id_
end

function Hero:name()
	return self.name_
end

function Hero:deck()
	return self.deck_
end

function Hero:hand()
	return self.hand_
end

function Hero:field()
	return self.field_
end

function Hero:grave()
	return self.grave_
end

function Hero:lv()
	return self.lv_
end

function Hero:setHp(hp)
	self.hp_ = hp

	self:dispatchEvent({name = Hero.HP_CHANGED_EVENT, hero = self, hp = self.hp_})

	if self.hp_ <= 0 then
		Log.write('hero['..self.name_..'] died..')
		self:dispatchEvent({name = Hero.DIED_EVENT, hero = self})
	end
end

function Hero:hp()
	return self.hp_
end

function Hero:damage(dam)
	self:dispatchEvent({name = Hero.BEFORE_DAM_EVENT, hero = self, damage = dam})

	local new_hp = self:hp() - dam:value()

	Log.write(string.format('[card][%s%i] %i-%i=%i', 
		self:name(), self:lv(), self:hp(), dam:value(), new_hp))

	self:setHp(new_hp)

	self:dispatchEvent({name = Hero.AFTER_DAM_EVENT, hero = self, damage = dam})

	return dam:value()
end

function Hero:dead()
	return self.hp_ <= 0
end

return Hero