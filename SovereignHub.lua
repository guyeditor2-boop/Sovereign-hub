
--// Sovereign Hub - Independent UI
--// UI layer rebuilt independently; the game-feature code follows below.
--// Requires a Roblox/Luau environment with the normal client Instance APIs.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function getGuiParent()
    if typeof(gethui) == "function" then
        local ok, gui = pcall(gethui)
        if ok and typeof(gui) == "Instance" then
            return gui
        end
    end
    return CoreGui
end

local function hexColor(v, fallback)
    if typeof(v) == "Color3" then return v end
    if type(v) ~= "string" then return fallback or Color3.fromRGB(255,255,255) end
    local h = v:gsub("#","")
    if #h == 6 then
        local r = tonumber(h:sub(1,2),16)
        local g = tonumber(h:sub(3,4),16)
        local b = tonumber(h:sub(5,6),16)
        if r and g and b then return Color3.fromRGB(r,g,b) end
    end
    return fallback or Color3.fromRGB(255,255,255)
end

local function safeCallback(cb, value)
    if type(cb) == "function" then
        task.spawn(function()
            pcall(cb, value)
        end)
    end
end

local function styleText(label, cfg)
    label.BackgroundTransparency = cfg.BackgroundTransparency == nil and 1 or cfg.BackgroundTransparency
    label.Text = cfg.Text or ""
    label.TextColor3 = cfg.Color or Color3.fromRGB(235,238,245)
    label.TextSize = math.floor((cfg.TextSize or 14) * (cfg.Scale or 1))
    label.Font = Enum.Font.Gotham
    label.TextWrapped = cfg.Wrap == true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
end

local old = getGuiParent():FindFirstChild("SovereignHubUI")
if old then pcall(old.Destroy, old) end

local gui = Instance.new("ScreenGui")
gui.Name = "SovereignHubUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = getGuiParent()

local launcher = Instance.new("TextButton")
launcher.Name = "SovereignLauncher"
launcher.Size = UDim2.fromOffset(54,54)
launcher.Position = UDim2.new(0,18,0.5,-27)
launcher.BackgroundColor3 = Color3.fromRGB(18,20,27)
launcher.BorderSizePixel = 0
launcher.Text = "S"
launcher.TextColor3 = Color3.fromRGB(255,255,255)
launcher.TextSize = 28
launcher.Font = Enum.Font.GothamBold
launcher.Visible = false
launcher.AutoButtonColor = false
launcher.ZIndex = 50
launcher.Parent = gui
Instance.new("UICorner", launcher).CornerRadius = UDim.new(0,16)
local launcherStroke = Instance.new("UIStroke", launcher)
launcherStroke.Color = Color3.fromRGB(110,118,255)
launcherStroke.Thickness = 2

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(720,500)
main.Position = UDim2.new(0.5,-360,0.5,-250)
main.BackgroundColor3 = Color3.fromRGB(13,15,21)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(42,46,60)
mainStroke.Thickness = 1

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,52)
top.BackgroundColor3 = Color3.fromRGB(18,20,28)
top.BorderSizePixel = 0
top.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-110,1,0)
title.Position = UDim2.fromOffset(18,0)
styleText(title,{Text="Sovereign Hub",Color=Color3.fromRGB(245,247,255),TextSize=18,Scale=1})
title.Font = Enum.Font.GothamBold
title.Parent = top

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,-130,0,18)
subtitle.Position = UDim2.fromOffset(19,31)
styleText(subtitle,{Text="Independent UI • All source features",Color=Color3.fromRGB(130,136,153),TextSize=10})
subtitle.Parent = top

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(40,32)
minimize.Position = UDim2.new(1,-50,0,10)
minimize.BackgroundColor3 = Color3.fromRGB(29,32,42)
minimize.BorderSizePixel = 0
minimize.Text = "—"
minimize.TextColor3 = Color3.fromRGB(225,228,238)
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.AutoButtonColor = false
minimize.Parent = top
Instance.new("UICorner", minimize).CornerRadius = UDim.new(0,9)

local side = Instance.new("Frame")
side.Size = UDim2.new(0,150,1,-52)
side.Position = UDim2.fromOffset(0,52)
side.BackgroundColor3 = Color3.fromRGB(16,18,25)
side.BorderSizePixel = 0
side.Parent = main

local sideList = Instance.new("UIListLayout", side)
sideList.Padding = UDim.new(0,6)
sideList.SortOrder = Enum.SortOrder.LayoutOrder

local sidePad = Instance.new("UIPadding", side)
sidePad.PaddingTop = UDim.new(0,12)
sidePad.PaddingLeft = UDim.new(0,10)
sidePad.PaddingRight = UDim.new(0,10)

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1,-150,1,-52)
pages.Position = UDim2.fromOffset(150,52)
pages.BackgroundTransparency = 1
pages.Parent = main

local window = {
    Tabs = {},
    Current = nil,
    Gui = gui,
    Main = main,
}

local function dragify(handle, target)
    local dragging = false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

dragify(top, main)
dragify(launcher, launcher)

local function makeHandle(default, callback)
    local value = default
    local listeners = {}

    local handle = {}
    handle.Instance = nil
    handle._renderers = {}
    handle._controller = {
        GetValue = function() return value end,
    }

    function handle:Get()
        return value
    end

    function handle:Set(v, silent)
        value = v
        for _, render in ipairs(handle._renderers) do
            pcall(render, value)
        end
        if not silent then
            safeCallback(callback, value)
            for _, fn in ipairs(listeners) do safeCallback(fn, value) end
        end
    end

    function handle:_BindRenderer(fn)
        if type(fn) == "function" then
            table.insert(handle._renderers, fn)
            pcall(fn, value)
        end
        return handle
    end

    function handle:Subscribe(fn)
        if type(fn) ~= "function" then return {Disconnect=function() end} end
        table.insert(listeners, fn)
        return {
            Disconnect = function()
                local i = table.find(listeners, fn)
                if i then table.remove(listeners, i) end
            end
        }
    end

    return handle
end

local function addRow(parent, cfg, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-16,0,height or 48)
    row.BackgroundColor3 = Color3.fromRGB(20,23,31)
    row.BorderSizePixel = 0
    row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-150,1,0)
    label.Position = UDim2.fromOffset(12,0)
    styleText(label,{Text=cfg.Name or "Control",Color=Color3.fromRGB(232,235,243),TextSize=13})
    label.Parent = row

    if cfg.Note then
        label.Size = UDim2.new(1,-150,0,21)
        label.Position = UDim2.fromOffset(12,3)
        local note = Instance.new("TextLabel")
        note.Size = UDim2.new(1,-162,0,18)
        note.Position = UDim2.fromOffset(12,24)
        styleText(note,{Text=cfg.Note,Color=Color3.fromRGB(122,128,145),TextSize=9})
        note.Parent = row
    end
    return row, label
end

local function createToggle(parent, cfg)
    local row = addRow(parent,cfg, cfg.Note and 58 or 46)
    local handle = makeHandle(cfg.Default == true, cfg.Callback)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(56,28)
    button.Position = UDim2.new(1,-68,0.5,-14)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = row
    Instance.new("UICorner",button).CornerRadius=UDim.new(1,0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(22,22)
    dot.Position = UDim2.fromOffset(3,3)
    dot.BorderSizePixel = 0
    dot.Parent = button
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local function render(v)
        button.BackgroundColor3 = v and Color3.fromRGB(93,101,230) or Color3.fromRGB(48,52,64)
        dot.Position = v and UDim2.new(1,-25,0,3) or UDim2.fromOffset(3,3)
        dot.BackgroundColor3 = Color3.fromRGB(245,247,255)
    end
    handle:_BindRenderer(render)
    button.Activated:Connect(function() handle:Set(not handle:Get()) end)
    handle.Instance = row
    return handle
end

local function createButton(parent,cfg)
    local row = addRow(parent,cfg, cfg.Note and 58 or 46)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(110,30)
    button.Position = UDim2.new(1,-122,0.5,-15)
    button.BackgroundColor3 = Color3.fromRGB(43,47,61)
    button.BorderSizePixel = 0
    button.Text = cfg.ButtonText or "Run"
    button.TextColor3 = Color3.fromRGB(238,240,248)
    button.TextSize = 11
    button.Font = Enum.Font.GothamSemibold
    button.AutoButtonColor = true
    button.Parent = row
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)
    button.Activated:Connect(function()
        safeCallback(cfg.Callback)
        if cfg.ConfirmText then
            button.Text = cfg.ConfirmText
            task.delay(1,function()
                if button.Parent then button.Text = cfg.ButtonText or "Run" end
            end)
        end
    end)
    local h = makeHandle(false)
    h.Instance=row
    return h
end

local function createText(parent,cfg)
    local row = Instance.new("TextLabel")
    row.Name = cfg.Name or "Text"
    row.Size = UDim2.new(1,-16,0,38)
    row.BackgroundTransparency = 1
    row.Text = cfg.Text or ""
    row.TextColor3 = Color3.fromRGB(160,166,184)
    row.TextSize = 11
    row.Font = Enum.Font.Gotham
    row.TextWrapped = true
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = parent

    local obj = {Instance=row}
    function obj:Set(props)
        for k,v in pairs(props or {}) do
            if k=="Text" then row.Text=tostring(v)
            elseif k=="Color" then row.TextColor3=hexColor(v,row.TextColor3)
            elseif row[k] ~= nil then pcall(function() row[k]=v end) end
        end
    end
    return obj
end

local function createDropdown(parent,cfg,multi)
    local row = addRow(parent,cfg, cfg.Note and 58 or 46)
    local current = multi and (type(cfg.Default)=="table" and cfg.Default or {}) or cfg.Default
    local handle = makeHandle(current,cfg.Callback)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(150,30)
    button.Position = UDim2.new(1,-162,0.5,-15)
    button.BackgroundColor3 = Color3.fromRGB(29,32,42)
    button.BorderSizePixel=0
    button.TextColor3=Color3.fromRGB(220,224,236)
    button.TextSize=10
    button.Font=Enum.Font.Gotham
    button.TextTruncate=Enum.TextTruncate.AtEnd
    button.AutoButtonColor=false
    button.Parent=row
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)

    local popup
    local function display(value)
        value = value == nil and handle:Get() or value
        if multi then
            local t={}
            for k,v in pairs(value or {}) do if v then table.insert(t,tostring(k)) end end
            table.sort(t)
            button.Text=#t==0 and "None" or table.concat(t,", ")
        else
            button.Text=tostring(value or "None")
        end
    end
    handle:_BindRenderer(display)

    local function openPopup()
        if popup then popup:Destroy(); popup=nil; return end
        popup=Instance.new("Frame")
        popup.Size=UDim2.fromOffset(240,math.min(300,40+32*#(cfg.Options or {})))
        popup.Position=UDim2.new(1,-252,1,4)
        popup.BackgroundColor3=Color3.fromRGB(17,19,26)
        popup.BorderSizePixel=0
        popup.ZIndex=20
        popup.Parent=row
        Instance.new("UICorner",popup).CornerRadius=UDim.new(0,10)
        local scroll=Instance.new("ScrollingFrame")
        scroll.Size=UDim2.new(1,-8,1,-8)
        scroll.Position=UDim2.fromOffset(4,4)
        scroll.BackgroundTransparency=1
        scroll.BorderSizePixel=0
        scroll.ScrollBarThickness=3
        scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        scroll.CanvasSize=UDim2.new()
        scroll.ZIndex=21
        scroll.Parent=popup
        local list=Instance.new("UIListLayout",scroll)
        list.Padding=UDim.new(0,3)
        for _,opt in ipairs(cfg.Options or {}) do
            local b=Instance.new("TextButton")
            b.Size=UDim2.new(1,-4,0,28)
            b.BackgroundColor3=Color3.fromRGB(27,30,40)
            b.BorderSizePixel=0
            b.Text=tostring(opt)
            b.TextColor3=Color3.fromRGB(225,228,238)
            b.TextSize=10
            b.Font=Enum.Font.Gotham
            b.TextXAlignment=Enum.TextXAlignment.Left
            b.ZIndex=22
            b.Parent=scroll
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
            b.Activated:Connect(function()
                if multi then
                    local t=handle:Get() or {}
                    t[opt]=not t[opt]
                    handle:Set(t)
                else
                    handle:Set(opt)
                    popup:Destroy(); popup=nil
                end
                        end)
        end
    end

    button.Activated:Connect(openPopup)
    display()
    handle.Instance=row
    return handle
end

local function createSlider(parent,cfg)
    local row=addRow(parent,cfg, cfg.Note and 62 or 50)
    local handle=makeHandle(tonumber(cfg.Default) or tonumber(cfg.Min) or 0,cfg.Callback)
    local box=Instance.new("TextBox")
    box.Size=UDim2.fromOffset(105,30)
    box.Position=UDim2.new(1,-117,0.5,-15)
    box.BackgroundColor3=Color3.fromRGB(29,32,42)
    box.BorderSizePixel=0
    box.TextColor3=Color3.fromRGB(230,233,242)
    box.TextSize=11
    box.Font=Enum.Font.Gotham
    box.ClearTextOnFocus=false
    box.Text=tostring(handle:Get())
    box.Parent=row
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,8)

    local minv,maxv=tonumber(cfg.Min) or 0,tonumber(cfg.Max) or 100
    local function commit()
        local v=tonumber(box.Text)
        if not v then v=handle:Get() end
        v=math.clamp(v,minv,maxv)
        handle:Set(v)
        box.Text=tostring(v)
    end
    box.FocusLost:Connect(commit)
    handle:_BindRenderer(function(v) box.Text=tostring(v) end)
    handle.Instance=row
    return handle
end

local function canvasObject(parent,kind,cfg)
    local obj
    if kind=="Frame" then obj=Instance.new("Frame")
    elseif kind=="Text" then obj=Instance.new("TextLabel")
    elseif kind=="Image" then obj=Instance.new("ImageLabel") end
    if not obj then return {} end
    obj.BorderSizePixel=0
    obj.Parent=cfg.Parent or parent
    obj.Position=UDim2.new((cfg.X or 0)/10,0,(cfg.Y or 0)/10,0)
    obj.Size=UDim2.new((cfg.Width or 1)/10,0,(cfg.Height or 1)/10,0)
    obj.BackgroundTransparency=cfg.BackgroundTransparency == nil and 0 or cfg.BackgroundTransparency
    if cfg.Background then obj.BackgroundColor3=hexColor(cfg.Background,Color3.fromRGB(30,33,43)) end
    if cfg.Corner then Instance.new("UICorner",obj).CornerRadius=UDim.new(0,cfg.Corner*8) end
    if kind=="Text" then styleText(obj,cfg) end
    if kind=="Image" then
        obj.Image=cfg.Image or ""
        obj.ImageTransparency=cfg.Visible==false and 1 or 0
    end
    obj.Visible=cfg.Visible ~= false
    local wrapper={Instance=obj}
    function wrapper:Set(props)
        for k,v in pairs(props or {}) do
            if k=="Background" then obj.BackgroundColor3=hexColor(v,obj.BackgroundColor3)
            elseif k=="Color" then obj.TextColor3=hexColor(v,obj.TextColor3)
            elseif k=="StrokeColor" then
                local st=obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",obj)
                st.Color=hexColor(v,st.Color)
            elseif k=="Image" then obj.Image=tostring(v or "")
            elseif k=="Text" then obj.Text=tostring(v or "")
            else pcall(function() obj[k]=v end) end
        end
    end
    return wrapper
end

local function createCanvas(parent,cfg)
    local holder=Instance.new("Frame")
    holder.Name=cfg.Name or "Canvas"
    holder.Size=UDim2.new(1,-16,0,math.max(100,(cfg.Style and (cfg.Style.MinLines or 4) or 4)*28))
    holder.BackgroundTransparency=1
    holder.Parent=parent
    local api={}
    function api:Frame(c) return canvasObject(holder,"Frame",c) end
    function api:Text(c) return canvasObject(holder,"Text",c) end
    function api:Image(c) return canvasObject(holder,"Image",c) end
    if type(cfg.Build)=="function" then pcall(cfg.Build,api) end
    return api
end

local function createSection(tab,cfg)
    local section={Name=cfg.Name or "Section"}

    -- Each original source section becomes its own independent page.
    -- This keeps every source feature accessible without requiring an external UI library.
    local page=Instance.new("ScrollingFrame")
    page.Name=section.Name.."Page"
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=4
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.CanvasSize=UDim2.new()
    page.Visible=false
    page.Parent=pages

    local pagePad=Instance.new("UIPadding",page)
    pagePad.PaddingTop=UDim.new(0,12)
    pagePad.PaddingLeft=UDim.new(0,12)
    pagePad.PaddingRight=UDim.new(0,12)
    pagePad.PaddingBottom=UDim.new(0,18)

    local layout=Instance.new("UIListLayout",page)
    layout.Padding=UDim.new(0,7)
    layout.SortOrder=Enum.SortOrder.LayoutOrder

    local header=Instance.new("TextLabel")
    header.Size=UDim2.new(1,-2,0,42)
    header.BackgroundColor3=Color3.fromRGB(23,26,35)
    header.BorderSizePixel=0
    header.Text="  "..section.Name
    header.TextColor3=Color3.fromRGB(245,247,255)
    header.TextSize=15
    header.Font=Enum.Font.GothamBold
    header.TextXAlignment=Enum.TextXAlignment.Left
    header.Parent=page
    Instance.new("UICorner",header).CornerRadius=UDim.new(0,10)

    local body=Instance.new("Frame")
    body.Name="Controls"
    body.Size=UDim2.new(1,0,0,0)
    body.BackgroundTransparency=1
    body.AutomaticSize=Enum.AutomaticSize.Y
    body.Parent=page

    local bodyLayout=Instance.new("UIListLayout",body)
    bodyLayout.Padding=UDim.new(0,6)
    bodyLayout.SortOrder=Enum.SortOrder.LayoutOrder

    section.body=body
    section.page=page

    function section:CreateToggle(c) return createToggle(body,c) end
    function section:CreateButton(c) return createButton(body,c) end
    function section:CreateDropdown(c) return createDropdown(body,c,false) end
    function section:CreateMultiDropdown(c) return createDropdown(body,c,true) end
    function section:CreateSlider(c) return createSlider(body,c) end
    function section:CreateText(c) return createText(body,c) end
    function section:CreateCanvas(c) return createCanvas(body,c) end

    -- Sidebar entry for this entire feature group.
    local button=Instance.new("TextButton")
    button.Name="Section_"..section.Name
    button.Size=UDim2.new(1,0,0,36)
    button.BackgroundColor3=Color3.fromRGB(16,18,25)
    button.BorderSizePixel=0
    button.Text=section.Name
    button.TextColor3=Color3.fromRGB(150,156,173)
    button.TextSize=10
    button.Font=Enum.Font.GothamSemibold
    button.TextTruncate=Enum.TextTruncate.AtEnd
    button.AutoButtonColor=false
    button.LayoutOrder=100+#tab.Sections
    button.Parent=side
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,8)
    section.button=button

    tab.Sections=tab.Sections or {}
    table.insert(tab.Sections,section)

    local function selectSection()
        for _,other in ipairs(tab.Sections) do
            other.page.Visible=false
            if other.button then
                other.button.BackgroundColor3=Color3.fromRGB(16,18,25)
                other.button.TextColor3=Color3.fromRGB(150,156,173)
            end
        end
        page.Visible=true
        button.BackgroundColor3=Color3.fromRGB(52,57,82)
        button.TextColor3=Color3.fromRGB(245,247,255)
        tab.CurrentSection=section
    end

    button.Activated:Connect(selectSection)

    -- First section is shown automatically.
    if #tab.Sections==1 then
        task.defer(selectSection)
    end

    return section
end

function window:CreateTab(cfg)
    local tab={Sections={},CurrentSection=nil}
    tab.Name=cfg.Name or ("Tab"..tostring(#self.Tabs+1))
    tab.content=Instance.new("ScrollingFrame")
    tab.content.Name=tab.Name.."Page"
    tab.content.Size=UDim2.new(1,0,1,0)
    tab.content.BackgroundTransparency=1
    tab.content.BorderSizePixel=0
    tab.content.ScrollBarThickness=4
    tab.content.AutomaticCanvasSize=Enum.AutomaticSize.Y
    tab.content.CanvasSize=UDim2.new()
    tab.content.Visible=false
    tab.content.Parent=pages
    local list=Instance.new("UIListLayout",tab.content)
    list.Padding=UDim.new(0,7)
    local pad=Instance.new("UIPadding",tab.content)
    pad.PaddingTop=UDim.new(0,10)
    pad.PaddingLeft=UDim.new(0,10)
    pad.PaddingRight=UDim.new(0,10)
    pad.PaddingBottom=UDim.new(0,14)

    local tabButton=Instance.new("TextButton")
    tabButton.Size=UDim2.new(1,0,0,38)
    tabButton.BackgroundColor3=Color3.fromRGB(16,18,25)
    tabButton.BorderSizePixel=0
    tabButton.Text=tab.Name
    tabButton.TextColor3=Color3.fromRGB(150,156,173)
    tabButton.TextSize=11
    tabButton.Font=Enum.Font.GothamSemibold
    tabButton.AutoButtonColor=false
    tabButton.LayoutOrder=#self.Tabs+1
    tabButton.Parent=side

    function tab:CreateSection(c) return createSection(self,c) end
    function tab:CreateToggle(c) return createToggle(self.content,c) end
    function tab:CreateButton(c) return createButton(self.content,c) end
    function tab:CreateDropdown(c) return createDropdown(self.content,c,false) end
    function tab:CreateMultiDropdown(c) return createDropdown(self.content,c,true) end
    function tab:CreateSlider(c) return createSlider(self.content,c) end
    function tab:CreateText(c) return createText(self.content,c) end
    function tab:CreateCanvas(c) return createCanvas(self.content,c) end

    tabButton.Activated:Connect(function()
        for _,t in ipairs(self.Tabs) do
            t.content.Visible=false
            t.button.BackgroundColor3=Color3.fromRGB(16,18,25)
            t.button.TextColor3=Color3.fromRGB(150,156,173)
        end
        tab.content.Visible=true
        tabButton.BackgroundColor3=Color3.fromRGB(52,57,82)
        tabButton.TextColor3=Color3.fromRGB(245,247,255)
        self.Current=tab
    end)
    tab.button=tabButton
    table.insert(self.Tabs,tab)
    return tab
end

function window:GetDefaultTab()
    return self.Current or self.Tabs[1]
end

function window:CreateState(cfg)
    return createToggle(self.Current and self.Current.content or pages,cfg)
end

function window:Finalize()
    return true
end

local result6 = {
    ManualQuickDefaults = {},
    CreateWindow = function(_, cfg)
        local w=window
        local farm=w:CreateTab({Name=cfg.DefaultTab or "Farm",SectionsExpanded=true})
        w.Current=farm
        farm.content.Visible=true
        farm.button.BackgroundColor3=Color3.fromRGB(52,57,82)
        farm.button.TextColor3=Color3.fromRGB(245,247,255)
        return w
    end,
    Finalize=function() return true end
}

local obj1 = result6:CreateWindow({Name="Sovereign Hub - Steal An Egg",DefaultTab="Farm"})
local defaultTab = obj1:GetDefaultTab()

minimize.Activated:Connect(function()
    main.Visible=false
    launcher.Visible=true
end)

launcher.Activated:Connect(function()
    launcher.Visible=false
    main.Visible=true
end)

UIS.InputBegan:Connect(function(input,gp)
    if not gp and input.KeyCode==Enum.KeyCode.RightShift then
        main.Visible=not main.Visible
        launcher.Visible=not main.Visible
    end
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
game:GetService("LocalizationService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local localPlayer = Players.LocalPlayer
local networking = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networking")

local function func6(callback1)
	local ok, result = pcall(function()
		return require(callback1())
	end)

	return ok and result or nil
end

local tbl2 = {
	EggState = func6(function()
		return ReplicatedStorage.Client.EggState
	end),
	AreaEggs = func6(function()
		return ReplicatedStorage.Shared.Types.AreaEggs
	end),
	ToolGameplayGuard = func6(function()
		return ReplicatedStorage.Client.ToolGameplayGuard
	end),
	Assets = func6(function()
		return ReplicatedStorage.Data.Assets
	end),
	Guards = func6(function()
		return ReplicatedStorage.Data.Guards
	end),
	EggRecords = func6(function()
		return ReplicatedStorage.Shared.Util.EggRecords
	end),
	Mutations = func6(function()
		return ReplicatedStorage.Shared.Modules.Mutations
	end),
	Save = func6(function()
		return ReplicatedStorage.Shared.Save
	end),
	FuseKernel = func6(function()
		return ReplicatedStorage.Shared.Util.FuseKernel
	end),
	AreaEggCycle = func6(function()
		return ReplicatedStorage.Shared.Util.AreaEggCycle
	end),
	AreaEggResetWall = func6(function()
		return ReplicatedStorage.Client.AreaEggResetWall
	end),
	AreaEggResetCycle = func6(function()
		return ReplicatedStorage.Data.AreaEggResetCycle
	end),
	Gears = func6(function()
		return ReplicatedStorage.Data.Gears
	end),
	Areas = func6(function()
		return ReplicatedStorage.Data.Areas
	end),
	LimitedEgg = func6(function()
		return ReplicatedStorage.Data.LimitedEgg
	end),
	BrainrotEgg = func6(function()
		return ReplicatedStorage.Data.BrainrotEgg
	end),
	MonsterEgg = func6(function()
		return ReplicatedStorage.Data.MonsterEgg
	end),
}

local save = tbl2.Save

if type(save) == "table" then
	if type(save.Get) ~= "function" then
		local func7 = setmetatable
		local tbl3 = {}
		local get = type(save.Get) == "function" and save.Get

		if get then
			tbl3.Get = get
			local fieldSignal = type(save.FieldSignal) == "function" and save.FieldSignal

			if fieldSignal then
				tbl3.FieldSignal = fieldSignal
				tbl2.Save = func7(tbl3, { __index = save })

				local function func8()
					if typeof(gethui) == "function" then
						local ok, result = pcall(gethui)
						if ok and typeof(result) == "Instance" then
							return result
						end
					end

					return CoreGui
				end

				func8()
				local obj2 = Random.new()
				local str1 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

				local function func9()
					local value2 = obj2:NextInteger(12, 20)
					local arr2 = table.create(value2)

					for i = 1, value2 do
						local value3 = obj2:NextInteger(1, #str1)
						arr2[i] = string.sub("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", value3, value3)
					end

					return table.concat(arr2)
				end

				local tbl4 = {}

				local function func10(param2)
					table.insert(tbl4, param2)
				end

				local tbl5 = {}

				local function func11(obj3, param3)
					local n = 1000
					local n2 = 3
					local n3 = 12

					local function func12(num1)
						if num1 <= 0 then
							return 0
						end
						local n4 = 10 ^ (math.floor(math.log10(num1)) - 2)
						return math.floor(num1 / n4 + 0.5) * n4
					end

					local function func13(param4)
						local n4 = math.clamp(tonumber(param4) or 0, 0, 1000)
						if n4 <= 0 then
							return 0
						end
						return func12(10 ^ (n2 + (n3 - n2) * n4 / n))
					end

					local function stepOf(param5)
						local n4 = tonumber(param5) or 0
						if n4 <= 0 then
							return 0
						end
						local n5 = n3 - n2
						return math.clamp(math.floor((math.log10(n4) - n2) / n5 * n * 100 + 0.5) / 100, 0, 1000)
					end

					local function func14(param6)
						local formatted = string.format(param6 >= 100 and "%.0f" or param6 >= 10 and "%.1f" or "%.2f", param6)

						if string.find(formatted, ".", 1, true) then
							formatted = string.gsub(string.gsub(formatted, "0+$", ""), "%.$", "")
						end

						return formatted
					end

					local function valueFormat(param7)
						local num2 = func13(param7)
						if num2 <= 0 then
							return "Off"
						end

						if num2 < 1000000 then
							return func14(num2 / 1000) .. " K/s"
						end

						if num2 < 1e9 then
							return func14(num2 / 1000000) .. " M/s"
						end
						return func14(num2 / 1e9) .. " B/s"
					end

					local function func15(param8)
						local num3 = func13(param8)
						if num3 <= 0 then
							return "0"
						end

						if num3 < 1000000 then
							return func14(num3 / 1000) .. "k"
						end
						return (string.gsub(string.gsub(string.format("%.3f", num3 / 1000000), "0+$", ""), "%.$", ""))
					end

					local tbl6 = { k = 1000, m = 1000000, b = 1e9, t = 1e12 }

					local function valueParse(flag1)
						local cleaned = string.gsub(string.lower(string.gsub(tostring(flag1 or ""), "[%s,/]", "")), "s$", "")
						if cleaned == "" or cleaned == "off" then
							return 0
						end
						local value4, value5 = string.match(cleaned, "^([%d%.]+)([kmbt]?)$")
						local num4 = tonumber(value4)
						if not num4 then
							return nil
						end
						return stepOf(num4 * (tbl6[value5] or 1000000))
					end

					local value6 = obj3:CreateSlider({
						Name = param3.Name,
						Note = param3.Note,
						SubOf = param3.SubOf,
						Min = 0,
						Max = n,
						Default = stepOf(param3.Default or 0),
						AllowDecimals = true,
						Increment = 0.01,
						ValueFormat = valueFormat,
						ValueParse = valueParse,
						Callback = function(value)
							if type(param3.OnRaw) == "function" then
								param3.OnRaw(func13(value))
							end
						end,
					})

					local obj4 = type(value6) == "table" and rawget(value6, "Instance") or nil

					if typeof(obj4) == "Instance" then
						for _, descendant in ipairs(obj4:GetDescendants()) do
							if descendant:IsA("TextBox") then
								local connection = descendant.Focused:Connect(function()
									task.defer(function()
										if descendant:IsFocused() then
											local ok, result = pcall(value6.Get, value6)
											descendant.Text = func15(ok and result or 0)
											descendant.CursorPosition = #descendant.Text + 1
											descendant.SelectionStart = 1
										end
									end)
								end)

								func10(function()
									pcall(function()
										connection:Disconnect()
									end)
								end)
							end
						end
					end

					if type(param3.Legacy) == "string" and type(param3.SectionName) == "string" then
						table.insert(tbl5, { Handle = value6, Name = param3.Name, Legacy = param3.Legacy, Section = param3.SectionName, StepOf = stepOf })
					end

					return value6
				end

				local function func16(param9)
					if type(param9) ~= "table" then
						return param9
					end
					local instance = rawget(param9, "Instance")
					if typeof(instance) ~= "Instance" then
						return param9
					end
					local flag2 = false

					local function func17(param10)
						if flag2 then
							return
						end

						if param10.Text == "None" then
							flag2 = true
							param10.Text = "All"
							flag2 = false
						end
					end

					local function func18(descendant)
						if not descendant:IsA("TextLabel") or descendant.Name ~= "Value" then
							return
						end
						func17(descendant)

						local connection = descendant:GetPropertyChangedSignal("Text"):Connect(function()
							func17(descendant)
						end)

						func10(function()
							pcall(function()
								connection:Disconnect()
							end)
						end)
					end

					for _, descendant in ipairs(instance:GetDescendants()) do
						func18(descendant)
					end

					local connection = instance.DescendantAdded:Connect(func18)

					func10(function()
						pcall(function()
							connection:Disconnect()
						end)
					end)

					return param9
				end

				if typeof(getgenv) == "function" then
					local genv = getgenv()

					if genv then
						if type(genv.SovereignHubCleanup) ~= "function" then
							genv.SovereignHubCleanup = function()
								for i = #tbl4, 1, -1 do
									pcall(tbl4[i])
								end

								table.clear(tbl4)
							end

							local n = 0
							local value7 = nil

							value7 = function(list1, flag3)
								local n2 = flag3 or 0

								if type(list1) == "table" then
									if n2 > 3 then
										return
									end
									local n3 = 0

									for k, value8 in pairs(list1) do
										n3 += 1

										if not (n3 > 20) then
											value7(k, n2 + 1)
											value7(value8, n2 + 1)
											continue
										end

										break
									end
								elseif typeof(list1) == "Instance" then
									pcall(list1.GetFullName, list1)
								else
									n += #tostring(list1)
								end
							end

							local list2 = {}

							local function func19(param11)
								list2[#list2 + 1] = param11
							end

							local function func20()
								for _, item2 in ipairs(list2) do
									pcall(function()
										item2:Disconnect()
									end)
								end

								table.clear(list2)
							end

							local function chilliToolKeeper()
								func20()

								for _, item3 in ipairs({
									"RE/GearSatchel/Lost",
									"RE/GearSatchel/Gained",
									"RE/RigSync/ProbeSatchel",
									"RE/RigSync/SeedSatchel",
									"RE/RigSync/CorrectionBegan",
									"RE/RigSync/Refresh",
									"RE/ToolTrigger/Trigger",
									"RE/BatSwing/Trigger",
								}) do
									local obj5 = networking:FindFirstChild(item3)

									if obj5 and obj5:IsA("RemoteEvent") then
										func19(obj5.OnClientEvent:Connect(function(...)
											value7({ ... })
										end))
									end
								end

								local function func21(flag4)
									if not flag4 then
										return
									end

									func19(flag4.ChildRemoved:Connect(function(child)
										if child:IsA("Tool") then
											value7({ child.Name, child.Parent })
										end
									end))

									func19(flag4.ChildAdded:Connect(function(child)
										if child:IsA("Tool") then
											value7({ child.Name })
										end
									end))
								end

								func21(localPlayer:FindFirstChildOfClass("Backpack"))

								func19(localPlayer.ChildAdded:Connect(function(child)
									if child:IsA("Backpack") then
										func21(child)
									end
								end))

								task.spawn(function()
									pcall(function()
										local value9 = tbl2.Save.Get()
										value7({ value9.GearInventory, value9.Inventory }, 2)
									end)

									if type(getgc) == "function" then
										pcall(function()
											for _, item4 in ipairs(getgc(false)) do
												if type(item4) == "function" and islclosure(item4) then
													pcall(debug.info, item4, "n")
												end
											end
										end)
									end
								end)
							end

							local genv2 = typeof(getgenv) == "function" and getgenv()

							if genv2 then
								genv2.SovereignToolKeeper = chilliToolKeeper
								task.defer(chilliToolKeeper)
								func10(func20)
								local n2 = 0.35
								local n3 = 5
								local tbl7 = {}
								local flag5 = true

								local tbl8 = {
									Add = function(param12)
										local tbl9 = { Run = param12, Gap = n2, Idle = n3, Repeat = false, Hold = 0 }
										table.insert(tbl7, tbl9)
										return tbl9
									end,
									Wake = function()
										flag5 = true
									end,
									Backoff = function(param13, param14)
										if param13 then
											param13.Hold = tonumber(param14) or 6
										end
									end,
								}

								local connection = RunService.Heartbeat:Connect(function(deltaTime)
									local flag6 = flag5
									flag5 = false

									for _, item5 in ipairs(tbl7) do
										item5.Gap = item5.Gap + deltaTime
										item5.Idle = item5.Idle + deltaTime

										if item5.Hold > 0 then
											item5.Hold = item5.Hold - deltaTime
										else
											local flag7 = item5.Gap >= n2
											local repeat_

											if flag7 then
												repeat_ = flag6 or item5.Repeat or item5.Idle >= n3
											else
												repeat_ = flag7
											end

											if repeat_ then
												item5.Gap = 0
												item5.Idle = 0
												local ok, result = pcall(item5.Run, item5)
												item5.Repeat = ok and result == true
											end
										end
									end
								end)

								func10(function()
									connection:Disconnect()
								end)

								local obj6 = defaultTab:CreateSection({ Name = "Dr Scramble Lab & Mech", Expanded = false })
								local obj7 = defaultTab:CreateSection({ Name = "Auto Steal", Expanded = true })
								local obj8 = defaultTab:CreateSection({ Name = "Auto Place Egg", Expanded = false })
								local obj9 = defaultTab:CreateSection({ Name = "Auto Treadmill", Expanded = false })
								local obj10 = defaultTab:CreateSection({ Name = "Auto Hatch & Equip", Expanded = false })
								local obj11 = defaultTab:CreateSection({ Name = "Auto Sell", Expanded = false })
								local obj12 = defaultTab:CreateSection({ Name = "Auto Fuse Machine", Expanded = false })
								local obj13 = defaultTab:CreateSection({ Name = "Auto Favorite", Expanded = false })
								local tbl10 = { Paused = false }
								local n4 = 0.5
								local value10 = nil
								local value11 = nil
								local list3 = {}
								local flag8 = false
								local n5 = 0

								local function func22()
									for i = #list3, 1, -1 do
										local entry1 = list3[i]

										if entry1 and entry1.Connected then
											entry1:Disconnect()
										end

										list3[i] = nil
									end
								end

								local function func23()
									func22()
									local obj14 = value10
									local flag9 = value11
									value10 = nil
									value11 = nil
									if not obj14 or not obj14.Parent or not flag9 then
										return
									end

									pcall(function()
										obj14.BreakJointsOnDeath = flag9.BreakJointsOnDeath
										obj14.RequiresNeck = flag9.RequiresNeck
										obj14:SetStateEnabled(Enum.HumanoidStateType.Dead, flag9.DeadEnabled)
									end)
								end

								local function func24(instance2)
									if not instance2 or not instance2.Parent then
										return false
									end

									return pcall(function()
										instance2.BreakJointsOnDeath = false
										instance2.RequiresNeck = false
										instance2:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
									end) and instance2.BreakJointsOnDeath == false and instance2.RequiresNeck == false and instance2:GetStateEnabled(Enum.HumanoidStateType.Dead) == false
								end

								local function func25(humanoid2)
									if tbl10.Paused or humanoid2 ~= value10 or not humanoid2 or not humanoid2.Parent or flag8 then
										return false
									end
									local maxHealth = humanoid2.MaxHealth
									if maxHealth <= 0 then
										return false
									end

									if maxHealth == math.huge or humanoid2.Health >= maxHealth then
										return true
									end
									flag8 = true

									local ok = pcall(function()
										humanoid2.Health = maxHealth
									end)

									flag8 = false
									return ok and humanoid2.Health >= maxHealth
								end

								local function func26(instance3)
									if instance3 == value10 and instance3 and instance3.Parent then
										return true
									end
									func23()
									if not instance3 or not instance3:IsA("Humanoid") or not instance3.Parent then
										return false
									end
									value10 = instance3

									value11 = {
										BreakJointsOnDeath = instance3.BreakJointsOnDeath,
										RequiresNeck = instance3.RequiresNeck,
										DeadEnabled = instance3:GetStateEnabled(Enum.HumanoidStateType.Dead),
									}

									if not func24(instance3) then
										func23()
										return false
									end
									func25(instance3)

									list3[#list3 + 1] = instance3.HealthChanged:Connect(function()
										func25(instance3)
									end)

									list3[#list3 + 1] = instance3:GetPropertyChangedSignal("MaxHealth"):Connect(function()
										func25(instance3)
									end)

									list3[#list3 + 1] = instance3.StateChanged:Connect(function(old, new)
										if new == Enum.HumanoidStateType.Dead and not tbl10.Paused then
											func24(instance3)
											func25(instance3)
										end
									end)

									n5 = os.clock()
									return true
								end

								local function func27()
									local character = localPlayer.Character
									return character and character:FindFirstChildOfClass("Humanoid") or nil
								end

								local connection2 = localPlayer.CharacterAdded:Connect(function()
									task.defer(function()
										func26(func27())
									end)
								end)

								local connection3 = RunService.Heartbeat:Connect(function()
									local now = os.clock()
									if tbl10.Paused or now - n5 < n4 then
										return
									end
									n5 = now
									local result7 = func27()
									if result7 ~= value10 then
										func26(result7)
										return
									end

									if result7 then
										func24(result7)
										func25(result7)
									end
								end)

								task.defer(function()
									func26(func27())
								end)

								func10(function()
									if connection2 then
										connection2:Disconnect()
									end

									if connection3 then
										connection3:Disconnect()
									end

									func23()
								end)

								local tbl11 = {
									"bat",
									"katana",
									"axe",
									"staff",
									"club",
									"hammer",
									"sword",
									"blade",
								}

								local num5

								num5 = {
									Steal = { Active = false, LastFinishedAt = 0, Carrying = false },
									SafeCarry = {
										Enabled = true,
										SkipUnsafe = false,
										WaitGuard = false,
										SameSpeedBigEggs = false,
										Blocked = {},
										StretchSeconds = 6,
										BeatGuard = false,
										SlowUntil = 0,
										SlowFactor = 0.3,
										LineDrop = false,
										LineGap = 12,
										LineWait = 15,
										DirectBudget = 450,
										DirectMargin = 0.3,
										CrossNow = false,
										CrossSpeed = 231,
										PickupSpeed = 154,
										HopRatio = 1.515,
										CrossRatio = 1,
										PickupRatio = 0.667,
										FarFromLine = 150,
										DropDelay = 0.19,
										LineApproach = 0.97,
										ReJump = true,
										ShakeTime = 0,
										SnapPickup = false,
										Hops = true,
										HopStep = 350,
										HopGap = 0.1,
										HopLift = 42,
										HopStop = 48,
										GetUp = true,
										ShakeInside = 1,
										CarryScale = 1,
										EasyRatio = 1.3,
										LastSkip = nil,
										Category = nil,
										PlanOk = true,
										LightMult = 0.96,
										Height = 70,
										ClimbShare = 0.5,
										Approach = "Run",
										RunSpeed = 1,
										RunWait = 0,
										RunAnimate = true,
										RunHeight = 50,
										SnapLimit = 90,
										StraightRun = true,
										RunStyle = "Velocity",
										CarryStyle = "Velocity",
										SpeedJitter = 0.08,
										Wobble = 0,
										LaneOffset = 0,
										JumpsPerMinute = 0,
										PausesPerMinute = 0,
										ReactMin = 0.2,
										ReactMax = 0.6,
										CarryReact = 0,
										SpeedRatio = 1.5,
										ExcessSeconds = 5.5,
										GuardMargin = 4,
										GuardRatio = 1.06,
										MinRatio = 1.1,
										BaseWait = 6.5,
										FreeJump = 1500,
										WaitRate = 0.9,
										RecoverTries = math.huge,
										GuessMult = 0.93,
										CarryRatio = 0.9,
										Mult = 1,
										Seen = {},
										JumpDistance = 0,
										JumpAt = 0,
										LastDelivered = 0,
										LastFailed = 0,
										Handle = nil,
									},
									Movement = {
										Owner = nil,
										PlaceWanted = false,
										StealFirst = false,
										MutationWanted = false,
										FracturedWanted = false,
									},
									AntiGuard = {
										Enabled = false,
										Busy = false,
										BusySince = 0,
										HitArms = 0,
										Handle = nil,
										Render = nil,
									},
									IsBatTool = function(instance4)
										if typeof(instance4) ~= "Instance" or not instance4:IsA("Tool") then
											return false
										end

										if instance4:GetAttribute("IsBat") == true then
											return true
										end
										local attribute = instance4:GetAttribute("GearName")

										if type(attribute) == "string" then
											local gears = tbl2.Gears
											local directory = type(gears) == "table" and gears.Directory or nil
											local flag10 = type(directory) == "table" and directory[attribute] or nil
											return type(flag10) == "table" and flag10.BatControllerData ~= nil
										end

										if instance4:GetAttribute("ItemType") ~= nil then
											return false
										end
										local lowered = string.lower(instance4.Name)

										for _, item6 in ipairs(tbl11) do
											if string.find(lowered, item6, 1, true) then
												return true
											end
										end

										return false
									end,
									FindBat = function()
										local character = localPlayer.Character
										local tool = character and character:FindFirstChildWhichIsA("Tool")
										if num5.IsBatTool(tool) then
											return tool
										end
										local backpack = localPlayer:FindFirstChildOfClass("Backpack")

										if backpack then
											for _, child in ipairs(backpack:GetChildren()) do
												if num5.IsBatTool(child) then
													return child
												end
											end
										end

										if character then
											for _, child in ipairs(character:GetChildren()) do
												if num5.IsBatTool(child) then
													return child
												end
											end
										end

										return nil
									end,
									IsNight = function()
										local areaEggCycle = tbl2.AreaEggCycle
										if type(areaEggCycle) ~= "table" or type(areaEggCycle.IsNightPhase) ~= "function" then
											return false
										end
										local ok, result = pcall(areaEggCycle.IsNightPhase, workspace:GetServerTimeNow())
										return ok and result == true
									end,
									WallSealed = function()
										local areaEggResetWall = tbl2.AreaEggResetWall
										if type(areaEggResetWall) ~= "table" or type(areaEggResetWall.IsSealed) ~= "function" then
											return false
										end
										local ok, result = pcall(areaEggResetWall.IsSealed)
										return ok and result == true
									end,
									WallOpenDelay = function()
										local areaEggResetCycle = tbl2.AreaEggResetCycle
										if type(areaEggResetCycle) ~= "table" then
											return 5
										end
										return (tonumber(areaEggResetCycle.WallCountdownDelayAfterDayStartsSeconds) or 2) + (tonumber(areaEggResetCycle.WallCountdownSeconds) or 3)
									end,
									ClaimMovement = function(owner)
										local movement = num5.Movement
										if movement.Owner == nil or movement.Owner == owner or movement.Owner == "treadmill" and owner ~= "treadmill" or movement.Owner == "scramble" and owner == "steal" then
											movement.Owner = owner
											return true
										end
										return false
									end,
									ReleaseMovement = function(param15)
										if num5.Movement.Owner == param15 then
											num5.Movement.Owner = nil
										end
									end,
								}

								local shieldMethods = { "Humanoid Swap", "Disable Monitor" }
								num5.ShieldMethods = shieldMethods
								local first1 = shieldMethods[1]
								local tbl12 = {}
								local tbl13 = {}
								local connection4 = nil
								local n6 = 0
								local tbl14 = { Original = nil, Clone = nil, Links = {} }
								local connection5 = nil
								local tbl15 = {}

								local function func28()
									for _, item7 in ipairs(tbl15) do
										task.defer(function()
											pcall(item7)
										end)
									end
								end

								num5.OnHumanoidChanged = function(param16)
									table.insert(tbl15, param16)
									local tbl16

									tbl16 = {
										Connected = true,
										Disconnect = function()
											tbl16.Connected = false
											local foundAt = table.find(tbl15, param16)

											if foundAt then
												table.remove(tbl15, foundAt)
											end
										end,
									}

									return tbl16
								end

								local function func29(humanoid)
									pcall(function()
										local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
										local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")

										if playerModule then
											local controls = require(playerModule):GetControls()

											if type(controls) == "table" then
												controls.humanoid = humanoid
											end
										end
									end)
								end

								local function func30(instance5)
									local animate = instance5 and instance5:FindFirstChild("Animate")

									if animate and animate:IsA("LocalScript") then
										task.spawn(function()
											animate.Enabled = false
											task.wait()
											animate.Enabled = true
										end)
									end
								end

								local function func31()
									for _, link in ipairs(tbl14.Links) do
										pcall(function()
											link:Disconnect()
										end)
									end

									table.clear(tbl14.Links)
								end

								num5.UndoSwap = function()
									func31()
									local character = localPlayer.Character
									local original = tbl14.Original
									local clone = tbl14.Clone
									local value12 = tbl14
									tbl14.Original = nil
									value12.Clone = nil

									if original and clone and character and original.Parent == nil and clone.Parent == character then
										original.Parent = character
										workspace.CurrentCamera.CameraSubject = original
										func29(original)

										pcall(function()
											clone:Destroy()
										end)

										func30(character)
										func28()
									end
								end

								local tbl17 = {
									[Enum.HumanoidStateType.Running] = true,
									[Enum.HumanoidStateType.RunningNoPhysics] = true,
									[Enum.HumanoidStateType.Landed] = true,
								}

								num5.Grounded = function(obj)
									if not obj then
										local character = localPlayer.Character
										obj = character and character:FindFirstChildOfClass("Humanoid")
									end

									if not obj or obj.Health <= 0 or obj.FloorMaterial == Enum.Material.Air then
										return false
									end
									return tbl17[obj:GetState()] == true
								end

								num5.ShieldPaused = false

								num5.WalkSpeed = function()
									local character = localPlayer.Character
									character = character and character:FindFirstChildOfClass("Humanoid")
									character = character and character.WalkSpeed or 16
									local original = tbl14.Original

									if original and original.Health > 0 then
										character = math.min(character, original.WalkSpeed)
									end

									local ok, result = pcall(function()
										local leaderstats = localPlayer:FindFirstChild("leaderstats")
										leaderstats = leaderstats and leaderstats:FindFirstChild("Speed")
										local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
										return leaderstats and TreadmillUtil.SpeedPowerToWalkSpeed(leaderstats.Value) or nil
									end)

									local n7

									if ok and tonumber(result) and result > 0 then
										n7 = math.min(character, result)
									else
										n7 = character
									end

									return n7
								end

								local function func32()
									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")
									if not humanoid or humanoid.Health <= 0 then
										return
									end

									if tbl14.Clone and tbl14.Clone.Parent == character then
										return
									end

									if not num5.Grounded(humanoid) then
										return
									end
									local clone = humanoid:Clone()
									humanoid.Parent = nil
									clone.Parent = character
									workspace.CurrentCamera.CameraSubject = clone
									func29(clone)
									func30(character)
									local value13 = tbl14
									tbl14.Original = humanoid
									value13.Clone = clone
									func28()

									table.insert(tbl14.Links, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
										if clone.Parent ~= nil then
											clone.WalkSpeed = humanoid.WalkSpeed
										end
									end))

									local animator = humanoid:FindFirstChildOfClass("Animator")
									local animator2 = clone:FindFirstChildOfClass("Animator")

									if animator and animator2 then
										table.insert(tbl14.Links, animator.AnimationPlayed:Connect(function(param17)
											local animation = param17.Animation
											if not animation or clone.Parent == nil then
												return
											end

											local ok, result = pcall(function()
												return animator2:LoadAnimation(animation)
											end)

											if not ok or not result then
												return
											end

											pcall(function()
												result.Priority = param17.Priority
												result.Looped = param17.Looped
												local speed = param17.Speed
												result:Play(0.05, math.max(param17.WeightTarget, 0.01), speed)
											end)

											local connection6 = nil

											connection6 = param17.Stopped:Connect(function()
												connection6:Disconnect()

												pcall(function()
													result:Stop(0.1)
												end)
											end)
										end))
									end

									table.insert(tbl14.Links, clone.Died:Connect(function()
										func31()
										local value14 = tbl14
										tbl14.Original = nil
										value14.Clone = nil
										local character2 = localPlayer.Character

										if character2 and humanoid.Parent == nil then
											humanoid.Parent = character2
											workspace.CurrentCamera.CameraSubject = humanoid
											func29(humanoid)
											func28()
										end

										pcall(function()
											clone:Destroy()
										end)

										humanoid.Health = 0
									end))
								end

								local function func33()
									if type(getconnections) ~= "function" then
										return
									end

									for _, item8 in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
										local ok, result = pcall(getconnections, item8)

										if ok and type(result) == "table" then
											for _, item9 in ipairs(result) do
												local ok2, result2 = pcall(function()
													return item9.Function
												end)

												local flag11 = ok2 and type(result2) == "function"
												local flag12 = false
												local result3 = nil

												if flag11 then
													flag12, result3 = pcall(debug.info, result2, "s")
												end

												if flag12 and string.find(tostring(result3), "UGI", 1, true) then
													local ok3, result4 = pcall(function()
														return item9.Enabled
													end)

													if not ok3 or result4 ~= false then
														if pcall(function()
															item9:Disable()
														end) then
															table.insert(tbl13, item9)
														end
													end
												end
											end
										end
									end
								end

								local function func34()
									if connection4 then
										connection4:Disconnect()
										connection4 = nil
									end

									if connection5 then
										connection5:Disconnect()
										connection5 = nil
									end

									for _, item10 in ipairs(tbl13) do
										pcall(function()
											item10:Enable()
										end)
									end

									table.clear(tbl13)
								end

								local function func35()
									if num5.ShieldPaused then
										return
									end

									if first1 == shieldMethods[1] then
										func32()
									else
										func33()
									end
								end

								local function func36()
									func35()
									n6 = 0

									connection4 = RunService.Heartbeat:Connect(function(deltaTime)
										n6 += deltaTime
										local character = localPlayer.Character
										local flag13 = first1 == shieldMethods[1]

										if flag13 then
											flag13 = not (tbl14.Clone and character and tbl14.Clone.Parent == character)
										end

										if (flag13 and 0.25 or 3) <= n6 then
											n6 = 0
											func35()
										end
									end)

									connection5 = localPlayer.CharacterAdded:Connect(function(character)
										func31()
										local value15 = tbl14
										tbl14.Original = nil
										value15.Clone = nil
										if first1 ~= shieldMethods[1] then
											return
										end

										task.spawn(function()
											character:WaitForChild("Humanoid", 10)
											task.wait(1)

											if connection4 and localPlayer.Character == character then
												func35()
											end
										end)
									end)
								end

								num5.Swapped = function()
									if first1 ~= shieldMethods[1] then
										return true
									end
									local character = localPlayer.Character
									return tbl14.Clone ~= nil and character ~= nil and tbl14.Clone.Parent == character
								end

								num5.Shield = function(param18, flag14)
									tbl12[param18] = flag14 == true or nil
									if next(tbl12) == nil then
										func34()
										return
									end

									if connection4 then
										return
									end
									func36()
								end

								num5.SetShieldMethod = function(flag15)
									if not table.find(shieldMethods, flag15) or flag15 == first1 then
										return
									end
									local flag16 = connection4 ~= nil
									func34()
									first1 = flag15

									if flag16 and next(tbl12) ~= nil then
										func36()
									end
								end

								func10(func34)
								num5.Shield("load", true)

								num5.Toggle = function(obj, flag17)
									if type(obj) ~= "table" then
										return flag17 == true
									end

									local ok, result = pcall(function()
										local controller = obj._controller
										return type(controller) == "table" and type(controller.GetValue) == "function" and controller.GetValue()
									end)

									if ok and type(result) == "boolean" then
										return result
									end

									for _, item11 in ipairs({ "Get", "GetValue" }) do
										local ok2, result2 = pcall(function()
											return obj[item11]
										end)

										if ok2 and type(result2) == "function" then
											local ok3, result3 = pcall(result2, obj)
											if ok3 and type(result3) == "boolean" then
												return result3
											end
										end
									end

									return flag17 == true
								end

								num5.Root = function()
									local character = localPlayer.Character
									local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
									return humanoidRootPart and humanoidRootPart:IsDescendantOf(workspace) and humanoidRootPart or nil
								end

								num5.PlacedPoints = function()
									local placedEggRenders = workspace:FindFirstChild("PlacedEggRenders")
									local tbl18 = {}
									if not placedEggRenders then
										return tbl18
									end
									local userId2 = tostring(localPlayer.UserId)

									for _, child in ipairs(placedEggRenders:GetChildren()) do
										if string.find(child.Name, userId2, 1, true) then
											local ok, result = pcall(function()
												return child:IsA("Model") and child:GetPivot() or child.CFrame
											end)

											if ok then
												table.insert(tbl18, result.Position)
											end
										end
									end

									return tbl18
								end

								num5.OwnPlot = function()
									local plots = workspace:FindFirstChild("Plots")
									if not plots then
										return nil
									end

									for _, child in ipairs(plots:GetChildren()) do
										local plotSign = child:FindFirstChild("PlotSign")
										plotSign = plotSign and plotSign:FindFirstChild("PlayerPlotSign")
										plotSign = plotSign and plotSign:FindFirstChild("Frame")
										plotSign = plotSign and plotSign:FindFirstChild("PlayerName")

										if plotSign and plotSign:IsA("TextLabel") then
											local lowered2 = string.lower(plotSign.Text)
											if lowered2 == string.lower(localPlayer.Name) or lowered2 == string.lower(localPlayer.DisplayName) then
												return child
											end
										end
									end

									return nil
								end

								local function func37()
									local list4 = num5.PlacedPoints()
									if #list4 == 0 then
										return nil
									end
									local vector = Vector3.zero

									for _, item12 in ipairs(list4) do
										vector += item12
									end

									return vector / #list4
								end

								num5.PenAnchor = function()
									local result8 = func37()
									if result8 then
										return result8
									end
									local obj15 = num5.OwnPlot()
									if not obj15 then
										return nil
									end
									local toUpdate = obj15:FindFirstChild("ToUpdate")
									local starterPen = toUpdate and toUpdate:FindFirstChild("StarterPen") or obj15:FindFirstChild("CenterPoint")
									if not starterPen then
										return nil
									end

									local ok, result = pcall(function()
										return starterPen:IsA("Model") and starterPen:GetPivot() or starterPen.CFrame
									end)

									return ok and result.Position or nil
								end

								num5.Plot = function()
									local value16 = num5.OwnPlot()
									if value16 then
										return value16
									end
									local plots = workspace:FindFirstChild("Plots")
									local result9 = func37()
									if not plots or not result9 then
										return nil
									end
									local huge = math.huge
									local value17 = nil

									for _, child in ipairs(plots:GetChildren()) do
										local ok, result, result2 = pcall(function()
											return child:GetBoundingBox()
										end)

										if ok and result and result2 then
											local value18 = result:PointToObjectSpace(result9)
											local n7 = result2.X / 2
											local flag18 = math.abs(value18.X) <= n7

											if flag18 then
												local n8 = result2.Z / 2
												flag18 = math.abs(value18.Z) <= n8
											end

											if flag18 then
												return child
											end
											local magnitude = (result.Position - result9).Magnitude

											if magnitude < huge then
												value17 = child
												huge = magnitude
											end
										end
									end

									if value17 and huge <= 60 then
										return value17
									end
									return nil
								end

								num5.Belt = function()
									local obj16 = num5.Plot()
									if not obj16 then
										return nil
									end
									local treadmillBottom = obj16:FindFirstChild("TreadmillBottom")
									if treadmillBottom and treadmillBottom:IsA("BasePart") then
										return treadmillBottom
									end
									local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
									clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. obj16.Name)
									local boundingBoxPart = clientTreadmillRenders and (clientTreadmillRenders:FindFirstChild("BoundingBoxPart") or clientTreadmillRenders:IsA("Model") and clientTreadmillRenders.PrimaryPart or clientTreadmillRenders:FindFirstChildWhichIsA("BasePart"))
									if boundingBoxPart then
										return boundingBoxPart
									end
									local treadmillUpgrade = obj16:FindFirstChild("TreadmillUpgrade")
									return treadmillUpgrade and treadmillUpgrade:FindFirstChildWhichIsA("BasePart") or nil
								end

								num5.DistanceTo = function(num6)
									local flag19 = num5.Root()
									if not flag19 or not num6 then
										return math.huge
									end
									return (flag19.Position - num6).Magnitude
								end

								local tbl19 = {}
								local n7 = 0

								local function func38()
									local obj17 = num5.Plot()
									if not obj17 then
										return {}
									end
									local tbl20 = {}

									for _, item13 in ipairs({ "TreadmillBottom", "TreadmillUpgrade" }) do
										local obj18 = obj17:FindFirstChild(item13)

										if obj18 then
											if obj18:IsA("BasePart") then
												table.insert(tbl20, obj18)
											else
												for _, descendant in ipairs(obj18:GetDescendants()) do
													if descendant:IsA("BasePart") then
														table.insert(tbl20, descendant)
													end
												end
											end
										end
									end

									local clientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
									clientTreadmillRenders = clientTreadmillRenders and clientTreadmillRenders:FindFirstChild("TreadmillRender_" .. obj17.Name)

									if clientTreadmillRenders then
										for _, descendant in ipairs(clientTreadmillRenders:GetDescendants()) do
											if descendant:IsA("BasePart") then
												table.insert(tbl20, descendant)
											end
										end
									end

									return tbl20
								end

								local function func39()
									for _, item14 in ipairs(func38()) do
										if not tbl19[item14] then
											tbl19[item14] = {
												CFrame = item14.CFrame,
												CanTouch = item14.CanTouch,
												CanCollide = item14.CanCollide,
												Transparency = item14.Transparency,
											}

											pcall(function()
												item14.CanTouch = false
												item14.CanCollide = false
												item14.Transparency = 1
												item14.CFrame = item14.CFrame - Vector3.new(0, 120, 0)
											end)
										end
									end
								end

								local function func40()
									for k, value19 in pairs(tbl19) do
										if k and k.Parent then
											pcall(function()
												k.CFrame = value19.CFrame
												k.CanTouch = value19.CanTouch
												k.CanCollide = value19.CanCollide
												k.Transparency = value19.Transparency
											end)
										end
									end

									table.clear(tbl19)
								end

								num5.HoldBelt = function()
									n7 += 1
									func39()
								end

								num5.ReleaseBelt = function()
									n7 = math.max(0, n7 - 1)

									if n7 == 0 then
										func40()
									end
								end

								num5.BeltHeld = function()
									return n7 > 0
								end

								num5.RefreshBeltHide = function()
									if n7 > 0 then
										func39()
									end
								end

								func10(function()
									n7 = 0
									func40()
								end)

								num5.LeaveBelt = function()
									local rfTreadmillAskDoff = networking:FindFirstChild("RF/Treadmill/AskDoff")

									if rfTreadmillAskDoff and rfTreadmillAskDoff:IsA("RemoteFunction") then
										pcall(rfTreadmillAskDoff.InvokeServer, rfTreadmillAskDoff)
									end
								end

								num5.Treadmill = { Riding = false }

								num5.ResetBelt = function()
									n7 = 0
									func40()
								end

								num5.OnBelt = function()
									local flag20 = num5.Belt()
									if not flag20 or tbl19[flag20] then
										return false
									end
									local flag21 = num5.Root()
									if not flag21 then
										return false
									end
									local value20 = flag20.CFrame:PointToObjectSpace(flag21.Position)
									local n8 = flag20.Size.X / 2 + 2
									local flag22 = math.abs(value20.X) <= n8

									if flag22 then
										local n9 = flag20.Size.Z / 2 + 2
										flag22 = math.abs(value20.Z) <= n9
									end

									return flag22 and value20.Y >= -2 and value20.Y <= flag20.Size.Y / 2 + 8
								end

								num5.ExitBelt = function()
									num5.Treadmill.Riding = false
									num5.LeaveBelt()
									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")

									if humanoid then
										pcall(function()
											humanoid.Jump = true
											humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
										end)
									end

									task.wait(0.35)
								end

								num5.Flying = false
								num5.Driving = 0

								num5.BeginFlight = function()
									num5.Flying = true
									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")

									if humanoid then
										humanoid.PlatformStand = true

										pcall(function()
											humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
										end)
									end

									return num5.Root() ~= nil
								end

								num5.SetFlightVelocity = function(assemblyLinearVelocity)
									local value21 = num5.Root()

									if value21 then
										value21.AssemblyLinearVelocity = assemblyLinearVelocity
										value21.AssemblyAngularVelocity = Vector3.zero
									end
								end

								num5.EndFlight = function()
									num5.Flying = false
									local value22 = num5.Root()

									if value22 then
										pcall(function()
											value22.AssemblyLinearVelocity = Vector3.zero
											value22.AssemblyAngularVelocity = Vector3.zero
										end)
									end

									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")

									if humanoid then
										humanoid.PlatformStand = false
									end
								end

								local tbl21 = {
									Enum.HumanoidStateType.FallingDown,
									Enum.HumanoidStateType.Ragdoll,
									Enum.HumanoidStateType.Physics,
									Enum.HumanoidStateType.Seated,
									Enum.HumanoidStateType.PlatformStanding,
								}

								local tbl22 = {}
								local flag23 = false

								num5.GodMode = function(param19)
									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")
									if not character or not humanoid then
										return
									end

									if param19 then
										flag23 = true

										for _, item15 in ipairs(tbl21) do
											pcall(function()
												humanoid:SetStateEnabled(item15, false)
											end)
										end

										pcall(function()
											humanoid.BreakJointsOnDeath = false
										end)

										for _, descendant in ipairs(character:GetDescendants()) do
											if descendant:IsA("BasePart") and tbl22[descendant] == nil then
												tbl22[descendant] = descendant.CanCollide

												pcall(function()
													descendant.CanCollide = false
												end)
											end
										end
									elseif flag23 then
										flag23 = false

										for _, item16 in ipairs(tbl21) do
											pcall(function()
												humanoid:SetStateEnabled(item16, true)
											end)
										end

										for k, value23 in pairs(tbl22) do
											if k and k.Parent then
												pcall(function()
													k.CanCollide = value23
												end)
											end
										end

										table.clear(tbl22)
									end
								end

								num5.GodTick = function()
									local character = localPlayer.Character
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")

									if humanoid and humanoid.Health < humanoid.MaxHealth then
										pcall(function()
											humanoid.Health = humanoid.MaxHealth
										end)
									end
								end
								-- deobfuscated by S​L​ ​|​ ​S​o​u​r​c​e​ ​L​e​a​k -> https://discord.gg/x7YbZeezpm

								num5.StopWalking = function()
									local character = localPlayer.Character
									local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
									local humanoid = character and character:FindFirstChildOfClass("Humanoid")

									if humanoid and humanoidRootPart then
										pcall(function()
											humanoid:MoveTo(humanoidRootPart.Position)
											humanoid:Move(Vector3.zero, false)
										end)
									end
								end

								local function func41(num7, param20, param21, callback2)
									local n8 = tonumber(param20) or 6
									local n9 = tonumber(param21) or 10
									local n10 = 0
									local value24 = nil
									local n11 = 0
									local n12 = 0

									while n10 < n9 do
										if type(callback2) == "function" and callback2() then
											num5.StopWalking()
											return false
										end
										local character = localPlayer.Character
										local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
										character = character and character:FindFirstChildOfClass("Humanoid")
										if not humanoidRootPart or not character or character.Health <= 0 then
											return false
										end

										if (humanoidRootPart.Position - num7).Magnitude <= n8 then
											num5.StopWalking()
											return true
										end
										value24 = value24 and (humanoidRootPart.Position - value24).Magnitude < 1

										if value24 then
											n11 += 0.2
										else
											n11 = 0
										end

										value24 = humanoidRootPart.Position
										n12 = math.max(0, n12 - 0.2)

										if n11 >= 0.8 and n12 <= 0 then
											num5.LeaveBelt()

											pcall(function()
												character.Jump = true
											end)

											n11 = 0
											n12 = 1.5
										end

										character:MoveTo(num7)
										n10 += task.wait(0.2)
									end

									num5.StopWalking()
									return num5.DistanceTo(num7) <= n8
								end

								num5.WalkTo = function(param22, param23, param24, param25)
									num5.Driving = num5.Driving + 1
									local ok, result = pcall(func41, param22, param23, param24, param25)
									num5.Driving = math.max(0, num5.Driving - 1)
									return ok and result == true
								end

								local tbl23 = {
									Boss = "Fractured",
									GreatBloom = "Spirit Bloom",
									Sakura = "Bloom",
									Monstrous = "Parasite",
								}

								task.spawn(function()
									local mutations = tbl2.Mutations

									local ok, result = pcall(function()
										return mutations.All()
									end)

									if ok and type(result) == "table" then
										for k, value25 in pairs(result) do
											local id = type(value25) == "table" and (value25.Id or k) or nil
											local label = type(value25) == "table" and value25.Label or nil

											if id ~= nil and type(label) == "string" and label ~= "" then
												tbl23[tostring(id)] = label
											end
										end
									end
								end)

								local function func42(param26)
									return tbl23[tostring(param26)] or tostring(param26)
								end

								local tbl24 = {
									"Forest",
									"Desert",
									"Snow",
									"Lake",
									"Jungle",
									"Volcano",
									"Prehistoric",
									"Cosmic",
									"Abyss Ocean",
									"Cherry Blossom",
									"Light Dark",
									"Titan Temple",
								}

								local tbl25 = {}

								for _, item17 in ipairs(tbl24) do
									tbl25[item17] = true
								end

								task.spawn(function()
									local eggState = tbl2.EggState

									local ok, result = pcall(function()
										return eggState.ReadFieldEggs()
									end)

									if ok and type(result) == "table" and type(result.Records) == "table" then
										for _, record in pairs(result.Records) do
											local areaId = type(record) == "table" and record.AreaId or nil

											if type(areaId) == "string" and not tbl25[areaId] then
												tbl25[areaId] = true
												table.insert(tbl24, areaId)
											end
										end
									end
								end)

								local tbl26 = { "Any" }
								local tbl27 = { Any = 0 }
								local tbl28 = {}

								if type(tbl2.Assets and tbl2.Assets.Directory) ~= "table" then
									if next(tbl28) ~= nil then
										local tbl29 = {}

										for k in pairs(tbl28) do
											table.insert(tbl29, k)
										end

										table.sort(tbl29)

										for _, item18 in ipairs(tbl29) do
											table.insert(tbl26, tbl28[item18])
											tbl27[tbl28[item18]] = item18
										end

										local tbl30 = {
											"Best Rarity",
											"Biggest Weight",
											"Best Mutation",
											"Highest Value",
											"Lowest Value",
										}

										local tbl31 = {}
										local n8 = 0
										local tbl32 = {}
										local tbl33 = {}
										local tbl34 = {}
										local tbl35 = {}
										num5.Steal.RiftPriority = false
										num5.Steal.RiftNeeds = {}
										local flag24 = false
										local tbl36 = {}
										local n9 = 0
										local entry2 = tbl30[4]
										local n10 = 27.4
										local n11 = 400
										local value26 = nil

										local value27 = obj7:CreateToggle({
											Name = "Auto Steal",
											Default = false,
											Callback = function()
												if value26 then
													value26()
												end
											end,
										})

										for _, item19 in ipairs(tbl24) do
											tbl31[item19] = true
										end

										func16(obj7:CreateMultiDropdown({
											Name = "Target Areas",
											Options = tbl24,
											Default = tbl24,
											Callback = function(value)
												local tbl37 = {}

												if type(value) == "table" then
													for k, value28 in pairs(value) do
														if value28 == true and type(k) == "string" then
															tbl37[k] = true
														elseif type(value28) == "string" then
															tbl37[value28] = true
														end
													end
												end

												if next(tbl37) == nil then
													for _, item20 in ipairs(tbl24) do
														tbl37[item20] = true
													end
												end

												tbl31 = tbl37
											end,
										}))

										obj7:CreateDropdown({
											Name = "Min Rarity",
											Note = "Steal eggs of the chosen rarity and every rarity above it",
											Options = tbl26,
											Default = tbl26[1],
											Callback = function(value)
												n8 = tbl27[value] or 0
											end,
										})

										func11(obj7, {
											Name = "Min Steal Value",
											Note = "Skip eggs worth less than this. Drag or type 250k, 50m, 1.5b",
											Legacy = "Min Value To Steal",
											SectionName = "Auto Steal",
											OnRaw = function(param27)
												n9 = param27
											end,
										})

										local tbl38 = {}
										local tbl39 = {}

										if tbl2.Assets then
											local tbl40 = {}

											if type(tbl2.Assets.Directory) ~= "table" then
												table.sort(tbl40, function(param28, param29)
													if param28.Rarity ~= param29.Rarity then
														return param28.Rarity > param29.Rarity
													end
													return param28.Name < param29.Name
												end)

												for _, item21 in ipairs(tbl40) do
													local formatted2 = string.format("%s [%s]", item21.Name, item21.RarityName)

													if tbl39[formatted2] then
														formatted2 = string.format("%s [%s] (%s)", item21.Name, item21.RarityName, item21.Category)
													end

													table.insert(tbl38, formatted2)
													tbl39[formatted2] = item21.Category
												end

												func16(obj7:CreateMultiDropdown({
													Name = "Target Specific Eggs",
													Note = "Only steal these eggs (empty = all)",
													Options = tbl38,
													Default = {},
													Callback = function(value)
														local tbl41 = {}

														if type(value) == "table" then
															for k, value29 in pairs(value) do
																k = value29 == true and type(k) == "string" and k

																if k then
																	value29 = k
																else
																	value29 = type(value29) == "string" and value29
																end

																value29 = value29 or nil

																if value29 and tbl39[value29] then
																	tbl41[tbl39[value29]] = true
																end
															end
														end

														tbl32 = tbl41
													end,
												}))

												local n12 = 30
												local value30 = nil
												local flag25 = false
												local n13 = 0

												local function func43()
													local tbl42 = {}
													local save2 = tbl2.Save

													if type(save2) == "table" and type(save2.Get) == "function" then
														local ok, result = pcall(save2.Get)

														if ok and type(result) == "table" then
															local func44 = pairs
															local inventory = result.Inventory or {}

															for _, value31 in func44(inventory) do
																if type(value31) == "table" and value31.Category ~= nil then
																	tbl42[tostring(value31.Category)] = true
																end
															end

															local func45 = pairs
															local eggInventory = result.EggInventory or {}

															for _, value32 in func45(eggInventory) do
																if type(value32) == "table" and value32.AssetCategory ~= nil then
																	tbl42[tostring(value32.AssetCategory)] = true
																end
															end
														end
													end

													return tbl42
												end

												local function func46()
													local rfScrambleTradeInAskState = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")
													if not rfScrambleTradeInAskState or not rfScrambleTradeInAskState:IsA("RemoteFunction") then
														return
													end
													local ok, result = pcall(rfScrambleTradeInAskState.InvokeServer, rfScrambleTradeInAskState)
													if not ok or type(result) ~= "table" or type(result.Requirements) ~= "table" then
														return
													end
													local result10 = func43()
													local riftNeeds = {}

													for _, requirement in pairs(result.Requirements) do
														if not result10[tostring(requirement)] then
															riftNeeds[tostring(requirement)] = true
														end
													end

													num5.Steal.RiftNeeds = riftNeeds
												end

												tbl8.Add(function()
													if not num5.Steal.RiftPriority or flag25 or os.clock() < n13 then
														return false
													end
													flag25 = true
													n13 = os.clock() + n12

													task.spawn(function()
														pcall(func46)
														flag25 = false
													end)

													return false
												end)

												local function func47()
													local riftNeeds = num5.Steal.RiftNeeds
													if not num5.Steal.RiftPriority or next(riftNeeds) == nil then
														return
													end
													local result11 = func43()
													local flag26 = false

													for k in pairs(riftNeeds) do
														if result11[k] then
															riftNeeds[k] = nil
															flag26 = true
														end
													end

													if flag26 then
														tbl8.Wake()
													end
												end

												local save2 = tbl2.Save

												if type(save2) == "table" and type(save2.FieldSignal) == "function" then
													for _, item22 in ipairs({ "EggInventory", "Inventory" }) do
														local ok, result = pcall(save2.FieldSignal, item22)

														if ok and type(result) == "table" and type(result.Connect) == "function" then
															local ok2, result2 = pcall(result.Connect, result, function()
																task.defer(func47)
															end)

															if ok2 and result2 then
																func10(function()
																	pcall(function()
																		result2:Disconnect()
																	end)
																end)
															end
														end
													end
												end

												value30 = obj7:CreateToggle({
													Name = "Steal Missing Lab Eggs",
													Default = false,
													Callback = function()
														num5.Steal.RiftPriority = num5.Toggle(value30, false) == true
														n13 = 0

														if not num5.Steal.RiftPriority then
															num5.Steal.RiftNeeds = {}
														end

														tbl8.Wake()
													end,
												})

												local value33 = nil
												local n17 = 0
												local n18 = 0
												local flag27 = false
												local tbl43 = {}

												local function func48()
													local save3 = tbl2.Save

													if type(save3) == "table" and type(save3.Get) == "function" then
														local ok, result = pcall(save3.Get)
														if ok and type(result) == "table" then
															return result
														end
													end

													return nil
												end

												local function func49()
													local result12 = func48()
													local directory = tbl2.Areas and tbl2.Areas.Directory
													local directory2 = tbl2.Assets and tbl2.Assets.Directory
													if not result12 or type(directory) ~= "table" or type(directory2) ~= "table" then
														return
													end
													local index = type(result12.Index) == "table" and result12.Index or {}
													local tbl44 = {}
													local func50 = pairs
													local inventory = result12.Inventory or {}

													for _, value34 in func50(inventory) do
														if type(value34) == "table" and value34.Category ~= nil then
															tbl44[tostring(value34.Category)] = true
														end
													end

													local func51 = pairs
													local eggInventory = result12.EggInventory or {}

													for _, value35 in func51(eggInventory) do
														if type(value35) == "table" and value35.AssetCategory ~= nil then
															tbl44[tostring(value35.AssetCategory)] = true
														end
													end

													local tbl45 = {}

													for _, value36 in pairs(directory) do
														local flag28 = type(value36) == "table" and type(value36.Rarity) == "table"

														if flag28 then
															flag28 = tonumber(value36.Rarity.RarityNumber or value36.Rarity.Rank)
														end

														flag28 = flag28 or 0
														local func52 = pairs
														local dropTable = type(value36) == "table" and value36.DropTable or {}

														for _, value37 in func52(dropTable) do
															local flag29 = type(value37) == "table" and value37[1] or nil
															local n19 = type(value37) == "table" and tonumber(value37[2]) or 0
															local flag30 = flag29 ~= nil and directory2[flag29] or nil

															if type(flag30) == "table" and n19 > 0 and flag30.DontRoll ~= true then
																local str2 = tostring(flag29)

																if index[flag29] ~= true and not tbl44[str2] and (tbl45[str2] == nil or flag28 > tbl45[str2]) then
																	tbl45[str2] = flag28
																end
															end
														end
													end

													tbl36 = tbl45
												end

												local function func53(childName, ...)
													local obj19 = networking:FindFirstChild(childName)
													if not obj19 or not obj19:IsA("RemoteFunction") then
														return false
													end
													local ok, result = pcall(obj19.InvokeServer, obj19, ...)
													return ok and result ~= false
												end

												local function func54(param30, list5)
													local tbl46 = {}
													if type(param30) ~= "table" then
														return tbl46
													end

													for _, item23 in ipairs(list5) do
														local tbl47 = param30

														for _, item24 in ipairs(item23) do
															tbl47 = type(tbl47) == "table" and tbl47[item24] or nil
														end

														local func55 = ipairs
														local tbl48 = type(tbl47) == "table" and tbl47 or {}

														for _, value38 in func55(tbl48) do
															if type(value38) == "table" and value38.AssetId ~= nil then
																table.insert(tbl46, value38.AssetId)
															end
														end
													end

													return tbl46
												end

												local tbl49 = {
													{
														Id = "LimitedEgg",
														Gear = "GravityDisruptor",
														Module = "LimitedEgg",
														Lists = {
															{ "Entries" },
															{ "MechaReroll", "Entries" },
														},
													},
													{
														Id = "BrainrotEgg",
														Gear = "BeeLauncher",
														Module = "BrainrotEgg",
														Lists = { { "Entries" } },
													},
													{
														Id = "MonsterEgg",
														Gear = "BeeLauncher",
														Module = "MonsterEgg",
														Lists = { { "Entries" }, { "MechaEntries" } },
													},
												}

												local function func56()
													local result13 = func48()
													if not result13 then
														return
													end
													local index = type(result13.Index) == "table" and result13.Index or {}
													local indexClaimedCategories = type(result13.IndexClaimedCategories) == "table" and result13.IndexClaimedCategories or {}

													for k, value39 in pairs(index) do
														if value39 == true and indexClaimedCategories[k] ~= true then
															func53("RF/Codex/AskRedeemAll")
															break
														end
													end

													local gearInventory = type(result13.GearInventory) == "table" and result13.GearInventory or {}

													for _, item25 in ipairs(tbl49) do
														local flag31 = (tonumber(gearInventory[item25.Gear]) or 0) <= 0

														if flag31 then
															flag31 = os.clock() >= (tbl43[item25.Id] or 0)
														end

														if flag31 then
															local list6 = func54(tbl2[item25.Module], item25.Lists)
															local len = #list6 > 0

															for _, item26 in ipairs(list6) do
																if index[item26] ~= true then
																	len = false
																	break
																end
															end

															if len then
																tbl43[item25.Id] = os.clock() + 60
																func53("RF/Codex/AskRedeemLimitedEgg", item25.Id)
															end
														end
													end
												end

												tbl8.Add(function()
													local now = os.clock()

													if flag24 and now >= n17 then
														n17 = now + 5
														pcall(func49)
													end

													if not flag27 and now >= n18 and num5.Toggle(num5.IndexClaimHandle, false) then
														flag27 = true
														n18 = now + 5

														task.spawn(function()
															pcall(func56)
															flag27 = false
														end)
													end

													return false
												end)

												value33 = obj7:CreateToggle({
													Name = "Steal Missing Index Eggs",
													Note = "Also steal eggs missing from your index, highest area first",
													Default = false,
													Callback = function()
														flag24 = num5.Toggle(value33, false) == true
														n17 = 0

														if not flag24 then
															tbl36 = {}
														end

														tbl8.Wake()
													end,
												})

												num5.IndexClaimRestart = function()
													n18 = 0
													tbl8.Wake()
												end

												num5.Steal.PriorityHandle = obj7:CreateDropdown({
													Name = "Steal Priority",
													Options = tbl30,
													Default = tbl30[4],
													Callback = function(value)
														if table.find(tbl30, value) then
															entry2 = value

															if type(num5.ResortSteal) == "function" then
																num5.ResortSteal()
															end
														end
													end,
												})

												num5.SafeCarry.InstantHandle = obj7:CreateToggle({
													Name = "Instant Steal",
													Note = "Delivers the egg to the safe zone in a few seconds, needs enough Speed",
													Default = false,
													Callback = function(value)
														if type(value) ~= "boolean" then
															value = num5.Toggle(num5.SafeCarry.InstantHandle, false)
														end

														num5.SafeCarry.LineDrop = value ~= false
														num5.SafeCarry.SpeedJitter = num5.SafeCarry.LineDrop and 0 or 0.08

														if num5.StealPanelSync then
															pcall(num5.StealPanelSync)
														end
													end,
												})

												num5.SafeCarry.RunHandle = obj7:CreateSlider({
													Name = "Tween Speed",
													Note = "Over 100% may glitch",
													Min = 50,
													Max = 120,
													Default = 100,
													Increment = 1,
													Unit = "%",
													Callback = function(value)
														num5.SafeCarry.RunSpeed = math.clamp(tonumber(value) or 100, 50, 120) / 100
													end,
												})

												obj7:CreateSlider({
													Name = "Carry Speed",
													Min = 80,
													Max = 120,
													Default = 100,
													Increment = 1,
													Unit = "%",
													Callback = function(value)
														num5.SafeCarry.CarryScale = math.clamp(tonumber(value) or 100, 80, 120) / 100
													end,
												})

												num5.AntiGuard.Handle = obj1:CreateState({ Name = "Anti Guard Enabled", Default = false })

												pcall(function()
													num5.AntiGuard.Enabled = num5.AntiGuard.Handle:Get() == true
												end)

												pcall(function()
													num5.AntiGuard.Handle:Subscribe(function(enabled2)
														if type(enabled2) ~= "boolean" then
															enabled2 = num5.AntiGuard.Handle:Get()
														end

														num5.AntiGuard.Enabled = enabled2 == true

														if num5.StealPanelSync then
															pcall(num5.StealPanelSync)
														end

														if num5.AntiGuard.Render and num5.UiDefer then
															num5.UiDefer(function()
																pcall(num5.AntiGuard.Render, false)
															end)
														end
													end)
												end)

												num5.AntiGuard.PanelHandle = obj7:CreateToggle({
													Name = "Anti Guard Panel",
													Default = true,
													Callback = function(panelShown)
														if type(panelShown) ~= "boolean" then
															panelShown = num5.Toggle(num5.AntiGuard.PanelHandle, true)
														end

														num5.AntiGuard.PanelShown = panelShown

														if num5.AntiGuard.ShowPanel then
															pcall(num5.AntiGuard.ShowPanel, panelShown)
														end
													end,
												})

												local value40 = nil
												local value41 = nil
												local value42 = nil
												local str3 = "None"
												local str4 = "Idle"
												local flag32 = false
												local n19 = 0
												local tbl50 = {}
												local uid = nil

												local function func57(flag33)
													return flag33 ~= n19 or not num5.Toggle(value40, false)
												end

												local tbl51 = {}

												local function func58(num8)
													if type(num8) ~= "number" or tbl51[num8] then
														return
													end
													tbl51[num8] = true

													task.delay(math.max(0, num8 - workspace:GetServerTimeNow()) + 0.05, function()
														tbl51[num8] = nil
														tbl8.Wake()
													end)
												end

												local n21 = 0

												local function func59()
													local areaEggCycle = tbl2.AreaEggCycle
													if type(areaEggCycle) ~= "table" then
														return nil
													end

													local ok, result, result2, result3, result4 = pcall(function()
														local serverTimeNow = workspace:GetServerTimeNow()
														local nextResetTime = areaEggCycle.NextResetTime
														return serverTimeNow, areaEggCycle.IsNightPhase(serverTimeNow), areaEggCycle.NextNightTime(serverTimeNow), nextResetTime(serverTimeNow)
													end)

													if not ok or type(result4) ~= "number" then
														return nil
													end

													if result2 == true then
														n21 = result4 + num5.WallOpenDelay()
														func58(n21)
														return n21, "night", result
													end

													if num5.WallSealed() then
														func58(result + 0.3)
														return math.max(n21, result), "wall", result
													end

													if type(result3) == "number" and result3 > result then
														func58(result3)
													end

													return nil
												end

												local areaEggResetWall = tbl2.AreaEggResetWall
												local changed = type(areaEggResetWall) == "table" and areaEggResetWall.Changed

												if changed then
													local n22, tbl52, n23, func60, func61, func62, func63, func64, func65, func66
													local func67, func68, n24, func69, func70, func71, func72, func73, func74, func75
													local func76, n25, n26, n27, func77, stealHome

													do
														do
															local n28, func78

															do
																do
																	do
																		do
																			local obj20 = changed

																			if type(obj20.Connect) == "function" then
																				do
																					local ok, result = pcall(function()
																						return obj20:Connect(function()
																							tbl8.Wake()
																						end)
																					end)

																					if ok and result then
																						func10(function()
																							pcall(function()
																								result:Disconnect()
																							end)
																						end)
																					end
																				end
																			end
																		end

																		n22 = 8
																		tbl52 = nil
																		n23 = 0

																		do
																			local function func79(flag34)
																				local tbl53 = {}
																				local str5 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
																				local eggState = tbl2.EggState

																				if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
																					task.spawn(function()
																						local ok, result = pcall(eggState.ReadFieldEggs)

																						if ok and type(result) == "table" and type(result.Records) == "table" then
																							for _, record in pairs(result.Records) do
																								local flag35 = type(record) == "table" and type(record.Uid) == "string"

																								if flag35 then
																									flag35 = not (flag34 and string.sub(record.Uid, 1, #str5) == str5)
																								end

																								if flag35 then
																									tbl53[record.Uid] = true
																								end
																							end
																						end
																					end)
																				end

																				return tbl53
																			end

																			func60 = function()
																				if tbl52 == nil then
																					return false
																				end

																				if num5.IsNight() then
																					return true
																				end

																				if n23 == math.huge then
																					n23 = os.clock() + n22
																				end

																				return false
																			end

																			func61 = function()
																				if tbl52 and n23 == math.huge then
																					return
																				end
																				tbl52 = func79(true)
																				n23 = math.huge
																				table.clear(tbl33)
																				table.clear(tbl35)
																				table.clear(tbl34)
																				table.clear(tbl50)
																				uid = nil
																			end

																			func62 = function()
																				if not tbl52 then
																					return false
																				end

																				if os.clock() >= n23 then
																					tbl52 = nil
																					return false
																				end
																				local result14 = func79()
																				if next(result14) == nil then
																					return true
																				end
																				local flag36 = false
																				local flag37 = false

																				for k in pairs(result14) do
																					if tbl52[k] then
																						flag36 = true
																					else
																						flag37 = true
																					end
																				end

																				if not flag36 then
																					tbl52 = nil
																					return false
																				end
																				return not flag37
																			end
																		end
																	end

																	do
																		local function func80(param31)
																			local directory = tbl2.Assets and tbl2.Assets.Directory
																			local flag38 = type(directory) == "table" and directory[tostring(param31)] or nil
																			local rarity = type(flag38) == "table" and type(flag38.Rarity) == "table" and flag38.Rarity or nil
																			local tbl54 = {}

																			if rarity then
																				rarity = tonumber(rarity.RarityNumber or rarity.Rank)
																			end

																			tbl54.RarityNumber = rarity or 0
																			tbl54.EarningRate = type(flag38) == "table" and tonumber(flag38.EarningRate) or 0
																			return tbl54
																		end

																		local function func81(flag39)
																			local mutations = tbl2.Mutations

																			if type(mutations) == "table" and type(mutations.EarningsFor) == "function" then
																				local ok, result = pcall(mutations.EarningsFor, type(flag39) == "table" and flag39 or {})
																				if ok and type(result) == "number" then
																					return result
																				end
																			end

																			return 1
																		end

																		local function func82(param32, param33)
																			local eggRecords = tbl2.EggRecords

																			if type(eggRecords) == "table" and type(eggRecords.WeightKgForScale) == "function" then
																				local ok, result = pcall(eggRecords.WeightKgForScale, param32, param33)
																				if ok and type(result) == "number" then
																					return result
																				end
																			end

																			return 0
																		end

																		func63 = function(flag40, flag41)
																			local records = nil
																			local eggState = tbl2.EggState

																			if type(eggState) == "table" and type(eggState.ReadFieldEggs) == "function" then
																				task.spawn(function()
																					local ok, result = pcall(eggState.ReadFieldEggs)

																					if ok and type(result) == "table" and type(result.Records) == "table" and next(result.Records) ~= nil then
																						records = result.Records
																					end
																				end)
																			end

																			if not records then
																				local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
																				if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
																					return {}
																				end
																				local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
																				records = ok and type(result) == "table" and result.Records or nil
																			end

																			if type(records) ~= "table" then
																				return {}
																			end
																			local tbl55 = {}
																			local tbl56 = {}

																			for _, record in pairs(records) do
																				local uid2 = type(record) == "table" and record.Uid or nil

																				if uid2 and record.State ~= "Claimed" then
																					tbl56[uid2] = true
																				end

																				local state2 = record.State == "Carried" and flag41 == true and flag40 ~= true and not (num5.Steal.Carrying and uid2 == num5.Steal.CarryUid)
																				local flag42

																				if uid2 then
																					flag42 = record.State == "Slot" or record.State == "Dropped" or state2
																				else
																					flag42 = uid2
																				end

																				local flag43 = uid2 and tbl33[uid2] or nil
																				local flag44 = uid2 and tbl34[uid2] == true or false
																				local flag45 = flag40 ~= true and flag24 and uid2 and tbl36[tostring(record.AssetCategory)] or nil
																				local flag46 = flag40 ~= true and num5.Steal.RiftPriority == true and uid2 ~= nil and num5.Steal.RiftNeeds[tostring(record.AssetCategory)] == true
																				local flag47 = flag40 == true or flag43 ~= nil or flag44 or flag46 or flag45 ~= nil or tbl31[tostring(record.AreaId)] == true
																				local flag48 = flag40 ~= true and flag43 == nil and tbl35[uid2] == true
																				local flag49 = tbl52 ~= nil and tbl52[uid2] == true
																				flag42 = flag42 and typeof(record.BottomCFrame) == "CFrame"
																				local flag50

																				if flag42 then
																					flag50 = (tbl50[uid2] or 0) <= os.clock()
																				else
																					flag50 = flag42
																				end

																				if flag50 and flag47 and not flag48 and not flag49 then
																					local assetCategory = func80(record.AssetCategory)
																					local assetCategory2 = tostring(record.AssetCategory)
																					local flag51 = assetCategory.RarityNumber >= n8
																					local flag52 = next(tbl32) == nil or tbl32[assetCategory2] == true
																					local n29 = tonumber(record.AssetScale) or 1
																					local mutations3 = func81(record.Mutations)
																					local n30 = n29 > 5 and (n29 / 5) ^ 1.2 * 19.637875755794113 or n29 ^ 1.85
																					local flag53 = n9 <= 0 or assetCategory.EarningRate * n30 * mutations3 >= n9
																					flag53 = flag51 and flag52 and flag53
																					local flag54 = flag46 and not flag53 and not flag44 and flag43 == nil and flag45 == nil
																					local lastSkip = flag40 ~= true and num5.SafeCarry.Unsafe({ Uid = uid2, Category = assetCategory2 })

																					if lastSkip then
																						tbl33[uid2] = nil
																						tbl34[uid2] = nil
																						num5.SafeCarry.LastSkip = lastSkip
																					elseif flag40 == true or flag43 or flag44 or flag46 or flag45 ~= nil or flag53 then
																						table.insert(tbl55, {
																							Uid = uid2,
																							Category = assetCategory2,
																							Scale = n29,
																							State = record.State,
																							Rarity = assetCategory.RarityNumber,
																							Weight = func82(record.AssetCategory, n29),
																							Mutation = mutations3,
																							Value = assetCategory.EarningRate * n30 * mutations3,
																							CFrame = record.BottomCFrame,
																							AreaId = tostring(record.AreaId),
																							Rift = flag40 ~= true and flag46,
																							RiftOnly = flag40 ~= true and flag54,
																							Index = flag45,
																							Forced = flag40 ~= true and flag43 and flag43.At or nil,
																							Priority = flag40 ~= true and flag44,
																						})
																					end
																				end
																			end

																			if next(tbl56) ~= nil then
																				for k in pairs(tbl33) do
																					if not tbl56[k] then
																						tbl33[k] = nil
																					end
																				end

																				for k in pairs(tbl34) do
																					if not tbl56[k] then
																						tbl34[k] = nil
																					end
																				end

																				for k in pairs(tbl35) do
																					if not tbl56[k] then
																						tbl35[k] = nil
																					end
																				end
																			end

																			table.sort(tbl55, function(param34, param35)
																				if param34.Forced ~= nil ~= param35.Forced ~= nil then
																					return param34.Forced ~= nil
																				end

																				if param34.Forced and param35.Forced and param34.Forced ~= param35.Forced then
																					return param34.Forced < param35.Forced
																				end

																				if param34.Priority ~= param35.Priority then
																					return param34.Priority == true
																				end

																				if param34.RiftOnly ~= param35.RiftOnly then
																					return param35.RiftOnly == true
																				end

																				if param34.Index ~= nil ~= param35.Index ~= nil then
																					return param34.Index ~= nil
																				end

																				if param34.Index and param35.Index and param34.Index ~= param35.Index then
																					return param34.Index > param35.Index
																				end

																				if entry2 == tbl30[2] and param34.Weight ~= param35.Weight then
																					return param34.Weight > param35.Weight
																				end

																				if entry2 == tbl30[3] and param34.Mutation ~= param35.Mutation then
																					return param34.Mutation > param35.Mutation
																				end

																				if entry2 == tbl30[4] and param34.Value ~= param35.Value then
																					return param34.Value > param35.Value
																				end

																				if entry2 == tbl30[5] and param34.Value ~= param35.Value then
																					return param34.Value < param35.Value
																				end

																				if param34.Rarity ~= param35.Rarity then
																					return param34.Rarity > param35.Rarity
																				end

																				if param34.Value ~= param35.Value then
																					return param34.Value > param35.Value
																				end
																				return tostring(param34.Uid) < tostring(param35.Uid)
																			end)

																			return tbl55
																		end
																	end
																end

																n28 = 6

																do
																	local value43 = nil
																	local connection6 = nil

																	func78 = function(part2, num9, num10, num11, flag55)
																		local n29 = num9 - part2.Position
																		local magnitude = n29.Magnitude
																		local n30 = math.max(num11, 0.0041666666666666666)
																		local vector = Vector3.zero

																		if magnitude > 0.01 then
																			vector = n29.Unit * math.min(num10, magnitude / n30)
																		end

																		local assemblyLinearVelocity = vector + Vector3.new(0, workspace.Gravity * n30 * 0.5, 0)

																		if magnitude > 2 then
																			if not flag55.mark then
																				flag55.mark = magnitude
																				flag55.clock = 0
																			end

																			flag55.clock = flag55.clock + num11

																			if flag55.clock >= 0.4 then
																				if flag55.mark - magnitude < num10 * 0.1 then
																					pcall(function()
																						part2.CFrame = part2.CFrame + n29.Unit * math.min(magnitude, num10 * n30)
																					end)
																				end

																				flag55.mark = magnitude
																				flag55.clock = 0
																			end
																		else
																			flag55.mark = nil
																		end

																		pcall(function()
																			part2.AssemblyLinearVelocity = assemblyLinearVelocity
																			part2.AssemblyAngularVelocity = Vector3.zero
																		end)

																		return magnitude <= 0.5
																	end

																	func64 = function()
																		local value44 = num5.Root()

																		if value44 then
																			pcall(function()
																				value44.AssemblyLinearVelocity = Vector3.zero
																				value44.AssemblyAngularVelocity = Vector3.zero
																			end)
																		end
																	end

																	local connection7 = nil
																	local tbl57 = {}

																	func65 = function()
																		value43 = nil

																		if connection6 then
																			connection6:Disconnect()
																			connection6 = nil
																		end

																		if connection7 then
																			connection7:Disconnect()
																			connection7 = nil
																		end
																	end

																	func66 = function()
																		local num12 = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
																		return num12 ~= nil and num12 > workspace:GetServerTimeNow()
																	end

																	local flag56 = false

																	local function func83()
																		if flag56 then
																			return true
																		end
																		return true
																	end

																	func67 = function(flag57, flag58)
																		value43 = flag57
																		flag56 = flag58 == true
																		if connection6 or not flag57 then
																			return
																		end
																		tbl57 = {}

																		connection6 = RunService.Heartbeat:Connect(function()
																			if not value43 or func83() or func66() or num5.AntiGuard.Busy then
																				return
																			end
																			local flag59 = num5.Root()
																			if not flag59 then
																				return
																			end

																			pcall(function()
																				local rotation = flag59.CFrame.Rotation
																				flag59.CFrame = CFrame.new(value43) * rotation
																				flag59.AssemblyLinearVelocity = Vector3.zero
																				flag59.AssemblyAngularVelocity = Vector3.zero
																			end)
																		end)

																		connection7 = RunService.PreSimulation:Connect(function(deltaTime)
																			if not value43 or not func83() or func66() or num5.AntiGuard.Busy then
																				return
																			end
																			local value45 = num5.Root()

																			if value45 then
																				func78(value45, value43, 400, deltaTime, tbl57)
																			end
																		end)
																	end
																end
															end

															do
																func10(func65)

																func68 = function()
																	func65()
																	num5.EndFlight()
																	num5.GodMode(false)
																	local character = localPlayer.Character
																	character = character and character:FindFirstChildOfClass("Humanoid")

																	if character then
																		character.PlatformStand = false
																	end
																end

																do
																	local n29 = 1.5
																	n24 = 0.6

																	local function func84(param36, param37)
																		local x = param37.X
																		return (Vector3.new(param36.X, 0, param36.Z) - Vector3.new(x, 0, param37.Z)).Magnitude
																	end

																	local function func85(obj21)
																		local ok, result = pcall(function()
																			return obj21:GetPivot().Position
																		end)

																		return ok and result or nil
																	end

																	func69 = function(part3, flag60, param38)
																		local position3 = func84(part3.Position, param38)
																		local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")

																		if areaEggSlotsClient then
																			for _, child in ipairs(areaEggSlotsClient:GetChildren()) do
																				if child:IsA("Model") and child.Name ~= flag60 then
																					local flag61 = func85(child)
																					if flag61 and func84(flag61, part3.Position) + n29 < position3 then
																						return false
																					end
																				end
																			end
																		end

																		for _, child in ipairs(workspace:GetChildren()) do
																			if child:IsA("Model") and child.Name ~= flag60 and #child.Name == 32 and child:FindFirstChild("Hitbox") then
																				local flag62 = func85(child)
																				if flag62 and func84(flag62, part3.Position) + n29 < position3 then
																					return false
																				end
																			end
																		end

																		return true
																	end

																	num5.Steal.WrongEgg = function(carryUid)
																		local steal = num5.Steal
																		if type(carryUid) ~= "string" or not steal.Carrying or steal.CarryUid == carryUid then
																			return false
																		end
																		local eggState = tbl2.EggState

																		if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																			pcall(eggState.DropFieldEgg, "PlayerRequest")
																		end

																		local n30 = 0

																		while steal.Carrying and n30 < 1 do
																			n30 += RunService.Heartbeat:Wait()
																		end

																		steal.Carrying = false
																		steal.CarryUid = carryUid
																		return true
																	end

																	func70 = function(param39, param40, flag63)
																		local n30 = flag63 or 14
																		local value46 = nil
																		local value47 = nil

																		for _, child in ipairs(workspace:GetChildren()) do
																			if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
																				local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

																				if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
																					local position4 = func84(child.Position, param40)

																					if position4 < n30 then
																						n30 = position4
																						value46 = carryAreaEgg
																						value47 = child
																					end
																				end
																			end
																		end

																		if not value46 or not value47 then
																			return nil
																		end

																		if type(param39) == "string" and not func69(value47, param39, param40) then
																			return nil
																		end
																		return value46, value47
																	end
																end
															end

															do
																func71 = function(param41)
																	local eggState = tbl2.EggState

																	if type(param41) == "string" and type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
																		pcall(eggState.CarryFieldEgg, param41)
																	end
																end

																do
																	local function func86()
																		local carryUid = num5.Steal.CarryUid
																		return type(carryUid) == "string" and carryUid or nil
																	end

																	local function func87(param42)
																		local result15 = func86()
																		if not result15 or type(param42) ~= "string" then
																			return true
																		end
																		return result15 == param42
																	end

																	local function func88(param43)
																		if type(param43) ~= "string" then
																			return false
																		end
																		local list7 = func63(false, true)
																		if #list7 == 0 then
																			return true
																		end

																		for _, item27 in ipairs(list7) do
																			if item27.Uid == param43 then
																				return true
																			end
																		end

																		return false
																	end

																	local function func89(param44)
																		local eggState = tbl2.EggState

																		if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																			pcall(eggState.DropFieldEgg, "PlayerRequest")
																		end

																		local n29 = 0

																		while num5.Steal.Carrying and n29 < 1 and not func57(param44) do
																			n29 += RunService.Heartbeat:Wait()
																		end
																	end

																	func72 = function(param45, param46)
																		local n29 = 0

																		while not num5.Steal.Carrying and n29 < n24 and not func57(param46) do
																			n29 += RunService.Heartbeat:Wait()
																		end

																		if not num5.Steal.Carrying then
																			str4 = "The egg never reached the hand"
																			return false
																		end

																		if func87(param45) then
																			return true
																		end
																		local result16 = func86()
																		if func88(result16) then
																			str4 = "Holding another egg that still matches, delivering it"
																			return true
																		end
																		str4 = "Wrong egg in hand, dropping it"
																		func89(param46)
																		return false
																	end
																end
															end

															do
																func73 = function(part4, param47)
																	local eggState = tbl2.EggState
																	local position = typeof(part4.CFrame) == "CFrame" and part4.CFrame.Position or nil
																	if not position then
																		return false
																	end
																	local n29 = 0
																	local huge = math.huge
																	local n30 = 0

																	while n29 < 1.5 do
																		if func57(param47) then
																			return false
																		end

																		if num5.Steal.Carrying and not num5.Steal.WrongEgg(part4.Uid) then
																			return true
																		end

																		if huge >= 0.06 then
																			local uid4 = func70(part4.Uid, position)

																			if uid4 then
																				pcall(function()
																					uid4.HoldDuration = 0
																				end)

																				n30 = 0

																				if typeof(fireproximityprompt) == "function" then
																					pcall(fireproximityprompt, uid4)
																				end
																			else
																				n30 += 1
																				if n30 >= 4 then
																					return false
																				end

																				if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
																					pcall(eggState.CarryFieldEgg, part4.Uid)
																				end
																			end

																			huge = 0
																		end

																		local result = RunService.Heartbeat:Wait()
																		n29 += result
																		huge += result
																	end

																	return num5.Steal.Carrying == true
																end

																do
																	local value48 = func6(function()
																		return ReplicatedStorage.Shared.Modules.Ragdoll
																	end)

																	func74 = function()
																		local character = localPlayer.Character

																		if type(value48) == "table" and type(value48.IsRagdolled) == "function" then
																			local ok, result = pcall(value48.IsRagdolled, character)
																			if ok and result == true then
																				return true
																			end
																		end
																		--[=[ Source Leak ]=] -- discord.gg/x7YbZeezpm

																		local num13 = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
																		if num13 and num13 > workspace:GetServerTimeNow() then
																			return true
																		end
																		character = character and character:FindFirstChildOfClass("Humanoid")
																		if character then
																			local state = character:GetState()
																			return state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown
																		end
																		return false
																	end
																end
															end

															do
																func75 = function(flag64, param48)
																	if num5.Steal.Carrying then
																		return true
																	end
																	local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
																	if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
																		return false
																	end
																	local n29 = 0

																	while n29 < 1 do
																		if func57(param48) or num5.Steal.Carrying then
																			return num5.Steal.Carrying == true
																		end
																		local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
																		ok = ok and type(result) == "table" and result.Records or nil

																		if type(ok) == "table" then
																			local flag65 = false

																			for _, value49 in pairs(ok) do
																				if type(value49) == "table" and value49.Uid == flag64 and (value49.State == "Slot" or value49.State == "Dropped") then
																					flag65 = true
																					break
																				end
																			end

																			if not flag65 then
																				return num5.Steal.Carrying == true
																			end
																		end

																		n29 += task.wait(0.3)
																	end

																	return num5.Steal.Carrying == true
																end

																do
																	local function func90(part5)
																		local flag66 = num5.Root()
																		local position = typeof(part5.CFrame) == "CFrame" and part5.CFrame.Position or nil
																		if not flag66 or not position then
																			return math.huge
																		end
																		return (flag66.Position - position).Magnitude
																	end

																	func76 = function(list8)
																		local huge = math.huge
																		local value50 = nil

																		for _, item28 in ipairs(list8) do
																			local flag67 = func90(item28)

																			if flag67 < huge then
																				huge = flag67
																				value50 = item28
																			end
																		end

																		return value50, huge
																	end
																end
															end

															n25 = 20
															n26 = 90
															n27 = 6

															func77 = function(num14, param49, flag68, flag69, flag70, callback3)
																func65()
																local flag71 = num5.Root()
																if not flag71 then
																	return false
																end
																local character = localPlayer.Character
																local position = flag71.Position
																local tbl58 = {}
																local position2 = nil
																local value51 = nil
																local value52 = nil
																local n29 = 0

																local function func91()
																	if flag69 ~= nil then
																		return true
																	end
																	return true
																end

																local function func92(param50)
																	n29 += param50
																	if func57(param49) then
																		value51 = false
																		return nil
																	end

																	if flag68 and not num5.Steal.Carrying then
																		value51 = false
																		value52 = "dropped"
																		return nil
																	end

																	if callback3 then
																		local result17 = callback3()

																		if result17 then
																			value51 = false
																			value52 = result17
																			return nil
																		end
																	end

																	local flag72 = num5.Root()

																	if not flag72 or n29 >= 25 or localPlayer.Character ~= character then
																		value51 = false
																		value52 = "respawned"
																		return nil
																	end

																	return flag72
																end

																local connection6 = RunService.Heartbeat:Connect(function(deltaTime)
																	if value51 ~= nil or func91() or num5.AntiGuard.Busy then
																		return
																	end
																	local flag73 = func92(deltaTime)
																	if not flag73 then
																		return
																	end

																	if n28 < (flag73.Position - position).Magnitude then
																		if flag70 then
																			value51 = false
																			value52 = "displaced"
																			return
																		end

																		position = flag73.Position
																	end

																	local n30 = (flag69 or 400) * (os.clock() < (num5.SafeCarry.SlowUntil or 0) and num5.SafeCarry.SlowFactor or 1)
																	local n31

																	if num5.SafeCarry.Enabled and num5.SafeCarry.Pace then
																		n31 = math.min(n30, num5.SafeCarry.Pace())
																	else
																		n31 = n30
																	end

																	local n32 = num14 - position
																	local n33 = n31 * deltaTime
																	local flag74 = n32.Magnitude <= math.max(n33, 0.05)
																	position = flag74 and num14 or position + n32.Unit * n33
																	local vector = Vector3.new(n32.X, 0, n32.Z)
																	local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or flag73.CFrame.Rotation

																	pcall(function()
																		flag73.CFrame = CFrame.new(position) * cframe
																		flag73.AssemblyLinearVelocity = Vector3.zero
																		flag73.AssemblyAngularVelocity = Vector3.zero
																	end)

																	if flag74 then
																		value51 = true
																	end
																end)

																local connection7 = RunService.PreSimulation:Connect(function(deltaTime)
																	if value51 ~= nil or not func91() or num5.AntiGuard.Busy then
																		return
																	end
																	local flag75 = func92(deltaTime)
																	if not flag75 then
																		return
																	end
																	local n30 = (flag69 or 400) * (os.clock() < (num5.SafeCarry.SlowUntil or 0) and num5.SafeCarry.SlowFactor or 1)
																	local n31

																	if num5.SafeCarry.Enabled and num5.SafeCarry.Pace then
																		n31 = math.min(n30, num5.SafeCarry.Pace())
																	else
																		n31 = n30
																	end

																	if flag70 and position2 and (flag75.Position - position2).Magnitude > n28 + n31 * deltaTime then
																		value51 = false
																		value52 = "displaced"
																		return
																	end

																	if func78(flag75, num14, n31, deltaTime, tbl58) then
																		value51 = true
																	end

																	position2 = flag75.Position
																	position = flag75.Position
																end)

																while value51 == nil do
																	RunService.Heartbeat:Wait()
																end

																connection6:Disconnect()
																connection7:Disconnect()

																if func91() and not value51 then
																	func64()
																end

																if value51 then
																	func67(num14, flag69 ~= nil)
																end

																return value51, value52
															end
														end

														do
															local tbl59 = {
																{
																	Path = { "GearGiver_Slap", "Podium" },
																	Offset = Vector3.new(-16.415, 21.072, -6.106),
																},
																{
																	Path = {
																		"World",
																		"Machines",
																		"RiftMachine",
																		"Rift",
																		"Meshes/VoidPortal_Cube.003",
																	},
																	Offset = Vector3.new(-26.776, 1.75, 18.665),
																},
																{
																	Path = {
																		"__OBJECTS",
																		"Machines",
																		"RiftMachine",
																		"Rift",
																		"Meshes/VoidPortal_Cube.003",
																	},
																	Offset = Vector3.new(-26.776, 1.75, 18.665),
																},
															}

															stealHome = function()
																for _, item29 in ipairs(tbl59) do
																	local obj22 = workspace

																	for _, item30 in ipairs(item29.Path) do
																		obj22 = obj22 and obj22:FindFirstChild(item30) or nil
																	end

																	if obj22 and obj22:IsA("BasePart") then
																		return obj22.CFrame:PointToWorldSpace(item29.Offset)
																	end
																end

																return Vector3.new(528.7, 70.57, -364.11)
															end
														end
													end

													local func93, func94, n28, func95, func96, func97, n29, func98, func99, huge
													local func100, func101

													do
														local func102

														do
															num5.StealHome = stealHome

															num5.InsideBase = function(obj)
																if not obj then
																	obj = num5.Root()
																	obj = obj and obj.Position
																end

																if obj == nil then
																	return false
																end
																local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																local areas = world and world:FindFirstChild("Areas")
																areas = areas and areas:FindFirstChild("SeparationLine")
																return obj.X < (areas and areas:IsA("BasePart") and areas.Position.X or 552)
															end

															func102 = function(num15)
																if num5.AntiGuard.Busy then
																	return false
																end
																local character = localPlayer.Character
																local flag76 = num5.Root()
																if not character or not flag76 then
																	return false
																end
																local rotation = flag76.CFrame.Rotation
																local cFrame = CFrame.new(num15) * rotation

																pcall(function()
																	character:PivotTo(cFrame)
																end)

																if (flag76.Position - num15).Magnitude > 3 then
																	pcall(function()
																		flag76.CFrame = cFrame
																	end)
																end

																for _, descendant in ipairs(character:GetDescendants()) do
																	if descendant:IsA("BasePart") then
																		pcall(function()
																			descendant.AssemblyLinearVelocity = Vector3.zero
																			descendant.AssemblyAngularVelocity = Vector3.zero
																		end)
																	end
																end

																return true
															end

															do
																local function func103(num16)
																	if num5.AntiGuard.Busy then
																		return
																	end
																	local character = localPlayer.Character
																	local num17 = num5.Root()
																	if not character or not num17 or not num16 then
																		return
																	end

																	if (num17.Position - num16).Magnitude > 6 then
																		func102(num16)
																		return
																	end

																	for _, descendant in ipairs(character:GetDescendants()) do
																		if descendant:IsA("BasePart") and descendant ~= num17 and (descendant.Position - num17.Position).Magnitude > 12 then
																			pcall(function()
																				descendant.CFrame = num17.CFrame
																				descendant.AssemblyLinearVelocity = Vector3.zero
																			end)
																		end
																	end
																end

																local function func104(param51, param52)
																	local n30 = 0

																	while true do
																		if not (n30 < n27) then
																			return not func57(param51)
																		else
																			if func57(param51) then
																				break
																			end
																			local character = localPlayer.Character
																			local result18 = func74()

																			if not result18 and character then
																				for _, descendant in ipairs(character:GetDescendants()) do
																					if descendant:IsA("Constraint") and string.find(descendant.Name, "RagdollConstraint", 1, true) then
																						result18 = true
																						break
																					end
																				end
																			end

																			if not result18 then
																				return not func57(param51)
																			end
																			func103(param52)
																			n30 += RunService.Heartbeat:Wait()
																		end
																	end

																	return false
																end

																func93 = function(childName2)
																	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																	world = world and world:FindFirstChild("Areas")
																	world = world and world:FindFirstChild("GuardAreas")
																	local areaId = world and childName2 and childName2.AreaId and world:FindFirstChild(childName2.AreaId)
																	return areaId and areaId:FindFirstChild("Guard") or nil
																end

																func94 = function(param53)
																	local obj23 = func93(param53)
																	return obj23 ~= nil and obj23:GetAttribute("GuardState") == "Sleeping"
																end

																n28 = 3

																func95 = function(part6)
																	local obj24 = func93(part6)
																	local position = typeof(part6.CFrame) == "CFrame" and part6.CFrame.Position or nil
																	if not obj24 or not position then
																		return nil, nil
																	end

																	local ok, result = pcall(function()
																		return obj24:GetPivot().Position
																	end)

																	if not ok then
																		return nil, nil
																	end
																	local vector = Vector3.new(position.X - result.X, 0, position.Z - result.Z)
																	if vector.Magnitude < 0.1 then
																		return nil, nil
																	end
																	local n30 = result + vector.Unit * n28
																	return Vector3.new(n30.X, position.Y + 3, n30.Z), result
																end

																func96 = function(param54, param55)
																	local tbl60 = { Landed = false, Destination = param55 }
																	local antiGuard = num5.AntiGuard
																	antiGuard.HitArms = antiGuard.HitArms + 1
																	num5.AntiGuard.HitArmedAt = os.clock()

																	tbl60.Link = localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
																		if tbl60.Landed or func57(param54) then
																			return
																		end
																		local num18 = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
																		if not num18 or num18 <= workspace:GetServerTimeNow() then
																			return
																		end
																		local num19 = num5.Root()
																		if not num19 then
																			return
																		end
																		tbl60.Landed = true
																		func65()
																		num5.SafeCarry.JumpDistance = (tbl60.Destination - num19.Position).Magnitude
																		num5.SafeCarry.JumpAt = os.clock()

																		pcall(function()
																			num19.CFrame = CFrame.new(tbl60.Destination)
																			num19.AssemblyLinearVelocity = Vector3.zero
																		end)
																	end)

																	tbl60.Stop = function()
																		if tbl60.Link then
																			tbl60.Link:Disconnect()
																			tbl60.Link = nil
																			num5.AntiGuard.HitArms = math.max(0, num5.AntiGuard.HitArms - 1)
																		end
																	end

																	return tbl60
																end

																func97 = function(param56, flag77, callback4)
																	local character = localPlayer.Character
																	character = character and character:FindFirstChildOfClass("Humanoid")

																	if character then
																		character.PlatformStand = false
																	end

																	local n30 = 0
																	local value53 = nil

																	while not flag77.Landed and n30 < n25 do
																		if func57(param56) then
																			break
																		end

																		if callback4 then
																			callback4(flag77)
																		end

																		if not num5.Steal.Carrying then
																			value53 = value53 or n30
																			if n30 - value53 > 1 then
																				break
																			end
																		end

																		n30 += RunService.Heartbeat:Wait()
																	end

																	flag77.Stop()
																	return flag77.Landed
																end

																n29 = 20

																func98 = function(part7, param57, param58, param59)
																	local position = typeof(part7.CFrame) == "CFrame" and part7.CFrame.Position or nil
																	if not position then
																		return false
																	end
																	local n30 = 0
																	local huge2 = math.huge

																	while n30 < param58 do
																		if func57(param57) then
																			return false
																		end

																		if num5.Steal.Carrying and not num5.Steal.WrongEgg(part7.Uid) then
																			return true
																		end

																		if huge2 >= 0.1 then
																			local uid5 = func70(part7.Uid, position)

																			if uid5 then
																				pcall(function()
																					uid5.HoldDuration = 0
																				end)

																				if typeof(fireproximityprompt) == "function" then
																					pcall(fireproximityprompt, uid5)
																				end
																			else
																				func71(part7.Uid)
																			end

																			huge2 = 0
																		end

																		if param59 then
																			func103(param59)
																		end

																		local result = RunService.Heartbeat:Wait()
																		n30 += result
																		huge2 += result
																	end

																	return num5.Steal.Carrying == true
																end

																func99 = function(part8, param60, param61, part9)
																	local position = typeof(part8.CFrame) == "CFrame" and part8.CFrame.Position or nil
																	if not position then
																		return false
																	end
																	local n30 = position + Vector3.new(0, 3, 0)
																	local character = localPlayer.Character
																	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

																	if humanoid and character:FindFirstChildWhichIsA("Tool") then
																		pcall(function()
																			humanoid:UnequipTools()
																		end)
																	end

																	if param61 then
																		func67(n30, true)
																		str4 = "Waiting to stand up"
																		if not func104(param60, n30) then
																			return false
																		end

																		if num5.SafeCarry.Enabled and part9 == nil and num5.SafeCarry.Settle then
																			if not num5.SafeCarry.Settle(param60, part8) then
																				return false
																			end
																		end
																	else
																		str4 = "Jumping to the egg"
																		local num20 = num5.Root()

																		if num20 and (n30 - num20.Position).Magnitude <= n26 then
																			pcall(function()
																				local rotation = num20.CFrame.Rotation
																				num20.CFrame = CFrame.new(n30) * rotation
																				num20.AssemblyLinearVelocity = Vector3.zero
																				num20.AssemblyAngularVelocity = Vector3.zero
																			end)
																		elseif not func77(n30, param60, nil, 400) then
																			return false
																		end
																	end

																	if func57(param60) then
																		return false
																	end
																	local flag78 = part9 and typeof(part9.CFrame) == "CFrame"
																	local value54 = nil

																	if flag78 then
																		value54 = func96(param60, part9.CFrame.Position + Vector3.new(0, 3, 0))
																	end

																	local str6 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
																	local uid6 = type(part8.Uid) == "string" and string.sub(part8.Uid, 1, #str6) == str6 and string.match(part8.Uid, "_([%w ]+:Slot_%d+)$") or nil
																	part9 = part9 and uid6
																	local flag79 = false

																	if part9 then
																		local eggState = tbl2.EggState

																		if type(eggState) == "table" and type(eggState.CarryFieldEgg) == "function" then
																			str4 = "Taking the starter egg"

																			task.spawn(function()
																				pcall(eggState.CarryFieldEgg, part8.Uid, uid6)
																			end)

																			local n31 = 0

																			while not num5.Steal.Carrying and n31 < 0.8 do
																				if func57(param60) then
																					return false
																				end
																				n31 += RunService.Heartbeat:Wait()
																			end

																			flag79 = num5.Steal.Carrying == true
																		end
																	end

																	if not flag79 then
																		str4 = "Taking the egg"
																		flag79 = func73(part8, param60)

																		if not flag79 and not func57(param60) then
																			func77(n30, param60, nil, 400)
																			flag79 = func73(part8, param60)
																		end
																	end

																	if not flag79 and not func75(part8.Uid, param60) then
																		if value54 then
																			value54.Stop()
																		end

																		tbl50[part8.Uid] = os.clock() + 20
																		str4 = "That egg would not come free"
																		return false
																	end

																	if value54 then
																		local reGuardPatrolForestStrike = networking:FindFirstChild("RE/GuardPatrol/ForestStrike")
																		local obj25 = func93(part8) or func93({ AreaId = "Forest" })
																		local humanoidRootPart = obj25 and obj25:FindFirstChild("HumanoidRootPart")

																		if reGuardPatrolForestStrike and reGuardPatrolForestStrike:IsA("RemoteEvent") and humanoidRootPart then
																			str4 = "Calling the guard strike"

																			pcall(function()
																				reGuardPatrolForestStrike:FireServer({ EggUid = part8.Uid, GuardCFrame = humanoidRootPart.CFrame })
																			end)
																		end
																	end

																	num5.Steal.LastFinishedAt = os.clock()
																	return true, value54
																end
															end
														end

														huge = math.huge

														do
															local huge2 = math.huge

															local function func105(num21, param62, param63)
																local value55 = nil
																local value56 = nil

																for _, child in ipairs(workspace:GetChildren()) do
																	if child.Name == "SmartPromptPart" and child:IsA("BasePart") then
																		local carryAreaEgg = child:FindFirstChild("CarryAreaEgg")

																		if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") then
																			local magnitude = (child.Position - num21).Magnitude

																			if magnitude < param62 then
																				param62 = magnitude
																				value55 = carryAreaEgg
																				value56 = child
																			end
																		end
																	end
																end

																if value55 and value56 and type(param63) == "string" and not func69(value56, param63, num21) then
																	return nil
																end
																return value55, value56
															end

															local function func106(childName3)
																local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
																local obj26 = workspace:FindFirstChild(childName3) or areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(childName3)
																if not obj26 then
																	return nil
																end

																local ok, result = pcall(function()
																	return obj26:GetPivot().Position
																end)

																return ok and result or nil
															end

															func100 = function(flag80)
																local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")
																if not rfEggWorldAskFieldEggSnapshot or not rfEggWorldAskFieldEggSnapshot:IsA("RemoteFunction") then
																	return nil
																end
																local ok, result = pcall(rfEggWorldAskFieldEggSnapshot.InvokeServer, rfEggWorldAskFieldEggSnapshot)
																local records = ok and type(result) == "table" and result.Records or nil
																if type(records) ~= "table" then
																	return nil
																end

																for _, record in pairs(records) do
																	if type(record) == "table" and record.Uid == flag80 and typeof(record.BottomCFrame) == "CFrame" then
																		return record.BottomCFrame.Position, true
																	end
																end

																return nil, true
															end

															local function func107(childName4)
																local obj27 = workspace:FindFirstChild(childName4)
																if not obj27 then
																	return false
																end

																for _, descendant in ipairs(obj27:GetDescendants()) do
																	if descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("RigidConstraint") then
																		local ok, result, result2 = pcall(function()
																			return descendant.Part0, descendant.Part1
																		end)

																		if ok then
																			for _, item31 in ipairs({ result, result2 }) do
																				if typeof(item31) == "Instance" and not item31:IsDescendantOf(obj27) then
																					local model = item31:FindFirstAncestorOfClass("Model")
																					if model and model ~= localPlayer.Character and Players:GetPlayerFromCharacter(model) then
																						return true
																					end
																				end
																			end
																		end
																	end
																end

																return false
															end

															func101 = function(param64, param65)
																local state = 1
																local value57, carryUid, n30, vector, connection6, n31, n32, huge3, num22, num23, n33, huge4, flag81, num24, num25, value58, value59, now, flag82, n34, flag83, value60

																while true do
																	if state == 1 then
																		value57 = param64
																		carryUid = param65

																		if carryUid then
																			state = 3
																		else
																			state = 2
																		end
																	elseif state == 2 then
																		carryUid = num5.Steal.CarryUid
																		state = 3
																	elseif state == 3 then
																		if type(carryUid) ~= "string" then
																			state = 50
																		else
																			state = 4
																		end
																	elseif state == 4 then
																		func65()
																		str4 = "Following the egg"
																		n30 = nil
																		vector = Vector3.zero

																		connection6 = RunService.PreSimulation:Connect(function(deltaTime)
																			local num26 = num5.Root()
																			if not num26 or not n30 or num5.Steal.Carrying or func57(value57) then
																				return
																			end

																			if func66() then
																				if not num5.SafeCarry.Enabled and (num26.Position - n30).Magnitude > 2 then
																					func102(n30)
																				end

																				return
																			end

																			local n35 = math.max(deltaTime, 0.0041666666666666666)
																			local n36 = vector + (n30 - num26.Position) / math.max(0.08, n35)
																			local enabled = num5.SafeCarry.Enabled and num5.SafeCarry.Pace() or n11 + vector.Magnitude

																			if n36.Magnitude > enabled then
																				n36 = n36.Unit * enabled
																			end

																			local assemblyLinearVelocity = n36 + Vector3.new(0, workspace.Gravity * n35 * 0.5, 0)

																			pcall(function()
																				num26.AssemblyLinearVelocity = assemblyLinearVelocity
																				num26.AssemblyAngularVelocity = Vector3.zero
																			end)
																		end)

																		n31 = 0
																		n32 = 0
																		huge3 = math.huge
																		num22 = nil
																		num23 = nil
																		n33 = 0
																		huge4 = math.huge
																		state = 5
																	elseif state == 5 then
																		flag81 = false

																		if not (n31 < huge2) then
																			state = 47
																		else
																			state = 6
																		end
																	elseif state == 6 then
																		if func57(value57) then
																			state = 47
																		else
																			state = 7
																		end
																	elseif state == 7 then
																		if num5.Steal.Carrying then
																			state = 8
																		else
																			state = 11
																		end
																	elseif state == 8 then
																		if num5.Steal.WrongEgg(carryUid) then
																			state = 10
																		else
																			state = 9
																		end
																	elseif state == 9 then
																		flag81 = true
																		state = 47
																	elseif state == 10 then
																		str4 = "Picked up the wrong egg, dropped it"
																		state = 11
																	elseif state == 11 then
																		num24 = num5.Root()

																		if not num24 then
																			state = 47
																		else
																			state = 12
																		end
																	elseif state == 12 then
																		num25 = func106(carryUid)

																		if num25 then
																			state = 21
																		else
																			state = 13
																		end
																	elseif state == 13 then
																		if huge3 >= 0.5 then
																			state = 14
																		else
																			state = 22
																		end
																	elseif state == 14 then
																		value58, value59 = func100(carryUid)

																		if value58 then
																			state = 20
																		else
																			state = 15
																		end
																	elseif state == 15 then
																		huge3 = 0

																		if value59 then
																			state = 17
																		else
																			state = 16
																		end
																	elseif state == 16 then
																		num25 = value58
																		state = 22
																	elseif state == 17 then
																		n32 += 1

																		if not (n32 >= 4) then
																			state = 19
																		else
																			state = 18
																		end
																	elseif state == 18 then
																		str4 = "The egg is gone"
																		state = 47
																	elseif state == 19 then
																		num25 = value58
																		state = 22
																	elseif state == 20 then
																		n32 = 0
																		huge3 = 0
																		num25 = value58
																		state = 22
																	elseif state == 21 then
																		n32 = 0
																		state = 22
																	elseif state == 22 then
																		if num25 then
																			state = 23
																		else
																			state = 32
																		end
																	elseif state == 23 then
																		now = os.clock()

																		if num22 then
																			state = 25
																		else
																			state = 24
																		end
																	elseif state == 24 then
																		flag82 = num22
																		state = 26
																	elseif state == 25 then
																		flag82 = num23
																		state = 26
																	elseif state == 26 then
																		if flag82 then
																			state = 27
																		else
																			state = 28
																		end
																	elseif state == 27 then
																		flag82 = now > num23
																		state = 28
																	elseif state == 28 then
																		if flag82 then
																			state = 29
																		else
																			state = 31
																		end
																	elseif state == 29 then
																		n34 = (num25 - num22) / math.max(now - num23, 0.0041666666666666666)

																		if not (n34.Magnitude < 3000) then
																			state = 31
																		else
																			state = 30
																		end
																	elseif state == 30 then
																		vector = vector:Lerp(n34, 0.3)
																		state = 31
																	elseif state == 31 then
																		n30 = num25 + Vector3.new(0, 3, 0)
																		num22 = num25
																		num23 = now
																		state = 32
																	elseif state == 32 then
																		if not (n33 >= 0.4) then
																			state = 36
																		else
																			state = 33
																		end
																	elseif state == 33 then
																		if func107(carryUid) then
																			state = 35
																		else
																			state = 34
																		end
																	elseif state == 34 then
																		str4 = "Egg dropped, taking it back"
																		n33 = 0
																		state = 36
																	elseif state == 35 then
																		str4 = "Another player has the egg, following it until it drops"
																		n33 = 0
																		state = 36
																	elseif state == 36 then
																		if n30 then
																			state = 38
																		else
																			state = 37
																		end
																	elseif state == 37 then
																		flag83 = n30
																		state = 39
																	elseif state == 38 then
																		flag83 = (n30 - num24.Position).Magnitude <= n29
																		state = 39
																	elseif state == 39 then
																		if flag83 then
																			state = 40
																		else
																			state = 41
																		end
																	elseif state == 40 then
																		flag83 = huge4 >= 0.1
																		state = 41
																	elseif state == 41 then
																		if flag83 then
																			state = 42
																		else
																			state = 46
																		end
																	elseif state == 42 then
																		value60 = func105(n30 - Vector3.new(0, 3, 0), 6, carryUid)

																		if value60 then
																			state = 44
																		else
																			state = 43
																		end
																	elseif state == 43 then
																		task.spawn(func71, carryUid)
																		huge4 = 0
																		state = 46
																	elseif state == 44 then
																		pcall(function()
																			value60.HoldDuration = 0
																		end)

																		huge4 = 0

																		if typeof(fireproximityprompt) ~= "function" then
																			state = 46
																		else
																			state = 45
																		end
																	elseif state == 45 then
																		pcall(fireproximityprompt, value60)
																		state = 46
																	elseif state == 46 then
																		local result = RunService.Heartbeat:Wait()
																		n31 += result
																		huge4 += result
																		huge3 += result
																		n33 += result
																		state = 5
																	elseif state == 47 then
																		connection6:Disconnect()
																		func64()

																		if flag81 then
																			state = 49
																		else
																			state = 48
																		end
																	elseif state == 48 then
																		flag81 = num5.Steal.Carrying == true
																		state = 49
																	elseif state == 49 then
																		return flag81
																	elseif state == 50 then
																		return false
																	end
																end
															end
														end
													end

													local func108, tbl61, n30, func109

													do
														func108 = function(part10, param66)
															local position = typeof(part10.CFrame) == "CFrame" and part10.CFrame.Position or nil
															if not position then
																return false
															end

															if num5.InsideBase() and not num5.InsideBase(position) then
																local result19 = stealHome()

																if result19 then
																	str4 = "Leaving the base through the safe zone"
																	if not func77(result19 + Vector3.new(0, 3, 0), param66, nil, 400) then
																		return false
																	end
																end
															end

															str4 = "Flying to the egg"
															if not func77(position + Vector3.new(0, 3, 0), param66, nil, 400) then
																return false
															end
															str4 = "Taking the egg"
															local flag84 = func98(part10, param66, 0.6, nil)

															if not flag84 and not func57(param66) then
																flag84 = func73(part10, param66)
															end

															if not flag84 and not func75(part10.Uid, param66) then
																tbl50[part10.Uid] = os.clock() + 20
																return false
															end
															num5.Steal.LastFinishedAt = os.clock()
															return true
														end

														tbl61 = { Uid = nil, Freed = nil, Token = nil }
														n30 = 3

														do
															local function func110()
																local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																world = world and world:FindFirstChild("Areas")
																world = world and world:FindFirstChild("GuardAreas")
																local num27 = num5.Root()
																if not world or not num27 then
																	return nil
																end
																local userId3 = tostring(localPlayer.UserId)
																local carryAreaId = num5.Steal.CarryAreaId and func93({ AreaId = tostring(num5.Steal.CarryAreaId) }) or nil
																local huge2 = math.huge
																local value61 = nil

																for _, child in ipairs(world:GetChildren()) do
																	local guard = child:FindFirstChild("Guard")

																	if guard then
																		if tostring(guard:GetAttribute("TargetPlayer")) == userId3 or tostring(guard:GetAttribute("WakeTargetPlayer")) == userId3 then
																			return guard
																		end

																		local ok, result = pcall(function()
																			return guard:GetPivot().Position
																		end)

																		if ok then
																			local magnitude = (result - num27.Position).Magnitude

																			if magnitude < huge2 then
																				value61 = guard
																				huge2 = magnitude
																			end
																		end
																	end
																end

																return carryAreaId or value61
															end

															func109 = function(param67, param68, num28)
																local result20 = func110()
																if not result20 then
																	return false
																end
																local flag85 = func96(param67, num28 + Vector3.new(0, 3, 0))
																local n31 = 0

																while true do
																	if not flag85.Landed and n31 < n25 and not func57(param67) then
																		local ok, result = pcall(function()
																			return result20:GetPivot().Position
																		end)

																		local num29 = num5.Root()

																		if not (not ok or not num29) then
																			if n28 + 5 < (result - num29.Position).Magnitude then
																				local vector = Vector3.new(num29.Position.X - result.X, 0, num29.Position.Z - result.Z)
																				local n32 = result + (vector.Magnitude > 0.1 and vector.Unit * n28 or Vector3.zero)

																				func77(Vector3.new(n32.X, result.Y + 3, n32.Z), param67, nil, 400, true, function()
																					if flag85.Landed then
																						return "hit"
																					end
																					return nil
																				end)
																			end

																			n31 += RunService.Heartbeat:Wait()
																			continue
																		end
																	end

																	break
																end

																flag85.Stop()
																if not flag85.Landed then
																	return false
																end
																return func101(param67, param68)
															end
														end
													end

													num5.SafeCarry.Dangers = {}
													num5.SafeCarry.DangerAt = 0

													num5.SafeCarry.RefreshDangers = function()
														local safeCarry = num5.SafeCarry
														local dangerAt = safeCarry.DangerAt
														if os.clock() - dangerAt < 1 then
															return safeCarry.Dangers
														end
														safeCarry.DangerAt = os.clock()
														local dangers = {}

														local function func111(part11)
															local ok, result, result2 = pcall(function()
																if part11:IsA("Model") then
																	return part11:GetBoundingBox()
																end

																if part11:IsA("BasePart") then
																	return part11.CFrame, part11.Size
																end
															end)

															if ok and result and result2 then
																local abs = math.abs
																local z = result2.Z
																local n31 = Vector3.new(math.abs(result2.X), 0, abs(z)) * 0.5
																local num30 = (result - result.Position):VectorToWorldSpace(n31)
																local x = n31.X
																local z2 = n31.Z
																local n32 = math.max(math.abs(num30.X), x, z2)
																local x2 = n31.X
																local z3 = n31.Z
																local n33 = math.max(math.abs(num30.Z), x2, z3)

																table.insert(dangers, {
																	MinX = result.Position.X - n32,
																	MaxX = result.Position.X + n32,
																	MinZ = result.Position.Z - n33,
																	MaxZ = result.Position.Z + n33,
																	Name = part11.Name,
																})
															end
														end

														local function func112(flag86)
															if flag86 == "ScrambleLocalVisuals" or flag86 == "DrScrambleEvent" then
																return false
															end
															local lowered3 = string.lower(flag86)
															return string.find(lowered3, "portal", 1, true) or string.find(lowered3, "teleport", 1, true) or string.find(lowered3, "mech", 1, true) or string.find(lowered3, "arena", 1, true) or string.find(lowered3, "scramble", 1, true)
														end

														for _, child in ipairs(workspace:GetChildren()) do
															if (child:IsA("Model") or child:IsA("BasePart") or child:IsA("Folder")) and func112(child.Name) then
																if child:IsA("Folder") then
																	for _, child2 in ipairs(child:GetChildren()) do
																		func111(child2)
																	end
																else
																	func111(child)
																end
															end
														end

														local world = workspace:FindFirstChild("World")
														world = world and world:FindFirstChild("Build")

														if world then
															for _, child in ipairs(world:GetChildren()) do
																if func112(child.Name) then
																	for _, child2 in ipairs(child:GetChildren()) do
																		func111(child2)
																	end
																end
															end
														end

														safeCarry.Dangers = dangers
														return dangers
													end

													num5.SafeCarry.Avoid = function(obj, param69)
														for _, refreshDanger in ipairs(num5.SafeCarry.RefreshDangers()) do
															local n31 = refreshDanger.MinX - 12
															local n32 = refreshDanger.MaxX + 12
															local n33 = refreshDanger.MinZ - 12
															local n34 = refreshDanger.MaxZ + 12
															local value62, value63, value64 = ipairs({ { obj.X, param69.X - obj.X, n31, n32 }, { obj.Z, param69.Z - obj.Z, n33, n34 } })
															local flag87 = true
															local n35 = 0
															local n36 = 1

															for _, value65 in value62, value63, value64 do
																local first2 = value65[1]
																local second1 = value65[2]
																local third1 = value65[3]
																local entry3 = value65[4]

																if math.abs(second1) < 1e-06 then
																	if first2 < third1 or first2 > entry3 then
																		flag87 = false
																	end
																else
																	local n37 = (third1 - first2) / second1
																	local n38 = (entry3 - first2) / second1
																	local value66, value67

																	if n37 > n38 then
																		value66 = n38
																		value67 = n37
																	else
																		value66 = n37
																		value67 = n38
																	end

																	local n39 = math.max(n35, value66)
																	local n40 = math.min(n36, value67)

																	if n39 > n40 then
																		flag87 = false
																		n35 = n39
																		n36 = n40
																	else
																		n35 = n39
																		n36 = n40
																	end
																end
															end

															if flag87 and not (obj.X >= n31 and obj.X <= n32 and obj.Z >= n33 and obj.Z <= n34) then
																local n37 = n33 - 2
																local n38 = n34 + 2
																local num31 = math.abs(obj.Z - n37) <= math.abs(obj.Z - n38) and n37 or n38

																if num31 < -440 or num31 > -290 then
																	num31 = num31 == n37 and n38 or n37
																end

																local num32 = math.abs(obj.X - n31) <= math.abs(obj.X - n32) and n31 or n32

																if math.abs(obj.Z - num31) < 3 then
																	num32 = math.abs(param69.X - n31) <= math.abs(param69.X - n32) and n31 or n32
																end

																return Vector3.new(num32, param69.Y, num31), refreshDanger.Name
															end
														end

														return param69, nil
													end

													num5.SafeCarry.NewHuman = function(flag88)
														local safeCarry = num5.SafeCarry
														local laneOffset = safeCarry.LaneOffset
														local num33

														num33 = {
															Clock = 0,
															Factor = 1,
															Target = 1,
															NextShift = 0,
															Phase = math.random() * 3.1415926535897931 * 2,
															Period = 2 + math.random() * 2.5,
															PauseUntil = 0,
															Lane = (math.random() * 2 - 1) * laneOffset,
															Step = function(num34, flag89, flag90)
																num33.Clock = num33.Clock + num34

																if num33.NextShift <= num33.Clock then
																	num33.NextShift = num33.Clock + 0.5 + math.random()
																	local n31 = math.max(safeCarry.SpeedJitter, 0)

																	if flag88 then
																		num33.Target = 1 - math.random() * n31
																	else
																		num33.Target = 1 + (math.random() * 2 - 1) * n31
																	end
																end

																num33.Factor = num33.Factor + (num33.Target - num33.Factor) * math.min(num34 * 3, 1)
																local wobble = safeCarry.Wobble
																local n31 = math.sin(num33.Clock * 2 * 3.1415926535897931 / num33.Period + num33.Phase) * wobble
																flag90 = flag90 and flag89 and safeCarry.JumpsPerMinute > 0

																if flag90 then
																	local n32 = safeCarry.JumpsPerMinute / 60 * num34
																	flag90 = math.random() < n32
																end

																if flag90 then
																	pcall(function()
																		flag89.Jump = true
																	end)
																end

																local flag91 = false

																if not flag88 then
																	if num33.Clock < num33.PauseUntil then
																		flag91 = true
																	else
																		local flag92 = safeCarry.PausesPerMinute > 0

																		if flag92 then
																			local n32 = safeCarry.PausesPerMinute / 60 * num34
																			flag92 = math.random() < n32
																		end

																		if flag92 then
																			num33.PauseUntil = num33.Clock + 0.3 + math.random() * 0.9
																			flag91 = true
																		end
																	end
																end

																return num33.Factor, num33.Lane + n31, flag91
															end,
														}

														return num33
													end

													num5.SafeCarry.React = function(param70, param71)
														local n31 = math.max(0, math.min(param70, param71))
														local n32 = math.max(param70, param71, 0)
														return n31 + math.random() * (n32 - n31)
													end

													num5.SafeCarry.RunTo = function(obj, param72)
														local safeCarry = num5.SafeCarry
														local position = typeof(obj.CFrame) == "CFrame" and obj.CFrame.Position or nil
														if not position then
															return false
														end
														func65()
														local character = localPlayer.Character
														local humanoid = character and character:FindFirstChildOfClass("Humanoid")

														if humanoid then
															humanoid.PlatformStand = false

															if character:FindFirstChildWhichIsA("Tool") then
																pcall(function()
																	humanoid:UnequipTools()
																end)
															end
														end

														local num35 = safeCarry.NewHuman(false)
														local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
														world = world and world:FindFirstChild("Areas")
														world = world and world:FindFirstChild("SeparationLine")
														local x = world and world:IsA("BasePart") and world.Position.X or 552
														local result21 = stealHome()
														local flag93 = num5.Root()
														local str7 = "field"
														local z = flag93 and flag93.Position.Z or position.Z

														if flag93 and result21 and flag93.Position.X < x - 2 then
															local z2 = result21.Z

															if (Vector3.new(flag93.Position.X, 0, flag93.Position.Z) - Vector3.new(result21.X, 0, result21.Z)).Magnitude > 20 then
																str7 = "safe"
															end

															z = z2
														end

														local n31 = math.clamp(z + num35.Lane, -425, -300)
														local n32 = position.Y + 3

														local function func113(num36)
															local flag94 = num5.Root()
															local character2 = localPlayer.Character
															local flag95 = not flag94 or not character2 or math.abs(flag94.Position.Y - num36) < 1

															if not flag95 then
																local snapLimit = safeCarry.SnapLimit
																flag95 = math.abs(flag94.Position.Y - num36) > snapLimit
															end

															if flag95 then
																return false
															end

															pcall(function()
																local rotation = flag94.CFrame.Rotation
																character2:PivotTo(CFrame.new(Vector3.new(flag94.Position.X, num36, flag94.Position.Z)) * rotation)
																flag94.AssemblyLinearVelocity = Vector3.new(flag94.AssemblyLinearVelocity.X, 0, flag94.AssemblyLinearVelocity.Z)
															end)

															return true
														end

														local function func114()
															if safeCarry.RunHeight <= 0.5 then
																return
															end
															func113(n32 + safeCarry.RunHeight)
														end

														if str7 == "field" then
															func114()
														end

														local now = os.clock()
														local now2 = os.clock()
														local now3 = os.clock()
														local position2 = flag93 and flag93.Position or nil

														local function func115(part12, param73, num37, flag96)
															local vector = Vector3.new(param73.X - part12.Position.X, 0, param73.Z - part12.Position.Z)
															local magnitude = vector.Magnitude
															local unit = magnitude > 0.01 and vector.Unit or Vector3.zero

															if safeCarry.RunHeight > 0.5 and str7 == "field" and not flag96 then
																local runSpeed = safeCarry.RunSpeed
																local n33 = math.max(num5.WalkSpeed() * runSpeed * num37, 8)
																local n34 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
																local magnitude2 = Vector3.new(position.X - part12.Position.X, 0, position.Z - part12.Position.Z).Magnitude

																if magnitude2 <= 3 then
																	if func113(n32) then
																		return
																	end
																end

																local n35 = magnitude2 <= 3 and n32 or n32 + safeCarry.RunHeight
																if math.abs(n35 - part12.Position.Y) > 2 and func113(n35) then
																	return
																end
																local n36 = math.clamp((n35 - part12.Position.Y) / 0.12, -n33 * n34, n33 * n34)
																local n37 = unit * math.min(math.sqrt(math.max(n33 * n33 - n36 * n36, 0)), magnitude / 0.05)

																pcall(function()
																	part12.AssemblyLinearVelocity = Vector3.new(n37.X, n36, n37.Z)
																end)
																-- join us: https://discord.gg/x7YbZeezpm

																return
															end

															pcall(function()
																if flag96 or magnitude <= 0.01 then
																	if humanoid then
																		if safeCarry.RunStyle == "Walk" then
																			humanoid:MoveTo(part12.Position)
																		end

																		humanoid:Move(Vector3.zero, false)
																	end

																	if safeCarry.RunStyle ~= "Walk" then
																		part12.AssemblyLinearVelocity = Vector3.new(0, part12.AssemblyLinearVelocity.Y, 0)
																	end
																elseif safeCarry.RunStyle == "Walk" then
																	if humanoid then
																		humanoid:MoveTo(part12.Position + unit * math.min(magnitude, 30))
																	end
																else
																	local runSpeed = safeCarry.RunSpeed
																	local n33 = unit * math.min(math.max(num5.WalkSpeed() * runSpeed * num37, 8), magnitude / 0.05)
																	part12.AssemblyLinearVelocity = Vector3.new(n33.X, part12.AssemblyLinearVelocity.Y, n33.Z)

																	if safeCarry.RunAnimate and humanoid then
																		humanoid:Move(unit, false)
																	end
																end
															end)
														end

														while os.clock() - now < 240 do
															if func57(param72) then
																return false
															end
															local num38 = num5.Root()
															if not num38 then
																return false
															end
															local now4 = os.clock()
															local n33 = math.max(now4 - now2, 0.0041666666666666666)
															local vector = Vector3.new(position.X - num38.Position.X, 0, position.Z - num38.Position.Z)
															if str7 == "field" and vector.Magnitude <= 2.5 and (safeCarry.RunHeight <= 0.5 or num38.Position.Y - n32 < 4) then
																break
															end
															local value68, num39, flag97 = num35.Step(n33, humanoid, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)

															if vector.Magnitude <= 15 then
																flag97 = false
															end

															local vector2 = position

															if str7 == "safe" and result21 then
																if (Vector3.new(result21.X, 0, result21.Z) - Vector3.new(num38.Position.X, 0, num38.Position.Z)).Magnitude <= 6 then
																	str7 = "field"
																	func114()
																end

																str4 = "Walking out to the safe zone"
																vector2 = result21
															else
																if not safeCarry.StraightRun and safeCarry.RunHeight <= 0.5 and math.abs(position.X - num38.Position.X) > 25 then
																	vector2 = Vector3.new(position.X, position.Y, math.clamp(n31 + num39, -425, -300))
																end

																str4 = string.format("Running to the egg, %d studs left", math.floor(vector.Magnitude + 0.5))
															end

															local value69, value70 = safeCarry.Avoid(num38.Position, vector2)

															if value70 then
																str4 = "Walking around " .. tostring(value70)
															end

															func115(num38, value69, value68, flag97)

															if now4 - now3 >= 1.5 then
																if not flag97 and position2 and (num38.Position - position2).Magnitude < 3 and humanoid then
																	pcall(function()
																		humanoid.Jump = true
																	end)
																end

																position2 = num38.Position
																now3 = now4
															end

															RunService.Heartbeat:Wait()
															now2 = now4
														end

														local value71 = num5.Root()

														if value71 then
															func115(value71, value71.Position, 1, true)
														end

														local vector = nil

														if value71 then
															local vector2 = Vector3.new(value71.Position.X - position.X, 0, value71.Position.Z - position.Z)
															local vector3 = vector2.Magnitude > 0.1 and vector2.Unit * 2 or Vector3.zero
															vector = Vector3.new(position.X + vector3.X, value71.Position.Y, position.Z + vector3.Z)
														end

														local connection6 = RunService.Heartbeat:Connect(function()
															local num40 = num5.Root()
															if not num40 or not vector or num5.Steal.Carrying or num5.AntiGuard.Busy then
																return
															end
															local vector2 = Vector3.new(vector.X - num40.Position.X, 0, vector.Z - num40.Position.Z)

															pcall(function()
																if vector2.Magnitude > 1.5 then
																	local rotation = num40.CFrame.Rotation
																	num40.CFrame = CFrame.new(vector.X, num40.Position.Y, vector.Z) * rotation
																end

																num40.AssemblyLinearVelocity = Vector3.new(0, math.min(num40.AssemblyLinearVelocity.Y, 0), 0)
															end)
														end)

														local function func116(param74)
															connection6:Disconnect()
															return param74
														end

														local obj28 = func93(obj)
														local now4 = os.clock()
														local num41 = safeCarry.React(safeCarry.ReactMin, safeCarry.ReactMax)

														while true do
															if func57(param72) then
																return (func116(false))
															else
																local n33 = os.clock() - now4
																local n34 = safeCarry.RunWait + num41
																local flag98 = not safeCarry.WaitGuard or not obj28 or obj28:GetAttribute("GuardState") == "Sleeping"
																if n33 >= n34 and (flag98 or n33 >= n34 + 15) then
																	break
																end
																str4 = n33 < n34 and string.format("Waiting before the grab, %.1fs", n34 - n33) or "Waiting for the guard to sleep"
																RunService.Heartbeat:Wait()
															end
														end

														str4 = "Taking the egg"
														local flag99 = func98(obj, param72, 0.8, nil)

														if not flag99 and not func57(param72) then
															flag99 = func73(obj, param72)
														end

														func116()
														if not flag99 then
															return false
														end
														num5.Steal.LastFinishedAt = os.clock()
														return true
													end

													num5.SafeCarry.Pace = function()
														local n31 = tonumber(num5.SafeCarry.RunSpeed) or 1
														return math.max(num5.WalkSpeed() * n31, 16)
													end

													num5.SafeCarry.Plan = function(param75, num42, num43)
														local safeCarry = num5.SafeCarry
														local character = localPlayer.Character

														if character then
															character:FindFirstChildOfClass("Humanoid")
														end

														local num44 = num5.WalkSpeed()
														num43 = num43 or safeCarry.Mult or 1

														if safeCarry.SameSpeedBigEggs then
															num43 = math.max(num43, safeCarry.LightMult)
														end

														local n31 = num44 * safeCarry.CarryRatio * num43
														local n32 = n31 * safeCarry.SpeedRatio
														local n33 = safeCarry.ExcessSeconds * n31
														local n34

														if num42 and num42 > n33 then
															n34 = math.min(n32, n31 * num42 / (num42 - n33))
														else
															n34 = n32
														end

														local guards = tbl2.Guards
														local flag100 = type(guards) == "table" and type(guards.Directory) == "table" and guards.Directory[tostring(param75)] or nil
														local n35 = type(flag100) == "table" and tonumber(flag100.WalkSpeed) or 0
														if not safeCarry.BeatGuard then
															return math.max(math.min(n31 * safeCarry.EasyRatio, n34), n31), true, n31, n34, n35
														end
														local n36 = math.max(n35 + safeCarry.GuardMargin, n31 * safeCarry.MinRatio)
														local n37 = math.max(n36, n35 * safeCarry.GuardRatio)

														if n34 < n36 then
															local n38 = n31 * safeCarry.SpeedRatio
															local n39 = safeCarry.StretchSeconds * n31
															local n40

															if num42 and num42 > n39 then
																n40 = math.min(n38, n31 * num42 / (num42 - n39))
															else
																n40 = n38
															end

															local n41 = n35 + math.max(safeCarry.GuardMargin, 1)
															if n41 <= n40 then
																return n41, true, n31, n40, n35
															end
														end

														return math.max(math.min(n37, n34), n31), n36 <= n34, n31, n34, n35
													end

													num5.SafeCarry.Unsafe = function(obj)
														local safeCarry = num5.SafeCarry
														if not safeCarry.Enabled or type(obj) ~= "table" or not obj.Uid or not safeCarry.Blocked[obj.Uid] then
															return nil
														end
														return string.format("the guard caught you with this %s before, skipping it", tostring(obj.Category))
													end

													num5.SafeCarry.Settle = function(param76, param77)
														local safeCarry = num5.SafeCarry
														local character = localPlayer.Character

														if character then
															character:FindFirstChildOfClass("Humanoid")
														end

														math.max(num5.WalkSpeed() * safeCarry.CarryRatio * (safeCarry.Seen[tostring(param77.Category)] or safeCarry.GuessMult) * safeCarry.WaitRate, 1)
														local baseWait = safeCarry.BaseWait
														local obj29 = func93(param77)

														while true do
															if func57(param76) then
																return false
															else
																local n31 = os.clock() - (safeCarry.JumpAt or 0)
																local flag101 = not safeCarry.WaitGuard or not obj29 or obj29:GetAttribute("GuardState") == "Sleeping"
																if n31 >= baseWait and (flag101 or n31 >= baseWait + 15) then
																	break
																end

																if n31 < baseWait then
																	str4 = string.format("Letting the jump settle, %.1fs", baseWait - n31)
																else
																	str4 = "Waiting for the guard to sleep"
																end

																RunService.Heartbeat:Wait()
															end
														end

														return true
													end

													do
														local monitorAction = num5.MonitorAction

														if monitorAction then
															local func117, func118

															do
																num5.MonitorAction = monitorAction

																num5.SafeCarry.LineDropHome = function(param78)
																	local safeCarry = num5.SafeCarry
																	local steal = num5.Steal
																	local carryUid = steal.CarryUid
																	local result22 = stealHome()
																	local flag102 = num5.Root()
																	if type(carryUid) ~= "string" or not result22 or not flag102 then
																		return false
																	end
																	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																	world = world and world:FindFirstChild("Areas")
																	world = world and world:FindFirstChild("SeparationLine")
																	local x = world and world:IsA("BasePart") and world.Position.X or 552.2
																	local y = world and world:IsA("BasePart") and world.Position.Y or 67.67
																	local tbl62 = {}

																	pcall(function()
																		for _, item32 in ipairs({ RunService.Heartbeat, RunService.PreSimulation, RunService.PostSimulation }) do
																			for _, getconnection in ipairs(getconnections(item32)) do
																				local ok, result = pcall(function()
																					return getconnection.Function
																				end)

																				if ok and type(result) == "function" then
																					local ok2, result2 = pcall(debug.info, result, "s")

																					if ok2 and string.find(tostring(result2), "UGI", 1, true) and not num5.MonitorAction(result) then
																						local ok3, result3 = pcall(function()
																							return getconnection.Enabled
																						end)

																						if not ok3 or result3 ~= false then
																							if pcall(function()
																								getconnection:Disable()
																							end) then
																								table.insert(tbl62, getconnection)
																							end
																						end
																					end
																				end
																			end
																		end
																	end)

																	local flag103 = false
																	local connection6 = nil

																	pcall(function()
																		connection6 = networking["RE/RigSync/Refresh"].OnClientEvent:Connect(function(param79)
																			if type(param79) == "table" and param79.Action == "Relocate" then
																				flag103 = true
																			end
																		end)
																	end)

																	local currentCamera = workspace.CurrentCamera
																	local value72 = nil

																	local function func119()
																		if value72 or not currentCamera then
																			return
																		end
																		value72 = { Type = currentCamera.CameraType, CFrame = currentCamera.CFrame }

																		pcall(function()
																			currentCamera.CameraType = Enum.CameraType.Scriptable
																			currentCamera.CFrame = value72.CFrame
																		end)
																	end

																	local function func120()
																		if not value72 or not currentCamera then
																			return
																		end
																		local value73 = value72
																		value72 = nil

																		pcall(function()
																			currentCamera.CameraType = value73.Type
																		end)
																	end

																	local function func121()
																		func120()

																		if connection6 then
																			connection6:Disconnect()
																			connection6 = nil
																		end

																		for _, item33 in ipairs(tbl62) do
																			pcall(function()
																				item33:Enable()
																			end)
																		end

																		table.clear(tbl62)
																	end

																	local now = os.clock()

																	local function func122(param80, param81, flag104, callback5)
																		local n31 = 0

																		while n31 < flag104 and not func57(param78) do
																			local num45 = num5.Root()
																			if not num45 then
																				return false
																			end

																			if callback5 and callback5() then
																				return true
																			end
																			local vector = Vector3.new(param80.X - num45.Position.X, 0, param80.Z - num45.Position.Z)
																			if vector.Magnitude < 2.5 then
																				return true
																			end
																			local n32 = vector.Unit * math.min(param81, vector.Magnitude / 0.05)

																			pcall(function()
																				num45.AssemblyLinearVelocity = Vector3.new(n32.X, num45.AssemblyLinearVelocity.Y, n32.Z)
																			end)

																			n31 += RunService.Heartbeat:Wait()
																		end

																		return false
																	end

																	func65()
																	local n31 = math.clamp(flag102.Position.Z, -425, -300)
																	local vector = Vector3.new(x + (safeCarry.Hops and safeCarry.HopStop or safeCarry.LineGap), y + 3.35, n31)

																	local function func123()
																		local rfEggWorldAskFieldEggSnapshot = networking:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot")

																		local ok, result = pcall(function()
																			return rfEggWorldAskFieldEggSnapshot:InvokeServer()
																		end)

																		local records = ok and type(result) == "table" and result.Records or nil

																		if type(records) == "table" then
																			for _, record in pairs(records) do
																				if type(record) == "table" and record.Uid == carryUid then
																					return record
																				end
																			end
																		end

																		return nil
																	end

																	local magnitude = Vector3.new(flag102.Position.X - x, 0, flag102.Position.Z - n31).Magnitude
																	local max = math.max
																	local carryRatio = safeCarry.CarryRatio
																	local num46 = max(num5.WalkSpeed() * carryRatio * (tonumber(safeCarry.Mult) or safeCarry.LightMult), 1)
																	local directMargin = safeCarry.DirectMargin
																	local n32 = math.max(0, (magnitude - safeCarry.DirectBudget) / num46) + directMargin

																	if safeCarry.CrossNow then
																		n32 = safeCarry.DirectMargin
																	end

																	local function func124()
																		local flag105 = num5.Root()
																		if not flag105 then
																			return
																		end

																		pcall(function()
																			flag105.CFrame = CFrame.new(vector) * CFrame.Angles(0, 1.5707963267948966, 0)
																			flag105.AssemblyLinearVelocity = Vector3.zero
																			flag105.AssemblyAngularVelocity = Vector3.zero
																		end)
																	end

																	func119()

																	if safeCarry.Hops then
																		local value74 = num5.Root()

																		if value74 then
																			local n33 = value74.Position.Y + safeCarry.HopLift
																			local x2 = value74.Position.X
																			local hopRatio = safeCarry.HopRatio
																			local n34 = math.max(num5.WalkSpeed() * hopRatio, 40)

																			while x2 - n34 > vector.X and steal.Carrying and not func57(param78) do
																				x2 -= n34
																				str4 = string.format("Line Drop: hopping home, X %d", math.floor(x2))
																				local n35 = 0

																				while n35 < safeCarry.HopGap do
																					local value75 = num5.Root()

																					if value75 then
																						pcall(function()
																							value75.CFrame = CFrame.new(x2, n33, n31) * CFrame.Angles(0, 1.5707963267948966, 0)
																							value75.AssemblyLinearVelocity = Vector3.zero
																							value75.AssemblyAngularVelocity = Vector3.zero
																						end)
																					end

																					n35 += RunService.Heartbeat:Wait()
																				end
																			end
																		end
																	end

																	str4 = "Line Drop: landing next to the line"
																	func124()

																	if safeCarry.Hops and steal.Carrying then
																		local n33 = 0

																		while n33 < safeCarry.DropDelay and steal.Carrying and not func57(param78) do
																			n33 += RunService.Heartbeat:Wait()
																		end

																		if steal.Carrying then
																			str4 = "Line Drop: dropping the egg next to the line"
																			local eggState = tbl2.EggState

																			if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																				pcall(eggState.DropFieldEgg, "PlayerRequest")
																			end

																			local n34 = 0

																			while steal.Carrying and n34 < 1 and not func57(param78) do
																				n34 += RunService.Heartbeat:Wait()
																			end
																		end
																	end

																	func120()

																	if safeCarry.ShakeTime > 0 then
																		local vector2 = Vector3.new(x - safeCarry.ShakeInside, vector.Y, n31)
																		local flag106 = false
																		local n33 = 0

																		while n33 < safeCarry.ShakeTime and steal.Carrying and not func57(param78) do
																			str4 = "Line Drop: shaking at the line"
																			flag106 = not flag106
																			local value76 = num5.Root()

																			if value76 then
																				pcall(function()
																					value76.CFrame = CFrame.new(flag106 and vector2 or vector) * CFrame.Angles(0, 1.5707963267948966, 0)
																					value76.AssemblyLinearVelocity = Vector3.zero
																				end)
																			end

																			n33 += RunService.Heartbeat:Wait()
																		end

																		func124()
																	end

																	local flag107 = n32 < safeCarry.LineWait
																	local n33 = 0
																	local n34 = 1

																	while true do
																		local carrying2 = steal.Carrying and n33 < safeCarry.LineWait

																		if carrying2 then
																			carrying2 = not (flag107 and n33 >= n32)
																		end

																		if carrying2 and not func57(param78) then
																			if flag107 then
																				str4 = string.format("Line Drop: stepping over the line in %.1fs", math.max(n32 - n33, 0))
																			else
																				str4 = string.format("Line Drop: crossing needs %.1fs, waiting for the guard, %.0fs left", n32, safeCarry.LineWait - n33)
																			end

																			if flag103 and safeCarry.ReJump and n34 < 40 and not func74() then
																				flag103 = false
																				n34 += 1
																				str4 = "Line Drop: pulled back, jumping to the line again"
																				func124()
																			end

																			n33 += RunService.Heartbeat:Wait()
																			continue
																		end

																		break
																	end

																	if steal.Carrying and flag107 and n33 >= n32 and not func57(param78) then
																		str4 = "Line Drop: stepping over the line"
																		local crossRatio = safeCarry.CrossRatio

																		func122(result22, num5.WalkSpeed() * crossRatio, 6, function()
																			return safeCarry.LastDelivered >= now or not steal.Carrying
																		end)

																		local n35 = 0

																		while n35 < 1.5 and safeCarry.LastDelivered < now and steal.Carrying and not func57(param78) do
																			n35 += RunService.Heartbeat:Wait()
																		end

																		if safeCarry.LastDelivered >= now then
																			func121()
																			return true
																		end
																	end

																	if steal.Carrying then
																		func121()
																		str4 = "Line Drop: the guard never came, dropping the egg"
																		local eggState = tbl2.EggState

																		if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																			pcall(eggState.DropFieldEgg, "PlayerRequest")
																		end

																		return false
																	end

																	if safeCarry.GetUp then
																		task.spawn(function()
																			local n35 = 0

																			while n35 < 1.5 do
																				local character = localPlayer.Character
																				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

																				if humanoid then
																					pcall(function()
																						humanoid.PlatformStand = false
																						local state = humanoid:GetState()

																						if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
																							humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
																						end
																					end)
																				end

																				n35 += RunService.Heartbeat:Wait()
																			end
																		end)
																	end

																	local n35 = 0

																	while not safeCarry.SnapPickup and not safeCarry.GetUp and func74() and n35 < 6 and not func57(param78) do
																		str4 = "Line Drop: egg is down at the line, getting up"
																		n35 += RunService.Heartbeat:Wait()
																	end

																	local n36 = 0

																	while not func57(param78) and n36 < 4 do
																		n36 += 1
																		local num47 = func100(carryUid)

																		if not num47 then
																			func121()
																			str4 = "Line Drop: the egg is gone"
																			return false
																		end

																		local result23 = func123()

																		if result23 and result23.State == "Slot" then
																			func121()
																			str4 = "Line Drop: the egg went back to its nest"
																			return false
																		end

																		str4 = "Line Drop: picking the egg up at the line"
																		local n37

																		if safeCarry.SnapPickup then
																			local value77 = num5.Root()

																			if value77 then
																				pcall(function()
																					value77.CFrame = CFrame.new(num47 + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
																					value77.AssemblyLinearVelocity = Vector3.zero
																				end)
																			end

																			n37 = 5
																		else
																			local pickupRatio = safeCarry.PickupRatio
																			func122(num47, num5.WalkSpeed() * pickupRatio, 5)
																			n37 = 2.5
																		end

																		local n38 = 0

																		while not steal.Carrying and n38 < n37 and not func57(param78) do
																			task.spawn(func71, carryUid)

																			if safeCarry.SnapPickup then
																				local flag108 = num5.Root()

																				if flag108 and Vector3.new(flag108.Position.X - num47.X, 0, flag108.Position.Z - num47.Z).Magnitude > 6 then
																					pcall(function()
																						flag108.CFrame = CFrame.new(num47 + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 1.5707963267948966, 0)
																					end)
																				end
																			end

																			n38 += task.wait(0.15)
																		end

																		if steal.Carrying and not steal.WrongEgg(carryUid) then
																			break
																		end
																	end

																	if not steal.Carrying then
																		func121()
																		str4 = "Line Drop: could not pick the egg up again"
																		return false
																	end

																	local flag109 = num5.Root()

																	if flag109 and flag109.Position.X - x > safeCarry.FarFromLine then
																		func121()
																		str4 = "Line Drop: egg ended up far from the line, carrying it home safely"
																		return num5.SafeCarry.Home(param78)
																	end

																	str4 = "Line Drop: stepping over the line"
																	local crossRatio = safeCarry.CrossRatio

																	func122(result22, num5.WalkSpeed() * crossRatio, 6, function()
																		return safeCarry.LastDelivered >= now or not steal.Carrying
																	end)

																	local value78 = num5.Root()

																	if value78 then
																		pcall(function()
																			value78.AssemblyLinearVelocity = Vector3.new(0, value78.AssemblyLinearVelocity.Y, 0)
																		end)
																	end
																	-- deobfuscated by 𝖲𝖫 -> https://discord.gg/x7YbZeezpm

																	local n37 = 0

																	while n37 < 2 and safeCarry.LastDelivered < now and steal.Carrying and not func57(param78) do
																		n37 += RunService.Heartbeat:Wait()
																	end

																	func121()
																	return safeCarry.LastDelivered >= now
																end

																num5.SafeCarry.Home = function(param82)
																	local safeCarry = num5.SafeCarry
																	local result24 = stealHome()
																	local flag110 = num5.Root()
																	if not result24 or not flag110 then
																		return false
																	end
																	func65()
																	local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																	world = world and world:FindFirstChild("Areas")
																	world = world and world:FindFirstChild("SeparationLine")
																	local n31 = (world and world:IsA("BasePart") and world.Position.X or 552) - 7
																	local character = localPlayer.Character
																	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

																	if humanoid then
																		humanoid.PlatformStand = false
																	end

																	local now = os.clock()
																	local n32 = 0

																	local function func125()
																		local flag111 = num5.Root()
																		if not flag111 then
																			return
																		end
																		local num48, flag112, num49, num50, num51 = safeCarry.Plan(num5.Steal.CarryAreaId, (Vector3.new(flag111.Position.X, 0, flag111.Position.Z) - Vector3.new(result24.X, 0, result24.Z)).Magnitude + math.max(0, safeCarry.Height) * 2, safeCarry.Mult)
																		local n33 = num48 * safeCarry.CarryScale
																		n32 = n33
																		safeCarry.PlanOk = flag112
																		safeCarry.FloorSpeed = safeCarry.BeatGuard and math.min(num51 + math.max(safeCarry.GuardMargin, 1), num50) or 0
																		str4 = string.format("Carrying home at %d (carry %d, guard %d, max %d)%s", math.floor(n33 + 0.5), math.floor(num49 + 0.5), math.floor(num51 + 0.5), math.floor(num50 + 0.5), flag112 and "" or ", guard is faster, going at your max safe speed")
																	end

																	local function func126()
																		local n33 = math.max(0, safeCarry.Height)
																		local flag113 = num5.Root()
																		local character2 = localPlayer.Character
																		if n33 <= 0.5 or not flag113 or not character2 then
																			return
																		end
																		local n34 = result24.Y + n33
																		if n34 - 2 <= flag113.Position.Y then
																			return
																		end
																		local rotation = flag113.CFrame.Rotation
																		local n35 = CFrame.new(Vector3.new(flag113.Position.X, n34, flag113.Position.Z)) * rotation

																		pcall(function()
																			character2:PivotTo(n35)
																			flag113.AssemblyLinearVelocity = Vector3.zero
																			flag113.AssemblyAngularVelocity = Vector3.zero
																		end)
																	end

																	func125()
																	local num52 = safeCarry.NewHuman(true)
																	local flag114 = num5.Root()
																	local n33 = math.clamp((flag114 and flag114.Position.Z or result24.Z) + num52.Lane, -425, -300)
																	local now2 = os.clock()

																	if safeCarry.CarryReact > 0 then
																		local n34 = os.clock() + safeCarry.React(0, safeCarry.CarryReact)

																		while os.clock() < n34 and not func57(param82) do
																			RunService.Heartbeat:Wait()
																		end
																	end

																	local n34 = 0

																	if safeCarry.CarryStyle ~= "Walk" then
																		func126()
																	end

																	while not func57(param82) do
																		local num53 = num5.Root()
																		if not num53 then
																			return false
																		end

																		if not num5.Steal.Carrying then
																			if now <= safeCarry.LastDelivered then
																				return true
																			end
																			task.wait(0.1)
																			if now <= safeCarry.LastDelivered then
																				return true
																			end

																			if now <= safeCarry.LastFailed then
																				str4 = "Delivery was rewound, too fast for your speed"
																				return false
																			end

																			if not safeCarry.PlanOk and num5.Steal.CarryUid then
																				safeCarry.Blocked[num5.Steal.CarryUid] = true
																				str4 = string.format("The guard caught you with %s, it is faster than your max safe speed, skipping this egg", tostring(safeCarry.Category))
																				return false
																			end

																			n34 += 1
																			if safeCarry.RecoverTries < n34 then
																				str4 = "The egg is gone"
																				return false
																			end
																			str4 = "Egg dropped, taking it back"
																			if not func101(param82) then
																				str4 = "Could not take the egg back"
																				return false
																			end
																			local n35 = 0

																			while func74() and n35 < 4 and not func57(param82) do
																				n35 += RunService.Heartbeat:Wait()
																			end

																			local n36 = math.min(now, os.clock())
																			func125()

																			if safeCarry.CarryStyle ~= "Walk" then
																				func126()
																			end

																			num53 = num5.Root()
																			if not num53 then
																				return false
																			end
																			now = n36
																		end

																		local now3 = os.clock()
																		local n35 = math.max(now3 - now2, 0.0041666666666666666)
																		local carryStyle = safeCarry.CarryStyle == "Walk"
																		local n36 = carryStyle and 0 or math.max(0, safeCarry.Height)
																		local num54, num55 = num52.Step(n35, n36 <= 0.5 and humanoid or nil, humanoid and humanoid.FloorMaterial ~= Enum.Material.Air)
																		local n37 = math.clamp(n33 + num55, -425, -300)
																		local vector = num53.Position.X > n31 + 2 and Vector3.new(n31, num53.Position.Y, n37) or result24
																		local flag115, flag116 = safeCarry.Avoid(num53.Position, vector)

																		if not flag116 then
																			flag115 = vector
																		end

																		local vector2 = Vector3.new(flag115.X - num53.Position.X, 0, flag115.Z - num53.Position.Z)
																		if vector2.Magnitude < 2 and flag115 == result24 then
																			break
																		end
																		local n38 = math.max(n32 * num54, safeCarry.FloorSpeed or 0)

																		if os.clock() < (safeCarry.SlowUntil or 0) then
																			n38 *= safeCarry.SlowFactor
																		end

																		if carryStyle then
																			pcall(function()
																				if humanoid and vector2.Magnitude > 0.01 then
																					humanoid:MoveTo(num53.Position + vector2.Unit * math.min(vector2.Magnitude, 30))
																				end
																			end)
																		elseif n36 > 0.5 then
																			local n39 = math.clamp(safeCarry.ClimbShare, 0.1, 0.9)
																			local y = result24.Y
																			local n40 = math.max(0, num53.Position.X - n31)
																			local n41 = n36 * math.sqrt(1 - n39 * n39) / n39
																			local n42 = y + n36

																			if flag115 == result24 or n40 <= n41 then
																				n42 = y + n36 * math.clamp((flag115 == result24 and 0 or n40) / math.max(n41, 1), 0, 1)
																			end

																			local n43 = math.clamp((n42 - num53.Position.Y) / 0.12, -n38 * n39, n38 * n39)
																			local num56 = math.sqrt(math.max(n38 * n38 - n43 * n43, 0))
																			local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(num56, vector2.Magnitude / 0.05) or Vector3.zero

																			pcall(function()
																				num53.AssemblyLinearVelocity = Vector3.new(vector3.X, n43, vector3.Z)
																			end)
																		else
																			local vector3 = vector2.Magnitude > 0.01 and vector2.Unit * math.min(n38, vector2.Magnitude / 0.05) or Vector3.zero

																			pcall(function()
																				num53.AssemblyLinearVelocity = Vector3.new(vector3.X, num53.AssemblyLinearVelocity.Y, vector3.Z)

																				if safeCarry.RunAnimate and humanoid and vector2.Magnitude > 0.01 then
																					humanoid:Move(vector2.Unit, false)
																				end
																			end)
																		end

																		RunService.Heartbeat:Wait()
																		now2 = now3
																	end

																	if humanoid then
																		pcall(function()
																			local value79 = num5.Root()

																			if safeCarry.CarryStyle == "Walk" and value79 then
																				humanoid:MoveTo(value79.Position)
																			end

																			humanoid:Move(Vector3.zero, false)
																		end)
																	end

																	local n35 = 0

																	while n35 < 2 and not func57(param82) do
																		if safeCarry.LastDelivered >= now then
																			return true
																		end

																		if now <= safeCarry.LastFailed then
																			str4 = "Delivery was rewound, too fast for your speed"
																			return false
																		end

																		if not num5.Steal.Carrying then
																			break
																		end
																		n35 += RunService.Heartbeat:Wait()
																	end

																	if num5.Steal.Carrying then
																		task.wait(0.2)
																		local eggState = tbl2.EggState

																		if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																			pcall(eggState.DropFieldEgg, "PlayerRequest")
																		end
																	end

																	return safeCarry.LastDelivered >= now
																end

																func117 = function(param83)
																	local antiGuard = num5.AntiGuard

																	if antiGuard.Enabled and not num5.SafeCarry.LineDrop then
																		local n31 = 0

																		while not antiGuard.Busy and n31 < 1 and not func57(param83) do
																			str4 = "Waiting for Anti Guard to start"
																			n31 += RunService.Heartbeat:Wait()
																		end

																		local busy = antiGuard.Busy
																		local n32 = 0

																		while antiGuard.Busy and n32 < 30 and not func57(param83) do
																			str4 = "Anti Guard is slipping past the guard"
																			n32 += RunService.Heartbeat:Wait()
																		end

																		if busy then
																			local n33 = 0
																			local n34 = 0

																			while n33 < 10 and not func57(param83) do
																				local result25 = func74()
																				local ok, result = pcall(num5.Steal.HeldByMe)
																				ok = ok and result == true
																				local flag117 = not result25
																				if flag117 and not ok then
																					break
																				end

																				if flag117 and ok and not antiGuard.Busy then
																					n34 += RunService.Heartbeat:Wait()
																					if not (n34 >= 0.3) then
																						continue
																					end
																					break
																				end

																				str4 = result25 and "The guard hit you, waiting until you can move" or "Waiting for Anti Guard to finish"
																				n33 += RunService.Heartbeat:Wait()
																				n34 = 0
																			end

																			local ok, result = pcall(num5.Steal.HeldByMe)

																			if ok and not result then
																				num5.Steal.Carrying = false
																			end

																			local safeCarry = num5.SafeCarry
																			local result26 = stealHome()
																			local n35 = result26 and safeCarry.Enabled and safeCarry.CarryStyle ~= "Walk" and safeCarry.Height > 0.5 and result26.Y + safeCarry.Height or nil
																			local n36 = 0

																			while n36 < 0.8 and num5.Steal.Carrying and not func57(param83) do
																				str4 = n36 < 0.6 and "Anti Guard done, rising up" or "Anti Guard done, getting ready"
																				local num57 = num5.Root()

																				if num57 and n35 then
																					local n37 = n35 - num57.Position.Y
																					local n38 = n36 < 0.6 and math.clamp(n37 / math.max(0.6 - n36, 0.1), -120, 120) or math.clamp(n37 / 0.2, -30, 30)

																					pcall(function()
																						num57.AssemblyLinearVelocity = Vector3.new(0, n38, 0)
																					end)
																				end

																				n36 += RunService.Heartbeat:Wait()
																			end

																			local ok2, result2 = pcall(num5.Steal.HeldByMe)

																			if ok2 and not result2 then
																				num5.Steal.Carrying = false
																			else
																				num5.SafeCarry.SlowUntil = os.clock() + 2
																			end
																		end
																	end

																	local n31 = 0

																	while not num5.Steal.Carrying and n31 < n24 and not func57(param83) do
																		str4 = "Checking the egg in hand"
																		n31 += RunService.Heartbeat:Wait()
																	end

																	if not num5.Steal.Carrying then
																		str4 = "The egg is gone, staying to look for it"
																		if not func101(param83) then
																			str4 = "The egg is gone"
																			return false
																		end
																	end

																	if num5.SafeCarry.LineDrop then
																		return num5.SafeCarry.LineDropHome(param83)
																	end

																	if num5.SafeCarry.Enabled then
																		return num5.SafeCarry.Home(param83)
																	end
																	local result27 = stealHome()
																	local flag118 = num5.Root()
																	if not result27 or not flag118 then
																		return false
																	end
																	local n32 = math.max(flag118.Position.Y, result27.Y) + n10

																	local function func127()
																		if tbl61.Uid and tbl61.Freed and num5.Steal.Carrying then
																			return "priority"
																		end
																		return nil
																	end

																	local flag119 = true
																	local n33 = 0

																	while true do
																		local flag120 = num5.Root()

																		if not flag120 then
																			return false
																		else
																			str4 = "Flying home"
																			local position = flag120.Position
																			local n34 = math.max(n32, position.Y)
																			local value80, flag121 = func77(Vector3.new(position.X + (result27.X - position.X) * 0.25, position.Y + (n34 - position.Y) * 0.7, position.Z + (result27.Z - position.Z) * 0.25), param83, flag119, nil, nil, func127)

																			if value80 then
																				value80, flag121 = func77(Vector3.new(result27.X, n34, result27.Z), param83, flag119, nil, nil, func127)
																			end

																			if value80 then
																				value80, flag121 = func77(result27, param83, flag119, nil, nil, func127)
																			end

																			if value80 then
																				local character = localPlayer.Character
																				character = character and character:FindFirstChildOfClass("Humanoid")

																				if character then
																					character.PlatformStand = false
																				end

																				task.wait(0.2)
																				if not num5.Steal.Carrying then
																					str4 = "Arrived without the egg"
																					return false
																				end
																				local eggState = tbl2.EggState

																				if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																					pcall(eggState.DropFieldEgg, "PlayerRequest")
																				end

																				return true
																			end

																			if flag121 == "priority" then
																				local uid2 = tbl61.Uid
																				local freed = tbl61.Freed
																				local value81 = tbl61
																				tbl61.Uid = nil
																				value81.Freed = nil
																				local num58 = num5.Root()
																				if not num58 or not uid2 or not freed then
																					return false
																				end

																				if (freed - num58.Position).Magnitude <= n11 * n30 then
																					str4 = "Best egg fell nearby, swapping eggs"
																					local eggState = tbl2.EggState

																					if type(eggState) == "table" and type(eggState.DropFieldEgg) == "function" then
																						pcall(eggState.DropFieldEgg, "PlayerRequest")
																					end

																					local n35 = 0

																					while num5.Steal.Carrying and n35 < 1 do
																						n35 += RunService.Heartbeat:Wait()
																					end

																					if not func101(param83, uid2) then
																						return false
																					end
																				else
																					str4 = "Best egg fell far away, riding a guard hit to it"
																					if not func109(param83, uid2, freed) then
																						return false
																					end
																				end

																				local value82 = num5.Root()
																				n33 = 0

																				if value82 then
																					n32 = math.max(value82.Position.Y, result27.Y) + n10
																				end

																				continue
																			end

																			if flag121 == "dropped" and n33 < huge then
																				n33 += 1
																				if not func101(param83) then
																					return false
																				end
																				continue
																			end

																			break
																		end
																	end

																	return false
																end

																do
																	local function func128(param84)
																		local n31 = tonumber(param84) or 0
																		local tbl63 = { "", "K", "M", "B", "T", "Qa", "Qi" }
																		local n32 = 1

																		while math.abs(n31) >= 1000 and n32 < #tbl63 do
																			n31 /= 1000
																			n32 += 1
																		end

																		return string.format(n32 == 1 and "%.0f%s" or "%.2f%s", n31, tbl63[n32])
																	end

																	func118 = function(flag122)
																		if not flag122 then
																			return "None"
																		end
																		local format = string.format
																		local category = tostring(flag122.Category)
																		local n31 = tonumber(flag122.Scale) or 0
																		local func129 = tostring
																		local areaId = flag122.AreaId
																		local str8 = format("%s  %.2fx  |  value %s  |  %s", category, n31, func128(flag122.Value), func129(areaId))
																		local str9

																		if flag122.State == "Dropped" then
																			str9 = str8 .. "  |  dropped"
																		elseif flag122.State == "Carried" then
																			str9 = str8 .. "  |  carried by a player"
																		else
																			str9 = str8
																		end

																		return str9
																	end
																end
															end

															do
																local flag123 = false
																local n31 = 0.5
																local n32 = 0.6
																local n33 = 0
																local n34 = 0

																local function func130()
																	local value83 = n19
																	num5.Steal.Active = true
																	num5.Steal.Carrying = num5.Steal.Carrying == true

																	if not num5.Steal.Carrying then
																		num5.Steal.CarryUid = nil
																	end

																	local value84 = func63(false, true)
																	local value85 = nil
																	local value86 = nil
																	local lastSkip = nil

																	for _, item34 in ipairs(value84) do
																		if item34.State == "Carried" then
																			value86 = value86 or item34
																		else
																			local value87 = num5.SafeCarry.Unsafe(item34)

																			if value87 then
																				lastSkip = lastSkip or value87
																			else
																				value85 = item34
																				break
																			end
																		end
																	end

																	local tbl64 = { value85 }
																	uid = value85 and value85.Uid or nil
																	num5.Steal.Wanted = value85 ~= nil
																	str3 = func118(value85)

																	if value86 then
																		str3 ..= "  |  watching " .. tostring(value86.Category)
																	end

																	if not value85 then
																		num5.Steal.Active = false
																		lastSkip = lastSkip or num5.SafeCarry.LastSkip
																		num5.SafeCarry.LastSkip = nil
																		str4 = value86 and "Best egg is carried, waiting for it" or lastSkip and "Skipped: " .. lastSkip or "No egg matches"
																		return false
																	end

																	if not num5.ClaimMovement("steal") then
																		num5.Steal.Active = false
																		str4 = "Waiting for Auto Place"
																		return false
																	end

																	if num5.Treadmill.Riding or num5.OnBelt() then
																		num5.ExitBelt()
																	end

																	flag123 = true
																	num5.HoldBelt()

																	local function func131(param85)
																		str4 = param85
																		local flag124 = func108(value85, value83)
																		local flag125 = false
																		local value88 = nil

																		if flag124 then
																			if func72(value85.Uid, value83) then
																				flag125 = func117(value83)
																				value88 = nil
																			else
																				value88 = str4
																			end
																		end

																		func68()
																		num5.Steal.Active = false
																		num5.Steal.LastFinishedAt = os.clock()
																		value88 = flag125 and "Delivered" or value88
																		local str10
																		-- 𝚂𝙻 | 𝚂𝚘𝚞𝚛𝚌𝚎 𝙻𝚎𝚊𝚔 // discord.gg/x7YbZeezpm

																		if value88 then
																			str10 = value88
																		else
																			str10 = flag124 and "Run ended" or "That egg would not come free"
																		end

																		str4 = str10
																		return true
																	end

																	local num59 = num5.Root()
																	local position = typeof(value85.CFrame) == "CFrame" and value85.CFrame.Position or nil

																	if num59 and position then
																		local num60 = (position - num59.Position).Magnitude <= n29
																		local areaId = value85.AreaId
																		local flag126 = localPlayer:GetAttribute("AreaId") == areaId
																		if num60 or flag126 then
																			return (func131("Target is right here, taking it"))
																		end
																	end

																	if num5.SafeCarry.Enabled and num5.SafeCarry.Approach == "Run" then
																		local flag127 = num5.SafeCarry.RunTo(value85, value83)
																		local flag128, flag129

																		if flag127 then
																			if func72(value85.Uid, value83) then
																				flag128 = func117(value83)
																				flag129 = nil
																			else
																				flag129 = str4
																				flag128 = false
																			end
																		else
																			tbl50[value85.Uid] = os.clock() + 20
																			flag129 = nil
																			flag128 = false
																		end

																		func68()
																		num5.Steal.Active = false
																		num5.Steal.LastFinishedAt = os.clock()
																		str4 = flag128 and "Delivered" or flag129 or flag127 and "Run ended" or "That egg would not come free"
																		return true
																	end

																	local value89 = func63(true)
																	local str11 = "FirstAreaEgg_" .. tostring(localPlayer.UserId)
																	local tbl65 = {}

																	for _, item35 in ipairs(value89) do
																		if func94(item35) or type(item35.Uid) == "string" and string.sub(item35.Uid, 1, #str11) == str11 then
																			table.insert(tbl65, item35)
																		end
																	end

																	if #tbl65 ~= 0 then
																		value89 = tbl65
																	end

																	local flag130, num61 = func76(value89)

																	if not flag130 then
																		num5.Steal.Active = false
																		str4 = "No egg matches"
																		return false
																	end

																	if flag130.Uid == value85.Uid then
																		return (func131("Target is the closest egg, taking it"))
																	end
																	local value90, num62 = func95(flag130)
																	local flag131

																	if num62 and num59 then
																		local value91, value92, value93 = ipairs(value89)
																		local huge2 = math.huge
																		flag131 = flag130

																		for _, value94 in value91, value92, value93 do
																			local position2 = typeof(value94.CFrame) == "CFrame" and value94.CFrame.Position or nil

																			if value94.Uid ~= value85.Uid and value94.AreaId == flag130.AreaId and position2 then
																				local magnitude = (position2 - num59.Position).Magnitude

																				if n26 < (position2 - num62).Magnitude then
																					magnitude += n26
																				end

																				if magnitude < huge2 then
																					huge2 = magnitude
																					flag131 = value94
																				end
																			end
																		end
																	else
																		flag131 = flag130
																	end

																	str4 = string.format("Sleeping guard egg %d studs away", math.floor(num61 + 0.5))

																	if not flag131 then
																		num5.Steal.Active = false
																		str4 = "No egg matches"
																		return false
																	end

																	local flag132, flag133 = func99(flag131, value83, false, tbl64[1])
																	if not flag132 then
																		num5.Steal.Active = false
																		return false
																	end
																	local uid2 = nil
																	local uid3 = value85.Uid
																	local n35 = 0

																	while true do
																		if flag133 and not func57(value83) then
																			str4 = "Holding for the guard hit"

																			if func97(value83, flag133, function(param86)
																				if not uid2 and tbl61.Uid and tbl61.Freed then
																					uid2 = tbl61.Uid
																					param86.Destination = tbl61.Freed + Vector3.new(0, 3, 0)
																					local value95 = tbl61
																					tbl61.Uid = nil
																					value95.Freed = nil
																					str4 = "Best egg fell, jumping to it instead"
																				end
																			end) then
																				n35 += 1

																				if uid2 then
																					uid3 = uid2
																					func101(value83, uid2)
																					break
																				else
																					local entry4 = tbl64[n35]
																					local value96
																					value96, flag133 = func99(entry4, value83, true, tbl64[n35 + 1])

																					if value96 then
																						if entry4 and type(entry4.Uid) == "string" then
																							uid3 = entry4.Uid
																						end

																						continue
																					end
																				end
																			end
																		end

																		break
																	end

																	if not func72(uid3, value83) then
																		local value97 = str4
																		func68()
																		num5.Steal.Active = false
																		num5.Steal.LastFinishedAt = os.clock()
																		str4 = value97
																		return true
																	end

																	local flag134 = func117(value83)
																	func68()
																	num5.Steal.Active = false
																	num5.Steal.LastFinishedAt = os.clock()
																	str4 = flag134 and "Delivered" or "Run ended"
																	return true
																end

																if type(tbl2.EggState) ~= "table" then
																	do
																		do
																			do
																				tbl8.Add(function()
																					local value98 = nil

																					if value41 then
																						value98 = type(value41.Set) == "function"
																					end

																					if value98 then
																						pcall(value41.Set, nil, str4)
																					end

																					local value99 = nil

																					if value42 then
																						value99 = type(value42.Set) == "function"
																					end

																					if value99 then
																						pcall(value42.Set, nil, str3)
																					end

																					if not num5.Toggle(value40, false) then
																						return false
																					end
																					local num63, flag135, num64 = func59()

																					if num63 then
																						if flag135 == "night" then
																							func61()
																						end

																						num5.Movement.StealFirst = true
																						num5.Steal.Wanted = false

																						if flag32 then
																							n19 += 1
																							num5.Steal.Active = false
																							func68()
																							num5.StopWalking()
																						end

																						local n35 = math.max(0, math.ceil(num63 - num64))

																						if flag135 == "wall" then
																							str4 = string.format("Field wall up, %ds", n35)
																						else
																							str4 = string.format("Night, going again in %ds", n35)
																						end

																						return false
																					end

																					if tbl52 and n23 == math.huge then
																						n23 = os.clock() + n22
																					end

																					if flag32 then
																						return true
																					end

																					if func62() then
																						str4 = "Night over, waiting for the field to reset"
																						tbl8.Wake()
																						return false
																					end

																					local stealFirst = num5.Movement.StealFirst
																					local owner = num5.Movement.Owner
																					local placeWanted = num5.Movement.PlaceWanted and not stealFirst

																					if not placeWanted then
																						placeWanted = owner ~= nil and owner ~= "steal" and owner ~= "treadmill" and owner ~= "scramble"
																					end

																					if placeWanted then
																						if os.clock() >= n33 then
																							n33 = os.clock() + n31
																							local ok, result = pcall(func63, false, false)
																							ok = ok and type(result) == "table" and result[1] ~= nil
																							num5.Steal.Wanted = ok

																							if ok then
																								num5.Movement.StealFirst = true
																							end
																						end

																						if num5.Steal.Wanted then
																							local func132 = tostring
																							owner = owner or "Auto Place"
																							str4 = "Egg found, waiting for " .. func132(owner) .. " to stop"
																						else
																							str4 = "Waiting for " .. tostring(owner or "Auto Place")
																						end

																						return true
																					end

																					if os.clock() < n34 then
																						return true
																					end
																					num5.Movement.StealFirst = false
																					flag32 = true

																					task.spawn(function()
																						local ok = pcall(func130)

																						if flag123 then
																							flag123 = false
																							num5.ReleaseBelt()
																						end

																						if not ok then
																							func68()
																							num5.Steal.Active = false
																						end

																						local flag136 = uid
																						uid = nil
																						local flag137 = flag136 and tbl33[flag136]

																						if flag137 and flag137.Once then
																							tbl33[flag136] = nil
																						end

																						local value100 = tbl61
																						local value101 = tbl61
																						tbl61.Uid = nil
																						value100.Freed = nil
																						value101.Token = nil

																						if str4 == "Delivered" and not num5.IsNight() then
																							num5.Movement.StealFirst = true
																						end

																						if not num5.Steal.Wanted then
																							n34 = os.clock() + n32
																						end

																						num5.ReleaseMovement("steal")
																						flag32 = false
																						tbl8.Wake()
																					end)

																					return true
																				end)

																				value40 = value27

																				value26 = function()
																					n19 += 1
																					table.clear(tbl50)
																					num5.Steal.Active = false
																					num5.Steal.Wanted = false
																					local flag138 = num5.Toggle(value40, false)
																					num5.Shield("steal", flag138)

																					if not flag138 then
																						num5.Movement.StealFirst = false
																						table.clear(tbl33)
																						table.clear(tbl34)
																						table.clear(tbl35)
																					end

																					func68()
																					num5.StopWalking()
																					tbl8.Wake()
																				end

																				do
																					local function func133()
																						n19 += 1
																						num5.Steal.Active = false
																						func68()
																						num5.StopWalking()
																					end

																					local function func134()
																						if num5.Toggle(value40, false) then
																							return true
																						end

																						if value40 and type(value40.Set) == "function" then
																							pcall(value40.Set, value40, true)
																						end

																						return false
																					end

																					num5.CancelSteal = function(param87)
																						if type(param87) ~= "string" then
																							return
																						end
																						tbl33[param87] = nil
																						tbl34[param87] = nil
																						tbl35[param87] = true

																						if flag32 and uid == param87 then
																							func133()
																						end

																						tbl8.Wake()
																					end

																					num5.StealQueue = function()
																						local tbl66 = {}

																						for k in pairs(tbl33) do
																							table.insert(tbl66, k)
																						end

																						table.sort(tbl66, function(flag139, param88)
																							local at = tbl33[flag139].At
																							local at2 = tbl33[param88].At
																							if at ~= at2 then
																								return at < at2
																							end
																							return flag139 < param88
																						end)

																						return tbl66
																					end

																					num5.PrioritizeSteal = function(param89)
																						if type(param89) ~= "string" or func60() then
																							return
																						end
																						local n35 = 0

																						for _, value102 in pairs(tbl33) do
																							if value102.At < n35 then
																								n35 = value102.At
																							end
																						end

																						tbl33[param89] = { At = n35 - 1, Once = false }
																						tbl35[param89] = nil
																						tbl50[param89] = nil

																						if func134() and flag32 and not num5.Steal.Carrying and uid ~= param89 then
																							func133()
																						end

																						tbl8.Wake()
																					end

																					num5.MoveInPlan = function(param90, num65)
																						if type(param90) ~= "string" or num65 ~= -1 and num65 ~= 1 or func60() then
																							return
																						end
																						local list9 = num5.StealPlan()
																						local foundAt2 = table.find(list9, param90)
																						local n35 = foundAt2 and foundAt2 + num65
																						if not n35 or n35 < 1 or n35 > #list9 then
																							return
																						end
																						table.remove(list9, foundAt2)
																						table.insert(list9, n35, param90)
																						local n36 = math.max(foundAt2, n35)

																						for i, item36 in ipairs(list9) do
																							if i <= n36 or tbl33[item36] then
																								local entry5 = tbl33[item36]

																								if entry5 then
																									entry5.At = i
																								else
																									tbl33[item36] = { At = i, Once = false }
																								end

																								tbl35[item36] = nil
																							end
																						end

																						if flag32 and not num5.Steal.Carrying and uid and list9[1] ~= uid then
																							func133()
																						end

																						tbl8.Wake()
																					end

																					num5.StealPlan = function()
																						if not num5.Toggle(value40, false) or num5.IsNight() then
																							return {}, nil
																						end
																						local tbl67 = {}

																						if uid then
																							table.insert(tbl67, uid)
																						end

																						local ok, result = pcall(func63, false, true)

																						if ok and type(result) == "table" then
																							for _, item37 in ipairs(result) do
																								if item37.Uid ~= uid then
																									table.insert(tbl67, item37.Uid)
																								end
																							end
																						end

																						return tbl67, uid
																					end

																					num5.SetPriority = function(param91, param92)
																						if param92 then
																							num5.PrioritizeSteal(param91)
																						else
																							num5.CancelSteal(param91)
																						end
																					end

																					num5.ResortSteal = function()
																						if flag32 and not num5.Steal.Carrying and uid and not tbl33[uid] then
																							local ok, result = pcall(func63, false, true)

																							if ok and type(result) == "table" then
																								local value103 = nil

																								for _, item38 in ipairs(result) do
																									if item38.State ~= "Carried" then
																										value103 = item38
																										break
																									else
																										value103 = nil
																									end
																								end

																								if not value103 or value103.Uid ~= uid then
																									func133()
																								end
																							end
																						end

																						tbl8.Wake()
																					end

																					num5.StealNow = function(param93, flag140)
																						if type(param93) ~= "string" or func60() then
																							return
																						end

																						if not tbl33[param93] then
																							local n35 = 0

																							for _, value104 in pairs(tbl33) do
																								if n35 < value104.At then
																									n35 = value104.At
																								end
																							end

																							tbl33[param93] = { At = n35 + 1, Once = flag140 == true }
																						end

																						tbl35[param93] = nil
																						tbl50[param93] = nil
																						local flag141 = func134() and flag32 and not num5.Steal.Carrying and uid ~= param93

																						if flag141 then
																							flag141 = not (uid and tbl33[uid])
																						end

																						if flag141 then
																							func133()
																						end

																						tbl8.Wake()
																					end
																				end
																			end

																			func10(function()
																				num5.GodMode(false)
																				num5.ReleaseMovement("steal")
																				func68()
																			end)

																			num5.UiQueue = {}

																			num5.UiDefer = function(param94)
																				table.insert(num5.UiQueue, param94)
																			end

																			num5.Notify = function(param95, param96)
																				if type(result6) == "table" and type(result6.Notify) == "function" then
																					pcall(result6.Notify, param95, param96, 5)
																				end
																			end

																			do
																				local connection6 = RunService.Heartbeat:Connect(function()
																					local uiQueue = num5.UiQueue
																					if #uiQueue == 0 then
																						return
																					end
																					num5.UiQueue = {}

																					for _, item39 in ipairs(uiQueue) do
																						pcall(item39)
																					end
																				end)

																				func10(function()
																					pcall(function()
																						connection6:Disconnect()
																					end)
																				end)
																			end
																		end

																		do
																			local n35

																			do
																				num5.Rift = {
																					Requirements = {},
																					At = 0,
																					Busy = false,
																					Next = 0,
																					Handles = {},
																					Restart = {},
																				}

																				num5.RiftOn = function(param97)
																					local flag142 = num5.Rift.Handles[param97]
																					return flag142 ~= nil and num5.Toggle(flag142, false) == true
																				end

																				n35 = 8

																				do
																					local function func135(param98)
																						local directory = tbl2.Assets and tbl2.Assets.Directory
																						local flag143 = type(directory) == "table" and directory[tostring(param98)] or nil
																						return type(flag143) == "table" and flag143 or nil
																					end

																					num5.EggRarity = function(obj)
																						local rarity = func135(obj.AssetCategory)
																						rarity = rarity and rarity.Rarity or nil
																						local flag144 = type(rarity) == "table"

																						if flag144 then
																							flag144 = tonumber(rarity.RarityNumber or rarity.Rank)
																						end

																						return flag144 or 0
																					end

																					num5.EggIncome = function(obj)
																						local n36 = func135(obj.AssetCategory)
																						n36 = n36 and tonumber(n36.EarningRate) or 0
																						local n37 = tonumber(obj.AssetScale) or 0
																						if n37 <= 0 then
																							return 0
																						end
																						local n38 = n37 > 5 and (n37 / 5) ^ 1.2 * 19.637875755794113 or n37 ^ 1.85
																						local mutations = tbl2.Mutations
																						local flag145 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
																						local n39 = 1

																						if flag145 then
																							local ok
																							ok, n39 = pcall(mutations.EarningsFor, type(obj.Mutations) == "table" and obj.Mutations or {})
																							local flag146 = ok and type(n39) == "number"
																							local n40 = 1

																							if not flag146 then
																								n39 = n40
																							end
																						end

																						return n36 * n38 * n39
																					end
																				end
																			end

																			num5.RiftShortfall = function()
																				local tbl68 = {}

																				for _, requirement in ipairs(num5.Rift.Requirements) do
																					tbl68[requirement] = (tbl68[requirement] or 0) + 1
																				end

																				if next(tbl68) == nil then
																					return tbl68
																				end
																				local save3 = tbl2.Save
																				local flag147 = type(save3) == "table" and type(save3.Get) == "function"
																				local result = nil

																				if flag147 then
																					local ok
																					ok, result = pcall(save3.Get)
																					result = ok and type(result) == "table" and result or nil
																				end

																				if not result then
																					return {}
																				end
																				local tbl69 = {}
																				local func136 = pairs
																				local equippedAssets = result.EquippedAssets or {}

																				for _, equippedAsset in func136(equippedAssets) do
																					tbl69[equippedAsset] = true
																				end

																				local func137 = pairs
																				local inventory = result.Inventory or {}

																				for k, value105 in func137(inventory) do
																					local str12 = type(value105) == "table" and tostring(value105.Category) or nil
																					local flag148

																					if str12 then
																						flag148 = (tbl68[str12] or 0) > 0
																					else
																						flag148 = str12
																					end

																					flag148 = flag148 and value105.InFuse ~= true and value105.IsFavorite ~= true and not tbl69[k]

																					if flag148 then
																						tbl68[str12] = tbl68[str12] - 1
																					end
																				end

																				for k, value106 in pairs(tbl68) do
																					if value106 <= 0 then
																						tbl68[k] = nil
																					end
																				end

																				return tbl68
																			end

																			do
																				local function func138()
																					for k in pairs(num5.Rift.Handles) do
																						if num5.RiftOn(k) then
																							return true
																						end
																					end

																					return false
																				end

																				tbl8.Add(function()
																					local rift = num5.Rift
																					local busy = rift.Busy

																					if not busy then
																						local next_ = rift.Next
																						busy = os.clock() < next_
																					end

																					if busy or not func138() then
																						return false
																					end
																					rift.Busy = true
																					rift.Next = os.clock() + n35

																					task.spawn(function()
																						local rfScrambleTradeInAskState = networking:FindFirstChild("RF/ScrambleTradeIn/AskState")

																						if rfScrambleTradeInAskState and rfScrambleTradeInAskState:IsA("RemoteFunction") then
																							local ok, result = pcall(rfScrambleTradeInAskState.InvokeServer, rfScrambleTradeInAskState)

																							if ok and type(result) == "table" then
																								local requirements = {}

																								if result.Unlocked == true and type(result.Requirements) == "table" then
																									for _, requirement in ipairs(result.Requirements) do
																										table.insert(requirements, tostring(requirement))
																									end
																								end

																								rift.Requirements = requirements
																								rift.At = os.clock()
																							end
																						end

																						rift.Busy = false
																						tbl8.Wake()
																					end)

																					return false
																				end)
																			end
																		end
																	end

																	local tbl70, tbl71, flag149, flag150, tbl72, tbl73, n35

																	do
																		do
																			tbl70 = {
																				"Always",
																				"Steal Idle",
																				"After Steal",
																				"Night Only",
																			}

																			tbl71 = {
																				"Biggest Size",
																				"Highest Value",
																				"Smallest Size",
																				"Backpack Order",
																			}

																			flag149 = tbl70[1]
																			flag150 = tbl71[2]
																			tbl72 = {}
																			tbl73 = {}
																			n35 = 0

																			local function func139()
																				if type(num5.PlaceEggRefresh) == "function" then
																					num5.PlaceEggRefresh()
																				end
																			end
																		end

																		local function func140(list10)
																			local tbl74 = {}

																			if type(list10) == "table" then
																				for k, value107 in pairs(list10) do
																					k = value107 == true and type(k) == "string" and k or type(value107) == "string" and value107 or nil

																					if k then
																						table.insert(tbl74, k)
																					end
																				end
																			end

																			return tbl74
																		end
																	end

																	num5.PlaceEggStatusRow = obj8:CreateText({
																		Name = "Pen Status",
																		Text = "Pen status unknown",
																	})

																	num5.PlaceEggHandle = obj8:CreateToggle({
																		Name = "Auto Place Egg",
																		Default = false,
																		Callback = function()
																			if type(num5.PlaceEggRestart) == "function" then
																				num5.PlaceEggRestart()
																			end
																		end,
																	})

																	do
																		local placeEggHandle = num5.PlaceEggHandle

																		obj8:CreateDropdown({
																			Name = "Place Egg Rule",
																			Options = tbl70,
																			Default = tbl70[1],
																			SubOf = placeEggHandle,
																			Callback = function(value)
																				if table.find(tbl70, value) then
																					flag149 = value
																				end
																			end,
																		})

																		obj8:CreateDropdown({
																			Name = "Place Egg Order",
																			Options = tbl71,
																			Default = tbl71[2],
																			SubOf = placeEggHandle,
																			Callback = function(value)
																				if table.find(tbl71, value) then
																					flag150 = value
																				end
																			end,
																		})

																		local tbl75 = {}

																		for i = 2, #tbl26 do
																			table.insert(tbl75, tbl26[i])
																		end

																		if not (#tbl75 > 0) then
																			do
																				local tbl76 = {}
																				local tbl77 = {}

																				if tbl2.Assets then
																					do
																						local tbl78 = {}

																						if type(tbl2.Assets.Directory) ~= "table" then
																							table.sort(tbl78, function(param99, param100)
																								if param99.Rarity ~= param100.Rarity then
																									return param99.Rarity > param100.Rarity
																								end
																								return param99.Name < param100.Name
																							end)

																							for _, item40 in ipairs(tbl78) do
																								local formatted3 = string.format("%s [%s]", item40.Name, item40.RarityName)

																								if tbl77[formatted3] then
																									formatted3 = string.format("%s [%s] (%s)", item40.Name, item40.RarityName, item40.Category)
																								end

																								table.insert(tbl76, formatted3)
																								tbl77[formatted3] = item40.Category
																							end

																							if not (#tbl76 > 0) then
																								local n36, n37, n38, n39, n40, n41, placeEggHandle2, placeEggStatusRow, str13, flag151
																								local tbl79, n42, flag152, n43, func141, func142, func143

																								do
																									do
																										do
																											local tbl80 = {
																												["K/s"] = {
																													Min = 0,
																													Max = 1000,
																													Mult = 1000,
																												},
																												["M/s"] = {
																													Min = 0,
																													Max = 1000,
																													Mult = 1000000,
																												},
																												["B/s"] = {
																													Min = 0,
																													Max = 100,
																													Mult = 1e9,
																												},
																											}

																											local n44 = 0
																											local str14 = "M/s"

																											local function func144(flag153, flag154)
																												if flag153 ~= nil then
																													n44 = math.max(0, math.floor(tonumber(flag153) or n44))
																												end

																												if flag154 ~= nil then
																													str14 = tostring(flag154)
																												end

																												n35 = n44 * (tbl80[str14] or tbl80["M/s"]).Mult
																											end

																											func11(obj8, {
																												Name = "Min Place Value",
																												Note = "Skip eggs worth less than this (0 = off)",
																												SubOf = placeEggHandle,
																												Legacy = "Place Min Value",
																												SectionName = "Auto Place Egg",
																												OnRaw = function(num66)
																													func144(math.floor(num66 / 1000), "K/s")
																												end,
																											})
																										end
																									end

																									do
																										local n44, func145, func146

																										do
																											n36 = 5
																											n37 = 26
																											n38 = 6
																											n39 = 8
																											n40 = 0
																											n41 = 30
																											n44 = 12
																											placeEggHandle2 = nil
																											placeEggStatusRow = nil
																											str13 = "Pen status unknown"
																											flag151 = false
																											tbl79 = {}
																											n42 = 0
																											flag152 = nil
																											n43 = 30

																											func141 = function(childName5, param101)
																												local obj30 = networking:FindFirstChild(childName5)
																												if not obj30 or not obj30:IsA("RemoteFunction") then
																													return false, nil
																												end
																												return pcall(obj30.InvokeServer, obj30, param101)
																											end

																											do
																												local function func147(param102)
																													local directory = tbl2.Assets and tbl2.Assets.Directory
																													local flag155 = type(directory) == "table" and directory[tostring(param102.AssetCategory)] or nil
																													return type(flag155) == "table" and flag155 or nil
																												end

																												func145 = function(param103)
																													local rarity = func147(param103)
																													rarity = rarity and rarity.Rarity or nil
																													local flag156 = type(rarity) == "table"
																													local flag157

																													if flag156 then
																														flag157 = tonumber(rarity.RarityNumber or rarity.Rank)
																													else
																														flag157 = flag156
																													end

																													return flag157 or 0
																												end

																												func146 = function(param104)
																													local n45 = func147(param104)
																													n45 = n45 and tonumber(n45.EarningRate) or 0
																													local n46 = tonumber(param104.AssetScale) or 0
																													if n46 <= 0 then
																														return 0
																													end
																													local n47 = n46 > 5 and (n46 / 5) ^ 1.2 * 19.637875755794113 or n46 ^ 1.85
																													local mutations = tbl2.Mutations
																													local flag158 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
																													local n48 = 1

																													if flag158 then
																														local ok
																														ok, n48 = pcall(mutations.EarningsFor, type(param104.Mutations) == "table" and param104.Mutations or {})
																														ok = ok and type(n48) == "number"
																														local n49 = 1

																														if not ok then
																															n48 = n49
																														end
																													end

																													return n45 * n47 * n48
																												end
																											end
																										end

																										do
																											local function func148()
																												local tbl81 = {}
																												local backpack = localPlayer:FindFirstChildOfClass("Backpack")
																												if not backpack then
																													return tbl81
																												end
																												local n45 = 0

																												for _, child in ipairs(backpack:GetChildren()) do
																													local attribute = child:GetAttribute("UID")

																													if type(attribute) == "string" then
																														n45 += 1
																														tbl81[attribute] = n45
																													end
																												end

																												return tbl81
																											end

																											func142 = function()
																												local eggState = tbl2.EggState
																												if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
																													return {}
																												end
																												local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
																												if not ok or type(result) ~= "table" then
																													return {}
																												end
																												local result28 = func148()
																												local tbl82 = {}

																												if num5.RiftOn("Place") then
																													tbl82 = num5.RiftShortfall()

																													for _, value108 in pairs(result) do
																														if type(value108) == "table" and value108.Placement ~= nil then
																															local assetCategory3 = tostring(value108.AssetCategory)

																															if (tbl82[assetCategory3] or 0) > 0 then
																																tbl82[assetCategory3] = tbl82[assetCategory3] - 1
																															end
																														end
																													end
																												end

																												local tbl83 = {}

																												for k, value109 in pairs(result) do
																													if type(value109) == "table" and value109.Placement == nil and not tbl79[k] then
																														local value110 = func146(value109)
																														local assetCategory4 = tostring(value109.AssetCategory)
																														local flag159 = next(tbl72) == nil or tbl72[func145(value109)] == true
																														local flag160 = next(tbl73) == nil or tbl73[assetCategory4] == true
																														local flag161 = n35 <= 0 or value110 >= n35
																														local flag162 = (tbl82[assetCategory4] or 0) > 0

																														if flag162 then
																															tbl82[assetCategory4] = tbl82[assetCategory4] - 1
																														end

																														if flag162 then
																															flag161 = flag162
																														else
																															flag161 = flag159 and flag160 and flag161
																														end

																														if flag161 then
																															table.insert(tbl83, {
																																Uid = k,
																																Scale = tonumber(value109.AssetScale) or 0,
																																Income = value110,
																																Slot = result28[k] or math.huge,
																																Rift = flag162,
																															})
																														end
																													end
																												end

																												table.sort(tbl83, function(param105, param106)
																													if param105.Rift ~= param106.Rift then
																														return param105.Rift
																													end

																													if flag150 == tbl71[2] and param105.Income ~= param106.Income then
																														return param105.Income > param106.Income
																													end

																													if flag150 == tbl71[3] and param105.Scale ~= param106.Scale then
																														return param105.Scale < param106.Scale
																													end

																													if flag150 == tbl71[4] and param105.Slot ~= param106.Slot then
																														return param105.Slot < param106.Slot
																													end
																													return param105.Scale > param106.Scale
																												end)

																												return tbl83
																											end
																										end

																										func143 = function(flag163)
																											if flag163 == 0 then
																												return false
																											end
																											local steal = num5.Steal
																											if flag149 == tbl70[2] then
																												return not steal.Active and not steal.Carrying
																											end

																											if flag149 == tbl70[3] then
																												local flag164 = steal.LastFinishedAt > 0

																												if flag164 then
																													local lastFinishedAt = steal.LastFinishedAt
																													flag164 = os.clock() - lastFinishedAt <= n44
																												end

																												return flag164
																											end

																											if flag149 == tbl70[4] then
																												return num5.IsNight()
																											end
																											return true
																										end
																									end
																								end

																								local func149, func150, func151

																								do
																									func149 = function()
																										local eggState = tbl2.EggState
																										local flag165 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
																										local n44 = 0

																										if flag165 then
																											local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

																											if ok and type(result) == "table" then
																												for _, value111 in pairs(result) do
																													if type(value111) == "table" and value111.Placement ~= nil then
																														n44 += 1
																													end
																												end
																											end
																										end

																										local save3 = tbl2.Save
																										local flag166 = type(save3) == "table" and type(save3.Get) == "function"
																										local result = nil

																										if flag166 then
																											local ok
																											ok, result = pcall(save3.Get)
																											result = ok and type(result) == "table" and result or nil
																										end

																										local flag167 = result and type(result.EquippedAssets) == "table"
																										local n45 = 0

																										if flag167 then
																											for k in pairs(result.EquippedAssets) do
																												n45 += 1
																											end
																										end

																										local value112 = func6(function()
																											return ReplicatedStorage.Data.Bases
																										end)

																										local flag168 = type(value112) == "table" and type(value112.GetAssetEquipCapacity) == "function"
																										local ok = nil

																										if flag168 then
																											local result2
																											ok, result2 = pcall(value112.GetAssetEquipCapacity, result and tonumber(result.BaseUpgradeLevel) or 0)
																											ok = ok and tonumber(result2) or nil
																										end

																										if not ok then
																											local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

																											if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
																												local result2
																												ok, result2 = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)
																												ok = ok and tonumber(result2) or nil
																											end
																										end

																										ok = ok or 0
																										return ok - n44 - n45, ok, n44, n45
																									end

																									do
																										local n44 = -0.5
																										local n45 = -24

																										func150 = function()
																											local eggState = tbl2.EggState
																											local tbl84 = {}
																											if type(eggState) ~= "table" or type(eggState.ReadOwnerEggs) ~= "function" then
																												return tbl84
																											end
																											local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)
																											if not ok or type(result) ~= "table" then
																												return tbl84
																											end

																											for _, value113 in pairs(result) do
																												local placement = type(value113) == "table" and value113.Placement or nil
																												local localCFrame = type(placement) == "table" and placement.LocalCFrame or nil

																												if typeof(localCFrame) == "CFrame" then
																													table.insert(tbl84, Vector2.new(localCFrame.Position.X, localCFrame.Position.Z))
																												end
																											end

																											return tbl84
																										end

																										local obj31 = Random.new()

																										func151 = function(list11)
																											local tbl85 = {}

																											for i = n45, 8, 4 do
																												for i2 = 4, 30, 4 do
																													local vector2 = Vector2.new(i, i2)
																													local flag169 = true

																													for _, item41 in ipairs(list11) do
																														if (item41 - vector2).Magnitude < n36 then
																															flag169 = false
																															break
																														end
																													end

																													if flag169 then
																														table.insert(tbl85, CFrame.new(i, n44, i2))
																													end
																												end
																											end

																											for i = #tbl85, 2, -1 do
																												local value114 = obj31:NextInteger(1, i)
																												local entry6 = tbl85[i]
																												tbl85[i] = tbl85[value114]
																												tbl85[value114] = entry6
																											end

																											return tbl85
																										end
																									end
																								end

																								local func152, func153

																								do
																									func152 = function()
																										local value115, value116, value117, value118 = func149()
																										local eggState = tbl2.EggState
																										local flag170 = type(eggState) == "table" and type(eggState.ReadOwnerEggs) == "function"
																										local n44 = 0

																										if flag170 then
																											local ok, result = pcall(eggState.ReadOwnerEggs, localPlayer.UserId)

																											if ok and type(result) == "table" then
																												for _, value119 in pairs(result) do
																													if type(value119) == "table" and value119.Placement == nil then
																														n44 += 1
																													end
																												end
																											end
																										end

																										str13 = string.format("Eggs placed %d/%d  -  %d/%d pets equipped, %d in bag", value117, 30, value118, value116, n44)
																										return value115, value117
																									end

																									do
																										local function func154(num67, callback6)
																											local flag171 = num5.Root()
																											if not flag171 then
																												return false
																											end
																											local position = flag171.Position
																											local n44 = (num67 - position).Magnitude / math.max(400, 1) + 3
																											local value120 = nil
																											local n45 = 0

																											local connection6 = RunService.Heartbeat:Connect(function(deltaTime)
																												if value120 ~= nil or num5.AntiGuard.Busy then
																													return
																												end
																												n45 += deltaTime
																												local flag172 = num5.Root()
																												if not flag172 or callback6() or n45 > n44 then
																													value120 = false
																													return
																												end

																												if (flag172.Position - position).Magnitude > 6 then
																													position = flag172.Position
																												end

																												local n46 = num67 - position
																												local n47 = n11 * deltaTime
																												local flag173 = n46.Magnitude <= math.max(n47, 0.05)
																												position = flag173 and num67 or position + n46.Unit * n47
																												local vector = Vector3.new(n46.X, 0, n46.Z)
																												local cframe = vector.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector.Unit) or flag172.CFrame.Rotation

																												pcall(function()
																													flag172.CFrame = CFrame.new(position) * cframe
																													flag172.AssemblyLinearVelocity = Vector3.zero
																													flag172.AssemblyAngularVelocity = Vector3.zero
																												end)

																												if flag173 then
																													value120 = true
																												end
																											end)

																											while value120 == nil do
																												RunService.Heartbeat:Wait()
																											end

																											connection6:Disconnect()
																											return value120
																										end

																										local function func155()
																											local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																											world = world and world:FindFirstChild("Areas")
																											world = world and world:FindFirstChild("SeparationLine")
																											return world and world:IsA("BasePart") and world.Position.X or 552
																										end

																										func153 = nil

																										local function func156(num68)
																											local flag174 = num5.Root()
																											if not flag174 or type(num5.StealHome) ~= "function" then
																												return nil
																											end
																											local result29 = func155()
																											if flag174.Position.X < result29 == num68.X < result29 then
																												return nil
																											end
																											local ok, result = pcall(num5.StealHome)
																											if not ok or typeof(result) ~= "Vector3" then
																												return nil
																											end

																											if (result - num68).Magnitude <= 12 or (flag174.Position - result).Magnitude <= 12 then
																												return nil
																											end
																											return result
																										end

																										func153 = function(num69, callback7, flag175, flag176)
																											local flag177 = num5.Root()
																											if not flag177 then
																												return false
																											end

																											if not flag176 then
																												local flag178 = func156(num69)
																												if flag178 and not func153(flag178, callback7, flag175, true) then
																													return false
																												end

																												if callback7 and callback7() then
																													return false
																												end
																												flag177 = num5.Root()
																												if not flag177 then
																													return false
																												end
																											end

																											num5.Shield(flag175 or "place", true)
																											num5.Driving = num5.Driving + 1
																											task.wait(0.2)
																											local n44 = num69 + Vector3.new(0, 3, 0)
																											local n45 = math.max(flag177.Position.Y, n44.Y) + n43

																											local ok, result = pcall(function()
																												return func154(Vector3.new(flag177.Position.X, n45, flag177.Position.Z), callback7) and func154(Vector3.new(n44.X, n45, n44.Z), callback7) and func154(n44, callback7)
																											end)

																											ok = ok and result == true
																											num5.Driving = math.max(0, num5.Driving - 1)
																											num5.Shield(flag175 or "place", false)
																											return ok
																										end
																									end
																								end

																								do
																									num5.FlyTo = function(param107, param108, flag179)
																										return func153(param107, param108, flag179 or "fly")
																									end

																									do
																										local function func157()
																											local eggState = tbl2.EggState
																											if type(eggState) ~= "table" or type(eggState.PlantEgg) ~= "function" then
																												return false
																											end
																											local result30 = func142()
																											if not func143(#result30) then
																												return false
																											end
																											func152()
																											local value121, value122, value123 = func149()
																											local n44 = n41 - (tonumber(value123) or 0)
																											if n44 <= 0 then
																												return false
																											end
																											local penAnch = num5.PenAnchor()
																											if not penAnch then
																												return false
																											end
																											num5.Movement.PlaceWanted = true
																											if not num5.ClaimMovement("place") then
																												return "waiting"
																											end
																											local flag180 = n42

																											local function func158()
																												if flag180 ~= n42 or not num5.Toggle(placeEggHandle2, false) then
																													return true
																												end

																												if num5.IsNight() then
																													return false
																												end
																												return flag149 == tbl70[4] or num5.Movement.StealFirst
																											end

																											if num5.Treadmill.Riding or num5.OnBelt() then
																												num5.ExitBelt()
																											end

																											local function func159()
																												num5.HoldBelt()
																												local ok, result = pcall(func153, penAnch, func158)
																												num5.ReleaseBelt()
																												return ok and result and true or false
																											end

																											if n37 < num5.DistanceTo(penAnch) then
																												str13 = "Flying to the pen"

																												if not func159() then
																													num5.LeaveBelt()
																													n40 = os.clock() + n38
																													return false
																												end
																											end

																											num5.LeaveBelt()
																											if func158() then
																												return false
																											end

																											local function func160()
																												if num5.DistanceTo(penAnch) <= n37 then
																													return true
																												end

																												if func158() then
																													return false
																												end
																												str13 = "Pen out of reach, flying back"
																												return func159() and num5.DistanceTo(penAnch) <= n37
																											end

																											if not func160() then
																												str13 = "Could not reach the pen, trying again soon"
																												n40 = os.clock() + n38
																												return false
																											end

																											local result31 = func150()
																											local n45 = 0
																											local n46 = 0

																											for _, item42 in ipairs(result30) do
																												if not (n45 >= n44 or func158()) then
																													if not func160() then
																														str13 = "Pen out of reach, stopping this pass"
																														break
																													else
																														local ok, result = pcall(eggState.WearEggTool, item42.Uid)

																														if ok and result ~= false then
																															task.wait(0.15)
																															local n47 = 0
																															local flag181 = false

																															for _, item43 in ipairs(func151(result31)) do
																																if not (func158() or n47 >= n39) then
																																	n47 += 1
																																	local AskPlaceEgg, flag182 = func141("RF/EggWorld/AskPlaceEgg", { Uid = item42.Uid, LocalCFrame = item43 })

																																	if AskPlaceEgg and flag182 ~= false then
																																		table.insert(result31, Vector2.new(item43.Position.X, item43.Position.Z))
																																		n45 += 1
																																		flag181 = true
																																		break
																																	else
																																		continue
																																	end
																																end

																																break
																															end

																															if flag181 then
																																n46 = 0
																																continue
																															else
																																tbl79[item42.Uid] = true
																																n46 += 1
																																if not (n46 >= 2) then
																																	continue
																																end
																															end
																														else
																															tbl79[item42.Uid] = true
																															continue
																														end
																													end
																												end

																												break
																											end

																											if type(eggState.DoffEggTool) == "function" then
																												pcall(eggState.DoffEggTool)
																											end

																											if n45 == 0 then
																												n40 = os.clock() + n38
																											end

																											return n45 > 0
																										end

																										tbl8.Add(function()
																											local value124, value125 = func152()

																											if placeEggStatusRow and type(placeEggStatusRow.Set) == "function" then
																												pcall(placeEggStatusRow.Set, placeEggStatusRow, str13)
																											end

																											local num70 = tonumber(value125)
																											local flag183 = num70 ~= nil and flag152 ~= nil and num70 < flag152

																											if num70 then
																												flag152 = num70
																											end

																											if flag183 then
																												table.clear(tbl79)
																											end

																											if not num5.Toggle(placeEggHandle2, false) then
																												num5.Movement.PlaceWanted = false
																												num5.ReleaseMovement("place")
																												return false
																											end

																											if flag151 then
																												return false
																											end

																											if os.clock() < n40 then
																												num5.Movement.PlaceWanted = false
																												return false
																											end

																											if num5.Movement.StealFirst and not num5.IsNight() then
																												num5.Movement.PlaceWanted = false
																												return false
																											end
																											flag151 = true

																											task.spawn(function()
																												local ok, result = pcall(func157)

																												if not (ok and result == "waiting") then
																													num5.Movement.PlaceWanted = false
																												end

																												num5.ReleaseMovement("place")
																												flag151 = false
																												tbl8.Wake()
																											end)

																											return false
																										end)
																									end
																								end

																								placeEggHandle2 = num5.PlaceEggHandle
																								placeEggStatusRow = num5.PlaceEggStatusRow

																								num5.PlaceEggRestart = function()
																									table.clear(tbl79)
																									n42 += 1
																									num5.StopWalking()
																									tbl8.Wake()
																								end

																								num5.PlaceEggRefresh = function()
																									table.clear(tbl79)
																									tbl8.Wake()
																								end

																								num5.Rift.Restart.Place = function()
																									table.clear(tbl79)
																									tbl8.Wake()
																								end

																								do
																									local save3 = tbl2.Save

																									if type(save3) == "table" then
																										do
																											if type(save3.FieldSignal) == "function" then
																												for _, item44 in ipairs({
																													"EggInventory",
																													"EquippedAssets",
																													"BaseUpgradeLevel",
																												}) do
																													local ok, result = pcall(save3.FieldSignal, item44)

																													if ok and type(result) == "table" and type(result.Connect) == "function" then
																														local ok2, result2 = pcall(result.Connect, result, function()
																															tbl8.Wake()
																														end)

																														if ok2 and result2 then
																															func10(function()
																																pcall(function()
																																	result2:Disconnect()
																																end)
																															end)
																														end
																													end
																												end
																											end

																											num5.Steal.HeldByMe = function()
																												local carryUid = num5.Steal.CarryUid
																												local character = localPlayer.Character
																												if type(carryUid) ~= "string" or not character then
																													return false
																												end
																												local obj32 = workspace:FindFirstChild(carryUid)
																												if not obj32 then
																													return false
																												end

																												for _, descendant in ipairs(obj32:GetDescendants()) do
																													if descendant:IsA("WeldConstraint") or descendant:IsA("JointInstance") then
																														local ok, result, result2 = pcall(function()
																															return descendant.Part0, descendant.Part1
																														end)

																														if ok and (result and result:IsDescendantOf(character) or result2 and result2:IsDescendantOf(character)) then
																															return true
																														end
																													end
																												end

																												return false
																											end

																											do
																												local n44 = 0

																												local connection6 = RunService.Heartbeat:Connect(function(deltaTime)
																													n44 += deltaTime
																													if n44 < 0.2 then
																														return
																													end
																													n44 = 0
																													local steal = num5.Steal

																													if not steal.Carrying then
																														if steal.GuessedDrop then
																															local ok, result = pcall(steal.HeldByMe)

																															if ok and result then
																																steal.GuessedDrop = false
																																steal.Carrying = true
																																steal.HeldSeenAt = os.clock()
																															end
																														end

																														return
																													end

																													local ok, result = pcall(steal.HeldByMe)
																													if not ok or result then
																														steal.HeldSeenAt = os.clock()
																														return
																													end

																													if os.clock() - (steal.HeldSeenAt or 0) > 0.8 then
																														steal.Carrying = false
																														steal.GuessedDrop = true
																														steal.LastFinishedAt = os.clock()
																														tbl8.Wake()
																													end
																												end)

																												func10(function()
																													pcall(function()
																														connection6:Disconnect()
																													end)
																												end)
																											end
																										end

																										do
																											local eggState = tbl2.EggState
																											local carryChanged = type(eggState) == "table" and eggState.CarryChanged

																											if carryChanged then
																												if type(carryChanged) == "table" and type(carryChanged.Connect) == "function" then
																													do
																														local n44, n45, n46, func161, func162

																														do
																															do
																																local ok, result = pcall(carryChanged.Connect, carryChanged, function(param109)
																																	local carrying = type(param109) == "table" and param109.IsCarrying == true

																																	if num5.Steal.Carrying and not carrying then
																																		num5.Steal.LastFinishedAt = os.clock()
																																	end

																																	num5.Steal.GuessedDrop = false

																																	if carrying then
																																		num5.Steal.HeldSeenAt = os.clock()
																																	end

																																	if carrying and type(param109.Uid) == "string" then
																																		num5.Steal.CarryUid = param109.Uid
																																		num5.Steal.CarryAreaId = param109.AreaId
																																		local mult = tonumber(param109.SpeedMultiplier)

																																		if mult and mult > 0 then
																																			num5.SafeCarry.Mult = mult
																																			num5.SafeCarry.Category = param109.AssetCategory

																																			if param109.AssetCategory ~= nil then
																																				local assetCategory5 = tostring(param109.AssetCategory)
																																				num5.SafeCarry.Seen[assetCategory5] = math.min(num5.SafeCarry.Seen[assetCategory5] or mult, mult)
																																			end
																																		end
																																	end

																																	num5.Steal.Carrying = carrying
																																	tbl8.Wake()
																																end)

																																if ok and result then
																																	func10(function()
																																		pcall(function()
																																			result:Disconnect()
																																		end)
																																	end)
																																end
																															end

																															pcall(function()
																																local reEggWorldFieldEggRedeemVerdict = networking:FindFirstChild("RE/EggWorld/FieldEggRedeemVerdict")
																																local reAlertsRaise = networking:FindFirstChild("RE/Alerts/Raise")

																																if reEggWorldFieldEggRedeemVerdict and reEggWorldFieldEggRedeemVerdict:IsA("RemoteEvent") then
																																	local connection6 = reEggWorldFieldEggRedeemVerdict.OnClientEvent:Connect(function()
																																		num5.SafeCarry.LastDelivered = os.clock()
																																	end)

																																	func10(function()
																																		connection6:Disconnect()
																																	end)
																																end

																																if reAlertsRaise and reAlertsRaise:IsA("RemoteEvent") then
																																	local connection6 = reAlertsRaise.OnClientEvent:Connect(function(param110)
																																		if type(param110) == "table" and type(param110.Text) == "string" and string.find(param110.Text, "Delivery failed", 1, true) then
																																			num5.SafeCarry.LastFailed = os.clock()
																																		end
																																	end)

																																	func10(function()
																																		connection6:Disconnect()
																																	end)
																																end
																															end)

																															n44 = 10
																															n45 = 1
																															n46 = 5

																															func161 = function(childName6)
																																local obj33 = networking:FindFirstChild(childName6)
																																if not obj33 or not obj33:IsA("RemoteFunction") then
																																	return false, nil, nil
																																end
																																local ok, result, result2 = pcall(obj33.InvokeServer, obj33)
																																return ok, result, result2
																															end

																															do
																																local n47 = 0
																																local flag184 = false

																																func162 = function(flag185, flag186, param111)
																																	if flag185 and flag186 ~= false then
																																		n47 = 0
																																		flag184 = false
																																		return true
																																	end

																																	if flag185 and tostring(param111) == "Already using treadmill" then
																																		n47 = 0
																																		flag184 = false
																																		return true
																																	end

																																	if flag185 and tostring(param111) == "Not grounded" and num5.Grounded() then
																																		n47 += 1

																																		if n47 >= 2 then
																																			n47 = 0

																																			if not flag184 then
																																				flag184 = true
																																				pcall(num5.UndoSwap)
																																			elseif type(num5.RequestRespawn) == "function" then
																																				flag184 = false
																																				num5.RequestRespawn()
																																			end
																																		end
																																	end

																																	return false
																																end
																															end
																														end

																														local value126 = nil
																														local value127 = nil
																														local flag187 = false
																														local n47 = 0
																														local flag188 = false
																														local treadmill = num5.Treadmill

																														local function func163()
																															return num5.Toggle(value126, false)
																														end

																														local function func164()
																															local movement = num5.Movement
																															return movement.PlaceWanted or movement.ScrambleWanted or movement.MutationWanted or movement.FracturedWanted or movement.Owner ~= nil and movement.Owner ~= "treadmill" or num5.Steal.Active or num5.Steal.Carrying
																														end

																														local function func165()
																															local flag189 = n47
																															if func164() or not num5.ClaimMovement("treadmill") then
																																return false
																															end

																															local function func166()
																																return flag189 ~= n47 or not func163() or num5.Movement.Owner ~= "treadmill" or func164()
																															end

																															if num5.BeltHeld() then
																																num5.ResetBelt()
																															end

																															local flag190 = num5.Belt()
																															if not flag190 then
																																return false
																															end
																															local n48 = flag190.Position + Vector3.new(0, flag190.Size.Y / 2, 0)

																															if num5.DistanceTo(n48 + Vector3.new(0, 2, 0)) > n44 then
																																if type(num5.FlyTo) ~= "function" or not num5.FlyTo(n48, func166, "treadmill") then
																																	return false
																																end
																															end

																															if func166() then
																																return false
																															end
																															treadmill.Riding = func162(func161("RF/Treadmill/AskWearStill"))
																															return treadmill.Riding
																														end

																														tbl8.Add(function()
																															if not func163() then
																																if treadmill.Riding and not flag187 then
																																	flag187 = true

																																	task.spawn(function()
																																		pcall(num5.ExitBelt)
																																		flag187 = false
																																		tbl8.Wake()
																																	end)
																																end

																																return false
																															end

																															if flag187 or func164() then
																																return false
																															end

																															if treadmill.Riding and num5.Toggle(value127, true) and num5.OnBelt() then
																																if os.clock() >= (treadmill.NextCheck or 0) and not num5.Flying and num5.Grounded() then
																																	treadmill.NextCheck = os.clock() + n46
																																	flag187 = true

																																	task.spawn(function()
																																		local ok, result = pcall(function()
																																			return func162(func161("RF/Treadmill/AskWearStill"))
																																		end)

																																		treadmill.Riding = ok and result == true

																																		if not treadmill.Riding then
																																			treadmill.NextTry = 0
																																		end

																																		flag187 = false
																																		tbl8.Wake()
																																	end)
																																end

																																return false
																															end

																															if os.clock() < (treadmill.NextTry or 0) then
																																return false
																															end
																															treadmill.NextCheck = 0
																															treadmill.NextTry = os.clock() + (treadmill.LastFailed and 3 or 4)
																															flag187 = true

																															task.spawn(function()
																																local ok, result = pcall(func165)
																																treadmill.LastFailed = not (ok and result == true)
																																num5.ReleaseMovement("treadmill")
																																flag187 = false
																																tbl8.Wake()
																															end)

																															return false
																														end)

																														task.spawn(function()
																															while not flag188 do
																																task.wait(3)

																																if not func163() and not func164() and not num5.Flying and num5.OnBelt() and num5.Grounded() then
																																	func162(func161("RF/Treadmill/AskWearStill"))
																																end
																															end
																														end)

																														task.spawn(function()
																															local n48 = 0

																															while not flag188 do
																																local value128 = task.wait(0.25)

																																if not func163() or not treadmill.Riding or func164() then
																																	n48 = 0
																																elseif num5.OnBelt() then
																																	n48 = 0
																																else
																																	n48 += value128

																																	if n48 >= 1.5 then
																																		treadmill.Riding = false
																																		treadmill.NextTry = 0
																																		tbl8.Wake()
																																		n48 = 0
																																	end
																																end
																															end
																														end)

																														task.spawn(function()
																															local n48 = 0
																															local n49 = 0
																															local position = nil

																															while not flag188 do
																																local num71 = task.wait(0.25)
																																n48 = math.max(0, n48 - num71)
																																local riding = treadmill.Riding and func163() and not func164()
																																local flag191 = num5.Root()
																																local character = localPlayer.Character
																																character = character and character:FindFirstChildOfClass("Humanoid")

																																if riding or not (num5.Flying or num5.Movement.Owner ~= nil or num5.Movement.PlaceWanted or character ~= nil and character.MoveDirection.Magnitude > 0.1) or not flag191 or not num5.OnBelt() then
																																	position = flag191 and flag191.Position
																																	n49 = 0
																																	position = position or nil
																																else
																																	local vector = Vector3.new(flag191.Position.X, 0, flag191.Position.Z)
																																	position = position and (vector - Vector3.new(position.X, 0, position.Z)).Magnitude < 0.5

																																	if position then
																																		n49 += num71
																																	else
																																		n49 = 0
																																	end

																																	position = flag191.Position

																																	if n49 >= n45 and n48 <= 0 then
																																		pcall(num5.ExitBelt)
																																		n48 = 1.5
																																		n49 = 0
																																	end
																																end
																															end
																														end)

																														func10(function()
																															flag188 = true
																															treadmill.Riding = false
																														end)

																														value126 = obj9:CreateToggle({
																															Name = "Auto Treadmill",
																															Default = false,
																															Callback = function()
																																n47 += 1
																																num5.StopWalking()
																																tbl8.Wake()
																															end,
																														})

																														value127 = obj9:CreateToggle({
																															Name = "Stay On Treadmill",
																															Default = true,
																														})
																													end
																													--[=[ 𝖲𝖫 ]=] -- discord.gg/x7YbZeezpm

																													local value129, n44, tbl86, tbl87

																													do
																														local n45, n46, flag192, func167, func168

																														do
																															n45 = 4
																															n46 = 10
																															value129 = nil
																															flag192 = false
																															n44 = 0
																															tbl86 = {}

																															tbl87 = {
																																MinRarity = 0,
																																MinIncome = 0,
																																Eggs = {},
																															}

																															func167 = function(childName7, param112)
																																local obj34 = networking:FindFirstChild(childName7)
																																if not obj34 or not obj34:IsA("RemoteFunction") then
																																	return false, nil
																																end
																																return pcall(obj34.InvokeServer, obj34, param112)
																															end

																															do
																																local function func169(param113)
																																	local flag193 = tbl87.MinRarity > 0

																																	if flag193 then
																																		local minRarity = tbl87.MinRarity
																																		flag193 = num5.EggRarity(param113) < minRarity
																																	end

																																	if flag193 then
																																		return false
																																	end
																																	local flag194 = tbl87.MinIncome > 0

																																	if flag194 then
																																		local minIncome = tbl87.MinIncome
																																		flag194 = num5.EggIncome(param113) < minIncome
																																	end

																																	if flag194 then
																																		return false
																																	end

																																	if next(tbl87.Eggs) ~= nil and tbl87.Eggs[tostring(param113.AssetCategory)] ~= true then
																																		return false
																																	end
																																	return true
																																end

																																func168 = function()
																																	local eggState2 = tbl2.EggState
																																	if type(eggState2) ~= "table" or type(eggState2.ReadOwnerEggs) ~= "function" then
																																		return {}
																																	end
																																	local ok, result = pcall(eggState2.ReadOwnerEggs, localPlayer.UserId)
																																	if not ok or type(result) ~= "table" then
																																		return {}
																																	end
																																	local flag195 = num5.Toggle(value129, false) == true
																																	local Hatch = num5.RiftOn("Hatch") and num5.RiftShortfall() or {}
																																	local tbl88 = {}
																																	local tbl89 = {}

																																	for k, value130 in pairs(result) do
																																		local flag196 = type(value130) == "table" and value130.Placement ~= nil

																																		if flag196 then
																																			flag196 = (tbl86[k] or 0) <= os.clock()
																																		end

																																		if flag196 then
																																			local ok2, result2 = pcall(eggState2.IsReadyToHatch, k)

																																			if ok2 and result2 == true then
																																				local assetCategory6 = tostring(value130.AssetCategory)

																																				if (Hatch[assetCategory6] or 0) > 0 then
																																					Hatch[assetCategory6] = Hatch[assetCategory6] - 1
																																					table.insert(tbl88, k)
																																				elseif flag195 and func169(value130) then
																																					table.insert(tbl89, k)
																																				end
																																			end
																																		end
																																	end

																																	for _, item45 in ipairs(tbl89) do
																																		table.insert(tbl88, item45)
																																	end

																																	return tbl88
																																end
																															end
																														end

																														do
																															local function func170()
																																return num5.Toggle(value129, false) or num5.RiftOn("Hatch")
																															end

																															local function func171()
																																local flag197 = n44
																																local result32 = func168()
																																local n47 = 0

																																for _, item46 in ipairs(result32) do
																																	if not (n47 >= n45 or flag197 ~= n44 or not func170()) then
																																		local AskHatch, flag198 = func167("RF/EggWorld/AskHatch", item46)

																																		if AskHatch and flag198 ~= false then
																																			task.wait(0.35)
																																			func167("RF/EggWorld/AskFinishHatch", item46)
																																			n47 += 1
																																			tbl86[item46] = nil
																																		else
																																			tbl86[item46] = os.clock() + n46
																																		end

																																		task.wait(0.2)
																																		continue
																																	end

																																	break
																																end

																																return n47 > 0
																															end

																															tbl8.Add(function()
																																if not func170() or flag192 then
																																	return false
																																end
																																flag192 = true

																																task.spawn(function()
																																	pcall(func171)
																																	flag192 = false
																																end)

																																return false
																															end)
																														end
																													end

																													local hatch

																													do
																														hatch = function()
																															n44 += 1
																															table.clear(tbl86)
																															tbl8.Wake()
																														end

																														value129 = obj10:CreateToggle({
																															Name = "Auto Hatch",
																															Default = false,
																															Callback = hatch,
																														})

																														obj10:CreateDropdown({
																															Name = "Hatch Min Rarity",
																															Note = "Hatch eggs of the chosen rarity and every rarity above it",
																															Options = tbl26,
																															Default = tbl26[1],
																															SubOf = value129,
																															Callback = function(value)
																																tbl87.MinRarity = tbl27[value] or 0
																																hatch()
																															end,
																														})

																														do
																															local tbl90 = {
																																["K/s"] = {
																																	Min = 0,
																																	Max = 1000,
																																	Mult = 1000,
																																},
																																["M/s"] = {
																																	Min = 0,
																																	Max = 1000,
																																	Mult = 1000000,
																																},
																																["B/s"] = {
																																	Min = 0,
																																	Max = 100,
																																	Mult = 1e9,
																																},
																															}

																															local tbl91 = {
																																Slider = nil,
																																Value = 0,
																																Unit = "M/s",
																															}

																															local function func172(flag199, flag200)
																																if flag199 ~= nil then
																																	tbl91.Value = math.max(0, math.floor(tonumber(flag199) or tbl91.Value))
																																end

																																if flag200 ~= nil then
																																	tbl91.Unit = tostring(flag200)
																																end

																																tbl87.MinIncome = tbl91.Value * (tbl90[tbl91.Unit] or tbl90["M/s"]).Mult
																																hatch()
																															end

																															tbl91.Slider = func11(obj10, {
																																Name = "Min Hatch Value",
																																Note = "Skip eggs worth less than this (0 = off)",
																																SubOf = value129,
																																Legacy = "Hatch Min Value",
																																SectionName = "Auto Hatch & Equip",
																																OnRaw = function(num72)
																																	func172(math.floor(num72 / 1000), "K/s")
																																end,
																															})
																														end
																													end

																													do
																														local tbl92 = {}
																														local tbl93 = {}

																														if tbl2.Assets then
																															do
																																local directory = tbl2.Assets.Directory
																																local n45 = 0

																																while type(directory) ~= "table" do
																																	if n45 < 2 then
																																		n45 += task.wait(0.1)

																																		if type(tbl2.Assets) ~= "table" then
																																			tbl2.Assets = func6(function()
																																				return ReplicatedStorage.Data.Assets
																																			end)
																																		end

																																		directory = tbl2.Assets and tbl2.Assets.Directory
																																		continue
																																	end

																																	do
																																		local tbl94 = {}

																																		if type(directory) ~= "table" then
																																			table.sort(tbl94, function(param114, param115)
																																				if param114.Rarity ~= param115.Rarity then
																																					return param114.Rarity > param115.Rarity
																																				end
																																				return param114.Name < param115.Name
																																			end)

																																			for _, item47 in ipairs(tbl94) do
																																				local formatted4 = string.format("%s [%s]", item47.Name, item47.RarityName)

																																				if tbl93[formatted4] then
																																					formatted4 = string.format("%s [%s] (%s)", item47.Name, item47.RarityName, item47.Category)
																																				end

																																				table.insert(tbl92, formatted4)
																																				tbl93[formatted4] = item47.Category
																																			end

																																			if not (#tbl92 > 0) then
																																				local flag201

																																				do
																																					local n46, value131, flag202, n47, tbl95, n48, func173

																																					do
																																						num5.Rift.Restart.Hatch = hatch
																																						n46 = 5

																																						do
																																							local n49 = 30
																																							value131 = nil
																																							flag202 = false
																																							n47 = 0
																																							tbl95 = {}
																																							n48 = 0
																																							flag201 = true
																																							local value132 = nil
																																							local n50 = -math.huge

																																							func173 = function(flag203)
																																								local value133 = func6(function()
																																									return ReplicatedStorage.Data.Bases
																																								end)

																																								if type(value133) == "table" and type(value133.GetAssetEquipCapacity) == "function" then
																																									local ok, result = pcall(value133.GetAssetEquipCapacity, flag203 and tonumber(flag203.BaseUpgradeLevel) or 0)
																																									if ok and tonumber(result) then
																																										return math.floor(tonumber(result))
																																									end
																																								end

																																								if value132 and os.clock() - n50 < n49 then
																																									return value132
																																								end
																																								local rfPenRosterAskWearLimit = networking:FindFirstChild("RF/PenRoster/AskWearLimit")

																																								if rfPenRosterAskWearLimit and rfPenRosterAskWearLimit:IsA("RemoteFunction") then
																																									local ok, result = pcall(rfPenRosterAskWearLimit.InvokeServer, rfPenRosterAskWearLimit)

																																									if ok and tonumber(result) then
																																										local n51 = math.floor(tonumber(result))
																																										local now = os.clock()
																																										value132 = n51
																																										n50 = now
																																										return value132
																																									end
																																								end

																																								local value134 = value132
																																								local n51

																																								if value132 then
																																									n51 = value134
																																								else
																																									n51 = 0
																																								end

																																								return n51
																																							end
																																						end
																																					end
																																					-- https://discord.gg/x7YbZeezpm | 𝗦𝗟

																																					local func174

																																					do
																																						do
																																							local function func175(param116)
																																								local directory2 = tbl2.Assets and tbl2.Assets.Directory
																																								local flag204 = type(directory2) == "table" and directory2[tostring(param116.Category)] or nil
																																								local n49 = type(flag204) == "table" and tonumber(flag204.EarningRate) or 0
																																								local n50 = tonumber(param116.Scale) or 0
																																								if n49 <= 0 or n50 <= 0 then
																																									return 0
																																								end
																																								local n51 = n50 > 5 and (n50 / 5) ^ 1.2 * 19.637875755794113 or n50 ^ 1.85
																																								local mutations = tbl2.Mutations
																																								local flag205 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
																																								local n52 = 1

																																								if flag205 then
																																									local ok, result = pcall(mutations.EarningsFor, type(param116.Mutations) == "table" and param116.Mutations or {})
																																									ok = ok and type(result) == "number"
																																									local n53 = 1

																																									if ok then
																																										n52 = result
																																									else
																																										n52 = n53
																																									end
																																								end

																																								return n49 * n51 * n52
																																							end

																																							func174 = function()
																																								local save4 = tbl2.Save
																																								local result

																																								if type(save4) == "table" and type(save4.Get) == "function" then
																																									local ok
																																									ok, result = pcall(save4.Get)
																																									result = ok and type(result) == "table" and result or nil
																																								end

																																								if not result then
																																									return nil
																																								end
																																								local tbl96 = {}
																																								local tbl97 = {}
																																								local func176 = pairs
																																								local equippedAssets = result.EquippedAssets or {}

																																								for _, equippedAsset in func176(equippedAssets) do
																																									if type(equippedAsset) == "string" then
																																										tbl96[equippedAsset] = true
																																										table.insert(tbl97, equippedAsset)
																																									end
																																								end

																																								local tbl98 = {}
																																								local func177 = pairs
																																								local inventory = result.Inventory or {}

																																								for k, value135 in func177(inventory) do
																																									if type(value135) == "table" and value135.InFuse ~= true then
																																										table.insert(tbl98, { Uid = k, Income = func175(value135), Equipped = tbl96[k] == true })
																																									end
																																								end

																																								table.sort(tbl98, function(param117, param118)
																																									if param117.Income ~= param118.Income then
																																										return param117.Income > param118.Income
																																									end
																																									return tostring(param117.Uid) < tostring(param118.Uid)
																																								end)

																																								return tbl98, tbl96, #tbl97, result
																																							end
																																						end
																																					end

																																					do
																																						local function func178(list12, flag206)
																																							local tbl99 = {}
																																							local flag207 = false

																																							for i, item48 in ipairs(list12) do
																																								if not (flag206 < i) then
																																									if not item48.Equipped then
																																										table.insert(tbl99, item48.Uid)

																																										if not tbl95[item48.Uid] then
																																											flag207 = true
																																										end
																																									end

																																									continue
																																								end

																																								break
																																							end

																																							return tbl99, flag207
																																						end

																																						tbl8.Add(function()
																																							if not num5.Toggle(value131, false) then
																																								return false
																																							end
																																							local value136, value137, value138, value139 = func174()

																																							if value136 then
																																								local value140 = func173(value139)
																																								local value141, flag208 = func178(value136, value140)

																																								if (flag208 or flag201) and not flag202 and os.clock() >= n48 then
																																									for _, item49 in ipairs(value141) do
																																										tbl95[item49] = true
																																									end

																																									flag201 = false
																																									flag202 = true
																																									n48 = os.clock() + n46
																																									local flag209 = n47

																																									task.spawn(function()
																																										local rfHaulFetchWearBestStatus = networking:FindFirstChild("RF/Haul/FetchWearBestStatus")
																																										local isRemoteFunction = rfHaulFetchWearBestStatus and rfHaulFetchWearBestStatus:IsA("RemoteFunction")
																																										local flag210 = true

																																										if isRemoteFunction then
																																											local ok, result = pcall(rfHaulFetchWearBestStatus.InvokeServer, rfHaulFetchWearBestStatus)
																																											flag210 = ok and result ~= false and result ~= nil
																																										end

																																										local rfHaulWearBest = networking:FindFirstChild("RF/Haul/WearBest")

																																										if flag210 and flag209 == n47 and rfHaulWearBest and rfHaulWearBest:IsA("RemoteFunction") then
																																											pcall(rfHaulWearBest.InvokeServer, rfHaulWearBest)
																																										end

																																										flag202 = false
																																										tbl8.Wake()
																																									end)
																																								end
																																							end

																																							return false
																																						end)
																																					end

																																					value131 = obj10:CreateToggle({
																																						Name = "Auto Equip Best",
																																						Note = "Equip Best when a better pet appears",
																																						Default = false,
																																						Callback = function()
																																							n47 += 1
																																							table.clear(tbl95)
																																							n48 = 0
																																							flag201 = true
																																							tbl8.Wake()
																																						end,
																																					})
																																				end

																																				do
																																					local save4 = tbl2.Save

																																					if type(save4) == "table" and type(save4.FieldSignal) == "function" then
																																						for _, item50 in ipairs({
																																							"Inventory",
																																							"EquippedAssets",
																																						}) do
																																							local ok, result = pcall(save4.FieldSignal, item50)

																																							if ok and type(result) == "table" and type(result.Connect) == "function" then
																																								local ok2, result2 = pcall(result.Connect, result, function()
																																									flag201 = true
																																									tbl8.Wake()
																																								end)

																																								if ok2 and result2 then
																																									func10(function()
																																										pcall(function()
																																											result2:Disconnect()
																																										end)
																																									end)
																																								end
																																							end
																																						end
																																					end
																																				end

																																				do
																																					local n46 = 3
																																					local n47 = 50

																																					local tbl100 = {
																																						"Rarity Only",
																																						"Value Only",
																																						"Rarity And Value",
																																						"Rarity Or Value",
																																					}

																																					local value142 = func6(function()
																																						return ReplicatedStorage.Shared.Util.AssetItems
																																					end)

																																					local tbl101 = {}
																																					local tbl102 = {}
																																					local tbl103 = {}
																																					local tbl104 = {}
																																					local directory2 = tbl2.Assets and tbl2.Assets.Directory
																																					local tbl105 = {}
																																					local tbl106 = {}

																																					if type(directory2) ~= "table" then
																																						local func179, value143, value144, flag211, n48, flag212, tbl107, flag213, n49, n50
																																						local flag214, tbl108, func180, func181, func182

																																						do
																																							do
																																								local tbl109 = {}

																																								for k in pairs(tbl105) do
																																									table.insert(tbl109, k)
																																								end

																																								table.sort(tbl109)

																																								for _, item51 in ipairs(tbl109) do
																																									local formatted5 = string.format("%d - %s", item51, tbl105[item51])
																																									table.insert(tbl101, formatted5)
																																									tbl102[formatted5] = item51
																																								end
																																							end

																																							do
																																								local flag215, flag216, n51, flag217, n52, func183, func184

																																								do
																																									table.sort(tbl106, function(param119, param120)
																																										if param119.Rarity ~= param120.Rarity then
																																											return param119.Rarity < param120.Rarity
																																										end
																																										return param119.Name < param120.Name
																																									end)

																																									for _, item52 in ipairs(tbl106) do
																																										local formatted6 = string.format("%s [%s]", item52.Name, item52.RarityName)

																																										if tbl104[formatted6] then
																																											formatted6 = string.format("%s [%s] (%s)", item52.Name, item52.RarityName, item52.Category)
																																										end

																																										table.insert(tbl103, formatted6)
																																										tbl104[formatted6] = item52.Category
																																									end

																																									func179 = function(param121)
																																										for _, item53 in ipairs(tbl101) do
																																											if tbl102[item53] == param121 then
																																												return item53
																																											end
																																										end

																																										return tbl101[1]
																																									end

																																									value143 = nil
																																									value144 = nil
																																									flag215 = nil
																																									flag211 = nil
																																									flag216 = tbl100[1]
																																									n51 = 3
																																									n48 = 0
																																									flag212 = true
																																									tbl107 = {}
																																									flag213 = tbl100[1]
																																									n49 = 3
																																									n50 = 0
																																									flag214 = true
																																									tbl108 = {}
																																									flag217 = false
																																									n52 = 0

																																									func183 = function(param122)
																																										local n53 = tonumber(param122) or 0
																																										local tbl110 = { "", "K", "M", "B", "T", "Qa", "Qi" }
																																										local n54 = 1

																																										while math.abs(n53) >= 1000 and n54 < #tbl110 do
																																											n53 /= 1000
																																											n54 += 1
																																										end

																																										return string.format(n54 == 1 and "$%.0f%s" or "$%.2f%s", n53, tbl110[n54])
																																									end

																																									func180 = function(list13, tbl111)
																																										local tbl112 = {}

																																										if type(list13) == "table" then
																																											for k, value145 in pairs(list13) do
																																												k = value145 == true and type(k) == "string" and k or type(value145) == "string" and value145 or nil

																																												if k then
																																													tbl112[tbl111 and tbl111[k] or k] = true
																																												end
																																											end
																																										end

																																										return tbl112
																																									end

																																									do
																																										local function func185(param123)
																																											local directory3 = tbl2.Assets and tbl2.Assets.Directory
																																											local flag218 = type(directory3) == "table" and directory3[tostring(param123)] or nil
																																											local rarity = type(flag218) == "table" and flag218.Rarity or nil
																																											local flag219 = type(rarity) == "table"

																																											if flag219 then
																																												flag219 = tonumber(rarity.RarityNumber or rarity.Rank)
																																											end

																																											return flag219 or math.huge
																																										end

																																										local function func186(param124)
																																											local directory3 = tbl2.Assets and tbl2.Assets.Directory
																																											local flag220 = type(directory3) == "table" and directory3[tostring(param124.Category)] or nil
																																											local n53 = type(flag220) == "table" and tonumber(flag220.EarningRate) or 0
																																											local n54 = tonumber(param124.Scale) or 0
																																											if n53 <= 0 or n54 <= 0 then
																																												return 0
																																											end
																																											local n55 = n54 > 5 and (n54 / 5) ^ 1.2 * 19.637875755794113 or n54 ^ 1.85
																																											local mutations = tbl2.Mutations
																																											local flag221 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
																																											local n56 = 1

																																											if flag221 then
																																												local ok, result = pcall(mutations.EarningsFor, type(param124.Mutations) == "table" and param124.Mutations or {})

																																												if ok and type(result) == "number" then
																																													n56 = result
																																												end
																																											end

																																											return n53 * n55 * n56
																																										end

																																										local function func187(param125)
																																											return type(param125) == "table" and next(param125) ~= nil
																																										end

																																										local function func188()
																																											local save4 = tbl2.Save
																																											if type(save4) ~= "table" or type(save4.Get) ~= "function" then
																																												return nil
																																											end
																																											local ok, result = pcall(save4.Get)
																																											return ok and type(result) == "table" and result or nil
																																										end

																																										func184 = function()
																																											local result33 = func188()
																																											local tbl113 = {}
																																											if not result33 then
																																												return tbl113, 0
																																											end
																																											local tbl114 = {}
																																											local func189 = pairs
																																											local equippedAssets = result33.EquippedAssets or {}

																																											for _, equippedAsset in func189(equippedAssets) do
																																												tbl114[equippedAsset] = true
																																											end

																																											local func190 = pairs
																																											local inventory = result33.Inventory or {}
																																											local n53 = 0

																																											for k, value146 in func190(inventory) do
																																												local flag222 = type(value146) == "table" and value146.InFuse ~= true and value146.IsFavorite ~= true and not tbl114[k] and not tbl107[tostring(value146.Category)]

																																												if flag222 then
																																													flag222 = not (flag212 and func187(value146.Mutations))
																																												end

																																												if flag222 then
																																													local num73 = func186(value146)
																																													local category2 = func185(value146.Category) <= n51
																																													local flag223 = n48 > 0 and num73 < n48

																																													if flag216 ~= tbl100[2] then
																																														if flag216 == tbl100[3] then
																																															flag223 = category2 and flag223
																																														elseif flag216 == tbl100[4] then
																																															flag223 = category2 or flag223
																																														else
																																															flag223 = category2
																																														end
																																													end

																																													if flag223 then
																																														table.insert(tbl113, k)
																																														local flag224 = type(value142) == "table" and type(value142.SalePrice) == "function"
																																														local flag225 = false
																																														local result = nil

																																														if flag224 then
																																															flag225, result = pcall(value142.SalePrice, value146)
																																														end

																																														n53 += flag225 and tonumber(result) or num73 * 100
																																													end
																																												end
																																											end

																																											return tbl113, n53
																																										end

																																										func181 = function()
																																											local tbl115 = {}
																																											local eggState2 = tbl2.EggState
																																											if type(eggState2) ~= "table" or type(eggState2.ReadOwnerEggs) ~= "function" then
																																												return tbl115, 0
																																											end
																																											local ok, result = pcall(eggState2.ReadOwnerEggs, localPlayer.UserId)
																																											if not ok or type(result) ~= "table" then
																																												return tbl115, 0
																																											end
																																											local character = localPlayer.Character
																																											character = character and character:FindFirstChildWhichIsA("Tool")
																																											character = character and character:GetAttribute("UID") or nil
																																											local eggRecords = tbl2.EggRecords
																																											local value147, value148, value149 = pairs(result)
																																											local n53 = 0

																																											for k, value150 in value147, value148, value149 do
																																												local flag226 = type(value150) == "table" and value150.Placement == nil and k ~= character and not tbl108[tostring(value150.AssetCategory)]

																																												if flag226 then
																																													flag226 = not (flag214 and func187(value150.Mutations))
																																												end

																																												if flag226 then
																																													local flag227 = func186({ Category = value150.AssetCategory, Scale = value150.AssetScale, Mutations = value150.Mutations })
																																													local assetCategory7 = func185(value150.AssetCategory) <= n49
																																													local flag228 = n50 > 0 and flag227 < n50

																																													if flag213 ~= tbl100[2] then
																																														if flag213 == tbl100[3] then
																																															flag228 = assetCategory7 and flag228
																																														elseif flag213 ~= tbl100[4] then
																																															flag228 = assetCategory7
																																														else
																																															flag228 = assetCategory7 or flag228
																																														end
																																													end

																																													if flag228 then
																																														table.insert(tbl115, k)

																																														if type(eggRecords) == "table" and type(eggRecords.SellPrice) == "function" then
																																															local ok2, result2 = pcall(eggRecords.SellPrice, value150)
																																															n53 += ok2 and tonumber(result2) or 0
																																														end
																																													end
																																												end
																																											end

																																											return tbl115, n53
																																										end
																																									end
																																								end

																																								do
																																									local function func191(list14, list15)
																																										local rePetSatchelSellSelection = networking:FindFirstChild("RE/PetSatchel/SellSelection")
																																										if not rePetSatchelSellSelection or not rePetSatchelSellSelection:IsA("RemoteEvent") then
																																											return false
																																										end
																																										local n53 = math.max(#list14, #list15)
																																										local n54 = 1

																																										while n54 <= n53 do
																																											local tbl116 = {}
																																											local tbl117 = {}

																																											for i = n54, n54 + n47 - 1 do
																																												if list14[i] then
																																													table.insert(tbl116, list14[i])
																																												end

																																												if list15[i] then
																																													table.insert(tbl117, list15[i])
																																												end
																																											end

																																											pcall(rePetSatchelSellSelection.FireServer, rePetSatchelSellSelection, { Eggs = tbl117, Assets = tbl116 })
																																											n54 += n47

																																											if n54 <= n53 then
																																												task.wait(0.3)
																																											end
																																										end

																																										return true
																																									end

																																									func182 = function(list16, list17)
																																										local flag229 = flag217

																																										if not flag217 then
																																											flag229 = #list16 == 0 and #list17 == 0
																																										end

																																										if flag229 then
																																											return
																																										end
																																										flag217 = true
																																										n52 = os.clock() + n46

																																										task.spawn(function()
																																											pcall(func191, list16, list17)
																																											flag217 = false
																																											tbl8.Wake()
																																										end)
																																									end
																																								end

																																								tbl8.Add(function()
																																									local flag230 = num5.Toggle(value143, false)
																																									local flag231 = num5.Toggle(value144, false)
																																									local list18, value151 = func184()
																																									local list19, value152 = func181()

																																									if flag215 and type(flag215.Set) == "function" then
																																										pcall(flag215.Set, flag215, string.format("Pet matches  -  %d pets for %s", #list18, func183(value151)))
																																									end

																																									if flag211 and type(flag211.Set) == "function" then
																																										pcall(flag211.Set, flag211, string.format("Egg matches  -  %d eggs for %s", #list19, func183(value152)))
																																									end

																																									local value153 = flag217
																																									local flag232

																																									if flag217 then
																																										flag232 = value153
																																									else
																																										flag232 = os.clock() < n52
																																									end

																																									local flag233

																																									if flag232 then
																																										flag233 = flag232
																																									else
																																										flag233 = not (flag230 or flag231)
																																									end

																																									if flag233 then
																																										return false
																																									end
																																									func182(flag230 and list18 or {}, flag231 and list19 or {})
																																									return false
																																								end)

																																								flag215 = obj11:CreateText({
																																									Name = "Pet Sell Preview",
																																									Text = "Pet matches  -  0 pets",
																																								})

																																								value143 = obj11:CreateToggle({
																																									Name = "Auto Sell Pet",
																																									Default = false,
																																									Callback = function()
																																										tbl8.Wake()
																																									end,
																																								})

																																								obj11:CreateButton({
																																									Name = "Sell Pets Now",
																																									ButtonText = "Sell",
																																									ConfirmText = "Sold!",
																																									SubOf = value143,
																																									Callback = function()
																																										func182(func184(), {})
																																									end,
																																								})

																																								obj11:CreateDropdown({
																																									Name = "Sell Pet Rule",
																																									Note = "Which checks must pass to sell",
																																									Options = tbl100,
																																									Default = tbl100[1],
																																									SubOf = value143,
																																									Callback = function(value)
																																										if table.find(tbl100, value) then
																																											flag216 = value
																																											tbl8.Wake()
																																										end
																																									end,
																																								})

																																								obj11:CreateDropdown({
																																									Name = "Pet Max Rarity",
																																									Note = "Sell pets at or below this rarity",
																																									Options = tbl101,
																																									Default = func179(3),
																																									SubOf = value143,
																																									Callback = function(value)
																																										n51 = tbl102[value] or n51
																																										tbl8.Wake()
																																									end,
																																								})
																																							end
																																						end

																																						do
																																							do
																																								local func192

																																								do
																																									local tbl118 = {
																																										["K/s"] = {
																																											Min = 0,
																																											Max = 1000,
																																											Mult = 1000,
																																										},
																																										["M/s"] = {
																																											Min = 0,
																																											Max = 1000,
																																											Mult = 1000000,
																																										},
																																										["B/s"] = {
																																											Min = 0,
																																											Max = 100,
																																											Mult = 1e9,
																																										},
																																									}

																																									func192 = function(flag234, param126, param127, callback8)
																																										local n51 = 0
																																										local str15 = "M/s"

																																										local function func193(flag235, flag236)
																																											if flag235 ~= nil then
																																												n51 = math.max(0, math.floor(tonumber(flag235) or n51))
																																											end

																																											if flag236 ~= nil then
																																												str15 = tostring(flag236)
																																											end

																																											callback8(n51 * (tbl118[str15] or tbl118["M/s"]).Mult)
																																											tbl8.Wake()
																																										end

																																										return (func11(obj11, {
																																											Name = flag234 == "Pet Value Threshold" and "Pet Sell Value" or flag234 == "Egg Value Threshold" and "Egg Sell Value" or flag234,
																																											Note = param126,
																																											SubOf = param127,
																																											Legacy = flag234,
																																											SectionName = "Auto Sell",
																																											OnRaw = function(num74)
																																												func193(math.floor(num74 / 1000), "K/s")
																																											end,
																																										}))
																																									end
																																								end

																																								func192("Pet Value Threshold", "Sell pets worth less than this (0 = off)", value143, function(param128)
																																									n48 = param128
																																								end)

																																								do
																																									local value154 = nil

																																									value154 = obj11:CreateToggle({
																																										Name = "Keep Mutated Pets",
																																										Note = "Never sell mutated pets",
																																										Default = true,
																																										SubOf = value143,
																																										Callback = function()
																																											flag212 = num5.Toggle(value154, true)
																																											tbl8.Wake()
																																										end,
																																									})
																																								end

																																								func16(obj11:CreateMultiDropdown({
																																									Name = "Blacklist Sell Pets",
																																									Note = "These pets are never sold",
																																									Options = tbl103,
																																									Default = {},
																																									SubOf = value143,
																																									Callback = function(value)
																																										tbl107 = func180(value, tbl104)
																																										tbl8.Wake()
																																									end,
																																								}))

																																								flag211 = obj11:CreateText({
																																									Name = "Egg Sell Preview",
																																									Text = "Egg matches  -  0 eggs",
																																								})

																																								value144 = obj11:CreateToggle({
																																									Name = "Auto Sell Egg",
																																									Note = "Sell bag eggs matching the rules below",
																																									Default = false,
																																									Callback = function()
																																										tbl8.Wake()
																																									end,
																																								})

																																								obj11:CreateButton({
																																									Name = "Sell Eggs Now",
																																									Note = "Sell matching eggs once",
																																									ButtonText = "Sell",
																																									ConfirmText = "Sold!",
																																									SubOf = value144,
																																									Callback = function()
																																										local result34 = func181()
																																										func182({}, result34)
																																									end,
																																								})

																																								obj11:CreateDropdown({
																																									Name = "Sell Egg Rule",
																																									Note = "Which checks must pass to sell",
																																									Options = tbl100,
																																									Default = tbl100[1],
																																									SubOf = value144,
																																									Callback = function(value)
																																										if table.find(tbl100, value) then
																																											flag213 = value
																																											tbl8.Wake()
																																										end
																																									end,
																																								})

																																								obj11:CreateDropdown({
																																									Name = "Egg Max Rarity",
																																									Note = "Sell eggs at or below this rarity",
																																									Options = tbl101,
																																									Default = func179(3),
																																									SubOf = value144,
																																									Callback = function(value)
																																										n49 = tbl102[value] or n49
																																										tbl8.Wake()
																																									end,
																																								})

																																								func192("Egg Value Threshold", "Sell eggs worth less than this (0 = off)", value144, function(param129)
																																									n50 = param129
																																								end)
																																							end

																																							do
																																								local value155 = nil

																																								value155 = obj11:CreateToggle({
																																									Name = "Keep Mutated Eggs",
																																									Note = "Never sell mutated eggs",
																																									Default = true,
																																									SubOf = value144,
																																									Callback = function()
																																										flag214 = num5.Toggle(value155, true)
																																										tbl8.Wake()
																																									end,
																																								})
																																							end

																																							func16(obj11:CreateMultiDropdown({
																																								Name = "Blacklist Sell Eggs",
																																								Note = "These eggs are never sold",
																																								Options = tbl103,
																																								Default = {},
																																								SubOf = value144,
																																								Callback = function(value)
																																									tbl108 = func180(value, tbl104)
																																									tbl8.Wake()
																																								end,
																																							}))

																																							do
																																								local save4 = tbl2.Save

																																								if type(save4) == "table" and type(save4.FieldSignal) == "function" then
																																									for _, item54 in ipairs({
																																										"Inventory",
																																										"EggInventory",
																																										"EquippedAssets",
																																									}) do
																																										local ok, result = pcall(save4.FieldSignal, item54)

																																										if ok and type(result) == "table" and type(result.Connect) == "function" then
																																											local ok2, result2 = pcall(result.Connect, result, function()
																																												tbl8.Wake()
																																											end)

																																											if ok2 and result2 then
																																												func10(function()
																																													pcall(function()
																																														result2:Disconnect()
																																													end)
																																												end)
																																											end
																																										end
																																									end
																																								end
																																							end
																																						end

																																						do
																																							local n51 = 2
																																							local n52 = 3
																																							local n53 = 20

																																							local tbl119 = {
																																								"Lowest Rarity First",
																																								"Highest Rarity First",
																																								"Most Copies First",
																																								"Lowest Value First",
																																							}

																																							local tbl120 = {
																																								"Lowest To Highest",
																																								"Highest To Lowest",
																																							}

																																							local list20 = {}
																																							local tbl121 = {}
																																							local tbl122 = {}
																																							local tbl123 = {}

																																							if tbl2.Assets then
																																								local value156, flag237, flag238

																																								do
																																									local func194, flag239, flag240, flag241, n54, tbl124, flag242, n55, n56, n57
																																									local tbl125, func195, func196, func197, func198, func199

																																									do
																																										do
																																											local tbl126, tbl127

																																											do
																																												local directory3 = tbl2.Assets.Directory
																																												tbl126 = {}
																																												tbl127 = {}

																																												if type(directory3) == "table" then
																																													for k, value157 in pairs(directory3) do
																																														local rarity = type(value157) == "table" and value157.Rarity or nil
																																														local flag243 = type(rarity) == "table"

																																														if flag243 then
																																															flag243 = tonumber(rarity.RarityNumber or rarity.Rank)
																																														end

																																														local value158 = flag243 or nil

																																														if value158 then
																																															local rarityName = tostring(rarity.DisplayName or rarity._id or value158)
																																															tbl126[value158] = tbl126[value158] or rarityName
																																															local insert = table.insert

																																															local tbl128 = {
																																																Category = tostring(k),
																																															}

																																															local func200 = tostring
																																															k = value157.DisplayName or k
																																															tbl128.Name = func200(k)
																																															tbl128.Rarity = value158
																																															tbl128.RarityName = rarityName
																																															insert(tbl127, tbl128)
																																														end
																																													end
																																												end
																																											end

																																											do
																																												local tbl129 = {}

																																												for k in pairs(tbl126) do
																																													table.insert(tbl129, k)
																																												end

																																												table.sort(tbl129)

																																												for _, item55 in ipairs(tbl129) do
																																													local formatted7 = string.format("%d - %s", item55, tbl126[item55])
																																													table.insert(list20, formatted7)
																																													tbl121[formatted7] = item55
																																												end
																																											end

																																											table.sort(tbl127, function(param130, param131)
																																												if param130.Rarity ~= param131.Rarity then
																																													return param130.Rarity < param131.Rarity
																																												end
																																												return param130.Name < param131.Name
																																											end)

																																											for _, item56 in ipairs(tbl127) do
																																												local formatted8 = string.format("%s [%s]", item56.Name, item56.RarityName)

																																												if tbl123[formatted8] then
																																													formatted8 = string.format("%s [%s] (%s)", item56.Name, item56.RarityName, item56.Category)
																																												end

																																												table.insert(tbl122, formatted8)
																																												tbl123[formatted8] = item56.Category
																																											end
																																										end

																																										func194 = function(param132)
																																											for _, item57 in ipairs(list20) do
																																												if tbl121[item57] == param132 then
																																													return item57
																																												end
																																											end

																																											return list20[#list20]
																																										end

																																										value156 = nil
																																										flag239 = nil
																																										flag240 = tbl119[1]
																																										flag241 = tbl120[1]
																																										n54 = 6
																																										tbl124 = {}
																																										flag237 = true
																																										flag238 = true
																																										flag242 = false
																																										n55 = 0
																																										n56 = 0
																																										n57 = 0
																																										tbl125 = {}

																																										func195 = function(childName8, flag244)
																																											local obj35 = networking:FindFirstChild(childName8)
																																											if not obj35 or not obj35:IsA("RemoteFunction") then
																																												return false, nil
																																											end

																																											if flag244 == nil then
																																												return pcall(obj35.InvokeServer, obj35)
																																											end
																																											return pcall(obj35.InvokeServer, obj35, flag244)
																																										end

																																										func196 = function()
																																											local save4 = tbl2.Save
																																											if type(save4) ~= "table" or type(save4.Get) ~= "function" then
																																												return nil
																																											end
																																											local ok, result = pcall(save4.Get)
																																											return ok and type(result) == "table" and result or nil
																																										end

																																										do
																																											local function func201(param133)
																																												local directory3 = tbl2.Assets and tbl2.Assets.Directory
																																												return type(directory3) == "table" and directory3[tostring(param133)] or nil
																																											end

																																											func197 = function(param134)
																																												local value159 = func201(param134)
																																												local rarity = type(value159) == "table" and value159.Rarity or nil
																																												local flag245 = type(rarity) == "table"

																																												if flag245 then
																																													flag245 = tonumber(rarity.RarityNumber or rarity.Rank)
																																												end

																																												return flag245 or math.huge
																																											end

																																											func198 = function(param135)
																																												local value160 = func201(param135)
																																												return tostring(type(value160) == "table" and value160.DisplayName or param135)
																																											end

																																											func199 = function(param136)
																																												local category3 = func201(param136.Category)
																																												local n58 = type(category3) == "table" and tonumber(category3.EarningRate) or 0
																																												local n59 = tonumber(param136.Scale) or 0
																																												if n58 <= 0 or n59 <= 0 then
																																													return 0
																																												end
																																												local n60 = n59 > 5 and (n59 / 5) ^ 1.2 * 19.637875755794113 or n59 ^ 1.85
																																												local mutations = tbl2.Mutations
																																												local flag246 = type(mutations) == "table" and type(mutations.EarningsFor) == "function"
																																												local n61 = 1

																																												if flag246 then
																																													local ok
																																													ok, n61 = pcall(mutations.EarningsFor, type(param136.Mutations) == "table" and param136.Mutations or {})
																																													local flag247 = ok and type(n61) == "number"
																																													local n62 = 1

																																													if not flag247 then
																																														n61 = n62
																																													end
																																												end

																																												return n58 * n60 * n61
																																											end
																																										end
																																									end

																																									local func202, func203, func204

																																									do
																																										do
																																											local function func205(param137)
																																												return type(param137) == "table" and next(param137) ~= nil
																																											end

																																											func202 = function(param138)
																																												local n58 = tonumber(param138) or 0
																																												local tbl130 = { "", "K", "M", "B", "T", "Qa", "Qi" }
																																												local n59 = 1

																																												while math.abs(n58) >= 1000 and n59 < #tbl130 do
																																													n58 /= 1000
																																													n59 += 1
																																												end

																																												return string.format(n59 == 1 and "$%.0f%s" or "$%.2f%s", n58, tbl130[n59])
																																											end

																																											func203 = function(param139)
																																												local fuseKernel = tbl2.FuseKernel
																																												if type(fuseKernel) ~= "table" or type(fuseKernel.PriceFor) ~= "function" then
																																													return nil
																																												end
																																												local ok, result = pcall(fuseKernel.PriceFor, param139)
																																												return ok and tonumber(result) or nil
																																											end

																																											local function func206(param140, param141, tbl131)
																																												local flag248 = type(param141) == "table" and param141.IsFavorite ~= true and not tbl131[param140] and func197(param141.Category) <= n54 and (next(tbl124) == nil or tbl124[tostring(param141.Category)] == true)
																																												local flag249

																																												if flag248 then
																																													flag249 = not (flag237 and func205(param141.Mutations))
																																												else
																																													flag249 = flag248
																																												end

																																												if flag249 then
																																													flag249 = (tbl125[param140] or 0) <= os.clock()
																																												end

																																												return flag249
																																											end

																																											func204 = function(param142)
																																												local inventory = type(param142.Inventory) == "table" and param142.Inventory or {}
																																												local tbl132 = {}
																																												local func207 = pairs
																																												local equippedAssets = param142.EquippedAssets or {}

																																												for _, equippedAsset in func207(equippedAssets) do
																																													tbl132[equippedAsset] = true
																																												end

																																												local tbl133 = {}
																																												local tbl134 = {}

																																												for i = 1, 3 do
																																													local fusionSlots = type(param142.FusionSlots) == "table" and param142.FusionSlots[i] or nil

																																													if fusionSlots ~= nil and type(inventory[fusionSlots]) == "table" then
																																														table.insert(tbl133, fusionSlots)
																																														tbl134[fusionSlots] = true
																																													end
																																												end

																																												local tbl135 = {}

																																												for k, value161 in pairs(inventory) do
																																													if not tbl134[k] and type(value161) == "table" and value161.InFuse ~= true and func206(k, value161, tbl132) then
																																														local category4 = tostring(value161.Category)
																																														tbl135[category4] = tbl135[category4] or {}
																																														table.insert(tbl135[category4], { Uid = k, Item = value161, Income = func199(value161) })
																																													end
																																												end

																																												local function func208(param143)
																																													table.sort(param143, function(param144, param145)
																																														if param144.Income ~= param145.Income then
																																															if flag241 == tbl120[2] then
																																																return param144.Income > param145.Income
																																															end
																																															return param144.Income < param145.Income
																																														end

																																														return tostring(param144.Uid) < tostring(param145.Uid)
																																													end)
																																												end

																																												if #tbl133 > 0 then
																																													local str16 = tostring(inventory[tbl133[1]].Category)
																																													local flag250 = true

																																													for _, item58 in ipairs(tbl133) do
																																														local entry7 = inventory[item58]

																																														if tostring(entry7.Category) ~= str16 or not func206(item58, entry7, tbl132) then
																																															flag250 = false
																																														end
																																													end

																																													local list21 = tbl135[str16] or {}

																																													if flag250 and #tbl133 + #list21 >= 3 then
																																														func208(list21)
																																														local tbl136 = { Category = str16, Load = {}, Items = {} }

																																														for _, item59 in ipairs(tbl133) do
																																															table.insert(tbl136.Items, inventory[item59])
																																														end

																																														for i = 1, 3 - #tbl133 do
																																															table.insert(tbl136.Load, list21[i].Uid)
																																															table.insert(tbl136.Items, list21[i].Item)
																																														end

																																														return tbl136
																																													end

																																													if flag238 then
																																														return { Category = str16, Eject = tbl133 }
																																													end
																																													return nil, "Machine holds pets that cannot finish a fuse"
																																												end

																																												local value162 = nil
																																												local value163 = nil

																																												for k, value164 in pairs(tbl135) do
																																													if #value164 >= 3 then
																																														local num75 = func197(k)
																																														local n58 = 0

																																														for _, item60 in ipairs(value164) do
																																															n58 += item60.Income
																																														end

																																														local tbl137

																																														if flag240 == tbl119[2] then
																																															tbl137 = { -num75, -#value164 }
																																														elseif flag240 == tbl119[3] then
																																															tbl137 = { -#value164, num75 }
																																														elseif flag240 == tbl119[4] then
																																															tbl137 = { n58 / #value164, num75 }
																																														else
																																															tbl137 = { num75, -#value164 }
																																														end

																																														local flag251 = value162 == nil or tbl137[1] < value162[1]
																																														local flag252

																																														if flag251 then
																																															flag252 = flag251
																																														else
																																															local flag253 = tbl137[1] == value162[1]

																																															if flag253 then
																																																local flag254 = tbl137[2] < value162[2]

																																																if flag254 then
																																																	flag252 = flag254
																																																else
																																																	flag252 = tbl137[2] == value162[2] and k < value163
																																																end
																																															else
																																																flag252 = flag253
																																															end
																																														end

																																														if flag252 then
																																															value162 = tbl137
																																															value163 = k
																																														end
																																													end
																																												end

																																												if not value163 then
																																													return nil, "No three matching pets"
																																												end
																																												local entry8 = tbl135[value163]
																																												func208(entry8)
																																												local tbl138 = { Category = value163, Load = {}, Items = {} }

																																												for i = 1, 3 do
																																													table.insert(tbl138.Load, entry8[i].Uid)
																																													table.insert(tbl138.Items, entry8[i].Item)
																																												end

																																												return tbl138
																																											end
																																										end
																																									end

																																									do
																																										local function func209(flag255)
																																											local result35 = func196()
																																											if not result35 then
																																												return
																																											end

																																											if result35.FusionLocked == true then
																																												if type(result35.FusionEggReward) == "table" and os.clock() >= n57 then
																																													n57 = os.clock() + n52
																																													func195("RF/Fusery/FinishReveal")
																																												end

																																												return
																																											end

																																											local flag256 = func204(result35)
																																											if not flag256 then
																																												return
																																											end

																																											if flag256.Eject then
																																												for _, item61 in ipairs(flag256.Eject) do
																																													if flag255 ~= n55 then
																																														return
																																													end
																																													func195("RF/Fusery/EjectPet", item61)
																																													task.wait(0.35)
																																												end

																																												return
																																											end

																																											local items = func203(flag256.Items)
																																											local money = tonumber(result35.Money)
																																											if items and money and money < items then
																																												return
																																											end

																																											for _, item62 in ipairs(flag256.Load) do
																																												if flag255 ~= n55 then
																																													return
																																												end
																																												local LoadPet, flag257 = func195("RF/Fusery/LoadPet", item62)
																																												if not LoadPet or flag257 == false then
																																													tbl125[item62] = os.clock() + n53
																																													return
																																												end
																																												task.wait(0.35)
																																											end

																																											if flag255 ~= n55 then
																																												return
																																											end
																																											local BeginFuse, flag258 = func195("RF/Fusery/BeginFuse")

																																											if BeginFuse and flag258 ~= false then
																																												n57 = os.clock() + n52
																																											end
																																										end

																																										local function func210(flag259)
																																											if not flag259 then
																																												return "Fuse status unknown"
																																											end

																																											if flag259.FusionLocked == true then
																																												return "Machine is fusing, waiting for the egg"
																																											end
																																											local list22, flag260 = func204(flag259)
																																											if not list22 then
																																												return flag260 or "No three matching pets"
																																											end

																																											if list22.Eject then
																																												return string.format("Would eject %d %s that cannot finish a fuse", #list22.Eject, func198(list22.Category))
																																											end
																																											local items2 = func203(list22.Items)
																																											local money2 = tonumber(flag259.Money)
																																											local str17 = items2 and money2 and money2 < items2 and "  (not enough money)" or ""
																																											return string.format("Next fuse  -  3 %s for %s%s", func198(list22.Category), items2 and func202(items2) or "?", str17)
																																										end

																																										tbl8.Add(function()
																																											local result36 = func196()

																																											if flag239 and type(flag239.Set) == "function" then
																																												pcall(flag239.Set, flag239, func210(result36))
																																											end

																																											if not num5.Toggle(value156, false) or flag242 or os.clock() < n56 then
																																												return false
																																											end
																																											flag242 = true
																																											n56 = os.clock() + n51
																																											local value165 = n55

																																											task.spawn(function()
																																												pcall(func209, value165)
																																												flag242 = false
																																												tbl8.Wake()
																																											end)

																																											return false
																																										end)
																																									end

																																									flag239 = obj12:CreateText({
																																										Name = "Fuse Preview",
																																										Text = "Fuse status unknown",
																																									})

																																									value156 = obj12:CreateToggle({
																																										Name = "Auto Fuse Machine",
																																										Note = "Fuse 3 same pets into an egg, nonstop",
																																										Default = false,
																																										Callback = function()
																																											n55 += 1
																																											table.clear(tbl125)
																																											n56 = 0
																																											tbl8.Wake()
																																										end,
																																									})

																																									obj12:CreateDropdown({
																																										Name = "Fuse Priority Mode",
																																										Options = tbl119,
																																										Default = tbl119[1],
																																										SubOf = value156,
																																										Callback = function(value)
																																											if table.find(tbl119, value) then
																																												flag240 = value
																																												tbl8.Wake()
																																											end
																																										end,
																																									})

																																									obj12:CreateDropdown({
																																										Name = "Pets To Use",
																																										Options = tbl120,
																																										Default = tbl120[1],
																																										SubOf = value156,
																																										Callback = function(value)
																																											if table.find(tbl120, value) then
																																												flag241 = value
																																												tbl8.Wake()
																																											end
																																										end,
																																									})

																																									obj12:CreateDropdown({
																																										Name = "Max Rarity to Fuse",
																																										Options = list20,
																																										Default = func194(6),
																																										SubOf = value156,
																																										Callback = function(value)
																																											n54 = tbl121[value] or n54
																																											tbl8.Wake()
																																										end,
																																									})

																																									func16(obj12:CreateMultiDropdown({
																																										Name = "Specific Species to Fuse",
																																										Note = "Only fuse these species (empty = all)",
																																										Options = tbl122,
																																										Default = {},
																																										SubOf = value156,
																																										Callback = function(value)
																																											local tbl139 = {}

																																											if type(value) == "table" then
																																												for k, value166 in pairs(value) do
																																													k = value166 == true and type(k) == "string" and k

																																													if k then
																																														value166 = k
																																													else
																																														value166 = type(value166) == "string" and value166
																																													end

																																													value166 = value166 or nil

																																													if value166 and tbl123[value166] then
																																														tbl139[tbl123[value166]] = true
																																													end
																																												end
																																											end

																																											tbl124 = tbl139
																																											tbl8.Wake()
																																										end,
																																									}))
																																								end

																																								do
																																									do
																																										local value167 = nil

																																										value167 = obj12:CreateToggle({
																																											Name = "Skip Mutated Pets",
																																											Default = true,
																																											SubOf = value156,
																																											Callback = function()
																																												flag237 = num5.Toggle(value167, true)
																																												tbl8.Wake()
																																											end,
																																										})
																																									end

																																									do
																																										local value168 = nil

																																										value168 = obj12:CreateToggle({
																																											Name = "Eject Incomplete Slots",
																																											Note = "Take out pets that can't make a set",
																																											Default = true,
																																											SubOf = value156,
																																											Callback = function()
																																												flag238 = num5.Toggle(value168, true)
																																												tbl8.Wake()
																																											end,
																																										})
																																									end

																																									do
																																										local save4 = tbl2.Save

																																										if type(save4) == "table" and type(save4.FieldSignal) == "function" then
																																											for _, item63 in ipairs({
																																												"Inventory",
																																												"EquippedAssets",
																																												"FusionSlots",
																																												"FusionLocked",
																																												"FusionEggReward",
																																												"Money",
																																											}) do
																																												local ok, result = pcall(save4.FieldSignal, item63)

																																												if ok and type(result) == "table" and type(result.Connect) == "function" then
																																													local ok2, result2 = pcall(result.Connect, result, function()
																																														tbl8.Wake()
																																													end)

																																													if ok2 and result2 then
																																														func10(function()
																																															pcall(function()
																																																result2:Disconnect()
																																															end)
																																														end)
																																													end
																																												end
																																											end
																																										end
																																									end
																																								end

																																								do
																																									local n54 = 2
																																									local n55 = 25
																																									local n56 = 4

																																									local tbl140 = {
																																										"Match Any",
																																										"Match All",
																																									}

																																									local str18 = "Any Mutation"

																																									local tbl141 = {
																																										"Off",
																																									}

																																									local tbl142 = {}
																																									local tbl143 = {}
																																									local tbl144 = {}

																																									local tbl145 = {
																																										"Any Mutation",
																																									}

																																									local tbl146 = {}
																																									local directory3 = tbl2.Assets and tbl2.Assets.Directory
																																									local tbl147 = {}
																																									local tbl148 = {}

																																									if type(directory3) ~= "table" then
																																										do
																																											local tbl149 = {}

																																											for k in pairs(tbl147) do
																																												table.insert(tbl149, k)
																																											end

																																											table.sort(tbl149)

																																											for _, item64 in ipairs(tbl149) do
																																												local formatted9 = string.format("%d - %s", item64, tbl147[item64])
																																												table.insert(tbl141, formatted9)
																																												tbl142[formatted9] = item64
																																											end
																																										end

																																										table.sort(tbl148, function(param146, param147)
																																											if param146.Rarity ~= param147.Rarity then
																																												return param146.Rarity < param147.Rarity
																																											end
																																											return param146.Name < param147.Name
																																										end)

																																										for _, item65 in ipairs(tbl148) do
																																											local formatted10 = string.format("%s [%s]", item65.Name, item65.RarityName)

																																											if tbl144[formatted10] then
																																												formatted10 = string.format("%s [%s] (%s)", item65.Name, item65.RarityName, item65.Category)
																																											end

																																											table.insert(tbl143, formatted10)
																																											tbl144[formatted10] = item65.Category
																																										end

																																										do
																																											local tbl150 = {}
																																											local mutations = tbl2.Mutations

																																											if type(mutations) == "table" and type(mutations.IdSet) == "table" then
																																												for k in pairs(mutations.IdSet) do
																																													table.insert(tbl150, tostring(k))
																																												end

																																												if #tbl150 ~= 0 then
																																													local n57, n58, n59, list23, tbl151, tbl152, n60, snapshot, n61, flag261
																																													local n62, n63, str19, str20, flag262, n64, flag263, list24, flag264, flag265
																																													local n65, value169, func211, func212, func213, func214, func215, func216, func217, func218
																																													local func219, func220, func221, func222, func223, func224, func225, func226, func227, func228
																																													local func229, func230, func231, func232, func233, func234

																																													do
																																														do
																																															do
																																																local value170, value171, value172, flag266, flag267, value173, flag268, tbl153, n66, tbl154
																																																local flag269, n67, tbl155, func235, func236, func237

																																																do
																																																	local func238

																																																	do
																																																		local func239, func240

																																																		do
																																																			table.sort(tbl150, function(param148, param149)
																																																				return func42(param148) < func42(param149)
																																																			end)

																																																			for _, item66 in ipairs(tbl150) do
																																																				local value174 = func42(item66)
																																																				table.insert(tbl145, value174)
																																																				tbl146[value174] = item66
																																																			end

																																																			value170 = nil
																																																			value171 = nil
																																																			value172 = nil
																																																			flag266 = nil
																																																			flag267 = tbl140[2]
																																																			value173 = nil
																																																			flag268 = false
																																																			tbl153 = {}
																																																			n66 = 0
																																																			tbl154 = {}
																																																			flag269 = false
																																																			n67 = 0
																																																			tbl155 = {}

																																																			func235 = function()
																																																				local save4 = tbl2.Save
																																																				if type(save4) ~= "table" or type(save4.Get) ~= "function" then
																																																					return nil
																																																				end
																																																				local ok, result = pcall(save4.Get)
																																																				return ok and type(result) == "table" and result or nil
																																																			end

																																																			do
																																																				local function func241(param150)
																																																					local directory4 = tbl2.Assets and tbl2.Assets.Directory
																																																					return type(directory4) == "table" and directory4[tostring(param150)] or nil
																																																				end

																																																				func239 = function(param151)
																																																					local value175 = func241(param151)
																																																					local rarity = type(value175) == "table" and value175.Rarity or nil
																																																					local flag270 = type(rarity) == "table"

																																																					if flag270 then
																																																						flag270 = tonumber(rarity.RarityNumber or rarity.Rank)
																																																					end

																																																					return flag270 or 0
																																																				end

																																																				func240 = function(param152)
																																																					local category5 = func241(param152.Category)
																																																					local n68 = type(category5) == "table" and tonumber(category5.EarningRate) or 0
																																																					local n69 = tonumber(param152.Scale) or 0
																																																					if n68 <= 0 or n69 <= 0 then
																																																						return 0
																																																					end
																																																					local n70 = n69 > 5 and (n69 / 5) ^ 1.2 * 19.637875755794113 or n69 ^ 1.85
																																																					local mutations2 = tbl2.Mutations
																																																					local flag271 = type(mutations2) == "table" and type(mutations2.EarningsFor) == "function"
																																																					local n71 = 1

																																																					if flag271 then
																																																						local ok
																																																						ok, n71 = pcall(mutations2.EarningsFor, type(param152.Mutations) == "table" and param152.Mutations or {})
																																																						ok = ok and type(n71) == "number"
																																																						local n72 = 1

																																																						if not ok then
																																																							n71 = n72
																																																						end
																																																					end

																																																					return n68 * n70 * n71
																																																				end
																																																			end
																																																		end

																																																		do
																																																			local function func242(list25)
																																																				local tbl156 = {}

																																																				if type(list25.Mutations) == "table" then
																																																					for k, mutation in pairs(list25.Mutations) do
																																																						if type(mutation) == "string" then
																																																							tbl156[mutation] = true
																																																						elseif mutation == true and type(k) == "string" then
																																																							tbl156[k] = true
																																																						end
																																																					end
																																																				end

																																																				if type(list25.BaseMutation) == "string" and list25.BaseMutation ~= "" then
																																																					tbl156[list25.BaseMutation] = true
																																																				end

																																																				return tbl156
																																																			end

																																																			func238 = function(param153)
																																																				if tbl154[tostring(param153.Category)] then
																																																					return true
																																																				end
																																																				local n68 = 0
																																																				local n69 = 0

																																																				if value173 then
																																																					n69 = 1

																																																					if func239(param153.Category) >= value173 then
																																																						n68 = 1
																																																					end
																																																				end

																																																				if flag268 or next(tbl153) ~= nil then
																																																					n69 += 1
																																																					local value176 = func242(param153)

																																																					if flag268 and next(value176) ~= nil then
																																																						n68 += 1
																																																					else
																																																						local flag272 = false

																																																						for k in pairs(value176) do
																																																							if tbl153[k] then
																																																								flag272 = true
																																																								break
																																																							end
																																																						end

																																																						if flag272 then
																																																							n68 += 1
																																																						end
																																																					end
																																																				end

																																																				if n66 > 0 then
																																																					n69 += 1

																																																					if n66 <= func240(param153) then
																																																						n68 += 1
																																																					end
																																																				end

																																																				if n69 == 0 then
																																																					return false
																																																				end

																																																				if flag267 == tbl140[2] then
																																																					return n68 == n69
																																																				end
																																																				return n68 > 0
																																																			end
																																																		end
																																																	end

																																																	do
																																																		local function func243(param154)
																																																			return (tbl155[param154] or 0) > os.clock()
																																																		end

																																																		func236 = function(list26)
																																																			local tbl157 = {}
																																																			local value177, value178, value179 = pairs(list26.Inventory or {})
																																																			local n68 = 0

																																																			for k, value180 in value177, value178, value179 do
																																																				if type(value180) == "table" and func238(value180) then
																																																					n68 += 1

																																																					if value180.IsFavorite ~= true and not func243(k) then
																																																						table.insert(tbl157, k)
																																																					end
																																																				end
																																																			end

																																																			return tbl157, n68
																																																		end

																																																		func237 = function(param155, param156, flag273)
																																																			local tbl158 = {}
																																																			local inventory = param155.Inventory or {}
																																																			local func244 = pairs
																																																			local equippedAssets = param155.EquippedAssets or {}

																																																			for _, equippedAsset in func244(equippedAssets) do
																																																				local entry9 = inventory[equippedAsset]

																																																				if type(entry9) == "table" and not func243(equippedAsset) then
																																																					if param156 then
																																																						if entry9.IsFavorite ~= true then
																																																							table.insert(tbl158, equippedAsset)
																																																						end
																																																					else
																																																						local isFavorite = entry9.IsFavorite == true

																																																						if isFavorite then
																																																							isFavorite = not (flag273 and func238(entry9))
																																																						end

																																																						if isFavorite then
																																																							table.insert(tbl158, equippedAsset)
																																																						end
																																																					end
																																																				end
																																																			end

																																																			return tbl158
																																																		end
																																																	end
																																																end

																																																do
																																																	local func245

																																																	do
																																																		do
																																																			local function func246(list27, param157)
																																																				local rePetSatchelWriteFavourite = networking:FindFirstChild("RE/PetSatchel/WriteFavourite")
																																																				if not rePetSatchelWriteFavourite or not rePetSatchelWriteFavourite:IsA("RemoteEvent") then
																																																					return
																																																				end

																																																				for i, item67 in ipairs(list27) do
																																																					if not (n55 < i) then
																																																						tbl155[item67] = os.clock() + n56
																																																						pcall(rePetSatchelWriteFavourite.FireServer, rePetSatchelWriteFavourite, item67, param157)
																																																						task.wait(0.12)
																																																						continue
																																																					end

																																																					break
																																																				end
																																																			end

																																																			func245 = function(list28, param158)
																																																				if flag269 or #list28 == 0 then
																																																					return false
																																																				end
																																																				flag269 = true
																																																				n67 = os.clock() + n54

																																																				task.spawn(function()
																																																					pcall(func246, list28, param158)
																																																					flag269 = false
																																																					tbl8.Wake()
																																																				end)

																																																				return true
																																																			end
																																																		end
																																																	end

																																																	tbl8.Add(function()
																																																		local result37 = func235()
																																																		if not result37 then
																																																			return false
																																																		end
																																																		local flag274 = num5.Toggle(value170, false)
																																																		local list29, value181 = func236(result37)

																																																		if flag266 and type(flag266.Set) == "function" then
																																																			local func247 = pairs
																																																			local inventory = result37.Inventory or {}
																																																			local n68 = 0

																																																			for _, value182 in func247(inventory) do
																																																				if type(value182) == "table" and value182.IsFavorite == true then
																																																					n68 += 1
																																																				end
																																																			end

																																																			pcall(flag266.Set, flag266, string.format("Favorite matches  -  %d pets, %d to mark  |  %d favorited", value181, #list29, n68))
																																																		end

																																																		local value183 = flag269
																																																		local flag275

																																																		if flag269 then
																																																			flag275 = value183
																																																		else
																																																			flag275 = os.clock() < n67
																																																		end

																																																		if flag275 then
																																																			return false
																																																		end

																																																		if flag274 and func245(list29, true) then
																																																			return false
																																																		end

																																																		if num5.Toggle(value171, false) then
																																																			if func245(func237(result37, true, false), true) then
																																																				return false
																																																			end
																																																		elseif num5.Toggle(value172, false) then
																																																			func245(func237(result37, false, flag274), false)
																																																		end

																																																		return false
																																																	end)

																																																	flag266 = obj13:CreateText({
																																																		Name = "Favorite Preview",
																																																		Text = "Favorite matches  -  0 pets",
																																																	})

																																																	value170 = obj13:CreateToggle({
																																																		Name = "Auto Favorite Pet",
																																																		Note = "Favorite pets matching the rules below",
																																																		Default = false,
																																																		Callback = function()
																																																			table.clear(tbl155)
																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	obj13:CreateButton({
																																																		Name = "Favorite Pets Now",
																																																		Note = "Favorite matching pets once",
																																																		ButtonText = "Favorite",
																																																		ConfirmText = "Done!",
																																																		SubOf = value170,
																																																		Callback = function()
																																																			local result38 = func235()

																																																			if result38 then
																																																				func245(func236(result38), true)
																																																			end
																																																		end,
																																																	})

																																																	obj13:CreateDropdown({
																																																		Name = "Favorite Rule",
																																																		Note = "Pass any check or all checks",
																																																		Options = tbl140,
																																																		Default = tbl140[2],
																																																		SubOf = value170,
																																																		Callback = function(value)
																																																			if table.find(tbl140, value) then
																																																				flag267 = value
																																																				tbl8.Wake()
																																																			end
																																																		end,
																																																	})

																																																	obj13:CreateDropdown({
																																																		Name = "Favorite Min Rarity",
																																																		Note = "Favorite pets of the chosen rarity and every rarity above it (Off = skip)",
																																																		Options = tbl141,
																																																		Default = "Off",
																																																		SubOf = value170,
																																																		Callback = function(value)
																																																			value173 = tbl142[value]
																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	func16(obj13:CreateMultiDropdown({
																																																		Name = "Favorite Mutations",
																																																		Note = "Mutation check (empty = skip)",
																																																		Options = tbl145,
																																																		Default = {},
																																																		SubOf = value170,
																																																		Callback = function(value)
																																																			local tbl159 = {}
																																																			local flag276 = false

																																																			if type(value) == "table" then
																																																				for k, value184 in pairs(value) do
																																																					k = value184 == true and type(k) == "string" and k

																																																					if k then
																																																						value184 = k
																																																					else
																																																						value184 = type(value184) == "string" and value184
																																																					end

																																																					local flag277 = value184 or nil

																																																					if flag277 == str18 then
																																																						flag276 = true
																																																					elseif flag277 then
																																																						tbl159[tbl146[flag277] or flag277] = true
																																																					end
																																																				end
																																																			end

																																																			flag268 = flag276
																																																			tbl153 = tbl159
																																																			tbl8.Wake()
																																																		end,
																																																	}))

																																																	do
																																																		local tbl160 = {
																																																			["K/s"] = {
																																																				Min = 0,
																																																				Max = 1000,
																																																				Mult = 1000,
																																																			},
																																																			["M/s"] = {
																																																				Min = 0,
																																																				Max = 1000,
																																																				Mult = 1000000,
																																																			},
																																																			["B/s"] = {
																																																				Min = 0,
																																																				Max = 100,
																																																				Mult = 1e9,
																																																			},
																																																		}

																																																		local n68 = 0
																																																		local str21 = "M/s"

																																																		local function func248(flag278, flag279)
																																																			if flag278 ~= nil then
																																																				n68 = math.max(0, math.floor(tonumber(flag278) or n68))
																																																			end

																																																			if flag279 ~= nil then
																																																				str21 = tostring(flag279)
																																																			end

																																																			n66 = n68 * (tbl160[str21] or tbl160["M/s"]).Mult
																																																			tbl8.Wake()
																																																		end

																																																		func11(obj13, {
																																																			Name = "Min Favorite Value",
																																																			Note = "Value check (0 = skip)",
																																																			SubOf = value170,
																																																			Legacy = "Favorite Min Value",
																																																			SectionName = "Auto Favorite",
																																																			OnRaw = function(num76)
																																																				func248(math.floor(num76 / 1000), "K/s")
																																																			end,
																																																		})
																																																	end

																																																	func16(obj13:CreateMultiDropdown({
																																																		Name = "Always Favorite Species",
																																																		Note = "Always favorite these species",
																																																		Options = tbl143,
																																																		Default = {},
																																																		SubOf = value170,
																																																		Callback = function(value)
																																																			local tbl161 = {}

																																																			if type(value) == "table" then
																																																				for k, value185 in pairs(value) do
																																																					k = value185 == true and type(k) == "string" and k or type(value185) == "string" and value185
																																																					local flag280 = k or nil

																																																					if flag280 and tbl144[flag280] then
																																																						tbl161[tbl144[flag280]] = true
																																																					end
																																																				end
																																																			end

																																																			tbl154 = tbl161
																																																			tbl8.Wake()
																																																		end,
																																																	}))

																																																	value171 = obj13:CreateToggle({
																																																		Name = "Auto Favorite Equipped",
																																																		Note = "Keep equipped pets favorited",
																																																		Default = false,
																																																		Callback = function()
																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	value172 = obj13:CreateToggle({
																																																		Name = "Auto Unfavorite Equipped",
																																																		Note = "Unfavorite equipped pets not in the rules",
																																																		Default = false,
																																																		Callback = function()
																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	obj13:CreateButton({
																																																		Name = "Favorite Equipped Now",
																																																		Note = "Favorite all equipped pets once",
																																																		ButtonText = "Favorite",
																																																		ConfirmText = "Done!",
																																																		Callback = function()
																																																			local result39 = func235()

																																																			if result39 then
																																																				func245(func237(result39, true, false), true)
																																																			end
																																																		end,
																																																	})

																																																	obj13:CreateButton({
																																																		Name = "Unfavorite Equipped Now",
																																																		Note = "Unfavorite all equipped pets once",
																																																		ButtonText = "Unfavorite",
																																																		ConfirmText = "Done!",
																																																		Callback = function()
																																																			local result40 = func235()

																																																			if result40 then
																																																				func245(func237(result40, false, false), false)
																																																			end
																																																		end,
																																																	})
																																																end
																																															end

																																															local save4 = tbl2.Save

																																															if type(save4) == "table" and type(save4.FieldSignal) == "function" then
																																																for _, item68 in ipairs({
																																																	"Inventory",
																																																	"EquippedAssets",
																																																}) do
																																																	local ok, result = pcall(save4.FieldSignal, item68)

																																																	if ok and type(result) == "table" and type(result.Connect) == "function" then
																																																		local ok2, result2 = pcall(result.Connect, result, function()
																																																			tbl8.Wake()
																																																		end)

																																																		if ok2 and result2 then
																																																			func10(function()
																																																				pcall(function()
																																																					result2:Disconnect()
																																																				end)
																																																			end)
																																																		end
																																																	end
																																																end
																																															end
																																														end

																																														do
																																															local n66, value186, value187, flag281, n67, n68, n69, flag282, n70, str22
																																															local flag283, func249, func250, func251, func252, func253

																																															do
																																																num5.MechBoot = function(obj36)
																																																	local ok, result = pcall(function()
																																																		return require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
																																																	end)

																																																	local mech = {
																																																		Handle = nil,
																																																		Row = nil,
																																																		Status = "Idle",
																																																		Shown = nil,
																																																		Busy = false,
																																																		Generation = 0,
																																																		Hazards = {},
																																																		TravelSpeed = 250,
																																																		Radius = 18,
																																																		SwingGap = 0.12,
																																																		Dodge = true,
																																																		TryBall = true,
																																																		Leave = true,
																																																		BaitSpeed = 225,
																																																		Interval = 1800,
																																																		Run = nil,
																																																		SwapTools = true,
																																																		SwapIndex = 1,
																																																		SwapSince = 0,
																																																		MainHold = 0.3,
																																																		SecondHold = 0.4,
																																																		LastSwing = 0,
																																																		Links = {},
																																																	}

																																																	num5.Mech = mech

																																																	local function func254()
																																																		return num5.Toggle(mech.Handle, false) == true
																																																	end

																																																	local function func255()
																																																		return workspace:FindFirstChild("ScrambleArena")
																																																	end

																																																	local function func256()
																																																		return workspace:FindFirstChild("ScrambleArenaPortal")
																																																	end

																																																	local function func257()
																																																		return localPlayer:GetAttribute("InScrambleArena") == true
																																																	end

																																																	mech.StealFirst = function()
																																																		local steal = num5.Steal
																																																		local movement = num5.Movement
																																																		if movement.PlaceWanted == true then
																																																			return "Auto Place Egg goes first"
																																																		end

																																																		if movement.MutationWanted == true then
																																																			return "Scrambled Mutation goes first"
																																																		end
																																																		local flag284 = num5.Toggle(value27, false) == true and steal ~= nil
																																																		local flag285

																																																		if flag284 then
																																																			flag285 = steal.Wanted == true or steal.Carrying == true or steal.Active == true
																																																		else
																																																			flag285 = flag284
																																																		end

																																																		if flag285 then
																																																			return "Auto Steal goes first"
																																																		end
																																																		return nil
																																																	end

																																																	pcall(function()
																																																		local scheduleIntervalSeconds = require(ReplicatedStorage.Shared.Flags.ScrambleBossFlags).ScheduleIntervalSeconds
																																																		local interval = type(scheduleIntervalSeconds) == "table" and tonumber(scheduleIntervalSeconds.Value) or nil

																																																		if interval and interval > 0 then
																																																			mech.Interval = interval
																																																		end
																																																	end)

																																																	mech.Clock = function(num77)
																																																		local n71 = math.max(0, math.floor(num77 + 0.5))
																																																		return string.format("%d:%02d", math.floor(n71 / 60), n71 % 60)
																																																	end

																																																	mech.Timer = function()
																																																		local serverTimeNow = workspace:GetServerTimeNow()
																																																		local scrambleArena = workspace:FindFirstChild("ScrambleArena")
																																																		local n71 = scrambleArena and tonumber(scrambleArena:GetAttribute("SpawnsAt")) or 0

																																																		if workspace:FindFirstChild("ScrambleArenaPortal") then
																																																			if serverTimeNow < n71 then
																																																				return "Mech portal is open  |  boss spawns in " .. mech.Clock(n71 - serverTimeNow)
																																																			end
																																																			return "Mech portal is open now"
																																																		end

																																																		local interval = mech.Interval
																																																		return "Next Mech portal in " .. mech.Clock(math.ceil(serverTimeNow / interval) * interval - serverTimeNow)
																																																	end

																																																	local function func258(instance6)
																																																		if not instance6 then
																																																			return nil
																																																		end
																																																		local hitbox = instance6:FindFirstChild("Hitbox", true)
																																																		if hitbox and hitbox:IsA("BasePart") then
																																																			return hitbox
																																																		end

																																																		for _, descendant in ipairs(instance6:GetDescendants()) do
																																																			if descendant:IsA("TouchTransmitter") and descendant.Parent and descendant.Parent:IsA("BasePart") then
																																																				return descendant.Parent
																																																			end
																																																		end

																																																		return nil
																																																	end

																																																	local function func259(flag286)
																																																		local flag287 = num5.Root()
																																																		if not flag287 or not flag286 or type(firetouchinterest) ~= "function" then
																																																			return
																																																		end

																																																		pcall(function()
																																																			firetouchinterest(flag287, flag286, 0)
																																																			task.wait(0.05)
																																																			firetouchinterest(flag287, flag286, 1)
																																																		end)
																																																	end

																																																	local function func260(param159, flag288)
																																																		if not mech.Dodge or not ok or type(result) ~= "table" or type(result.Contains) ~= "function" then
																																																			return false
																																																		end

																																																		for k, hazard in pairs(mech.Hazards) do
																																																			local n71 = tonumber(hazard.At) or 0
																																																			local n72 = tonumber(hazard.Warn) or 0
																																																			if flag288 > n71 + (tonumber(hazard.Duration) or 0.5) + 1.5 then
																																																				mech.Hazards[k] = nil
																																																				continue
																																																			end

																																																			if flag288 >= n71 - n72 - 0.1 then
																																																				local ok2, result2 = pcall(result.Contains, hazard, param159, flag288)
																																																				if ok2 and result2 then
																																																					return true
																																																				end
																																																			end
																																																		end

																																																		return false
																																																	end

																																																	local function func261()
																																																		local character = localPlayer.Character
																																																		local backpack = localPlayer:FindFirstChildOfClass("Backpack")

																																																		for _, item69 in ipairs({ character, backpack }) do
																																																			if item69 then
																																																				for _, child in ipairs(item69:GetChildren()) do
																																																					if child:IsA("Tool") and tostring(child:GetAttribute("ItemType")) == "Gear" then
																																																						if string.find(string.lower(tostring(child:GetAttribute("GearName") or "")), "scrambler", 1, true) then
																																																							return child
																																																						end
																																																					end
																																																				end
																																																			end
																																																		end

																																																		return nil
																																																	end

																																																	local function func262()
																																																		local lastSwing = mech.LastSwing
																																																		if os.clock() - lastSwing < mech.SwingGap then
																																																			return
																																																		end
																																																		mech.LastSwing = os.clock()
																																																		local character = localPlayer.Character
																																																		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
																																																		local findBat = type(num5.FindBat) == "function" and num5.FindBat() or nil
																																																		local swapTools = mech.SwapTools and func261() or nil
																																																		local obj37

																																																		if findBat and swapTools and findBat ~= swapTools then
																																																			local secondHold = mech.SwapIndex == 2 and mech.SecondHold or mech.MainHold
																																																			local swapSince = mech.SwapSince

																																																			if secondHold <= os.clock() - swapSince then
																																																				mech.SwapIndex = mech.SwapIndex == 2 and 1 or 2
																																																				mech.SwapSince = os.clock()
																																																			end

																																																			obj37 = mech.SwapIndex == 2 and swapTools or findBat
																																																		else
																																																			obj37 = findBat or swapTools
																																																		end

																																																		if not obj37 or not humanoid then
																																																			return
																																																		end

																																																		if obj37.Parent ~= character then
																																																			pcall(function()
																																																				humanoid:EquipTool(obj37)
																																																			end)
																																																		end

																																																		pcall(function()
																																																			obj37:Activate()
																																																		end)
																																																	end

																																																	local function func263(num78, param160)
																																																		local character = localPlayer.Character
																																																		local flag289 = num5.Root()
																																																		if not character or not flag289 then
																																																			return
																																																		end

																																																		if (flag289.Position - num78).Magnitude > 3 then
																																																			pcall(function()
																																																				character:PivotTo(CFrame.lookAt(num78, Vector3.new(param160.X, num78.Y, param160.Z)))
																																																				flag289.AssemblyLinearVelocity = Vector3.zero
																																																			end)
																																																		end
																																																	end

																																																	local function func264(instance7)
																																																		local mech2 = instance7:FindFirstChild("Mech")
																																																		local hitbox = mech2 and mech2:FindFirstChild("Hitbox")
																																																		if hitbox and hitbox:IsA("BasePart") then
																																																			return hitbox.Position, mech2
																																																		end

																																																		for _, child in ipairs(instance7:GetChildren()) do
																																																			if child:IsA("Model") and child.Name ~= "Ball" and child.Name ~= "LeaveTeleport" and child.Name ~= "Structure" then
																																																				local hitbox2 = child:FindFirstChild("Hitbox")
																																																				if hitbox2 and hitbox2:IsA("BasePart") then
																																																					return hitbox2.Position, child
																																																				end
																																																			end
																																																		end

																																																		return nil, nil
																																																	end

																																																	local function func265(instance8, part13)
																																																		local ball = instance8:FindFirstChild("Ball")
																																																		if not ball then
																																																			return false
																																																		end
																																																		local position = ball:GetBoundingBox().Position
																																																		local n71 = (tonumber(instance8:GetAttribute("FloorY")) or position.Y) + 3
																																																		local n72 = tonumber(instance8:GetAttribute("CoreStage")) or 0

																																																		if instance8:GetAttribute("BallStunned") == true then
																																																			mech.Run = nil
																																																			local vector = Vector3.new(part13.Position.X - position.X, 0, part13.Position.Z - position.Z)
																																																			local unit = vector.Magnitude > 1 and vector.Unit or Vector3.new(1, 0, 0)
																																																			func263(Vector3.new(position.X, n71, position.Z) + unit * 10, position)
																																																			func262()
																																																			mech.Status = string.format("Smashing the core  |  stage %d / 3  |  core %s", n72, tostring(instance8:GetAttribute("CoreHealth") or "?"))
																																																			return true
																																																		end

																																																		local str23 = tostring(instance8:GetAttribute("BallTarget"))
																																																		local attribute = instance8:GetAttribute("BallCoil")

																																																		if not mech.Run and str23 == tostring(localPlayer.UserId) and type(attribute) == "string" and attribute ~= "" then
																																																			local coils = instance8:FindFirstChild("Coils")
																																																			coils = coils and coils:FindFirstChild(attribute)
																																																			coils = coils and coils:GetAttribute("Home")

																																																			if typeof(coils) == "Vector3" then
																																																				local vector = Vector3.new(coils.X - position.X, 0, coils.Z - position.Z)

																																																				if vector.Magnitude > 1 then
																																																					local n73 = vector.Unit * 40
																																																					mech.Run = { Goal = Vector3.new(coils.X, n71, coils.Z) + n73, Until = os.clock() + 8, Coil = attribute }
																																																				end
																																																			end
																																																		end

																																																		if mech.Run then
																																																			local vector = Vector3.new(mech.Run.Goal.X - part13.Position.X, 0, mech.Run.Goal.Z - part13.Position.Z)
																																																			local flag290 = vector.Magnitude < 4

																																																			if not flag290 then
																																																				local until_ = mech.Run.Until
																																																				flag290 = os.clock() > until_
																																																			end

																																																			if flag290 then
																																																				mech.Run = nil

																																																				pcall(function()
																																																					part13.AssemblyLinearVelocity = Vector3.new(0, part13.AssemblyLinearVelocity.Y, 0)
																																																				end)
																																																			else
																																																				local n73 = vector.Unit * mech.BaitSpeed

																																																				pcall(function()
																																																					part13.AssemblyLinearVelocity = Vector3.new(n73.X, part13.AssemblyLinearVelocity.Y, n73.Z)
																																																				end)
																																																				-- Ｓｏｕｒｃｅ Ｌｅａｋ (ＳＬ) | https://discord.gg/x7YbZeezpm

																																																				mech.Status = string.format("Baiting the ball into %s  |  stage %d / 3", mech.Run.Coil, n72)
																																																			end

																																																			return true
																																																		end

																																																		local vector = Vector3.new(part13.Position.X - position.X, 0, part13.Position.Z - position.Z)

																																																		if vector.Magnitude > 18 or vector.Magnitude < 6 then
																																																			local vector2 = vector.Magnitude < 1 and Vector3.new(1, 0, 0) or vector.Unit
																																																			func263(Vector3.new(position.X, n71, position.Z) + vector2 * 12, position)
																																																		end

																																																		mech.Status = string.format("Ball phase, waiting for it to lock on  |  stage %d / 3", n72)
																																																		return true
																																																	end

																																																	local function func266(instance9, part14)
																																																		local scrambleHuman = instance9:FindFirstChild("ScrambleHuman")
																																																		if not scrambleHuman then
																																																			return false
																																																		end
																																																		local humanoidRootPart = scrambleHuman:FindFirstChild("HumanoidRootPart") or scrambleHuman.PrimaryPart or scrambleHuman:FindFirstChildWhichIsA("BasePart")
																																																		local position = humanoidRootPart and humanoidRootPart.Position or scrambleHuman:GetPivot().Position
																																																		humanoidRootPart = humanoidRootPart and humanoidRootPart.AssemblyLinearVelocity or Vector3.zero
																																																		local n71 = position + Vector3.new(humanoidRootPart.X, 0, humanoidRootPart.Z) * 0.15
																																																		local vector = Vector3.new(part14.Position.X - n71.X, 0, part14.Position.Z - n71.Z)
																																																		local vector2 = vector.Magnitude > 1 and vector.Unit * 5 or Vector3.zero
																																																		local n72 = Vector3.new(n71.X, part14.Position.Y, n71.Z) + vector2
																																																		local character = localPlayer.Character

																																																		pcall(function()
																																																			character:PivotTo(CFrame.lookAt(n72, Vector3.new(position.X, n72.Y, position.Z)))
																																																		end)

																																																		func262()
																																																		mech.Status = string.format("Chasing Dr Scramble  |  hits %s / %s", tostring(instance9:GetAttribute("HumanHits") or 0), tostring(instance9:GetAttribute("HumanNeeded") or 3))
																																																		return true
																																																	end

																																																	local function func267()
																																																		local result41 = func255()
																																																		local num79 = num5.Root()
																																																		local character = localPlayer.Character
																																																		character = character and character:FindFirstChildOfClass("Humanoid")
																																																		if not result41 or not num79 then
																																																			return
																																																		end
																																																		local str24 = tostring(result41:GetAttribute("Phase"))
																																																		local n71 = tonumber(result41:GetAttribute("Health")) or 0
																																																		local n72 = tonumber(result41:GetAttribute("MaxHealth")) or 0

																																																		if tostring(result41:GetAttribute("GrabVictim")) == tostring(localPlayer.UserId) and character then
																																																			character.Jump = true
																																																			func262()
																																																			mech.Status = "Grabbed, breaking free"
																																																			return
																																																		end

																																																		if str24 == "Ball" and mech.TryBall and func265(result41, num79) then
																																																			return
																																																		end

																																																		if str24 == "Human" and func266(result41, num79) then
																																																			return
																																																		end
																																																		local flag291, obj38 = func264(result41)

																																																		if not flag291 then
																																																			local n73 = (tonumber(result41:GetAttribute("SpawnsAt")) or 0) - workspace:GetServerTimeNow()
																																																			mech.Status = n73 > 0 and "In the arena  |  boss spawns in " .. mech.Clock(n73) or string.format("Phase %s, waiting for the boss", str24)
																																																			return
																																																		end

																																																		local serverTimeNow = workspace:GetServerTimeNow()
																																																		local n73 = (tonumber(result41:GetAttribute("FloorY")) or flag291.Y) + 3
																																																		local value188 = nil
																																																		local value189 = nil

																																																		for i = 0, 15 do
																																																			local n74 = i / 16 * 3.1415926535897931 * 2
																																																			local radius = mech.Radius
																																																			local z = flag291.Z
																																																			local radius2 = mech.Radius
																																																			local vector = Vector3.new(flag291.X + math.cos(n74) * radius, n73, z + math.sin(n74) * radius2)
																																																			local magnitude = (vector - num79.Position).Magnitude

																																																			if func260(vector, serverTimeNow) or func260(vector, serverTimeNow + 0.4) then
																																																				magnitude += 10000
																																																			end

																																																			if not value188 or magnitude < value188 then
																																																				value188 = magnitude
																																																				value189 = vector
																																																			end
																																																		end

																																																		if value189 then
																																																			func263(value189, flag291)
																																																		end

																																																		func262()
																																																		obj38 = obj38 and obj38:GetAttribute("Overheated") == true
																																																		mech.Status = string.format("Fighting %s  |  boss %d / %d%s", str24, math.floor(n71 + 0.5), math.floor(n72 + 0.5), obj38 and "  |  OVERHEAT" or "")
																																																	end

																																																	local function func268()
																																																		local result42 = func255()
																																																		local flag292 = func258(result42 and result42:FindFirstChild("LeaveTeleport"))
																																																		if not flag292 then
																																																			return
																																																		end
																																																		local character = localPlayer.Character

																																																		pcall(function()
																																																			character:PivotTo(CFrame.new(flag292.Position + Vector3.new(0, 3, 0)))
																																																		end)

																																																		task.wait(0.2)
																																																		func259(flag292)
																																																	end

																																																	local function func269(flag293)
																																																		local result43 = func256()
																																																		local flag294 = func258(result43)
																																																		if not result43 or not flag294 then
																																																			return false
																																																		end
																																																		local stealHome2 = type(num5.StealHome) == "function" and num5.StealHome() or nil

																																																		if stealHome2 and num5.InsideBase() then
																																																			local respawned = mech.Respawned == true
																																																			local n71 = stealHome2 + Vector3.new(0, 3, 0)
																																																			local travelSpeed = respawned and math.min(mech.TravelSpeed, 300) or mech.TravelSpeed
																																																			local now = os.clock()
																																																			local exitTo = nil

																																																			while true do
																																																				if not (os.clock() - now < 20) then
																																																					exitTo = 1
																																																					break
																																																				else
																																																					if flag293 ~= mech.Generation or not func254() or func257() or mech.StealFirst() then
																																																						exitTo = 2
																																																						break
																																																					else
																																																						local num80 = num5.Root()

																																																						if num80 then
																																																							local n72 = n71 - num80.Position

																																																							if n72.Magnitude <= 4 then
																																																								exitTo = 1
																																																								break
																																																							else
																																																								mech.Status = respawned and "Respawned, going out through the safe zone" or "Leaving the base through the safe zone"
																																																								local magnitude = n72.Magnitude
																																																								local n73 = math.min(travelSpeed * RunService.Heartbeat:Wait(), magnitude)

																																																								pcall(function()
																																																									local rotation = num80.CFrame.Rotation
																																																									num80.CFrame = CFrame.new(num80.Position + n72.Unit * n73) * rotation
																																																									num80.AssemblyLinearVelocity = Vector3.zero
																																																								end)

																																																								continue
																																																							end
																																																						end
																																																					end

																																																					break
																																																				end
																																																			end

																																																			if exitTo ~= 1 then
																																																				if exitTo == 2 then
																																																					return false
																																																				end
																																																				return false
																																																			end

																																																			if respawned then
																																																				mech.Status = "Respawned, resting in the safe zone"
																																																				local n72 = 0

																																																				while n72 < 0.75 do
																																																					local value190 = num5.Root()

																																																					if value190 then
																																																						pcall(function()
																																																							value190.AssemblyLinearVelocity = Vector3.zero
																																																						end)
																																																					end

																																																					n72 += RunService.Heartbeat:Wait()
																																																				end
																																																			end
																																																		end

																																																		mech.Respawned = false
																																																		local position = flag294.Position
																																																		local now = os.clock()
																																																		local exitTo2 = nil
																																																		local num81

																																																		while true do
																																																			if not (os.clock() - now < 60) then
																																																				exitTo2 = 1
																																																				break
																																																			else
																																																				if flag293 ~= mech.Generation or not func254() or func257() or mech.StealFirst() then
																																																					exitTo2 = 1
																																																					break
																																																				else
																																																					num81 = num5.Root()

																																																					if not num81 then
																																																						exitTo2 = 2
																																																						break
																																																					else
																																																						local vector = Vector3.new(position.X - num81.Position.X, 0, position.Z - num81.Position.Z)

																																																						if not (vector.Magnitude <= 14) then
																																																							local n71 = vector.Unit * math.min(mech.TravelSpeed, vector.Magnitude / 0.05)
																																																							mech.Status = string.format("Going to the Mech portal, %d studs", math.floor(vector.Magnitude + 0.5))

																																																							pcall(function()
																																																								num81.AssemblyLinearVelocity = Vector3.new(n71.X, num81.AssemblyLinearVelocity.Y, n71.Z)
																																																							end)

																																																							RunService.Heartbeat:Wait()
																																																							continue
																																																						end
																																																					end
																																																				end

																																																				break
																																																			end
																																																		end

																																																		if exitTo2 ~= 1 then
																																																			if exitTo2 == 2 then
																																																				return false
																																																			end

																																																			pcall(function()
																																																				num81.AssemblyLinearVelocity = Vector3.zero
																																																			end)

																																																			func259(flag294)
																																																			task.wait(0.4)

																																																			if not func257() then
																																																				pcall(function()
																																																					local rfScrambleBossEnterArena = networking:FindFirstChild("RF/ScrambleBoss/EnterArena")

																																																					if rfScrambleBossEnterArena then
																																																						rfScrambleBossEnterArena:InvokeServer()
																																																					end
																																																				end)
																																																			end
																																																		end

																																																		local now2 = os.clock()

																																																		while not func257() and os.clock() - now2 < 5 do
																																																			task.wait(0.1)
																																																		end

																																																		return func257()
																																																	end

																																																	local function func270()
																																																		mech.Busy = true
																																																		mech.Generation = mech.Generation + 1
																																																		local generation = mech.Generation
																																																		num5.Shield("mech", true)

																																																		pcall(function()
																																																			if num5.Treadmill and num5.Treadmill.Riding or type(num5.OnBelt) == "function" and num5.OnBelt() then
																																																				num5.ExitBelt()
																																																			end
																																																		end)

																																																		if not func257() and not mech.StealFirst() then
																																																			pcall(func269, generation)
																																																		end

																																																		while generation == mech.Generation and func254() and func257() and not mech.StealFirst() do
																																																			local result44 = func255()
																																																			result44 = result44 and tostring(result44:GetAttribute("Phase")) or ""

																																																			if result44 == "Defeated" or result44 == "Final" or result44 == "Ended" or result44 == "Won" then
																																																				mech.Status = "Dr Scramble defeated, going back home"
																																																				mech.DefeatedAt = mech.DefeatedAt or os.clock()
																																																				local leave = mech.Leave

																																																				if leave then
																																																					local defeatedAt = mech.DefeatedAt
																																																					leave = os.clock() - defeatedAt > 15
																																																				end

																																																				if leave then
																																																					pcall(func268)
																																																					task.wait(2)
																																																				else
																																																					task.wait(0.3)
																																																				end
																																																			else
																																																				pcall(func267)
																																																				RunService.Heartbeat:Wait()
																																																			end
																																																		end

																																																		if func257() and mech.StealFirst() then
																																																			mech.Status = tostring(mech.StealFirst()) .. ", leaving the arena"
																																																			pcall(func268)
																																																			local n71 = 0

																																																			while func257() and n71 < 5 do
																																																				n71 += task.wait(0.2)
																																																			end
																																																		end

																																																		mech.DefeatedAt = nil
																																																		mech.Run = nil
																																																		num5.Shield("mech", false)
																																																		num5.ReleaseMovement("mech")
																																																		mech.Busy = false
																																																		tbl8.Wake()
																																																	end

																																																	pcall(function()
																																																		local reScrambleBossHazard = networking:FindFirstChild("RE/ScrambleBoss/Hazard")

																																																		if reScrambleBossHazard and reScrambleBossHazard:IsA("RemoteEvent") then
																																																			table.insert(mech.Links, reScrambleBossHazard.OnClientEvent:Connect(function(param161)
																																																				if type(param161) == "table" then
																																																					mech.Hazards[param161.Id or #mech.Hazards + 1] = param161
																																																				end
																																																			end))
																																																		end
																																																	end)

																																																	table.insert(mech.Links, localPlayer.CharacterAdded:Connect(function()
																																																		mech.Respawned = true
																																																	end))

																																																	mech.Row = obj36:CreateText({ Name = "Mech Status", Text = "Idle" })

																																																	mech.Handle = obj36:CreateToggle({
																																																		Name = "Auto Mech Boss",
																																																		Default = false,
																																																		Callback = function()
																																																			if not func254() then
																																																				mech.Generation = mech.Generation + 1
																																																			end

																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	for _, item70 in ipairs({
																																																		{ "Mech Tween Speed", 100, 1000, 250, 10, "studs/s", "TravelSpeed" },
																																																		{ "Main Weapon Hold", 0, 1.5, 0.3, 0.01, "s", "MainHold" },
																																																		{ "Scrambler Hold", 0, 1.5, 0.4, 0.01, "s", "SecondHold" },
																																																	}) do
																																																		obj36:CreateSlider({
																																																			Name = item70[1],
																																																			Min = item70[2],
																																																			Max = item70[3],
																																																			Default = item70[4],
																																																			Increment = item70[5],
																																																			Unit = item70[6],
																																																			SubOf = mech.Handle,
																																																			Callback = function(value)
																																																				mech[item70[7]] = math.clamp(tonumber(value) or item70[4], item70[2], item70[3])
																																																			end,
																																																		})
																																																	end

																																																	for _, item71 in ipairs({
																																																		{ "Swap Two Weapons", "SwapTools" },
																																																		{ "Dodge Attacks", "Dodge" },
																																																		{ "Ball And Core Phase", "TryBall" },
																																																		{ "Leave After Fight", "Leave" },
																																																	}) do
																																																		obj36:CreateToggle({
																																																			Name = item71[1],
																																																			Default = true,
																																																			SubOf = mech.Handle,
																																																			Callback = function(value)
																																																				mech[item71[2]] = value ~= false
																																																			end,
																																																		})
																																																	end

																																																	tbl8.Add(function()
																																																		local row = mech.Row

																																																		if not func254() then
																																																			mech.Status = "Off  |  " .. mech.Timer()
																																																		elseif not mech.Busy then
																																																			if func257() then
																																																				mech.Status = "In the arena"
																																																			else
																																																				mech.Status = mech.Timer()
																																																			end
																																																		end

																																																		if row and mech.Shown ~= mech.Status and type(row.Set) == "function" then
																																																			mech.Shown = mech.Status
																																																			pcall(row.Set, row, mech.Status)
																																																		end

																																																		local invisibilityHandle = num5.InvisibilityHandle
																																																		local flag295 = invisibilityHandle ~= nil and num5.Toggle(invisibilityHandle, false)

																																																		if func254() and (mech.Busy or func257() or func256()) then
																																																			mech.InvisResumeAt = nil

																																																			if not num5.InvisMech then
																																																				num5.InvisMech = true

																																																				if flag295 then
																																																					num5.Notify("Invisibility", "Invisibility is paused for the Mech boss and comes back after it.")
																																																				end
																																																			end
																																																		elseif num5.InvisMech and not mech.Busy then
																																																			mech.InvisResumeAt = mech.InvisResumeAt or os.clock() + 5

																																																			if mech.InvisResumeAt <= os.clock() then
																																																				mech.InvisResumeAt = nil
																																																				num5.InvisMech = false

																																																				if flag295 then
																																																					num5.Notify("Invisibility", "The Mech boss is over, Invisibility is back on.")
																																																				end
																																																			end
																																																		end

																																																		if not func254() or mech.Busy then
																																																			return true
																																																		end

																																																		if func257() or func256() then
																																																			local str25 = mech.StealFirst()
																																																			if str25 then
																																																				mech.Status = str25 .. "  |  " .. mech.Timer()
																																																				return true
																																																			end
																																																			local character = localPlayer.Character
																																																			if character and character:GetAttribute("InvisApplied") == true then
																																																				mech.Status = "Leaving Invisibility for the boss"
																																																				return true
																																																			end

																																																			if not num5.ClaimMovement("mech") then
																																																				mech.Status = "Waiting for " .. tostring(num5.Movement.Owner or "movement")
																																																				return true
																																																			end
																																																			task.spawn(func270)
																																																			return true
																																																		end

																																																		return true
																																																	end)

																																																	func10(function()
																																																		num5.InvisMech = false
																																																		mech.Generation = mech.Generation + 1

																																																		for _, link in ipairs(mech.Links) do
																																																			pcall(function()
																																																				link:Disconnect()
																																																			end)
																																																		end

																																																		pcall(num5.Shield, "mech", false)
																																																		pcall(num5.ReleaseMovement, "mech")
																																																	end)
																																																end

																																																num5.MechBoot(obj6)
																																																n66 = 5

																																																do
																																																	local n71 = 5
																																																	value186 = nil
																																																	value187 = nil
																																																	flag281 = false
																																																	n67 = 0
																																																	n68 = 0
																																																	n69 = 0
																																																	flag282 = nil
																																																	n70 = 0
																																																	str22 = ""
																																																	flag283 = false

																																																	func249 = function(childName9, flag296)
																																																		local obj39 = networking:FindFirstChild(childName9)
																																																		if not obj39 or not obj39:IsA("RemoteFunction") then
																																																			return false, nil, nil
																																																		end

																																																		if flag296 == nil then
																																																			return pcall(obj39.InvokeServer, obj39)
																																																		end
																																																		return pcall(obj39.InvokeServer, obj39, flag296)
																																																	end

																																																	func250 = function()
																																																		local save4 = tbl2.Save
																																																		if type(save4) ~= "table" or type(save4.Get) ~= "function" then
																																																			return nil
																																																		end
																																																		local ok, result = pcall(save4.Get)
																																																		return ok and type(result) == "table" and result or nil
																																																	end

																																																	local function func271(param162)
																																																		local directory4 = tbl2.Assets and tbl2.Assets.Directory
																																																		local flag297 = type(directory4) == "table" and directory4[tostring(param162)] or nil
																																																		return tostring(type(flag297) == "table" and flag297.DisplayName or param162)
																																																	end

																																																	func251 = function(flag298)
																																																		if not flag298 and type(flag282) == "table" and os.clock() < n69 then
																																																			return flag282
																																																		end
																																																		n69 = os.clock() + n71
																																																		local AskState, value191 = func249("RF/ScrambleTradeIn/AskState")

																																																		if AskState and type(value191) == "table" then
																																																			flag282 = value191
																																																			n70 = os.clock()
																																																		end

																																																		return flag282
																																																	end

																																																	func252 = function(param163, list30)
																																																		local requirements = type(param163) == "table" and param163.Requirements or nil
																																																		if type(requirements) ~= "table" or #requirements == 0 then
																																																			return nil, "No active recipe"
																																																		end
																																																		local tbl162 = {}

																																																		if type(list30.EquippedAssets) == "table" then
																																																			for _, equippedAsset in pairs(list30.EquippedAssets) do
																																																				tbl162[equippedAsset] = true
																																																			end
																																																		end

																																																		local tbl163 = {}

																																																		for _, requirement in ipairs(requirements) do
																																																			tbl163[tostring(requirement)] = {}
																																																		end

																																																		local func272 = pairs
																																																		local inventory = list30.Inventory or {}

																																																		for k, value192 in func272(inventory) do
																																																			local flag299 = type(value192) == "table" and tbl163[tostring(value192.Category)] or nil

																																																			if flag299 and value192.InFuse ~= true and value192.IsFavorite ~= true and not tbl162[k] then
																																																				local mutations4 = type(value192.Mutations) == "table" and next(value192.Mutations) ~= nil
																																																				table.insert(flag299, { Uid = k, Scale = tonumber(value192.Scale) or 0, Mutated = mutations4 })
																																																			end
																																																		end

																																																		for _, value193 in pairs(tbl163) do
																																																			table.sort(value193, function(param164, param165)
																																																				if param164.Mutated ~= param165.Mutated then
																																																					return param165.Mutated
																																																				end
																																																				return param164.Scale < param165.Scale
																																																			end)
																																																		end

																																																		local tbl164 = {}
																																																		local tbl165 = {}

																																																		for _, requirement in ipairs(requirements) do
																																																			local entry10 = tbl163[tostring(requirement)]
																																																			local func273 = ipairs
																																																			entry10 = entry10 or {}
																																																			local value194 = nil

																																																			for _, value195 in func273(entry10) do
																																																				if not tbl165[value195.Uid] then
																																																					value194 = value195
																																																					break
																																																				else
																																																					value194 = nil
																																																				end
																																																			end

																																																			if not value194 then
																																																				return nil, "Missing " .. func271(requirement)
																																																			end
																																																			tbl165[value194.Uid] = true
																																																			table.insert(tbl164, value194.Uid)
																																																		end

																																																		return tbl164
																																																	end

																																																	func253 = function()
																																																		local value196 = flag282
																																																		if type(value196) ~= "table" then
																																																			return "Lab status unknown"
																																																		end

																																																		if value196.Unlocked ~= true then
																																																			return "Lab is locked on this account"
																																																		end
																																																		local tbl166 = {}
																																																		local func274 = ipairs
																																																		local requirements = value196.Requirements or {}

																																																		for _, requirement in func274(requirements) do
																																																			table.insert(tbl166, func271(requirement))
																																																		end

																																																		local n72 = (tonumber(value196.SecondsUntilRotation) or 0) - os.clock() - n70

																																																		if n72 < 0 then
																																																			n72 = 0
																																																		end

																																																		local formatted11 = string.format("%s  -  needs %s  -  pity %s/%s  -  free rerolls %s  -  rotates in %d:%02d", tostring(value196.BannerDisplayName or value196.BannerId or "Lab"), #tbl166 > 0 and table.concat(tbl166, ", ") or "unknown", tostring(value196.PityCount or 0), tostring(value196.PityThreshold or 0), tostring(value196.FreeRefreshesRemaining or 0), math.floor(n72 / 60), math.floor(n72 % 60))

																																																		if str22 ~= "" then
																																																			formatted11 ..= "  -  " .. str22
																																																		end

																																																		return formatted11
																																																	end
																																																end
																																															end

																																															do
																																																local function func275(flag300)
																																																	local value197 = func251(true)
																																																	if type(value197) ~= "table" or value197.Unlocked ~= true then
																																																		return
																																																	end

																																																	if value197.PendingReward ~= nil and value197.PendingReward ~= false then
																																																		local AskFinishReveal, flag301 = func249("RF/ScrambleTradeIn/AskFinishReveal")
																																																		str22 = AskFinishReveal and flag301 ~= false and "Reward claimed" or "Reward claim failed"
																																																		n69 = 0
																																																		return
																																																	end

																																																	local result45 = func250()
																																																	if not result45 then
																																																		return
																																																	end
																																																	local flag302, flag303 = func252(value197, result45)

																																																	if not flag302 then
																																																		str22 = flag303 or "Recipe not ready"
																																																		local flag304 = flag300 == n67 and num5.Toggle(value187, false)

																																																		if flag304 then
																																																			flag304 = (tonumber(value197.FreeRefreshesRemaining) or 0) > 0
																																																		end

																																																		if flag304 then
																																																			local AskRefresh, flag305, flag306 = func249("RF/ScrambleTradeIn/AskRefresh")

																																																			if AskRefresh and flag305 ~= false then
																																																				str22 = "Recipe rerolled"
																																																			else
																																																				str22 = tostring(flag306 or "Reroll rejected")
																																																			end

																																																			n69 = 0
																																																		end

																																																		return
																																																	end

																																																	if not num5.Toggle(value186, false) then
																																																		str22 = "Ready to trade in"
																																																		return
																																																	end

																																																	if flag300 ~= n67 then
																																																		return
																																																	end
																																																	local AskTradeIn, flag307, flag308 = func249("RF/ScrambleTradeIn/AskTradeIn", flag302)

																																																	if AskTradeIn and flag307 ~= false then
																																																		str22 = "Trade-in sent"
																																																	else
																																																		str22 = tostring(flag308 or "Trade rejected")
																																																	end

																																																	n69 = 0
																																																end

																																																local flag309 = obj6:CreateText({
																																																	Name = "Lab Status",
																																																	Text = "Loading Lab data...",
																																																})

																																																value186 = obj6:CreateToggle({
																																																	Name = "Auto Lab Trade-In",
																																																	Default = false,
																																																	Callback = function()
																																																		n67 += 1
																																																		str22 = ""
																																																		n68 = 0
																																																		n69 = 0
																																																		tbl8.Wake()
																																																	end,
																																																})

																																																value187 = obj6:CreateToggle({
																																																	Name = "Auto Reroll Lab Recipe",
																																																	Default = false,
																																																	Callback = function()
																																																		n67 += 1
																																																		str22 = ""
																																																		n68 = 0
																																																		n69 = 0
																																																		tbl8.Wake()
																																																	end,
																																																})

																																																for _, item72 in ipairs({
																																																	{
																																																		Key = "Place",
																																																		Name = "Place Lab Recipe Eggs",
																																																	},
																																																	{
																																																		Key = "Hatch",
																																																		Name = "Hatch Lab Recipe Eggs",
																																																	},
																																																}) do
																																																	local key = item72.Key

																																																	num5.Rift.Handles[key] = obj6:CreateToggle({
																																																		Name = item72.Name,
																																																		Default = false,
																																																		Callback = function()
																																																			num5.Rift.Next = 0
																																																			local func276 = num5.Rift.Restart[key]

																																																			if type(func276) == "function" then
																																																				func276()
																																																			end

																																																			tbl8.Wake()
																																																		end,
																																																	})
																																																end

																																																tbl8.Add(function()
																																																	local flag310 = num5.Toggle(value186, false)
																																																	local value198 = num5.Toggle(value187, false)
																																																	local n71 = (flag310 or value198) and 5 or 30

																																																	if not flag283 and (flag282 == nil or n69 == 0 or os.clock() - n70 >= n71) then
																																																		flag283 = true

																																																		task.spawn(function()
																																																			pcall(func251, true)
																																																			flag283 = false
																																																		end)
																																																	end

																																																	if flag309 and type(flag309.Set) == "function" then
																																																		pcall(flag309.Set, flag309, func253())
																																																	end

																																																	local flag311 = flag281

																																																	if not flag281 then
																																																		flag311 = not (flag310 or value198)
																																																	end

																																																	if flag311 or os.clock() < n68 then
																																																		return false
																																																	end
																																																	flag281 = true
																																																	n68 = os.clock() + n66
																																																	local value199 = n67

																																																	task.spawn(function()
																																																		pcall(func275, value199)
																																																		flag281 = false
																																																		tbl8.Wake()
																																																	end)

																																																	return false
																																																end)
																																															end
																																														end

																																														do
																																															local tbl167, tbl168

																																															do
																																																do
																																																	local vector

																																																	do
																																																		do
																																																			n57 = 6
																																																			n58 = 1.5
																																																			n59 = 400
																																																			vector = Vector3.new(2120, -120, -355)

																																																			list23 = {
																																																				"LostPart1",
																																																				"LostPart2",
																																																			}

																																																			tbl167 = {
																																																				{
																																																					Label = "Experiment #001",
																																																					Id = "LimitedTimeExperimentPet",
																																																				},
																																																				{
																																																					Label = "Nibbles #013",
																																																					Id = "Nibbles013",
																																																				},
																																																				{
																																																					Label = "Scrambled Mutation",
																																																					Id = "MutationConsumable",
																																																				},
																																																				{
																																																					Label = "2x Cash Booster",
																																																					Id = "CashBooster",
																																																				},
																																																				{
																																																					Label = "1.25x Speed",
																																																					Id = "SpeedBoost",
																																																				},
																																																				{
																																																					Label = "2x Treadmill Booster",
																																																					Id = "TreadmillBooster",
																																																				},
																																																			}

																																																			do
																																																				local list31 = {}

																																																				for _, item73 in ipairs(tbl167) do
																																																					list31[#list31 + 1] = item73.Label
																																																				end
																																																			end
																																																		end

																																																		tbl151 = {}
																																																		tbl152 = {}
																																																		n60 = 0

																																																		tbl168 = {
																																																			["Experiment #001"] = true,
																																																			["Nibbles #013"] = true,
																																																			["Scrambled Mutation"] = true,
																																																		}

																																																		snapshot = nil
																																																		n61 = -math.huge
																																																		flag261 = false
																																																		n62 = 0
																																																		n63 = 0
																																																		str19 = ""
																																																		str20 = ""

																																																		flag262 = {
																																																			Tool = nil,
																																																			EquipAt = 0,
																																																		}

																																																		n64 = 16
																																																		flag263 = false

																																																		list24 = {
																																																			Index = 1,
																																																			Since = 0,
																																																			Tool = nil,
																																																		}

																																																		flag264 = {
																																																			Latch = false,
																																																			Ended = false,
																																																		}

																																																		flag265 = false
																																																		n65 = 0
																																																		value169 = nil

																																																		do
																																																			local function func277()
																																																				local packages = ReplicatedStorage:FindFirstChild("Packages")
																																																				packages = packages and packages:FindFirstChild("Networking")
																																																				packages = packages and packages:FindFirstChild("RF/Scramble/Request")
																																																				if packages and packages:IsA("RemoteFunction") then
																																																					return packages
																																																				end
																																																				return nil
																																																			end

																																																			func211 = function(payload, ...)
																																																				local result46 = func277()
																																																				if not result46 then
																																																					return nil
																																																				end
																																																				local packed1 = table.pack(...)

																																																				local ok, result = pcall(function()
																																																					return result46:InvokeServer(payload, table.unpack(packed1, 1, packed1.n))
																																																				end)

																																																				if not ok or type(result) ~= "table" then
																																																					return nil
																																																				end

																																																				if type(result.Snapshot) == "table" then
																																																					snapshot = result.Snapshot
																																																					n61 = os.clock()
																																																				elseif payload == "Snapshot" and type(result.State) == "table" then
																																																					snapshot = result
																																																					n61 = os.clock()
																																																				end

																																																				return result
																																																			end
																																																		end
																																																	end

																																																	do
																																																		func212 = function(flag312)
																																																			if flag312 or snapshot == nil or os.clock() - n61 >= n57 then
																																																				func211("Snapshot")
																																																			end

																																																			return snapshot
																																																		end

																																																		func213 = function()
																																																			local value200 = snapshot
																																																			return type(value200) == "table" and type(value200.State) == "table" and value200.State or nil
																																																		end

																																																		func214 = function()
																																																			local value201 = snapshot
																																																			if type(value201) ~= "table" or value201.Enabled == false or type(value201.State) ~= "table" then
																																																				return false
																																																			end
																																																			local eventEndsAt = tonumber(value201.EventEndsAt)
																																																			return eventEndsAt == nil or workspace:GetServerTimeNow() < eventEndsAt
																																																		end

																																																		func215 = function()
																																																			local value202 = snapshot
																																																			local window = type(value202) == "table" and value202.Window or nil
																																																			if type(window) ~= "table" then
																																																				return false, nil
																																																			end
																																																			local serverTimeNow = workspace:GetServerTimeNow()
																																																			local startsAt = tonumber(window.StartsAt)
																																																			local endsAt = tonumber(window.EndsAt)
																																																			local active2 = window.Active == true
																																																			local flag313

																																																			if active2 then
																																																				flag313 = active2
																																																			else
																																																				flag313 = startsAt and endsAt and serverTimeNow >= startsAt and serverTimeNow < endsAt
																																																			end

																																																			if flag313 then
																																																				return true, endsAt and math.max(0, endsAt - serverTimeNow) or nil
																																																			end
																																																			local nextAt = tonumber(window.NextAt)
																																																			return false, nextAt and math.max(0, nextAt - serverTimeNow) or nil
																																																		end

																																																		func216 = function(param166, param167)
																																																			local lostParts = type(param166) == "table" and param166.LostParts or nil
																																																			if type(lostParts) ~= "table" then
																																																				return false
																																																			end

																																																			if lostParts[param167] then
																																																				return true
																																																			end

																																																			for _, lostPart in pairs(lostParts) do
																																																				if lostPart == param167 then
																																																					return true
																																																				end
																																																			end

																																																			return false
																																																		end

																																																		func217 = function(param168)
																																																			local n66 = 0

																																																			for _, item74 in ipairs(list23) do
																																																				if func216(param168, item74) then
																																																					n66 += 1
																																																				end
																																																			end

																																																			return n66
																																																		end

																																																		do
																																																			local function func278(param169)
																																																				local n66 = math.max(0, math.floor(tonumber(param169) or 0))
																																																				if n66 >= 3600 then
																																																					return string.format("%dh %dm", n66 // 3600, n66 % 3600 // 60)
																																																				end
																																																				return string.format("%dm %ds", n66 // 60, n66 % 60)
																																																			end

																																																			func218 = function()
																																																				local result47 = func213()
																																																				if not result47 then
																																																					return "Dr Scramble event is not running"
																																																				end

																																																				if not func214() then
																																																					return "Dr Scramble event has ended"
																																																				end
																																																				local value203, flag314 = func215()
																																																				local flag315

																																																				if value203 then
																																																					flag315 = "Outbreak live " .. func278(flag314 or 0)
																																																				else
																																																					flag315 = value203
																																																				end

																																																				flag315 = flag315 or flag314 and "Outbreak in " .. func278(flag314) or "Outbreak soon"
																																																				local completed = result47.Completed == true and "Vault claimed"

																																																				if not completed then
																																																					completed = string.format("Lost %d/2  Drone %d/3", func217(result47), math.min(3, tonumber(result47.DroneParts) or 0))
																																																				end

																																																				if value203 then
																																																					local n66 = 0

																																																					for _, value204 in pairs(tbl151) do
																																																						if (tonumber(value204.Health) or 0) > 0 then
																																																							n66 += 1
																																																						end
																																																					end

																																																					flag315 ..= string.format("  %d drones", n66)
																																																				end

																																																				local formatted12 = string.format("Samples %d  -  %s  -  %s", tonumber(result47.Samples) or 0, completed, flag315)

																																																				if str20 ~= "" and num5.Toggle(nil, false) then
																																																					formatted12 ..= "  -  " .. str20
																																																				end

																																																				if str19 ~= "" then
																																																					formatted12 ..= "  -  " .. str19
																																																				end

																																																				return formatted12
																																																			end
																																																		end
																																																	end

																																																	do
																																																		func219 = function()
																																																			return num5.Root()
																																																		end

																																																		func220 = function(num82, callback9, flag316, flag317)
																																																			local n66 = flag317 or 400
																																																			local result48 = func219()
																																																			if not result48 then
																																																				return false
																																																			end
																																																			flag316 = flag316 or 1
																																																			if (result48.Position - num82).Magnitude <= flag316 then
																																																				return true
																																																			end
																																																			num5.Shield("scramble", true)
																																																			local n67 = os.clock() + 6

																																																			while not num5.Swapped() and os.clock() < n67 and not callback9() do
																																																				str19 = "Waiting for the character to settle"
																																																				RunService.Heartbeat:Wait()
																																																			end

																																																			local value205 = func219() or result48
																																																			local character = localPlayer.Character
																																																			num5.Driving = num5.Driving + 1
																																																			local position = value205.Position
																																																			local value206 = nil
																																																			local n68 = (num82 - position).Magnitude / n66 + 3
																																																			local n69 = 0

																																																			local connection6 = RunService.Heartbeat:Connect(function(deltaTime)
																																																				if value206 ~= nil or num5.AntiGuard.Busy then
																																																					return
																																																				end
																																																				n69 += deltaTime
																																																				local result49 = func219()
																																																				if not result49 or callback9() or n69 > n68 or localPlayer.Character ~= character then
																																																					value206 = false
																																																					return
																																																				end

																																																				if (result49.Position - position).Magnitude > 8 then
																																																					position = result49.Position
																																																				end

																																																				local n70 = num82 - position
																																																				local n71 = n66 * deltaTime
																																																				local flag318 = n70.Magnitude <= math.max(n71, flag316)
																																																				position = flag318 and num82 or position + n70.Unit * n71
																																																				local vector2 = Vector3.new(n70.X, 0, n70.Z)
																																																				local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or result49.CFrame.Rotation

																																																				pcall(function()
																																																					result49.CFrame = CFrame.new(position) * cframe
																																																					result49.AssemblyLinearVelocity = Vector3.zero
																																																					result49.AssemblyAngularVelocity = Vector3.zero
																																																				end)

																																																				if flag318 then
																																																					value206 = true
																																																				end
																																																			end)

																																																			while value206 == nil do
																																																				RunService.Heartbeat:Wait()
																																																			end

																																																			connection6:Disconnect()
																																																			num5.Driving = math.max(0, num5.Driving - 1)
																																																			num5.Shield("scramble", false)
																																																			return value206
																																																		end

																																																		func221 = function(instance10)
																																																			if typeof(instance10) ~= "Instance" or not instance10:IsA("ProximityPrompt") then
																																																				return false
																																																			end

																																																			local ok = pcall(function()
																																																				instance10:InputHoldBegin()
																																																				local n66 = tonumber(type(num5.PromptHold) == "function" and num5.PromptHold(instance10) or instance10.HoldDuration) or 0

																																																				if n66 > 0 then
																																																					task.wait(n66 + 0.2)
																																																				end

																																																				instance10:InputHoldEnd()
																																																			end)

																																																			if not ok and type(fireproximityprompt) == "function" then
																																																				ok = pcall(fireproximityprompt, instance10)
																																																			end

																																																			return ok
																																																		end

																																																		do
																																																			local function func279()
																																																				local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																																																				local secretZones = world and world:FindFirstChild("SecretZones")
																																																				return secretZones and secretZones:FindFirstChild("Cave") or nil
																																																			end

																																																			func222 = function(childName10)
																																																				local result50 = func279()
																																																				local teleporter = result50 and result50:FindFirstChild("Teleporter")
																																																				teleporter = teleporter and teleporter:FindFirstChild(childName10)
																																																				teleporter = teleporter and teleporter:FindFirstChild("SecretZonePrompt", true)
																																																				return teleporter and teleporter:IsA("ProximityPrompt") and teleporter or nil
																																																			end
																																																		end
																																																	end

																																																	func223 = function(part15, param170)
																																																		part15 = part15 and part15.Parent
																																																		if part15 and part15:IsA("Attachment") then
																																																			return part15.WorldPosition
																																																		end

																																																		if part15 and part15:IsA("BasePart") then
																																																			return part15.Position
																																																		end
																																																		return param170
																																																	end

																																																	func224 = function()
																																																		local result51 = func219()
																																																		if not result51 then
																																																			return false
																																																		end
																																																		local position = result51.Position
																																																		local vector2 = Vector3.new(position.X - vector.X, 0, position.Z - vector.Z)
																																																		return position.Y < -60 and vector2.Magnitude < 160
																																																	end
																																																end

																																																do
																																																	local function func280()
																																																		local world = workspace:FindFirstChild("World") or workspace:FindFirstChild("__OBJECTS")
																																																		world = world and world:FindFirstChild("Areas")
																																																		world = world and world:FindFirstChild("SeparationLine")
																																																		return world and world:IsA("BasePart") and world.Position.X or 552
																																																	end

																																																	func225 = function(part16)
																																																		if not part16 then
																																																			part16 = func219()
																																																			part16 = part16 and part16.Position
																																																		end

																																																		return part16 ~= nil and part16.X < func280()
																																																	end
																																																end
																																															end

																																															do
																																																do
																																																	local connection6 = localPlayer.CharacterAdded:Connect(function()
																																																		num5.ScrambleRespawned = true
																																																		flag262.Tool = nil
																																																		flag262.EquipAt = 0
																																																	end)

																																																	func10(function()
																																																		pcall(function()
																																																			connection6:Disconnect()
																																																		end)
																																																	end)
																																																end

																																																func226 = function(callback10, flag319)
																																																	if not func225() then
																																																		num5.ScrambleRespawned = false
																																																		return true
																																																	end

																																																	if flag319 and func225(flag319) then
																																																		return true
																																																	end
																																																	--[=[ 𝐒𝐋 ]=] -- discord.gg/x7YbZeezpm

																																																	local function func281()
																																																		str19 = "Respawned, resting in the safe zone"
																																																		local n66 = os.clock() + 0.75

																																																		while os.clock() < n66 do
																																																			if callback10() then
																																																				return false
																																																			end
																																																			task.wait(0.1)
																																																		end

																																																		num5.ScrambleRespawned = false
																																																		return true
																																																	end

																																																	local stealHome3 = type(num5.StealHome) == "function" and num5.StealHome() or nil
																																																	if not stealHome3 then
																																																		num5.ScrambleRespawned = false
																																																		return true
																																																	end
																																																	local scrambleRespawned = num5.ScrambleRespawned == true

																																																	if num5.DistanceTo(stealHome3) <= 12 then
																																																		if scrambleRespawned then
																																																			return (func281())
																																																		end
																																																		return true
																																																	end

																																																	str19 = scrambleRespawned and "Respawned, easing out through the safe zone" or "Leaving the base through the safe zone"
																																																	local func282 = func220
																																																	local num83 = func282(stealHome3 + Vector3.new(0, 3, 0), callback10, 3, scrambleRespawned and math.min(400, 300) or nil)
																																																	if num83 and scrambleRespawned then
																																																		return (func281())
																																																	end
																																																	return num83
																																																end

																																																do
																																																	local function func283(param171, param172, param173)
																																																		local result52 = func219()
																																																		if not result52 then
																																																			return false
																																																		end
																																																		num5.Shield("scramblefly", true)
																																																		local position = result52.Position
																																																		local flag320 = true

																																																		if Vector3.new(param171.X - position.X, 0, param171.Z - position.Z).Magnitude > 250 then
																																																			local n66 = math.max(position.Y, param171.Y, 98)
																																																			flag320 = func220(Vector3.new(position.X, n66, position.Z), param172, 2) and func220(Vector3.new(param171.X, n66, param171.Z), param172, 2)
																																																		end

																																																		flag320 = flag320 and func220(param171, param172, math.min(param173, 2))
																																																		num5.Shield("scramblefly", false)
																																																		return flag320
																																																	end

																																																	local function func284()
																																																		local stealHome4 = type(num5.StealHome) == "function" and num5.StealHome() or nil
																																																		return stealHome4 and stealHome4 + Vector3.new(0, 3, 0) or nil
																																																	end

																																																	func227 = function(num84, param174, flag321)
																																																		local n66 = flag321 or 6
																																																		if num5.DistanceTo(num84) <= n66 then
																																																			return true
																																																		end
																																																		local result53 = func225()
																																																		local flag322 = func225(num84)

																																																		if result53 and not flag322 then
																																																			if not func226(param174, num84) then
																																																				return false
																																																			end
																																																		elseif flag322 and not result53 then
																																																			local result54 = func284()

																																																			if result54 and (result54 - num84).Magnitude > 12 and num5.DistanceTo(result54) > 12 then
																																																				str19 = "Coming back through the safe zone"
																																																				if not func283(result54, param174, 3) then
																																																					return false
																																																				end
																																																			end
																																																		end

																																																		return func283(num84, param174, n66)
																																																	end

																																																	func228 = function(callback11)
																																																		if func225() or callback11() or num5.IsNight() or num5.WallSealed() then
																																																			return
																																																		end
																																																		local result55 = func284()

																																																		if result55 then
																																																			str19 = "Coming back through the safe zone"
																																																			func227(result55, callback11, 4)
																																																		end
																																																	end
																																																end
																																															end

																																															do
																																																local function func285(callback12)
																																																	if func224() then
																																																		return true
																																																	end
																																																	local Entry = func222("Entry")
																																																	local num85 = func223(Entry, Vector3.new(2125.7, 73.1, -295.4))
																																																	str19 = "Flying to the Secret Cave"
																																																	if not func227(num85, callback12, 6) then
																																																		return false
																																																	end

																																																	for i = 1, 4 do
																																																		if callback12() then
																																																			return false
																																																		end
																																																		str19 = "Entering the Secret Cave"
																																																		func221(Entry or func222("Entry"))
																																																		local n66 = os.clock() + 1.5

																																																		while os.clock() < n66 and not func224() do
																																																			RunService.Heartbeat:Wait()
																																																		end

																																																		if func224() then
																																																			return true
																																																		end
																																																	end

																																																	str19 = "Cave door missed, flying in"
																																																	local quest = type(snapshot) == "table" and snapshot.Quest or nil
																																																	local position = type(quest) == "table" and type(quest.EscapedExperiment) == "table" and quest.EscapedExperiment.Position or nil

																																																	if typeof(position) == "Vector3" then
																																																		pcall(num5.FlyTo, position, callback12, "scramble")
																																																	end

																																																	return func224()
																																																end

																																																local function func286(childName11)
																																																	local quest = type(snapshot) == "table" and snapshot.Quest or nil
																																																	local flag323 = type(quest) == "table" and quest[childName11] or nil
																																																	local position = type(flag323) == "table" and flag323.Position or nil
																																																	if typeof(position) == "Vector3" then
																																																		return position
																																																	end
																																																	local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
																																																	drScrambleEvent = drScrambleEvent and drScrambleEvent:FindFirstChild(childName11)
																																																	if drScrambleEvent and drScrambleEvent:IsA("Model") then
																																																		return drScrambleEvent:GetPivot().Position
																																																	end
																																																	return nil
																																																end

																																																local function func287(param175)
																																																	local value207 = snapshot
																																																	local interactions = type(value207) == "table" and value207.Interactions or nil
																																																	return math.max(4, (type(interactions) == "table" and tonumber(interactions[param175]) or 12) - 4)
																																																end

																																																func229 = function(param176)
																																																	local result56 = func213()
																																																	if not result56 or result56.Discovered == true then
																																																		return true
																																																	end
																																																	local EscapedExperiment = func286("EscapedExperiment")
																																																	if not EscapedExperiment or not func285(param176) then
																																																		return false
																																																	end
																																																	str19 = "Talking to the Escaped Experiment"
																																																	if not func220(EscapedExperiment, param176, func287("NpcRadius")) then
																																																		return false
																																																	end
																																																	local Discover = func211("Discover")
																																																	func212(true)
																																																	return Discover ~= nil and func213() ~= nil and func213().Discovered == true
																																																end

																																																func230 = function(callback13)
																																																	local result57 = func213()
																																																	local flag324 = not result57 or result57.Completed == true
																																																	local flag325

																																																	if flag324 then
																																																		flag325 = flag324
																																																	else
																																																		local n66 = #list23
																																																		flag325 = func217(result57) >= n66
																																																	end

																																																	if flag325 then
																																																		return
																																																	end

																																																	if result57.Discovered ~= true and not func229(callback13) then
																																																		return
																																																	end

																																																	for _, item75 in ipairs(list23) do
																																																		if callback13() then
																																																			return
																																																		end

																																																		if not func216(func213(), item75) then
																																																			local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
																																																			local hitbox = drScrambleEvent and drScrambleEvent:FindFirstChild(item75)
																																																			hitbox = hitbox and hitbox:FindFirstChild("Hitbox", true)
																																																			local claimLostPart = hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
																																																			local position = hitbox and hitbox:IsA("BasePart") and hitbox.Position or func286(item75)

																																																			if position then
																																																				str19 = "Flying to " .. (item75 == "LostPart1" and "Lost Part 1" or "Lost Part 2")

																																																				if func227(position + Vector3.new(0, 2, 0), callback13, 3) then
																																																					str19 = "Collecting the lost part"
																																																					local n66 = position + Vector3.new(0, 2.5, 0)
																																																					local character = localPlayer.Character
																																																					num5.Shield("scramble", true)
																																																					num5.Driving = num5.Driving + 1

																																																					local connection6 = RunService.Heartbeat:Connect(function()
																																																						local flag326 = num5.Root()
																																																						if not flag326 or flag326.Parent ~= character or num5.AntiGuard.Busy or num5.Movement.Owner ~= "scramble" then
																																																							return
																																																						end

																																																						pcall(function()
																																																							local rotation = flag326.CFrame.Rotation
																																																							flag326.CFrame = CFrame.new(n66) * rotation
																																																							flag326.AssemblyLinearVelocity = Vector3.zero
																																																							flag326.AssemblyAngularVelocity = Vector3.zero
																																																						end)
																																																					end)

																																																					for i = 1, 4 do
																																																						if not callback13() then
																																																							claimLostPart = claimLostPart or hitbox and hitbox:FindFirstChild("ClaimLostPart", true)
																																																							func221(claimLostPart)
																																																							task.wait(0.6)
																																																							func212(true)
																																																							if not func216(func213(), item75) then
																																																								continue
																																																							end
																																																						end

																																																						break
																																																					end

																																																					connection6:Disconnect()
																																																					num5.Driving = math.max(0, num5.Driving - 1)
																																																					num5.Shield("scramble", false)
																																																					if callback13() then
																																																						return
																																																					end
																																																					continue
																																																				end
																																																			end
																																																		end
																																																	end
																																																end

																																																func231 = function(param177)
																																																	local result58 = func213()
																																																	if not result58 or result58.Completed == true then
																																																		return
																																																	end
																																																	local totalParts = tonumber(result58.TotalParts)

																																																	if not totalParts then
																																																		totalParts = func217(result58) + (tonumber(result58.DroneParts) or 0)
																																																	end

																																																	if totalParts < 5 then
																																																		return
																																																	end
																																																	local ExperimentVault = func286("ExperimentVault")
																																																	if not ExperimentVault or not func285(param177) then
																																																		return
																																																	end
																																																	str19 = "Opening the Experiment Vault"
																																																	if not func220(ExperimentVault, param177, func287("VaultRadius")) then
																																																		return
																																																	end
																																																	func211("Vault")
																																																	func212(true)
																																																	local result59 = func213()

																																																	if result59 and result59.Completed == true then
																																																		str19 = "Vault opened, The Scrambler unlocked"
																																																	end
																																																end
																																															end

																																															func232 = function()
																																																local function func288(instance11)
																																																	if not instance11 or not instance11:IsA("Tool") then
																																																		return false
																																																	end

																																																	if tostring(instance11:GetAttribute("ItemType")) ~= "MutationConsumable" then
																																																		return false
																																																	end
																																																	local attribute = instance11:GetAttribute("MutationId") or instance11:GetAttribute("MutationTemplate")
																																																	if attribute ~= nil then
																																																		return tostring(attribute) == "Scrambled"
																																																	end
																																																	return string.find(string.lower(instance11.Name), "scrambled", 1, true) ~= nil
																																																end

																																																local character = localPlayer.Character

																																																if character then
																																																	for _, child in ipairs(character:GetChildren()) do
																																																		if func288(child) then
																																																			return child, true
																																																		end
																																																	end
																																																end

																																																local backpack = localPlayer:FindFirstChildOfClass("Backpack")

																																																if backpack then
																																																	for _, child in ipairs(backpack:GetChildren()) do
																																																		if func288(child) then
																																																			return child, false
																																																		end
																																																	end
																																																end

																																																return nil, false
																																															end

																																															func233 = function(param178, param179)
																																																local shopPurchases = type(param178) == "table" and param178.ShopPurchases or nil
																																																local flag327 = type(shopPurchases) == "table" and shopPurchases[param179.Id] or nil
																																																if type(flag327) ~= "table" then
																																																	return 0
																																																end
																																																local shopPeriod = type(snapshot) == "table" and snapshot.ShopPeriod or nil
																																																if flag327.Period ~= nil and shopPeriod ~= nil and flag327.Period ~= shopPeriod then
																																																	return 0
																																																end
																																																return tonumber(flag327.Count) or 0
																																															end

																																															func234 = function(callback14)
																																																local value208 = func212(true)
																																																if type(value208) ~= "table" or type(value208.Shop) ~= "table" then
																																																	return
																																																end

																																																for _, item76 in ipairs(tbl167) do
																																																	if callback14() then
																																																		return
																																																	end

																																																	if tbl168[item76.Label] == true then
																																																		for i = 1, 10 do
																																																			local value209 = snapshot
																																																			local result60 = func213()
																																																			local value210, value211, value212 = ipairs(type(value209) == "table" and value209.Shop or {})
																																																			local value213 = nil

																																																			for _, value214 in value210, value211, value212 do
																																																				if type(value214) == "table" and value214.Id == item76.Id then
																																																					value213 = value214
																																																				end
																																																			end

																																																			if not (not value213 or not result60 or callback14()) then
																																																				local purchaseLimit = tonumber(value213.PurchaseLimit)

																																																				if not (purchaseLimit and func233(result60, value213) >= purchaseLimit) then
																																																					if not ((tonumber(result60.Samples) or 0) - (tonumber(value213.Price) or math.huge) < n60) then
																																																						local Shop = func211("Shop", value213.Id, { Quote = value213.Quote, Sequence = tonumber(result60.ShopSequence) or 0 })

																																																						if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
																																																							str19 = "Bought " .. item76.Label
																																																							task.wait(0.4)
																																																							continue
																																																						end
																																																					end
																																																				end
																																																			end

																																																			break
																																																		end
																																																	end
																																																end
																																															end
																																														end
																																													end

																																													local n66, tbl169, tbl170, flag328, n67, n68, n69, n70, func289, func290
																																													local func291, func292, func293, func294, func295, func296

																																													do
																																														local n71, n72, n73, num86, func297

																																														do
																																															local tbl171, value215, func298, func299

																																															do
																																																do
																																																	n71 = 98
																																																	n66 = 12
																																																	n72 = 20
																																																	n73 = 3

																																																	tbl169 = {
																																																		Vector3.new(2000, 90, -360),
																																																		Vector3.new(2700, 90, -370),
																																																		Vector3.new(3400, 90, -365),
																																																		Vector3.new(4100, 90, -360),
																																																		Vector3.new(4800, 90, -370),
																																																		Vector3.new(5500, 90, -360),
																																																		Vector3.new(5900, 90, -365),
																																																	}

																																																	tbl170 = {}

																																																	num86 = {
																																																		Link = nil,
																																																		Goal = nil,
																																																		Look = nil,
																																																		Character = nil,
																																																	}

																																																	do
																																																		local userId = localPlayer.UserId
																																																		local list32 = {}

																																																		for _, item77 in ipairs({
																																																			{
																																																				Label = "Scrap Drone",
																																																				Tier = "ScrapDrone",
																																																			},
																																																			{
																																																				Label = "Reactor Drone",
																																																				Tier = "ReactorDrone",
																																																			},
																																																			{
																																																				Label = "Augmented Drone",
																																																				Tier = "AugmentedDrone",
																																																			},
																																																		}) do
																																																			list32[#list32 + 1] = item77.Label
																																																		end

																																																		tbl171 = {
																																																			ScrapDrone = true,
																																																			ReactorDrone = true,
																																																			AugmentedDrone = true,
																																																		}

																																																		value215 = ({
																																																			"Nearest",
																																																			"Rare First",
																																																			"Most HP First",
																																																		})[1]

																																																		flag328 = ({
																																																			"Tween",
																																																			"Teleport",
																																																		})[1]

																																																		n67 = 110
																																																		n68 = 1.5
																																																		n69 = 0
																																																		n70 = -math.huge

																																																		func298 = function(param180)
																																																			local flag329 = type(param180) == "table" and tonumber(param180.OwnerUserId) or nil
																																																			return flag329 == nil or flag329 == userId
																																																		end
																																																	end
																																																end

																																																func299 = function(part17)
																																																	if typeof(part17) == "CFrame" then
																																																		return part17.Position
																																																	end

																																																	if typeof(part17) == "Vector3" then
																																																		return part17
																																																	end
																																																	return nil
																																																end

																																																do
																																																	local function func300(childName12, param181)
																																																		local obj40 = networking:FindFirstChild(childName12)
																																																		if not obj40 or not obj40:IsA("RemoteEvent") then
																																																			return
																																																		end

																																																		local connection6 = obj40.OnClientEvent:Connect(function(...)
																																																			pcall(param181, ...)
																																																		end)

																																																		func10(function()
																																																			pcall(function()
																																																				connection6:Disconnect()
																																																			end)
																																																		end)
																																																	end

																																																	func300("RE/Scramble/Drones", function(param182)
																																																		if type(param182) ~= "table" then
																																																			return
																																																		end
																																																		local func301 = pairs
																																																		local upserts = type(param182.Upserts) == "table" and param182.Upserts or {}

																																																		for _, upsert in func301(upserts) do
																																																			if type(upsert) == "table" and upsert.Id ~= nil and func298(upsert) then
																																																				local id = tostring(upsert.Id)
																																																				local attributes = type(upsert.Attributes) == "table" and upsert.Attributes or {}
																																																				local tbl172 = tbl151[id] or {}
																																																				tbl172.Id = id
																																																				tbl172.Position = func299(upsert.CFrame) or tbl172.Position
																																																				tbl172.Health = tonumber(upsert.Health) or tbl172.Health or 1
																																																				tbl172.Tier = tostring(attributes.ScrambleTier or tbl172.Tier or "")
																																																				tbl172.Area = tostring(attributes.ScrambleArea or tbl172.Area or "")
																																																				tbl172.Seen = os.clock()
																																																				tbl151[id] = tbl172
																																																			end
																																																		end

																																																		local func302 = pairs
																																																		local removed = type(param182.Removed) == "table" and param182.Removed or {}

																																																		for k, value216 in func302(removed) do
																																																			tbl151[tostring(type(value216) == "string" and value216 or k)] = nil
																																																		end
																																																	end)

																																																	func300("RE/Scramble/Effect", function(flag330, param183, param184)
																																																		if flag330 ~= "Hit" or type(param184) ~= "table" or param184.DroneId == nil then
																																																			return
																																																		end
																																																		local entry11 = tbl151[tostring(param184.DroneId)]
																																																		if not entry11 then
																																																			return
																																																		end
																																																		entry11.Position = func299(param183) or entry11.Position
																																																		entry11.Health = (tonumber(entry11.Health) or 1) - (tonumber(param184.Amount) or 1)

																																																		if type(param184.Motion) == "string" and string.find(param184.Motion, "\"Death\"", 1, true) then
																																																			entry11.Health = 0
																																																		end

																																																		if entry11.Health <= 0 then
																																																			tbl151[entry11.Id] = nil
																																																		end
																																																	end)

																																																	func300("RE/Scramble/Drops", function(flag331)
																																																		local func303 = pairs
																																																		local tbl173 = type(flag331) == "table" and flag331 or {}

																																																		for _, value217 in func303(tbl173) do
																																																			if type(value217) == "table" and value217.Id ~= nil and func298(value217) then
																																																				local position5 = func299(value217.Position) or func299(value217.Origin)

																																																				if position5 then
																																																					tbl152[tostring(value217.Id)] = {
																																																						Position = position5,
																																																						Radius = tonumber(value217.Radius) or 6,
																																																						ExpiresAt = tonumber(value217.ExpiresAt),
																																																						Kind = value217.Kind,
																																																					}
																																																				end
																																																			end
																																																		end
																																																	end)

																																																	func300("RE/Scramble/State", function(list33)
																																																		if type(list33) ~= "table" then
																																																			return
																																																		end

																																																		if list33.Patch == true and type(snapshot) == "table" then
																																																			for k, value218 in pairs(list33) do
																																																				if k ~= "Patch" then
																																																					snapshot[k] = value218
																																																				end
																																																			end
																																																		elseif type(list33.State) == "table" then
																																																			snapshot = list33
																																																		end

																																																		n61 = os.clock()
																																																	end)

																																																	func300("RE/Scramble/RemoveDrops", function(flag332)
																																																		local func304 = pairs
																																																		local tbl174 = type(flag332) == "table" and flag332 or {}

																																																		for k, value219 in func304(tbl174) do
																																																			local tbl175 = tbl152
																																																			local func305 = tostring
																																																			value219 = type(value219) == "string" and value219 or k
																																																			tbl175[func305(value219)] = nil
																																																		end
																																																	end)
																																																end
																																															end

																																															local func306

																																															do
																																																func297 = function(str26)
																																																	local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
																																																	return scrambleLocalVisuals and scrambleLocalVisuals:FindFirstChild("PersonalDrone_" .. str26) or nil
																																																end

																																																do
																																																	local value220 = nil
																																																	local n74 = 0

																																																	func306 = function()
																																																		if value220 and next(value220) ~= nil then
																																																			return value220
																																																		end
																																																		value220 = nil
																																																		if os.clock() < n74 or type(getgc) ~= "function" or not func215() then
																																																			return nil
																																																		end
																																																		n74 = os.clock() + 15

																																																		for _, item78 in ipairs(getgc(false)) do
																																																			if type(item78) == "function" and islclosure(item78) then
																																																				local ok, result = pcall(debug.info, item78, "s")

																																																				if ok and type(result) == "string" and string.find(result, "PersonalDrones", 1, true) then
																																																					local ok2, result2 = pcall(debug.getupvalues, item78)

																																																					if ok2 and type(result2) == "table" then
																																																						for _, value221 in pairs(result2) do
																																																							if type(value221) == "table" then
																																																								local key, value222 = next(value221)
																																																								if type(value222) == "table" and value222.OwnerUserId ~= nil and value222.CFrame ~= nil then
																																																									value220 = value221
																																																									return value221
																																																								end
																																																							end
																																																						end

																																																						continue
																																																					end
																																																				end
																																																			end
																																																		end

																																																		return nil
																																																	end
																																																end
																																															end

																																															do
																																																local function func307()
																																																	local result61 = func306()
																																																	if not result61 then
																																																		return
																																																	end

																																																	for k, value223 in pairs(result61) do
																																																		if type(value223) == "table" and func298(value223) then
																																																			local str27 = tostring(value223.Id or k)
																																																			local attributes = type(value223.Attributes) == "table" and value223.Attributes or {}
																																																			local entry12 = tbl151[str27]
																																																			local health = tonumber(value223.Health)

																																																			if not entry12 then
																																																				entry12 = { Id = str27, Health = health or 1 }
																																																				tbl151[str27] = entry12
																																																			elseif health then
																																																				entry12.Health = math.min(health, tonumber(entry12.Health) or health)
																																																			end

																																																			entry12.Position = func299(value223.CFrame) or entry12.Position
																																																			entry12.Tier = tostring(attributes.ScrambleTier or entry12.Tier or "")
																																																			entry12.Area = tostring(attributes.ScrambleArea or entry12.Area or "")

																																																			if attributes.DroneState == "Death" then
																																																				entry12.Health = 0
																																																			end
																																																		end
																																																	end

																																																	for k in pairs(tbl151) do
																																																		if result61[k] == nil then
																																																			tbl151[k] = nil
																																																		end
																																																	end
																																																end

																																																func289 = function()
																																																	pcall(func307)
																																																	local scrambleLocalVisuals = workspace:FindFirstChild("ScrambleLocalVisuals")
																																																	if not scrambleLocalVisuals then
																																																		return
																																																	end

																																																	for _, child in ipairs(scrambleLocalVisuals:GetChildren()) do
																																																		local attribute = child:GetAttribute("ScrambleDroneId")
																																																		-- deobfuscated by 𝚂𝙻 -> https://discord.gg/x7YbZeezpm

																																																		if child:IsA("Model") and attribute ~= nil and string.sub(child.Name, 1, 14) == "PersonalDrone_" then
																																																			local str28 = tostring(attribute)

																																																			if child:GetAttribute("DroneState") == "Death" then
																																																				tbl151[str28] = nil
																																																			elseif not tbl151[str28] then
																																																				local ok, result = pcall(child.GetPivot, child)

																																																				tbl151[str28] = {
																																																					Id = str28,
																																																					Position = ok and result.Position or nil,
																																																					Health = tonumber(child:GetAttribute("Health")) or 1,
																																																					Tier = tostring(child:GetAttribute("ScrambleTier") or ""),
																																																					Area = tostring(child:GetAttribute("ScrambleArea") or ""),
																																																					Seen = os.clock(),
																																																				}
																																																			end
																																																		end
																																																	end
																																																end
																																															end

																																															func290 = function(part18)
																																																local id2 = func297(part18.Id)
																																																local hitbox = id2 and id2:FindFirstChild("Hitbox")
																																																if hitbox and hitbox:IsA("BasePart") then
																																																	return hitbox.Position
																																																end

																																																if id2 and id2.PrimaryPart then
																																																	return id2.PrimaryPart.Position
																																																end
																																																return part18.Position
																																															end

																																															func291 = function()
																																																local list34 = {}
																																																local now = os.clock()

																																																for k, value224 in pairs(tbl151) do
																																																	local tier = value224.Tier == nil or value224.Tier == "" or tbl171[value224.Tier] == true

																																																	if tier then
																																																		tier = (tonumber(value224.Health) or 0) > 0
																																																	end

																																																	tier = tier and value224.Position
																																																	local flag333

																																																	if tier then
																																																		flag333 = (tbl170[k] or 0) <= now
																																																	else
																																																		flag333 = tier
																																																	end

																																																	if flag333 then
																																																		list34[#list34 + 1] = value224
																																																	end
																																																end

																																																return list34
																																															end

																																															func292 = function()
																																																local result62 = func219()
																																																if not result62 then
																																																	return nil
																																																end
																																																local huge2 = math.huge
																																																local value225 = nil

																																																for _, item79 in ipairs(func291()) do
																																																	local magnitude = ((func290(item79) or item79.Position) - result62.Position).Magnitude
																																																	local flag334 = value215
																																																	local n74

																																																	if flag334 == "Rare First" then
																																																		if item79.Tier == "AugmentedDrone" then
																																																			n74 = magnitude - 200000
																																																		elseif item79.Tier ~= "ReactorDrone" then
																																																			n74 = magnitude
																																																		else
																																																			n74 = magnitude - 100000
																																																		end
																																																	elseif flag334 == "Most HP First" then
																																																		n74 = magnitude - (tonumber(item79.Health) or 0) * 100000
																																																	else
																																																		n74 = magnitude
																																																	end

																																																	if n74 < huge2 then
																																																		huge2 = n74
																																																		value225 = item79
																																																	end
																																																end

																																																return value225
																																															end
																																														end

																																														local func308, func309, func310, func311

																																														do
																																															func308 = function()
																																																local result63 = func219()
																																																if not result63 then
																																																	return nil, nil
																																																end
																																																local serverTimeNow = workspace:GetServerTimeNow()
																																																local huge2 = math.huge
																																																local value226 = nil
																																																local value227 = nil

																																																for k, value228 in pairs(tbl152) do
																																																	if value228.ExpiresAt and value228.ExpiresAt < serverTimeNow then
																																																		tbl152[k] = nil
																																																	else
																																																		local magnitude = (value228.Position - result63.Position).Magnitude
																																																		local n74

																																																		if value228.Kind == "Part" then
																																																			n74 = magnitude - 100000
																																																		else
																																																			n74 = magnitude
																																																		end

																																																		if n74 < huge2 then
																																																			huge2 = n74
																																																			value226 = k
																																																			value227 = value228
																																																		end
																																																	end
																																																end

																																																return value226, value227
																																															end

																																															func293 = function()
																																																if not num86.Link then
																																																	if num86.SwapWait then
																																																		num86.SwapWait = nil
																																																		num5.Shield("scramble", false)
																																																	end

																																																	return
																																																end

																																																num86.Link:Disconnect()
																																																local value229 = num86
																																																local value230 = num86
																																																local value231 = num86
																																																num86.Link = nil
																																																value229.Goal = nil
																																																value230.Look = nil
																																																value231.Character = nil
																																																local value232 = num86
																																																local value233 = num86
																																																local value234 = num86
																																																local value235 = num86
																																																num86.Track = nil
																																																value232.Dir = nil
																																																value233.Last = nil
																																																value234.LastAt = nil
																																																value235.Vel = nil
																																																num5.Driving = math.max(0, num5.Driving - 1)
																																																num5.Shield("scramble", false)
																																															end

																																															func10(func293)

																																															func294 = function(goal, look, track)
																																																if track ~= num86.Track then
																																																	local value236 = num86
																																																	local value237 = num86
																																																	num86.Last = nil
																																																	value236.LastAt = nil
																																																	value237.Vel = nil
																																																end

																																																local value238 = num86
																																																local value239 = num86
																																																num86.Goal = goal
																																																value238.Look = look
																																																value239.Track = track
																																																local character = localPlayer.Character

																																																if num86.Link and num86.Character ~= character then
																																																	func293()
																																																	local value240 = num86
																																																	local value241 = num86
																																																	num86.Goal = goal
																																																	value240.Look = look
																																																	value241.Track = track
																																																end

																																																if num86.Link or not character then
																																																	return
																																																end

																																																if not num5.Swapped() then
																																																	num5.Shield("scramble", true)
																																																	num86.SwapWait = num86.SwapWait or os.clock() + 6
																																																	local swapWait = num86.SwapWait
																																																	if os.clock() < swapWait then
																																																		str19 = "Waiting for the character to settle"
																																																		return
																																																	end
																																																end

																																																if num86.SwapWait then
																																																	num86.SwapWait = nil
																																																else
																																																	num5.Shield("scramble", true)
																																																end

																																																num86.Character = character
																																																num5.Driving = num5.Driving + 1

																																																num86.Link = RunService.Heartbeat:Connect(function(deltaTime)
																																																	local flag335 = num5.Root()
																																																	local goal2 = num86.Goal
																																																	if not flag335 or not goal2 or flag335.Parent ~= num86.Character or num5.AntiGuard.Busy or num5.Movement.Owner ~= "scramble" then
																																																		return
																																																	end
																																																	local position = flag335.Position

																																																	if num86.Track then
																																																		local ok, last = pcall(num86.Track)

																																																		if ok and typeof(last) == "Vector3" then
																																																			local now = os.clock()

																																																			if not num86.Last or not num86.LastAt then
																																																				local value242 = num86
																																																				num86.Last = last
																																																				value242.LastAt = now
																																																			elseif (last - num86.Last).Magnitude > 0.01 then
																																																				local n74 = math.max(now - num86.LastAt, 0.0041666666666666666)
																																																				local n75 = (last - num86.Last) / n74

																																																				if n75.Magnitude < 400 then
																																																					local n76 = math.clamp(n74 * 12, 0.2, 0.8)
																																																					num86.Vel = num86.Vel and num86.Vel:Lerp(n75, n76) or n75
																																																				end

																																																				local value243 = num86
																																																				num86.Last = last
																																																				value243.LastAt = now
																																																			elseif now - num86.LastAt > 0.25 and num86.Vel then
																																																				num86.Vel = num86.Vel:Lerp(Vector3.zero, math.clamp(deltaTime * 6, 0, 1))
																																																			end

																																																			local vel = num86.Vel or Vector3.zero
																																																			local look2 = num86.Last + vel * (math.clamp(now - num86.LastAt, 0, 0.25) + 0.1)
																																																			local vector = Vector3.new(position.X - look2.X, 0, position.Z - look2.Z)

																																																			if vector.Magnitude > 0.5 then
																																																				local unit = vector.Unit
																																																				local n74 = math.clamp(deltaTime * 5, 0, 1)
																																																				local dir = num86.Dir and num86.Dir:Lerp(unit, n74) or unit
																																																				num86.Dir = dir.Magnitude > 0.01 and dir.Unit or unit
																																																			end

																																																			goal2 = look2 + (num86.Dir or Vector3.new(0, 0, 1)) * n64 + Vector3.new(0, -1, 0)
																																																			local value244 = num86
																																																			num86.Goal = goal2
																																																			value244.Look = look2

																																																			if (goal2 - position).Magnitude <= 40 then
																																																				local n74 = math.max(deltaTime, 0.0041666666666666666)
																																																				local n75 = vel + (goal2 - position) / math.max(0.1, n74)
																																																				local n76 = math.max(400, vel.Magnitude + 80)

																																																				if n76 < n75.Magnitude then
																																																					n75 = n75.Unit * n76
																																																				end

																																																				local assemblyLinearVelocity = n75 + Vector3.new(0, workspace.Gravity * n74 * 0.5, 0)
																																																				local vector2 = Vector3.new(look2.X - position.X, 0, look2.Z - position.Z)

																																																				pcall(function()
																																																					if vector2.Magnitude > 0.05 then
																																																						flag335.CFrame = CFrame.lookAt(position, position + vector2.Unit)
																																																					end

																																																					flag335.AssemblyLinearVelocity = assemblyLinearVelocity
																																																					flag335.AssemblyAngularVelocity = Vector3.zero
																																																				end)

																																																				return
																																																			end
																																																		end
																																																	end

																																																	local vector

																																																	if Vector3.new(goal2.X - position.X, 0, goal2.Z - position.Z).Magnitude > 250 then
																																																		local n74 = math.max(n71, goal2.Y)
																																																		vector = position.Y < n74 - 2 and Vector3.new(position.X, n74, position.Z) or Vector3.new(goal2.X, n74, goal2.Z)
																																																	else
																																																		vector = goal2
																																																	end

																																																	local n74 = vector - position
																																																	local n75 = n59 * deltaTime
																																																	vector = n74.Magnitude <= n75 and vector or position + n74.Unit * n75
																																																	local look2 = num86.Look or goal2
																																																	local vector2 = Vector3.new(look2.X - vector.X, 0, look2.Z - vector.Z)
																																																	local cframe = vector2.Magnitude > 0.05 and CFrame.lookAt(Vector3.zero, vector2.Unit) or flag335.CFrame.Rotation

																																																	pcall(function()
																																																		flag335.CFrame = CFrame.new(vector) * cframe
																																																		flag335.AssemblyLinearVelocity = Vector3.zero
																																																		flag335.AssemblyAngularVelocity = Vector3.zero
																																																	end)
																																																end)
																																															end

																																															do
																																																local function func312(instance12)
																																																	if typeof(instance12) ~= "Instance" or not instance12:IsA("Tool") then
																																																		return false
																																																	end
																																																	local attribute = instance12:GetAttribute("GearName")
																																																	local gears = tbl2.Gears
																																																	local directory4 = type(gears) == "table" and gears.Directory or nil
																																																	local flag336 = type(attribute) == "string" and type(directory4) == "table" and directory4[attribute] or nil
																																																	return type(flag336) == "table" and (flag336.ToolController == "Slap" or flag336.SlapPower ~= nil)
																																																end

																																																func309 = function(instance13)
																																																	if typeof(instance13) ~= "Instance" or not instance13:IsA("Tool") then
																																																		return false
																																																	end

																																																	if tostring(instance13:GetAttribute("ItemType")) ~= "Gear" then
																																																		return false
																																																	end
																																																	local str29 = tostring(instance13:GetAttribute("GearName") or "")
																																																	if str29 == "" then
																																																		return false
																																																	end
																																																	return string.find(string.lower(str29), "scrambler", 1, true) ~= nil
																																																end

																																																func310 = function()
																																																	return localPlayer.Character, localPlayer:FindFirstChildOfClass("Backpack")
																																																end

																																																local function func313()
																																																	local value245 = num5.FindBat()
																																																	if value245 then
																																																		return value245
																																																	end
																																																	local value246, value247 = func310()

																																																	for _, item80 in ipairs({ value246, value247 }) do
																																																		if item80 then
																																																			for _, child in ipairs(item80:GetChildren()) do
																																																				if func312(child) or func309(child) then
																																																					return child
																																																				end
																																																			end
																																																		end
																																																	end

																																																	return nil
																																																end

																																																flag262.Valid = function(instance14)
																																																	if typeof(instance14) ~= "Instance" or not instance14:IsA("Tool") then
																																																		return false
																																																	end
																																																	return num5.IsBatTool(instance14) or func312(instance14) or func309(instance14)
																																																end

																																																flag262.Owned = function(obj)
																																																	if typeof(obj) ~= "Instance" or not obj:IsA("Tool") then
																																																		return false
																																																	end
																																																	local flag337, value248 = func310()
																																																	local parent = obj.Parent
																																																	local flag338 = parent ~= nil
																																																	local flag339

																																																	if flag338 then
																																																		flag339 = parent == flag337 or parent == value248
																																																	else
																																																		flag339 = flag338
																																																	end

																																																	return flag339
																																																end

																																																flag262.Name = function(obj)
																																																	if func309(obj) then
																																																		return "The Scrambler"
																																																	end
																																																	return tostring(obj:GetAttribute("GearName") or obj.Name)
																																																end

																																																flag262.Put = function(obj, obj41, parent)
																																																	local equipAt = flag262.EquipAt
																																																	if os.clock() - equipAt < 0.4 then
																																																		return false
																																																	end
																																																	flag262.EquipAt = os.clock()

																																																	pcall(function()
																																																		obj41:EquipTool(obj)
																																																	end)

																																																	if obj.Parent ~= parent then
																																																		pcall(function()
																																																			obj.Parent = parent
																																																		end)
																																																	end

																																																	return obj.Parent == parent
																																																end

																																																func311 = function()
																																																	local character = localPlayer.Character
																																																	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
																																																	if not character or not humanoid or humanoid.Health <= 0 then
																																																		return nil, false
																																																	end
																																																	local tool = character:FindFirstChildWhichIsA("Tool")

																																																	if tool ~= nil and flag262.Valid(tool) then
																																																		flag262.Tool = tool
																																																		str20 = flag262.Name(tool)
																																																		return tool, true
																																																	end

																																																	if not flag262.Owned(flag262.Tool) then
																																																		flag262.Tool = func313()
																																																	end

																																																	local tool2 = flag262.Tool
																																																	if not tool2 then
																																																		str20 = ""
																																																		return nil, false
																																																	end
																																																	str20 = flag262.Name(tool2)
																																																	flag262.Put(tool2, humanoid, character)
																																																	return tool2, tool2.Parent == character
																																																end
																																															end
																																														end

																																														do
																																															local function func314()
																																																local obj42, value249 = func311()

																																																if obj42 and value249 then
																																																	if flag263 then
																																																		pcall(function()
																																																			obj42:Activate()
																																																		end)

																																																		task.defer(function()
																																																			pcall(function()
																																																				obj42:Deactivate()
																																																			end)
																																																		end)
																																																	else
																																																		pcall(function()
																																																			obj42:Deactivate()
																																																			obj42:Activate()
																																																		end)
																																																	end
																																																end

																																																return obj42 ~= nil
																																															end

																																															local function func315()
																																																local value250, value251 = func310()
																																																local value252 = nil
																																																local value253 = nil
																																																local value254 = nil

																																																for _, item81 in ipairs({ value250, value251 }) do
																																																	if item81 then
																																																		for _, child in ipairs(item81:GetChildren()) do
																																																			if flag262.Valid(child) then
																																																				if func309(child) then
																																																					value252 = value252 or child
																																																				elseif num5.IsBatTool(child) and (value253 == nil or not num5.IsBatTool(value253)) then
																																																					if value254 then
																																																						value253 = child
																																																					else
																																																						value254 = value253
																																																						value253 = child
																																																					end
																																																				elseif value253 == nil then
																																																					value253 = child
																																																				elseif value254 == nil then
																																																					value254 = child
																																																				end
																																																			end
																																																		end
																																																	end
																																																end

																																																return value253, value252 or value254
																																															end

																																															local function func316(obj43)
																																																pcall(function()
																																																	obj43:Activate()
																																																end)

																																																task.defer(function()
																																																	pcall(function()
																																																		obj43:Deactivate()
																																																	end)
																																																end)
																																															end

																																															list24.SpamUntil = 0
																																															list24.List = {}
																																															list24.Dirty = true
																																															list24.BuiltAt = 0
																																															list24.NextBag = 0
																																															list24.Links = {}

																																															list24.Click = function(obj)
																																																pcall(obj.Deactivate, obj)
																																																pcall(obj.Activate, obj)
																																															end

																																															list24.Rebuild = function()
																																																list24.Dirty = false
																																																list24.BuiltAt = os.clock()
																																																table.clear(list24.List)
																																																local value255, value256 = func310()

																																																for _, item82 in ipairs({ value255, value256 }) do
																																																	if item82 then
																																																		for _, child in ipairs(item82:GetChildren()) do
																																																			if flag262.Valid(child) then
																																																				list24.List[#list24.List + 1] = child
																																																			end
																																																		end
																																																	end
																																																end
																																															end

																																															list24.Beat = RunService.Heartbeat:Connect(function()
																																																local now = os.clock()
																																																if list24.SpamUntil <= now then
																																																	return
																																																end

																																																if list24.Dirty or now - list24.BuiltAt > 1 then
																																																	list24.Rebuild()
																																																end

																																																local character = localPlayer.Character
																																																local flag340 = now >= list24.NextBag

																																																if flag340 then
																																																	list24.NextBag = now + 0.25
																																																end

																																																for _, item83 in ipairs(list24.List) do
																																																	local parent = item83.Parent

																																																	if parent == character then
																																																		list24.Click(item83)
																																																	elseif flag340 and parent ~= nil then
																																																		list24.Click(item83)
																																																	end
																																																end
																																															end)

																																															list24.Unwatch = function()
																																																for i = #list24.Links, 1, -1 do
																																																	pcall(function()
																																																		list24.Links[i]:Disconnect()
																																																	end)

																																																	list24.Links[i] = nil
																																																end
																																															end

																																															list24.Watch = function(obj)
																																																list24.Unwatch()
																																																list24.Dirty = true
																																																if not obj then
																																																	return
																																																end

																																																list24.Links[#list24.Links + 1] = obj.ChildAdded:Connect(function(child)
																																																	if not child:IsA("Tool") then
																																																		return
																																																	end
																																																	list24.Dirty = true
																																																	local spamUntil = list24.SpamUntil

																																																	if os.clock() < spamUntil and flag262.Valid(child) then
																																																		list24.Click(child)
																																																		task.defer(list24.Click, child)
																																																	end
																																																end)

																																																list24.Links[#list24.Links + 1] = obj.ChildRemoved:Connect(function(child)
																																																	if child:IsA("Tool") then
																																																		list24.Dirty = true
																																																	end
																																																end)

																																																task.defer(function()
																																																	local backpack = localPlayer:FindFirstChildOfClass("Backpack") or localPlayer:WaitForChild("Backpack", 5)

																																																	if backpack and localPlayer.Character == obj then
																																																		list24.Links[#list24.Links + 1] = backpack.ChildAdded:Connect(function()
																																																			list24.Dirty = true
																																																		end)

																																																		list24.Links[#list24.Links + 1] = backpack.ChildRemoved:Connect(function()
																																																			list24.Dirty = true
																																																		end)
																																																	end
																																																end)
																																															end

																																															list24.Watch(localPlayer.Character)
																																															list24.CharLink = localPlayer.CharacterAdded:Connect(list24.Watch)

																																															func10(function()
																																																list24.SpamUntil = 0
																																																list24.Unwatch()

																																																for _, item84 in ipairs({ "Beat", "CharLink" }) do
																																																	if list24[item84] then
																																																		pcall(function()
																																																			list24[item84]:Disconnect()
																																																		end)

																																																		list24[item84] = nil
																																																	end
																																																end
																																															end)

																																															local function func317()
																																																local character = localPlayer.Character
																																																local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
																																																if not character or not humanoid or humanoid.Health <= 0 then
																																																	return false
																																																end
																																																local flag341, flag342 = func315()
																																																if not flag341 or not flag342 then
																																																	return func314()
																																																end
																																																local tbl176 = { flag341, flag342 }
																																																local tbl177 = { 0.3, 0.4 }
																																																local entry13 = tbl176[list24.Index]

																																																if list24.Tool ~= entry13 then
																																																	local value257 = list24
																																																	local value258 = list24
																																																	local now = os.clock()
																																																	value257.Tool = entry13
																																																	value258.Since = now
																																																end

																																																local parent3 = entry13.Parent == character

																																																if parent3 then
																																																	local since = list24.Since
																																																	parent3 = os.clock() - since >= tbl177[list24.Index]
																																																end

																																																if parent3 then
																																																	list24.Index = list24.Index == 1 and 2 or 1
																																																	entry13 = tbl176[list24.Index]
																																																	local value259 = list24
																																																	local value260 = list24
																																																	local now = os.clock()
																																																	value259.Tool = entry13
																																																	value260.Since = now
																																																end

																																																flag262.Tool = entry13
																																																str20 = flag262.Name(entry13)

																																																if entry13.Parent ~= character then
																																																	pcall(function()
																																																		humanoid:EquipTool(entry13)
																																																	end)

																																																	if entry13.Parent ~= character then
																																																		pcall(function()
																																																			entry13.Parent = character
																																																		end)
																																																	end

																																																	list24.Since = os.clock()

																																																	if entry13.Parent == character then
																																																		func316(entry13)
																																																		task.defer(func316, entry13)
																																																	end

																																																	return true
																																																end

																																																func316(entry13)
																																																return true
																																															end

																																															func295 = function(callback15, num87, flag343)
																																																local now = os.clock()
																																																local n74 = now + n73

																																																while os.clock() < n74 and not callback15() do
																																																	local value261, flag344 = func308()
																																																	local flag345 = not flag344

																																																	if not flag345 then
																																																		if num87 then
																																																			flag345 = (flag344.Position - num87).Magnitude > (flag343 or 40)
																																																		else
																																																			flag345 = num87
																																																		end
																																																	end

																																																	if flag345 then
																																																		if num87 and os.clock() - now < 1.2 then
																																																			task.wait(0.1)
																																																			continue
																																																		end
																																																		return
																																																	end

																																																	if func225() and not func225(flag344.Position) then
																																																		func293()
																																																		str19 = "Leaving the base through the safe zone"
																																																		if not func227(flag344.Position + Vector3.new(0, 2.5, 0), callback15, 6) then
																																																			return
																																																		end
																																																		continue
																																																	end

																																																	str19 = flag344.Kind == "Part" and "Picking up a Drone Part" or "Picking up Samples"
																																																	func294(flag344.Position + Vector3.new(0, 2.5, 0), flag344.Position)
																																																	local n75 = os.clock() + 2.5

																																																	while tbl152[value261] and os.clock() < n75 and not callback15() do
																																																		task.wait(0.1)
																																																	end

																																																	tbl152[value261] = nil
																																																	n74 = os.clock() + 1.2
																																																end
																																															end

																																															func296 = function(humanoid3, callback16)
																																																local now = os.clock()
																																																local n74 = tonumber(humanoid3.Health) or 0
																																																local value262 = nil
																																																local value263 = nil
																																																local value264 = nil
																																																local flag346 = false

																																																while not callback16() do
																																																	local entry14 = tbl151[humanoid3.Id]
																																																	local flag347 = not entry14

																																																	if not flag347 then
																																																		flag347 = (tonumber(entry14.Health) or 0) <= 0
																																																	end

																																																	if flag347 then
																																																		return true
																																																	end
																																																	local id3 = func297(humanoid3.Id)
																																																	if id3 and id3:GetAttribute("DroneState") == "Death" then
																																																		tbl151[humanoid3.Id] = nil
																																																		return true
																																																	end
																																																	local result64 = func219()
																																																	local flag348 = result64 ~= nil and entry14.Position ~= nil

																																																	if flag348 then
																																																		flag348 = (result64.Position - (func290(entry14) or entry14.Position)).Magnitude <= 30
																																																	end

																																																	if flag348 and not id3 then
																																																		local now2 = value262 or os.clock()
																																																		if os.clock() - now2 > 1.5 then
																																																			tbl151[humanoid3.Id] = nil
																																																			return false
																																																		end
																																																		value262 = now2
																																																	else
																																																		value262 = nil
																																																	end

																																																	local n75 = tonumber(entry14.Health) or 0

																																																	if n75 ~= n74 then
																																																		value263 = nil
																																																		n74 = n75
																																																	end

																																																	if n72 < os.clock() - now then
																																																		tbl170[humanoid3.Id] = os.clock() + 30
																																																		return false
																																																	end
																																																	local position = func290(entry14) or entry14.Position
																																																	local result65 = func219()
																																																	if not result65 then
																																																		return false
																																																	end

																																																	if func225() and not func225(position) then
																																																		func293()
																																																		str19 = "Leaving the base through the safe zone"
																																																		if not func227(position, callback16, 12) then
																																																			return false
																																																		end

																																																		if callback16() then
																																																			return false
																																																		end
																																																	end

																																																	if not value264 then
																																																		local value265 = nil
																																																		local isBasePart = nil

																																																		value264 = function()
																																																			local entry15 = tbl151[humanoid3.Id]
																																																			if not entry15 then
																																																				return nil
																																																			end

																																																			if not value265 or not value265.Parent then
																																																				value265 = func297(humanoid3.Id)
																																																				local hitbox = value265 and value265:FindFirstChild("Hitbox")
																																																				isBasePart = hitbox and hitbox:IsA("BasePart") and hitbox or value265 and value265.PrimaryPart or nil
																																																			end

																																																			if isBasePart and isBasePart.Parent then
																																																				return isBasePart.Position
																																																			end
																																																			return entry15.Position
																																																		end
																																																	end

																																																	if flag263 then
																																																		func294(position + Vector3.new(0, -1, 16), position, value264)
																																																	else
																																																		func294(position + Vector3.new(0, -1, 5), position)
																																																	end

																																																	if (result65.Position - position).Magnitude <= 60 and not flag263 then
																																																		func311()
																																																	end

																																																	local magnitude = (result65.Position - position).Magnitude
																																																	local flag349 = false

																																																	if flag263 then
																																																		flag349 = math.max(12, n64 + 7)
																																																	end

																																																	local flag350 = magnitude <= (flag349 or 12)

																																																	if flag350 then
																																																		if flag263 then
																																																			list24.SpamUntil = os.clock() + 0.2
																																																		end

																																																		local now2 = value263 or os.clock()
																																																		if os.clock() - now2 > 8 then
																																																			tbl170[humanoid3.Id] = os.clock() + 30
																																																			return false
																																																		end
																																																		local flag351 = false

																																																		if flag263 then
																																																			flag351 = func317()
																																																		end

																																																		if flag351 or not flag263 and func314() then
																																																			str19 = string.format("Smashing %s  %d HP", entry14.Tier ~= "" and entry14.Tier or "drone", math.max(0, tonumber(entry14.Health) or 0))
																																																			value263 = now2
																																																		elseif not flag346 then
																																																			str19 = "No bat found, get any bat to smash drones"
																																																			flag346 = true
																																																			value263 = now2
																																																		else
																																																			value263 = now2
																																																		end
																																																	else
																																																		str19 = "Flying to a drone"
																																																	end

																																																	local wait = task.wait
																																																	local flag352 = false

																																																	if flag263 then
																																																		flag352 = flag350
																																																	end

																																																	wait(flag352 and 0.03 or 0.1)
																																																end

																																																return false
																																															end
																																														end
																																													end

																																													local value266, func318, func319, func320, func321

																																													do
																																														local func322

																																														do
																																															do
																																																local function func323(callback17)
																																																	for _, item85 in ipairs(tbl169) do
																																																		if callback17() then
																																																			return false
																																																		end
																																																		str19 = "Looking for drones"
																																																		func294(item85)
																																																		local n71 = os.clock() + 12

																																																		while os.clock() < n71 and not callback17() do
																																																			func289()
																																																			if #func291() > 0 then
																																																				return true
																																																			end

																																																			if num5.DistanceTo(item85) < 8 then
																																																				break
																																																			end
																																																			task.wait(0.2)
																																																		end
																																																	end

																																																	return #func291() > 0
																																																end

																																																local function func324()
																																																	local serverTimeNow = workspace:GetServerTimeNow()
																																																	local flag353, flag354 = func215()
																																																	if flag353 and flag354 and flag354 < 25 then
																																																		return next(tbl152) ~= nil
																																																	end
																																																	-- S​L // discord.gg/x7YbZeezpm

																																																	for _, value267 in pairs(tbl152) do
																																																		if value267.Kind == "Part" or value267.ExpiresAt and value267.ExpiresAt - serverTimeNow < 30 then
																																																			return true
																																																		end
																																																	end

																																																	return false
																																																end

																																																local value268 = nil

																																																local function func325()
																																																	local window = type(snapshot) == "table" and snapshot.Window or nil
																																																	return type(window) == "table" and window.Index or nil
																																																end

																																																func322 = function(callback18)
																																																	local flag355 = value268 ~= nil and value268 == func325()

																																																	while not callback18() do
																																																		RunService.Heartbeat:Wait()
																																																		if callback18() then
																																																			break
																																																		end
																																																		func289()

																																																		if func324() then
																																																			func295(callback18)
																																																		end

																																																		if func225() then
																																																			func293()
																																																			if not func226(callback18) then
																																																				break
																																																			end
																																																		end

																																																		local result66 = func292()

																																																		if not result66 and next(tbl152) ~= nil then
																																																			func295(callback18)
																																																			func289()
																																																			result66 = func292()
																																																		end

																																																		if not result66 then
																																																			if not func215() or flag355 then
																																																				break
																																																			end
																																																			value268 = func325()
																																																			flag355 = true
																																																			if not func323(callback18) then
																																																				break
																																																			end
																																																			continue
																																																		end

																																																		local position = func290(result66) or result66.Position
																																																		local result67 = func219()
																																																		local magnitude = result67 and (result67.Position - position).Magnitude or 0
																																																		result67 = flag328 == "Teleport" and result67

																																																		if result67 then
																																																			result67 = not (func225() and not func225(position))
																																																		end

																																																		if result67 then
																																																			if magnitude > n66 and magnitude <= n67 and os.clock() >= n69 and os.clock() - n70 >= n68 then
																																																				n70 = os.clock()
																																																				local vector = Vector3.new
																																																				local flag357 = false

																																																				if flag263 then
																																																					flag357 = 16
																																																				end

																																																				local n71 = position + vector(0, -1, flag357 or 5)
																																																				func294(n71, position)
																																																				local result68 = func219()

																																																				if result68 then
																																																					str19 = "Teleporting to the next drone"

																																																					pcall(function()
																																																						result68.CFrame = CFrame.lookAt(n71, Vector3.new(position.X, n71.Y, position.Z))
																																																						result68.AssemblyLinearVelocity = Vector3.zero
																																																						result68.AssemblyAngularVelocity = Vector3.zero
																																																					end)

																																																					local n72 = os.clock() + 0.8

																																																					while true do
																																																						if os.clock() < n72 and not callback18() then
																																																							local result69 = func219()

																																																							if result69 and (result69.Position - n71).Magnitude > 40 then
																																																								n69 = os.clock() + 30
																																																								str19 = "Teleport pulled back, tweening"
																																																								break
																																																							else
																																																								RunService.Heartbeat:Wait()
																																																								continue
																																																							end
																																																						end

																																																						break
																																																					end
																																																				end
																																																			end
																																																		end

																																																		func296(result66, callback18)
																																																	end

																																																	func295(callback18)
																																																	func293()
																																																end
																																															end
																																														end

																																														do
																																															local tbl178 = {
																																																LostPart1 = "Mechanical Gear",
																																																LostPart2 = "Wiring Harness",
																																															}

																																															num5.ScrambleLostPart = function(param185)
																																																return func216(func213(), param185)
																																															end

																																															value266 = nil

																																															func318 = function()
																																																local result70 = func213()
																																																if not result70 then
																																																	return "Lost Parts: no event data"
																																																end
																																																local drScrambleEvent = workspace:FindFirstChild("DrScrambleEvent")
																																																local list35 = {}
																																																local n71 = 0
																																																local n72 = 0

																																																for _, item86 in ipairs(list23) do
																																																	local value269 = drScrambleEvent and drScrambleEvent:FindFirstChild(item86)

																																																	if value269 then
																																																		n71 += 1
																																																	end

																																																	if func216(result70, item86) then
																																																		n72 += 1
																																																	elseif value269 then
																																																		local ok, result = pcall(value269.GetPivot, value269)
																																																		ok = ok and num5.DistanceTo(result.Position) or nil
																																																		list35[#list35 + 1] = ok and string.format("%s %d studs", tbl178[item86], math.floor(ok)) or tbl178[item86]
																																																	else
																																																		list35[#list35 + 1] = tbl178[item86] .. " not on map"
																																																	end
																																																end

																																																local formatted13 = string.format("Lost Parts on map %d/2  -  Collected %d/2", n71, n72)
																																																local str30

																																																if #list35 > 0 then
																																																	str30 = formatted13 .. "  -  " .. table.concat(list35, "  -  ")
																																																else
																																																	str30 = formatted13
																																																end

																																																return str30
																																															end
																																														end

																																														do
																																															local function func326(callback19)
																																																if not func224() then
																																																	return true
																																																end
																																																local Exit = func222("Exit")
																																																local flag358 = func223(Exit, nil)
																																																if not flag358 then
																																																	return false
																																																end
																																																str19 = "Leaving the Secret Cave"
																																																if not func220(flag358, callback19, 4) then
																																																	return false
																																																end

																																																for i = 1, 4 do
																																																	if callback19() then
																																																		return false
																																																	end
																																																	func221(Exit or func222("Exit"))
																																																	local n71 = os.clock() + 1.5

																																																	while os.clock() < n71 and func224() do
																																																		RunService.Heartbeat:Wait()
																																																	end

																																																	if not func224() then
																																																		return true
																																																	end
																																																end

																																																return not func224()
																																															end

																																															local function func327()
																																																return num5.IsNight() or num5.WallSealed()
																																															end

																																															local function func328(callback20)
																																																if not func327() then
																																																	return true
																																																end
																																																func293()

																																																while func327() and not callback20() do
																																																	str19 = num5.IsNight() and "Night, waiting for the wall to drop" or "Waiting for the wall to drop"
																																																	RunService.Heartbeat:Wait()
																																																end

																																																return not callback20()
																																															end

																																															func319 = function()
																																																if not num5.Toggle(nil, false) or not func214() then
																																																	return false
																																																end

																																																if flag264.Ended then
																																																	return false
																																																end

																																																if func215() then
																																																	return true
																																																end
																																																func289()
																																																return #func291() > 0 or next(tbl152) ~= nil
																																															end

																																															func320 = function()
																																																local result71 = func213()
																																																if not result71 or result71.Completed == true or not func214() then
																																																	return false
																																																end
																																																local totalParts2 = tonumber(result71.TotalParts)

																																																if not totalParts2 then
																																																	totalParts2 = func217(result71) + (tonumber(result71.DroneParts) or 0)
																																																end

																																																local flag359 = num5.Toggle(nil, false)

																																																if flag359 then
																																																	local n71 = #list23
																																																	flag359 = func217(result71) < n71
																																																end

																																																local flag360 = num5.Toggle(nil, false) and (totalParts2 >= 5 or result71.Discovered ~= true)
																																																return flag359 or flag360
																																															end

																																															func321 = function(flag361)
																																																local function func329()
																																																	return flag361 ~= n62 or num5.Movement.Owner ~= "scramble"
																																																end

																																																local function func330()
																																																	return func329() or not func319() or func327()
																																																end

																																																while true do
																																																	if func319() and not func329() then
																																																		if func328(func329) then
																																																			pcall(func322, func330)
																																																			if func327() then
																																																				continue
																																																			end
																																																		end
																																																	end

																																																	break
																																																end

																																																func293()
																																																if func329() or func319() then
																																																	return
																																																end

																																																if not func320() then
																																																	func228(func329)
																																																	str19 = ""
																																																	return
																																																end

																																																if not func328(func329) then
																																																	return
																																																end
																																																func212(true)
																																																local result72 = func213()
																																																if not result72 then
																																																	return
																																																end

																																																if not func320() then
																																																	str19 = ""
																																																	return
																																																end

																																																if num5.Toggle(nil, false) and result72.Discovered ~= true then
																																																	pcall(func229, func329)
																																																end

																																																if num5.Toggle(nil, false) then
																																																	pcall(func230, function()
																																																		return func329() or not num5.Toggle(nil, false) or func319() or func327()
																																																	end)
																																																end

																																																if num5.Toggle(nil, false) then
																																																	pcall(func231, function()
																																																		return func329() or not num5.Toggle(nil, false) or func319() or func327()
																																																	end)
																																																end

																																																if func224() and not func329() then
																																																	pcall(func326, func329)
																																																end

																																																if not func224() and not func319() then
																																																	pcall(func228, func329)
																																																end
																																															end
																																														end
																																													end

																																													do
																																														local function func331(callback21)
																																															if not (num5.Treadmill.Riding or num5.OnBelt()) then
																																																return true
																																															end

																																															for i = 1, 3 do
																																																if callback21() then
																																																	return false
																																																end
																																																str19 = "Jumping off the treadmill"
																																																num5.Treadmill.Riding = false
																																																task.spawn(num5.LeaveBelt)
																																																local character = localPlayer.Character
																																																local humanoid = character and character:FindFirstChildOfClass("Humanoid")

																																																if humanoid then
																																																	pcall(function()
																																																		humanoid.Sit = false
																																																		humanoid.Jump = true
																																																		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
																																																	end)
																																																end

																																																local result73 = func219()

																																																if result73 then
																																																	local position = result73.Position
																																																	local n71 = position + Vector3.new(0, 18, 0)
																																																	local now = os.clock()

																																																	while true do
																																																		RunService.Heartbeat:Wait()
																																																		local result74 = func219()

																																																		if not result74 then
																																																			break
																																																		else
																																																			local n72 = math.min(1, (os.clock() - now) / 0.25)

																																																			pcall(function()
																																																				local rotation = result74.CFrame.Rotation
																																																				result74.CFrame = CFrame.new(position:Lerp(n71, n72)) * rotation
																																																				result74.AssemblyLinearVelocity = Vector3.zero
																																																				result74.AssemblyAngularVelocity = Vector3.zero
																																																			end)

																																																			if not (n72 >= 1) then
																																																				continue
																																																			end
																																																			break
																																																		end
																																																	end
																																																end

																																																if not (num5.Treadmill.Riding or num5.OnBelt()) then
																																																	return true
																																																end
																																															end

																																															return not num5.OnBelt()
																																														end

																																														local tbl179 = {
																																															"Highest Value",
																																															"Best Rarity",
																																															"Biggest Size",
																																														}

																																														local tbl180 = {
																																															idle = "#8C93A6",
																																															work = "#FFC857",
																																															good = "#57E08A",
																																															stop = "#FF6B6B",
																																														}

																																														local n71 = 6

																																														local tbl181 = {
																																															Handle = nil,
																																															BuyHandle = nil,
																																															Loop = 0,
																																															MinRarity = 0,
																																															MinIncome = 0,
																																															Priority = tbl179[1],
																																															SkipMutated = true,
																																															Targets = {},
																																															Cooldown = 0,
																																															Status = "Idle",
																																															State = "idle",
																																															Detail = "Turn it on to start applying Scrambled",
																																															RarityColor = "#FFFFFF",
																																															Icon = "",
																																															Ui = {},
																																															Row = nil,
																																															Left = 0,
																																															Pen = 0,
																																															Match = 0,
																																															Tries = 0,
																																															Hits = 0,
																																															Locked = nil,
																																															Short = false,
																																															EggOptions = {},
																																															EggCategory = {},
																																														}

																																														local directory4 = tbl2.Assets and tbl2.Assets.Directory
																																														local tbl182 = {}

																																														if type(directory4) ~= "table" then
																																															local func332, func333, func334, func335, func336

																																															do
																																																local func337, func338, func339, func340

																																																do
																																																	table.sort(tbl182, function(param186, param187)
																																																		if param186.Rarity ~= param187.Rarity then
																																																			return param186.Rarity > param187.Rarity
																																																		end
																																																		return param186.Name < param187.Name
																																																	end)

																																																	for _, item87 in ipairs(tbl182) do
																																																		local formatted14 = string.format("%s [%s]", item87.Name, item87.RarityName)

																																																		if tbl181.EggCategory[formatted14] then
																																																			formatted14 = string.format("%s [%s] (%s)", item87.Name, item87.RarityName, item87.Category)
																																																		end

																																																		table.insert(tbl181.EggOptions, formatted14)
																																																		tbl181.EggCategory[formatted14] = item87.Category
																																																	end

																																																	func332 = function(param188)
																																																		local directory5 = tbl2.Assets and tbl2.Assets.Directory
																																																		return type(directory5) == "table" and directory5[tostring(param188)] or nil
																																																	end

																																																	func337 = function(param189)
																																																		local assetCategory8 = func332(param189.AssetCategory)
																																																		local rarity = type(assetCategory8) == "table" and assetCategory8.Rarity or nil
																																																		local flag362 = type(rarity) == "table"

																																																		if flag362 then
																																																			flag362 = tonumber(rarity.RarityNumber or rarity.Rank)
																																																		end

																																																		return flag362 or 0
																																																	end

																																																	func338 = function(param190)
																																																		local assetCategory9 = func332(param190.AssetCategory)
																																																		local n72 = type(assetCategory9) == "table" and tonumber(assetCategory9.EarningRate) or 0
																																																		local n73 = tonumber(param190.AssetScale) or 0
																																																		if n72 <= 0 or n73 <= 0 then
																																																			return 0
																																																		end
																																																		return n72 * (n73 > 5 and (n73 / 5) ^ 1.2 * 19.637875755794113 or n73 ^ 1.85)
																																																	end

																																																	func339 = function(list36)
																																																		if tostring(list36.BaseMutation or "") == "Scrambled" then
																																																			return true
																																																		end

																																																		if type(list36.Mutations) == "table" then
																																																			for k, mutation in pairs(list36.Mutations) do
																																																				if type(mutation) == "string" and mutation == "Scrambled" then
																																																					return true
																																																				end

																																																				if type(k) == "string" and k == "Scrambled" and mutation ~= false then
																																																					return true
																																																				end
																																																			end
																																																		end

																																																		return false
																																																	end

																																																	func340 = function()
																																																		local eggState2 = tbl2.EggState
																																																		if type(eggState2) ~= "table" or type(eggState2.ReadOwnerEggs) ~= "function" then
																																																			return {}
																																																		end
																																																		local ok, result = pcall(eggState2.ReadOwnerEggs, localPlayer.UserId)
																																																		if not ok or type(result) ~= "table" then
																																																			return {}
																																																		end
																																																		local list37 = {}

																																																		for k, value270 in pairs(result) do
																																																			if type(value270) == "table" and value270.Placement ~= nil then
																																																				k = value270.Uid or k
																																																				value270.Uid = k
																																																				list37[#list37 + 1] = value270
																																																			end
																																																		end

																																																		return list37
																																																	end

																																																	do
																																																		local function func341(childName13)
																																																			childName13 = childName13 and childName13.Uid

																																																			if childName13 then
																																																				local areaEggSlotsClient = workspace:FindFirstChild("AreaEggSlotsClient")
																																																				areaEggSlotsClient = areaEggSlotsClient and areaEggSlotsClient:FindFirstChild(childName13)

																																																				if areaEggSlotsClient then
																																																					local ok, result = pcall(function()
																																																						return areaEggSlotsClient:GetPivot().Position
																																																					end)

																																																					if ok and typeof(result) == "Vector3" then
																																																						return result
																																																					end
																																																				end
																																																			end

																																																			if type(num5.PenAnchor) == "function" then
																																																				local ok, result = pcall(num5.PenAnchor)
																																																				if ok and typeof(result) == "Vector3" then
																																																					return result
																																																				end
																																																			end

																																																			return nil
																																																		end

																																																		func333 = function(param191, flag363)
																																																			local num88 = func341(param191)
																																																			if num88 == nil then
																																																				return true
																																																			end

																																																			if num5.DistanceTo(num88) <= n71 then
																																																				return true
																																																			end

																																																			local function func342()
																																																				if flag363 ~= tbl181.Loop or not num5.Toggle(tbl181.Handle, false) then
																																																					return true
																																																				end

																																																				if num5.Movement.PlaceWanted == true then
																																																					return true
																																																				end
																																																				return num5.Movement.ScrambleWanted == true or num5.Steal.Wanted == true
																																																			end

																																																			if num5.Treadmill.Riding or num5.OnBelt() then
																																																				num5.ExitBelt()
																																																			end

																																																			num5.HoldBelt()
																																																			local ok, result = pcall(num5.FlyTo, num88 + Vector3.new(0, 3, 0), func342, "mutation")
																																																			num5.ReleaseBelt()
																																																			num5.LeaveBelt()
																																																			result = ok and result

																																																			if result then
																																																				local n72 = n71 + 4
																																																				result = num5.DistanceTo(num88) <= n72
																																																			end

																																																			return result
																																																		end
																																																	end
																																																end

																																																do
																																																	local func343 = func232

																																																	local function func344(obj44)
																																																		if not obj44 then
																																																			return 0
																																																		end
																																																		local num89 = tonumber(obj44:GetAttribute("Uses"))
																																																		if num89 ~= nil then
																																																			return num89
																																																		end
																																																		local matched = string.match(obj44.Name, "%[X(%d+)%]")
																																																		return tonumber(matched) or 1
																																																	end

																																																	func334 = function()
																																																		local result75 = func343()
																																																		if not result75 then
																																																			return nil, 0
																																																		end
																																																		local value271 = func344(result75)
																																																		if value271 <= 0 then
																																																			return nil, 0
																																																		end
																																																		return result75, value271
																																																	end
																																																end

																																																tbl181.Grip = function(obj)
																																																	local character = localPlayer.Character
																																																	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
																																																	if not character or not humanoid or not obj or obj.Parent == nil then
																																																		return false
																																																	end

																																																	if obj.Parent ~= character then
																																																		pcall(function()
																																																			humanoid:EquipTool(obj)
																																																		end)

																																																		if obj.Parent ~= character then
																																																			pcall(function()
																																																				obj.Parent = character
																																																			end)
																																																		end

																																																		task.wait(0.2)
																																																	end

																																																	return obj.Parent == character
																																																end

																																																func335 = function()
																																																	if not num5.Toggle(tbl181.BuyHandle, false) or flag265 then
																																																		return false
																																																	end
																																																	flag265 = true
																																																	local flag364 = false

																																																	local ok, result = pcall(function()
																																																		flag364 = tbl181.Purchase()
																																																	end)

																																																	flag265 = false

																																																	if not ok then
																																																		tbl181.Status = "Buy failed: " .. tostring(result)
																																																	end

																																																	return flag364
																																																end

																																																tbl181.Purchase = function()
																																																	local n72 = 0
																																																	local short = false

																																																	for i = 1, 10 do
																																																		local flag365 = n72 == 0 and func212(true) or snapshot
																																																		local result76 = func213()

																																																		if not (type(flag365) ~= "table" or type(result76) ~= "table") then
																																																			local value272, value273, value274 = ipairs(type(flag365.Shop) == "table" and flag365.Shop or {})
																																																			local value275 = nil

																																																			for _, value276 in value272, value273, value274 do
																																																				if type(value276) == "table" and value276.Id == "MutationConsumable" then
																																																					value275 = value276
																																																				end
																																																			end

																																																			if value275 then
																																																				local purchaseLimit2 = tonumber(value275.PurchaseLimit)

																																																				if not (purchaseLimit2 and func233(result76, value275) >= purchaseLimit2) then
																																																					local huge2 = tonumber(value275.Price) or math.huge

																																																					if (tonumber(result76.Samples) or 0) - huge2 < n60 then
																																																						short = true

																																																						if n72 == 0 then
																																																							tbl181.Status = "Need " .. tostring(math.floor(huge2)) .. " Samples"
																																																						end

																																																						break
																																																					else
																																																						local Shop = func211("Shop", value275.Id, { Quote = value275.Quote, Sequence = tonumber(result76.ShopSequence) or 0 })

																																																						if not (type(Shop) ~= "table" or Shop.Ok ~= true) then
																																																							n72 += 1
																																																							task.wait(0.4)
																																																							continue
																																																						end
																																																					end
																																																				end
																																																			end
																																																		end

																																																		break
																																																	end

																																																	if n72 > 0 then
																																																		tbl181.Status = string.format("Bought %d Scrambled", n72)
																																																		tbl181.Short = short
																																																		return true
																																																	end

																																																	tbl181.Short = short
																																																	return false
																																																end

																																																func336 = function()
																																																	local pen = 0
																																																	local match = 0
																																																	local n72 = -1
																																																	local value277 = nil

																																																	for _, item88 in ipairs(func340()) do
																																																		pen += 1
																																																		local skipMutated = tbl181.SkipMutated and func339(item88)
																																																		local flag366 = false

																																																		if skipMutated then
																																																			flag366 = true
																																																		end

																																																		local flag367 = not flag366

																																																		if flag367 then
																																																			local minRarity = tbl181.MinRarity
																																																			flag367 = func337(item88) < minRarity
																																																		end

																																																		if flag367 then
																																																			flag366 = true
																																																		end

																																																		local flag368 = not flag366 and tbl181.MinIncome > 0

																																																		if flag368 then
																																																			local minIncome = tbl181.MinIncome
																																																			flag368 = func338(item88) < minIncome
																																																		end

																																																		if flag368 then
																																																			flag366 = true
																																																		end

																																																		if not flag366 and next(tbl181.Targets) ~= nil and tbl181.Targets[tostring(item88.AssetCategory)] ~= true then
																																																			flag366 = true
																																																		end

																																																		if not flag366 then
																																																			match += 1
																																																			local n73

																																																			if tbl181.Priority == tbl179[2] then
																																																				n73 = func337(item88) * 1000 + (tonumber(item88.AssetScale) or 0)
																																																			elseif tbl181.Priority == tbl179[3] then
																																																				n73 = tonumber(item88.AssetScale) or 0
																																																			else
																																																				n73 = func338(item88)
																																																			end

																																																			local flag369 = n73 > n72

																																																			if not flag369 and value277 ~= nil and n73 == n72 and item88.Uid == tbl181.Locked then
																																																				n72 = n73
																																																				value277 = item88
																																																			elseif flag369 then
																																																				n72 = n73
																																																				value277 = item88
																																																			end
																																																		end
																																																	end

																																																	local value278 = tbl181
																																																	tbl181.Pen = pen
																																																	value278.Match = match
																																																	return value277
																																																end
																																															end

																																															local func345, func346

																																															do
																																																do
																																																	local function func347(param192)
																																																		if typeof(param192) ~= "Color3" then
																																																			return "#FFFFFF"
																																																		end
																																																		return string.format("#%02X%02X%02X", math.floor(param192.R * 255 + 0.5), math.floor(param192.G * 255 + 0.5), math.floor(param192.B * 255 + 0.5))
																																																	end

																																																	local function func348(param193)
																																																		local ok, result = pcall(Color3.fromHex, param193)
																																																		if not ok or typeof(result) ~= "Color3" then
																																																			return param193
																																																		end
																																																		local value279, value280, value281 = result:ToHSV()
																																																		return func347(Color3.fromHSV(value279, math.min(value280, 0.78), math.max(value281, 0.82)))
																																																	end

																																																	func345 = function(flag370)
																																																		local value282 = func332(flag370 and flag370.AssetCategory)
																																																		local icon = type(value282) == "table" and value282.Icon or nil
																																																		if icon == nil then
																																																			return ""
																																																		end

																																																		if tonumber(icon) then
																																																			return "rbxassetid://" .. tostring(icon)
																																																		end
																																																		return tostring(icon)
																																																	end

																																																	func346 = function(flag371)
																																																		local value283 = func332(flag371 and flag371.AssetCategory)
																																																		local rarity = type(value283) == "table" and value283.Rarity or nil
																																																		local flag372 = type(rarity) == "table"

																																																		if flag372 then
																																																			flag372 = tostring(rarity.DisplayName or rarity._id or "")
																																																		end

																																																		flag372 = flag372 or ""
																																																		local packed2 = table.pack(func348(func347(type(rarity) == "table" and rarity.Color or nil)))
																																																		return flag372, table.unpack(packed2, 1, packed2.n)
																																																	end
																																																end
																																															end

																																															local func349, func350

																																															do
																																																do
																																																	local function func351(param194)
																																																		if type(param194) ~= "table" then
																																																			return "No egg selected"
																																																		end
																																																		local assetCategory10 = func332(param194.AssetCategory)
																																																		local flag373 = type(assetCategory10) == "table"

																																																		if flag373 then
																																																			flag373 = tostring(assetCategory10.DisplayName or param194.AssetCategory)
																																																		end

																																																		return flag373 or tostring(param194.AssetCategory)
																																																	end

																																																	func349 = function()
																																																		local idle = tbl180[tbl181.State] or tbl180.idle

																																																		if tbl181.Ui.Accent and type(tbl181.Ui.Accent.Set) == "function" then
																																																			tbl181.Ui.Accent.Set({ Background = idle })
																																																		end

																																																		if tbl181.Ui.Title and type(tbl181.Ui.Title.Set) == "function" then
																																																			tbl181.Ui.Title.Set({ Text = tbl181.Status, Color = idle })
																																																		end

																																																		if tbl181.Ui.Egg and type(tbl181.Ui.Egg.Set) == "function" then
																																																			tbl181.Ui.Egg.Set({ Text = tbl181.Detail, Color = tbl181.RarityColor })
																																																		end

																																																		if tbl181.Ui.Meta and type(tbl181.Ui.Meta.Set) == "function" then
																																																			tbl181.Ui.Meta.Set({
																																																				Text = string.format("Charges %d  Eggs %d/%d  Tries %d  Applied %d", tbl181.Left, tbl181.Match, tbl181.Pen, tbl181.Tries, tbl181.Hits),
																																																			})
																																																		end

																																																		if tbl181.Ui.Icon and type(tbl181.Ui.Icon.Set) == "function" then
																																																			tbl181.Ui.Icon.Set({ Visible = tbl181.Icon ~= "", Image = tbl181.Icon, StrokeColor = tbl181.RarityColor })
																																																		end

																																																		if tbl181.Row and type(tbl181.Row.Set) == "function" then
																																																			pcall(tbl181.Row.Set, tbl181.Row, tbl181.Status .. "  -  " .. tbl181.Detail)
																																																		end
																																																	end

																																																	func350 = function(param195)
																																																		if type(param195) ~= "table" then
																																																			tbl181.Detail = "No egg matches the filters"
																																																			tbl181.RarityColor = "#C7CBD6"
																																																			tbl181.Icon = ""
																																																			return
																																																		end

																																																		local flag374, value284 = func346(param195)
																																																		local n72 = tonumber(param195.AssetScale) or 0
																																																		tbl181.Detail = string.format("%s   %.2f kg", func351(param195), n72)

																																																		if flag374 ~= "" then
																																																			tbl181.Detail = tbl181.Detail .. "   " .. string.upper(flag374)
																																																		end

																																																		tbl181.RarityColor = value284
																																																		tbl181.Icon = func345(param195)
																																																	end
																																																end
																																															end

																																															tbl181.Apply = function(obj, param196)
																																																if not tbl181.Grip(param196) then
																																																	tbl181.State = "work"
																																																	tbl181.Status = "Could not hold Scrambled"
																																																	tbl181.Cooldown = os.clock() + 2
																																																	return false
																																																end

																																																local packages = ReplicatedStorage:FindFirstChild("Packages")
																																																packages = packages and packages:FindFirstChild("Networking")
																																																local rfBossMasteryAskUseMutationConsu = packages and packages:FindFirstChild("RF/BossMastery/AskUseMutationConsumable")

																																																if not rfBossMasteryAskUseMutationConsu or not rfBossMasteryAskUseMutationConsu:IsA("RemoteFunction") then
																																																	tbl181.State = "stop"
																																																	tbl181.Status = "Mutation remote is missing"
																																																	tbl181.Cooldown = os.clock() + 10
																																																	return false
																																																end

																																																tbl181.State = "work"
																																																tbl181.Status = "Applying Scrambled"
																																																tbl181.Tries = tbl181.Tries + 1

																																																local ok, result = pcall(function()
																																																	return rfBossMasteryAskUseMutationConsu:InvokeServer(obj.Uid)
																																																end)

																																																if not ok or type(result) ~= "table" then
																																																	tbl181.Cooldown = os.clock() + 10
																																																	return false
																																																end

																																																if result.Success == true then
																																																	tbl181.Status = "Scrambled applied"
																																																	tbl181.Locked = nil
																																																	tbl181.State = "good"
																																																	tbl181.Hits = tbl181.Hits + 1
																																																	return true
																																																end

																																																local str31 = tostring(result.Message or "")
																																																local lowered4 = string.lower(str31)
																																																tbl181.Status = str31 ~= "" and str31 or "Try failed"
																																																tbl181.State = "work"

																																																if string.find(lowered4, "not found") or string.find(lowered4, "invalid") then
																																																	tbl181.Locked = nil
																																																	tbl181.Cooldown = os.clock() + 3
																																																	return false
																																																end

																																																return true
																																															end

																																															tbl181.Settle = function()
																																																local n72 = os.clock() + 3

																																																while os.clock() < n72 do
																																																	if num5.Grounded() then
																																																		return
																																																	end
																																																	RunService.Heartbeat:Wait()
																																																end
																																															end

																																															tbl181.Over = function(flag375)
																																																if flag375 ~= tbl181.Loop or not num5.Toggle(tbl181.Handle, false) then
																																																	return true
																																																end

																																																if num5.Movement.PlaceWanted == true then
																																																	return true
																																																end
																																																return num5.Movement.ScrambleWanted == true or num5.Steal.Wanted == true
																																															end

																																															tbl181.Idle = function(status, detail, flag376)
																																																tbl181.State = "idle"
																																																tbl181.Status = status
																																																tbl181.Left = 0
																																																tbl181.Detail = detail
																																																tbl181.RarityColor = "#C7CBD6"
																																																tbl181.Icon = ""
																																																tbl181.Cooldown = os.clock() + (flag376 or 5)
																																															end

																																															do
																																																local function func352(param197)
																																																	if num5.Movement.ScrambleWanted == true or num5.Steal.Wanted == true then
																																																		tbl181.State = "work"
																																																		tbl181.Status = num5.Movement.ScrambleWanted == true and "Drone hunt goes first" or "Auto Steal goes first"
																																																		tbl181.Cooldown = os.clock() + 2
																																																		return
																																																	end

																																																	local cooldown = tbl181.Cooldown
																																																	if os.clock() < cooldown then
																																																		return
																																																	end
																																																	local flag377, value285 = func334()

																																																	if not flag377 then
																																																		pcall(func336)
																																																		if func335() then
																																																			tbl181.Cooldown = os.clock() + 0.5
																																																			return
																																																		end

																																																		if tbl181.Short then
																																																			tbl181.Idle("Out of Samples, waiting for more", "Hunt drones to earn Samples", 10)
																																																			return
																																																		end

																																																		if not string.find(tbl181.Status, "Samples", 1, true) then
																																																			tbl181.Status = "Need a Scrambled consumable"
																																																		end

																																																		tbl181.Idle(tbl181.Status, "Buy Scrambled from the event shop", 5)
																																																		return
																																																	end

																																																	tbl181.Left = value285
																																																	local result77 = func336()

																																																	if not result77 or not result77.Uid then
																																																		tbl181.State = "stop"
																																																		tbl181.Status = "Waiting"
																																																		func350(nil)
																																																		return
																																																	end

																																																	if num5.Movement.PlaceWanted == true then
																																																		tbl181.State = "work"
																																																		tbl181.Status = "Auto Place goes first"
																																																		tbl181.Cooldown = os.clock() + 2
																																																		return
																																																	end

																																																	if not num5.ClaimMovement("mutation") then
																																																		tbl181.State = "work"
																																																		tbl181.Status = "Waiting for " .. tostring(num5.Movement.Owner or "movement")
																																																		tbl181.Cooldown = os.clock() + 2
																																																		return
																																																	end

																																																	num5.Movement.MutationWanted = true

																																																	local ok, result = pcall(function()
																																																		while not tbl181.Over(param197) do
																																																			local value286, value287 = func334()

																																																			if value286 then
																																																				tbl181.Left = value287
																																																				local result78 = func336()

																																																				if not result78 or not result78.Uid then
																																																					tbl181.State = "stop"
																																																					tbl181.Status = "Waiting"
																																																					func350(nil)
																																																					break
																																																				else
																																																					if result78.Uid ~= tbl181.Locked then
																																																						tbl181.Locked = result78.Uid
																																																						tbl181.Status = "New target picked"
																																																					end

																																																					func350(result78)

																																																					if not func333(result78, param197) then
																																																						tbl181.State = "work"
																																																						tbl181.Status = "Could not reach the egg"
																																																						tbl181.Cooldown = os.clock() + 3
																																																						break
																																																					elseif not tbl181.Over(param197) then
																																																						if tbl181.Apply(result78, value286) then
																																																							pcall(func349)
																																																							task.wait(0.35)
																																																							continue
																																																						end
																																																					end
																																																				end
																																																			end

																																																			break
																																																		end
																																																	end)

																																																	if not ok then
																																																		tbl181.Status = "Stopped: " .. tostring(result)
																																																		tbl181.State = "work"
																																																		tbl181.Cooldown = os.clock() + 3
																																																	end

																																																	tbl181.Settle()
																																																	num5.Movement.MutationWanted = false
																																																	num5.ReleaseMovement("mutation")
																																																end

																																																tbl181.Handle = obj6:CreateToggle({
																																																	Name = "Auto Use Scrambled Mutation",
																																																	Default = false,
																																																	Callback = function(value)
																																																		tbl181.Loop = tbl181.Loop + 1
																																																		num5.Movement.MutationWanted = false
																																																		num5.ReleaseMovement("mutation")
																																																		if value ~= true then
																																																			return
																																																		end
																																																		local loop = tbl181.Loop

																																																		task.spawn(function()
																																																			while loop == tbl181.Loop and num5.Toggle(tbl181.Handle, false) do
																																																				pcall(func352, loop)
																																																				pcall(func349)
																																																				task.wait(tbl181.State == "idle" and 3 or 1)
																																																			end
																																																		end)
																																																	end,
																																																})
																																															end

																																															if type(obj6.CreateCanvas) == "function" then
																																																local obj45, tbl183, tbl184, n72, n73, n74, value288, func353

																																																do
																																																	do
																																																		local obj46, createToggle, n75, func354, func355

																																																		do
																																																			do
																																																				do
																																																					do
																																																						local obj47 = obj6:CreateCanvas({
																																																							Name = "Scrambled Status",
																																																							ShowTitle = false,
																																																							Layout = "free",
																																																							SubOf = tbl181.Handle,
																																																							Style = {
																																																								TextScale = 1,
																																																								LineHeight = 1.1,
																																																								MinLines = 4,
																																																								MaxLines = 4,
																																																								AutoHeight = true,
																																																								BackgroundTransparency = 0.35,
																																																								TextColor = Color3.fromRGB(255, 255, 255),
																																																								TextStrokeTransparency = 0.7,
																																																							},
																																																							Build = function(obj48)
																																																								tbl181.Ui.Card = obj48:Frame({
																																																									X = 0,
																																																									Y = 0,
																																																									Width = 1,
																																																									Height = 3.6,
																																																									Corner = 0.3,
																																																									Background = "#151821",
																																																									BackgroundTransparency = 0.25,
																																																								})

																																																								tbl181.Ui.Accent = obj48:Frame({
																																																									Parent = tbl181.Ui.Card,
																																																									X = 0.08,
																																																									Y = 0.18,
																																																									Width = 0.16,
																																																									Height = 3.24,
																																																									Corner = 0.2,
																																																									Background = tbl180.idle,
																																																								})

																																																								tbl181.Ui.Icon = obj48:Image({
																																																									Parent = tbl181.Ui.Card,
																																																									X = 0.42,
																																																									Y = 0.3,
																																																									Width = 3,
																																																									Height = 3,
																																																									Corner = 0.3,
																																																									Background = "#242938",
																																																									BackgroundTransparency = 0.1,
																																																									StrokeThickness = 0.06,
																																																									StrokeTransparency = 0,
																																																									Visible = false,
																																																								})

																																																								tbl181.Ui.Title = obj48:Text({
																																																									Parent = tbl181.Ui.Card,
																																																									X = 3.7,
																																																									Y = 0.32,
																																																									Width = 1,
																																																									Height = 1.05,
																																																									Scale = 1.16,
																																																									Wrap = false,
																																																									Text = tbl181.Status,
																																																									Color = tbl180.idle,
																																																									TextStrokeTransparency = 1,
																																																								})

																																																								tbl181.Ui.Egg = obj48:Text({
																																																									Parent = tbl181.Ui.Card,
																																																									X = 3.7,
																																																									Y = 1.42,
																																																									Width = 1,
																																																									Height = 1,
																																																									Scale = 1,
																																																									Wrap = false,
																																																									Text = tbl181.Detail,
																																																									Color = "#FFFFFF",
																																																									TextStrokeTransparency = 1,
																																																								})

																																																								tbl181.Ui.Meta = obj48:Text({
																																																									Parent = tbl181.Ui.Card,
																																																									X = 3.7,
																																																									Y = 2.42,
																																																									Width = 1,
																																																									Height = 0.9,
																																																									Scale = 0.86,
																																																									Wrap = false,
																																																									Text = "Charges 0  Eggs 0/0  Tries 0  Applied 0",
																																																									Color = "#AEB4C6",
																																																									TextStrokeTransparency = 1,
																																																								})

																																																								func349()
																																																							end,
																																																						})

																																																						func10(function()
																																																							pcall(function()
																																																								obj47:Destroy()
																																																							end)
																																																						end)
																																																					end

																																																					obj6:CreateDropdown({
																																																						Name = "Mutation Min Rarity",
																																																						Note = "Only eggs of this rarity and above are used",
																																																						Options = tbl26,
																																																						Default = tbl26[1],
																																																						SubOf = tbl181.Handle,
																																																						Callback = function(value)
																																																							tbl181.MinRarity = tbl27[value] or 0
																																																						end,
																																																					})

																																																					do
																																																						local tbl185 = {
																																																							["K/s"] = {
																																																								Min = 0,
																																																								Max = 1000,
																																																								Mult = 1000,
																																																							},
																																																							["M/s"] = {
																																																								Min = 0,
																																																								Max = 1000,
																																																								Mult = 1000000,
																																																							},
																																																							["B/s"] = {
																																																								Min = 0,
																																																								Max = 100,
																																																								Mult = 1e9,
																																																							},
																																																						}

																																																						local tbl186 = {
																																																							Slider = nil,
																																																							Value = 0,
																																																							Unit = "M/s",
																																																						}

																																																						local function func356(flag378, flag379)
																																																							if flag378 ~= nil then
																																																								tbl186.Value = math.max(0, math.floor(tonumber(flag378) or tbl186.Value))
																																																							end

																																																							if flag379 ~= nil then
																																																								tbl186.Unit = tostring(flag379)
																																																							end

																																																							tbl181.MinIncome = tbl186.Value * (tbl185[tbl186.Unit] or tbl185["M/s"]).Mult
																																																						end

																																																						tbl186.Slider = func11(obj6, {
																																																							Name = "Min Mutation Value",
																																																							Note = "Skip eggs worth less than this (0 = off)",
																																																							SubOf = tbl181.Handle,
																																																							Legacy = "Mutation Min Value",
																																																							SectionName = "Dr Scramble Event",
																																																							OnRaw = function(num90)
																																																								func356(math.floor(num90 / 1000), "K/s")
																																																							end,
																																																						})
																																																					end
																																																				end

																																																				obj6:CreateDropdown({
																																																					Name = "Mutation Priority",
																																																					Note = "Which egg gets the consumable first",
																																																					Options = tbl179,
																																																					Default = tbl179[1],
																																																					SubOf = tbl181.Handle,
																																																					Callback = function(value)
																																																						tbl181.Priority = tostring(value)
																																																					end,
																																																				})

																																																				func16(obj6:CreateMultiDropdown({
																																																					Name = "Mutation Target Eggs",
																																																					Note = "Only use the consumable on these eggs (empty = all)",
																																																					Options = tbl181.EggOptions,
																																																					Default = {},
																																																					SubOf = tbl181.Handle,
																																																					Callback = function(value)
																																																						local targets = {}

																																																						if type(value) == "table" then
																																																							for k, value289 in pairs(value) do
																																																								k = value289 == true and type(k) == "string" and k or type(value289) == "string" and value289
																																																								local flag380 = k or nil

																																																								if flag380 and tbl181.EggCategory[flag380] then
																																																									targets[tbl181.EggCategory[flag380]] = true
																																																								end
																																																							end
																																																						end

																																																						tbl181.Targets = targets
																																																					end,
																																																				}))

																																																				tbl181.BuyHandle = obj6:CreateToggle({
																																																					Name = "Auto Buy Scrambled",
																																																					Note = "Buy another Scrambled from the event shop when you run out",
																																																					Default = false,
																																																					SubOf = tbl181.Handle,
																																																					Callback = function()
																																																						tbl181.Cooldown = 0
																																																					end,
																																																				})

																																																				func10(function()
																																																					tbl181.Loop = tbl181.Loop + 1
																																																					num5.Movement.MutationWanted = false
																																																					num5.ReleaseMovement("mutation")
																																																				end)

																																																				do
																																																					local n76 = nil
																																																					local flag381 = false
																																																					local flag382 = false

																																																					tbl8.Add(function()
																																																						if not flag382 and os.clock() - n61 >= n57 then
																																																							flag382 = true

																																																							task.spawn(function()
																																																								pcall(func212, true)
																																																								flag382 = false
																																																							end)
																																																						end

																																																						local value290 = nil

																																																						if value169 then
																																																							value290 = type(value169.Set) == "function"
																																																						end

																																																						if value290 then
																																																							pcall(value169.Set, nil, func218())
																																																						end

																																																						local value291 = nil

																																																						if value266 then
																																																							value291 = type(value266.Set) == "function"
																																																						end

																																																						if value291 then
																																																							pcall(value266.Set, nil, func318())
																																																						end

																																																						local result79 = func215()
																																																						local flag383 = num5.IsNight()

																																																						if result79 and not flag381 then
																																																							flag264.Latch = flag383
																																																							flag264.Ended = false
																																																						end

																																																						if not flag383 then
																																																							flag264.Latch = false
																																																						elseif result79 and not flag264.Latch and not flag264.Ended then
																																																							flag264.Ended = true
																																																							str19 = "Night arrived, this outbreak is over"
																																																							table.clear(tbl151)
																																																							table.clear(tbl152)
																																																						end

																																																						if not result79 then
																																																							flag264.Ended = false
																																																						end

																																																						if flag381 and not result79 then
																																																							task.delay(15, function()
																																																								if not func215() then
																																																									table.clear(tbl151)
																																																									table.clear(tbl170)
																																																								end
																																																							end)
																																																						end

																																																						flag381 = result79

																																																						if num5.Toggle(nil, false) and not flag265 and os.clock() >= n65 and func214() then
																																																							flag265 = true
																																																							n65 = os.clock() + 8

																																																							task.spawn(function()
																																																								pcall(func234, function()
																																																									return not num5.Toggle(nil, false)
																																																								end)

																																																								flag265 = false
																																																							end)
																																																						end

																																																						local result80 = func319()
																																																						local result81 = func320()
																																																						num5.Movement.ScrambleWanted = result80 or result81
																																																						local invisibilityHandle = num5.InvisibilityHandle
																																																						local flag384 = invisibilityHandle ~= nil and num5.Toggle(invisibilityHandle, false)

																																																						if result80 then
																																																							n76 = nil

																																																							if not num5.InvisSuspended then
																																																								num5.InvisSuspended = true
																																																								flag384 = flag384 and type(result6.Notify) == "function"
																																																								-- https://discord.gg/x7YbZeezpm | Ｓｏｕｒｃｅ Ｌｅａｋ (ＳＬ)

																																																								if flag384 then
																																																									pcall(result6.Notify, "Invisibility", "Invisibility is paused for the drone hunt and comes back after it.", 5)
																																																								end
																																																							end
																																																						elseif num5.InvisSuspended and not flag261 then
																																																							n76 = n76 or os.clock() + 5

																																																							if os.clock() >= n76 then
																																																								n76 = nil
																																																								num5.InvisSuspended = false

																																																								if flag384 and type(result6.Notify) == "function" then
																																																									pcall(result6.Notify, "Invisibility", "The drone hunt is over, Invisibility is back on.", 5)
																																																								end
																																																							end
																																																						end

																																																						local character = localPlayer.Character
																																																						if result80 and not flag261 and character and character:GetAttribute("InvisApplied") == true then
																																																							str19 = "Leaving Invisibility for the hunt"
																																																							return true
																																																						end

																																																						if flag261 then
																																																							return result80
																																																						end

																																																						if not (result80 or result81) or os.clock() < n63 then
																																																							if not result80 and not result81 then
																																																								str19 = ""
																																																							end

																																																							return false
																																																						end

																																																						local steal = num5.Steal
																																																						if steal.Active or steal.Carrying or steal.Wanted then
																																																							str19 = "Auto Steal goes first"
																																																							return result80
																																																						end

																																																						if not num5.ClaimMovement("scramble") then
																																																							str19 = "Waiting for " .. tostring(num5.Movement.Owner or "movement") .. " to finish"
																																																							return result80
																																																						end
																																																						flag261 = true
																																																						n63 = os.clock() + n58
																																																						local flag385 = n62

																																																						task.spawn(function()
																																																							pcall(func331, function()
																																																								return flag385 ~= n62
																																																							end)

																																																							num5.HoldBelt()
																																																							pcall(func321, flag385)
																																																							func293()
																																																							num5.ReleaseBelt()
																																																							num5.ReleaseMovement("scramble")
																																																							flag261 = false
																																																							tbl8.Wake()
																																																						end)

																																																						return result80
																																																					end)
																																																				end
																																																			end

																																																			do
																																																				func10(function()
																																																					n62 += 1
																																																					func293()
																																																					num5.InvisSuspended = false
																																																					num5.Movement.ScrambleWanted = false
																																																					num5.ReleaseMovement("scramble")
																																																				end)

																																																				do
																																																					local obj49 = obj1:CreateTab({
																																																						Name = "Player",
																																																						SectionsExpanded = true,
																																																					})

																																																					num5.EspSection = obj49:CreateSection({
																																																						Name = "ESP",
																																																						Expanded = false,
																																																					})

																																																					obj46 = obj49:CreateSection({
																																																						Name = "Movement",
																																																						Expanded = true,
																																																					})

																																																					obj45 = obj49:CreateSection({
																																																						Name = "Character",
																																																						Expanded = true,
																																																					})

																																																					obj49:CreateSection({
																																																						Name = "Combat",
																																																						Expanded = true,
																																																					})
																																																				end
																																																			end

																																																			createToggle = nil
																																																			n75 = 350

																																																			do
																																																				local connection6 = nil
																																																				local flag386 = false

																																																				local function func357()
																																																					local character = localPlayer.Character
																																																					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
																																																					character = character and character:FindFirstChildOfClass("Humanoid")
																																																					if humanoidRootPart and character and character.Health > 0 then
																																																						return humanoidRootPart, character
																																																					end
																																																					return nil, nil
																																																				end

																																																				local function func358()
																																																					if not flag386 then
																																																						return
																																																					end
																																																					flag386 = false
																																																					local flag387, num91 = func357()
																																																					if not flag387 then
																																																						return
																																																					end
																																																					local assemblyLinearVelocity = flag387.AssemblyLinearVelocity
																																																					local moveDirection = num91.MoveDirection
																																																					local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
																																																					local vector2 = vector.Magnitude > 0.001 and vector.Unit * num91.WalkSpeed or Vector3.zero

																																																					pcall(function()
																																																						flag387.AssemblyLinearVelocity = Vector3.new(vector2.X, assemblyLinearVelocity.Y, vector2.Z)
																																																					end)
																																																				end

																																																				func354 = function()
																																																					if connection6 then
																																																						connection6:Disconnect()
																																																						connection6 = nil
																																																					end

																																																					func358()
																																																					num5.Shield("speed", false)
																																																				end

																																																				func355 = function()
																																																					if connection6 then
																																																						return
																																																					end
																																																					num5.Shield("speed", true)

																																																					connection6 = RunService.Heartbeat:Connect(function()
																																																						if num5.Steal.Active or num5.Flying or num5.Driving > 0 or num5.Treadmill.Riding then
																																																							flag386 = false
																																																							return
																																																						end
																																																						local flag388, value292 = func357()
																																																						if not flag388 or value292.Sit or value292.PlatformStand then
																																																							flag386 = false
																																																							return
																																																						end
																																																						local num92 = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
																																																						if num92 and num92 > workspace:GetServerTimeNow() then
																																																							flag386 = false
																																																							return
																																																						end
																																																						local moveDirection = value292.MoveDirection
																																																						local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)
																																																						if vector.Magnitude <= 0.001 then
																																																							func358()
																																																							return
																																																						end
																																																						local n76 = vector.Unit * n75
																																																						local assemblyLinearVelocity = flag388.AssemblyLinearVelocity

																																																						pcall(function()
																																																							flag388.AssemblyLinearVelocity = Vector3.new(n76.X, assemblyLinearVelocity.Y, n76.Z)
																																																						end)

																																																						flag386 = true
																																																					end)
																																																				end
																																																			end
																																																		end

																																																		do
																																																			local flag389, flag390, flag391

																																																			do
																																																				num5.SpeedForced = false

																																																				do
																																																					local function func359()
																																																						if num5.Toggle(createToggle, false) or num5.SpeedForced then
																																																							func355()
																																																						else
																																																							func354()
																																																						end
																																																					end

																																																					flag389 = false
																																																					flag390 = false
																																																					flag391 = false

																																																					num5.SetSpeedForced = function(flag392)
																																																						num5.SpeedForced = flag392 == true
																																																						flag389 = true
																																																						func359()
																																																					end

																																																					local tbl187 = {
																																																						Name = "Speed Boost",
																																																						Default = false,
																																																						Callback = function()
																																																							if num5.SpeedForced and not num5.Toggle(createToggle, false) then
																																																								flag389 = true
																																																								flag391 = true
																																																							end

																																																							func359()
																																																						end,
																																																					}

																																																					createToggle = obj46.CreateToggle
																																																					createToggle = createToggle(obj46, tbl187)
																																																				end
																																																			end

																																																			local connection6 = RunService.Heartbeat:Connect(function()
																																																				if flag391 then
																																																					flag391 = false

																																																					if type(result6.Notify) == "function" then
																																																						pcall(result6.Notify, "Speed Boost", "Speed Boost must stay on while Invisibility is on.", 5)
																																																					end
																																																				end

																																																				if not flag389 then
																																																					return
																																																				end
																																																				flag389 = false
																																																				local flag393

																																																				if num5.SpeedForced and not num5.Toggle(createToggle, false) then
																																																					flag390 = true
																																																					flag393 = true
																																																				else
																																																					local flag394 = not num5.SpeedForced and flag390
																																																					flag393 = nil

																																																					if flag394 then
																																																						flag390 = false
																																																						flag393 = nil

																																																						if num5.Toggle(createToggle, false) then
																																																							flag393 = false
																																																						end
																																																					end
																																																				end

																																																				if flag393 ~= nil then
																																																					for _, item89 in ipairs({ "Set", "SetValue" }) do
																																																						local ok, result = pcall(function()
																																																							return createToggle[item89]
																																																						end)

																																																						if not (ok and type(result) == "function" and pcall(result, createToggle, flag393)) then
																																																							continue
																																																						end
																																																						break
																																																					end
																																																				end
																																																			end)

																																																			func10(function()
																																																				connection6:Disconnect()
																																																			end)
																																																		end

																																																		obj46:CreateSlider({
																																																			Name = "Boost Speed",
																																																			Min = 20,
																																																			Max = 1000,
																																																			Default = 350,
																																																			Increment = 5,
																																																			Unit = "studs/s",
																																																			Callback = function(value)
																																																				n75 = math.clamp(tonumber(value) or 350, 20, 1000)
																																																			end,
																																																		})

																																																		func10(func354)

																																																		do
																																																			local value293 = nil
																																																			local connection6 = nil

																																																			local function func360()
																																																				if connection6 then
																																																					connection6:Disconnect()
																																																					connection6 = nil
																																																				end

																																																				num5.Shield("jump", false)
																																																			end

																																																			value293 = obj46:CreateToggle({
																																																				Name = "Infinite Jump",
																																																				Default = false,
																																																				Callback = function()
																																																					if not num5.Toggle(value293, false) then
																																																						func360()
																																																						return
																																																					end

																																																					if connection6 then
																																																						return
																																																					end
																																																					num5.Shield("jump", true)

																																																					connection6 = UserInputService.JumpRequest:Connect(function()
																																																						local character = localPlayer.Character
																																																						local humanoid = character and character:FindFirstChildOfClass("Humanoid")

																																																						if humanoid then
																																																							pcall(function()
																																																								humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
																																																							end)
																																																						end
																																																					end)
																																																				end,
																																																			})

																																																			func10(func360)
																																																		end
																																																	end

																																																	do
																																																		local value294, flag395, flag396, flag397, flag398, flag399, value295, flag400, func361, func362
																																																		local func363, func364, func365

																																																		do
																																																			local func366, func367

																																																			do
																																																				local hipHeight, func368

																																																				do
																																																					value294 = nil
																																																					flag395 = false
																																																					flag396 = true
																																																					flag397 = false
																																																					flag398 = false
																																																					flag399 = false
																																																					value295 = nil
																																																					flag400 = nil
																																																					hipHeight = 999

																																																					func361 = function()
																																																						return flag395 and not num5.InvisSuspended and not num5.InvisMech
																																																					end

																																																					func362 = function(obj50)
																																																						return obj50 and obj50:FindFirstChildOfClass("Humanoid") or nil
																																																					end

																																																					do
																																																						local function func369(childName14)
																																																							return networking:FindFirstChild(childName14)
																																																						end

																																																						func363 = function(obj51)
																																																							return obj51 ~= nil and obj51:GetAttribute("InvisApplied") == true
																																																						end

																																																						func368 = function()
																																																							local AskDoff = func369("RF/Treadmill/AskDoff")

																																																							if AskDoff and AskDoff:IsA("RemoteFunction") then
																																																								for i = 1, 2 do
																																																									pcall(AskDoff.InvokeServer, AskDoff)
																																																								end
																																																							end
																																																						end

																																																						func366 = function(param198)
																																																							local AskRigWipe = func369("RE/RigSync/AskRigWipe")

																																																							if AskRigWipe and AskRigWipe:IsA("RemoteEvent") then
																																																								pcall(AskRigWipe.FireServer, AskRigWipe, param198)
																																																							end
																																																						end
																																																					end
																																																				end

																																																				do
																																																					local function func370(instance15)
																																																						local backpack = localPlayer:FindFirstChildOfClass("Backpack")

																																																						for _, child in ipairs(instance15:GetChildren()) do
																																																							if child:IsA("Humanoid") then
																																																								pcall(child.UnequipTools, child)
																																																							end
																																																						end

																																																						if backpack then
																																																							for _, child in ipairs(instance15:GetChildren()) do
																																																								if child:IsA("Tool") then
																																																									pcall(function()
																																																										child.Parent = backpack
																																																									end)
																																																								end
																																																							end
																																																						end

																																																						for i = 1, 3 do
																																																							RunService.Heartbeat:Wait()
																																																						end
																																																					end

																																																					func367 = function(obj52)
																																																						local obj53 = func362(obj52)
																																																						if not obj52 or not obj53 then
																																																							return false
																																																						end
																																																						func370(obj52)
																																																						func368()

																																																						pcall(function()
																																																							obj53:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
																																																							obj53.BreakJointsOnDeath = true
																																																							obj53.RequiresNeck = true
																																																							obj53.Health = 0
																																																						end)

																																																						pcall(function()
																																																							obj53:ChangeState(Enum.HumanoidStateType.Dead)
																																																						end)

																																																						pcall(function()
																																																							obj52:BreakJoints()
																																																						end)

																																																						func366(obj52)
																																																						return true
																																																					end
																																																				end

																																																				func364 = function(parent)
																																																					local flag401 = func362(parent)
																																																					local n75 = os.clock() + 10

																																																					while true do
																																																						if os.clock() < n75 and flag396 and parent.Parent then
																																																							flag401 = flag401 or func362(parent)
																																																							if not (flag401 and parent:FindFirstChild("HumanoidRootPart") and parent:FindFirstChild("Head")) then
																																																								task.wait()
																																																								continue
																																																							end
																																																						end

																																																						break
																																																					end

																																																					local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
																																																					if not func361() or not flag401 or not humanoidRootPart or not parent:FindFirstChild("Head") then
																																																						return false
																																																					end
																																																					task.wait(0.05)
																																																					if not func361() or parent.Parent == nil then
																																																						return false
																																																					end

																																																					for i = 1, 2 do
																																																						pcall(flag401.UnequipTools, flag401)
																																																					end

																																																					if type(replicatesignal) == "function" then
																																																						for i = 1, 2 do
																																																							pcall(replicatesignal, flag401.ServerBreakJoints)
																																																						end
																																																					end

																																																					local hipHeight2 = flag401.HipHeight

																																																					pcall(function()
																																																						flag401.HipHeight = hipHeight
																																																					end)

																																																					for _, child in ipairs(parent:GetChildren()) do
																																																						if child:IsA("Accessory") or child:IsA("BasePart") and child ~= humanoidRootPart then
																																																							pcall(function()
																																																								child.Parent = nil
																																																							end)
																																																						end
																																																					end

																																																					task.wait(0.12)

																																																					local function func371()
																																																						pcall(function()
																																																							flag401.HipHeight = hipHeight2
																																																						end)

																																																						for _, child in ipairs(parent:GetChildren()) do
																																																							if child:IsA("Humanoid") and child.HipHeight ~= hipHeight2 then
																																																								pcall(function()
																																																									child.HipHeight = hipHeight2
																																																								end)
																																																							end
																																																						end
																																																					end

																																																					if parent.Parent == nil then
																																																						func371()
																																																						return false
																																																					end
																																																					local motor6D = Instance.new("Motor6D")
																																																					motor6D.Name = "RightWrist"
																																																					motor6D.C0 = CFrame.new(1.2, 0, 0)
																																																					motor6D.C1 = CFrame.new()
																																																					motor6D.Part0 = humanoidRootPart
																																																					motor6D.Parent = humanoidRootPart
																																																					local part = Instance.new("Part")
																																																					part.Name = "RightHand"
																																																					part.Size = Vector3.new(0.2, 0.2, 0.2)
																																																					part.Transparency = 1
																																																					part.CanCollide = false
																																																					part.CanTouch = false
																																																					part.CanQuery = false
																																																					part.Massless = true
																																																					part.CFrame = humanoidRootPart.CFrame * motor6D.C0
																																																					motor6D.Part1 = part
																																																					part.Parent = parent

																																																					pcall(function()
																																																						humanoidRootPart.CanCollide = false
																																																					end)

																																																					func371()
																																																					parent:SetAttribute("InvisApplied", true)

																																																					task.delay(1, function()
																																																						local chilliToolKeeper2 = (typeof(getgenv) == "function" and getgenv() or _G).SovereignToolKeeper

																																																						if parent.Parent and type(chilliToolKeeper2) == "function" then
																																																							pcall(chilliToolKeeper2)
																																																						end
																																																					end)

																																																					task.delay(0.2, function()
																																																						if humanoidRootPart.Parent then
																																																							pcall(function()
																																																								humanoidRootPart.CanCollide = true
																																																							end)
																																																						end
																																																					end)

																																																					local connection6 = parent.ChildAdded:Connect(function(child)
																																																						if child:IsA("Humanoid") then
																																																							task.defer(function()
																																																								if child.HipHeight ~= hipHeight2 then
																																																									pcall(function()
																																																										child.HipHeight = hipHeight2
																																																									end)
																																																								end
																																																							end)
																																																						end
																																																					end)

																																																					local connection7 = nil

																																																					connection7 = parent.AncestryChanged:Connect(function(child, parent2)
																																																						if parent2 == nil then
																																																							connection6:Disconnect()
																																																							connection7:Disconnect()
																																																						end
																																																					end)

																																																					return true
																																																				end
																																																			end

																																																			do
																																																				local function func372()
																																																					local active = num5.Steal.Active or num5.Steal.Carrying or num5.Flying

																																																					if not active then
																																																						active = (num5.Driving or 0) > 0
																																																					end

																																																					return active
																																																				end

																																																				num5.RequestRespawn = function()
																																																					flag399 = true
																																																				end

																																																				func365 = function()
																																																					flag397 = true
																																																					local flag402 = flag399

																																																					while true do
																																																						local flag403 = flag396

																																																						if flag396 then
																																																							flag403 = func372() or not num5.ClaimMovement("invisibility")
																																																						end

																																																						if flag403 then
																																																							task.wait(0.2)
																																																							continue
																																																						end
																																																						break
																																																					end

																																																					local character = localPlayer.Character

																																																					if flag396 and character and (flag402 or func363(character) ~= func361()) and func362(character) then
																																																						flag399 = false
																																																						tbl10.Paused = true
																																																						num5.ShieldPaused = true
																																																						pcall(num5.UndoSwap)
																																																						task.wait()
																																																						func367(localPlayer.Character)
																																																						local n75 = os.clock() + 60
																																																						local n76 = os.clock() + 8

																																																						while flag396 and os.clock() < n75 and localPlayer.Character == character do
																																																							if n76 <= os.clock() then
																																																								n76 = os.clock() + 8
																																																								func366(character)
																																																							end

																																																							task.wait(0.05)
																																																						end

																																																						task.wait(0.1)

																																																						while flag396 and flag398 do
																																																							task.wait(0.05)
																																																						end
																																																					end

																																																					tbl10.Paused = false
																																																					num5.ShieldPaused = false
																																																					num5.ReleaseMovement("invisibility")
																																																					flag397 = false
																																																				end
																																																			end
																																																		end

																																																		do
																																																			local connection6, thread

																																																			do
																																																				connection6 = localPlayer.CharacterAdded:Connect(function(character)
																																																					if not func361() then
																																																						return
																																																					end
																																																					flag398 = true
																																																					num5.ShieldPaused = true

																																																					task.spawn(function()
																																																						pcall(func364, character)
																																																						flag398 = false

																																																						if not flag397 then
																																																							num5.ShieldPaused = false
																																																						end
																																																					end)
																																																				end)

																																																				thread = task.spawn(function()
																																																					while flag396 do
																																																						local character = localPlayer.Character
																																																						local flag404 = func362(character)

																																																						if not flag397 and not flag398 and character and flag404 and flag404.Health > 0 and (flag399 or func363(character) ~= func361()) then
																																																							func365()
																																																						end

																																																						local character3 = func363(localPlayer.Character)

																																																						if character3 ~= value295 then
																																																							value295 = character3
																																																							num5.SetSpeedForced(character3)
																																																						end

																																																						task.wait(0.25)
																																																					end
																																																				end)

																																																				do
																																																					local connection7 = RunService.Heartbeat:Connect(function()
																																																						local character = localPlayer.Character
																																																						if not character or not func363(character) then
																																																							return
																																																						end
																																																						local rightHand = character:FindFirstChild("RightHand")
																																																						local tool = character:FindFirstChildWhichIsA("Tool")
																																																						local handle = tool and tool:FindFirstChild("Handle")
																																																						if not rightHand or not handle or not handle:IsA("BasePart") then
																																																							return
																																																						end
																																																						local cframe = CFrame.new()

																																																						for _, child in ipairs(rightHand:GetChildren()) do
																																																							if child:IsA("JointInstance") and child.Name == "RightGrip" and child.Part1 == handle then
																																																								cframe = child.C0 * child.C1:Inverse()

																																																								if child.Enabled then
																																																									child.Enabled = false
																																																								end
																																																							end
																																																						end

																																																						pcall(function()
																																																							handle.CFrame = rightHand.CFrame * cframe
																																																							handle.AssemblyLinearVelocity = Vector3.zero
																																																							handle.AssemblyAngularVelocity = Vector3.zero
																																																						end)
																																																					end)

																																																					func10(function()
																																																						connection7:Disconnect()
																																																					end)
																																																				end
																																																			end

																																																			local connection7 = RunService.Heartbeat:Connect(function()
																																																				local character = localPlayer.Character
																																																				local flag405 = func362(character)
																																																				local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
																																																				if not flag405 or not humanoidRootPart or flag405.Health <= 0 then
																																																					return
																																																				end
																																																				local flag406 = func363(character) and not num5.Steal.Active and not num5.Flying

																																																				if flag406 then
																																																					flag406 = (num5.Driving or 0) == 0
																																																				end

																																																				if flag406 then
																																																					flag406 = not (num5.Treadmill and num5.Treadmill.Riding)
																																																				end

																																																				if not (flag406 and not flag405.Sit and not flag405.PlatformStand) then
																																																					if flag400 == flag405 then
																																																						flag400 = nil

																																																						pcall(function()
																																																							flag405.AutoRotate = true
																																																						end)
																																																					end

																																																					return
																																																				end

																																																				if flag405.AutoRotate then
																																																					pcall(function()
																																																						flag405.AutoRotate = false
																																																					end)
																																																				end

																																																				flag400 = flag405
																																																				local moveDirection = flag405.MoveDirection
																																																				local vector = Vector3.new(moveDirection.X, 0, moveDirection.Z)

																																																				if vector.Magnitude > 0.01 then
																																																					pcall(function()
																																																						humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + vector.Unit)
																																																					end)
																																																				end
																																																			end)

																																																			num5.InvisibilityHandle = obj45:CreateToggle({
																																																				Name = "Invisibility",
																																																				Note = "Makes you invisible to other players",
																																																				Default = false,
																																																				Callback = function()
																																																					local value296 = nil

																																																					if type(num5.CombatActive) == "function" and num5.CombatActive() then
																																																						value296 = "Auto Hit"
																																																					end

																																																					if num5.Toggle(value294, false) and value296 then
																																																						flag395 = false
																																																						local value297 = value294

																																																						num5.UiDefer(function()
																																																							pcall(value297.Set, value297, false, false)
																																																							num5.Notify("Invisibility", "Turn off " .. value296 .. " first, both cannot be on at the same time")
																																																						end)

																																																						return
																																																					end

																																																					flag395 = num5.Toggle(value294, false) == true

																																																					if func361() and not func363(localPlayer.Character) and num5.Movement.Owner == nil then
																																																						num5.Movement.Owner = "invisibility"
																																																					end
																																																				end,
																																																			})

																																																			func10(function()
																																																				flag396 = false
																																																				connection6:Disconnect()
																																																				connection7:Disconnect()
																																																				pcall(task.cancel, thread)
																																																				tbl10.Paused = false
																																																				num5.ShieldPaused = false
																																																				num5.ReleaseMovement("invisibility")
																																																			end)
																																																		end
																																																	end

																																																	tbl183 = {
																																																		BallSocketConstraint = true,
																																																		NoCollisionConstraint = true,
																																																		HingeConstraint = true,
																																																	}

																																																	tbl184 = {
																																																		[Enum.HumanoidStateType.Physics] = true,
																																																		[Enum.HumanoidStateType.Ragdoll] = true,
																																																		[Enum.HumanoidStateType.FallingDown] = true,
																																																	}

																																																	n72 = 0.5
																																																	n73 = 5
																																																	n74 = 0

																																																	value288 = func6(function()
																																																		return ReplicatedStorage.Shared.Modules.Ragdoll
																																																	end)

																																																	do
																																																		local value298 = nil

																																																		func353 = function()
																																																			if value298 then
																																																				return value298
																																																			end

																																																			local ok, result = pcall(function()
																																																				return require(localPlayer:WaitForChild("PlayerScripts", 5):WaitForChild("PlayerModule", 5)):GetControls()
																																																			end)

																																																			if ok then
																																																				value298 = result
																																																			end

																																																			return value298
																																																		end
																																																	end
																																																end

																																																local createToggle, func373, func374

																																																do
																																																	local flag407, connection6, n75, func375, list38, list39, n76, obj54, humanoid, func376
																																																	local func377, func378, func379, func380, func381, func382, func383, func384, func385

																																																	do
																																																		createToggle = nil
																																																		flag407 = false
																																																		connection6 = nil
																																																		n75 = 0
																																																		func375 = nil
																																																		list38 = {}
																																																		list39 = {}
																																																		n76 = 0
																																																		obj54 = nil
																																																		humanoid = nil

																																																		func376 = function(list40)
																																																			for _, item90 in ipairs(list40) do
																																																				if item90.Connected then
																																																					item90:Disconnect()
																																																				end
																																																			end

																																																			table.clear(list40)
																																																		end

																																																		func377 = function(param199)
																																																			list38[#list38 + 1] = param199
																																																		end

																																																		func378 = function(param200)
																																																			list39[#list39 + 1] = param200
																																																		end

																																																		func379 = function()
																																																			if not obj54 or not humanoid then
																																																				return
																																																			end
																																																			local humanoidRootPart = obj54:FindFirstChild("HumanoidRootPart")
																																																			if not humanoidRootPart then
																																																				return
																																																			end
																																																			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
																																																			local vector = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)
																																																			local n77 = humanoid.WalkSpeed + n73
																																																			local y = assemblyLinearVelocity.Y
																																																			local flag408 = false

																																																			if n77 < vector.Magnitude then
																																																				vector = vector.Unit * n77
																																																				flag408 = true
																																																			end

																																																			if y > n74 then
																																																				y = n74
																																																				flag408 = true
																																																			end

																																																			if flag408 then
																																																				pcall(function()
																																																					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(vector.X, y, vector.Z)
																																																				end)
																																																			end
																																																		end

																																																		do
																																																			local function func386()
																																																				if type(value288) ~= "table" then
																																																					return
																																																				end

																																																				if type(value288.ClearClientRagdoll) == "function" then
																																																					pcall(value288.ClearClientRagdoll)
																																																				end

																																																				if type(value288.Unragdoll) == "function" then
																																																					pcall(value288.Unragdoll, obj54)
																																																				end
																																																			end

																																																			local function func387()
																																																				if not obj54 or not obj54.Parent then
																																																					return
																																																				end

																																																				for _, descendant in ipairs(obj54:GetDescendants()) do
																																																					if tbl183[descendant.ClassName] then
																																																						pcall(function()
																																																							descendant:Destroy()
																																																						end)
																																																					end
																																																				end
																																																			end

																																																			local function func388()
																																																				if not obj54 or not obj54.Parent then
																																																					return
																																																				end

																																																				for _, descendant in ipairs(obj54:GetDescendants()) do
																																																					if descendant:IsA("Motor6D") and not descendant.Enabled then
																																																						pcall(function()
																																																							descendant.Enabled = true
																																																						end)
																																																					elseif descendant:IsA("AnimationConstraint") and not descendant.Enabled then
																																																						pcall(function()
																																																							descendant.Enabled = true
																																																						end)
																																																					end
																																																				end
																																																			end

																																																			local function func389()
																																																				local result82 = func353()

																																																				if result82 and result82.controlsEnabled == false then
																																																					pcall(function()
																																																						result82:Enable()
																																																					end)
																																																				end
																																																			end

																																																			func380 = function()
																																																				local currentCamera = workspace.CurrentCamera

																																																				if currentCamera and humanoid and currentCamera.CameraSubject ~= humanoid then
																																																					pcall(function()
																																																						currentCamera.CameraSubject = humanoid
																																																					end)
																																																				end
																																																			end

																																																			local function func390()
																																																				if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then
																																																					return
																																																				end

																																																				if tbl184[humanoid:GetState()] then
																																																					pcall(function()
																																																						humanoid:ChangeState(Enum.HumanoidStateType.Running)
																																																					end)
																																																				end

																																																				if humanoid.PlatformStand then
																																																					humanoid.PlatformStand = false
																																																				end
																																																			end

																																																			func381 = function()
																																																				if type(value288) == "table" and type(value288.IsRagdolled) == "function" then
																																																					local ok, result = pcall(value288.IsRagdolled, obj54)
																																																					if ok and result == true then
																																																						return true
																																																					end
																																																				end

																																																				local num93 = tonumber(localPlayer:GetAttribute("RagdollEndTime"))
																																																				return num93 ~= nil and num93 > workspace:GetServerTimeNow()
																																																			end

																																																			local n77 = 21

																																																			func382 = function()
																																																				if num5.AntiGuard.Busy == true then
																																																					return true
																																																				end

																																																				if (tonumber(num5.AntiGuard.HitArms) or 0) <= 0 then
																																																					return false
																																																				end
																																																				return os.clock() - (tonumber(num5.AntiGuard.HitArmedAt) or 0) <= n77
																																																			end

																																																			func383 = function()
																																																				if not humanoid or not humanoid.Parent then
																																																					return false
																																																				end

																																																				if humanoid.PlatformStand then
																																																					return true
																																																				end
																																																				return tbl184[humanoid:GetState()] == true
																																																			end

																																																			func384 = function()
																																																				if not obj54 or not obj54.Parent then
																																																					return false
																																																				end

																																																				for _, child in ipairs(obj54:GetChildren()) do
																																																					if tbl183[child.ClassName] then
																																																						return true
																																																					end

																																																					if child:IsA("BasePart") then
																																																						for _, child2 in ipairs(child:GetChildren()) do
																																																							if tbl183[child2.ClassName] then
																																																								return true
																																																							end
																																																						end
																																																					end
																																																				end

																																																				return false
																																																			end

																																																			func385 = function()
																																																				func379()
																																																				func386()
																																																				func387()
																																																				func388()
																																																				func390()
																																																				func389()
																																																				func380()
																																																			end
																																																		end
																																																	end

																																																	do
																																																		local function func391()
																																																			if not flag407 or func382() then
																																																				return
																																																			end
																																																			n75 = os.clock() + n72
																																																		end

																																																		local function func392()
																																																			local character = localPlayer.Character

																																																			if character ~= obj54 then
																																																				if character then
																																																					func375(character)
																																																				else
																																																					n76 += 1
																																																					func376(list39)
																																																					obj54 = nil
																																																					humanoid = nil
																																																				end

																																																				return
																																																			end

																																																			if not obj54 then
																																																				return
																																																			end

																																																			if obj54:FindFirstChildOfClass("Humanoid") ~= humanoid then
																																																				func375(obj54)
																																																			end
																																																		end

																																																		local function func393()
																																																			if not flag407 then
																																																				return
																																																			end
																																																			func392()
																																																			if not obj54 or not humanoid or humanoid.Health <= 0 then
																																																				return
																																																			end

																																																			if func382() then
																																																				n75 = 0
																																																				return
																																																			end
																																																			local now = os.clock()

																																																			if func383() or func381() or func384() then
																																																				n75 = now + n72
																																																			end

																																																			if now <= n75 then
																																																				func385()
																																																			end
																																																		end

																																																		func375 = function(obj55)
																																																			n76 += 1
																																																			local flag409 = n76
																																																			func376(list39)
																																																			obj54 = obj55
																																																			humanoid = nil
																																																			if not flag407 or not obj55 then
																																																				return
																																																			end
																																																			humanoid = obj55:FindFirstChildOfClass("Humanoid")
																																																			if not flag407 or n76 ~= flag409 or obj55 ~= localPlayer.Character or not humanoid or not humanoid:IsA("Humanoid") then
																																																				return
																																																			end

																																																			func378(humanoid.StateChanged:Connect(function(old, new)
																																																				if flag407 and tbl184[new] then
																																																					func391()
																																																				end
																																																			end))

																																																			func378(humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
																																																				if flag407 and humanoid and humanoid.PlatformStand then
																																																					func391()
																																																				end
																																																			end))

																																																			func378(obj55.DescendantAdded:Connect(function(descendant)
																																																				if flag407 and tbl183[descendant.ClassName] then
																																																					func391()
																																																				end
																																																			end))

																																																			func378(obj55.ChildAdded:Connect(function(child)
																																																				if flag407 and child:IsA("Humanoid") and child ~= humanoid then
																																																					task.defer(func392)
																																																				end
																																																			end))

																																																			func380()

																																																			if func381() then
																																																				func391()
																																																			end
																																																		end

																																																		func373 = function()
																																																			flag407 = false
																																																			n76 += 1
																																																			n75 = 0

																																																			if connection6 then
																																																				pcall(function()
																																																					connection6:Disconnect()
																																																				end)

																																																				connection6 = nil
																																																			end

																																																			func376(list39)
																																																			func376(list38)
																																																			obj54 = nil
																																																			humanoid = nil
																																																		end

																																																		func374 = function()
																																																			func373()
																																																			flag407 = true
																																																			func353()
																																																			connection6 = RunService.Heartbeat:Connect(func393)

																																																			func377(localPlayer.CharacterAdded:Connect(function(character)
																																																				if flag407 then
																																																					task.defer(function()
																																																						if flag407 and character == localPlayer.Character then
																																																							func375(character)
																																																						end
																																																					end)
																																																				end
																																																			end))

																																																			func377(localPlayer.CharacterRemoving:Connect(function(character)
																																																				if flag407 and character == obj54 then
																																																					n76 += 1
																																																					n75 = 0
																																																					func376(list39)
																																																					obj54 = nil
																																																					humanoid = nil
																																																				end
																																																			end))

																																																			func377(localPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
																																																				if flag407 then
																																																					func391()
																																																				end
																																																			end))

																																																			local clientRagdollRemote = type(value288) == "table" and value288.ClientRagdollRemote or nil

																																																			if typeof(clientRagdollRemote) == "Instance" and clientRagdollRemote:IsA("RemoteEvent") then
																																																				func377(clientRagdollRemote.OnClientEvent:Connect(function()
																																																					if flag407 and not func382() then
																																																						func379()
																																																						func391()
																																																					end
																																																				end))
																																																			end

																																																			func377(num5.OnHumanoidChanged(function()
																																																				if flag407 and localPlayer.Character then
																																																					func375(localPlayer.Character)
																																																				end
																																																			end))

																																																			if localPlayer.Character then
																																																				func375(localPlayer.Character)
																																																			end
																																																		end
																																																	end
																																																end

																																																do
																																																	do
																																																		local flag410, func394, func395

																																																		do
																																																			do
																																																				func10(func373)

																																																				do
																																																					local tbl188 = {
																																																						Name = "Anti Ragdoll",
																																																						Default = true,
																																																						Callback = function()
																																																							if num5.Toggle(createToggle, false) then
																																																								func374()
																																																							else
																																																								func373()
																																																							end
																																																						end,
																																																					}

																																																					createToggle = obj45.CreateToggle
																																																					createToggle = createToggle(obj45, tbl188)
																																																				end
																																																			end

																																																			flag410 = false

																																																			do
																																																				local tbl189 = {}

																																																				func394 = function()
																																																					for _, item91 in ipairs(tbl189) do
																																																						pcall(function()
																																																							item91:Disconnect()
																																																						end)
																																																					end

																																																					table.clear(tbl189)
																																																				end

																																																				local function func396(humanoid4)
																																																					if flag410 and humanoid4.Parent and humanoid4.Health > 0 and humanoid4.Health < humanoid4.MaxHealth then
																																																						pcall(function()
																																																							humanoid4.Health = humanoid4.MaxHealth
																																																						end)
																																																					end
																																																				end

																																																				func395 = function(obj56)
																																																					func394()
																																																					if not flag410 or not obj56 then
																																																						return
																																																					end
																																																					local humanoid = obj56:FindFirstChildOfClass("Humanoid") or obj56:WaitForChild("Humanoid", 5)
																																																					if not flag410 or not humanoid or not humanoid:IsA("Humanoid") or obj56 ~= localPlayer.Character then
																																																						return
																																																					end

																																																					table.insert(tbl189, humanoid.HealthChanged:Connect(function()
																																																						func396(humanoid)
																																																					end))

																																																					table.insert(tbl189, RunService.Heartbeat:Connect(function()
																																																						func396(humanoid)
																																																					end))

																																																					func396(humanoid)
																																																				end
																																																			end
																																																		end

																																																		do
																																																			local connection6 = localPlayer.CharacterAdded:Connect(function(character)
																																																				if flag410 then
																																																					task.defer(func395, character)
																																																				end
																																																			end)

																																																			local obj57 = num5.OnHumanoidChanged(function()
																																																				if flag410 and localPlayer.Character then
																																																					func395(localPlayer.Character)
																																																				end
																																																			end)

																																																			func10(function()
																																																				flag410 = false
																																																				connection6:Disconnect()
																																																				obj57:Disconnect()
																																																				func394()
																																																			end)
																																																		end

																																																		flag410 = true

																																																		if localPlayer.Character then
																																																			task.spawn(func395, localPlayer.Character)
																																																		end
																																																	end

																																																	do
																																																		local value299, flag411, tbl190, tbl191, func397

																																																		do
																																																			value299 = nil
																																																			flag411 = true
																																																			tbl190 = {}
																																																			tbl191 = {}

																																																			do
																																																				local function func398(instance16)
																																																					if instance16:IsA("BasePart") and tbl190[instance16] == nil then
																																																						tbl190[instance16] = instance16.CanTouch

																																																						pcall(function()
																																																							instance16.CanTouch = false
																																																						end)
																																																					end
																																																				end

																																																				func397 = function(instance17)
																																																					if not flag411 or not instance17.Parent then
																																																						return
																																																					end
																																																					local name = localPlayer.Name
																																																					if instance17:GetAttribute("Owner") == name then
																																																						return
																																																					end
																																																					func398(instance17)

																																																					for _, descendant in ipairs(instance17:GetDescendants()) do
																																																						func398(descendant)
																																																					end

																																																					table.insert(tbl191, instance17.DescendantAdded:Connect(function(descendant)
																																																						if flag411 then
																																																							func398(descendant)
																																																						end
																																																					end))
																																																				end
																																																			end
																																																		end

																																																		do
																																																			local function func399()
																																																				for _, item92 in ipairs(CollectionService:GetTagged("PlacedTrap")) do
																																																					func397(item92)
																																																				end
																																																			end

																																																			local function func400()
																																																				for k, value300 in pairs(tbl190) do
																																																					if k.Parent then
																																																						pcall(function()
																																																							k.CanTouch = value300
																																																						end)
																																																					end
																																																				end

																																																				table.clear(tbl190)
																																																			end

																																																			table.insert(tbl191, CollectionService:GetInstanceAddedSignal("PlacedTrap"):Connect(function(param201)
																																																				task.defer(func397, param201)
																																																			end))

																																																			value299 = obj45:CreateToggle({
																																																				Name = "Anti Trap",
																																																				Note = "Traps from other players cannot catch you",
																																																				Default = true,
																																																				Callback = function()
																																																					flag411 = num5.Toggle(value299, true) == true

																																																					if flag411 then
																																																						func399()
																																																					else
																																																						func400()
																																																					end
																																																				end,
																																																			})

																																																			func399()

																																																			func10(function()
																																																				flag411 = false

																																																				for _, item93 in ipairs(tbl191) do
																																																					pcall(function()
																																																						item93:Disconnect()
																																																					end)
																																																				end

																																																				table.clear(tbl191)
																																																				func400()
																																																			end)
																																																		end
																																																	end
																																																end

																																																local value301, tbl192, connection6, connection7, func401

																																																do
																																																	value301 = nil

																																																	do
																																																		local str32 = "CarryAreaEgg"

																																																		local byName2 = {
																																																			ClaimLostPart = true,
																																																		}

																																																		tbl192 = {}
																																																		connection6 = nil
																																																		connection7 = nil

																																																		func401 = function(instance18)
																																																			if not instance18:IsA("ProximityPrompt") or byName2[instance18.Name] then
																																																				return
																																																			end

																																																			if tbl192[instance18] == nil then
																																																				if instance18.HoldDuration <= 0 and instance18.Name ~= str32 then
																																																					return
																																																				end
																																																				tbl192[instance18] = instance18.HoldDuration
																																																			end

																																																			if instance18.HoldDuration ~= 0 then
																																																				pcall(function()
																																																					instance18.HoldDuration = 0
																																																				end)
																																																			end
																																																		end
																																																	end
																																																end

																																																do
																																																	local function func402(instance19)
																																																		if instance19.Name ~= "SmartPromptPart" then
																																																			return nil
																																																		end
																																																		local carryAreaEgg = instance19:FindFirstChild("CarryAreaEgg")
																																																		return carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and carryAreaEgg or nil
																																																	end

																																																	num5.PromptHold = function(obj)
																																																		local entry16 = tbl192[obj]
																																																		if type(entry16) == "number" then
																																																			return entry16
																																																		end
																																																		return obj.HoldDuration
																																																	end

																																																	local function func403()
																																																		if connection6 then
																																																			return
																																																		end

																																																		connection7 = ProximityPromptService.PromptShown:Connect(function(param202)
																																																			if num5.Toggle(value301, true) then
																																																				func401(param202)
																																																			end
																																																		end)

																																																		for _, child in ipairs(workspace:GetChildren()) do
																																																			local value302 = func402(child)

																																																			if value302 then
																																																				func401(value302)
																																																			end
																																																		end

																																																		connection6 = workspace.ChildAdded:Connect(function(child)
																																																			if child.Name ~= "SmartPromptPart" then
																																																				return
																																																			end

																																																			task.defer(function()
																																																				local carryAreaEgg = child:FindFirstChild("CarryAreaEgg") or child:WaitForChild("CarryAreaEgg", 2)

																																																				if carryAreaEgg and carryAreaEgg:IsA("ProximityPrompt") and num5.Toggle(value301, true) then
																																																					func401(carryAreaEgg)
																																																				end
																																																			end)
																																																		end)
																																																	end

																																																	local function func404()
																																																		for k, value303 in pairs(tbl192) do
																																																			if k and k.Parent then
																																																				pcall(function()
																																																					k.HoldDuration = value303
																																																				end)
																																																			end
																																																		end

																																																		table.clear(tbl192)

																																																		if connection6 then
																																																			connection6:Disconnect()
																																																			connection6 = nil
																																																		end

																																																		if connection7 then
																																																			connection7:Disconnect()
																																																			connection7 = nil
																																																		end
																																																	end

																																																	num5.PressStealPrompt = function(num94)
																																																		if typeof(fireproximityprompt) ~= "function" or not num94 then
																																																			return false
																																																		end
																																																		local value304 = nil
																																																		local huge2 = math.huge

																																																		for _, child in ipairs(workspace:GetChildren()) do
																																																			local flag412 = func402(child)

																																																			if flag412 and child:IsA("BasePart") then
																																																				local magnitude = (child.Position - num94).Magnitude

																																																				if magnitude < huge2 then
																																																					value304 = flag412
																																																					huge2 = magnitude
																																																				end
																																																			end
																																																		end

																																																		if not value304 or huge2 > 14 then
																																																			return false
																																																		end

																																																		if num5.Toggle(value301, true) then
																																																			pcall(function()
																																																				value304.HoldDuration = 0
																																																			end)
																																																		end

																																																		local ok = pcall(fireproximityprompt, value304)

																																																		if ok and value304.HoldDuration > 0 then
																																																			task.wait(value304.HoldDuration + 0.1)
																																																		end

																																																		return ok
																																																	end

																																																	tbl8.Add(function()
																																																		if num5.Toggle(value301, true) then
																																																			func403()

																																																			for k in pairs(tbl192) do
																																																				if not k.Parent then
																																																					tbl192[k] = nil
																																																				elseif k.HoldDuration ~= 0 then
																																																					pcall(function()
																																																						k.HoldDuration = 0
																																																					end)
																																																				end
																																																			end
																																																		elseif next(tbl192) ~= nil or connection6 then
																																																			func404()
																																																		end

																																																		return false
																																																	end)

																																																	value301 = obj45:CreateToggle({
																																																		Name = "Instant Prompts",
																																																		Default = true,
																																																		Callback = function()
																																																			tbl8.Wake()
																																																		end,
																																																	})

																																																	func10(func404)
																																																end

																																																num5.Combat = {}
																																																error("SL: this block could not be recovered")
																																															end

																																															error("SL: this block could not be recovered")
																																														end
																																													end

																																													error("SL: this block could not be recovered")
																																												end

																																												error("SL: this block could not be recovered")
																																											end
																																										end

																																										error("SL: this block could not be recovered")
																																									end
																																								end

																																								error("SL: this block could not be recovered")
																																							end
																																						end

																																						error("SL: this block could not be recovered")
																																					end
																																				end

																																				error("SL: this block could not be recovered")
																																			end

																																			error("SL: this block could not be recovered")
																																		end
																																	end

																																	error("SL: this block could not be recovered")
																																end
																															end

																															error("SL: this block could not be recovered")
																														end
																													end

																													error("SL: this block could not be recovered")
																												end

																												error("SL: this block could not be recovered")
																											end
																										end

																										error("SL: this block could not be recovered")
																									end
																								end

																								error("SL: this block could not be recovered")
																							end

																							error("SL: this block could not be recovered")
																						end
																					end

																					error("SL: this block could not be recovered")
																				end
																			end

																			error("SL: this block could not be recovered")
																		end
																	end

																	error("SL: this block could not be recovered")
																end
															end

															error("SL: this block could not be recovered")
														end
													end

													error("SL: this block could not be recovered")
												end

												error("SL: this block could not be recovered")
											end

											error("SL: this block could not be recovered")
										end

										error("SL: this block could not be recovered")
									end

									error("SL: this block could not be recovered")
								end

								error("SL: this block could not be recovered")
							end

							error("SL: this block could not be recovered")
						end

						error("SL: this block could not be recovered")
					end

					error("SL: this block could not be recovered")
				end

				error("SL: this block could not be recovered")
			end

			error("SL: this block could not be recovered")
		end

		error("SL: this block could not be recovered")
	end

	error("SL: this block could not be recovered")
end

error("SL: this block could not be recovered")

-- more leaks: https://discord.gg/x7YbZeezpm