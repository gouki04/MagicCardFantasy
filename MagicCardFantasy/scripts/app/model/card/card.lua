local CardDefine   = import '.cardDefine'
local Skill        = import '..skill.skill'
local SkillFactory = import '..skill.skillFactory'

local Card = class('Card', cc.mvc.ModelBase)

-- 定义事件
Card.BEFORE_ATTACK_TO_CARD_EVENT     = "BEFORE_ATTACK_TO_CARD_EVENT"
Card.AFTER_ATTACK_TO_CARD_EVENT      = "AFTER_ATTACK_TO_CARD_EVENT"
Card.COST_PHYSICAL_DAM_TO_CARD_EVENT = "COST_PHYSICAL_DAM_TO_CARD_EVENT"
Card.BEFORE_ATTACK_TO_HERO_EVENT     = "BEFORE_ATTACK_TO_HERO_EVENT"
Card.AFTER_ATTACK_TO_HERO_EVENT      = "AFTER_ATTACK_TO_HERO_EVENT"
Card.COST_PHYSICAL_DAM_TO_HERO_EVENT = "COST_PHYSICAL_DAM_TO_HERO_EVENT"
Card.BEFORE_DAM_EVENT                = "BEFORE_DAM_EVENT"
Card.AFTER_DAM_EVENT                 = "AFTER_DAM_EVENT"
Card.DIED_EVENT                      = "DIED_EVENT"
Card.ATK_CHANGED_EVENT               = "ATK_CHANGED_EVENT"
Card.HP_CHANGED_EVENT                = "HP_CHANGED_EVENT"
Card.ENTER_EVENT                     = "ENTER_EVENT"
Card.LEAVE_EVENT                     = "LEAVE_EVENT"
Card.SKILL_TRIGGER_BEGIN_EVENT       = "SKILL_TRIGGER_BEGIN_EVENT"
Card.SKILL_TRIGGER_END_EVENT         = "SKILL_TRIGGER_END_EVENT"
Card.CD_CHANGE_EVENT                 = "CD_CHANGE_EVENT"
Card.ADD_BUFF_EVENT                  = "ADD_BUFF_EVENT"
Card.REMOVE_BUFF_EVENT               = "REMOVE_BUFF_EVENT"
Card.ENCOUNTER_SKILL_EVENT           = "ENCOUNTER_SKILL_EVENT"

-- 定义属性
Card.schema = {}

Card.schema["id"]     = {"number"}
Card.schema["cardId"] = {"number"}
Card.schema["lv"]     = {"number"}
Card.schema["hero"]   = {"table"}

function Card:ctor(properties)
	Card.super.ctor(self, properties)

    self.info_ = CardDefine.getCardInfo(self.cardId_)
end

function Card:destroy()
    if self.skill_ then
        for k, v in pairs(self.skill_) do
            v:destroy()
        end
    end
end

function Card:notifySkillTriggerBegin(evt)
    self:dispatchEvent({name = Card.SKILL_TRIGGER_BEGIN_EVENT, card = self, skill = evt.skill})
end

function Card:notifySkillTriggerEnd(evt)
    self:dispatchEvent({name = Card.SKILL_TRIGGER_END_EVENT, card = self, skill = evt.skill})
end

function Card:skill()
    return self.skill_
end

function Card:addSkill(skill)
    skill:setCard(self)
    skill:addEventListener(Skill.TRIGGER_BEGIN_EVENT, self.notifySkillTriggerBegin, self)
    skill:addEventListener(Skill.TRIGGER_END_EVENT, self.notifySkillTriggerEnd, self)

    table.insert(self.skill_, skill)
end

function Card:initSkill()
    self.skill_ = {}

    for i = 1, #self.info_.skills do
        local skillinfo = self.info_.skills[i]
        if self.lv_ >= skillinfo.needLv then
            local skill = SkillFactory.createSkillById(skillinfo.id, skillinfo.lv)
            self:addSkill(skill)
        end
    end
end

function Card:id()
    return self.id_
end

function Card:cardId()
	return self.cardId_
end

function Card:lv()
	return self.lv_
end

function Card:hero()
    return self.hero_
end

function Card:heroId()
    return self:hero():id()
end

function Card:setHero(hero)
    self.hero_ = hero
end

function Card:star()
    return self.info_.star
end

function Card:cost()
    return self.info_.cost
end

function Card:name()
    return self.info_.name
end

function Card:race()
    return self.info_.race
end

function Card:notifySkill(funcName, ...)
    if self.skill_ then
        for i = 1, #self.skill_ do
            local skill = self.skill_[i]
            skill[funcName](skill, ...)
        end
    end
end

function Card:enterDeck(hero)
    self:notifySkill('enterDeck', hero, self)
end

function Card:leaveDeck(hero)
    self:notifySkill('leaveDeck', hero, self)
end

function Card:enterHand(hero)
	self:notifySkill('enterHand', hero, self)
end

function Card:leaveHand(hero)
    self:notifySkill('leaveHand', hero, self)
end

function Card:enterField(hero)
	self:notifySkill('enterField', hero, self)
end

function Card:leaveField(hero)
    self:notifySkill('leaveField', hero, self)
end

function Card:enterGrave(hero)
	self:notifySkill('enterGrave', hero, self)
end

function Card:leaveGrave(hero)
    self:notifySkill('leaveGrave', hero, self)
end

return Card