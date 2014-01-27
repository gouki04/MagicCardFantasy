--[[
	@brief scripts/model/game.lua
]]
require 'log'
require 'config'

local Round = import '.round'
local Hero  = import '.hero.hero'
local Card  = import '.card.card'

local Game = class('Game', cc.mvc.ModelBase)

function Game:ctor(properties)
	Game.super.ctor(self, properties)

	self.end_ = false
	self.round_ = 1
	self.hero1_ = nil
	self.hero2_ = nil
end

function Game:log(...)
	if Config.logMode == 1 then
		print(...)
	else
		Log.write(...)
	end
end

function Game:notifyHeroDied(hero)
	Game.log('[game] hero['..hero:name()..'] fail...')
	self.end_ = true
end

function Game:start(hero1, hero2)
	Game:log('[game] start')

	math.randomseed(os.time())

	self.hero1_ = hero1
	self.hero2_ = hero2

	self.hero1_.eventDied:regist(notifyHeroDied)
	self.hero2_.eventDied:regist(notifyHeroDied)

	-- m_round = 1
	-- local side = 1
	-- while m_round < 30 and not m_end do
	-- 	if side == 1 then
	-- 		attack = hero1
	-- 		defend = hero2
	-- 		side = 0
	-- 	else
	-- 		attack = hero2
	-- 		defend = hero1
	-- 		side = 1
	-- 	end

	-- 	if #attack:deck() <= 0 and #attack:hand() <= 0 and table.empty(attack:field()) then
	-- 		Game.log('[game] hero['..attack:name()..'] fail...')
	-- 		break
	-- 	end

	-- 	Game.log('\n[game] round '..m_round..' start')

	-- 	Round.start(attack, defend)
	-- 	m_round = m_round + 1
	-- end

	self:log('[game] end')
end

return Game