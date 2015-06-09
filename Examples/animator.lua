--[[
    To-Do: 
        - Make grid code cleaner and more DRY
        - Grids for duration
        - README
        - onAnimationChange
        - onLoop
        - merge function (combine single tables and grids)
--]]

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
	assert( passed, 'Animation error: ' .. errCode )
end

local function getFrameType( self, frame )
    frame = frame or self.currentFrame
    return self.frames[frame]:type()
end

local function isPositive( x ) return x > 0 end
local function isInteger( x ) return x % 1 == 0 end

return {
    newGrid = function( frameWidth, frameHeight, image, startX, startY, stopWidth, stopHeight )
        local imageWidth, imageHeight = image:getDimensions()
        startX, startY = startX or 0, startY or 0
        stopX, stopY = stopX or imageWidth, stopY or imageHeight
        
        local frames = {
            reference = {}, 
            getFrames = function( self, ... )
                local args = { ... }
                local returns = {}

                err( 'getFrames: expected an even amount of arguments greater than one after the grid.', args, 
                    function( args )
                        return #args % 2 == 0 and #args ~= 0
                    end
                )
                for i = 1, #args, 2 do
                    local arg1, arg2 = args[i], args[i + 1]
                    err( 'getFrames: expected x argument ' .. i .. ' after grid to be a number or a string, got a %type%.', arg1, 'number', 'string' )
                    err( 'getFrames: expected y argument ' .. i .. ' after grid to be a number or a string, got a %type%.', arg2, 'number', 'string' )
                    err( 'getFrames: argument ' .. i .. ': both x and y can\'t be strings.', nil, 
                        function()
                            local arg1, arg2 = type( arg1 ), type( arg2 )
                            return ( arg1 == arg2 and arg1 == 'number' ) or ( arg1 ~= arg2 )
                        end
                    )

                    local which, start, stop = nil, nil, nil
                    err( 'getFrames: expected y argument ' .. i .. ' to be valid coordinate(s) of grid.', arg2, 
                        function( arg )
                            local numbers = {}
                            tostring( arg ):gsub( '(%d+)', function( y ) table.insert( numbers, tonumber( y ) ) end )
                            err( 'getFrames: y argument ' .. i .. ': too many numbers passed.', nil, 
                                function()
                                    return #numbers <= 2
                                end
                            ) 
                            local Start, Stop = unpack( numbers )
                            if Stop then 
                                which, start, stop = 'y', unpack( numbers )
                                for y = start, stop, math.abs( stop - start ) / ( stop - start ) do
                                    if not self.reference[y] then return false end
                                end
                            else
                                local y = tonumber( Start )
                                return self.reference[y]
                            end
                            return true
                        end
                    )
                    err( 'getFrames: expected x argument ' .. i .. ' to be valid coordinate(s) of grid.', arg1, 
                        function( arg )
                            local numbers = {}
                            tostring( arg ):gsub( '(%d+)', function( x ) table.insert( numbers, tonumber( x ) ) end )
                             err( 'getFrames: y argument ' .. i .. ': too many numbers passed.', nil, 
                                function()
                                    return #numbers <= 2
                                end
                            )
                            local Start, Stop = unpack( numbers )
                            if Stop then 
                                which, start, stop = 'x', Start, Stop
                                for x = start, stop, math.abs( stop - start ) / ( stop - start ) do
                                    if not self.reference[arg2][x] then return false end
                                end
                            else
                                local x = tonumber( Start )
                                if which then -- which is set to y
                                    local y = tonumber( arg2:match( '%d' ) )
                                    return self.reference[y][x]
                                else
                                    local y = tonumber( arg2 )
                                    return self.reference[y][x]
                                end
                            end
                            return true
                        end 
                    )
                    if which then
                        if which == 'x' then
                            local y = tonumber( arg2 )
                            for x = start, stop, math.abs( stop - start ) / ( stop - start ) do
                                table.insert( returns, self.reference[y][x] )
                            end
                        else -- which == y
                            local x = tonumber( arg1 )
                            for y = start, stop, math.abs( stop - start ) / ( stop - start ) do
                                table.insert( returns, self.reference[y][x] )
                            end
                        end
                    else
                        table.insert( returns, self.reference[arg2][arg1] )
                    end
                end
                
                return returns
            end, 
        }
        local x, y = 0, 0
        for y = startY, stopY - 1, frameHeight do
            local Y = ( y - startY ) / frameHeight + 1
            frames.reference[Y] = {}
            for x = startX, stopX - 1, frameWidth do
                local frame = love.graphics.newQuad( x, y, frameWidth, frameHeight, imageWidth, imageHeight )  
                table.insert( frames, frame )
                local X = ( x - startX ) / frameWidth + 1
                frames.reference[Y][X] = frame
            end
        end

        return setmetatable( frames, { __call = frames.getFrames } )
    end, 
    newAnimation = function( frames, delays, quadImage )
        err( 'newAnimation: expected argument 1 to be a table, got %type%.', frames, 'table' )
        err( 'newAnimation: expected argument 2 to be a table or a number, got %type%.', delays, 'table', 'number' )
        if quadImage then 
            err( 'newAnimation: expected argument 3 to be an image, got %type%.', quadImage, 
                function( quadImage )
                    if type( quadImage ) ~= 'userdata' then 
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
        local needsQuads = false
        err( 'newAnimation: expected argument 1 to be a table of images and/or quads.', frames, 
            function( frames ) 
                for _, frame in ipairs( frames ) do
                    local frameType = type( frame )
                    if frameType == 'userdata' then 
                        frameType = frame:type()
                        if frameType ~= 'Image' and frameType ~= 'Quad' then 
                            return false
                        elseif frameType == 'Quad' then
                            needsQuads = true
                        end
                    else
                        return false
                    end
                end
                return true
            end 
        )
        if needsQuads then 
            err( 'newAnimation: Need an image as the third argument for the reference quads!', needsQuads, 
                function( needsQuads )
                    return not not quadImage
                end 
            )
        end
        if type( delays ) == 'table' then 
            err( 'newAnimation: argument 2 should have the same number of entries as argument 1.', delays, 
                function( delays )
                    return #delays == #frames
                end
            )
            err( 'newAnimation: expected argument 2 to be a table of numbers or a single number.', delays, 
                function( delays )
                    for index, delay in ipairs( delays ) do
                        if type( delay ) ~= 'number' then return false end
                    end
                    return true
                end
            )
        else
            local delay = delays
            delays = {}
            for i = 1, #frames do
                delays[i] = delay
            end
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
            shouldPauseAtEnd = false, 

            update = function( self, dt )
                err( 'update: expected argument two to be a number, got %type%.', dt, 'number' )
                err( 'update: expected argument two to be positive.', dt, isPositive )

                if self.active and not self.paused then
                    self.delayTimer = self.delayTimer + dt
                    if self.delayTimer > self.delays[self.currentFrame] then
                        self.delayTimer = 0
                        self.currentFrame = self.currentFrame + 1
                        if self.currentFrame > #self.frames then
                            if self.looping then 
                                self.currentFrame = 1
                            else
                                if self.shouldPauseAtEnd then
                                    self.paused = true
                                else
                                    self.active = false
                                end
                                self.currentFrame = #self.frames
                            end
                        end
                    end
                end
            end, 
            draw = function( self, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                if self.active then 
                    err( 'draw: expected argument two to be a number or nil, got %type%.', x, 'number', 'nil' )
                    err( 'draw: expected argument three to be a number or nil, got %type%.', y, 'number', 'nil' )
                    err( 'draw: expected argument four to be a number or nil, got %type%.', rotation, 'number', 'nil' )
                    err( 'draw: expected argument five to be a number or nil, got %type%.', scaleX, 'number', 'nil' )
                    err( 'draw: expected argument six to be a number or nil, got %type%.', scaleY, 'number', 'nil' )
                    err( 'draw: expected argument seven to be a number or nil, got %type%.', offsetX, 'number', 'nil' )
                    err( 'draw: expected argument eight to be a number or nil, got %type%.', offsetX, 'number', 'nil' )
                    err( 'draw: expected argument nine to be a number or nil, got %type%.', shearingX, 'number', 'nil' )
                    err( 'draw: expected argument ten to be a number or nil, got %type%.', shearingY, 'number', 'nil' )

                    local frame = self.frames[self.currentFrame]
                    local frameType = frame:type()
                    if frameType == 'Image' then 
                        love.graphics.draw( frame, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                    elseif frameType == 'Quad' then 
                        love.graphics.draw( self.quadImage, frame, x, y, rotation, scaleX, scaleY, offsetX, offsetY, shearingX, shearingY )
                    end
                end 
            end, 
            
            setPaused = function( self, paused ) 
                err( 'setPaused: expected argument two be a boolean, got %type%.', paused, 'boolean' )
                self.paused = paused 
            end, 
            getPaused = function( self ) return self.pause end, 
            pause = function( self ) self.paused = true end, 
            resume = function( self ) self.paused = false end, 
            togglePause = function( self ) self.paused = not self.paused end, 
            setCurrentFrame = function( self, frame ) 
                err( 'setCurrentFrame: expected argument two to be a be number, got %type%.', frame, 'number' )
                err( 'setCurrentFrame: argument two must be a positive integer 1-#animation.frames.', frame, function( frame ) return self.frames[frame] end )
                self.currentFrame = frame
                self.delayTimer = 0
            end, 
            getCurrentFrame = function( self ) return self.currentFrame end, 
            setActive = function( self, active ) 
                err( 'setActive: expected argument two to be a boolean, got %type%.', active, 'boolean' )
                self.active = active 
            end, 
            getActive = function( self ) return self.active end,
            toggleactive = function( self ) self.active = not self.active end, 
            setLooping = function( self, looping ) 
                looping = looping or true
                err( 'setLooping: expected argument two to be a boolean, got %type%.', looping, 'boolean' )
                self.looping = looping 
            end, 
            getLooping = function( self ) return self.looping end, 
            toggleLooping = function( self ) self.looping = not self.looping end,  
            setPauseAtEnd = function( self, pauseAtEnd ) 
                err( 'setPauseAtEnd: expected argument two to be a boolean, got %type%.', pauseAtEnd, 'boolean' )
                self.shouldPauseAtEnd = pauseAtEnd 
            end, 
            getPauseAtEnd = function( self ) return self.shouldPauseAtEnd end, 
            togglePauseAtEnd = function( self ) self.shouldPauseAtEnd = not self.shouldPauseAtEnd end, 
            pauseAtEnd = function( self ) self.shouldPauseAtEnd = true end, 
            restart = function( self )
                self:setCurrentFrame( 1 )
                self.active = true
                self.paused = false
            end, 
            getWidth = function( self ) 
                local currentFrame = self.frames[self.currentFrame]
                local currentFrameType = getFrameType( self )
                return self.active and ( 
                        ( currentFrameType == 'Image' and currentFrame:getWidth() )
                    or  ( currentFrameType == 'Quad' and select( 3, currentFrame:getViewport() ) ) 
                )
            end, 
            getHeight = function( self )
                local currentFrame = self.frames[self.currentFrame]
                local currentFrameType = getFrameType( self )
                return self.active and (
                        ( currentFrameType == 'Image' and currentFrame:getHeight() )
                    or  ( currentFrameType == 'Quad' and select( 4, currentFrame:getViewport() ) )
                )
            end, 
            getDimensions = function( self )
                local currentFrame = self.frames[self.currentFrame]
                local currentFrameType = getFrameType( self )
                if self.active then -- Ternary returns don't do multiples
                    if currentFrameType == 'Image' then
                        return currentFrame:getDimensions()
                    elseif currentFrameType == 'Quad' then
                        return self:getWidth(), self:getHeight()
                    end
                end
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
