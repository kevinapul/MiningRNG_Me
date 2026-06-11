--////////////////////////////////////////////////////////////
-- CONFIG & SERVICES
--////////////////////////////////////////////////////////////
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Hapus GUI lama jika ada agar tidak double saat di-execute ulang
if PlayerGui:FindFirstChild("KuroHub_V54_Farm") then
	PlayerGui.KuroHub_V54_Farm:Destroy()
end

-- KuroHub Theme Palette
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

print("1 - Theme loaded successfully") -- CHECKPOINT 1

-- STATE MANAGEMENT (Menggunakan struktur data sukses dari hasil debug kamu)
local AutoFarmRunning = false
local SelectedZoneName = "Select Zone"
local SelectedOreName = "Select Ore"

-- TERSANGKA #3 (DIBERSIHKAN): Langsung menggunakan FindFirstChild agar instant tanpa delay 10 detik
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

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Stroke
MainStroke.Parent = Main

print("2 - Main Frame created successfully") -- CHECKPOINT 2

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Parent = Main
Topbar.Size = UDim2.new(1,0,0,44)
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.BorderSizePixel = 0

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0,10)
TopbarCorner.Parent = Topbar

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

-- Minimize & Close Buttons
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

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0,6)
MinCorner.Parent = Minimize

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

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,6)
CloseCorner.Parent = Close

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
	
	local TabCorner = Instance.new("UICorner")
	TabCorner.CornerRadius = UDim.new(0,6)
	TabCorner.Parent = Tab

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Stroke
	Stroke.Parent = Tab

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

print("3 - CreateTab initialized successfully") -- CHECKPOINT 3

--////////////////////////////////////////////////////////////
-- COLLAPSE CONTAINER BUILDER
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
	
	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0,8)
	HeaderCorner.Parent = Header

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Stroke
	Stroke.Parent = Header

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
	
	local BodyCorner = Instance.new("UICorner")
	BodyCorner.CornerRadius = UDim.new(0,8)
	BodyCorner.Parent = Body

	local BodyStroke = Instance.new("UIStroke")
	BodyStroke.Color = Theme.Stroke
	BodyStroke.Parent = Body

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
		-- TERSANGKA #4 (DIBERSIHKAN): Ditambahkan print & proteksi kondisional if-statement agar tidak error nil
		print("Debug Collapse mainLayout status:", mainLayout)
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

print("4 - CreateCollapse processed successfully") -- CHECKPOINT 4

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
	
	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(1,0)
	ToggleCorner.Parent = Toggle

	local Circle = Instance.new("Frame")
	Circle.Parent = Toggle
	Circle.Size = UDim2.new(0, 16, 0, 16)
	Circle.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	Circle.BackgroundColor3 = Theme.Text
	
	local CircleCorner = Instance.new("UICorner")
	CircleCorner.CornerRadius = UDim.new(1,0)
	CircleCorner.Parent = Circle

	Toggle.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		Toggle.BackgroundColor3 = Enabled and Theme.Accent or Theme.Card
		Circle.Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		callback(Enabled)
	end)
	callback(default)
end

