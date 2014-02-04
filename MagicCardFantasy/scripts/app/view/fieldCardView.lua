--[[
	@brief scripts/view/fieldCard.lua
]]
local CardDefine = import '..model.card.cardDefine'
local scheduler  = require 'framework.scheduler'

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

	self.hp_ = self.cardInfo_.hp + self.cardInfo_.hpInc * self.cardLv_
	self.hpLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("hp:%s", self.hp_),
            size = 22,
            color = display.COLOR_WHITE,
            valign = ui.TEXT_VALIGN_BOTTOM,
        })
		:align(display.BOTTOM_LEFT, 0, 0)
        :addTo(self)

    self.atk_ = self.cardInfo_.atk + self.cardInfo_.atkInc * self.cardLv_
    self.atkLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("atk:%s", self.atk_),
            size = 22,
            color = display.COLOR_WHITE,
            valign = ui.TEXT_VALIGN_BOTTOM,
        })
        :align(display.BOTTOM_LEFT, 0, 30)
        :addTo(self)
end

function FieldCardView:setSide(side)
    self.side_ = side

    if self.side_ == 'side.down' then
        self.triggerMoveY_ = 5
    else
        self.triggerMoveY_ = -5
    end

    return self
end

function FieldCardView:setAtk(atk)
    local t = 0
    local time = 0.5
    local id
    id = scheduler.scheduleUpdateGlobal(
        function(dt)
            t = t + dt

            local showAtk
            if t >= time then
                showAtk = atk
            else
                showAtk = self.atk_ + (t / time) * (atk - self.atk_)
            end

            self.atkLabel_:setString(string.format("atk:%s", math.floor(showAtk)))

            if t >= time then
                self.atk_ = atk
                scheduler.unscheduleGlobal(id)
            end
        end, 0.1)

    return time
end

function FieldCardView:setHp(hp)
    local t = 0
    local time = 0.5
    local id
    id = scheduler.scheduleUpdateGlobal(
        function(dt)
            t = t + dt

            local showHp
            if t >= time then
                showHp = hp
            else
                showHp = self.hp_ + (t / time) * (hp - self.hp_)
            end

            self.hpLabel_:setString(string.format("hp:%s", math.floor(showHp)))

            if t >= time then
                self.hp_ = hp
                scheduler.unscheduleGlobal(id)
            end
        end, 0.1)

    return time
end

function FieldCardView:cardId()
	return self.cardId_
end

function FieldCardView:heroId()
	return self.heroId_
end

function FieldCardView:enter()
	-- transition.scaleTo(self, {
	-- 		scale = 1.05,
	-- 		time = 0.1,
	-- 		easing = 'in',
	-- 	})
end

function FieldCardView:leave()
	-- transition.scaleTo(self, {
	-- 		scale = 1,
	-- 		time = 0.1,
	-- 		easing = 'in',
	-- 	})
end

function FieldCardView:fieldSide()
    return self.side_
end

function FieldCardView:showTrigger(msg)
    local skillLabel = ui.newTTFLabelWithShadow({
            text = msg,
            size = 22,
            color = display.COLOR_RED,
            align = ui.TEXT_ALIGN_CENTER,
        })
        :align(display.CENTER, 110 / 2, 170 / 2)
        :scale(0)
        :addTo(self)

    local time = 0.5
    transition.scaleTo(skillLabel, {
            scale = 2,
            time = time,
            easing = 'out',
            onComplete = function()
                    skillLabel:removeSelf()
                end
        })

    return time
end

function FieldCardView:attackBegin()
    transition.moveBy(self, {
            x = 0,
            y = self.triggerMoveY_,
            time = 0.1,
            easing = 'in'
        })

    self:showTrigger('攻击')

    return 0.1
end

function FieldCardView:attackEnd()
    transition.moveBy(self, {
            x = 0,
            y = -self.triggerMoveY_,
            time = 0.1,
            easing = 'out'
        })

    return 0.1
end

function FieldCardView:skillTriggerBegin(skillId)
    transition.moveBy(self, {
            x = 0,
            y = self.triggerMoveY_,
            time = 0.1,
            easing = 'in'
        })

    self:showTrigger(db.skill[skillId].name)
    return 0.1
end

function FieldCardView:skillTriggerEnd(skillId)
    transition.moveBy(self, {
            x = 0,
            y = -self.triggerMoveY_,
            time = 0.1,
            easing = 'out'
        })

    return 0.1
end

function FieldCardView:encounterSkill(skillId)
    local anim = db.skill[skillId].anim

    if anim == db.skill.anim.fire then
        self.sprite_:setColor(display.COLOR_RED)

        local time = 0.3
        scheduler.performWithDelayGlobal(
            function()
                self.sprite_:setColor(display.COLOR_WHITE)
            end, time)

        return time
    elseif anim == db.skill.anim.dodge then
        transition.moveBy(self, {
                x = 10,
                y = 0,
                time = 0.2,
                easing = 'BOUNCEINOUT'
            })
        return 0.2
    end

    return 0
end

return FieldCardView