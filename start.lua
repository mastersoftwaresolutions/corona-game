local fpsLib = require "fpsLib";
fpsLib.init();
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

function scene:createScene( event )
local group = self.view


local sky = display.newImage( "IMG/sky.jpg",contentCenterX,display.contentCenterY)
sky.x = dpw/2
sky.y = dph/2
group:insert( sky )

local emitter

		emitter = particleDesigner.newEmitter("air_stars.json")
		emitter.x = (contentCenterX)
		emitter.y = (contentCenterY)
		group:insert( emitter )
		
local button = {}

y= -50

for count = 1,3 do
    y = y + 110
    x = 20

    for insideCount = 1,3 do
        x = x + 110

        button[count] = display.newImage("IMG/1.png")             

        button[count].x = x
        button[count].y = y   
		group:insert(button[count])
		
		
        local container = display.newContainer( 0, 0 )
        container:translate(button[count].x, button[count].y)
		group:insert( container )
		
        local bkgd = display.newImage( container, "IMG/2.png" )
		


        function buttonTap(self)
        button[count].touch = transition.to(container,{time=1000, height = button[count].height+x, width = button[count].width+y})
		
         function StartGame()
            storyboard.purgeScene("main")
              if count == 1 and insideCount == 1 then
                    storyboard:gotoScene("bridge")
                    elseif count == 1 and insideCount == 2 then
					storyboard:gotoScene("Heli")
                    elseif count == 1 and insideCount ==3 then
                     storyboard:gotoScene("wrongWay")
                        elseif count == 2 and insideCount ==1 then
                       storyboard:gotoScene("spaceMonkey")
                        elseif count == 2 and insideCount ==2 then
                       storyboard:gotoScene("shootGame")
                        elseif count == 2 and insideCount ==3 then
                       storyboard:gotoScene("footbal")
                       elseif count == 3 and insideCount ==1 then
                       storyboard:gotoScene("basketbal")
                        elseif count == 3 and insideCount ==2 then
                       storyboard:gotoScene("paddle")
                        elseif count == 3 and insideCount ==3 then
                       storyboard:gotoScene("appleCatcher")
                end    
        end
        timer.performWithDelay( 400, StartGame, 1 )
        
        end

        button[count]:addEventListener( "touch", buttonTap)
    end
end





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