-------------------------------
-- VWarp by UnmatchedBracket --
-------------------------------
--     A library to make     --
--    moving/scaling HUD     --
--     elements easier.      --
-------------------------------

-- NOTE: VWarp relies on CustomHUD for strings,
 -- and therefore does not support these flags:
   -- V_6WIDTHSPACE, V_OLDSPACING, V_MONOSPACE
 -- But really, you shouldn't be using those anyway.

-- defined here, filled out later
local vwarpcustomhud = {}

local function def(modv, truev, key)
    modv[key] = truev[key]
end

local function iif(cond, tru, fals)
    if cond then return tru else return fals end
end

local align_nonfixed2fixed = {
    ["left"]              = "fixed",
    ["center"]            = "fixed-center",
    ["right"]             = "fixed-right",
    ["small"]             = "small-fixed",
    ["small-center"]      = "small-fixed-center",
    ["small-right"]       = "small-fixed-right",
    ["thin"]              = "thin-fixed",
    ["thin-center"]       = "thin-fixed-center",
    ["thin-right"]        = "thin-fixed-right",
    ["small-thin"]        = "small-thin-fixed",
    ["small-thin-center"] = "small-thin-fixed-center",
    ["small-thin-right"]  = "small-thin-fixed-right",
}

--[[ align, scale, font ]]
local align_propertymap = {
    ["fixed"]                   = {"left",  FU,   "STCFN"},
    ["fixed-center"]            = {"center",FU,   "STCFN"},
    ["fixed-right"]             = {"right", FU,   "STCFN"},
    ["small-fixed"]             = {"left",  FU/2, "STCFN"},
    ["small-fixed-center"]      = {"center",FU/2, "STCFN"},
    ["small-fixed-right"]       = {"right", FU/2, "STCFN"},
    ["thin-fixed"]              = {"left",  FU,   "TNYFN"},
    ["thin-fixed-center"]       = {"center",FU,   "TNYFN"},
    ["thin-fixed-right"]        = {"right", FU,   "TNYFN"},
    ["small-thin-fixed"]        = {"left",  FU/2, "TNYFN"},
    ["small-thin-fixed-center"] = {"center",FU/2, "TNYFN"},
    ["small-thin-fixed-right"]  = {"right", FU/2, "TNYFN"},
}

local font_lineheights = {
    STCFN = 12,
    TNYFN = 12,
    CRFNT = 16,
    LTFNT = 16,
    NTFNT = 21,
    NTFNO = 21
}

