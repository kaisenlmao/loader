

local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local GuiService: GuiService = cloneref(game:GetService("GuiService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        local Ready, Failure = pcall(RecursiveCreatePath, AssetData.Path, true)
        if not Ready then return false, tostring(Failure) end

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        pcall(CustomImageManager.DownloadAsset, AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    DevicePlatform = nil,
    IsMobile = false,
    IsRobloxFocused = true,

    ScreenGui = nil,

    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,
    FuzzySearch = true,
    SearchValues = true,
    ActiveExpandedDropdown = nil,

    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},
    DependencyBoxes = {},

    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    Notifications = {},
    NotificationHistory = {},
    NotificationUnread = 0,
    NotificationBellEnabled = true,
    Dialogues = {},
    ActiveDialog = nil,

    Corners = {},

    ToggleKeybind = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    Toggled = false,
    Unloaded = false,

    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    NotifySide = "Right",
    ForceCheckbox = true,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,

    CantDragForced = false,

    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 0,
    OptionChangedCallbacks = {},

    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(23, 25, 29),
        NavigationColor = Color3.fromRGB(28, 30, 34),
        HeaderColor = Color3.fromRGB(44, 48, 54),
        FieldColor = Color3.fromRGB(18, 20, 24),
        MutedColor = Color3.fromRGB(184, 190, 200),
        MainColor = Color3.fromRGB(34, 37, 42),
        AccentColor = Color3.fromRGB(255, 66, 117),
        OutlineColor = Color3.fromRGB(72, 77, 87),
        FontColor = Color3.fromRGB(240, 241, 244),
        Font = Font.fromEnum(Enum.Font.BuilderSans),
        FontBold = Font.fromEnum(Enum.Font.BuilderSansBold),
        FontMono = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 119, 131),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),
    },

    Registry = {},
    Scales = {},

    ImageManager = CustomImageManager,
}

-- Presentation assignment compatibility is event-driven. Feature registries are untouched.
do
    local Values = Library.Scheme
    local Protected = {}
    for Key in Values do Protected[Key] = true end
    Library.LegacyAppearanceAssignments = {}
    Library.Scheme = setmetatable({}, {
        __index = Values,
        __newindex = function(_, Key, Value)
            if Protected[Key] and not Library._SchemeWriting then
                Library.LegacyAppearanceAssignments[Key] = Value
                return
            end
            Values[Key] = Value
        end,
        __iter = function() return next, Values, nil end,
    })
    local Scheme = Library.Scheme
    rawset(Library, "Scheme", nil)
    setmetatable(Library, {
        __index = function(_, Key) if Key == "Scheme" then return Scheme end end,
        __newindex = function(Self, Key, Value)
            if Key == "Scheme" then
                if typeof(Value) == "table" then
                    for Name, Color in Value do Scheme[Name] = Color end
                end
            else rawset(Self, Key, Value) end
        end,
    })
    function Library:GetScheme()
        return table.clone(Values)
    end
end

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)
    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\-
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        TextSize = 14,
        TextScaled = false,
        TextStrokeTransparency = 1,
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        TextSize = 14,
        TextScaled = false,
        TextStrokeTransparency = 1,
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        TextSize = 14,
        TextScaled = false,
        TextStrokeTransparency = 1,
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "Chiyo",
        Footer = "",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(1080, 700),
        IconSize = UDim2.fromOffset(30, 30),
        AutoShow = true,
        Center = true,
        Resizable = true,
        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,
        FuzzySearch = true,
        SearchValues = true,
        CornerRadius = 0,
        NotifySide = "Right",
        Font = Enum.Font.BuilderSans,
        ShowOverview = false,
        HideIdentity = false,
        SidebarWidth = 212,
        ToggleKeybind = Enum.KeyCode.RightControl,
        MobileButtonsSide = "Left",
        UnlockMouseWhileOpen = true,
        DisableNotificationBell = false,
        ShowToggleButton = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 180,
        SidebarCompactWidth = 64,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        AutoDestroy = false,
        OutsideClickDismiss = true,
        FooterButtons = {},
        OnShow = nil,
        OnDismiss = nil,
        OnDestroy = nil,
        Width = nil,
        MaxHeight = nil,
        StartHidden = false,
    },
    List = {
        Text = nil,
        Items = {},
        Multi = false,
        MaxHeight = 150,
        EmptyText = "No items",
        Callback = function() end,
        Changed = function() end,
        Disabled = false,
        Visible = true,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        Multi = false,
        MaxVisibleDropdownItems = 8,
        Searchable = true,
        SelectAllButtons = true,
        Expandable = true,
        ExpandColumns = 2,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Finished = false
    local Connection
    local function Complete(Value)
        if Finished then return end
        Finished = true
        if Connection then Connection:Disconnect() end
        Bindable:Fire(Value)
    end
    Connection = Event:Connect(function(...)
        if not Condition or Condition(...) then Complete(true) end
    end)
    local Timer = task.delay(Timeout, function() Complete(false) end)
    local Result = Bindable.Event:Wait()
    pcall(task.cancel, Timer)
    Bindable:Destroy()
    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end
local function StopTween(Tween: TweenBase)
    if not (Tween and Tween.PlaybackState == Enum.PlaybackState.Playing) then
        return
    end

    Tween:Cancel()
end
local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

local function SearchScore(Text: any, Search: string): number
    if typeof(Text) ~= "string" then return 0 end
    local Lower = Text:lower()
    Search = tostring(Search or ""):lower()
    if Search == "" then return 1 end
    if Lower == Search then return 400 end
    if Lower:sub(1, #Search) == Search then return 300 end
    local At = Lower:find(Search, 1, true)
    if At then return 200 - math.min(At, 99) end
    if Library.FuzzySearch == false then return 0 end
    local Index = 1
    for Cursor = 1, #Lower do
        if Lower:sub(Cursor, Cursor) == Search:sub(Index, Index) then
            Index += 1
            if Index > #Search then return 1 end
        end
    end
    return 0
end

local function MatchesSearchText(Text: any, Search: string): boolean
    return SearchScore(Text, Search) > 0
end

local function SearchName(Object, Key, Search)
    local Name = Object and Object.Name
    if typeof(Name) ~= "string" then
        Name = typeof(Key) == "string" and Key or ""
    end
    return Name, SearchScore(Name, Search)
end

local function SearchElement(Element, Search)
    local BestScore = SearchScore(Element.Text, Search)
    if Library.SearchValues ~= false then
        for _, Value in Element.Values or {} do
            local Formatted = Element.FormatListValue and Library:SafeCallback(Element.FormatListValue, Value, Element.ValueLabels and Element.ValueLabels[Value]) or (Element.ValueLabels and Element.ValueLabels[Value]) or Value
            BestScore = math.max(BestScore, SearchScore(tostring(Formatted), Search))
        end
    end
    return BestScore
end

local function SetElementSearchVisibility(Element, Search, Revealed, RevealScore)
    if Element.Type == "Divider" then
        Element.Holder.Visible = false
        return 0, 0
    end

    local Score = SearchElement(Element, Search)
    local MainVisible = Element.Visible ~= false and (Revealed or Score > 0)
    if not Element.SubButton then
        Element.Holder.Visible = MainVisible
        return MainVisible and 1 or 0, MainVisible and math.max(Score, RevealScore) or 0
    end

    local SubScore = SearchElement(Element.SubButton, Search)
    local SubVisible = Element.SubButton.Visible ~= false and (Revealed or SubScore > 0)
    Element.Base.Visible = MainVisible
    Element.SubButton.Base.Visible = SubVisible
    Element.Holder.Visible = MainVisible or SubVisible

    if not Element.Holder.Visible then
        return 0, 0
    end
    return 1, math.max(MainVisible and math.max(Score, RevealScore) or 0, SubVisible and math.max(SubScore, RevealScore) or 0)
end

local FilterContents
local FilterTabbox

FilterContents = function(Box, Search, Revealed, RevealScore)
    local VisibleElements = 0
    local BestScore = 0

    for _, Element in Box.Elements or {} do
        local Visible, Score = SetElementSearchVisibility(Element, Search, Revealed, RevealScore)
        VisibleElements += Visible
        BestScore = math.max(BestScore, Score)
    end

    for _, Depbox in Box.DependencyBoxes or {} do
        if Depbox.Visible then
            local Visible, Score = FilterContents(Depbox, Search, Revealed, RevealScore)
            Depbox.Holder.Visible = Visible > 0
            if Visible > 0 then
                Depbox:Resize()
            end
            VisibleElements += Visible
            BestScore = math.max(BestScore, Score)
        end
    end

    for Key, InnerTabbox in Box.InnerTabboxes or {} do
        local Visible, Score = FilterTabbox(InnerTabbox, Key, Search, Revealed, RevealScore)
        VisibleElements += Visible
        BestScore = math.max(BestScore, Score)
    end

    return VisibleElements, BestScore
end

local function IsBetterSearchCandidate(Candidate, CandidateName, CandidateScore, Best, BestName, BestScore, Active)
    if not Best or CandidateScore ~= BestScore then
        return CandidateScore > BestScore
    end
    if Candidate == Active then
        return true
    end
    if Best == Active then
        return false
    end
    return CandidateName:lower() < BestName:lower()
end

FilterTabbox = function(Tabbox, Key, Search, Revealed, RevealScore)
    local _, TabboxScore = SearchName(Tabbox, Key, Search)
    local TabboxMatches = Revealed or TabboxScore > 0
    local TabboxRevealScore = math.max(RevealScore, TabboxScore)
    local VisibleTabs = 0
    local BestScore = 0
    local BestTab
    local BestTabName = ""
    local VisibleByTab = {}

    local Children = {}
    for Key, SubTab in Tabbox.Tabs or {} do
        local Name = SearchName(SubTab, Key, Search)
        table.insert(Children, { Key = Key, Tab = SubTab, Name = Name })
    end
    table.sort(Children, function(Left, Right)
        if Left.Name:lower() == Right.Name:lower() then
            return tostring(Left.Key) < tostring(Right.Key)
        end
        return Left.Name:lower() < Right.Name:lower()
    end)

    for _, Entry in Children do
        local SubTab = Entry.Tab
        local _, SubTabScore = SearchName(SubTab, Entry.Key, Search)
        local SubTabMatches = TabboxMatches or SubTabScore > 0
        local Visible, Score = FilterContents(SubTab, Search, SubTabMatches, math.max(TabboxRevealScore, SubTabScore))
        VisibleByTab[SubTab] = Visible

        SubTab.ButtonHolder.Visible = Visible > 0
        if Visible > 0 then
            VisibleTabs += 1
            Score = math.max(Score, TabboxScore, SubTabScore, RevealScore)
            if IsBetterSearchCandidate(SubTab, Entry.Name, Score, BestTab, BestTabName, BestScore, Tabbox.ActiveTab) then
                BestTab = SubTab
                BestTabName = Entry.Name
                BestScore = Score
            end
        end
    end

    local ActiveTab = Tabbox.ActiveTab
    if ActiveTab and (VisibleByTab[ActiveTab] or 0) == 0 then
        ActiveTab:Hide()
    end
    if BestTab then
        if BestTab == Tabbox.ActiveTab then
            BestTab:Resize()
        else
            BestTab:Show()
        end
    end

    Tabbox.BoxHolder.Visible = VisibleTabs > 0
    return VisibleTabs, VisibleTabs > 0 and BestScore or 0
end

local function FilterGroupbox(Groupbox, Key, Search, Revealed, RevealScore)
    if Groupbox.Visible == false then
        Groupbox.BoxHolder.Visible = false
        return 0, 0
    end

    local _, GroupboxScore = SearchName(Groupbox, Key, Search)
    local Visible, Score = FilterContents(Groupbox, Search, Revealed or GroupboxScore > 0, math.max(RevealScore, GroupboxScore))
    Groupbox.BoxHolder.Visible = Visible > 0
    if Visible > 0 then
        Groupbox:Resize()
        Score = math.max(Score, GroupboxScore, RevealScore)
    end
    return Visible, Score
end

local function ApplySearchToTab(Tab, Key, Search)
    if not Tab or Tab.Visible == false then
        return false, 0
    end

    local _, TabScore = SearchName(Tab, Key, Search)
    local TabMatches = TabScore > 0
    local VisibleElements = 0
    local BestScore = 0

    for Key, Groupbox in Tab.Groupboxes or {} do
        local Visible, Score = FilterGroupbox(Groupbox, Key, Search, TabMatches, TabScore)
        VisibleElements += Visible
        BestScore = math.max(BestScore, Score)
    end

    for TabboxKey, Tabbox in Tab.Tabboxes or {} do
        local Visible, Score = FilterTabbox(Tabbox, TabboxKey, Search, TabMatches, TabScore)
        VisibleElements += Visible
        BestScore = math.max(BestScore, Score)
    end

    for Key, DepGroupbox in Tab.DependencyGroupboxes or {} do
        if DepGroupbox.Visible then
            local _, GroupboxScore = SearchName(DepGroupbox, Key, Search)
            local Visible, Score = FilterContents(DepGroupbox, Search, TabMatches or GroupboxScore > 0, math.max(TabScore, GroupboxScore))
            DepGroupbox.Holder.Visible = Visible > 0
            if Visible > 0 then
                DepGroupbox:Resize()
                Score = math.max(Score, GroupboxScore, TabScore)
            end
            VisibleElements += Visible
            BestScore = math.max(BestScore, Score)
        end
    end

    return VisibleElements > 0, VisibleElements > 0 and math.max(BestScore, TabScore) or 0
end

local function ResetElement(Element)
    Element.Holder.Visible = Element.Visible ~= false
    if Element.SubButton then
        Element.Base.Visible = Element.Visible ~= false
        Element.SubButton.Base.Visible = Element.SubButton.Visible ~= false
    end
end

local ResetContents
local function ResetTabbox(Tabbox)
    for _, SubTab in Tabbox.Tabs or {} do
        ResetContents(SubTab)
        SubTab.ButtonHolder.Visible = true
    end
    Tabbox.BoxHolder.Visible = true
    if Tabbox.ActiveTab then
        Tabbox.ActiveTab:Resize()
    end
end

ResetContents = function(Box)
    for _, Element in Box.Elements or {} do
        ResetElement(Element)
    end
    for _, Depbox in Box.DependencyBoxes or {} do
        if Depbox.Visible then
            ResetContents(Depbox)
            Depbox.Holder.Visible = true
            Depbox:Resize()
        end
    end
    for _, InnerTabbox in Box.InnerTabboxes or {} do
        ResetTabbox(InnerTabbox)
    end
end

local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes or {} do
        if Groupbox.Visible ~= false then
            ResetContents(Groupbox)
            Groupbox.BoxHolder.Visible = true
            Groupbox:Resize()
        end
    end
    for _, Tabbox in Tab.Tabboxes or {} do
        ResetTabbox(Tabbox)
    end
    for _, DepGroupbox in Tab.DependencyGroupboxes or {} do
        if DepGroupbox.Visible then
            ResetContents(DepGroupbox)
            DepGroupbox.Holder.Visible = true
            DepGroupbox:Resize()
        end
    end
end

function Library:UpdateSearch(SearchText)
    SearchText = tostring(SearchText or "")
    Library.SearchText = SearchText

    local TabsToSearch = {}
    if Library.GlobalSearch then
        for Key, Tab in Library.Tabs do
            if typeof(Tab) == "table" and not Tab.IsKeyTab and Tab.Visible ~= false then
                table.insert(TabsToSearch, { Key = Key, Tab = Tab })
            end
        end
    elseif Library.ActiveTab and not Library.ActiveTab.IsKeyTab and Library.ActiveTab.Visible ~= false then
        table.insert(TabsToSearch, { Tab = Library.ActiveTab })
    end

    for _, Entry in TabsToSearch do
        ResetTab(Entry.Tab)
    end

    local Search = Trim(tostring(SearchText or "")):lower()
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch then
        Library.LastSearchTab = Library.ActiveTab
        Library.Searching = #TabsToSearch > 0
        if #TabsToSearch > 0 then
            ApplySearchToTab(TabsToSearch[1].Tab, TabsToSearch[1].Key, Search)
        end
        return
    end

    Library.Searching = true
    local BestTab
    local BestTabName = ""
    local BestScore = -1

    for _, Entry in TabsToSearch do
        local Tab = Entry.Tab
        local TabName = SearchName(Tab, Entry.Key, Search)
        local HasVisible, Score = ApplySearchToTab(Tab, Entry.Key, Search)
        if HasVisible and IsBetterSearchCandidate(Tab, TabName, Score, BestTab, BestTabName, BestScore, Library.ActiveTab) then
            BestTab = Tab
            BestTabName = TabName
            BestScore = Score
        end
    end

    if BestTab then
        local SearchMarker = SearchText
        task.defer(function()
            if Library.SearchText ~= SearchMarker then
                return
            end
            if Library.ActiveTab ~= BestTab then
                BestTab:Show()
            else
                BestTab:RefreshSides()
            end
        end)
    end

    Library.LastSearchTab = nil
end
function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
    for Object, Refresh in Library.VisualRefreshers or {} do
        if Object.Parent then Refresh() else Library.VisualRefreshers[Object] = nil end
    end
end

function Library:SetDPIScale(Percent)
    assert(typeof(Percent) == "number" and Percent == Percent and Percent >= 25 and Percent <= 300, "DPI scale must be between 25 and 300")
    Library.LegacyAppearanceAssignments.DPIScale = Percent
    if (Library.FeatureLoadDepth or 0) > 0 then return false end
    return Library:SetReadability(Percent <= 100 and "Standard" or Percent <= 125 and "Larger" or "Largest")
end

function Library:GiveSignal(Connection, Lifetime)
    if typeof(Connection) ~= "RBXScriptConnection" then return Connection end
    table.insert(Library.Signals, Connection)
    if Lifetime then
        Lifetime.Destroying:Once(function()
            Connection:Disconnect()
            local Index = table.find(Library.Signals, Connection)
            if Index then table.remove(Library.Signals, Index) end
        end)
    end
    return Connection
end

-- Internal state observation is separate from a script's replaceable OnChanged callback.
function Library:OnOptionChanged(Callback)
    assert(typeof(Callback) == "function", "Expected a callback")
    local Connection = { Connected = true }
    Library.OptionChangedCallbacks[Connection] = Callback
    function Connection:Disconnect()
        self.Connected = false
        Library.OptionChangedCallbacks[self] = nil
    end
    return Connection
end

function Library:NotifyOptionChanged(Element)
    if Library.Unloaded then return end
    for Connection, Callback in Library.OptionChangedCallbacks do
        if Connection.Connected then Library:SafeCallback(Callback, Element) end
    end
end

Library.FeatureValueChangedCallbacks = {}
Library.FeatureValueSnapshots = setmetatable({}, { __mode = "k" })
function Library:OnFeatureValueChanged(Callback)
    assert(typeof(Callback) == "function", "Expected a callback")
    local Connection = { Connected = true }
    Library.FeatureValueChangedCallbacks[Connection] = Callback
    function Connection:Disconnect() self.Connected = false; Library.FeatureValueChangedCallbacks[self] = nil end
    return Connection
end
function Library:ValueSnapshot(Element)
    return { Value = typeof(Element.Value) == "table" and table.clone(Element.Value) or Element.Value,
        Transparency = Element.Transparency, Mode = Element.Mode, Modifiers = Element.Modifiers and table.clone(Element.Modifiers) or nil }
end
function Library:ObserveOptionValue(Element)
    if Library.Unloaded or Element.Destroyed then return end
    local function Equal(A, B)
        if typeof(A) ~= "table" or typeof(B) ~= "table" then return A == B end
        for K, V in A do if not Equal(V, B[K]) then return false end end
        for K in B do if A[K] == nil then return false end end
        return true
    end
    local Next = Library:ValueSnapshot(Element)
    local Previous = Library.FeatureValueSnapshots[Element]
    Library.FeatureValueSnapshots[Element] = Next
    if not Equal(Previous, Next) then
        for Connection, Callback in Library.FeatureValueChangedCallbacks do
            if Connection.Connected then Library:SafeCallback(Callback, Element) end
        end
    end
    -- Keep the old observable-event contract, including the color picker's repeated explicit setters.
    if not Element.Disabled then Library:NotifyOptionChanged(Element) end
end

local function IsFinite(Value)
    return typeof(Value) == "number" and Value == Value and math.abs(Value) < math.huge
end

function Library:DestroyElement(Element, SkipHolder)
    if not Element or Element.Destroyed then return end
    Element.Destroyed = true
    Library.FeatureValueSnapshots[Element] = nil
    if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
    if Element.Groupbox then
        local Index = table.find(Element.Groupbox.Elements or {}, Element)
        if Index then table.remove(Element.Groupbox.Elements, Index) end
    end
    if Element.ParentObj then
        local Index = table.find(Element.ParentObj.Addons or {}, Element)
        if Index then table.remove(Element.ParentObj.Addons, Index) end
    end
    for _, Addon in table.clone(Element.Addons or {}) do Library:DestroyElement(Addon) end
    if Element.SubButton then Library:DestroyElement(Element.SubButton) end
    for _, Menu in { Element.Menu, Element.ColorMenu, Element.ContextMenu } do
        if Menu then if Menu.Destroy then Menu:Destroy() else Menu:Close(); if Menu.Menu then Menu.Menu:Destroy() end end end
    end
    if Element.Collapse then Element:Collapse() end
    if Element.TooltipTable then Element.TooltipTable:Destroy() end
    if Element.KeybindHolder then Element.KeybindHolder:Destroy() end
    if Element.KeybindToggle then
        local Index = table.find(Library.KeybindToggles, Element.KeybindToggle)
        if Index then table.remove(Library.KeybindToggles, Index) end
    end
    for _, Registry in { Options, Toggles, Labels, Buttons } do
        if Element.Idx ~= nil then
            if Registry[Element.Idx] == Element then Registry[Element.Idx] = nil end
        else
            for Key, Object in Registry do if Object == Element then Registry[Key] = nil end end
        end
    end
    if Element.Holder and not SkipHolder then Element.Holder:Destroy() end
end

function Library:TrackElement(Element, Owner)
    if Owner and Owner.Internal then Element.Internal = true end
    Element.Groupbox = Element.Groupbox or Owner
    if not Library.FeatureValueSnapshots[Element] then Library.FeatureValueSnapshots[Element] = Library:ValueSnapshot(Element) end
    if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
    if Element.Holder and not Element.Tracked then
        Element.Tracked = true
        Element.Holder.Destroying:Once(function() Library:DestroyElement(Element, true) end)
    end
    return Element
end

local function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string"
        and (Icon:match("rbxasset") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

-- Lucide asset catalogue, pinned to Footagesus/Icons revision
-- 58f2a4994f75d035472bdeb0ca276bd5bafc3282, lucide/dist/Icons.lua
-- Upstream blob d1888c0f4bf064c2c7e6a88bc0a4cd096a268287. No provider code is downloaded.
-- These references were checked against the pinned catalogue. Roblox delivery/permissions
-- remain platform-dependent; loaded-state fallbacks do not claim offline availability.
local BundledIcons = {
    ["check"] = 93898873302694, ["chevron-down"] = 134243273101015,
    ["chevron-left"] = 73780377692148, ["chevron-right"] = 92473583511724,
    ["chevron-up"] = 122444883127455, ["chevrons-down"] = 100524612205956,
    ["chevrons-up"] = 100467452364672, ["chevron-first"] = 105243363790238,
    ["chevron-last"] = 89268452603731, ["arrow-up"] = 89282378235317,
    ["arrow-down"] = 98764963621439, ["arrow-up-to-line"] = 108818207813537,
    ["arrow-down-to-line"] = 87050478931254, ["arrow-left-right"] = 131324733048447,
    ["arrow-up-down"] = 81019887641527, ["arrow-left"] = 102531941843733,
    ["arrow-right"] = 113692007244654, ["bell"] = 97392696311902,
    ["search"] = 121018724060431, ["sliders-horizontal"] = 85538382643347,
    ["sliders-vertical"] = 101190569086853, ["expand"] = 137492887754537,
    ["move-diagonal-2"] = 117298577948096, ["move-diagonal"] = 101433481954184,
    ["move"] = 116138709011735, ["minus"] = 118026365011536,
    ["menu"] = 77021539815611, ["columns-2"] = 113004100221850,
    ["circle-question-mark"] = 97516698664325, ["info"] = 124560466474914,
    ["circle-alert"] = 83898160590116, ["circle-check"] = 85262178816537,
    ["circle-x"] = 76821953846248, ["octagon-alert"] = 140438367956051,
    ["octagon-x"] = 90498161006311, ["folder"] = 80846616596607,
    ["folder-cog"] = 85299519462846, ["folder-open"] = 76018996254888,
    ["folder-plus"] = 91865663406119, ["file-text"] = 90496405707281,
    ["file-input"] = 124728604166044, ["file-output"] = 92146832572911,
    ["file-code"] = 130978036895504, ["key"] = 96510194465420,
    ["keyboard"] = 121474456068237, ["lock"] = 134724289526879,
    ["lock-open"] = 93597915325122, ["house"] = 98755624629571,
    ["layout-panel-left"] = 125092469751491, ["layout-list"] = 87462136296578,
    ["layout-grid"] = 81344910161871, ["layers"] = 81973586053257,
    ["component"] = 110027788875080, ["box"] = 101768155599700,
    ["boxes"] = 136372617578355, ["package"] = 97261141732706,
    ["package-open"] = 132890233237818, ["gem"] = 112904952151156,
    ["anvil"] = 100203029845919, ["anchor"] = 92181172123618,
    ["hammer"] = 83545120140895, ["compass"] = 115123411028382,
    ["settings"] = 80758916183665, ["settings-2"] = 135684703553372,
    ["shield"] = 110987169760162, ["shield-check"] = 87354736164608,
    ["shield-alert"] = 114995877719925, ["save"] = 126116963775616,
    ["save-off"] = 87085435778560, ["save-all"] = 116946975799440,
    ["rotate-ccw"] = 110116685948665, ["rotate-cw"] = 84183336178654,
    ["refresh-ccw"] = 117913330389477, ["refresh-cw"] = 138133190015277,
    ["download"] = 134814648082393, ["upload"] = 138212042425501,
    ["clipboard"] = 89601995828423, ["clipboard-copy"] = 125851897718493,
    ["clipboard-paste"] = 74382068849983, ["copy"] = 78979572434545,
    ["external-link"] = 129331830773832, ["link"] = 131607023382430,
    ["list"] = 113179976918783, ["list-ordered"] = 83212528113913,
    ["list-filter"] = 103321376129527, ["funnel"] = 108829540827529,
    ["list-checks"] = 99809353635593, ["list-start"] = 84828348299727,
    ["list-end"] = 77650610048119, ["eye"] = 100033680381365,
    ["eye-off"] = 135928786788378, ["image-off"] = 81934811700938,
    ["image"] = 112751259236831, ["images"] = 79350649395557,
    ["film"] = 120978945609706, ["code"] = 107380207681249,
    ["terminal"] = 106783148545356, ["database"] = 126791525623846,
    ["cpu"] = 77549309870247, ["network"] = 127410729922644,
    ["monitor"] = 72664649203050, ["smartphone"] = 96623008834511,
    ["mouse-pointer"] = 72322454962935, ["mouse-pointer-click"] = 107150227368485,
    ["accessibility"] = 114029945302017, ["languages"] = 90816903776498,
    ["type"] = 133543553793564, ["a-large-small"] = 111491496660216,
    ["contrast"] = 112796643981497, ["moon"] = 83380517901735,
    ["palette"] = 86350350950064, ["paint-bucket"] = 124275586663284,
    ["clock"] = 121808839832144, ["history"] = 123980022019922,
    ["logs"] = 89772091251787, ["loader"] = 78408734580845,
    ["loader-circle"] = 116535712789945, ["gauge"] = 110273524101447,
    ["activity"] = 94212016861936, ["chart-line"] = 101833156055618,
    ["construction"] = 106539489968173, ["bug"] = 83626408925438,
    ["flask-conical"] = 128406680901165, ["beaker"] = 80902539995520,
    ["flower"] = 86129438272762, ["rose"] = 126336840238769,
    ["sparkles"] = 138635884129147, ["sailboat"] = 87110567187540,
    ["ship"] = 83995100553930, ["scroll"] = 74072101474951,
    ["shrink"] = 90953687918880, ["shuffle"] = 132382786975101,
    ["maximize"] = 76045941763188, ["maximize-2"] = 73085922906397,
    ["minimize"] = 121304296213645, ["minimize-2"] = 116269596042539,
    ["x"] = 110786993356448, ["plus"] = 111774323017047,
    ["play"] = 135609604299893, ["pause"] = 74873705394436,
    ["panel-left"] = 97419752870313, ["panel-left-close"] = 126579818823552,
    ["panel-left-open"] = 111075816195767, ["panels-top-left"] = 79858853850600,
    ["user"] = 81589895647169, ["users"] = 115398113982385,
    ["user-cog"] = 92795491530865, ["user-check"] = 81775205032725,
    ["trash"] = 106723740584310, ["trash-2"] = 109843431391323,
    ["wrench"] = 112148279212860, ["triangle-alert"] = 125920361880643,
    ["swords"] = 81872698913435, ["sword"] = 124448418211665,
    ["target"] = 87563802520297, ["zap"] = 130551565616516,
    ["pin"] = 120978111007514, ["pin-off"] = 127696372451750,
    ["ellipsis"] = 140019550645825, ["ellipsis-vertical"] = 117978708573781,
    ["power"] = 96479131758775, ["power-off"] = 118768311012214,
    ["pipette"] = 133167932934404, ["pencil"] = 137986121120732,
    ["pickaxe"] = 105888023317688, ["puzzle"] = 136837798892463,
    ["route"] = 89968303228953, ["ruler"] = 81432445547423,
    ["table"] = 109109148250737, ["tag"] = 129104970103940,
    ["timer"] = 85473888890506, ["tool-case"] = 87533537832522,
    ["toolbox"] = 85341033903792, ["video"] = 107587444636945,
    ["volume-2"] = 89344380902620, ["volume-x"] = 139252359189540,
    ["wifi"] = 104669375183960, ["wifi-off"] = 74113634330106,
    ["webhook"] = 112812457747322, ["workflow"] = 99186544029189,
    ["zoom-in"] = 127956924984803, ["zoom-out"] = 108334162607319,
    ["undo"] = 111258459077271, ["redo"] = 116150342119054,
    ["sun"] = 110150589884127, ["heart"] = 116559368303288,
    ["book-open"] = 129845326810392, ["bookmark"] = 121093149326239,
    ["archive"] = 122180020814574, ["award"] = 132740088158419,
    ["bell-off"] = 78560046118930, ["bell-ring"] = 94612128913941,
    ["bolt"] = 102881251417484, ["braces"] = 117761094704041,
    ["brackets"] = 74368995728099, ["camera"] = 79950339943067,
    ["calendar"] = 114792700814035, ["circle"] = 130359823580534,
    ["clipboard-check"] = 92649798577170, ["cloud"] = 121226497050352,
    ["command"] = 93648221906330, ["crosshair"] = 134242818164054,
    ["crown"] = 127843403295538, ["delete"] = 126279426372342,
    ["droplet"] = 100597455015098, ["file"] = 74748492079329,
    ["files"] = 102806336233202, ["flag"] = 78183383236196,
    ["flame"] = 98218034436456, ["focus"] = 87493973153317,
    ["gamepad-2"] = 92483947987410, ["git-branch"] = 90490195516649,
    ["github"] = 120349554354380, ["globe"] = 114238209622913,
    ["grip"] = 109058783556768, ["grip-vertical"] = 137183678565296,
    ["hand"] = 130703864968637, ["hard-drive"] = 88183305858463,
    ["hash"] = 82890331678520, ["headphones"] = 118833729589183,
    ["hourglass"] = 86160434939203, ["inbox"] = 112591360302868,
    ["infinity"] = 98083086936965, ["keyboard-off"] = 92466375369772,
    ["laptop"] = 111387063244975, ["library"] = 114334671982047,
    ["lightbulb"] = 103871245626488, ["list-todo"] = 132980603752108,
    ["log-in"] = 103768533135201, ["log-out"] = 84895399304975,
    ["mail"] = 103945161245599, ["map"] = 95107167260947,
    ["map-pin"] = 84279202219901, ["message-square"] = 83881670383280,
    ["mic"] = 89640799126523, ["mouse"] = 73096068864710,
    ["navigation"] = 79308213542922, ["notebook"] = 136132108664987,
}
local IconAliases = {
    close = "x", home = "house", columns = "columns-2", sliders = "sliders-horizontal",
    filter = "funnel", ["help-circle"] = "circle-question-mark", ["circle-help"] = "circle-question-mark",
    ["alert-triangle"] = "triangle-alert", ["alert-circle"] = "circle-alert", ["alert-octagon"] = "octagon-alert",
    ["check-circle"] = "circle-check", ["x-circle"] = "circle-x", ["more-horizontal"] = "ellipsis", ["more-vertical"] = "ellipsis-vertical",
    sidebar = "panel-left", ["layout"] = "panels-top-left", ["settings-appearance"] = "sliders-horizontal",
}
local FetchIcons, Icons = false, nil
Library.IconCatalogue = { Revision = "58f2a4994f75d035472bdeb0ca276bd5bafc3282", Blob = "d1888c0f4bf064c2c7e6a88bc0a4cd096a268287", Source = "Footagesus/Icons/lucide/dist/Icons.lua" }
function Library:GetBundledIcon(Name)
    if typeof(Name) ~= "string" then return nil end
    Name = Name:gsub("^lucide%-", ""):gsub("^lucide:", "")
    Name = IconAliases[Name] or Name
    local Id = BundledIcons[Name]
    if not Id then return nil end
    return { Url = "rbxassetid://" .. tostring(Id), Id = Id, IconName = Name, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = false }
end
function Library:GetIcon(Name)
    if typeof(Name) ~= "string" then return nil end
    if FetchIcons and Icons and typeof(Icons.GetAsset) == "function" then
        local Ok, Ref = pcall(Icons.GetAsset, Name)
        if Ok and typeof(Ref) == "table" and typeof(Ref.Url) == "string" then
            Ref = table.clone(Ref)
            Ref.ImageRectOffset, Ref.ImageRectSize = Ref.ImageRectOffset or Vector2.zero, Ref.ImageRectSize or Vector2.zero
            return Ref
        end
    end
    return Library:GetBundledIcon(Name)
end
function Library:GetIconNames()
    local Names = {}
    for Name in BundledIcons do table.insert(Names, Name) end
    table.sort(Names)
    return Names
end


function Library:GetCustomIcon(IconName: string): any
    local CustomIcon = IsValidCustomIcon(IconName)
    if CustomIcon then
        return {
            Url = IconName,
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    local LucideIcon = Library:GetIcon(IconName)
    if LucideIcon then
        return LucideIcon
    end

    if tonumber(IconName) then
        return {
            Url = string.format("rbxassetid://%s", tostring(IconName)),
            ImageRectOffset = Vector2.zero,
            ImageRectSize = Vector2.zero,
            Custom = true,
        }
    end

    return nil
end

local function CopyDefault(Value)
    if typeof(Value) ~= "table" then return Value end
    local Copy = {}
    for Key, Item in Value do Copy[Key] = CopyDefault(Item) end
    return Copy
end

function Library:Validate(Data, Template)
    local Result = typeof(Data) == "table" and table.clone(Data) or {}
    for Key, Value in Template do
        if Result[Key] == nil then
            Result[Key] = CopyDefault(Value)
        elseif typeof(Value) == "table" and typeof(Result[Key]) == "table" then
            Result[Key] = CopyDefault(Result[Key])
        end
    end
    return Result
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)
    if ClassName == "UICorner" then Properties = table.clone(Properties); Properties.CornerRadius = UDim.new(0, 0) end
    if ClassName == "UIScale" and Properties.Scale == nil then
        Properties = table.clone(Properties)
        Properties.Scale = Library.DPIScale
    end

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)
    if (Instance:IsA("GuiButton") or Instance:IsA("TextBox")) and Library.InteractiveObjects then Library.InteractiveObjects[Instance] = true end
    if ClassName == "TextLabel" or ClassName == "TextButton" or ClassName == "TextBox" then
        Instance.TextScaled = false
        Instance.TextStrokeTransparency = 1
        if Library.RegisterTypography then Library:RegisterTypography(Instance) end
    end
    if Library.DensityMetrics and ClassName == "UIListLayout" and Properties.FillDirection ~= Enum.FillDirection.Horizontal then
        local Gap = Properties.Padding and Properties.Padding.Offset
        if Gap and Gap >= 6 and Gap <= 16 then
            Library.DensityMetrics[Instance] = { Padding = Gap }
            Instance.Padding = UDim.new(0, Library:Metrics().Gap)
        end
    end
    Instance.Destroying:Once(function()
        local Active = Library.MotionTweens and Library.MotionTweens[Instance]
        if Active then for _, Tween in Active do Tween:Cancel() end; Library.MotionTweens[Instance] = nil end
        -- Transient browsers and rebuilt rows must not accumulate in radius/DPI arrays.
        local Array = ClassName == "UICorner" and Library.Corners or (ClassName == "UIScale" and Library.Scales or nil)
        if Array then
            local Index = table.find(Array, Instance)
            if Index then table.remove(Array, Index) end
        end
        Library.Registry[Instance] = nil
        for Thread, Owner in Library.PendingTasks or {} do if Owner == Instance then Library:CancelTask(Thread) end end
        for _, Name in { "TextReflows", "TabRails", "DensityMetrics", "MotionTargets", "SurfaceStates", "IconMetrics", "TooltipOwners", "VisualRefreshers", "InteractiveObjects" } do
            if Library[Name] then Library[Name][Instance] = nil end
        end
    end)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

-- Chiyo construction primitives. Native text, integer layout, and square surfaces.
Library.Version = "5.0.0-chiyo-test.1"
Library.Design = { Radius = 0, Gap = 8, RowHeight = 36, HeaderHeight = 44 }
Library.Density = "Compact"
Library.SliderStyle = "Precision"
Library.ReducedMotion = false
Library.Readability = "Standard"
Library.TextSizeOffset = 0
Library.TextMetrics = setmetatable({}, { __mode = "k" })
Library.DensityMetrics = setmetatable({}, { __mode = "k" })
Library.MotionTweens = setmetatable({}, { __mode = "k" })
Library.MotionTargets = setmetatable({}, { __mode = "k" })
Library.TextReflows = setmetatable({}, { __mode = "k" })
Library.TabRails = setmetatable({}, { __mode = "k" })
Library.SurfaceStates = setmetatable({}, { __mode = "k" })
Library.IconMetrics = setmetatable({}, { __mode = "k" })
Library.ConsumedInputs = setmetatable({}, { __mode = "k" })
Library.CaptureInputs = setmetatable({}, { __mode = "k" })
Library.HandledInputs = setmetatable({}, { __mode = "k" })
Library.TooltipOwners = setmetatable({}, { __mode = "k" })
Library.PendingTasks = {}
Library.VisualRefreshers = setmetatable({}, { __mode = "k" })
Library.InteractiveObjects = setmetatable({}, { __mode = "k" })
Library.NavigationTargets = {}
Library.VirtualLists = setmetatable({}, { __mode = "k" })
Library.Animations = { TabSwitch = true, GroupboxCollapse = true, Slider = true }
Library.ThemeName = "Charcoal"
Library.Themes = {
    Charcoal = { BackgroundColor = "17191D", MainColor = "22252A", NavigationColor = "1C1E22", HeaderColor = "2C3036", FieldColor = "121418", OutlineColor = "484D57", FontColor = "F0F1F4", MutedColor = "B8BEC8", AccentColor = "FF4275" },
    Slate = { BackgroundColor = "171C23", MainColor = "232B35", NavigationColor = "1B222C", HeaderColor = "2D3846", FieldColor = "11171E", OutlineColor = "4A596B", FontColor = "EFF3F8", MutedColor = "BAC6D3", AccentColor = "FF4275" },
    Cinder = { BackgroundColor = "1D1919", MainColor = "2B2525", NavigationColor = "231E1E", HeaderColor = "383030", FieldColor = "171313", OutlineColor = "5B4E4E", FontColor = "F5EFEF", MutedColor = "CCBBBB", AccentColor = "FF4275" },
}
Library.ReadabilityPresets = {
    Standard = { Offset = 0, Field = 36, Target = 36, Gap = 8, Icon = 18, Header = 44, Column = 332 },
    Larger = { Offset = 2, Field = 40, Target = 40, Gap = 9, Icon = 20, Header = 48, Column = 372 },
    Largest = { Offset = 4, Field = 44, Target = 44, Gap = 10, Icon = 22, Header = 52, Column = 412 },
}
function Library:Metrics()
    local P = Library.ReadabilityPresets[Library.Readability] or Library.ReadabilityPresets.Standard
    if not Library.IsMobile then return P end
    local Result = table.clone(P)
    Result.Target, Result.Field = math.max(44, P.Target), math.max(40, P.Field)
    return Result
end
function Library:DeferOwned(Owner, Delay, Callback)
    if Library.Unloaded then return nil end
    local Thread
    local function Run()
        if not Library.Unloaded and (not Owner or Owner.Parent) then
            local Ok, Error = pcall(Callback)
            Library.PendingTasks[Thread] = nil
            if not Ok then warn("Chiyo owned task: " .. tostring(Error)) end
        else Library.PendingTasks[Thread] = nil end
    end
    Thread = Delay and task.delay(Delay, Run) or task.defer(Run)
    Library.PendingTasks[Thread] = Owner or true
    return Thread
end
function Library:CancelTask(Thread)
    if not Thread then return end
    Library.PendingTasks[Thread] = nil
    if Thread ~= coroutine.running() then pcall(task.cancel, Thread) end
end
function Library:IsReducedMotion()
    local Ok, Value = pcall(function() return GuiService.ReducedMotionEnabled end)
    return Library.ReducedMotion == true or (Ok and Value == true)
end
function Library:CreateTween(Object, Info, Goals)
    local Active = Library.MotionTweens[Object]
    if not Active then Active = {}; Library.MotionTweens[Object] = Active end
    local Conflicts = {}
    for Key in Goals do if Active[Key] then Conflicts[Active[Key]] = true end end
    for Tween in Conflicts do Tween:Cancel() end
    local Tween = TweenService:Create(Object, Library:IsReducedMotion() and TweenInfo.new(0) or Info, Goals)
    local Targets = Library.MotionTargets[Object] or {}
    Library.MotionTargets[Object] = Targets
    for Key, Value in Goals do Active[Key] = Tween; Targets[Key] = Value end
    Tween.Completed:Once(function()
        for Key in Goals do if Active[Key] == Tween then Active[Key] = nil; Targets[Key] = nil end end
    end)
    return Tween
end
function Library:CancelMotion(Object)
    local Active, Unique = Library.MotionTweens[Object], {}
    if not Active then return end
    for _, Tween in Active do Unique[Tween] = true end
    for Tween in Unique do Tween:Cancel() end
end
function Library:SetReducedMotion(Value)
    if Library.FeatureLoadDepth and Library.FeatureLoadDepth > 0 then return false end
    Library.ReducedMotion = Value == true
    if Library:IsReducedMotion() then
        for Object, Active in Library.MotionTweens do
            local Targets, Tweens = {}, {}
            for Key, Tween in Active do Targets[Key] = (Library.MotionTargets[Object] or {})[Key]; Tweens[Tween] = true end
            for Tween in Tweens do Tween:Cancel() end
            if Object.Parent then for Key, Value in Targets do Object[Key] = Value end end
        end
    end
    Library:LayoutChanged()
    return true
end
function Library:RegisterTypography(Object)
    local Minimum = Object.FontFace.Family == Library.Scheme.FontMono.Family and 14 or 15
    local Entry = { Size = math.max(Minimum, Object.TextSize), Applied = Object.TextSize }
    Library.TextMetrics[Object] = Entry
    local function Apply()
        if Library.Unloaded then return end
        -- Readability changes the native text size; it never scales a rasterized group.
        Entry.Applied = math.floor(Entry.Size + Library.TextSizeOffset + 0.5)
        if Object.TextSize ~= Entry.Applied then Object.TextSize = Entry.Applied end
    end
    Entry.Apply = Apply
    Object:GetPropertyChangedSignal("TextSize"):Connect(function()
        if Object.TextSize ~= Entry.Applied then Entry.Size = math.max(Minimum, Object.TextSize); Apply() end
    end)
    Object.Destroying:Once(function() Library.TextMetrics[Object] = nil end)
    Apply()
end
function Library:RefreshTypography()
    if Library.Unloaded then return end
    for Object, Entry in Library.TextMetrics do if Object.Parent then Entry.Apply() end end
    for Object, Entry in Library.IconMetrics do
        if Object.Parent then
            local Size = Entry.Size + Library.TextSizeOffset
            Object.Size = UDim2.fromOffset(Size, Size)
        end
    end
    for Object, Reflow in Library.TextReflows do if Object.Parent then Reflow() end end
    for Object, Rail in Library.TabRails do if Object.Parent then Rail:Update() end end
    if Library.Window then Library.Window:ApplyLayout() end
end
function Library:SetReadability(Name)
    if Library.FeatureLoadDepth and Library.FeatureLoadDepth > 0 then return false end
    local Preset = Library.ReadabilityPresets[Name]
    if not Preset then return false, "readability must be Standard, Larger, or Largest" end
    Library.Readability, Library.TextSizeOffset = Name, Preset.Offset
    for Object in Library.DensityMetrics do if Object.Parent then Object.Padding = UDim.new(0, Preset.Gap) end end
    Library:RefreshTypography()
    Library:LayoutChanged()
    return true
end
function Library:SetTextSizeOffset(Value)
    assert(IsFinite(Value) and Value >= 0 and Value <= 4 and Value % 1 == 0, "Text size offset must be an integer between 0 and 4")
    return Library:SetReadability(Value == 0 and "Standard" or (Value <= 2 and "Larger" or "Largest"))
end
function Library:SetDensity(Value)
    assert(Value == "Compact" or Value == "Comfortable" or Value == "Spacious", "Unknown density")
    -- Accepted presentation alias; no legacy oversized padding is reintroduced.
    return Library:SetReadability(Value == "Compact" and "Standard" or (Value == "Comfortable" and "Larger" or "Largest"))
end
function Library:SetTheme(Name)
    if Library.FeatureLoadDepth and Library.FeatureLoadDepth > 0 then return false end
    local Legacy = { Graphite = true, Ocean = true, Iris = true, Paper = true, Lunar = true, Aurora = true, Ember = true, Rose = true }
    if Legacy[Name] then Name = "Charcoal" end
    local Theme = Library.Themes[Name]
    if not Theme then return false, "unknown dark palette" end
    for _, Active in Library.MotionTweens do for Key, Tween in Active do if Key == "Color" or Key:find("Color3", 1, true) then Tween:Cancel() end end end
    Library._SchemeWriting = true
    for Key, Value in Theme do if Key ~= "AccentColor" then Library.Scheme[Key] = Color3.fromHex(Value) end end
    Library._SchemeWriting = false
    Library.IsLightTheme, Library.ThemeName = false, Name
    Library:UpdateColorsUsingRegistry()
    Library:LayoutChanged()
    return true
end
function Library:GetActiveTheme() return Library.ThemeName end
function Library:SetAccentColor(Color)
    assert(typeof(Color) == "Color3", "Accent color must be a Color3")
    if Library.FeatureLoadDepth and Library.FeatureLoadDepth > 0 then return false end
    Library._SchemeWriting = true; Library.Scheme.AccentColor = Color; Library._SchemeWriting = false
    Library:UpdateColorsUsingRegistry(); Library:LayoutChanged()
    return true
end
function Library:SetSliderStyle(Style)
    assert(Style == "Precision" or Style == "Line" or Style == "Filled" or Style == "Stepped" or Style == "Channel", "Unknown slider style")
    Library.SliderStyle = Style == "Stepped" and "Stepped" or "Precision"
    for _, Option in Library.Options do if Option.Type == "Slider" and Option.SetStyle and not Option.CustomStyle then Option:SetStyle(Library.SliderStyle) end end
    return true
end
function Library:GetContrastRatio(A, B)
    local function Luminance(C)
        local function Linear(V) return V <= 0.04045 and V / 12.92 or ((V + 0.055) / 1.055) ^ 2.4 end
        return 0.2126 * Linear(C.R) + 0.7152 * Linear(C.G) + 0.0722 * Linear(C.B)
    end
    local LA, LB = Luminance(A), Luminance(B)
    return (math.max(LA, LB) + 0.05) / (math.min(LA, LB) + 0.05)
end
function Library:GetOnColor(Background)
    local Dark, Light = Color3.fromRGB(16, 18, 22), Color3.new(1, 1, 1)
    return Library:GetContrastRatio(Dark, Background) >= Library:GetContrastRatio(Light, Background) and Dark or Light
end
function Library:GetMutedColor() return Library.Scheme.MutedColor end
function Library:GetThemeContrast()
    local Text = Library:GetContrastRatio(Library.Scheme.FontColor, Library.Scheme.MainColor)
    local Input = Library:GetContrastRatio(Library.Scheme.FontColor, Library.Scheme.FieldColor)
    local Accent = Library:GetContrastRatio(Library:GetOnColor(Library.Scheme.AccentColor), Library.Scheme.AccentColor)
    return { Text = Text, Input = Input, Accent = Accent, Pass = math.min(Text, Input, Accent) >= 4.5 }
end
function Library:RoundSurface(Object, _Radius)
    local Corner = Object:FindFirstChildOfClass("UICorner") or New("UICorner", { Parent = Object })
    Corner.CornerRadius = UDim.new(0, 0)
    return Corner
end
function Library:Surface(Object, Kind)
    local State = Library.SurfaceStates[Object]
    if State then return State end
    State = { Kind = Kind, Pressed = false, Focused = false, Disabled = false, Error = false }
    Library.SurfaceStates[Object] = State
    Object.BorderSizePixel = 0
    State.Stroke = New("UIStroke", { Name = "ChiyoBorder", Color = "OutlineColor", Thickness = 1, Transparency = 0, Parent = Object })
    State.Top = New("Frame", { Name = "ChiyoUpperEdge", BackgroundColor3 = "WhiteColor", BackgroundTransparency = Kind == "Field" and 1 or 0.93, Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 0, 1), Parent = Object })
    State.Bottom = New("Frame", { Name = "ChiyoLowerEdge", BackgroundColor3 = "DarkColor", BackgroundTransparency = Kind == "Action" and 0.3 or 0.6, Position = UDim2.new(0, 1, 1, -2), Size = UDim2.new(1, -2, 0, Kind == "Action" and 2 or 1), Parent = Object })
    if Kind == "Field" then
        State.Top.BackgroundColor3, State.Top.BackgroundTransparency = Library.Scheme.DarkColor, 0.25
        Library.Registry[State.Top].BackgroundColor3 = "DarkColor"
        Object.BackgroundColor3 = Library.Scheme.FieldColor
        local Props = Library.Registry[Object] or {}
        Props.BackgroundColor3 = "FieldColor"
        if Object:IsA("TextBox") or Object:IsA("TextButton") or Object:IsA("TextLabel") then Props.TextColor3 = Props.TextColor3 or "FontColor" end
        Library.Registry[Object] = Props
    else
        State.Gradient = New("UIGradient", { Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(231, 233, 237)), Rotation = 90, Parent = Object })
    end
    function State:Paint()
        if not Object.Parent or Library.Unloaded then return end
        local Role = State.Error and "RedColor" or (State.Focused and not State.Disabled and "AccentColor" or "OutlineColor")
        State.Stroke.Color = Library.Scheme[Role]
        Library.Registry[State.Stroke].Color = Role
        State.Stroke.Thickness = State.Focused and 2 or 1
        State.Stroke.Transparency = State.Disabled and 0.25 or 0
    end
    if Object:IsA("GuiObject") then
        Object.SelectionGained:Connect(function() State.Focused = true; State:Paint() end)
        Object.SelectionLost:Connect(function() State.Focused = false; State:Paint() end)
    end
    if Object:IsA("TextBox") then
        Object.Focused:Connect(function() State.Focused = true; State:Paint() end)
        Object.FocusLost:Connect(function() State.Focused = false; State:Paint() end)
    end
    return State
end
function Library:StyleField(Object)
    return Library:Surface(Object, "Field").Stroke
end
function Library:SetFieldError(Object, Message)
    local State = Library.SurfaceStates[Object] or Library:Surface(Object, "Field")
    State.Error = Message ~= nil and Message ~= ""
    State:Paint()
    Object:SetAttribute("ChiyoError", Message)
end
function Library:ActionPress(Button, Pressed)
    local State = Library.SurfaceStates[Button]
    if not State or State.Kind ~= "Action" or State.Disabled or not Button.Parent then return end
    State.Pressed = Pressed == true
    State.Top.BackgroundTransparency = Pressed and 1 or 0.93
    State.Bottom.Size = UDim2.new(1, -2, 0, Pressed and 0 or 2)
    local Padding = Button:FindFirstChildOfClass("UIPadding")
    if Padding then
        if not State.PadTop then State.PadTop, State.PadBottom = Padding.PaddingTop, Padding.PaddingBottom end
        local Delta = Pressed and not Library:IsReducedMotion() and 1 or 0
        Padding.PaddingTop = UDim.new(State.PadTop.Scale, State.PadTop.Offset + Delta)
        Padding.PaddingBottom = UDim.new(State.PadBottom.Scale, State.PadBottom.Offset - Delta)
    end
end
function Library:StyleAction(Button, Variant, Disabled, Hovered)
    local State = Library:Surface(Button, "Action")
    State.Variant, State.Disabled, State.Hovered = Variant or "Secondary", Disabled == true, Hovered == true
    local function Background()
        if State.Disabled then return Library.Scheme.MainColor end
        if State.Variant == "Primary" then return Library.Scheme.AccentColor end
        if State.Variant == "Destructive" then return Library.Scheme.MainColor:Lerp(Library.Scheme.RedColor, State.Hovered and 0.22 or 0.12) end
        return State.Hovered and Library.Scheme.HeaderColor:Lerp(Library.Scheme.FontColor, 0.035) or Library.Scheme.HeaderColor
    end
    local function Foreground()
        if State.Disabled then return Library.Scheme.MutedColor end
        if State.Variant == "Primary" then return Library:GetOnColor(Library.Scheme.AccentColor) end
        if State.Variant == "Destructive" then return Library.Scheme.RedColor end
        return Library.Scheme.FontColor
    end
    local Properties = Library.Registry[Button] or {}
    Properties.BackgroundColor3, Properties.TextColor3 = Background, Foreground
    Library.Registry[Button] = Properties
    Button.BackgroundColor3, Button.TextColor3 = Background(), Foreground()
    Button.TextTransparency, Button.BackgroundTransparency = 0, 0
    Button.Active, Button.Selectable = not State.Disabled, not State.Disabled
    State:Paint()
    if not State.Bound then
        State.Bound = true
        Button.InputBegan:Connect(function(Input)
            if not IsClickInput(Input) or State.Disabled then return end
            if State.PressConnection then State.PressConnection:Disconnect(); State.PressConnection = nil end
            Library:ActionPress(Button, true)
            local Ended
            Ended = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel then
                    Ended:Disconnect(); State.PressConnection = nil; Library:ActionPress(Button, false)
                end
            end)
            State.PressConnection = Ended
        end)
        Button.MouseLeave:Connect(function() Library:ActionPress(Button, false) end)
        Button.Destroying:Once(function() if State.PressConnection then State.PressConnection:Disconnect(); State.PressConnection = nil end end)
    end
end
function Library:CreateSymbol(Parent, Name, Position, Size, Color)
    Size = Size or 18
    local Icon = Library:GetBundledIcon(Name)
    local Root = New("Frame", { Name = "Symbol_" .. tostring(Name), BackgroundTransparency = 1, Position = Position or UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(Size, Size), Parent = Parent })
    local Image = New("ImageLabel", { Name = "Lucide", BackgroundTransparency = 1, Image = Icon and Icon.Url or "", ImageColor3 = Color or "FontColor", Size = UDim2.fromScale(1, 1), Parent = Root })
    local FallbackNames = { ["move-diagonal"] = "Size", ["arrow-up"] = "Up", ["arrow-down"] = "Down", ["chevron-up"] = "Up", ["arrow-up-to-line"] = "Top", ["arrow-down-to-line"] = "End", info = "Info", pin = "Pin", star = "Pin", play = "Play", close = "Close", x = "Close", search = "Find", bell = "Log", sliders = "Look", ["sliders-horizontal"] = "Look", expand = "Open", ["panel-left"] = "Pages", minus = "Hide", check = "Yes", ["chevron-down"] = "More", ["chevron-left"] = "Back", ["chevron-right"] = "Next", ["circle-help"] = "Help", ["circle-question-mark"] = "Help" }
    local Fallback = New("TextLabel", { Name = "IconFallback", BackgroundTransparency = 1, Text = FallbackNames[Name] or tostring(Name):gsub("%-", " "), RichText = false, TextSize = 14, TextColor3 = Color or "FontColor", TextWrapped = false, Visible = not Icon, Size = UDim2.fromScale(1, 1), Parent = Root })
    local function Loaded()
        local Ok, Value = pcall(function() return Image.IsLoaded end)
        if Ok and Value then Fallback.Visible = false; Image.Visible = true end
    end
    Image:GetPropertyChangedSignal("IsLoaded"):Connect(Loaded)
    Root:GetPropertyChangedSignal("Rotation"):Connect(function() Fallback.Rotation = -Root.Rotation end)
    Library:DeferOwned(Root, 4, function()
        local Ok, LoadedNow = pcall(function() return Image.IsLoaded end)
        if not Ok or not LoadedNow then
            Image.Visible, Fallback.Visible = false, true
            local Width = Library:GetTextBounds(Fallback.Text, Fallback.FontFace, Fallback.TextSize, nil, false)
            -- Text fallback gets room instead of rendering a tiny replacement glyph.
            Fallback.AnchorPoint = Vector2.new(0.5, 0.5)
            Fallback.Position = UDim2.fromScale(0.5, 0.5)
            Fallback.Size = UDim2.fromOffset(math.max(Size, Width + 4), math.max(Size, Fallback.TextSize + 4))
            Root:SetAttribute("ChiyoIconUnavailable", true)
            if Library.Window and Library.Window.ApplyLayout then Library.Window:ApplyLayout() end
        end
    end)
    Library.IconMetrics[Root] = { Size = Size }
    Loaded()
    return Root
end
function Library:FitToggle(Holder, Label, Owner, Minimum)
    local AddonHost = Holder:FindFirstChild("ChiyoAttachments")
    if not AddonHost then
        local OldLayout = Label:FindFirstChildOfClass("UIListLayout")
        if OldLayout then OldLayout:Destroy() end
        AddonHost = New("Frame", { Name = "ChiyoAttachments", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(0, 28), Parent = Holder })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), Parent = AddonHost })
        Label:SetAttribute("ChiyoHasAttachmentHost", true)
    end
    Label.TextWrapped = true
    local Pending = false
    local function Fit()
        if Pending or not Holder.Parent or Library.Unloaded then return end
        Pending = true
        Library:DeferOwned(Holder, nil, function()
            Pending = false
            local M = Library:Metrics()
            local AddonWidth, AddonHeight = 0, M.Target
            for _, Child in AddonHost:GetChildren() do if Child:IsA("GuiObject") and Child.Visible then AddonWidth += Child.Size.X.Offset + 6; AddonHeight = math.max(AddonHeight, Child.Size.Y.Offset) end end
            AddonWidth = math.max(0, AddonWidth - 6)
            local Width = math.max(80, Holder.AbsoluteSize.X / Library.DPIScale)
            local Left = Label.Position.X.Offset
            local Separate = AddonWidth > Width * 0.52
            local Available = math.max(40, Width - Left - (Separate and 0 or AddonWidth > 0 and AddonWidth + 10 or 0))
            local _, Height = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, Available, Label.RichText)
            local TextHeight = math.max(AddonWidth > 0 and not Separate and AddonHeight or (Minimum or M.Target), Height + 8)
            Label.Size = UDim2.new(0, Available, 0, TextHeight)
            AddonHost.Size = UDim2.fromOffset(math.min(AddonWidth, Width), AddonHeight)
            AddonHost.AnchorPoint = Vector2.new(1, Separate and 0 or 0.5)
            AddonHost.Position = Separate and UDim2.new(1, 0, 0, TextHeight) or UDim2.new(1, 0, 0, TextHeight / 2)
            Holder.Size = UDim2.new(1, 0, 0, TextHeight + (Separate and AddonHeight or 0))
            Owner:Resize()
        end)
    end
    Library.TextReflows[Holder] = Fit
    Label:GetPropertyChangedSignal("Text"):Connect(Fit)
    Label:GetPropertyChangedSignal("TextSize"):Connect(Fit)
    Label:GetPropertyChangedSignal("FontFace"):Connect(Fit)
    Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
    AddonHost.ChildAdded:Connect(Fit); AddonHost.ChildRemoved:Connect(Fit)
    AddonHost:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Fit)
    Fit()
    return AddonHost
end
function Library:CreateTabRail(Parent, Level)
    Level = Level or 1
    local Rail = { Buttons = {}, Active = nil, Updating = false, Level = Level }
    local Frame = New("Frame", { Name = Level == 1 and "PrimaryTabs" or "SecondaryTabs", BackgroundColor3 = Level == 1 and "HeaderColor" or "NavigationColor", Size = UDim2.new(1, 0, 0, 38), Parent = Parent })
    local Scroll = New("ScrollingFrame", { BackgroundTransparency = 1, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2, ScrollBarImageColor3 = "OutlineColor", Position = UDim2.fromOffset(0, 0), Size = UDim2.fromScale(1, 1), Parent = Frame })
    local Content = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(0, 1), ZIndex = Scroll.ZIndex + 2, Parent = Scroll })
    local Layout = New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 2), Parent = Content })
    local Chip = New("Frame", { Name = "SelectedTab", BackgroundColor3 = "AccentColor", BackgroundTransparency = Level == 1 and 0.88 or 0, Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(0, 36), Visible = false, ZIndex = Scroll.ZIndex + 1, Parent = Scroll })
    local Marker = New("Frame", { BackgroundColor3 = "AccentColor", Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2), Parent = Chip })
    local function Arrow(Right)
        local B = New("TextButton", { BackgroundColor3 = "HeaderColor", Text = "", Size = UDim2.fromOffset(32, 36), AnchorPoint = Vector2.new(Right and 1 or 0, 0.5), Position = Right and UDim2.fromScale(1, 0.5) or UDim2.fromScale(0, 0.5), Visible = false, ZIndex = 5, Parent = Frame })
        Library:CreateSymbol(B, Right and "chevron-right" or "chevron-left", UDim2.new(0.5, -9, 0.5, -9), 18)
        Library:AddTooltip(Right and "Scroll tabs right" or "Scroll tabs left", "", B)
        return B
    end
    local Previous, Next = Arrow(false), Arrow(true)
    Rail.Frame, Rail.Scroll, Rail.Content, Rail.LayoutObject, Rail.Previous, Rail.Next, Rail.Chip = Frame, Scroll, Content, Layout, Previous, Next, Chip
    Library.TabRails[Frame] = Rail
    function Rail:GetMaxScroll() return math.max(0, (Rail.ContentWidth or 0) * Library.DPIScale - Scroll.AbsoluteSize.X) end
    function Rail:Reveal(Button)
        if not Button or not Button.Parent or Scroll.AbsoluteSize.X <= 0 then return end
        local Left = Button.AbsolutePosition.X - Scroll.AbsolutePosition.X + Scroll.CanvasPosition.X
        local Target = Scroll.CanvasPosition.X
        if Left < Target then Target = Left elseif Left + Button.AbsoluteSize.X > Target + Scroll.AbsoluteSize.X then Target = Left + Button.AbsoluteSize.X - Scroll.AbsoluteSize.X end
        Scroll.CanvasPosition = Vector2.new(math.clamp(Target, 0, Rail:GetMaxScroll()), 0)
    end
    function Rail:Update()
        if Rail.Updating or not Frame.Parent or Library.Unloaded then return end
        Rail.Updating = true
        local M, Width = Library:Metrics(), 0
        local Height = math.max(M.Target, Level == 1 and 38 or 34)
        for _, Entry in Rail.Buttons do
            if Entry.Button.Visible then
                local TextWidth, TextHeight = Library:GetTextBounds(Entry.Label.Text, Entry.Label.FontFace, Entry.Label.TextSize, nil, false)
                local W = math.max(64, TextWidth + (Entry.Icon and 44 or 24))
                Entry.Button.Size = UDim2.fromOffset(W, Height)
                Width += W + 2; Height = math.max(Height, TextHeight + 12)
            end
        end
        Width = math.max(0, Width - 2)
        Rail.ContentWidth = Width
        Frame.Size = UDim2.new(1, 0, 0, Height + 2)
        Content.Size = UDim2.new(0, Width, 1, 0)
        Scroll.CanvasSize = UDim2.fromOffset(Width, 0)
        local Overflow = Width * Library.DPIScale > Frame.AbsoluteSize.X
        local Target = math.max(32, M.Target)
        Scroll.Position = UDim2.fromOffset(Overflow and Target or 0, 0)
        Scroll.Size = UDim2.new(1, Overflow and -Target * 2 or 0, 1, 0)
        Previous.Size, Next.Size = UDim2.fromOffset(Target, Height), UDim2.fromOffset(Target, Height)
        Previous.Visible, Next.Visible = Overflow, Overflow
        Previous.Active, Next.Active = Scroll.CanvasPosition.X > 1, Scroll.CanvasPosition.X < Rail:GetMaxScroll() - 1
        Previous.BackgroundTransparency, Next.BackgroundTransparency = Previous.Active and 0 or 0.5, Next.Active and 0 or 0.5
        local Entry = Rail.Active
        if Entry and Entry.Button.Visible then
            local Left = (Entry.Button.AbsolutePosition.X - Scroll.AbsolutePosition.X + Scroll.CanvasPosition.X) / Library.DPIScale
            local Goals = { Position = UDim2.fromOffset(math.max(0, math.floor(Left + 0.5)), Level == 1 and 0 or Height - 2), Size = UDim2.fromOffset(Entry.Button.Size.X.Offset, Level == 1 and Height or 2) }
            Chip.Visible = true
            if Rail.LastX ~= Goals.Position.X.Offset or Rail.LastWidth ~= Goals.Size.X.Offset or Rail.LastHeight ~= Height then
                Rail.LastX, Rail.LastWidth, Rail.LastHeight = Goals.Position.X.Offset, Goals.Size.X.Offset, Height
                Library:CreateTween(Chip, TweenInfo.new(Library.Animations.TabSwitch and 0.1 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Goals):Play()
            end
        else Chip.Visible = false end
        Rail.Updating = false
    end
    function Rail:Add(Button, Label, Icon, Activate)
        local Entry = { Button = Button, Label = Label, Icon = Icon, Activate = Activate }
        table.insert(Rail.Buttons, Entry)
        local function Ink() return Rail.Active == Entry and Library.Scheme.FontColor or Library.Scheme.MutedColor end
        Library.Registry[Label].TextColor3 = Ink; Label.TextColor3 = Ink()
        Button:GetPropertyChangedSignal("Visible"):Connect(function() Rail:Update() end)
        Label:GetPropertyChangedSignal("Text"):Connect(function() Rail:Update() end)
        Button.InputBegan:Connect(function(Input)
            if UserInputService:GetFocusedTextBox() or Library.PickingKeybind then return end
            local Direction = (Input.KeyCode == Enum.KeyCode.Left or Input.KeyCode == Enum.KeyCode.DPadLeft) and -1 or ((Input.KeyCode == Enum.KeyCode.Right or Input.KeyCode == Enum.KeyCode.DPadRight) and 1 or 0)
            if Direction == 0 then return end
            Library.ConsumedInputs[Input] = true
            local Index = table.find(Rail.Buttons, Entry)
            for Step = 1, #Rail.Buttons do
                local Candidate = Rail.Buttons[(Index - 1 + Direction * Step) % #Rail.Buttons + 1]
                if Candidate.Button.Visible then Candidate.Activate(); GuiService.SelectedObject = Candidate.Button; break end
            end
        end)
        Rail:Update()
        return Entry
    end
    function Rail:Select(Entry)
        Rail.Active = Entry
        for _, Item in Rail.Buttons do
            Item.Label.TextColor3 = Item == Entry and Library.Scheme.FontColor or Library.Scheme.MutedColor
            Item.Label.TextTransparency = 0
        end
        Rail:Update()
        Library:DeferOwned(Frame, nil, function() if Rail.Active == Entry then Rail:Update(); Rail:Reveal(Entry and Entry.Button) end end)
    end
    local function Move(Direction)
        Scroll.CanvasPosition = Vector2.new(math.clamp(Scroll.CanvasPosition.X + Direction * math.max(96, Scroll.AbsoluteSize.X * 0.7), 0, Rail:GetMaxScroll()), 0)
        Rail:Update()
    end
    Previous.Activated:Connect(function() Move(-1) end); Next.Activated:Connect(function() Move(1) end)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Rail:Update() end)
    Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Rail:Update() end)
    Scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function() Rail:Update() end)
    return Rail
end

-- Bounded, variable-height row recycling. Metadata is O(n); GUI instances are viewport-bounded.
function Library:CreateVirtualList(Parent, Config)
    Config = Config or {}
    local List = New("ScrollingFrame", { Name = "RecycledRows", BackgroundTransparency = 1, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = "OutlineColor", Active = true, Size = UDim2.fromScale(1, 1), Parent = Parent })
    local V = { Frame = List, Config = Config, Entries = {}, Pool = {}, Heights = {}, Lines = {}, Generation = 0, Selection = 1, Columns = 1 }
    local Empty = New("TextLabel", { BackgroundTransparency = 1, Text = Config.EmptyText or "No available items", RichText = false, TextWrapped = true, TextSize = 15, TextColor3 = "MutedColor", Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 0, 64), Visible = true, Parent = List })
    V.Empty = Empty
    local function Open() return List.Parent and not Library.Unloaded and (not Config.IsOpen or Config.IsOpen()) end
    local function ColumnCount(Width) return math.max(1, Config.Columns and Config.Columns(Width) or 1) end
    local function Geometry()
        local Width = math.max(60, math.floor(List.AbsoluteSize.X / Library.DPIScale) - List.ScrollBarThickness - 2)
        local Columns = ColumnCount(Width)
        if not V.GeometryDirty and V.GeometryWidth == Width and V.GeometryPreset == Library.Readability and V.GeometryGeneration == V.Generation and V.Columns == Columns then return end
        V.GeometryDirty, V.GeometryWidth, V.GeometryPreset, V.GeometryGeneration = false, Width, Library.Readability, V.Generation
        V.Columns = Columns
        V.CellWidth = math.max(40, math.floor((Width - (V.Columns - 1) * 8) / V.Columns))
        local Y, Minimum = 0, Library:Metrics().Target
        V.Lines = {}
        for Index = 1, #V.Entries, V.Columns do
            local Height = Minimum
            for J = Index, math.min(#V.Entries, Index + V.Columns - 1) do
                local Entry = V.Entries[J]
                local Cache = V.Heights[Entry.Key]
                if Cache and Cache.Width == V.CellWidth and Cache.Text == Entry.Text and Cache.Subtitle == Entry.Subtitle and Cache.Preset == Library.Readability then Height = math.max(Height, Cache.Height) end
            end
            V.Lines[#V.Lines + 1] = { Top = Y, Height = Height, First = Index }
            Y += Height + 2
        end
        local PreviousHeight = V.TotalHeight
        V.TotalHeight = math.max(0, Y - 2)
        List.CanvasSize = UDim2.fromOffset(0, V.TotalHeight)
        if PreviousHeight ~= V.TotalHeight and Config.HeightChanged then Config.HeightChanged(V.TotalHeight) end
    end
    local function FindLine(Y)
        local Low, High = 1, #V.Lines
        while Low < High do
            local Middle = math.floor((Low + High + 1) / 2)
            if V.Lines[Middle].Top <= Y then Low = Middle else High = Middle - 1 end
        end
        return Low
    end
    local function MakeRow()
        local R = {}
        R.Button = New("TextButton", { Name = "PooledRow", BackgroundColor3 = "MainColor", Text = "", Visible = false, Parent = List })
        R.Marker = New("Frame", { Name = "Selection", BackgroundColor3 = "FieldColor", Position = UDim2.fromOffset(8, 10), Size = UDim2.fromOffset(18, 18), Parent = R.Button })
        R.MarkerStroke = New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = R.Marker })
        R.Check = Library:CreateSymbol(R.Marker, "check", UDim2.fromOffset(1, 1), 16, function() return Library:GetOnColor(Library.Scheme.AccentColor) end)
        R.Rank = New("TextLabel", { BackgroundTransparency = 1, FontFace = "FontMono", RichText = false, Text = "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center, Size = UDim2.fromOffset(34, 36), Parent = R.Button })
        R.Image = New("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24), Position = UDim2.fromOffset(34, 6), Visible = false, Parent = R.Button })
        R.Label = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Parent = R.Button })
        R.Subtitle = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextWrapped = true, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Visible = false, Parent = R.Button })
        R.Divider = New("Frame", { BackgroundColor3 = "OutlineColor", BackgroundTransparency = 0.65, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), Parent = R.Button })
        R.Focus = New("UIStroke", { Color = "AccentColor", Thickness = 1, Transparency = 1, Parent = R.Button })
        R.Button.MouseEnter:Connect(function() R.Hovered = true; V:Paint() end)
        R.Button.MouseLeave:Connect(function() R.Hovered = false; V:Paint() end)
        R.Button.SelectionGained:Connect(function() if R.Index then V.Selection = R.Index; V.Keyboard = true; V:Paint() end end)
        R.Button.InputBegan:Connect(function(Input)
            if IsClickInput(Input) then R.PressInput, R.PressPosition, R.PressScroll = Input, Input.Position, List.CanvasPosition.Y end
        end)
        R.Button.Activated:Connect(function(Input)
            if Input and R.PressInput == Input and ((Input.Position - R.PressPosition).Magnitude > 7 * Library.DPIScale or math.abs(List.CanvasPosition.Y - R.PressScroll) > 3) then return end
            if R.Entry and not (Config.IsDisabled and Config.IsDisabled(R.Entry)) and Library:CanInteract(R.Button, Input) and Config.Activate then Config.Activate(R.Entry, R.Index) end
        end)
        R.Button.InputBegan:Connect(function(Input) if Config.HandleInput then Config.HandleInput(Input) end end)
        return R
    end
    function V:SetEntries(Entries, ResetScroll)
        V.Generation += 1
        V.Entries = Entries or {}
        V.Selection = math.clamp(V.Selection, 1, math.max(1, #V.Entries))
        local Members = {}
        for _, Entry in V.Entries do Members[Entry.Key] = true end
        for Key in V.Heights do if not Members[Key] then V.Heights[Key] = nil end end
        if ResetScroll then List.CanvasPosition = Vector2.zero; V.Selection = 1 end
        Geometry(); V:Paint()
    end
    function V:Paint()
        if V.Painting or not Open() then return end
        V.Painting = true
        local Generation = V.Generation
        Geometry()
        local Scroll = List.CanvasPosition.Y / Library.DPIScale
        local FirstLine = math.max(1, FindLine(Scroll) - 1)
        local LastLine, ViewBottom = FirstLine, Scroll + List.AbsoluteSize.Y / Library.DPIScale
        while LastLine < #V.Lines and V.Lines[LastLine].Top <= ViewBottom do LastLine += 1 end
        local Wanted = math.max(0, math.min(#V.Entries - (FirstLine - 1) * V.Columns, (LastLine - FirstLine + 1) * V.Columns))
        for Index = #V.Pool + 1, Wanted do V.Pool[Index] = MakeRow() end
        for Index = #V.Pool, Wanted + 1, -1 do V.Pool[Index].Button:Destroy(); V.Pool[Index] = nil end
        local Changed = false
        for Index, R in V.Pool do
            local EntryIndex = (FirstLine - 1) * V.Columns + Index
            local Entry = V.Entries[EntryIndex]
            R.Entry, R.Index = Entry, EntryIndex
            R.Button.Visible = Entry ~= nil
            if Entry then
                local Line = V.Lines[math.floor((EntryIndex - 1) / V.Columns) + 1]
                local Col = (EntryIndex - 1) % V.Columns
                local Disabled = Config.IsDisabled and Config.IsDisabled(Entry) or false
                local Selected = Config.IsSelected and Config.IsSelected(Entry) or false
                local Focused = V.Selection == EntryIndex and Config.KeyboardFocus == true and V.Keyboard == true
                local Ranked = Config.Priority == true
                local Ref = Entry.Image
                local Icon = Ref and Library:GetCustomIcon(Ref)
                local Left = Config.NoMarker and 10 or (Ranked and 42 or 34)
                R.Image.Visible = Icon ~= nil
                if Icon then R.Image.Image = Icon.Url; R.Image.ImageRectOffset = Icon.ImageRectOffset or Vector2.zero; R.Image.ImageRectSize = Icon.ImageRectSize or Vector2.zero; R.Image.Position = UDim2.fromOffset(Left, 6); Left += 30 end
                local Cache = V.Heights[Entry.Key]
                local Height, TitleHeight, SubtitleHeight
                if Cache and Cache.Width == V.CellWidth and Cache.Text == Entry.Text and Cache.Subtitle == Entry.Subtitle and Cache.Preset == Library.Readability and Cache.Left == Left then Height, TitleHeight, SubtitleHeight = Cache.Height, Cache.TitleHeight, Cache.SubtitleHeight
                else
                    local _, TextHeight = Library:GetTextBounds(Entry.Text, R.Label.FontFace, R.Label.TextSize, math.max(20, V.CellWidth - Left - 10), false)
                    TitleHeight, SubtitleHeight = TextHeight, 0
                    if Entry.Subtitle and Entry.Subtitle ~= "" then local _, H = Library:GetTextBounds(Entry.Subtitle, R.Subtitle.FontFace, R.Subtitle.TextSize, math.max(20, V.CellWidth - Left - 10), false); SubtitleHeight = H + 4 end
                    Height = math.max(Library:Metrics().Target, TextHeight + SubtitleHeight + 12)
                end
                if Generation ~= V.Generation or not Open() then V.Painting = false; return end
                if not Cache or Cache.Height ~= Height or Cache.Width ~= V.CellWidth or Cache.Text ~= Entry.Text or Cache.Preset ~= Library.Readability or Cache.Subtitle ~= Entry.Subtitle or Cache.Left ~= Left then
                    V.Heights[Entry.Key] = { Width = V.CellWidth, Text = Entry.Text, Subtitle = Entry.Subtitle, TitleHeight = TitleHeight, SubtitleHeight = SubtitleHeight, Preset = Library.Readability, Height = Height, Left = Left }; Changed = true; V.GeometryDirty = true
                end
                R.Button.Position = UDim2.fromOffset(Col * (V.CellWidth + 8), Line.Top)
                R.Button.Size = UDim2.fromOffset(V.CellWidth, Line.Height)
                R.Button.Active, R.Button.Selectable = not Disabled, not Disabled
                R.Button.BackgroundColor3 = Selected and Library.Scheme.MainColor:Lerp(Library.Scheme.AccentColor, 0.16) or (R.Hovered and Library.Scheme.HeaderColor or Library.Scheme.MainColor)
                R.Marker.Visible, R.Rank.Visible = not Ranked and not Config.NoMarker, Ranked
                R.Marker.Position = UDim2.fromOffset(8, math.floor((Line.Height - 18) / 2))
                R.Marker.BackgroundColor3 = Selected and (Disabled and Library.Scheme.MutedColor or Library.Scheme.AccentColor) or Library.Scheme.FieldColor
                R.MarkerStroke.Color = Selected and Library.Scheme.AccentColor or Library.Scheme.OutlineColor
                R.Check.Visible = Selected
                R.Rank.Text, R.Rank.Size = tostring(Entry.Rank or EntryIndex), UDim2.fromOffset(34, Line.Height)
                R.Label.Text, R.Label.TextColor3 = Entry.Text, Disabled and Library.Scheme.MutedColor or Library.Scheme.FontColor
                R.Label.Position, R.Label.Size = UDim2.fromOffset(Left, 0), UDim2.new(1, -Left - 10, 1, 0)
                R.Subtitle.Visible = Entry.Subtitle ~= nil and Entry.Subtitle ~= ""
                if R.Subtitle.Visible then
                    R.Label.Position, R.Label.Size = UDim2.fromOffset(Left, 6), UDim2.new(1, -Left - 10, 0, TitleHeight)
                    R.Subtitle.Text = Entry.Subtitle
                    R.Subtitle.Position, R.Subtitle.Size = UDim2.fromOffset(Left, TitleHeight + 10), UDim2.new(1, -Left - 10, 0, math.max(0, (SubtitleHeight or 4) - 4))
                end
                R.Focus.Transparency = Focused and 0 or 1
                R.Button:SetAttribute("ChiyoDisabled", Disabled)
                R.Button:SetAttribute("ChiyoSelected", Selected)
                if Config.Decorate then Config.Decorate(R, Entry, EntryIndex) end
            end
        end
        Empty.Visible = #V.Entries == 0
        Empty.Text = Config.EmptyText or "No available items"
        V.Painting = false
        if Changed and not V.RepaintQueued then
            V.RepaintQueued = true
            Library:DeferOwned(List, nil, function() V.RepaintQueued = false; V:Paint() end)
        end
    end
    function V:RevealIndex(Index)
        if #V.Entries == 0 then return end
        V.Selection = math.clamp(Index, 1, #V.Entries)
        Geometry()
        local Line = V.Lines[math.floor((V.Selection - 1) / V.Columns) + 1]
        local Y, Height = Line.Top * Library.DPIScale, Line.Height * Library.DPIScale
        local Scroll = List.CanvasPosition.Y
        if Y < Scroll then Scroll = Y elseif Y + Height > Scroll + List.AbsoluteSize.Y then Scroll = Y + Height - List.AbsoluteSize.Y end
        List.CanvasPosition = Vector2.new(0, math.max(0, Scroll))
        V:Paint()
    end
    function V:Refresh() V.Heights = {}; V.GeometryDirty = true; V:Paint() end
    function V:Destroy() V.Generation += 1; table.clear(V.Pool); table.clear(V.Heights); List:Destroy() end
    List:GetPropertyChangedSignal("CanvasPosition"):Connect(function() V:Paint() end)
    List:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() V:Paint() end)
    Library.TextReflows[List] = function() V:Refresh() end
    Library.VirtualLists[List] = V
    List.Destroying:Once(function()
        V.Generation += 1; Library.VirtualLists[List] = nil
        table.clear(V.Pool); table.clear(V.Heights); table.clear(V.Entries); table.clear(V.Lines)
    end)
    return V
end


--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local ScreenGui = New("ScreenGui", {
    Name = "Chiyo",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    ResetOnSpawn = false,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui
ScreenGui.DescendantRemoving:Connect(function(Object)
    task.defer(function()
        if Object:IsDescendantOf(ScreenGui) then return end
        Library:RemoveFromRegistry(Object)
        Library.TextReflows[Object], Library.TabRails[Object], Library.DensityMetrics[Object] = nil, nil, nil
        Library:CancelMotion(Object)
        Library.MotionTweens[Object], Library.MotionTargets[Object] = nil, nil
        for _, Registry in { Library.Corners, Library.Scales } do
            local Index = table.find(Registry, Object)
            if Index then table.remove(Registry, Index) end
        end
    end)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Notification
local NotificationArea
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        ZIndex = 16000,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

Library.NotifyOrder = {}

function Library:UpdateNotificationPositions(Snap)
    local Left = Library.NotifySide:lower() == "left"
    local XScale = Left and 0 or 1
    local RunningY = 0

    for _, FakeBg in Library.NotifyOrder do
        local Data = Library.Notifications[FakeBg]
        if Data and FakeBg.Parent then
            local Target = UDim2.new(XScale, 0, 0, RunningY)

            if Snap or not Data.PositionInitialized then
                FakeBg.Position = Target
                Data.PositionInitialized = true
            elseif FakeBg.Position ~= Target then
                Library:CreateTween(FakeBg, Library.NotifyTweenInfo, {
                    Position = Target,
                }):Play()
            end

            RunningY += FakeBg.AbsoluteSize.Y / Library.DPIScale + 8
        end
    end
end

--// Lib Functions \\--
function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text, Face, Size, Width, RichText)
    Text = tostring(Text or "")
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text, Params.Font, Params.Size = Text, Face, Size
    Params.RichText = RichText ~= false
    Params.Width = Width and Width > 0 and math.max(1, math.floor(Width)) or 0
    local Success, Bounds = pcall(TextService.GetTextBoundsAsync, TextService, Params)
    Params:Destroy()
    if not Success then
        local Plain = RichText ~= false and Text:gsub("<[^>]*>", ""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&") or Text
        local FontEnum = Face.Family == Library.Scheme.FontMono.Family and Enum.Font.Code or Enum.Font.BuilderSans
        Bounds = TextService:GetTextSize(Plain, Size, FontEnum, Vector2.new(Width and Width > 0 and math.max(1, Width) or 1000000, 1000000))
        Library.TextMeasurementFallback = true
    end
    return math.ceil(Bounds.X), math.ceil(Bounds.Y)
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        Library.CallbackErrorSequence = (Library.CallbackErrorSequence or 0) + 1
        Library.LastCallbackError = tostring(Error)
        warn(debug.traceback(tostring(Error), 2))
        if Library.NotifyOnError and not Library.Unloaded then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function Library:MakeDraggable(UI, DragFrame, IgnoreToggled, IsMainWindow)
    DragFrame.Active = true
    Library.InteractiveObjects[DragFrame] = true
    local Dead = false
    local Begin = DragFrame.InputBegan:Connect(function(Input)
        if Dead or not IsClickInput(Input) or not IgnoreToggled and not Library.Toggled
            or IsMainWindow and Library.CantDragForced or UserInputService:GetFocusedTextBox() then return end
        local Start, Position = Input.Position, UI.Position
        local Moved = false
        Library:BeginPointerDrag(DragFrame, Input, function(Point)
            if not IgnoreToggled and not Library.Toggled or IsMainWindow and Library.CantDragForced then Library:StopPointerDrag("blocked"); return end
            local Delta = Point - Start
            if not Moved and Delta.Magnitude < 7 then return end
            Moved = true
            UI:SetAttribute("ChiyoDraggedAt", os.clock())
            UI.Position = UDim2.new(Position.X.Scale, math.floor(Position.X.Offset + Delta.X + 0.5), Position.Y.Scale, math.floor(Position.Y.Offset + Delta.Y + 0.5))
            if UI == Library.LayoutMain then Library:SetSnapGuides(UI, true) end
        end, function()
            if UI.Parent and Moved then Library:SnapFrame(UI, UI ~= Library.LayoutMain) end
            if UI == Library.LayoutMain then Library:SetSnapGuides(nil, false); if Moved then Library:LayoutChanged() end end
        end)
    end)
    local function Cleanup()
        if Dead then return end
        Dead = true; Begin:Disconnect(); Library.InteractiveObjects[DragFrame] = nil
        if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == DragFrame then Library:StopPointerDrag("destroy") end
    end
    UI.Destroying:Once(Cleanup)
    return Cleanup
end

function Library:MakeResizable(UI, DragFrame, Callback)
    local Begin = DragFrame.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) or UserInputService:GetFocusedTextBox() then return end
        local Start, Size = Input.Position, UI.Size
        Library:BeginPointerDrag(DragFrame, Input, function(Point)
            local Delta = Point - Start
            local Origin, View = Library:GetUsableRect()
            local P = UI.AbsolutePosition - ScreenGui.AbsolutePosition
            local MaxX, MaxY = math.max(1, Origin.X + View.X - P.X), math.max(1, Origin.Y + View.Y - P.Y)
            local MinX, MinY = math.min(336, MaxX), math.min(240, MaxY)
            UI.Size = UDim2.fromOffset(math.floor(math.clamp(Size.X.Offset + Delta.X, MinX, MaxX)), math.floor(math.clamp(Size.Y.Offset + Delta.Y, MinY, MaxY)))
            if Callback then Library:SafeCallback(Callback) end
        end, function() if UI.Parent then Library:SnapFrame(UI, true); Library:LayoutChanged() end end)
    end)
    local function Cleanup()
        Begin:Disconnect()
        if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == DragFrame then Library:StopPointerDrag("destroy") end
    end
    UI.Destroying:Once(Cleanup)
    return Cleanup
end



-- Layout coordinates are JSON-safe and remain backward compatible with version 1.
local function PackUDim2(Value)
    return { xs = Value.X.Scale, xo = Value.X.Offset, ys = Value.Y.Scale, yo = Value.Y.Offset }
end
local function ValidUDim2(Value)
    if typeof(Value) ~= "table" then return false end
    for _, Key in { "xs", "xo", "ys", "yo" } do
        if not IsFinite(Value[Key]) or math.abs(Value[Key]) > 1000000 then return false end
    end
    return true
end
local function UnpackUDim2(Value)
    if not ValidUDim2(Value) then return nil end
    return UDim2.new(Value.xs, Value.xo, Value.ys, Value.yo)
end
Library.OnLayoutChanged = nil
Library.LayoutRestoring = false

function Library:SnapFrame(Frame, ClampOnly)
    if not Frame or not Frame.Parent then return end
    local View = ScreenGui.AbsoluteSize
    local Scale = Library.DPIScale
    if View.X <= 0 or View.Y <= 0 then return end
    local Margin, Distance = 8, 28
    local MaxWidth, MaxHeight = math.max(1, View.X - Margin * 2), math.max(1, View.Y - Margin * 2)
    if Frame.AbsoluteSize.X > MaxWidth or Frame.AbsoluteSize.Y > MaxHeight then
        Frame.Size = UDim2.fromOffset(math.min(Frame.AbsoluteSize.X, MaxWidth) / Scale, math.min(Frame.AbsoluteSize.Y, MaxHeight) / Scale)
    end
    local Size = Vector2.new(math.min(Frame.AbsoluteSize.X, MaxWidth), math.min(Frame.AbsoluteSize.Y, MaxHeight))
    local Origin = ScreenGui.AbsolutePosition
    local Position = Frame.AbsolutePosition - Origin
    local TargetsX = { Margin, math.max(Margin, (View.X - Size.X) / 2), math.max(Margin, View.X - Size.X - Margin) }
    local TargetsY = { Margin, math.max(Margin, (View.Y - Size.Y) / 2), math.max(Margin, View.Y - Size.Y - Margin) }
    local function Closest(Value, Targets)
        local Best, Delta = math.clamp(Value, Targets[1], Targets[3]), Distance + 1
        for _, Target in ClampOnly and {} or Targets do
            local Gap = math.abs(Value - Target)
            if Gap <= Distance and Gap < Delta then Best, Delta = Target, Gap end
        end
        return Best
    end
    local X, Y = Closest(Position.X, TargetsX), Closest(Position.Y, TargetsY)
    -- Frame.Position offsets are parent-space pixels; its own UIScale scales size, not Position.
    Frame.Position = UDim2.new(Frame.Position.X.Scale, math.floor(Frame.Position.X.Offset + X - Position.X + 0.5), Frame.Position.Y.Scale, math.floor(Frame.Position.Y.Offset + Y - Position.Y + 0.5))
end

function Library:SetSnapGuides(Frame, Visible)
    if Library.Unloaded then return end
    if not Library.SnapGuideX and not Visible then return end
    if not Library.SnapGuideX then
        Library.SnapGuideX = New("Frame", { BackgroundColor3 = "AccentColor", BackgroundTransparency = 0.55, Size = UDim2.new(0, 1, 1, 0), Visible = false, ZIndex = 999, Parent = ScreenGui })
        Library.SnapGuideY = New("Frame", { BackgroundColor3 = "AccentColor", BackgroundTransparency = 0.55, Size = UDim2.new(1, 0, 0, 1), Visible = false, ZIndex = 999, Parent = ScreenGui })
    end
    Library.SnapGuideX.Visible = Visible == true
    Library.SnapGuideY.Visible = Visible == true
    if Visible and Frame then
        local Position, Size = Frame.AbsolutePosition - ScreenGui.AbsolutePosition, Frame.AbsoluteSize
        Library.SnapGuideX.Position = UDim2.fromOffset(math.floor(Position.X + Size.X / 2), 0)
        Library.SnapGuideY.Position = UDim2.fromOffset(0, math.floor(Position.Y + Size.Y / 2))
    end
end

function Library:LayoutChanged()
    if not Library.LayoutRestoring and not Library.Unloaded then Library:SafeCallback(Library.OnLayoutChanged, Library:GetLayout()) end
end
function Library:GetLayout()
    local Data = { Version = 1, Main = {} }
    if Library.LayoutMain then
        Data.Main.Position = PackUDim2(Library.LayoutMain.Position)
        Data.Main.Size = PackUDim2(Library.LayoutMain.Size)
    end
    return Data
end
function Library:ValidateLayout(Data)
    if typeof(Data) ~= "table" or (Data.Version ~= nil and Data.Version ~= 1) then return false, "unsupported layout" end
    if Data.Main ~= nil then
        if typeof(Data.Main) ~= "table" then return false, "invalid main layout" end
        if Data.Main.Position ~= nil and not ValidUDim2(Data.Main.Position) then return false, "invalid layout position" end
        if Data.Main.Size ~= nil then
            if not ValidUDim2(Data.Main.Size) or Data.Main.Size.xs < 0 or Data.Main.Size.ys < 0 or Data.Main.Size.xo <= 0 or Data.Main.Size.yo <= 0 then
                return false, "invalid layout size"
            end
        end
    end
    return true
end
function Library:SetLayout(Data)
    if (Library.FeatureLoadDepth or 0) > 0 then return true, "feature profiles do not restore UI layout" end
    local Valid, Error = Library:ValidateLayout(Data)
    if not Valid then return false, Error end
    local Previous = Library.LayoutRestoring
    Library.LayoutRestoring = true
    local Ok, Err = pcall(function()
        local Main = Data.Main
        if Library.LayoutMain and Main then
            if Main.Size then Library.LayoutMain.Size = UnpackUDim2(Main.Size) end
            if Main.Position then Library.LayoutMain.Position = UnpackUDim2(Main.Position) end
            Library:SnapFrame(Library.LayoutMain, true)
            if Library.Window then Library.Window:ApplyLayout() end
        end
    end)
    Library.LayoutRestoring = Previous
    if not Ok then return false, tostring(Err) end
    return true
end
function Library:ResetLayout()
    if (Library.FeatureLoadDepth or 0) > 0 then return false end
    Library.LayoutRestoring = true
    if Library.LayoutMain and Library.LayoutDefault then
        Library.LayoutMain.Position = Library.LayoutDefault.Position
        Library.LayoutMain.Size = Library.LayoutDefault.Size
        Library:SnapFrame(Library.LayoutMain)
        if Library.Window then Library.Window:ApplyLayout() end
    end
    Library.LayoutRestoring = false
    Library:LayoutChanged()
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local Border = New("UIStroke", { Color = "OutlineColor", Thickness = 1, Transparency = 0.15, Parent = Frame })
    local Ambient = New("UIStroke", { Color = "DarkColor", Thickness = 3, Transparency = 0.94, Parent = Frame })
    return Border, Ambient
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

-- This is used only by explicitly requested AddPlayerInfo components.
function Library:CreatePlayerCard(Parent, Info, Changed)
    Info = typeof(Info) == "table" and Info or {}
    local Player = Info.Player or LocalPlayer
    local UserId = Info.UserId or (typeof(Player) == "Instance" and Player:IsA("Player") and Player.UserId) or LocalPlayer.UserId
    local Minimum = tonumber(Info.Height) or (Info.Compact and 46 or 68)
    local Holder = New("Frame", { Name = "RequestedPlayerInformation", BackgroundColor3 = "NavigationColor", Size = UDim2.new(1, 0, 0, Minimum), Visible = Info.Visible ~= false, Parent = Parent })
    Library:Surface(Holder, "Panel")
    local Avatar = New("ImageLabel", { BackgroundColor3 = "FieldColor", Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(48, 48), Parent = Holder })
    if Info.RoundAvatar ~= false then
        local Circle = Instance.new("UICorner"); Circle.CornerRadius = UDim.new(1, 0); Circle.Parent = Avatar
    end
    local Missing = New("TextLabel", { BackgroundTransparency = 1, Text = "No image", RichText = false, TextSize = 14, TextWrapped = true, Size = UDim2.fromScale(1, 1), Parent = Avatar })
    local Title = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Title or (typeof(Player) == "Instance" and Player.DisplayName or tostring(UserId))), FontFace = "FontBold", TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
    local Description = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Description or ""), TextColor3 = "MutedColor", TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
    local Card = { Type = "PlayerInfo", Holder = Holder, Avatar = Avatar, Title = Title, Description = Description, Text = Title.Text, Visible = Holder.Visible }
    local Fitting = false
    local function Fit()
        if Fitting or Card.Destroyed or not Holder.Parent or Library.Unloaded then return end
        Fitting = true
        local ImageSize = (Info.Compact and 32 or 48) + Library.TextSizeOffset * 2
        local W = math.max(60, Holder.AbsoluteSize.X - ImageSize - 28)
        local _, TH = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, W, false)
        local DH = 0
        if Description.Text ~= "" then local _, H = Library:GetTextBounds(Description.Text, Description.FontFace, Description.TextSize, W, false); DH = H + 4 end
        local Height = math.max(Minimum, ImageSize + 16, TH + DH + 16)
        Avatar.Size = UDim2.fromOffset(ImageSize, ImageSize)
        Title.Position, Title.Size = UDim2.fromOffset(ImageSize + 18, 8), UDim2.fromOffset(W, TH)
        Description.Position, Description.Size, Description.Visible = UDim2.fromOffset(ImageSize + 18, TH + 12), UDim2.fromOffset(W, math.max(1, DH - 4)), DH > 0
        Holder.Size = UDim2.new(1, 0, 0, Height)
        Fitting = false
        if Changed then Changed(Card.Visible and Height or 0) end
    end
    function Card:SetText(Text) Card.Text, Title.Text = tostring(Text or ""), tostring(Text or ""); Fit() end
    function Card:SetDescription(Text) Description.Text = tostring(Text or ""); Fit() end
    function Card:SetVisible(Visible) Card.Visible, Holder.Visible = Visible ~= false, Visible ~= false; Fit() end
    function Card:Destroy()
        if Card.Destroyed then return end
        Library:DestroyElement(Card); if Changed then Changed(0) end
    end
    
    Library.TextReflows[Holder] = Fit
    Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
    Library:DeferOwned(Holder, nil, function()
        local Ok, Image, Ready = pcall(Players.GetUserThumbnailAsync, Players, UserId, Info.ThumbnailType or Enum.ThumbnailType.HeadShot, Info.ThumbnailSize or Enum.ThumbnailSize.Size100x100)
        if Ok and Ready and not Card.Destroyed and Holder.Parent then Avatar.Image = Image end
    end)
    Avatar:GetPropertyChangedSignal("IsLoaded"):Connect(function() Missing.Visible = not Avatar.IsLoaded end)
    Fit(); return Card
end


function Library:AddDraggableLabel(Text: string)
    local Table = {}

    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )
    Library:AddOutline(Label)

    Library:MakeDraggable(Label, Label, true)

    Table.Label = Label

    function Table:SetText(Text: string)
        Label.Text = Text
    end

    function Table:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end

    function Table:Destroy()
        Label:Destroy()
    end

    return Table
end

function Library:AddDraggableButton(Text, Func, ExcludeScaling, ExcludeDragging)
    local Object = {}
    local Button = New("TextButton", { Name = "FloatingAction", BackgroundColor3 = "HeaderColor", Position = UDim2.fromOffset(12, 12), Text = tostring(Text or ""), TextSize = 15, RichText = false, ZIndex = 90, Parent = ScreenGui })
    Library:StyleAction(Button, "Secondary", false, false)
    local Moved, Pointer, Origin, LastPointer = false, nil, nil, nil
    Button.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) or not Library:CanInteract(Button, Input) then return end
        Moved, Pointer, LastPointer, Origin = false, Input, Input, Input.Position
    end)
    if not ExcludeDragging then Object.DragCleanup = Library:MakeDraggable(Button, Button, true) end
    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input)
        if not Pointer or ExcludeDragging then return end
        if Input == Pointer or Pointer.UserInputType ~= Enum.UserInputType.Touch and Input.UserInputType == Enum.UserInputType.MouseMovement then
            if (Input.Position - Origin).Magnitude > 7 then Moved = true end
        end
    end), Button)
    Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input) if Input == Pointer or Pointer and Input.UserInputType == Pointer.UserInputType then Pointer = nil end end), Button)
    Button.Activated:Connect(function(Input)
        if not Library:CanInteract(Button, Input) then return end
        if Input and Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then Moved = false end
        if Moved then Moved = false; return end
        Library:SafeCallback(Func, Object)
    end)
    Object.Button = Button
    function Object:SetText(Value)
        Button.Text = tostring(Value or "")
        local W, H = Library:GetTextBounds(Button.Text, Button.FontFace, Button.TextSize, math.max(80, ScreenGui.AbsoluteSize.X - 40), false)
        Button.TextWrapped = true
        Button.Size = UDim2.fromOffset(math.max(Library:Metrics().Target, W + 24), math.max(Library:Metrics().Target, H + 14))
    end
    function Object:SetVisible(Value) Button.Visible = Value == true end
    function Object:Destroy() if Object.DragCleanup then Object.DragCleanup(); Object.DragCleanup = nil end; Button:Destroy() end
    Library.TextReflows[Button] = function() Object:SetText(Button.Text) end
    Object:SetText(Text)
    return Object
end

function Library:AddDraggableMenu(Name)
    local Holder = New("Frame", { Name = "FloatingUtility", BackgroundColor3 = "MainColor", Position = UDim2.fromOffset(12, 64), Size = UDim2.fromOffset(300, 48), ZIndex = 90, Parent = ScreenGui })
    Library:Surface(Holder, "Panel")
    local Header = New("TextLabel", { BackgroundColor3 = "HeaderColor", Text = tostring(Name or ""), RichText = false, FontFace = "FontBold", TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0, 36), Parent = Holder })
    New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Header })
    local Container = New("ScrollingFrame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 44), Size = UDim2.new(1, -16, 0, 0), CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 4, ScrollBarImageColor3 = "OutlineColor", Parent = Holder })
    local Layout = New("UIListLayout", { Padding = UDim.new(0, 6), Parent = Container })
    local Fitting = false
    local function Fit()
        if Fitting or not Holder.Parent or Library.Unloaded then return end
        Fitting = true
        local _, View = Library:GetUsableRect()
        local Width = math.min(420, math.max(180, View.X - 16))
        local _, H = Library:GetTextBounds(Header.Text, Header.FontFace, Header.TextSize, Width - 20, false)
        local HH = math.max(Library:Metrics().Target, H + 12)
        local Height = math.ceil(Layout.AbsoluteContentSize.Y)
        Header.Size = UDim2.new(1, 0, 0, HH)
        local VisibleHeight = math.min(Height, math.max(24, View.Y - HH - 16))
        Container.Position, Container.Size = UDim2.fromOffset(8, HH + 8), UDim2.new(1, -16, 0, VisibleHeight)
        Container.CanvasSize = UDim2.fromOffset(0, Height)
        Container.ScrollBarThickness = Height > VisibleHeight and 4 or 0
        Holder.Size = UDim2.fromOffset(Width, HH + VisibleHeight + 16)
        Fitting = false
    end
    Library:MakeDraggable(Holder, Header, true)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Fit)
    Library.TextReflows[Holder] = Fit
    Holder:GetPropertyChangedSignal("Visible"):Connect(function() if Holder.Visible then Fit(); Library:SnapFrame(Holder, true) end end)
    Fit()
    return Holder, Container
end

-- Optional segmented watermark. Static or hidden watermarks have no refresh timer.
function Library:AddWatermark(Info)
    local Segments = typeof(Info) == "table" and (Info.Segments or (Info.Text ~= nil and { Info } or Info)) or { { Text = tostring(Info or "") } }
    local Holder = New("Frame", { Name = "RequestedWatermark", BackgroundColor3 = "HeaderColor", Position = typeof(Info) == "table" and Info.Position or UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(160, 34), ZIndex = 90, Parent = ScreenGui })
    Library:Surface(Holder, "Panel")
    local Scroll = New("ScrollingFrame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 3), Size = UDim2.new(1, -16, 1, -6), CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2, ScrollBarImageColor3 = "OutlineColor", Parent = Holder })
    local Watermark = { Holder = Holder, Cells = {}, Destroyed = false, RefreshTask = nil, DragCleanup = nil }
    Watermark.DragCleanup = Library:MakeDraggable(Holder, Holder, true)
    local TimerAllowed = not (typeof(Info) == "table" and Info.Refresh == false)
    local Fitting = false
    local function Fit()
        if Fitting or Watermark.Destroyed or not Holder.Parent or Library.Unloaded then return end
        Fitting = true
        local X, Height = 0, 26
        for _, Cell in Watermark.Cells do
            local W, H = Library:GetTextBounds(Cell.Label.Text, Cell.Label.FontFace, Cell.Label.TextSize, 0, false)
            local ImageWidth = Cell.Avatar and Library:Metrics().Icon + 8 or 0
            Cell.Frame.Position, Cell.Frame.Size = UDim2.fromOffset(X, 0), UDim2.fromOffset(W + ImageWidth + 16, H + 10)
            Cell.Label.Position, Cell.Label.Size = UDim2.fromOffset(ImageWidth + 8, 0), UDim2.fromOffset(W + 2, H + 10)
            if Cell.Avatar then Cell.Avatar.Size = UDim2.fromOffset(Library:Metrics().Icon, Library:Metrics().Icon); Cell.Avatar.Position = UDim2.new(0, 6, 0.5, -Library:Metrics().Icon / 2) end
            Height = math.max(Height, H + 10); X += W + ImageWidth + 17
        end
        local _, View = Library:GetUsableRect()
        Holder.Size = UDim2.fromOffset(math.min(math.max(36, X + 16), View.X), Height + 6)
        Scroll.CanvasSize = UDim2.fromOffset(X, 0)
        Fitting = false
    end
    local function Schedule()
        Library:CancelTask(Watermark.RefreshTask); Watermark.RefreshTask = nil
        if not TimerAllowed or Watermark.Destroyed or not Holder.Visible or Library.Unloaded then return end
        local HasGetter = false
        for _, Cell in Watermark.Cells do if Cell.Getter then HasGetter = true; break end end
        if not HasGetter then return end
        Watermark.RefreshTask = Library:DeferOwned(Holder, 1, function()
            Watermark.RefreshTask = nil
            if Watermark.Destroyed or not Holder.Visible then return end
            for _, Cell in Watermark.Cells do
                if Cell.Getter then
                    local Ok, Value = pcall(Cell.Getter)
                    if Ok and not Watermark.Destroyed and Cell.Label.Parent then Cell.Label.Text = tostring(Value or "") end
                end
            end
            Fit(); Schedule()
        end)
    end
    function Watermark:SetSegments(Value)
        if Watermark.Destroyed then return end
        for _, Cell in Watermark.Cells do Cell.Frame:Destroy() end
        table.clear(Watermark.Cells)
        Segments = Value or {}
        for Index, Original in Segments do
            local Segment = typeof(Original) == "table" and Original or { Text = Original }
            local Cell = { Frame = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 30), Parent = Scroll }) }
            if Index > 1 then New("Frame", { BackgroundColor3 = "OutlineColor", Position = UDim2.fromOffset(0, 6), Size = UDim2.new(0, 1, 1, -12), Parent = Cell.Frame }) end
            local P = Segment.Player
            local UserId = typeof(P) == "Instance" and P:IsA("Player") and P.UserId or typeof(P) == "number" and P or Segment.PlayerCard and LocalPlayer.UserId
            if UserId then Cell.Avatar = New("ImageLabel", { BackgroundTransparency = 1, Image = "rbxthumb://type=AvatarBust&id=" .. tostring(UserId) .. "&w=48&h=48", Size = UDim2.fromOffset(18, 18), Parent = Cell.Frame }) end
            Cell.Getter = typeof(Segment.Text) == "function" and Segment.Text or nil
            local Text = Cell.Getter and "" or Segment.Text
            if Text == nil and UserId then Text = typeof(P) == "Instance" and P:IsA("Player") and P.DisplayName or LocalPlayer.DisplayName end
            Cell.Label = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Text or ""), RichText = false, TextColor3 = Segment.Accent and "AccentColor" or "FontColor", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.fromOffset(0, 30), Parent = Cell.Frame })
            Watermark.Cells[Index] = Cell
        end
        Fit(); Schedule()
    end
    function Watermark:SetText(Index, Text)
        if typeof(Index) ~= "number" then Text, Index = Index, 1 end
        local Cell = Watermark.Cells[Index]
        if Cell then Cell.Getter = nil; Cell.Label.Text = tostring(Text or ""); Fit(); Schedule() end
    end
    function Watermark:SetSegment(Index, Segment) Segments[Index] = Segment; Watermark:SetSegments(Segments) end
    function Watermark:SetVisible(Value) Holder.Visible = Value ~= false; Schedule() end
    function Watermark:Destroy()
        if Watermark.Destroyed then return end
        Watermark.Destroyed = true
        Library:CancelTask(Watermark.RefreshTask); Watermark.RefreshTask = nil
        if Watermark.DragCleanup then Watermark.DragCleanup(); Watermark.DragCleanup = nil end
        Holder:Destroy()
    end
    Holder.Destroying:Once(function() Watermark.Destroyed = true; Library:CancelTask(Watermark.RefreshTask); Watermark.RefreshTask = nil end)
    Holder:GetPropertyChangedSignal("Visible"):Connect(Schedule)
    Library.TextReflows[Holder] = Fit
    Watermark:SetSegments(Segments)
    return Watermark
end


--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

-- Input ownership, attached surfaces and contextual help share a single lifecycle.
local CurrentMenu
local CurrentHoverInstance
Library.ConsumedInputs = setmetatable({}, { __mode = "k" })
Library.DismissedInputs = setmetatable({}, { __mode = "k" })
Library.UIInputs = setmetatable({}, { __mode = "k" })
Library.CaptureInputs = setmetatable({}, { __mode = "k" })
Library.HandledInputs = setmetatable({}, { __mode = "k" })
Library.FocusScopes = {}
Library.TooltipOwners = setmetatable({}, { __mode = "k" })

function Library:ReleaseSignal(Connection)
    if not Connection then return end
    Connection:Disconnect()
    local Index = table.find(Library.Signals, Connection)
    if Index then table.remove(Library.Signals, Index) end
end
function Library:IsObjectVisible(Object)
    if not Object or not Object.Parent then return false end
    local Node = Object
    while Node and Node ~= ScreenGui do
        if Node:IsA("GuiObject") and not Node.Visible then return false end
        Node = Node.Parent
    end
    return Node == ScreenGui and ScreenGui.Enabled
end
function Library:PointIsVisible(Object, Point)
    if not Library:IsObjectVisible(Object) or not Library:MouseIsOverFrame(Object, Point) then return false end
    local Parent = Object.Parent
    while Parent and Parent ~= ScreenGui do
        if Parent:IsA("GuiObject") and Parent.ClipsDescendants and not Library:MouseIsOverFrame(Parent, Point) then return false end
        Parent = Parent.Parent
    end
    return true
end
function Library:IsLibraryPoint(Point)
    if Library.LayoutMain and Library:PointIsVisible(Library.LayoutMain, Point) then return true end
    for Object in Library.InteractiveObjects do
        if Object.Parent and Library:PointIsVisible(Object, Point) then return true end
    end
    return false
end
function Library:GetUsableRect(WithinWindow)
    local Origin, Size = ScreenGui.AbsolutePosition, ScreenGui.AbsoluteSize
    local X, Y, W, H = 8, 8, math.max(1, Size.X - 16), math.max(1, Size.Y - 16)
    local Ok, Visible, Position, KeyboardSize = pcall(function()
        return UserInputService.OnScreenKeyboardVisible, UserInputService.OnScreenKeyboardPosition, UserInputService.OnScreenKeyboardSize
    end)
    if Ok and Visible and Position and KeyboardSize and KeyboardSize.Y > 0 and Position.Y > Origin.Y then
        H = math.max(1, math.min(H, Position.Y - Origin.Y - Y - 8))
    end
    if WithinWindow and Library.LayoutMain then
        local P, S = Library.LayoutMain.AbsolutePosition - Origin, Library.LayoutMain.AbsoluteSize
        local Right, Bottom = math.min(X + W, P.X + S.X), math.min(Y + H, P.Y + S.Y)
        X, Y = math.max(X, P.X), math.max(Y, P.Y)
        W, H = math.max(1, Right - X), math.max(1, Bottom - Y)
    end
    return Vector2.new(X, Y), Vector2.new(W, H)
end
function Library:IsInputOwned(Input)
    return Input and (Library.ConsumedInputs[Input] or Library.DismissedInputs[Input] or Library.UIInputs[Input] or Library.CaptureInputs[Input]) or false
end
function Library:CanInteract(Object, Input)
    if Library.Unloaded or not Library:IsObjectVisible(Object) or (Input and Library.DismissedInputs[Input]) then return false end
    if Library.HelpMode then return false end
    if Library.PickingKeybind and Object ~= Library.PickingKeybind.Picker then return false end
    local Scope = Library.FocusScopes[#Library.FocusScopes]
    if Scope and Scope.Frame.Parent and Scope.Frame.Visible then
        local IsMenu = CurrentMenu and Object:IsDescendantOf(CurrentMenu.Menu) and CurrentMenu.Holder:IsDescendantOf(Scope.Frame)
        if Object ~= Scope.Frame and not Object:IsDescendantOf(Scope.Frame) and not IsMenu then return false end
    end
    if CurrentMenu and Object ~= CurrentMenu.Holder and not Object:IsDescendantOf(CurrentMenu.Holder) and not Object:IsDescendantOf(CurrentMenu.Menu)
        and not (CurrentMenu.RelatedHolder and (Object == CurrentMenu.RelatedHolder or Object:IsDescendantOf(CurrentMenu.RelatedHolder))) then return false end
    return true
end
-- Pointer capture is event-driven and temporary. Resizing never reconstructs controls.
function Library:StopPointerDrag(Reason)
    local Drag = Library.ActivePointerDrag
    if not Drag then return end
    Library.ActivePointerDrag = nil
    for _, Connection in Drag.Connections do Connection:Disconnect() end
    table.clear(Drag.Connections)
    for Frame, Enabled in Drag.Scrolling do if Frame.Parent then Frame.ScrollingEnabled = Enabled end end
    if Drag.Finish then Library:SafeCallback(Drag.Finish, Reason or "end") end
end
function Library:BeginPointerDrag(Owner, Input, Update, Finish, Sides, AllowSecondary)
    if not IsClickInput(Input, AllowSecondary) or not Library:CanInteract(Owner, Input) then return false end
    Library:StopPointerDrag("replaced")
    local Drag = { Owner = Owner, Input = Input, Update = Update, Finish = Finish, Connections = {}, Scrolling = {} }
    Library.ActivePointerDrag = Drag
    local function Suspend(Frame)
        if Frame:IsA("ScrollingFrame") and Drag.Scrolling[Frame] == nil then Drag.Scrolling[Frame] = Frame.ScrollingEnabled; Frame.ScrollingEnabled = false end
    end
    local Ancestor = Owner.Parent
    while Ancestor and Ancestor ~= ScreenGui do Suspend(Ancestor); Ancestor = Ancestor.Parent end
    for _, Frame in Sides or {} do Suspend(Frame) end
    local function Move(Point)
        if Library.ActivePointerDrag ~= Drag then return end
        if Library.Unloaded or not Library:IsObjectVisible(Owner) or not Library.IsRobloxFocused then Library:StopPointerDrag("unavailable"); return end
        local Ok, Error = pcall(Update, Point)
        if not Ok then Library:StopPointerDrag("error"); warn("Chiyo pointer input: " .. tostring(Error)) end
    end
    table.insert(Drag.Connections, UserInputService.InputChanged:Connect(function(Change)
        if Input.UserInputType == Enum.UserInputType.Touch then
            if Change == Input then Move(Change.Position) end
        elseif Change.UserInputType == Enum.UserInputType.MouseMovement then Move(Change.Position) end
    end))
    table.insert(Drag.Connections, UserInputService.InputEnded:Connect(function(Ended)
        if Ended == Input or Input.UserInputType ~= Enum.UserInputType.Touch and Ended.UserInputType == Input.UserInputType then Library:StopPointerDrag("end") end
    end))
    table.insert(Drag.Connections, Owner.Destroying:Connect(function() Library:StopPointerDrag("destroy") end))
    Move(Input.Position)
    return true
end

function Library:GetFocusable(Frame)
    local Result = {}
    if not Frame or not Frame.Parent then return Result end
    for _, Object in Frame:GetDescendants() do
        if Object:IsA("GuiObject") and Object.Selectable and Object.Active and Library:IsObjectVisible(Object)
            and (Object:IsA("GuiButton") or Object:IsA("TextBox")) and Object:GetAttribute("ChiyoDecorative") ~= true then
            table.insert(Result, Object)
        end
    end
    table.sort(Result, function(A, B)
        local AY, BY = math.floor(A.AbsolutePosition.Y), math.floor(B.AbsolutePosition.Y)
        if AY ~= BY then return AY < BY end
        if A.AbsolutePosition.X ~= B.AbsolutePosition.X then return A.AbsolutePosition.X < B.AbsolutePosition.X end
        return A.LayoutOrder < B.LayoutOrder
    end)
    return Result
end
function Library:PushFocusScope(Owner, Frame, Initial)
    Library:PopFocusScope(Owner, false)
    local Focus = UserInputService:GetFocusedTextBox()
    if Focus and not Focus:IsDescendantOf(Frame) then Focus:ReleaseFocus() end
    table.insert(Library.FocusScopes, { Owner = Owner, Frame = Frame, Previous = GuiService.SelectedObject })
    if Initial and Initial.Parent then GuiService.SelectedObject = Initial
    else GuiService.SelectedObject = Library:GetFocusable(Frame)[1] end
end
function Library:PopFocusScope(Owner, Restore)
    for Index = #Library.FocusScopes, 1, -1 do
        local Scope = Library.FocusScopes[Index]
        if Scope.Owner == Owner then
            local WasTop = Index == #Library.FocusScopes
            table.remove(Library.FocusScopes, Index)
            local Focus = UserInputService:GetFocusedTextBox()
            if Focus and Focus:IsDescendantOf(Scope.Frame) then Focus:ReleaseFocus() end
            if WasTop and Restore ~= false and not Library.Unloaded then
                local Previous = Scope.Previous
                if Previous and Library:IsObjectVisible(Previous) then GuiService.SelectedObject = Previous
                else
                    local Top = Library.FocusScopes[#Library.FocusScopes]
                    GuiService.SelectedObject = Top and Library:GetFocusable(Top.Frame)[1] or nil
                end
            end
            return
        end
    end
end
function Library:CycleFocus(Direction)
    local Scope = Library.FocusScopes[#Library.FocusScopes]
    if not Scope then return false end
    local List = Library:GetFocusable(CurrentMenu and CurrentMenu.Menu or Scope.Frame)
    if #List == 0 then return false end
    local Current = UserInputService:GetFocusedTextBox() or GuiService.SelectedObject
    local Index = table.find(List, Current) or (Direction == 1 and 0 or 1)
    local Next = List[(Index - 1 + Direction) % #List + 1]
    if Current and Current:IsA("TextBox") and Current ~= Next then Current:ReleaseFocus() end
    GuiService.SelectedObject = Next
    if Next:IsA("TextBox") then Next:CaptureFocus() end
    return true
end
local Refocusing = false
Library:GiveSignal(GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
    if Refocusing or Library.Unloaded then return end
    local Scope = Library.FocusScopes[#Library.FocusScopes]
    local Selected = GuiService.SelectedObject
    if Scope and Scope.Frame.Parent and Scope.Frame.Visible and Selected and not Selected:IsDescendantOf(Scope.Frame)
        and not (CurrentMenu and Selected:IsDescendantOf(CurrentMenu.Menu)) then
        Refocusing = true
        GuiService.SelectedObject = Library:GetFocusable(Scope.Frame)[1]
        Refocusing = false
    end
end), ScreenGui)

function Library:AddContextMenu(Holder, Size, Offset, List, ActiveCallback, MenuZIndex)
    local Z = MenuZIndex or 2000
    local Menu = New(List and "ScrollingFrame" or "Frame", {
        Name = "AttachedMenu", BackgroundColor3 = "MainColor", Size = typeof(Size) == "function" and Size() or Size,
        Visible = false, Active = true, ZIndex = Z, Parent = ScreenGui,
    })
    if List then
        Menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Menu.CanvasSize = UDim2.fromOffset(0, 0)
        Menu.ScrollingDirection = Enum.ScrollingDirection.Y
        Menu.ScrollBarThickness = 4
        Menu.ScrollBarImageColor3 = Library.Scheme.OutlineColor
    end
    table.insert(Library.Scales, New("UIScale", { Parent = Menu }))
    Library:Surface(Menu, "Panel")
    local Shield = New("TextButton", { Name = "MenuDismissArea", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Selectable = false, Visible = false, ZIndex = Z - 1, Parent = ScreenGui })
    Shield:SetAttribute("ChiyoDecorative", true)
    local Result = { Holder = Holder, Menu = Menu, Shield = Shield, Size = Size, Active = false, Signals = {}, List = nil }
    if List then Result.List = New("UIListLayout", { Parent = Menu }) end
    local Positioning = false
    local function PositionMenu(Animate)
        if Positioning or not Result.Active or not Holder.Parent or not Menu.Parent then return end
        Positioning = true
        local Origin, View = Library:GetUsableRect()
        local Scale = Library.DPIScale
        local Requested = typeof(Result.Size) == "function" and Result.Size() or Result.Size
        local Width = math.clamp(Requested.X.Scale * View.X / Scale + Requested.X.Offset, 40, math.max(40, View.X / Scale))
        local Height = Requested.Y.Scale * View.Y / Scale + Requested.Y.Offset
        if List == 1 then
            local Padding = Menu:FindFirstChildOfClass("UIPadding")
            Height = math.max(Height, Result.List.AbsoluteContentSize.Y / Scale + (Padding and Padding.PaddingTop.Offset + Padding.PaddingBottom.Offset or 0))
        end
        Height = math.clamp(Height, 1, math.max(1, View.Y / Scale))
        Menu.Size = UDim2.fromOffset(math.floor(Width), math.floor(Height))
        local Delta = typeof(Offset) == "function" and Offset() or Offset or { 0, Holder.AbsoluteSize.Y + 4 }
        local P = Holder.AbsolutePosition - ScreenGui.AbsolutePosition
        local X = math.clamp(P.X + (Delta[1] or 0), Origin.X, math.max(Origin.X, Origin.X + View.X - Width * Scale))
        local Y = P.Y + (Delta[2] or 0)
        if Y + Height * Scale > Origin.Y + View.Y then Y = P.Y - Height * Scale - 4 end
        Y = math.clamp(Y, Origin.Y, math.max(Origin.Y, Origin.Y + View.Y - Height * Scale))
        local Target = UDim2.fromOffset(math.floor(X), math.floor(Y))
        Library:CancelMotion(Menu)
        if Animate and not Library:IsReducedMotion() then
            Menu.Position = Target + UDim2.fromOffset(0, Y >= P.Y and -5 or 5)
            Library:CreateTween(Menu, TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = Target }):Play()
        else Menu.Position = Target end
        Positioning = false
    end
    function Result:Open()
        if Result.Destroyed or Library.Unloaded then return false end
        if Result.Active then return true end
        if CurrentMenu then CurrentMenu:Close("other menu") end
        if not Library:CanInteract(Holder) then return false end
        CurrentMenu, Library.CurrentMenu, Result.Active = Result, Result, true
        Menu.Visible, Shield.Visible = true, true
        if typeof(ActiveCallback) == "function" then Library:SafeCallback(ActiveCallback, true) end
        PositionMenu(true)
        Library:PushFocusScope(Result, Menu)
        Library:DeferOwned(Menu, nil, function() PositionMenu(false) end)
        table.insert(Result.Signals, Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() PositionMenu(false) end))
        table.insert(Result.Signals, ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() PositionMenu(false) end))
        for _, Property in { "OnScreenKeyboardVisible", "OnScreenKeyboardPosition", "OnScreenKeyboardSize" } do
            pcall(function() table.insert(Result.Signals, UserInputService:GetPropertyChangedSignal(Property):Connect(function() PositionMenu(false) end)) end)
        end
        Result.Signal = Result.Signals[1]
        return true
    end
    function Result:Close(Reason)
        if not Result.Active then return false end
        Result.Active = false
        if CurrentMenu == Result then CurrentMenu, Library.CurrentMenu = nil, nil end
        Library:CancelMotion(Menu)
        Menu.Visible, Shield.Visible = false, false
        Library:PopFocusScope(Result)
        local Focus = UserInputService:GetFocusedTextBox()
        if Focus and Focus:IsDescendantOf(Menu) then Focus:ReleaseFocus() end
        for _, Connection in Result.Signals do Connection:Disconnect() end
        table.clear(Result.Signals); Result.Signal = nil
        if typeof(ActiveCallback) == "function" then Library:SafeCallback(ActiveCallback, false) end
        if Result.OnDismiss then Result.OnDismiss(Reason or "close") end
        return true
    end
    function Result:Toggle() if Result.Active then return Result:Close("toggle") end; return Result:Open() end
    function Result:SetSize(Value) Result.Size = Value; if Result.Active then PositionMenu(false) else Menu.Size = typeof(Value) == "function" and Value() or Value end end
    function Result:Reposition() PositionMenu(false) end
    function Result:Destroy()
        if Result.Destroyed then return end
        Result:Close("destroy")
        Result.Destroyed = true
        Menu:Destroy(); Shield:Destroy()
    end
    Shield.Activated:Connect(function(Input)
        if not Result.Active then return end
        local Point = Input and Input.Position
        if Point and Result.TriggerActivate and Result.RelatedHolder and Library:MouseIsOverFrame(Result.RelatedHolder, Point) then
            Result.TriggerActivate(Input); return
        end
        if Point and Library:MouseIsOverFrame(Holder, Point) then Result:Close("toggle"); return end
        if Input then Library.DismissedInputs[Input] = true end
        Result:Close("outside")
    end)
    if Result.List then Result.List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PositionMenu(false) end) end
    Holder.Destroying:Once(function() Result:Destroy() end)
    return Result
end

local TooltipLabel = New("TextLabel", { Name = "ChiyoHelp", BackgroundColor3 = "HeaderColor", TextSize = 15, RichText = true,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
    Visible = false, Active = false, ZIndex = 20000, Parent = ScreenGui })
Library:Surface(TooltipLabel, "Panel")
New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = TooltipLabel })
table.insert(Library.Scales, New("UIScale", { Parent = TooltipLabel }))
function Library:HideTooltip()
    TooltipLabel.Visible = false
    CurrentHoverInstance = nil
    Library.CurrentTooltip = nil
end
function Library:AddTooltip(InfoStr, DisabledInfoStr, HoverInstance)
    local Data = { Disabled = false, Hovering = false, Signals = {}, Info = InfoStr, DisabledInfo = DisabledInfoStr, Owner = HoverInstance, Generation = 0 }
    Library.TooltipOwners[HoverInstance] = Data
    local function Text()
        local Value = Data.Disabled and Data.DisabledInfo or Data.Info
        return typeof(Value) == "string" and Value or ""
    end
    function Data:Hide()
        Data.Generation += 1
        Library:CancelTask(Data.Timer); Data.Timer = nil
        if Library.CurrentTooltip == Data then Library:HideTooltip() end
    end
    function Data:Show(Point)
        if Data.Destroyed or Library.Unloaded or not Library:IsObjectVisible(HoverInstance) or Text() == "" then return false end
        if not Library.HelpMode and not Library:CanInteract(HoverInstance) then return false end
        Library:HideTooltip()
        local Origin, View = Library:GetUsableRect()
        local Width = math.max(50, math.min(360, View.X / Library.DPIScale - 20))
        local X, H = Library:GetTextBounds(Text(), TooltipLabel.FontFace, TooltipLabel.TextSize, Width, true)
        local W = math.min(Width + 20, X + 20)
        H = math.min(H + 16, View.Y / Library.DPIScale)
        TooltipLabel.Text, TooltipLabel.Size = Text(), UDim2.fromOffset(W, H)
        local P = Point or Vector2.new(HoverInstance.AbsolutePosition.X, HoverInstance.AbsolutePosition.Y + HoverInstance.AbsoluteSize.Y)
        P = P - ScreenGui.AbsolutePosition
        local PX = math.clamp(P.X + 8, Origin.X, math.max(Origin.X, Origin.X + View.X - W * Library.DPIScale))
        local PY = P.Y + 8
        if PY + H * Library.DPIScale > Origin.Y + View.Y then PY = HoverInstance.AbsolutePosition.Y - ScreenGui.AbsolutePosition.Y - H * Library.DPIScale - 8 end
        TooltipLabel.Position = UDim2.fromOffset(math.floor(PX), math.floor(math.clamp(PY, Origin.Y, math.max(Origin.Y, Origin.Y + View.Y - H * Library.DPIScale))))
        TooltipLabel.Visible, CurrentHoverInstance, Library.CurrentTooltip = true, HoverInstance, Data
        return true
    end
    local function Schedule(Delay)
        Data:Hide()
        if Text() == "" then return end
        Data.Hovering = true
        local Generation = Data.Generation
        Data.Timer = Library:DeferOwned(HoverInstance, Delay, function()
            Data.Timer = nil
            if Data.Generation == Generation and Data.Hovering then Data:Show() end
        end)
    end
    local function Add(Connection) table.insert(Data.Signals, Connection) end
    do
        Add(HoverInstance.MouseEnter:Connect(function() Schedule(0.45) end))
        Add(HoverInstance.MouseLeave:Connect(function() Data.Hovering = false; Data:Hide() end))
        Add(HoverInstance.SelectionGained:Connect(function() Schedule(0.25) end))
        Add(HoverInstance.SelectionLost:Connect(function() Data.Hovering = false; Data:Hide() end))
    end
    function Data:SetText(Value, DisabledValue) Data.Info = Value; if DisabledValue ~= nil then Data.DisabledInfo = DisabledValue end; Data:Hide() end
    function Data:Destroy()
        if Data.Destroyed then return end
        Data:Hide(); Data.Destroyed = true
        for _, Connection in Data.Signals do Connection:Disconnect() end
        table.clear(Data.Signals)
        if Library.TooltipOwners[HoverInstance] == Data then Library.TooltipOwners[HoverInstance] = nil end
        local At = table.find(Tooltips, Data); if At then table.remove(Tooltips, At) end
    end
    HoverInstance.Destroying:Once(function() Data:Destroy() end)
    table.insert(Tooltips, Data)
    return Data
end

-- This listener is installed before feature keypickers. Ownership survives a menu closing or capture finishing during the same event.
Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, Processed)
    if Library.Unloaded then return end
    if Processed then Library.ConsumedInputs[Input] = true end
    local Picker = Library.PickingKeybind
    if Picker then
        Library.CaptureInputs[Input] = Picker
        Library.ConsumedInputs[Input] = true
        if Picker.HandleCapture then Picker.HandleCapture(Input) end
        return
    end
    if IsMouseInput(Input, true) then
        if Library:IsLibraryPoint(Input.Position) then Library.UIInputs[Input] = true end
        if CurrentMenu then
            Library.UIInputs[Input] = true
            if not Library:MouseIsOverFrame(CurrentMenu.Menu, Input.Position) and not Library:MouseIsOverFrame(CurrentMenu.RelatedHolder or CurrentMenu.Holder, Input.Position) then
                Library.DismissedInputs[Input] = true
                CurrentMenu:Close("outside")
                return
            end
        end
    end
    if UserInputService:GetFocusedTextBox() or Library.HelpMode or #Library.FocusScopes > 0 then Library.ConsumedInputs[Input] = true end
    if CurrentMenu then
        Library.ConsumedInputs[Input] = true
        if CurrentMenu.HandleInput and CurrentMenu:HandleInput(Input) then Library.HandledInputs[Input] = true; return end
        if Input.KeyCode == Enum.KeyCode.Escape then Library.HandledInputs[Input] = true; CurrentMenu:Close("escape"); return end
    end
    if Input.KeyCode == Enum.KeyCode.Tab and #Library.FocusScopes > 0 then
        local Shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        if Library:CycleFocus(Shift and -1 or 1) then Library.ConsumedInputs[Input] = true end
    end
end), ScreenGui)
Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
    local Picker = Library.PickingKeybind
    if Picker then
        Library.CaptureInputs[Input] = Picker
        Library.ConsumedInputs[Input] = true
        if Picker.HandleCaptureEnded then Picker.HandleCaptureEnded(Input) end
    end
end), ScreenGui)


function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

function Library:Unload()
    if Library.Unloaded then
        return
    end
    Library:StopPointerDrag("unload")
    if Library.PickingKeybind then Library.PickingKeybind.CancelPicking() end
    Library.Unloaded = true
    for Thread in Library.PendingTasks do Library:CancelTask(Thread) end
    table.clear(Library.PendingTasks)
    if Library.ActiveExpandedDropdown then
        Library.ActiveExpandedDropdown:Collapse()
    end

    if Library.SnapGuideX then
        Library.SnapGuideX.Visible = false
        Library.SnapGuideY.Visible = false
        Library.SnapGuideX = nil
        Library.SnapGuideY = nil
    end

    local Notifications = {}
    for _, Notification in Library.Notifications do
        table.insert(Notifications, Notification)
    end
    for _, Notification in Notifications do
        Notification:Destroy("script", true)
    end
    table.clear(Library.NotifyOrder)
    table.clear(Library.Notifications)

    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    for _, Callback in Library.UnloadSignals do
        Library:SafeCallback(Callback)
    end

    for _, Dialog in table.clone(Library.Dialogues) do Dialog:Destroy() end
    for _, Tooltip in table.clone(Tooltips) do Library:SafeCallback(Tooltip.Destroy, Tooltip) end
    for Connection in Library.OptionChangedCallbacks do Connection:Disconnect() end
    for Connection in Library.FeatureValueChangedCallbacks do Connection:Disconnect() end
    table.clear(Library.FeatureValueSnapshots)
    table.clear(Library.UnloadSignals)
    table.clear(Tooltips)

    for Object in Library.MotionTweens do Library:CancelMotion(Object) end
    ScreenGui:Destroy()
    for _, Collection in { Library.Registry, Library.TextMetrics, Library.TextReflows, Library.TabRails, Library.DensityMetrics, Library.MotionTweens, Library.MotionTargets, Library.TabButtons, Library.Tabs, Library.DependencyBoxes, Library.Corners, Library.Scales } do table.clear(Collection) end

    if getgenv().Library == Library then
        getgenv().Library = nil
    end
end

local CheckIcon = Library:GetIcon("check")
local ArrowIcon = Library:GetIcon("chevron-down")
local ResizeIcon = Library:GetIcon("move-diagonal-2")
local KeyIcon = Library:GetIcon("key")
local MoveIcon = Library:GetIcon("bell")

function Library:SetIconModule(module: IconModule)
    assert(typeof(module) == "table" and typeof(module.GetAsset) == "function", "Icon module must expose GetAsset(name)")
    FetchIcons = true
    Icons = module

    -- Essential UI symbols continue to use the pinned catalogue.
    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-down")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("bell")
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        Info = Library:Validate(Info, Templates.KeyPicker)
        local ParentObj, Groupbox = self, self.Groupbox
        local Host = ParentObj.AddonContainer or ParentObj.TextLabel
        local K = {
            Idx = Idx, Type = "KeyPicker", Text = Info.Text, Value = Info.Default, Modifiers = {}, DisplayValue = Info.Default,
            Blacklisted = Info.Blacklisted, BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted, WhitelistedModifiers = Info.WhitelistedModifiers,
            Toggled = false, Mode = Info.Mode, SyncToggleState = Info.SyncToggleState,
            Callback = Info.Callback, ChangedCallback = Info.ChangedCallback, Changed = Info.Changed, Clicked = Info.Clicked,
            ParentObj = ParentObj, Groupbox = Groupbox,
        }
        if K.Mode == "Press" then
            assert(ParentObj.Type == "Label", "KeyPicker with the mode 'Press' can be only applied on Labels.")
            K.SyncToggleState = false; Info.Modes = { "Press" }
        end
        if K.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }
            if not table.find(Info.Modes, K.Mode) then K.Mode = "Toggle" end
        end
        if not table.find(Info.Modes, K.Mode) then K.Mode = Info.Modes[1] or "Toggle" end
        if K.SyncToggleState and K.Mode == "Toggle" then K.Toggled = ParentObj.Value == true end
        local MouseKeys = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
        local MouseNames = { [Enum.UserInputType.MouseButton1] = "MB1", [Enum.UserInputType.MouseButton2] = "MB2", [Enum.UserInputType.MouseButton3] = "MB3" }
        local ModifierOrder = { "LCtrl", "RCtrl", "LShift", "RShift", "LAlt", "RAlt", "Tab", "CapsLock" }
        local Modifiers = { LAlt = Enum.KeyCode.LeftAlt, RAlt = Enum.KeyCode.RightAlt, LCtrl = Enum.KeyCode.LeftControl, RCtrl = Enum.KeyCode.RightControl,
            LShift = Enum.KeyCode.LeftShift, RShift = Enum.KeyCode.RightShift, Tab = Enum.KeyCode.Tab, CapsLock = Enum.KeyCode.CapsLock }
        local ModifierNames = {}; for Name, Key in Modifiers do ModifierNames[Key] = Name end
        local function VerifiedModifiers(Source)
            local Result = {}
            for _, Name in typeof(Source) == "table" and Source or {} do if Modifiers[Name] then table.insert(Result, Name) end end
            return Result
        end
        local function ActiveModifiers()
            local Result = {}
            for _, Name in ModifierOrder do if UserInputService:IsKeyDown(Modifiers[Name]) then table.insert(Result, Name) end end
            return Result
        end
        local function ModifiersHeld()
            for _, Name in K.Modifiers do if not UserInputService:IsKeyDown(Modifiers[Name]) then return false end end
            return true
        end
        local function Allowed(Name, White, Black)
            return (#White == 0 or table.find(White, Name) ~= nil) and not table.find(Black, Name)
        end
        K.Modifiers = VerifiedModifiers(Info.DefaultModifiers)
        local Wrapper = New("Frame", { Name = "KeyAttachment", BackgroundTransparency = 1, Size = UDim2.fromOffset(104, 32), Parent = Host })
        local Picker = New("TextButton", { Name = "Keycap", BackgroundColor3 = "HeaderColor", Text = "", FontFace = "FontMono", TextSize = 14,
            TextWrapped = true, RichText = false, Size = UDim2.new(1, -30, 1, 0), Parent = Wrapper })
        New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), Parent = Picker })
        local More = New("TextButton", { Name = "BindingMenu", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 28, 1, 0), Text = "", Parent = Wrapper })
        Library:CreateSymbol(More, "ellipsis-vertical", UDim2.new(0.5, -8, 0.5, -8), 16)
        Library:StyleAction(Picker, "Secondary", ParentObj.Disabled, false)
        Library:AddTooltip("Capture a shortcut. Escape cancels without changing the feature.", "This control is disabled.", Picker)
        Library:AddTooltip("Shortcut mode, key name and clear binding", "This control is disabled.", More)
        K.Holder, K.Picker, K.MenuButton = Wrapper, Picker, More

        local KeybindsToggle = { Normal = K.Mode ~= "Toggle", Loaded = true }
        local BindHolder = New("TextButton", { Name = "TrackedKeybind", BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, 32), Visible = not Info.NoUI, Parent = Library.KeybindContainer })
        local BindCheck = New("Frame", { BackgroundColor3 = "FieldColor", Position = UDim2.new(0, 0, 0.5, -9), Size = UDim2.fromOffset(18, 18), Parent = BindHolder })
        Library:Surface(BindCheck, "Field")
        local BindMark = Library:CreateSymbol(BindCheck, "check", UDim2.fromOffset(2, 2), 14)
        local BindLabel = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextWrapped = true, Text = "", TextSize = 15,
            Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = BindHolder })
        function KeybindsToggle:Display(State)
            BindMark.Visible = State == true
            BindCheck.BackgroundColor3 = State and Library.Scheme.AccentColor or Library.Scheme.FieldColor
            BindLabel.TextColor3 = State and Library.Scheme.FontColor or Library.Scheme.MutedColor
        end
        function KeybindsToggle:SetText(Text)
            BindLabel.Text = Text
            local _, Available = Library:GetUsableRect()
            local Width = math.max(180, math.min(400, Available.X / Library.DPIScale - 24))
            local _, Height = Library:GetTextBounds(Text, BindLabel.FontFace, BindLabel.TextSize, Width - 32, false)
            BindHolder.Size = UDim2.fromOffset(Width, math.max(Library:Metrics().Target, Height + 8))
        end
        function KeybindsToggle:SetVisibility(Value) BindHolder.Visible = Value end
        function KeybindsToggle:SetNormal(Value)
            KeybindsToggle.Normal = Value
            BindHolder.Active, BindHolder.Selectable, BindCheck.Visible = not Value, not Value, not Value
            BindLabel.Position = UDim2.fromOffset(Value and 0 or 26, 0)
            BindLabel.Size = UDim2.new(1, Value and 0 or -26, 1, 0)
        end
        KeybindsToggle.Holder, KeybindsToggle.Label, KeybindsToggle.Checkbox = BindHolder, BindLabel, BindCheck
        K.KeybindHolder, K.KeybindToggle = BindHolder, KeybindsToggle
        table.insert(Library.KeybindToggles, KeybindsToggle)

        local Menu = Library:AddContextMenu(More, UDim2.fromOffset(224, 0), function() return { 0, More.AbsoluteSize.Y + 4 } end, 1, nil, Groupbox and Groupbox.IsDialog and 9010 or nil)
        K.Menu = Menu
        New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), Parent = Menu.Menu })
        Menu.List.Padding = UDim.new(0, 4)
        local ModeButtons = {}
        local KeyName = New("TextBox", { Name = "BindingKeyName", BackgroundColor3 = "FieldColor", FontFace = "FontMono", TextSize = 14, Text = K.Value,
            PlaceholderText = "Key name, e.g. F or MB2", ClearTextOnFocus = false, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 1, Parent = Menu.Menu })
        Library:StyleField(KeyName)
        local Help = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextWrapped = true, Text = "Key name applies on Enter. Clear removes the shortcut.",
            TextColor3 = "MutedColor", TextSize = 14, Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 2, Parent = Menu.Menu })
        local Picking, LastModifier, CapturedModifiers = false, nil, {}
        local function Reflow()
            if K.Destroyed or not Wrapper.Parent then return end
            local M = Library:Metrics()
            local MaxWidth = math.max(60, math.min(240, (ParentObj.Holder.AbsoluteSize.X / Library.DPIScale) - 34))
            local TextWidth, Height = Library:GetTextBounds(Picker.Text, Picker.FontFace, Picker.TextSize, MaxWidth - 12, false)
            local Width = math.clamp(TextWidth + 16, 46, MaxWidth)
            local H = math.max(30 + Library.TextSizeOffset, math.ceil(Height) + 8)
            Wrapper.Size = UDim2.fromOffset(Width + 30, math.max(H, Library.IsMobile and 40 or 32))
            KeyName.Size = UDim2.new(1, 0, 0, M.Field)
            local _, HH = Library:GetTextBounds(Help.Text, Help.FontFace, Help.TextSize, 200, false)
            Help.Size = UDim2.new(1, 0, 0, HH + 6)
            for _, B in ModeButtons do B.Size = UDim2.new(1, 0, 0, M.Target) end
            if Library.TextReflows[ParentObj.Holder] then Library.TextReflows[ParentObj.Holder]() end
            if Menu.Active then Menu:Reposition() end
        end
        function K:Display(Text)
            if K.Destroyed or Library.Unloaded then return end
            Picker.Text = Text or K.DisplayValue
            Library:StyleAction(Picker, Picking and "Primary" or "Secondary", ParentObj.Disabled, false)
            Reflow()
        end
        function K:GetState()
            if K.Mode == "Always" then return true end
            if K.Mode ~= "Hold" then return K.Toggled end
            if not Library.IsRobloxFocused or ParentObj.Disabled or K.Value == "None" or K.Value == "Unknown" or UserInputService:GetFocusedTextBox() or not ModifiersHeld() then return false end
            if MouseKeys[K.Value] then return UserInputService:IsMouseButtonPressed(MouseKeys[K.Value]) end
            local Ok, Down = pcall(UserInputService.IsKeyDown, UserInputService, Enum.KeyCode[K.Value])
            return Ok and Down or false
        end
        function K:Update()
            K:Display(Picking and "Press a key…" or nil)
            if K.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then KeybindsToggle:SetVisibility(false); return end
            local State = K:GetState()
            if K.SyncToggleState and not K.SuppressSync and ParentObj.Value ~= State then ParentObj:SetValue(State) end
            if Info.NoUI then return end
            KeybindsToggle:SetNormal(not (Library.ShowToggleFrameInKeybinds and K.Mode == "Toggle"))
            KeybindsToggle:SetText(("[%s] %s (%s)"):format(K.DisplayValue, K.Text, K.Mode))
            KeybindsToggle:SetVisibility(true); KeybindsToggle:Display(State)
        end
        function K:OnChanged(Func) K.Changed = Func end
        function K:OnClick(Func) K.Clicked = Func end
        function K:DoClick()
            if K.Mode == "Press" then
                if K.Toggled and Info.WaitForCallback then return end
                K.Toggled = true
            end
            Library:SafeCallback(K.Callback, K.Toggled)
            Library:SafeCallback(K.Clicked, K.Toggled)
            if K.Mode == "Press" then K.Toggled = false end
        end
        function K:SetValue(Data)
            if K.Destroyed or Library.Unloaded then return end
            assert(typeof(Data) == "table", "KeyPicker:SetValue expects { key, mode, modifiers }")
            local PreviousKey, PreviousMode, PreviousMods = K.Value, K.Mode, table.concat(K.Modifiers, "\0")
            local Key, Mode, Mods = Data[1], Data[2], Data[3]
            local Valid, KeyCode = pcall(function()
                if Key == "None" then Key = nil; return nil end
                return MouseKeys[Key] or Enum.KeyCode[Key]
            end)
            K.Value = Key == nil and "None" or Valid and Key or "Unknown"
            K.Modifiers = VerifiedModifiers(typeof(Mods) == "table" and Mods or K.Modifiers)
            K.DisplayValue = #K.Modifiers > 0 and (table.concat(K.Modifiers, " + ") .. " + " .. K.Value) or K.Value
            if ModeButtons[Mode] then K.Mode = Mode; Menu:Close("mode") end
            for Name, B in ModeButtons do Library:StyleAction(B, K.Mode == Name and "Primary" or "Secondary", ParentObj.Disabled, false) end
            KeyName.Text = K.Value
            K:Update()
            if PreviousKey ~= K.Value or PreviousMode ~= K.Mode or PreviousMods ~= table.concat(K.Modifiers, "\0") then
                local Enums = {}; for _, Name in K.Modifiers do table.insert(Enums, Modifiers[Name]) end
                Library:SafeCallback(K.ChangedCallback, KeyCode, Enums)
                Library:SafeCallback(K.Changed, KeyCode, Enums)
                Library:ObserveOptionValue(K)
            end
        end
        function K:SetText(Text) K.Text = tostring(Text or ""); K:Update() end
        local function CancelCapture()
            Picking, LastModifier, CapturedModifiers = false, nil, {}
            if Library.PickingKeybind == K then Library.PickingKeybind = nil end
            if Picker.Parent and not Library.Unloaded then K.SuppressSync = true; K:Update(); K.SuppressSync = nil end
        end
        K.CancelPicking = CancelCapture
        local function CommitCapture(Key, Mods, Input)
            Picking = false; Library.PickingKeybind = nil
            K.SuppressSync = true
            K:SetValue({ Key, K.Mode, Mods })
            K.SuppressSync = nil
            if Input then K.IgnoreRelease = Input; Library.CaptureInputs[Input] = K end
            CapturedModifiers, LastModifier = {}, nil
        end
        function K:StartPicking()
            if Library.PickingKeybind then Library.PickingKeybind.CancelPicking() end
            if ParentObj.Disabled or not Library:CanInteract(Picker) then return false end
            if CurrentMenu then CurrentMenu:Close("capture") end
            Picking = true; Library.PickingKeybind = K
            CapturedModifiers, LastModifier = {}, nil
            K:Display("Press a key…")
            return true
        end
        K.HandleCapture = function(Input)
            if Input.KeyCode == Enum.KeyCode.Escape then CancelCapture(); return end
            if IsMouseInput(Input, true) and Library.LayoutMain and Library:MouseIsOverFrame(Library.LayoutMain, Input.Position) then
                K.IgnoreActivateInput = Input
                Library.DismissedInputs[Input] = true
                CancelCapture(); return
            end
            if UserInputService:GetFocusedTextBox() then CancelCapture(); return end
            local Modifier = Input.UserInputType == Enum.UserInputType.Keyboard and ModifierNames[Input.KeyCode]
            if Modifier then
                if Allowed(Modifier, K.WhitelistedModifiers, K.BlacklistedModifiers) then
                    LastModifier = Input.KeyCode.Name
                    if not table.find(CapturedModifiers, Modifier) then table.insert(CapturedModifiers, Modifier) end
                    K:Display(table.concat(CapturedModifiers, " + ") .. " + …")
                end
                return
            end
            local Name = MouseNames[Input.UserInputType] or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name)
            if not Name or not Allowed(Name, K.Whitelisted, K.Blacklisted) then return end
            local Active = ActiveModifiers()
            for _, M in Active do if not Allowed(M, K.WhitelistedModifiers, K.BlacklistedModifiers) then return end end
            CommitCapture(Name, Active, Input)
        end
        K.HandleCaptureEnded = function(Input)
            if LastModifier == Input.KeyCode.Name and Allowed(LastModifier, K.Whitelisted, K.Blacklisted) then CommitCapture(LastModifier, {}, Input) end
        end
        Picker.Activated:Connect(function(Input)
            if Input and (K.IgnoreActivateInput == Input or Library.DismissedInputs[Input]) then return end
            if Picking then CancelCapture() else K:StartPicking() end
        end)
        More.Activated:Connect(function(Input)
            if ParentObj.Disabled or Input and Library.DismissedInputs[Input] then return end
            if Picking then CancelCapture() end
            Menu:Toggle()
        end)
        Picker.MouseButton2Click:Connect(function() if not ParentObj.Disabled then CancelCapture(); Menu:Toggle() end end)
        for Index, Mode in Info.Modes do
            local B = New("TextButton", { Text = Mode, RichText = false, TextSize = 15, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = Index + 2, Parent = Menu.Menu })
            ModeButtons[Mode] = B
            Library:StyleAction(B, K.Mode == Mode and "Primary" or "Secondary", ParentObj.Disabled, false)
            B.Activated:Connect(function(Input) if not ParentObj.Disabled and Library:CanInteract(B, Input) and K.Mode ~= Mode then K:SetValue({ K.Value, Mode, K.Modifiers }) end end)
        end
        local Clear = New("TextButton", { Text = "Clear binding", RichText = false, TextSize = 15, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = 30, Parent = Menu.Menu })
        Library:StyleAction(Clear, "Secondary", false, false)
        Clear.Activated:Connect(function(Input) if not ParentObj.Disabled and Library:CanInteract(Clear, Input) then CommitCapture("None", {}, Input); Menu:Close("clear") end end)
        KeyName.FocusLost:Connect(function(Enter)
            if not Enter or ParentObj.Disabled then KeyName.Text = K.Value; return end
            local Name = KeyName.Text:match("^%s*(.-)%s*$")
            local Valid = Name == "None" or MouseKeys[Name] ~= nil
            if not Valid then local Ok, Value = pcall(function() return Enum.KeyCode[Name] end); Valid = Ok and Value ~= nil end
            if Valid and Allowed(Name, K.Whitelisted, K.Blacklisted) then Library:SetFieldError(KeyName, ""); CommitCapture(Name, K.Modifiers)
            else Library:SetFieldError(KeyName, "Unknown or restricted key name"); Help.Text = "Unknown or restricted key name. Use an Enum.KeyCode name, MB1, MB2 or MB3."; Reflow() end
        end)
        BindHolder.Activated:Connect(function(Input)
            if KeybindsToggle.Normal or ParentObj.Disabled or not Library:CanInteract(BindHolder, Input) then return end
            K.Toggled = not K.Toggled; K:DoClick(); K:Update()
        end)
        Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
            if K.Destroyed or Library.Unloaded or Library:IsInputOwned(Input) or Picking or Library.PickingKeybind or ParentObj.Disabled
                or CurrentMenu or Library.ActiveDialog or Library.ActiveExpandedDropdown or Library.HelpMode or (Library.Window and Library.Window.PaletteOpen)
                or UserInputService:GetFocusedTextBox() or K.Mode == "Always" or K.Value == "Unknown" or K.Value == "None" then return end
            local Matched = ModifiersHeld() and (MouseNames[Input.UserInputType] == K.Value or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == K.Value))
            if K.Mode == "Toggle" and Matched then K.Toggled = not K.Toggled; K:DoClick()
            elseif K.Mode == "Press" and Matched then K:DoClick()
            elseif K.Mode == "Hold" then local State = K:GetState(); if State ~= K.Toggled then K.Toggled = State; K:DoClick() end end
            if Matched or K.Mode == "Hold" then K:Update() end
        end), Wrapper)
        Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
            if K.Destroyed or Library.Unloaded or Picking or Library.CaptureInputs[Input] or K.IgnoreRelease == Input then return end
            if K.Mode == "Hold" then local State = K:GetState(); if State ~= K.Toggled then K.Toggled = State; K:DoClick() end; K:Update() end
        end), Wrapper)
        Wrapper.Destroying:Once(CancelCapture)
        Library.TextReflows[Wrapper] = Reflow
        local ValidDefault = K.Value == "None" or MouseKeys[K.Value] ~= nil
        if not ValidDefault then local Ok, Key = pcall(function() return Enum.KeyCode[K.Value] end); ValidDefault = Ok and Key ~= nil end
        if not ValidDefault then K.Value = "Unknown" end
        K.DisplayValue = #K.Modifiers > 0 and (table.concat(K.Modifiers, " + ") .. " + " .. K.Value) or K.Value
        K.Default, K.DefaultModifiers = K.Value, table.clone(K.Modifiers)
        if ParentObj.Addons then table.insert(ParentObj.Addons, K) end
        Options[Idx] = Library:TrackElement(K, Groupbox)
        K:Update()
        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end
    function Funcs:AddColorPicker(Idx, Info)
        Info = Library:Validate(Info, Templates.ColorPicker)
        assert(typeof(Info.Default) == "Color3", "Color picker Default must be a Color3")
        if Info.Transparency ~= nil then assert(IsFinite(Info.Transparency), "Transparency must be finite"); Info.Transparency = math.clamp(Info.Transparency, 0, 1) end
        local ParentObj, Groupbox = self, self.Groupbox
        local Host = ParentObj.AddonContainer or ParentObj.TextLabel
        local C = { Idx = Idx, Type = "ColorPicker", Value = Info.Default, Transparency = Info.Transparency or 0, Title = Info.Title,
            Callback = Info.Callback, Changed = Info.Changed, ParentObj = ParentObj, Groupbox = Groupbox }
        C.Hue, C.Sat, C.Vib = C.Value:ToHSV()
        local Holder = New("TextButton", { Name = "ColorAttachment", BackgroundColor3 = C.Value, Text = "", Size = UDim2.fromOffset(32, 32), Parent = Host })
        local SwatchStroke = New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = Holder })
        local Checker = New("ImageLabel", { BackgroundTransparency = 1, Image = CustomImageManager.GetAsset("TransparencyTexture"), ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(8, 8), Size = UDim2.fromScale(1, 1), ImageTransparency = 1 - C.Transparency, Parent = Holder })
        C.Holder = Holder
        local Menu, Content
        local Field, FieldMarker, Hue, HueMarker, Alpha, AlphaColor, AlphaMarker, Hex, RGB, AlphaBox, ErrorLabel
        local Title, Entries, Actions
        local ErrorMessage = ""
        local Layouting = false
        local function Layout()
            if Layouting or not Menu or C.Destroyed then return end
            Layouting = true
            local M = Library:Metrics()
            Holder.Size = UDim2.fromOffset(Library.IsMobile and 40 or 30 + Library.TextSizeOffset, Library.IsMobile and 40 or 30 + Library.TextSizeOffset)
            local _, View = Library:GetUsableRect()
            local W = math.min(330 + Library.TextSizeOffset * 8, View.X / Library.DPIScale)
            local Top = Title.Visible and M.Target or 8
            local Extra = M.Field * (Alpha and 4 or 3) + 82
            local FieldHeight = math.max(70, math.min(180, View.Y / Library.DPIScale - Top - Extra))
            Title.Size = UDim2.new(1, -20, 0, M.Target - 6)
            Field.Position, Field.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, FieldHeight)
            Top += FieldHeight + 8
            Hue.Position, Hue.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, math.max(24, M.Target - 8))
            Top += math.max(24, M.Target - 8) + 8
            if Alpha then
                Alpha.Position, Alpha.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, math.max(24, M.Target - 8))
                Top += math.max(24, M.Target - 8) + 8
            end
            Entries.Position, Entries.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, M.Field + 22)
            Hex.Position, Hex.Size = UDim2.fromOffset(0, 22), UDim2.new(0.39, -4, 0, M.Field)
            RGB.Position, RGB.Size = UDim2.new(0.39, 4, 0, 22), UDim2.new(0.61, -4, 0, M.Field)
            Top += M.Field + 28
            if AlphaBox then
                AlphaBox.Position, AlphaBox.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, M.Field)
                Top += M.Field + 6
            end
            local EH = 0
            if ErrorMessage ~= "" then local _, H = Library:GetTextBounds(ErrorMessage, ErrorLabel.FontFace, ErrorLabel.TextSize, W - 20, false); EH = H + 8 end
            ErrorLabel.Visible, ErrorLabel.Text = EH > 0, ErrorMessage
            ErrorLabel.Position, ErrorLabel.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, EH)
            Top += EH
            Actions.Position, Actions.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, M.Target)
            if Content then Content.CanvasSize = UDim2.fromOffset(0, Top + M.Target + 10) end
            Menu:SetSize(UDim2.fromOffset(W, Top + M.Target + 10))
            Layouting = false
            if Library.TextReflows[ParentObj.Holder] then Library.TextReflows[ParentObj.Holder]() end
        end
        Menu = Library:AddContextMenu(Holder, UDim2.fromOffset(330, 360), function() return { 0, Holder.AbsoluteSize.Y + 5 } end, nil,
            function(Active) if Active then Layout() end end, Groupbox and Groupbox.IsDialog and 9010 or nil)
        C.ColorMenu = Menu
        Content = New("ScrollingFrame", { Name = "ColorContents", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = "OutlineColor", ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Menu.Menu })
        Title = New("TextLabel", { BackgroundTransparency = 1, FontFace = "FontBold", TextSize = 15, RichText = false, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(C.Title or ""), Visible = typeof(C.Title) == "string" and C.Title ~= "", Position = UDim2.fromOffset(10, 4), Parent = Content })
        Field = New("TextButton", { Name = "SaturationValue", BackgroundColor3 = Color3.fromHSV(C.Hue, 1, 1), Text = "", Parent = Content })
        -- Native gradients represent HSV exactly; a missing image cannot turn this into an unusable flat square.
        local White = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromScale(1, 1), Parent = Field })
        New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = White })
        local Black = New("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = Field })
        New("UIGradient", { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = Black })
        New("UIStroke", { Color = "OutlineColor", Parent = Field })
        FieldMarker = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(7, 7), ZIndex = Field.ZIndex + 2, Parent = Field })
        New("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Parent = FieldMarker })
        Hue = New("TextButton", { Name = "Hue", BackgroundColor3 = Color3.new(1, 1, 1), Text = "", Parent = Content })
        New("UIGradient", { Color = ColorSequence.new(HueSequenceTable), Parent = Hue })
        New("UIStroke", { Color = "OutlineColor", Parent = Hue })
        HueMarker = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 4, 1, 0), Parent = Hue })
        New("UIStroke", { Color = Color3.new(0, 0, 0), Parent = HueMarker })
        if Info.Transparency ~= nil then
            Alpha = New("ImageButton", { Name = "Transparency", BackgroundColor3 = "HeaderColor", Image = CustomImageManager.GetAsset("TransparencyTexture"), ScaleType = Enum.ScaleType.Tile, TileSize = UDim2.fromOffset(8, 8), Parent = Content })
            AlphaColor = New("Frame", { BackgroundColor3 = C.Value, Size = UDim2.fromScale(1, 1), Parent = Alpha })
            New("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = AlphaColor })
            New("UIStroke", { Color = "OutlineColor", Parent = Alpha })
            AlphaMarker = New("Frame", { BackgroundColor3 = Color3.new(1, 1, 1), AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(0, 4, 1, 0), Parent = Alpha })
            New("UIStroke", { Color = Color3.new(0, 0, 0), Parent = AlphaMarker })
            AlphaBox = New("TextBox", { Name = "TransparencyNumber", BackgroundColor3 = "FieldColor", ClearTextOnFocus = false, FontFace = "FontMono", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Content })
            Library:StyleField(AlphaBox)
            New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = AlphaBox })
        end
        Entries = New("Frame", { BackgroundTransparency = 1, Parent = Content })
        New("TextLabel", { BackgroundTransparency = 1, Text = "Hex", RichText = false, TextSize = 14, Size = UDim2.new(0.39, 0, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = Entries })
        New("TextLabel", { BackgroundTransparency = 1, Text = "RGB", RichText = false, TextSize = 14, Position = UDim2.new(0.39, 4, 0, 0), Size = UDim2.new(0.61, -4, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, Parent = Entries })
        Hex = New("TextBox", { Name = "HexColor", BackgroundColor3 = "FieldColor", ClearTextOnFocus = false, FontFace = "FontMono", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Entries })
        RGB = New("TextBox", { Name = "RGBColor", BackgroundColor3 = "FieldColor", ClearTextOnFocus = false, FontFace = "FontMono", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Entries })
        for _, Box in { Hex, RGB } do Library:StyleField(Box); New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = Box }) end
        ErrorLabel = New("TextLabel", { BackgroundTransparency = 1, TextColor3 = "RedColor", TextSize = 14, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Content })
        Actions = New("Frame", { BackgroundTransparency = 1, Parent = Content })
        local Copy = New("TextButton", { Text = "Copy", TextSize = 15, RichText = false, Size = UDim2.new(0.3, -4, 1, 0), Parent = Actions })
        local Paste = New("TextButton", { Text = "Paste", TextSize = 15, RichText = false, Position = UDim2.new(0.3, 2, 0, 0), Size = UDim2.new(0.3, -4, 1, 0), Parent = Actions })
        local Done = New("TextButton", { Text = "Done", TextSize = 15, RichText = false, Position = UDim2.new(0.6, 4, 0, 0), Size = UDim2.new(0.4, -4, 1, 0), Parent = Actions })
        Library:StyleAction(Copy, "Secondary", false, false); Library:StyleAction(Paste, "Secondary", false, false); Library:StyleAction(Done, "Primary", false, false)
        local Context = Library:AddContextMenu(Holder, UDim2.fromOffset(190, 0), function() return { Holder.AbsoluteSize.X + 4, 0 } end, 1, nil, Groupbox and Groupbox.IsDialog and 9010 or nil)
        C.ContextMenu = Context
        function C:SetHSVFromRGB(Color) C.Hue, C.Sat, C.Vib = Color:ToHSV() end
        function C:Display()
            if C.Destroyed or Library.Unloaded then return end
            C.Value = Color3.fromHSV(C.Hue, C.Sat, C.Vib)
            Holder.BackgroundColor3, Checker.ImageTransparency = C.Value, 1 - C.Transparency
            Field.BackgroundColor3 = Color3.fromHSV(C.Hue, 1, 1)
            FieldMarker.Position = UDim2.fromScale(C.Sat, 1 - C.Vib)
            HueMarker.Position = UDim2.fromScale(C.Hue, 0)
            if Alpha then AlphaColor.BackgroundColor3 = C.Value; AlphaMarker.Position = UDim2.fromScale(C.Transparency, 0); AlphaBox.Text = string.format("Transparency: %.3f", C.Transparency) end
            Hex.Text = "#" .. C.Value:ToHex()
            RGB.Text = string.format("%d, %d, %d", math.floor(C.Value.R * 255 + 0.5), math.floor(C.Value.G * 255 + 0.5), math.floor(C.Value.B * 255 + 0.5))
        end
        function C:Update()
            C:Display()
            -- Unlike other value controls, the supplied color API notifies on every explicit valid setter.
            Library:SafeCallback(C.Callback, C.Value); Library:SafeCallback(C.Changed, C.Value); Library:ObserveOptionValue(C)
        end
        function C:OnChanged(Func) C.Changed = Func end
        function C:SetValueRGB(Color, Transparency)
            if C.Destroyed or Library.Unloaded then return end
            assert(typeof(Color) == "Color3", "Expected Color3")
            if Info.Transparency ~= nil and Transparency ~= nil then assert(IsFinite(Transparency), "Transparency must be finite"); C.Transparency = math.clamp(Transparency, 0, 1) end
            C:SetHSVFromRGB(Color); C:Update()
        end
        function C:SetValue(HSV, Transparency)
            if C.Destroyed or Library.Unloaded then return end
            if typeof(HSV) == "Color3" then C:SetValueRGB(HSV, Transparency); return end
            assert(typeof(HSV) == "table" and IsFinite(HSV[1]) and IsFinite(HSV[2]) and IsFinite(HSV[3]), "Expected finite HSV components")
            C:SetValueRGB(Color3.fromHSV(HSV[1] % 1, math.clamp(HSV[2], 0, 1), math.clamp(HSV[3], 0, 1)), Transparency)
        end
        local function Error(Box, Message)
            ErrorMessage = Message or ""
            Library:SetFieldError(Box, ErrorMessage)
            Layout()
        end
        local function Interactive() return not ParentObj.Disabled and not C.Destroyed and not Library.Unloaded end
        Hex.FocusLost:Connect(function()
            if not Interactive() then C:Display(); return end
            local Value = Hex.Text:match("^%s*#?(%x%x%x%x%x%x)%s*$")
            if not Value then Error(Hex, "Enter six hexadecimal digits, for example FF4275."); return end
            Error(Hex, ""); C:SetValueRGB(Color3.fromHex(Value))
        end)
        RGB.FocusLost:Connect(function()
            if not Interactive() then C:Display(); return end
            local R, G, B = RGB.Text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
            R, G, B = tonumber(R), tonumber(G), tonumber(B)
            if not R or not G or not B or R > 255 or G > 255 or B > 255 then Error(RGB, "Enter R, G, B as three whole numbers from 0 to 255."); return end
            Error(RGB, ""); C:SetValueRGB(Color3.fromRGB(R, G, B))
        end)
        if AlphaBox then
            AlphaBox.Focused:Connect(function() AlphaBox.Text = tostring(C.Transparency) end)
            AlphaBox.FocusLost:Connect(function()
                if not Interactive() then C:Display(); return end
                local Value = tonumber(AlphaBox.Text)
                if not IsFinite(Value) or Value < 0 or Value > 1 then Error(AlphaBox, "Transparency must be between 0 (opaque) and 1 (transparent)."); return end
                Error(AlphaBox, ""); C:SetValueRGB(C.Value, Value)
            end)
        end
        local function Start(Which, Input)
            if not Interactive() then return end
            Library:BeginPointerDrag(Which, Input, function(Point)
                if not Interactive() then Library:StopPointerDrag("disabled"); return end
                local X = math.clamp((Point.X - Which.AbsolutePosition.X) / math.max(1, Which.AbsoluteSize.X), 0, 1)
                if Which == Field then
                    C.Sat = X; C.Vib = 1 - math.clamp((Point.Y - Which.AbsolutePosition.Y) / math.max(1, Which.AbsoluteSize.Y), 0, 1)
                elseif Which == Hue then C.Hue = X
                else C.Transparency = X end
                C:Update()
            end)
        end
        Field.InputBegan:Connect(function(Input) Start(Field, Input) end)
        Hue.InputBegan:Connect(function(Input) Start(Hue, Input) end)
        if Alpha then Alpha.InputBegan:Connect(function(Input) Start(Alpha, Input) end) end
        local function CopyColor() Library.CopiedColor = { C.Value, C.Transparency } end
        local function PasteColor() if Library.CopiedColor then C:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2]) end end
        Copy.Activated:Connect(function(Input) if Interactive() and Library:CanInteract(Copy, Input) then CopyColor() end end)
        Paste.Activated:Connect(function(Input) if Interactive() and Library:CanInteract(Paste, Input) then PasteColor() end end)
        Done.Activated:Connect(function() Menu:Close("done") end)
        local function ContextAction(Caption, Action)
            local B = New("TextButton", { Text = Caption, TextSize = 15, RichText = false, Size = UDim2.new(1, 0, 0, Library:Metrics().Target), Parent = Context.Menu })
            Library:StyleAction(B, "Secondary", false, false)
            B.Activated:Connect(function(Input) if Interactive() and Library:CanInteract(B, Input) then Action(); Context:Close("action") end end)
        end
        ContextAction("Copy color", CopyColor); ContextAction("Paste color", PasteColor)
        local function Clipboard(Text)
            if typeof(setclipboard) ~= "function" then ErrorMessage = "Clipboard capability is unavailable."; return end
            local Ok, Result = pcall(setclipboard, Text)
            if not Ok or Result == false then ErrorMessage = "Clipboard write failed." end
        end
        ContextAction("Copy Hex", function() Clipboard(C.Value:ToHex()); if ErrorMessage ~= "" then Library:Notify({ Title = "Clipboard unavailable", Description = ErrorMessage, Type = "Error" }) end end)
        ContextAction("Copy RGB", function() Clipboard(RGB.Text); if ErrorMessage ~= "" then Library:Notify({ Title = "Clipboard unavailable", Description = ErrorMessage, Type = "Error" }) end end)
        Holder.Activated:Connect(function(Input) if Interactive() and Library:CanInteract(Holder, Input) then Menu:Toggle() end end)
        Holder.MouseButton2Click:Connect(function() if Interactive() and Library:CanInteract(Holder) then Context:Toggle() end end)
        Library:AddTooltip(Info.Tooltip or (Info.Title and ("Edit " .. Info.Title)), Info.DisabledTooltip, Holder)
        Menu.OnDismiss = function() if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner:IsDescendantOf(Menu.Menu) then Library:StopPointerDrag("closed") end end
        C.Default = Info.Default; C.DefaultTransparency = C.Transparency
        C.HexBox, C.RGBBox, C.TransparencyBox, C.Field = Hex, RGB, AlphaBox, Field
        Library.TextReflows[Menu.Menu] = Layout
        Library.TextReflows[Holder] = Layout
        if ParentObj.Addons then table.insert(ParentObj.Addons, C) end
        -- Establish the dirty-tracking baseline after the initial HSV normalization.
        -- This does not dispatch the explicit-setter callbacks during construction.
        C:Display()
        Options[Idx] = Library:TrackElement(C, Groupbox)
        Layout()
        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local function DependenciesMet(Dependencies)
    for _, Dependency in Dependencies do
        local Element, Expected = Dependency[1], Dependency[2]
        if Element.Destroyed then return false end
        if Element.Type == "PriorityDropdown" then
            if not table.find(Element.Value, Expected) then return false end
        elseif Element.Type == "Dropdown" and Element.Multi then
            if not Element.Value[Expected] then return false end
        elseif Element.Value ~= Expected then return false end
    end
    return true
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        local Params = select(1, ...)
        local Info = typeof(Params) == "table" and Params or { Text = typeof(Params) == "string" and Params or nil }
        local Owner = self
        local Top, Bottom = Info.MarginTop or Info.Margin or 0, Info.MarginBottom or Info.Margin or 0
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8 + Top + Bottom), Parent = Owner.Container })
        local Line = New("Frame", { BackgroundColor3 = "OutlineColor", Position = UDim2.fromOffset(0, Top + 3), Size = UDim2.new(1, 0, 0, 1), Parent = Holder })
        if Info.Text then
            local Text = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Text), RichText = false, FontFace = "FontBold", TextSize = 15, TextColor3 = Info.AccentColor and "AccentColor" or "MutedColor", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(0, Top), Size = UDim2.new(1, 0, 0, 24), Parent = Holder })
            local function Fit()
                if not Holder.Parent or Library.Unloaded then return end
                local _, H = Library:GetTextBounds(Text.Text, Text.FontFace, Text.TextSize, math.max(30, Holder.AbsoluteSize.X / Library.DPIScale), false)
                Text.Size = UDim2.new(1, 0, 0, H + 4)
                Line.Position = UDim2.fromOffset(0, Top + H + 6)
                Holder.Size = UDim2.new(1, 0, 0, Top + H + 10 + Bottom)
                Owner:Resize()
            end
            Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
            Library.TextReflows[Holder] = Fit; Fit()
        end
        table.insert(Owner.Elements, { Holder = Holder, Type = "Divider" })
        Owner:Resize()
    end

    function Funcs:AddLabel(...)
        local First, Second = select(1, ...), select(2, ...)
        local P = typeof(First) == "table" and First or (typeof(Second) == "table" and Second or { Text = First, DoesWrap = Second, Index = select(3, ...) })
        local Idx = typeof(Second) == "table" and First or P.Index
        local Owner = self
        local Label = { Idx = Idx, Text = P.Text or "", DoesWrap = P.DoesWrap == true, Visible = P.Visible ~= false, Type = "Label", Addons = {}, Groupbox = Owner, Container = Owner.Container }
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Visible = Label.Visible, Parent = Owner.Container })
        local Text = New("TextLabel", { BackgroundTransparency = 1, Text = Label.Text, RichText = P.RichText ~= false, TextSize = P.Size or 15, TextWrapped = true, TextXAlignment = Owner.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left, Size = UDim2.fromScale(1, 1), Parent = Holder })
        Label.Holder, Label.TextLabel = Holder, Text
        local function Fit()
            if not Holder.Parent or Library.Unloaded then return end
            local _, H = Library:GetTextBounds(Text.Text, Text.FontFace, Text.TextSize, math.max(30, Holder.AbsoluteSize.X / Library.DPIScale), Text.RichText)
            Holder.Size = UDim2.new(1, 0, 0, H + 6)
            Owner:Resize()
        end
        function Label:SetText(Value)
            if Label.Destroyed then return end
            Label.Text = tostring(Value or ""); Text.Text = Label.Text
            if Label.AddonContainer then Library.TextReflows[Holder]() else Fit() end
        end
        function Label:SetSize(Value)
            assert(IsFinite(Value) and Value > 0, "Label size must be positive")
            local Metrics = Library.TextMetrics[Text]
            Metrics.Size = math.max(15, Value); Metrics.Apply(); Label:SetText(Label.Text)
        end
        function Label:SetVisible(Value) Label.Visible = Value; Holder.Visible = Value; Owner:Resize() end
        if not Label.DoesWrap then
            Label.AddonContainer = Library:FitToggle(Holder, Text, Owner, 28)
            setmetatable(Label, BaseAddons)
        else
            Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
            Text:GetPropertyChangedSignal("TextSize"):Connect(Fit)
            Library.TextReflows[Holder] = Fit; Fit()
        end
        if P.Tooltip then Label.TooltipTable = Library:AddTooltip(P.Tooltip, "", Text) end
        Library:TrackElement(Label, Owner)
        table.insert(Owner.Elements, Label)
        if Idx ~= nil then Labels[Idx] = Label else table.insert(Labels, Label) end
        return Label
    end


    function Funcs:AddButton(...)
        local Groupbox = self
        local function ReadInfo(...)
            local A, B = select(1, ...), select(2, ...)
            local Info = typeof(A) == "table" and table.clone(A) or (typeof(B) == "table" and table.clone(B) or { Text = A, Func = B, Idx = select(3, ...) })
            if typeof(B) == "table" then Info.Idx = A end
            Info.Text = tostring(Info.Text or "Button")
            Info.Func = Info.Func or Info.Callback or function() end
            Info.Variant = Info.Variant or (Info.Risky and "Destructive" or "Secondary")
            assert(Info.Variant == "Primary" or Info.Variant == "Secondary" or Info.Variant == "Destructive" or Info.Variant == "Ghost", "Unknown button variant")
            assert(typeof(Info.Func) == "function", "Button callback must be a function")
            return Info
        end
        local Info = ReadInfo(...)
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Parent = Groupbox.Container })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 8), Parent = Holder })
        local Main
        local Pending = false
        local function Fit()
            if Pending or not Holder.Parent or Library.Unloaded then return end
            Pending = true
            task.defer(function()
                Pending = false
                if not Holder.Parent or Library.Unloaded then return end
                local Height = Library:Metrics().Target
                for _, Object in { Main, Main and Main.SubButton } do
                    if Object and Object.Base.Parent and Object.Visible then
                        local Width = math.max(40, Object.Base.AbsoluteSize.X / Library.DPIScale - (Object.Icon and 48 or 24))
                        local _, TextHeight = Library:GetTextBounds(Object.Base.Text, Object.Base.FontFace, Object.Base.TextSize, Width, false)
                        Height = math.max(Height, TextHeight + 16)
                    end
                end
                Holder.Size = UDim2.new(1, 0, 0, math.ceil(Height))
                Groupbox:Resize()
            end)
        end
        Library.TextReflows[Holder] = Fit
        local function Create(Data, IsSub)
            local Button = { Text = Data.Text, Func = Data.Func, Idx = Data.Idx, DoubleClick = Data.DoubleClick == true,
                Variant = Data.Variant, Risky = Data.Risky == true, Disabled = Data.Disabled == true, Visible = Data.Visible ~= false,
                WaitForCallback = Data.WaitForCallback == true, Tooltip = Data.Tooltip, DisabledTooltip = Data.DisabledTooltip,
                Type = IsSub and "SubButton" or "Button", Hovered = false, ArmGeneration = 0 }
            local Base = New("TextButton", { BackgroundColor3 = "MainColor", Size = UDim2.fromScale(1, 1), Text = Button.Text,
                RichText = false, TextSize = 14, TextWrapped = true, Visible = Button.Visible, Parent = Holder })
            Library:RoundSurface(Base, 7)
            local Icon = Library:GetCustomIcon(Data.Icon)
            if Icon then
                Button.Icon = New("ImageLabel", { Image = Icon.Url, ImageRectOffset = Icon.ImageRectOffset, ImageRectSize = Icon.ImageRectSize,
                    Position = UDim2.new(0, 12, 0.5, -8), Size = UDim2.fromOffset(16, 16), ImageColor3 = "FontColor", Parent = Base })
                Base.TextXAlignment = Enum.TextXAlignment.Left
            end
            New("UIPadding", { PaddingLeft = UDim.new(0, Icon and 36 or 12), PaddingRight = UDim.new(0, 12), Parent = Base })
            local Stroke = New("UIStroke", { Color = "OutlineColor", Transparency = 0.15, Parent = Base })
            Button.Base, Button.Stroke, Button.Holder = Base, Stroke, IsSub and Base or Holder
            function Button:UpdateColors()
                if Button.Destroyed or Library.Unloaded then return end
                Library:StyleAction(Base, Button.Variant, Button.Disabled or Button.Busy or Button.Locked, Button.Hovered)
                Stroke.Transparency = Button.Disabled and 0.5 or (Button.Variant == "Ghost" and 1 or 0.05)
                Stroke.Color = Button.Hovered and not Button.Disabled and Library.Scheme.AccentColor or Library.Scheme.OutlineColor
                Library.Registry[Stroke].Color = Button.Hovered and not Button.Disabled and "AccentColor" or "OutlineColor"
                if Button.Icon then
                    local function Ink() return Button.Variant == "Primary" and not Button.Disabled and Library:GetOnColor(Library.Scheme.AccentColor) or Library.Scheme.FontColor end
                    Library.Registry[Button.Icon].ImageColor3 = Ink; Button.Icon.ImageColor3 = Ink()
                end
            end
            function Button:SetDisabled(Value)
                Button.Disabled = Value == true
                Button.ArmDeadline = nil; Button.ArmGeneration += 1; Base.Text = Button.Text
                if Button.TooltipTable then Button.TooltipTable.Disabled = Button.Disabled end
                Button:UpdateColors()
            end
            function Button:SetVisible(Value)
                Button.Visible = Value ~= false; Base.Visible = Button.Visible
                Holder.Visible = (Main and Main.Visible) or (Main and Main.SubButton and Main.SubButton.Visible) or false
                Fit()
            end
            function Button:SetText(Value) Button.Text = tostring(Value); Base.Text = Button.Text; Fit() end
            function Button:SetVariant(Value)
                assert(Value == "Primary" or Value == "Secondary" or Value == "Destructive" or Value == "Ghost", "Unknown button variant")
                Button.Variant = Value; Button:UpdateColors()
            end
            function Button:SetBusy(Value, Text)
                Button.Busy = Value == true
                Base.Text = Button.Busy and tostring(Text or "Working...") or Button.Text
                Button:UpdateColors(); Fit()
            end
            function Button:Activate(Input)
                if Button.Destroyed or Library.Unloaded or Button.Disabled or Button.Busy or Button.Locked or not Button.Visible or not Library:CanInteract(Base, Input) then return false end
                if Button.DoubleClick then
                    local Now = os.clock()
                    if not Button.ArmDeadline or Now > Button.ArmDeadline then
                        Button.ArmDeadline, Button.ArmGeneration = Now + 0.8, Button.ArmGeneration + 1
                        local Generation = Button.ArmGeneration
                        Base.Text = "Click again to confirm"
                        task.delay(0.8, function()
                            if not Button.Destroyed and Base.Parent and Generation == Button.ArmGeneration then Button.ArmDeadline = nil; Base.Text = Button.Text end
                        end)
                        return false
                    end
                    Button.ArmDeadline = nil; Button.ArmGeneration += 1; Base.Text = Button.Text
                end
                Button.Locked = Button.WaitForCallback
                if Button.Locked then Base.Text = "Working..."; Button:UpdateColors() end
                Library:SafeCallback(Button.Func)
                Button.Locked = false
                if not Button.Destroyed and Base.Parent then Base.Text = Button.Text; Button:UpdateColors() end
                return true
            end
            function Button:Destroy()
                if Button.Destroyed then return end
                Library:DestroyElement(Button)
                if IsSub and Main and Main.SubButton == Button then Main.SubButton = nil end
                if Holder.Parent then Holder.Visible = Main and Main.Visible or false; Fit() end
            end
            Base.Activated:Connect(function(Input) Button:Activate(Input) end)
            Base.MouseEnter:Connect(function() Button.Hovered = true; Button:UpdateColors() end)
            Base.MouseLeave:Connect(function() Button.Hovered = false; Button:UpdateColors() end)
            Base:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
            Base:GetPropertyChangedSignal("TextSize"):Connect(Fit)
            if typeof(Data.Tooltip) == "string" or typeof(Data.DisabledTooltip) == "string" then
                Button.TooltipTable = Library:AddTooltip(Data.Tooltip, Data.DisabledTooltip, Base)
                Button.TooltipTable.Disabled = Button.Disabled
            end
            Library:TrackElement(Button, Groupbox)
            if Data.Idx ~= nil then Buttons[Data.Idx] = Button else table.insert(Buttons, Button) end
            Button:UpdateColors()
            return Button
        end
        Main = Create(Info, false)
        function Main:AddButton(...)
            if Main.SubButton then Main.SubButton:Destroy() end
            Main.SubButton = Create(ReadInfo(...), true)
            Holder.Visible = Main.Visible or Main.SubButton.Visible
            Fit()
            return Main.SubButton
        end
        Holder.Visible = Main.Visible
        table.insert(Groupbox.Elements, Main)
        Fit()
        return Main
    end

    function Funcs:AddCheckbox(Idx, Info)
        Info = Library:Validate(Info, Templates.Toggle)
        local Groupbox = self
        local Toggle = { Idx = Idx, Type = "Toggle", Text = Info.Text, Value = Info.Default, Default = Info.Default, Tooltip = Info.Tooltip, DisabledTooltip = Info.DisabledTooltip, Callback = Info.Callback, Changed = Info.Changed, Risky = Info.Risky, Disabled = Info.Disabled, Visible = Info.Visible, Addons = {}, Groupbox = Groupbox, Container = Groupbox.Container }
        local Button = New("TextButton", { Name = "BooleanRow", Active = not Toggle.Disabled, Selectable = not Toggle.Disabled, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "", Visible = Toggle.Visible, Parent = Groupbox.Container })
        local Label = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(30, 0), Size = UDim2.new(1, -30, 1, 0), Text = Toggle.Text, TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Button })
        local Checkbox = New("Frame", { Name = "RecessedCheckbox", AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = "FieldColor", Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(20, 20), Parent = Button })
        local Field = Library:Surface(Checkbox, "Field")
        local Check = Library:CreateSymbol(Checkbox, "check", UDim2.fromOffset(2, 2), 16, function() return Library:GetOnColor(Library.Scheme.AccentColor) end)
        local Focus = New("UIStroke", { Color = "AccentColor", Transparency = 1, Thickness = 1, Parent = Button })
        local function Background()
            if Toggle.Value then return Toggle.Disabled and Library.Scheme.AccentColor:Lerp(Library.Scheme.MainColor, 0.55) or Library.Scheme.AccentColor end
            return Library.Scheme.FieldColor
        end
        Library.Registry[Checkbox].BackgroundColor3 = Background
        local function Ink() return Toggle.Disabled and Library.Scheme.MutedColor or (Toggle.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor) end
        Library.Registry[Label].TextColor3 = Ink
        function Toggle:Display()
            if Toggle.Destroyed or Library.Unloaded then return end
            Checkbox.BackgroundColor3, Label.TextColor3 = Background(), Ink()
            Label.TextTransparency = 0
            Check.Visible = Toggle.Value == true
            Field.Disabled, Field.Focused = Toggle.Disabled == true, Toggle.Focused == true
            Field:Paint()
            Focus.Transparency = Toggle.Focused and not Toggle.Disabled and 0 or 1
            Button.Active, Button.Selectable = not Toggle.Disabled, not Toggle.Disabled
            Button:SetAttribute("ChiyoChecked", Toggle.Value == true)
            Button:SetAttribute("ChiyoDisabled", Toggle.Disabled == true)
        end
        function Toggle:UpdateColors() Toggle:Display() end
        function Toggle:OnChanged(Callback) Toggle.Changed = Callback end
        function Toggle:SetValue(Value)
            assert(typeof(Value) == "boolean", "Toggle value must be boolean")
            if Toggle.Destroyed or Library.Unloaded or Toggle.Value == Value then return false end
            Toggle.Value = Value; Toggle:Display()
            for _, Addon in Toggle.Addons do if Addon.Type == "KeyPicker" and Addon.SyncToggleState then Addon.Toggled = Value; Addon:Update() end end
            Library:UpdateDependencyBoxes()
            if not Toggle.Disabled then Library:SafeCallback(Toggle.Callback, Value); Library:SafeCallback(Toggle.Changed, Value) end
            Library:ObserveOptionValue(Toggle)
        end
        function Toggle:SetDisabled(Value)
            Toggle.Disabled = Value
            if Toggle.TooltipTable then Toggle.TooltipTable.Disabled = Value end
            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then Addon:Update() end
                if Value then
                    if Addon.Menu then Addon.Menu:Close() end
                    if Addon.ColorMenu then Addon.ColorMenu:Close() end
                    if Addon.CancelPicking then Addon.CancelPicking() end
                end
            end
            Toggle:Display()
        end
        function Toggle:SetVisible(Value) Toggle.Visible = Value; Button.Visible = Value; Groupbox:Resize() end
        function Toggle:SetText(Text) Toggle.Text = tostring(Text); Label.Text = Toggle.Text end
        Button.Activated:Connect(function(Input) if not Toggle.Disabled and Library:CanInteract(Button, Input) then Toggle:SetValue(not Toggle.Value) end end)
        Button.SelectionGained:Connect(function() Toggle.Focused = true; Toggle:Display() end)
        Button.SelectionLost:Connect(function() Toggle.Focused = false; Toggle:Display() end)
        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Info.Tooltip, Info.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end
        Toggle.Holder, Toggle.TextLabel, Toggle.Checkbox, Toggle.Check = Button, Label, Checkbox, Check
        Toggle.AddonContainer = Library:FitToggle(Button, Label, Groupbox, 36)
        setmetatable(Toggle, BaseAddons)
        table.insert(Groupbox.Elements, Toggle)
        Toggles[Idx] = Library:TrackElement(Toggle, Groupbox)
        Toggle:Display(); Groupbox:Resize()
        return Toggle
    end


    function Funcs:AddToggle(Idx, Info)
        return Funcs.AddCheckbox(self, Idx, Info)
    end

    function Funcs:AddInput(Idx, Info)
        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
            Sensitive = Info.Sensitive == true,
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 58),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Text = Input.Text,
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 34),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = false,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        Library:StyleField(Box)
        Input.TextBox = Box
        local ErrorLabel = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextColor3 = "RedColor", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Visible = false, Parent = Holder })
        Input.ErrorLabel = ErrorLabel
        function Input:SetError(Message)
            Input.Error = Message
            ErrorLabel.Text, ErrorLabel.Visible = tostring(Message or ""), Message ~= nil and Message ~= ""
            Library:SetFieldError(Box, Message)
            if Library.TextReflows[Holder] then Library.TextReflows[Holder]() end
        end
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency, Box.TextTransparency = 0, 0
            Label.TextColor3, Box.TextColor3 = Input.Disabled and Library.Scheme.MutedColor or Library.Scheme.FontColor, Input.Disabled and Library.Scheme.MutedColor or Library.Scheme.FontColor
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:SetValue(Text)
            if Input.Destroyed or Library.Unloaded then return end
            Text = tostring(Text or "")
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength then
                local Limit = math.max(0, math.floor(Info.MaxLength))
                local Ok, Clipped = pcall(function()
                    if Limit == 0 then return "" end
                    if utf8.graphemes then
                        local Count = 0
                        for _, Last in utf8.graphemes(Text) do Count += 1; if Count == Limit then return Text:sub(1, Last) end end
                        return Text
                    end
                    local Offset = utf8.offset(Text, Limit + 1)
                    return Offset and Text:sub(1, Offset - 1) or Text
                end)
                if Ok then Text = Clipped else Input:SetError("Text contains invalid UTF-8."); return end
            end

            local ErrorMessage
            if Input.Numeric and #Text > 0 and not IsFinite(tonumber(Text)) then
                Text = Input.Value; ErrorMessage = "Enter a finite number."
            end

            if typeof(Input.VerifyValue) == "function" and Text ~= Input.EmptyReset then
                local Ok, Accepted = pcall(Input.VerifyValue, Text)
                if not Ok or Accepted ~= true then Text = Input.EmptyReset; ErrorMessage = Info.ValidationMessage or "The entered value was rejected." end
            end
            Input:SetError(ErrorMessage)
            if Text == Input.Value then Box.Text = Text; return end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Library:SafeCallback(Input.Callback, Input.Value)
                Library:SafeCallback(Input.Changed, Input.Value)
            end
            Library:ObserveOptionValue(Input)
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            if Input.Disabled and UserInputService:GetFocusedTextBox() == Box then Box:ReleaseFocus() end
            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end)
        else
            Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end
                
                Input:SetValue(Box.Text)
            end)
        end

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        local Fitting = false
        local function Fit()
            if Fitting or not Holder.Parent or Library.Unloaded then return end
            Fitting = true
            local Width = math.max(40, Holder.AbsoluteSize.X / Library.DPIScale)
            local _, Height = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, Width)
            local _, GlyphHeight = Library:GetTextBounds("Mg", Box.FontFace, Box.TextSize, Width)
            local LabelHeight, BoxHeight = math.max(20, math.ceil(Height)), math.max(Library:Metrics().Field, math.ceil(GlyphHeight) + 14)
            local ErrorHeight = 0
            if ErrorLabel.Visible then local _, H = Library:GetTextBounds(ErrorLabel.Text, ErrorLabel.FontFace, ErrorLabel.TextSize, Width, false); ErrorHeight = H + 6 end
            Label.Size = UDim2.new(1, 0, 0, LabelHeight)
            Box.AnchorPoint, Box.Position = Vector2.zero, UDim2.fromOffset(0, LabelHeight + 5)
            Box.Size = UDim2.new(1, 0, 0, BoxHeight)
            ErrorLabel.Position = UDim2.fromOffset(0, LabelHeight + 5 + BoxHeight + 4)
            ErrorLabel.Size = UDim2.new(1, 0, 0, ErrorHeight)
            Holder.Size = UDim2.new(1, 0, 0, LabelHeight + BoxHeight + 5 + ErrorHeight)
            Fitting = false; Groupbox:Resize()
        end
        Library.TextReflows[Holder] = Fit
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        Label:GetPropertyChangedSignal("Text"):Connect(Fit)
        Label:GetPropertyChangedSignal("TextSize"):Connect(Fit)
        Label:GetPropertyChangedSignal("FontFace"):Connect(Fit)
        Fit()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input:UpdateColors()
        Input.Default = Input.Value
        if typeof(Input.VerifyValue) == "function" and Input.Default ~= Input.EmptyReset then
            local Ok, Accepted = pcall(Input.VerifyValue, Input.Default)
            if not Ok or Accepted ~= true then
                Input.Value = Input.EmptyReset
                Box.Text = Input.EmptyReset
                Input.Default = Input.EmptyReset
            end
        end
        Input.Idx = Idx

        Options[Idx] = Library:TrackElement(Input, Groupbox)

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        Info = Library:Validate(Info, Templates.Slider)
        assert(IsFinite(Info.Min) and IsFinite(Info.Max) and Info.Max > Info.Min, "Slider requires finite Min < Max")
        assert(IsFinite(Info.Rounding) and Info.Rounding >= 0 and Info.Rounding <= 10 and Info.Rounding % 1 == 0, "Invalid slider precision")
        assert(not Info.Logarithmic or Info.Min > 0, "A logarithmic slider requires a positive minimum")
        local Step = Info.Step or 10 ^ -Info.Rounding
        assert(IsFinite(Step) and Step > 0, "Step must be positive")
        local Groupbox = self
        local Slider = {
            Idx = Idx, Type = "Slider", Text = Info.Text, Min = Info.Min, Max = Info.Max,
            Rounding = Info.Rounding, Step = Step, Logarithmic = Info.Logarithmic == true,
            Prefix = Info.Prefix, Suffix = Info.Suffix, Compact = Info.Compact,
            Callback = Info.Callback, Changed = Info.Changed, Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip, Disabled = Info.Disabled, Visible = Info.Visible,
            CustomStyle = Info.Style ~= nil, Style = Info.Style or Library.SliderStyle,
        }
        local function Quantize(Value)
            if Value <= Slider.Min then return Slider.Min end
            if Value >= Slider.Max then return Slider.Max end
            local N = Slider.Min + math.floor((Value - Slider.Min) / Slider.Step + 0.5) * Slider.Step
            return math.clamp(tonumber(string.format("%.10f", N)), Slider.Min, Slider.Max)
        end
        local InitialValue = tonumber(Info.Default) or Slider.Min
        assert(IsFinite(InitialValue), "Slider default must be finite")
        Slider.Value = Quantize(InitialValue)
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Info.Compact and 54 or 72), Visible = Slider.Visible, Parent = Groupbox.Container })
        local Label = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -106, 0, 26), Text = Slider.Text, RichText = false, TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local ValueBox = New("TextBox", { FontFace = "FontMono", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "MainColor", Position = UDim2.fromScale(1, 0), Size = UDim2.fromOffset(98, 26), ClearTextOnFocus = false, TextEditable = not Slider.Disabled, TextSize = 13, Text = "", Parent = Holder })
        Library:StyleField(ValueBox)
        New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = ValueBox })
        local Bar = New("TextButton", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 30), Text = "", Active = not Slider.Disabled, Selectable = true, Parent = Holder })
        local Track = New("Frame", { AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = "OutlineColor", Position = UDim2.new(0, 7, 0.5, 0), Size = UDim2.new(1, -14, 0, 6), Parent = Bar })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })
        local Fill = New("Frame", { BackgroundColor3 = "AccentColor", Size = UDim2.fromScale(0, 1), Parent = Track })
        New("UICorner", { CornerRadius = UDim.new(0, 4), Parent = Fill })
        local ChannelGradient = New("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(170, 175, 190), Color3.new(1, 1, 1)), Enabled = false, Parent = Fill })
        local TrackStroke = New("UIStroke", { Color = "OutlineColor", Transparency = 0.25, Parent = Track })
        local Ticks = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Track })
        local Handle = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "FontColor", Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(10, 22), ZIndex = Track.ZIndex + 3, Parent = Track })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Handle })
        New("UIStroke", { Color = "OutlineColor", Thickness = 1, Parent = Handle })
        Library:Surface(Handle, "Action")
        local Bounds = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 0, 14), Text = "", TextSize = 12, TextTransparency = 0.4, TextXAlignment = Enum.TextXAlignment.Left, Visible = not Info.Compact and Info.ShowBounds ~= false, Parent = Holder })
        local MaxLabel = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", TextSize = 12, TextTransparency = 0.4, TextXAlignment = Enum.TextXAlignment.Right, Parent = Bounds })
        function Slider:ValueToRatio(Value)
            if Slider.Logarithmic then return math.clamp(math.log(Value / Slider.Min) / math.log(Slider.Max / Slider.Min), 0, 1) end
            return math.clamp((Value - Slider.Min) / (Slider.Max - Slider.Min), 0, 1)
        end
        function Slider:RatioToValue(Ratio)
            Ratio = math.clamp(Ratio, 0, 1)
            return Slider.Logarithmic and Slider.Min * (Slider.Max / Slider.Min) ^ Ratio or Slider.Min + (Slider.Max - Slider.Min) * Ratio
        end
        function Slider:Display()
            if Slider.Destroyed or Library.Unloaded then return end
            if UserInputService:GetFocusedTextBox() ~= ValueBox then
                local Custom = Info.FormatDisplayValue and Library:SafeCallback(Info.FormatDisplayValue, Slider, Slider.Value)
                ValueBox.Text = tostring(Custom or (Slider.Prefix .. tostring(Slider.Value) .. Slider.Suffix))
            end
            local Ratio = Slider:ValueToRatio(Slider.Value)
            if Slider.Initialized and not Slider.Dragging and Library.Animations.Slider then
                Library:CreateTween(Fill, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromScale(Ratio, 1) }):Play()
                Library:CreateTween(Handle, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromScale(Ratio, 0.5) }):Play()
            else
                Library:CancelMotion(Fill); Library:CancelMotion(Handle)
                Fill.Size = UDim2.fromScale(Ratio, 1)
                Handle.Position = UDim2.fromScale(Ratio, 0.5)
            end
            Bounds.Text = Slider.Prefix .. tostring(Slider.Min) .. Slider.Suffix
            MaxLabel.Text = Info.HideMax and "" or (Slider.Prefix .. tostring(Slider.Max) .. Slider.Suffix)
        end
        function Slider:UpdateColors()
            if Slider.Destroyed or Library.Unloaded then return end
            Label.TextTransparency, ValueBox.TextTransparency = 0, 0
            local Role = Slider.Disabled and "MutedColor" or "FontColor"
            Label.TextColor3, ValueBox.TextColor3 = Library.Scheme[Role], Library.Scheme[Role]
            Library.Registry[Label].TextColor3, Library.Registry[ValueBox].TextColor3 = Role, Role
            Library.SurfaceStates[ValueBox].Disabled = Slider.Disabled; Library.SurfaceStates[ValueBox]:Paint()
            Handle.BackgroundTransparency = Slider.Disabled and 0.5 or 0
            Fill.BackgroundTransparency = Slider.Disabled and 0.65 or 0
            Bar.Active = not Slider.Disabled
            Bar.Selectable = not Slider.Disabled
            ValueBox.TextEditable = not Slider.Disabled
        end
        function Slider:SetStyle(Style)
            assert(Style == "Precision" or Style == "Line" or Style == "Filled" or Style == "Stepped" or Style == "Channel", "Unknown slider style")
            Slider.Style = Style == "Stepped" and "Stepped" or "Precision"
            Track.Size, Track.Position = UDim2.new(1, -12, 0, 6), UDim2.new(0, 6, 0.5, 0)
            Handle.Visible, ChannelGradient.Enabled = true, true
            Handle.Size = UDim2.fromOffset(10 + math.floor(Library.TextSizeOffset / 2), 22 + Library.TextSizeOffset)
            Track.BackgroundColor3 = Library.Scheme.FieldColor
            Library.Registry[Track].BackgroundColor3 = "FieldColor"
            local TickKey = Slider.Style .. ":" .. tostring(Slider.Min) .. ":" .. tostring(Slider.Max) .. ":" .. tostring(Slider.Step)
            if Slider.TickKey == TickKey then return end
            Slider.TickKey = TickKey
            for _, Child in Ticks:GetChildren() do Child:Destroy() end
            if Slider.Style == "Stepped" then
                local Count = math.clamp(math.floor((Slider.Max - Slider.Min) / Slider.Step), 1, 20)
                for Index = 0, Count do New("Frame", { BackgroundColor3 = "OutlineColor", Position = UDim2.new(Index / Count, 0, 1, 4), Size = UDim2.fromOffset(1, 4), Parent = Ticks }) end
            end
        end

        function Slider:SetValue(Value)
            local Num = tonumber(Value)
            if not IsFinite(Num) or Slider.Destroyed or Library.Unloaded then return false end
            Num = Quantize(Num)
            if Num == Slider.Value then return false end
            Slider.Value = Num
            Slider:Display()
            if not Slider.Disabled then
                Library:SafeCallback(Slider.Callback, Num)
                Library:SafeCallback(Slider.Changed, Num)
            end
            Library:ObserveOptionValue(Slider)
            return true
        end
        function Slider:SetMin(Value)
            assert(IsFinite(Value) and Value < Slider.Max and (not Slider.Logarithmic or Value > 0), "Invalid minimum")
            Slider.Min = Value; Slider:SetValue(Slider.Value); Slider:SetStyle(Slider.Style); Slider:Display()
        end
        function Slider:SetMax(Value)
            assert(IsFinite(Value) and Value > Slider.Min, "Invalid maximum")
            Slider.Max = Value; Slider:SetValue(Slider.Value); Slider:SetStyle(Slider.Style); Slider:Display()
        end
        function Slider:SetText(Text) Slider.Text = tostring(Text); Label.Text = Slider.Text end
        function Slider:SetPrefix(Value) Slider.Prefix = tostring(Value); Slider:Display() end
        function Slider:SetSuffix(Value) Slider.Suffix = tostring(Value); Slider:Display() end
        function Slider:OnChanged(Callback) Slider.Changed = Callback end
        function Slider:SetDisabled(Value)
            Slider.Disabled = Value == true
            if Slider.Disabled and Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == Bar then Library:StopPointerDrag("disabled") end
            if Slider.TooltipTable then Slider.TooltipTable.Disabled = Slider.Disabled end
            Slider:UpdateColors()
        end
        function Slider:SetVisible(Value) Slider.Visible = Value ~= false; Holder.Visible = Slider.Visible; if not Slider.Visible and Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == Bar then Library:StopPointerDrag("hidden") end; Groupbox:Resize() end
        ValueBox.Focused:Connect(function() if not Slider.Disabled then ValueBox.Text = tostring(Slider.Value) end end)
        local ErrorLabel = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextColor3 = "RedColor", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Visible = false, Parent = Holder })
        function Slider:SetError(Message)
            Slider.Error = Message
            ErrorLabel.Text, ErrorLabel.Visible = tostring(Message or ""), Message ~= nil and Message ~= ""
            Library:SetFieldError(ValueBox, Message)
            if Library.TextReflows[Holder] then Library.TextReflows[Holder]() end
        end
        ValueBox.FocusLost:Connect(function()
            if not Slider.Disabled then
                if IsFinite(tonumber(ValueBox.Text)) then Slider:SetError(nil); Slider:SetValue(ValueBox.Text)
                else Slider:SetError("Enter a finite number between " .. tostring(Slider.Min) .. " and " .. tostring(Slider.Max) .. ".") end
            end
            Slider:Display()
        end)
        Bar.InputBegan:Connect(function(Input)
            if Slider.Disabled or not Library:CanInteract(Bar, Input) then return end
            local Key = Input.KeyCode
            if Key == Enum.KeyCode.Left or Key == Enum.KeyCode.Down or Key == Enum.KeyCode.DPadLeft then Slider:SetValue(Slider.Value - Slider.Step); return end
            if Key == Enum.KeyCode.Right or Key == Enum.KeyCode.Up or Key == Enum.KeyCode.DPadRight then Slider:SetValue(Slider.Value + Slider.Step); return end
            if Key == Enum.KeyCode.Home then Slider:SetValue(Slider.Min); return end
            if Key == Enum.KeyCode.End then Slider:SetValue(Slider.Max); return end
            if not IsClickInput(Input) then return end
            Slider.Dragging = true
            Library:CancelMotion(Fill); Library:CancelMotion(Handle)
            local Sides = (Groupbox.Tab and Groupbox.Tab.Sides) or Groupbox.Sides or {}
            local Began = Library:BeginPointerDrag(Bar, Input, function(Point)
                if Slider.Disabled then Library:StopPointerDrag("disabled"); return end
                if Track.AbsoluteSize.X > 0 then Slider:SetValue(Slider:RatioToValue((Point.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X)) end
            end, function() Slider.Dragging = false end, Sides)
            if not Began then Slider.Dragging = false end
        end)
        Bar.MouseEnter:Connect(function()
            if not Slider.Disabled then TrackStroke.Color = Library.Scheme.AccentColor; TrackStroke.Transparency = 0.15 end
        end)
        Bar.MouseLeave:Connect(function() TrackStroke.Color = Library.Scheme.OutlineColor; TrackStroke.Transparency = 0.25 end)
        local Fitting = false
        local function Fit()
            if Fitting or not Holder.Parent or Library.Unloaded then return end
            Fitting = true
            local Width = math.max(100, Holder.AbsoluteSize.X / Library.DPIScale)
            local ValueTextWidth = Library:GetTextBounds(ValueBox.Text, ValueBox.FontFace, ValueBox.TextSize, nil, false)
            local ValueWidth = math.min(math.max(86, ValueTextWidth + 16), math.max(86, Width * 0.46))
            local _, Height = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, math.max(40, Width - ValueWidth - 12), false)
            local HeaderHeight = math.max(Library:Metrics().Field, math.ceil(Height + 6))
            Label.Size = UDim2.new(1, -ValueWidth - 12, 0, HeaderHeight)
            ValueBox.Size = UDim2.fromOffset(ValueWidth, HeaderHeight)
            local Target = Library:Metrics().Target
            Bar.Position, Bar.Size = UDim2.fromOffset(0, HeaderHeight + 2), UDim2.new(1, 0, 0, Target)
            local BW = math.max(40, Width / 2 - 6)
            local _, LH = Library:GetTextBounds(Bounds.Text, Bounds.FontFace, Bounds.TextSize, BW, false)
            local _, RH = Library:GetTextBounds(MaxLabel.Text, MaxLabel.FontFace, MaxLabel.TextSize, BW, false)
            local BoundsHeight = math.max(LH, RH, Bounds.TextSize + 3)
            Bounds.TextWrapped, MaxLabel.TextWrapped = true, true
            Bounds.Position, Bounds.Size = UDim2.fromOffset(0, HeaderHeight + Target + 4), UDim2.new(0.5, -6, 0, BoundsHeight)
            MaxLabel.Parent = Holder
            MaxLabel.Position, MaxLabel.Size, MaxLabel.Visible = UDim2.new(0.5, 6, 0, HeaderHeight + Target + 4), UDim2.new(0.5, -6, 0, BoundsHeight), Bounds.Visible
            local Bottom = HeaderHeight + Target + 4 + (Bounds.Visible and BoundsHeight + 4 or 0)
            local ErrorHeight = 0
            if ErrorLabel.Visible then local _, H = Library:GetTextBounds(ErrorLabel.Text, ErrorLabel.FontFace, ErrorLabel.TextSize, Width, false); ErrorHeight = H + 6 end
            ErrorLabel.Position, ErrorLabel.Size = UDim2.fromOffset(0, Bottom), UDim2.new(1, 0, 0, ErrorHeight)
            Holder.Size = UDim2.new(1, 0, 0, Bottom + ErrorHeight)
            Slider:SetStyle(Slider.Style)
            Fitting = false
            Groupbox:Resize()
        end
        Library.TextReflows[Holder] = Fit
        Library.VisualRefreshers[Holder] = function() Slider:UpdateColors() end
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        ValueBox:GetPropertyChangedSignal("Text"):Connect(Fit)
        Bounds:GetPropertyChangedSignal("Text"):Connect(Fit)
        MaxLabel:GetPropertyChangedSignal("Text"):Connect(Fit)
        Label:GetPropertyChangedSignal("Text"):Connect(Fit)
        Label:GetPropertyChangedSignal("TextSize"):Connect(Fit)
        Label:GetPropertyChangedSignal("FontFace"):Connect(Fit)
        Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Label)
        Slider.TooltipTable.Disabled = Slider.Disabled
        Slider.Holder, Slider.Bar, Slider.Fill, Slider.Handle, Slider.ValueBox = Holder, Bar, Fill, Handle, ValueBox
        Slider.TextLabel = Label
        Slider.Default = Slider.Value
        Slider:SetStyle(Slider.Style); Slider:UpdateColors(); Slider:Display()
        table.insert(Groupbox.Elements, Slider)
        Options[Idx] = Library:TrackElement(Slider, Groupbox)
        Slider.Initialized = true
        Fit()
        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        Info = Library:Validate(Info, Templates.Dropdown)
        local Owner = self
        local Priority, Multi = Info.Priority == true, Info.Multi == true and Info.Priority ~= true
        if Info.SpecialType == "Player" then Info.Values = GetPlayers(Info.ExcludeLocalPlayer); Info.AllowNull = true
        elseif Info.SpecialType == "Team" then Info.Values = GetTeams(); Info.AllowNull = true end
        local function DecodeValues(Source)
            assert(typeof(Source) == "table", "Dropdown values must be an array or a string-keyed dictionary")
            local Values, Labels, Members, Keys, Dictionary = {}, {}, {}, {}, false
            for Key in Source do if typeof(Key) ~= "number" then Dictionary = true end; table.insert(Keys, Key) end
            if Dictionary then
                for _, Key in Keys do assert(typeof(Key) == "string", "Dictionary option IDs must be strings") end
                table.sort(Keys, function(A, B) if A:lower() == B:lower() then return A < B end; return A:lower() < B:lower() end)
            else
                for _, Key in Keys do assert(IsFinite(Key) and Key >= 1 and Key % 1 == 0, "Invalid array index") end
                table.sort(Keys)
            end
            for _, Key in Keys do
                local Value = Dictionary and Key or Source[Key]
                assert(Value ~= nil and (typeof(Value) ~= "number" or IsFinite(Value)), "Dropdown identities must be finite")
                if not Members[Value] then Members[Value] = true; table.insert(Values, Value); Labels[Value] = Dictionary and tostring(Source[Key]) or tostring(Value) end
            end
            return Values, Labels, Members, Dictionary
        end
        local Values, LabelsForValues, Members, Dictionary = DecodeValues(Info.Values)
        local D = {
            Idx = Idx, Type = Priority and "PriorityDropdown" or "Dropdown", Priority = Priority, Multi = Multi,
            Text = typeof(Info.Text) == "string" and Info.Text or nil, Values = Values, ValueLabels = LabelsForValues,
            IsDictionary = Dictionary, DisabledValues = {}, Value = (Multi or Priority) and {} or nil,
            DefaultValues = table.clone(Info.Values), FormatListValue = Info.FormatListValue,
            Callback = Info.Callback, Changed = Info.Changed, Tooltip = Info.Tooltip, DisabledTooltip = Info.DisabledTooltip,
            Disabled = Info.Disabled == true, Visible = Info.Visible ~= false, SpecialType = Info.SpecialType,
            ExcludeLocalPlayer = Info.ExcludeLocalPlayer, Expandable = Info.Expandable ~= false,
            ExpandColumns = math.clamp(math.floor(tonumber(Info.ExpandColumns) or 3), 1, 6),
            ValueImages = table.clone(Info.ValueImages or {}), BatchSelection = Info.BatchSelection == true,
            DraftActive = false, Query = "", OnlySelected = false, StatusMessage = "",
        }
        local DisabledSet, Formatted = {}, {}
        local Compact, Expanded, ExpandedBackdrop, ExpandedPanel
        local Menu
        local Holder = New("Frame", { Name = "Dropdown", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 64), Visible = D.Visible, Parent = Owner.Container })
        local Label = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextWrapped = true, TextSize = 15, Text = D.Text or "",
            TextXAlignment = Enum.TextXAlignment.Left, Visible = D.Text ~= nil, Size = UDim2.new(1, 0, 0, 22), Parent = Holder })
        local Display = New("TextButton", { Name = "DropdownField", BackgroundColor3 = "FieldColor", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, -42, 0, 36), Text = "", Parent = Holder })
        Library:StyleField(Display)
        local DisplayLabel = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextSize = 15, Text = "", TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -42, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = Display })
        local Remainder = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextSize = 14, TextColor3 = "MutedColor", Text = "", TextXAlignment = Enum.TextXAlignment.Right,
            AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -36, 0, 0), Size = UDim2.new(0, 0, 1, 0), Visible = false, Parent = Display })
        local Arrow = Library:CreateSymbol(Display, "chevron-down", UDim2.new(1, -27, 0.5, -9), 18)
        local ExpandButton = New("TextButton", { Name = "ExpandOptions", AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = "HeaderColor", Position = UDim2.fromScale(1, 1),
            Size = UDim2.fromOffset(36, 36), Text = "", Visible = D.Expandable, Parent = Holder })
        Library:StyleAction(ExpandButton, "Secondary", D.Disabled, false)
        Library:CreateSymbol(ExpandButton, "expand", UDim2.new(0.5, -9, 0.5, -9), 18)
        Library:AddTooltip("Open the larger option browser", "This control is disabled.", ExpandButton)
        D.Holder, D.TextLabel, D.DisplayLabel, D.ExpandButton, D.DisplayButton, D.RemainderLabel = Holder, Label, DisplayLabel, ExpandButton, Display, Remainder
        local function Copy(Value) return typeof(Value) == "table" and table.clone(Value) or Value end
        local function Same(A, B)
            if typeof(A) ~= "table" or typeof(B) ~= "table" then return A == B end
            for Key, Value in A do if B[Key] ~= Value then return false end end
            for Key, Value in B do if A[Key] ~= Value then return false end end
            return true
        end
        local function Format(Value, Formatter)
            local Caption = D.ValueLabels[Value] or tostring(Value)
            if typeof(Formatter) == "function" then local Ok, Text = pcall(Formatter, Value, Caption); if Ok and Text ~= nil then return tostring(Text) end end
            return Caption
        end
        local function Working() if D.DraftActive then return D.DraftValue end; return D.Value end
        local function Normalize(Value)
            if Priority then
                local Order, Seen = {}, {}
                for _, Item in typeof(Value) == "table" and Value or {} do if Members[Item] and not Seen[Item] then Seen[Item] = true; table.insert(Order, Item) end end
                for _, Item in D.Values do if not Seen[Item] then Seen[Item] = true; table.insert(Order, Item) end end
                return Order
            elseif Multi then
                if typeof(Value) == "string" then Value = Value ~= "" and { Value } or {} end
                if Value ~= nil and typeof(Value) ~= "table" then return nil end
                local Selected = {}
                for Key, Item in Value or {} do
                    local Candidate = typeof(Item) == "boolean" and Key or Item
                    if Item ~= false and Members[Candidate] then Selected[Candidate] = true end
                end
                return Selected
            end
            if Value ~= nil and not Members[Value] then return D.Value end
            return Value
        end
        local function Count(Value)
            if Priority then return #Value end
            if Multi then return GetTableSize(Value) end
            return Value ~= nil and 1 or 0
        end
        local function Selected(Value, Selection)
            if Priority then return D.PrioritySelection == Value end
            return Multi and Selection[Value] == true or not Multi and Selection == Value
        end
        local function NullAllowed(Next, Previous)
            local Empty = Multi and next(Next) == nil or not Multi and not Priority and Next == nil
            return not Empty or Info.AllowNull or Count(Previous) == 0
        end
        local Refresh
        local function Emit()
            Library:UpdateDependencyBoxes()
            if not D.Disabled then Library:SafeCallback(D.Callback, D.Value); Library:SafeCallback(D.Changed, D.Value) end
            Library:ObserveOptionValue(D)
        end
        function D:Display()
            if D.Destroyed or Library.Unloaded then return end
            local Captions = {}
            if Priority then if D.Value[1] ~= nil then table.insert(Captions, Format(D.Value[1], Info.FormatDisplayValue)) end
            elseif Multi then for _, Value in D.Values do if D.Value[Value] then table.insert(Captions, Format(Value, Info.FormatDisplayValue)) end end
            elseif D.Value ~= nil then table.insert(Captions, Format(D.Value, Info.FormatDisplayValue)) end
            local M = Library:Metrics()
            local Available = math.max(30, Display.AbsoluteSize.X / Library.DPIScale - M.Icon - 30)
            local Total, Prefix, FitCount = #Captions, "", 0
            if Multi and Total > 1 then
                for Index, Caption in Captions do
                    local Next = Prefix == "" and Caption or Prefix .. ", " .. Caption
                    local More = Index < Total and ("+" .. tostring(Total - Index) .. " more") or ""
                    local X = Library:GetTextBounds(Next, DisplayLabel.FontFace, DisplayLabel.TextSize, nil, false)
                    local Y = More ~= "" and Library:GetTextBounds(More, Remainder.FontFace, Remainder.TextSize, nil, false) + 8 or 0
                    if X + Y > Available then break end
                    Prefix, FitCount = Next, Index
                end
                if FitCount == 0 then Prefix, FitCount = Captions[1], 1 end
            else Prefix, FitCount = Captions[1] or (Info.Placeholder or "Choose…"), Total end
            local Rest = Total - FitCount
            Remainder.Text, Remainder.Visible = Rest > 0 and ("+" .. tostring(Rest) .. " more") or "", Rest > 0
            local MoreWidth = Rest > 0 and Library:GetTextBounds(Remainder.Text, Remainder.FontFace, Remainder.TextSize, nil, false) or 0
            Remainder.Size = UDim2.new(0, MoreWidth, 1, 0)
            Remainder.Position = UDim2.new(1, -M.Icon - 20, 0, 0)
            DisplayLabel.Text = Prefix
            DisplayLabel.Size = UDim2.new(1, -M.Icon - 30 - (Rest > 0 and MoreWidth + 8 or 0), 1, 0)
            DisplayLabel.TextColor3 = (D.Disabled or Total == 0) and Library.Scheme.MutedColor or Library.Scheme.FontColor
            DisplayLabel.TextTransparency = 0
            Arrow.Position = UDim2.new(1, -M.Icon - 10, 0.5, -M.Icon / 2)
        end
        function D:UpdateColors()
            Label.TextColor3 = D.Disabled and Library.Scheme.MutedColor or Library.Scheme.FontColor
            Display.Active, Display.Selectable = not D.Disabled, not D.Disabled
            Library:StyleAction(ExpandButton, "Secondary", D.Disabled, false)
            local State = Library.SurfaceStates[Display]; if State then State.Disabled = D.Disabled; State:Paint() end
            D:Display()
            if Refresh then Refresh(false) end
        end
        function D:SetValue(Value)
            if D.Destroyed or Library.Unloaded then return false end
            local Next = Normalize(Value)
            if Multi and Next == nil then return false end
            if not NullAllowed(Next, D.Value) then return false end
            if D.DraftActive and not D.ApplyingDraft then
                D.DraftValue = Copy(Next)
                D.StatusMessage = "Selection changed externally. The draft has restarted."
            end
            if Same(Next, D.Value) then if Refresh then Refresh(true) end; return false end
            D.Value = Next
            if Priority then D.OrderedValue = Next end
            D:Display(); if Refresh then Refresh(true) end; Emit()
            return true
        end
        function D:BeginSelection()
            if not D.BatchSelection or D.Destroyed then return false end
            if not D.DraftActive then D.DraftActive = true; D.DraftValue = Copy(D.Value); D.StatusMessage = "Changes are pending until Apply." end
            return true
        end
        function D:GetDraftValue() if D.DraftActive then return Copy(D.DraftValue) end; return nil end
        function D:HasDraft() return D.DraftActive end
        function D:SetDraftValue(Value)
            if not D.BatchSelection or not D.DraftActive or D.Disabled or D.Destroyed then return false end
            local Next = Normalize(Value)
            if Multi and Next == nil or not NullAllowed(Next, Working()) then return false end
            if Same(Next, D.DraftValue) then return false end
            D.DraftValue = Next
            D.StatusMessage = "Changes are pending until Apply."
            if Refresh then Refresh(true) end
            return true
        end
        local function Change(Value)
            if D.DraftActive then return D:SetDraftValue(Value) end
            return D:SetValue(Value)
        end
        local function Results(Query, OnlySelected)
            Query = tostring(Query or ""):lower()
            local Rows, State = {}, Working()
            for Rank, Value in Priority and State or D.Values do
                local Text = Formatted[Value]
                if not Text then Text = Format(Value, D.FormatListValue); Formatted[Value] = Text end
                local Score = SearchScore(Text, Query)
                if D.IsDictionary then Score = math.max(Score, SearchScore(tostring(Value), Query)) end
                if Score > 0 and (not OnlySelected or Selected(Value, State)) then
                    local Image = D.ValueImages[Value]
                    if D.SpecialType == "Player" and Info.EnablePlayerImages and typeof(Value) == "Instance" then Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(Value.UserId) .. "&w=48&h=48" end
                    table.insert(Rows, { Key = Value, Value = Value, Text = Text, Rank = Rank, Score = Score, Image = Image })
                end
            end
            if not Priority and Query ~= "" then table.sort(Rows, function(A, B) if A.Score == B.Score then return A.Rank < B.Rank end; return A.Score > B.Score end) end
            return Rows
        end
        local function CanMove(Value, Offset)
            if not Priority or D.Disabled or Value == nil or DisabledSet[Value] then return false end
            local State = Working()
            local Index = table.find(State, Value)
            if not Index then return false end
            local Target = math.clamp(Index + math.floor(Offset), 1, #State)
            if Target == Index then return false end
            for Cursor = math.min(Index, Target), math.max(Index, Target) do if DisabledSet[State[Cursor]] then return false end end
            return true, Index, Target
        end
        function D:Move(Value, Offset)
            if D.Destroyed or not IsFinite(Offset) then return false end
            local Allowed, Index, Target = CanMove(Value, Offset)
            if not Allowed then return false end
            local Order = table.clone(Working())
            table.remove(Order, Index); table.insert(Order, Target, Value)
            return Change(Order)
        end
        function D:MoveToTop(Value) return D:Move(Value, -#Working()) end
        function D:MoveToBottom(Value) return D:Move(Value, #Working()) end
        local function Choose(Entry)
            if not Entry or D.Disabled or D.Destroyed or DisabledSet[Entry.Key] then return false end
            if Priority then D.PrioritySelection = Entry.Key; if Refresh then Refresh(false) end; return true end
            local State = Working()
            if Multi then
                local Next = table.clone(State); Next[Entry.Key] = not Next[Entry.Key] and true or nil
                return Change(Next)
            end
            local Value = Entry.Key
            if State == Value and Info.AllowNull then Value = nil end
            local Changed = Change(Value)
            if not D.DraftActive then D:Collapse() end
            return Changed
        end
        function D:Choose(Value) return Members[Value] and Choose({ Key = Value }) or false end
        local function Bulk(Action, Filter)
            if not Multi or D.Disabled or D.Destroyed then return false end
            local Explicit = Filter ~= nil
            local Next = table.clone(Working())
            for _, Entry in Results(Explicit and Filter or D.Query, not Explicit and D.OnlySelected or false) do
                if not DisabledSet[Entry.Key] then
                    if Action == "select" then Next[Entry.Key] = true elseif Action == "clear" then Next[Entry.Key] = nil else Next[Entry.Key] = not Next[Entry.Key] and true or nil end
                end
            end
            return Change(Next)
        end
        function D:SelectAll(Filter) return Bulk("select", Filter) end
        function D:DeselectAll(Filter) return Bulk("clear", Filter) end
        function D:InvertSelection(Filter) return Bulk("invert", Filter) end
        function D:GetValue() return Copy(D.Value) end
        function D:GetActiveValues(ReturnCount)
            if ReturnCount == true or ReturnCount == nil and not Multi then return Count(D.Value) end
            if Priority then return table.clone(D.Value) end
            local Active = {}; for _, Value in D.Values do if Selected(Value, D.Value) then table.insert(Active, Value) end end
            return Active
        end
        function D:GetValueLabel(Value) return D.ValueLabels[Value] end

        local function CreateSurface(Parent, IsExpanded)
            local S = { Expanded = IsExpanded, Parent = Parent, Rows = {}, PriorityButtons = {}, Syncing = false }
            local Canvas = New("ScrollingFrame", { Name = "OptionBrowser", BackgroundTransparency = 1, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.None,
                ScrollBarThickness = 0, ScrollBarImageColor3 = "OutlineColor", ScrollingDirection = Enum.ScrollingDirection.Y, Size = UDim2.fromScale(1, 1), Parent = Parent })
            S.Canvas = Canvas
            if IsExpanded then
                S.Title = New("TextLabel", { BackgroundTransparency = 1, RichText = false, FontFace = "FontBold", TextSize = 17, TextWrapped = true, Text = D.Text or (Priority and "Priority order" or "Choose options"),
                    Position = UDim2.fromOffset(12, 6), TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
                S.Close = New("TextButton", { BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 6), Size = UDim2.fromOffset(36, 36), Parent = Canvas })
                Library:CreateSymbol(S.Close, "x", UDim2.new(0.5, -9, 0.5, -9), 18)
                Library:AddTooltip("Close without applying pending changes", "", S.Close)
                S.Close.Activated:Connect(function() D:Collapse() end)
            end
            if Info.Searchable ~= false or IsExpanded then
                S.Search = New("TextBox", { Name = "OptionSearch", BackgroundColor3 = "FieldColor", ClearTextOnFocus = false, TextSize = 15, Text = D.Query,
                    PlaceholderText = "Search options…", TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
                Library:StyleField(S.Search)
                New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = S.Search })
                S.Search:GetPropertyChangedSignal("Text"):Connect(function()
                    if S.Syncing then return end
                    D.Query = S.Search.Text
                    D.QueryGeneration = (D.QueryGeneration or 0) + 1
                    local Generation = D.QueryGeneration
                    Library:CancelTask(D.FilterTask)
                    D.FilterTask = Library:DeferOwned(Holder, 0.055, function()
                        D.FilterTask = nil
                        if D.QueryGeneration == Generation then Refresh(true, true) end
                    end)
                end)
            end
            S.Count = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
            if Multi then
                S.Scope = New("TextLabel", { BackgroundTransparency = 1, Text = "Actions affect matching choices", RichText = false, TextSize = 14, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
                S.Tools = New("Frame", { BackgroundTransparency = 1, Parent = Canvas })
                for Index, Action in { { "Select", "select" }, { "Clear", "clear" }, { "Invert", "invert" } } do
                    local B = New("TextButton", { Text = Action[1], TextSize = 15, RichText = false, Position = UDim2.new((Index - 1) / 3, 2, 0, 0), Size = UDim2.new(1 / 3, -4, 1, 0), Parent = S.Tools })
                    Library:StyleAction(B, "Secondary", false, false)
                    B.Activated:Connect(function(Input) if Library:CanInteract(B, Input) then Bulk(Action[2]) end end)
                    Library:AddTooltip(Action[1] .. " matching choices. Disabled and out-of-filter choices are unchanged.", "", B)
                end
                S.SelectedOnly = New("TextButton", { Text = "Selected only", RichText = false, TextSize = 14, Parent = Canvas })
                Library:StyleAction(S.SelectedOnly, "Secondary", false, false)
                S.SelectedOnly.Activated:Connect(function(Input)
                    if Library:CanInteract(S.SelectedOnly, Input) then D.OnlySelected = not D.OnlySelected; Refresh(true, true) end
                end)
            elseif Priority then
                S.SelectionLabel = New("TextLabel", { BackgroundTransparency = 1, RichText = false, TextWrapped = true, Text = "Select a row to move it.", TextSize = 14,
                    TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
                S.Tools = New("Frame", { BackgroundTransparency = 1, Parent = Canvas })
                for Index, Action in { { "Up", -1, "Move up one rank" }, { "Down", 1, "Move down one rank" }, { "Top", -math.huge, "Move to top" }, { "Bottom", math.huge, "Move to bottom" } } do
                    local B = New("TextButton", { Text = Action[1], RichText = false, TextSize = 15, Position = UDim2.new((Index - 1) / 4, 2, 0, 0), Size = UDim2.new(0.25, -4, 1, 0), Parent = S.Tools })
                    S.PriorityButtons[Index] = { Button = B, Offset = Action[2] }
                    Library:StyleAction(B, "Secondary", true, false)
                    Library:AddTooltip(Action[3] .. " in the complete order. Hidden matches retain their relative order; disabled ranks cannot be crossed.", "Select a movable row.", B)
                    B.Activated:Connect(function(Input)
                        if not Library:CanInteract(B, Input) or D.PrioritySelection == nil then return end
                        local Offset = Action[2]
                        if Offset == -math.huge then Offset = -#Working() elseif Offset == math.huge then Offset = #Working() end
                        D:Move(D.PrioritySelection, Offset)
                    end)
                end
            end
            local V = Library:CreateVirtualList(Canvas, {
                Priority = Priority, KeyboardFocus = true,
                IsOpen = function() return not D.Destroyed and (IsExpanded and ExpandedBackdrop ~= nil or not IsExpanded and Menu and Menu.Active) end,
                Columns = function(Width) return IsExpanded and not Priority and math.min(D.ExpandColumns, math.max(1, math.floor(Width / (240 + Library.TextSizeOffset * 16)))) or 1 end,
                IsDisabled = function(Entry) return D.Disabled or DisabledSet[Entry.Key] == true end,
                IsSelected = function(Entry) return Selected(Entry.Key, Working()) end,
                Activate = function(Entry) Choose(Entry) end,
                HandleInput = function(Input) return S:Handle(Input) end,
            })
            S.View, S.List, S.Pool = V, V.Frame, V.Pool
            if D.BatchSelection then
                S.Message = New("TextLabel", { BackgroundTransparency = 1, Text = "", TextSize = 14, RichText = false, TextWrapped = true, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, Parent = Canvas })
                S.Footer = New("Frame", { BackgroundTransparency = 1, Parent = Canvas })
                S.Cancel = New("TextButton", { Text = "Cancel", TextSize = 15, RichText = false, Size = UDim2.new(0.5, -3, 1, 0), Parent = S.Footer })
                S.Apply = New("TextButton", { Text = "Apply", TextSize = 15, RichText = false, Position = UDim2.new(0.5, 3, 0, 0), Size = UDim2.new(0.5, -3, 1, 0), Parent = S.Footer })
                Library:StyleAction(S.Cancel, "Secondary", false, false); Library:StyleAction(S.Apply, "Primary", false, false)
                S.Cancel.Activated:Connect(function() D:CancelSelection() end)
                S.Apply.Activated:Connect(function(Input) if Library:CanInteract(S.Apply, Input) then D:ApplySelection() end end)
            end
            function S:IsOpen() return not D.Destroyed and (IsExpanded and ExpandedBackdrop ~= nil or not IsExpanded and Menu and Menu.Active) end
            function S:Layout()
                if S.Layouting or not Parent.Parent or D.Destroyed then return end
                S.Layouting = true
                local M = Library:Metrics()
                local _, Available = Library:GetUsableRect()
                local W = IsExpanded and Parent.Size.X.Offset or math.min(math.max(280, Holder.AbsoluteSize.X / Library.DPIScale), Available.X / Library.DPIScale)
                local Top = 8
                if S.Title then
                    local _, H = Library:GetTextBounds(S.Title.Text, S.Title.FontFace, S.Title.TextSize, math.max(40, W - M.Target - 36), false)
                    local TH = math.max(M.Target, H + 8)
                    S.Title.Size = UDim2.new(1, -M.Target - 36, 0, TH)
                    S.Close.Size = UDim2.fromOffset(M.Target, M.Target)
                    Top = TH + 12
                end
                if S.Search then S.Search.Position = UDim2.fromOffset(8, Top); S.Search.Size = UDim2.new(1, -16, 0, M.Field); Top += M.Field + 8 end
                if Multi then
                    S.Scope.TextWrapped = true
                    local _, ScopeHeight = Library:GetTextBounds(S.Scope.Text, S.Scope.FontFace, S.Scope.TextSize, math.max(40, W - 20), false)
                    S.Scope.Position, S.Scope.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, ScopeHeight)
                    Top += ScopeHeight + 6
                    S.Tools.Position, S.Tools.Size = UDim2.fromOffset(8, Top), UDim2.new(1, -16, 0, M.Target)
                    Top += M.Target + 6
                elseif Priority then
                    local Caption = D.PrioritySelection ~= nil and ("Move: " .. Format(D.PrioritySelection, D.FormatListValue)) or "Select a row. Moves use the complete order."
                    S.SelectionLabel.Text = Caption
                    local _, H = Library:GetTextBounds(Caption, S.SelectionLabel.FontFace, S.SelectionLabel.TextSize, math.max(40, W - 20), false)
                    S.SelectionLabel.Position, S.SelectionLabel.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, H + 6)
                    Top += H + 8
                    local MinimumButton = 0
                    for _, Action in S.PriorityButtons do MinimumButton = math.max(MinimumButton, Library:GetTextBounds(Action.Button.Text, Action.Button.FontFace, Action.Button.TextSize, 0, false) + 20) end
                    local Columns = (W - 16) / 4 >= MinimumButton and 4 or 2
                    local ToolHeight = Columns == 4 and M.Target or M.Target * 2 + 6
                    S.Tools.Position, S.Tools.Size = UDim2.fromOffset(8, Top), UDim2.new(1, -16, 0, ToolHeight)
                    for Index, Action in S.PriorityButtons do
                        Action.Button.Position = UDim2.new(((Index - 1) % Columns) / Columns, 2, 0, math.floor((Index - 1) / Columns) * (M.Target + 6))
                        Action.Button.Size = UDim2.new(1 / Columns, -4, 0, M.Target)
                    end
                    Top += ToolHeight + 6
                end
                S.Count.Text = string.format("%d matching / %d available%s", #S.Rows, #D.Values, Multi and (" / " .. Count(Working()) .. " selected") or "")
                local OnlyWidth = S.SelectedOnly and Library:GetTextBounds("Selected only", S.SelectedOnly.FontFace, S.SelectedOnly.TextSize, 0, false) + 18 or 0
                local CountWidth = math.max(40, W - 20 - (S.SelectedOnly and OnlyWidth + 8 or 0))
                local CountOnOwnRow = S.SelectedOnly and CountWidth < 180
                if CountOnOwnRow then CountWidth = W - 20 end
                local _, CountH = Library:GetTextBounds(S.Count.Text, S.Count.FontFace, S.Count.TextSize, CountWidth, false)
                local CountHeight = math.max(M.Target - 4, CountH + 4)
                S.Count.TextWrapped = true
                S.Count.Position, S.Count.Size = UDim2.fromOffset(10, Top), UDim2.fromOffset(CountWidth, CountHeight)
                if S.SelectedOnly then
                    S.SelectedOnly.Position = CountOnOwnRow and UDim2.fromOffset(8, Top + CountHeight + 4) or UDim2.new(1, -OnlyWidth - 8, 0, Top)
                    S.SelectedOnly.Size = UDim2.fromOffset(math.min(OnlyWidth, W - 16), M.Target)
                end
                Top += CountHeight + 6 + (CountOnOwnRow and M.Target + 6 or 0)
                local MH = 0
                if S.Message then
                    S.Message.Text = D.StatusMessage
                    local _, H = Library:GetTextBounds(S.Message.Text, S.Message.FontFace, S.Message.TextSize, math.max(40, W - 20), false)
                    MH = H + 10
                end
                local FooterHeight = S.Footer and M.Target + MH + 8 or 0
                local Limit = math.clamp(math.floor(tonumber(Info.MaxVisibleDropdownItems) or 8), 1, 30)
                local Preferred = math.max(56, math.min(#S.Rows, Limit) * (M.Target + 4))
                local MaxHeight = IsExpanded and Parent.Size.Y.Offset or Available.Y / Library.DPIScale
                local Height = IsExpanded and math.max(56, MaxHeight - Top - FooterHeight - 10) or math.min(Preferred, math.max(56, MaxHeight - Top - FooterHeight - 10))
                V.Frame.Position, V.Frame.Size = UDim2.fromOffset(8, Top), UDim2.new(1, -16, 0, Height)
                Top += Height + 6
                if S.Message then S.Message.Position, S.Message.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 0, MH); Top += MH end
                if S.Footer then S.Footer.Position, S.Footer.Size = UDim2.fromOffset(8, Top), UDim2.new(1, -16, 0, M.Target); Top += M.Target + 8 end
                local ContentHeight = Top + 4
                if not IsExpanded then Menu:SetSize(UDim2.fromOffset(W, math.min(ContentHeight, MaxHeight))) end
                Canvas.CanvasSize = UDim2.fromOffset(0, ContentHeight)
                Canvas.ScrollingEnabled = ContentHeight > MaxHeight + 1
                Canvas.ScrollBarThickness = Canvas.ScrollingEnabled and 4 or 0
                S.Layouting = false
                V:Paint()
            end
            function S:Paint()
                if not S:IsOpen() then return end
                S.Count.Text = tostring(#S.Rows) .. (D.Query ~= "" and " matches" or " choices") .. (Multi and (" / " .. Count(Working()) .. " selected") or "")
                if S.SelectedOnly then Library:StyleAction(S.SelectedOnly, D.OnlySelected and "Primary" or "Secondary", false, false) end
                for _, Action in S.PriorityButtons do
                    local Offset = Action.Offset == -math.huge and -#Working() or Action.Offset == math.huge and #Working() or Action.Offset
                    Library:StyleAction(Action.Button, "Secondary", not CanMove(D.PrioritySelection, Offset), false)
                end
                V:Paint()
            end
            function S:Refresh(Reset)
                if not S:IsOpen() then return end
                if S.Search and S.Search.Text ~= D.Query then S.Syncing = true; S.Search.Text = D.Query; S.Syncing = false end
                S.Rows = Results(D.Query, D.OnlySelected)
                if Priority and D.PrioritySelection ~= nil then
                    local Visible = false; for _, Entry in S.Rows do if Entry.Key == D.PrioritySelection then Visible = true; break end end
                    if not Visible then D.PrioritySelection = nil end
                end
                V.Config.EmptyText = #D.Values == 0 and (Info.EmptyText or "No options available") or D.OnlySelected and "No selected choices match this search" or "No search results"
                V.Empty.Text = V.Config.EmptyText
                V:SetEntries(S.Rows, Reset)
                S:Layout(); S:Paint()
            end
            function S:Handle(Input)
                if S.LastInput == Input then return true end
                local Key = Input.KeyCode
                local Recognized = Key == Enum.KeyCode.Escape or Key == Enum.KeyCode.ButtonB or Key == Enum.KeyCode.Down or Key == Enum.KeyCode.Up
                    or Key == Enum.KeyCode.DPadDown or Key == Enum.KeyCode.DPadUp or Key == Enum.KeyCode.Left or Key == Enum.KeyCode.Right
                    or Key == Enum.KeyCode.Return or Key == Enum.KeyCode.KeypadEnter
                if not Recognized or (Key == Enum.KeyCode.Left or Key == Enum.KeyCode.Right) and UserInputService:GetFocusedTextBox() then return false end
                S.LastInput = Input; Library.ConsumedInputs[Input] = true; Library.HandledInputs[Input] = true
                if Key == Enum.KeyCode.Escape or Key == Enum.KeyCode.ButtonB then D:Collapse(); return true end
                if Key == Enum.KeyCode.Down or Key == Enum.KeyCode.Up or Key == Enum.KeyCode.DPadDown or Key == Enum.KeyCode.DPadUp
                    or Key == Enum.KeyCode.Left or Key == Enum.KeyCode.Right then
                    if (Key == Enum.KeyCode.Left or Key == Enum.KeyCode.Right) and UserInputService:GetFocusedTextBox() then return false end
                    local Columns = V.Columns or 1
                    local Delta = (Key == Enum.KeyCode.Down or Key == Enum.KeyCode.DPadDown) and Columns or (Key == Enum.KeyCode.Up or Key == Enum.KeyCode.DPadUp) and -Columns or Key == Enum.KeyCode.Right and 1 or -1
                    V.Keyboard = true; V.Selection = math.clamp(V.Selection + Delta, 1, math.max(1, #S.Rows)); V:RevealIndex(V.Selection); return true
                elseif Key == Enum.KeyCode.Return or Key == Enum.KeyCode.KeypadEnter then
                    Choose(S.Rows[V.Selection]); return true
                end
                return false
            end
            Library.TextReflows[Canvas] = function() S:Layout() end
            Canvas.Destroying:Once(function() table.clear(S.Rows) end)
            return S
        end
        Refresh = function(Refilter, Reset)
            for _, S in { Compact, Expanded } do
                if S and S:IsOpen() then if Refilter then S:Refresh(Reset) else S:Layout(); S:Paint() end end
            end
        end
        Menu = Library:AddContextMenu(Display, UDim2.fromOffset(300, 180), function() return { 0, Display.AbsoluteSize.Y + 5 } end, nil, function(Active)
            local Icon = Arrow:FindFirstChild("Icon") or Arrow:FindFirstChildOfClass("ImageLabel")
            if Icon then Icon.Rotation = Active and 180 or 0 end
            if Active then
                if Library.ActiveExpandedDropdown and Library.ActiveExpandedDropdown ~= D then Library.ActiveExpandedDropdown:Collapse() end
                D:BeginSelection()
                if Compact then Compact:Refresh() end
            end
        end, Owner.IsDialog and 9010 or nil)
        D.Menu = Menu
        Menu.RelatedHolder = Holder
        Menu.TriggerActivate = function(Input)
            if ExpandButton.Visible and Library:MouseIsOverFrame(ExpandButton, Input.Position) then D:Expand() else D:Collapse() end
        end
        Menu.HandleInput = function(_, Input) return Compact and Compact:Handle(Input) end
        Menu.OnDismiss = function(Reason)
            if Reason ~= "switch" and not D.Closing then
                D.DraftActive, D.DraftValue, D.StatusMessage = false, nil, ""
            end
        end
        Compact = CreateSurface(Menu.Menu, false)
        D.SearchBox, D.List = Compact.Search, Compact.List
        local function CloseViews()
            D.Closing = true
            Library:CancelTask(D.FilterTask); D.FilterTask = nil
            D.QueryGeneration = (D.QueryGeneration or 0) + 1
            if Library.ActiveExpandedDropdown == D then Library.ActiveExpandedDropdown = nil end
            if ExpandedBackdrop then
                Library:PopFocusScope(D)
                local Old = ExpandedBackdrop
                ExpandedBackdrop, ExpandedPanel, Expanded = nil, nil, nil
                Old:Destroy()
            end
            Menu:Close("close")
            D.Closing = false
        end
        function D:Collapse()
            D.DraftActive, D.DraftValue, D.StatusMessage = false, nil, ""
            CloseViews()
        end
        function D:CancelSelection() D:Collapse(); return true end
        function D:ApplySelection()
            if not D.DraftActive or not D.BatchSelection or D.Disabled or D.Destroyed then return false end
            local Next = Normalize(D.DraftValue)
            if Multi then for _, Value in D.Values do if DisabledSet[Value] then Next[Value] = D.Value[Value] end end end
            if not NullAllowed(Next, D.Value) then D.StatusMessage = "Choose at least one item before applying."; Refresh(false); return false end
            D.DraftActive, D.DraftValue, D.StatusMessage = false, nil, ""
            CloseViews()
            D.ApplyingDraft = true
            local Changed = D:SetValue(Next)
            D.ApplyingDraft = nil
            return true, Changed
        end
        function D:IsExpanded() return ExpandedBackdrop ~= nil end
        local function LayoutExpanded()
            if not ExpandedPanel or not ExpandedBackdrop then return end
            local Origin, Available = Library:GetUsableRect(true)
            local ParentPosition = Library.LayoutMain.AbsolutePosition - ScreenGui.AbsolutePosition
            local Scale = Library.DPIScale
            local W = math.max(80, math.min(840, Available.X / Scale - 20))
            local H = math.max(80, math.min(550, Available.Y / Scale - 20))
            ExpandedPanel.Size = UDim2.fromOffset(W, H)
            ExpandedPanel.Position = UDim2.fromOffset(math.floor((Origin.X - ParentPosition.X + Available.X / 2) / Scale), math.floor((Origin.Y - ParentPosition.Y + Available.Y / 2) / Scale))
            if Expanded then Expanded:Layout() end
        end
        function D:Expand()
            if not D.Expandable or D.Disabled or D.Destroyed or not D.Visible or Library.Unloaded or not Library:IsObjectVisible(Holder) then return false end
            if ExpandedBackdrop then return true end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            D:BeginSelection()
            Menu:Close("switch")
            Library.ActiveExpandedDropdown = D
            ExpandedBackdrop = New("TextButton", { Name = "ExpandedOptions", BackgroundColor3 = "DarkColor", BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 1), Text = "", Selectable = false, ZIndex = 9020, Parent = Library.LayoutMain })
            ExpandedPanel = New("TextButton", { BackgroundColor3 = "MainColor", AnchorPoint = Vector2.new(0.5, 0.5), Text = "", Selectable = false, Size = UDim2.fromOffset(700, 460), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 9021, Parent = ExpandedBackdrop })
            Library:Surface(ExpandedPanel, "Panel")
            Expanded = CreateSurface(ExpandedPanel, true)
            LayoutExpanded(); Expanded:Refresh(true)
            Library:PushFocusScope(D, ExpandedPanel, Expanded.Search)
            ExpandedBackdrop.Activated:Connect(function(Input) if Input then Library.DismissedInputs[Input] = true end; D:Collapse() end)
            Library:GiveSignal(Library.LayoutMain:GetPropertyChangedSignal("AbsoluteSize"):Connect(LayoutExpanded), ExpandedBackdrop)
            for _, Property in { "OnScreenKeyboardVisible", "OnScreenKeyboardPosition", "OnScreenKeyboardSize" } do pcall(function() Library:GiveSignal(UserInputService:GetPropertyChangedSignal(Property):Connect(LayoutExpanded), ExpandedBackdrop) end) end
            return true
        end
        function D:ToggleExpanded() if ExpandedBackdrop then D:Collapse(); return false end; return D:Expand() end
        function D:Open() if D.Disabled or not Library:IsObjectVisible(Holder) then return false end; return Menu:Open() end
        function D:HandleInput(Input) return Expanded and Expanded:Handle(Input) or Compact and Menu.Active and Compact:Handle(Input) or false end
        function D:SetValues(Source)
            if D.Destroyed or Library.Unloaded then return end
            local NewValues, NewLabels, NewMembers, IsDictionary = DecodeValues(Source or {})
            local Previous, Draft = D.Value, D.DraftValue
            D.Values, D.ValueLabels, D.IsDictionary, Members = NewValues, NewLabels, IsDictionary, NewMembers
            Formatted = {}
            if not Multi and not Priority and Previous ~= nil and not Members[Previous] then D.Value = nil else D.Value = Normalize(Previous) end
            if Priority then D.OrderedValue = D.Value end
            if D.DraftActive then
                if not Multi and not Priority and Draft ~= nil and not Members[Draft] then D.DraftValue = nil else D.DraftValue = Normalize(Draft) end
                D.StatusMessage = "Choices changed. Unavailable choices were removed from the draft."
            end
            D:Display(); Refresh(true)
            if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
            if not Same(Previous, D.Value) then Emit() end
        end
        function D:AddValues(Source)
            if D.IsDictionary then
                local Next = table.clone(D.ValueLabels)
                if typeof(Source) ~= "table" then Next[tostring(Source)] = tostring(Source)
                else local Add, Names = DecodeValues(Source); for _, Value in Add do assert(typeof(Value) == "string", "Dictionary option IDs must be strings"); Next[Value] = Names[Value] end end
                D:SetValues(Next)
            else
                local Next = table.clone(D.Values)
                local Add = typeof(Source) == "table" and DecodeValues(Source) or { Source }
                for _, Value in Add do table.insert(Next, Value) end
                D:SetValues(Next)
            end
        end
        function D:SetDisabledValues(Source)
            assert(typeof(Source) == "table", "DisabledValues must be an array or identity-to-boolean map")
            D.DisabledValues, DisabledSet = {}, {}
            for Key, Item in Source do
                local Value = typeof(Item) == "boolean" and Key or Item
                if Item ~= false and not DisabledSet[Value] then DisabledSet[Value] = true; table.insert(D.DisabledValues, Value) end
            end
            if D.DraftActive then
                if Priority then D.DraftValue = Copy(D.Value)
                elseif Multi then for _, Value in D.Values do if DisabledSet[Value] then D.DraftValue[Value] = D.Value[Value] end end
                elseif DisabledSet[D.DraftValue] then D.DraftValue = D.Value end
                D.StatusMessage = "Disabled choices were refreshed; their committed state is preserved."
            end
            Refresh(false)
        end
        function D:AddDisabledValues(Source)
            local Next = table.clone(D.DisabledValues)
            for Key, Item in typeof(Source) == "table" and Source or { Source } do if Item ~= false then table.insert(Next, typeof(Item) == "boolean" and Key or Item) end end
            D:SetDisabledValues(Next)
        end
        function D:SetValueImages(Source) D.ValueImages = table.clone(Source or {}); Refresh(true) end
        function D:SetDisabled(Value) D.Disabled = Value == true; if D.TooltipTable then D.TooltipTable.Disabled = D.Disabled end; D:Collapse(); D:UpdateColors() end
        function D:SetVisible(Value) D.Visible = Value == true; Holder.Visible = D.Visible; if not D.Visible then D:Collapse() end; Owner:Resize() end
        function D:OnChanged(Callback) D.Changed = Callback end
        function D:Destroy() Library:DestroyElement(D); Owner:Resize() end
        function D:BuildDropdownList() Formatted = {}; Refresh(true) end
        function D:RecalculateListSize() if Compact and Menu.Active then Compact:Layout() end; LayoutExpanded() end
        function D:GetRenderStats()
            return { CompactRows = Compact and #Compact.View.Pool or 0, ExpandedRows = Expanded and #Expanded.View.Pool or 0,
                Matching = Expanded and #Expanded.Rows or Compact and #Compact.Rows or 0, Total = #D.Values }
        end
        local Fitting = false
        local function Fit()
            if Fitting or not Holder.Parent or D.Destroyed or D.Presentation == "Segmented" then return end
            Fitting = true
            local M = Library:Metrics()
            local _, Height = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, math.max(40, Holder.AbsoluteSize.X / Library.DPIScale), false)
            local LH = Label.Visible and math.max(22, Height) or 0
            Label.Size = UDim2.new(1, 0, 0, LH)
            Holder.Size = UDim2.new(1, 0, 0, M.Field + (Label.Visible and LH + 6 or 0))
            Display.Size = UDim2.new(1, D.Expandable and -M.Field - 6 or 0, 0, M.Field)
            ExpandButton.Size = UDim2.fromOffset(M.Field, M.Field)
            Fitting = false; D:Display(); D:RecalculateListSize(); Owner:Resize()
        end
        function D:SetText(Text) D.Text = Text; Label.Text = Text or ""; Label.Visible = Text ~= nil; if Expanded then Expanded.Title.Text = Text or "Choose options" end; Fit(); if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end end
        Library.TextReflows[Holder] = Fit
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        Label:GetPropertyChangedSignal("TextSize"):Connect(Fit)
        Label:GetPropertyChangedSignal("FontFace"):Connect(Fit)
        Display.Activated:Connect(function(Input) if not D.Disabled and Library:CanInteract(Display, Input) then if Menu.Active or ExpandedBackdrop then D:Collapse() else D:Open() end end end)
        Display.InputBegan:Connect(function(Input) if Input.KeyCode == Enum.KeyCode.Down and not D.Disabled and Library:CanInteract(Display, Input) then D:Open(); Library.ConsumedInputs[Input] = true end end)
        ExpandButton.Activated:Connect(function(Input) if not D.Disabled and Library:CanInteract(ExpandButton, Input) then D:Expand() end end)
        Holder.Destroying:Once(function() D:Collapse(); Menu:Destroy() end)
        D.TooltipTable = Library:AddTooltip(Info.Tooltip, Info.DisabledTooltip, Display); D.TooltipTable.Disabled = D.Disabled
        local Default = Info.Default
        if not Priority then
            if typeof(Default) == "number" then Default = D.Values[Default] end
            if typeof(Default) == "table" then local Chosen = {}; for _, Value in ipairs(Default) do if Members[Value] then table.insert(Chosen, Value) end end; Default = Multi and Chosen or Chosen[1] end
        end
        D.Value = Normalize(Default)
        if Multi and D.Value == nil then D.Value = {} end
        D.OrderedValue = Priority and D.Value or nil
        D.Default = Priority and table.clone(D.Value) or {}
        if not Priority then for Index, Value in D.Values do if Selected(Value, D.Value) then table.insert(D.Default, Index) end end end
        D:SetDisabledValues(Info.DisabledValues or {})
        table.insert(Owner.Elements, D)
        Options[Idx] = Library:TrackElement(D, Owner)
        Library.VisualRefreshers = Library.VisualRefreshers or setmetatable({}, { __mode = "k" })
        Library.VisualRefreshers[Holder] = function() D:UpdateColors() end
        D:UpdateColors(); Fit()
        return D
    end

    function Funcs:AddPriorityDropdown(Idx, Info)
        Info = typeof(Info) == "table" and table.clone(Info) or {}
        Info.Priority = true
        return self:AddDropdown(Idx, Info)
    end

    function Funcs:AddPlayerInfo(Idx, Info)
        local Owner = self
        Info = typeof(Idx) == "table" and Idx or Info or {}
        local Card = Library:CreatePlayerCard(Owner.Container, Info, function() Owner:Resize() end)
        Card.Idx = typeof(Idx) ~= "table" and Idx or nil
        table.insert(Owner.Elements, Card)
        Library:TrackElement(Card, Owner)
        return Card
    end

    function Funcs:AddViewport(Idx, Info)
        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        assert(typeof(ViewportObject) == "Instance" and (ViewportObject:IsA("BasePart") or ViewportObject:IsA("Model")), "Object must be a BasePart or Model")
        if Info.Clone then
            local Archivable = ViewportObject.Archivable
            ViewportObject.Archivable = true
            local Ok, Clone = pcall(ViewportObject.Clone, ViewportObject)
            ViewportObject.Archivable = Archivable
            assert(Ok and Clone, "Failed to clone viewport object")
            ViewportObject = Clone
        end

        local Viewport = {
            Object = ViewportObject,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = Viewport.Object:GetPivot().Position

            Viewport.Camera.CFrame =
                CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "FieldColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        Library:Surface(Box, "Field")
        New("UIPadding", { PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), Parent = Box })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        local ScrollState = {}
        local function RestoreScrolling()
            Dragging, Pinching = false, false
            if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == ViewportFrame then Library:StopPointerDrag("viewport released") end
            for Side, Enabled in ScrollState do if Side.Parent then Side.ScrollingEnabled = Enabled end end
            table.clear(ScrollState)
        end
        local function Allowed()
            return Viewport.Interactive and not Viewport.Destroyed and Library:CanInteract(ViewportFrame)
        end
        local function Suspend()
            local Parent = ViewportFrame.Parent
            while Parent and Parent ~= ScreenGui do
                if Parent:IsA("ScrollingFrame") and ScrollState[Parent] == nil then ScrollState[Parent] = Parent.ScrollingEnabled; Parent.ScrollingEnabled = false end
                Parent = Parent.Parent
            end
        end
        local function Orbit(Point)
            if not Allowed() or Pinching then Library:StopPointerDrag("viewport blocked"); return end
            if not LastMousePos then LastMousePos = Point; return end
            local Delta = Point - LastMousePos; LastMousePos = Point
            local Position, Camera = Viewport.Object:GetPivot().Position, Viewport.Camera
            local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -Delta.X * 0.01)
            Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame
            local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -Delta.Y * 0.01)
            local Pitched = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame
            if Pitched.UpVector.Y > 0.1 then Camera.CFrame = Pitched end
        end
        ViewportFrame.InputBegan:Connect(function(Input)
            if not Allowed() or Pinching or not (Input.UserInputType == Enum.UserInputType.MouseButton2 or Input.UserInputType == Enum.UserInputType.Touch) then return end
            LastMousePos, Dragging = Input.Position, true
            Library:BeginPointerDrag(ViewportFrame, Input, Orbit, function() Dragging = false; LastMousePos = nil; RestoreScrolling() end, nil, true)
        end)
        ViewportFrame.MouseEnter:Connect(function() if Allowed() then Suspend() end end)
        ViewportFrame.MouseLeave:Connect(function() if not Dragging and not Pinching then RestoreScrolling() end end)
        ViewportFrame.InputChanged:Connect(function(Input)
            if Allowed() and Input.UserInputType == Enum.UserInputType.MouseWheel then Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * (Input.Position.Z * 2) end
        end)
        Library:GiveSignal(UserInputService.TouchPinch:Connect(function(Points, Scale, Velocity, State)
            if State == Enum.UserInputState.End or State == Enum.UserInputState.Cancel then RestoreScrolling(); return end
            if not Allowed() or #Points < 2 or not Library:MouseIsOverFrame(ViewportFrame, Points[1]) or not Library:MouseIsOverFrame(ViewportFrame, Points[2]) then return end
            local Distance = (Points[1] - Points[2]).Magnitude
            if State == Enum.UserInputState.Begin then
                if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner == ViewportFrame then Library:StopPointerDrag("pinch") end
                Pinching, Dragging, LastPinchDist = true, false, Distance; Suspend()
            elseif State == Enum.UserInputState.Change and Pinching then
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ((Distance - LastPinchDist) * 0.1)
                LastPinchDist = Distance
            end
        end), Holder)
        Holder.Destroying:Once(RestoreScrolling)
        Library.VisualRefreshers[Holder] = function() if not Library:IsObjectVisible(Holder) or not Viewport.Interactive then RestoreScrolling() end end

        if not Info.Camera then Viewport.Camera.Parent = ViewportFrame end
        Viewport.Object.Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(typeof(Object) == "Instance" and (Object:IsA("BasePart") or Object:IsA("Model")), "Object must be a BasePart or Model")
            if Object == Viewport.Object then if Viewport.AutoFocus then FocusCamera() end; return end
            if Clone == nil then Clone = Info.Clone end
            if Clone then
                local Archivable = Object.Archivable
                Object.Archivable = true
                local Ok, Cloned = pcall(Object.Clone, Object)
                Object.Archivable = Archivable
                assert(Ok and Cloned, "Unable to clone viewport object")
                Object = Cloned
            end
            local Previous = Viewport.Object
            Viewport.Object = Object
            Object.Parent = ViewportFrame
            if Previous then Previous:Destroy() end
            if Viewport.AutoFocus then FocusCamera() end
            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            if not Interactive then
                RestoreScrolling()
            end
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible
            if not Visible then RestoreScrolling() end

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        Viewport.Idx = Idx
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Library:TrackElement(Viewport, Groupbox)

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "FieldColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        Library:Surface(Box, "Field")
        New("UIPadding", { PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), Parent = Box })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = Image.Image,
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ImageRectOffset = Image.RectOffset,
            ImageRectSize = Image.RectSize,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(ImageProperties.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Image.RectOffset ~= Vector2.zero and Image.RectOffset or Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Image.RectSize ~= Vector2.zero and Image.RectSize or Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)
        local Missing = New("TextLabel", { BackgroundTransparency = 1, Text = "Image unavailable", TextColor3 = "MutedColor", TextSize = 15, RichText = false, TextWrapped = true, Size = UDim2.fromScale(1, 1), Visible = not ImageLabel.IsLoaded, Parent = Box })
        ImageLabel:GetPropertyChangedSignal("IsLoaded"):Connect(function() Missing.Visible = not ImageLabel.IsLoaded end)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            NewImage = Icon.Url
            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            ImageLabel.Image = NewImage
            ImageLabel.ImageRectOffset = Icon.ImageRectOffset
            ImageLabel.ImageRectSize = Icon.ImageRectSize
            Image.Image = NewImage
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        Image.Idx = Idx
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Library:TrackElement(Image, Groupbox)

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "FieldColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        Library:Surface(Box, "Field")
        New("UIPadding", { PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), Parent = Box })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing
        local MediaMessage = New("TextLabel", { BackgroundTransparency = 1, Text = Video.Video == "" and "No video supplied" or "Video loading or unavailable", TextColor3 = "MutedColor", TextSize = 15, RichText = false, TextWrapped = true, Size = UDim2.fromScale(1, 1), Parent = Box })
        local function MediaState()
            local Ok, Loaded = pcall(function() return VideoFrameInstance.IsLoaded end)
            MediaMessage.Visible = Video.Video == "" or Ok and not Loaded
            MediaMessage.Text = Video.Video == "" and "No video supplied" or "Video loading or unavailable"
        end
        local Ok, LoadedSignal = pcall(function() return VideoFrameInstance:GetPropertyChangedSignal("IsLoaded") end)
        if Ok then LoadedSignal:Connect(MediaState) end
        MediaState()

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
            MediaState()
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        Video.Idx = Idx
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Library:TrackElement(Video, Groupbox)

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        Passthrough.Idx = Idx
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Library:TrackElement(Passthrough, Groupbox)

        return Passthrough
    end

    function Funcs:AddList(Idx, Info)
        Info = Library:Validate(Info, Templates.List)
        local Owner = self
        local L = { Idx = Idx, Type = "List", Text = typeof(Info.Text) == "string" and Info.Text or nil,
            Value = Info.Multi and {} or nil, Items = {}, Multi = Info.Multi, MaxHeight = Info.MaxHeight, EmptyText = Info.EmptyText,
            Callback = Info.Callback, Changed = Info.Changed, Disabled = Info.Disabled, Visible = Info.Visible }
        local Holder = New("Frame", { Name = "SelectableList", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 150), Visible = L.Visible, Parent = Owner.Container })
        local Label = New("TextLabel", { BackgroundTransparency = 1, Text = L.Text or "", RichText = false, TextWrapped = true, TextSize = 15,
            Visible = L.Text ~= nil, Size = UDim2.new(1, 0, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local View, Layout
        local function Selected(Key) return L.Multi and L.Value[Key] == true or not L.Multi and L.Value == Key end
        local function Normalize(Items)
            assert(typeof(Items) == "table", "List items must be a table")
            local Result, Seen = {}, {}
            for Index, Item in ipairs(Items) do
                local Entry
                if typeof(Item) == "string" then Entry = { Key = Index, Display = Item }
                elseif typeof(Item) == "table" then Entry = table.clone(Item); Entry.Key = Entry.Key ~= nil and Entry.Key or Index; Entry.Display = tostring(Entry.Display or Entry.Key)
                else error("List items must be strings or tables") end
                assert((typeof(Entry.Key) == "string" or IsFinite(Entry.Key)) and not Seen[Entry.Key], "List keys must be unique strings or finite numbers")
                Seen[Entry.Key] = true; table.insert(Result, Entry)
            end
            return Result
        end
        local function Render(Reset)
            local Entries = {}
            for Index, Item in L.Items do table.insert(Entries, { Key = Item.Key, Text = Item.Display, Item = Item, Index = Index, Image = Item.Image }) end
            View.Config.EmptyText = L.EmptyText
            View:SetEntries(Entries, Reset)
            Layout()
        end
        local function Choose(Entry)
            if L.Disabled or L.Destroyed then return end
            if L.Multi then L.Value[Entry.Key] = not L.Value[Entry.Key] and true or nil else L.Value = Entry.Key end
            View:Paint()
            -- Lists intentionally preserve their separate click and programmatic-selection contracts.
            Library:SafeCallback(L.Callback, Entry.Item, Entry.Index)
            Library:SafeCallback(L.Changed, L.Value)
        end
        local function Handle(Input)
            if L.LastInput == Input or L.Disabled then return end
            if Input.KeyCode == Enum.KeyCode.Up or Input.KeyCode == Enum.KeyCode.Down then
                L.LastInput = Input; Library.ConsumedInputs[Input] = true
                View:RevealIndex(View.Selection + (Input.KeyCode == Enum.KeyCode.Up and -1 or 1))
            elseif Input.KeyCode == Enum.KeyCode.Return and View.Entries[View.Selection] then
                L.LastInput = Input; Library.ConsumedInputs[Input] = true; Choose(View.Entries[View.Selection])
            end
        end
        View = Library:CreateVirtualList(Holder, {
            EmptyText = L.EmptyText, KeyboardFocus = true,
            IsOpen = function() return not L.Destroyed and Library:IsObjectVisible(Holder) end,
            IsSelected = function(Entry) return Selected(Entry.Key) end,
            IsDisabled = function() return L.Disabled end,
            Activate = Choose, HandleInput = Handle,
            HeightChanged = function() if Layout then Layout() end end,
        })
        Library:Surface(View.Frame, "Field")
        local LayingOut = false
        Layout = function()
            if LayingOut or L.Destroyed or not Holder.Parent then return end
            LayingOut = true
            local _, TextHeight = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, math.max(40, Holder.AbsoluteSize.X / Library.DPIScale), false)
            local Top = Label.Visible and math.max(22, TextHeight) + 6 or 0
            Label.Size = UDim2.new(1, 0, 0, Top > 0 and Top - 6 or 0)
            local Height = #L.Items == 0 and 62 or math.min(L.MaxHeight, math.max(Library:Metrics().Target, View.TotalHeight or #L.Items * Library:Metrics().Target))
            View.Frame.Position, View.Frame.Size = UDim2.fromOffset(0, Top), UDim2.new(1, 0, 0, Height)
            Holder.Size = UDim2.new(1, 0, 0, Top + Height)
            LayingOut = false; Owner:Resize()
        end
        function L:SetItems(Items) local Next = Normalize(Items); L.Items = Next; L.Value = L.Multi and {} or nil; Render(true) end
        function L:AddItem(Item)
            local Items = table.clone(L.Items)
            if typeof(Item) == "string" then
                local Key, Used = #Items + 1, {}
                for _, Entry in Items do Used[Entry.Key] = true end
                while Used[Key] do Key += 1 end
                Item = { Key = Key, Display = Item }
            end
            table.insert(Items, Item); L.Items = Normalize(Items); Render(false)
        end
        function L:RemoveItem(KeyOrIndex)
            local Target
            for Index, Item in L.Items do if Item.Key == KeyOrIndex then Target = Index; break end end
            Target = Target or (typeof(KeyOrIndex) == "number" and KeyOrIndex)
            if not Target or not L.Items[Target] then return false end
            local Key = L.Items[Target].Key
            if L.Multi then L.Value[Key] = nil elseif L.Value == Key then L.Value = nil end
            table.remove(L.Items, Target); Render(false); return true
        end
        function L:GetSelected()
            if L.Multi then local Result = {}; for _, Item in L.Items do if L.Value[Item.Key] then table.insert(Result, Item) end end; return Result end
            for _, Item in L.Items do if Item.Key == L.Value then return Item end end
            return nil
        end
        function L:SetSelected(KeyOrIndex)
            local function Resolve(Key)
                for _, Item in L.Items do if Item.Key == Key then return Key end end
                return typeof(Key) == "number" and L.Items[Key] and L.Items[Key].Key or nil
            end
            if L.Multi then
                local Next = typeof(KeyOrIndex) == "table" and {} or table.clone(L.Value or {})
                for _, Key in typeof(KeyOrIndex) == "table" and KeyOrIndex or { KeyOrIndex } do local Found = Resolve(Key); if Found ~= nil then Next[Found] = true end end
                L.Value = Next
            else L.Value = Resolve(KeyOrIndex) end
            View:Paint()
        end
        function L:ClearSelection() L.Value = L.Multi and {} or nil; View:Paint() end
        function L:GetItems() local Items = {}; for Index, Item in L.Items do Items[Index] = table.clone(Item) end; return Items end
        function L:SetText(Text) L.Text = Text; Label.Text = Text or ""; Label.Visible = Text ~= nil; Layout() end
        function L:SetVisible(Value) L.Visible = Value; Holder.Visible = Value; Layout(); if Value then View:Paint() end end
        function L:SetDisabled(Value) L.Disabled = Value; Label.TextColor3 = Value and Library.Scheme.MutedColor or Library.Scheme.FontColor; View:Paint() end
        function L:OnChanged(Callback) L.Changed = Callback end
        function L:GetRenderStats() return { Rows = #View.Pool, Total = #L.Items } end
        function L:Destroy() Library:DestroyElement(L); Owner:Resize() end
        L.Holder, L.TextLabel, L.List, L.View = Holder, Label, View.Frame, View
        Library.TextReflows[Holder] = Layout
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Layout)
        Holder:GetPropertyChangedSignal("Visible"):Connect(function() if Holder.Visible then View:Paint() end end)
        Library.VisualRefreshers = Library.VisualRefreshers or setmetatable({}, { __mode = "k" })
        Library.VisualRefreshers[Holder] = function() View:Paint() end
        L.Items = Normalize(Info.Items)
        table.insert(Owner.Elements, L)
        Options[Idx] = Library:TrackElement(L, Owner)
        Render(true)
        return L
    end

    function Funcs:AddDependencyBox()
        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,
            Tab = Groupbox.Tab or Groupbox,
            IsDialog = Groupbox.IsDialog,

            Elements = {},
            DependencyBoxes = {},
            InnerTabboxes = {},
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            if Depbox.Destroyed then return end
            Depbox.Visible = DependenciesMet(Depbox.Dependencies)
            DepboxContainer.Visible = Depbox.Visible
            if Depbox.Visible then Depbox:Resize() else Groupbox:Resize() end
            if Library.Searching and not CancelSearch then Library:UpdateSearch(Library.SearchText) end
        end

        DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end)

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(typeof(Dependency[1]) == "table", "Dependency is missing an element")
                assert(Dependency[1].Type == "Toggle" or Dependency[1].Type == "Dropdown" or Dependency[1].Type == "PriorityDropdown", "Unsupported dependency type")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end)

        setmetatable(Depbox, BaseGroupbox)

        DepboxContainer.Destroying:Once(function()
            Depbox.Destroyed = true
            local Index = table.find(Library.DependencyBoxes, Depbox)
            if Index then table.remove(Library.DependencyBoxes, Index) end
            Index = table.find(Groupbox.DependencyBoxes, Depbox)
            if Index then table.remove(Groupbox.DependencyBoxes, Index) end
        end)
        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        local Groupbox = self
        local Tab = Groupbox.Tab or Groupbox
        local BoxHolder = Groupbox.BoxHolder or Groupbox.Container

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            IsDialog = Groupbox.IsDialog,
            Elements = {},
            DependencyBoxes = {},
            InnerTabboxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            if DepGroupbox.Destroyed then return end
            DepGroupbox.Visible = DependenciesMet(DepGroupbox.Dependencies)
            DepGroupboxContainer.Visible = DepGroupbox.Visible
            if DepGroupbox.Visible then DepGroupbox:Resize() else Groupbox:Resize() end
            if Library.Searching and not CancelSearch then Library:UpdateSearch(Library.SearchText) end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(typeof(Dependency[1]) == "table", "Dependency is missing an element")
                assert(Dependency[1].Type == "Toggle" or Dependency[1].Type == "Dropdown" or Dependency[1].Type == "PriorityDropdown", "Unsupported dependency type")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        Tab.DependencyGroupboxes = Tab.DependencyGroupboxes or {}
        DepGroupboxContainer.Destroying:Once(function()
            DepGroupbox.Destroyed = true
            local Index = table.find(Library.DependencyBoxes, DepGroupbox)
            if Index then table.remove(Library.DependencyBoxes, Index) end
            Index = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if Index then table.remove(Tab.DependencyGroupboxes, Index) end
        end)
        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox)

        return DepGroupbox
    end

    function Funcs:AddTabbox()
        local Groupbox = self
        local Wrapper = New("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0), Parent = Groupbox.Container })
        local Depth = (Groupbox.Depth or 0) + 1
        local Rail = Library:CreateTabRail(Wrapper, Depth)
        local Inner = { ActiveTab = nil, Tabs = {}, Groupbox = Groupbox, BoxHolder = Wrapper, Strip = Rail.Scroll, Rail = Rail, Internal = Groupbox.Internal, Depth = Depth }
        Groupbox.InnerTabboxes = Groupbox.InnerTabboxes or {}
        table.insert(Groupbox.InnerTabboxes, Inner)
        local Key = Library:NavigationKey(Groupbox, "inner", tostring(#Groupbox.InnerTabboxes))
        Library:RegisterNavigation("Box", Key, Inner)
        function Inner:AddTab(Name, IconName)
            Name = tostring(Name or "")
            assert(Inner.Tabs[Name] == nil, "A tab with this name already exists in this tabbox")
            local Icon = Library:GetCustomIcon(IconName)
            local Button = New("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromOffset(80, 32), Text = "", Parent = Rail.Content })
            local Image
            if Icon then
                Image = New("ImageLabel", { Image = Icon.Url, ImageRectOffset = Icon.ImageRectOffset, ImageRectSize = Icon.ImageRectSize,
                    ImageColor3 = Icon.Custom and "WhiteColor" or "FontColor", Position = UDim2.new(0, 10, 0.5, -8), Size = UDim2.fromOffset(16, 16), Parent = Button })
                Image:SetAttribute("CustomIcon", Icon.Custom == true)
            end
            local Text = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Icon and 34 or 12, 0),
                Size = UDim2.new(1, Icon and -44 or -24, 1, 0), Text = Name, RichText = false, TextSize = 14,
                TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Left, Parent = Button })
            local Content = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 54), Size = UDim2.fromScale(1, 0), Visible = false, Parent = Wrapper })
            local Layout = New("UIListLayout", { Padding = UDim.new(0, 10), Parent = Content })
            local Tab = { Name = Name, ButtonHolder = Button, TextLabel = Text, Container = Content, Tab = Groupbox.Tab or Groupbox,
                Groupbox = Groupbox, ParentTabbox = Inner, IsDialog = Groupbox.IsDialog, Elements = {}, DependencyBoxes = {}, InnerTabboxes = {}, Depth = Depth, Internal = Groupbox.Internal, NavKey = Library:NavigationKey(Inner, "tab", Name) }
            function Tab:Resize()
                if Inner.ActiveTab ~= Tab or not Wrapper.Parent then return end
                local Top = Rail.Frame.Size.Y.Offset + Library:Metrics().Gap
                local Height = math.ceil(Layout.AbsoluteContentSize.Y / Library.DPIScale)
                Content.Position = UDim2.fromOffset(0, Top)
                Content.Size = UDim2.new(1, 0, 0, Height)
                Wrapper.Size = UDim2.new(1, 0, 0, Top + Height)
                Groupbox:Resize()
            end
            function Tab:Show(User)
                if User then Library:NavigationSelected("Box", Inner.NavKey) end
                if not Button.Parent or not Button.Visible then return end
                if Inner.ActiveTab == Tab then Tab:Resize(); Rail:Reveal(Button); return end
                if Inner.ActiveTab then Inner.ActiveTab:Hide() end
                Inner.ActiveTab = Tab
                Content.Visible = true
                Rail:Select(Tab.RailEntry)
                Tab:Resize()
                Library:RefreshVisibleComponents()
                Library:LayoutChanged()
            end
            function Tab:Hide()
                Content.Visible = false
                if Inner.ActiveTab == Tab then Inner.ActiveTab = nil; Rail:Select(nil) end
            end
            function Tab:SetName(Value)
                Value = tostring(Value)
                assert(Value == Tab.Name or Inner.Tabs[Value] == nil, "Duplicate tab name")
                Inner.Tabs[Tab.Name] = nil; Tab.Name = Value; Inner.Tabs[Value] = Tab; Text.Text = Value
                if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
            end
            Tab.RailEntry = Rail:Add(Button, Text, Image, function() Tab:Show(true) end)
            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Tab:Resize() end)
            Rail.Frame:GetPropertyChangedSignal("Size"):Connect(function() Tab:Resize() end)
            Button.Activated:Connect(function(Input) if Library:CanInteract(Button, Input) then Tab:Show(true) end end)
            Button.MouseEnter:Connect(function() if Inner.ActiveTab ~= Tab then Text.TextTransparency = 0 end end)
            Button.MouseLeave:Connect(function() if Inner.ActiveTab ~= Tab then Text.TextTransparency = 0.1 end end)
            Library:AddTooltip(Name, "", Button)
            setmetatable(Tab, BaseGroupbox)
            Inner.Tabs[Name] = Tab
            Library:ScheduleNavigationRestore()
            if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
            if not Inner.ActiveTab then Tab:Show() end
            return Tab
        end
        return Inner
    end

    -- Explicit read-only components; nothing is injected into the window automatically.
    function Funcs:AddStatCard(Idx, Info)
        if typeof(Idx) == "table" then Info, Idx = Idx, nil end
        Info = typeof(Info) == "table" and Info or {}
        local Owner = self
        local Holder = New("Frame", { Name = "MetricReadout", BackgroundColor3 = "NavigationColor", Size = UDim2.new(1, 0, 0, 54), Visible = Info.Visible ~= false, Parent = Owner.Container })
        Library:Surface(Holder, "Panel")
        local Title = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Text or "Metric"), FontFace = "FontBold", TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local Value = New("TextLabel", { BackgroundTransparency = 1, Text = Info.Value ~= nil and tostring(Info.Value) or "Not supplied", FontFace = "FontMono", TextSize = 20, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Right, Parent = Holder })
        local Detail = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Description or ""), TextColor3 = "MutedColor", TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local Card = { Idx = Idx, Type = "StatCard", Text = Title.Text, Value = Info.Value, Holder = Holder, TextLabel = Title, ValueLabel = Value, DescriptionLabel = Detail, Visible = Holder.Visible }
        local Fitting = false
        local function Fit()
            if Fitting or not Holder.Parent or Card.Destroyed or Library.Unloaded then return end
            Fitting = true
            local Width = math.max(100, Holder.AbsoluteSize.X - 20)
            local ValueWidth = Library:GetTextBounds(Value.Text, Value.FontFace, Value.TextSize, 0, false)
            local Stacked = ValueWidth > Width * 0.52
            local TitleWidth = Stacked and Width or math.max(40, Width - ValueWidth - 14)
            local _, TitleHeight = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, TitleWidth, false)
            local _, ValueHeight = Library:GetTextBounds(Value.Text, Value.FontFace, Value.TextSize, Stacked and Width or ValueWidth + 2, false)
            local HeaderHeight = Stacked and TitleHeight + ValueHeight + 6 or math.max(TitleHeight, ValueHeight)
            Title.Position, Title.Size = UDim2.fromOffset(10, 8), UDim2.fromOffset(TitleWidth, Stacked and TitleHeight or HeaderHeight)
            Value.Position = Stacked and UDim2.fromOffset(10, TitleHeight + 14) or UDim2.new(1, -10 - ValueWidth - 2, 0, 8)
            Value.Size, Value.TextXAlignment = UDim2.fromOffset(Stacked and Width or ValueWidth + 2, ValueHeight), Stacked and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
            local DetailHeight = 0
            if Detail.Text ~= "" then local _, H = Library:GetTextBounds(Detail.Text, Detail.FontFace, Detail.TextSize, Width, false); DetailHeight = H + 6 end
            Detail.Visible, Detail.Position, Detail.Size = DetailHeight > 0, UDim2.fromOffset(10, HeaderHeight + 14), UDim2.fromOffset(Width, math.max(1, DetailHeight - 6))
            Holder.Size = UDim2.new(1, 0, 0, HeaderHeight + DetailHeight + 16)
            Fitting = false; Owner:Resize()
        end
        function Card:SetValue(NewValue, Description)
            if Card.Destroyed then return end
            Card.Value, Value.Text = NewValue, tostring(NewValue)
            if Description ~= nil then Detail.Text = tostring(Description) end
            Fit()
        end
        function Card:SetText(Text) Card.Text, Title.Text = tostring(Text), tostring(Text); Fit() end
        function Card:SetDescription(Text) Detail.Text = tostring(Text or ""); Fit() end
        function Card:SetVisible(Visible) Card.Visible, Holder.Visible = Visible ~= false, Visible ~= false; Owner:Resize() end
        function Card:Destroy() Library:DestroyElement(Card); Owner:Resize() end
        Library.TextReflows[Holder] = Fit
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        for _, Text in { Title, Value, Detail } do Text:GetPropertyChangedSignal("Text"):Connect(Fit); Text:GetPropertyChangedSignal("TextSize"):Connect(Fit) end
        table.insert(Owner.Elements, Card)
        if Idx ~= nil then Labels[Idx] = Card end
        Library:TrackElement(Card, Owner); Fit()
        return Card
    end

    function Funcs:AddProgressBar(Idx, Info)
        if typeof(Idx) == "table" then Info, Idx = Idx, nil end
        Info = typeof(Info) == "table" and Info or {}
        local Owner, Maximum = self, Info.Max or 100
        assert(IsFinite(Maximum) and Maximum > 0, "Progress maximum must be positive")
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58), Visible = Info.Visible ~= false, Parent = Owner.Container })
        local Title = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Text or "Progress"), TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local Percent = New("TextLabel", { BackgroundTransparency = 1, Text = "0%", FontFace = "FontMono", TextSize = 15, RichText = false, TextXAlignment = Enum.TextXAlignment.Right, Parent = Holder })
        local Track = New("Frame", { BackgroundColor3 = "FieldColor", Size = UDim2.new(1, 0, 0, 8), Parent = Holder })
        Library:Surface(Track, "Field")
        local Fill = New("Frame", { BackgroundColor3 = Info.Color or "AccentColor", Size = UDim2.fromScale(0, 1), ZIndex = Track.ZIndex + 1, Parent = Track })
        local Detail = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Description or ""), TextColor3 = "MutedColor", TextSize = 15, RichText = false, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local Progress = { Idx = Idx, Type = "ProgressBar", Text = Title.Text, Value = 0, Max = Maximum, Holder = Holder, TextLabel = Title, Fill = Fill, Visible = Holder.Visible }
        local Fitting = false
        local function Fit()
            if Fitting or Progress.Destroyed or not Holder.Parent or Library.Unloaded then return end
            Fitting = true
            local Width = math.max(90, Holder.AbsoluteSize.X)
            local PW = Library:GetTextBounds("100%", Percent.FontFace, Percent.TextSize, 0, false) + 8
            local _, H = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, math.max(30, Width - PW - 10), false)
            H = math.max(H, Percent.TextSize + 4)
            Title.Position, Title.Size = UDim2.fromOffset(0, 0), UDim2.new(1, -PW - 10, 0, H)
            Percent.Position, Percent.Size = UDim2.new(1, -PW, 0, 0), UDim2.fromOffset(PW, H)
            Track.Position = UDim2.fromOffset(0, H + 6)
            local DH = 0
            if Detail.Text ~= "" then local _, Height = Library:GetTextBounds(Detail.Text, Detail.FontFace, Detail.TextSize, Width, false); DH = Height + 6 end
            Detail.Position, Detail.Size, Detail.Visible = UDim2.fromOffset(0, H + 20), UDim2.new(1, 0, 0, math.max(1, DH - 6)), DH > 0
            Holder.Size = UDim2.new(1, 0, 0, H + 20 + DH)
            Fitting = false; Owner:Resize()
        end
        function Progress:SetValue(Value, Description)
            if Progress.Destroyed or Library.Unloaded or not IsFinite(Value) then return false end
            Progress.Value = math.clamp(Value, 0, Progress.Max)
            local Ratio = Progress.Value / Progress.Max
            Percent.Text = string.format("%d%%", math.floor(Ratio * 100 + 0.5))
            if Description ~= nil then Detail.Text = tostring(Description) end
            if Library:IsObjectVisible(Holder) then Library:CreateTween(Fill, TweenInfo.new(0.1), { Size = UDim2.fromScale(Ratio, 1) }):Play()
            else Library:CancelMotion(Fill); Fill.Size = UDim2.fromScale(Ratio, 1) end
            Fit(); return true
        end
        function Progress:SetMax(Value) assert(IsFinite(Value) and Value > 0, "Progress maximum must be positive"); Progress.Max = Value; Progress:SetValue(Progress.Value) end
        function Progress:SetText(Text) Progress.Text, Title.Text = tostring(Text), tostring(Text); Fit() end
        function Progress:SetDescription(Text) Detail.Text = tostring(Text or ""); Fit() end
        function Progress:SetVisible(Visible) Progress.Visible, Holder.Visible = Visible ~= false, Visible ~= false; Owner:Resize() end
        function Progress:Destroy() Library:DestroyElement(Progress); Owner:Resize() end
        Library.TextReflows[Holder] = Fit
        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        for _, Text in { Title, Percent, Detail } do Text:GetPropertyChangedSignal("TextSize"):Connect(Fit) end
        table.insert(Owner.Elements, Progress)
        if Idx ~= nil then Labels[Idx] = Progress end
        Library:TrackElement(Progress, Owner); Progress:SetValue(Info.Value or 0); Fit()
        return Progress
    end

    -- Short, explicitly requested choices use the same production dropdown value model.
    function Funcs:AddSegmented(Idx, Info)
        Info = typeof(Info) == "table" and table.clone(Info) or {}
        Info.Searchable, Info.Expandable = false, false
        local Owner, Choice = self, self:AddDropdown(Idx, Info)
        Choice.Presentation = "Segmented"
        Choice.Menu.Holder.Visible, Choice.ExpandButton.Visible = false, false
        local Strip = New("ScrollingFrame", { Name = "SegmentedChoices", BackgroundColor3 = "FieldColor", AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.fromScale(0, 0), ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 3, ScrollBarImageColor3 = "OutlineColor", Parent = Choice.Holder })
        Library:Surface(Strip, "Field")
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Strip })
        local Footer = New("Frame", { BackgroundTransparency = 1, Visible = false, Parent = Choice.Holder })
        local Apply = New("TextButton", { Text = "Apply", RichText = false, Size = UDim2.new(0.5, -3, 1, 0), Parent = Footer })
        local Cancel = New("TextButton", { Text = "Cancel", RichText = false, Position = UDim2.new(0.5, 3, 0, 0), Size = UDim2.new(0.5, -3, 1, 0), Parent = Footer })
        Library:StyleAction(Apply, "Primary", false, false); Library:StyleAction(Cancel, "Secondary", false, false)
        local Rows, Fitting = {}, false
        local function Fit()
            if Fitting or Choice.Destroyed or not Choice.Holder.Parent or Library.Unloaded then return end
            Fitting = true
            local M, W, LH = Library:Metrics(), math.max(80, Choice.Holder.AbsoluteSize.X), 0
            if Choice.TextLabel.Visible then local _, H = Library:GetTextBounds(Choice.TextLabel.Text, Choice.TextLabel.FontFace, Choice.TextLabel.TextSize, W, false); LH = H + 6; Choice.TextLabel.Size = UDim2.new(1, 0, 0, H) end
            local Height = M.Target + 5
            Strip.Position, Strip.Size = UDim2.fromOffset(0, LH), UDim2.new(1, 0, 0, Height)
            Footer.Visible = Choice.BatchSelection and Choice.DraftActive
            Footer.Position, Footer.Size = UDim2.fromOffset(0, LH + Height + 6), UDim2.new(1, 0, 0, M.Target)
            Choice.Holder.Size = UDim2.new(1, 0, 0, LH + Height + (Footer.Visible and M.Target + 6 or 0))
            local State = Choice.Value
            if Choice.DraftActive then State = Choice:GetDraftValue() end
            for Value, Row in Rows do
                local Selected = Choice.Multi and State[Value] == true or not Choice.Multi and State == Value
                local Disabled = Choice.Disabled or table.find(Choice.DisabledValues, Value) ~= nil
                Library:StyleAction(Row, Selected and "Primary" or "Secondary", Disabled, false)
                local Width, H = Library:GetTextBounds(Row.Text, Row.FontFace, Row.TextSize, 0, false)
                Row.Size = UDim2.fromOffset(math.max(64, Width + 24), math.max(M.Target, H + 12))
            end
            Fitting = false; Owner:Resize()
        end
        local function Build()
            for _, Row in Rows do Row:Destroy() end
            table.clear(Rows)
            for Index, Value in Choice.Values do
                local Name = Choice:GetValueLabel(Value) or tostring(Value)
                local Text = Name
                if typeof(Info.FormatListValue) == "function" then local Ok, Result = pcall(Info.FormatListValue, Value, Name); if Ok and Result ~= nil then Text = tostring(Result) end end
                local Row = New("TextButton", { Text = Text, RichText = false, TextSize = 15, LayoutOrder = Index, Parent = Strip })
                Rows[Value] = Row
                Row.Activated:Connect(function(Input)
                    if not Library:CanInteract(Row, Input) then return end
                    if Choice.BatchSelection then Choice:BeginSelection() end
                    Choice:Choose(Value); Fit()
                end)
            end
            Fit()
        end
        local Display, SetValues, SetDisabled, SetDisabledValues, Draft, Collapse = Choice.Display, Choice.SetValues, Choice.SetDisabled, Choice.SetDisabledValues, Choice.SetDraftValue, Choice.Collapse
        function Choice:Display() Display(self); Fit() end
        function Choice:SetValues(Values) SetValues(self, Values); Build() end
        function Choice:SetDisabled(Value) SetDisabled(self, Value); Fit() end
        function Choice:SetDisabledValues(Values) SetDisabledValues(self, Values); Fit() end
        function Choice:SetDraftValue(Value) local Changed = Draft(self, Value); Fit(); return Changed end
        function Choice:Collapse() Collapse(self); Fit() end
        Apply.Activated:Connect(function(Input) if Library:CanInteract(Apply, Input) then Choice:ApplySelection(); Fit() end end)
        Cancel.Activated:Connect(function(Input) if Library:CanInteract(Cancel, Input) then Choice:CancelSelection(); Fit() end end)
        Strip.InputBegan:Connect(function(Input) if Input.KeyCode == Enum.KeyCode.Escape and Choice:HasDraft() then Library.ConsumedInputs[Input] = true; Library.HandledInputs[Input] = true; Choice:CancelSelection() end end)
        Choice.Strip, Choice.Segments = Strip, Rows
        Library.TextReflows[Choice.Holder], Library.VisualRefreshers[Choice.Holder] = Fit, Fit
        Choice.Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
        Choice.TextLabel:GetPropertyChangedSignal("Text"):Connect(Fit)
        Build(); return Choice
    end


    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then FontFace = Font.fromEnum(FontFace) end
    assert(typeof(FontFace) == "Font", "Expected a Font or Enum.Font")
    Library.LegacyAppearanceAssignments.Font = FontFace
    -- Coordinated sans/mono faces are retained. No feature values are touched.
    return true
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local Left = Side:lower() == "left"
    if Left then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBg in Library.Notifications do
        FakeBg.AnchorPoint = Left and Vector2.new(0, 0) or Vector2.new(1, 0)
    end
    Library:UpdateNotificationPositions(true)
end

function Library:IsExecutorSupported(Info)
    Info = typeof(Info) == "table" and Info or {}
    local Executor = Info.Executor
    if not Executor and identifyexecutor then local Ok, Name = pcall(identifyexecutor); if Ok then Executor = Name end end
    Executor = tostring(Executor or "Unknown")
    local function Listed(List)
        for _, Entry in List or {} do
            if Executor:lower():find(tostring(Entry):lower(), 1, true) then return true end
        end
        return false
    end
    local SupportedList = Info.Supported or Info.Whitelist
    local UnsupportedList = Info.Unsupported or Info.Blocklist or Info.Blacklist
    local Blocked
    if typeof(SupportedList) == "table" then
        Blocked = not Listed(SupportedList)
    elseif typeof(UnsupportedList) == "table" then
        Blocked = Listed(UnsupportedList)
    else
        Blocked = true
    end
    return not Blocked, Executor
end

function Library:CreateUnsupportedScreen(Info)
    Info = typeof(Info) == "table" and Info or {}
    local Supported, Executor = Library:IsExecutorSupported(Info)
    if Supported then return nil end
    local Frame = New("Frame", { Name = "UnsupportedEnvironment", BackgroundColor3 = "MainColor", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(420, 200), ZIndex = 18000, Parent = ScreenGui })
    Library:Surface(Frame, "Panel")
    New("Frame", { BackgroundColor3 = "RedColor", Size = UDim2.new(1, 0, 0, 3), Parent = Frame })
    local Body = New("ScrollingFrame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 12), Size = UDim2.new(1, -24, 1, -24), CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = "OutlineColor", ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Frame })
    local Title = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, FontFace = "FontBold", TextSize = 18, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Body })
    local Description = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextColor3 = "FontColor", TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Body })
    local Language = New("TextButton", { Text = "", RichText = false, TextSize = 15, Parent = Body })
    Library:StyleAction(Language, "Secondary", false, false)
    local Footer = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Footer or ""), RichText = false, TextColor3 = "MutedColor", TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Body })
    local Languages = typeof(Info.Languages) == "table" and Info.Languages or {}
    if #Languages == 0 then
        Languages = {
            { Name = "English", Title = Info.Title or "Unsupported executor", Description = Info.Description or ("This script does not support " .. Executor .. ".") },
            { Name = "Espanol", Title = Info.Title or "Ejecutor no compatible", Description = Info.Description or ("Este script no es compatible con " .. Executor .. ".") },
            { Name = "Portugues", Title = Info.Title or "Executor nao suportado", Description = Info.Description or ("Este script nao suporta " .. Executor .. ".") },
        }
    end
    local Screen = { Frame = Frame, Title = Title, Description = Description, Executor = Executor }
    local Index, Fitting = 1, false
    local function Fit()
        if Fitting or not Frame.Parent or Library.Unloaded then return end
        Fitting = true
        local _, View = Library:GetUsableRect()
        local W = math.max(100, math.min(440, View.X - 16))
        local Width = math.max(40, W - 32)
        local _, TH = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, Width, false)
        local _, DH = Library:GetTextBounds(Description.Text, Description.FontFace, Description.TextSize, Width, false)
        local _, FH = Library:GetTextBounds(Footer.Text, Footer.FontFace, Footer.TextSize, Width, false)
        if Footer.Text == "" then FH = 0 end
        Title.Position, Title.Size = UDim2.fromOffset(0, 0), UDim2.new(1, -6, 0, TH)
        Description.Position, Description.Size = UDim2.fromOffset(0, TH + 10), UDim2.new(1, -6, 0, DH)
        Language.Position, Language.Size = UDim2.fromOffset(0, TH + DH + 24), UDim2.new(1, -6, 0, Library:Metrics().Target)
        local Y = TH + DH + Library:Metrics().Target + 36
        Footer.Position, Footer.Size, Footer.Visible = UDim2.fromOffset(0, Y), UDim2.new(1, -6, 0, FH), FH > 0
        Frame.Size = UDim2.fromOffset(W, math.min(Y + FH + 24, View.Y - 16))
        Body.CanvasSize = UDim2.fromOffset(0, Y + FH)
        Fitting = false
    end
    local function Display()
        local Entry = Languages[Index]
        Title.Text = tostring(Entry.Title or Info.Title or "Unsupported executor")
        Description.Text = tostring(Entry.Description or Info.Description or ("This script does not support " .. Executor .. "."))
        Language.Text = "Language: " .. tostring(Entry.Name or Index)
        Fit()
    end
    Language.Activated:Connect(function(Input)
        if Library:CanInteract(Language, Input) then Index = Index % #Languages + 1; Display() end
    end)
    function Screen:Destroy() if Frame.Parent then Frame:Destroy() end end
    Library.TextReflows[Frame] = Fit
    Library:GiveSignal(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit), Frame)
    Display()
    if typeof(Info.OnUnsupported) == "function" then Library:SafeCallback(Info.OnUnsupported, Screen) end
    return Screen
end


function Library:RecordNotification(Title: any, Description: any, Type: any)
    Type = tostring(Type or "Info")
    local Text = Type .. "\n" .. (Title and tostring(Title) .. "\n" or "") .. tostring(Description or "")
    local Last = Library.NotificationHistory[1]
    if Last and Last.Text == Text then
        Last.Count += 1
        Last.Timestamp = os.time()
    else
        table.insert(Library.NotificationHistory, 1, { Text = Text, Title = tostring(Title or ""), Description = tostring(Description or ""), Type = Type, Count = 1, Timestamp = os.time() })
        if #Library.NotificationHistory > 100 then table.remove(Library.NotificationHistory) end
    end
    if not (Library.HistoryOpen and Library.LayoutMain and Library.LayoutMain.Visible) then Library.NotificationUnread += 1 end
    if Library.RefreshNotificationHistory then Library:RefreshNotificationHistory() end
end

function Library:Notify(...)
    local Info = select(1, ...)
    local Data = typeof(Info) == "table" and table.clone(Info) or { Description = tostring(Info or ""), Time = select(2, ...), SoundId = select(3, ...) }
    Data.Title = Data.Title ~= nil and tostring(Data.Title) or nil
    Data.Description = tostring(Data.Description or "")
    Data.Type = tostring(Data.Type or "Info")
    Data.Closable = Data.Closable ~= false
    Data.Destroyed = Library.Unloaded
    Data.Steps = IsFinite(Data.Steps) and Data.Steps > 0 and Data.Steps or nil
    if typeof(Data.Time) ~= "Instance" then Data.Time = IsFinite(Data.Time) and math.max(0, Data.Time) or 5 end
    local Fake, Holder, Title, Description, IconLabel, CloseButton, Progress, LifetimeConnection
    local function Cancel(Thread)
        if Thread and Thread ~= coroutine.running() then pcall(task.cancel, Thread) end
    end
    function Data:Resize()
        if Data.Destroyed or not Holder then return end
        local MaxWidth = math.max(96, math.min(360, ScreenGui.AbsoluteSize.X / Library.DPIScale - 16))
        local Left = IconLabel and 44 or 14
        local Right = Data.Closable and 38 or 14
        local Width = math.max(1, MaxWidth - Left - Right)
        local Y, TextWidth = 12, 40
        if Title then
            local X, Height = Library:GetTextBounds(Data.Title or "", Title.FontFace, Title.TextSize, Width)
            Title.Position = UDim2.fromOffset(Left, Y)
            Title.Size = UDim2.fromOffset(Width, Height)
            Y += Height + 4
            TextWidth = math.max(TextWidth, X)
        end
        local X, Height = Library:GetTextBounds(Data.Description, Description.FontFace, Description.TextSize, Width)
        Description.Position = UDim2.fromOffset(Left, Y)
        Description.Size = UDim2.fromOffset(Width, Height)
        TextWidth = math.max(TextWidth, X)
        local TotalHeight = math.max(Y + Height + 10, IconLabel and 44 or 30)
        if Progress and Progress.Parent.Visible then TotalHeight += 7 end
        Fake.Size = UDim2.fromOffset(math.min(MaxWidth, TextWidth + Left + Right), TotalHeight)
        -- Give labels the actual content width after fitting short notifications.
        local ActualWidth = math.max(1, Fake.Size.X.Offset - Left - Right)
        if Title then Title.Size = UDim2.fromOffset(ActualWidth, Title.Size.Y.Offset) end
        Description.Size = UDim2.fromOffset(ActualWidth, Description.Size.Y.Offset)
        Library:UpdateNotificationPositions()
    end
    function Data:ChangeTitle(Text)
        if Data.Destroyed or not Holder then return end
        Data.Title = tostring(Text or "")
        if not Title then
            Title = New("TextLabel", { BackgroundTransparency = 1, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextColor3 = Data.TitleColor or "FontColor", Parent = Holder })
        end
        Title.Text = Data.Title
        Data:Resize()
    end
    function Data:ChangeDescription(Text)
        if Data.Destroyed or not Description then return end
        Data.Description = tostring(Text or "")
        Description.Text = Data.Description
        Data:Resize()
    end
    function Data:ChangeStep(Step)
        if Data.Destroyed or not Progress or not Data.Steps or not IsFinite(Step) then return end
        Progress.Size = UDim2.fromScale(math.clamp(Step, 0, Data.Steps) / Data.Steps, 1)
    end
    function Data:Destroy(Reason, Immediate)
        if Data.Destroyed then return end
        Data.Destroyed = true
        Data.CloseReason = (Reason == "user" or Reason == "timer") and Reason or "script"
        Cancel(Data.TimerThread); Data.TimerThread = nil
        StopTween(Data.TimerTween)
        if LifetimeConnection then LifetimeConnection:Disconnect(); LifetimeConnection = nil end
        if Fake then
            local Index = table.find(Library.NotifyOrder, Fake)
            if Index then table.remove(Library.NotifyOrder, Index) end
            Library.Notifications[Fake] = nil
            Library:UpdateNotificationPositions()
            if Immediate or Library.Unloaded or not Fake.Parent then Fake:Destroy()
            else
                Library:CreateTween(Holder, Library.NotifyTweenInfo, { Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0) }):Play()
                Data.CleanupThread = task.delay(Library.NotifyTweenInfo.Time, function()
                    Data.CleanupThread = nil
                    if Fake.Parent then Fake:Destroy() end
                end)
            end
        end
        Library:SafeCallback(Data.Callback, Data.CloseReason)
    end
    if Library.Unloaded then return Data end
    Library:RecordNotification(Data.Title, Data.Description, Data.Type)
    Fake = New("Frame", { AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.zero or Vector2.new(1, 0), BackgroundTransparency = 1, Size = UDim2.fromOffset(240, 48), Parent = NotificationArea })
    Holder = New("Frame", { BackgroundColor3 = "MainColor", Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0), Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = Fake })
    Data.Holder = Holder
    Library:AddOutline(Holder)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Holder }))
    local Icon = Library:GetCustomIcon(Data.BigIcon or Data.Icon)
    if Icon then
        IconLabel = New("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(22, 22), Image = Icon.Url, ImageRectOffset = Icon.ImageRectOffset, ImageRectSize = Icon.ImageRectSize, ImageColor3 = Data.IconColor or "AccentColor", Parent = Holder })
    end
    if Data.Title then
        Title = New("TextLabel", { BackgroundTransparency = 1, Text = Data.Title, TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Data.TitleColor or "FontColor", Parent = Holder })
    end
    Description = New("TextLabel", { BackgroundTransparency = 1, Text = Data.Description, TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Data.DescriptionColor or "FontColor", Parent = Holder })
    if Data.Closable then
        CloseButton = New("TextButton", { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(28, 28), Text = "", Parent = Holder })
        Library:CreateSymbol(CloseButton, "close", UDim2.fromOffset(6, 6), 16)
        CloseButton.Activated:Connect(function() Data:Destroy("user") end)
    end
    local Timed = not Data.Persist and not Data.Steps and typeof(Data.Time) == "number"
    local Track = New("Frame", { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "OutlineColor", Position = UDim2.new(0, 10, 1, -7), Size = UDim2.new(1, -20, 0, 2), Visible = Timed or Data.Steps ~= nil, Parent = Holder })
    Progress = New("Frame", { BackgroundColor3 = "AccentColor", Size = UDim2.fromScale(Data.Steps and 0 or 1, 1), Parent = Track })
    Library.TextReflows[Holder] = function() Data:Resize() end
    Data:Resize()
    Library.Notifications[Fake] = Data
    table.insert(Library.NotifyOrder, Fake)
    Library:UpdateNotificationPositions()
    Library:CreateTween(Holder, Library.NotifyTweenInfo, { Position = UDim2.fromOffset(0, 0) }):Play()
    if typeof(Data.Time) == "Instance" then
        -- Time can observe an external lifetime, but a notification never owns that Instance.
        LifetimeConnection = Data.Time.Destroying:Connect(function() Data:Destroy("script") end)
    elseif Timed then
        Data.TimerThread = task.delay(Library.NotifyTweenInfo.Time, function()
            if Data.Destroyed then return end
            Data.TimerTween = Library:CreateTween(Progress, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
            Data.TimerTween:Play()
            task.wait(Data.Time)
            Data.TimerThread = nil
            Data:Destroy("timer")
        end)
    end
    if Data.SoundId then
        local SoundId = typeof(Data.SoundId) == "number" and ("rbxassetid://" .. Data.SoundId) or Data.SoundId
        local Ok, Err = pcall(function() New("Sound", { SoundId = SoundId, Volume = 1, PlayOnRemove = true, Parent = SoundService }):Destroy() end)
        if not Ok then warn("Notification sound: " .. tostring(Err)) end
    end
    return Data
end

-- Presentation restoration is independent of option setters and feature profiles.
Library.NavigationTargets = { Page = {}, Box = {}, Section = {} }
Library.VirtualLists = Library.VirtualLists or setmetatable({}, { __mode = "k" })
function Library:RefreshVisibleComponents()
    for Frame, View in Library.VirtualLists do
        if Frame.Parent and Library:IsObjectVisible(Frame) then View:Paint() end
    end
end
function Library:NavigationKey(Parent, Kind, Name)
    Name = tostring(Name or "")
    return (Parent and Parent.NavKey or "") .. "/" .. Kind .. "/" .. tostring(#Name) .. ":" .. Name
end
function Library:RegisterNavigation(Kind, Key, Object)
    Object.NavKey = Key
    if Object.Internal then return end
    Library.NavigationTargets[Kind][Key] = Object
    local Holder = Object.BoxHolder or Object.Container or Object.Holder
    if Holder then Holder.Destroying:Once(function()
        if Library.NavigationTargets[Kind][Key] == Object then Library.NavigationTargets[Kind][Key] = nil end
    end) end
    Library:ScheduleNavigationRestore()
end
function Library:ScheduleNavigationRestore()
    if Library.NavigationRestoreQueued or Library.Unloaded then return end
    Library.NavigationRestoreQueued = true
    Library:DeferOwned(ScreenGui, nil, function()
        Library.NavigationRestoreQueued = false
        Library:TryRestoreNavigation()
    end)
end
function Library:GetNavigation()
    local Data = { Tabs = {}, Sections = {}, Scroll = {} }
    local Pending = Library.PendingNavigation
    if Pending then
        Data = CopyDefault(Pending)
        Data.Tabs, Data.Sections, Data.Scroll = Data.Tabs or {}, Data.Sections or {}, Data.Scroll or {}
    end
    if Library.ActiveTab and not Library.ActiveTab.IsKeyTab and not (Pending and Pending.Page) then Data.Page = Library.ActiveTab.NavKey end
    for Key, Box in Library.NavigationTargets.Box do if Box.ActiveTab and not (Pending and Pending.Tabs and Pending.Tabs[Key]) then Data.Tabs[Key] = Box.ActiveTab.Name end end
    for Key, Section in Library.NavigationTargets.Section do if not (Pending and Pending.Sections and Pending.Sections[Key] ~= nil) then Data.Sections[Key] = Section.Minimized == true end end
    for Key, Page in Library.NavigationTargets.Page do
        if Page.GetScrollPositions and not (Pending and Pending.Scroll and Pending.Scroll[Key]) then Data.Scroll[Key] = Page:GetScrollPositions() end
    end
    return Data
end
function Library:ValidateNavigation(Data)
    if typeof(Data) ~= "table" then return false, "invalid navigation record" end
    if Data.Page ~= nil and (typeof(Data.Page) ~= "string" or #Data.Page > 4096) then return false, "invalid saved page" end
    for _, Field in { "Tabs", "Sections", "Scroll" } do
        if Data[Field] ~= nil then
            if typeof(Data[Field]) ~= "table" then return false, "invalid navigation " .. Field end
            local Count = 0
            for Key, Value in Data[Field] do
                Count += 1
                if Count > 512 or typeof(Key) ~= "string" or #Key > 4096 then return false, "invalid navigation key" end
                if Field == "Tabs" and (typeof(Value) ~= "string" or #Value > 1024) then return false, "invalid inner tab name" end
                if Field == "Sections" and typeof(Value) ~= "boolean" then return false, "invalid section state" end
                if Field == "Scroll" then
                    if typeof(Value) ~= "table" then return false, "invalid scroll record" end
                    for _, Side in { "Left", "Right", "Single" } do
                        local Y = Value[Side]
                        if Y ~= nil and (not IsFinite(Y) or Y < 0 or Y > 10000000) then return false, "invalid scroll offset" end
                    end
                end
            end
        end
    end
    return true
end
function Library:SetNavigation(Data)
    local Valid, Error = Library:ValidateNavigation(Data)
    if not Valid then return false, Error end
    Library.PendingNavigation = CopyDefault(Data)
    Library:ScheduleNavigationRestore()
    return true
end
function Library:NavigationSelected(Kind, Key)
    if Library.LayoutRestoring or Library.NavigationRestoring then return end
    local Pending = Library.PendingNavigation
    if Pending then
        if Kind == "Page" then Pending.Page = nil
        elseif Kind == "Box" and Pending.Tabs then Pending.Tabs[Key] = nil
        elseif Kind == "Section" and Pending.Sections then Pending.Sections[Key] = nil
        elseif Kind == "Scroll" and Pending.Scroll then Pending.Scroll[Key] = nil end
    end
    Library:LayoutChanged()
end
function Library:TryRestoreNavigation()
    local Data = Library.PendingNavigation
    if not Data or Library.NavigationRestoring or Library.Unloaded then return end
    Library.NavigationRestoring = true
    local Previous = Library.LayoutRestoring
    Library.LayoutRestoring = true
    local Ok, Error = pcall(function()
        if Data.Page then
            local Page = Library.NavigationTargets.Page[Data.Page]
            if Page and Page.Visible ~= false and not Page.IsKeyTab then Page:Show(); Data.Page = nil end
        end
        for Key, Name in Data.Tabs or {} do
            local Box = Library.NavigationTargets.Box[Key]
            local Tab = Box and Box.Tabs[Name]
            if Tab and Tab.ButtonHolder.Visible then Tab:Show(); Data.Tabs[Key] = nil end
        end
        for Key, Minimized in Data.Sections or {} do
            local Section = Library.NavigationTargets.Section[Key]
            if Section and not Section.Destroyed then Section:SetMinimized(Minimized, true); Data.Sections[Key] = nil end
        end
        for Key, Positions in Data.Scroll or {} do
            local Page = Library.NavigationTargets.Page[Key]
            if Page and Page.RestoreScrollPositions then Page:RestoreScrollPositions(Positions) end
        end
    end)
    Library.LayoutRestoring, Library.NavigationRestoring = Previous, false
    if not Ok then warn("Chiyo navigation restoration: " .. tostring(Error)) end
    Library:RefreshVisibleComponents()
end
function Library:GetPreferences()
    local Window = Library.Window
    local Pins = {}
    if Window and Window.Studio then for Key in Window.Studio.Pins do table.insert(Pins, Key) end; table.sort(Pins) end
    return {
        Version = 2, Palette = Library.ThemeName, Accent = Library.Scheme.AccentColor:ToHex(),
        Readability = Library.Readability, ReducedMotion = Library.ReducedMotion,
        CompactSidebar = Window and Window.RequestedCompact or false,
        SidebarWidth = Window and Window.ExpandedSidebarWidth or 212,
        Hidden = Window and not Library.Toggled or false, Window = Library:GetLayout(), Navigation = Library:GetNavigation(), Pins = Pins,
        Launcher = Library.Launcher and PackUDim2(Library.Launcher.Position) or nil,
    }
end
function Library:ValidatePreferences(Data)
    if typeof(Data) ~= "table" then return false, "invalid UI preferences" end
    if Data.Version == 1 then return true, "legacy visual preferences are accepted but not applied" end
    if Data.Version ~= 2 then return false, "unsupported UI preference version" end
    if Data.Palette ~= nil and not Library.Themes[Data.Palette] then return false, "unknown dark palette" end
    if Data.Accent ~= nil and (typeof(Data.Accent) ~= "string" or not Data.Accent:match("^%x%x%x%x%x%x$")) then return false, "invalid accent" end
    if Data.Readability ~= nil and not Library.ReadabilityPresets[Data.Readability] then return false, "invalid readability preset" end
    for _, Key in { "ReducedMotion", "CompactSidebar", "Hidden" } do if Data[Key] ~= nil and typeof(Data[Key]) ~= "boolean" then return false, "invalid " .. Key end end
    if Data.SidebarWidth ~= nil and (not IsFinite(Data.SidebarWidth) or Data.SidebarWidth < 160 or Data.SidebarWidth > 480) then return false, "invalid sidebar width" end
    if Data.Launcher ~= nil and not ValidUDim2(Data.Launcher) then return false, "invalid launcher placement" end
    if Data.Window ~= nil then local Ok, Error = Library:ValidateLayout(Data.Window); if not Ok then return false, Error end end
    if Data.Navigation ~= nil then local Ok, Error = Library:ValidateNavigation(Data.Navigation); if not Ok then return false, Error end end
    if Data.Pins ~= nil then
        if typeof(Data.Pins) ~= "table" then return false, "invalid search pins" end
        local Count = 0
        for Index, Key in Data.Pins do
            Count += 1
            if Count > 128 or not IsFinite(Index) or Index < 1 or Index % 1 ~= 0 or typeof(Key) ~= "string" or #Key > 4096 then return false, "invalid search pin" end
        end
        for Index = 1, Count do if Data.Pins[Index] == nil then return false, "sparse search pin array" end end
    end
    return true
end
function Library:SetPreferences(Data)
    if (Library.FeatureLoadDepth or 0) > 0 then return true, "UI preferences are not feature-profile values" end
    local Valid, Error = Library:ValidatePreferences(Data)
    if not Valid then return false, Error end
    if Data.Version == 1 then return true, "legacy visual preferences ignored; Chiyo preferences use version 2" end
    local Previous = Library.LayoutRestoring
    Library.LayoutRestoring = true
    local Ok, Failure = pcall(function()
        if Data.Palette then Library:SetTheme(Data.Palette) end
        if Data.Accent then Library:SetAccentColor(Color3.fromHex(Data.Accent)) end
        if Data.Readability then Library:SetReadability(Data.Readability) end
        if Data.ReducedMotion ~= nil then Library:SetReducedMotion(Data.ReducedMotion) end
        if Data.Navigation then Library:SetNavigation(Data.Navigation) end
        local Window = Library.Window
        if Window then
            if Data.SidebarWidth then Window:SetSidebarWidth(Data.SidebarWidth) end
            if Data.CompactSidebar ~= nil then Window:SetCompact(Data.CompactSidebar) end
            if Data.Window then Library:SetLayout(Data.Window) end
            if Data.Pins and Window.Studio then table.clear(Window.Studio.Pins); for _, Key in Data.Pins do Window.Studio.Pins[Key] = true end end
            if Data.Hidden ~= nil then Library:Toggle(not Data.Hidden) end
            if Data.Launcher and Library.Launcher then Library.Launcher.Position = UnpackUDim2(Data.Launcher); Library:SnapFrame(Library.Launcher, true) end
        else Library.PendingWindowPreferences = CopyDefault(Data) end
    end)
    Library.LayoutRestoring = Previous
    if not Ok then return false, tostring(Failure) end
    return true
end
function Library:ResetAppearance()
    if (Library.FeatureLoadDepth or 0) > 0 then return false end
    Library:SetTheme("Charcoal")
    Library:SetAccentColor(Color3.fromHex("FF4275"))
    Library:SetReadability("Standard")
    Library:SetReducedMotion(false)
    if Library.Window then Library.Window:SetSidebarWidth(212); Library.Window:SetCompact(false) end
    Library:LayoutChanged()
    Library:SafeCallback(Library.OnAppearanceReset)
    return true
end

-- Search and appearance are window-owned tools, not a dashboard or identity area.
function Library:InstallStudioWorkspace(Window, UI, Info)
    local Studio = { Pins = {}, Index = {}, IndexDirty = true, QueryGeneration = 0, Filter = "All", Selection = 1, PaletteOpen = false }
    Window.Studio, Window.OverviewVisible = Studio, false
    local function Plain(Value)
        return tostring(Value or ""):gsub("<[^>]->", ""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&")
    end
    local function Ordered(Map)
        local Result = {}
        for _, Object in Map or {} do if typeof(Object) == "table" then table.insert(Result, Object) end end
        table.sort(Result, function(A, B)
            local AO = A.ButtonHolder and A.ButtonHolder.LayoutOrder or A.BoxHolder and A.BoxHolder.LayoutOrder or 0
            local BO = B.ButtonHolder and B.ButtonHolder.LayoutOrder or B.BoxHolder and B.BoxHolder.LayoutOrder or 0
            return AO == BO and tostring(A.Name or "") < tostring(B.Name or "") or AO < BO
        end)
        return Result
    end
    local function Available(Entry)
        if Entry.Root.Visible == false or Entry.Object.Destroyed or Entry.Object.Visible == false then return false end
        if Entry.Object.ParentObj and (Entry.Object.ParentObj.Destroyed or Entry.Object.ParentObj.Visible == false) then return false end
        for _, Owner in Entry.Chain do if Owner.Visible == false or Owner.Destroyed then return false end end
        return true
    end
    local function Caption(Entry) return Plain(Entry.Object.Text or Entry.Object.Name or Entry.Label or Entry.Idx or Entry.Key) end
    function Window:GetControlIndex()
        if not Studio.IndexDirty then return Studio.Index end
        local Index = {}
        local function Add(Object, Root, Path, Chain, Kind)
            if Object.Internal or Object.Destroyed then return end
            local Id = Object.Idx
            local Key = Id ~= nil and (Kind .. ":" .. type(Id) .. ":" .. tostring(Id)) or (Kind .. ":" .. Path)
            table.insert(Index, { Key = Key, Idx = Id, Object = Object, Root = Root, Path = Path, Chain = table.clone(Chain), Kind = Kind, Pinnable = Id ~= nil or Kind == "Page" or Kind == "Section" })
        end
        for _, Root in Ordered(Library.Tabs) do
            if not Root.IsKeyTab then
                local Seen, Walk = {}, nil
                Add(Root, Root, Root.Name, {}, "Page")
                local function WalkTabs(Box, Path, Chain)
                    for _, Child in Ordered(Box.Tabs) do
                        local Next = table.clone(Chain); table.insert(Next, Child)
                        Add(Child, Root, Path .. " / " .. Child.Name, Next, "Section")
                        Walk(Child, Path .. " / " .. Child.Name, Next)
                    end
                end
                Walk = function(Box, Path, Chain)
                    if Seen[Box] then return end
                    Seen[Box] = true
                    for _, Element in Box.Elements or {} do
                        if Element.Type ~= "Divider" then
                            Add(Element, Root, Path, Chain, Element.Type or "Control")
                            for _, Addon in Element.Addons or {} do Add(Addon, Root, Path, Chain, Addon.Type or "Control") end
                            if Element.SubButton then Add(Element.SubButton, Root, Path, Chain, "Button") end
                        end
                    end
                    for _, Dep in Box.DependencyBoxes or {} do local Next = table.clone(Chain); table.insert(Next, Dep); Walk(Dep, Path, Next) end
                    for _, Dep in Box.DependencyGroupboxes or {} do local Next = table.clone(Chain); table.insert(Next, Dep); Walk(Dep, Path, Next) end
                    for _, Inner in Box.InnerTabboxes or {} do WalkTabs(Inner, Path, Chain) end
                end
                for _, Box in Ordered(Root.Groupboxes) do
                    local Chain, Path = { Box }, Root.Name .. " / " .. Box.Name
                    Add(Box, Root, Path, Chain, "Section"); Walk(Box, Path, Chain)
                end
                for _, Box in Ordered(Root.Tabboxes) do WalkTabs(Box, Root.Name, {}) end
                for _, Box in Ordered(Root.DependencyGroupboxes) do Walk(Box, Root.Name, { Box }) end
            end
        end
        Studio.Index, Studio.IndexDirty = Index, false
        return Index
    end
    local function Find(Identifier)
        if Identifier == nil then return nil end
        if typeof(Identifier) == "table" and Identifier.Object and Identifier.Root then return Identifier end
        for _, Entry in Window:GetControlIndex() do if Entry.Key == Identifier or Entry.Idx == Identifier or Entry.Object == Identifier then return Entry end end
        return nil
    end
    function Window:IsControlPinned(Identifier) local Entry = Find(Identifier); return Entry ~= nil and Studio.Pins[Entry.Key] == true end
    function Window:GetPinnedControls()
        local Result = {}; for _, Entry in Window:GetControlIndex() do if Studio.Pins[Entry.Key] then table.insert(Result, Entry) end end; return Result
    end
    function Window:PinControl(Identifier, Value)
        local Entry = Find(Identifier)
        if not Entry or not Entry.Pinnable then return false, "control has no stable identifier" end
        if Value == nil then Value = not Studio.Pins[Entry.Key] end
        Studio.Pins[Entry.Key] = Value == true or nil
        Library:LayoutChanged()
        if Studio.RenderResults then Studio.RenderResults() end
        return true
    end
    function Window:FocusControl(Identifier)
        local Entry = Find(Identifier)
        if not Entry then return false, "control not found" end
        if not Available(Entry) then return false, "this control is hidden by its page or dependencies" end
        if Library.ActiveDialog then return false, "close the current dialog first" end
        Window:CloseCommandPalette()
        Library:Toggle(true)
        if Library.Searching then Library:UpdateSearch("") end
        Library:NavigationSelected("Scroll", Entry.Root.NavKey)
        Entry.Root:Show(true)
        for _, Owner in Entry.Chain do
            if Owner.SetMinimized then Owner:SetMinimized(false, true) end
            if Owner.ParentTabbox and Owner.Show then Owner:Show(true) end
        end
        local Object = Entry.Object
        local Holder = Object.Holder or Object.Container or (Object.ParentObj and Object.ParentObj.Holder)
        if not Holder then return true end
        Library:DeferOwned(Holder, nil, function()
            Library:DeferOwned(Holder, nil, function()
                if not Available(Entry) then return end
                local Parent = Holder.Parent
                while Parent and Parent ~= UI.Main do
                    if Parent:IsA("ScrollingFrame") and Library:IsObjectVisible(Parent) then
                        local Y = Parent.CanvasPosition.Y + Holder.AbsolutePosition.Y - Parent.AbsolutePosition.Y - 8
                        Parent.CanvasPosition = Vector2.new(Parent.CanvasPosition.X, math.clamp(Y, 0, math.max(0, Parent.AbsoluteCanvasSize.Y - Parent.AbsoluteSize.Y)))
                    end
                    Parent = Parent.Parent
                end
                if not Object.Disabled then
                    local Target = Object.Bar or Object.Base or Object.DisplayButton or Object.Picker
                    if not Target then Target = Holder:IsA("GuiButton") and Holder or Library:GetFocusable(Holder)[1] end
                    if Target and Target.Active and Target.Selectable then GuiService.SelectedObject = Target end
                end
                local Stroke = New("UIStroke", { Name = "SearchReveal", Color = "AccentColor", Thickness = 2, Parent = Holder })
                if not Library:IsReducedMotion() then Library:CreateTween(Stroke, TweenInfo.new(0.65), { Transparency = 1 }):Play() end
                Library:DeferOwned(Stroke, 0.75, function() Stroke:Destroy() end)
                Library:LayoutChanged()
            end)
        end)
        return true
    end
    function Library:MarkStudioIndexDirty() Studio.IndexDirty = true end
    function Studio.ScheduleRefresh() Studio.IndexDirty = true; if Studio.PaletteOpen then Studio.RenderResults() end end
    function Studio.Refresh() Studio.ScheduleRefresh() end
    function Window:OnPageAdded(Tab) Studio.IndexDirty = true; Library:ScheduleNavigationRestore() end
    function Window:OnPageShown(Tab)
        Window:ShowTabInfo(Tab.Name, Tab.Description)
        if Window.CloseNavigationDrawer then Window:CloseNavigationDrawer() end
        Library:RefreshVisibleComponents()
        Library:LayoutChanged()
    end
    function Window:ShowOverview() return false, "Overview has been removed; select an application page" end
    function Window:SetIdentityHidden(Value) Studio.IdentityHidden = Value == true; return true end

    local Overlay = New("TextButton", { Name = "ControlSearch", BackgroundColor3 = "DarkColor", BackgroundTransparency = 0.38, Size = UDim2.fromScale(1, 1), Text = "", Selectable = false, Visible = false, ZIndex = 10000, Parent = UI.Main })
    local Panel = New("TextButton", { Name = "SearchPanel", BackgroundColor3 = "MainColor", Text = "", Selectable = false, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(620, 490), ZIndex = 10001, Parent = Overlay })
    Library:Surface(Panel, "Panel")
    local Query = New("TextBox", { Name = "ControlQuery", BackgroundColor3 = "FieldColor", ClearTextOnFocus = false, PlaceholderText = "Find a control or location", Text = "", TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -62, 0, 40), Parent = Panel })
    Library:StyleField(Query)
    New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Query })
    local Close = New("TextButton", { BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(36, 40), Parent = Panel })
    Library:CreateSymbol(Close, "close", UDim2.new(0.5, -9, 0.5, -9), 18)
    Library:AddTooltip("Close search", "", Close)
    local FilterRail = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 36), Position = UDim2.fromOffset(10, 60), CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2, Parent = Panel })
    New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = FilterRail })
    local Filters = {}
    local ResultHolder = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 102), Size = UDim2.new(1, -20, 1, -136), Parent = Panel })
    local Count = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 12, 1, -30), Size = UDim2.new(1, -24, 0, 24), Parent = Panel })
    local View
    local function Activate(Entry)
        local Ok, Error = Window:FocusControl(Entry.Source)
        if not Ok then Count.Text = Error end
    end
    View = Library:CreateVirtualList(ResultHolder, { IsOpen = function() return Studio.PaletteOpen end, NoMarker = true, KeyboardFocus = true, EmptyText = "No matching controls. Try a shorter query.", Activate = Activate,
        IsSelected = function(Row) return Row.Key == Studio.SelectedKey end,
        HandleInput = function(Input) Window:HandleStudioInput(Input) end,
    })
    Studio.ResultView = View
    function Studio.RenderResults()
        if not Studio.PaletteOpen or Library.Unloaded then return end
        local Results, Filter = {}, Trim(Query.Text):lower()
        for _, Entry in Window:GetControlIndex() do
            local Include = Available(Entry) and (Studio.Filter == "All" or Studio.Filter == "Pinned" and Studio.Pins[Entry.Key] or Studio.Filter == "Enabled" and Entry.Kind == "Toggle" and Entry.Object.Value)
            if Include then
                local Score = math.max(SearchScore(Caption(Entry), Filter), SearchScore(Entry.Path, Filter))
                if Library.SearchValues and Filter ~= "" then
                    for _, Value in Entry.Object.Values or {} do
                        local Text = Entry.Object.ValueLabels and Entry.Object.ValueLabels[Value] or Value
                        if Entry.Object.FormatListValue then local Ok, Formatted = pcall(Entry.Object.FormatListValue, Value, Text); if Ok and Formatted ~= nil then Text = Formatted end end
                        Score = math.max(Score, SearchScore(Plain(Text), Filter))
                    end
                end
                if Score > 0 then
                    local State = Entry.Object.Disabled and " / Disabled" or ""
                    table.insert(Results, { Key = Entry.Key, Text = Caption(Entry), Subtitle = Entry.Kind .. " / " .. Entry.Path .. State, Source = Entry, Score = Score })
                end
            end
        end
        table.sort(Results, function(A, B) return A.Score == B.Score and A.Key < B.Key or A.Score > B.Score end)
        for Name, Button in Filters do Library:StyleAction(Button, Studio.Filter == Name and "Primary" or "Secondary", false, false) end
        Studio.Selection, Studio.SelectedKey = 1, nil
        View:SetEntries(Results, true)
        Count.Text = tostring(#Results) .. " matches / Enter reveals; Escape closes"
    end
    for _, Name in { "All", "Pinned", "Enabled" } do
        local Button = New("TextButton", { BackgroundColor3 = "HeaderColor", Text = Name, RichText = false, TextSize = 14, Size = UDim2.fromOffset(90, 36), Parent = FilterRail })
        Library:StyleAction(Button, "Secondary", false, false)
        Button.Activated:Connect(function(Input) if Library:CanInteract(Button, Input) then Studio.Filter = Name; Studio.RenderResults() end end)
        Filters[Name] = Button
    end
    local function ResizePalette()
        if not UI.Main.Parent then return end
        local Origin, ViewSize = Library:GetUsableRect(true)
        local Base = UI.Main.AbsolutePosition - ScreenGui.AbsolutePosition
        local M = Library:Metrics()
        local Width, Height = math.min(680, ViewSize.X - 20), math.min(520 + M.Offset * 16, ViewSize.Y - 20)
        Width, Height = math.max(120, Width), math.max(110, Height)
        Panel.Size = UDim2.fromOffset(Width, Height)
        Panel.Position = UDim2.fromOffset(math.floor(Origin.X - Base.X + ViewSize.X / 2), math.floor(Origin.Y - Base.Y + ViewSize.Y / 2))
        Query.Size = UDim2.new(1, -M.Target - 30, 0, M.Field)
        Close.Size = UDim2.fromOffset(M.Target, M.Field)
        FilterRail.Position = UDim2.fromOffset(10, M.Field + 18)
        FilterRail.Size = UDim2.new(1, -20, 0, M.Target)
        for _, Button in Filters do local W = Library:GetTextBounds(Button.Text, Button.FontFace, Button.TextSize, 0, false); Button.Size = UDim2.fromOffset(W + 26, M.Target) end
        local Top = M.Field + M.Target + 26
        ResultHolder.Position, ResultHolder.Size = UDim2.fromOffset(10, Top), UDim2.new(1, -20, 1, -Top - M.Field)
        Count.Size, Count.Position = UDim2.new(1, -24, 0, M.Field - 4), UDim2.new(0, 12, 1, -M.Field)
        Count.TextWrapped = true
        View:Refresh()
    end
    function Studio.Layout() ResizePalette() end
    function Window:OpenCommandPalette(Value, Filter)
        if Library.Unloaded or Library.ActiveDialog or Library.PickingKeybind then return false end
        if Window.SetHelpMode then Window:SetHelpMode(false) end
        if CurrentMenu then CurrentMenu:Close("search") end
        if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
        if Library.ToggleNotificationHistory then Library:ToggleNotificationHistory(false) end
        Library:Toggle(true)
        if Studio.PaletteOpen then Query.Text = tostring(Value or ""); Query:CaptureFocus(); return true end
        Studio.Filter = Filter == "Pinned" and "Pinned" or Filter == "Enabled" and "Enabled" or "All"
        Studio.PaletteOpen, Overlay.Visible, Studio.IndexDirty = true, true, true
        Query.Text = tostring(Value or "")
        ResizePalette(); Studio.RenderResults()
        Library:PushFocusScope(Studio, Panel, Query)
        Query:CaptureFocus()
        return true
    end
    function Window:CloseCommandPalette()
        if not Studio.PaletteOpen then return end
        Studio.QueryGeneration += 1
        Studio.PaletteOpen, Overlay.Visible = false, false
        if UserInputService:GetFocusedTextBox() == Query then Query:ReleaseFocus() end
        Library:PopFocusScope(Studio)
    end
    function Window:HandleStudioInput(Input)
        if Library.PickingKeybind or Library.CaptureInputs[Input] or Studio.LastInput == Input then return false end
        local Key, Focus = Input.KeyCode, UserInputService:GetFocusedTextBox()
        local Control = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        if Control and Key == Enum.KeyCode.K and not Info.DisableSearch and (not Focus or Focus == Query) then
            Studio.LastInput = Input; Library.ConsumedInputs[Input], Library.HandledInputs[Input] = true, true
            if Studio.PaletteOpen then Window:CloseCommandPalette() else Window:OpenCommandPalette() end
            return true
        end
        if not Studio.PaletteOpen then return false end
        if Key == Enum.KeyCode.Escape or Key == Enum.KeyCode.ButtonB then Window:CloseCommandPalette()
        elseif Key == Enum.KeyCode.Down or Key == Enum.KeyCode.DPadDown or Key == Enum.KeyCode.Up or Key == Enum.KeyCode.DPadUp then
            local Delta = (Key == Enum.KeyCode.Up or Key == Enum.KeyCode.DPadUp) and -1 or 1
            Studio.Selection = math.clamp(Studio.Selection + Delta, 1, math.max(1, #View.Entries))
            local Row = View.Entries[Studio.Selection]; Studio.SelectedKey = Row and Row.Key
            View.Keyboard = true; View:RevealIndex(Studio.Selection)
        elseif Key == Enum.KeyCode.Return or Key == Enum.KeyCode.KeypadEnter then
            local Row = View.Entries[Studio.Selection]; if Row then Activate(Row) end
        else return false end
        Studio.LastInput = Input; Library.ConsumedInputs[Input], Library.HandledInputs[Input] = true, true
        return true
    end
    Query:GetPropertyChangedSignal("Text"):Connect(function()
        Studio.QueryGeneration += 1; local Generation = Studio.QueryGeneration
        Library:DeferOwned(Query, 0.06, function() if Generation == Studio.QueryGeneration then Studio.RenderResults() end end)
    end)
    Close.Activated:Connect(function() Window:CloseCommandPalette() end)
    Overlay.Activated:Connect(function() Window:CloseCommandPalette() end)
    Library.TextReflows[Panel] = ResizePalette
    UI.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(ResizePalette)
    for _, Property in { "OnScreenKeyboardVisible", "OnScreenKeyboardPosition", "OnScreenKeyboardSize" } do
        pcall(function() Library:GiveSignal(UserInputService:GetPropertyChangedSignal(Property):Connect(function() if Studio.PaletteOpen then ResizePalette() end end), Overlay) end)
    end
    function Window:OpenAppearance()
        if Library.ActiveDialog and Library.ActiveDialog ~= Studio.Appearance or Library.PickingKeybind then return false end
        Window:CloseCommandPalette()
        if Window.SetHelpMode then Window:SetHelpMode(false) end
        if Studio.Appearance and not Studio.Appearance.Destroyed then Studio.Appearance:Destroy() end
        local Dialog = Window:AddDialog("__Chiyo_Appearance", { Title = "Appearance", Description = "", Internal = true, StartHidden = true, Width = 490, MaxHeight = 440, AutoDestroy = true, FooterButtons = { Done = { Title = "Done", Variant = "Primary" } } })
        Studio.Appearance = Dialog
        local function Internal(Object) Object.Internal = true; return Object end
        Internal(Dialog:AddDropdown("__Chiyo_Palette", { Text = "Dark palette", Values = { "Charcoal", "Slate", "Cinder" }, Default = Library.ThemeName, Expandable = false, Callback = function(Value) Library:SetTheme(Value) end }))
        Internal(Dialog:AddLabel("Accent color")):AddColorPicker("__Chiyo_Accent", { Default = Library.Scheme.AccentColor, Title = "Accent color", Callback = function(Value) Library:SetAccentColor(Value) end })
        Options.__Chiyo_Accent.Internal = true
        Internal(Dialog:AddDropdown("__Chiyo_Readability", { Text = "Readability", Values = { "Standard", "Larger", "Largest" }, Default = Library.Readability, Expandable = false, Callback = function(Value) Library:SetReadability(Value) end }))
        Internal(Dialog:AddToggle("__Chiyo_Motion", { Text = "Reduced motion", Default = Library.ReducedMotion, Tooltip = "Removes movement without changing input timing or notification lifetimes. A platform reduced-motion preference is also respected.", Callback = function(Value) Library:SetReducedMotion(Value) end }))
        Internal(Dialog:AddToggle("__Chiyo_Compact", { Text = "Compact desktop navigation", Default = Window.RequestedCompact, Tooltip = "Names remain available in tooltips and through the navigation expansion button. Narrow windows use an expandable navigation drawer.", Callback = function(Value) Window:SetCompact(Value) end }))
        Internal(Dialog:AddButton({ Text = "Center window", Func = function() Window:Center(); end }))
        Internal(Dialog:AddButton({ Text = "Reset window placement and size", Func = function() Library:ResetLayout() end }))
        Internal(Dialog:AddButton({ Text = "Reset approved appearance", Func = function() Library:ResetAppearance(); Dialog:Dismiss() end }))
        Internal(Dialog:AddLabel("Appearance and navigation are project UI preferences, not feature-profile values.", true))
        Dialog:Show()
        return true
    end
    UI.Appearance.Activated:Connect(function() Window:OpenAppearance() end)
    UI.Search.Activated:Connect(function() Window:OpenCommandPalette() end)
    Library:OnUnload(function() Studio.QueryGeneration += 1; table.clear(Studio.Index); table.clear(Studio.Pins) end)
end

function Library:CreateWindow(WindowInfo)
    assert(not Library.Window, "A library instance owns one main window")
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    -- Old presentation settings remain accepted but cannot reconstruct the retired shell.
    for _, Key in { "ShowOverview", "HideIdentity", "ColumnMode", "CornerRadius", "Font", "Compact", "SidebarCompacted", "SearchbarSize" } do
        if WindowInfo[Key] ~= nil then Library.LegacyAppearanceAssignments[Key] = WindowInfo[Key] end
    end
    WindowInfo.CornerRadius, WindowInfo.ShowOverview, WindowInfo.SidebarCompacted = 0, false, false
    WindowInfo.SidebarCompactWidth = 64
    Library.CornerRadius = 0
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch, Library.FuzzySearch, Library.SearchValues = WindowInfo.GlobalSearch, WindowInfo.FuzzySearch ~= false, WindowInfo.SearchValues ~= false
    local ViewportSize = ScreenGui.AbsoluteSize
    if ViewportSize.X < 100 or ViewportSize.Y < 100 then ViewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720) end
    local MaxX, MaxY = math.max(160, ViewportSize.X - 48), math.max(160, ViewportSize.Y - 48)
    local RequestedSize = WindowInfo.Size
    WindowInfo.Size = UDim2.fromOffset(math.floor(math.clamp(RequestedSize.X.Offset, math.min(480, MaxX), MaxX)), math.floor(math.clamp(RequestedSize.Y.Offset, math.min(360, MaxY), MaxY)))
    local Window = { ColumnMode = "Auto", RequestedCompact = false, ExpandedSidebarWidth = math.clamp(tonumber(WindowInfo.SidebarWidth) or 212, 180, 320), OverviewVisible = false, PageSequence = 0 }
    local IsCompact = false
    local MainFrame = New("TextButton", { Name = "ChiyoWindow", BackgroundColor3 = "BackgroundColor", Text = "", Selectable = false, Position = WindowInfo.Position, Size = WindowInfo.Size, Visible = false, ZIndex = 10, Parent = ScreenGui })
    Library:Surface(MainFrame, "Panel")
    table.insert(Library.Scales, New("UIScale", { Scale = 1, Parent = MainFrame }))
    Library.LayoutMain, Library.Window = MainFrame, Window
    Window.Holder, Window.MainFrame = MainFrame, MainFrame
    local BackgroundImage
    if WindowInfo.BackgroundImage and WindowInfo.BackgroundImage ~= "" then
        local Ref = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        BackgroundImage = New("ImageLabel", { Name = "ApplicationBackground", BackgroundTransparency = 1, Image = Ref and Ref.Url or tostring(WindowInfo.BackgroundImage), ImageTransparency = 0.94, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, ZIndex = 10, Parent = MainFrame })
    end
    local TopBar = New("Frame", { Name = "ChiyoTitlebar", BackgroundColor3 = "HeaderColor", Size = UDim2.new(1, 0, 0, 44), ZIndex = 40, Parent = MainFrame })
    Library:Surface(TopBar, "Panel")
    New("Frame", { BackgroundColor3 = "AccentColor", Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), ZIndex = 41, Parent = TopBar })
    local function Tool(Name, Icon, Help)
        local Button = New("TextButton", { Name = Name, Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), ZIndex = 42, Parent = TopBar })
        local Symbol = Library:CreateSymbol(Button, Icon, UDim2.new(0.5, -9, 0.5, -9), 18)
        local Focus = New("UIStroke", { Color = "AccentColor", Transparency = 1, Parent = Button })
        local function Paint(Hover) Button.BackgroundTransparency = Hover and 0 or 1; Button.BackgroundColor3 = Library.Scheme.MainColor end
        Button.MouseEnter:Connect(function() Paint(true) end); Button.MouseLeave:Connect(function() Paint(false) end)
        Button.SelectionGained:Connect(function() Focus.Transparency = 0 end); Button.SelectionLost:Connect(function() Focus.Transparency = 1 end)
        Library:AddTooltip(Help, "", Button)
        return Button, Symbol
    end
    local NavToggle, NavSymbol = Tool("NavigationLabels", "panel-left", "Expand or collapse navigation names")
    local SearchButton = Tool("GlobalSearch", "search", "Find controls (Ctrl+K)")
    local HistoryButton = Tool("NotificationHistory", "bell", "Session messages (RightAlt)")
    local Appearance = Tool("Appearance", "sliders", "Appearance and readability")
    local HelpButton = Tool("InspectHelp", "info", "Help inspector: select this, then tap a control to read supplied help without activating it")
    local HideButton = Tool("HideWindow", "minus", "Hide Chiyo; the movable launcher and configured shortcut restore it")
    SearchButton.Visible, HistoryButton.Visible = not WindowInfo.DisableSearch, not WindowInfo.DisableNotificationBell
    local DragSurface = New("Frame", { BackgroundTransparency = 1, Active = true, Position = UDim2.fromOffset(46, 0), Size = UDim2.new(1, -260, 1, 0), ZIndex = 41, Parent = TopBar })
    Library:MakeDraggable(MainFrame, DragSurface, false, true)
    local BrandIcon = Library:GetCustomIcon(WindowInfo.Icon)
    local WindowIcon = New("ImageLabel", { Name = "ApplicationIcon", BackgroundTransparency = 1, Image = BrandIcon and BrandIcon.Url or "", ImageRectOffset = BrandIcon and BrandIcon.ImageRectOffset or Vector2.zero, ImageRectSize = BrandIcon and BrandIcon.ImageRectSize or Vector2.zero, Position = UDim2.new(0, 0, 0.5, -12), Size = UDim2.fromOffset(24, 24), Visible = BrandIcon ~= nil, ZIndex = 41, Parent = DragSurface })
    local WindowTitle = New("TextLabel", { Name = "ApplicationTitle", BackgroundTransparency = 1, Text = tostring(WindowInfo.Title), RichText = false, FontFace = "FontBold", TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(BrandIcon and 32 or 0, 0), Size = UDim2.new(1, BrandIcon and -32 or 0, 1, 0), ZIndex = 41, Parent = DragSurface })
    local TitleHelp = Library:AddTooltip(tostring(WindowInfo.Title) .. (WindowInfo.Subtitle and ("\n" .. tostring(WindowInfo.Subtitle)) or ""), "", DragSurface)
    local BrandName = New("TextLabel", { Name = "ChiyoSignature", BackgroundTransparency = 1, Text = WindowInfo.Title ~= "Chiyo" and "Chiyo" or "", RichText = false, FontFace = "FontBold", TextSize = 15, TextColor3 = "MutedColor", TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 41, Parent = TopBar })
    local NavSurface = New("Frame", { Name = "NavigationSurface", BackgroundColor3 = "NavigationColor", Position = UDim2.fromOffset(0, 44), Size = UDim2.new(0, 212, 1, -76), ZIndex = 20, Parent = MainFrame })
    local DividerLine = New("Frame", { BackgroundColor3 = "OutlineColor", Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), ZIndex = 21, Parent = NavSurface })
    local Tabs = New("ScrollingFrame", { Name = "Categories", BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.fromOffset(0, 0), ScrollingDirection = Enum.ScrollingDirection.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = "OutlineColor", Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12), ZIndex = 22, Parent = NavSurface })
    New("UIListLayout", { Padding = UDim.new(0, 3), Parent = Tabs })
    local Container = New("Frame", { Name = "FeaturePages", BackgroundTransparency = 1, Position = UDim2.fromOffset(222, 54), Size = UDim2.new(1, -232, 1, -94), ZIndex = 12, Parent = MainFrame })
    local DrawerShield = New("TextButton", { Name = "NavigationDismissArea", BackgroundColor3 = "DarkColor", BackgroundTransparency = 0.55, Text = "", Selectable = false, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 1, -76), Visible = false, ZIndex = 19, Parent = MainFrame })
    local Footer = New("Frame", { Name = "StatusFooter", BackgroundColor3 = "NavigationColor", AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 32), ZIndex = 30, Parent = MainFrame })
    New("Frame", { BackgroundColor3 = "OutlineColor", Size = UDim2.new(1, 0, 0, 1), Parent = Footer })
    local FooterState = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -90, 1, 0), Parent = Footer })
    local FooterSecondary = New("TextLabel", { BackgroundTransparency = 1, Text = "", RichText = false, TextSize = 14, TextColor3 = "MutedColor", TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Right, Parent = Footer })
    local DetailsButton = New("TextButton", { Name = "StatusDetails", BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -36, 0, 0), Size = UDim2.fromOffset(32, 32), Parent = Footer })
    Library:CreateSymbol(DetailsButton, "info", UDim2.new(0.5, -8, 0.5, -8), 16)
    Library:AddTooltip("Full profile, save, and project details", "", DetailsButton)
    local ResizeButton
    if WindowInfo.Resizable then
        ResizeButton = New("TextButton", { Name = "ResizeWindow", BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.fromOffset(32, 32), ZIndex = 35, Parent = MainFrame })
        Library:CreateSymbol(ResizeButton, "move-diagonal", UDim2.new(0.5, -8, 0.5, -8), 16, "MutedColor")
        Library:AddTooltip("Resize window", "", ResizeButton)
        Library:MakeResizable(MainFrame, ResizeButton, function() Window:ApplyLayout(); Library:LayoutChanged() end)
    end
    Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
    Library.KeybindFrame.AnchorPoint, Library.KeybindFrame.Position, Library.KeybindFrame.Visible = Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0), false
    Window.KeybindFrame = Library.KeybindFrame
    local function ApplyCompact()
        local M = Library:Metrics()
        IsCompact = Window.EffectiveCompact == true
        for _, Entry in Library.TabButtons do
            local Button, Label, Image = Entry.Label.Parent, Entry.Label, Entry.Icon
            local HasIcon = Image and Image.Visible and Image.IsLoaded
            if Image and not Image:GetAttribute("ChiyoLoadObserved") then
                Image:SetAttribute("ChiyoLoadObserved", true)
                Image:GetPropertyChangedSignal("IsLoaded"):Connect(function() if not Library.Unloaded then Window:ApplyLayout() end end)
            end
            local Left = HasIcon and M.Icon + 24 or 12
            local Badge = Button:FindFirstChild("ActivityBadge")
            local BadgeWidth = Badge and Badge.Visible and math.max(28, Badge.TextSize * 2) or 0
            Label.Text = tostring(Entry.Title or Label.Text)
            Label.TextWrapped, Label.TextTruncate = not IsCompact or not HasIcon, Enum.TextTruncate.None
            Label.Visible = not IsCompact or not HasIcon
            Label.TextXAlignment = IsCompact and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
            local Height = math.max(M.Target + 2, IsCompact and 46 or 40)
            if Label.Visible then
                local _, H = Library:GetTextBounds(Label.Text, Label.FontFace, Label.TextSize, math.max(28, Tabs.AbsoluteSize.X - (IsCompact and 8 or Left + 12 + BadgeWidth)), false)
                Height = math.max(Height, H + 12)
            end
            Button.Size = UDim2.new(1, -4, 0, Height)
            Label.Position, Label.Size = UDim2.fromOffset(IsCompact and 4 or Left, 0), UDim2.new(1, IsCompact and -8 or -Left - 12 - BadgeWidth, 1, 0)
            if Entry.Padding then Entry.Padding.PaddingBottom, Entry.Padding.PaddingTop, Entry.Padding.PaddingLeft, Entry.Padding.PaddingRight = UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0) end
            if Image then
                Image.SizeConstraint, Image.AnchorPoint = Enum.SizeConstraint.RelativeXY, Vector2.new(IsCompact and 0.5 or 0, 0.5)
                Image.Size = UDim2.fromOffset(M.Icon, M.Icon)
                Image.Position = IsCompact and UDim2.fromScale(0.5, 0.5) or UDim2.new(0, 12, 0.5, 0)
            end
            local Marker = Button:FindFirstChild("ActivePageMarker")
            if Marker then Marker.Position, Marker.Size = UDim2.fromOffset(0, 6), UDim2.new(0, 3, 1, -12) end
            if Badge then Badge.Position = UDim2.new(1, -4, IsCompact and 0 or 0.5, IsCompact and 2 or 0); Badge.AnchorPoint = Vector2.new(1, IsCompact and 0 or 0.5); Badge.Size = UDim2.fromOffset(BadgeWidth, math.max(22, Badge.TextSize + 4)) end
        end
    end
    function Window:ChangeTitle(Title)
        assert(typeof(Title) == "string", "Expected a title string")
        WindowInfo.Title, WindowTitle.Text = Title, Title
        TitleHelp:SetText(Title .. (WindowInfo.Subtitle and ("\n" .. tostring(WindowInfo.Subtitle)) or ""))
        BrandName.Text = Title ~= "Chiyo" and "Chiyo" or ""
    end
    function Window:SetBackgroundImage(Image)
        assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected an image asset")
        local Ref = Library:GetCustomIcon(Image)
        if not BackgroundImage then BackgroundImage = New("ImageLabel", { BackgroundTransparency = 1, ImageTransparency = 0.94, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Crop, ZIndex = 10, Parent = MainFrame }) end
        BackgroundImage.Image, BackgroundImage.Visible = Ref and Ref.Url or tostring(Image), tostring(Image) ~= ""
        WindowInfo.BackgroundImage = Image
    end
    function Window:SetFooter(Text) assert(typeof(Text) == "string", "Expected footer text"); WindowInfo.Footer = Text; Window:RefreshFooter() end
    function Window:SetCornerRadius(Radius) assert(IsFinite(Radius), "Corner radius must be finite"); Library.LegacyAppearanceAssignments.CornerRadius = Radius; return true end
    function Window:ShowTabInfo(Name, Description) Window.ContextName, Window.ContextDescription = tostring(Name or ""), tostring(Description or "") end
    function Window:HideTabInfo() Window.ContextName, Window.ContextDescription = "", "" end
    function Window:GetSidebarWidth() return Window.SidebarWidth or Window.ExpandedSidebarWidth end
    function Window:IsSidebarCompacted() return IsCompact end
    function Window:GetColumnMode() return "Auto" end
    function Window:SetColumnMode(Mode)
        assert(Mode == "Auto" or Mode == "Single" or Mode == "Split", "Column mode must be Auto, Single, or Split")
        Library.LegacyAppearanceAssignments.ColumnMode = Mode
        Window.ColumnMode = "Auto"; Window:ApplyLayout(); return true
    end
    function Window:SetSidebarWidth(Width, LayoutOnly)
        if (Library.FeatureLoadDepth or 0) > 0 then return false end
        assert(IsFinite(Width), "Sidebar width must be finite")
        if not LayoutOnly then
            if Width <= 80 then Window.RequestedCompact = true
            else Window.ExpandedSidebarWidth, Window.RequestedCompact = math.clamp(math.floor(Width), 180, 320), false end
        end
        Window:ApplyLayout()
        if not LayoutOnly then Library:LayoutChanged() end
    end
    function Window:SetCompact(State)
        if (Library.FeatureLoadDepth or 0) > 0 then return false end
        Window.RequestedCompact = State == true
        Window.DrawerOpen = false
        Window:ApplyLayout(); Library:LayoutChanged()
    end
    function Window:CloseNavigationDrawer()
        if Window.DrawerOpen then Window.DrawerOpen = false; Window:ApplyLayout() end
    end
    function Window:Center()
        if (Library.FeatureLoadDepth or 0) > 0 then return false end
        local Origin, View = Library:GetUsableRect()
        MainFrame.Position = UDim2.fromOffset(math.floor(Origin.X + math.max(0, View.X - MainFrame.AbsoluteSize.X) / 2), math.floor(Origin.Y + math.max(0, View.Y - MainFrame.AbsoluteSize.Y) / 2))
        Library:LayoutChanged()
    end
    function Window:SetStatus(Text, Kind)
        Window.StatusText, Window.StatusKind = tostring(Text or ""), tostring(Kind or "Info")
        Window:RefreshFooter()
    end
    function Window:SetPersistenceStatus(Status)
        Window.PersistenceStatus = table.clone(Status or {})
        Window:RefreshFooter()
    end
    function Window:GetStatusDetails()
        local Lines, P = {}, Window.PersistenceStatus
        if P then
            table.insert(Lines, (P.ProfileSource == "saved" and "Named save: " or "Loaded profile: ") .. tostring(P.Profile or "none"))
            if P.Storage then table.insert(Lines, "Storage: " .. tostring(P.Storage)) end
            table.insert(Lines, "Feature settings: " .. (P.Dirty and "Unsaved changes" or "Unchanged since load or verified save"))
            table.insert(Lines, "Autosave: " .. tostring(P.AutoSaveText or (P.AutoSave and "enabled" or "disabled")))
            table.insert(Lines, "Autosave destination: " .. tostring(P.Destination or "none; an explicit named load or save is required"))
            if P.Project then table.insert(Lines, "Profile folder: " .. P.Project) end
            if P.Preferences then table.insert(Lines, "UI preferences: " .. P.Preferences) end
        end
        if Window.StatusText and Window.StatusText ~= "" then table.insert(Lines, Window.StatusKind .. ": " .. Window.StatusText) end
        if WindowInfo.Footer ~= "" then table.insert(Lines, tostring(WindowInfo.Footer)) end
        if WindowInfo.Subtitle and WindowInfo.Subtitle ~= "" then table.insert(Lines, tostring(WindowInfo.Subtitle)) end
        if #Lines == 0 then table.insert(Lines, "Session UI. No configuration manager is attached.") end
        return table.concat(Lines, "\n")
    end
    function Window:RefreshFooter()
        if not Footer.Parent then return end
        local M, P = Library:Metrics(), Window.PersistenceStatus
        local Narrow = MainFrame.Size.X.Offset < 700
        local Reserve = (ResizeButton and 2 or 1) * math.max(32, M.Target) + 18
        local Status = Window.StatusText or ""
        local First, Second
        if P then
            First = (P.Busy and "Working" or P.Dirty and "Unsaved" or "Unchanged") .. " / " .. tostring(P.Profile or "No profile loaded")
            Second = P.AutoSave and (P.Paused and ("Autosave paused: " .. tostring(P.Destination or "no destination")) or "Autosave: " .. tostring(P.Destination or "no destination")) or "Autosave off"
        else First, Second = Status, tostring(WindowInfo.Footer or "") end
        FooterState.Text = First
        FooterSecondary.Text = Second
        FooterState.TextColor3 = Window.StatusKind == "Error" and not P and Library.Scheme.RedColor or Library.Scheme.FontColor
        FooterSecondary.TextXAlignment = Narrow and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        if Narrow then
            FooterState.Position, FooterState.Size = UDim2.fromOffset(10, 3), UDim2.new(1, -Reserve, 0, M.Field - 12)
            FooterSecondary.Position, FooterSecondary.Size = UDim2.fromOffset(10, M.Field - 9), UDim2.new(1, -Reserve, 0, M.Field - 12)
        else
            local Available = MainFrame.Size.X.Offset - Reserve
            local SecondWidth = math.min(Available * 0.5, Library:GetTextBounds(Second, FooterSecondary.FontFace, FooterSecondary.TextSize, 0, false) + 12)
            FooterState.Position, FooterState.Size = UDim2.fromOffset(10, 0), UDim2.fromOffset(math.max(20, Available - SecondWidth), Window.FooterHeight)
            FooterSecondary.Position, FooterSecondary.Size = UDim2.new(1, -SecondWidth - Reserve + 10, 0, 0), UDim2.fromOffset(SecondWidth, Window.FooterHeight)
        end
        if P and not Narrow and Status ~= "" then
            local Candidate = First .. " / " .. Status
            if Library:GetTextBounds(Candidate, FooterState.FontFace, FooterState.TextSize, 0, false) <= FooterState.Size.X.Offset then FooterState.Text = Candidate end
        end
        FooterSecondary.Visible = Second ~= ""
    end
    function Window:ApplyLayout()
        if Window.ApplyingLayout or Library.Unloaded or not MainFrame.Parent then return end
        Window.ApplyingLayout = true
        local M, Width = Library:Metrics(), MainFrame.Size.X.Offset
        Window.Narrow = Width < 700
        Window.EffectiveCompact = Window.Narrow and not Window.DrawerOpen or not Window.Narrow and Window.RequestedCompact
        local Sidebar = Window.EffectiveCompact and 64 or math.min(Window.ExpandedSidebarWidth + M.Offset * 6, math.max(180, Width - 260))
        if Window.Narrow and Window.DrawerOpen then Sidebar = math.min(Window.ExpandedSidebarWidth + M.Offset * 6, Width - 44) end
        Window.SidebarWidth = Sidebar
        Window.FooterHeight = Window.Narrow and (M.Field * 2 - 18) or math.max(32, M.Field - 2)
        local Header = math.max(M.Header, M.Target + 6)
        Window.HeaderHeight = Header
        TopBar.Size = UDim2.new(1, 0, 0, Header)
        NavToggle.Position, NavToggle.Size = UDim2.fromOffset(4, 2), UDim2.fromOffset(M.Target, Header - 4)
        local Right = 5
        for _, Button in { HideButton, HelpButton, Appearance, HistoryButton, SearchButton } do
            if Button.Visible then Button.AnchorPoint = Vector2.new(1, 0); Button.Position = UDim2.new(1, -Right, 0, 2); Button.Size = UDim2.fromOffset(M.Target, Header - 4); Right += M.Target + 3 end
        end
        local ShowBrand = Width >= 920 and WindowInfo.Title ~= "Chiyo"
        BrandName.Visible, BrandName.Position, BrandName.Size = ShowBrand, UDim2.new(1, -Right - 76, 0, 0), UDim2.fromOffset(64, Header - 2)
        local Start = M.Target + 14
        DragSurface.Position, DragSurface.Size = UDim2.fromOffset(Start, 0), UDim2.new(1, -Start - Right - (ShowBrand and 90 or 8), 1, -2)
        WindowIcon.Size = UDim2.fromOffset(24 + M.Offset, 24 + M.Offset)
        WindowIcon.Position = UDim2.new(0, 0, 0.5, -12 - M.Offset / 2)
        local Left = BrandIcon and 32 + M.Offset or 0
        WindowTitle.Position, WindowTitle.Size = UDim2.fromOffset(Left, 0), UDim2.new(1, -Left, 1, 0)
        NavSurface.Position, NavSurface.Size = UDim2.fromOffset(0, Header), UDim2.new(0, Sidebar, 1, -Header - Window.FooterHeight)
        local ContentSidebar = Window.Narrow and 64 or Sidebar
        Container.Position, Container.Size = UDim2.fromOffset(ContentSidebar + 10, Header + 10), UDim2.new(1, -ContentSidebar - 20, 1, -Header - Window.FooterHeight - 20)
        DrawerShield.Position, DrawerShield.Size, DrawerShield.Visible = UDim2.fromOffset(0, Header), UDim2.new(1, 0, 1, -Header - Window.FooterHeight), Window.Narrow and Window.DrawerOpen == true
        NavSymbol.Rotation = Window.EffectiveCompact and 0 or 180
        Footer.Size = UDim2.new(1, 0, 0, Window.FooterHeight)
        DetailsButton.Size = UDim2.fromOffset(math.max(32, M.Target), Window.FooterHeight)
        DetailsButton.Position = UDim2.new(1, ResizeButton and -math.max(32, M.Target) - 4 or -4, 0, 0)
        if ResizeButton then ResizeButton.Size = UDim2.fromOffset(math.max(32, M.Target), math.max(32, M.Target)) end
        ApplyCompact()
        for _, Page in Library.Tabs do if Page.Resize then Page:Resize(true) end end
        Window:RefreshFooter()
        if Window.Studio then Window.Studio.Layout() end
        if Window.HelpOverlay then Window.HelpOverlay.Position, Window.HelpOverlay.Size = UDim2.fromOffset(0, Header), UDim2.new(1, 0, 1, -Header - Window.FooterHeight) end
        Window.ApplyingLayout = false
    end
    NavToggle.Activated:Connect(function()
        if Library.ActiveDialog or Library.PickingKeybind then return end
        if Window.Narrow then Window.DrawerOpen = not Window.DrawerOpen; Window:ApplyLayout()
        else Window:SetCompact(not Window.RequestedCompact) end
    end)
    DrawerShield.Activated:Connect(function() Window:CloseNavigationDrawer() end)
    DetailsButton.Activated:Connect(function() Window:ShowHelp("Status details", Window:GetStatusDetails(), true) end)
    HelpButton.Activated:Connect(function() Window:SetHelpMode(not Library.HelpMode) end)
    HideButton.Activated:Connect(function() Library:Toggle(false) end)
    function Window:ShowHelp(Title, Text, PlainText)
        if CurrentMenu then CurrentMenu:Close("help") end
        if Window.CloseCommandPalette then Window:CloseCommandPalette() end
        Window:SetHelpMode(false)
        if Library.ActiveDialog then return false, "close the current dialog first" end
        local Dialog = Window:AddDialog("__Chiyo_Help", { Title = tostring(Title or "Help"), Description = "", Internal = true, Width = 520, MaxHeight = 360, StartHidden = true, AutoDestroy = true, FooterButtons = { Close = { Title = "Close", Variant = "Secondary" } } })
        local Label = Dialog:AddLabel({ Text = tostring(Text or ""), DoesWrap = true })
        Label.Internal = true
        if PlainText and Label.TextLabel then Label.TextLabel.RichText = false; Label:SetText(tostring(Text or "")) end
        Dialog:Show()
        return true
    end
    function Window:SetHelpMode(Enabled)
        if Enabled and (Library.ActiveDialog or Library.PickingKeybind) then return false end
        if not Enabled and not Window.HelpOverlay then Library.HelpMode = false; return true end
        if not Window.HelpOverlay then
            local Overlay = New("TextButton", { Name = "HelpInspector", BackgroundColor3 = "BackgroundColor", BackgroundTransparency = 0.72, Text = "", Selectable = false, Visible = false, ZIndex = 8000, Parent = MainFrame })
            Window.HelpOverlay = Overlay
            local Hint = New("TextLabel", { Name = "HelpHint", BackgroundColor3 = "HeaderColor", Text = "Help inspector: tap a control. Escape or the Help button closes this mode.", RichText = false, TextSize = 15, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -16, 0, 56), Parent = Overlay })
            New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Hint })
            Overlay.Activated:Connect(function(Input)
                if not Library.HelpMode or not Input then return end
                local Best, Area
                for Object, Data in Library.TooltipOwners do
                    local Text = Data.Disabled and Data.DisabledInfo or Data.Info
                    if typeof(Text) == "string" and Text ~= "" and Object:IsDescendantOf(MainFrame) and Library:IsObjectVisible(Object) and Library:MouseIsOverFrame(Object, Input.Position) then
                        local A = Object.AbsoluteSize.X * Object.AbsoluteSize.Y
                        if not Area or A < Area then Best, Area = Data, A end
                    end
                end
                if Best then
                    local Text = Best.Disabled and Best.DisabledInfo or Best.Info
                    Window:ShowHelp("Control help", Text)
                else Hint.Text = "No help was supplied for that location. Choose another control, or close Help." end
            end)
        end
        Library.HelpMode = Enabled == true
        Window.HelpOverlay.Visible = Library.HelpMode
        Library:HideTooltip()
        if Enabled then
            if CurrentMenu then CurrentMenu:Close("help inspector") end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            if Window.CloseCommandPalette then Window:CloseCommandPalette() end
        end
        Window:ApplyLayout()
        return true
    end
    -- A bounded session log. The icon badge is not an activity counter.
    local HistoryMenu = Library:AddContextMenu(HistoryButton, UDim2.fromOffset(400, 340), function() return { HistoryButton.AbsoluteSize.X - 400, HistoryButton.AbsoluteSize.Y + 6 } end, nil, function(Active)
        Library.HistoryOpen = Active
        if Active then Library.NotificationUnread = 0; Library:RefreshNotificationHistory() end
    end)
    Library.HistoryPanel = HistoryMenu.Menu
    local HistorySearch = New("TextBox", { Name = "MessageFilter", BackgroundColor3 = "FieldColor", Text = "", ClearTextOnFocus = false, PlaceholderText = "Search session messages", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -104, 0, 36), Parent = HistoryMenu.Menu })
    Library:StyleField(HistorySearch)
    New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = HistorySearch })
    local ClearHistory = New("TextButton", { Text = "Clear", RichText = false, TextSize = 15, BackgroundColor3 = "HeaderColor", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(80, 36), Parent = HistoryMenu.Menu })
    Library:StyleAction(ClearHistory, "Secondary", false, false)
    local HistoryHolder = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 52), Size = UDim2.new(1, -16, 1, -60), Parent = HistoryMenu.Menu })
    local HistoryView = Library:CreateVirtualList(HistoryHolder, { NoMarker = true, IsOpen = function() return HistoryMenu.Active end, EmptyText = "No session messages", Activate = function(Row)
        local Entry = Row.Source
        Window:ShowHelp(Entry.Type, Entry.Text .. (Entry.Count > 1 and ("\nRepeated " .. Entry.Count .. " times") or ""))
    end })
    local Badge = New("Frame", { Name = "Unread", BackgroundColor3 = "AccentColor", Size = UDim2.fromOffset(5, 5), Position = UDim2.new(1, -5, 0, 4), Visible = false, Parent = HistoryButton })
    function Library:RefreshNotificationHistory()
        Badge.Visible = Library.NotificationUnread > 0
        if not HistoryMenu.Active then return end
        local Rows, Filter = {}, HistorySearch.Text:lower()
        for Index, Entry in Library.NotificationHistory do
            if Filter == "" or Entry.Text:lower():find(Filter, 1, true) then
                local Plain = Entry.Description:gsub("<[^>]->", ""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")
                table.insert(Rows, { Key = Index, Text = Entry.Type .. (Entry.Title ~= "" and (": " .. Entry.Title) or "") .. (Entry.Count > 1 and (" / " .. Entry.Count .. " repeats") or ""), Subtitle = Plain, Source = Entry })
            end
        end
        HistoryView.Config.EmptyText = #Library.NotificationHistory == 0 and "No session messages" or "No messages match this search"
        HistoryView:SetEntries(Rows, false)
    end
    function Library:GetNotificationHistory() local Result = {}; for Index, Entry in Library.NotificationHistory do Result[Index] = table.clone(Entry) end; return Result end
    function Library:GetNotificationUnread() return Library.NotificationUnread end
    function Library:GetNotificationBellEnabled() return HistoryButton.Visible end
    function Library:SetNotificationBellEnabled(Enabled) HistoryButton.Visible = Enabled ~= false; Library.NotificationBellEnabled = HistoryButton.Visible; Window:ApplyLayout() end
    function Library:ClearNotificationHistory() table.clear(Library.NotificationHistory); Library.NotificationUnread = 0; Library:RefreshNotificationHistory() end
    function Library:ToggleNotificationHistory(Value)
        if Value == nil then Value = not HistoryMenu.Active end
        if Value then
            if Library.ActiveDialog or Library.PickingKeybind then return false end
            Window:SetHelpMode(false)
            if Window.CloseCommandPalette then Window:CloseCommandPalette() end
            local M = Library:Metrics()
            HistoryMenu:SetSize(UDim2.fromOffset(math.min(430, MainFrame.Size.X.Offset - 20), math.min(380, MainFrame.Size.Y.Offset - Window.HeaderHeight - 20)))
            HistorySearch.Size = UDim2.new(1, -104, 0, M.Field)
            ClearHistory.Size = UDim2.fromOffset(80, M.Field)
            HistoryHolder.Position, HistoryHolder.Size = UDim2.fromOffset(8, M.Field + 16), UDim2.new(1, -16, 1, -M.Field - 24)
            return HistoryMenu:Open()
        end
        HistoryMenu:Close("history hidden"); return false
    end
    HistoryButton.Activated:Connect(function() Library:ToggleNotificationHistory() end)
    ClearHistory.Activated:Connect(function() Library:ClearNotificationHistory() end)
    HistorySearch:GetPropertyChangedSignal("Text"):Connect(function() Library:RefreshNotificationHistory() end)
    Library.NotificationBellEnabled = HistoryButton.Visible
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Window:ApplyLayout() end)
    Library:GiveSignal(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not Library.Unloaded then Library:SnapFrame(MainFrame, true); Window:ApplyLayout(); if Library.Launcher then Library:SnapFrame(Library.Launcher) end end
    end), MainFrame)
    Library.TextReflows[MainFrame] = function() Window:ApplyLayout() end

    function Window:AddTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil
        local SingleColumn = false

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
            SingleColumn = Info.Layout == "Single" or Info.Layout == "Center" or Info.Layout == true or Info.Layout == 1 or Info.SingleColumn == true
        else
            Name = select(1, ...)
            Icon = select(2, ...)
            Description = select(3, ...)
            SingleColumn = select(4, ...) == true
        end

        SingleColumn = false
        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight
        local TabAccent

        Icon = Library:GetCustomIcon(Icon) or Library:GetBundledIcon("folder")
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = "",
                Parent = Tabs,
            })
            New("UICorner", { CornerRadius = UDim.new(0, WindowInfo.CornerRadius), Parent = TabButton })
            TabAccent = New("Frame", { Name = "ActivePageMarker", BackgroundColor3 = "AccentColor", BackgroundTransparency = 1, Position = UDim2.fromOffset(3, 6), Size = UDim2.fromOffset(3, 28), Parent = TabButton })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = TabAccent })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(Icon and 30 or 0, 0),
                Size = UDim2.new(1, Icon and -30 or 0, 1, 0),
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = Name,
                TextSize = 15,
                RichText = false,
                TextTransparency = 0,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    Image = Icon.Url,
                    ImageColor3 = Icon.Custom and "WhiteColor" or "FontColor",
                    ImageRectOffset = Icon.ImageRectOffset,
                    ImageRectSize = Icon.ImageRectSize,
                    ImageTransparency = 0.1,
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = Enum.SizeConstraint.RelativeXY,
                    Parent = TabButton,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Title = Name,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            TabLeft = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarImageTransparency = 0.05,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = "OutlineColor",
                Size = SingleColumn and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 12),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 0.05,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = "OutlineColor",
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 12),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
        end

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 0),
            Visible = false,
            Parent = TabContainer,
        })

        local WarningBox
        local WarningBoxOutline
        local WarningBoxShadowOutline
        local WarningBoxScrollingFrame
        local WarningTitle
        local WarningStroke
        local WarningText
        do
            WarningBox = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.fromOffset(2, 0),
                Size = UDim2.new(1, -5, 0, 0),
                Parent = WarningBoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = WarningBox,
                })
            )
            WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)

            WarningBoxScrollingFrame = New("ScrollingFrame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 4,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = WarningBox,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                Parent = WarningBoxScrollingFrame,
            })

            WarningTitle = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -4, 0, 14),
                Text = "",
                TextColor3 = Library.Scheme.RedColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })

            WarningStroke = New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1,
                Color = Color3.fromRGB(169, 0, 0),
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningTitle,
            })

            WarningText = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 16),
                Size = UDim2.new(1, -4, 0, 0),
                Text = "",
                TextSize = 14,
                TextWrapped = true,
                Parent = WarningBoxScrollingFrame,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            })

            New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 1,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
            Description = Description,
            Container = TabContainer,
            ButtonHolder = TabButton,
            PanelSides = {}, PanelOrders = {}, ScrollPositions = { Left = 0, Right = 0, Single = 0 }, ExpectedScroll = {}, ColumnGeneration = 0,
            PanelSequence = 0,
            LayoutId = string.format("tab:%s:%d", tostring(Name), #Library.Tabs + 1),
            Visible = true,
            Groupboxes = {},
            Tabboxes = {},
            DependencyGroupboxes = {},
            SingleColumn = SingleColumn,
            Sides = SingleColumn and { TabLeft } or { TabLeft, TabRight },
            WarningBox = {
                IsNormal = false,
                LockSize = false,
                Visible = false,
                Title = "Warning",
                Text = "",
            },
        }

        Window.PageSequence += 1
        Tab.Sequence = Window.PageSequence
        Tab.NavKey = Library:NavigationKey(nil, "page", Name)
        TabButton.LayoutOrder = Tab.Sequence
        function Tab:SetActivity(Activity: any)
            Activity = typeof(Activity) == "table" and Activity or {}
            local Count = tonumber(Activity.enabled) or 0
            Count = (Count == Count and math.abs(Count) < 1000000) and math.max(0, math.floor(Count)) or 0
            Tab.Activity = { enabled = Count, error = Activity.error == true }
            if not Tab.ActivityBadge then
                Tab.ActivityBadge = New("TextLabel", { Name = "ActivityBadge", AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "AccentColor", Position = UDim2.new(1, -1, 0, 1), Size = UDim2.fromOffset(14, 14), TextSize = 14, FontFace = "FontMono", Parent = TabButton })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Tab.ActivityBadge })
            end
            Tab.ActivityBadge.Visible = Count > 0 or Tab.Activity.error
            Tab.ActivityBadge.BackgroundColor3 = Tab.Activity.error and Library.Scheme.RedColor or Library.Scheme.AccentColor
            Tab.ActivityBadge.Text = Tab.Activity.error and "Error" or (Count > 9 and "9+" or tostring(Count))
            local function Ink() return Library:GetOnColor(Tab.Activity.error and Library.Scheme.RedColor or Library.Scheme.AccentColor) end
            Tab.ActivityBadge.TextColor3 = Ink()
            Library:AddToRegistry(Tab.ActivityBadge, { BackgroundColor3 = Tab.Activity.error and "RedColor" or "AccentColor", TextColor3 = Ink })
            ApplyCompact()
        end

        function Tab:UpdateWarningBox(Info)
            if typeof(Info.IsNormal) == "boolean" then
                Tab.WarningBox.IsNormal = Info.IsNormal
            end
            if typeof(Info.LockSize) == "boolean" then
                Tab.WarningBox.LockSize = Info.LockSize
            end
            if typeof(Info.Visible) == "boolean" then
                Tab.WarningBox.Visible = Info.Visible
            end
            if typeof(Info.Title) == "string" then
                Tab.WarningBox.Title = Info.Title
            end
            if typeof(Info.Text) == "string" then
                Tab.WarningBox.Text = Info.Text
            end

            WarningBoxHolder.Visible = Tab.WarningBox.Visible
            WarningTitle.Text = Tab.WarningBox.Title
            WarningText.Text = Tab.WarningBox.Text
            Tab:Resize(true)

            WarningBox.BackgroundColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor:Lerp(Library.Scheme.RedColor, 0.12)

            WarningBoxShadowOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor
                or Color3.fromRGB(85, 0, 0)
            WarningBoxOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                or Library.Scheme.RedColor

            WarningTitle.TextColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor
                or Library.Scheme.RedColor
            WarningStroke.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                or Color3.fromRGB(169, 0, 0)

            if not Library.Registry[WarningBox] then
                Library:AddToRegistry(WarningBox, {})
            end
            if not Library.Registry[WarningBoxShadowOutline] then
                Library:AddToRegistry(WarningBoxShadowOutline, {})
            end
            if not Library.Registry[WarningBoxOutline] then
                Library:AddToRegistry(WarningBoxOutline, {})
            end
            if not Library.Registry[WarningTitle] then
                Library:AddToRegistry(WarningTitle, {})
            end
            if not Library.Registry[WarningStroke] then
                Library:AddToRegistry(WarningStroke, {})
            end

            Library.Registry[WarningBox].BackgroundColor3 = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Library.Scheme.MainColor:Lerp(Library.Scheme.RedColor, 0.12)
            end

            Library.Registry[WarningBoxShadowOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
            end

            Library.Registry[WarningBoxOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Library.Scheme.RedColor
            end

            Library.Registry[WarningTitle].TextColor3 = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Library.Scheme.RedColor
            end

            Library.Registry[WarningStroke].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
            end
        end

        function Tab:GetScrollPositions()
            local Result = table.clone(Tab.ScrollPositions)
            if not Tab.SwitchingColumns then
                if Tab.ResponsiveSingle then Result.Single = TabLeft.CanvasPosition.Y
                else Result.Left, Result.Right = TabLeft.CanvasPosition.Y, TabRight.CanvasPosition.Y end
            end
            return Result
        end
        function Tab:RestoreScrollPositions(Positions)
            for _, Side in { "Left", "Right", "Single" } do if Positions[Side] ~= nil then Tab.ScrollPositions[Side] = Positions[Side] end end
            local function Place(Frame, Y)
                local Limit = math.max(0, Frame.AbsoluteCanvasSize.Y - Frame.AbsoluteSize.Y)
                local Target = math.clamp(Y or 0, 0, Limit)
                Tab.ExpectedScroll[Frame] = Target
                Frame.CanvasPosition = Vector2.new(0, Target)
            end
            if Tab.ResponsiveSingle then Place(TabLeft, Tab.ScrollPositions.Single)
            else Place(TabLeft, Tab.ScrollPositions.Left); Place(TabRight, Tab.ScrollPositions.Right) end
        end
        function Tab:RefreshSides()
            if Tab.Destroyed then return end
            local Offset = (WarningBoxHolder.Visible and WarningBoxHolder.Size.Y.Offset + 8 or 0) + (Tab.PlayerInfoHeight or 0)
            local Width = math.max(1, math.floor(TabContainer.AbsoluteSize.X))
            local Single = Width < Library:Metrics().Column * 2 + 16
            local Changed = Tab.ResponsiveSingle ~= Single
            if Changed then
                Tab.ScrollPositions = Tab:GetScrollPositions()
                Tab.SwitchingColumns = true
                Tab.ColumnGeneration += 1
            end
            Tab.ResponsiveSingle = Single
            Tab.Sides = Single and { TabLeft } or { TabLeft, TabRight }
            local Panels = {}
            for Panel, Side in Tab.PanelSides do if Panel.Parent then table.insert(Panels, { Panel = Panel, Side = Side, Order = Tab.PanelOrders[Panel] or Panel.LayoutOrder }) end end
            table.sort(Panels, function(A, B)
                if Single and A.Side ~= B.Side then return A.Side < B.Side end
                return A.Order < B.Order
            end)
            for Index, Entry in Panels do
                local Destination = Single or Entry.Side == 1
                Destination = Destination and TabLeft or TabRight
                if Entry.Panel.Parent ~= Destination then Entry.Panel.Parent = Destination end
                Entry.Panel.LayoutOrder = Single and Index or Entry.Order
            end
            TabRight.Visible = not Single
            local ColumnWidth = Single and Width or math.floor((Width - 16) / 2)
            TabLeft.Position, TabRight.Position = UDim2.fromOffset(0, Offset), UDim2.new(1, 0, 0, Offset)
            TabLeft.Size, TabRight.Size = UDim2.new(0, ColumnWidth, 1, -Offset), UDim2.new(0, ColumnWidth, 1, -Offset)
            if Changed then
                local Generation = Tab.ColumnGeneration
                Library:DeferOwned(TabContainer, nil, function()
                    Library:DeferOwned(TabContainer, nil, function()
                        if Generation ~= Tab.ColumnGeneration then return end
                        Tab:RestoreScrollPositions(Tab.ScrollPositions)
                        Tab.SwitchingColumns = false
                        Library:ScheduleNavigationRestore()
                        Library:RefreshVisibleComponents()
                    end)
                end)
            end
        end
        for _, Frame in { TabLeft, TabRight } do
            Frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                local Expected = Tab.ExpectedScroll[Frame]
                if Expected ~= nil and math.abs(Expected - Frame.CanvasPosition.Y) < 0.5 then Tab.ExpectedScroll[Frame] = nil; return end
                Tab.ExpectedScroll[Frame] = nil
                if Tab.SwitchingColumns or Library.LayoutRestoring or Library.NavigationRestoring then return end
                local Key = Tab.ResponsiveSingle and "Single" or Frame == TabLeft and "Left" or "Right"
                if Tab.ResponsiveSingle and Frame == TabRight then return end
                Tab.ScrollPositions[Key] = Frame.CanvasPosition.Y
                Library:NavigationSelected("Scroll", Tab.NavKey)
            end)
            Frame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
                if Library.PendingNavigation and Library.PendingNavigation.Scroll and Library.PendingNavigation.Scroll[Tab.NavKey] then Library:ScheduleNavigationRestore() end
            end)
        end

        function Tab:Resize(ResizeWarningBox)
            if Tab.Destroyed or not TabContainer.Parent then return end
            if ResizeWarningBox and Tab.WarningBox.Visible then
                local M = Library:Metrics()
                local W = math.max(20, TabContainer.AbsoluteSize.X - 20)
                local _, TitleHeight = Library:GetTextBounds(WarningTitle.Text, WarningTitle.FontFace, WarningTitle.TextSize, W, WarningTitle.RichText)
                local _, TextHeight = Library:GetTextBounds(WarningText.Text, WarningText.FontFace, WarningText.TextSize, W, WarningText.RichText)
                local Total = TitleHeight + TextHeight + 18
                local Maximum = math.max(M.Target, math.floor(TabContainer.AbsoluteSize.Y / 3))
                local Height = Tab.WarningBox.LockSize and math.min(Total, Maximum) or Total
                WarningTitle.Size = UDim2.new(1, -4, 0, TitleHeight)
                WarningText.Position, WarningText.Size = UDim2.fromOffset(0, TitleHeight + 6), UDim2.new(1, -4, 0, TextHeight)
                WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, Total)
                WarningBoxScrollingFrame.ScrollBarThickness = Total > Height and 4 or 0
                WarningBox.Size, WarningBoxHolder.Size = UDim2.new(1, -4, 0, Height), UDim2.new(1, 0, 0, Height)
            end
            Tab:RefreshSides()
        end

        function Tab:AddGroupbox(Info)
            Info = typeof(Info) == "table" and table.clone(Info) or { Name = tostring(Info or "Section") }
            Info.Name = tostring(Info.Name or "Section")
            assert(not Tab.Groupboxes[Info.Name], "A groupbox with this name already exists on this page")
            local Side = (Info.Side == 2 or Info.Side == "Right" or Info.Side == "right") and 2 or 1
            local BoxHolder = New("Frame", { Name = "SectionSlot", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = Side == 1 and TabLeft or TabRight })
            local Card = New("Frame", { Name = "TechnicalSection", BackgroundColor3 = "MainColor", Size = UDim2.fromScale(1, 1), Parent = BoxHolder })
            Library:Surface(Card, "Panel")
            local Header = New("TextButton", { Name = "SectionHeader", BackgroundColor3 = "HeaderColor", Size = UDim2.new(1, 0, 0, 34), Text = "", Selectable = false, Parent = Card })
            local Icon = Library:GetCustomIcon(Info.IconName or Info.Icon)
            local Image
            if Icon then Image = New("ImageLabel", { Image = Icon.Url, ImageRectOffset = Icon.ImageRectOffset, ImageRectSize = Icon.ImageRectSize, ImageColor3 = Icon.Custom and "WhiteColor" or "MutedColor", Position = UDim2.new(0, 10, 0.5, -9), Size = UDim2.fromOffset(18, 18), Parent = Header }) end
            local Title = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Icon and 36 or 10, 0), Size = UDim2.new(1, -84, 1, 0), Text = Info.Name, RichText = false, FontFace = "FontBold", TextSize = 16, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header })
            local Divider = Library:MakeLine(Card, { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 0, 1) })
            local Body = New("Frame", { Name = "SectionBody", BackgroundColor3 = "MainColor", Position = UDim2.fromOffset(1, 35), Size = UDim2.new(1, -2, 0, 16), Parent = Card })
            local Layout = New("UIListLayout", { Padding = UDim.new(0, Library:Metrics().Gap), Parent = Body })
            local Padding = New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9), Parent = Body })
            local Groupbox = { Name = Info.Name, Description = tostring(Info.Description or ""), BoxHolder = BoxHolder, Holder = Card, Container = Body, TitleLine = Divider, TextLabel = Title,
                Tab = Tab, DependencyBoxes = {}, Elements = {}, InnerTabboxes = {}, Depth = 0, Internal = Info.Internal == true,
                Minimized = false, Visible = Info.Visible ~= false, DisableCollapsing = Info.DisableCollapsing == true, AnimationGeneration = 0,
            }
            local Help = New("TextButton", { Name = "SectionHelp", AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -36, 0.5, 0), Size = UDim2.fromOffset(32, 32), Text = "", Visible = Groupbox.Description ~= "", Parent = Header })
            Library:CreateSymbol(Help, "info", UDim2.new(0.5, -8, 0.5, -8), 16, "MutedColor")
            local HelpData = Library:AddTooltip(Groupbox.Description, "", Help)
            local Collapse = New("TextButton", { Name = "CollapseSection", AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(32, 32), Text = "", Visible = not Groupbox.DisableCollapsing, Parent = Header })
            local Chevron = Library:CreateSymbol(Collapse, "chevron-down", UDim2.new(0.5, -8, 0.5, -8), 16)
            Library:AddTooltip("Collapse or expand this section", "", Collapse)
            Groupbox.CollapseButton, Groupbox.HelpButton, Groupbox.PinButton = Collapse, Help, nil
            local Sizing = false
            function Groupbox:Resize(KeepHeight)
                if Sizing or Groupbox.Destroyed or not Card.Parent then return end
                Sizing = true
                local M = Library:Metrics()
                local Width = math.max(80, BoxHolder.AbsoluteSize.X)
                local ActionWidth = math.max(32, M.Target - 4)
                local Reserved = (Collapse.Visible and ActionWidth or 0) + (Help.Visible and ActionWidth or 0) + 8
                local Left = Image and M.Icon + 18 or 10
                local _, TextHeight = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, math.max(20, Width - Left - Reserved), false)
                local HeaderHeight = math.max(Library.IsMobile and 44 or 34 + M.Offset, TextHeight + 12)
                Title.Position, Title.Size = UDim2.fromOffset(Left, 0), UDim2.new(1, -Left - Reserved, 1, 0)
                Header.Size = UDim2.new(1, 0, 0, HeaderHeight)
                Help.Position = UDim2.new(1, Collapse.Visible and -ActionWidth - 2 or -2, 0.5, 0)
                Help.Size, Collapse.Size = UDim2.fromOffset(ActionWidth, HeaderHeight), UDim2.fromOffset(ActionWidth, HeaderHeight)
                if Image then Image.Size = UDim2.fromOffset(M.Icon, M.Icon); Image.Position = UDim2.new(0, 10, 0.5, -math.floor(M.Icon / 2)) end
                Layout.Padding = UDim.new(0, M.Gap)
                local BodyHeight = math.ceil(Layout.AbsoluteContentSize.Y) + Padding.PaddingTop.Offset + Padding.PaddingBottom.Offset
                Divider.Position = UDim2.fromOffset(0, HeaderHeight)
                Body.Position, Body.Size = UDim2.fromOffset(1, HeaderHeight + 1), UDim2.new(1, -2, 0, BodyHeight)
                Groupbox.HeaderHeight, Groupbox.TargetHeight = HeaderHeight, HeaderHeight + (Groupbox.Minimized and 0 or BodyHeight + 1)
                if not KeepHeight and not Groupbox.Animating then BoxHolder.Size = UDim2.new(1, 0, 0, Groupbox.TargetHeight) end
                Sizing = false
            end
            function Groupbox:SetMinimized(Value, Immediate)
                Value = Value == true
                if Groupbox.Destroyed or Groupbox.Minimized == Value then return end
                Groupbox.Minimized = Value
                if Value then
                    if CurrentMenu and CurrentMenu.Holder:IsDescendantOf(Card) then CurrentMenu:Close("section collapsed") end
                    if Library.ActiveExpandedDropdown and Library.ActiveExpandedDropdown.Holder:IsDescendantOf(Card) then Library.ActiveExpandedDropdown:Collapse() end
                    if Library.ActivePointerDrag and Library.ActivePointerDrag.Owner:IsDescendantOf(Card) then Library:StopPointerDrag("section collapsed") end
                end
                Groupbox.AnimationGeneration += 1
                local Generation = Groupbox.AnimationGeneration
                Library:CancelMotion(BoxHolder)
                Groupbox:Resize(true)
                Card.ClipsDescendants, Body.Visible = true, true
                local Duration = not Immediate and Library.Animations.GroupboxCollapse and not Library:IsReducedMotion() and 0.12 or 0
                Groupbox.Animating = Duration > 0
                local function Finish()
                    if Groupbox.Destroyed or Generation ~= Groupbox.AnimationGeneration then return end
                    Groupbox.Animating = false
                    Body.Visible, Divider.Visible, Card.ClipsDescendants = not Value, not Value, Value
                    Groupbox:Resize()
                    if not Value then Library:RefreshVisibleComponents() end
                end
                if Duration == 0 then BoxHolder.Size = UDim2.new(1, 0, 0, Groupbox.TargetHeight); Finish()
                else
                    local Tween = Library:CreateTween(BoxHolder, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, Groupbox.TargetHeight) })
                    Tween.Completed:Once(Finish); Tween:Play()
                end
                Library:CreateTween(Chevron, TweenInfo.new(Duration), { Rotation = Value and -90 or 0 }):Play()
                Library:NavigationSelected("Section", Groupbox.NavKey)
            end
            function Groupbox:SetDescription(Text)
                Groupbox.Description = tostring(Text or "")
                Help.Visible = Groupbox.Description ~= ""
                HelpData:SetText(Groupbox.Description)
                Groupbox:Resize(); Library:MarkStudioIndexDirty()
            end
            function Groupbox:SetVisible(Value)
                Groupbox.Visible = Value == true; BoxHolder.Visible = Groupbox.Visible
                if not Groupbox.Visible then
                    if CurrentMenu and CurrentMenu.Holder:IsDescendantOf(Card) then CurrentMenu:Close("section hidden") end
                    if Library.ActiveExpandedDropdown and Library.ActiveExpandedDropdown.Holder:IsDescendantOf(Card) then Library.ActiveExpandedDropdown:Collapse() end
                elseif Library.Searching then Library:UpdateSearch(Library.SearchText) end
                Groupbox:Resize(); Library:RefreshVisibleComponents()
            end
            function Groupbox:Show() Groupbox:SetVisible(true) end
            function Groupbox:Hide() Groupbox:SetVisible(false) end
            function Groupbox:SetOrder(Order)
                assert(IsFinite(Order), "Section order must be finite")
                Tab.PanelOrders[BoxHolder] = Order; Tab:RefreshSides()
            end
            function Groupbox:Destroy() if not Groupbox.Destroyed then BoxHolder:Destroy() end end
            local function ToggleCollapsed(Input)
                if not Groupbox.DisableCollapsing and Library:CanInteract(Header, Input) then Groupbox:SetMinimized(not Groupbox.Minimized) end
            end
            Header.Activated:Connect(ToggleCollapsed); Collapse.Activated:Connect(ToggleCollapsed)
            Help.Activated:Connect(function(Input) if Library:CanInteract(Help, Input) then Window:ShowHelp(Groupbox.Name, Groupbox.Description) end end)
            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Groupbox:Resize() end)
            BoxHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Groupbox:Resize() end)
            Library.TextReflows[BoxHolder] = function() Groupbox:Resize() end
            setmetatable(Groupbox, BaseGroupbox)
            Tab.PanelSequence += 1
            Tab.PanelOrders[BoxHolder], Tab.PanelSides[BoxHolder] = Tab.PanelSequence, Side
            BoxHolder.Destroying:Once(function()
                Groupbox.Destroyed = true; Groupbox.AnimationGeneration += 1
                Tab.PanelSides[BoxHolder], Tab.PanelOrders[BoxHolder] = nil, nil
                if Tab.Groupboxes[Info.Name] == Groupbox then Tab.Groupboxes[Info.Name] = nil end
                Library:MarkStudioIndexDirty()
            end)
            Tab.Groupboxes[Info.Name] = Groupbox
            Library:RegisterNavigation("Section", Library:NavigationKey(Tab, "section", Groupbox.Name), Groupbox)
            BoxHolder.Visible = Groupbox.Visible
            Groupbox:Resize(); Tab:RefreshSides()
            if Info.Minimized then Groupbox:SetMinimized(true, true) end
            Library:MarkStudioIndexDirty()
            return Groupbox
        end

        function Tab:AddLeftGroupbox(Name, IconName, Visible)
            return Tab:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible })
        end

        function Tab:AddRightGroupbox(Name, IconName, Visible)
            return Tab:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible })
        end

        function Tab:AddPlayerInfo(Info)
            Info = typeof(Info) == "table" and Info or {}
            if Tab.PlayerInfo then Tab.PlayerInfo:Destroy(); Tab.PlayerInfo = nil end
            local Card = Library:CreatePlayerCard(TabContainer, Info, function(Height)
                Tab.PlayerInfoHeight = Height > 0 and Height + 8 or 0
                Tab:RefreshSides()
            end)
            Card.Holder.Position = UDim2.fromOffset(4, 4)
            Card.Holder.Size = UDim2.new(1, -8, 0, Card.Holder.Size.Y.Offset)
            Tab.PlayerInfo = Card
            local Destroy = Card.Destroy
            function Card:Destroy()
                Destroy(self)
                if Tab.PlayerInfo == self then Tab.PlayerInfo = nil; Tab.PlayerInfoHeight = 0; Tab:RefreshSides() end
            end
            return Card
        end

        function Tab:AddTabbox(Info)
            local Outer = New("Frame", { BackgroundColor3 = "MainColor", Size = UDim2.new(1, 0, 0, 0), Parent = (Tab.SingleColumn or Tab.ResponsiveSingle or Info.Side == 1) and TabLeft or TabRight })
            Library:RoundSurface(Outer, Library.CornerRadius)
            Library:AddOutline(Outer)
            local Container = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -20, 1, -16), Parent = Outer })
            local Adapter = { Container = Container, Tab = Tab, Depth = 0, Elements = {}, DependencyBoxes = {}, InnerTabboxes = {},
                NavKey = Library:NavigationKey(Tab, "tabbox", Info.Name or ("unnamed-" .. tostring(Tab.PanelSequence + 1))) }
            local Tabbox
            function Adapter:Resize()
                if Tabbox and Tabbox.Surface then Outer.Size = UDim2.new(1, 0, 0, Tabbox.Surface.Size.Y.Offset + 16) end
            end
            setmetatable(Adapter, BaseGroupbox)
            Tabbox = Adapter:AddTabbox()
            Tabbox.Surface = Tabbox.BoxHolder
            Tabbox.BoxHolder = Outer
            Tabbox.Name = Info.Name
            function Tabbox:UpdateCorners() end -- Corners are registered with the window's radius controller.
            Tab.PanelSequence += 1
            Outer.LayoutOrder = Tab.PanelSequence
            Tab.PanelOrders[Outer] = Tab.PanelSequence
            Tab.PanelSides[Outer] = Info.Side or 1
            Outer.Destroying:Once(function() Tab.PanelSides[Outer], Tab.PanelOrders[Outer] = nil, nil; Library:MarkStudioIndexDirty() end)
            if Info.Name then Tab.Tabboxes[Info.Name] = Tabbox else table.insert(Tab.Tabboxes, Tabbox) end
            Tab:RefreshSides()
            return Tabbox
        end

        function Tab:AddLeftTabbox(Name)
            return Tab:AddTabbox({ Side = 1, Name = Name })
        end

        function Tab:AddRightTabbox(Name)
            return Tab:AddTabbox({ Side = 2, Name = Name })
        end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            Library:CreateTween(TabButton, Library.TweenInfo, { BackgroundTransparency = Hovering and 0.25 or 1 }):Play()
            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0 or 0.1,
            }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0 or 0.1,
                }):Play()
            end
        end

        function Tab:Show(User)
            if User then Library:NavigationSelected("Page", Tab.NavKey) end
            if Library.Unloaded or Tab.Visible == false then return false end
            if Library.ActiveTab == Tab then Tab:RefreshSides(); Library:RefreshVisibleComponents(); return true end
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            Library:CreateTween(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            Library:CreateTween(TabAccent, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            TabContainer.Visible = true
            Tab:RefreshSides()

            Library.ActiveTab = Tab
            if Window.OnPageShown then Window:OnPageShown(Tab) end

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            if Library.ActiveTab == Tab and CurrentMenu then CurrentMenu:Close() end
            if Library.ActiveTab == Tab and Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            Library:CreateTween(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            Library:CreateTween(TabAccent, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.1,
            }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.1,
                }):Play()
            end
            TabContainer.Visible = false

            if Library.ActiveTab == Tab then Window:HideTabInfo(); Library.ActiveTab = nil end
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.Visible = Visible
            Library:MarkStudioIndexDirty()
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
                Window:SelectFallbackPage()
            end
        end

        function Tab:SetOrder(Order)
            assert(IsFinite(Order), "Tab order must be finite")
            TabButton.LayoutOrder = Order
        end
        function Tab:SetName(NewName)
            assert(typeof(NewName) == "string" and NewName ~= "", "Tab name must be nonempty")
            assert(not Library.Tabs[NewName] or Library.Tabs[NewName] == Tab, "Tab name already exists")
            if Library.Tabs[Name] == Tab then Library.Tabs[Name] = nil end
            Name, Tab.Name, TabLabel.Text = NewName, NewName, NewName
            for _, Button in Library.TabButtons do if Button.Label == TabLabel then Button.Title = NewName end end
            ApplyCompact()
            if Library.MarkStudioIndexDirty then Library:MarkStudioIndexDirty() end
            Library.Tabs[NewName] = Tab
            if Tab.HelpData then Tab.HelpData:SetText(NewName .. (Description and ("\n" .. tostring(Description)) or "")) end
            if Library.ActiveTab == Tab then Window:ShowTabInfo(Name, Description or WindowInfo.Title) end
        end
        function Tab:SetDescription(Value)
            Description = Value
            Tab.Description = Value
            if Tab.HelpData then Tab.HelpData:SetText(tostring(Tab.Name) .. (Value and ("\n" .. tostring(Value)) or "")) end
            if Library.ActiveTab == Tab then
                Window:ShowTabInfo(Name, Description or WindowInfo.Title)
            end
        end
        function Tab:SetIcon(Value)
            local NewIcon = Library:GetCustomIcon(Value)
            if not TabIcon and NewIcon then
                TabIcon = New("ImageLabel", { Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY, Parent = TabButton })
                for _, Button in Library.TabButtons do if Button.Label == TabLabel then Button.Icon = TabIcon end end
            end
            Icon = NewIcon
            if TabIcon then
                TabIcon.Visible = NewIcon ~= nil
                if NewIcon then
                    TabIcon.Image = NewIcon.Url
                    TabIcon.ImageRectOffset, TabIcon.ImageRectSize = NewIcon.ImageRectOffset, NewIcon.ImageRectSize
                    TabIcon.ImageColor3 = NewIcon.Custom and Library.Scheme.WhiteColor or Library.Scheme.AccentColor
                    Library:AddToRegistry(TabIcon, { ImageColor3 = NewIcon.Custom and "WhiteColor" or "AccentColor" })
                end
            end
            TabLabel.Position = UDim2.fromOffset(NewIcon and 30 or 0, 0)
            TabLabel.Size = UDim2.new(1, NewIcon and -30 or 0, 1, 0)
            ApplyCompact()
        end

        --// Execution \\--
        if not Library.ActiveTab and not Window.OverviewVisible then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.Activated:Connect(function(Input) if Library:CanInteract(TabButton, Input) then Tab:Show(true) end end)
        Tab.HelpData = Library:AddTooltip(tostring(Name or "") .. (Description and ("\n" .. tostring(Description)) or ""), "", TabButton)

        Library.Tabs[Name] = Tab
        Library:RegisterNavigation("Page", Tab.NavKey, Tab)
        TabContainer.Destroying:Once(function()
            Tab.Destroyed = true
            if Library.Tabs[Name] == Tab then Library.Tabs[Name] = nil end
            for Index = #Library.TabButtons, 1, -1 do if Library.TabButtons[Index].Label == TabLabel then table.remove(Library.TabButtons, Index) end end
        end)
        ApplyCompact()
        if Window.OnPageAdded then Window:OnPageAdded(Tab) end

        return Tab
    end


    function Window:AddKeyTab(...)
        local Name = nil
        local Icon = nil
        local Description = nil

        if select("#", ...) == 1 and typeof(...) == "table" then
            local Info = select(1, ...)
            Name = Info.Name or "Tab"
            Icon = Info.Icon
            Description = Info.Description
        else
            Name = select(1, ...) or "Tab"
            Icon = select(2, ...)
            Description = select(3, ...)
        end

        Icon = Icon or "key"

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer

        Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                Parent = Tabs,
            })
            local ButtonPadding = New("UIPadding", {
                PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                Parent = TabButton,
            })

            TabLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(Icon and 30 or 0, 0),
                Size = UDim2.new(1, Icon and -30 or 0, 1, 0),
                TextTruncate = Enum.TextTruncate.AtEnd,
                Text = Name,
                TextSize = 16,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = not IsCompact,
                Parent = TabButton,
            })

            if Icon then
                TabIcon = New("ImageLabel", {
                    Image = Icon.Url,
                    ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                    ImageRectOffset = Icon.ImageRectOffset,
                    ImageRectSize = Icon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Size = UDim2.fromScale(1, 1),
                    SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                    Parent = TabButton,
                })
            end

            table.insert(Library.TabButtons, {
                Label = TabLabel,
                Padding = ButtonPadding,
                Icon = TabIcon,
            })

            --// Tab Container \\--
            TabContainer = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                ScrollBarThickness = 0,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })
            New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                Parent = TabContainer,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name, Visible = true,
            Elements = {}, DependencyBoxes = {}, DependencyGroupboxes = {}, InnerTabboxes = {}, Sides = { TabContainer },
            IsKeyTab = true,
        }

        function Tab:AddKeyBox(Callback)
            assert(typeof(Callback) == "function", "Callback must be a function")
            local Holder = New("Frame", { Name = "KeyEntry", BackgroundTransparency = 1, Size = UDim2.new(1, -16, 0, 42), Parent = TabContainer })
            local Box = New("TextBox", { BackgroundColor3 = "FieldColor", PlaceholderText = "Key", Text = "", ClearTextOnFocus = false, FontFace = "FontMono", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
            Library:StyleField(Box)
            New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = Box })
            local Button = New("TextButton", { Text = "Execute", TextSize = 15, RichText = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Parent = Holder })
            Library:StyleAction(Button, "Primary", false, false)
            local function Fit()
                if not Holder.Parent or Library.Unloaded then return end
                local M = Library:Metrics()
                local Width = Library:GetTextBounds(Button.Text, Button.FontFace, Button.TextSize, 0, false) + 26
                local Stacked = Holder.AbsoluteSize.X - Width - 8 < 120
                local Height = math.max(M.Target, M.Field)
                Holder.Size = UDim2.new(1, -16, 0, Stacked and Height * 2 + 6 or Height)
                Box.Size = UDim2.new(1, Stacked and 0 or -Width - 8, 0, Height)
                Button.Size = UDim2.new(Stacked and 1 or 0, Stacked and 0 or Width, 0, Height)
                Button.Position = UDim2.new(1, 0, 0, Stacked and Height + 6 or 0)
            end
            Button.Activated:Connect(function(Input)
                if Library:CanInteract(Button, Input) then Library:SafeCallback(Callback, Box.Text) end
            end)
            Library.TextReflows[Holder] = Fit
            Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(Fit)
            Fit()
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = Hovering and 0.25 or 0.5,
                }):Play()
            end
        end

        function Tab:Show()
            if Library.Unloaded or Tab.Visible == false then return false end
            if Library.ActiveTab == Tab then Tab:RefreshSides(); return true end
            if Library.ActiveTab then
                Library.ActiveTab:Hide()
            end

            Library:CreateTween(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end
            TabContainer.Visible = true

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab
            if Window.OnPageShown then Window:OnPageShown(Tab) end

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            if Library.ActiveTab == Tab and CurrentMenu then CurrentMenu:Close() end
            if Library.ActiveTab == Tab and Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            Library:CreateTween(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            Library:CreateTween(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                Library:CreateTween(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0.5,
                }):Play()
            end
            TabContainer.Visible = false

            if Library.ActiveTab == Tab then Window:HideTabInfo(); Library.ActiveTab = nil end
        end

        function Tab:SetVisible(Visible: boolean)
            Tab.Visible = Visible
            TabButton.Visible = Visible

            if not Visible and Library.ActiveTab == Tab then
                Tab:Hide()
            end
        end

        function Tab:SetOrder(Order)
            assert(IsFinite(Order), "Tab order must be finite")
            TabButton.LayoutOrder = Order
        end
        function Tab:SetName(NewName)
            assert(typeof(NewName) == "string" and NewName ~= "", "Tab name must be nonempty")
            assert(not Library.Tabs[NewName] or Library.Tabs[NewName] == Tab, "Tab name already exists")
            if Library.Tabs[Name] == Tab then Library.Tabs[Name] = nil end
            Name, Tab.Name, TabLabel.Text = NewName, NewName, NewName
            Library.Tabs[NewName] = Tab
            if Library.ActiveTab == Tab and Description then Window:ShowTabInfo(Name, Description) end
        end
        function Tab:SetDescription(Value)
            Description = Value
            if Library.ActiveTab == Tab then
                if Description then Window:ShowTabInfo(Name, Description) else Window:HideTabInfo() end
            end
        end
        function Tab:SetIcon(Value)
            local NewIcon = Library:GetCustomIcon(Value)
            if not TabIcon and NewIcon then
                TabIcon = New("ImageLabel", { Size = UDim2.fromScale(1, 1), SizeConstraint = Enum.SizeConstraint.RelativeYY, Parent = TabButton })
                for _, Button in Library.TabButtons do if Button.Label == TabLabel then Button.Icon = TabIcon end end
            end
            Icon = NewIcon
            if TabIcon then
                TabIcon.Visible = NewIcon ~= nil
                if NewIcon then
                    TabIcon.Image = NewIcon.Url
                    TabIcon.ImageRectOffset, TabIcon.ImageRectSize = NewIcon.ImageRectOffset, NewIcon.ImageRectSize
                    TabIcon.ImageColor3 = NewIcon.Custom and Library.Scheme.WhiteColor or Library.Scheme.AccentColor
                    Library:AddToRegistry(TabIcon, { ImageColor3 = NewIcon.Custom and "WhiteColor" or "AccentColor" })
                end
            end
            TabLabel.Position = UDim2.fromOffset(NewIcon and 30 or 0, 0)
            TabLabel.Size = UDim2.new(1, NewIcon and -30 or 0, 1, 0)
            ApplyCompact()
        end

        --// Execution \\--
        if not Library.ActiveTab then
            Tab:Show()
        end

        TabButton.MouseEnter:Connect(function()
            Tab:Hover(true)
        end)
        TabButton.MouseLeave:Connect(function()
            Tab:Hover(false)
        end)
        TabButton.Activated:Connect(Tab.Show)
        Library:AddTooltip(Name or "", "", TabButton)

        Tab.Container = TabContainer
        setmetatable(Tab, BaseGroupbox)

        Library.Tabs[Name] = Tab

        return Tab
    end


    function Window:AddDialog(Idx, Info)
        Info = Library:Validate(Info, Templates.Dialog)
        assert(Idx ~= nil, "Dialog ID is required")
        if Library.Dialogues[Idx] then Library.Dialogues[Idx]:Destroy() end
        local Overlay = New("TextButton", { BackgroundColor3 = "DarkColor", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", Visible = false, ZIndex = 9000, Parent = MainFrame })
        local Frame = New("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "BackgroundColor", Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(400, 160), Text = "", ZIndex = 9001, Parent = Overlay })
        Library:AddOutline(Frame)
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Frame }))
        local Scale = New("UIScale", { Scale = 1, Parent = Frame })
        local Surface = New("ScrollingFrame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.fromScale(0, 0), ScrollBarThickness = 0, ScrollBarImageColor3 = "AccentColor", ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Frame })
        local Header = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 12), Size = UDim2.new(1, -28, 0, 50), Parent = Surface })
        local Icon = Library:GetCustomIcon(Info.Icon)
        if Icon then New("ImageLabel", { Image = Icon.Url, ImageRectOffset = Icon.ImageRectOffset, ImageRectSize = Icon.ImageRectSize, ImageColor3 = Info.TitleColor or "FontColor", Position = UDim2.fromOffset(0, 1), Size = UDim2.fromOffset(18, 18), Parent = Header }) end
        local Title = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Icon and 24 or 0, 0), Text = tostring(Info.Title), TextColor3 = Info.TitleColor or "FontColor", TextSize = 18, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header })
        local Description = New("TextLabel", { BackgroundTransparency = 1, Text = tostring(Info.Description), TextColor3 = Info.DescriptionColor or "FontColor", TextTransparency = Info.DescriptionColor and 0 or 0.25, TextSize = 14, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header })
        local Body = New("ScrollingFrame", { BackgroundTransparency = 1, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.fromScale(0, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = "AccentColor", ScrollingDirection = Enum.ScrollingDirection.Y, Parent = Surface })
        local Content = New("Frame", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, -4, 0, 0), Parent = Body })
        local ContentLayout = New("UIListLayout", { Padding = UDim.new(0, 12), Parent = Content })
        local Separator = New("Frame", { BackgroundColor3 = "OutlineColor", Size = UDim2.new(1, -28, 0, 1), Parent = Surface })
        local Footer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 28), Parent = Surface })
        local FooterLayout = New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Wraps = true, Padding = UDim.new(0, 6), Parent = Footer })
        local FooterButtons = {}
        local CloseDialog = New("TextButton", { Name = "DismissDialog", BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(32, 32), ZIndex = 9002, Parent = Frame })
        Library:CreateSymbol(CloseDialog, "close", UDim2.new(0.5, -8, 0.5, -8), 16)
        Library:AddTooltip("Close dialog without executing an action", "", CloseDialog)
        local Dialog = {
            Idx = Idx, Elements = {}, DependencyBoxes = {}, DependencyGroupboxes = {}, InnerTabboxes = {},
            Holder = Overlay, BoxHolder = Content, Container = Content, Sides = { Body },
            Visible = false, Destroyed = false, IsDialog = true, Internal = Info.Internal == true, Generation = 0,
            Frame = Frame, Depth = 0, NavKey = Library:NavigationKey(nil, "dialog", Idx),
        }
        Dialog.Tab = Dialog
        local function Cancel(Thread)
            if Thread and Thread ~= coroutine.running() then pcall(task.cancel, Thread) end
        end
        local function StopWait(Button)
            Cancel(Button.Timer); Button.Timer = nil
            StopTween(Button.TimerTween); Button.TimerTween = nil
        end
        function Dialog:Resize()
            if Dialog.Destroyed or not Frame.Parent then return end
            local Dpi = Library.DPIScale * Scale.Scale
            local Origin, Available = Library:GetUsableRect(true)
            local MainOrigin = MainFrame.AbsolutePosition - ScreenGui.AbsolutePosition
            local Center = Origin - MainOrigin + Available / 2
            Frame.Position = UDim2.fromOffset(math.floor(Center.X), math.floor(Center.Y))
            local Width = math.max(100, math.min(tonumber(Info.Width) or 400, Available.X - 24))
            local MaxHeight = math.max(80, Available.Y - 24)
            local CloseSize = Library:Metrics().Target
            CloseDialog.Size = UDim2.fromOffset(CloseSize, CloseSize)
            local _, TitleHeight = Library:GetTextBounds(Title.Text, Title.FontFace, Title.TextSize, math.max(1, Width - 36 - CloseSize - (Icon and 24 or 0)), false)
            local _, DescHeight = Library:GetTextBounds(Description.Text, Description.FontFace, Description.TextSize, math.max(1, Width - 28))
            if Description.Text == "" then DescHeight = 0 end
            Title.Size = UDim2.new(1, -CloseSize - 8 - (Icon and 24 or 0), 0, TitleHeight)
            Description.Position = UDim2.fromOffset(0, TitleHeight + 6)
            Description.Size = UDim2.new(1, 0, 0, DescHeight)
            Description.Visible = DescHeight > 0
            local HeaderHeight = TitleHeight + (DescHeight > 0 and DescHeight + 6 or 0)
            Header.Size = UDim2.new(1, -28, 0, HeaderHeight)
            local HasButtons = next(FooterButtons) ~= nil
            Footer.Visible = HasButtons; Separator.Visible = HasButtons
            local FooterHeight = HasButtons and math.max(Library:Metrics().Target, FooterLayout.AbsoluteContentSize.Y / Dpi) or 0
            local ContentHeight = ContentLayout.AbsoluteContentSize.Y / Dpi
            local BodyLimit = math.max(0, MaxHeight - HeaderHeight - FooterHeight - 50)
            local BodyHeight = math.min(ContentHeight, tonumber(Info.MaxHeight) or BodyLimit, BodyLimit)
            Body.Position = UDim2.fromOffset(14, 12 + HeaderHeight + 10)
            Body.Size = UDim2.new(1, -28, 0, BodyHeight)
            Body.Visible = BodyHeight > 0
            Body.ScrollBarThickness = ContentHeight > BodyHeight and 3 or 0
            local Bottom = 12 + HeaderHeight + (BodyHeight > 0 and BodyHeight + 10 or 0)
            Separator.Position = UDim2.fromOffset(14, Bottom + 10)
            Footer.Position = UDim2.fromOffset(14, Bottom + 20)
            Footer.Size = UDim2.new(1, -28, 0, FooterHeight)
            local TotalHeight = Bottom + (HasButtons and FooterHeight + 32 or 12)
            Frame.Size = UDim2.fromOffset(Width, math.min(TotalHeight, MaxHeight))
            Surface.CanvasSize = UDim2.fromOffset(0, TotalHeight)
            Surface.ScrollBarThickness = TotalHeight > MaxHeight and 3 or 0
        end
        local ResizeQueued = false
        local function QueueResize()
            if ResizeQueued or Dialog.Destroyed then return end
            ResizeQueued = true
            task.defer(function() ResizeQueued = false; if not Dialog.Destroyed then Dialog:Resize() end end)
        end
        Library.TextReflows[Frame] = QueueResize
        Title:GetPropertyChangedSignal("TextSize"):Connect(QueueResize)
        Description:GetPropertyChangedSignal("TextSize"):Connect(QueueResize)
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueResize)
        FooterLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueResize)
        Library:GiveSignal(MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueResize), Overlay)
        for _, Property in { "OnScreenKeyboardVisible", "OnScreenKeyboardPosition", "OnScreenKeyboardSize" } do
            pcall(function() Library:GiveSignal(UserInputService:GetPropertyChangedSignal(Property):Connect(function() if Dialog.Visible then QueueResize() end end), Overlay) end)
        end
        function Dialog:SetTitle(Value) if not Dialog.Destroyed then Title.Text = tostring(Value or ""); Dialog:Resize() end end
        function Dialog:SetDescription(Value) if not Dialog.Destroyed then Description.Text = tostring(Value or ""); Dialog:Resize() end end
        function Dialog:SetSize(Width, MaxHeight)
            if Width ~= nil then assert(IsFinite(Width) and Width > 0, "Width must be positive"); Info.Width = Width end
            if MaxHeight ~= nil then assert(IsFinite(MaxHeight) and MaxHeight > 0, "MaxHeight must be positive"); Info.MaxHeight = MaxHeight end
            Dialog:Resize()
        end
        local function Collect(Box, Result)
            for _, Element in Box.Elements or {} do
                table.insert(Result, Element)
                for _, Addon in Element.Addons or {} do table.insert(Result, Addon) end
                if Element.SubButton then table.insert(Result, Element.SubButton) end
            end
            for _, Child in Box.DependencyBoxes or {} do Collect(Child, Result) end
            for _, Child in Box.DependencyGroupboxes or {} do Collect(Child, Result) end
            for _, Tabbox in Box.InnerTabboxes or {} do for _, Tab in Tabbox.Tabs do Collect(Tab, Result) end end
            return Result
        end
        function Dialog:GetElement(Key)
            for _, Element in Collect(Dialog, {}) do if Element.Idx == Key then return Element end end
            return nil
        end
        local function RemoveReference(Box, Element)
            local Index = table.find(Box.Elements or {}, Element)
            if Index then table.remove(Box.Elements, Index) end
            for _, Parent in Box.Elements or {} do
                local AddonIndex = table.find(Parent.Addons or {}, Element)
                if AddonIndex then table.remove(Parent.Addons, AddonIndex) end
                if Parent.SubButton == Element then Parent.SubButton = nil end
            end
            for _, Child in Box.DependencyBoxes or {} do RemoveReference(Child, Element) end
            for _, Child in Box.DependencyGroupboxes or {} do RemoveReference(Child, Element) end
            for _, Tabbox in Box.InnerTabboxes or {} do for _, Tab in Tabbox.Tabs do RemoveReference(Tab, Element) end end
        end
        function Dialog:RemoveElement(Key)
            local Element = Dialog:GetElement(Key)
            if not Element then return false end
            RemoveReference(Dialog, Element)
            Library:DestroyElement(Element)
            Dialog:Resize()
            return true
        end
        function Dialog:ClearElements()
            for _, Element in Collect(Dialog, {}) do Library:DestroyElement(Element) end
            for Index = #Library.DependencyBoxes, 1, -1 do
                local Box = Library.DependencyBoxes[Index]
                if Box.IsDialog and Box.Holder and (not Box.Holder.Parent or Box.Holder:IsDescendantOf(Content)) then table.remove(Library.DependencyBoxes, Index) end
            end
            for _, Child in Content:GetChildren() do if Child:IsA("GuiObject") then Child:Destroy() end end
            table.clear(Dialog.Elements); table.clear(Dialog.DependencyBoxes); table.clear(Dialog.DependencyGroupboxes); table.clear(Dialog.InnerTabboxes)
            Dialog:Resize()
        end
        function Dialog:IsVisible() return Dialog.Visible and not Dialog.Destroyed end
        function Dialog:Dismiss()
            if Window.SuspendedDialog == Dialog then Window.SuspendedDialog = nil end
            if not Dialog.Visible or Dialog.Destroyed then return false end
            Dialog.Visible = false
            Library:PopFocusScope(Dialog)
            Dialog.Generation += 1
            local Generation = Dialog.Generation
            if Library.ActiveDialog == Dialog then Library.ActiveDialog = nil end
            if CurrentMenu and CurrentMenu.Holder:IsDescendantOf(Overlay) then CurrentMenu:Close() end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            for _, Button in FooterButtons do StopWait(Button) end
            Library:CreateTween(Overlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            Library:CreateTween(Frame, Library.TweenInfo, { Position = Frame.Position + UDim2.fromOffset(0, Library:IsReducedMotion() and 0 or 5) }):Play()
            Cancel(Dialog.HideTask)
            Dialog.HideTask = task.delay(Library.TweenInfo.Time, function()
                Dialog.HideTask = nil
                if Dialog.Destroyed or Dialog.Generation ~= Generation or Dialog.Visible then return end
                Overlay.Visible = false
                if Info.AutoDestroy then Dialog:Destroy() end
            end)
            Library:SafeCallback(Info.OnDismiss, Dialog)
            return true
        end
        function Dialog:Destroy()
            Library:PopFocusScope(Dialog)
            if Window.SuspendedDialog == Dialog then Window.SuspendedDialog = nil end
            if Dialog.Destroyed then return end
            Dialog:ClearElements()
            Dialog.Destroyed = true
            Dialog.Visible = false
            Dialog.Generation += 1
            Cancel(Dialog.HideTask); Dialog.HideTask = nil
            for _, Button in FooterButtons do StopWait(Button) end
            if Library.ActiveDialog == Dialog then Library.ActiveDialog = nil end
            if Library.Dialogues[Idx] == Dialog then Library.Dialogues[Idx] = nil end
            Overlay:Destroy()
            Library:SafeCallback(Info.OnDestroy, Dialog)
        end
        function Dialog:Show()
            if Dialog.Destroyed or Library.Unloaded then return false end
            if Dialog.Visible then return true end
            if Library.ActiveDialog and Library.ActiveDialog ~= Dialog then Library.ActiveDialog:Dismiss() end
            if CurrentMenu then CurrentMenu:Close() end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            Cancel(Dialog.HideTask); Dialog.HideTask = nil
            Dialog.Generation += 1
            Dialog.Visible = true
            if not Library.Toggled then Library:Toggle(true) end
            Library.ActiveDialog = Dialog
            Overlay.Visible = true
            Overlay.BackgroundTransparency = 1
            Scale.Scale = 1
            Dialog:Resize()
            local Target = Frame.Position
            Frame.Position = Target + UDim2.fromOffset(0, Library:IsReducedMotion() and 0 or 5)
            Library:CreateTween(Overlay, Library.TweenInfo, { BackgroundTransparency = 0.45 }):Play()
            Library:CreateTween(Frame, Library.TweenInfo, { Position = Target }):Play()
            Library:PushFocusScope(Dialog, Frame)
            Library:RefreshVisibleComponents()
            for _, Button in FooterButtons do Button:StartWait() end
            Library:SafeCallback(Info.OnShow, Dialog)
            return true
        end
        function Dialog:RemoveFooterButton(Key)
            local Button = FooterButtons[Key]
            if Button then StopWait(Button); Button.Container:Destroy(); FooterButtons[Key] = nil; Dialog:Resize() end
        end
        function Dialog:SetButtonDisabled(Key, Disabled)
            local Button = FooterButtons[Key]
            if Button then Button.Disabled = Disabled == true; Button:Display() end
        end
        function Dialog:SetButtonOrder(Key, Order)
            local Button = FooterButtons[Key]
            if Button then assert(IsFinite(Order), "Order must be finite"); Button.Container.LayoutOrder = Order; Dialog:Resize() end
        end
        function Dialog:SetButtonText(Key, Text)
            local Button = FooterButtons[Key]
            if Button then
                Button.Label.Text = tostring(Text or "")
                local Width, Height = Library:GetTextBounds(Button.Label.Text, Button.Label.FontFace, Button.Label.TextSize, math.max(40, math.min(240, Frame.Size.X.Offset - 52)), false)
                Button.Container.Size = UDim2.fromOffset(math.ceil(Width + 24), math.max(Library:Metrics().Target, math.ceil(Height + 12)))
                Dialog:Resize()
            end
        end
        function Dialog:SetButtonVariant(Key, Variant)
            local Button = FooterButtons[Key]
            if Button then Button.Variant = Variant; Button:Display() end
        end
        function Dialog:AddFooterButton(Key, ButtonInfo)
            assert(typeof(ButtonInfo) == "table", "Footer button options must be a table")
            Dialog:RemoveFooterButton(Key)
            local Button = { Variant = ButtonInfo.Variant or "Secondary", Disabled = ButtonInfo.Disabled == true, Busy = false, Waiting = false, WaitTime = IsFinite(ButtonInfo.WaitTime) and math.max(0, ButtonInfo.WaitTime) or 0 }
            Button.Container = New("TextButton", { BackgroundColor3 = "MainColor", Size = UDim2.fromOffset(80, 28), LayoutOrder = ButtonInfo.Order or 0, Text = "", Parent = Footer })
            Button.Label = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = tostring(ButtonInfo.Title or Key), TextSize = 15, RichText = false, TextWrapped = true, Parent = Button.Container })
            local Stroke = New("UIStroke", { Color = "OutlineColor", Parent = Button.Container })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Button.Container }))
            Button.Progress = New("Frame", { BackgroundColor3 = "AccentColor", Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(0, 0, 0, 2), Visible = false, Parent = Button.Container })
            function Button:Display()
                if Dialog.Destroyed or not Button.Container.Parent then return end
                local Disabled = Button.Disabled or Button.Waiting or Button.Busy
                Library:StyleAction(Button.Container, Button.Variant, Disabled, Button.Hovered)
                local function Foreground()
                    local Props = Library.Registry[Button.Container]
                    local Color = Props and Props.TextColor3
                    return typeof(Color) == "function" and Color() or Button.Container.TextColor3
                end
                Library:AddToRegistry(Button.Label, { TextColor3 = Foreground, FontFace = "Font" })
                Button.Label.TextColor3 = Foreground()
                Button.Label.TextTransparency = Disabled and 0.18 or 0
                Stroke.Transparency = Disabled and 0.5 or 0.05
            end
            function Button:StartWait()
                StopWait(Button)
                Button.Waiting = Button.WaitTime > 0
                Button.Progress.Visible = Button.Waiting
                Button.Progress.Size = UDim2.new(0, 0, 0, 2)
                Button:Display()
                if not Button.Waiting then return end
                local Generation = Dialog.Generation
                Button.TimerTween = Library:CreateTween(Button.Progress, TweenInfo.new(Button.WaitTime, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 0, 2) })
                Button.TimerTween:Play()
                Button.Timer = task.delay(Button.WaitTime, function()
                    Button.Timer = nil
                    if Dialog.Destroyed or not Dialog.Visible or Dialog.Generation ~= Generation or FooterButtons[Key] ~= Button then return end
                    Button.Waiting = false; Button.Progress.Visible = false; Button:Display()
                end)
            end
            Button.Container.MouseEnter:Connect(function() Button.Hovered = true; Button:Display() end)
            Button.Container.MouseLeave:Connect(function() Button.Hovered = false; Button:Display() end)
            Button.Label:GetPropertyChangedSignal("TextSize"):Connect(function() Dialog:SetButtonText(Key, Button.Label.Text) end)
            Button.Container.Activated:Connect(function(Input)
                if Dialog.Destroyed or not Dialog.Visible or Button.Disabled or Button.Waiting or Button.Busy or not Library:CanInteract(Button.Container, Input) then return end
                local Generation = Dialog.Generation
                Button.Busy = true; local OriginalCaption = Button.Label.Text; Button.Label.Text = "Working"; Button:Display()
                local Ok, Result = true, nil
                if typeof(ButtonInfo.Callback) == "function" then Ok, Result = pcall(ButtonInfo.Callback, Dialog) end
                Button.Busy = false; if Button.Label.Parent then Button.Label.Text = OriginalCaption end; Button:Display()
                if not Ok then
                    warn("Dialog callback: " .. tostring(Result))
                    Library:Notify({ Title = "Action failed", Description = tostring(Result), Type = "Error" })
                    return
                end
                if Info.AutoDismiss and Result ~= false and Dialog.Generation == Generation then Dialog:Dismiss() end
            end)
            FooterButtons[Key] = Button
            Dialog:SetButtonText(Key, ButtonInfo.Title or Key)
            Button:Display()
            if Dialog.Visible then Button:StartWait() end
            return Button
        end
        CloseDialog.Activated:Connect(function() Dialog:Dismiss() end)
        Overlay.Activated:Connect(function() if Info.OutsideClickDismiss then Dialog:Dismiss() end end)
        for Key, ButtonInfo in Info.FooterButtons do Dialog:AddFooterButton((typeof(Key) == "number" and ButtonInfo.Id) or Key, ButtonInfo) end
        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog
        Dialog:Resize()
        if not Info.StartHidden then Dialog:Show() end
        return Dialog
    end


    function Window:SelectFallbackPage()
        local First
        for _, Page in Library.Tabs do
            if Page.Visible ~= false and not Page.IsKeyTab and not Page.Destroyed then
                if not First or (Page.ButtonHolder.LayoutOrder < First.ButtonHolder.LayoutOrder) then First = Page end
            end
        end
        if First then First:Show() end
    end
    function Library:Toggle(Value)
        if Library.Unloaded then return end
        local Next = typeof(Value) == "boolean" and Value or not Library.Toggled
        if Next == Library.Toggled and MainFrame.Visible == Next then return end
        Library.Toggled, MainFrame.Visible = Next, Next
        if WindowInfo.UnlockMouseWhileOpen then ModalElement.Modal = Next end
        if not Next then
            if Library.PickingKeybind then Library.PickingKeybind.CancelPicking() end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            if CurrentMenu then CurrentMenu:Close("window hidden") end
            if Window.CloseCommandPalette then Window:CloseCommandPalette() end
            Window:SetHelpMode(false)
            Library:StopPointerDrag("window hidden")
            Library:HideTooltip()
            Library:SetSnapGuides(nil, false)
            Library.CantDragForced = false
            local Focus = UserInputService:GetFocusedTextBox()
            if Focus and Focus:IsDescendantOf(MainFrame) then Focus:ReleaseFocus() end
            -- Hiding suspends a dialog without invoking dismissal or feature callbacks.
            if Library.ActiveDialog then
                Window.SuspendedDialog = Library.ActiveDialog
                Library:PopFocusScope(Library.ActiveDialog)
                Library.ActiveDialog = nil
            end
        else
            local Dialog = Window.SuspendedDialog
            Window.SuspendedDialog = nil
            if Dialog and not Dialog.Destroyed and Dialog.Visible then
                Library.ActiveDialog = Dialog
                Library:PushFocusScope(Dialog, Dialog.Frame or Dialog.Holder)
            end
            Library:RefreshVisibleComponents()
        end
        if Library.Launcher then Library.Launcher.Visible = not Next end
        Library:LayoutChanged()
    end
    local Launcher = New("TextButton", { Name = "ChiyoLauncher", BackgroundColor3 = "HeaderColor", Text = "", Position = UDim2.fromOffset(16, 64), Size = UDim2.fromOffset(52, 52), Visible = true, ZIndex = 90, Parent = ScreenGui })
    Library.Launcher = Launcher
    Library:Surface(Launcher, "Action")
    New("Frame", { BackgroundColor3 = "AccentColor", Position = UDim2.new(0, 0, 1, -3), Size = UDim2.new(1, 0, 0, 3), Parent = Launcher })
    local LauncherText = New("TextLabel", { BackgroundTransparency = 1, RichText = false, Text = "Chiyo", FontFace = "FontBold", TextSize = 15, Size = UDim2.fromScale(1, 1), Visible = BrandIcon == nil, Parent = Launcher })
    local LauncherImage
    if BrandIcon then LauncherImage = New("ImageLabel", { Image = BrandIcon.Url, ImageRectOffset = BrandIcon.ImageRectOffset, ImageRectSize = BrandIcon.ImageRectSize, BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(30, 30), Parent = Launcher }) end
    Library:AddTooltip("Open Chiyo. Drag to reposition this launcher.", "", Launcher)
    local function FitLauncher()
        local Width = Library:GetTextBounds("Chiyo", LauncherText.FontFace, LauncherText.TextSize, 0, false)
        local Side = math.max(48, Library:Metrics().Target + 8, math.ceil(Width + 10))
        Launcher.Size = UDim2.fromOffset(Side, Side)
        if LauncherImage then LauncherImage.Size = UDim2.fromOffset(Side - 18, Side - 18) end
    end
    Launcher.InputBegan:Connect(function(Input)
        if not IsClickInput(Input) or Library.Toggled then return end
        local Start, Position, Moved = Input.Position, Launcher.Position, false
        Library:BeginPointerDrag(Launcher, Input, function(Point)
            local Delta = Point - Start
            if Delta.Magnitude > 7 then Moved = true end
            if Moved then Launcher.Position = UDim2.fromOffset(math.floor(Position.X.Offset + Delta.X), math.floor(Position.Y.Offset + Delta.Y)) end
        end, function(Reason)
            if Reason == "end" then
                Library:SnapFrame(Launcher, true)
                if not Moved then Library:Toggle(true) else Library:LayoutChanged() end
            end
        end)
    end)
    Library.TextReflows[Launcher] = FitLauncher
    FitLauncher()
    if WindowInfo.EnableSidebarResize then
        local Grabber = New("TextButton", { Name = "ResizeNavigation", BackgroundTransparency = 1, Text = "", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(0, Library.IsMobile and 24 or 12, 1, 0), Parent = DividerLine })
        Grabber.InputBegan:Connect(function(Input)
            if not IsClickInput(Input) or Window.Narrow then return end
            local Start, Width = Input.Position.X, Window:GetSidebarWidth()
            Library:BeginPointerDrag(Grabber, Input, function(Point)
                local Value = Width + Point.X - Start
                Window.RequestedCompact = Value < 130
                if not Window.RequestedCompact then Window.ExpandedSidebarWidth = math.clamp(math.floor(Value), 180, 320) end
                Window:ApplyLayout()
            end, function() Library:LayoutChanged() end)
        end)
    end
    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
        if Library.Unloaded or Library.HandledInputs[Input] or Library.CaptureInputs[Input] or Library.PickingKeybind then return end
        if Window.HandleStudioInput and Window:HandleStudioInput(Input) then return end
        if Library.ActiveExpandedDropdown and Library.ActiveExpandedDropdown.HandleInput then
            if Library.ActiveExpandedDropdown:HandleInput(Input) then Library.HandledInputs[Input] = true; return end
        end
        local Key = Input.KeyCode
        if Key == Enum.KeyCode.Escape or Key == Enum.KeyCode.ButtonB then
            if CurrentMenu then CurrentMenu:Close("escape")
            elseif Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse()
            elseif Library.ActiveDialog then Library.ActiveDialog:Dismiss()
            elseif Library.HelpMode then Window:SetHelpMode(false)
            elseif Window.DrawerOpen then Window:CloseNavigationDrawer()
            else return end
            Library.ConsumedInputs[Input], Library.HandledInputs[Input] = true, true
            return
        end
        if UserInputService:GetFocusedTextBox() or CurrentMenu or Library.ActiveDialog or Library.ActiveExpandedDropdown or Library.HelpMode or Library.ActivePointerDrag or (Window.Studio and Window.Studio.PaletteOpen) then return end
        if Library.ConsumedInputs[Input] then return end
        if Key == Enum.KeyCode.RightAlt then Library:ToggleNotificationHistory(); Library.ConsumedInputs[Input] = true; return end
        local Bind, Matches = Library.ToggleKeybind, false
        if typeof(Bind) == "EnumItem" then Matches = Key == Bind
        elseif typeof(Bind) == "table" and Bind.Type == "KeyPicker" then
            local MouseKeys = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
            Matches = Input.UserInputType == Enum.UserInputType.Keyboard and Key.Name == Bind.Value or MouseKeys[Bind.Value] == Input.UserInputType
            local Modifiers = { LAlt = Enum.KeyCode.LeftAlt, RAlt = Enum.KeyCode.RightAlt, LCtrl = Enum.KeyCode.LeftControl, RCtrl = Enum.KeyCode.RightControl, LShift = Enum.KeyCode.LeftShift, RShift = Enum.KeyCode.RightShift, Tab = Enum.KeyCode.Tab, CapsLock = Enum.KeyCode.CapsLock }
            for _, Name in Bind.Modifiers or {} do if not Modifiers[Name] or not UserInputService:IsKeyDown(Modifiers[Name]) then Matches = false; break end end
        end
        if Matches then Library.ConsumedInputs[Input] = true; Library:Toggle() end
    end), MainFrame)
    Library:GiveSignal(UserInputService.WindowFocused:Connect(function() Library.IsRobloxFocused = true end), MainFrame)
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
        if Library.PickingKeybind then Library.PickingKeybind.CancelPicking() end
        Library:StopPointerDrag("focus lost")
        for _, Option in Options do
            if Option.Type == "KeyPicker" and Option.Mode == "Hold" and Option.Toggled then Option.Toggled = false; Option:DoClick(); Option:Update() end
        end
    end), MainFrame)
    Library:InstallStudioWorkspace(Window, { Main = MainFrame, Container = Container, Appearance = Appearance, Search = SearchButton }, WindowInfo)
    Window:ApplyLayout()
    if WindowInfo.Center then Window:Center() end
    Library.LayoutDefault = { Position = MainFrame.Position, Size = MainFrame.Size }
    Library:DeferOwned(MainFrame, nil, function()
        if Library.PendingWindowPreferences then
            local Preferences = Library.PendingWindowPreferences; Library.PendingWindowPreferences = nil
            Library:SetPreferences(Preferences)
        elseif WindowInfo.AutoShow then Library:Toggle(true) end
        Library:ScheduleNavigationRestore()
    end)
    return Window
end

function Library:Confirm(Info)
    assert(Library.Window, "Library:Confirm requires a window")
    Info = typeof(Info) == "table" and Info or {}
    local Previous = Library.ActiveDialog
    if Previous then Previous:Dismiss() end
    Library.ConfirmSequence = (Library.ConfirmSequence or 0) + 1
    local Decision, Resolved = false, false
    local function Resolve()
        if Resolved then return end
        Resolved = true
        if Previous and not Previous.Destroyed and not Library.Unloaded then Previous:Show() end
        Library:SafeCallback(Info.Callback, Decision)
    end
    local Dialog = Library.Window:AddDialog("__Confirm_" .. Library.ConfirmSequence, {
        Title = Info.Title or "Confirm", Description = Info.Description or "Are you sure?", Icon = Info.Icon,
        AutoDismiss = false, AutoDestroy = true, OutsideClickDismiss = Info.OutsideClickDismiss ~= false,
        OnDismiss = Resolve, OnDestroy = Resolve,
        FooterButtons = {
            Cancel = { Title = Info.CancelText or "Cancel", Variant = "Ghost", Order = 1, Callback = function(Self) Self:Dismiss() end },
            Confirm = { Title = Info.ConfirmText or "Confirm", Variant = Info.ConfirmVariant or "Primary", Order = 2, WaitTime = Info.WaitTime,
                Callback = function(Self) Decision = true; Self:Dismiss() end },
        },
    })
    return Dialog
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(function() task.defer(OnPlayerChange) end))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

getgenv().Library = Library
return Library
