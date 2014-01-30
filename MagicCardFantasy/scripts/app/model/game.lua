--[[
	@brief scripts/model/game.lua
]]
require 'config'

local Round = import '.round'
local Hero  = import '.hero.hero'
local Card  = import '.card.card'
local Log   = require 'log'

local Game = class('Game', cc.mvc.ModelBase)

function Game:ctor(properties)
	Game.super.ctor(self, properties)

	self.end_ = false
	self.round_ = 1
	self.hero1_ = nil
	self.hero2_ = nil
end

function Game:notifyHeroDied(hero)
	Log.write('[game] hero['..hero:name()..'] fail...')
	self.end_ = true
end

function Game:start(hero1, hero2)
	Log.write('[game] start')

	math.randomseed(os.time())

	self.hero1_ = hero1
	self.hero2_ = hero2

	self.hero1_.eventDied:regist(notifyHeroDied)
	self.hero2_.eventDied:regist(notifyHeroDied)

	self.round_ = 1
	local side = 1
	while self.round_ < 30 and not self.end_ do
		if side == 1 then
			attack = hero1
			defend = hero2
			side = 0
		else
			attack = hero2
			defend = hero1
			side = 1
		end

		if #attack:deck() <= 0 and #attack:hand() <= 0 and table.empty(attack:field()) then
			Log.write('[game] hero['..attack:name()..'] fail...')
			break
		end

		Log.write('\n[game] round '..self.round_..' start')

		Round.start(attack, defend)
		self.round_ = self.round_ + 1
	end

	Log.write('[game] end')
end

return Game