--[[
	@brief scripts/model/damage.lua
]]
local Damage = class('Damage', cc.mvc.ModelBase)

Damage.eType = {
	Physical = 1,
	Magical = 2,
}

-- 定义属性
Damage.schema = {}

Damage.schema["type"] = {"number"}
Damage.schema["value"] = {"number"}

function Damage:ctor(properties)
	Damage.super.ctor(self, properties)
end

function Damage:source()
	return self.src_
end

function Damage:target()
	return self.trg_
end

function Damage:setValue(value)
	self.value_ = value
end

function Damage:value()
	return self.value_
end

function Damage:type()
	return self.type_
end

return Damage