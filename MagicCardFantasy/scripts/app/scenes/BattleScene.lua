require 'utility.utility'

local Hero          = import '..model.hero.hero'
local Game          = import '..model.game'
local FieldCardView = import '..view.fieldCardView'
local HandCardView  = import '..view.HandCardView'
local Track         = import '..model.track'
local Timer         = require 'framework.api.Timer'
local scheduler     = require 'framework.scheduler'

local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor(hero1Info, hero2Info)
    self.hero1_ = hero1Info
    self.hero2_ = hero2Info

    self.handCards_ = {}
    self.handCards_[self.hero1_.id] = {}
    self.handCards_[self.hero2_.id] = {}

    self.fieldCards_ = {}
    self.fieldCards_[self.hero1_.id] = {}
    self.fieldCards_[self.hero2_.id] = {}

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

    self.timerCnt_ = 1
    self.timer_ = Timer.new()

    -- app.game = self.game_
end

function BattleScene:updateHandCard(heroId)
    local y
    if heroId == self.hero1_.id then
        y = 0
    else
        y = display.top - 110
    end

    for i, v in ipairs(self.handCards_[heroId]) do
        v:pos(100 + i * (110 + 10), y)
    end
end

function BattleScene:reorderField()
    -- hero 1
    local field = self.fieldCards_[self.hero1_.id]
    local field_cnt = table.count(field)
    if field_cnt > 0 then
        local idx = 1
        for i = 1, 10 do
            if field[i] ~= nil then
                if idx ~= i then
                    field[idx] = field[i]
                    field[i] = nil
                end
                
                idx = idx + 1
                if idx > field_cnt then
                    break
                end
            end
        end
    end

    for i = 1, #field do
        local card = field[i]
        if card then
            card:pos(100 + i * (110 + 10), 150)
        end
    end

    -- hero 2
    local field = self.fieldCards_[self.hero2_.id]
    local field_cnt = table.count(field)
    if field_cnt > 0 then
        local idx = 1
        for i = 1, 10 do
            if field[i] ~= nil then
                if idx ~= i then
                    field[idx] = field[i]
                    field[i] = nil
                end
                
                idx = idx + 1
                if idx > field_cnt then
                    break
                end
            end
        end
    end

    for i = 1, #field do
        local card = field[i]
        if card then
            card:pos(100 + i * (110 + 10), display.top - 150 - 170)
        end
    end
end

function BattleScene:updateFieldCard(heroId)
    local y
    if heroId == self.hero1_.id then
        y = 150
    else
        y = display.top - 150 - 170
    end

    for i = 1, 10 do
        local card = self.fieldCards_[heroId][i]
        if card then
            card:pos(100 + i * (110 + 10), y)
        end
    end
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

                local handCardView = HandCardView.new(cmd.heroId, cmd.cardId, cardTypeId)
                    :align(display.BOTTOM_LEFT)
                    :addTo(self)

                table.insert(self.handCards_[cmd.heroId], handCardView)

                self:updateHandCard(cmd.heroId)
                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_ADD_CARD_TO_FIELD then
        scheduler.performWithDelayGlobal(
            function(evt)
                local cardTypeId = self.heros_[cmd.heroId].deck[cmd.cardId].id

                local fieldCardView = FieldCardView.new(cmd.heroId, cmd.cardId, cardTypeId, cmd.cardLv)
                    :align(display.BOTTOM_LEFT)
                    :addTo(self)

                self.fieldCards_[cmd.heroId][cmd.idx] = fieldCardView

                self:updateFieldCard(cmd.heroId)
                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_ADD_CARD_TO_GRAVE then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_DECK then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_HAND then
        scheduler.performWithDelayGlobal(
            function()
                for i, v in ipairs(self.handCards_[cmd.heroId]) do
                    if v:cardId() == cmd.cardId then
                        table.remove(self.handCards_[cmd.heroId], i)
                        v:removeSelf()
                        break
                    end
                end

                self:updateHandCard(cmd.heroId)
                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_FIELD then
        scheduler.performWithDelayGlobal(
            function()
                local card = self.fieldCards_[cmd.heroId][cmd.idx]
                self.fieldCards_[cmd.heroId][cmd.idx] = nil
                card:removeSelf()

                self:executeNextCmd()
            end, 1)
    elseif cmdType == Track.HERO_REMOVE_CARD_FROM_GRAVE then
        self:executeNextCmd()
    elseif cmdType == Track.HERO_PROPERTY_CHANGE then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_CD_CHANGE then
        local hand = self.handCards_[cmd.heroId]
        for i, v in pairs(hand) do
            if v:cardId() == cmd.cardId then
                v:setCD(cmd.cd)
            end
        end
        self:executeNextCmd()
    elseif cmdType == Track.CARD_ATTACK_TO_CARD then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_ATTACK_TO_HERO then
        self:executeNextCmd()
    elseif cmdType == Track.CARD_PROPERTY_CHANGE then
        scheduler.performWithDelayGlobal(
            function()
                local field = self.fieldCards_[cmd.heroId]
                for i, card in pairs(field) do
                    if card:cardId() == cmd.cardId then
                        for k, v in pairs(cmd.property) do
                            if k == 'hp' then
                                card:setHp(v)
                            elseif k == 'atk' then
                                card:setAtk(v)
                            end
                        end
                        break
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
        self:reorderField()
        self:executeNextCmd()
    end
end

function BattleScene:onEnter()
    self:executeNextCmd()
end

return BattleScene
