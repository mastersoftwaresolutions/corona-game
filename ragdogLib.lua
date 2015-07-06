------------------------------------------------------------------------
---This library contains a few functions that we're gonna use in several 
---parts of this template.
---We use various functions throughout our games and apps to speed up
---the most common practices. 
---Each template only contains a handful of these (the one useful to it)
---but we're planning on a release that will contain all our functions
---revised and polished up.
---Made by Ragdog Studios SRL in 2013 http://www.ragdogstudios.com
------------------------------------------------------------------------

local ragdogLib = {};

ragdogLib.getSaveValue = function(key)
  if not ragdogLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      ragdogLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  ragdogLib.saveTable = ragdogLib.saveTable or {};
  return ragdogLib.saveTable[key];
end

ragdogLib.setSaveValue = function(key, value, operateSave)
  if not ragdogLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      ragdogLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  ragdogLib.saveTable = ragdogLib.saveTable or {};
  ragdogLib.saveTable[key] = value;
  if operateSave then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "w+");
    local json = require "json";
    file:write(json.encode(ragdogLib.saveTable));
    io.close(file);
  end
  return ragdogLib.saveTable[key];
end

ragdogLib.newSimpleButton = function(group, img, width, height)
  local button = display.newImageRect(group or display.getCurrentStage(), img, width, height);
  function button:touch(event)
    if event.phase == "began" then
      display.getCurrentStage():setFocus(self);
      self.isFocus = true;
      if self.touchBegan then
        self:touchBegan();
      end
      return true;
    elseif event.phase == "moved" and self.isFocus then
      local bounds = self.contentBounds;
      if event.x > bounds.xMax or event.x < bounds.xMin or event.y > bounds.yMax or event.y < bounds.yMin then
        self.isFocus = false;
        display.getCurrentStage():setFocus(nil);
        if self.touchEnded then
          self:touchEnded();
        end
      end
      return true;
    elseif event.phase == "ended" and self.isFocus then
      self.isFocus = false;
      display.getCurrentStage():setFocus(nil);
      if self.touchEnded then
        self:touchEnded();
      end
      return true;
    end
  end
  button:addEventListener("touch", button);
  
  return button;
end

ragdogLib.convertRGB = function(r, g, b)
   return {r/255, g/255, b/255};
end

return ragdogLib;
