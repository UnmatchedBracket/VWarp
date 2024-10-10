-- if true then return end

local s = 0
local START_TICK = 24*TICRATE
local START_OFFSET = 0

local EXPECTED_TIMESCALE = 3
START_TICK = $ * EXPECTED_TIMESCALE

local DEBUG = false

local RANDOMSHIFT = {0, -16, 44, -38, 14, -20, -20, 46, 14, 11, -39, -40}
local RANDOMY = {12, 67, 76, 28, 46, 96, 14, 77, 7, 4, 43, 62}

local INTROLEN = FU*24

local beatsfx1 = sfx_s3k5f
local beatsfx2 = sfx_radio
local specialbinks = {
    el = {sfx_pop},
    [11] = {beatsfx1, beatsfx2},
    [12] = {beatsfx1, beatsfx2},
    [13] = {beatsfx1, beatsfx2},
}
local binked = {}
local function bink(id)
    if not binked[id] then
        binked[id] = true
        local sounds = specialbinks[id] or {sfx_radio}
        for _, v in pairs(sounds) do
            S_StartSound(nil, v)
        end
    end
end

--[[@param v videolib]]
local function intro(v, beat)
    beat = $ + INTROLEN
    local nbeat = (FixedFloor(beat)/FU)
    local subbeat = beat - FixedFloor(beat)

    if beat < 0 then
        binked = {}
        v.drawNum(150, 100, beat)
        return
    end

    if nbeat < 20 or (nbeat < 21 and subbeat < FU/2) then
        v.drawString(
            160, ease.outcubic(min(beat, FU), -20, 20),
            "Let's say you've got a nice HUD element.", V_ALLOWLOWERCASE, "center"
        )
        if subbeat > 10000 then
            bink(1)
        end
        if nbeat >= 4 then
            v.drawString(
                160, 30,
                "But wait! You wanted to move it dynamically.", V_ALLOWLOWERCASE, "thin-center"
            )
            bink(2)
        end
        if nbeat >= 8 then
            v.drawString(
                160, 40,
                "Or maybe make it squish under certian conditions?", V_ALLOWLOWERCASE, "thin-center"
            )
            bink(3)
        end
        if nbeat >= 13 then
            v.drawString(
                160, 60,
                "Oh, but that's going to be such a pain.", V_ALLOWLOWERCASE, "thin-center"
            )
            bink(4)
            local complaints = {
                "Have to add something to every coordinate...",
                "Need to squish every element individually...",
                "And also calculate how to position those to match up?",
                "What do you MEAN drawNum doesn't support fixed-point?",
                "And you can't scale strings?",
                "Negative scale errors? Shouldn't it just flip?"
            }
            if nbeat >= 16 then
                local prog = 2*(beat-(FU*16))/9
                -- print(prog)
                prog = #complaints*ease.insine(prog)/FU+1
                for i=1,prog do
                    v.drawString(
                        160+RANDOMSHIFT[i], 70+RANDOMY[i],
                        complaints[i], V_ALLOWLOWERCASE, "thin-center"
                    )
                    bink(100+i)
                end
            end
        end
    else
        local titlewarp = VWarp(v, {xscale = 2*FU, yscale=2*FU, xorigin = 160*FU})
        if nbeat >= 21 then
            titlewarp.drawString(160, 10, "HAVE I GOT", 0, "center")
            bink(11)
        end
        if nbeat >= 22 then
            titlewarp.drawString(160, 20, "THE LIBRARY", 0, "center")
            bink(12)
        end
        if nbeat >= 23 then
            titlewarp.drawString(160, 30, "FOR YOU", 0, "center")
            bink(13)
        end
    end
end

