
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
    self:enterScene("BattleScene", nil, "fade", 0.6, display.COLOR_WHITE)
end

return MagicCardFantasy
