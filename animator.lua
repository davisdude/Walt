-- [[
    To-Do: 
        - Grids (see github.com/kikito/anim8
        - Error checking to get/set methods
        - README
-- ]]

local unpack = table.unpack or unpack

local function err( errCode, passed, ... )
	local types = { ... }
	local typeOfPassed = type( passed )
	if type( types[1] ) == 'function' then
		assert( types[1]( passed ), errCode:gsub( '%%type%%', typeOfPassed ) )
		return true
	end
	local passed = false
	for i = 1, #types do
		if types[i] == typeOfPassed then
			passed = true
			break
		end
	end
	errCode = errCode:gsub( '%%type%%', typeOfPassed )
	assert( passed, 'Animation Error: ' .. errCode )
end

local function isUserdata( data )
    return pcall( function() data:type() end )
end

return { 
    newAnimation = function( frames, delays, quadImage )
        err( 'newAnimation: expected argument 1 to be a table, got %type%.', frames, 'table' )
        err( 'newAnimation: expected argument 2 to be a table or a number, got %type%.', delays, 'table', 'number' )
        if quadImage then 
            err( 'newAnimation: expected argument 3 to be an image, got %type%.', quadImage, 
                function( quadImage )
                    if not isUserdata( quadImage ) then 
                        return false
                    else
                        if quadImage:type() == 'Image' then
                            return true
                        end
                        return false
                    end
                end
            )
        end
        err( 'newAnimation: expected argument 1 to be a table of images and/or quads. Make sure you have argument 3 passed if you are using quads.', frames, 
            function( frames ) 
                for _, frame in ipairs( frames ) do
                    local frameType = type( frame )
                    if frameType == 'userdata' then 
                        if not isUserdata( frame ) then 
                            return false 
                        end
                        frameType = frame:type()
                        if frameType ~= 'Image' and frameType ~= 'Quad' then 
                            return false
                        elseif frameType == 'Quad' then
                            if not quadImage then 
                                return false
                            end
                        end
                    else
                        return false
                    end
                end
                return true
            end 
        )
        if type( delays ) == 'table' then 
            err( 'newAnimation: argument 2 should have the same number of entries as argument 1.', delays, 
                function( delays )
                    return #delays == #frames
                end
            )
            err( 'newAnimation: expected argument 2 to be a table of numbers or a single number.', delays, 
                function( delays )
                    for index, delay in ipairs( delays ) do
                        local delayType = type( delay )
                        if delayType ~= 'number' then
                            if delayType == 'string' then
                                if not tonumber( delay ) then
                                    return false
                                else
                                    delays[index] = tonumber( delay )
                                end
                            else
                                return false
                            end
                        end
                    end
                    return true
                end
            )
        end

        local animation = {
            frames = frames, 
            delays = delays, 
            quadImage = quadImage, 

            currentFrame = 1, 
            delayTimer = 0,
            looping = false, 
            active = true, 
            paused = false, 
            pauseAtEnd = false, 

            update = function( self, dt )
                if self.active and not self.paused then
                    self.delayTimer = self.delayTimer + dt
                    if self.delayTimer > self.delays[self.currentFrame] then
                        self.delayTimer = 0
                        self.currentFrame = self.currentFrame + 1
                        if self.currentFrame > #self.frames then
                            if self.looping then 
                                self.currentFrame = 1
                            else
                                if not self.pauseAtEnd then
                                    self.active = false
                                else
                                    self.paused = true
                                end
                                self.currentFrame = #self.frames
                            end
                        end
                    end
                end
            end, 
            draw = function( self, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                if self.active then 
                    local frame = self.frames[self.currentFrame]
                    local frameType = frame:type()
                    if frameType == 'Image' then 
                        love.graphics.draw( frame, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                    elseif frameType == 'Quad' then 
                        love.graphics.draw( self.quadImage, frame, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                    end
                end 
            end, 
            
            setPaused = function( self, paused ) self.paused = paused end, 
            getPaused = function( self ) return self.pause end, 
            pause = function( self ) self.paused = true end, 
            resume = function( self ) self.paused = false end, 
            togglePause = function( self ) self.paused = not self.paused end, 
            setCurrentFrame = function( self, frame ) 
                self.currentFrame = frame 
                self.delayTimer = 0
            end, 
            getCurrentFrame = function( self ) return self.currentFrame end, 
            setActive = function( self, active ) self.active = active end, 
            getActive = function( self ) return self.active end,
            toggleactive = function( self ) self.active = not self.active end, 
            setLooping = function( self, looping ) self.looping = looping end, 
            getLooping = function( self ) return self.looping end, 
            toggleLooping = function( self ) self.looping = not self.looping end,  
            setPauseAtEnd = function( self, pauseAtEnd ) self.pauseAtEnd = pauseAtEnd end, 
            getPauseAtEnd = function( self ) return self.pauseAtEnd end, 
            togglePauseAtEnd = function( self ) self.pauseAtEnd = not self.pauseAtEnd end, 
            pauseAtEnd = function( self ) self.pauseAtEnd = true end, 
            restart = function( self )
                self:setCurrentFrame( 1 )
                self.active = true
                self.paused = false
            end, 
        }
        -- Aliases
        animation.isPaused = animation.getPaused
        animation.setFrame = animation.setCurrentFrame
        animation.gotoFrame = animation.setCurrentFrame
        animation.getFrame = animation.getCurrentFrame
        animation.isActive = animation.getActive
        animation.isLooping = animation.getLooping

        return animation
    end
}
