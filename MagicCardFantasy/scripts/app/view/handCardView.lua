--[[
	@brief scripts/view/handCard.lua
]]
local CardDefine   = import '..model.card.cardDefine'

local HandCardView = class('HandCardView', function()
    return display.newNode()
end)

function HandCardView:ctor(heroId, cardId, cardTypeId)
	self.heroId_ = heroId
	self.cardId_ = cardId
	self.cardTypeId_ = cardTypeId
	self.cardInfo_ = CardDefine.getCardInfo(self.cardTypeId_)

	local sprFileName = 'res/card/110_110/img_photoCard_'..self.cardTypeId_..'.jpg'
	self.sprite_ = display.newSprite(sprFileName):addTo(self)
		:align(display.BOTTOM_LEFT)

	self.cdLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("cd:%s", self.cardInfo_.cd),
            size = 22,
            color = display.COLOR_WHITE,
            align = ui.TEXT_ALIGN_CENTER,
        })
		:align(display.CENTER, 55, 55)
        :addTo(self)
end

function HandCardView:setCD(cd)
	self.cdLabel_:setString(string.format("cd:%s", cd))
end

function HandCardView:cardId()
	return self.cardId_
end

function HandCardView:heroId()
	return self.heroId_
end

return HandCardView