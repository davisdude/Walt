local animator = require 'animator'
local anim

function love.load()
    love.graphics.setDefaultFilter( 'nearest', 'nearest' )
    local one = love.graphics.newImage( 'Images/1.png' )
    local quad = love.graphics.newImage( 'Images/2 and 4.png' )
    local three = love.graphics.newImage( 'Images/3.png' )
    local two = love.graphics.newQuad( 0, 0, 32, 32, 64, 32 )
    local four = love.graphics.newQuad( 32, 0, 32, 32, 64, 32 )
    anim = animator.newAnimation( { one, two, three, four }, { 1, 1, 1, 1 }, quad )
    anim:setLooping()
    rotation = 0
    scale = 0
end

function love.update( dt )
    rotation = rotation + dt
    scale = scale + dt
    anim:update( dt )
end

function love.draw()
    anim:draw( 400, 300, rotation, scale, scale, anim:getWidth() / 2, anim:getHeight() / 2, scale / 10 )
end

function love.keyreleased( key )
    if key == 'escape' then 
        love.event.quit()
    else 
        anim:restart()
    end
end
