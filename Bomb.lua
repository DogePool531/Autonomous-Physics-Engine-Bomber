-- mqsci3 is the current model working on science

if STARTED ~= nil then
    if input() then
        local ran, err = pcall(onTick)

        if not ran then
            onError()
            error(err)
        end
    else
        onStop()
    end
else
    --global and functions
    
    FPL = {
        {"const", "target","na", "na", "na", "na", "na", "na", "na","na"},
        {1000, 197.125, -2000, -4500, 0, 0, 0, 0, 0, 0},
        {1000, -230.875, -2000, -3500, 0, 0, 0, 0, 0, 0},
        {200, -12.625, 200, 200, 200, 0, 0, 0, 0, 0},
    }
    stat = 0
    waypoint = 1
    function getAtOri() --Rotates about the At Axis
        local lY = self.shape:getUp()
        local lZ = self.shape:getAt()
        
        local angle = 0
        if sm.vec3.new(0, 0, 1):cross(lZ):length() > 0.001 then
            local fakeX = sm.vec3.new(0, 0, 1):cross(lZ):normalize()
            local fakeY = lZ:cross(fakeX)
            angle = math.atan2(-fakeX:dot(lY), fakeY:dot(lY))
        end
        return(angle)
    end
    function getRightOri() --rotates about the right axis
        local lY = self.shape:getUp()
        local lZ = self.shape:getRight()
        
        local angle = 0
        if sm.vec3.new(0, 0, 1):cross(lZ):length() > 0.001 then
            local fakeX = sm.vec3.new(0, 0, 1):cross(lZ):normalize()
            local fakeY = lZ:cross(fakeX)
            angle = math.atan2(-fakeX:dot(lY), fakeY:dot(lY))
        end
        return(angle)
    end
    function getRightV() -- velocity to right

        local direc = self.shape:getRight()
        local speed = self.shape:getVelocity()
        local natV = 0

        natV = sm.vec3.dot(speed, direc)/sm.vec3.length(direc)

        return((natV))
        
    end
    function getUpV() -- velocity up 

        local direc = self.shape:getUp()
        local speed = self.shape:getVelocity()
        local natV = 0

        natV = sm.vec3.dot(speed, direc)/sm.vec3.length(direc)

        return((natV))
        
    end
    function getAtV() -- foward veloicty

        local direc = self.shape:getAt()
        local speed = self.shape:getVelocity()
        local natV = 0

        natV = sm.vec3.dot(speed, direc)/sm.vec3.length(direc)

        return((natV))
        
    end
    function getX() -- in meters
        local posX = self.shape:getWorldPosition().x
        return(posX)
    end
    function getY() -- in meters
        local posX = self.shape:getWorldPosition().y
        return(posX)
    end
    function getZ() -- in meters
        local posX = self.shape:getWorldPosition().z
        return(posX)
    end
    function getAlpha() -- in radians    
        local atFace = self.shape:getAt()
        local upFace = self.shape:getUp()
        local speed = self.shape:getVelocity()

        local atV = sm.vec3.dot(speed, atFace)/sm.vec3.length(atFace)
        local upV = sm.vec3.dot(speed, upFace)/sm.vec3.length(upFace)
        local angle = math.atan2(-upV, atV)
        return(angle)
    end
    function getBeta() -- in radians
        local atFace = self.shape:getAt()
        local upFace = self.shape:getRight()
        local speed = self.shape:getVelocity()

        local atV = sm.vec3.dot(speed, atFace)/sm.vec3.length(atFace)
        local upV = sm.vec3.dot(speed, upFace)/sm.vec3.length(upFace)
        local angle = math.atan2(-upV, atV)
        return(angle)
    end
    function setLift(lift)
    
        local atFace = self.shape:getAt()
        local upFace = self.shape:getUp()
        local rightFace = self.shape:getRight()
        local speed = self.shape:getVelocity()
        local atV = sm.vec3.dot(speed, atFace)
        local upV = sm.vec3.dot(speed, upFace) 
        local rightV = sm.vec3.dot(speed, rightFace) 
        local vNorm = sm.vec3.safeNormalize(sm.vec3.new(rightV, -upV, atV), sm.vec3.new(0, 1, 0))
        if (getAtV() > 0) then
        sm.physics.applyImpulse(self.shape, vNorm * lift, false, sm.vec3.new(0, 0, 0))
        worldpos = self.shape:getWorldPosition()

        end

        
    end
    function setDrag(drag)
    
        local atFace = self.shape:getAt()
        local upFace = self.shape:getUp()
        local rightFace = self.shape:getRight()
        local speed = self.shape:getVelocity()
        local atV = sm.vec3.dot(speed, atFace)
        local upV = sm.vec3.dot(speed, upFace)
        local rightV = sm.vec3.dot(speed, rightFace) 
        local vNorm = sm.vec3.safeNormalize(sm.vec3.new(-rightV, -atV, upV), sm.vec3.new(0, 1, 0))
        if (getAtV() > 0) then
        sm.physics.applyImpulse(self.shape, vNorm * drag, false, sm.vec3.new(0, 0, 0))
        end
    

    end
    function sign(x)
        local y
        if x > 0 then
            x = 1
        elseif x < 0 then
            x = -1
        else
            x = 0
        end
        return(x)
    end

    function getAngle()
        local vToT = sm.vec3.new( FPL[2][waypoint], FPL[3][waypoint], FPL[4][waypoint]) - self.shape:getWorldPosition()
        local face = self.shape:getVelocity() + self.shape:getAt()
        local tSign = sign(vToT.x * face.y - face.x * vToT.y)
        local costheta = tSign * math.acos((vToT.y * face.y + vToT.x * face.x)/(math.sqrt(vToT.x*vToT.x +vToT.y*vToT.y)*math.sqrt(face.y*face.y+face.x*face.x)))
        return(costheta)
    end
    function getDistance()
        local vToT = sm.vec3.new( FPL[2][waypoint], FPL[3][waypoint], FPL[4][waypoint]) - self.shape:getWorldPosition()
        return(sm.vec3.length(vToT))
    end

    
    -- PID loop function
    -- PID parameters

    -- Note array declares values for different PID loops 
    -- in order,       roll, alpha, yaw, throttle, orient, climb, steering
    local km = 2500 --       1      2      3    4     5        6     7
    local Kpr =         {    1,   1.4,   0.7,  10,  2,    0.01,    4} -- Proportional gain
    local Kir =         {    0,  0.00,  0.00,   1, 0.00, 0.00006,    0} -- Integral gain
    local Kdr =         {  0.3,   0.3,   0.1,  10,  1,     0.5,    1} -- Derivative gain
    local maxPos =      { 0.35,  0.35,  0.35, 400,  0.2,    0.5, 0.7}
    local maxNeg =      {-0.35, -0.35, -0.35,   0, -0.25,   -0.60,-0.7} 
    local maxPosInt =   { 0.35,   0.1,  0.35, 400,  0.2,   -0.07,    0}
    local maxNegInt =   {-0.35,  -0.3, -0.35,   0, -0.3,  -0.085,    0} 
    local maxPosError = {     1,    3,     1,  30,    1,      60,  0.8} 
    local maxNegError = {    -1,   -1,    -1, -30,   -1,     -60, -0.8}
    local intBound =    {0}
    local integral =    {0, 0, 0, 100, 0, 0, 0}   -- Integral term
    local prevError =   {0, 0, 0, 0, 0, 0, 0}  -- Previous error for derivative term

    function pidLoop(_error, PIndex)
        if _error ~= math.min(math.max(_error, maxNegError[PIndex]), maxPosError[PIndex]) then --print( PIndex, _error)
        --print(math.min(math.max(_error, maxNegError[PIndex]), maxPosError[PIndex]))
        end
        _error = math.min(math.max(_error, maxNegError[PIndex]), maxPosError[PIndex])
        local proportional = Kpr[PIndex] * _error
        integral[PIndex] = math.min(math.max(integral[PIndex] + Kir[PIndex] * _error, maxNegInt[PIndex]), maxPosInt[PIndex]) 
        local derivative = Kdr[PIndex] * (_error - prevError[PIndex])
        prevError[PIndex] = _error
        local output = math.min(math.max(proportional + integral[PIndex] + derivative, maxNeg[PIndex]), maxPos[PIndex])
        
        return(output)
    end
    function getPacket()
        
        local port = getPorts()[1]
        if port.getPacketsCount() > 0 then
            local data = port.nextPacket()
            stat = port.nextPacket()
       FPL = sm.json.parseJsonString(data)
       end
       
    end
    function getDistance()
        local vToT = sm.vec3.new( FPL[2][wayp], FPL[3][wayp], FPL[4][wayp]) - self.shape:getWorldPosition()
        return(sm.vec3.length(vToT))
    end
    function calcBomb()
        local t = {}
        local x = {}
        local y = {}
        local z = {}
        local xV = {}
        local yV = {}
        local zV = {}
        --local xA = {}
        --local yA = {}
        local zA = {}
        local v = self.shape:getVelocity()
        local Vx = sm.vec3.new(1,0,0):dot(v)
        local Vy = sm.vec3.new(0,1,0):dot(v)
        local Vz = sm.vec3.new(0,0,1):dot(v)
        local drag = 1 - 0.005
        local desZ = FPL[4][wayp]
        
         t[1] = 0
         x[1] = getX()
         y[1] = getY()
         z[1] = getZ()
         xV[1] = Vx 
         yV[1] = Vy 
         zV[1] = Vz 
         --print(Vx, Vy, Vz)
         --xA[1] = 0
         --yA[1] = 0
         zA[1] = -10
         h = 1/40
         i = 1
         --print(x[i], y[i])
        
         while z[i] > desZ do
            i = i + 1
            
            --xA[i] = h * (xV[i-1] * -0.025)
            --yA[i] = h * (xV[i-1] * -0.025)
            zA[i] = -10-- + h * (zV[i-1] * -0.025)
            
            xV[i] = xV[i-1]*drag
            yV[i] = yV[i-1]*drag
            zV[i] = zV[i-1]*drag + h*zA[i]
            
            x[i] = x[i-1] + h*xV[i]
            y[i] = y[i-1] + h*yV[i]
            z[i] = z[i-1] + h*zV[i]

            t[i] = (i - 1) * h
        end
        local diff = sm.vec3.new(x[i]-x[1],y[i]-y[1],z[i]-z[1])
        local eulerPos = sm.vec3.new(x[i],y[i],z[i])
        return eulerPos, diff:length(), t[i]
    end
    function onStart()
        
    end
    cont = 1
    wayp = 1
    function onTick()

        
        
        if stat ~= "1" then 
            getPacket()
            --print("noPacket")
        end
        
        if true then
             
            wayp = getreg("wayp")
            --print(getreg("wayp"))
            --print(wayp)
            if wayp == 0 then
                 wayp = 1
            end
            setreg("cont", cont)
            --print("its happening")
        end
        

        cont = 1
        --print(wayp, "this")
            local targetPos = sm.vec3.new(FPL[2][wayp],FPL[3][wayp],FPL[4][wayp])
            local estPos, dist, time = calcBomb()
            --local estPos = sm.vec3.new(getX(),getY(),getZ())
            --print(targetPos:length() - estPos:length(), "dist")
            print(dist, "this")
            --print(sm.physics.getGravity(), "grav")
        if FPL[1][wayp] == "target" then
            if (targetPos - estPos):length() < 800 then
            cont = 0
            end
            print(getDistance(), "getDist")
            print((getDistance() - dist), "difference")
            if math.abs(getDistance() - dist) < 10 then
                out(1)
                print("Dropped")
            end

        end

        
        --local startPos = self.shape:getWorldPosition() 
        --local atFace = self.shape:getAt()
            --print(sm.physics.raycast(startPos + atFace * 1.5, startPos + atFace * 3))
      
     
        
        
       -- if armed == true then
       --     sm.physics.explode( self.shape.worldPosition, 20, 5, 10, 10, "PropaneTank - ExplosionSmall", self.shape)
       -- end

    end

    function onStop()
        
    end

    function onError()
        -- this method invokes when computer gets error in onTick method
        -- you can invoke onStop method
        onStop()
    end

    onStart()
    STARTED = true
end











