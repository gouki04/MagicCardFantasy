local HandCardView  = import '.HandCardView'

local HandCardRowView = class('HandCardRowView', function()
    return display.newNode()
end)

function HandCardRowView:ctor(hero)
    self.cards_ = {}
    self.hero_ = hero
end

function HandCardRowView:update()
    for i, v in ipairs(self.cards_) do
        v:moveTo(0.5, i * (110 + 10), 0)
    end
end

function HandCardRowView:addCard(cardId, cardTypeId)
    local handCardView = HandCardView.new(self.hero_.id, cardId, cardTypeId)
        :align(display.BOTTOM_LEFT, -110, 0)
        :addTo(self)

    table.insert(self.cards_, handCardView)
    self:update()
end

function HandCardRowView:removeCard(cardId)
    for i, v in ipairs(self.cards_) do
        if v:cardId() == cardId then
            table.remove(self.cards_, i)
            v:removeSelf()
            break
        end
    end

    self:update()
end

function HandCardRowView:getCard(cardId)
    for i, v in pairs(self.cards_) do
        if v:cardId() == cardId then
            return v
        end
    end
end

return HandCardRowView