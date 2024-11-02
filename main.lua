require("sugarlove/sugarlove")
local S = sugar.S
local pal = S.palettes.sweetie16
local fading = false

function love.load()
    S.init_sugar("~ sugarlove ~", 320, 180, 3)

    S.load_png("sugarlove_logo", "sugarlove/icon.png", pal, true)

    S.register_btn(0, 0, S.input_id("keyboard", "return"))
end

function love.update()
    if S.btnp(0) then
        fading = true
    end
    if fading then
        S.clip(S.t(), S.t(), 100-S.t(), 100-S.t())
    end
end

function love.draw()
    S.cls()
    S.use_palette(pal)
    S.tri(
        160+36*S.cos(S.t()/4), 90+36*S.sin(S.t()/4),
        160+36*S.cos(S.t()/4+0.333), 90+36*S.sin(S.t()/4+0.333),
        160+36*S.cos(S.t()/4+0.666), 90+36*S.sin(S.t()/4+0.666), 12
      )
    S.print("Made using", 126, 30, 12)
    local str = "sugarlove"
    local x, y = 130, 45
    for i = 1, #str do
        local clr
        if i<6 then
            clr=10
        else
            clr=1
        end
        local c = str:sub(i,i)
        S.print(c, x, y + 3*S.cos(-S.t()/4 * 2 + i/5), clr)
        x = x + S.str_px_width(c)
    end
    S.spritesheet_grid(17, 19)
    S.aspr(0, 160, 90, S.t()/5)
end