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
    is_buffering = false
    scene = 0
    line = 1
    til = 0 --until
    image_drawn = nil
    fadesource = nil
    keypresses = {}
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
            img = love.graphics.newImage"sprites/splash2x.png",
            loc = "center"
        },
        loaf= {
            img = love.graphics.newImage"sprites/loaf2x.png",
            loc = "dial"
        },
        loafshrug= {
            img = love.graphics.newImage"sprites/loafshrug2x.png",
            loc = "dial"
        },
        loafstand= {
            img = love.graphics.newImage"sprites/loafstand2x.png",
            loc = "dial"
        },
        loafwave= {
            img = love.graphics.newImage"sprites/loafwave2x.png",
            loc = "dial"
        },
        loafpoint= {
            img = love.graphics.newImage"sprites/loafpoint2x.png", --dear lord automate this
            loc = "dial"
        },
    }
    music = {
        opening = love.audio.newSource("music/Opening.ogg","stream"),
        theme = love.audio.newSource("music/Theme.ogg","stream")
    }
    music.opening:setLooping(true)
    music.theme:setLooping(true)
    tbuf = {} --text buffer
    is_saying = false
    wstate = nil
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
        for i=1,#ctext do
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

    local speed=0.75
    game = {
        --[[ TABLE FIELDS:
            dial - dialogue. default, next keypress advances
            grey - do a setGray(grey)
            dur - wait this long before calling the next event, or for keypress if nil (maybe 0 in the future)
        ]]
        [0] = {
            {
                center_text="TURN YOUR SOUND ON"
            }
        },
        [1] = {
            {
                play=music.opening,
                dial="On the floor of your bedroom, you find an old computer."},
            {dial="It says... <c128,128,128>Apple ][<c256,256,256> on the front?"}, ---write a validator?
            {dial="Man, only <c026,188,156>Mr. Flibble<c256,256,256> knows how old this thing must be."}, --color Mr. Flibble as 26, 188, 156
            {dial="There's a <c128,128,128>cassette player<c256,256,256> hooked up to the machine. " .. --oo, multiline - but don't forget the spaces
                "You lean down and try to read the label on the <c128,128,128>cassette<c256,256,256>, but it's smudged off."},
            {dial="Only one thing left to do, you suppose."},
            {dial="You turn the machine on..."},
        },
        [2] = {
            --railroad=true, --do not allow keypress advances
            {
                dur=speed,

                fadesource=music.opening,

                fadedur = speed*3
            },
            {
                grey=0.67,
                dur=speed
            },
            {
                grey=0.33,
                dur=speed
            },
            {
                grey=0,
                dur=speed,
            },
            {
                img=images.splash,
                dur=speed/2,
                grey=0.5,
                cleardisp=true,
                stop = music.opening
            },
            {
                img=images.splash,
                dur=speed/2,
                grey=0.75,
            },
            {
                img=images.splash,
                --dur=speed/2,
                grey=1,
                center_text = "PRESS START",
                play = music.theme
            },
        },
        [3] = {
            {
                img = images.loaf, --todo - fade in
                dial="Hey!"
            },
            {
                img = images.loaf, 
                dial="Welcome to <w>The Story of Rassilon!</w>"
            },
            {
                img = images.loaf, 
                dial="I'm your host, <c077,161,214>Loaf</c>."
            },
            {
                img = images.loaf, 
                dial="First, I'd like to thank you for even loading this game up!"
            },
            {
                img = images.loaf, 
                dial="I spent far too much time on it, so hopefully you like it."
            },
            {
                img = images.loaf, 
                dial="I must confess, though..."
            },
            {
                img = images.loafshrug, 
                dial="The game isn't done yet!"
            },
            {
                img = images.loafshrug, 
                dial="In fact, I've barely started!"
            },
            {
                img = images.loaf, 
                dial="My idea is that this game is supposed to be <w>episodic</w>."
            },
            {
                img = images.loaf, 
                dial="That means I can make new parts and release them as they come out."
            },
            {
                img = images.loafshrug, 
                dial="Sounds cool, huh?"
            },
            {
                img = images.loaf, 
                dial="I thought it was a good idea, anyway."
            },
            {
                img = images.loaf, 
                dial="So let's cut to the chase:"
            },
            {
                img = images.loafstand, 
                dial="This is <w>The Story of Rassilon!</w>"
            },
            {
                img = images.loafstand, 
                dial="If you're reading this, you're probably in <w>The Network of Rassilon!</w>"
            },
            {
                img = images.loafpoint, 
                dial="Which means this story is about you!"
            },
            {
                img = images.loafstand, 
                dial="(Excuse my abuse of the wavy text, I just figured it out.)"
            },
            {
                img = images.loaf, 
                dial="With all this free summertime on my hands, I figured I'd blend several project ideas into one."
            },
            {
                img = images.loafshrug, 
                dial="What if I told a story about my friends?"
            },
            {
                img = images.loafshrug, 
                dial="With writing! And music! And mediocre sprite art!"
            },
            {
                img = images.loafshrug, 
                dial="And what if I made it kind of interactive?"
            },
            {
                img = images.loaf, 
                dial="Because, well, I can't make a better game than what's already out there."
            },
            {
                img = images.loaf, 
                dial="(If you can't notice, this game kind of looks like a ripoff of <c256,000,000>Undertale</c>.)"
            },
            {
                img = images.loaf, 
                dial="(To that, I say - I'm not ripping <c256,000,000>Undertale</c> off if it's worse than <c256,000,000>Undertale</c>!)"
            },
            {
                img = images.loafshrug, 
                dial="Ha ha!"
            },
            {
                img = images.loafstand, 
                dial="But I can make a game about my very own community!"
            },
            {
                img = images.loafstand, 
                dial="(Or is it more of a visual novel?)"
            },
            {
                img = images.loafstand, 
                dial="Anyone who comments about this game in #meta will, unless they request otherwise, be included in the Story."
            },
            {
                img = images.loafstand, 
                dial="Unless you provide me with a different name, you'll be called by your Discord username or nickname, depending on which is more recognizable."
            }, --why is this busting the box
            {
                img = images.loafstand, 
                dial="Unless you provide me with a different image, your sprite will resemble your Discord avatar."
            },
            {
                img = images.loaf, 
                dial="(Personally, I look forward to drawing the <c033,190,033>Pugman</c>.)"
            },
            {
                img = images.loafshrug, 
                dial="And, well, let's see where this story takes us!"
            },
            {
                img = images.loaf, 
                dial="That's all for now, I think."
            },
            {
                img = images.loafwave, 
                dial="Until later!"
            },
            {
                dial="To be continued..."
            }
        },
    }

    function advanceline()
        --[[ CONTROL FLOW:
            scene and line represent THE CURRENT SCENE AND LINE.
            so they should be incremented when advanceline() is called
            but BEFORE the render. that way scene and line are up to date.
            squishing a bug by making scene 0 a thing.
        ]]
        if line == #game[scene] then 
            til = 0
            if scene == #game then return end
            scene = scene + 1
            line = 1 --IF YOU GET A NIL LINE, IT'S PROBABLY THIS
        else
            line = line + 1
        end
        print(scene, line)
        renderline(game[scene][line])
    end

    function renderline(l)
        if l.dial then sayText(l.dial) end
        if l.grey then setgrey(l.grey) end
        if l.cleardisp then tdisp = {} end
        if l.center_text then center_text = l.center_text else center_text = nil end
        if l.img then image_drawn = l.img else image_drawn = nil end
        if l.play then l.play:play() end
        if l.stop then l.stop:stop() end
        if l.fadesource then fadesource = l.fadesource end --screw it, no fadedur

    end
    --center_text = "PRESS START"
    dosplash = nil
    renderline(game[scene][line]) --heh
