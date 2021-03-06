--WHEN MAKING THE .LOVE, YOU NEED TO ZIP WHILE PWD=/GAME
--OR FIGURE IT OUT
--AND TEST YOUR DAMNED .LOVE BEFORE BUILDING, DAMMIT
--[[ TO FIX:
    -MUSIC
    -OVERFLOW BUGS AGAIN
]]

function iter (a, i)
    i = i + 1
    local v = a[i]
    if v then
      return i, v
    end
  end
  
  function spairs (a,start)
    return iter, a, start-1
  end

function love.load()
    love.graphics.setColor(1,1,1,1)
    f = love.graphics.newFont("apple.ttf",16,"none")
    --bf =  --bigger font?
    love.graphics.setFont(f)
    text_counter = 1
    til_text = 0
    cps = 30 --chars per second
    til_wait_over = 0 --for longer-length characters like period
    tdisp = {} --table of characters with metadata that are actively being drawn
    is_buffering = false
    scene = 0 --admin console when
    line = 1
    til = 0 --until
    choice = 1
    drawn = {}
    fadesource = nil
    keypresses = {}
    dialbox = false
    default_color = {
        r=1,
        g=1,
        b=1,
        a=1,  
    }
    function setgrey (all) 
        default_color.r=all
        default_color.g=all
        default_color.b=all
        default_color.a=1
    end
    
    tbuf = {} --text buffer
    is_saying = false
    wstate = nil
    playing = nil
    function sayText(text,color)
        tdisp = {}
        center_text = ""
        is_saying = true
        ctext = "" --clean text, without markup
        local mkups = {} --markup info to be merged into tbuf
        local markup_mode = nil
        for i=1,#text do
            if not markup_mode and text:sub(i,i) == "<" then
                markup_mode = text:sub(i+1,i+1) --inb4 out of index
                if markup_mode == "c" then
                    --<cRRR,GGG,BBB>
                    mkups[#ctext+1] = {
                        markup = "c",
                        r = tonumber(text:sub(i+2,i+4)),
                        g = tonumber(text:sub(i+6,i+8)),
                        b = tonumber(text:sub(i+10,i+12)),
                    }
                elseif markup_mode == "w" then
                    mkups[#ctext+1] = {
                        markup = "w",
                        wstate = 0
                    }
                elseif markup_mode == "/" then
                    markup_demode = text:sub(i+2,i+2)
                    if markup_demode == "c" then
                        --[[mkups[#ctext+1] = {
                            markup = "c",
                            r = default_color.r,
                            g=default_color.g,
                            b=default_color.b
                        }]]
                        mkups[#ctext+1] = {
                            markup = "/c",
                        }
                    elseif markup_demode == "w" then
                    mkups[#ctext+1] = {
                        markup = "/w",loafstand= {
                            img = love.graphics.newImage"sprites/loafstand2x.png",
                            loc = "dial"
                        },
                    }
                    else print("Invalid markup demode!") end
                end
            elseif markup_mode and text:sub(i,i) == ">" then
                markup_mode = nil
            elseif not markup_mode then
                ctext = ctext .. text:sub(i,i)
            end
        end
        local wrapcounter=1
        for i=1,#ctext do
            --37 characters per line
            if wrapcounter == 37 then
                j = i
                wrapcounter = 0
                --print(i,ctext:sub(i,i))
                while ctext:sub(j,j) ~= " " do
                    j = j - 1
                    wrapcounter = wrapcounter + 1 --watch there be an off by one in here somewhere
                    --print(j,ctext:sub(j,j))
                end
                if j == i then
                    next_char = {newline=true}
                else
                    tbuf[j] = {newline=true} --yeah, just replace the space
                    next_char = {char=ctext:sub(i,i)}
                end
                table.insert(tbuf,next_char)
                
            else
                table.insert(tbuf,{char=ctext:sub(i,i)})
            end
            wrapcounter = wrapcounter + 1
        end
        for i,v in pairs(mkups) do
            if i > #tbuf then
                tbuf[i] = v
            else
                for k,w in pairs(v) do
                    --print(i,k,w)
                    --print(#tbuf)
                    tbuf[i][k] = w
                end
            end
        end
        is_saying = false
    end

    local g = require("game")
    game = g.game
    select_screen = require("select_screen")

    function advanceline()
        --[[ CONTROL FLOW:
            scene and line represent THE CURRENT SCENE AND LINE.
            so they should be incremented when advanceline() is called
            but BEFORE the render. that way scene and line are up to date.
            squishing a bug by making scene 0 a thing.
        ]]
        if line == #game[scene] then 
            til = 0
            if scene == #game then
                scene = 0
                line = 2
            else
                scene = scene + 1
                line = 1 --IF YOU GET A NIL LINE, IT'S PROBABLY THIS
            end
        elseif game[scene][line+1].tag then
            for i,v in spairs(game[scene],line) do
                if v.endtag then 
                    line=i
                    break
                end
            end
        else
            line = line + 1
        end
        --print(scene, line)
        renderline(game[scene][line])
    end

    function renderline(l)
        if l.reset then
            tdisp = {}
            center_text = nil
            drawn = {}
            dialbox = false
            if playing then playing:stop() end
        end
        if l.dial then sayText(l.dial) end
        if l.grey then setgrey(l.grey) end
        if l.cleardisp then tdisp = {} end
        if l.center_text then center_text = l.center_text else center_text = nil end
        if l.background then drawn[1] = l.background end --pos1 is reserved for backgroud, if it exists
        if l.img then drawn[2] = l.img end --image must be manually reset to nil
        if l.play then 
            if l.play ~= playing then
                if playing then playing:stop() end
                playing = l.play
                l.play:play()
            end
        end
        if l.sfx then l.sfx:play() end
        if l.stopfx then l.stopfx:stop() end
        if l.stop and playing then playing:stop() end --or: playing.stop
        if l.fadesource then fadesource = l.fadesource end --screw it, no fadedur
        if l.dialbox == true then dialbox = true elseif l.dialbox == false then dialbox = false end --tfw
    end
    --center_text = "PRESS START"
    dosplash = nil
    renderline(game[scene][line]) --heh
end

function love.update(dt)
    --text is fed into tdisp when needed
    --good god make this callbacks already
    til_text = til_text + dt
    til = til + dt
    if fadesource then fadesource:setVolume(fadesource:getVolume()-dt/3) end
    if til_text >= 1/cps and tbuf[1] and not is_saying then
        is_buffering = true
        til_text = 0
        if til_wait_over ~= 0 then
            til_wait_over = til_wait_over - 1
        else
            table.insert(tdisp,tbuf[1])
            if tbuf[1].char == "." then
                til_wait_over = 3
            end
            table.remove(tbuf,1)
            if not tbuf[1] then is_buffering = false end
        end
    end
    for i,v in ipairs(tdisp) do
        if v.markup == "w" then v.wstate = v.wstate + dt*5 end --tweak constant
    end

    if game[scene] and game[scene][line] and game[scene][line].dur then
        if til < game[scene][line].dur then return end
    end
    til = 0
    
    if game[scene][line] and game[scene][line].dur then advanceline()
    elseif game[scene][line].select_screen and keypresses[1] then
        if keypresses[1] == "return" then
            selected_scene = select_screen.scene()
            if selected_scene then
                scene = selected_scene
                line = 1
                renderline(game[scene][line])
            end
        else
            select_screen.arrow(keypresses[1])
        end
        table.remove(keypresses,1)
    elseif keypresses[1] and game[scene][line].choice then
        if keypresses[1]=="return" then
            for i,v in spairs(game[scene],line) do --this should start at the current line when tag hunting
                if v.tag and v.tag == game[scene][line].choice[choice].tag then
                    line = i
                    renderline(game[scene][line])
                    break
                end
            end
        else
            if choice == #game[scene][line].choice then choice = 1
            else choice = choice + 1 end
        end
        table.remove(keypresses,1) --repetition ouch - i need to read these comments and clean house
    elseif keypresses[1] and not game[scene][line].dur then
        if not is_buffering then
            advanceline()
            --control flow might be a little cursed here   
        end
        table.remove(keypresses,1) --loop over all keypresses in one update?
    end
end

function love.draw()
    --oh joyous day, we get to render chars individually
    newlines = 0
    dpos = 0
    love.graphics.setColor(default_color.r,default_color.g,default_color.b,default_color.a)
    wstate = nil
    for i,v in ipairs(tdisp) do 
        if v.markup == "c" then
            love.graphics.setColor(v.r/256,v.g/256,v.b/256)
        elseif v.markup == "/c" then
            love.graphics.setColor(default_color.r,default_color.g,default_color.b,default_color.a)
        elseif v.markup == "w" then
            wstate = v.wstate
        elseif v.markup == "/w" then
            wstate = nil
        end
        if not v.char then
            if v.newline then
                newlines = newlines + 1
                dpos = 0
            end
        else
            local xpos = 100+dpos*16
            local ypos = 420+24*newlines
            if wstate then ypos = ypos + 4*math.sin(wstate) end
            love.graphics.print(v.char,xpos,ypos) --no newlines yet
            dpos = dpos + 1
        end
        if wstate then wstate = wstate + 0.3 end --tweak this constant too
    end
    --beware this color reset
    love.graphics.setColor(default_color.r,default_color.g,default_color.b,default_color.a)
    if center_text then love.graphics.printf(center_text, 100, 450, 600, "center") end
    for i, img in pairs(drawn) do --limitation - can only draw one image centrally. future images should be drawn separately
        if img.loc == "center" then
            imgx = (love.graphics.getWidth()-img.img:getPixelWidth())/2
            imgy = (love.graphics.getHeight()-img.img:getPixelHeight())/2
        elseif img.loc == "dial" then
            imgx = (love.graphics.getWidth()-img.img:getPixelWidth())/2
            imgy = 400-img.img:getPixelHeight()
        else --image is assumed to have a locx and locy
            imgx = img.locx
            imgy = img.locy
        end
        love.graphics.draw(
            img.img, imgx, imgy
        )
    end
    love.graphics.setLineWidth(4)
    if game[scene][line].choice then
        --for my sanity let's only implement two choices
        --idk how 3+ choices should be implemented anyway
        for i, c in ipairs(game[scene][line].choice) do
            if i == choice then love.graphics.setColor(248/255,222/255,52/255,1)
            else love.graphics.setColor(1,1,1,1) end
            love.graphics.printf(game[scene][line].choice[i].text,80+320*(i-1),475,320,"center")
        end
    end
    if dialbox then 
        love.graphics.setColor(1,1,1,1) --default_color?
        love.graphics.rectangle("line",80,400,640,150) --why is it grey
    end
    if game[scene][line].select_screen then select_screen.draw() end
end

function love.keypressed(key,scancode,isrepeat)
    --all keypress code ported to update()
    --learn to ignore fn keys, alttab, etc
    --keypressed is for like movements, but i handle it all in update()
    table.insert(keypresses,key) --why does keypresses:insert not work
end


