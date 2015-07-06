----------------------------------------------------------------------------------
local storyboard  =   require( "storyboard" )
local scene     =   storyboard.newScene()
local fpsLib = require "fpsLib";

local widget = require( "widget" )
local json = require "json"
local particleDesigner = require( "particleDesigner" )
local physics = require( "physics" )
local ragdogLib = require "ragdogLib";


  
local colorOfScoreInGame = ragdogLib.convertRGB(255, 255, 255); --specify values in R G B range 0-255
local colorOfTitleInGame = ragdogLib.convertRGB(255, 255, 255); --specify values in R G B range 0-255
local colorOfInstructionsText = ragdogLib.convertRGB(255, 255, 255); --specify values in R G B range 0-255
local titleOfTheGame = "Wrong Way Racing";
local textOfInstructions = "Tap to change Lanes";

dpw =   display.contentWidth-(display.screenOriginX*2)
dph =   display.contentHeight-(display.screenOriginY*2)
cw  = contentWidth

_G.leftSide = display.screenOriginX;
_G.rightSide = display.contentWidth-display.screenOriginX;
_G.topSide = display.screenOriginY;
_G.bottomSide = display.contentHeight-display.screenOriginY;

--let's localize these values for faster reading
local totalWidth = dpw;
local totalHeight = dph;
local leftSide = _G.leftSide;
local rightSide = _G.rightSide;
local topSide = _G.topSide;
local bottomSide = _G.bottomSide;
local centerX = display.contentCenterX;
local centerY = display.contentCenterY;
local originX, originY = display.screenOriginX, display.screenOriginY;

local buttonSFX = _G.buttonSFX;
local hitSFX;
local countdownSFX;
local pointSFX;

local mRandom = math.random;
local mMax, mMin, mSin, mCos = math.max, math.min, math.sin, math.cos;
local mSqrt, mAtan2, mPi = math.sqrt, math.atan2, math.pi;

local currentScore, currentBest;
local gameLayer;
local hudLayer;
local createHud;
local createCar;


local mustChangeLanes;


local raceTrack;
local carSpeed = 200;
local initialCarSpeed = 200;
local maxCarSpeed = 300;

local speedIncreaseAtEachLap = 10;

local mainCar, enemyCar1, enemyCar2, enemyCar3;

local countdownTable = {
  "",
  "3..",
  "2..",
  "1..",
  "GO!!!"
};

local gameStart;


local curvesPoint = {
  352,
  137
};

local curvesCenter = {
  {352, centerY-30}
};

setupStartGame = function(group)
  carSpeed = initialCarSpeed;
  carsMustChangeLanes = 0;
  currentScore = 0;
  currentBest = ragdogLib.getSaveValue("bestScore") or 0;
  
  gameStart = nil;
  mainCar:setLinearVelocity(0, 0);
  enemyCar1:setLinearVelocity(0, 0);
  enemyCar2:setLinearVelocity(0, 0);
  enemyCar3:setLinearVelocity(0, 0);
  
  mainCar.x, mainCar.y = centerX+60, centerY+81;
  
  enemyCar1.x, enemyCar1.y = centerX, centerY+60;
  enemyCar2.x, enemyCar2.y = centerX+30, centerY+60;
  enemyCar3.x, enemyCar3.y = centerX+60, centerY+60;
  
  mainCar.currentLane = 2;
  enemyCar1.currentLane = 1;
  enemyCar2.currentLane = 1;
  enemyCar3.currentLane = 1;
  
  mainCar.linearDamping = 0;
  enemyCar1.linearDamping = 0;
  enemyCar2.linearDamping = 0;
  enemyCar3.linearDamping = 0;
  mainCar.angularVelocity = 0;
  enemyCar1.angularVelocity = 0;
  enemyCar2.angularVelocity = 0;
  enemyCar3.angularVelocity = 0;
  mainCar.angularDamping = 0;
  enemyCar1.angularDamping = 0;
  enemyCar2.angularDamping = 0;
  enemyCar3.angularDamping = 0;
  
  mainCar.isSensor = true;
  enemyCar1.isSensor = true;
  enemyCar2.isSensor = true;
  enemyCar3.isSensor = true;
  
  mainCar.rotation = 90;
  enemyCar1.rotation = -90;
  enemyCar2.rotation = -90;
  enemyCar3.rotation = -90;
  
  mainCar.time = 0;
  enemyCar1.time = 0;
  enemyCar2.time = 0;
  enemyCar3.time = 0;
  
  mainCar.insideCurve1 = nil;
  mainCar.readyForLap = nil;
  mainCar.insideCurve2 = nil;
  
  enemyCar1.insideCurve1 = nil;
  enemyCar1.insideCurve2 = nil;
  
  enemyCar2.insideCurve1 = nil;
  enemyCar2.insideCurve2 = nil;
  
  enemyCar3.insideCurve1 = nil;
  enemyCar3.insideCurve2 = nil;
  
  countdownObject.text = countdownTable[2];
  countdownObject.currentPoint = 2;
  countdownObject.time = 0;
  countdownObject.startPlay = true;
