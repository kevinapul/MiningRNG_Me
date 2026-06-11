--////////////////////////////////////////////////////////////
-- CONFIG & SERVICES
--////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama jika ada
if PlayerGui:FindFirstChild("KuroHub_V54_Farm") then
	PlayerGui.KuroHub_V54_Farm:Destroy()
end

-- KuroHub V5.3 Theme Palette
local Theme = {
	Background = Color3.fromRGB(13,13,15),
	Topbar = Color3.fromRGB(11,11,13),
	Sidebar = Color3.fromRGB(9,9,11),
	Card = Color3.fromRGB(18,18,22),
	Card2 = Color3.fromRGB(22,22,26),
	Accent = Color3.fromRGB(0,210,255),
	Stroke = Color3.fromRGB(35,35,40),
	Text = Color3.fromRGB(245,245,245),
	Muted = Color3.fromRGB(140,140,150)
}

-- STATE MANAGEMENT (Auto Farm & Finder)
local AutoFarmRunning = false
local SelectedZoneName = "Select Zone"
local SelectedOreName = "Select Ore"

local ZonesFolder = workspace:FindFirstChild("Zones")
local CurrentTargetOre = nil

--////////////////////////////////////////////////////////////
-- MAIN GUI EXTRACTION (KUROHUB STYLE)
--////////////////////////////////////////////////////////////
local Gui = Instance.new("ScreenGui")
Gui.Name = "KuroHub_V54_Farm"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Size = UDim2.new(0,580,0,360)
Main.Position = UDim2.new(0.5,-290,0.5,-180)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Theme.Stroke

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Parent = Main
Topbar.Size = UDim2.new(1,0,0,44)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.BorderSizePixel = 0
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0,10)

local TopbarFix = Instance.new("Frame")
TopbarFix.Parent = Topbar
TopbarFix.Size = UDim2.new(1,0,0,10)
TopbarFix.Position = UDim2.new(0,0,1,-10)
TopbarFix.BackgroundColor3 = Theme.Topbar
TopbarFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = Topbar
Title.Position = UDim2.new(0,14,0,0)
Title.Size = UDim2.new(0,250,1,0)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Text = "KUROHUB <font color='rgb(0,210,255)'>V5.4</font> <font color='rgb(140,140,150)'>[FARM]</font>"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize & Close Button
local Minimize = Instance.new("TextButton")
Minimize.Parent = Topbar
Minimize.AnchorPoint = Vector2.new(1,0)
Minimize.Position = UDim2.new(1,-44,0,9)
Minimize.Size = UDim2.new(0,26,0,26)
Minimize.BackgroundColor3 = Theme.Card2
Minimize.Text = "-"
Minimize.TextColor3 = Theme.Text
Minimize.Font = Enum.Font.GothamBold
Minimize.TextSize = 16
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0,6)

local Close = Instance.new("TextButton")
Close.Parent = Topbar
Close.AnchorPoint = Vector2.new(1,0)
Close.Position = UDim2.new(1,-10,0,9)
Close.Size = UDim2.new(0,26,0,26)
Close.BackgroundColor3 = Theme.Card2
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255,100,100)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0,130,1,-44)
Sidebar.Position = UDim2.new(0,0,0,44)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0

local SideLine = Instance.new("Frame")
SideLine.Parent = Sidebar
SideLine.Position = UDim2.new(1,0,0,0)
SideLine.Size = UDim2.new(0,1,1,0)
SideLine.BackgroundColor3 = Theme.Stroke

