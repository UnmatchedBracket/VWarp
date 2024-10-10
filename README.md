# VWarp
VWarp is an SRB2 Lua library to allow for easy warping of HUD elements (scaling, moving).

Trailer  
[![Trailer](https://img.youtube.com/vi/iLFRJOmbY20/0.jpg)](https://youtu.be/iLFRJOmbY20)

## Usage
Create a `VWarp` object:
```lua
local VWarp = dofile("VWarp")
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
```
Then use it like you would `v`:
```lua
warpv.drawString(20, 120, "Wow, it's a\x83 string!")
warpv.draw(30, 160, warpv.cachePatch("CHAOS4"))
```
![The result of the above code](https://raw.githubusercontent.com/UnmatchedBracket/VWarp/refs/heads/github-assets/srb22182.png)  
(see [Lua/test-readmedemo.lua](https://github.com/UnmatchedBracket/VWarp/blob/main/Lua/test-readmedemo.lua) for full code demo)