end

createCar = function(group, direction)
  local baseX, baseY = raceTrack.x, raceTrack.y-18;
  
  local car = display.newImageRect(group, "IMG/car.png", 21, 32);
  car.x, car.y = centerX+60, centerY+60;
  car.rotation = 90;
  if direction == 1 then
    car.rotation = -90;
  end
  car:setFillColor(mRandom(1, 255)/255, mRandom(1, 255)/255, mRandom(1, 255)/255);
  car.direction = direction;
  car.currentLane = 1;

  physics.addBody(car, {isSensor = true, radius = 10, bounce = .9});
 
  function car:enterFrame()
    if not gameStart then
      if self.angularDamping > 0 then
        self.time = self.time+1;
        if self.time > 2 then
          self.time = 0;
          local particle = display.newCircle(gameLayer, 0, 0, 2)
          particle:setFillColor(255, 70, 0);
          particle.r = 255;
          particle.g = 70;
          particle.alpha = .8;
          particle.speed = mRandom(1, 5)*.1;
          particle.x, particle.y = self.x+mRandom(-5, 5), self.y+mRandom(-5, 5);
          function particle:enterFrame()
            self.xScale = self.xScale+.1;
            self.yScale = self.xScale;
            self.y = self.y-self.speed;
            self.alpha = self.alpha-0.015;
            if self.alpha <= 0 then
              Runtime:removeEventListener("enterFrame", self);
              self:removeSelf();
            end
            self.r = self.r*.7;
            self.g = self.g*.7;
            self:setFillColor(self.r, self.g, 0);
          end
          Runtime:addEventListener("enterFrame", particle);
        end
      end
      return
    end
    local angle = self.rotation*math.pi/180;
    self:setLinearVelocity(mSin(angle)*carSpeed, -mCos(angle)*carSpeed);

    if self.currentLane == 2 then
      if self.direction == 2 then
        if self.x > 345 then
          if self.readyForLap then
            audio.play(pointSFX, {channel = audio.findFreeChannel()});
            currentScore = currentScore+1;
            carSpeed = carSpeed+speedIncreaseAtEachLap;
            if carSpeed > maxCarSpeed then
              carSpeed = maxCarSpeed;
            end
            self.readyForLap = nil;
          end
          self.insideCurve1 = true;
          self.rotation = self.rotation-((carSpeed*0.198)/20);
        elseif self.insideCurve1 then
          self.insideCurve1 = nil;
          self.rotation = -90;
          self.y = centerY-111;
        end
        
        if self.x < 137 then
          self.insideCurve2 = true;
          self.rotation = self.rotation-((carSpeed*0.198)/20);
        elseif self.insideCurve2 then
          self.insideCurve2 = nil;
          self.readyForLap = true;
          self.rotation = 90;
          self.y = centerY+81;
        end
      else
        if self.x > 345 then
          self.insideCurve1 = true;
          self.rotation = self.rotation+((carSpeed*0.198)/20);
        elseif self.insideCurve1 then
          if self == enemyCar1 and mRandom(1, 3) == 1 then
            self:changeLane();
            mustChangeLanes = 2;
          elseif self == enemyCar2 or self == enemyCar3 then
            if mustChangeLanes > 0 then
              self:changeLane();
              mustChangeLanes = mustChangeLanes-1;
            end
          end
          self.insideCurve1 = nil;
          self.rotation = -90;
          self.y = centerY+81;
          if self == enemyCar2 then
            self.x = enemyCar1.x+30;
          elseif self == enemyCar3 then
            self.x = enemyCar2.x+30;
          end
        end
        
        if self.x < 137 then
          self.insideCurve2 = true;
          self.rotation = self.rotation+((carSpeed*0.198)/20);
        elseif self.insideCurve2 then
          if self == enemyCar1 and mRandom(1, 3) == 1 then
            self:changeLane();
            mustChangeLanes = 2;
          elseif self == enemyCar2 or self == enemyCar3 then
            if mustChangeLanes > 0 then
              self:changeLane();
              mustChangeLanes = mustChangeLanes-1;
            end
          end
          self.insideCurve2 = nil;
          self.rotation = 90;
          self.y = centerY-111;
          if self == enemyCar2 then
            self.x = enemyCar1.x-30;
          elseif self == enemyCar3 then
            self.x = enemyCar2.x-30;
          end
        end
      end
    else
      if self.direction == 2 then
        if self.x > 345 then
          if self.readyForLap then
            audio.play(pointSFX, {channel = audio.findFreeChannel()});
            currentScore = currentScore+1;
            carSpeed = carSpeed+speedIncreaseAtEachLap;
            if carSpeed > maxCarSpeed then
              carSpeed = maxCarSpeed;
            end
            self.readyForLap = nil;
          end
          self.insideCurve1 = true;
          self.rotation = self.rotation-((carSpeed*0.251)/20);
        elseif self.insideCurve1 then
          self.insideCurve1 = nil;
          self.rotation = -90;
          self.y = centerY-92;
        end
        
        if self.x < 137 then
          self.insideCurve2 = true;
          self.rotation = self.rotation-((carSpeed*0.251)/20);
        elseif self.insideCurve2 then
          self.readyForLap = true;
          self.insideCurve2 = nil;
          self.rotation = 90;
          self.y = centerY+60;
        end
      else
        if self.x > 345 then
          self.insideCurve1 = true;
          self.rotation = self.rotation+((carSpeed*0.251)/20);
        elseif self.insideCurve1 then
          if self == enemyCar1 and mRandom(1, 3) == 1 then
            self:changeLane();
            mustChangeLanes = 2;
          elseif self == enemyCar2 or self == enemyCar3 then
            if mustChangeLanes > 0 then
              self:changeLane();
              mustChangeLanes = mustChangeLanes-1;
            end
          end     
          self.insideCurve1 = nil;
          self.rotation = -90;
          self.y = centerY+60;
          if self == enemyCar2 then
            self.x = enemyCar1.x+30;
          elseif self == enemyCar3 then
            self.x = enemyCar2.x+30;
          end
        end
        
        if self.x < 137 then
          self.insideCurve2 = true;
          self.rotation = self.rotation+((carSpeed*0.251)/20);
        elseif self.insideCurve2 then
          if self == enemyCar1 and mRandom(1, 3) == 1 then
            self:changeLane();
            mustChangeLanes = 2;
          elseif self == enemyCar2 or self == enemyCar3 then
            if mustChangeLanes > 0 then
              self:changeLane();
              mustChangeLanes = mustChangeLanes-1;
            end
          end
          self.insideCurve2 = nil;
          self.rotation = 90;
          self.y = centerY-92;
          if self == enemyCar2 then
            self.x = enemyCar1.x-30;
          elseif self == enemyCar3 then
            self.x = enemyCar2.x-30;
          end
        end
      end
    end
  end
  Runtime:addEventListener("enterFrame", car);
  
  local resetCar = function()
    car.transTo = nil;
  end

  if direction == 2 then
    function car:changeLane()
      if self.currentLane == 1 then
        self.currentLane = 2;
        local angle = (self.rotation-112.5)*math.pi/180;
        local newX, newY = self.x-mSin(angle)*21, self.y+mCos(angle)*21;
        self.transTo = transition.to(self, {time = 20, x = newX, y = newY, onComplete = resetCar});
      else
        self.currentLane = 1;
        local angle = (self.rotation-67.5)*math.pi/180;
        local newX, newY = self.x+mSin(angle)*21, self.y-mCos(angle)*21;
        self.transTo = transition.to(self, {time = 20, x = newX, y = newY, onComplete = resetCar});
      end
    end
    
    function car:collision(event)
      if event.phase == "began" then
        if self.currentLane == event.other.currentLane then
          audio.play(hitSFX, {channel = audio.findFreeChannel()});
          ragdogLib.setSaveValue("bestScore", currentBest, true);
          
          countdownObject.text = countdownTable[1];
          gameStart = nil;
          mainCar.linearDamping = 1;
          enemyCar1.linearDamping = 1;
          enemyCar2.linearDamping = 1;
          enemyCar3.linearDamping = 1;
          mainCar.angularVelocity = mRandom(-50, 50);
          enemyCar1.angularVelocity = mRandom(-50, 50);
          enemyCar2.angularVelocity = mRandom(-50, 50);
          enemyCar3.angularVelocity = mRandom(-50, 50);
          mainCar.angularDamping = .6;
          enemyCar1.angularDamping = .6;
          enemyCar2.angularDamping = .6;
          enemyCar3.angularDamping = .6;    
          mainCar.isSensor = false;
          enemyCar1.isSensor = false;
          enemyCar2.isSensor = false;
          enemyCar3.isSensor = false;

         timer.performWithDelay( 5000, goBack, 1 )
        end
      end
    end
    car:addEventListener("collision", car);
  else
    function car:changeLane()
      if self.currentLane == 1 then
        self.currentLane = 2;
        local angle = (self.rotation+112.5)*math.pi/180;
        local newX, newY = self.x-mSin(angle)*21, self.y+mCos(angle)*21;
        self.transTo = transition.to(self, {time = 50, x = newX, y = newY, onComplete = resetCar});
      else
        self.currentLane = 1;
        local angle = (self.rotation+67.5)*math.pi/180;
        local newX, newY = self.x+mSin(angle)*21, self.y-mCos(angle)*21;
        self.transTo = transition.to(self, {time = 50, x = newX, y = newY, onComplete = resetCar});
      end
    end
  end
  
  return car;
