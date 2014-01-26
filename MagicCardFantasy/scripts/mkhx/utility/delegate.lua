--[[
	lua下事件委托

	用法：
	local function p(a,b)           -- 测试函数1
		print(a,b)
	end

	local function p2(a)            -- 测试函数2
		print(a * 20)
	end

	local event = delegate:new()	-- 创建委托

	-- 第一种写法
	event:regist(p, true)			-- 注册p，单一回调
	event:regist(p2)				-- 注册p2，永久回调
	event:call(1,2)	 				-- 触发事件，打印1 2 20
	event:unregist(p2)				-- 反注册p2

	-- 第二种写法
	event = event + p + p2			-- 注册p，p2，永久回调（用加号只能添加永久回调）
	event(1,2)	 					-- 触发事件（直接用括号以函数形式调用）
	event = event - p2				-- 反注册p2
]]--
delegate = {

}

function delegate:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function delegate:regist(func, once, check_func)
	if func == nil then return end
	
	once = once or false

	for i = 1, #self do
		if self[i][1] == func then
			self[i][2] = once
			self[i][3] = check_func
			return
		end
	end

	table.insert(self, {func, once, check_func})
end

function delegate:registOnce(func, check_func)
	self:regist(func, true, check_func)
end

function delegate:unregist(func)
	if func == nil then return end

	local i = 1
	while self[i] ~= nil do
		if self[i][1] == func then
			table.remove(self, i)
		else
			i = i + 1
		end
	end
end

function delegate:call(...)
	local i = 1
	while self[i] ~= nil do
		local check_func = self[i][3]
		if check_func == nil or check_func(unpack(arg)) then
			self[i][1](unpack(arg))

			if self[i][2] == true then
				table.remove(self, i)
			else
				i = i + 1
			end
		else
			i = i + 1
		end
	end
end

function delegate:__add(func)
	self:regist(func)
	return self
end

function delegate:__sub(func)
	self:unregist(func)
	return self
end

function delegate:__call(...)
	self:call(unpack(arg))
end
