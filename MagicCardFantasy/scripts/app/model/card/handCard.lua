local Card         = import '.card'
local CardDefine   = import '.cardDefine'
local SkillFactory = import '..skill.skillFactory'

local HandCard = class('HandCard', Card)

function HandCard:ctor(properties)
    HandCard.super.ctor(self, properties)

    if self.cardId_ ~= nil and self.lv_ ~= nil then
        self:init(self.cardId_, self.lv_)
    end
end

function HandCard:init(id, lv)
    self.cardId_ = id
    self.lv_ = lv

    self.cd_ = self.info_.cd

    -- 部分技能可以作用于手牌的卡，例如传送
    -- 而这时候部分防御技能可以发挥作用，如免疫
    -- 所以手牌的卡还是需要初始化其技能
    self.skill_ = {}
    for i = 1, #self.info_.skills do
        local skillinfo = self.info_.skills[i]
        if self.lv_ >= skillinfo.needLv then
            local skill = SkillFactory.createSkillById(skillinfo.id, skillinfo.lv)
            skill:setCard(self)
            
            table.insert(self.skill_, skill)
        end
    end
end

function HandCard:cd()
    return self.cd_
end

function HandCard:reduceCd()
    if self.cd_ >= 1 then
        self.cd_ = self.cd_ - 1
    end
end

return HandCard