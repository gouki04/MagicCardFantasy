--[[
	@brief scripts/model/hero/hero.lua
]]

require 'utility/delegate'
require 'utility/class'

Hero = class()

function Hero:ctor()
	self.m_deck = {}
	self.m_hand = {}
	self.m_field = {}
	self.m_grave = {}
end

function Hero:init(lv, name)
	self.m_name = name
	self.m_lv = lv
	self.m_hp = 1000 + lv * 70

	self.m_notifyCardDied = function(card)
		local field = self:field()
		for i = 1, #field do
			if field[i] == card then
				self:addCardToGrave(field[i])
				field[i] = nil
			end
		end
	end

	self.eventDied = delegate:new()
end

function Hero:addCardToDeck(id, lv)
	local card = {id = id, lv = lv}
	table.insert(self.m_deck, card)
end

function Hero:addCardToHand(deck_card)
	local hand_card = Card:new()
	hand_card:init(deck_card.id, deck_card.lv)
	table.insert(self.m_hand, hand_card)

	Game.log(string.format('[hero][%s] put card[%s%i] to hand', 
		self:name(), hand_card:name(), hand_card:lv()))
end

function Hero:addCardToField(hand_card)
	table.insert(self.m_field, hand_card)

	hand_card.eventDied:regist(self.m_notifyCardDied)

	Game.log(string.format('[hero][%s] put card[%s%i] to field', 
		self:name(), hand_card:name(), hand_card:lv()))
end

function Hero:addCardToGrave(field_card)
	table.insert(self.m_grave, {id = field_card:id(), lv = field_card:lv()})

	Game.log(string.format('[hero][%s] put card[%s%i] to grave', 
		self:name(), field_card:name(), field_card:lv()))
end

function Hero:name()
	return self.m_name
end

function Hero:deck()
	return self.m_deck
end

function Hero:hand()
	return self.m_hand
end

function Hero:field()
	return self.m_field
end

function Hero:grave()
	return self.m_grave
end

function Hero:lv()
	return self.m_lv
end

function Hero:setHp(hp)
	self.m_hp = hp

	if self.m_hp <= 0 then
		Game.log('hero['..self.m_name..'] died..')
		self.eventDied(self)
	end
end

function Hero:hp()
	return self.m_hp
end

function Hero:damage(dam)
	Game.log('[hero]['..self.m_name..'] '..self.m_hp..' - '..dam.. ' = '..self.m_hp - dam)
	self:setHp(self.m_hp - dam)
	return dam
end

function Hero:dead()
	return self.m_hp <= 0
end
