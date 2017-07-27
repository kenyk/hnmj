--
-- Author: LXL
-- Date: 2016-11-07 10:01:24
--

local data = {
	{{1,0},{1,0,0},{0,1,0},{1,0,0,0},{1,1,1},{0,0,0},"转转麻将"},
	{{1,0},{1,0,0},{0,0,0},{0,0,0,0},{0,0,0},"长沙麻将"},
	{{1,0},{1,0,0},{0,1,0},{0,0,0,0},{0,0,0},"郴州麻将"},
	{{1,0},{1,0,0},{1,0,0},{0,0,0,0},{1,0,0},"红中麻将"},
	{{1,0},{1,0,0},{0,0,0},{1,0,0},{0,0,0},"宁乡麻将"},
	{{1,0},{1,0,0},{0,0,0},{1,0,0},{0,0,0},"常德麻将"},
}

if nil == LocalData.data.clearCreateRoomData then
	LocalData.data.clearCreateRoomData = true
	LocalData.data.createRoomData = nil
end

if nil == LocalData.data.clearCreateRoomData2 then
	LocalData.data.clearCreateRoomData2 = true
	LocalData.data.createRoomData = nil
end

LocalData.data.createRoomData = LocalData.data.createRoomData or data

for k,v in pairs(data) do
	LocalData.data.createRoomData[k] = LocalData.data.createRoomData[k] or v
end

-- dump(LocalData.data.createRoomData,"LocalData.data.createRoomData get")

return LocalData.data.createRoomData