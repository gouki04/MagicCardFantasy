--[[
	@brief skill/skill.lua
]]
require 'utility/class'
require 'utility/delegate'

Skill = class()

function Skill:ctor()
end

function Skill:init(id, lv)
	self.m_id = id
	self.m_lv= lv
end

function Skill:name()
	return self.m_name
end

function Skill:enter()
end

function Skill:leave()
end

function Skill:setCard(card)
	self.m_card = card
end

function Skill:card()
	return self.m_card
end

function Skill:lv()
	return self.m_lv
end

function Skill:id()
	return self.m_id
end