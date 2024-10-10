if true then return end

local globalv = nil
local globalmv = nil
local function dual(v, mv, f)
    f(v)
    f(mv)
end

--[[@param v videolib]]
hud.add(function (v)
    -- local n = sin(leveltime*ANG2)/6000
    -- local p = 1
    -- local mv = VWarp(v, {xorigin = 160*FU, xscale = FU + sin(leveltime*ANG2)/10, yoffset = 20*FU})
    local mv = VWarp(v, {xorigin = 160*FU, xscale = sin(leveltime*ANG2*3), yoffset = 20*FU})

    --  v.drawString(100, 0, 12, 0)
    --  v.drawString(100, 10, 12, V_REDMAP)
    --  v.drawString(100, 20, 12, V_ORANGEMAP)
    --  v.drawString(100, 30, 12, V_REDMAP|V_ORANGEMAP)
    -- mv.drawString(160, 0, 12, 0)
    -- mv.drawString(160, 10, 12, V_REDMAP)
    -- mv.drawString(160, 20, 12, V_ORANGEMAP)
    -- mv.drawString(160, 30, 12, V_REDMAP|V_ORANGEMAP)

    --[[@param d videolib]]
    dual(v, mv, function (d)
        d.drawNameTag(
            160, 20, "Hello",
            V_CENTERNAMETAG, SKINCOLOR_RED, SKINCOLOR_BLUE
        )
        d.drawScaledNameTag(
            160*FU, 70*FU,
            "Scaled", V_CENTERNAMETAG, FU/3,
            SKINCOLOR_RED, SKINCOLOR_BLUE
        )
        d.drawLevelTitle(
            160, 120,
            "Title", 0
        )
    end)

    --  v.drawPaddedNum(80, 60, n, p, V_REDMAP)
    -- mv.drawPaddedNum(80, 80, n, p)
end)

hud.add(function (v)
    hud.disable("lives")
    hud.disable("time")
    hud.disable("score")
    hud.disable("rings")
end)