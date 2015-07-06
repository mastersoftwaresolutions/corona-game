-- Keep Ups Game
-- Developed by Carlos Yanez

-- Hide Status Bar

local storyboard 	= 	require( "storyboard" )
local scene 		= 	storyboard.newScene()
local widget = require( "widget" )
local json = require "json"
local particleDesigner = require( "particleDesigner" )

-- Physics

local physics = require('physics')
physics.start()
--physics.setDrawMode('hybrid')

-- Graphics
dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight


function scene:createScene( event )
local group = self.view



local gameBg = display.newImage( "IMG/gameBgFootball.png",contentCenterX,display.contentCenterY)
gameBg.x = dpw/2
gameBg.y = dph/2
group:insert( gameBg )

-- Game Background

local gameBg

-- TextFields

local scoreTF

-- Instructions

local ins

local scoreTF

-- Ball

local ball

-- Alert

local alertView

-- Sounds

local ballHit = audio.loadSound('SFX/Footbal_kick.mp3')

-- Variables

local floor

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local onTap = {}
local onCollision = {}
local alert = {}

-- Main Function

function Main()
	showGameView()
end



function showGameView()
--	transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil end})
	
	-- [Add GFX]
	
	-- Instructions Message
	
	local ins = display.newImage('IMG/insfootbal.png', 44, 214)
	transition.from(ins, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(2000, function() transition.to(ins, {time = 200, alpha = 0.1, onComplete = function() display.remove(ins) ins = nil end}) end) end})
	
	scoreTF = display.newText('0', 62, 295, 'Marker Felt', 16)
	scoreTF:setTextColor(255, 204, 0)
	group:insert(scoreTF)
	-- Ball
	
	ball = display.newImage('IMG/ball.png', 205, 250)
	ball.name = 'ball'
	group:insert(ball)


	local wall1 = display.newRect(group, 0, 0, dpw, 30);
  wall1.x, wall1.y = centerX, topSide;
  wall1.isVisible = true;
  physics.addBody(wall1, "static", {bounce = .8});
 
  local wall2 = display.newRect( group,0, 0, 10, dph);
  wall2.x, wall2.y = leftSide, centerY;
  wall2.isVisible = true;
  physics.addBody(wall2, "static", {bounce = .8});
  
  
  local wall3 = display.newRect(group,0,0, 10, dph);
  wall3.x, wall3.y = display.contentWidth, centerY;
  wall3.isVisible = true;
  physics.addBody(wall3, "static", {bounce = .8});
	
	-- Floor
	
	floor = display.newLine(240, 321, 700, 321)
	group:insert(floor)
	
	-- Add Physics
	
	-- Ball
	
	physics.addBody(ball, 'dynamic', {radius = 30})
	
	-- Floor
	
	physics.addBody(floor, 'static')
	
	gameListeners('add')
end

function gameListeners(action)
	if(action == 'add') then
		ball:addEventListener('tap', onTap)
		floor:addEventListener('collision', onCollision)
	else
		ball:removeEventListener('tap', onTap)
		floor:removeEventListener('collision', onCollision)
	end
end

function onTap(e)
	audio.play(ballHit)
	ball:applyForce((ball.x - e.x) * 0.1, -15, ball.x, ball.y)
	scoreTF.text = tostring(tonumber(scoreTF.text) + 1)
end

function onCollision(e)
	if(tonumber(scoreTF.text) > 1) then
		alert(scoreTF.text)
	end
	scoreTF.text = 0
end

function alert(score)
	gameListeners('rmv')
	alertView = display.newImage('IMG/alert.png', dpw/2, dph/2)
	transition.from(alertView, {time = 300, xScale = 0.5, yScale = 0.5})
	
	local score = display.newText(scoreTF.text, dpw/2, display.contentCenterY+30, 'Marker Felt', 18)
	score:setTextColor(0,0,0)
	
	group:insert(alertView)
	group:insert(score)
	
	-- Wait 3 seconds to stop physics
	timer.performWithDelay(3000, function() physics.stop() end, 1)
	timer.performWithDelay(4000, goBack, 1)
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