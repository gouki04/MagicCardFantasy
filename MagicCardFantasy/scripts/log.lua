--[[
	@brief log.lua
]]

local m_logFile = nil
local m_logFileName = 'log.txt'

local function init()
	m_logFile = io.open(m_logFileName, 'w+')
end

local function destroy()
	if m_logFile then
		m_logFile:close()
		m_logFile = nil
	end
end

local function write(...)
	if m_logFile then
		m_logFile:write(...)
		m_logFile:write('\n')
		m_logFile:flush()
	end
end

Log = {
	init = init,
	destroy = destroy,
	write = write,
}