--
-- Author: LXL
-- Date: 2016-11-17 16:33:06
--

function sumhexa(k)
	local k = md5.sum(k)
	return (string.gsub(k, ".", function (c)
				return string.format("%02x", string.byte(c))
	end))
end

local md5 = require "md5"
local NetSprite = {}

--传入图片url和默认图片路径 (默认图片必须传入)
function NetSprite:getSpriteUrl(url,defaultImage)
	local default = defaultImage or "Default/ImageFile.png"
	local image = MyExtend.WPNetSprite:create(default)
	local imageName = sumhexa(md5.sum(url))..".png"
	image:setFullImageUrl(url,imageName);
	return image
end

return NetSprite