local HeroView = class('HeroView', function()
    return display.newNode()
end)

function HeroView:ctor(hero)
	self.heroId_ = hero.id

	self.hpLabel_ = ui.newTTFLabelWithShadow({
            text = string.format("hp:%s", 1000 + hero.lv * 70),
            size = 22,
            color = display.COLOR_WHITE,
            align = ui.TEXT_ALIGN_CENTER,
        })
		:align(display.CENTER)
        :addTo(self)
end

function HeroView:setHp(hp)
	self.hpLabel_:setString(string.format("hp:%s", hp))
end

function HeroView:heroId()
	return self.heroId_
end

return HeroView