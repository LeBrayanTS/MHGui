-- // Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Create Window
local Window = Rayfield:CreateWindow({
    Name = "My Market Tool",
    LoadingTitle = "My Market Tool",
    LoadingSubtitle = "by BrayanTS",
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

-- Teleport function
local function TeleportToPart(part)
    if not part or not part:IsA("BasePart") then return end
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    end
end

-- Auto collect loop
local collecting = false
local function StartAutoCollect()
    local myBase = FindPlayerBase()
    if not myBase then
        warn("No base found for player!")
        return
    end
    print("Found your base:", myBase.Name)

    task.spawn(function()
        while collecting do
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local oldPos = char.HumanoidRootPart.CFrame

                local collectors = myBase:FindFirstChild("Collectors")
                if collectors then
                    for _, collector in pairs(collectors:GetChildren()) do
                        if collector:IsA("BasePart") then
                            TeleportToPart(collector)
                            task.wait(0.1) -- Give time for touch to register
                        elseif collector:IsA("Model") then
                            local touchPart = collector:FindFirstChildWhichIsA("BasePart")
                            if touchPart then
                                TeleportToPart(touchPart)
                                task.wait(0.1)
                            end
                        end
                    end
                end

                -- Return to original position
                char.HumanoidRootPart.CFrame = oldPos
            end
            task.wait(1)
        end
    end)
end

-- Toggle
MainTab:CreateToggle({
    Name = "Enable Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        collecting = Value
        if Value then
            StartAutoCollect()
        else
            print("Auto Collect disabled")
        end
    end
})
