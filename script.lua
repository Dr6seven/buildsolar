-- ===== OIL EMPIRE ULTIMATE HUB (V8 - UI Fixed) =====
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

-- ==========================================
-- ===== SETTING (Ubah di sini biar aman) ===
-- ==========================================
local SETTINGS = {
    SELL_DELAY   = 2.0,
    BUY_DELAY    = 1.5,
    PLACE_DELAY  = 2.5,
    PHONE_DELAY  = 3.0,
    ESP_DELAY    = 1.0,
    STEAL_DELAY  = 4.0,
    PLACE_RADIUS = 15,
    PLACE_HEIGHT = 1.5,
    DEFAULT_MIN_PRICE = 10, 
    MIN_GAS_TO_STEAL = 50,
}
-- ==========================================

if getgenv().OilEmpireUI then pcall(function() getgenv().OilEmpireUI:Destroy() end) end

local C_BG   = Color3.fromRGB(18, 18, 22)
local C_BAR  = Color3.fromRGB(26, 26, 32)
local C_ROW  = Color3.fromRGB(34, 34, 42)
local C_OFF  = Color3.fromRGB(70, 70, 82)
local C_ON   = Color3.fromRGB(60, 190, 100)
local C_GRAY = Color3.fromRGB(150, 150, 160)
local C_WARN = Color3.fromRGB(240, 170, 60)
local C_GOOD = Color3.fromRGB(90, 200, 120)

local State = {
    AutoSell = false, AutoBuy = false, AutoPlace = false, AutoPhone = false, AutoSteal = false,
    ESP_Player = false, ESP_Merchant = false, ESP_LuckyBlock = false, ESP_Refinery = false,
    SellMin = SETTINGS.DEFAULT_MIN_PRICE,
    DrillType = "Basic Drill",
}

local function corner(inst, r) Instance.new("UICorner", inst).CornerRadius = UDim.new(0, r) end
local function generateUUID()
    local template = 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

-- ==========================================
-- ===== BIKIN UI DULU (BIAR LANGSUNG MUNCUL) =
-- ==========================================
local gui = Instance.new("ScreenGui")
gui.Name = "OilEmpireUI"
gui.ResetOnSpawn = false
local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not ok or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end
getgenv().OilEmpireUI = gui

local WIN_W, WIN_H = 430, 310
local main = Instance.new("Frame")
main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
main.Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2)
main.BackgroundColor3 = C_BG
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
corner(main, 12)
Instance.new("UIStroke", main).Color = Color3.fromRGB(60, 60, 72)

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 32)
bar.BackgroundColor3 = C_BAR
bar.BorderSizePixel = 0
bar.Parent = main

local titleBox = Instance.new("Frame")
titleBox.Size = UDim2.new(1, -220, 1, 0)
titleBox.Position = UDim2.new(0, 12, 0, 0)
titleBox.BackgroundTransparency = 1
titleBox.Parent = bar
local tbl = Instance.new("UIListLayout", titleBox)
tbl.FillDirection = Enum.FillDirection.Horizontal
tbl.VerticalAlignment = Enum.VerticalAlignment.Center
tbl.SortOrder = Enum.SortOrder.LayoutOrder
tbl.Padding = UDim.new(0, 5)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 0, 0, 16)
title.AutomaticSize = Enum.AutomaticSize.X
title.BackgroundTransparency = 1
title.Text = "OIL EMPIRE HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.LayoutOrder = 1
title.Parent = titleBox

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(0, 0, 0, 10)
credit.AutomaticSize = Enum.AutomaticSize.X
credit.BackgroundTransparency = 1
credit.Text = "By Delta"
credit.TextColor3 = C_GRAY
credit.Font = Enum.Font.Gotham
credit.TextSize = 7
credit.LayoutOrder = 2
credit.Parent = titleBox

