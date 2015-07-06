local storyboard 	= 	require( "storyboard" )
local scene 		= 	storyboard.newScene()

local widget = require( "widget" )
local json = require "json"
local particleDesigner = require( "particleDesigner" )
local physics = require( "physics" )
physics.start()

dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight


function scene:createScene( event )
local group = self.view




-- The final "true" parameter overrides Corona's auto-scaling of large images


local background = display.newImage( "IMG/jungle_bkg.png",contentCenterX,display.contentCenterY)
background.x = dpw/2
background.y = dph/2
group:insert( background )


local pole1 = display.newImage( "IMG/bamboo.png" )
pole1.x = 50; pole1.y = 250; pole1.rotation = -12
physics.addBody( pole1, "static", { friction=0.5 } )
group:insert( pole1 )

local pole2 = display.newImage( "IMG/bamboo.png" )
pole2.x = 430; pole2.y = 250; pole2.rotation = 12
physics.addBody( pole2, "static", { friction=0.5 } )
group:insert( pole2 )

local instructionLabel = display.newText( "touch boards to break bridge, touch rocks to remove", centerX, 40, native.systemFont, 17 )
instructionLabel:setFillColor( 190/255, 1, 131/255, 150/255 )
group:insert( instructionLabel )

local board = {}
local joint = {}
local ball


-- A touch listener to "break" bridge joints
local breakJoint = function( event )
	local t = event.target
	local phase = event.phase

	if "began" == phase then
		local myIndex = t.myIndex
		print( "breaking joint at board#" .. myIndex )
		joint[myIndex]:removeSelf() -- destroy joint
		 timer.performWithDelay( 3000,  goBack, 1 )
	end
	-- Stop further propagation of touch event
	return true
end



function goBack()
	timer.cancel( randomBallTimer )
	timer.cancel( goBackTimer )
	
    storyboard:gotoScene("ads") 
end
 goBackTimer=timer.performWithDelay( 10000, goBack, 1 )


-- A touch listener to remove rocks
local removeBody = function( event )
	local t = event.target
	local phase = event.phase

	if "began" == phase then
		t:removeSelf() -- destroy object
		
	end

	-- Stop further propagation of touch event
	return true

end

for j = 1,16 do
	board[j] = display.newImage( "IMG/board.png" )
	board[j].x = 20 + (j*26)
	board[j].y = 150
	board[j].myIndex = j -- for touch handler above
	board[j]:addEventListener( "touch", breakJoint ) -- assign touch listener to board
	group:insert( board[j] )
	
	
	physics.addBody( board[j], { density=2, friction=0.3, bounce=0.3 } )
	
	-- damping the board motion increases the "tension" in the bridge
	board[j].angularDamping = 5000
	board[j].linearDamping = 0.7

	-- create joints between boards
	if (j > 1) then
		prevLink = board[j-1] -- each board is joined with the one before it
	else
		prevLink = pole1 -- first board is joined to left pole
	end
	joint[j] = physics.newJoint( "pivot", prevLink, board[j], 6+(j*26), 150 )

end

-- join final board to right pole
joint[#joint + 1] = physics.newJoint( "pivot", board[16], pole2, 6+(17*26), 150 )

local balls = {}

-- function to drop random coconuts and rocks
local randomBall = function()

	choice = math.random( 100 )
	
	
	if ( choice < 80 ) then
		ball = display.newImage( "IMG/coconut.png" )
		ball.x = 40 + math.random( 380 ); ball.y = -40
		physics.addBody( ball, { density=0.6, friction=0.6, bounce=0.6, radius=19 } )
		ball.angularVelocity = math.random(800) - 400
		ball.isSleepingAllowed = false
		group:insert( ball )
	
	else
		ball = display.newImage( "IMG/rock.png" )
		ball.x = 40 + math.random( 380 ); ball.y = -40
		physics.addBody( ball, { density=2.0, friction=0.6, bounce=0.2, radius=33 } )
		ball.angularVelocity = math.random(600) - 300
		group:insert( ball )
		
	end
	
	ball:addEventListener( "touch", removeBody ) -- assign touch listener to rock
	balls[#balls + 1] = ball	
end

-- run the above function 14 times
randomBallTimer = timer.performWithDelay( 1500, randomBall, 14 )







end--end


function scene:enterScene( event )
local group = self.view
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
---------------------------------------------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )
---------------------------------------------------------------------------------
return scene