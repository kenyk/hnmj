helper = {}

--执行
function helper.doCallback(callback, obj)
	if callback ~= nil then
		if obj ~= nil then
			callback(obj)
		else
			callback()
		end
	end
end

-- 遍历UI节点,返回指定名字的Node, 递归
function helper.findNodeByName(root, name)
    if not root.getChildByName then return nil end
    local res = root:getChildByName(name)
    if res then
        return res
    else
        local children = root:getChildren()
        for _, ch in pairs(children) do
            res = helper.findNodeByName(ch, name)
            if res then
                return res
            end
        end
    end
end

--获取文件名：res/ui/test.png返回test
function helper.getFileName(fileFullName)
    if not type(fileFullName) == "string" then return end
    return fileFullName:match(".+/(.+)%.%a+$")
end

--获取文件格式名：res/ui/test.png返回png
function helper.getExpandName(fileFullName)
    if not type(fileFullName) == "string" then return end
    return fileFullName:match(".+%.(%w+)$")
end

--去除扩展名：res/ui/test.png返回res/ui/test
function helper.stripExpandName(filePath)
    local idx = filePath:match(".+()%.%w+$")
    if(idx) then
        return filePath:sub(1, idx-1)
    else
        return filePath
    end
end

--获取文件路径：res/ui/test.png返回res/ui
function helper.stripPath(fileFullName)
    if not type(fileFullName) == "string" then return end
    return fileFullName:match("(.+)/[^/]*%.%w+$")
end

--添加文本下划线:颜色 大小
function helper.enableLinkLine(label, linkcolor, linksize)
    linkcolor = linkcolor or cc.c4b(255, 255, 255, 255)
    linksize = linksize or 1
    local linkLine = cc.LayerColor:create(linkcolor)
    linkLine:setAnchorPoint(cc.p(0.5, 0.5))
    linkLine:ignoreAnchorPointForPosition(false)
    linkLine:setContentSize(label:getContentSize().width, linksize)
    linkLine:setPosition(cc.p(label:getContentSize().width / 2, -1))
    label:addChild(linkLine)
end

--按钮状态灰和点击状态
function helper.setBtnState(btn, state)
    btn:setBright(state)
    btn:setTouchEnabled(state)
end

function helper.ReleaseResources()
    CCAnimationCache:destroyInstance()
    --cc.AnimationCache:purgeSharedAnimationCache()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    --    cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    --    cc.Director:getInstance():purgeCachedData()
end

--创建图片并返回宽度
function helper.createImage(resPath)
    helper.changeTextureFormat()
    local img = ccui.ImageView:create(resPath)
    helper.revertTextureFormat()
    local width = img:getContentSize().width
    local height = img:getContentSize().height
    return img, width, height
end

--创建9宫格图片
function helper.createScale9Image(resPath,size,capInsets)
    helper.changeTextureFormat()
    local mImgHightlighted = ccui.ImageView:create(resPath)
    helper.revertTextureFormat()
    mImgHightlighted:setScale9Enabled(true)
    mImgHightlighted:setContentSize(size)
    mImgHightlighted:setCapInsets(cc.rect(capInsets[1], capInsets[2], capInsets[3], capInsets[4]))
    return mImgHightlighted
end

--创建基础文本并返回宽度，高度
function helper.createText(str,fontSize,fontColor,fontName,outLineColor,outLineSize)
    fontSize = fontSize or 20
    fontColor = fontColor or display.COLOR_WHITE
    fontName = fontName or consts.FONT_NAME --"Arial"
	local text = ccui.Text:create()
	text:setString(str)
	text:setFontName(fontName)
--	text:setFontName(consts.FONT_NAME)
	text:setFontSize(fontSize)
	text:setColor(fontColor)
    if outLineColor then
        local color = cc.convertColor(outLineColor, "4b")
        text:enableOutline(color,outLineSize or 1)
    end
	local width = text:getContentSize().width
    local height = text:getContentSize().height
	return text, width, height
end

--数字转化成带万字符串：10万为基础,times为倍数
function helper.formatNumberToString(number,times)
    local num = number or 0
    local times = times or 1
    local yi = 100000000
    if number >= 100000 * times then
		if number >= yi then
			num  = string.format("%.2f",(number - number % 1000000)/yi) .. consts.Chinese.numberStr1
		else
			num = math.floor(number / 10000) .. consts.Chinese.numberStr2
		end
    end
	return num
end