local search = Instance.new("TextBox")
search.Size = UDim2.new(0, 120, 0, 22)
search.Position = UDim2.new(1, -196, 0, 5)
search.BackgroundColor3 = C_BG
search.PlaceholderText = "Search"
search.PlaceholderColor3 = C_GRAY
search.Text = ""
search.TextColor3 = Color3.new(1, 1, 1)
search.Font = Enum.Font.Gotham
search.TextSize = 11
search.ClearTextOnFocus = false
search.Parent = bar
corner(search, 6)

local function barBtn(text, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 0, 22)
    b.Position = UDim2.new(1, xOff, 0, 5)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = bar
    corner(b, 6)
    return b
end
local minBtn = barBtn("-", -64, C_OFF)
local closeBtn = barBtn("X", -32, Color3.fromRGB(200, 50, 50))

local dlg = Instance.new("Frame")
dlg.Size = UDim2.new(1, 0, 1, 0)
dlg.BackgroundColor3 = Color3.new(0, 0, 0)
dlg.BackgroundTransparency = 0.45
dlg.BorderSizePixel = 0
dlg.Active = true
dlg.Visible = false
dlg.ZIndex = 50
dlg.Parent = main

local dbox = Instance.new("Frame")
dbox.Size = UDim2.new(0, 270, 0, 110)
dbox.AnchorPoint = Vector2.new(0.5, 0.5)
dbox.Position = UDim2.new(0.5, 0, 0.5, 0)
dbox.BackgroundColor3 = C_ROW
dbox.BorderSizePixel = 0
dbox.ZIndex = 51
dbox.Parent = dlg
corner(dbox, 10)
Instance.new("UIStroke", dbox).Color = Color3.fromRGB(70, 70, 85)

local dtxt = Instance.new("TextLabel")
dtxt.Size = UDim2.new(1, -20, 0, 50)
dtxt.Position = UDim2.new(0, 10, 0, 10)
dtxt.BackgroundTransparency = 1
dtxt.Text = "Do you want to close this window"
dtxt.TextColor3 = Color3.new(1, 1, 1)
dtxt.Font = Enum.Font.GothamBold
dtxt.TextSize = 13
dtxt.TextWrapped = true
dtxt.ZIndex = 52
dtxt.Parent = dbox

local function dlgBtn(text, xScale, xOff, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 105, 0, 30)
    b.Position = UDim2.new(xScale, xOff, 1, -42)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.ZIndex = 52
    b.Parent = dbox
    corner(b, 8)
    return b
end
local noBtn = dlgBtn("No", 0, 20, Color3.fromRGB(70, 70, 82))
local yesBtn = dlgBtn("Yes", 1, -125, Color3.fromRGB(200, 50, 50))

closeBtn.MouseButton1Click:Connect(function() dlg.Visible = true end)
noBtn.MouseButton1Click:Connect(function() dlg.Visible = false end)
yesBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

do
    local dragging, startPos, startPoint, dragInput
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragInput = true, i
            startPoint, startPos = i.Position, main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i == dragInput or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - startPoint
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i) if i == dragInput then dragging = false end end)
end

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 46, 0, 46)
mini.BackgroundColor3 = C_BAR
mini.Text = "OE"
mini.TextColor3 = Color3.new(1, 1, 1)
mini.Font = Enum.Font.GothamBold
mini.TextSize = 20
mini.AutoButtonColor = false
mini.Position = UDim2.new(0, 16, 0.5, -23)
mini.Visible = false
mini.Parent = gui
corner(mini, 12)
Instance.new("UIStroke", mini).Color = Color3.fromRGB(220, 130, 30)

local iconPlaced = false
minBtn.MouseButton1Click:Connect(function()
    if not iconPlaced then
        mini.Position = main.Position
        iconPlaced = true
    end
    main.Visible = false
    mini.Visible = true
end)

do
    local dragging, moved, startPoint, startPos, dragInput
    mini.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragInput = true, false, i
            startPoint, startPos = i.Position, mini.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i == dragInput or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - startPoint
            if d.Magnitude > 8 then moved = true end
            if moved then
                mini.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if dragging and i == dragInput then
            dragging = false
            if not moved then
                mini.Visible = false
                main.Visible = true
            end
        end
    end)
