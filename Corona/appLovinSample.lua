--[[

Copyright (c) 2013 Binary Pumpkin Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--]]

local success1, appLovin = pcall(require, "plugin.applovin")
if not success1 then
  appLovin = nil; 
  print("Failed to require appLovin plugin") 
end

local function listenerFunc(event)
  if event.phase == "loaded" then
    -- BP: Interstitial Loaded
  elseif event.phase == "notAvailable" then
    -- BP: Interstitial not available ... need to update plugin to pass error code.
  elseif event.phase == "displayed" then
    -- BP: Interstitial shown.
  elseif event.phase == "closed" then
    -- BP: The user selected the close button; if you wish to track num ads skipped.
  elseif event.phase == "clicked" then
    -- BP: The user clicked the ad.
  else
  	print("[AppLovin] Unhandled phase: " .. tostring(event.phase)) 
  end
end

-- BP: If the plugin could be loaded, lets initialise it!
if appLovin ~= nil then
  appLovin.init(listenerFunc)
  appLovin.show()
end