--创建输入框
function helper.createEditBox(position, size, placeHolder)
    local editBoxBg = cc.Scale9Sprite:create()
    local editBox = cc.EditBox:create(size, editBoxBg)

    editBox:setTouchEnabled(true)
    editBox:setPosition(position)
    editBox:setFontColor(display.COLOR_WHITE)
    editBox:setFontSize(20)
    editBox:setFontName("font_UITextFieldTest")
    editBox:setLocalZOrder(10)
    editBox:setMaxLength(60)
    editBox:setPlaceHolder(placeHolder)
    editBox:setAnchorPoint(cc.p(0.5, 0.5))
    return editBox
end

function helper.convertTextFiledToEditBox(inputFiled,func)
    assert(inputFiled)
    local scaleX = inputFiled:getScaleX()
    local scaleY = inputFiled:getScaleY()
    local contentSize = cc.size(inputFiled:getContentSize().width * scaleX, inputFiled:getContentSize().height * scaleY)
    local position = cc.p(contentSize.width/2, contentSize.height/2)

    -- 新建个editBox 加在inputFiled上
    local bg = ccui.Scale9Sprite:create()
    local editBox = cc.EditBox:create(contentSize,bg)
    editBox:setPosition(position)
    editBox:setFontColor(cc.c3b(255,255,255))
    editBox:setFontSize(inputFiled:getFontSize())
    editBox:setMaxLength(inputFiled:getMaxLength())

    inputFiled:addChild(editBox)
    inputFiled:setString("")
    inputFiled:setTouchEnabled(false)

    local function editBoxTextEventHandle(eventType)
        if eventType == "began" then
            editBox:setText(inputFiled:getString())
        elseif eventType == "return" then
            inputFiled:setString(editBox:getText())
            editBox:setText("")
        end
        if func then func(eventType,inputFiled) end
    end
    editBox:registerScriptEditBoxHandler(editBoxTextEventHandle)

    return inputFiled
end

--将编辑器中的scroolView转化成自己创建的sv：编辑器中的滚动惯性有问题
function helper.convertScrollView(sv)
    if not sv then return end
    local scrollView = ccui.ScrollView:create()
    scrollView:setTouchEnabled(sv:isTouchEnabled())
    scrollView:setContentSize(sv:getContentSize())
    scrollView:setPosition(sv:getPosition())
    scrollView:setBounceEnabled(sv:isBounceEnabled())
    scrollView:setDirection(sv:getDirection())
    scrollView:addTo(sv:getParent())
    sv:hide()
    return scrollView
end

--图片灰色化：适用于Sprite 遍历子项
function helper.darkNodeAndChildren(node)
    function dark(root)
        local children = root:getChildren()
        for _, ch in pairs(children) do
--            print("dark(root)",ch:getDescription())
            helper.darkNode(ch)
            dark(ch)
        end
    end
    dark(node)
end
--图片灰色化：适用于Sprite
function helper.darkNode(node)
    local vertDefaultSource = [[
        attribute vec4 a_position;
        attribute vec2 a_texCoord;
        attribute vec4 a_color;

        #ifdef GL_ES
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
        #endif

        void main()
        {
            gl_Position = CC_PMatrix * a_position;
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }
    ]]
    local pszFragSource = [[
        #ifdef GL_ES
        precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        void main(void)
        {
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
            gl_FragColor.w = c.w;
        }

    ]]
    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

--取消灰色
function helper.cancleDarkNode(node)
    node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
end

--灰色Widget
function helper.darkWidget(widget)
    if widget and widget.getVirtualRenderer then
        widget:getVirtualRenderer():setState(1)
    end
end

--取消灰色Widget
function helper.cancelDarkWidget(widget)
    if widget and widget.getVirtualRenderer then
        widget:getVirtualRenderer():setState(0)
    end
end

--判断空字符串 如 空格
function helper.is_empty(str)
    return not string.match(str, "[^ \t]")
end

--去掉字符串两边空格
function helper.delEmpty(str)
    assert(type(str)=="string")
    return string.trim(str)
end

------------------------------------------------
-- 转换
------------------------------------------------

-- 转换json数据为lua数据
function helper.convertJsonToLua(path)
    local path = getFullPathForFilename(path)
    local content = cc.FileUtils:getInstance():getStringFromFile(path)
    local result = json.decode(content)
    return result
end

function helper.encodeATableToJsonAndSaveToPath(aTable, path)
    assert(aTable)
    assert(path)
    local file = io.open(path, "w+")
    if not file then --什么情况会是not file?? 文件不存在会自动创建
        return
    end
    local jsonStr = json.encode(aTable)
    file:write(jsonStr)
    file:close()
end
function helper.encodeATableToStringAndSaveToPath(aTable, path)

    assert(aTable)
    assert(path)

    local file = io.open(path, "w+")
    if not file then --什么情况会是not file?? 文件不存在会自动创建
    return
    end

    local str = helper.convertTableToString(aTable)

    file:write(str)
    file:close()
