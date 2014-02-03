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
	self.hpLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("hp:%s", hp),
            size = 22,
            color = display.COLOR_WHITE,
            valign = ui.TEXT_VALIGN_BOTTOM,
        })
		:align(display.BOTTOM_LEFT, 0, 0)
        :addTo(self)

    local atk = self.cardInfo_.atk + self.cardInfo_.atkInc * self.cardLv_
    self.atkLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("atk:%s", atk),
            size = 22,
            color = display.COLOR_WHITE,
            valign = ui.TEXT_VALIGN_BOTTOM,
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

function FieldCardView:enter()
	transition.scaleTo(self, {
			scale = 1.2,
			time = 0.5,
			easing = 'in',
		})
end

function FieldCardView:leave()
	transition.scaleTo(self, {
			scale = 1,
			time = 0.5,
			easing = 'in',
		})
end

function FieldCardView:attack()
	local skillLabel = ui.newTTFLabelWithShadow({
            text = '攻击',
            size = 22,
            color = display.COLOR_RED,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER, 110 / 2, 170 / 2)
        :scale(0)
        :addTo(self)

    transition.scaleTo(skillLabel, {
    		scale = 2,
    		time = 2,
    		easing = 'in',
    		onComplete = function()
    				skillLabel:removeSelf()
    			end
    	})

    return 2
end

function FieldCardView:triggerSkill(skillId)
	local skillLabel = ui.newTTFLabelWithShadow({
            text = db.skill[skillId].name,
            size = 22,
            color = display.COLOR_RED,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER, 110 / 2, 170 / 2)
        :scale(0)
        :addTo(self)

    transition.scaleTo(skillLabel, {
    		scale = 2,
    		time = 2,
    		easing = 'in',
    		onComplete = function()
    				skillLabel:removeSelf()
    			end
    	})

    return 2
end

return FieldCardView