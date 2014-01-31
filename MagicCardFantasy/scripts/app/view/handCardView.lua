--[[
	@brief scripts/view/handCard.lua
]]

local HandCardView = class('HandCardView', , function()
    return display.newNode()
end)

function HandCardView:ctor(handCard)
	self.handCard_ = handCard

	local sprFileName = 'card/110_110/img_photoCard_'..handCard:id()..'.jpg'
	self.sprite_ = display.newSprite(sprFileName):addTo(self)
end

function HandCardView:id()
	return self.handCard_:id()
end

function HandCardView:card()
	return self.handCard_
end