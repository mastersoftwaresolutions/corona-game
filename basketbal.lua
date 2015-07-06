local storyboard  =   require( "storyboard" )
local scene     =   storyboard.newScene()

local widget = require( "widget" )
local json = require "json"
local particleDesigner = require( "particleDesigner" )

local physics = require "physics"
physics.start()
physics.setGravity(0, 9.81)  -- 9.81 m/s*s in the positive x direction
physics.setScale(80)  -- 80 pixels per meter
physics.setDrawMode("normal")

-- Cutoff For Step 1
dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight


function scene:createScene( event )
local group = self.view

local Bg = display.newImage("IMG/courtbackground.png",contentCenterX,display.contentCenterY)
Bg.x = dpw/2
Bg.y = dph/2
group:insert( Bg )

local score = display.newText("Score: 0", 70, 20)
score:setTextColor(0, 0, 0)
score.size = 26
group:insert( score )

  local wall1 = display.newRect(0, 0, dpw, 10);
  wall1.x, wall1.y = centerX, topSide;
  wall1.isVisible = true;
  wall1:setFillColor(0, 0, 0)
  physics.addBody(wall1, "static", {bounce = .8});
  group:insert(wall1)

  local wall2 = display.newRect(0, 0, 10, dph);
  wall2.x, wall2.y = leftSide, centerY;
  wall2.isVisible = true;
  wall2:setFillColor(0, 0, 0)
  physics.addBody(wall2, "static", {bounce = .8});
  group:insert(wall2)
  
  local wall3 = display.newRect(0,0, 10, dph);
  wall3.x, wall3.y = display.contentWidth, centerY;
  wall3.isVisible = true;
  wall3:setFillColor(0, 0, 0)
  physics.addBody(wall3, "static", {bounce = .8});
	group:insert(wall3)

  local wall4 = display.newRect( 0, 0, dpw, 10);
  wall4.x, wall4.y = centerX, display.contentHeight;
  wall4.isVisible = true;
  wall4:setFillColor(0, 0, 0)
  physics.addBody(wall4, "static", {bounce = .8});
 group:insert(wall4)
  


local horizPost = display.newRect(430, 50, 10, 70)
horizPost:setFillColor(0, 0, 0)
horizPost.rotation = 90
group:insert(horizPost)
local horizjoint = display.newRect(390, 80, 10, 35)
horizjoint:setFillColor(0, 0, 0)
group:insert(horizjoint)


physics.addBody(horizjoint, "static", staticMaterial)
physics.addBody(horizPost, "static", staticMaterial)

--Create the Ball
local ball = display.newCircle(100, 200, 15)
ball:setFillColor(0,0,225)

physics.addBody(ball, {density=.2, friction=.3, bounce=.6, radius=10})
group:insert(ball)

-- End step 2

local speedX = 0
local speedY = 0
local prevTime = 0
local prevX = 0
local prevY = 0

-- A basic function for dragging physics objects
local function drag( event )
  local ball = event.target
  
  local phase = event.phase
  if "began" == phase then
    display.getCurrentStage():setFocus( ball )

    -- Store initial position
    ball.x0 = event.x - ball.x
    ball.y0 = event.y - ball.y
    
    -- Make body type temporarily "kinematic" (to avoid gravitional forces)
    event.target.bodyType = "kinematic"
    
    -- Stop current motion, if any
    event.target:setLinearVelocity(0, 0)
    event.target.angularVelocity = 0

  else
    if "moved" == phase then
      ball.x = event.x - ball.x0
      ball.y = event.y - ball.y0
    elseif "ended" == phase or "cancelled" == phase then
      display.getCurrentStage():setFocus( nil )
      event.target.bodyType = "dynamic"
      ball:setLinearVelocity(speedX, speedY)
    end
  end

  -- Stop further propagation of touch event!
  return true
end

function trackVelocity(event) 
  local timePassed = event.time - prevTime
  prevTime = prevTime + timePassed
  
  speedX = (ball.x - prevX)/(timePassed/1000)
  speedY = (ball.y - prevY)/(timePassed/1000)

  prevX = ball.x
  prevY = ball.y
end
Runtime:addEventListener("enterFrame", trackVelocity)
--ball:addEventListener("touch", drag)

local rimBack = display.newRect(380, 105, 5, 12)
rimBack:setFillColor(255,0,0)
rimBack.rotation=90
group:insert(rimBack)

local rimFront = display.newRect(340, 105, 5, 12)
rimFront:setFillColor(255,0,0)
rimFront.rotation=90
group:insert(rimFront)

local rimMiddle = display.newRect(360, 105, 5, 35)
rimMiddle:setFillColor(255,0,0)
rimMiddle.rotation=90
group:insert(rimMiddle)


physics.addBody(rimBack, "static", staticMaterial)
physics.addBody(rimFront, "static", staticMaterial)
scoreCtr = 0
local lastGoalTime = 1000

function intialiseBallListener()
  ball:addEventListener("touch", drag)
end
timer.performWithDelay(6000, intialiseBallListener, 1)

function monitorScore(event) 
  if event.time - lastGoalTime > 500  then
    if ball.x > 352 and ball.x < 380 and ball.y > 98 and ball.y < 105 then
      scoreCtr = scoreCtr + 1
      print(score)
      lastGoalTime = event.time
      score.text = "Score: " .. scoreCtr
      if(scoreCtr>3) then
        Runtime:removeEventListener("enterFrame", trackVelocity)
        ball:removeEventListener("touch", drag)
        Runtime:removeEventListener("enterFrame", monitorScore)
        timer.performWithDelay( 3000, goBack, 1 )
      end
    end
  end
end
Runtime:addEventListener("enterFrame", monitorScore)

end

function goBack()
    storyboard:gotoScene("ads") 
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
