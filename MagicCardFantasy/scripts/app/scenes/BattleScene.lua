require 'utility.utility'

local Hero             = import '..model.hero.hero'
local Game             = import '..model.game'
local FieldCardRowView = import '..view.FieldCardRowView'
local HandCardRowView  = import '..view.HandCardRowView'
local Track            = import '..model.track'
local scheduler        = require 'framework.scheduler'

local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor(hero1Info, hero2Info)
    self.hero1_ = hero1Info
    self.hero2_ = hero2Info

    self.hand_ = {}
    self.hand_[self.hero1_.id] = HandCardRowView.new(self.hero1_)
        :align(display.BOTTOM_LEFT, 100, 0)
        :addTo(self)

    self.hand_[self.hero2_.id] = HandCardRowView.new(self.hero2_)
        :align(display.BOTTOM_LEFT, 100, display.top - 110)
        :addTo(self)

    self.field_ = {}
    self.field_[self.hero1_.id] = FieldCardRowView.new(self.hero1_)
        :align(display.BOTTOM_LEFT, 100, 150)
        :addTo(self)

    self.field_[self.hero2_.id] = FieldCardRowView.new(self.hero1_)
        :align(display.BOTTOM_LEFT, 100, display.top - 150 - 170)
        :addTo(self)

    self.heros_ = {}
    self.heros_[self.hero1_.id] = self.hero1_
    self.heros_[self.hero2_.id] = self.hero2_

    self.game_ = Game.new()
    self.trackEngine_ = Track.new(self.game_)

    local hero1 = Hero.new({
            id = hero1Info.id,
            name = hero1Info.name,
            lv = hero1Info.lv,
        })

    for i, v in pairs(hero1Info.deck) do
        hero1:addCardToDeck(i, v.id, v.lv)
    end

    local hero2 = Hero.new({
            id = hero2Info.id,
            name = hero2Info.name,
            lv = hero2Info.lv,
        })

    for i, v in pairs(hero2Info.deck) do
        hero2:addCardToDeck(i, v.id, v.lv)
    end

    self.trackEngine_:start()

    self.game_:start(hero1, hero2)
    self.game_:autoBattle()

    self.trackInfo_ = self.trackEngine_:finish()
    self.trackInfo_.idx = 1

    -- app.game = self.game_
end

function BattleScene:executeNextCmd()
    local cmd = self.trackInfo_[self.trackInfo_.idx]
    if not cmd then
        -- end
        return
    end

    self.trackInfo_.idx = self.trackInfo_.idx + 1

    -- dispatch
    local cmdType = cmd.cmdType
    echoInfo('executeNextCmd : '..cmdType)

    if cmdType == Track.HERO_ADD_CARD_TO_DECK then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_ADD_CARD_TO_HAND then
        scheduler.performWithDelayGlobal(
            function(evt)
                local cardTypeId = self.heros_[cmd.heroId].deck[cmd.cardId].id
                self.hand_[cmd.heroId]:addCard(cmd.cardId, cardTypeId)

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_ADD_CARD_TO_FIELD then
        scheduler.performWithDelayGlobal(
            function(evt)
                local cardTypeId = self.heros_[cmd.heroId].deck[cmd.cardId].id
                self.field_[cmd.heroId]:addCard(cmd.cardId, cardTypeId, cmd.cardLv, cmd.idx)

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_ADD_CARD_TO_GRAVE then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_DECK then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_HAND then
        scheduler.performWithDelayGlobal(
            function()
                self.hand_[cmd.heroId]:removeCard(cmd.cardId)

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_FIELD then
        scheduler.performWithDelayGlobal(
            function()
                self.field_[cmd.heroId]:removeCard(cmd.cardId, cmd.idx)

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_GRAVE then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_PROPERTY_CHANGE then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_CD_CHANGE then
        local card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
        if card then
            card:setCD(cmd.cd)
        end

        self:executeNextCmd()
    elseif cmdType == Track.CARD_ATTACK_TO_CARD then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_ATTACK_TO_HERO then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_PROPERTY_CHANGE then
        scheduler.performWithDelayGlobal(
            function()
                local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
                if card then
                    for k, v in pairs(cmd.property) do
                        if k == 'hp' then
                            card:setHp(v)
                        elseif k == 'atk' then
                            card:setAtk(v)
                        end
                    end
                end

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.CARD_ENTER then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_LEAVE then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_SKILL_TRIGGER then
        self:executeNextCmd()
    elseif cmdType == Track.ROUND_START then
        self.field_[self.hero1_.id]:reorder()
        self.field_[self.hero2_.id]:reorder()
        self:executeNextCmd()
    end
end

function BattleScene:onEnter()
    self:executeNextCmd()
end

return BattleScene
