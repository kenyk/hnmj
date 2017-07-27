--extend io module

local APPLICATION_FILE_PATH = consts.App.APP_FILE_PATH
local APPLICATION_PLATFORM = consts.App.APP_PLATFORM

function io.TouchDir(PathFile)
	local dirPath = PathFile
	local dirIndexB, dirIndexH = string.find(PathFile, "[^/]+[.]%a+$")
	if dirIndexB and dirIndexH then
		dirPath = string.sub(PathFile, 1, dirIndexB - 1)
	end
	if io.dirIsExist(dirPath) then
		return
	end

	local Start = 1
	while 1 do
		local TmpStart, TmpEnd = string.find(dirPath, "%/", Start)
		if TmpStart and TmpEnd then
			local Path = string.sub(PathFile, 1, TmpEnd)
			if not io.dirIsExist(Path) then
				io.createDir(Path)
			end
			Start = TmpEnd+1
		else
			break
		end
	end
end

function io.Error(msg)
--	if not _G.Debug then return end
	local path = "cache/error.log"
	if APPLICATION_PLATFORM ~= kTargetWindows then
		path = APPLICATION_FILE_PATH .. path
	end
	local msg = string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), msg)
	-- HttpServiceUtil.upLoadError(msg)
	io.AppendFile(path, msg)
end

function io.Log(filename, msg)
	-- if not _G.Debug then return end
	local path = "cache/" .. filename
	if APPLICATION_PLATFORM ~= kTargetWindows then
		path = APPLICATION_FILE_PATH .. path
	end
	local msg = string.format("[%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), msg)
	io.AppendFile(path, msg)
end

function io.Exists( path )
	local f = io.open(path, "r")
	return f ~= nil
end

--读取文件所有内容
function io.ReadFile(file)
	io.TouchDir(file)
	local fh, msg = io.open(file)
	if not fh then
		print(msg)
		return nil
	end
	local data = fh:read("*a")
	fh:close()
	return data
end

--向文件写入数据
function io.WriteFile(file, data)
	io.TouchDir(file)
	local fh, msg = io.open(file, "w")
	if not fh then
		print(msg)
		return nil
	end
	fh:write(data)
	fh:close()
	return true
end

--向文件追加数据
function io.AppendFile(file, data)
	io.TouchDir(file)
	print(" io.AppendFile(file, data)........................................................",file)
	local fh, msg = io.open(file, "a")
	if not fh then
		print(msg)
		return nil
	end
	print(" io.AppendFile(file, data)........................................................",data)
	fh:write(data)
	fh:close()
	return true
end

function io.checkDirOK( path )
    require "lfs"
    local oldpath = lfs.currentdir()


    if lfs.chdir(path) then
        lfs.chdir(oldpath)
        print("路径检查OK->"..path)
        return true
    end

    if lfs.mkdir(path) then
        print("路径创建OK->"..path)
        return true
    end
end


function io.writefileCheckDir(path, data)
    local pathinfo = io.pathinfo(path)
    if checkDirOK(pathinfo.dirname) then
        io.writefile(path, data)
        return true
    else
        

        if device.platform == "windows" then
            local newStr = string.gsub(pathinfo.dirname, "/", "\\")
            print("开始创建目录："..newStr)
            os.execute("mkdir "..newStr)
        else
            os.execute("mkdir -p "..pathinfo.dirname)
        end

        io.writefile(path, data)
        return true
    end

    print("写入完成:"..path)
end