end

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -32)
body.Position = UDim2.new(0, 0, 0, 32)
body.BackgroundTransparency = 1
body.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 96, 1, 0)
sidebar.BackgroundColor3 = C_BAR
sidebar.BorderSizePixel = 0
sidebar.Parent = body

local tabList = Instance.new("Frame")
tabList.Size = UDim2.new(1, 0, 1, -30)
tabList.BackgroundTransparency = 1
tabList.Parent = sidebar
local tl = Instance.new("UIListLayout", tabList)
tl.Padding = UDim.new(0, 4)
local tp = Instance.new("UIPadding", tabList)
tp.PaddingTop = UDim.new(0, 8); tp.PaddingLeft = UDim.new(0, 6); tp.PaddingRight = UDim.new(0, 6)

local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(1, -12, 0, 16)
fpsLbl.Position = UDim2.new(0, 6, 1, -22)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "-- FPS"
fpsLbl.TextColor3 = C_GRAY
fpsLbl.Font = Enum.Font.Gotham
fpsLbl.TextSize = 10
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
fpsLbl.Parent = sidebar
do
    local frames, t0 = 0, os.clock()
    RunService.Heartbeat:Connect(function()
        if not gui.Parent then return end
        frames += 1
        local now = os.clock()
        if now - t0 >= 0.5 then
            fpsLbl.Text = math.floor(frames / (now - t0)) .. " FPS"
            frames, t0 = 0, now
        end
    end)
end

local pages, tabs = {}, {}
local function newPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, -96, 1, 0)
    p.Position = UDim2.new(0, 96, 0, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    p.Parent = body
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", p)
    pad.PaddingLeft = UDim.new(0, 8); pad.PaddingRight = UDim.new(0, 8); pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 8)
    pages[name] = p
    return p
end

local function setTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(tabs) do
        b.BackgroundColor3 = (n == name) and C_ROW or C_BAR
        b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or C_GRAY
    end
end

local function newTab(name, order, icon)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = order
    b.Parent = tabList
    corner(b, 8)
    Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 32)
    local ic = Instance.new("TextLabel")
    ic.Size = UDim2.new(0, 24, 1, 0)
    ic.Position = UDim2.new(0, -26, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextSize = 15
    ic.Font = Enum.Font.GothamBold
    ic.TextColor3 = Color3.new(1, 1, 1)
    ic.Parent = b
    tabs[name] = b
    b.MouseButton1Click:Connect(function() setTab(name) end)
end

local mainPage = newPage("Main")
local miscPage = newPage("Misc")
newTab("Main", 1, "🏠")
newTab("Misc", 2, "⚙")

local sections = {}
local function section(page, keyword, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundTransparency = 1
    f.LayoutOrder = order
    f.Parent = page
    local l = Instance.new("UIListLayout", f)
    l.Padding = UDim.new(0, 4)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    sections[#sections + 1] = { f, keyword:lower() }
    return f
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = search.Text:lower()
    for _, s in ipairs(sections) do
        s[1].Visible = (q == "") or (s[2]:find(q, 1, true) ~= nil)
    end
end)

local function groupTitle(page, text, order)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order
    l.Parent = page
end

local refreshers = {}
local function refreshAll() for _, f in ipairs(refreshers) do f() end end

local function textBlock(parent, titleText, desc, widthOffset, inList)
    local txt = Instance.new("Frame")
    txt.Size = UDim2.new(1, inList and 0 or widthOffset, 0, 0)
    txt.AutomaticSize = Enum.AutomaticSize.Y
    txt.BackgroundTransparency = 1
    txt.LayoutOrder = 1
    if not inList then txt.Position = UDim2.new(0, 10, 0, 0) end
    txt.Parent = parent
    local l = Instance.new("UIListLayout", txt)
    l.Padding = UDim.new(0, 2)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", txt)
    pad.PaddingTop = UDim.new(0, 7)
    pad.PaddingBottom = UDim.new(0, 7)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 16)
    t.BackgroundTransparency = 1
    t.Text = titleText
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 1
    t.Parent = txt

    if desc then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 0)
        d.AutomaticSize = Enum.AutomaticSize.Y
        d.BackgroundTransparency = 1
        d.Text = desc
        d.TextColor3 = C_GRAY
        d.Font = Enum.Font.Gotham
        d.TextSize = 10
        d.TextWrapped = true
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.LayoutOrder = 2
        d.Parent = txt
    end
    return txt, t