local Tabs = Instance.new("Frame")
Tabs.Parent = Sidebar
Tabs.Position = UDim2.new(0,0,0,10)
Tabs.Size = UDim2.new(1,0,1,-20)
Tabs.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = Tabs
TabLayout.Padding = UDim.new(0,6)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Pages = {}
local function CreateTab(text, default)
	local Tab = Instance.new("TextButton")
	Tab.Parent = Tabs
	Tab.Size = UDim2.new(0,112,0,30)
	Tab.BackgroundColor3 = default and Theme.Card or Color3.fromRGB(0,0,0)
	Tab.BackgroundTransparency = default and 0 or 1
	Tab.Text = text
	Tab.TextColor3 = default and Theme.Accent or Theme.Muted
	Tab.Font = Enum.Font.GothamMedium
	Tab.TextSize = 13
	Instance.new("UICorner", Tab).CornerRadius = UDim.new(0,6)
	local Stroke = Instance.new("UIStroke")
	Stroke.Parent = Tab
	Stroke.Color = Theme.Stroke

	local Page = Instance.new("ScrollingFrame")
	Page.Parent = Main
	Page.Position = UDim2.new(0,140,0,54)
	Page.Size = UDim2.new(1,-150,1,-64)
	Page.BackgroundTransparency = 1
	Page.BorderSizePixel = 0
	Page.ScrollBarThickness = 2
	Page.ScrollBarImageColor3 = Theme.Accent
	Page.CanvasSize = UDim2.new(0,0,0,500)
	Page.Visible = default

	local Layout = Instance.new("UIListLayout")
	Layout.Name = "MainLayout"
	Layout.Parent = Page
	Layout.Padding = UDim.new(0,10)

	Pages[text] = Page

	Tab.MouseButton1Click:Connect(function()
		for _, v in ipairs(Tabs:GetChildren()) do
			if v:IsA("TextButton") then
				v.BackgroundTransparency = 1
				v.BackgroundColor3 = Color3.fromRGB(0,0,0)
				v.TextColor3 = Theme.Muted
			end
		end
		Tab.BackgroundTransparency = 0
		Tab.BackgroundColor3 = Theme.Card
		Tab.TextColor3 = Theme.Accent
		for _, p in pairs(Pages) do p.Visible = false end
		Page.Visible = true
	end)
	return Page
end

local AutoFarmPage = CreateTab("Auto Farm", true)

--////////////////////////////////////////////////////////////
-- RE-DESIGN COLLAPSE
--////////////////////////////////////////////////////////////
local function CreateCollapse(parent, text, defaultOpen)
	local Holder = Instance.new("Frame")
	Holder.Parent = parent
	Holder.BackgroundTransparency = 1
	Holder.Size = UDim2.new(1, -5, 0, 42)

	local Header = Instance.new("TextButton")
	Header.Parent = Holder
	Header.Size = UDim2.new(1, 0, 0, 42)
	Header.BackgroundColor3 = Theme.Card
	Header.Text = ""
	Instance.new("UICorner", Header).CornerRadius = UDim.new(0,8)
	local Stroke = Instance.new("UIStroke")
	Stroke.Parent = Header
	Stroke.Color = Theme.Stroke

	local Label = Instance.new("TextLabel")
	Label.Parent = Header
	Label.Position = UDim2.new(0, 14, 0, 0)
	Label.Size = UDim2.new(1, -30, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Arrow = Instance.new("TextLabel")
	Arrow.Parent = Header
	Arrow.AnchorPoint = Vector2.new(1, 0)
	Arrow.Position = UDim2.new(1, -12, 0, 0)
	Arrow.Size = UDim2.new(0, 20, 1, 0)
	Arrow.BackgroundTransparency = 1
	Arrow.Text = defaultOpen and "▲" or "▼"
	Arrow.TextColor3 = Theme.Muted
	Arrow.Font = Enum.Font.GothamBold
	Arrow.TextSize = 11

	local Body = Instance.new("Frame")
	Body.Parent = Holder
	Body.Visible = defaultOpen
	Body.Position = UDim2.new(0, 0, 0, 50)
	Body.Size = UDim2.new(1, 0, 0, 0)
	Body.BackgroundColor3 = Theme.Card2
	Body.ClipsDescendants = false
	Instance.new("UICorner", Body).CornerRadius = UDim.new(0,8)
	local BodyStroke = Instance.new("UIStroke")
	BodyStroke.Parent = Body
	BodyStroke.Color = Theme.Stroke

	local BodyLayout = Instance.new("UIListLayout")
	BodyLayout.Parent = Body
	BodyLayout.Padding = UDim.new(0, 10)
	BodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = Body
	UIPadding.PaddingTop = UDim.new(0, 12)
	UIPadding.PaddingBottom = UDim.new(0, 12)

	local function UpdateSizes()
		if Body.Visible then
			local contentSize = BodyLayout.AbsoluteContentSize.Y + UIPadding.PaddingTop.Offset + UIPadding.PaddingBottom.Offset
			Body.Size = UDim2.new(1, 0, 0, contentSize)
			Holder.Size = UDim2.new(1, -5, 0, 50 + contentSize)
		else
			Holder.Size = UDim2.new(1, -5, 0, 42)
		end
		
		local mainLayout = parent:FindFirstChild("MainLayout")
		if mainLayout then
			parent.CanvasSize = UDim2.new(0, 0, 0, mainLayout.AbsoluteContentSize.Y + 20)
		end
	end

	BodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSizes)

	local Open = defaultOpen
	Header.MouseButton1Click:Connect(function()
		Open = not Open
		Body.Visible = Open
		Arrow.Text = Open and "▲" or "▼"
		UpdateSizes()
	end)

	task.spawn(UpdateSizes)

	return Body