local function splitLines(str)
    local lines = {}
    for line in (str.."\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    return lines
end

--[[@param x number]]
--[[@param y number]]
--[[@param settings WarpSettings]]
local function posWarp(x, y, settings)
    return (
        FixedMul(x - settings.xorigin, settings.xscale) + settings.xorigin + settings.xoffset
    ), (
        FixedMul(y - settings.yorigin, settings.yscale) + settings.yorigin + settings.yoffset
    )
end

---@class WarpSettings
---@field xscale fixed_t? Scale factor for x (default: FU)
---@field yscale fixed_t? Scale factor for y (default: FU)
---@field xorigin fixed_t? Scale origin for x (default: 0, center of screen: 160FU)
---@field yorigin fixed_t? Scale origin for y (default: 0, center of screen: 100FU)
---@field xoffset fixed_t? Offset for x (default: 0)
---@field yoffset fixed_t? Offset for y (default: 0)

--[[@param truev videolib]]
--[[@param settings WarpSettings]]
rawset(_G, "VWarp", function (truev, settings)
    if not settings then settings = {} end
    settings = {
        xscale = settings.xscale or FU,
        yscale = settings.yscale or FU,
        xorigin = settings.xorigin or 0,
        yorigin = settings.yorigin or 0,
        xoffset = settings.xoffset or 0,--160*FU - FixedMul(160*FU, xs),
        yoffset = settings.yoffset or 0,--100*FU - FixedMul(100*FU, ys)+cos(leveltime*ANG2*3)*10
    }

    --[[@type videolib]]
    local modv = {settings = settings}

    -- cache
    def(modv, truev, "patchExists")
    def(modv, truev, "cachePatch")
    def(modv, truev, "getSpritePatch")
    def(modv, truev, "getSprite2Patch")
    def(modv, truev, "getColormap")
    def(modv, truev, "getStringColormap")
    def(modv, truev, "getSectorColormap")
    -- drawing
    modv.draw = function (x, y, p, f, c)
        modv.drawStretched(x*FU, y*FU, FU, FU, p, f, c)
    end
    modv.drawScaled = function (x, y, s, p, f, c)
        modv.drawStretched(x, y, s, s, p, f, c)
    end
    modv.drawStretched = function (x, y, xs, ys, p, f, c)
        local wx, wy = posWarp(x, y, settings)
        truev.drawStretched(
            wx, wy,
            FixedMul(xs, settings.xscale),
            FixedMul(ys, settings.yscale),
            p, f, c
        )
    end
    modv.drawCropped = function (x, y, xs, ys, p, f, c, sx, sy, w, h)
        local wx, wy = posWarp(x, y, settings)
        truev.drawCropped(
            wx, wy,
            FixedMul(xs, settings.xscale),
            FixedMul(ys, settings.yscale),
            p, f, c, sx, sy, w, h
        )
    end
    modv.drawNum = function (x, y, n, f)

        -- drawNum is always nonfixed, make it fixed
        local wx, wy = posWarp(x*FU, y*FU, settings)

        -- TODO drawNum is not just drawString(tostring(num))
        -- TODO but also make this better
        truev.drawNum(
            wx/FU, wy/FU,
            n, f
        )
    end
    def(modv, truev, "drawPaddedNum")
    modv.drawFill = function (x, y, w, h, c)
        -- this is funky to make sure no gaps appear
        -- TODO maybe make this draw a texture? would be hard to do for a drop-in library lua. you probably shouldn't be using this anyway.
        local wx, wy = posWarp(x*FU, y*FU, settings)
        local wx2, wy2 = posWarp((x+w)*FU, (y+h)*FU, settings)
        wx = $/FU
        wy = $/FU
        wx2 = $/FU
        wy2 = $/FU
        if (wx == wx2) or (wy == wy2) then return end
        truev.drawFill(
            wx, wy,
            wx2 - wx,
            wy2 - wy,
            c
        )
    end
    modv.drawString = function (x, y, t, f, a)
        -- TODO custom drawString to allow scaling
        -- TODO also convert draw type to fixed
        if align_nonfixed2fixed[a or "left"] then
            a = align_nonfixed2fixed[a or "left"]
            x = $ * FU
            y = $ * FU
        end
        -- local wx, wy = posWarp(x, y, settings)
        -- truev.drawString(wx, wy, t, f, a)

        -- since CustomHUD uses normal drawing functions we just need to translate the request and pass in modv
        -- align, scale, font name
        local metadata = align_propertymap[a]

        if (f & V_ALLOWLOWERCASE) then
            f = $ & ~V_ALLOWLOWERCASE
        else
            t = t:upper()
        end

        local lineheight = font_lineheights[metadata[3]]
        if f & V_RETURN8 then
            lineheight = 8;
        end

        -- print(x .. "/" .. y .. "/" .. x/FU .. "f/" .. y/FU .. "f/" .. t .. "/" .. f)

        -- TODO not passing in modv for debug
        for _, line in pairs(splitLines(tostring(t))) do
            vwarpcustomhud.CustomFontString(
                -- v, x, y, str, fontname, flags, align, scale, color
                modv,
                -- x, y, str
                x, y, line,
                -- fontname, flags, align
                metadata[3], f or 0, metadata[1],
                -- scale, color
                metadata[2], 0 -- TODO actually figure out the color
            )
            y = $ + FixedMul(lineheight*FU, metadata[2])
        end
    end
    def(modv, truev, "drawNameTag")
    def(modv, truev, "drawScaledNameTag")
    def(modv, truev, "drawLevelTitle")
    def(modv, truev, "fadeScreen")
    -- misc
    def(modv, truev, "stringWidth")
    def(modv, truev, "nameTagWidth")
    def(modv, truev, "levelTitleWidth")
    def(modv, truev, "levelTitleHeight")
    -- random
    def(modv, truev, "RandomFixed")
    def(modv, truev, "RandomByte")
    def(modv, truev, "RandomKey")
    def(modv, truev, "RandomRange")
    def(modv, truev, "SignedRandom")
    def(modv, truev, "RandomChance")
    -- properties
    def(modv, truev, "width")
    def(modv, truev, "height")
    def(modv, truev, "dupx")
    def(modv, truev, "dupy")
    def(modv, truev, "renderer")
    def(modv, truev, "localTransFlag")
    def(modv, truev, "userTransFlag")

    return modv
end)


-- #region CustomHUD

-- == Custom HUD Functions by TehRealSalt ==
-- Trimmed and modified for use in VWarp (specifically so i don't have to draw strings myself)

-- vwarpcustomhud def higher up

local function warn(str)
	print("\131WARNING: \128"..str);
end

local fonts = {};

local function CreateNewFont(fontName, kerning, space, mono)
	if (type(kerning) != "number")
		kerning = 0;
	end

	if (type(space) != "number")
		space = 4;
	end

	local newFont = {
		name = fontName,
		kerning = kerning,
		space = space,
		mono = nil,
		patches = {},
		number = false,
	};

	if (type(mono) == "number")
		newFont.mono = mono;
	end

	return newFont;
end

function vwarpcustomhud.SetupFont(fontName, kerning, space, mono)
	if (type(fontName) != "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupFont");
		return;
	end

	if (fontName:len() > 5) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupFont");
		return;
	end

	fonts[fontName] = CreateNewFont(fontName, kerning, space, mono);
end

function vwarpcustomhud.GetFont(fontName)
	return fonts[fontName];
end

local function FontPatchNameDirect(fontName, charByte)
	return fontName .. string.format("%03d", charByte);
end

local function FontPatchName(v, fontName, charByte)
	local patchName = FontPatchNameDirect(fontName, charByte);

	local capsOffset = 32;
	if (charByte >= 65 and charByte <= 90 and not v.patchExists(patchName)) then
		charByte = $1 + capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	elseif (charByte >= 97 and charByte <= 122 and not v.patchExists(patchName)) then
		charByte = $1 - capsOffset;
		patchName = FontPatchNameDirect(fontName, charByte);
	end

	return patchName;
end

local function NumberPatchName(v, fontName, charByte)
	local charNumber = charByte - 48;
	if (charNumber >= 0 and charNumber <= 9) then
		return fontName .. string.format("%d", charNumber);
	end
	return "";
end

function vwarpcustomhud.GetFontPatch(v, font, charByte)
	if not (font.patches[charByte] and font.patches[charByte].valid) then
		local patchName = "";

		if (font.number == true) then -- Number-only font
			patchName = NumberPatchName(v, font.name, charByte);
		else
			patchName = FontPatchName(v, font.name, charByte);
		end

		if (patchName == "")
			return nil;
		end

		-- Try to create a new patch & cache it
		if (v.patchExists(patchName)) then
			font.patches[charByte] = v.cachePatch(patchName);
		end
	end

	return font.patches[charByte];
end

function vwarpcustomhud.CustomFontStringWidth(v, str, fontName, scale)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontStringWidth");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontStringWidth");
		return;
	end

	local font = vwarpcustomhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	local strwidth = 0;
	if (str == "") then
		return strwidth;
	end

	if (type(scale) != "number")
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale != nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale != nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono != nil and scale != nil) then
		mono = $1 * scale;
	end

	for i = 1,str:len() do
		local charByte = str:byte(i,i);
		local patch = vwarpcustomhud.GetFontPatch(v, font, charByte);

		if (patch and patch.valid) then
			local charWidth = patch.width;

			if (mono != nil) then
				charWidth = mono;
			elseif (scale != nil) then
				charWidth = $1 * scale;
			end

			strwidth = $1 + charWidth + kerning;
		else
			strwidth = $1 + space;
		end
	end

	return strwidth;