end

local switchRefresh = {}
local function switchRow(parent, text, desc, key)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundColor3 = C_ROW
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = 1
    row.Parent = parent
    corner(row, 8)
    Instance.new("UISizeConstraint", row).MinSize = Vector2.new(0, 38)
    textBlock(row, text, desc, -64, false)

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 40, 0, 20)
    pill.Position = UDim2.new(1, -50, 0.5, -10)
    pill.Parent = row
    corner(pill, 10)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = pill
    corner(knob, 8)

    local function refresh(animate)
        local on = State[key]
        local col = on and C_ON or C_OFF
        local pos = on and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
        if animate then
            TS:Create(pill, TweenInfo.new(0.15), { BackgroundColor3 = col }):Play()
            TS:Create(knob, TweenInfo.new(0.15), { Position = pos }):Play()
        else
            pill.BackgroundColor3 = col
            knob.Position = pos
        end
    end
    switchRefresh[key] = refresh
    row.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        refresh(true)
    end)
    refresh(false)
end

local function makeDropdown(page, order, keyword, titleText, desc, opts)
    local sec = section(page, keyword, order)
    local head = Instance.new("TextButton")
    head.Size = UDim2.new(1, 0, 0, 0)
    head.AutomaticSize = Enum.AutomaticSize.Y
    head.BackgroundColor3 = C_ROW
    head.Text = ""
    head.AutoButtonColor = false
    head.LayoutOrder = 1
    head.Parent = sec
    corner(head, 8)
    Instance.new("UISizeConstraint", head).MinSize = Vector2.new(0, 38)
    local _, titleLbl = textBlock(head, titleText, desc, -40, false)

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 0, 20)
    arrow.Position = UDim2.new(1, -30, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = Color3.new(1, 1, 1)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.Parent = head

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.AutomaticSize = Enum.AutomaticSize.Y
    list.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    list.Visible = false
    list.LayoutOrder = 2
    list.Parent = sec
    corner(list, 8)
    local ll = Instance.new("UIListLayout", list)
    ll.Padding = UDim.new(0, 2)
    local lp2 = Instance.new("UIPadding", list)
    lp2.PaddingLeft = UDim.new(0, 6); lp2.PaddingRight = UDim.new(0, 8); lp2.PaddingTop = UDim.new(0, 6); lp2.PaddingBottom = UDim.new(0, 6)

    local rowsUI, open = {}, false

    for i, it in ipairs(opts.items) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 22)
        b.BackgroundColor3 = C_ROW
        b.BackgroundTransparency = 1
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.LayoutOrder = i
        b.Parent = list
        corner(b, 5)
        Instance.new("UIPadding", b).PaddingLeft = UDim.new(0, 8)
        b.MouseButton1Click:Connect(function()
            opts.pick(it.key)
            refreshAll()
        end)
        rowsUI[#rowsUI + 1] = { btn = b, key = it.key, label = it.label }
    end

    local function refresh()
        titleLbl.Text = titleText .. opts.summary()
        arrow.Text = open and "^" or "v"
        list.Visible = open
        for _, r in ipairs(rowsUI) do
            local on = opts.isOn(r.key)
            r.btn.Text = (on and "✓  " or "    ") .. r.label
            r.btn.TextColor3 = on and Color3.new(1, 1, 1) or C_GRAY
            r.btn.BackgroundTransparency = on and 0 or 1
        end
    end
    head.MouseButton1Click:Connect(function() open = not open; refresh() end)
    table.insert(refreshers, refresh)
end

local function boxCard(page, order, keyword, titleText, desc)
    local sec = section(page, keyword, order)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C_ROW
    card.LayoutOrder = 1
    card.Parent = sec
    corner(card, 8)
    local cl = Instance.new("UIListLayout", card)
    cl.Padding = UDim.new(0, 4)
    local cp = Instance.new("UIPadding", card)
    cp.PaddingLeft = UDim.new(0, 10); cp.PaddingRight = UDim.new(0, 10); cp.PaddingBottom = UDim.new(0, 8)
    textBlock(card, titleText, desc, 0, true)
    return card
end

local function newBox(parent, placeholder, order)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = C_BG
    b.PlaceholderText = placeholder
    b.PlaceholderColor3 = C_GRAY
    b.Text = ""
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.ClearTextOnFocus = false
    b.LayoutOrder = order
    b.Parent = parent
    corner(b, 6)
    return b
end

-- === UI MAIN PAGE ===
groupTitle(mainPage, "Live Status", 0)
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 32)
statusCard.BackgroundColor3 = C_ROW
statusCard.LayoutOrder = 1
statusCard.Parent = section(mainPage, "gas price live", 1)
corner(statusCard, 8)

