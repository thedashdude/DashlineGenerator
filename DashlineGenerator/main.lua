--Hotline Generator Gui

--[[
Notes on functionality: 
all rooms are placed on coords that are multiples of 3, this makes the smallest rooms still reasonable
and allows enemies to placed on coords which are 1 more than a multiple of 3, meaning all enemies will never be placed on walls.
Doors are placed in a similar manner, horizontal doors are placed on multiple of 3s ys and 1 more than a multiple of 3 x, meaning they are never too close to a vertical wall
vertical doors have similar placeent technique

floors, walls and enemies have coords simplified for most of the program. only in the functions that actually place them are the coords multiplied by 32 to put them in the same scale as the size of the walls and collision boxes

the building is alwasy from (0,0) to (30,18)
that is in the games coords from (0,0) to (960,576).
x32 as mentioned above

the format of the level files are explained in a different file

]]

--[[

starters:
empty
+
-
|






]]




--Starters are rooms placed before the normal room placing algorithm that are not normally possible but add a nice variety to levels.
function doStarter()
    ratioSum = Adjusters:get('+ ratio') + Adjusters:get('- ratio') + Adjusters:get('| ratio') + Adjusters:get('* ratio') + Adjusters:get('O ratio')
    n = math.floor(r(1,ratioSum))

    --remember where you placed it so enemies dont overlap
    if n<=Adjusters:get('+ ratio') then
        plusStarter()
    elseif n<=Adjusters:get('+ ratio')+Adjusters:get('- ratio') then
        dashStarter()
    elseif n<=Adjusters:get('+ ratio')+Adjusters:get('- ratio')+Adjusters:get('| ratio') then
        pipeStarter()
    elseif n<=Adjusters:get('+ ratio')+Adjusters:get('- ratio')+Adjusters:get('| ratio')+Adjusters:get('* ratio') then
        ringStarter()
    else
        --no starter
    end
end

