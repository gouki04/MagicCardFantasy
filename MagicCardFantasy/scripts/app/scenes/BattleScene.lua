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
    self.hand_[self.hero1_.id] = HandCardRowView.new(self.hero1_, 'side.down')
        :align(display.BOTTOM_LEFT, 100, 0)
        :addTo(self)

    self.hand_[self.hero2_.id] = HandCardRowView.new(self.hero2_, 'side.up')
        :align(display.BOTTOM_LEFT, 100, display.top - 110)
        :addTo(self)

    self.field_ = {}
    self.field_[self.hero1_.id] = FieldCardRowView.new(self.hero1_, 'side.down')
        :align(display.BOTTOM_LEFT, 100, 150)
        :addTo(self)

    self.field_[self.hero2_.id] = FieldCardRowView.new(self.hero1_, 'side.up')
        :align(display.BOTTOM_LEFT, 100, display.top - 150 - 170)
        :addTo(self)

    self.heros_ = {}
    self.heros_[self.hero1_.id] = HeroView.new(self.hero1_, 'side.down')
        :align(display.BOTTOM_LEFT, 50, 50)
        :addTo(self)

    self.heros_[self.hero2_.id] = HeroView.new(self.hero2_, 'side.up')
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
    self:registCmdHandle(Track.CARD_BEFORE_ATTACK_TO_CARD, self.onCardBeforeAttackToCard)
    self:registCmdHandle(Track.CARD_AFTER_ATTACK_TO_CARD, self.onCardAfterAttackToCard)
    self:registCmdHandle(Track.CARD_BEFORE_ATTACK_TO_HERO, self.onCardBeforeAttackToHero)
    self:registCmdHandle(Track.CARD_AFTER_ATTACK_TO_HERO, self.onCardAfterAttackToHero)
    self:registCmdHandle(Track.CARD_PROPERTY_CHANGE, self.onCardPropertyChange)
    self:registCmdHandle(Track.CARD_ENTER, self.onCardEnter)
    self:registCmdHandle(Track.CARD_LEAVE, self.onCardLeave)
    self:registCmdHandle(Track.CARD_SKILL_TRIGGER_BEGIN, self.onSkillTriggerBegin)
    self:registCmdHandle(Track.CARD_SKILL_TRIGGER_END, self.onSkillTriggerEnd)
    self:registCmdHandle(Track.ROUND_START, self.onRoundStart)
    self:registCmdHandle(Track.CARD_ENCOUNTER_SKILL, self.onCardEncounterSkill)
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
        end, 0.5)
end

function BattleScene:onHeroAddCardToField(cmd)
    scheduler.performWithDelayGlobal(
        function(evt)
            local cardTypeId = self.heroInfos_[cmd.heroId].deck[cmd.cardId].id
            self.field_[cmd.heroId]:addCard(cmd.cardId, cardTypeId, cmd.cardLv, cmd.idx)

            self:executeNextCmd()
        end, 0.5)
end

function BattleScene:onHeroRemoveCardFromHand(cmd)
    scheduler.performWithDelayGlobal(
        function()
            self.hand_[cmd.heroId]:removeCard(cmd.cardId)

            self:executeNextCmd()
        end, 0.5)
end

function BattleScene:onHeroRemoveCardFromField(cmd)
    scheduler.performWithDelayGlobal(
        function()
            self.field_[cmd.heroId]:removeCard(cmd.cardId, cmd.idx)

            self:executeNextCmd()
        end, 0.5)
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

function BattleScene:onCardBeforeAttackToCard(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attackBegin()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardAfterAttackToCard(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attackEnd()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardBeforeAttackToHero(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attackBegin()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardAfterAttackToHero(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        -- TODO wtf
        return
    end

    local time = card:attackEnd()
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onCardPropertyChange(cmd)
    local time = 0
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if card then
        for k, v in pairs(cmd.property) do
            if k == 'hp' then
                time = card:setHp(v)
            elseif k == 'atk' then
                time = card:setAtk(v)
            end
        end
    end

    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
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

function BattleScene:onSkillTriggerBegin(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
    end

    if not card then
        -- TODO wtf
        return
    end

    local time = card:skillTriggerBegin(cmd.skillId)
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
end

function BattleScene:onSkillTriggerEnd(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
    end

    if not card then
        -- TODO wtf
        return
    end

    local time = card:skillTriggerEnd(cmd.skillId)
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

function BattleScene:onCardEncounterSkill(cmd)
    local card = self.field_[cmd.heroId]:getCard(cmd.cardId)
    if not card then
        card = self.hand_[cmd.heroId]:getCard(cmd.cardId)
    end

    if not card then
        -- TODO wtf
        return
    end

    local time = card:encounterSkill(cmd.skillId)
    scheduler.performWithDelayGlobal(
        function()
            self:executeNextCmd()
        end, time)
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
