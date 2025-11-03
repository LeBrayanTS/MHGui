local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Miner's Haven Tool",
   Icon = 0,
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by BrayanTS",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MHTool"
   },
})

local MainTab = Window:CreateTab("Main", nil)

-- Auto Open Crate Section
local CrateSection = MainTab:CreateSection("Auto Open Crate")

local crateName = "Easter"
MainTab:CreateInput({
    Name = "Crate Name",
    PlaceholderText = "Enter crate name (e.g., Easter)",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        crateName = text
    end,
})

local autoOpen = false
MainTab:CreateToggle({
    Name = "Auto Open Crate",
    CurrentValue = false,
    Callback = function(value)
        autoOpen = value
        task.spawn(function()
            while autoOpen do
                local args = {
                    [1] = crateName
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("MysteryBox"):InvokeServer(unpack(args))
                end)
                task.wait(1)
            end
        end)
    end,
})

-- Auto Layout Section
local LayoutSection = MainTab:CreateSection("Auto Layout")

local layoutToggles = {
    Layout1 = false,
    Layout2 = false,
    Layout3 = false,
}

local function loopLayout(layoutName)
    task.spawn(function()
        while layoutToggles[layoutName] do
            local args = {
                [1] = "Load",
                [2] = layoutName
            }
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Layouts"):InvokeServer(unpack(args))
            end)
            task.wait(2) -- delay between layout loads
        end
    end)
end

-- Create toggles for each layout
for i = 1, 3 do
    local layoutName = "Layout" .. i
    MainTab:CreateToggle({
        Name = "Load " .. layoutName,
        CurrentValue = false,
        Callback = function(state)
            layoutToggles[layoutName] = state
            if state then
                loopLayout(layoutName)
            end
        end,
    })
end

local RebirthSection = MainTab:CreateSection("Auto Rebirth")

local autoRebirth = false

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(state)
        autoRebirth = state
        task.spawn(function()
            while autoRebirth do
                local args = {
                    [1] = 26
                }
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Rebirth"):InvokeServer(unpack(args))
                end)
                task.wait(.5)
            end
        end)
    end,
})

-- BOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOSTEEEEEEEEEEEEEEEEEEEEEEEEEEEEER PAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAART

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local tycoonsFolder = Workspace.Tycoons
local droppedParts = Workspace.DroppedParts

-- Detecta la base del jugador
local function getBase()
	local activeTycoon = localPlayer:WaitForChild("ActiveTycoon").Value
	for _, tycoonModel in ipairs(tycoonsFolder:GetChildren()) do
		if tycoonModel == activeTycoon then
			return tycoonModel
		end
	end
end

local baseModel = getBase()
local selectedCell = ""
local boosting = false

-- Mueve todas las hitboxes (Upgrade parts) a una sola zona flotante
local function moveUpgradersToCell(cell)
	local model = cell:FindFirstChild("Model")
	if not model then return end

	local lava = model:FindFirstChild("Lava") or model:FindFirstChild("Lava1")
	if not lava then return end

	local stackPos = lava.CFrame * CFrame.new(0, 20, 0) -- zona flotante

	for _, item in ipairs(baseModel:GetChildren()) do
		if item:IsA("Model") then
			local model = item:FindFirstChild("Model")
			if model then
				local upgradePart = model:FindFirstChild("Upgrade")
				if upgradePart then
					-- Mover la hitbox arriba de la cell
					upgradePart.CFrame = stackPos
					upgradePart.Size = Vector3.new(40, 40, 40) -- tamaño reducido para que sí funcione sin lag
					upgradePart.Transparency = 1
				end
			end
		end
	end

	return lava
end

-- Boosting Loop
task.spawn(function()
	while true do
		if boosting and baseModel and selectedCell ~= "" then
			local cell = baseModel:FindFirstChild(selectedCell)
			if cell then
				local lava = moveUpgradersToCell(cell)
				if lava then
					local oresFolder = droppedParts:FindFirstChild(baseModel.Name)
					if oresFolder then
						for _, ore in ipairs(oresFolder:GetChildren()) do
							if ore:IsA("BasePart") then
								-- Primero a la zona de los boosters
								ore.CFrame = lava.CFrame * CFrame.new(0, 20, 0)
								task.wait(0.2)

								-- Después al lava para procesarse
								ore.CFrame = lava.CFrame * CFrame.new(0, 5, 0)
							end
						end
					end
				end
			end
		end
		task.wait(1)
	end
end)

-- === Rayfield Integration ===
MainTab:CreateSection("Ore Booster")

MainTab:CreateLabel("Base: " .. (baseModel and baseModel.Name or "Not Found"))

MainTab:CreateInput({
	Name = "Cell Name",
	PlaceholderText = "Enter Cell Name (exactly)",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		selectedCell = text
	end,
})

MainTab:CreateToggle({
	Name = "Enable Ore Boosting",
	CurrentValue = false,
	Callback = function(value)
		boosting = value
	end,
})


local MiscTab = Window:CreateTab("Misc", nil)