local gasLabel = Instance.new("TextLabel")
gasLabel.Size = UDim2.new(1, -10, 1, 0)
gasLabel.Position = UDim2.new(0, 10, 0, 0)
gasLabel.BackgroundTransparency = 1
gasLabel.Text = "Harga Gas: Loading..."
gasLabel.TextColor3 = C_WARN
gasLabel.Font = Enum.Font.GothamBold
gasLabel.TextSize = 12
gasLabel.TextXAlignment = Enum.TextXAlignment.Left
gasLabel.Parent = statusCard

groupTitle(mainPage, "Auto Farm", 2)
local sBuy = section(mainPage, "auto buy drill", 3)
switchRow(sBuy, "Auto Buy Drill", "Otomatis beli drill sesuai tipe di bawah.", "AutoBuy")

do
    local items = {
        { key = "Basic Drill", label = "Basic Drill" },
        { key = "Strong Drill", label = "Strong Drill" },
        { key = "Enhanced Drill", label = "Enhanced Drill" }
    }
    makeDropdown(mainPage, 4, "select drill options", "Select Drill Options", "Pilih tipe drill yang mau dibeli otomatis.", {
        items = items,
        isOn = function(k) return State.DrillType == k end,
        pick = function(k) State.DrillType = k end,
        summary = function() return "  (" .. State.DrillType .. ")" end,
    })
end

local sPlace = section(mainPage, "auto place", 5)
switchRow(sPlace, "Auto Place Drill", "Otomatis taruh drill di sekitar karaktermu.", "AutoPlace")

groupTitle(mainPage, "Steal / Sabotage", 9)
local sSteal = section(mainPage, "auto steal", 10)
switchRow(sSteal, "Auto Steal (Prioritas Full)", "Teleport ke Refinery orang yang isinya penuh.", "AutoSteal")

groupTitle(mainPage, "Sell & Phone", 11)
local sSell = section(mainPage, "auto sell gas", 12)
switchRow(sSell, "Auto Sell Gas", "Jual gas otomatis saat harga menyentuh angka minimal.", "AutoSell")

do
    local card = boxCard(mainPage, 13, "min max sell", "Min / Max Sell", "Set harga minimal gas untuk dijual otomatis.")
    local box = newBox(card, "eg. 10", 2)
    box.Text = tostring(State.SellMin)
    box.FocusLost:Connect(function()
        local v = tonumber(box.Text)
        if v and v > 0 then State.SellMin = v else box.Text = tostring(State.SellMin) end
    end)
end

local sPhone = section(mainPage, "auto accept phone", 14)
switchRow(sPhone, "Auto Accept Phone", "Otomatis terima tawaran random dari NPC.", "AutoPhone")

