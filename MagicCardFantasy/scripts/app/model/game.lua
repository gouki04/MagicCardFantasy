--[[
	@brief scripts/model/game.lua
]]
require 'config'

local Round = import '.round'
local Hero  = import '.hero.hero'
local Card  = import '.card.card'
local Log   = require 'log'

local Game = class('Game', cc.mvc.ModelBase)

-- 定义事件
Game.HERO_DIED_EVENT     = "HERO_DIED_EVENT"
Game.EMPTY_CARD_EVENT    = "EMPTY_CARD_EVENT"
Game.END_EVENT           = "END_EVENT"
Game.ROUND_END_EVENT     = "ROUND_END_EVENT"

function Game:ctor(properties)
	Game.super.ctor(self, properties)

	self.heroDied_ = nil
	self.round_    = nil
	self.hero1_    = nil
	self.hero2_    = nil
	self.attack_   = nil
	self.defend_   = nil
	self.maxRount_ = 30
	self.end_      = false
	self.winHero_  = nil
	self.loseHero_ = nil
end

function Game:notifyHeroDied(evt)
	Log.write('[game] hero['..evt.hero:name()..'] fail...')
	self.heroDied_ = evt.hero
end

function Game:start(hero1, hero2)
	Log.init()
	Log.write('[game] start')

	math.randomseed(os.time())

	self.end_      = false
	self.round_    = Round.new()
	self.heroDied_ = nil
	self.winHero_  = nil
	self.loseHero_ = nil
	self.hero1_    = hero1
	self.hero2_    = hero2
	self.attack_   = hero1
	self.defend_   = hero2

	self.hero1_:addEventListener(Hero.DIED_EVENT, self.notifyHeroDied, self)
	self.hero2_:addEventListener(Hero.DIED_EVENT, self.notifyHeroDied, self)
end

function Game:swapSide()
	local tmp = self.attack_
	self.attack_ = self.defend_
	self.defend_ = tmp
end

function Game:endGame()
	self.end_ = true

	Log.write('[game] end')
	Log.destroy()

	self:dispatchEvent({name = Game.END_EVENT, game = self, win = self.winHero_, lose = self.loseHero_})
end

function Game:nextRound(userCmds)
	if self.end_ then return end

	-- 开始回合
	self.round_:start(self.attack_, self.defend_)
	Log.write('\n[game] round '..self.round_:count()..' start')

	-- 交换攻守
	self:swapSide()

	-- 检查是否超过最大回合数
	-- 如果超出了最大回合数，则判定先手方失败
	if self.round_:count() >= self.maxRount_ then
		self.winHero_ = self.hero2_
		self.loseHero_ = self.hero1_

		self:dispatchEvent({name = Game.ROUND_END_EVENT, game = self})
		self:endGame()
		return
	-- 检查是否有英雄死亡
	elseif self.heroDied_ then
		if self.heroDied_ == self.attack_ then
			self.winHero_ = self.defend_
			self.loseHero_ = self.attack_
		else
			self.winHero_ = self.attack_
			self.loseHero_ = self.defend_
		end

		self:dispatchEvent({name = Game.HERO_DIED_EVENT, game = self})
		self:endGame()
		return
	-- 检查攻方是否已经没有卡牌了
	-- 这里有种情况，如果上一轮的攻方的攻击导致了双方的卡牌都全死光了，那会优先判定为下一轮的攻方失败
	elseif (#self.attack_:deck() <= 0 and 
            #self.attack_:hand() <= 0 and 
            table.empty(self.attack_:field())) then
		self.winHero_ = self.defend_
		self.loseHero_ = self.attack_

		self:dispatchEvent({name = Game.EMPTY_CARD_EVENT, game = self})
		self:endGame()
		return
	end
end

function Game:autoBattle()
	while not self.end_ do
		self:nextRound()
	end
end

return Game