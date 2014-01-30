--[[
	@brief log.lua
]]

local logFile_ = nil
local logFileName_ = 'log.txt'

local Log = class('Log')

function Log.init()
	logFile_ = io.open(logFileName_, 'w+')
end

function Log.destroy()
	if logFile_ then
		logFile_:close()
		logFile_ = nil
	end
end

function Log.write(...)
	if logFile_ then
		logFile_:write(...)
		logFile_:write('\n')
		logFile_:flush()
	end
end

return Log