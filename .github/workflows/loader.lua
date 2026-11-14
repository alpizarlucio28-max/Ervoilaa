--[[
ervoila hub loader
discord.gg/ervoila

dont reupload this
]]

local GLOBAL_KEYLESS_MODE = false -- set true to turn off the key system

-- xor
local function _e(str, key)
local res = {}
for i = 1, #str do
local char = string.byte(str, i)
local keyChar = string.byte(key, (i - 1) % #key + 1)
res[i] = string.char(bit32.bxor(char, keyChar))
end
return table.concat(res)
end
local _k = "ervoila_secure_key_2024"

-- endpoints
local twMain    = "https://luaprot.net/api/v3/loaders/get/98708973876200258257"
local twTruck   = "https://luaprot.net/api/v3/loaders/get/20666563422235563630"
local twProbe   = "https://luaprot.net/api/v3/loaders/get/82147944153403029808"
local heMain    = "https://luaprot.net/api/v3/loaders/get/69894509937470821569"
local heProbe   = "https://luaprot.net/api/v3/loaders/get/38094715006260034759"
local txMain    = "https://luaprot.net/api/v3/loaders/get/49059268727434618091"
local moonMain  = "https://luaprot.net/api/v3/loaders/get/49344018525772747851"
local stcMain   = "https://luaprot.net/api/v3/loaders/get/93276521945463462103"
local rvMain    = "https://luaprot.net/api/v3/loaders/get/14726428719250395680"
local rcMain    = "https://luaprot.net/api/v3/loaders/get/58612659438017459476"

local _enc_discord_code = _e("ervoila", _k)
local _enc_banner_url = _e("https://media.discordapp.net/attachments/1494760735337615491/1504899466606673960/ERVOILA_1.png?ex=6a08aa58&is=6a0758d8&hm=41e2efbdaf6124ffb072a1e0c467494f8c1dde6f0f11ad2cb53eb2c1514a703c&=&format=webp&quality=lossless&width=1872&height=250", _k)

-- env check
local function _check_env()
local _bad_globals = {"getgenv", "getrenv", "getreg", "getgc", "getinstances", "getnilinstances", "getloadedmodules", "getconnections", "firesignal", "fireclickdetector", "firetouchinterest", "isrbxactive", "mouse1click", "mouse2click", "mousemoverel", "mousescroll", "mouse1press", "mouse1release", "mouse2press", "mouse2release", "keypress", "keyrelease", "iswindowactive", "isgameactive", "readfile", "writefile", "appendfile", "loadfile", "listfiles", "isfile", "isfolder", "makefolder", "delfile", "delfolder", "dofile", "loadstring", "getcustomasset"}
for _, _g in ipairs(_bad_globals) do
if getfenv()[_g] or _G[_g] then
-- Found a suspicious global
end
end
if not pcall(function() end) then
return false
end
return true
end

if not _check_env() then
error("An unexpected error occurred.")
return
end

local _s, _e_msg = pcall(function()
local plrs = game:GetService("Players")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local lp = plrs.LocalPlayer

-- auto join discord
pcall(function()
    local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if req then
        req({
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = {
                ['Content-Type'] = 'application/json',
                Origin = 'https://discord.com'
            },
            Body = game:GetService('HttpService'):JSONEncode({
                cmd = 'INVITE_BROWSER',
                nonce = game:GetService('HttpService'):GenerateGUID(false),
                args = {code = _e(_enc_discord_code, _k)}
            })
        })
    end
end)

local games = {
    [14170731342] = {
        name = "Twisted",
        scripts = {
            {name = "Main Hub", url = twMain},
            {name = "Trucker Autofarm", url = twTruck},
            {name = "Probe Autofarm", url = twProbe, adkey = true}
        }
    },
    [17759606919] = {
        name = "Helicity",
        scripts = {
            {name = "Main Hub", url = heMain},
            {name = "Autofarm Probe", url = heProbe, adkey = true}
        }
    },
    [137775739066479] = {name = "TwisterX", scripts = {{name = "Main Hub", url = txMain}}},
    [75356998324697] = {name = "Ship The Cargo", scripts = {{name = "Main Hub", url = stcMain}}},
    [17625359962] = {name = "RIVALS", keyless = true, scripts = {{name = "Rivals", url = rvMain}}},
    [5829141886] = {name = "Realistic Car Driving", keyless = true, scripts = {{name = "Main Hub", url = rcMain}}}
}

-- moon, matched by universe so it works in the lobby and the game
local MOON_GAME_ID = 10770466814
-- Place IDs that must resolve to the Moon entry. The universe check below is a
-- safety net, not a substitute: it needs game.GameId to be readable and it is
-- simply nicer to have the exact IDs listed. 88549191352404 is the Moon place
-- itself; the two older IDs cover the lobby and the previous Moon build.
local MOON_PLACES = {
    [88549191352404] = true,
    [77902310012360] = true,
    [1794065552826] = true,
}

local moonEntry = {
    name = "Moon",
    scripts = {
        {name = "Sweep The Moon", url = moonMain}
    }
}

for placeId in pairs(MOON_PLACES) do
    games[placeId] = moonEntry
end

local current = games[game.PlaceId]

-- anything else in the moon universe
if not current and game.GameId == MOON_GAME_ID then
    current = moonEntry
end

if not current then
    -- nothing mapped here
    current = {
        name = "Universal",
        scripts = {}
    }
end

local isMoon = (current == moonEntry) or MOON_PLACES[game.PlaceId] == true

-- true when this game runs without a key (RIVALS, or the global switch)
local game_keyless = GLOBAL_KEYLESS_MODE or current.keyless == true

-- show the key box only if something here is actually keyed
local ui_needs_key = false
if not game_keyless then
    for _, s in pairs(current.scripts) do
        if not s.keyless then
            ui_needs_key = true
            break
        end
    end
end

-- grab banner
local banner_img = ""
local link = _e(_enc_banner_url, _k)

pcall(function()
    if not isfile("ervoila_banner.png") then
        writefile("ervoila_banner.png", game:HttpGet(link))
    end
    local getasset = getcustomasset or getsynasset
    if getasset then banner_img = getasset("ervoila_banner.png") end
end)


-- colours
local BG     = Color3.fromRGB(12, 12, 16)
local PANEL  = Color3.fromRGB(21, 21, 28)
local PANEL2 = Color3.fromRGB(28, 28, 37)
local LINE   = Color3.fromRGB(42, 42, 54)
local ACCENT = Color3.fromRGB(99, 112, 245)
local TEXT   = Color3.fromRGB(240, 241, 247)
local SUB    = Color3.fromRGB(148, 150, 168)
local MUTED  = Color3.fromRGB(102, 104, 122)
local OK     = Color3.fromRGB(72, 214, 130)
local BAD    = Color3.fromRGB(246, 96, 96)
local ADKEY  = Color3.fromRGB(196, 150, 60)

local function mk(class, props, parent)
    local o = Instance.new(class)
    for k, v in next, props do
        o[k] = v
    end
    if parent then
        o.Parent = parent
    end
    return o
end

local function round(o, r)
    return mk("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end

local function outline(o, colour)
    return mk("UIStroke", {
        Color = colour or LINE,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

-- window
local gui = Instance.new("ScreenGui")
gui.Name = "ervoila_" .. tostring(math.random(1000, 9999))
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 80
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local s_parent = pcall(function() gui.Parent = cg end)
if not s_parent then gui.Parent = lp:WaitForChild("PlayerGui") end

-- clamp the width on phones
local function viewportSize()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize) or Vector2.new(1280, 720)
end

local function windowWidth()
    local vp = viewportSize()
    return math.clamp(vp.X - 36, 280, 400)
end

local W = windowWidth()

local bg = mk("Frame", {
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(W, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
}, gui)
round(bg, 14)
outline(bg, LINE)

-- refit on rotate
pcall(function()
    local cam = workspace.CurrentCamera
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            pcall(function()
                bg.Size = UDim2.fromOffset(windowWidth(), 0)
            end)
        end)
    end
end)

mk("UIPadding", {
    PaddingTop = UDim.new(0, 16),
    PaddingBottom = UDim.new(0, 14),
    PaddingLeft = UDim.new(0, 16),
    PaddingRight = UDim.new(0, 16),
}, bg)
mk("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 9),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, bg)

local order = 1
local function nextOrder()
    order = order + 1
    return order
end


-- header
if banner_img ~= "" then
    local banner = mk("ImageLabel", {
        LayoutOrder = nextOrder(),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 66),
        Image = banner_img,
        ScaleType = Enum.ScaleType.Fit,
    }, bg)
    round(banner, 10)
else
    local mark = mk("Frame", {
        LayoutOrder = nextOrder(),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
    }, bg)
    round(mark, 10)
    outline(mark, LINE)

    local bar = mk("Frame", {
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(4, 22),
        Position = UDim2.fromOffset(16, 19),
    }, mark)
    round(bar, 2)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 11),
        Size = UDim2.new(1, -46, 0, 22),
        Font = Enum.Font.GothamBlack,
        Text = "ERVOILA HUB",
        TextColor3 = TEXT,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, mark)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(30, 33),
        Size = UDim2.new(1, -46, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = "discord.gg/ervoila",
        TextColor3 = ACCENT,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, mark)
end

-- close
local x_btn = mk("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -8, 0, 8),
    Size = UDim2.fromOffset(24, 24),
    BackgroundColor3 = Color3.fromRGB(20, 20, 26),
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = SUB,
    TextSize = 11,
    ZIndex = 5,
}, bg)
round(x_btn, 12)
outline(x_btn, LINE)
x_btn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- title
local titleRow = mk("Frame", {
    LayoutOrder = nextOrder(),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 38),
}, bg)

