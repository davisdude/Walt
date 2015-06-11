Walt
====

An animation library for LÖVE.

#Table of Contents
- [Usage](#usage)
- [Functions](#functions)
    - [animator.merge](#animatormerge)
    - [animator.newAnimation](#animatornewanimation)
        - [anim:draw](#animatordraw)
        - [anim:getActive](#animgetactive)
        - [anim:getCurrentFrame](#animgetcurrentframe)
        - [anim:getDimensions](#animgetdimensions)
        - [anim:getHeight](#animgetheight)
        - [anim:getLooping](#animgetlooping)
        - [anim:getOnAnimationChange](#animgetonanimationchange)
        - [anim:getOnLoop](#animgetonloop)
        - [anim:getPauseAtEnd](#animgetpauseatend)
        - [anim:getPaused](#animgetpaused)
        - [anim:getWidth](#animgetwidth)
        - [anim:pause](#animpause)
        - [anim:pauseAtEnd](#animpauseatend)
        - [anim:restart](#animrestart)
        - [anim:resume](#animresume)
        - [anim:setActive](#animsetactive)
        - [anim:setCurrentFrame](#animsetcurrentframe)
        - [anim:setLooping](#animsetlooping)
        - [anim:setOnAnimationChange](#animsetonanimationchange)
        - [anim:setOnLoop](#animsetonloop)
        - [anim:setPauseAtEnd](#animsetpauseatend)
        - [anim:setPaused](#animsetpaused)
        - [anim:togglePause](#animtogglepause)
        - [anim:toggleActive](#animtoggleactive)
        - [anim:toggleLooping](#animtogglelooping)
        - [anim:togglePauseAtEnd](#animtogglepauseatend)
        - [anim:update](#animatorupdate)
        - [Aliases](#aliases)
    - [animator.newGrid](#animatornewgrid)
        - [grid:getFrames](#gridgetframes)
- [Examples](#examples)
- [License](#license)

##Usage
```Lua
local animator = require 'Path.to.walt'

function love.load()
    local image = love.graphics.newImage( 'Path/to/image.png' )
    anim = animator.newAnimation( { image }, 1 )
end

function love.update( dt )
    anim:update( dt )
end

function love.draw()
    anim:draw()
end
```
And that's it!

##Name
- Walt is named for famous animator Walt Disney.

##Functions
###animator.merge
- Combine several tables into one compact table.
- Synopsis
    - `frames = animator.merge( ... )`
- Arguments: 
	- `...`: Tables. A list of images and quads in the order of the animation. 
- Returns:
	- `frames`: Table. A flattened list of the quads and images. 
- Notes: 
    - Works well in combination with [newAnimation](#newanimation).

###animator.newAnimation
- Creates a new animation object. 
- Synopsis
    - `anim = animator.newAnimation( frames, duration, [quadImage] )`
    - `anim = animator.newAnimation( frames, durations, [quadImage] )`
- Arguments: 
    - `frames`: Table. A flat table of images and quads in the order that they will be played.
	- `duration`: Number. The amount of time each animation will be played.
    - `durations`: Table. There are several "___flavors___" to this table. Each must have the same number of entries as `frames`. You can combine these in any way.

| Flavor    | Description                                                                                                               | Example               |
| ----------|---------------------------------------------------------------------------------------------------------------------------|-----------------------|
| __Flat__  | A numbered list, representing the corresponding frame.                                                                    | `{ .1, .2, .1, .5 }`  |
| __List__  | A table key, listing the frame numbers, in the style of `lower - larger`. Can have 0-unlimited spaces between the `-`.    | `{ ['1 - 5'] = 1 }`   |
| __Key__   | Frame numbers are seperated by `,`. Can have 0-unlimited spaces after the `,`.                                            | `{ ['1, 3, 5'] = 1 }` |

	- `quadImage`: Image. The image that the quads for the animation will be using.
- Returns:
	- `anim`: 
- Notes: 
    - The quads should all be from the same image. 
    - After all of the `Key`s and `List`s are inserted, the unassigned ones are done in the order of the undone ones.
        - `{ ['1 - 3'] = .5, ['6 - 10'] = 1, .2, .3, .4 }` = `{ .5, .5, .5, .2, .3, .4, 1, 1, 1, 1, 1 }`

####anim:draw

####anim:getActive

####anim:getCurrentFrame

####anim:getDimensions

####anim:getHeight

####anim:getLooping

####anim:getOnAnimationChange

####anim:getOnLoop

####anim:getPauseAtEnd

####anim:getPaused

####anim:getWidth

####anim:pause

####anim:pauseAtEnd

####anim:restart

####anim:resume

####anim:setActive

####anim:setCurrentFrame

####anim:setLooping

####anim:setOnAnimationChange

####anim:setOnLoop

####anim:setPauseAtEnd

####anim:setPaused

####anim:togglePause

####anim:toggleActive

####anim:toggleLooping

####anim:togglePauseAtEnd

####anim:update

###Aliases

###animator.newGrid

####grid:getFrames

###Alisases
- There functions are also available, and work just like their conterpart.

| Alias		    	        | Corresponding Function	        	                    |
| --------------------------|:---------------------------------------------------------:|
| anim:isActive 	        | [anim:getActive](#animgetactive)		                    |
| anim:isLooping            | [anim:getLooping](#animgetlooping)                        |
| anim:isPaused	            | [anim:getPaused](#animgetpaused)                          |
| anim:getFrame 	        | [anim:getGetCurrentFrame](#animgetcurrentframe)		    |
| anim:gotoFrame            | [anim:setCurrentFrame](#animsetcurrentframe)              |
| anim:setAnimationChange   | [anim:setOnAnimationChange](#animsetonanimationchange)    |
| anim:setFrame             | [anim:setCurrentFrame](#animsetcurrentframe)              |
| grid:__call               | [grid:getFrames](#gridgetframes)                          |


##Examples
See [Examples](https://github.com/davisdude/Walt/tree/master/Examples/).

##License
An animation library for LÖVE
Copyright (C) 2015 Davis Claiborne
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
Contact me at davisclaib at gmail.com