end

function vwarpcustomhud.CustomFontChar(v, x, y, charByte, fontName, flags, scale, color)
	if not (type(charByte) == "number") then
		warn("No character byte given in customhud.CustomFontChar");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = vwarpcustomhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) != "number")
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale != nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale != nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono != nil and scale != nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local patch = vwarpcustomhud.GetFontPatch(v, font, charByte);
	if (patch and patch.valid) then
		if (scale != nil) then
			v.drawScaled(x, y, scale, patch, flags, wc);
		else
			v.draw(x, y, patch, flags, wc);
		end
	end

	local nextx = x;
	if (patch and patch.valid) then
		local charWidth = patch.width;

		if (mono != nil) then
			charWidth = mono;
		elseif (scale != nil) then
			charWidth = $1 * scale;
		end

		nextx = $1 + charWidth + kerning;
	else
		nextx = $1 + space;
	end

	return nextx;
end

function vwarpcustomhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color)
	if not (type(str) == "string") then
		warn("No string given in customhud.CustomFontString");
		return;
	end

	if not (type(fontName) == "string") then
		warn("No font given in customhud.CustomFontChar");
		return;
	end

	local font = vwarpcustomhud.GetFont(fontName);
	if (font == nil) then
		warn("Invalid font given in customhud.CustomFontStringWidth");
		return;
	end

	if (type(scale) != "number")
		scale = nil;
	end

	local kerning = font.kerning;
	if (scale != nil) then
		kerning = $1 * scale;
	end

	local space = font.space;
	if (scale != nil) then
		space = $1 * scale;
	end

	local mono = font.mono;
	if (mono != nil and scale != nil) then
		mono = $1 * scale;
	end

	local wc = nil;
	if (color) then
		wc = v.getColormap(TC_DEFAULT, color);
	end

	local nextx = x;

	if (align == "right") then
		nextx = $1 - vwarpcustomhud.CustomFontStringWidth(v, str, fontName, scale);
	elseif (align == "center") then
		nextx = $1 - (vwarpcustomhud.CustomFontStringWidth(v, str, fontName, scale) / 2);
	end

	for i = 1,str:len() do
		local nextByte = str:byte(i,i);
		nextx = vwarpcustomhud.CustomFontChar(v, nextx, y, nextByte, fontName, flags, scale, color);
	end
