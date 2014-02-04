local Buff = class('Buff', cc.mvc.ModelBase)

function Buff:ctor(properties)
    Buff.super.ctor(self, properties)
end

function Buff:canEnter()
    if self.canEnter_ == nil then
        self.canEnter_ = true
    end

    return self.canEnter_
end

function Buff:canAttack()
    if self.canAttack_ == nil then
        self.canAttack_ = true
    end

    return self.canAttack_
end

function Buff:name()
    return self.name_
end

function Buff:setCard(card)
    self.card_ = card
end

function Buff:enter(defend, dcard)
end

function Buff:leave(defend, dcard)
    if self.once_ == true then
        self.card_:removeBuff(self)
    end
end

function Buff:type()
    return self.type_
end

function Buff:lv()
    return self.lv_
end