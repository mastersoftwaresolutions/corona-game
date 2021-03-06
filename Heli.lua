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



local gameBg = display.newImage( "IMG/gameBg.png",contentCenterX,display.contentCenterY)
gameBg.x = dpw/2
gameBg.y = dph/2
group:insert( gameBg )


-- [Title View]

local titleBg
local playBtn
local creditsBtn
local titleView

-- [Credits]

local creditsView

-- TextFields

local scoreTF

-- Instructins Message

local ins

-- Helicopter

local helicopter

-- Blocks

local blocks = {}

-- Alert

local alertView

-- Sounds

local bgMusic = audio.loadStream('SFX/POL-rocket-station-short.wav')
local explo = audio.loadSound('SFX/explo.wav')

-- Variables

local timerSrc
local yPos = {90, 140, 180}
local speed = 5
local speedTimer
local up = false
local impulse = -60

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local createBlock = {}
local movePlayer = {}
local increaseSpeed = {}
local update = {}
local alert = {}

-- Main Function

function Main()
	
	showGameView()
	--startButtonListeners('add')
end

function showGameView()
	--transition.to(titleView, {time = 300, x = -titleView.height})
	
	-- [Add GFX]
	
	-- Instructions Message
	
	ins = display.newImage('IMG/insHeli.png', 180, 270)
	transition.from(ins, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(2000, function() transition.to(ins, {time = 200, alpha = 0.1, onComplete = function() display.remove(ins) ins = nil end}) end) end})
	
	-- TextFields

     scoreTF = display.newText('0', 450, 5, 'Marker Felt', 14)
     scoreTF:setTextColor(255, 255, 255)
     group:insert(scoreTF)
	-- Helicopter
	
	helicopter = display.newImage('IMG/helicopter.png', 23, 152)
	group:insert(helicopter)
	
	-- Walls
	
	local top = display.newRect(0, 60, 480, 1)
	top:setFillColor(34, 34, 34)
	group:insert(top)
	local bottom = display.newRect(0, 260, 480, 1)
	bottom:setFillColor(34, 34, 34)
	group:insert(bottom)
	
	-- Add physics
	
	physics.addBody(helicopter)
	physics.addBody(top, 'static')
	physics.addBody(bottom, 'static')
	
	blocks = display.newGroup()
	gameListeners('add')
	group:insert(blocks)
	audio.play(bgMusic, {loops = -1, channel = 1})
end

function gameListeners(action)
	if(action == 'add') then
		gameBg:addEventListener('touch', movePlayer)
		Runtime:addEventListener('enterFrame', update)
		timerSrc = timer.performWithDelay(1300, createBlock, 0)
		speedTimer = timer.performWithDelay(5000, increaseSpeed, 5)
		helicopter:addEventListener('collision', onCollision)
	else
		gameBg:addEventListener('touch', movePlayer)
		Runtime:removeEventListener('enterFrame', update)
		timer.cancel(timerSrc)
		timerSrc = nil
		timer.cancel(speedTimer)
		speedTimer = nil
		helicopter:removeEventListener('collision', onCollision)
	end
end

function createBlock()
	local b
	local rnd = math.floor(math.random() * 4) + 1
	b = display.newImage('IMG/block.png', display.contentWidth, yPos[math.floor(math.random() * 3)+1])
	b.name = 'block'
	-- Block physics
	physics.addBody(b, 'kinematic')
	b.isSensor = true
	blocks:insert(b)
end

function movePlayer(e)
	if(e.phase == 'began') then
		up = true
	end
	if(e.phase == 'ended') then
		up = false
		impulse = -100
	end
end

function increaseSpeed()
	speed = speed + 1
	-- Icon
	local icon = display.newImage('IMG/speed.png', 204, 124)
	transition.from(icon, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(500, function() transition.to(icon, {time = 200, alpha = 0.1, onComplete = function() display.remove(icon) icon = nil end}) end) end})
    group:insert(icon)
end

function update(e)
	-- Move helicopter up
	if(up) then

		impulse = impulse - 3
		helicopter:setLinearVelocity(0, impulse)
	end
	-- Move Blocks
	if(blocks ~= nil)then
		for i = 1, blocks.numChildren do
			blocks[i].x = blocks[i].x - speed
		end
	end
	scoreTF.text = tostring(tonumber(scoreTF.text) + 1)
end

function onCollision(e)
	audio.play(explo)
	display.remove(helicopter)
	audio.stop(1)
    audio.dispose()
    bgMusic = nil
    gameListeners('rmv')
	
	timer.performWithDelay( 3000, alert, 1 )
	
end

function alert() 

alertView = display.newImage('IMG/gameoveralert.png', dpw/2, dph/2)
transition.from(alertView, {time = 300, xScale = 0.5, yScale = 0.5}) 
group:insert(alertView)
-- Wait 100 ms to stop physics
timer.performWithDelay(1000, function() physics.stop() end, 1)
timer.performWithDelay( 3000, goBack, 1 )
end
function goBack()
    storyboard:gotoScene("ads") 
end

Main()

end


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