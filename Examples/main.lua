require 'Utilities.Globals'

local animator = require 'utilities.animator'
local one = love.graphics.newImage( 'Source/Images/1.png' )
local quad = love.graphics.newImage( 'Source/Images/2 and 4.png' )
local three = love.graphics.newImage( 'Source/Images/3.png' )
local two = love.graphics.newQuad( 0, 0, 32, 32, 64, 32 )
local four = love.graphics.newQuad( 32, 0, 32, 32, 64, 32 )
local anim = animator.newAnimation( { one, two, three, four }, { 1, 1, '1', '1' }, quad )

-- {{{ love.load
function love.load()
--    GameState:gotoState( 'Loading' )

    input = Input()
    input:bind( 'escape', function() love.event.quit() end )
    camera = Camera( 0, 0, Globals.screenWidth, Globals.screenHeight )
end
-- }}}

-- {{{ love.update
function love.update( dt )
 --   GameState:update( dt )
    anim:update( dt )

    -- Input
    input:update( dt )
end
-- }}}

-- {{{ love.draw
function love.draw()
    camera:push()
        anim:draw()
  --      GameState:draw()
    camera:pop()
end
-- }}}

-- {{{ Others
function love.keypressed( key )
    input:keypressed( key )
end

function love.keyreleased( key )
    input:keyreleased( key )
end

function love.mousepressed( x, y, button )
    input:mousepressed( button)
end

function love.mousereleased(x, y, button)
    input:mousereleased( button )
end

function love.gamepadpressed( joystick, button )
    input:gamepadpressed( joystick, button )
end

function love.gamepadreleased( joystick, button )
    input:gamepadreleased( joystick, button )
end

function love.gamepadaxis( joystick, axis, value )
    input:gamepadaxis( joystick, axis, value )
end

function love.quit()
end
-- }}}