--////////////////////////////////////////////////////////////
-- DROPDOWN BUILDER (DE-CHAINED PROPERTY & SAFE DESIGN)
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
	
	local DropCorner = Instance.new("UICorner")
	DropCorner.CornerRadius = UDim.new(0,6)
	DropCorner.Parent = DropBtn
	
	-- TERSANGKA #2 (DIBERSIHKAN): Memisahkan penulisan UIStroke DropBtn
	local DropStroke = Instance.new("UIStroke")
	DropStroke.Color = Theme.Stroke
	DropStroke.Parent = DropBtn

	local ListFrame = Instance.new("ScrollingFrame")
	ListFrame.Parent = Container
	ListFrame.Visible = false
	ListFrame.Size = UDim2.new(1, 0, 0, 110)
	ListFrame.Position = UDim2.new(0, 0, 0, 36)
	ListFrame.BackgroundColor3 = Theme.Card
	ListFrame.BorderSizePixel = 0
	ListFrame.ZIndex = 10
	ListFrame.ScrollBarThickness = 4
	ListFrame.ScrollBarImageColor3 = Theme.Accent
	
	local ListCorner = Instance.new("UICorner")
	ListCorner.CornerRadius = UDim.new(0,6)
	ListCorner.Parent = ListFrame
	
	-- TERSANGKA #2 (DIBERSIHKAN): Memisahkan penulisan UIStroke ListFrame
	local ListStroke = Instance.new("UIStroke")
	ListStroke.Color = Theme.Stroke
	ListStroke.Parent = ListFrame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.Parent = ListFrame
	ListLayout.Padding = UDim.new(0, 4)
	ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	
	-- TERSANGKA #1 (DIBERSIHKAN): Memisahkan penulisan UIPadding secara utuh & aman
	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 4)
	Padding.Parent = ListFrame

	local function CloseDrop()
		DropdownOpen = false
		ListFrame.Visible = false
		Container.Size = UDim2.new(1, -28, 0, 32)
	end

	DropBtn.MouseButton1Click:Connect(function()
		DropdownOpen = not DropdownOpen
		
		if DropdownOpen then
			-- Reset list tombol lama sebelum menggambar list yang baru
			for _, child in ipairs(ListFrame:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			
			local currentOptions = optionsCallback()
			
			if not currentOptions or #currentOptions == 0 then
				currentOptions = {"No Options Found"}
			end
			
			-- Render dinamis list tombol pilihan
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
				
				local OptCorner = Instance.new("UICorner")
				OptCorner.CornerRadius = UDim.new(0,6)
				OptCorner.Parent = OptBtn

				if optName ~= "No Options Found" then
					OptBtn.MouseButton1Click:Connect(function()
						DropBtn.Text = optName
						CloseDrop()
						DropBtn.TextColor3 = Theme.Accent
					end)
				end
			end
			
			ListFrame.Visible = true
			Container.Size = UDim2.new(1, -28, 0, 150)
		else
			CloseDrop()
		end
	end)

	return DropBtn
end

-- Info Status Node Real-time Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = FarmMain
InfoLabel.Size = UDim2.new(1, -28, 0, 36)
InfoLabel.BackgroundTransparency = 1
InfoLabel.RichText = true
InfoLabel.Text = "Status: Idle | Zone: None | Ore: None"
InfoLabel.TextColor3 = Theme.Muted
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

--////////////////////////////////////////////////////////////
-- LOGIKA PEMETAAN DROPDOWN (BERDASARKAN DATA HASIL DEBUG KAMU)
--////////////////////////////////////////////////////////////
local ZoneDropdown = CreateKuroDropdown(FarmMain, "Select Zone", function()
	local names = {}
	if ZonesFolder then
		for _, z in ipairs(ZonesFolder:GetChildren()) do
			table.insert(names, z.Name)
		end
	else
		names = {"Zones Folder Not Found"}
	end
	return names
end)

local OreDropdown = CreateKuroDropdown(FarmMain, "Select Ore", function()
	local ores = {}
	local found = {}
	
	if SelectedZoneName ~= "Select Zone" and SelectedZoneName ~= "No Options Found" and ZonesFolder then
		local targetZone = ZonesFolder:FindFirstChild(SelectedZoneName)
		if targetZone then
			-- LOGIKA DEBUG PEMETAAN BATU MILIKMU YANG BERHASIL
			for _, obj in ipairs(targetZone:GetDescendants()) do
				if obj.Name == "Ore" and obj:IsA("ObjectValue") and obj.Value then
					local oreName = obj.Value.Name
					if not found[oreName] then
						found[oreName] = true
						table.insert(ores, oreName)
					end
				end
			end
		end
	end
	return ores
end)

-- Sinkronisasi pemilihan dropdown
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

print("5 - AutoFarm Engine Setup Ready") -- CHECKPOINT 5

--////////////////////////////////////////////////////////////
-- CORE AUTO FARM ENGINE (DENGAN STRUKTUR POSISI AMAN)
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

	-- Menggunakan logika scanning presisi milikmu
	for _, obj in ipairs(zone:GetDescendants()) do
		if obj.Name == "Ore" and obj:IsA("ObjectValue") and obj.Value and obj.Value.Name == SelectedOreName then
			local nodePart = obj.Parent -- Mengambil parent batu (bisa Part / Model)
			if nodePart then
				-- Proteksi agar tidak nil index saat mengambil koordinat posisi model/part
				local partPos = (nodePart:IsA("Model") and nodePart:GetPivot().Position) or (nodePart:IsA("BasePart") and nodePart.Position)
				
				if partPos then
					local dist = (myPos - partPos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closestNode = nodePart
					end
				end
			end
		end
	end
	return closestNode
end

-- Thread loop eksekusi Auto Teleport Farm
task.spawn(function()
	while true do
		task.wait(0.1)
		
		if AutoFarmRunning and SelectedZoneName ~= "Select Zone" and SelectedOreName ~= "Select Ore" then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if root then
				-- Jika target batu masih utuh dan ada di dalam game workspace
				if CurrentTargetOre and CurrentTargetOre.Parent and CurrentTargetOre:FindFirstChild("Ore") then
					InfoLabel.Text = "Status: <font color='rgb(0,210,255)'>Mining Node...</font> | Zone: " .. SelectedZoneName .. " | Ore: " .. SelectedOreName
					
					local targetPos = (CurrentTargetOre:IsA("Model") and CurrentTargetOre:GetPivot().Position) or CurrentTargetOre.Position
					root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0)) -- Teleport tepat di atas kepala batu (+3.5)
				else
					-- Cari batu terdekat berikutnya jika batu lama sudah hancur
					CurrentTargetOre = GetClosestOreNode()
					if CurrentTargetOre then
						local targetPos = (CurrentTargetOre:IsA("Model") and CurrentTargetOre:GetPivot().Position) or CurrentTargetOre.Position
						root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0))
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
-- UTILITIES SYSTEM (DRAG & CLOSE UI)
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
