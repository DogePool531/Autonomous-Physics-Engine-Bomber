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
    function getRightOri() -- doesn't work
      
        local jZ = self.shape:getYAxis()

        local lX = self.shape:getRight()
        local lY = self.shape:getUp()
        local lZ = self.shape:getAt()
        
        local angle = 0
        if sm.vec3.new(0, 0, 1):cross(lZ):length() > 0.001 then
            local fakeX = sm.vec3.new(0, 0, 1):cross(lZ):normalize()
            local fakeY = lZ:cross(fakeX)
            angle = math.atan2(-fakeX:dot(lY), fakeY:dot(lY))
        else
            local rot = sm.vec3.getRotation(lZ, jZ)
            lY = rot * lY
            angle = math.atan2(lY.z, -lY.y)
        end
        

        return(math.deg(angle))
    
    end
    function getAtOri() --Roll given natural position with face foward
        
        local lY = self.shape:getUp()
        local lZ = self.shape:getRight()
        
        local angle = 0
        if sm.vec3.new(0, 0, 1):cross(lZ):length() > 0.001 then
            local fakeX = sm.vec3.new(0, 0, 1):cross(lZ):normalize()
            local fakeY = lZ:cross(fakeX)
            angle = math.atan2(fakeY:dot(lY), -fakeX:dot(lY))
        end

        return(angle)
    
    end
    function getRightV() -- get velocity to the right of the block assuming foward is the weird pipe bit on the block and the computer face is up

        local direc = self.shape:getRight()
		local speed = self.shape:getVelocity()
		local natV = 0

		natV = sm.vec3.dot(speed, direc)/sm.vec3.length(direc)

		return((natV))
		
	end
    function getUpV() -- get velocity to the top of the block assuming foward is the weird pipe bit on the block and the computer face is up

        local direc = self.shape:getUp()
		local speed = self.shape:getVelocity()
		local natV = 0

		natV = sm.vec3.dot(speed, direc)/sm.vec3.length(direc)

		return((natV))
		
	end
    function getAtV() -- get velocity to the front of the block assuming foward is the weird pipe bit on the block and the computer face is up

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
        local AtFace = self.shape:getAt()
        local upFace = self.shape:getUp()
		local speed = self.shape:getVelocity()

		local AtV = sm.vec3.dot(speed, AtFace)/sm.vec3.length(AtFace)
        local upV = sm.vec3.dot(speed, upFace)/sm.vec3.length(upFace)
        local angle = math.atan2(-upV, AtV)
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


	function onStart()
        lMult = 1
        dMult = 0.3
	end
    
	function onTick()
        local CL
        local CD = 0
        local v2 = sm.vec3.length2(self.shape:getVelocity())*(math.abs(getAtV())/getAtV())
        local theta = getAlpha()
        if math.abs(theta) > 0.383 then
            CL = 0
            CD = 1
        elseif theta > 0 then
            CL = math.sin(3*theta) - math.pow(theta, 10)*20000
        else 
            CL = math.sin(3*theta) + math.pow(theta, 10)*20000
       end
        local lift = CL*lMult*v2
        setLift(lift)

        local cd0 = 0.3
        if math.abs(theta) > 1.57 then
        else
            CD = math.pow(theta, 2) * 10 + 0.3
        end
         local drag = CD*dMult*v2
        setDrag(drag)


        local totD = drag * dMult
        local totL = lift * lMult
        local effiency = totL/totD
        
    end

	function onStop()
		-- it invokes when computer turns off
		-- there you can deactivate motors
	end

	function onError()
		-- this method invokes when computer gets error in onTick method
		-- you can invoke onStop method
		onStop()
	end

	onStart()
	STARTED = true
end








