local Card = import '.card'

local GraveCard = class('GraveCard', Card)

function GraveCard:ctor(properties)
    GraveCard.super.ctor(self, properties)
end

return GraveCard