end

function helper.convertTableToString(aTable)
    if not aTable then return "nil" end
    if type(aTable) ~= "table" then return aTable end
    local numberType    = "number"
    local stringType    = "string"
    local tableType     = "table"
    local booleanType   = "boolean"
    local userdataType  = "userdata"
    local equalStr          = " = "
    local commaStr          = ","
    local leftBraceStr      = "{"
    local rightBraceStr     = "}"
    local leftBracketStr    = "["
    local rightBracketStr   = "]"
    local accentStr         = "'"
    local formatString      = "%q"
    local strParts = {}
    local function recursionFunc(aTable)
        table.insert(strParts, leftBraceStr)
        for k,v in pairs(aTable) do

            -- 拼接key--------------------------------

            -- number类型的key要加中括号
            if type(k) == numberType then
                table.insert(strParts, leftBracketStr)
                table.insert(strParts, tostring(k))
                table.insert(strParts, rightBracketStr)
                table.insert(strParts, equalStr)

                -- string类型的key直接加就行
            elseif type(k) == stringType then

                table.insert(strParts, leftBracketStr)
                table.insert(strParts, string.format(formatString, k))
                table.insert(strParts, rightBracketStr)
                table.insert(strParts, equalStr)

                -- 不支持其他类型的key
            else
                assert(false, "convertTableToString 不支持的key类型"..type(v))
            end

            -- 拼接value-------------------------------

            -- 表格类型, 递归
            if type(v) == tableType then
                recursionFunc(v)

                -- 数字
            elseif type(v) == numberType or type(v) == booleanType then
                table.insert(strParts, tostring(v))

                -- 字符串, 要在前后加'
            elseif type(v) == stringType  then
                table.insert(strParts, string.format(formatString, v))

                -- userdata 当做string处理
            elseif type(v) == userdataType then
                table.insert(strParts, string.format(formatString, tostring(v)))

                -- 其他格式, 不支持
            else
                assert(false, "convertTableToString 不支持的value类型"..type(v))
            end

            table.insert(strParts, commaStr)
        end

        table.insert(strParts, rightBraceStr)
    end

    recursionFunc(aTable)
    return table.concat(strParts)
end

function helper.convertStringToTable(content)
    return loadstring("return "..content)()
end

function helper.getStringFromFilePath(filePath)
    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    local content = cc.FileUtils:getInstance():getStringFromFile(fullPath)
    return content
end

function helper.printFight(...)
    if not CC_FIGHT_PRINT_ON_OFF then return end
    print(...)
end
function helper.dumpFight(...)
    if not CC_FIGHT_PRINT_ON_OFF then return end
    dump(...)
end

--灰态node：包括所有子节点中的sprite和ImageView,isTraverse 是否遍历子节点
function helper.setGray(node,isTraverse)
    if isTraverse == nil then isTraverse = true end
    local cType = tolua.type(node)
    if cType == "cc.Sprite" then
        helper.darkNode(node)
    elseif cType == "ccui.ImageView" then
        if node.getVirtualRenderer then
            node:getVirtualRenderer():setState(1)
        end
    elseif cType == "ccui.Button" then
        if node.getVirtualRenderer then
            node:getVirtualRenderer():setState(1)
        end
    end
    if isTraverse then
        if node.getChildren then
            for k, v in pairs(node:getChildren()) do
                helper.setGray(v)
            end
        end
    end
end

function helper.cancelGray(node)
    local cType = tolua.type(node)
    if cType == "cc.Sprite" then
        helper.cancleDarkNode(node)
    elseif cType == "ccui.ImageView" then
        if node.getVirtualRenderer then
            node:getVirtualRenderer():setState(0)
        end
    elseif cType == "ccui.Button" then
        if node.getVirtualRenderer then
            node:getVirtualRenderer():setState(0)
        end
    end
    if node.getChildren then
        for k, v in pairs(node:getChildren()) do
            helper.cancelGray(v)
        end
    end
end

local function getBeReplacedStr(str)
    local beReplacedStr = ""
    for i=1, string.len(str) do
        beReplacedStr = beReplacedStr.."*"
    end
    return beReplacedStr
end

-- 屏蔽字库
function helper.getScreeningMsg(msg)
    local isExistScreenChar = false
    for _, typeTB in ipairs(TB_screening) do
        for i, screeningStr in ipairs(typeTB.screening) do
            local isExist = string.find(msg, screeningStr)
            if isExist ~= nil then
                isExistScreenChar = true
                local beReplacedStr = getBeReplacedStr(screeningStr)
                msg = string.gsub(msg, screeningStr, beReplacedStr)
            end
        end
    end
    return isExistScreenChar, msg
