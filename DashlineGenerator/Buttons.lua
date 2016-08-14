local Buttons = {}
Buttons.font = love.graphics.newFont( "saxmono.ttf", 14)

function Buttons:add(text,x,y,w,h,func)
    w = w or 6 + 8*text:len()
    Buttons[#Buttons + 1] = {text,x,y,w,h,func}
end
function Buttons:update()
    mx, my = love.mouse.getPosition()
    for i = 1, #Buttons do
        if mx >= Buttons[i][2] and mx <= Buttons[i][2]+Buttons[i][4] and my >= Buttons[i][3] and my <= Buttons[i][3]+Buttons[i][5] then
            Buttons[i][6]()
        end  
    end
end
function Buttons:draw()
    love.graphics.setFont(self.font)
    for i = 1, #Buttons do
        x = Buttons[i][2]
        y = Buttons[i][3]
        text = Buttons[i][1]
        h = Buttons[i][5]
        w = Buttons[i][4]
        love.graphics.setColor(150,150,150)
        love.graphics.rectangle('fill',x,y,w,h)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',x,y,w,h)
        love.graphics.setColor(0,0,0)
        love.graphics.print(text,x+3,y+5)
    end
end
function Buttons.width(text)
    return 6 + 8*text:len()
end
return Buttons