-------------------------------------------------
-- ESP Section
-------------------------------------------------
local ESPSection = MiscTab:CreateSection("ESP")

local crateESPEnabled = false
local eggESPEnabled = false
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Objects"

local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local highlightParts = {}
local espLines = {}

local function clearESP()
    -- Remove Highlight instances
    for _, v in ipairs(espFolder:GetChildren()) do
        v:Destroy()
    end
    highlightParts = {}

    -- Remove Drawing lines
    for _, line in pairs(espLines) do
        line:Remove()
    end
    espLines = {}
end

local function createESP(object, color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = espFolder
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    table.insert(highlightParts, {object = object, color = color})
end

local function findHighlightPart(crate)
    if crate:IsA("BasePart") then
        return crate
    end
    for _, descendant in ipairs(crate:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

local function updateESP()
    clearESP()

    if crateESPEnabled then
        local boxesFolder = workspace:FindFirstChild("Boxes")
        if boxesFolder then
            for _, crate in ipairs(boxesFolder:GetChildren()) do
                if crate:FindFirstChildOfClass("Decal") or crate:FindFirstChildWhichIsA("Decal") then
                    local partToHighlight = findHighlightPart(crate)
                    if partToHighlight then
                        createESP(partToHighlight, Color3.fromRGB(255, 215, 0)) -- Gold
                    end
                end
            end
        end
    end

    if eggESPEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(obj.Name:lower(), "egg") then
                createESP(obj, Color3.fromRGB(255, 0, 255)) -- Pink
            end
        end
    end
end

-- Update Drawing lines every frame
RunService.RenderStepped:Connect(function()
    -- Clear previous lines
    for _, line in pairs(espLines) do
        line.Visible = false
        line:Remove()
    end
    espLines = {}

    local screenPos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, entry in ipairs(highlightParts) do
        local obj = entry.object
        local color = entry.color

        if obj and obj.Parent then
            local objPos = obj.Position
            local onScreen, screenPoint = pcall(function()
                return camera:WorldToViewportPoint(objPos)
            end)

            if onScreen then
                local inView = screenPoint.Z > 0
                if inView then
                    local line = Drawing.new("Line")
                    line.From = screenPos
                    line.To = Vector2.new(screenPoint.X, screenPoint.Y)
                    line.Color = color
                    line.Thickness = 2
                    line.Transparency = 1
                    line.Visible = true
                    table.insert(espLines, line)
                end
            end
        end
    end
end)

-- GUI toggles to control ESP
MiscTab:CreateToggle({
    Name = "Crate ESP",
    CurrentValue = false,
    Callback = function(state)
        crateESPEnabled = state
        updateESP()
    end,
})

MiscTab:CreateToggle({
    Name = "Egg ESP",
    CurrentValue = false,
    Callback = function(state)
        eggESPEnabled = state
        updateESP()
    end,
})

-- Periodic update to ESP highlights (every 3 seconds)
task.spawn(function()
    while true do
        if crateESPEnabled or eggESPEnabled then
            updateESP()
        end
        task.wait(3)
    end
end)
-------------------------------------------------
-- ESP Section END
-------------------------------------------------

local MiscSection = MiscTab:CreateSection("Egg Events")

local autoEasterEggs = false

local function collectEasterEggs()
    local Workspace = game:GetService("Workspace")
    local Easter = Workspace:FindFirstChild("Easter")
    local mapthing = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("EGG_SPAWNS")

    if not Easter and not mapthing then return end

    local function collectFrom(folder)
        for _, v in ipairs(folder:GetChildren()) do
            for _, child in ipairs(v:GetChildren()) do
                local prompt = child:FindFirstChild("ProximityPrompt")
                if prompt then
                    local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = child.CFrame
                        task.wait(0.5)
                        fireproximityprompt(prompt)
                        task.wait(0.5)
                    end
                end
            end
        end
    end

    if Easter then
        local easterthing = Easter:FindFirstChild("EASTER ISLAND EGG SPAWNS")
        if easterthing then
            collectFrom(easterthing)
        end
    end

    if mapthing then
        collectFrom(mapthing)
    end
end

MiscTab:CreateToggle({
    Name = "Auto Easter Eggs",
    CurrentValue = false,
    Callback = function(state)
        autoEasterEggs = state
        task.spawn(function()
            while autoEasterEggs do
                pcall(collectEasterEggs)
                task.wait(3) -- delay between each scan
            end
        end)
    end,
})

local selectedBox = "Pumpkin"
local autoCrateTP = false

-- CREATE TELEPORT
MiscTab:CreateToggle({
    Name = "Auto Crate TP",
    CurrentValue = false,
    Callback = function(state)
        autoCrateTP = state

        if state then
            local boxesFolder = workspace:WaitForChild("Boxes")
            local player = game.Players.LocalPlayer

            -- Teleport loop
            task.spawn(function()
                while autoCrateTP do
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        local crates = boxesFolder:GetChildren()
                        local closestCrate, closestDist, crateCFrame

                        for _, crate in ipairs(crates) do
                            local targetPart = nil

                            if crate:IsA("BasePart") then
                                targetPart = crate
                            elseif crate:IsA("Model") then
                                if crate.PrimaryPart then
                                    targetPart = crate.PrimaryPart
                                else
                                    targetPart = crate:FindFirstChildWhichIsA("BasePart")
                                end
                            end

                            if targetPart then
                                local dist = (hrp.Position - targetPart.Position).Magnitude
                                if not closestDist or dist < closestDist then
                                    closestDist = dist
                                    closestCrate = crate
                                    crateCFrame = targetPart.CFrame
                                end
                            end
                        end

                        if crateCFrame then
                            hrp.CFrame = crateCFrame -- dentro del crate
                        end
                    end

                    task.wait(0.25) -- ajusta el delay si quieres más rápido
                end
            end)
        end
    end,
})


-- Make sure this is at the top of your script or in a shared place
local HttpService = game:GetService("HttpService")

-- Auto Easter Egg Server Hop
local autoEasterHop = false
local hopToggle

-- Save toggle state
local function saveToggleState(state)
    pcall(function()
        writefile("AutoEasterHop.json", HttpService:JSONEncode({enabled = state}))
    end)
end

-- Load toggle state
local function loadToggleState()
    if isfile("AutoEasterHop.json") then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile("AutoEasterHop.json"))
        end)
        if success and result and typeof(result.enabled) == "boolean" then
            autoEasterHop = result.enabled
        end
    end