end

--设置透明度
function helper.setNodeOpacity(node,opacity)
    local cType = tolua.type(node)
    if cType == "cc.Sprite" or cType == "ccui.ImageView" then
        node:setCascadeOpacityEnabled(true)
        node:setOpacity(opacity)
    end
    if node.getChildren then
        for k, v in pairs(node:getChildren()) do
            helper.setNodeOpacity(v,opacity)
        end
    end
end

--cc.c3b转化成<#AABBCC>格式（字符串）：在RichTextEx中使用
function helper.convertC3bToHex(color)
    if type(color) ~= "table" then return end
    --获取十六进制字符串：除0x后面的数字（取两位，即0A）
    local function getHexStr(num)
        local str = ""
        if num == 0 then
            str = "00"
        else
            local hex = string.format("%#x",num)    --十六进制：0xFF
            str = string.sub(hex,3)
            if string.len(str) <= 1 then
                str = "0" .. str
            end
        end
        return str
    end
    local str = "<#" .. getHexStr(color.r) .. getHexStr(color.g) .. getHexStr(color.b) .. ">"
    return str
end

local _changeRef = 0
local _oldFormat = -1
function helper.changeTextureFormat()
	if _changeRef == 0 then
	    -- 设置贴图格式为RBGA8888
    	_oldFormat = cc.Texture2D:getDefaultAlphaPixelFormat()
    	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	end
	_changeRef = _changeRef+1
end


function helper.revertTextureFormat()
	if _changeRef == 1 then
	    -- 恢复
	    cc.Texture2D:setDefaultAlphaPixelFormat(_oldFormat)
	end
	_changeRef = _changeRef-1
end

function helper.createRichLabel(params)
    local RichLabel = require("utils.richlabel.RichLabel")
    local data = params or {}
    local label=RichLabel.new {
            fontName    = "res/sfzht.ttf",
            fontSize    = data.fontSize or 25,
            fontColor   = data.fontColor or cc.c3b(255, 255, 255),
            maxWidth    = data.maxWidth or 600,
            lineSpace   = data.lineSpace or 15,
            charSpace   = data.charSpace or 0,
    }
    label:setAnchorPoint(cc.p(0.5, 0.5))
    return label
end

-- 网络回调返回是否正确
function helper.isCallbackSuccess(data)
    -- 默认显示
    return data.args.code == 0
end

function helper.getRealPos(chairid,myChaird,playerCount)
    local pos = 0
    if chairid >= myChaird then
        pos = chairid - myChaird + 1
    else
        pos = chairid + playerCount - myChaird + 1
    end
    if playerCount == 2 and pos == 2 then
        pos = 3
    elseif playerCount == 3 and pos == 3 then
        pos = 4
    end
    return pos
end

function helper.str2Color(str)
    str = string.gsub(str,"#","")
    return cc.c3b(tonumber(string.sub(str,1,2),16),
                 tonumber(string.sub(str,3,4),16),
                 tonumber(string.sub(str,5,6),16))
end

--名字过长 省略
function helper.nameAbbrev(name)
    if string.len(name) > 12 then
        return string.sub(name, 1, 12).."..."
    else
        return name
    end
end

--重新请求房卡
function helper.updateGameCard( callback )
    HttpServiers:getFunds(nil,  
        function(entity,response,statusCode)
            if entity  then
                UserData.userInfo.totalGameCard = entity.totalGameCard
                UserData.userInfo.surplusGameCard = entity.surplusGameCard
                --更新房卡
                local mainUI = UIMgr:getUI(consts.UI.mainUI)
                if(mainUI)then mainUI:updateCard()end
                if(callback)then callback()end
            end
        end)
end

--经纬度获取距离
function helper.distance_earth(lat1, lng1, lat2, lng2)
    local radLat1 = lat1 * math.pi / 180.0
    local radLat2 = lat2 * math.pi / 180.0
    local a = radLat1 - radLat2
    local b = lng1 * math.pi / 180.0 - lng2 * math.pi / 180.0
    local s = 2 * math.asin(math.sqrt(math.sin(a/2) * math.sin(a/2)  + math.cos(radLat1) * math.cos(radLat2) * math.sin(b/2) * math.sin(b/2)))
    s = s * 6378.137 * 1000
    --print(s)
    return s
end

--听牌算法版本数据转换
function v2ToV1Data(result)
    local newResult = {}
    for k,v in pairs(result) do
        table.insert(newResult, k)
    end
    table.sort(newResult)
    return newResult
end

return helper