end

local FarmMain = CreateCollapse(AutoFarmPage, "Ores Farming Controller", true)

-- Toggle Builder Function
local function CreateToggle(parent, text, default, callback)
	local Container = Instance.new("Frame")
	Container.Parent = parent
	Container.Size = UDim2.new(1, -28, 0, 24)
	Container.BackgroundTransparency = 1

	local Enabled = default
	local Label = Instance.new("TextLabel")
	Label.Parent = Container
	Label.Size = UDim2.new(0, 160, 1, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.GothamBold
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Toggle = Instance.new("TextButton")
	Toggle.Parent = Container
	Toggle.Position = UDim2.new(1, -40, 0.5, -10)
	Toggle.Size = UDim2.new(0, 40, 0, 20)
	Toggle.BackgroundColor3 = Enabled and Theme.Accent or Theme.Card
	Toggle.Text = ""
	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)

	local Circle = Instance.new("Frame")
	Circle.Parent = Toggle
	Circle.Size = UDim2.new(0, 16, 0, 16)
	Circle.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	Circle.BackgroundColor3 = Theme.Text
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1,0)

	Toggle.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		Toggle.BackgroundColor3 = Enabled and Theme.Accent or Theme.Card
		Circle.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		callback(Enabled)
	end)
	callback(default)
end

