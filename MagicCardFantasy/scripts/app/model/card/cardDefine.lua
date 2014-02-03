--[[
	@brief scripts/model/card/cardDefine.lua
]]
local function getCardInfo(id)
	return db.card[id]
end

local CardDefine = {
	getCardInfo = getCardInfo,
}

return CardDefine