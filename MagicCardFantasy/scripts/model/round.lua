--[[
	@brief scripts/model/round.lua
]]
require 'scripts/model/hero/hero'
require 'scripts/model/card/card'

local function handCardBattle(acard, dcard)
	acard:attackCard(dcard)
end

local function start(attack, defend)
	Game.log('[round] hero['..attack:name()..']')

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

		attack:addCardToHand(deck[i])
		table.remove(deck, i)
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
				attack:addCardToField(hand[i])
				table.remove(hand, i)
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

			if dcard == nil then
				-- attack to hero
				defend:damage(acard:atk())
			else
				-- attack to card
				handCardBattle(acard, dcard)
			end

			acard:leave()
		end
	end
end

Round = {
	start = start,
}