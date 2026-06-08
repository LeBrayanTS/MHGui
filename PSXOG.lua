local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Universal Egg Farmer",
   LoadingTitle = "Loading GUI...",
   LoadingSubtitle = "by BrayanTS",
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

-- Arguments table setup with flexible defaults
local args = {
    "Egg of Many Gifts", -- args[1]: Egg Name
    false                -- args[2]: Triple Hatch Factor (Default to single hatch)
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
        if autoEggActive and exactRemote then
            task.spawn(function()
                pcall(function()
                    exactRemote:InvokeServer(unpack(args))
                end)
            end)
        end
        task.wait(0.2)
    end
end)

-- 3. GUI Text Input Element for changing egg names
local Input = Tab:CreateInput({
   Name = "Target Egg Name",
   PlaceholderText = "Enter exact egg name here...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      args[1] = Text
   end,
})

-- 4. GUI Toggle for Triple Hatch (The True/False Factor)
local TripleToggle = Tab:CreateToggle({
   Name = "Triple Hatch (Gamepass Only)",
   CurrentValue = false,
   Flag = "TripleHatchToggle",
   Callback = function(Value)
      args[2] = Value -- Sets argument 2 to true if enabled, false if disabled
   end,
})

-- 5. GUI Main Toggle Construction
local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Egg",
   CurrentValue = false,
   Flag = "EggFarmToggle", 
   Callback = function(Value)
      autoEggActive = Value
      
      if autoEggActive and not exactRemote then
          Rayfield:Notify({
             Title = "Capture Required",
             Content = "Open ANY egg manually once to initialize the loop!",
             Duration = 4,
             Image = nil,
          })
      end
   end,
})
