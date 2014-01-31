local CardDefine   = import '.cardDefine'

local Card = class('Card', cc.mvc.ModelBase)

-- 定义事件
Card.BEFORE_ATTACK_EVENT     = "BEFORE_ATTACK_EVENT"
Card.AFTER_ATTACK_EVENT      = "AFTER_ATTACK_EVENT"
Card.COST_PHYSICAL_DAM_EVENT = "COST_PHYSICAL_DAM_EVENT"
Card.BEFORE_DAM_EVENT        = "BEFORE_DAM_EVENT"
Card.AFTER_DAM_EVENT         = "AFTER_DAM_EVENT"
Card.DIED_EVENT              = "DIED_EVENT"

-- 定义属性
Card.schema = {}

Card.schema["id"] = {"number"}
Card.schema["lv"] = {"number"}

function Card:ctor(properties)
	Card.super.ctor(self, properties)

    self.info_ = CardDefine.getCardInfo(self.id_)
end

function Card:id()
	return self.id_
end

function Card:lv()
	return self.lv_
end

function Card:hero()
    return self.hero_
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

function Card:toDeck(hero)
    if self.skill_ then
    	for i = 1, #self.skill_ do
            self.skill_[i]:toDeck(hero, self)
        end
    end
end

function Card:toHand(hero)
	if self.skill_ then
        for i = 1, #self.skill_ do
            self.skill_[i]:toHand(hero, self)
        end
    end
end

function Card:toField(hero)
	if self.skill_ then
        for i = 1, #self.skill_ do
            self.skill_[i]:toField(hero, self)
        end
    end
end

function Card:toGrave(hero)
	if self.skill_ then
        for i = 1, #self.skill_ do
            self.skill_[i]:toGrave(hero, self)
        end
    end
end

return Card