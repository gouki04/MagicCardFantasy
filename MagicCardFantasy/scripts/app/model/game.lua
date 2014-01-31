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
	self.round_ = Round.new()
	self.hero1_ = nil
	self.hero2_ = nil
	self.attack_ = nil
	self.defend_ = nil
end

function Game:notifyHeroDied(evt)
	Log.write('[game] hero['..evt.hero:name()..'] fail...')
	self.end_ = true
end

function Game:start(hero1, hero2)
	Log.init()
	Log.write('[game] start')

	math.randomseed(os.time())

	self.hero1_ = hero1
	self.hero2_ = hero2

	self.hero1_:addEventListener(Hero.DIED_EVENT, self.notifyHeroDied, self)
	self.hero2_:addEventListener(Hero.DIED_EVENT, self.notifyHeroDied, self)

	local side = 1
	while self.round_:count() < 30 and not self.end_ do
		if side == 1 then
			self.attack_ = hero1
			self.defend_ = hero2
			side = 0
		else
			self.attack_ = hero2
			self.defend_ = hero1
			side = 1
		end

		if #self.attack_:deck() <= 0 and #self.attack_:hand() <= 0 and table.empty(self.attack_:field()) then
			Log.write('[game] hero['..self.attack_:name()..'] fail...')
			break
		end

		self.round_:start(self.attack_, self.defend_)

		Log.write('\n[game] round '..self.round_:count()..' start')
	end

	Log.write('[game] end')
	Log.destroy()
end

return Game