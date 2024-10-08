if true then return end

local MAXN = 7;

--[[@param v videolib]]
local function orbit(v, n)
    v.draw(160-4, 100-4, v.cachePatch("TEMER" + tostring((n%7)+1)))
    if n > 0 then
        local orbitspeed = (MAXN-n)+1
        if n % 2 then
            orbitspeed = -$
        end
        local settings = {
            xoffset = cos(leveltime*ANG1*orbitspeed)*18,
            yoffset = sin(leveltime*ANG1*orbitspeed)*18
        }
        orbit(VWarp(v, settings), n-1)
    end
end

hud.add(function (v)
    orbit(v, MAXN)
    hud.disable("lives")
    hud.disable("time")
    hud.disable("score")
    hud.disable("rings")
end)