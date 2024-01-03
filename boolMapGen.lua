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
    -- it is beautyful place where you can write your code
    -- there you can declare global variables/functions
    local function numberToHexColor(num)
        -- Ensure num is between 0 and 1
        num = math.max(0, math.min(1, num))

        -- Calculate red and blue components
        local red = math.floor(255 * (1 - num) / 1)
        local blue = math.floor(255 * num / 1)

        -- Convert to hexadecimal
        local redHex = string.format("%02X", red)
        local blueHex = string.format("%02X", blue)

        -- Combine to form the color
        return "#" .. redHex .. "00" .. blueHex
    end

    function onStart()
        world = sm.world.getCurrentWorld()
        self.character = self.character or sm.character.createCharacter(sm.player.getAllPlayers()[1], world, sm.vec3.new(0,0,0))
        i = 0
        j = 0
        display = getDisplays()[1]
        display.clear("#000000")
        sign = 0
        tabley = {}
        tempTabley = {}
        longstring = ""
        --print(1)
    end

    function onTick()
        here = self.shape:getWorldPosition()
        if display == nil then return end
                x = i*100 - 6400
                y = -j*100 + 6400
                local charPostion = sm.vec3.new(x,y, -20)
                local start = sm.vec3.new(x,y, 170)
                local final = sm.vec3.new(x,y, -17.75)
                if sign == 0 then
                    self.character:setWorldPosition(charPostion)
                    sign = 1
                elseif sign == 1 then
                    local bool, ray = sm.physics.raycast(start, final)
                    local bool2, ray2 = sm.physics.raycast(start, final)
                    --print(ray.fraction)
                    local col = math.floor(ray.fraction * 9)
                    local color
                    if bool then
                        display.drawPixel(i, j,  "#3BB143")
                        --color = sm.color.new(1-col,col,0,0):getHexStr()
                    else
                        
                        display.drawPixel(i, j, "#031521")
                        color = "#031521"
                    end
                    longstring = longstring .. (tostring(col))
                    --table.insert(tabley, bool and 1 or 0)
                    if bool ~= bool2 then
                        sign = 1
                        --print(true)
                    elseif i < 128 then
                        i = i + 1
                        sign = 0
                    elseif j > 128 then
                        sm.json.save(longstring, "$CONTENT_DATA/BoolMap".. "5" .. ".json" )
                        print(true)
                    else
                        j = j + 1
                        i = 0
                        sign = 2
                        --table.insert(tabley, tempTabley)
                        sm.json.save( longstring, "$CONTENT_DATA/testasddd.json" )
   
                    end
                    --print(false)
                    display.forceFlush() -- send data to render
                    
                else
                    self.character:setWorldPosition(charPostion)
                    sign = 0
                end
               --print(i,j)

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