local Log = require 'log'

local Skill = import '.skill'

Skill_wang_guo_zhi_li = class('Skill_wang_guo_zhi_li', Skill)

function Skill_wang_guo_zhi_li:ctor(properties)
	Skill_wang_guo_zhi_li.super.ctor(self, properties)
	
	self.name_ = '王国之力'
end

function Skill_wang_guo_zhi_li:onHeroAddCardToField(evt)
	local card = evt.card
	if card:race() == db.race.kingdom then
		card:addBaseAtk(self.additionAtk_)
	end
end

function Skill_wang_guo_zhi_li:toField(hero, card)
	self.additionAtk_ = 25 * self.lv_

	local field = hero:field()

	for k, v in pairs(field) do
		if v:race() == db.race.kingdom then
			v:addBaseAtk(self.additionAtk_)
		end
	end

	hero:addEventListener(Hero.ADD_CARD_TO_FIELD, self.onHeroAddCardToField, self)
end

function Skill_wang_guo_zhi_li:leaveField(hero, card)
	self.additionAtk_ = 25 * self.lv_
	
	local field = hero:field()

	for k, v in pairs(field) do
		if v:race() == db.race.kingdom then
			v:addBaseAtk(-self.additionAtk_)
		end
	end
end

return Skill_wang_guo_zhi_li