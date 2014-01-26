--[[
	@brief game.lua
]]
require 'round'
require 'hero/hero'
require 'card/card'
require 'log'
require 'config'

local m_hero1 = nil
local m_hero2 = nil
local m_round = 1
local m_end = false

local function log(...)
	if Config.logMode == 1 then
		print(...)
	else
		Log.write(...)
	end
end

local function notifyHeroDied(hero)
	Game.log('[game] hero['..hero:name()..'] fail...')
	m_end = true
end

local function start(hero1, hero2)
	Log.init()
	Game.log('[game] start')

	math.randomseed(os.time())

	m_hero1 = hero1
	m_hero2 = hero2

	m_hero1.eventDied:regist(notifyHeroDied)
	m_hero2.eventDied:regist(notifyHeroDied)

	m_round = 1
	local side = 1
	while m_round < 30 and not m_end do
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
			Game.log('[game] hero['..attack:name()..'] fail...')
			break
		end

		Game.log('\n[game] round '..m_round..' start')

		Round.start(attack, defend)
		m_round = m_round + 1
	end

	Game.log('[game] end')
	Log.destroy()
end

Game = {
	start = start,
	log = log,
}