end

-- Main server hopping egg collector
local function startEggHop()
    repeat wait() until game:IsLoaded()

    local slotnumber = 1

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    wait(1)
    ReplicatedStorage.QuickLoad:InvokeServer(slotnumber)
    ReplicatedStorage.LoadPlayerData:InvokeServer(slotnumber)

    local Workspace = game:GetService("Workspace")
    local Easter = Workspace:FindFirstChild("Easter")
    local easterthing = Easter and Easter:FindFirstChild("EASTER ISLAND EGG SPAWNS")
    local mapthing = Workspace.Map:FindFirstChild("EGG_SPAWNS")

    local function collectEggs(container)
        for _, v in ipairs(container:GetChildren()) do
            for _, child in ipairs(v:GetChildren()) do
                local prompt = child:FindFirstChild("ProximityPrompt")
                if prompt then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = child.CFrame
                    task.wait(0.5)
                    fireproximityprompt(prompt)
                    wait(0.5)
                end
            end
        end
    end

    if easterthing then collectEggs(easterthing) end
    if mapthing then collectEggs(mapthing) end

    wait(1)

    -- Server hopping logic
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    local Deleted = false

    local File = pcall(function()
        AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
    end)
    if not File then
        AllIDs = {actualHour}
        writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
    end

    local function TPReturner()
        local Site
        if foundAnything == "" then
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
        end

        if Site.nextPageCursor then
            foundAnything = Site.nextPageCursor
        end

        for _, v in pairs(Site.data) do
            local ID = tostring(v.id)
            local Possible = true

            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if ID == tostring(Existing) then
                        Possible = false
                        break
                    end
                end

                if Possible then
                    table.insert(AllIDs, ID)
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                    wait(4)
                    break
                end
            end
        end
    end

    local function Teleport()
        while true do
            pcall(TPReturner)
            wait()
        end
    end

    Teleport()
end

-- Load toggle state before UI
loadToggleState()

-- Create toggle
hopToggle = MiscTab:CreateToggle({
    Name = "Auto Easter Egg (Server Hop)",
    CurrentValue = autoEasterHop,
    Callback = function(state)
        autoEasterHop = state
        saveToggleState(state)
        if state then
            task.spawn(startEggHop)
        end
    end
})

-- If toggle was ON before, reflect in UI and start
if autoEasterHop and hopToggle then
    hopToggle:Set(true)
    task.spawn(startEggHop)
end

-- 🔧 MISC: Auto Proximity Prompt Spammer
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local spamZ = false
local pressDelay = 0.08 -- ajusta la velocidad si quieres

MiscTab:CreateToggle({
    Name = "Spam Z (simulate key)",
    CurrentValue = false,
    Callback = function(state)
        spamZ = state
        if state then
            task.spawn(function()
                local vim = game:GetService("VirtualInputManager")
                while spamZ do
                    local ok, err = pcall(function()
                        -- Press Z down then up
                        vim:SendKeyEvent(true, "Z", false, game)
                        task.wait(0.1)
                        vim:SendKeyEvent(false, "Z", false, game)
                    end)
                    if not ok then
                        -- si falla VirtualInputManager, intenta fallback mínimo con VirtualUser click (no es Z, pero sirve de emergencia)
                        pcall(function()
                            local vu = game:GetService("VirtualUser")
                            vu:CaptureController()
                            vu:ClickButton1(Vector2.new(0,0))
                        end)
                    end
                    task.wait(pressDelay)
                end
            end)
        end
    end,
})
