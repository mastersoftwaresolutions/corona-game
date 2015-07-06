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

local url = "https://play.google.com/store?hl=en"

function scene:createScene( event )
local group = self.view

local sky = display.newImage( "IMG/sky.jpg",contentCenterX,display.contentCenterY)
sky.x = dpw/2
sky.y = dph/2
group:insert( sky )

-- for sound
local bgMusic = audio.loadStream('POL-rocket-station-short.wav')
local explo = audio.loadSound('explo.wav')

local Green_Text = display.newText("", display.contentCenterX, display.contentCenterY-100,native.systemFont,50)
Green_Text:setTextColor(0, 250, 0)

Green_Text.size = 20
Green_Text.text = "DownLoad The Application From Playstore For Free !!!"
group:insert( Green_Text )

local Blue_Text = display.newText("", display.contentCenterX, display.contentCenterY,native.systemFont,50)
Blue_Text:setTextColor(1, 0.5, 0)

Blue_Text.size = 20
Blue_Text.text = url

group:insert( Blue_Text )

local goButton = display.newImage("IMG/goButton.png")


goButton.x = display.contentWidth * 0.5
goButton.y = Blue_Text.y + 50

group:insert(goButton)

local backButton = display.newImage("IMG/goButton.png")


backButton.x = display.contentWidth * 0.5
backButton.y = goButton.y + 50

group:insert(backButton)

function goButton:tap()
     system.openURL(url)
    
end
function backButton:tap()
     storyboard:gotoScene("start") 
    
end

-- Listeners

goButton:addEventListener("tap", goButton)
backButton:addEventListener("tap", backButton)

local emitter

		emitter = particleDesigner.newEmitter("water_fountain.json")
		emitter.x = (contentCenterX)
		emitter.y = (contentCenterY)
		group:insert( emitter )



end


function scene:enterScene( event )
local group = self.view
if(storyboard.getPrevious() ~= nil) then
		storyboard.purgeScene(storyboard.getPrevious())
		storyboard.removeScene(storyboard.getPrevious())
	end
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