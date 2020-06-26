local M = {}

speed=0.75
M.images = {
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
M.music = {
    opening = love.audio.newSource("music/Opening.ogg","stream"),
    theme = love.audio.newSource("music/Theme.ogg","stream")
}
M.music.opening:setLooping(true)
M.music.theme:setLooping(true)


M.game = {
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
            play=M.music.opening,
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

            fadesource=M.music.opening,

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
            img=M.images.splash,
            dur=speed/2,
            grey=0.5,
            cleardisp=true,
            stop = M.music.opening
        },
        {
            img=M.images.splash,
            dur=speed/2,
            grey=0.75,
        },
        {
            img=M.images.splash,
            --dur=speed/2,
            grey=1,
            center_text = "PRESS START",
            play = M.music.theme
        },
    },
    [3] = {
        {
            img = M.images.loaf, --todo - fade in
            dial="Hey!"
        },
        {
            img = M.images.loaf, 
            dial="Welcome to <w>The Story of Rassilon!</w>"
        },
        {
            img = M.images.loaf, 
            dial="I'm your host, <c077,161,214>Loaf</c>."
        },
        {
            img = M.images.loaf, 
            dial="First, I'd like to thank you for even loading this game up!"
        },
        {
            img = M.images.loaf, 
            dial="I spent far too much time on it, so hopefully you like it."
        },
        {
            img = M.images.loaf, 
            dial="I must confess, though..."
        },
        {
            img = M.images.loafshrug, 
            dial="The game isn't done yet!"
        },
        {
            img = M.images.loafshrug, 
            dial="In fact, I've barely started!"
        },
        {
            img = M.images.loaf, 
            dial="My idea is that this game is supposed to be <w>episodic</w>."
        },
        {
            img = M.images.loaf, 
            dial="That means I can make new parts and release them as they come out."
        },
        {
            img = M.images.loafshrug, 
            dial="Sounds cool, huh?"
        },
        {
            img = M.images.loaf, 
            dial="I thought it was a good idea, anyway."
        },
        {
            img = M.images.loaf, 
            dial="So let's cut to the chase:"
        },
        {
            img = M.images.loafstand, 
            dial="This is <w>The Story of Rassilon!</w>"
        },
        {
            img = M.images.loafstand, 
            dial="If you're reading this, you're probably in <w>The Network of Rassilon!</w>"
        },
        {
            img = M.images.loafpoint, 
            dial="Which means this story is about you!"
        },
        {
            img = M.images.loafstand, 
            dial="(Excuse my abuse of the wavy text, I just figured it out.)"
        },
        {
            img = M.images.loaf, 
            dial="With all this free summertime on my hands, I figured I'd blend several project ideas into one."
        },
        {
            img = M.images.loafshrug, 
            dial="What if I told a story about my friends?"
        },
        {
            img = M.images.loafshrug, 
            dial="With writing! And music! And mediocre sprite art!"
        },
        {
            img = M.images.loafshrug, 
            dial="And what if I made it kind of interactive?"
        },
        {
            img = M.images.loaf, 
            dial="Because, well, I can't make a better game than what's already out there."
        },
        {
            img = M.images.loaf, 
            dial="(If you can't notice, this game kind of looks like a ripoff of <c256,000,000>Undertale</c>.)"
        },
        {
            img = M.images.loaf, 
            dial="(To that, I say - I'm not ripping <c256,000,000>Undertale</c> off if it's worse than <c256,000,000>Undertale</c>!)"
        },
        {
            img = M.images.loafshrug, 
            dial="Ha ha!"
        },
        {
            img = M.images.loafstand, 
            dial="But I can make a game about my very own community!"
        },
        {
            img = M.images.loafstand, 
            dial="(Or is it more of a visual novel?)"
        },
        {
            img = M.images.loafstand, 
            dial="Anyone who comments about this game in #meta will, unless they request otherwise, be included in the Story."
        },
        {
            img = M.images.loafstand, 
            dial="Unless you provide me with a different name, you'll be called by your Discord username or nickname, depending on which is more recognizable."
        }, --why is this busting the box
        {
            img = M.images.loafstand, 
            dial="Unless you provide me with a different image, your sprite will resemble your Discord avatar."
        },
        {
            img = M.images.loaf, 
            dial="(Personally, I look forward to drawing the <c033,190,033>Pugman</c>.)"
        },
        {
            img = M.images.loafshrug, 
            dial="And, well, let's see where this story takes us!"
        },
        {
            img = M.images.loaf, 
            dial="That's all for now, I think."
        },
        {
            img = M.images.loafwave, 
            dial="Until later!"
        },
        {
            dial="To be continued..."
        }
    },
}

return M