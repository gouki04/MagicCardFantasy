--[[
	@brief scripts/model/damage.lua
]]
require 'utility/class'
require 'utility/delegate'

Damage = class()

DamageType_Physical = 1
DamageType_Magical = 2

function Damage:ctor(type, value, card)
	self.m_type = type
	self.m_value= value
	self.m_card = card
end

function Damage:init(type, value, card)
	self.m_type = type
	self.m_value= value
	self.m_card = card
end

function Damage:card()
	return self.m_card
end

function Damage:setValue(value)
	self.m_value = value
end

function Damage:value()
	return self.m_value
end

function Damage:type()
	return self.m_type
end