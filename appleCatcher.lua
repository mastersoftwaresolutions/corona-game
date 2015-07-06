-- Apple Catcher Game
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
physics.setGravity(0, 9.8)


-- Graphics
dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- [Background]

function scene:createScene( event )
local group = self.view

local bg = display.newImage( "IMG/treebg.png",contentCenterX,display.contentCenterY)
bg.x = dpw/2
bg.y = dph/2
group:insert( bg )

-- [Title View]

local titleBg
local playBtn
local creditsBtn
local titleView

-- [Credits]

local creditsView

-- Basket

local basket

-- Variables

local infoBar
local timerSrc
local timeLeft
local times = 0
local score

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local dragBasket = {}
local update = {}
local onCollision = {}

-- Main Function

function Main()

	showGameView()

end


function showGameView()

	-- Basket
	
	basket = display.newImage('IMG/basket.png', 203, 240)
	group:insert(basket)
	
	-- Info Bar
	
	infoBar = display.newImage('IMG/infoBar.png', 75, 8)
	group:insert(infoBar)
	score = display.newText('0', 55, 8, native.systemFontBold, 14)
	score:setTextColor(0)
	timeLeft = display.newText('20', 165, 8, native.systemFontBold, 14)
	timeLeft:setTextColor(0)
	
	-- Add Physics
	
	physics.addBody(basket, 'static')
	
	-- Game Listeners
	
	gameListeners('add')
end

function gameListeners(action)
	if(action == 'add') then
		timerSrc = timer.performWithDelay(500, update, 0)
		basket:addEventListener('collision', onCollision)
		basket:addEventListener('touch', dragBasket)
	else
		timer.cancel(timerSrc)
		timerSrc = nil
		basket:removeEventListener('collision', onCollision)
		basket:removeEventListener('touch', dragBasket)
		physics.stop()
	end
end

-- Drag Basket

function dragBasket(e)
	if(e.phase == 'began') then
		lastX = e.x - basket.x
	elseif(e.phase == 'moved') then
		basket.x = e.x - lastX
	end
end

function update(e)
	-- Add Apple or Stick
	
	local rx = math.floor(math.random() * display.contentWidth)
	local r = math.floor(math.random() * 4) -- 0, 1, 2, or 3 (3 is stick)
	
	if(r == 3) then
		local stick = display.newImage('IMG/stick.png', rx, -20)
		stick.name = 'stick'
		physics.addBody(stick)
		group:insert(stick)
	else
		local apple = display.newImage('IMG/apple.png', rx, -40)
		apple.name = 'apple'
		physics.addBody(apple)
		group:insert(apple)
	end
	
	-- Decrease Timer
	
	times = times + 1
	if(times == 2) then
		timeLeft.text = tostring(tonumber(timeLeft.text) - 1)
		times = 0
	end
	
	-- Check if timer is over
	
	if(timeLeft.text == '0') then
		alert()
	end
end

function onCollision(e)
	if(e.other.name == 'apple') then
		-- Remove Apple
		display.remove(e.other)
		-- Display animation
		local scoreAnim = display.newText('+10', basket.x, basket.y-10, native.systemFontBold, 16)
		transition.to(scoreAnim, {time = 600, y = scoreAnim.y - 30, alpha = 0, onComplete = function() display.remove(scoreAnim) scoreAnim = nil end})
		-- Update Score
		score.text = tostring(tonumber(score.text) + 10)
	elseif(e.other.name == 'stick') then
		--Remove Stick
		display.remove(e.other)
		-- Display animation
		local scoreAnim = display.newText('-10', basket.x, basket.y-10, native.systemFontBold, 16)
		transition.to(scoreAnim, {time = 600, y = scoreAnim.y - 30, alpha = 0, onComplete = function() display.remove(scoreAnim) scoreAnim = nil end})
		-- Update Score
		score.text = tostring(tonumber(score.text) - 10)
	end
end

function alert()
	gameListeners('remove')
	local alertView = display.newImage('IMG/alert.png', dpw/2, dph/2)
	transition.from(alertView, {time = 300, xScale = 0.5, yScale = 0.5})
	local totalScore = display.newText(score.text, display.contentCenterX-11, display.contentCenterY + 24, native.systemFontBold, 21)
	totalScore:setTextColor(72, 34, 0)
	group:insert(alertView)
	group:insert(totalScore)
	timer.performWithDelay( 8000, goBack, 1 )
end

Main()

function goBack()
  storyboard:gotoScene("ads") 
end

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