-- === UI MISC PAGE ===
groupTitle(miscPage, "ESP", 1)
local sEsp = section(miscPage, "esp player", 2)
switchRow(sEsp, "ESP Player", "Melihat posisi pemain lain (tembus tembok).", "ESP_Player")
local sMerch = section(miscPage, "esp merchant", 3)
switchRow(sMerch, "ESP Merchant", "Melihat posisi NPC Merchant (penawar gas).", "ESP_Merchant")
local sLucky = section(miscPage, "esp lucky block", 4)
switchRow(sLucky, "ESP Lucky Block", "Melihat posisi Lucky Block di map.", "ESP_LuckyBlock")
local sRef = section(miscPage, "esp refinery", 5)
switchRow(sRef, "ESP Refinery", "Melihat posisi kilang minyak pemain lain.", "ESP_Refinery")

setTab("Main")
refreshAll()

-- ==========================================
-- ===== AMBIL REMOTE DI BELAKANG LAYAR =====
-- ==========================================
local PurchaseRE, PlaceRE, PhoneRE, SellRE, gasPriceObj

task.spawn(function()
    -- Pakai pcall biar kalau gagal ngedapetin remote, UI tetep aman
    pcall(function()
        local KnitServices = ReplicatedStorage:WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10)
        PurchaseRE = KnitServices:WaitForChild("StoresService", 10):WaitForChild("RE", 10):WaitForChild("Purchase", 10)
        PlaceRE = KnitServices:WaitForChild("BaseService", 10):WaitForChild("RE", 10):WaitForChild("PlaceBuilding", 10)
        PhoneRE = KnitServices:WaitForChild("PhoneService", 10):WaitForChild("RE", 10):WaitForChild("Phone", 10)
        SellRE = KnitServices:WaitForChild("BaseService", 10):WaitForChild("RE", 10):WaitForChild("SellGas", 10)
        gasPriceObj = Workspace:WaitForChild("Shops", 10):WaitForChild("GasPrice", 10)
    end)
end)

-- ===== LOGIKA LIVE GAS PRICE =====
task.spawn(function()
    while task.wait(0.5) do
        if gasPriceObj then
            gasLabel.Text = "Harga Gas Saat Ini: $" .. tostring(gasPriceObj.Value)
            if gasPriceObj.Value >= State.SellMin then
                gasLabel.TextColor3 = C_GOOD
            else
                gasLabel.TextColor3 = C_WARN
            end
        else
            gasLabel.Text = "Harga Gas: Menunggu data..."
        end
    end
end)

-- ===== LOGIKA EKSEKUSI =====
task.spawn(function()
    while task.wait(SETTINGS.SELL_DELAY) do
        if State.AutoSell and gasPriceObj and gasPriceObj.Value >= State.SellMin and SellRE then
            pcall(function() SellRE:FireServer() end)
            task.wait(SETTINGS.SELL_DELAY)
        end
    end
end)

task.spawn(function()
    while task.wait(SETTINGS.BUY_DELAY) do
        if State.AutoBuy and PurchaseRE then 
            pcall(function() PurchaseRE:FireServer("DrillShop", State.DrillType) end) 
        end
    end
end)

task.spawn(function()
    while task.wait(SETTINGS.PLACE_DELAY) do
        if State.AutoPlace and PlaceRE and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            local posX = hrp.Position.X + math.random(-SETTINGS.PLACE_RADIUS, SETTINGS.PLACE_RADIUS)
            local posY = hrp.Position.Y + SETTINGS.PLACE_HEIGHT
            local posZ = hrp.Position.Z + math.random(-SETTINGS.PLACE_RADIUS, SETTINGS.PLACE_RADIUS)
            pcall(function() PlaceRE:FireServer(generateUUID(), CFrame.new(posX, posY, posZ)) end)
        end
    end
end)

task.spawn(function()
    while task.wait(SETTINGS.PHONE_DELAY) do
        if State.AutoPhone and PhoneRE then 
            pcall(function() PhoneRE:FireServer("Accept") end) 
        end
    end
end)