--[[@param v videolib]]
local function orbit(v, dat)
    local emeraldcount = max(0, 6-dat.logostage)
    local spin = dat.spin * 360

    v.draw(152, 94, v.cachePatch("CHAOS3"))
    local emid = 3
    local chainv = v
    if emeraldcount > 0 then
        for i=1,emeraldcount do
            local orbitspeed = i+1
            if i % 2 then
                orbitspeed = -$
            end
            local settings = {
                xoffset = cos(FixedAngle(spin)*orbitspeed)*FixedMul(28, dat.spread),
                yoffset = sin(FixedAngle(spin)*orbitspeed)*FixedMul(28, dat.spread),
                xorigin = 160*FU,
                yorigin = 100*FU,
                xscale = 11*FU/12,
                yscale = 11*FU/12
            }
            chainv = VWarp(chainv, settings)
            chainv.draw(152, 94, v.cachePatch("CHAOS" + tostring((emid%7)+1)))
            emid = $ + 1
        end
    end

    if dat.logostage >= 8 then
        v.drawLevelTitle(152, 94, "V")
    end
    if dat.logostage >= 9 then
        local logowarp = VWarp(v, {
            xscale = FU/2,
            yscale = FU/2,
            xorigin = 160*FU,
            yorigin = 100*FU
        })
        logowarp.drawLevelTitle(176, 106, "W")
        logowarp.drawLevelTitle(196, 106, "ARP")
        v.drawString(178, 130, "Easy HUD warping library for SRB2", V_ALLOWLOWERCASE, "thin-center")
    end

    if DEBUG then
        v.drawNum(160, 140, dat.logostage)
    end
end

