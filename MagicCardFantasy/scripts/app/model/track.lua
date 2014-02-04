local Hero = import '.hero.hero'
local Card = import '.card.card'
local Game = import '.game'

local Track = class('Track')

Track.HERO_ADD_CARD_TO_DECK       = 1
Track.HERO_ADD_CARD_TO_HAND       = 2
Track.HERO_ADD_CARD_TO_FIELD      = 3
Track.HERO_ADD_CARD_TO_GRAVE      = 4
Track.HERO_REMOVE_CARD_FROM_DECK  = 5
Track.HERO_REMOVE_CARD_FROM_HAND  = 6
Track.HERO_REMOVE_CARD_FROM_FIELD = 7
Track.HERO_REMOVE_CARD_FROM_GRAVE = 8
Track.HERO_PROPERTY_CHANGE        = 9
Track.CARD_CD_CHANGE              = 10
Track.CARD_BEFORE_ATTACK_TO_CARD  = 11
Track.CARD_AFTER_ATTACK_TO_CARD   = 12
Track.CARD_BEFORE_ATTACK_TO_HERO  = 13
Track.CARD_AFTER_ATTACK_TO_HERO   = 14
Track.CARD_PROPERTY_CHANGE        = 15
Track.CARD_ENTER                  = 16
Track.CARD_LEAVE                  = 17
Track.CARD_SKILL_TRIGGER_BEGIN    = 18
Track.CARD_SKILL_TRIGGER_END      = 19
Track.ROUND_START                 = 20
Track.CARD_ENCOUNTER_SKILL        = 21

function Track:ctor(game)
    self.game_ = game

    self.game_:addEventListener(Game.GAME_START_EVENT, self.onGameStart, self)
    self.game_:addEventListener(Game.ROUND_START_EVENT, self.onRoundStart, self)
end

function Track:onRoundStart(evt)
    self:record({
            cmdType = Track.ROUND_START,
        })
end

function Track:onGameStart(evt)
    self.hero1_ = evt.hero1
    self.hero2_ = evt.hero2

    self.hero1_:addEventListener(Hero.ADD_CARD_TO_DECK, self.onHeroAddCardToDeck, self)
    self.hero1_:addEventListener(Hero.ADD_CARD_TO_HAND, self.onHeroAddCardToHand, self)
    self.hero1_:addEventListener(Hero.ADD_CARD_TO_FIELD, self.onHeroAddCardToField, self)
    self.hero1_:addEventListener(Hero.ADD_CARD_TO_GRAVE, self.onHeroAddCardToGrave, self)
    self.hero1_:addEventListener(Hero.REMOVE_CARD_FROM_DECK, self.onHeroRemoveCardFromDeck, self)
    self.hero1_:addEventListener(Hero.REMOVE_CARD_FROM_HAND, self.onHeroRemoveCardFromHand, self)
    self.hero1_:addEventListener(Hero.REMOVE_CARD_FROM_FIELD, self.onHeroRemoveCardFromField, self)
    self.hero1_:addEventListener(Hero.REMOVE_CARD_FROM_GRAVE, self.onHeroRemoveCardFromGrave, self)
    self.hero1_:addEventListener(Hero.HP_CHANGED_EVENT, self.onHeroHPChanged, self)

    self.hero2_:addEventListener(Hero.ADD_CARD_TO_DECK, self.onHeroAddCardToDeck, self)
    self.hero2_:addEventListener(Hero.ADD_CARD_TO_HAND, self.onHeroAddCardToHand, self)
    self.hero2_:addEventListener(Hero.ADD_CARD_TO_FIELD, self.onHeroAddCardToField, self)
    self.hero2_:addEventListener(Hero.ADD_CARD_TO_GRAVE, self.onHeroAddCardToGrave, self)
    self.hero2_:addEventListener(Hero.REMOVE_CARD_FROM_DECK, self.onHeroRemoveCardFromDeck, self)
    self.hero2_:addEventListener(Hero.REMOVE_CARD_FROM_HAND, self.onHeroRemoveCardFromHand, self)
    self.hero2_:addEventListener(Hero.REMOVE_CARD_FROM_FIELD, self.onHeroRemoveCardFromField, self)
    self.hero2_:addEventListener(Hero.REMOVE_CARD_FROM_GRAVE, self.onHeroRemoveCardFromGrave, self)
    self.hero2_:addEventListener(Hero.HP_CHANGED_EVENT, self.onHeroHPChanged, self)
end

function Track:onHeroAddCardToDeck(evt)
    self:record({
            cmdType = Track.HERO_ADD_CARD_TO_DECK,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })
end

function Track:onHeroAddCardToHand(evt)
    self:record({
            cmdType = Track.HERO_ADD_CARD_TO_HAND,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })

    evt.card:addEventListener(Card.CD_CHANGE_EVENT, self.onCardCdChanged, self)
    evt.card:addEventListener(Card.SKILL_TRIGGER_BEGIN_EVENT, self.onCardSkillTriggerBegin, self)
end