-- ===== LOGIKA AUTO STEAL (HANYA YANG PENUH) =====
task.spawn(function()
    while task.wait(SETTINGS.STEAL_DELAY) do
        if State.AutoSteal and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            local originalCFrame = hrp.CFrame 
            
            local highestGas = -1
            local targetPrompt = nil
            local targetRefinery = nil
            
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if (obj:IsA("Model") or obj:IsA("BasePart")) and string.find(string.lower(obj.Name), "refinery") then
                    if not obj:IsDescendantOf(lp.Character) then
                        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                        
                        if prompt and prompt.Enabled then
                            local currentGas = 0
                            local maxGas = 0
                            
                            for _, child in ipairs(obj:GetDescendants()) do
                                if child:IsA("ValueBase") then
                                    local n = string.lower(child.Name)
                                    if string.find(n, "max") or string.find(n, "capacity") or string.find(n, "limit") then
                                        maxGas = math.max(maxGas, child.Value)
                                    elseif string.find(n, "storage") or string.find(n, "gas") or string.find(n, "amount") or string.find(n, "fuel") then
                                        currentGas = math.max(currentGas, child.Value)
                                    end
                                end
                            end
                            
                            local isFull = false
                            if maxGas > 0 then
                                if currentGas >= (maxGas * 0.9) then isFull = true end
                            else
                                isFull = true 
                            end
                            
                            if isFull and currentGas > highestGas then
                                highestGas = currentGas
                                targetPrompt = prompt
                                targetRefinery = obj
                            end
                        end
                    end
                end
            end
            
            if targetPrompt and targetRefinery and highestGas >= SETTINGS.MIN_GAS_TO_STEAL then
                hrp.CFrame = CFrame.new(targetRefinery.Position + Vector3.new(0, 3, 0))
                task.wait(0.25) 
                
                pcall(function()
                    fireproximityprompt(targetPrompt)
                end)
                
                task.wait(0.3) 
                hrp.CFrame = originalCFrame
            end
        end
    end
end)

-- ESP Logic
local espHighlights = {}
local function createESP(object, color)
    if not object or (not object:IsA("Model") and not object:IsA("BasePart")) then return end
    if object == lp.Character or (lp.Character and object:IsDescendantOf(lp.Character)) then return end 
    if espHighlights[object] and espHighlights[object].Parent == object then return end
    if espHighlights[object] then espHighlights[object]:Destroy() end
    
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = object
    espHighlights[object] = hl
end
local function removeESP(object)
    if espHighlights[object] then
        pcall(function() espHighlights[object]:Destroy() end) 
        espHighlights[object] = nil
    end
end

task.spawn(function()
    while task.wait(SETTINGS.ESP_DELAY) do
        if State.ESP_Player then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then createESP(plr.Character, Color3.fromRGB(255, 50, 50)) end
            end
        else
            for obj, hl in pairs(espHighlights) do
                if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then removeESP(obj) end
            end
        end

        if State.ESP_Merchant or State.ESP_LuckyBlock or State.ESP_Refinery then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if State.ESP_Merchant and string.find(n, "merchant") then createESP(obj, Color3.fromRGB(255, 215, 0))
                    elseif State.ESP_LuckyBlock and (string.find(n, "luckyblock") or string.find(n, "lucky block")) then createESP(obj, Color3.fromRGB(50, 150, 255))
                    elseif State.ESP_Refinery and string.find(n, "refinery") then createESP(obj, Color3.fromRGB(150, 50, 255)) end
                end
            end
        end

        for obj, hl in pairs(espHighlights) do
            if not obj or not obj.Parent then removeESP(obj) 
            else
                local n = string.lower(obj.Name)
                if not State.ESP_Player and Players:GetPlayerFromCharacter(obj) then removeESP(obj) end
                if not State.ESP_Merchant and string.find(n, "merchant") then removeESP(obj) end
                if not State.ESP_LuckyBlock and (string.find(n, "luckyblock") or string.find(n, "lucky block")) then removeESP(obj) end
                if not State.ESP_Refinery and string.find(n, "refinery") then removeESP(obj) end
            end
        end
    end
end)
