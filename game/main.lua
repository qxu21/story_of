function love.load()
    love.graphics.setColor(255,255,255,1)
    f = love.graphics.newFont("apple.ttf",16,"none")
    --bf =  --bigger font?
    love.graphics.setFont(f)
    text_counter = 1
    til_text = 0
    cps = 30 --chars per second
    til_wait_over = 0 --for longer-length characters like period
    tdisp = {} --table of characters with metadata that are actively being drawn
    is_typing = false
    scene = 0
    line = 1
    scene_two_timer = 0
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
    images = {
        splash= {
            love.graphics.newImage"sprites/splash2x_lowa.png",
            love.graphics.newImage"sprites/splash2x_mida.png",
            love.graphics.newImage"sprites/splash2x.png"
        },
        loaf=love.graphics.newImage"sprites/loaf2x.png"
    }
    tbuf = {} --text buffer
    is_saying = false
    function sayText(text,color)
        is_saying = true
        ctext = "" --clean text, without markup
        local mkups = {} --markup info to be merged into tbuf
        --i hope draw doesn't call in the middle of this and cause a race condition
        --brb fixing that
        --fixed with is_saying
        local markup_mode = nil
        for i=1,#text do
            if not markup_mode and text:sub(i,i) == "<" then
                markup_mode = text:sub(i+1,i+1) 
                --just don't put < at the end of messages you little shits
                --unless it'll just return nil, because that would be funny
                if markup_mode == "c" then
                    --<cRRR,GGG,BBB>
                    mkups[#ctext+1] = {
                        markup = "c",
                        r = tonumber(text:sub(i+2,i+4)), --watch the substringing
                        g = tonumber(text:sub(i+6,i+8)),
                        b = tonumber(text:sub(i+10,i+12)),
                    }
                    
                end
            elseif markup_mode and text:sub(i,i) == ">" then
                markup_mode = nil
            elseif not markup_mode then
                ctext = ctext .. text:sub(i,i)
            end
        end
        for i=1,#ctext do
            --if ctext:sub(i,i) == "<" then
                --[[ formatting docstring:
                    <c=000000 - hexadecimal color to apply>
                    <n> - newline
                ]]
                -- coming back to this lol
                -- DONT FORGET TO JUMP i OVER THE FORMATTING CODE, OR BETTER YET, REDACT IT FROM THE TEXT
            --37 characters per line
            if i % 37 == 0 then
                j = i
                while ctext:sub(j,j) ~= " " do
                    j = j - 1
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
        end
        for i,v in pairs(mkups) do
            for k,w in pairs(v) do
                tbuf[i][k] = w
            end
            --[[for k,w in pairs(tbuf[i]) do
                print(k .. " : " .. tostring(w))
                
            end]]
        end
        is_saying = false
    end

    game = {
        {
            "On the floor of your bedroom, you find an old computer.",
            "It says... <c128,128,128>Apple ][<c256,256,256> on the front?", ---write a validator?
            "Man, only <c026,188,156>Mr. Flibble<c256,256,256> knows how old this thing must be.", --color Mr. Flibble as 26, 188, 156
            "There's a <c128,128,128>cassette player<c256,256,256> hooked up to the machine. " .. --oo, multiline - but don't forget the spaces
            "You lean down and try to read the label on the <c128,128,128>cassette<c256,256,256>, but it's smudged off.",
            "Only one thing left to do, you suppose.",
            "You turn the machine on..."
        }
    }

    center_text = "PRESS START"

    dosplash = nil

end

function love.update(dt)
    --text is fed into t when needed
    til_text = til_text + dt
    if til_text >= 1/cps and tbuf[1] and not is_saying then
        is_typing = true
        til_text = 0
        if til_wait_over ~= 0 then
            til_wait_over = til_wait_over - 1
        else
            table.insert(tdisp,tbuf[1])
            if tbuf[1].char == "." then
                til_wait_over = 3
            end
            table.remove(tbuf,1)
            if not tbuf[1] then is_typing = false end
        end
    end
    if scene == 2 then
        scene_two_timer = scene_two_timer + dt
        local speed = 0.75
        if scene_two_timer > 1*speed and scene_two_timer <= 2*speed then setgrey(0.67)
        elseif scene_two_timer > 2*speed and scene_two_timer <= 3*speed then setgrey(0.33)
        elseif scene_two_timer > 3*speed and scene_two_timer <= 4*speed then tdisp = {}
        elseif scene_two_timer > 4*speed and scene_two_timer <= 4.5*speed then dosplash = 1
        elseif scene_two_timer > 4.5*speed and scene_two_timer <= 5*speed then dosplash = 2
        elseif scene_two_timer > 5*speed and scene_two_timer <= 6*speed then dosplash = 3
        --eventually i'm coding a proper gamestate parser, but not for the demo
            setgrey(1)
        end
    end
end

function love.draw()
    --oh joyous day, we get to render chars individually
    newlines = 0
    dpos = 0
    love.graphics.setColor(default_color.r,default_color.g,default_color.b,default_color.a)
    for i,v in ipairs(tdisp) do 
        if v.markup == "c" then
            love.graphics.setColor(v.r/256,v.g/256,v.b/256)
        end  
        if not v.char then
            if v.newline then
                newlines = newlines + 1
                dpos = 0
            end
        else
            love.graphics.print(v.char,100+dpos*16,400+18*newlines) --no newlines yet
            dpos = dpos + 1
            --love.graphics.setColor(1,1,1)
        end
    end
    love.graphics.printf(center_text, 100, 400, 600, "center")
    --love.graphics.draw(images.loaf,(love.graphics.getWidth()-images.loaf:getPixelWidth())/2)
    if dosplash then 
        love.graphics.draw(
            images.splash[dosplash],
            (love.graphics.getWidth()-images.splash[dosplash]:getPixelWidth())/2,
            (love.graphics.getHeight()-images.splash[dosplash]:getPixelHeight())/2
        )
    end
end

function love.keypressed(key, scancode, isrepeat)
    if scene == 0 then
        scene = 1
    end
    if scene == 1 and not is_typing then
        if line > table.getn(game[scene]) then 
            scene = 2
            return
        end
        center_text = ""
        tdisp = {}
        sayText(game[scene][line])
        line = line + 1
        
        --control flow might be a little cursed here   
    end
end


