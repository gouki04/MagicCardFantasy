--[[
	@brief scripts/model/hero/hero.lua
]]

require 'utility.delegate'
local Game = import '..model.game'

local Hero = class('Hero', cc.mvc.ModelBase)

-- 定义事件
Hero.DIED_EVENT = "DIED_EVENT"

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

function Hero:notifyCardDied(card)
	local field = self:field()
	for i = 1, #field do
		if field[i] == card then
			self:addCardToGrave(field[i])
			field[i] = nil
		end
	end
end

function Hero:addCardToDeck(id, lv)
	local card = {id = id, lv = lv}
	table.insert(self.deck_, card)
end

function Hero:addCardToHand(deck_card)
	local hand_card = Card:new()
	hand_card:init(deck_card.id, deck_card.lv)
	table.insert(self.hand_, hand_card)

	Game:log(string.format('[hero][%s] put card[%s%i] to hand', 
		self:name(), hand_card:name(), hand_card:lv()))
end

function Hero:addCardToField(hand_card)
	table.insert(self.field_, hand_card)

	hand_card:addEventListener(Card.DIED_EVENT, self.notifyCardDied, self)

	Game:log(string.format('[hero][%s] put card[%s%i] to field', 
		self:name(), hand_card:name(), hand_card:lv()))
end

function Hero:addCardToGrave(field_card)
	table.insert(self.grave_, {id = field_card:id(), lv = field_card:lv()})

	Game:log(string.format('[hero][%s] put card[%s%i] to grave', 
		self:name(), field_card:name(), field_card:lv()))
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
		Game:log('hero['..self.name_..'] died..')
		self:dispatchEvent({name = Hero.DIED_EVENT, hero = self})
	end
end

function Hero:hp()
	return self.hp_
end

function Hero:damage(dam)
	Game:log('[hero]['..self.name_..'] '..self.hp_..' - '..dam.. ' = '..self.hp_ - dam)
	self:setHp(self.hp_ - dam)
	return dam
end

function Hero:dead()
	return self.hp_ <= 0
end

return Hero