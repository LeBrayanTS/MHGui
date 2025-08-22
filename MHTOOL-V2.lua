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

-- Auto Rebirth Section
local RebirthSection = MainTab:CreateSection("Auto Rebirth")

local autoRebirth = false
MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Callback = function(state)
        autoRebirth = state
        task.spawn(function()
            while autoRebirth do
                local args = {[1] = 26}
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Rebirth"):InvokeServer(unpack(args))
                end)
                task.wait(0.5)
            end
        end)
    end,
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local tycoonsFolder = Workspace.Tycoons
local droppedParts = Workspace.DroppedParts

-- Auto-detect base
local function getBase()
	local activeTycoon = localPlayer:WaitForChild("ActiveTycoon").Value
	for _, tycoonModel in ipairs(tycoonsFolder:GetChildren()) do
		if tycoonModel == activeTycoon then
			return tycoonModel
		end
	end
end

local baseModel = getBase()

-- === Ore Booster Section Optimizada ===
MainTab:CreateSection("Ore Booster")

-- Label mostrando la base
MainTab:CreateLabel("Base: " .. (baseModel and baseModel.Name or "Not Found"))

-- Dropdown para seleccionar la cell donde se procesarán los ores
local cellOptions = {}
for _, c in ipairs(baseModel:GetChildren()) do
    if c:IsA("Model") then
        table.insert(cellOptions, c.Name)
    end
end

local selectedCell = cellOptions[1] or ""

MainTab:CreateDropdown({
    Name = "Select Furnace Cell",
    Options = cellOptions,
    CurrentOption = selectedCell,
    Callback = function(option)
        selectedCell = option
    end,
})

-- Toggle de activación
local boosting = false
MainTab:CreateToggle({
    Name = "Enable Ore Boosting",
    CurrentValue = false,
    Callback = function(value)
        boosting = value
    end,
})

-- Configuración de alturas para evitar colisiones
local boosterHeight = 20
local resetterHeight = 40
local finalHeight = 10

-- Orden de los resetters
local resettersOrder = {"Black Dwarf", "The Final Upgrader", "Tesla Refuter"}

local function getResetters()
    local resetters = {}
    for _, cell in ipairs(baseModel:GetChildren()) do
        if cell:IsA("Model") then
            local cellModel = cell:FindFirstChild("Model")
            if cellModel then
                for _, item in ipairs(cellModel:GetChildren()) do
                    if item:IsA("BasePart") and table.find(resettersOrder, item.Name) then
                        table.insert(resetters, item)
                    end
                end
            end
        end
    end
    table.sort(resetters, function(a, b)
        return table.find(resettersOrder, a.Name) < table.find(resettersOrder, b.Name)
    end)
    return resetters
end

-- Loop principal de boosting
task.spawn(function()
    while true do
        if boosting and baseModel and selectedCell ~= "" then
            local cell = baseModel:FindFirstChild(selectedCell)
            if cell then
                local model = cell:FindFirstChild("Model")
                if model then
                    local lava = model:FindFirstChild("Lava") or model:FindFirstChild("Lava1")
                    if lava then
                        local oresFolder = droppedParts:FindFirstChild(baseModel.Name)
                        if oresFolder then
                            local ores = oresFolder:GetChildren()
                            local resetters = getResetters()
                            
                            for _, ore in ipairs(ores) do
                                if ore:IsA("BasePart") then
                                    ore.CFrame = lava.CFrame * CFrame.new(0, boosterHeight, 0)
                                    task.wait(0.1)
                                    
                                    for _, resetter in ipairs(resetters) do
                                        ore.CFrame = resetter.CFrame * CFrame.new(0, resetterHeight, 0)
                                        task.wait(0.2)
                                        ore.CFrame = lava.CFrame * CFrame.new(0, boosterHeight, 0)
                                        task.wait(0.1)
                                    end
                                    
                                    ore.CFrame = lava.CFrame * CFrame.new(0, finalHeight, 0)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- === Misc Tab ===
local MiscTab = Window:CreateTab("Misc", nil)

-- ESP Section
local ESPSection = MiscTab:CreateSection("ESP")
local crateESPEnabled, eggESPEnabled = false, false
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Objects"
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local highlightParts = {}
local espLines = {}

local function clearESP()
    for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
    highlightParts = {}
    for _, line in pairs(espLines) do line:Remove() end
    espLines = {}
end

local function createESP(object,color)
    local highlight = Instance.new("Highlight")
    highlight.Parent = espFolder
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    table.insert(highlightParts,{object=object,color=color})
end

local function findHighlightPart(crate)
    if crate:IsA("BasePart") then return crate end
    for _, descendant in ipairs(crate:GetDescendants()) do
        if descendant:IsA("BasePart") then return descendant end
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
                        createESP(partToHighlight, Color3.fromRGB(255,215,0))
                    end
                end
            end
        end
    end
    if eggESPEnabled then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(obj.Name:lower(),"egg") then
                createESP(obj, Color3.fromRGB(255,0,255))
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    for _, line in pairs(espLines) do line.Visible=false; line:Remove() end
    espLines={}
    local screenPos = Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
    for _, entry in ipairs(highlightParts) do
        local obj, color = entry.object, entry.color
        if obj and obj.Parent then
            local onScreen, screenPoint = pcall(function()
                return camera:WorldToViewportPoint(obj.Position)
            end)
            if onScreen and screenPoint.Z>0 then
                local line = Drawing.new("Line")
                line.From=screenPos
                line.To=Vector2.new(screenPoint.X,screenPoint.Y)
                line.Color=color
                line.Thickness=2
                line.Transparency=1
                line.Visible=true
                table.insert(espLines,line)
            end
        end
    end
end)