mk("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "Ervoila Hub",
    TextColor3 = TEXT,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleRow)

mk("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(0, 20),
    Size = UDim2.new(1, 0, 0, 15),
    Font = Enum.Font.GothamMedium,
    Text = "DETECTED: " .. current.name:upper(),
    TextColor3 = MUTED,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleRow)


-- key box
local box = nil

if ui_needs_key then
    mk("TextLabel", {
        LayoutOrder = nextOrder(),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = "YOUR KEY",
        TextColor3 = SUB,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, bg)

    box = mk("TextBox", {
        LayoutOrder = nextOrder(),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamMedium,
        PlaceholderText = "paste your LuaProt key here",
        PlaceholderColor3 = MUTED,
        Text = "",
        TextColor3 = TEXT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, bg)
    round(box, 9)
    local boxStroke = outline(box, LINE)
    mk("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }, box)

    box.Focused:Connect(function()
        ts:Create(boxStroke, TweenInfo.new(0.15), { Color = ACCENT }):Play()
        ts:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = PANEL2 }):Play()
    end)
    box.FocusLost:Connect(function()
        ts:Create(boxStroke, TweenInfo.new(0.15), { Color = LINE }):Play()
        ts:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = PANEL }):Play()
    end)

    -- discord
    local drow = mk("Frame", {
        LayoutOrder = nextOrder(),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
    }, bg)
    round(drow, 9)
    outline(drow, LINE)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 8),
        Size = UDim2.new(1, -110, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = "Key is in the Discord",
        TextColor3 = TEXT,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, drow)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 24),
        Size = UDim2.new(1, -110, 0, 22),
        Font = Enum.Font.GothamMedium,
        Text = "discord.gg/ervoila\n" .. (game_keyless
            and "No key needed. Join for updates and support."
            or (isMoon
                and "No ads. Join and grab your key."
                or "Join to get your key.")),
        TextColor3 = MUTED,
        TextSize = 10,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, drow)

    local get_key = mk("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(90, 30),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "COPY INVITE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
    }, drow)
    round(get_key, 8)

    get_key.MouseEnter:Connect(function()
        ts:Create(get_key, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(76, 88, 210) }):Play()
    end)
    get_key.MouseLeave:Connect(function()
        ts:Create(get_key, TweenInfo.new(0.12), { BackgroundColor3 = ACCENT }):Play()
    end)

    get_key.MouseButton1Click:Connect(function()
        local clip = setclipboard or toclipboard
        local copied = false
        if clip then copied = pcall(clip, "https://discord.gg/ervoila") end
        if copied then
            get_key.Text = "COPIED"
            task.wait(1.5)
            if get_key.Parent then get_key.Text = "COPY INVITE" end
        end
    end)
