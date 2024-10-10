-- if true then return end

local VWarp = dofile("VWarp")

hud.add(function (v)
    -- within a HUD hook
    local warpv = VWarp(v, {
        -- x/yscale set how much to stretch the element  (default FU,FU (no scaling))
        xscale = FU*2,
        yscale = FU/2,
        -- x/yorigin set what point to scale the element around (default 0,0 (upper left))
        xorigin = 160*FU,
        yorigin = 100*FU,
        -- x/yoffset determine how much the element is shifted, independent of scale (default 0,0 (no movement))
        xoffset = 130*FU,
        yoffset = -50*FU
    })
    warpv.drawString(20, 120, "Wow, it's a\x83 string!")
    warpv.draw(30, 160, warpv.cachePatch("CHAOS4"))
end)