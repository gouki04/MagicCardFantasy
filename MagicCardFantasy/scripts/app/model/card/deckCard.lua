local Card = import '.card'

local DeckCard = class('DeckCard', Card)

function DeckCard:ctor(properties)
    DeckCard.super.ctor(self, properties)
end

return DeckCard