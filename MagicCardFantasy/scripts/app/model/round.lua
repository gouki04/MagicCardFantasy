--[[
	@brief scripts/model/round.lua
]]
local Log = require 'log'

local Round = class('Round', cc.mvc.ModelBase)

function Round:ctor()
	self.roundCnt_ = 0
end

function Round:count()
	return self.roundCnt_
end

function Round:handCardBattle(acard, dcard)
	acard:attackCard(dcard)
end

function Round:start(attack, defend)
	self.roundCnt_ = self.roundCnt_ + 1

	Log.write('[round] hero['..attack:name()..']')

	-- 移牌
	local field = attack:field()
	local field_cnt = table.count(field)
	if field_cnt > 0 then
		local idx = 1
		for i = 1, 10 do
			if field[i] ~= nil then
				if idx ~= i then
					field[idx] = field[i]
					field[i] = nil
				end
				
				idx = idx + 1
				if idx > field_cnt then
					break
				end
			end
		end
	end

	field = defend:field()
	field_cnt = table.count(field)
	if field_cnt > 0 then
		local idx = 1
		for i = 1, 10 do
			if field[i] ~= nil then
				if idx ~= i then
					field[idx] = field[i]
					field[i] = nil
				end
				
				idx = idx + 1
				if idx > field_cnt then
					break
				end
			end
		end
	end

	-- 抽牌
	local deck = attack:deck()
	if #deck > 0 then
		local i = math.random(1, #deck)
		while deck[i] == nil do
			i = math.random(1, #deck)
		end

		local card = deck[i]
		attack:removeCardFromDeckByIdx(i)
		attack:addCardToHand(card)
	end

	-- 计算cd
	local hand = attack:hand()
	for i = 1, #hand do
		if hand[i] ~= nil then
			hand[i]:reduceCd()
		end
	end

	hand = defend:hand()
	for i = 1, #hand do
		if hand[i] ~= nil then
			hand[i]:reduceCd()
		end
	end

	-- 移牌上场
	local hand = attack:hand()
	if #hand > 0 then
		local i = 1
		while hand[i] ~= nil do
			if hand[i]:cd() <= 0 then
				local card = hand[i]
				attack:removeCardFromHandByIdx(i)
				attack:addCardToField(card)
			else
				i = i + 1
			end
		end
	end

	local afield = attack:field()
	local dfield = defend:field()
	for i = 1, 10 do
		local acard = afield[i]

		if acard ~= nil then
			local dcard = dfield[i]

			acard:enter(defend, dcard)

			-- 因为enter时可能会将对位卡打死
			-- 所以此处要再查询一次对位卡
			dcard = dfield[i]
			if dcard == nil then
				-- attack to hero
				acard:attackHero(defend)
			else
				-- attack to card
				acard:attackCard(dcard)
			end

			acard:leave()
		end
	end
end

return Round
