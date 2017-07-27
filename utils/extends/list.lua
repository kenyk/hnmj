
local list = {count = 0}

function list:new()
    return clone(self)
end

function list:add(value)
	if self.max and self.count >= self.max then
		self:remove(1)
	end
	self[self.count + 1] = value
	self.count = self.count + 1
end

function list:insert(index, value)
    if index > self.count or index < 0 then
        return
    else
        for i = self.count, index, -1  do
            self[i + 1] = self[i]
        end
        self.count = self.count + 1
        self[index] = value
    end
end

function list:remove(index)
    if index > self.count then
        return
    else
        for i = index, self.count - 1 do
            self[i] = self[i + 1]
        end
        self.count = self.count - 1
        self[self.count + 1] = nil
    end
end

--if remove the value then return true, didn't exist return false
function list:removeValue(value)
    for i = 1, self.count do
        if value == self[i] then
            self:remove(i)
            return true
        end
    end
    return false
end

function list:get_count()
    return self.count
end

function list:reset()
    for i = 1, self.count do
        self[i] = nil
    end
    self.count = 0
end

function list:setmax(value)
	self.max = tonumber(value)
end

return list