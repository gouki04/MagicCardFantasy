--[[
	@brief scripts/view/fieldCard.lua
]]
local CardDefine   = import '..model.card.cardDefine'

local FieldCardView = class('FieldCardView', function()
    return display.newNode()
end)

function FieldCardView:ctor(heroId, cardId, cardTypeId, cardLv)
	self.heroId_ = heroId
	self.cardId_ = cardId
	self.cardTypeId_ = cardTypeId
	self.cardLv_ = cardLv
	self.cardInfo_ = CardDefine.getCardInfo(self.cardTypeId_)

	local sprFileName = 'res/card/110_170/img_minCard_'..self.cardTypeId_..'.jpg'
	self.sprite_ = display.newSprite(sprFileName):addTo(self)
		:align(display.BOTTOM_LEFT)

	local hp = self.cardInfo_.hp + self.cardInfo_.hpInc * self.cardLv_
	self.hpLabel_ = ui.newTTFLabel({
            text = string.format("hp:%s", hp),
            size = 22,
            color = display.COLOR_WHITE,
        })
		:align(display.BOTTOM_LEFT, 0, 0)
        :addTo(self)

    local atk = self.cardInfo_.atk + self.cardInfo_.atkInc * self.cardLv_
    self.atkLabel_ = ui.newTTFLabel({
            text = string.format("atk:%s", atk),
            size = 22,
            color = display.COLOR_WHITE,
        })
        :align(display.BOTTOM_LEFT, 0, 30)
        :addTo(self)
end

function FieldCardView:setAtk(atk)
	self.atkLabel_:setString(string.format("atk:%s", atk))
end

function FieldCardView:setHp(hp)
	self.hpLabel_:setString(string.format("hp:%s", hp))
end

function FieldCardView:cardId()
	return self.cardId_
end

function FieldCardView:heroId()
	return self.heroId_
end

return FieldCardView