--[[@param rv videolib]]
hud.add(function (rv)
    hud.disable("lives")
    hud.disable("time")
    hud.disable("score")
    hud.disable("rings")
    hud.disable("stagetitle")

    if leveltime < 2 then return end

    local beat = FixedMul((leveltime - START_TICK + START_OFFSET)*FU/EXPECTED_TIMESCALE, 3995) -- this magic number converts tics to beats
    -- if beat < FU then beat = -FU+1 end
    -- print((beat/FU*10) + (beat%FU)/6554)

    local nbeat = (FixedFloor(beat)/FU)
    local subbeat = beat - FixedFloor(beat)

    --[[@type WarpSettings]]
    local settings = {
        xorigin = 160*FU,
        yorigin = 100*FU
        -- transp = ((-cos((beat%FU)*35000)+FU)*5+(FU/2))/FU
    }

    --[[@type WarpSettings?]]
    local gemsettings = nil
    --[[@type WarpSettings?]]
    local boxsettings = nil
    local orbitMode = nil
    local header = ""

    if nbeat < 0 then
        local intro_nbeat = nbeat + INTROLEN/FU
        local intro_beat = beat + INTROLEN
        if intro_nbeat >= 14 and intro_nbeat < 20 then
            settings.transp = min(7, 5*(intro_beat-(14*FU))/FU/3)
        elseif intro_nbeat >= 14 and intro_nbeat < 21 then
            settings.transp = min(7, 14*((21*FU)-intro_beat)/FU)
        end
    elseif nbeat == 0 then
        header = "We got"
        local wiggle = 0
        if subbeat < 2*FU/3 then
            wiggle = ease.outquart(subbeat*2/3)
        else
            wiggle = ease.outquint(((FU-subbeat)*3))
        end
        settings.xscale = FU + wiggle/2
        settings.yscale = FU + wiggle/3
        settings.transp = wiggle*4/FU
    elseif nbeat <= 2 then
        header = "SCALING"
        settings.xscale = FU + sin(FixedAngle(beat-FU)*360)/2
        settings.yscale = FU + sin(FixedAngle(beat-FU)*180)/4
    elseif nbeat <= 4 then
        header = "MOVING"
        local seqbeat = beat - (FU*3)
        local chastart = seqbeat/(FU/2)*(FU/2)
        if chastart > FU then
            if seqbeat > (3*FU/2) then
                chastart = FU+(seqbeat-(3*FU/2))*2
            else
                chastart = FU
            end
        end
        local cha = seqbeat - chastart
        local chatarget = 45*FU
        if seqbeat >= (FU/2) and seqbeat < FU then
            chatarget = -$
        end

        settings.xoffset = FixedMul(chatarget, FixedSqrt(FixedSqrt(cha)))
    elseif nbeat <= 6 then
        header = "NEGATIVE X SCALE"
        settings.xscale = cos((FixedAngle(beat-FU)*180) - ANG60)*2
    elseif nbeat <= 8 then
        header = "TRANSPARENCY"
        local seqbeat = beat - (FU*7)
        local fac = FU-sin(FixedAngle(seqbeat)*90)
        settings.xscale = fac
        settings.yscale = fac
        settings.transp = (10-(fac/6553))
    elseif nbeat <= 12 then
        header = "It can chain too!"
        local seqbeat = beat - (FU*9)
        local fac = sin(FixedAngle(seqbeat)*45)
        settings.xscale = FU+fac
        settings.yscale = FU+fac/2
        local spin = FixedAngle(seqbeat)*360
        gemsettings = {
            xoffset = FixedMul(sin(spin), fac*40),
            yoffset = FixedMul(cos(spin), fac*40)
        }
    else
        local seqbeat = beat - (FU*13)
        local fac = ease.outquint(min(seqbeat, FU-1), FU, 1)
        boxsettings = {
            xscale = fac,
            yscale = fac,
            xorigin = 160*FU,
            yorigin = 100*FU
        }
        local spin = 0
        if seqbeat >= (FU/2) and seqbeat < 4*FU then
            spin = 2*(seqbeat-(FU/2))/7
        end
        local logostage = 0
        local beatpoints = {6, 10, 14, 18, 20, 22, 24, 28, 32}
        local currentoutro = 8*(beat - (FU*17))/FU
        for _, v in pairs(beatpoints) do
            if currentoutro >= v then
                logostage = $ + 1
            end
        end

        if logostage < 7 then
            settings.xscale = (FU+fac)/2
            settings.yscale = (FU+fac)/2
        else
            settings.xoffset = -18*FU
            if logostage == 9 then
                settings.yoffset = -8*FU
            end
        end
        
        orbitMode = {
            spread = ease.inoutcubic(min(seqbeat*2, FU)),
            spin = spin,
            logostage = logostage
        }
    end
    local v = VWarp(rv, settings)
    local bv = v
    if boxsettings then
        bv = VWarp(v, boxsettings)
    end
    local gv = v
    if gemsettings then
        gv = VWarp(v, gemsettings)
    end
    -- print(settings.transp)

    if orbitMode and orbitMode.logostage >= 9 then
        bv.fadeScreen(31, 10)
    end

    if nbeat >= 2-INTROLEN/FU then
        bink("el")
        bv.draw(145, 120, v.cachePatch("EMBOX3"))
        bv.drawString(160, 80, "EMERALD GET!", 0, "center")
        if orbitMode then
            orbit(gv, orbitMode)
        else
            gv.draw(152, 94, v.cachePatch("CHAOS3"))
        end
    end

    if nbeat < 0 then
        intro(rv, beat)
    end

    local titlewarp = VWarp(rv, {xscale = 2*FU, yscale=2*FU, xorigin = 160*FU})
    titlewarp.drawString(160, 10, header, V_ALLOWLOWERCASE, "center")

    --[[
    local code = 'v.draw(145, 120, EMBOX3)\n'
    code = $ .. 'v.draw(152, 94, CHAOS3)\n'
    code = $ .. 'v.drawString(160, 80, "EMERALD GET!", 0, "center")'

    local codesettings = {
        xscale = FU/2,
        yscale = FU/2
    }
    v = VWarp(rv, codesettings)
    -- print(code)
    code = code:gsub("&G", "\x83"):gsub("&B", "\x84"):gsub("&R", "\x85"):gsub("&-", "\x80")
    -- print(code)
    -- v.drawString(10, 40, code, V_ALLOWLOWERCASE, "thin")

    ]]

    if DEBUG then
        v = VWarp(rv, {
            xscale = FU/2,
            yscale = FU/2,
            xorigin = 160*FU,
            yorigin = 200*FU
        })
        v.drawFill(0, 190, 320, 10, 31)
        v.drawFill(0, 190, FixedMul(320, subbeat), 10, 149)
        v.drawString(160, 190, nbeat, 0, "center")
    end
end)

addHook("ThinkFrame", function ()
    if leveltime < START_TICK-2 then
        S_StopMusic()
    end
    if leveltime == START_TICK-1 then
        -- BPM is 128
        -- S_ChangeMusic("chacha", false, nil, 0, 172100)
        S_ChangeMusic("chchch", false, nil, 0, (1000*START_OFFSET)/TICRATE)
    end
    -- if consoleplayer.cmd.sidemove then
    --     s = $ + consoleplayer.cmd.sidemove*FU/150
    --     print(s/FU)
    -- end
    if consoleplayer and consoleplayer.valid and consoleplayer.mo then
        consoleplayer.mo.spritexoffset = 999*FU
        consoleplayer.mo.shadowscale = 0
    end
end)