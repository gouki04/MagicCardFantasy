
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")

local MagicCardFantasy = class("MagicCardFantasy", cc.mvc.AppBase)

function MagicCardFantasy:ctor()
    MagicCardFantasy.super.ctor(self)
    self.objects_ = {}
end

function MagicCardFantasy:run()
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    -- display.addSpriteFramesWithFile(GAME_TEXTURE_DATA_FILENAME, GAME_TEXTURE_IMAGE_FILENAME)

    self:enterBattleScene()
end

function MagicCardFantasy:enterBattleScene()
    -- 配置双方的牌堆
    local hero1 = {
        id = 1,
        name = 'a',
        lv = 20,
        deck = {
            [1] = {id = 56, lv = 3},
            [2] = {id = 106, lv = 5},
            [3] = {id = 26, lv = 7},
            [4] = {id = 56, lv = 9},
            [5] = {id = 106, lv = 1},
        }
    }

    local hero2 = {
        id = 2,
        name = 'b',
        lv = 18,
        deck = {
            [11] = {id = 106, lv = 10},
            [12] = {id = 106, lv = 10},
            [13] = {id = 26, lv = 10},
        }
    }

    self:enterScene("BattleScene", {hero1, hero2}, "fade", 0.6, display.COLOR_WHITE)
end

return MagicCardFantasy
