require("sugarlove/sugarlove")
local S = sugar.S
local pal = S.palettes.sweetie16
local fading = false
local sugar_icon = 10
local white_fade = 12

function love.load()
    S.init_sugar("~ sugarlove ~", 320, 180, 3)
    S.use_palette(S.palettes.sweetie16)

    S.load_png("sugarlove_logo", "sugarlove/icon.png", pal, true)

    S.register_btn(0, 0, S.input_id("keyboard", "return"))
end

function love.update()
    if S.btnp(0) then
        fading = true
    end
    if fading then
        if S.t()%.2<.01 then
            if sugar_icon>0 then
                sugar_icon = sugar_icon - 1
                if sugar_icon<8 then
                    sugar_icon=0
                end
            end
            if white_fade>0 then
                white_fade=white_fade-1
                if white_fade >3 then
                    white_fade = 3
                end
            end
        end
    end
end

function love.draw()
    S.cls()
    if fading then
        if S.t()%.8<.015 then
            S.pal(1, 0)
        end
    end
    S.pal(10, sugar_icon, true)
    S.pal(12, white_fade, true)
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
            clr=sugar_icon
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