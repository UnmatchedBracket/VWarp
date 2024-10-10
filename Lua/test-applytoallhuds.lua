-- if true then return end
local VWarp = dofile("VWarp")

local cachev = nil

local tick = 0
local function addarea(type)
    hud.add(function (v)
        tick = $ + 1
    end, type)
end
addarea("game")
addarea("scores")
addarea("title")
-- addarea("titlecard")
addarea("intermission")

local oldHudAdd = hud.add
local myHudAdd = function (func, area)
    --[[@param v videolib]]
    oldHudAdd(function (v, a, b, c)
        if cachev == nil then
            cachev = VWarp(v, {xorigin = 160*FU, yorigin = 100*FU})
        end
        local xs = sin(tick*ANG2*3)/8 + 7*FU/8
        local ys = cos(tick*ANG2*3)/8 + 7*FU/8
        xs = FU
        ys = FU
        local jiggle = ((displayplayer and displayplayer.valid and displayplayer.speed) or 0)/8
        cachev.settings.xscale = xs
        cachev.settings.yscale = ys
        -- cachev.settings.xoffset = 160*FU - FixedMul(160*FU, xs)+v.RandomRange(-jiggle, jiggle)
        -- cachev.settings.yoffset = 100*FU - FixedMul(100*FU, ys)+v.RandomRange(-jiggle, jiggle)
        cachev.settings.xoffset = v.RandomRange(-jiggle, jiggle)
        cachev.settings.yoffset = v.RandomRange(-jiggle, jiggle)
                                                             --+cos(leveltime*ANG2*6)*10
        return func(cachev, a, b, c)
    end, area)
end
rawset(hud, "add", myHudAdd)

local oldAddHook = addHook
rawset(_G, "addHook", function (hooktype, func, a, b, c)
    if hooktype == "HUD" then
        myHudAdd(func, a)
    else
        oldAddHook(hooktype, func, a, b, c)
    end
end)