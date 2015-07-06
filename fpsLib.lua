local fpsLib = {};

local desiredFPS = 1/60;

fpsLib.desiredFPS = desiredFPS;

local previousTime = 0;
local calculateFPS = function(event)
  local currTime = event.time;
  previousTime = previousTime == 0 and currTime or previousTime;
  fpsLib.FPS = (currTime-previousTime)*0.001/desiredFPS;
  previousTime = currTime;
end

fpsLib.init = function()
  Runtime:addEventListener("enterFrame", calculateFPS);
end

fpsLib.stop = function()
  Runtime:removeEventListener("enterFrame", calculateFPS);
end

return fpsLib;