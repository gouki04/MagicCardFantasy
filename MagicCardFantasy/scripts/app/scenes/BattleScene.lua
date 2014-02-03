require 'utility.utility'

local Hero             = import '..model.hero.hero'
local Game             = import '..model.game'
local FieldCardRowView = import '..view.FieldCardRowView'
local HandCardRowView  = import '..view.HandCardRowView'
local HeroView         = import '..view.HeroView'
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
    self.heros_[self.hero1_.id] = HeroView.new(self.hero1_)
        :align(display.BOTTOM_LEFT, 50, 50)
        :addTo(self)

    self.heros_[self.hero2_.id] = HeroView.new(self.hero2_)
        :align(display.BOTTOM_LEFT, 50, display.top - 50)
        :addTo(self)

    self.heroInfos_ = {}
    self.heroInfos_[self.hero1_.id] = self.hero1_
    self.heroInfos_[self.hero2_.id] = self.hero2_

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

    self.cmdHandle_ = {}
    self:registCmdHandle(Track.HERO_ADD_CARD_TO_HAND, self.onHeroAddCardToHand)
    self:registCmdHandle(Track.HERO_ADD_CARD_TO_FIELD, self.onHeroAddCardToField)
    self:registCmdHandle(Track.HERO_REMOVE_CARD_FROM_HAND, self.onHeroRemoveCardFromHand)
    self:registCmdHandle(Track.HERO_REMOVE_CARD_FROM_FIELD, self.onHeroRemoveCardFromField)
    self:registCmdHandle(Track.HERO_PROPERTY_CHANGE, self.onHeroPropertyChange)
    self:registCmdHandle(Track.CARD_CD_CHANGE, self.onCardCdChange)
    self:registCmdHandle(Track.CARD_ATTACK_TO_CARD, self.onCardAttackToCard)
    self:registCmdHandle(Track.CARD_ATTACK_TO_HERO, self.onCardAttackToHero)
    self:registCmdHandle(Track.CARD_PROPERTY_CHANGE, self.onCardPropertyChange)
    self:registCmdHandle(Track.CARD_ENTER, self.onCardEnter)
    self:registCmdHandle(Track.CARD_LEAVE, self.onCardLeave)
    self:registCmdHandle(Track.CARD_SKILL_TRIGGER, self.onSkillTrigger)
    self:registCmdHandle(Track.ROUND_START, self.onRoundStart)
end

function BattleScene:registCmdHandle(cmdType, handle)
    self.cmdHandle_[cmdType] = handle
end

function BattleScene:onHeroAddCardToHand(cmd)
    scheduler.performWithDelayGlobal(
        function(evt)
            local cardTypeId = self.heroInfos_[cmd.heroId].deck[cmd.cardId].id
            self.hand_[cmd.heroId]:addCard(cmd.cardId, cardTypeId)

            self:executeNextCmd()
        end, 1)
end

function BattleScene:onHeroAddCardToField(cmd)
    scheduler.performWithDelayGlobal(
        function(evt)
            local cardTypeId = self.heroInfos_[cmd.heroId].deck[cmd.cardId].id
            self.field_[cmd.heroId]:addCard(cmd.cardId, cardTypeId, cmd.cardLv, cmd.idx)

            self:executeNextCmd()
        end, 1)
end

function BattleScene:onHeroRemoveCardFromHand(cmd)
    scheduler.performWithDelayGlobal(
        function()
            self.hand_[cmd.heroId]:removeCard(cmd.cardId)

            self:executeNextCmd()
        end, 1)
end

function BattleScene:onHeroRemoveCardFromField(cmd)
    scheduler.performWithDelayGlobal(
        function()
            self.field_[cmd.heroId]:removeCard(cmd.cardId, cmd.idx)

            self:executeNextCmd()
        end, 1)
end

function BattleScene:onHeroPropertyChange(cmd)
    scheduler.performWithDelayGlobal(
        function()
            local hero = self.heros_[cmd.heroId]
            if hero then
                for k, v in pairs(cmd.property) do
                    if k == 'hp' then
                        hero:setHp(v)
                    end
                end
            end

            self:executeNextCmd()
        end, 1)
end

function BattleScene:onCardCdChange(cmd)
    local card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
    if card then
        card:setCD(cmd.cd)
    end

    self:executeNextCmd()
end

function BattleScene:onCardAttackToCard(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attack()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardAttackToHero(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attack()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardPropertyChange(cmd)
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
end

function BattleScene:onCardEnter(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    card:enter()
    self:executeNextCmd()
end

function BattleScene:onCardLeave(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    card:leave()
    self:executeNextCmd()
end

function BattleScene:onSkillTrigger(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
    end

    if not card then
        -- TODO wtf
        return
    end

    local time = card:triggerSkill(cmd.skillId)
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onRoundStart(cmd)
    self.field_[self.hero1_.id]:reorder()
    self.field_[self.hero2_.id]:reorder()
    self:executeNextCmd()
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

    local handle = self.cmdHandle_[cmdType]
    if not handle then
        handle = self.executeNextCmd
    end

    handle(self, cmd)
end

function BattleScene:onEnter()
    self:executeNextCmd()
end

return BattleScene
