-- Bullets Game
-- Developed by Carlos Yanez

-- Hide Status Bar

local storyboard 	= 	require( "storyboard" )
local scene 		= 	storyboard.newScene()
-- Physics

local physics = require('physics')
physics.start()
physics.setGravity(0, 0)

--physics.setDrawMode('hybrid')

-- Graphics
dpw =  	display.contentWidth
dph =  	display.contentHeight
cw	=	contentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight
-- [Background]
function scene:createScene( event )
local group = self.view

local gameBg = display.newImage( "IMG/ShootBg.png",contentCenterX,display.contentCenterY)
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


-- Instructins Message

local ins

-- Bullets

local bulletsLeft
local bullets
local exploBullets = {}

-- Turret

local turret

-- Enemy

local enemies

-- Sounds

local bgMusic = audio.loadStream('SFX/POL-hard-corps-short.mp3')
local shootSnd = audio.loadSound('SFX/shoot.wav')
local exploSnd = audio.loadSound('SFX/explo.wav')

-- Variables

local timerSrc
local yPos = {58, 138, 218}
local speed = 3
local targetX
local targetY

-- Functions

local Main = {}
local startButtonListeners = {}
local showCredits = {}
local hideCredits = {}
local showGameView = {}
local gameListeners = {}
local createEnemy = {}
local shoot = {}
local update = {}
local onCollision = {}
local addExBullets = {}


-- Main Function

function Main()
	showGameView()
end

function showGameView()
	-- transition.to(titleView, {time = 300, x = -titleView.height, onComplete = function() startButtonListeners('rmv') display.remove(titleView) titleView = nil gameBg:addEventListener('tap', shoot) end})
	
	-- [Add GFX]
	
	-- Instructions Message
	
	ins = display.newImage('IMG/insShoot.png', 135, 255)
	transition.from(ins, {time = 200, alpha = 0.1, onComplete = function() timer.performWithDelay(2000, function() transition.to(ins, {time = 200, alpha = 0.1, onComplete = function() display.remove(ins) ins = nil end}) end) end})
	
	-- Bullets Left
	
	bullets = display.newGroup()
	
	bulletsLeft = display.newGroup()
	for i = 1, 10 do
		local b = display.newImage('IMG/bullet.png', i*12, 12)
		bulletsLeft:insert(b)
		
	end
	
	-- TextFields
	
	scoreTF = display.newText('0', 80, 35.5, 'Courier Bold', 16)
	scoreTF:setTextColor(239, 175, 29)
	group:insert(scoreTF)

	-- Turret
	
	turret = display.newImage('IMG/turret.png', 220, 301)
	
	enemies = display.newGroup()
	gameListeners('add')
	group:insert(turret)

	audio.play(bgMusic, {loops = -1, channel = 1})
end

function gameListeners(action)
	if(action == 'add') then
		timerSrc = timer.performWithDelay(1200, createEnemy, 0)
		Runtime:addEventListener('enterFrame', update)
		gameBg:addEventListener('tap', shoot)
	else
		timer.cancel(timerSrc)
		timerSrc = nil
		Runtime:removeEventListener('enterFrame', update)
		gameBg:removeEventListener('tap', shoot)
	end
end

function createEnemy()
    local enemy
    local rnd = math.floor(math.random() * 4) + 1
    enemy = display.newImage('IMG/enemy.png', display.contentWidth, yPos[math.floor(math.random() * 3)+1])
    enemy.name = 'bad'
    -- Enemy physics
    physics.addBody(enemy)
    enemy.isSensor = true
    enemy:addEventListener('collision', onCollision)
    enemies:insert(enemy)
    group:insert(enemies)
end

function shoot()
	audio.play(shootSnd)
	local b = display.newImage('IMG/bullet.png', turret.x, turret.y)
	
	physics.addBody(b)
	b.isSensor = true
	bullets:insert(b)

	-- Remove Bullets Left
	bulletsLeft:remove(bulletsLeft.numChildren)
	-- End game 4 seconds after last bullet
	if(bulletsLeft.numChildren == 0) then
		gameBg:removeEventListener('tap', shoot)
		timer.performWithDelay(4000, alert, 1)
	end
end

function update()
	-- Move enemies
	if(enemies ~= nil)then
		for i = 1, enemies.numChildren do
			enemies[i].x = enemies[i].x - speed
		end
	end
	-- Move Shoot bullets
	if(bullets[1] ~= nil) then
		for i = 1, bullets.numChildren do
			bullets[i].y = bullets[i].y - speed*2
		end
	end
	-- Move Explosion Bullets
	if(exploBullets[1] ~= nil) then
		for j = 1, #exploBullets do
			if(exploBullets[j][1].y ~= nil) then exploBullets[j][1].y = exploBullets[j][1].y + speed*2 end
			if(exploBullets[j][2].y ~= nil) then exploBullets[j][2].y = exploBullets[j][2].y - speed*2 end
			if(exploBullets[j][3].x ~= nil) then exploBullets[j][3].x = exploBullets[j][3].x + speed*2 end
			if(exploBullets[j][4].x ~= nil) then exploBullets[j][4].x = exploBullets[j][4].x - speed*2 end
		end
	end
end

function onCollision(e)
	audio.play(exploSnd)
	targetX = e.target.x
	targetY = e.target.y
	timer.performWithDelay(100, addExBullets, 1)
	-- Remove Collision Objects
	display.remove(e.target)
	e.target = nil
	display.remove(e.other)
	e.other = nil
	-- Increase Score
	scoreTF.text = tostring(tonumber(scoreTF.text) + 50)
	scoreTF.x = 90
	
end

function addExBullets()
	-- Explosion bullets
	local eb = {}
	local b1 = display.newImage('IMG/bullet.png', targetX, targetY)
	local b2 = display.newImage('IMG/bullet.png', targetX, targetY)
	local b3 = display.newImage('IMG/bullet.png', targetX, targetY)
	local b4 = display.newImage('IMG/bullet.png', targetX, targetY)
	group:insert(b1)
	group:insert(b2)
	group:insert(b3)
	group:insert(b4)
	
	physics.addBody(b1)
	b1.isSensor = true
	physics.addBody(b2)
	b2.isSensor = true
	physics.addBody(b3)
	b3.isSensor = true
	physics.addBody(b4)
	b4.isSensor = true
	table.insert(eb, b1)
	table.insert(eb, b2)
	table.insert(eb, b3)
	table.insert(eb, b4)
	table.insert(exploBullets, eb)

end

function alert()
	audio.stop(1)
	audio.dispose()
	bgMusic = nil
	gameListeners('rmv')
	alertView = display.newImage('IMG/alert.png', dpw/2, dph/2)
	transition.from(alertView, {time = 300, xScale = 0.5, yScale = 0.5})
	
	local score = display.newText(scoreTF.text, dpw/2, display.contentCenterY+24, 'Courier Bold', 25)
	score:setTextColor(0,0,0)
	
	group:insert(alertView)
	group:insert(score)
	
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