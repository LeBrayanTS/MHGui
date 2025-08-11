-- // Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Create Window
local Window = Rayfield:CreateWindow({
    Name = "My Market Tool",
    LoadingTitle = "My Market Tool",
    LoadingSubtitle = "by YourNameHere", -- Change to your name
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyMarketTool",
        FileName = "MyMarketToolConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- // Create Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- // Create Auto Collect Section
local AutoCollectSection = MainTab:CreateSection("Auto Collect")

-- Function to find player's base
local function FindPlayerBase()
    local playerName = game.Players.LocalPlayer.Name
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") and plot.Owner.Value == playerName then
            return plot
        end
    end
    return nil
end

-- Toggle for Auto Collect
MainTab:CreateToggle({
    Name = "Enable Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        if Value then
            print("Auto Collect enabled")
            local myBase = FindPlayerBase()
            if myBase then
                print("Found your base:", myBase.Name)
                -- You can now use `myBase` for your auto collect logic
            else
                warn("No base found for player!")
            end
        else
            print("Auto Collect disabled")
        end
    end
})
