local Log = require 'log'

local Skill = import '.skill'

Skill_fu_huo = class('Skill_fu_huo', Skill)

function Skill_fu_huo:ctor(properties)
    Skill_fu_huo.super.ctor(self, properties)
    
    self.name_ = '复活'
end

function Skill_fu_huo:enter(defend, dcard)
    local hero = self.card_:hero()
    local grave = hero:grave()

    local cnt = table.nums(grave)
    if cnt > 0 then
        local i = 1
        local selectCard = nil
        for _, card in pairs(grave) do
            -- 检查该卡是否有复活技能
            local skills = card:skill()
            for _, skill in pairs(skills) do
                if 
            end

            local rate = i / cnt
            if math.random(0, 1) <= rate then
                selectCard = card
                break
            else
                i = i + 1
            end
        end

        if selectCard then
            selectCard:encounterSkill(self)
            
            hero:removeCardFromGrave(selectCard)
            hero:addCardToField(selectCard)
        end
    end 
end

return Skill_fu_huo