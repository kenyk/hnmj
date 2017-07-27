require "TingpaiHelperV2"
function v2ToV1Data(result)
    local newResult = {}
    for k,v in pairs(result) do
        table.insert(newResult, k)
    end
    table.sort(newResult)
    return newResult
end
--qidui1 癞子不能当万能牌
--qidui2 癞子能当万能牌

-- local cards = {45, 12, 12, 12, 13, 13, 14, 16, 16, 21, 26, 27, 25}
-- local cards = {45, 45, 45, 13, 14, 16, 22, 23, 34, 35, 36, 37, 38}
-- local cards = {11, 11, 13, 13, 18, 18, 21, 21, 26, 26, 31, 31, 35}
-- local cards = {26, 26, 26, 36, 37, 37, 38, 38, 39, 45}
local cards = {45, 25, 25, 26, 26, 26, 36, 37, 37, 38, 38, 39, 39}
local ret = getAllting(cards, {qidui2 = true}, 45)
-- local ret = getAllting(cards, {}, 45)
print_r(ret)