end
function goBack()
  currentBest=0;
  ragdogLib.setSaveValue("bestScore", currentBest, true);
  storyboard:gotoScene("ads") 
end

createHud = function(group)
  local scoreText = display.newEmbossedText(group, currentScore, 0, 0, native.systemFont, 60);
  scoreText.x, scoreText.y = centerX-60, centerY-30;
  
  local bestText = display.newEmbossedText(group, "Best "..currentBest, 0, 0, native.systemFont, 20);
  bestText.x, bestText.y = scoreText.x, scoreText.y+40;
  bestText.currentBest = currentBest;
  
  local countDownText = display.newEmbossedText(group, countdownTable[1], 0, 0, native.systemFont, 20);
  countDownText.x, countDownText.y = centerX, topSide+14;
  countDownText.time = 0;
  
  function countDownText:enterFrame()
    if not gameStart and self.startPlay then
      self.time = self.time+1*fpsLib.FPS;
      if self.time >= 60 then
        audio.play(countdownSFX, {channel = audio.findFreeChannel()});
        self.currentPoint = self.currentPoint+1;
        self.text = countdownTable[self.currentPoint]
        if self.currentPoint < #countdownTable then
          self.time = 0;
        else
          mustChangeLanes = 0;
          self.startPlay = nil;
          gameStart = true;
        end
      end
    end
    scoreText.text = currentScore;
    if bestText.currentBest ~= currentBest then
      bestText.text = "Best "..currentBest;
    end
    if currentScore > currentBest then
      currentBest = currentScore;
      bestText.text = "Best "..currentBest;
    end
  end
  Runtime:addEventListener("enterFrame", countDownText);
  
  countdownObject = countDownText;
