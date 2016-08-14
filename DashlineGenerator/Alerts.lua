local Alerts = { strs = {"Program has begun."} }
Alerts.font = love.graphics.newFont( "saxmono.ttf", 14)
Alerts.min = 75
function Alerts:add(str)
    self.strs[#self.strs+1] = str
end
function Alerts:drawUp(x,y)
    love.graphics.setFont(self.font)
    for i = 0, #self.strs-1 do
        love.graphics.setColor(math.min(Alerts.min,15*i),math.min(Alerts.min,15*i),math.min(Alerts.min,15*i))
        love.graphics.print(self.strs[#self.strs-i],x,y-16*i)
    end
end
function Alerts:drawDown(x,y)
    love.graphics.setFont(self.font)
    for i = 0, #self.strs-1 do
        love.graphics.setColor(math.min(Alerts.min,15*i),math.min(Alerts.min,15*i),math.min(Alerts.min,15*i))
        love.graphics.print(self.strs[#self.strs-i],x,y+16*i+16)
    end
end
function Alerts:clear()
    self.strs = {}
end
return Alerts