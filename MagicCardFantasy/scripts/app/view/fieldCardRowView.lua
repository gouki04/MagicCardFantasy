local FieldCardView  = import '.FieldCardView'

local FieldCardRowView = class('FieldCardRowView', function()
    return display.newNode()
end)

function FieldCardRowView:ctor(hero)
    self.cards_ = {}
    self.hero_ = hero
end

function FieldCardRowView:update()
    for i = 1, 10 do
        local card = self.cards_[i]
        if card then
            card:moveTo(0.5, i * (110 + 10), 0)
        end
    end
end

function FieldCardRowView:reorder()
    local field = self.cards_
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

    self:update()
end

function FieldCardRowView:addCard(cardId, cardTypeId, cardLv, idx)
    local fieldCardView = FieldCardView.new(self.hero_.id, cardId, cardTypeId, cardLv)
        :align(display.BOTTOM_LEFT, -110, 0)
        :addTo(self)

    self.cards_[idx] = fieldCardView
    self:update()
end

function FieldCardRowView:removeCard(cardId, idx)
    local card = self.cards_[idx]
    self.cards_[idx] = nil
    card:removeSelf()

    self:update()
end

function FieldCardRowView:getCard(cardId)
    for i, v in pairs(self.cards_) do
        if v:cardId() == cardId then
            return v
        end
    end
end

return FieldCardRowView