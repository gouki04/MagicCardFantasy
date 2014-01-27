--[[
	@brief scripts/view/handCard.lua
]]
require 'utility/class'
require 'utility/delegate'

HandCard_view = class()

function HandCard_view:ctor()
end

function HandCard_view:init(handCard)
	self.m_card = handCard

	local spr = CCSprite:spriteWithFile('card/110_110/img_photoCard_'..self:id()..'.jpg')
	self.m_spr = spr
end

function HandCard_view:detroy()
	if self.m_spr then
		self.m_spr:removeFromParentAndCleanup(true)
	end

	self.m_spr = nil
end

function HandCard_view:id()
	return self.m_card:id()
end

function HandCard_view:node()
	return self.m_spr
end

function HandCard_view:card()
	return self.m_card
end