MiscTab:CreateToggle({Name="Crate ESP",CurrentValue=false,Callback=function(state) crateESPEnabled=state; updateESP() end})
MiscTab:CreateToggle({Name="Egg ESP",CurrentValue=false,Callback=function(state) eggESPEnabled=state; updateESP() end})

task.spawn(function()
    while true do
        if crateESPEnabled or eggESPEnabled then updateESP() end
        task.wait(3)
    end
end)

-- Egg Events
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
        if easterthing then collectFrom(easterthing) end
    end
    if mapthing then collectFrom(mapthing) end
end

MiscTab:CreateToggle({
    Name="Auto Easter Eggs",
    CurrentValue=false,
    Callback=function(state)
        autoEasterEggs=state
        task.spawn(function()
            while autoEasterEggs do
                pcall(collectEasterEggs)
                task.wait(3)
            end
        end)
    end,
})

local selectedBox = "Pumpkin"
local autoCrateTP = false
MiscTab:CreateToggle({
    Name="Auto Crate TP",
    CurrentValue=false,
    Callback=function(state)
        autoCrateTP=state
        if state then
            local boxesFolder = workspace:WaitForChild("Boxes")
            local player = game.Players.LocalPlayer
            task.spawn(function()
                while autoCrateTP do
                    pcall(function() game.ReplicatedStorage.MysteryBox:InvokeServer(selectedBox) end)
                    task.wait(1)
                end
            end)
            task.spawn(function()
                while autoCrateTP do
                    local crates = boxesFolder:GetChildren()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if #crates>0 and hrp then hrp.CFrame=crates[1].CFrame end
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- Auto Easter Egg Server Hop
local HttpService = game:GetService("HttpService")
local autoEasterHop = false
local hopToggle

local function saveToggleState(state)
    pcall(function()
        writefile("AutoEasterHop.json", HttpService:JSONEncode({enabled=state}))
    end)
end

local function loadToggleState()
    if isfile("AutoEasterHop.json") then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile("AutoEasterHop.json")) end)
        if success and result and typeof(result.enabled)=="boolean" then
            autoEasterHop=result.enabled
        end
    end
end

local function startEggHop()
    repeat wait() until game:IsLoaded()
    local slotnumber=1
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

    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
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
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100&cursor='..foundAnything))
        end
        if Site.nextPageCursor then foundAnything = Site.nextPageCursor end
        for _, v in pairs(Site.data) do
            local ID = tostring(v.id)
            local Possible = true
            if tonumber(v.maxPlayers)>tonumber(v.playing) then
                for _, Existing in pairs(AllIDs) do
                    if ID==tostring(Existing) then Possible=false; break end
                end
                if Possible then
                    table.insert(AllIDs,ID)
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID,ID,game.Players.LocalPlayer)
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

loadToggleState()

hopToggle = MiscTab:CreateToggle({
    Name="Auto Easter Egg (Server Hop)",
    CurrentValue=autoEasterHop,
    Callback=function(state)
        autoEasterHop=state
        saveToggleState(state)
        if state then task.spawn(startEggHop) end
    end
})

if autoEasterHop and hopToggle then
    hopToggle:Set(true)
    task.spawn(startEggHop)
end