end


-- status line
local status = mk("TextLabel", {
    LayoutOrder = nextOrder(),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 15),
    Font = Enum.Font.GothamMedium,
    Text = ui_needs_key and "Paste your key, then press LOAD" or "Ready",
    TextColor3 = MUTED,
    TextSize = 11,
}, bg)

local function say(msg, colour, reset)
    status.Text = msg
    status.TextColor3 = colour or MUTED
    if reset then
        local mine = msg
        task.delay(reset, function()
            if status and status.Text == mine then
                status.Text = "Ready"
                status.TextColor3 = MUTED
            end
        end)
    end
end

-- script rows
for i, v in pairs(current.scripts) do
    -- load row
    local row = mk("TextButton", {
        LayoutOrder = nextOrder(),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 46),
        Text = "",
    }, bg)
    round(row, 9)
    local rowStroke = outline(row, LINE)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 6),
        Size = UDim2.new(1, -100, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = v.name,
        TextColor3 = TEXT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    -- what it takes to load this one
    local row_sub, row_sub_col
    if v.keyless or game_keyless then
        row_sub, row_sub_col = "Keyless - no key needed", OK
    elseif v.adkey then
        row_sub, row_sub_col = "Free - unlock with an ad key", ADKEY
    elseif v.name == "Sweep The Moon" then
        row_sub, row_sub_col = "Free - key from the Discord", MUTED
    else
        row_sub, row_sub_col = "Key required", MUTED
    end

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 24),
        Size = UDim2.new(1, -100, 0, 15),
        Font = Enum.Font.GothamMedium,
        Text = row_sub,
        TextColor3 = row_sub_col,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local chip = mk("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(70, 28),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    }, row)
    round(chip, 7)

    local chipText = mk("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBold,
        Text = "LOAD",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
    }, chip)

    row.MouseEnter:Connect(function()
        ts:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = PANEL2 }):Play()
        ts:Create(rowStroke, TweenInfo.new(0.12), { Color = ACCENT }):Play()
    end)
    row.MouseLeave:Connect(function()
        ts:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = PANEL }):Play()
        ts:Create(rowStroke, TweenInfo.new(0.12), { Color = LINE }):Play()
    end)

    row.MouseButton1Click:Connect(function()
        local k = box and box.Text or ""
        k = k:gsub("%s+", "") -- keys pasted from discord carry newlines

        chipText.Text = "..."
        chip.BackgroundColor3 = PANEL2
        say("Connecting...", SUB)

        -- LuaProt's loader stub reads the global lp_key and builds
        -- "<script url>?k=" .. (lp_key or "x"). Writing an EMPTY string
        -- here produces "?k=" which LuaProt rejects as "Missing
        -- parameters", so only hand over a key when there really is one.
        if not (GLOBAL_KEYLESS_MODE or v.keyless or game_keyless) and #k > 0 then
            if type(getgenv) == "function" then getgenv().lp_key = k end
            _G.lp_key = k
            if type(getfenv) == "function" then
                pcall(function() getfenv(0).lp_key = k end)
            end
        end

        gui.Enabled = false

        local ok2, err = pcall(function()
            loadstring(game:HttpGet(v.url))()
        end)

        if not ok2 then
            pcall(function() gui.Enabled = true end)
            pcall(function()
                chipText.Text = "FAILED"
                chip.BackgroundColor3 = BAD
            end)
            say("Loader stopped - see the console", BAD, 10)
            warn("[Ervoila] " .. tostring(err))
        end
    end)
end

if #current.scripts == 0 then
    mk("TextLabel", {
        LayoutOrder = nextOrder(),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamMedium,
        Text = "No script for this game yet.",
        TextColor3 = MUTED,
        TextSize = 11,
        TextWrapped = true,
    }, bg)
end

-- footer
mk("Frame", {
    LayoutOrder = nextOrder(),
    BackgroundColor3 = LINE,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 1),
}, bg)

mk("TextLabel", {
    LayoutOrder = nextOrder(),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 15),
    Font = Enum.Font.GothamMedium,
    Text = "discord.gg/ervoila",
    TextColor3 = MUTED,
    TextSize = 10,
}, bg)

-- drag
local dragging, dragStart, startPos

bg.InputBegan:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = bg.Position
    end
end)

uis.InputChanged:Connect(function(input)
    if not dragging then return end
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        bg.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

uis.InputEnded:Connect(function(input)
    local t = input.UserInputType
    if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        dragging = false
    end
end)

end)

if not _s then
-- warn("[LOADER ERROR] " .. tostring(_e_msg))
end
