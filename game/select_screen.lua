local M = {}

M.scenes = {
    {scene=1,text={"OPENING"}}, --supports up to 3 lines
    {scene=2,text={"INTRO"}},
    {scene=4,text={"CHAPTER 1","MR. FLIBBLE","NEW!"}},
    {scene=nil,text={"???"}},
    {scene=nil,text={"???"}},
    {scene=nil,text={"???"}},
    {scene=nil,text={"???"}},
    {scene=nil,text={"???"}},
} --list of jumpable scenes -TODO - custom rendered text

M.x = 1 --left to right
M.y = 1 --top to down

M.xmax = 2
M.ymax = 4

function M.arrow(key)
    if key == "left" and M.x ~= 1 then --maybe allow for wasd or vimkeys or smth
        M.x = M.x - 1
    elseif key == "right" and M.x ~= M.xmax then
        M.x = M.x + 1
    elseif key == "up" and M.y ~= 1 then
        M.y = M.y - 1
    elseif key == "down" and M.y ~= M.ymax then
        M.y = M.y + 1
    end --don't forget to implement enter

end

function M.draw()
    local x = 0
    local y = 0
    --20px on the side, 40px between
    for i,s in ipairs(M.scenes) do
        --[[local xpos = 20 + x * 
        (760) -- 
        / (M.xmax)
        local ypos = 20 + y * (540/M.ymax)]]
        local xlen = math.floor((760 - 30*(M.xmax - 1)) / (M.xmax))
        local ylen = math.floor((540 - 30*(M.ymax - 1)) / (M.ymax))
        local xpos = math.floor(20 + x*(xlen+30))
        local ypos = math.floor(20 + y*(ylen+30)) --maybe stop hardcoding some of this :|
        if x + 1 == M.x and y+1 == M.y then
            love.graphics.setColor(248/255,222/255,52/255,1) --store colors somewhere
        else
            love.graphics.setColor(1,1,1,1)
        end
        love.graphics.setLineWidth(4) --YEEEES - but stick to even values
        love.graphics.rectangle("line", xpos,ypos,xlen,ylen)
        love.graphics.setColor(1,1,1,1)
        for n,t in ipairs(s.text) do
            love.graphics.printf(s.text[n],xpos,ypos+20+(n-1)*24,xlen,"center")
        end
        if x ~= M.xmax-1 then
            x = x + 1 
        else
            x = 0
            y = y + 1 --no pagination 4 u
        end
    end
end

function M.scene()
    return M.scenes[M.x + (M.y-1) * M.xmax].scene
end

return M