end

function vwarpcustomhud.SetupNumberFont(fontName, kerning, space, mono)
	if (type(fontName) != "string") then
		warn("Invalid font name \""..fontName.."\" in customhud.SetupNumberFont");
		return;
	end

	if (fontName:find(" ")) then
		warn("Font name \""..fontName.."\" cannot have spaces in customhud.SetupNumberFont");
		return;
	end

	if (fontName:len() > 7) or (fontName:len() < 1) then
		warn("Bad font name length in customhud.SetupNumberFont");
		return;
	end

	local newFont = CreateNewFont(fontName, kerning, space, mono);
	newFont.number = true;

	fonts[fontName] = newFont;
end

function vwarpcustomhud.CustomNumWidth(v, num, fontName, padding, scale)
	local str = "";

	if (padding != nil)
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return vwarpcustomhud.CustomFontStringWidth(v, str, fontName, scale);
end

function vwarpcustomhud.CustomNum(v, x, y, num, fontName, padding, flags, align, scale, color)
	local str = "";

	if (padding != nil)
		str = string.format("%0"..padding.."d", num);
	else
		str = string.format("%d", num);
	end

	return vwarpcustomhud.CustomFontString(v, x, y, str, fontName, flags, align, scale, color);
end
-- #endregion

vwarpcustomhud.SetupFont("STCFN", 0,  4)
vwarpcustomhud.SetupFont("TNYFN", 0,  2)
vwarpcustomhud.SetupFont("CRFNT", 0, 16)
vwarpcustomhud.SetupFont("LTFNT", 0, 16)
vwarpcustomhud.SetupFont("NTFNT", 2,  4)
vwarpcustomhud.SetupFont("NTFNO", 0,  4)