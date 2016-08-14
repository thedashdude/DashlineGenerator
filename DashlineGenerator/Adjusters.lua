local Adjusters = { values = {}, data = {}, x = 0, y = 0, dy = 60 }
function Adjusters:get(name)
    for i = 1, #self.values do
        if self.values[i][1] == name then
            return self.values[i][2]
        end
    end
end
function Adjusters:add(name,min,max,increment,default)
    self.values[#self.values + 1] = {name,default}
    self.data[name] = {min,max,increment}
end
function Adjusters:draw(x,y)
    self.x = x
    self.y = y
    love.graphics.setColor(0,0,0)
    i = 0
    for key, value in ipairs(self.values) do
        i = i + 1
        love.graphics.print(self.values[key][1] .. ": ",x,y+i*self.dy-16)
        love.graphics.print(value[2],x+40,y+i*self.dy)
        love.graphics.print("[ "..self.data[self.values[key][1]][1].." - "..self.data[self.values[key][1]][2].." ]", x+36, y+i*self.dy+16)
        love.graphics.rectangle('line',x,y+i*self.dy+16,16,16)
        love.graphics.print('-',x+4,y+i*self.dy+16)
        love.graphics.rectangle('line',x+16,y+i*self.dy+16,16,16)
        love.graphics.print('+',x+22,y+i*self.dy+16)
        love.graphics.rectangle('line',x-5,y+i*self.dy-16-3,105,self.dy)
    end
end
function Adjusters:update(clicked)
    love.graphics.setColor(0,0,0)

    for i = 1, #self.values do

        mx, my = love.mouse.getPosition()
        key = self.values[i][1]
        value = self.values[i][2]
        if Adjusters:between(mx, self.x, self.x + 16) and Adjusters:between(my, self.y+i*self.dy+16, self.y+i*self.dy+32) and Adjusters:between(value - self.data[key][3],self.data[key][1],self.data[key][2]) then
            self.values[i][2] = value - self.data[key][3]
        elseif Adjusters:between(mx, self.x+16, self.x + 32) and Adjusters:between(my, self.y+i*self.dy+16, self.y+i*self.dy+32) and Adjusters:between(value + self.data[key][3],self.data[key][1],self.data[key][2])  then
            self.values[i][2] = value + self.data[key][3]
        end
    end
end
function Adjusters:between(k,min,max)
    if k >= min and k <= max then
        return true
    end
    return false
end
return Adjusters