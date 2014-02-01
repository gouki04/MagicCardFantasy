require 'utility.utility'

local Hero   = import '..model.hero.hero'
local Game   = import '..model.game'
local Record = import '..model.record'

local BattleScene = class("BattleScene", function()
    return display.newScene("BattleScene")
end)

function BattleScene:ctor()
    self.game_ = Game.new()
    self.record_ = Record.new()

    local hero1 = Hero.new({
            id = 1,
            name = 'a',
            lv = 20,
        })

    hero1:addCardToDeck(1, 1, 3)
    hero1:addCardToDeck(2, 2, 5)
    hero1:addCardToDeck(3, 3, 7)
    hero1:addCardToDeck(4, 1, 9)
    hero1:addCardToDeck(5, 2, 1)

    local hero2 = Hero.new({
            id = 2,
            name = 'b',
            lv = 18,
        })

    hero2:addCardToDeck(11, 2, 10)
    hero2:addCardToDeck(12, 2, 10)
    hero2:addCardToDeck(13, 3, 10)
    --hero2:addCardToDeck(1, 3)

    self.game_:start(hero1, hero2)
    self.game_:autoBattle()

    app.game = self.game_
    app.record = self.record_
end

function BattleScene:onEnter()
end

return BattleScene
