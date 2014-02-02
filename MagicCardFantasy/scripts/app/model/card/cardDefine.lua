--[[
	@brief scripts/model/card/cardDefine.lua
]]

local CARD_RACE_KINGDOM = 1
local CARD_RACE_FOREST  = 2
local CARD_RACE_WILD    = 3
local CARD_RACE_HELL    = 4

local m_cards = {}

m_cards[56] = {
	star   = 4,
	atk    = 210,
	atkInc = 24,
	hp     = 790,
	hpInc  = 37,
	cd     = 6,
	cost   = 11,
	name   = '魔法协会长',
	race   = CARD_RACE_KINGDOM,
	skills = {
		{
			id = 7,
			lv = 5,
			needLv = 5,
		}
	},
}

m_cards[106] = {
	star   = 3,
	atk    = 165,
	atkInc = 29,
	hp     = 590,
	hpInc  = 8,
	cd     = 2,
	cost   = 9,
	name   = '堕落精灵',
	race   = CARD_RACE_HELL,
	skills = {
		{
			id = 2,
			lv = 3,
			needLv = 0,
		},
		{
			id = 4,
			lv = 3,
			needLv = 5,
		},
		{
			id = 3,
			lv = 7,
			needLv = 10,
		}
	},
}

m_cards[26] = {
	star   = 4,
	atk    = 220,
	atkInc = 19,
	hp     = 810,
	hpInc  = 55,
	cd     = 4,
	cost   = 11,
	name   = '火灵操控者',
	race   = CARD_RACE_FOREST,
	skills = {
		{
			id = 5,
			lv = 4,
			needLv = 0,
		},
		{
			id = 6,
			lv = 7,
			needLv = 10,
		}
	},
}

local function getCardInfo(id)
	return m_cards[id]
end

local CardDefine = {
	getCardInfo = getCardInfo,
}

return CardDefine