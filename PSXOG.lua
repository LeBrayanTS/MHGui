local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Silent Egg Farmer",
   LoadingTitle = "Loading GUI...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

local Tab = Window:CreateTab("Farm", nil)

-- Configuration Variables
local autoEggActive = false
local exactRemote = nil
local oldNamecall

local args = {
    "Egg of Many Gifts",
    true
}

-- 1. Setup the namecall hook right away to capture the remote on manual hatch
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    
    if (method == "InvokeServer" or method == "invokeServer") and self:IsA("RemoteFunction") then
        local callingScript = getcallingscript()
        
        if callingScript and (callingScript.Name == "2 - Network" or callingScript.Name == "Eggs") then
            exactRemote = self
            hookmetamethod(game, "__namecall", oldNamecall) -- Restore original namecall once caught
        end
    end
    
    return oldNamecall(self, ...)
end)

-- 2. Persistent Background Loop Worker
task.spawn(function()
    while true do
        -- Only fire if the toggle is enabled AND the remote has been captured
        if autoEggActive and exactRemote then
            task.spawn(function()
                pcall(function()
                    exactRemote:InvokeServer(unpack(args))
                end)
            end)
        end
        task.wait(0.6) -- The exact delay from your base script
    end
end)

-- 3. GUI Toggle Construction
local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Egg",
   CurrentValue = false,
   Flag = "EggFarmToggle", 
   Callback = function(Value)
      autoEggActive = Value
      
      -- If they turn it on but haven't initialized the remote yet, remind them
      if autoEggActive and not exactRemote then
          Rayfield:Notify({
             Title = "Capture Required",
             Content = "Open ONE egg manually now to initialize the silent loop!",
             Duration = 4,
             Image = nil,
          })
      end
   end,
})