end

-- "scene:create()"
function scene:createScene( event )
 local sceneGroup = self.view
end
function scene:willEnterScene( event )

    local sceneGroup = self.view
    
end

function scene:enterScene( event )
local sceneGroup = self.view
 
carSpeed = initialCarSpeed;
  mustChangeLanes = 0;
  
  physics.start();
  physics.setGravity(0,0);
  local group = self.view;
  
  
  
  countdownSFX = audio.loadSound("SFX/flapSFX.mp3");
  hitSFX = audio.loadSound("SFX/hitSFX.mp3");
  pointSFX = audio.loadSound("SFX/pointSFX.mp3");
  
  currentScore = 0;
  currentBest = 0;
  
   local bg = display.newImageRect(group, "IMG/bg.png", totalWidth, totalHeight);
  bg.x, bg.y = centerX, centerY;
  
  local track = display.newImageRect(group, "IMG/raceTrack.png", 508*.9, 333*.9);
  track.x, track.y = centerX, centerY;
  raceTrack = track;
  
  local gameTitle = display.newEmbossedText(group, titleOfTheGame, 0, 0, native.systemFont, 30);
  gameTitle.x, gameTitle.y = centerX, bottomSide-gameTitle.contentHeight*.5-24;
  gameTitle:setFillColor(unpack(colorOfTitleInGame));
  
  local instructionsText = display.newEmbossedText(group, textOfInstructions, 0, 0, native.systemFont, 15);
  instructionsText:setFillColor(unpack(colorOfInstructionsText));
  instructionsText.x, instructionsText.y = gameTitle.x, gameTitle.y+gameTitle.contentHeight*.5+instructionsText.contentHeight*.5;
  gameLayer = display.newGroup();
  hudLayer = display.newGroup();
  
  local wall1 = display.newRect(group, 0, 0, totalWidth, 30);
  wall1.x, wall1.y = centerX, topSide;
  wall1.isVisible = false;
  physics.addBody(wall1, "static", {bounce = .8});
  
  local wall2 = display.newRect(group, 0, 0, 30, totalHeight);
  wall2.x, wall2.y = leftSide, centerY;
  wall2.isVisible = false;
  physics.addBody(wall2, "static", {bounce = .8});
  
  local wall3 = display.newRect(group, 0, 0, totalWidth, 30);
  wall3.x, wall3.y = centerX, bottomSide;
  wall3.isVisible = false;
  physics.addBody(wall3, "static", {bounce = .8});
  
  local wall4 = display.newRect(group, 0, 0, 30, totalHeight);
  wall4.x, wall4.y = rightSide, centerY;
  wall4.isVisible = false;
  physics.addBody(wall4, "static", {bounce = .8});
  
  group:insert(gameLayer);
  group:insert(hudLayer);
  createHud(hudLayer);
  mainCar = createCar(gameLayer, 2);
  enemyCar1 = createCar(gameLayer, 1);
  enemyCar2 = createCar(gameLayer, 1);
  enemyCar3 = createCar(gameLayer, 1);
  
  enemyCar1.mainEnemyCar = true;
 setupStartGame();

  function bg:touch(event)
    if event.phase == "began" and not mainCar.transTo and gameStart then
      mainCar:changeLane();
    end
  end
  bg:addEventListener("touch", bg);
end



-- "scene:hide()"
function scene:exitScene( event )

    local sceneGroup = self.view
    local phase = event.phase

      physics.stop();
      audio.stop();
      audio.dispose(countdownSFX);
      audio.dispose(hitSFX);
      audio.dispose(pointSFX);
      countdownSFX = nil;
      hitSFX = nil;
      pointSFX = nil;
      
       removeAll = function(group)
        if group.enterFrame then
         -- Runtime:removeEventListener("enterFrame", group);
        end
        if group.touch then
          group:removeEventListener("touch", group);
          Runtime:removeEventListener("touch", group);
        end   
        for i = group.numChildren, 1, -1 do
          if group[i].numChildren then
            removeAll(group[i]);
          else
            if group[i].enterFrame then
              Runtime:removeEventListener("enterFrame", group[i]);
            end
            if group[i].touch then
              group[i]:removeEventListener("touch", group[i]);
              Runtime:removeEventListener("touch", group[i]);
            end
          end
        end
      end

      removeAll(self.view);
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    
end

function scene:didExitScene( event )
local sceneGroup = self.view    
end


-- "scene:destroy()"
function scene:destroyScene( event )
local sceneGroup = self.view
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )

-- -------------------------------------------------------------------------------

return scene