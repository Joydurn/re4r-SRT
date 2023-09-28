-- re4r srt overlay
-- original by resist56k
-- modified by JoydurnYup
--TO INSTALL: Install REFramework for RE4R, then put srt-overlay.lua in reframework/autorun folder

--ADJUST SCALE FOR GUI (experimental might cause unexpected visual bugs)
local scale=1

--ADJUST PERCENT true or false TO SHOW HP IN PERCENTAGE OR RAW VALUE
local percent=false





local ff, fw, fh


local function get_da()
    local z = sdk.get_managed_singleton("chainsaw.GameRankSystem")
    return tostring(z:call("get_GameRank"))
end

local function get_spinel()
    local z = sdk.get_managed_singleton("chainsaw.InGameShopManager")
    return tostring(z:call("get_CurrSpinelCount"))
end

da0Values={-5000,-4000,-3000,-2000,-1000,999,1999,2999,3999,4999,5999,6999,7999,8999,9999,10999}
local function get_Points()
    local z = sdk.get_managed_singleton("chainsaw.GameRankSystem")
    local ap = z:call("get_ActionPoint")
    local ip = z:call("get_ItemPoint")
    -- -- get total points and remove decimals
    local total = math.floor(ap + ip)
    
    -- get the index of the closest value in the table which is lower than total
    local index = 1
    for i=1,#da0Values do
        if math.abs(total - da0Values[i]) < math.abs(total - da0Values[index]) 
        and total > da0Values[i] then
            index = i
        end
    end
    closest = da0Values[index]
    -- get the difference between the closest value and the total
    local difference = total - closest

    -- create table of all relevant values to return
    local returnValues = {}
    returnValues["ap"] = ap
    returnValues["ip"] = ip
    returnValues["total"] = total
    returnValues["closest"] = closest
    returnValues["difference"] = difference
    return returnValues
end

local function get_killcount()
    local z = sdk.get_managed_singleton("chainsaw.GameStatsManager")
    return tostring(z:call("getKillCount"))
end

local function get_money()
    local z = sdk.get_managed_singleton("chainsaw.InventoryManager")
    z = tostring(z:call("get_CurrPTAS"))
    return z:reverse():gsub("...", "%1,", (#z - 1) // 3):reverse()
end

local function get_enemies()
    local z = sdk.get_managed_singleton("chainsaw.CharacterManager")
    local p = z:call("getPlayerContextRef")
    if p ~= nil then
        p = p:call("get_Position")
    end
    local a = z:call("get_EnemyContextList")
    local r = {}
    for i = 0, a:call("get_Count") - 1 do
        local x = a:call("get_Item", i)
        local h = x:call("get_HitPoint")
        local m = h:call("get_DefaultHitPoint")
        if m ~= 1 and h:call("get_IsLive") then
            table.insert(r, {
                h:call("get_CurrentDamagePoint"),
                m,
                (p - x:call("get_Position")):length(),
                h:call("get_CurrentHitPoint"),
                h:call("get_HitPointRatio")
            })
        end
    end
    table.sort(r, function(a, b)
        return a[1] > b[1] or (a[1] == b[1] and (a[2] > b[2] or
            (a[2] == b[2] and a[3] < b[3])))
    end)
    return r
end


function transformNumber(v)
    if v<0 then
        v=tostring(v)
        floor=math.ceil(v)
    else
        v=tostring(v)
        floor=math.floor(v)
    end
    difference=v-floor
    if difference==0 then
        return v
    else
        fullLength=string.len(v)
        floorLength=string.len(floor)
        
        decimal=string.sub(v,floorLength+1,fullLength)
        
        newDecimal=''
        i=1
        while true do
            local c = tostring(decimal:sub(i,i))
            newDecimal=newDecimal .. c
            if c~='0' and c~='.' then break
            end
            i=i+1
        end
        
        newNumber=floor..newDecimal
        return tostring(newNumber)
    end
end


d2d.register(function()
    

    ff = d2d.Font.new("Verdana", 20 * scale)
    _, fh = ff:measure("0123456789")
    fw = 0
    for i = 0, 9 do
        local x, _ = ff:measure(tostring(i))
        fw = math.max(fw, x)
    end
end, function()
    local sw, sh = d2d.surface_size()
    local x0 = 10 * scale
    local y1 = sh - 10 * scale
    local x1 = x0 + 20 * scale * fw
    local y0 = y1 - 10 * scale * fh
    d2d.fill_rect(x0, y0, x1 - x0 + 0.25 * fw, y1 - y0, 0x802e3440)

    local w, _ = ff:measure(m)
    d2d.text(ff, "ptas " .. get_money(), x0 + 0.5 * fw, y0, 0xffeceff4)
    
    local sp = "spin " .. get_spinel()
    w, _ = ff:measure(sp)
    d2d.text(ff, sp, x1 - w - 2.5 * fw, y0, 0xffeceff4)

    



    --1st column 3 rows
    local da = "rank " .. get_da()
    d2d.text(ff, da, x0 + 0.5 * fw, y0 + fh * 1, 0xffeceff4)

    local pointsTable = get_Points()
    i='ap'
    v = pointsTable[i]
    v = transformNumber(v)
    d2d.text(ff, 'ap' .. '    ' .. v, x0 + 0.5 * fw, y0 + fh * 3, 0xffeceff4)

    i='ip'
    v = pointsTable[i]
    d2d.text(ff, i .. '     ' .. v, x0 + 0.5 * fw, y0 + fh * 4 , 0xffeceff4)

    --2nd column 3 rows
    
    w, _ = ff:measure(kc)

    kc = "kills"
    w, _ = ff:measure(kc)
    d2d.text(ff, kc, x1 - w - 4.5 * fw, y0 + fh * 1, 0xffeceff4)
    local kc = get_killcount()
    d2d.text(ff, kc, x1 - w - 0.5* fw , y0+ fh, 0xffeceff4)

    i='total'
    v = pointsTable[i]
    w, _ = ff:measure(v)
    d2d.text(ff, v, x1 - w, y0 + fh * 3, 0xffeceff4)
    w, _ = ff:measure(i)
    d2d.text(ff, i, x1 - w - 4.5 * fw, y0 + fh * 3 , 0xffeceff4)

    i='difference'
    v = pointsTable[i]
    w, _ = ff:measure(v)
    d2d.text(ff, v, x1 - w, y0 + fh * 4, 0xffeceff4)
    i='dif'
    w, _ = ff:measure(i)
    d2d.text(ff, i, x1 - w - 4.5 * fw, y0 + fh * 4, 0xffeceff4)

   

    for i, x in ipairs(get_enemies()) do
        if i <= 5 then
            local s = tostring(x[4])
            w, _ = ff:measure(s)
            if percent then
                percent=tonumber(string.format("%.1f", tostring(x[5]*100))) .. '%'
                d2d.text(ff, percent, x1 - w-25, y0 + (4 + i) * fh, 0xffeceff4)
            else
                d2d.text(ff, s, x1 - w, y0 + (4 + i) * fh, 0xffeceff4)
            end
            local a0 = x0 + 0.5 * fw
            local b0 = y0 + (4.3 + i) * fh
            local a1 = x1 - x0 - 6 * fw
            local b1 = 0.4 * fh
            offset=25
            d2d.fill_rect(a0, b0, a1 * x[5] - offset, b1, 0xffa3be8c)
            d2d.outline_rect(a0, b0, a1 - offset, b1, 1, 0xff4c566a)
        end
    end
end)
