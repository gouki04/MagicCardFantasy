-- 避免内存泄露
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

table.remove_if = function(t, if_func)
	for i = 1, table.getn(t) do
		if if_func(t[i]) then
			table.remove(t, i)
			break
		end
	end
end

table.remove_all_if = function(t, if_func)
	local i = 1
	while t[i] ~= nil do
		if if_func(t[i]) then
			table.remove(t, i)
		else
			i = i + 1
		end
	end
end

table.find_if = function(t, if_func)
	for k, v in pairs(t) do
		if if_func(v) then
			return v
		end
	end
	return nil
end

table.exist_if = function(t, if_func)
	return table.find_if(t, if_func) ~= nil
end

table.count_if = function(t, if_func)
	local sum = 0
	for k, v in pairs(t) do
		if if_func(v) then
			sum = sum + 1
		end
	end
	return sum
end

table.count = function(t)
	local sum = 0
	for k, v in pairs(t) do
		if v then
			sum = sum + 1
		end
	end
	return sum
end

table.foreach_do = function(t, do_func)
	for k, v in pairs(t) do
		do_func(v)
	end
end

table.empty = function(t)
	for k, v in pairs(t) do
		if v ~= nil then
			return false
		end
	end
	return true
end

table.copy = function(ori_tab)
    if (type(ori_tab) ~= "table") then
        return nil
    end
    local new_tab = {}
    for i,v in pairs(ori_tab) do
        local vtyp = type(v)
        if (vtyp == "table") then
            new_tab[i] = table.copy(v)
        elseif (vtyp == "thread") then
            -- TODO: dup or just point to?
            new_tab[i] = v
        elseif (vtyp == "userdata") then
            -- TODO: dup or just point to?
            new_tab[i] = v
        else
            new_tab[i] = v
        end
    end
    return new_tab
end

math.fequal = function(f1, f2, e)
	e = e or 0.00001
	return math.abs(f1 - f2) < e
end

math.round = function(f)
	return math.floor(f + 0.5)
end