end

function love.update(dt)
    --text is fed into tdisp when needed
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
    if game[scene][line] and game[scene][line].dur then advanceline() ; print("dur", scene, line)
    elseif keypresses[1] and not game[scene][line].dur then --just deprecated railroad
        --if scene == 0 then scene = 1 end
        if not is_buffering then --todo - scene agnostic 
            advanceline()
            --control flow might be a little cursed here   
        end
        table.remove(keypresses,1) --loop over all keypresses in one update?
        print("key", scene, line)
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
            local ypos = 400+24*newlines
            if wstate then ypos = ypos + 4*math.sin(wstate) end
            love.graphics.print(v.char,xpos,ypos) --no newlines yet
            dpos = dpos + 1
        end
        if wstate then wstate = wstate + 0.3 end --tweak this constant too
    end
    --beware this color reset
    love.graphics.setColor(default_color.r,default_color.g,default_color.b,default_color.a)
    if center_text then love.graphics.printf(center_text, 100, 450, 600, "center") end
    if image_drawn then --limitation - can only draw one image centrally. future images should be drawn separately
        if image_drawn.loc == "center" then
            imgx = (love.graphics.getWidth()-image_drawn.img:getPixelWidth())/2
            imgy = (love.graphics.getHeight()-image_drawn.img:getPixelHeight())/2
        elseif image_drawn.loc == "dial" then
            imgx = (love.graphics.getWidth()-image_drawn.img:getPixelWidth())/2
            imgy = 390-image_drawn.img:getPixelHeight()
        end
        love.graphics.draw(
            image_drawn.img, imgx, imgy
        )
    end
end

function love.keypressed(key,scancode,isrepeat)
    --all keypress code ported to update()
    --learn to ignore fn keys, alttab, etc
    table.insert(keypresses,key) --why does keypresses:insert not work
end


