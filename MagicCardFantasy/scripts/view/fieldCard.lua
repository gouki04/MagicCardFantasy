--[[
	@brief scripts/view/fieldCard.lua
]]
require 'utility/class'
require 'utility/delegate'

FieldCard_view = class()

function FieldCard_view:ctor()
end

function FieldCard_view:init(fieldCard)
	self.m_card = fieldCard

	local spr = CCSprite:spriteWithFile('card/110_170/img_minCard_'..self:id()..'.jpg')
	self.m_spr = spr
end

function FieldCard_view:detroy()
	if self.m_spr then
		self.m_spr:removeFromParentAndCleanup(true)
	end
	
	self.m_spr = nil
end

function FieldCard_view:id()
	return self.m_card:id()
end

function FieldCard_view:node()
	return self.m_spr
end

function FieldCard_view:card()
	return self.m_card
end