--////////////////////////////////////////////////////////////
-- DROPDOWN BUILDER (FIXED BLANK LIST VIEW)
--////////////////////////////////////////////////////////////
local function CreateKuroDropdown(parent, placeholder, optionsCallback)
	local Container = Instance.new("Frame")
	Container.Parent = parent
	Container.Size = UDim2.new(1, -28, 0, 32)
	Container.BackgroundTransparency = 1

	local DropdownOpen = false

	local DropBtn = Instance.new("TextButton")
	DropBtn.Parent = Container
	DropBtn.Size = UDim2.new(1, 0, 0, 32)
	DropBtn.BackgroundColor3 = Theme.Background
	DropBtn.Text = placeholder
	DropBtn.TextColor3 = Theme.Text
	DropBtn.Font = Enum.Font.GothamMedium
	DropBtn.TextSize = 12
	Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0,6)
	Instance.new("UIStroke", DropBtn).Color = Theme.Stroke

	local ListFrame = Instance.new("ScrollingFrame")
	ListFrame.Parent = Container
	ListFrame.Visible = false
	ListFrame.Size = UDim2.new(1, 0, 0, 100)
	ListFrame.Position = UDim2.new(0, 0, 0, 36)
	ListFrame.BackgroundColor3 = Theme.Card
	ListFrame.BorderSizePixel = 0
	ListFrame.ZIndex = 10
	ListFrame.ScrollBarThickness = 3
	ListFrame.ScrollBarImageColor3 = Theme.Accent
	Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0,6)
	Instance.new("UIStroke", ListFrame).Color = Theme.Stroke

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Parent = ListFrame
	ListLayout.Padding = UDim.new(0, 4)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	Instance.new("UIPadding", ListFrame).PaddingTop = UDim.new(0, 4)

	local function CloseDrop()
		DropdownOpen = false
		ListFrame.Visible = false
		Container.Size = UDim2.new(1, -28, 0, 32)
	end

	DropBtn.MouseButton1Click:Connect(function()
		DropdownOpen = not DropdownOpen
		
		if DropdownOpen then
			-- Bersihkan list lama sebelum render opsi baru
			for _, child in ipairs(ListFrame:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			
			local currentOptions = optionsCallback()
			
			-- FIX: Jika datanya kosong/tidak terbaca, jangan biarkan kosong melandai[cite: 4]
			if not currentOptions or #currentOptions == 0 then
				currentOptions = {"No Options Found"}
			end
			
			ListFrame.CanvasSize = UDim2.new(0, 0, 0, (#currentOptions * 30) + 10)
			for _, optName in ipairs(currentOptions) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Parent = ListFrame
				OptBtn.Size = UDim2.new(1, -8, 0, 26)
				OptBtn.BackgroundColor3 = Theme.Card2
				OptBtn.Text = optName
				OptBtn.TextColor3 = (optName == "No Options Found") and Theme.Muted or Theme.Text
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 11
				Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0,6)

				if optName ~= "No Options Found" then
					OptBtn.MouseButton1Click:Connect(function()
						DropBtn.Text = optName
						CloseDrop()
						DropBtn.TextColor3 = Theme.Accent
					end)
				end
			end
			
			ListFrame.Visible = true
			Container.Size = UDim2.new(1, -28, 0, 142)
		else
			CloseDrop()
		end
	end)

	return DropBtn
end

-- Info Node Real-time Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = FarmMain
InfoLabel.Size = UDim2.new(1, -28, 0, 30)
InfoLabel.BackgroundTransparency = 1
InfoLabel.RichText = true
InfoLabel.Text = "Status: Idle | Zone: None | Ore: None"
InfoLabel.TextColor3 = Theme.Muted
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Dropdowns Implementation
local ZoneDropdown = CreateKuroDropdown(FarmMain, "Select Zone", function()
	local names = {}
	-- Deteksi folder "Zones" asli di workspace game[cite: 4]
	if ZonesFolder and #ZonesFolder:GetChildren() > 0 then[cite: 4]
		for _, z in ipairs(ZonesFolder:GetChildren()) do
			table.insert(names, z.Name)
		end
	else
		-- AUTO FALLBACK: Supaya UI tidak kosong kalau folder game belum terbaca[cite: 4]
		names = {"Zone 1", "Zone 2", "Zone 3"} 
	end
	return names
end)

local OreDropdown = CreateKuroDropdown(FarmMain, "Select Ore", function()
	local ores = {}
	local found = {}
	if SelectedZoneName ~= "Select Zone" and SelectedZoneName ~= "No Options Found" and ZonesFolder then[cite: 4]
		local targetZone = ZonesFolder:FindFirstChild(SelectedZoneName)
		if targetZone then
			for _, obj in ipairs(targetZone:GetDescendants()) do
				if obj.Name == "Ore" and obj:IsA("ObjectValue") and obj.Value then[cite: 4]
					local oreName = obj.Value.Name[cite: 4]
					if not found[oreName] then[cite: 4]
						found[oreName] = true[cite: 4]
						table.insert(ores, oreName)[cite: 4]
					end
				end
			end
		end
	end
	
	-- AUTO FALLBACK ORE[cite: 4]
	if #ores == 0 then
		ores = {"Copper", "Iron", "Gold", "Diamond"}
	end
	return ores
end)

ZoneDropdown:GetPropertyChangedSignal("Text"):Connect(function()
	SelectedZoneName = ZoneDropdown.Text
	OreDropdown.Text = "Select Ore" 
	SelectedOreName = "Select Ore"
end)

OreDropdown:GetPropertyChangedSignal("Text"):Connect(function()
	SelectedOreName = OreDropdown.Text
	CurrentTargetOre = nil 
end)

CreateToggle(FarmMain, "Activate Auto Farm", false, function(state)
	AutoFarmRunning = state
	if not state then
		CurrentTargetOre = nil
	end
end)

--////////////////////////////////////////////////////////////
-- CORE AUTO FARM ENGINE
--////////////////////////////////////////////////////////////
local function GetClosestOreNode()
	if not ZonesFolder or SelectedZoneName == "Select Zone" or SelectedOreName == "Select Ore" then
		return nil
	end

	local zone = ZonesFolder:FindFirstChild(SelectedZoneName)
	if not zone then return nil end

	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = char.HumanoidRootPart.Position

	local closestNode = nil
	local shortestDist = math.huge

	for _, obj in ipairs(zone:GetDescendants()) do
		if obj.Name == "Ore" and obj:IsA("ObjectValue") and obj.Value and obj.Value.Name == SelectedOreName then[cite: 4]
			local nodePart = obj.Parent
			if nodePart and (nodePart:IsA("BasePart") or nodePart:IsA("Model")) then
				local partPos = nodePart:IsA("Model") and nodePart:GetPivot().Position or nodePart.Position
				local dist = (myPos - partPos).Magnitude
				
				if dist < shortestDist then
					shortestDist = dist
					closestNode = nodePart
				end
			end
		end
	end
	return closestNode
end

task.spawn(function()
	while true do
		task.wait(0.1)
		
		if AutoFarmRunning and SelectedZoneName ~= "Select Zone" and SelectedOreName ~= "Select Ore" then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if root then
				if CurrentTargetOre and CurrentTargetOre.Parent and CurrentTargetOre:FindFirstChild("Ore") then[cite: 4]
					InfoLabel.Text = "Status: <font color='rgb(0,210,255)'>Mining Node...</font> | Zone: " .. SelectedZoneName .. " | Ore: " .. SelectedOreName
					local targetPos = CurrentTargetOre:IsA("Model") and CurrentTargetOre:GetPivot().Position or CurrentTargetOre.Position
					root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
				else
					CurrentTargetOre = GetClosestOreNode()
					if CurrentTargetOre then
						local targetPos = CurrentTargetOre:IsA("Model") and CurrentTargetOre:GetPivot().Position or CurrentTargetOre.Position
						root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
						InfoLabel.Text = "Status: <font color='rgb(0,255,100)'>Target Found!</font> | Zone: " .. SelectedZoneName .. " | Ore: " .. SelectedOreName
					else
						InfoLabel.Text = "Status: <font color='rgb(255,100,100)'>Scanning Ores...</font> | Zone: " .. SelectedZoneName .. " | Ore: " .. SelectedOreName
					end
				end
			end
		else
			if not AutoFarmRunning then
				InfoLabel.Text = "Status: Idle | Zone: " .. SelectedZoneName .. " | Ore: " .. SelectedOreName
			end
		end
	end
end)

--////////////////////////////////////////////////////////////
-- UTILITIES SYSTEM (DRAG & CLOSE)
--////////////////////////////////////////////////////////////
local Dragging, DragInput, DragStart, StartPos
Topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPos = Main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then Dragging = false end
		end)
	end
end)
UIS.InputChanged:Connect(function(input)
	if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = input.Position - DragStart
		Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
	end
end)

Close.MouseButton1Click:Connect(function()
	AutoFarmRunning = false
	Gui:Destroy()
end)
