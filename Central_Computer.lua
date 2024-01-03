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
        local AtFace = self.shape:getAt()
        local upFace = self.shape:getUp()
        local rightFace = self.shape:getRight()
		local speed = self.shape:getVelocity()
        local atV = sm.vec3.dot(speed, AtFace)
        local upV = sm.vec3.dot(speed, upFace) 
        local rightV = sm.vec3.dot(speed, rightFace) 
        local vNorm = sm.vec3.safeNormalize(sm.vec3.new(-rightV, -upV, atV), sm.vec3.new(0, 1, 0))
        if (getAtV() > 0) then
        sm.physics.applyImpulse(self.shape, vNorm * lift, false, sm.vec3.new(0, 0, 0))
        worldpos = self.shape:getWorldPosition()
        end
	end
    function setDrag(drag)
        local AtFace = self.shape:getAt()
        local upFace = self.shape:getUp()
        local rightFace = self.shape:getRight()
		local speed = self.shape:getVelocity()
        local atV = sm.vec3.dot(speed, AtFace)
        local upV = sm.vec3.dot(speed, upFace)
        local rightV = sm.vec3.dot(speed, rightFace) 
        local vNorm = sm.vec3.safeNormalize(sm.vec3.new(-rightV, -atV, -upV), sm.vec3.new(0, 1, 0))
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
    local Kpr =         {    1,   1.4,   0.7,  10,    2,    0.01,    4} -- Proportional gain
    local Kir =         {    0,  0.00,  0.00,   1, 0.00, 0.00006,    0} -- Integral gain
    local Kdr =         {  0.3,   0.3,   0.1,  10,    1,     0.5,    1} -- Derivative gain
    local maxPos =      { 0.35,  0.35,  0.35, 400,  0.2,     0.5,  0.7}
    local maxNeg =      {-0.35, -0.40, -0.35,   0, -0.25,   -0.60, -0.7} 
    local maxPosInt =   { 0.35,   0.1,  0.35, 400,   0.2,   -0.07,    0}
    local maxNegInt =   {-0.35,  -0.3, -0.35,   0,  -0.3,  -0.085,    0} 
    local maxPosError = {     1,    3,     1,  30,     1,      60,  0.8} 
    local maxNegError = {    -1,   -1,    -1, -30,    -1,     -60, -0.8}
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

    function onStart()
        lMult = 1
        dMult = 0.18
        rmotor = getMotors()[1]
        p1motor = getMotors()[2]
        p2motor = getMotors()[3]
        if rmotor == nil then return end
        rmotor.setVelocity(10)
        rmotor.setStrength(11000)
        rmotor.setActive(true)
        p1motor.setVelocity(10)
        p1motor.setStrength(11000)
        p1motor.setActive(true)
        p2motor.setVelocity(10)
        p2motor.setStrength(11000)
        p2motor.setActive(true)
    end
    
    local won = 0
    local lastZ = getZ()
    local uThrPos = 0

    function onTick()
       
        --> Notes

        --> Check if stat
        if stat ~= "1" then 
            getPacket()
            --print("noPacket")
        end

        setreg("toBomb", waypoint)
        
        --determine mode
        FM = 0
        if FPL[1][waypoint] == "const" then
            FM = 1
            if getDistance() < 250 then
                waypoint = waypoint + 1
            end
        elseif FPL[1][waypoint] == "player" then
            FM = 2
        elseif FPL[1][waypoint] == "upload" then
            FM = 3
        elseif FPL[1][waypoint] == "target" then
            FM = 4
        elseif FPL[1][waypoint] == "land" then
            FM = 5
        else
            FM = 0
        end


         --> User Input 
         local wasd = getComponents("wasd")[1] 
         local ifOn = getreg("k")
         local aon = 0
         local rDef = 0.32
         local wDef = 0.02
         local yDef = 0.2
         local uYaw = getreg("yL")
          uYaw = uYaw - 1 * getreg("yR")
         local uThr = getreg("tUp")
          uThr = uThr - 1 * getreg("tDown")
          uThrPos = uThrPos + uThr * 2
         if wasd.isW() == true then
             won = won + wDef
         elseif wasd.isS() == true then
             won = won - wDef
         end
         if wasd.isD() == true then
             aon =  rDef
         elseif wasd.isA() == true then
             aon = -rDef
         end

        --> Some Variable Declarations
        local v2 = sm.vec3.length2(self.shape:getVelocity())*(math.abs(getAtV())/getAtV())
        local v = sm.vec3.length(self.shape:getVelocity())*(math.abs(getAtV())/getAtV())
        local roll = getAtOri() 
        local pitch = getRightOri()
        local alpha = getAlpha()
        local xPos = getX()
        local yPos = getY()
        local zPos = getZ()
        local deltAlt = (zPos - FPL[4][waypoint])
        if FM == 4 then
            deltAlt = zPos - 200
        end
        
        

        AtoT = 0
        if math.abs(deltAlt) < 50 then
        AtoT = getAngle() -- angle to Target
        end
        --print(math.deg(AtoT))
        local pidS = pidLoop(AtoT, 7)
        
        --> cross Relations
        local rVal = -0.8
        local RtoPM = 1/math.cos(roll)
        local RtoPS = rVal/math.cos(roll)

        --> Pitch Control Loop

        
        local climbRate = (zPos - lastZ)*40 
        local pidC = pidLoop(deltAlt, 6)
        local pidP = pidLoop(pitch + pidC, 5)
        local pidA = pidLoop(alpha + pidP + RtoPS - rVal, 2)
        lastZ = getZ()
        
        --> Roll Control Loop
        local pidR = pidLoop(roll - pidS, 1)

        --> Yaw Control Loop
        local YtoR = 0.1 -- constant that relates roll moment and yaw control
        local yaw = getBeta()
        local pidY = pidLoop(yaw, 3)
        
        --> Throttle Control Loop
        local desV = 50 - v
        local pidT = pidLoop(desV, 4)
       
        --> Set motors position
        local thrOutput
       
        if ifOn == 0 and v2 > 40 then    -- set motors if autopilot
            local rOutput = math.min(math.max(km*(-pidR + aon)/(v2+0.01), maxNeg[1]), maxPos[1])
            local p1Output = math.min(math.max(km*(pidP - pidY + RtoPS - rVal)/(v2+0.01), maxNeg[2]), maxPos[2])
            local p2Output = math.min(math.max(km*(pidP + pidY + RtoPS - rVal)/(v2+0.01), maxNeg[2]), maxPos[2])
            rmotor.setAngle(rOutput)
            p1motor.setAngle(p1Output)
            p2motor.setAngle(p2Output)
        else -- set motors if override
            rmotor.setAngle(aon - uYaw * YtoR)
            p1motor.setAngle(won - uYaw * yDef)
            p2motor.setAngle(won + uYaw * yDef)
            thrOutput = uThrPos
            integral = {0, 0, 0, 100, 0, 0, 0} -- included in here becuase it determines 
        end
        if ifOn == 0 then
            thrOutput = pidT
            uThrPos = pidT
        end
        thrOutput = math.min(math.max(thrOutput, maxNeg[4]), maxPos[4])
        out(thrOutput)
      
        --print(getX())
        --print(getY())
    --    print(pidS)
        --print(pidC)
    --print(getDistance()/50)
    --print(deltAlt)

       --print(integral[6])


        

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








