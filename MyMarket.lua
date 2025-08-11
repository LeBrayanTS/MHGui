-- // Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- // Create Window
local Window = Rayfield:CreateWindow({
    Name = "My Market Tool",
    LoadingTitle = "My Market Tool",
    LoadingSubtitle = "by YourNameHere",
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

-- Create a label to show base name inside the Rayfield GUI
local baseNameLabel = AutoCollectSection:CreateLabel("Base: Searching...")

-- Function to find player's base
local function FindPlayerBase()
    local playerName = game.Players.LocalPlayer.Name
    for _, plot in pairs(workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("Owner") then
            local ownerVal = plot.Owner.Value
            if typeof(ownerVal) == "string" and ownerVal == playerName then
                baseNameLabel:Set("Base: " .. plot.Name)
                return plot
            elseif typeof(ownerVal) == "Instance" and ownerVal:IsA("Player") and ownerVal.Name == playerName then
                baseNameLabel:Set("Base: " .. plot.Name)
                return plot
            end
        end
    end
    baseNameLabel:Set("Base: Not Found")
    return nil
end

-- Teleport function
local function TeleportToPart(part)
    local player = game.Players.LocalPlayer
    if not part or not part:IsA("BasePart") or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
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
                    -- Use GetDescendants to catch all parts inside collectors
                    for _, obj in ipairs(collectors:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            TeleportToPart(obj)
                            task.wait(0.2) -- Slightly longer wait for touch to register
                        end
                    end
                end

                -- Return to original position if still alive
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = oldPos
                end
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
