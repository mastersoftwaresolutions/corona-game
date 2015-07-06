-----------------------------------------------------------------------------------------
--
-- game.lua
-- Background graphic from http://opengameart.org/content/starfield-background, courtesy of Sauer2
-- Monkey, enemy, and bullet graphics are from http://www.vickiwenderlich.com/2013/05/free-game-art-space-monkey/
--
-----------------------------------------------------------------------------------------

-- Require in some of Corona's 
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


local widget = require( "widget" )
local json = require "json"
local particleDesigner = require( "particleDesigner" )

-- include Corona's "physics" library
local physics = require "physics"


local numberOfLives = 1
local bulletSpeed = 0.35
local badGuyMovementSpeed = 1200
local badGuyCreationSpeed = 1000

-- forward declarations and other locals
local background, monkey, bullet
local tmr_createBadGuy
local lives = {}
local badGuy = {}
local badGuyCounter = 1
local score = 0


dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view	

	function touched(event)		

		if(event.phase == "began") then

			angle = math.deg(math.atan2((event.y-monkey.y),(event.x-monkey.x)))            
            monkey.rotation = angle + 90

			bullet = display.newImageRect("IMG/grenade_red.png",12,16)
				bullet.x = dpw/2
				bullet.y = dph/2				
				bullet.name = "bullet"
				physics.addBody( bullet, "dynamic", { isSensor=true, radius=dph*.025} )
				group:insert(bullet)

			local farX = dpw*2
			local slope = ((event.yStart-dph/2)/(event.xStart-dpw/2))			
			local yInt = event.yStart - (slope*event.xStart)

			if(event.xStart >= dpw/2)then
				farX = dpw*2
			else
				farX = dpw-(dpw*2)
			end

			local farY = (slope*farX)+yInt
			
			local xfactor = farX-bullet.x
			local yfactor = farY-bullet.y
			
			local distance = math.sqrt((xfactor*xfactor) + (yfactor*yfactor))

			bullet.trans = transition.to(bullet, { time=distance/bulletSpeed, y=farY, x=farX, onComplete=nil})
		end
	end

	-- Create a background for our game
	background = display.newImageRect("IMG/background.png", 480, 320)
		background.x = dpw/2
		background.y = dph/2
		group:insert(background)
	
	-- Place our monkey in the center of screen
	monkey = display.newImageRect("IMG/spacemonkey-01.png",30,40)
		monkey.x = dpw/2
		monkey.y = dph/2
		group:insert(monkey)

	
	-- Insert our lives, but show them as bananas
	for i=1,numberOfLives do
		lives[i] = display.newImageRect("IMG/banana.png",45,34)
			lives[i].x = i*40-20
			lives[i].y = 18
			group:insert(lives[i])
	end

	-- This function will create our bad guy
	function createBadGuy()		

		-- Determine the enemies starting position
		local startingPosition = math.random(1,4)
		if(startingPosition == 1) then
			-- Send bad guy from left side of the screen
			startingX = -10
			startingY = math.random(0,dph)
		elseif(startingPosition == 2) then
			-- Send bad guy from right side of the screen
			startingX = dpw + 10
			startingY = math.random(0,dph)
		elseif(startingPosition == 3) then
			-- Send bad guy from the top of the screen
			startingX = math.random(0,dpw)
			startingY = -10
		else
			-- Send bad guy from the bototm of the screen
			startingX = math.random(0,dpw)
			startingY = dph + 10
		end
        if(numberOfLives > 0) then
		-- Start the bad guy according to starting position
		badGuy[badGuyCounter] = display.newImageRect("IMG/alien_1.png",34,34)
			badGuy[badGuyCounter].x = startingX
			badGuy[badGuyCounter].y = startingY
			physics.addBody( badGuy[badGuyCounter], "dynamic", { isSensor=true, radius=17} )
			badGuy[badGuyCounter].name = "badGuy"
			group:insert(badGuy[badGuyCounter])

		-- Then move the bad guy towards the center of the screen. Once the transition is done, remove the bad guy.
   
		badGuy[badGuyCounter].trans = transition.to(badGuy[badGuyCounter], { time=badGuyMovementSpeed, x=dpw/2, y=dph/2, 			
		onComplete = function (self)
			self.parent:remove(self); 
			self = nil;
			-- Since the bad guy has reached the monkey, we will want to remove a banana
			display.remove(lives[numberOfLives])
			numberOfLives = numberOfLives - 1			

			-- If the numbers of lives reaches 0 or less, it's game over!
			if(numberOfLives <= 0) then
				
                timer.cancel(tmr_createBadGuy)
				background:removeEventListener("touch", touched)
				timer.performWithDelay( 2000, goBack, 1)
			end
		end;})
	end
		badGuyCounter = badGuyCounter + 1
	end


	function goBack()
	timer.cancel(tmr_createBadGuy)
    storyboard:gotoScene("ads") 
end
 -- goBackTimer=timer.performWithDelay( 10000, goBack, 1 )

	-- This function handles the collisions. In our game, this will remove the bullet and bad guys when they collide. 
	function onCollision( event )		
		if(event.object1.name == "badGuy" and event.object2.name == "bullet" or event.object1.name == "bullet" and event.object2.name == "badGuy") then			
			
			-- Update the score
			

			-- Make the objects invisible
			event.object1.alpha = 0	
			event.object2.alpha = 0	

			-- Cancel the transitions on the object
			transition.cancel(event.object1.trans)
			transition.cancel(event.object2.trans)			

			-- Then remove the object after 1 cycle. Never remove display objects in the middle of collision detection. 
			local function removeObjects()				
				display.remove(event.object1)
				display.remove(event.object2)
			end
			timer.performWithDelay(1, removeObjects, 1)
		end
	end
end

function scene:enterScene( event )
	local group = self.view

	-- Actually start the game!	
	physics.start()
	
	tmr_createBadGuy = timer.performWithDelay(badGuyCreationSpeed, createBadGuy, 0)
	background:addEventListener("touch", touched)
	Runtime:addEventListener( "collision", onCollision )

end
function scene:willEnterScene( event )
local group = self.view
end
function scene:exitScene( event )
local group = self.view
 
end
function scene:didExitScene( event )
local group = self.view    
 
end
function scene:destroyScene( event )
local group = self.view
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )

return scene