function Track:onHeroAddCardToField(evt)
    self:record({
            cmdType = Track.HERO_ADD_CARD_TO_FIELD,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
            cardLv = evt.card:lv(),
            idx = evt.idx,
        })

    evt.card:addEventListener(Card.BEFORE_ATTACK_TO_CARD_EVENT, self.onCardBeforeAttackToCard, self)
    evt.card:addEventListener(Card.AFTER_ATTACK_TO_CARD_EVENT, self.onCardAfterAttackToCard, self)
    evt.card:addEventListener(Card.BEFORE_ATTACK_TO_HERO_EVENT, self.onCardBeforeAttackToHero, self)
    evt.card:addEventListener(Card.AFTER_ATTACK_TO_HERO_EVENT, self.onCardAfterAttackToHero, self)
    evt.card:addEventListener(Card.ATK_CHANGED_EVENT, self.onCardAtkChanged, self)
    evt.card:addEventListener(Card.HP_CHANGED_EVENT, self.onCardHPChanged, self)
    evt.card:addEventListener(Card.ENTER_EVENT, self.onCardEnter, self)
    evt.card:addEventListener(Card.LEAVE_EVENT, self.onCardLeave, self)
    evt.card:addEventListener(Card.SKILL_TRIGGER_BEGIN_EVENT, self.onCardSkillTriggerBegin, self)
    evt.card:addEventListener(Card.SKILL_TRIGGER_END_EVENT, self.onCardSkillTriggerEnd, self)
    evt.card:addEventListener(Card.ENCOUNTER_SKILL_EVENT, self.onCardEncounterSkill, self)
end

function Track:onHeroAddCardToGrave(evt)
    self:record({
            cmdType = Track.HERO_ADD_CARD_TO_GRAVE,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })
end

function Track:onHeroRemoveCardFromDeck(evt)
    self:record({
            cmdType = Track.HERO_REMOVE_CARD_FROM_DECK,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })
end

function Track:onHeroRemoveCardFromHand(evt)
    self:record({
            cmdType = Track.HERO_REMOVE_CARD_FROM_HAND,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })
end

function Track:onHeroRemoveCardFromField(evt)
    self:record({
            cmdType = Track.HERO_REMOVE_CARD_FROM_FIELD,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
            idx = evt.idx,
        })
end

function Track:onHeroRemoveCardFromGrave(evt)
    self:record({
            cmdType = Track.HERO_REMOVE_CARD_FROM_GRAVE,
            heroId = evt.hero:id(),
            cardId = evt.card:id(),
        })
end

function Track:onHeroHPChanged(evt)
    self:record({
            cmdType = Track.HERO_PROPERTY_CHANGE,
            heroId = evt.hero:id(),
            property = {
                hp = evt.hp,
            }
        })
end

function Track:onCardCdChanged(evt)
    self:record({
            cmdType = Track.CARD_CD_CHANGE,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            cd = evt.cd,
        })
end

function Track:onCardBeforeAttackToCard(evt)
    self:record({
            cmdType = Track.CARD_BEFORE_ATTACK_TO_CARD,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            target = {
                heroId = evt.targetCard:heroId(),
                cardId = evt.targetCard:id(),
            }
        })
end

function Track:onCardAfterAttackToCard(evt)
    self:record({
            cmdType = Track.CARD_AFTER_ATTACK_TO_CARD,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
        })
end

function Track:onCardBeforeAttackToHero(evt)
    self:record({
            cmdType = Track.CARD_BEFORE_ATTACK_TO_HERO,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            target = evt.targetCard:id(),
        })
end

function Track:onCardAfterAttackToHero(evt)
    self:record({
            cmdType = Track.CARD_AFTER_ATTACK_TO_HERO,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
        })
end

function Track:onCardAtkChanged(evt)
    self:record({
            cmdType = Track.CARD_PROPERTY_CHANGE,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            property = {
                atk = evt.atk,
            }
        })
end

function Track:onCardHPChanged(evt)
    self:record({
            cmdType = Track.CARD_PROPERTY_CHANGE,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            property = {
                hp = evt.hp,
            }
        })
end

function Track:onCardEnter(evt)
    self:record({
            cmdType = Track.CARD_ENTER,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
        })
end

function Track:onCardLeave(evt)
    self:record({
            cmdType = Track.CARD_LEAVE,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
        })
end

function Track:onCardSkillTriggerBegin(evt)
    self:record({
            cmdType = Track.CARD_SKILL_TRIGGER_BEGIN,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            skillId = evt.skill:id(),
        })
end

function Track:onCardSkillTriggerEnd(evt)
    self:record({
            cmdType = Track.CARD_SKILL_TRIGGER_END,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            skillId = evt.skill:id(),
        })
end

function Track:onCardEncounterSkill(evt)
    self:record({
            cmdType = Track.CARD_ENCOUNTER_SKILL,
            heroId = evt.card:heroId(),
            cardId = evt.card:id(),
            skillId = evt.skill:id(),
        })
end

function Track:start()
    self.Tracks_ = {}
end

function Track:record(cmd)
    table.insert(self.Tracks_, cmd)
end

function Track:finish()
    return self.Tracks_
end

return Track