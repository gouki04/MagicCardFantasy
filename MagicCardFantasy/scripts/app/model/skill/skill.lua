--[[
	@brief scripts/model/skill/skill.lua
]]
local Skill = class('Skill', cc.mvc.ModelBase)

Skill.TRIGGER_BEGIN_EVENT = "TRIGGER_BEGIN_EVENT"
Skill.TRIGGER_END_EVENT   = "TRIGGER_END_EVENT"

function Skill:ctor(properties)
	Skill.super.ctor(self, properties)
end

function Skill:init(id, lv)
	self.id_ = id
	self.lv_= lv
end

function Skill:destroy()
    
end

function Skill:name()
	return self.name_
end

function Skill:enter()
end

function Skill:leave()
end

function Skill:setCard(card)
	self.card_ = card
end

function Skill:card()
	return self.card_
end

function Skill:cardId()
    return self:card():id()
end

function Skill:hero()
    return self:card():hero()
end

function Skill:heroId()
    return self:hero():id()
end

function Skill:lv()
	return self.lv_
end

function Skill:id()
	return self.id_
end

function Skill:triggerBegin()
    self:dispatchEvent({name = Skill.TRIGGER_BEGIN_EVENT, skill = self})
end

function Skill:triggerEnd()
    self:dispatchEvent({name = Skill.TRIGGER_END_EVENT, skill = self})
end

function Skill:enterDeck(hero, card)
end

function Skill:leaveDeck(hero, card)
end

function Skill:enterHand(hero, card)
end

function Skill:leaveHand(hero, card)
end

function Skill:enterField(hero, card)
end

function Skill:leaveField(hero, card)
end

function Skill:enterGrave(hero, card)
end

function Skill:leaveGrave(hero, card)
end

return Skill