--Adds two hallways in the shape of a plus
function plusStarter()
    x = math.floor(r(1,Adjusters:get('width')/3-2))*3 
    y = math.floor(r(1,Adjusters:get('height')/3-2))*3 
    box(0,0,x,y,1,true)
    box(0,y+3,x,Adjusters:get('height'),1,true)
    box(x+3,0,Adjusters:get('width'),y,1,true)
    box(x+3,y+3,Adjusters:get('width'),Adjusters:get('height'),1,true)



    placeEnemy(x+1,y+2,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
    if r() > 0.25 then
        placeEnemy(x,y+1,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
    end
    for i = 1, Adjusters:get('width')/3 do
        enemyTable[i][y/3+1] = 1
    end
    for j = 1, Adjusters:get('height')/3 do
        enemyTable[x/3+1][j] = 1
    end

    DashSolids:set(nil,x,0,3,Adjusters:get('height'))
    DashSolids:set(nil,0,y,Adjusters:get('width'),3)
end

--Adds a hallway horizontally
function dashStarter()
    x=0
    y = math.floor(r(1,Adjusters:get('height')/3-2))*3 
    box(0,y,Adjusters:get('width'),y+3)
    DashSolids:set(nil,0,y,Adjusters:get('width'),3)
end

--Adds a hallway vertically
function pipeStarter()
    x = math.floor(r(1,Adjusters:get('width')/3-2))*3
    y = 0
    box(x,0,x+3,Adjusters:get('height'))
    DashSolids:set(nil,x,0,3,Adjusters:get('width'))
end

--Adds a ring shaped hallway like thing
function ringStarter()
    x, y = math.floor(r(0,Adjusters:get('width')/3-3))*3, math.floor(r(0,Adjusters:get('height')/3-3))*3
    w, h = math.floor(r(3,(Adjusters:get('width') - x)/3 ))*3, math.floor(r(3,(Adjusters:get('height') - y)/3 ))*3
    box(x,y,x+w,y+h,1,true)
    box(x+3,y+3,x+w-3,y+h-3,1)
    DashSolids:set(nil,x,y,3,h)
    DashSolids:set(nil,x+w-3,y,3,h)
    DashSolids:set(nil,x,y,w,3)
    DashSolids:set(nil,x,y+h-3,w,3)

    placeEnemy(x+1,y+2,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
    if r() > 0.25 then
        placeEnemy(x+2,y+1,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
    end
    for i = x/3+1, x/3+w/3 do
        enemyTable[i][y/3+1] = 1
        enemyTable[i][y/3+h/3] = 1
    end
    for j = y/3+1, y/3+h/3 do
        enemyTable[x/3+1][j] = 1
        enemyTable[x/3+w/3][j] = 1
    end
end

--Converts a table to a string with each entry on a new line
function makeString(tab)
    str = ''
    for i = 1, #tab do 
        str = str .. tab[i] .. '\n'
    end
    return str
end

--Used to make sure every room has an enemy
function floodEnemyTable(x,y)
    if enemyTable[x][y] == 0 then
        enemyTable[x][y] = 2
    else
        return 0 
    end
    for k = 1, 11*7 do
        for i = 1, Adjusters:get('width')/3 do
            for j=1,Adjusters:get('height')/3 do
                if (enemyTable[i][j+1] == 2 or enemyTable[i][j-1] == 2 or enemyTable[i+1][j] == 2 or enemyTable[i-1][j] == 2) and enemyTable[i][j] ~= 1 then
                    enemyTable[i][j] = 2
                end
            end
        end
    end
    for i = 1, Adjusters:get('width')/3 do
        for j=1,Adjusters:get('height')/3 do
            if enemyTable[i][j] == 2 then
                enemyTable[i][j] = 1
            end
        end
    end
end

--Checks to see if every room has an enemy
function enemyTableFull()
    for i = 1, Adjusters:get('width')/3 do
        for j=1,Adjusters:get('height')/3 do
            if enemyTable[i][j] == 0 then
                return false
            end
        end
    end
    return true
end

--Places an enemy if the room doesn't have one
function addEnemyTable()
    for i = 1, Adjusters:get('width')/3 do
        for j=1,Adjusters:get('height')/3 do
            if enemyTable[i][j] == 0 and r() > 0.95 then
                floodEnemyTable(i,j)
                placeEnemy(i*3-2,j*3-2,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
                if r() > 0.25 then
                    placeEnemy(i*3-1,j*3-2,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
                end
            end
        end
    end
end

--The function that actually generates the levels, all level generation functions are only ever called from here
function generator()
    --Reset the data from the previous level
        DashSolids.Solids = {}
        obj = PlayerObjs[Player]
        wllTable = {}
        objTable = {}
        objTable[1] = obj
        tlsTable = {}
        floodTable = {}
        for i = 0, Adjusters:get('width') do
            floodTable[i] = {}
            for j=0,Adjusters:get('height') do
                floodTable[i][j] = 0
            end
        end
        rooms = Adjusters:get('rooms')
        mafia = math.floor(r(Adjusters:get('minMafia'),Adjusters:get('maxMafia')))
        mafiaCords = {}
        boxLocations = {}
        enemyTable = {}
        for i = 0, Adjusters:get('width')/3+1 do
            enemyTable[i] = {}
            for j=0,Adjusters:get('height')/3+1 do
                enemyTable[i][j] = 0
            end
        end
    width = Adjusters:get('width')
    height = Adjusters:get('height')
    -- corners are kept track of with q, e, z, and c representing the different corners. 
    done = {}
    --[[
    they represent them like this:
    q e
    
    z c
    that is, q is the top left, e is top right, z bottom left, c bottom right
    ]]

    --this keeps track of if the corners have had rooms placed on them yet.
    done.q = false
    done.e = false
    done.z = false
    done.c = false

    --place the rooms, with a 50% chance to try to place a corner room and a 50% chance to place a float room, that is one that does not touch the edges of the building
    --plusStarter()
    --dashStarter()
    --pipeStarter()
    --ringStarter()
    doStarter()



    while rooms > 0 do
        if r() > 0.5 then
            corner()
        else
            float()
        end
    end
    
    --place all the enemies
    while mafia > 0 do
        mafia = mafia - 1
        --random coords that will not interset with walls
        x,y = math.floor(r(0,width/3-1))*3+1,math.floor(r(0,height/3-1))*3+1

        --make sure you do not place an enemy on one that is there already
        shouldPlace = true
        i = 200
        while not canPlaceMafia(x,y) do
            x,y = math.floor(r(0,width/3-1))*3+1,math.floor(r(0,height/3-1))*3+1
            i = i - 1
            if i <= 0 then
                shouldPlace = false
                break
            end
        end

        --place a random enemy at x,y
        if shouldPlace then
            placeEnemy(x,y,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
            floodEnemyTable((x-1)/3+1,(y-1)/3+1)
        end
    end
    while not enemyTableFull() do 
        addEnemyTable()
    end
    --placing rooms adds entries to boxLocations
    --we use these to place doors on rooms
    for i = 1, #boxLocations do
        makeDoorInBox(boxLocations[i][1],boxLocations[i][2],boxLocations[i][3],boxLocations[i][4], boxLocations[i][5])
    end

    --place the building as one huge room around the others and then place a door by the botton left by the car
    box(0,0,width,height,1)
    removeWallsAt(1,height,'H')
    doorFunctions['addHDoor'](1,height)
    
    --this makes sure all rooms are reachable
    while not checkFlood() do
        fixFlood()
    end

    --the level is done
    Alerts:add("Successfuly generated level.")
    for i = 1, Adjusters:get('width')/3 do
        str = ""
        for j=1,Adjusters:get('height')/3 do
            str = str .. " " .. enemyTable[i][j]
        end
        --prit(str)
    end
end

--tests to see if an enemy has been placed on (x,y) before
function canPlaceMafia(x,y)
    for i=1,#mafiaCords do
        if x == mafiaCords[i][1] and y == mafiaCords[i][2] then
            return false
        end
    end
    return true
end

--tries to place a corner room
function corner()
    mafiaMode = 0
    --choose where the room will be
    --xend and yend are one set of coords, the other will be deterimined by choosing a corner of the building
    xend,yend = math.floor(r(1,Adjusters:get('width')/3-1))*3, math.floor(r(1,Adjusters:get('height')/3-1))*3
    xstart, ystart = 0,0
    direc = nil
    max = 14
    --pick a corner that has not been chosen before, mark is as having been chosen and set the xstart and ystart coords apropriately
    if math.random() > 0.75 and not done.q then
        xstart, ystart = 0,0
        done.q = true
        direc = 'q'
    elseif math.random() > 2/3 and not done.e then
        xstart, ystart = Adjusters:get('width'),0
        done.e = true
        direc = 'e'
    elseif math.random() > 1/2 and not done.c then
        xstart, ystart = Adjusters:get('width'),Adjusters:get('height')
        done.c = true
        direc = 'c'
    elseif not done.z then 
        xstart, ystart = 0,Adjusters:get('height')
        done.z = true
        direc = 'z'
        max = 10
        mafiaMode = 2
    else
        --if there are no open corners, leave this function
        rooms = rooms - 1
        return 0
    end

    --makeCoordsWH takes two pairs of coords and returns 4 values, a top left x and y and a width and height
    xLeft, yTop, w,h  = makeCoordsWH(xend,yend,xstart,ystart)

    --lim makes sure you dont spend too long checking random rooms to see if they work
    lim = 0

    --DashSolids:checkCollision(xLeft,yTop,w,h) tests to see if the room intersects a previously placed room
    --(w^2 + h^2)^0.5 > 14 makes sure the room is of a reasonable size by limiting the diagonal
    --( (w^2 + h^2)^0.5 < 5 and r()<0.66 ) makes the loop try again 2/3s of time if the room is really tiny, because tiny rooms aren't very fun
    while DashSolids:checkCollision(xLeft,yTop,w,h) or (w^2 + h^2)^0.5 > max or ( (w^2 + h^2)^0.5 < 5 ) do
        -- if any of those conditions are met the loop repicks coords and tries again
        xend,yend = math.floor(r(1,Adjusters:get('width')/3-1))*3, math.floor(r(1,Adjusters:get('height')/3-1))*3
        xLeft, yTop, w,h  = makeCoordsWH(xend,yend,xstart,ystart)
        --if you have tried 100 times, leave so generation doesn't take forever
        lim = lim + 1
        if lim > 100 then
            rooms = rooms - 1
            return 0
        end
    end

    --This records the rooms placement in DashSolids so other rooms are checked to see if they collide with this one
    DashSolids:set(nil,xLeft, yTop, w, h)

    --place this room as walls
    box(xstart,ystart,xend,yend,mafiaMode)

    --you have placed a room, record this
    rooms = rooms - 1
end

--takes two sets of coords and returns it in the form x,y,width,height
function makeCoordsWH(x1,y1,x2,y2)
    x = math.min(x1,x2)
    y = math.min(y1,y2)
    return x, y, math.abs(x1-x2), math.abs(y1-y2)
end

--place a floating room, that is one that doesn't touch the outside walls of the building
function float( ... )
    --pick to coords for the room
    x, y = math.floor(r(1,Adjusters:get('width')/3-2))*3, math.floor(r(1,Adjusters:get('height')/3-2))*3
    x2, y2 = math.floor(r(x/3+1,Adjusters:get('width')/3-1))*3, math.floor(r(y/3+1,Adjusters:get('height')/3-1))*3

    --determine the width and height of the room
    w,h = x2-x,y2-y

    --the same loop as in corner(), makes sure the room is reasonable 
    lim = 0
    while DashSolids:checkCollision(x,y,w,h) or (w^2 + h^2)^0.5 > 14 or ( (w^2 + h^2)^0.5 < 5 )  do
        lim = lim + 1
        if lim > 100 then
            rooms = rooms - 1
            return 0
        end
        x, y = math.floor(r(1,Adjusters:get('width')/3-2))*3, math.floor(r(1,Adjusters:get('height')/3-2))*3
        x2, y2 = math.floor(r(x/3+1,Adjusters:get('width')/3-1))*3, math.floor(r(y/3+1,Adjusters:get('height')/3-1))*3

        --determine the width and height of the room
        w,h = x2-x,y2-y
    end

    --place the room, record it in DashSolids, and decrement the number of rooms left to place
    box(x,y,x+w,y+h)
    DashSolids:set(nil,x,y,w,h)
    rooms = rooms - 1
end

--this places a room, or box, at the specified coords. direc is only really used to tell the box if it is a corner
function box(x1,y1,x2,y2,enemyMode,noBg)
    --enemyMode:
    --1 = no enemies
    --2 = melee enemies
    --take the coords and make them easier to work with finding the larger and smaller of the two values of each of x and y
    xS = math.min(x1,x2) --smaller x
    xL = math.max(x1,x2) --larger x
    yS = math.min(y1,y2) --smaller y
    yL = math.max(y1,y2) -- larger y

    --the amount of glass left to place in a sequence of glass. if it is zero, as it mostly will be, dont place glass
    glass = 0

    --the percent chance placing a single wall will begin a glass sequence. I am not a glass fan, so I have this as 1
    --Adjusters:get('glass%')

    --place the walls on the horizontal y1 side
    for i = xS, xL-1 do

        --if glass is zero (or less) place walls as normal
        if glass <= 0 then
            --place the wall
            addHWall(i,y1)
            --with Adjusters:get('glass%') chance begin a glass sequence of 2-5 glass inclusive
            if math.floor(r(1,100)) <= Adjusters:get('glass%') then
                glass = math.floor(r(2,5))
            end
        else
            --if in a glass sequence place glass and decrease the glass left to place
            addHGlass(i,y1)
            glass = glass - 1
        end
    end
    --reset the amount of glass to zero
    glass = 0

    --all the following for loops do the same for different sides of the room
    --horizontal y2 side
    for i = xS, xL-1 do
        if glass <= 0 then
            addHWall(i,y2)
            if math.floor(r(1,100)) <= Adjusters:get('glass%') then
                glass = math.floor(r(2,5))
            end
        else
            addHGlass(i,y2)
            glass = glass - 1
        end
    end
    glass = 0

    --vertical x1 side
    for i = yS, yL-1 do
        if glass <= 0 then
            addVWall(x1,i)
            if  math.floor(r(1,100)) <= Adjusters:get('glass%') then
                glass = math.floor(r(2,5))
            end
        else
            addVGlass(x1,i)
            glass = glass - 1
        end
    end
    glass = 0

    --vertical x2 side
    for i = yS, yL-1 do
        if glass <= 0 then
            addVWall(x2,i)
            if math.floor(r(1,100)) <= Adjusters:get('glass%') then
                glass = math.floor(r(2,5))
            end
        else
            addVGlass(x2,i)
            glass = glass - 1
        end
    end

    --n and n2 choose the flooring that the room will be filled with (n is the x on the sprite sheet, n2 is the y)
    n = math.floor(r(0,2))*4
    n2 = math.floor(r(0,10))
    if not noBg then
        --fill in the box with floor
        for xi = xS, xL -1 do
            for yi = yS, yL-1 do
                addFloor(xi,yi,n,n2)
            end
        end
    end

    --mafia will be greater than 0 on all boxes/rooms but the building that surrounds them all.
    --this adds the box location to the table that the doors will be placed from for all rooms but the building, which has a special way of getting doors.
    if mafia > 0 then
        --direc makes sure corner rooms dont have doors into the outside
        boxLocations[#boxLocations+1] = {xS,yS,xL,yL,direc}
        --50% chance to have 2 doors
        if r() > 0.5 then
            boxLocations[#boxLocations+1] = {xS,yS,xL,yL,direc}
        end
    end

    -- for all placed rooms but the building, place two enemies in them
    if enemyMode ~= 1 then
        for i = xS/3+1, xL/3 do
            for j=yS/3+1, yL/3 do
                enemyTable[i][j] = 1
            end
        end
        --corner z is the one jacket must enter through, so if this room is tha one, enemy spawing is different
        if enemyMode ~= 2 then
            placeEnemy((xS+xL)/2,(yS+yL)/2-0.5,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
            if r() > 0.25 then
                placeEnemy((xS+xL)/2,(yS+yL)/2+0.5,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),Adjusters:get('gunRand#'),Adjusters:get('gunPatrol#'))
            end
        else
            -- the two enemies placed have 0% chance of being gun carrying enemies
            placeEnemy((xS+xL)/2,(yS+yL)/2-0.5,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),0,0)
            if r() > 0.5 then
                placeEnemy((xS+xL)/2,(yS+yL)/2+0.5,addMeleeRandomEnemy,addMeleePatrolEnemy,addGunRandomEnemy,addGunPatrolEnemy,Adjusters:get('meleeRand#'),Adjusters:get('meleePatrol#'),0,0)
            end
        end
    end
end

--given a rooms coords, place a door randomly on it
function makeDoorInBox(xS,yS,xL,yL)
    -- holder values for x and y
    x,y = 0,0
    dir = ''
    directions = 'qezc'
    n = math.floor(r(1,4))
    --if specified direc stays the same, otherwise it is randomy picked from the string above, "qezc"
    direc = direc or directions:sub(n,n)

    --depending on what corner the room is in, or randomly if it isn't, determine the coords of the door
    --the door isn't placed on the buildings walls, so q cant have doors on the top or left wall, e cant have doors on the top or right wall and so on
    if direc == 'q' then
        if r() >= 0.5 then
            --dir is the orientation of the door, V is vertical and H is horizontal
            dir = 'V'
            --xL is the larger of the two xs, or the right side
            x = xL
            --one more than a multiple of 3 from yS to yL
            y = math.floor(math.floor(r(yS+1,yL-1))/3)*3+1
        else
            dir = 'H'
            y = yL
            x = math.floor(math.floor(r(xS+1,xL-1))/3)*3+1
        end
    end
    -- all the other ifs do the same thing
    if direc == 'e' then
        if r() >= 0.5 then
            dir = 'V'
            x = xS
            y = math.floor(math.floor(r(yS+1,yL-1))/3)*3+1
        else
            dir = 'H'
            y = yL
            x = math.floor(math.floor(r(xS+1,xL-1))/3)*3+1
        end
    end
    if direc == 'z' then
        if r() >= 0.5 then
            dir = 'V'
            x = xL
            y = math.floor(math.floor(r(yS+1,yL-1))/3)*3+1
        else
            dir = 'H'
            y = yS
            x = math.floor(math.floor(r(xS+1,xL-1))/3)*3+1
        end
    end
    if direc == 'c' then
        if r() >= 0.5 then
            dir = 'V'
            x = xS
            y = math.floor(math.floor(r(yS+1,yL-1))/3)*3+1
        else
            dir = 'H'
            y = yS
            x = math.floor(math.floor(r(xS+1,xL-1))/3)*3+1
        end
    end

    --removes the walls that the door will replace
    removeWallsAt(x,y,dir)

    --place the door, using dir to determine the function to be called
    doorFunctions['add'..dir..'Door'](x,y)

    --floodTable will be explained later, towards the bottom with the associated functions
    floodTable[x][y] = 0
end

--r is a function that gets a random number.
--if no parameters are passed it returns a number from [0,1)
--otherwise a number (non-integer) from [min,max+1)
--this means math.floor(r(min,max)) returns an integer from min to max inclusive
function r(min,max)
    min = min or 0
    max = max or 0
    return min+math.random()*(max+1-min)
end

--add flooring at x,y with sprite on the sprite sheet k,l
function addFloor(x,y,k,l)
    --floors sprites are 16*16, so to have this function work on the same scale as the other functions it must place four floor sprites
    k = k or 0
    l = l or 0
    l = l * 16
    k = k * 16
    tlsTable[#tlsTable+1] = {2,k,l,(x*32),(y*32),1001}
    tlsTable[#tlsTable+1] = {2,k,l,(x*32)+16,(y*32)+16,1001}
    tlsTable[#tlsTable+1] = {2,k,l,(x*32),(y*32)+16,1001}
    tlsTable[#tlsTable+1] = {2,k,l,(x*32)+16,(y*32),1001}
end

--add a horizontal wall at x,y ( this means going to right of x,y )
function addHWall(x,y)
    --remove any walls that would be there
    removeWallsAt(x,y,'H')
    wllTable[#wllTable+1] = {7,(x*32),(y*32),62,0}
    floodTable[x][y] = 2
end

--add a vertical wall at x,y ( this means going down form x,y )
function addVWall(x,y)
    --remove any walls that would be there
    removeWallsAt(x,y,'V')
    wllTable[#wllTable+1] = {8,(x*32),(y*32),63,0}
    floodTable[x][y] = 2
end

--add a random moving melee enemy at x,y
--has weapon 73 or 74 (club or knife)
function addMeleeRandomEnemy(x,y)
    objTable[#objTable+1] = {10,(x*32),(y*32),getBat(),0,getPattern(3),0}
end

--add a patroling melee enemy at x,y
--has weapon 73 or 74 (club or knife)
function addMeleePatrolEnemy(x,y)
    objTable[#objTable+1] = {10,(x*32),(y*32),getBat(),0,getPattern(4),0}
end

--add a patroling gun enemy at x,y
--has weapon a weapon from {70,75,68,69,1500}
function addGunPatrolEnemy(x,y)
    objTable[#objTable+1] = {10,(x*32),(y*32),getGun(),0,getPattern(2),0}
end

--add a random moving gun enemy at x,y
--has weapon a weapon from {70,75,68,69,1500}
function addGunRandomEnemy(x,y)
    objTable[#objTable+1] = {10,(x*32),(y*32),getGun(),0,getPattern(1),0}
end
function getPattern(n)
    return EnemyData[SelectedEnemy].Pattern[n]
end

--pick a gun for a gun enemy
function getGun( ... )
    --{70,75,68,69,1500} corespond to (M16, Silencer, Double Barrel, Shotgun, Kalashnikov)
    guns = EnemyData[SelectedEnemy].Guns
    return guns[math.floor(r(1,#guns))]
end

--pick a melee weapon for melee enemy
function getBat()
    bats = EnemyData[SelectedEnemy].Bats
    return bats[math.floor(r(1,#bats))]
end

function placeFat(x,y)
    objTable[#objTable+1] = {10,(x*32),(y*32),EnemyData[SelectedEnemy].Fat[1],180,EnemyData[SelectedEnemy].Fat[2],0}
end

--place an enemy at x,y by calling a function a,b,c, or d with the provided ratios
function placeEnemy(x,y,a,b,c,d,aRatio,bRatio,cRatio,dRatio)
    ratioSum = aRatio+bRatio+cRatio+dRatio
    n = math.floor(r(1,ratioSum))

    --remember where you placed it so enemies dont overlap
    mafiaCords[#mafiaCords+1] = {x,y}
    if math.floor(r(1,100)) <= Adjusters:get('fat%') and SelectedEnemy ~= 6 then
        placeFat(x,y)
    else
        if n<=aRatio then
            a(x,y)
        elseif n<=bRatio+aRatio then
            b(x,y)
        elseif n<=cRatio+bRatio+aRatio then
            c(x,y)
        else
            d(x,y)
        end
    end
end

--add horizontal glass at x,y, removing any wall that may have been there before
function addHGlass( x,y )
    removeWallsAt(x,y,'H')
    wllTable[#wllTable+1] = {683,(x*32),(y*32),1997,0}
    floodTable[x][y] = 2
end

--add vertical glass at x,y, removing any wall that may have been there before
function addVGlass( x,y )
    removeWallsAt(x,y,'V')
    wllTable[#wllTable+1] = {682,(x*32),(y*32),1996,0}
    floodTable[x][y] = 2
end

--[[
the flood functions and flood table are used to make sure you can reach all rooms.
any wall or glass placed marks is position on the floodTable with a 2
everything else is by default a 0

floodTable has x values from 0 to 30 and y from 0 to 18

flood table looks like 

2222222222222222222
2000000000000000002
2000000002000000002
2000000002000000002
2000000000000000002
2000000002000000002
2222222222222022222
2000000000000002002
2002002000000002002
2002022022222220002
2000000002000000002
2002000002000000002
2002222222002222002
2000000000002002002
2002000002002002002
2002222222222020002
2002000000000000002
2002000002002000002
2002000002002000002
2002000002000000002
2002000002002000002
2002222222222022222
2000002000000000002
2000002000000002002
2222022222222222002
2000000000000002002
2000000000002002002
2000000000002222002
2000000000000002002
2000000000002002002
2222222222222222220

]]

--checkFlood sets floodTable[1][1] to 1 from 0 and then sets all 0s adjacent to 1s to 1s
--and repeats this until flood table is all 1s and 2s or until it has filled all it could
--this is the titular 'flooding'
--if anything is still a 0 the building fails the checkFlood and a door must
--be placed so the unflooded rooms can be reached
function checkFlood()
    floodTable[1][1] = 1
    --flood the table
    for k = 0, 29*17 do
        for i = 1, Adjusters:get('width')-1 do
            for j = 1, Adjusters:get('height')-1 do
                flood(i,j)
            end
        end
    end

    --test to see if everything flooded
    for i = 1, Adjusters:get('width')-1 do
        for j = 1, Adjusters:get('height')-1 do
            if floodTable[i][j] == 0 then
                return false
            end
        end
    end
    return true
end

--sets floodTable[x][y] to 1 if it is next to another 1 and isn't a 2
--is used by checkFlood()
function flood(x,y)
    if floodTable[x][y] == 2 then
        return 0
    end

    if floodTable[x-1][y] == 1 or floodTable[x+1][y] == 1 or floodTable[x][y-1] == 1 or floodTable[x][y+1] == 1 then
        floodTable[x][y] = 1
    end
end

--called if the building fails checkFlood()
--goes through all cells in floodTable and calls checkTransition() on them
--by calling this until checkFlood succeeds the level is garunteed to have all rooms be reachable
function fixFlood( ... )
    for i = 1, Adjusters:get('width')-1 do
        for j = 1, Adjusters:get('height')-1 do
            if checkTransition(i,j) then
                return 0
            end
        end
    end
end

--checkTransition checks if a cell is a wall with flooded area on one side and unflooded area on the other
--if the cell is and its coords are acceptable as doors (see Notes on Functionality) it has a chance of
--placing a door at x,y 
function checkTransition(x,y)
    dir = ''
    if not (x%3 + y%3 == 1) then
        return false
    end
    if floodTable[x][y] == 2 and floodTable[x-1][y]+floodTable[x+1][y] == 1 then
        dir = 'V'
    elseif floodTable[x][y] == 2 and floodTable[x][y-1]+floodTable[x][y+1] == 1 then
        dir = 'H'
    else
        return false   
    end


    if math.floor(r(1,100)) <= 5 then
        removeWallsAt(x,y,dir)
        doorFunctions['add'..dir..'Door'](x,y)
        floodTable[x][y] = 1
        return true
    end
    return false
end

--looks through wllTable and removes any glass or walls with the specified coords and direction
--used primarily for clearing room for doors
function removeWallsAt(x,y,dir)
    dir = dir or 'H'
    i = 1
    while i <= #wllTable do
        --not really an easier way to write this if, but it is ugly, just checks for the wall or glass text corresponding to the provided direction
        if (dir == 'H' and matchWall(i,x*32,y*32,1)) or (dir == 'V' and matchWall(i,x*32,y*32,0)) then
            table.remove(wllTable,i)
            i= i-1
        end
        i = i + 1
    end

    i = 1
    while i <= #objTable do
        --not really an easier way to write this if, but it is ugly, just checks for the wall or glass text corresponding to the provided direction
        if (dir == 'H' and matchDoor(i,x*32,y*32,0)) or (dir == 'V' and matchDoor(i,x*32,y*32,1)) then
            table.remove(objTable,i)
            i = i - 1
        end
        i = i + 1
    end
end
function matchWall(i,x,y,odd)
    if ( wllTable[i][1]%2 == odd%2 ) and ( x == wllTable[i][2] ) and ( y == wllTable[i][3] ) then
        return true
    end
    return false
end
function matchDoor(i,x,y,odd)
    if ( objTable[i][1]%2 == odd%2 ) and ( x == objTable[i][2] ) and ( y == objTable[i][3] ) and ( (objTable[i][1] == 25)or(objTable[i][1] == 26) ) then
        return true
    end
    return false
end




--These are functions for placing doors, placed in a table so that they can be called like this:
--doorFunctions["addVDoor"](x,y)
--which allows you to choose what function to call with string manipulation
doorFunctions = {}
function doorFunctions.addVDoor(x,y)
    --obj = obj .. '25\n' .. (x*32).. '\n' .. (y*32).. '\n' .. '91' .. '\n0\n0\n0\n'
    objTable[#objTable+1] = {25,(x*32),(y*32),91,0,0,0}
end
function doorFunctions.addHDoor(x,y)
    --obj = obj .. '26\n' .. (x*32).. '\n' .. (y*32).. '\n' .. '92' .. '\n0\n0\n0\n'
    objTable[#objTable+1] = {26,(x*32),(y*32),92,0,0,0}
end

function love.load()
    
    --Just data the program needs to know to work with HLM2
    PlayerRange = {1,11}
    Player = 1
    PlayerNames = {"Jacket","Biker","Cobra","Cop","Fans","Hammer","Henchman","Rat","Soldier","Son","Writer"}
    EnemyNames = {"Mafia","Police","Gang","Soldiers","Columbians","Guards"}

    PlayerObjs = {  {1583,63,740,4154,0,2345,0} , 
                    {1582,99,691,4080,90,2334,0, 1583,63,740,4094,0,2347,0} ,
                    {1583,63,740,1432,0,870,0},
                    {1582,99,691,1243,90,763,0, 1583,63,740,1258,0,764,0},
                    {1583,63,740,392,0,236,0},
                    {1582,99,691,4162,90,2387,0, 1583,63,740,4271,0,2394,0},
                    {1582,99,691,1786,90,1067,0, 1583,63,740,1933,0,1147,0, 2401,86,677,1458,156.8408203125,880,0},
                    {1582,99,691,2394,90,1225,0, 1583,63,740,3485,0,2040,0},
                    {1582,99,691,533,90,324,0, 1583,63,740,2225,0,1341,0},
                    {1583,63,740,2439,0,1366,0},
                    {1582,99,691,2022,90,1048,0, 1583,63,740,1731,0,1049,0}
                }
    obj = PlayerObjs[Player]
    EnemyOptions = { 
                    {1}, 
                    {1}, 
                    {1}, 
                    {2,3,5}, 
                    {1,3}, 
                    {1,2,3,5,6}, 
                    {3}, 
                    {1}, 
                    {4}, 
                    {5,6}, 
                    {1,3} 
                }
    SelectedEnemyNumber = 1
    SelectedEnemy = EnemyOptions[Player][SelectedEnemyNumber]
    EnemyData = 
    {
        {
            --MAFIA
            Guns = {70,75,68,69,1500}, -- M16, Silencer, Double Barrel, Shotgun, Kalashnikov
            Bats = {67,66,73,74}, -- Bat, Club, Knife, Pipe
            Pattern = {876,878,875,938}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {2596,1464} -- Is Fat
        },
        {
            --POLICE
            Guns = {1551,1558}, -- 9mm, Shotgun
            Bats = {1553}, -- Baton
            Pattern = {932,933,931,939}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {1570,937} -- Is Fat
        },
        {
            --GANG
            Guns = {208,206,201}, -- Uzi, Shotgun, 9mm
            Bats = {202,203,204,205}, -- Bat, Chain, Knife, Pipe
            Pattern = {183,184,170,941}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {2194,1289}
        },
        {
            --SOLDIERS
            Guns = {1117}, -- Kalashnikov
            Bats = {1118}, -- Machete
            Pattern = {674,696,672,2396}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {1161,704} -- Is Fat
        },
        {
            --COLUMBIAN
            Guns = {2288,2291,2293,2294}, -- Famae, Mendoza, Shotgun, Silencer
            Bats = {2290,2292,2289}, -- Machete, Pipe, Knife
            Pattern = {1356,1358,1354,1355}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {2596,1464}, -- Is Fat
        },
        {
            --GUARD
            Guns = {2679,2680}, -- Magnum, Shotgun
            Bats = {2681}, -- Baton
            Pattern = {1532,1534,1530,1531}, -- Gun Rand, Gun Patrol, Bat Rand, Bat Patrol
            Fat = {2681,1531} -- Is just a melee enemy
        },

        

    }

    --Variables on the visual part of the program
    love.window.setTitle("Dashline Generator: Hotline Miami 2 Procedural Level Generation")
    font = love.graphics.newFont( 12 )

    gridSize = 24
    --os.execute('explorer .')
    f = assert(io.open('data.txt', "r"))
    t = f:read()
    levelNumber = tonumber(f:read()) or -1
    f:close()

    levelFolder = t or ""

    lfIndex = levelFolder:len()
    mainMode = true
    love.window.setMode(1200, 800)
    offset = {}
    offset.x = 10
    offset.y = 15
    --Set the random seed to the time to get a unique level each time.
    math.randomseed( os.time() )

    infoString = ""
    
    --Files used through the program, see their files for information on them 
    DashSolids = require('DashSolids')
    Alerts = require('Alerts')
    Buttons = require('Buttons')
    Adjusters = require('Adjusters')

    Buttons:add('GENERATE',10+Buttons.width("EDIT FOLDER")+Buttons.width("PUBLISH")+10,22*gridSize+25,nil,30,generator)
    Buttons:add('PUBLISH',10+Buttons.width("EDIT FOLDER")+5,22*gridSize+25,nil,30,publish)
    Buttons:add('EDIT FOLDER',10,22*gridSize+25,nil,30,endMainMode)
    Buttons:add('SIDEBAR HELP 1',10+Buttons.width("EDIT FOLDER")+Buttons.width("PUBLISH")+Buttons.width("GENERATE")+15,22*gridSize+25,nil,30,sidebarHelp1)
    Buttons:add('SIDEBAR HELP 2',10+Buttons.width("EDIT FOLDER")+Buttons.width("PUBLISH")+Buttons.width("GENERATE")+Buttons.width("SIDEBAR HELP 1")+20,22*gridSize+25,nil,30,sidebarHelp2)

    Buttons:add('CHARACTER',10+Buttons.width("EDIT FOLDER")+Buttons.width("PUBLISH")+Buttons.width("GENERATE")+Buttons.width("SIDEBAR HELP 1")+Buttons.width("SIDEBAR HELP 2")+25,22*gridSize+25,nil,30,nextPlayer)
    Buttons:add('ENEMY',10+Buttons.width("EDIT FOLDER")+Buttons.width("PUBLISH")+Buttons.width("GENERATE")+Buttons.width("SIDEBAR HELP 1")+Buttons.width("SIDEBAR HELP 2")+Buttons.width("CHARACTER")+30,22*gridSize+25,nil,30,nextEnemy)

    
    Adjusters:add('glass%',0,25,1,2)
    Adjusters:add('rooms',0,100,1,25)
    Adjusters:add('gunPatrol#',0,10,1,5)
    Adjusters:add('gunRand#',0,10,1,2)
    Adjusters:add('meleePatrol#',0,10,1,4)
    Adjusters:add('fat%',0,25,1,2)
    Adjusters:add('meleeRand#',0,10,1,3)--3,4,2,5
    Adjusters:add('minMafia',0,30,1,10)
    Adjusters:add('maxMafia',0,30,1,15)
    Adjusters:add('width',9,33,3,30)
    Adjusters:add('height',9,21,3,18)
    Adjusters:add('+ ratio',0,10,1,1)
    Adjusters:add('- ratio',0,10,1,1)
    Adjusters:add('| ratio',0,10,1,1)
    Adjusters:add('* ratio',0,10,1,1)
    Adjusters:add('O ratio',0,10,1,1)

    -- the files that need to be changed are level0.wll, level0.wobj, and level0.tls

    -- tables are used with each entry being a distinct object/sprite then concatenated into a string at the end of generating the level
    -- this allows entries to be removed if you know the index
    -- the initial text in the obj string is the car the player comes out of
    wllTable = {}
    objTable = {}
    objTable[1] = obj
    tlsTable = {}

    --floodTable is a table used to tell if all rooms are accessable
    --it starts as all 0s
    floodTable = {}
    for i = 0, 30 do
        floodTable[i] = {}
        for j=0,18 do
            floodTable[i][j] = 0
        end
    end

    --enemyTable is similar but used to tell if all rooms have enemies
    enemyTable = {}


    --the number of rooms to try to place, an integer between 20 and 30 inclusive
    rooms = Adjusters:get('rooms')

    --the number of enemies to place, an integer between 10 and 15 inclusive
    mafia = math.floor(r(Adjusters:get('minMafia'),Adjusters:get('maxMafia')))

    --a list of all locations enemies have been placed, used to avoid placing enemies on top of each other
    mafiaCords = {}

    --a list of all places boxes (rooms) have been placed. this is used to place doors after all rooms have been placed
    boxLocations = {}

    --call the function that builds the level
    generator()


    --just variables that are used in user interaction
    mouseDown = false
    spaceDown = false
    AdjustY = 10
end

--Updates every frame depending on mainMode
function love.update(dt)
    if mainMode then
        if love.mouse.isDown(1) then
            mouseDown = true
            
        end
        if not love.mouse.isDown(1) and mouseDown then
            mouseDown = false
            Adjusters:update()
            Buttons:update()
        end
        if love.keyboard.isDown('space') then
            spaceDown = true
        end
        if not love.keyboard.isDown('space') and spaceDown then
            spaceDown = false
            generator()

        end
    else
        if (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) and love.keyboard.isDown('v') then
            levelFolder = love.system.getClipboardText()
            lfIndex = levelFolder:len()
        end
        if love.keyboard.isDown('return') then
            if levelFolder:len() > 0 and levelFolder:sub(levelFolder:len()) ~= [[\]] then
                levelFolder = levelFolder .. [[\]]
            end

            file = assert(io.open('data.txt', "w"))
            file:write(levelFolder .. "\n" .. levelNumber)
            file:close()
            mainMode = true
        end
        
    end
end


function love.draw( ... )
    love.graphics.setFont(font)
    width, height, flags = love.window.getMode( )
    love.graphics.setColor(200,200,200)
    love.graphics.rectangle('fill',0,0,width,height)
    love.graphics.setColor(0,0,0)
    
    if mainMode then
        


        --These are all bounding rectangles
        --for Alerts
        love.graphics.setColor(230,230,230)
        love.graphics.rectangle('fill',20 + gridSize*33,5,256,height-10)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',20 + gridSize*33,5,256,height-10)

        --for Adjusters
        love.graphics.setColor(230,230,230)
        love.graphics.rectangle('fill',20 + gridSize*33+256+5,5,122,height-10)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',20 + gridSize*33+256+5,5,122,height-10)

        --for bottom
        love.graphics.setColor(230,230,230)
        love.graphics.rectangle('fill',5,22*gridSize+20,33*gridSize+10,height-5-(22*gridSize+20))
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',5,22*gridSize+20,33*gridSize+10,height-5-(22*gridSize+20))
        love.graphics.print(infoString,15,22*gridSize+20+50)



        Alerts:drawDown(25 + gridSize*33,10)

        --for level
        love.graphics.setColor(80,80,80)
        love.graphics.rectangle('fill',5,5,33*gridSize+10,22*gridSize+10)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',5,5,33*gridSize+10,22*gridSize+10)

        drawTls(offset)
        drawWalls(offset)
        drawObjects(offset)
        love.graphics.setFont(font)
        Adjusters:draw(1090-5,AdjustY)
        Buttons:draw()
        love.graphics.setColor(0,0,0)
        if levelFolder:len() ~= 0 then
            love.graphics.print("Current output directory:\n" .. levelFolder,10,height-40)
        else
            love.graphics.print("Currently set to output locally.",10,height-30)
        end

        --Who the level is made for and the enemy they are facing
        love.graphics.print(PlayerNames[Player] .. " vs. " .. EnemyNames[EnemyOptions[Player][SelectedEnemyNumber]],630,22*gridSize + 30)
        love.graphics.setColor(200,200,200)
        love.graphics.rectangle('fill',0,0,width,4)
        love.graphics.rectangle('fill',0,height-4,width,4)
    else
        drx = 200
        dry = 200
        love.graphics.setColor(230,230,230)
        love.graphics.rectangle('fill',drx-5,dry-5,800,120)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle('line',drx-5,dry-5,800,120)
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle('fill',drx,dry+17,790,18)
        --Alerts:drawDown(50,200)
        love.graphics.setFont(Buttons.font)
        love.graphics.setColor(0,0,0)
        love.graphics.print("Enter the level destination: ",drx,dry)
        love.graphics.print(levelFolder,drx,dry+20)
        love.graphics.setColor(100,100,100)
        love.graphics.print([[Ex: C:\Users\theda_000\Documents\My Games\HotlineMiami2\Levels\single\HOLDER\]],drx+5,dry+40)
        love.graphics.print("Enter to begin. Leave blank to write locally.",drx+5,dry+60)
        love.graphics.print("Or drag a folder on to this window to be written to.",drx+5,dry+80)
        love.graphics.print("Press F1 to open File Explorer.",drx+5,dry+100)
        love.graphics.line(drx + 8*lfIndex,dry+20,drx + 8*lfIndex,dry+20+12)
        --C:\Users\theda_000\Documents\My Games\HotlineMiami2\Levels\single\HOLDER\
    end
end

--Draw the levels floors
function drawTls(offset)
    for i =1, #tlsTable do
        k = tlsTable[#tlsTable-i+1]
        love.graphics.setColor(k[2]%101+100,k[3]%101+100,k[2]*k[3]%101+100)
        love.graphics.rectangle('fill',offset.x+k[4]/32*gridSize,offset.y+k[5]/32*gridSize,gridSize/2,gridSize/2)
    end
end

--For bug fixing, shows rooms with enemies in them
function drawEnemytable(offset)
    for i = 1, Adjusters:get('width')/3 do
        for j=1,Adjusters:get('height')/3 do
            if enemyTable[i][j] == 1 then
                love.graphics.setColor(255,0,0,100)
                love.graphics.rectangle('fill',offset.x+(i-1)*gridSize*3,offset.y+(j-1)*gridSize*3,gridSize*3,gridSize*3)
            end
        end
    end
end

--Draw the levels walls
function drawWalls(offset)
    for i =1, #wllTable do
        k = wllTable[i]
        dx = 0
        dy = 0
        if k[1] % 2 == 1 then --horizontal is odd
            dx = gridSize
        else
            dy = gridSize
        end
        if k[1] > 100 then
            love.graphics.setColor(0,200,255)
        else
            love.graphics.setColor(0,0,0)
        end
        love.graphics.line(offset.x+k[2]/32*gridSize,offset.y+k[3]/32*gridSize,offset.x+k[2]/32*gridSize+dx,offset.y+k[3]/32*gridSize+dy)
    end
end

--Draw the levels Enemies and doors
function drawObjects(offset)
    for i =1, #objTable do
        k = objTable[i]
        if k[1] == 10 then
            love.graphics.setColor(0,0,0)
            if isRand(k[6]) then
                love.graphics.setColor(175,25,25)
            end
            love.graphics.ellipse('line',offset.x+k[2]/32*gridSize,offset.y+k[3]/32*gridSize,14/32*gridSize,9/32*gridSize)
            if isGun(k[4]) then --check for fats
                love.graphics.setColor(0,0,0)
                --prit('weedidit')
                love.graphics.line(offset.x + k[2]/32*gridSize + 8/32*gridSize, offset.y + k[3]/32*gridSize, offset.x + k[2]/32*gridSize + 8/32*gridSize, offset.y + k[3]/32*gridSize - 20/32*gridSize)
            elseif k[5] == 180 then
                love.graphics.setColor(0,0,0)
                love.graphics.ellipse('line',offset.x+k[2]/32*gridSize,offset.y+k[3]/32*gridSize,16/32*gridSize,16/32*gridSize)
            else
                love.graphics.setColor(139,69,19)
                love.graphics.line(offset.x + k[2]/32*gridSize + 10/32*gridSize, offset.y + k[3]/32*gridSize-4/32*gridSize, offset.x + k[2]/32*gridSize - 10/32*gridSize, offset.y + k[3]/32*gridSize - 4/32*gridSize)
            end
        elseif k[1] == 26 or k[1] == 25 then
            love.graphics.setColor(139,69,19) 
            love.graphics.line(offset.x+k[2]/32*gridSize,offset.y+k[3]/32*gridSize,offset.x+k[2]/32*gridSize+gridSize/2^0.5,offset.y+k[3]/32*gridSize+gridSize/2^0.5)
        end
        --love.graphics.line(offset.x+k[2],offset.y+k[3],offset.x+k[2]+dx,offset.y+k[3]+dy)
    end
end

--Checks if n is a gun or melee weapon
function isGun(n)
    for i = 1, 6 do
        for j = 1, #EnemyData[i].Guns do
            if n == EnemyData[i].Guns[j] then
                return true
            end
        end
    end
    return false
end

--Checks if n is a random patrol pattern
function isRand(n)
    for i = 1, 6 do
        for j = 1, #EnemyData[i].Pattern do
            if n == EnemyData[i].Pattern[j] then
                return j%2 == 1
            end
        end
    end
    return 9/0
end

function love.wheelmoved( x, y )
    AdjustY = AdjustY + y*10
end

--Write the files to the specified folder
function publish()
    wll = ""
    for i=1,#wllTable do
        wll = wll..makeString(wllTable[i])
    end
    obj = ""
    for i=1,#objTable do
        obj = obj..makeString(objTable[i])
    end
    tls = ""
    for i=1,#tlsTable do
        tls = tls..makeString(tlsTable[i])
    end


    --C:\Users\theda_000\Documents\My Games\HotlineMiami2\Levels\single\HOLDER\
    --open all the files and write the data to them. These are not the files used by HM2, but you can copy the data from the txt files to the .wll, .obj and .tls files
    exists = directory_exists( levelFolder )
    if exists then
        hlm = makeHlm()
        f = assert(io.open(levelFolder .. [[level0.wll]],'w'))
        f:write(wll)
        f:close()
        f = io.open(levelFolder .. [[level0.obj]],'w')
        f:write(obj)
        f:close()
        f = io.open(levelFolder .. [[level0.tls]],'w')
        f:write(tls)
        f:close()
        f = io.open(levelFolder .. [[level0.play]],'w')
        f:write('')
        f:close()
        f = io.open(levelFolder .. [[level.hlm]],'w')
        f:write(hlm)
        f:close()
        Alerts:add("Successfuly created files.")
        Alerts:add("Level titled DASHLINE" .. levelNumber ..".")
        Alerts:add("Remember to edit before playing.")
    else
        Alerts:add("Failed to create files.")
        Alerts:add("Not a valid directory.")
        --print("snafubar")
    end
end

--Write the folder
function love.textinput( text )
    if not mainMode then
        levelFolder = levelFolder:sub(1,lfIndex) .. text .. levelFolder:sub(lfIndex+1)
        lfIndex = lfIndex + 1
    end
end

--Yup
function endMainMode()
    mainMode = false
end


function love.keypressed(key)
    if not mainMode then
        if key == "backspace" and lfIndex ~= 0 then
            levelFolder = levelFolder:sub(1,lfIndex-1) .. levelFolder:sub(lfIndex+1)
            lfIndex = math.max(0,lfIndex-1)
        end
        if key == 'right' then
                lfIndex = math.min(levelFolder:len(),lfIndex+1)
        end
        if key == 'left' then
            lfIndex = math.max(0,lfIndex-1)
        end
        if key == 'f1' then
            os.execute('explorer .')
        end
    end
end

--Select cursor location in text
function love.mousepressed( x, y, button, istouch )
    --Alerts:add("Clicked.")
    if button == 1 and not mainMode then
        lfIndex = math.min(math.max(math.floor((x-200+4)/8),0),levelFolder:len())
    end
end

function love.directorydropped( path )
    if mainMode == false then
        levelFolder = path
        lfIndex = levelFolder:len()
    end
end

function directory_exists( sPath )
    if type( sPath ) ~= "string" then return false end
    local response = os.execute( "cd " .. sPath )
    if response == 0 then
        return true
    end
    return false
end

--Just lots of text explaing the values.
function sidebarHelp1()
    infoString = [[glass% is the percent chance that a wall being placed starts a string of glass.

rooms is the number of rooms to try to place. Not all will be placed successfuly.

gunPatrol#, gunRand#, meleePatrol#, and meleeRand# are the ratios at which the different types of enemies will be placed.

minMafia and maxMafia are the lower and upper bounds for the number of extra enemies placed.
    Keep in mind that 1-2 enemies are placed in all rooms automaticaly.

fat% is the percent chance that a placed enemy is a fat.

]]
end
function sidebarHelp2()
    infoString = [[width is the width of the level.

height is the height of level.

+ ratio, - ratio, | ratio, * ratio, and O ratio are the ratio of various templates for levels.
    + places two hallways in a plus shape.
    - places one horizontal hallway.
    | places one vertical hallway.
    * places a ring.
    O places nothing.]]
end

--Change the player
function nextPlayer()
    Alerts:add("Changed character.")
    Player = Player + 1
    if Player > PlayerRange[2] then
        Player = PlayerRange[1]
    end
    SelectedEnemy = EnemyOptions[Player][1]
    SelectedEnemyNumber = 1
    generator()
end

--Change the enemy the player is fighting
function nextEnemy()
    Alerts:add("Changed enemy.")
    SelectedEnemyNumber = SelectedEnemyNumber + 1
    if SelectedEnemyNumber > #EnemyOptions[Player] then
        SelectedEnemyNumber = 1
    end
    SelectedEnemy = EnemyOptions[Player][SelectedEnemyNumber]
    generator()
end

--make the .hlm file
function makeHlm()
    levelNumber = levelNumber + 1
    str = [[DASHLINE]]..levelNumber.."\n"..[[0
Dashline Generator
0
0]].."\n".. makePlayerNumber().."\n"..[[1
-1
35
0
0
1440
768
974
0
00
00
01
01
1991
MIAMI
FLORIDA

0
9999
9999]]

    return str
end

--Switches from the programs Player number to HLM2's
function makePlayerNumber( ... )
    PlayerNames = {"Jacket","Biker","Cobra","Cop","Fans","Hammer","Henchman","Rat","Soldier","Son","Writer"}
    --[[
0 - The Fans
1- Cop
4- Writer
3- Soldier
2- Son
5- Rat
6- Cobra
7- Butcher -- NOT AVAILABLE
8- Henchman
9- Hammer
10- Jacket
11- Biker]]
    switch = {10,11,6,1,0,9,8,5,3,4,2}
    return switch[Player]
end

--Make sure the data.txt works when done
function love.quit( ... )
    levelFolder = levelFolder or ""
    levelNumber = levelNumber or -1
    file = assert(io.open('data.txt', "w"))
    file:write(levelFolder .. "\n" .. levelNumber)
    file:close()
end