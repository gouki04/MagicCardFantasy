--[[
	@brief main.lua
]]
require 'utility/utility'
require 'hero/hero'
require 'game'

local hero1 = Hero:new()
hero1:init(10, 'a')
hero1:addCardToDeck(1, 3)
hero1:addCardToDeck(2, 5)
hero1:addCardToDeck(3, 7)
hero1:addCardToDeck(1, 9)
hero1:addCardToDeck(2, 1)

local hero2 = Hero:new()
hero2:init(8, 'b')
hero2:addCardToDeck(2, 10)
hero2:addCardToDeck(2, 10)
hero2:addCardToDeck(3, 10)
--hero2:addCardToDeck(1, 3)

Game.start(hero1, hero2)
