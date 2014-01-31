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
Hero.DIED_EVENT        = "DIED_EVENT"
Hero.ADD_CARD_TO_DECK  = "ADD_CARD_TO_DECK"
Hero.ADD_CARD_TO_HAND  = "ADD_CARD_TO_HAND"
Hero.ADD_CARD_TO_FIELD = "ADD_CARD_TO_FIELD"
Hero.ADD_CARD_TO_GRAVE = "ADD_CARD_TO_GRAVE"

-- 定义属性
Hero.schema = {}

Hero.schema["name"] = {"string"}
Hero.schema["lv"]   = {"number", 1}

function Hero:ctor(properties)
	Hero.super.ctor(self, properties)

	self.deck_ = {}
	self.hand_ = {}
	self.field_ = {}
	self.grave_ = {}

	if self.lv_ ~= nil and self.name_ ~= nil then
		self:init(self.lv_, self.name_)
	end
end

function Hero:init(lv, name)
	self.name_ = name
	self.lv_ = lv
	self.hp_ = 1000 + lv * 70
end

function Hero:notifyCardDied(evt)
	local card = evt.card

	local field = self:field()
	for i = 1, #field do
		if field[i] == card then
			self:addCardToGrave(field[i])
			field[i] = nil
		end
	end
end

function Hero:addCardToDeck(id, lv)
	local card = DeckCard.new({id = id, lv = lv})
	table.insert(self.deck_, card)

	card:toDeck(self)
	self:dispatchEvent({name = Hero.ADD_CARD_TO_DECK, hero = self, card = card})
end

function Hero:addCardToHand(deck_card)
	local hand_card = HandCard.new({
			id = deck_card:id(),
			lv = deck_card:lv(),
		})

	table.insert(self.hand_, hand_card)

	hand_card:toHand(self)
	self:dispatchEvent({name = Hero.ADD_CARD_TO_HAND, hero = self, card = hand_card})

	Log.write(string.format('[hero][%s] put card[%s%i] to hand', 
		self:name(), hand_card:name(), hand_card:lv()))
end

function Hero:addCardToField(hand_card)
	local field_card = FieldCard.new({
			id = hand_card:id(),
			lv = hand_card:lv(),
		})

	table.insert(self.field_, field_card)

	field_card:addEventListener(Card.DIED_EVENT, self.notifyCardDied, self)

	field_card:toField(self)
	self:dispatchEvent({name = Hero.ADD_CARD_TO_FIELD, hero = self, card = field_card})

	Log.write(string.format('[hero][%s] put card[%s%i] to field', 
		self:name(), field_card:name(), field_card:lv()))
end

function Hero:addCardToGrave(field_card)
	local grave_card = GraveCard.new({
			id = field_card:id(),
			lv = field_card:lv(),
		})

	table.insert(self.grave_, grave_card)

	grave_card:toGrave(self)
	self:dispatchEvent({name = Hero.ADD_CARD_TO_GRAVE, hero = self, card = grave_card})

	Log.write(string.format('[hero][%s] put card[%s%i] to grave', 
		self:name(), grave_card:name(), grave_card:lv()))
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

	if self.hp_ <= 0 then
		Log.write('hero['..self.name_..'] died..')
		self:dispatchEvent({name = Hero.DIED_EVENT, hero = self})
	end
end

function Hero:hp()
	return self.hp_
end

function Hero:damage(dam)
	Log.write('[hero]['..self.name_..'] '..self.hp_..' - '..dam.. ' = '..self.hp_ - dam)
	self:setHp(self.hp_ - dam)
	return dam
end

function Hero:dead()
	return self.hp_ <= 0
end

return Hero