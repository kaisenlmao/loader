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

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
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
    ForceCheckbox = false,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,

    CantDragForced = false,

    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,
    OptionChangedCallbacks = {},

    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(255, 160, 182),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Gotham),

        RedColor = Color3.fromRGB(255, 50, 50),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),
    },

    Registry = {},
    Scales = {},

    ImageManager = CustomImageManager,
}

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
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
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
        Title = "No Title",
        Footer = "No Footer",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),
        AutoShow = true,
        Center = true,
        Resizable = true,
        SearchbarSize = UDim2.fromScale(1, 1),
        GlobalSearch = false,
        FuzzySearch = true,
        SearchValues = true,
        CornerRadius = 4,
        NotifySide = "Right",
        Font = Enum.Font.Gotham,
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
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
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
        ClearTextOnFocus = true,
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
        Searchable = false,
        SelectAllButtons = true,
        Expandable = false,
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
            local Formatted = Element.FormatListValue and Element.FormatListValue(Value) or Value
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
end

function Library:SetDPIScale(DPIScale: number)
    assert(typeof(DPIScale) == "number" and DPIScale == DPIScale and DPIScale >= 25 and DPIScale <= 300, "DPI scale must be between 25 and 300")
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

    for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" or Option.Type == "PriorityDropdown" then
            Option:RecalculateListSize()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end
    Library:UpdateNotificationPositions(true)
    if Library.LayoutMain then Library:SnapFrame(Library.LayoutMain) end
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

local function IsFinite(Value)
    return typeof(Value) == "number" and Value == Value and math.abs(Value) < math.huge
end

function Library:DestroyElement(Element, SkipHolder)
    if not Element or Element.Destroyed then return end
    Element.Destroyed = true
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
        if Menu then Menu:Close(); if Menu.Menu then Menu.Menu:Destroy() end end
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
    Element.Groupbox = Element.Groupbox or Owner
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

local FetchIcons, Icons = pcall(function()
    return (loadstring(
        game:HttpGet("https://gitlab.com/upio/lucide-roblox-direct/-/raw/main/source.lua")
    ) :: () -> IconModule)()
end)

function Library:GetIcon(IconName: string)
    if not FetchIcons then
        return
    end

    local Success, Icon = pcall(Icons.GetAsset, IconName)
    if not Success then
        return
    end
    return Icon
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
    if ClassName == "UIScale" and Properties.Scale == nil then
        Properties = table.clone(Properties)
        Properties.Scale = Library.DPIScale
    end

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
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
    Name = "Obsidian",
    DisplayOrder = 999,
    ResetOnSpawn = false,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui
ScreenGui.DescendantRemoving:Connect(function(Instance)
    Library:RemoveFromRegistry(Instance)
    for _, Registry in { Library.Corners, Library.Scales } do
        local Index = table.find(Registry, Instance)
        if Index then table.remove(Registry, Index) end
    end
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
                TweenService:Create(FakeBg, Library.NotifyTweenInfo, {
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

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = math.max(1, Width or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X - 32 or 720))
    local Success, Bounds = pcall(TextService.GetTextBoundsAsync, TextService, Params)
    Params:Destroy()
    if not Success then error(Bounds, 2) end
    return Bounds.X, Bounds.Y
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
        task.defer(error, debug.traceback(Error, 2))
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

function Library:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local BeginConnection = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if UI == Library.LayoutMain then
                Library:SnapFrame(UI)
                Library:SetSnapGuides(nil, false)
                Library:LayoutChanged()
            end
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)
    local MoveConnection = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Position =
                UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
            if UI == Library.LayoutMain then
                Library:SetSnapGuides(UI, true)
            end
        end
    end)
    Library:GiveSignal(MoveConnection, UI)
    UI.Destroying:Once(function()
        Dragging = false
        if Changed and Changed.Connected then Changed:Disconnect() end
        if BeginConnection.Connected then BeginConnection:Disconnect() end
    end)
    return function()
        Dragging = false
        if Changed and Changed.Connected then Changed:Disconnect() end
        if BeginConnection.Connected then BeginConnection:Disconnect() end
        if MoveConnection.Connected then MoveConnection:Disconnect() end
        local Index = table.find(Library.Signals, MoveConnection)
        if Index then table.remove(Library.Signals, Index) end
    end
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed

    DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = (Input.Position - StartPos) / Library.DPIScale
            local View = ScreenGui.AbsoluteSize / Library.DPIScale
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, math.min(Library.OriginalMinSize.X, View.X - 16), math.max(1, View.X - 16)),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, math.min(Library.OriginalMinSize.Y, View.Y - 16), math.max(1, View.Y - 16))
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end))
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

function Library:SnapFrame(Frame)
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
        for _, Target in Targets do
            local Gap = math.abs(Value - Target)
            if Gap <= Distance and Gap < Delta then Best, Delta = Target, Gap end
        end
        return Best
    end
    local X, Y = Closest(Position.X, TargetsX), Closest(Position.Y, TargetsY)
    -- Frame.Position offsets are parent-space pixels; its own UIScale scales size, not Position.
    Frame.Position = UDim2.new(Frame.Position.X.Scale, Frame.Position.X.Offset + X - Position.X, Frame.Position.Y.Scale, Frame.Position.Y.Offset + Y - Position.Y)
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
    local Valid, Error = Library:ValidateLayout(Data)
    if not Valid then return false, Error end
    Library.LayoutRestoring = true
    local Ok, Err = pcall(function()
        local Main = Data.Main
        if Library.LayoutMain and Main then
            if Main.Size then Library.LayoutMain.Size = UnpackUDim2(Main.Size) end
            if Main.Position then Library.LayoutMain.Position = UnpackUDim2(Main.Position) end
            Library:SnapFrame(Library.LayoutMain)
            if Library.Window then Library.Window:ApplyLayout() end
        end
    end)
    Library.LayoutRestoring = false
    if not Ok then return false, tostring(Err) end
    return true
end
function Library:ResetLayout()
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
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
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

function Library:AddDraggableButton(Text: string, Func, ExcludeScaling: boolean?, ExcludeDragging: boolean?)
    local Table = {}

    local Button: TextButton = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local DragThreshold = if ExcludeDragging then 0.25 else math.huge
    local PressConnection
    Button.Destroying:Once(function()
        if PressConnection then PressConnection:Disconnect(); PressConnection = nil end
    end)
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        local Start = tick()

        if PressConnection then PressConnection:Disconnect() end
        PressConnection = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            if PressConnection then PressConnection:Disconnect(); PressConnection = nil end
            if tick() - Start <= DragThreshold and not Library.Unloaded and Button.Parent then
                Library:SafeCallback(Func, Table)
            end
        end)
    end)

    Library:MakeDraggable(Button, Button, true)

    Table.Button = Button

    function Table:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end
    Table:SetText(Text)

    function Table:SetVisible(Visible) Button.Visible = Visible == true end
    function Table:Destroy() Button:Destroy() end
    return Table
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)
    return Holder, Container
end

--// Watermark \\--
function Library:AddWatermark(Info)
    local Segments = typeof(Info) == "table" and (Info.Segments or (Info.Text ~= nil and { Info } or Info)) or { { Text = tostring(Info or "") } }
    local Position = typeof(Info) == "table" and Info.Position or nil
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = Position or UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 20,
        Parent = ScreenGui,
    })
    Library:AddOutline(Holder)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Holder }))
    table.insert(Library.Scales, New("UIScale", { Parent = Holder }))
    New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = Holder })
    New("UIPadding", { PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 5), Parent = Holder })
    local DragCleanup = Library:MakeDraggable(Holder, Holder, true)
    local Watermark = { Holder = Holder, Cells = {}, Destroyed = false, DragCleanup = DragCleanup, RefreshTask = nil }
    local function Escape(Text) return tostring(Text or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") end
    local function Build(Segment, Index)
        Segment = typeof(Segment) == "table" and Segment or { Text = Segment }
        if Index > 1 then New("Frame", { BackgroundColor3 = "OutlineColor", LayoutOrder = Index * 2 - 1, Size = UDim2.fromOffset(1, 14), ZIndex = 21, Parent = Holder }) end
        local Cell = New("Frame", { AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, LayoutOrder = Index * 2, Size = UDim2.fromOffset(0, 18), ZIndex = 21, Parent = Holder })
        New("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = Cell })
        local PlayerValue = Segment.Player
        local UserId = typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") and PlayerValue.UserId or typeof(PlayerValue) == "number" and PlayerValue or Segment.PlayerCard and LocalPlayer.UserId
        if UserId then local Avatar = New("ImageLabel", { BackgroundTransparency = 1, Image = "rbxthumb://type=AvatarBust&id=" .. tostring(UserId) .. "&w=48&h=48", Position = UDim2.fromOffset(0, 1), Size = UDim2.fromOffset(16, 16), ZIndex = 22, Parent = Cell }); New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar }) end
        local Getter = typeof(Segment.Text) == "function" and Segment.Text or nil
        local DefaultText = Segment.Text
        if DefaultText == nil and UserId then DefaultText = typeof(PlayerValue) == "Instance" and PlayerValue:IsA("Player") and PlayerValue.DisplayName or LocalPlayer.DisplayName end
        local Label = New("TextLabel", { AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Position = UDim2.fromOffset(UserId and 20 or 0, 0), Size = UDim2.fromOffset(0, 18), Text = Getter and "" or Escape(DefaultText), TextColor3 = Segment.Accent and "AccentColor" or "FontColor", TextSize = 13, ZIndex = 22, Parent = Cell })
        Watermark.Cells[Index] = { Frame = Cell, Label = Label, Getter = Getter }
    end
    function Watermark:SetSegments(NewSegments)
        for _, Child in Holder:GetChildren() do if Child:IsA("Frame") then Child:Destroy() end end
        table.clear(Watermark.Cells)
        Segments = NewSegments or {}
        for Index = 1, #Segments do Build(Segments[Index], Index) end
    end
    function Watermark:SetText(Index, Text)
        if typeof(Index) ~= "number" then Text, Index = Index, 1 end
        local Cell = Watermark.Cells[Index]
        if Cell then Cell.Getter = nil; Cell.Label.Text = Escape(Text) end
    end
    function Watermark:SetSegment(Index, Segment) Segments[Index] = Segment; Watermark:SetSegments(Segments) end
    function Watermark:SetVisible(Visible) Holder.Visible = Visible ~= false end
    function Watermark:Destroy()
        Watermark.Destroyed = true
        local Current = coroutine.running()
        if Watermark.RefreshTask and Watermark.RefreshTask ~= Current then task.cancel(Watermark.RefreshTask) end
        Watermark.RefreshTask = nil
        if Watermark.DragCleanup then Watermark.DragCleanup(); Watermark.DragCleanup = nil end
        if Holder.Parent then Holder:Destroy() end
    end
    Watermark:SetSegments(Segments)
    if not (typeof(Info) == "table" and Info.Refresh == false) then
        Watermark.RefreshTask = task.spawn(function()
            while Holder.Parent and not Library.Unloaded and not Watermark.Destroyed do
                if Holder.Visible then for _, Cell in Watermark.Cells do if Cell.Getter then local Ok, Value = pcall(Cell.Getter); if Ok and not Watermark.Destroyed and Cell.Label.Parent then Cell.Label.Text = Escape(Value) end end end end
                task.wait(1)
            end
        end)
    end
    Library:OnUnload(function()
        if Watermark.RefreshTask then task.cancel(Watermark.RefreshTask); Watermark.RefreshTask = nil end
    end)
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

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    Holder: GuiObject,
    Size: UDim2 | () -> (),
    Offset: { [number]: number } | () -> {},
    List: number?,
    ActiveCallback: (Active: boolean) -> ()?,
    MenuZIndex: number?
)
    local MenuZ = MenuZIndex or 10
    local Menu
    if List then
        Menu = New("ScrollingFrame", {
            AutomaticCanvasSize = List == 2 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            AutomaticSize = List == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = List == 2 and 2 or 0,
            Size = typeof(Size) == "function" and Size() or Size,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = MenuZ,
            Parent = ScreenGui,
        })
    else
        Menu = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Size = typeof(Size) == "function" and Size() or Size,
            Visible = false,
            ZIndex = MenuZ,
            Parent = ScreenGui,
        })
    end
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Menu,
        })
    )

    local Table = {
        Active = false,
        Holder = Holder,
        Menu = Menu,
        List = nil,
        Signal = nil,

        Size = Size,
    }

    if List then
        Table.List = New("UIListLayout", {
            Parent = Menu,
        })
    end

    local function PositionMenu()
        if not Holder.Parent or not Menu.Parent then return end
        local OffsetValue = typeof(Offset) == "function" and Offset() or Offset
        local Position = Holder.AbsolutePosition - ScreenGui.AbsolutePosition
        local View = ScreenGui.AbsoluteSize
        local Size = Menu.AbsoluteSize
        local X = math.clamp(Position.X + OffsetValue[1], 4, math.max(4, View.X - Size.X - 4))
        local Y = Position.Y + OffsetValue[2]
        if Y + Size.Y > View.Y - 4 then Y = Position.Y - Size.Y - 3 end
        Y = math.clamp(Y, 4, math.max(4, View.Y - Size.Y - 4))
        Menu.Position = UDim2.fromOffset(math.floor(X), math.floor(Y))
    end
    function Table:Open()
        if Table.Destroyed or Library.Unloaded or not Holder.Parent then return false end
        if CurrentMenu == Table then return true end
        if CurrentMenu then CurrentMenu:Close() end
        CurrentMenu = Table
        Table.Active = true
        Menu.Size = typeof(Table.Size) == "function" and Table.Size() or Table.Size
        if typeof(ActiveCallback) == "function" then Library:SafeCallback(ActiveCallback, true) end
        Menu.Visible = true
        PositionMenu()
        task.defer(function() if CurrentMenu == Table and Menu.Parent then PositionMenu() end end)
        Table.Signal = Holder:GetPropertyChangedSignal("AbsolutePosition"):Connect(PositionMenu)
        return true
    end

    function Table:Close()
        if CurrentMenu ~= Table then
            return
        end
        Menu.Visible = false

        if Table.Signal then
            Table.Signal:Disconnect()
            Table.Signal = nil
        end
        Table.Active = false
        CurrentMenu = nil
        if typeof(ActiveCallback) == "function" then
            Library:SafeCallback(ActiveCallback, false)
        end
    end

    function Table:Toggle()
        if Table.Active then
            Table:Close()
        else
            Table:Open()
        end
    end

    function Table:SetSize(Size)
        Table.Size = Size
        Menu.Size = typeof(Size) == "function" and Size() or Size
    end

    Holder.Destroying:Once(function()
        Table:Close()
        Table.Destroyed = true
        Menu:Destroy()
    end)
    return Table
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = "BackgroundColor",
    BorderColor3 = "OutlineColor",
    BorderSizePixel = 1,
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 20,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    if Library.Unloaded then
        return
    end

    local X, _ = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            Library.Toggled
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            TooltipLabel.Position = UDim2.fromOffset(
                Mouse.X + 14,
                Mouse.Y + 12
            )

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        local Index = table.find(Tooltips, TooltipTable)
        if Index then table.remove(Tooltips, Index) end
        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    HoverInstance.Destroying:Once(function() TooltipTable:Destroy() end)
    table.insert(Tooltips, TooltipTable)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

function Library:Unload()
    if Library.Unloaded then
        return
    end
    Library.Unloaded = true
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
    table.clear(Library.UnloadSignals)
    table.clear(Tooltips)

    ScreenGui:Destroy()

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
    FetchIcons = true
    Icons = module

    -- Top ten fixes 🚀
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

        local ParentObj = self
        local Groupbox = ParentObj.Groupbox
        local ToggleLabel = ParentObj.TextLabel

        local KeyPicker = {
            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label", "KeyPicker with the mode 'Press' can be only applied on Labels.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        KeyPicker.Mode = Info.Mode
        if KeyPicker.SyncToggleState and KeyPicker.Mode == "Toggle" then KeyPicker.Toggled = ParentObj.Value == true end
        if not table.find(Info.Modes, KeyPicker.Mode) then KeyPicker.Mode = Info.Modes[1] or "Toggle" end
        Info.Mode = KeyPicker.Mode
        local Picking = false

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers) -- Verify default modifiers

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Size = UDim2.fromOffset(18, 18),
            Text = KeyPicker.Value,
            TextSize = 14,
            Parent = ToggleLabel,
        })

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                Image = CheckIcon and CheckIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
                KeyPicker:Update()
            end)

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, nil, (Groupbox and Groupbox.IsDialog) and 9010 or nil)
        KeyPicker.Menu = MenuTable

        local ModeButtons = {}
        for _, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
                if KeyPicker.Update then
                    KeyPicker:Update()
                end
            end

            function ModeButton:Deselect()
                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            Button.MouseButton1Click:Connect(function()
                if ParentObj.Disabled or KeyPicker.Destroyed or KeyPicker.Mode == Mode then return end
                KeyPicker:SetValue({ KeyPicker.Value, Mode, KeyPicker.Modifiers })
            end)

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local X, Y = Library:GetTextBounds(
                PickerText or KeyPicker.DisplayValue,
                Picker.FontFace,
                Picker.TextSize,
                ToggleLabel.AbsoluteSize.X
            )
            Picker.Text = PickerText or KeyPicker.DisplayValue
            Picker.Size = UDim2.fromOffset((X + 9), (Y + 4))
        end

        function KeyPicker:Update()
            KeyPicker:Display()

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if Info.NoUI then return end
            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                if not Library.IsRobloxFocused or ParentObj.Disabled then return false end
                local Key = KeyPicker.Value
                if Key == "None" or Key == "Unknown" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key]) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

                KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:SetValue(Data)
            if KeyPicker.Destroyed or Library.Unloaded then return end
            assert(typeof(Data) == "table", "KeyPicker:SetValue expects { key, mode, modifiers }")
            local PreviousKey, PreviousMode = KeyPicker.Value, KeyPicker.Mode
            local PreviousModifiers = table.concat(KeyPicker.Modifiers, "\0")
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            if PreviousKey ~= KeyPicker.Value or PreviousMode ~= KeyPicker.Mode or PreviousModifiers ~= table.concat(KeyPicker.Modifiers, "\0") then
                local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
                Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
                Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
                Library:NotifyOptionChanged(KeyPicker)
            end
        end

        function KeyPicker:SetText(Text)
            KeyPicker.Text = tostring(Text or "")
            KeyPicker:Update()
        end

        local CapturedModifiers = {}
        local LastModifier
        local function Allowed(Name, Whitelist, Blacklist)
            return (#Whitelist == 0 or table.find(Whitelist, Name) ~= nil) and table.find(Blacklist, Name) == nil
        end
        local function CancelCapture()
            if Library.PickingKeybind == KeyPicker then Library.PickingKeybind = nil end
            Picking = false
            CapturedModifiers = {}
            LastModifier = nil
            if Picker.Parent and not Library.Unloaded then KeyPicker:Update() end
        end
        local function Capture(Input)
            if Input.KeyCode == Enum.KeyCode.Escape then CancelCapture(); return end
            if UserInputService:GetFocusedTextBox() then CancelCapture(); return end
            if IsModifierInput(Input) then
                local Name = ModifiersInput[Input.KeyCode]
                if Allowed(Name, KeyPicker.WhitelistedModifiers, KeyPicker.BlacklistedModifiers) then
                    LastModifier = Input.KeyCode.Name
                    if not table.find(CapturedModifiers, Name) then table.insert(CapturedModifiers, Name) end
                    KeyPicker:Display(table.concat(CapturedModifiers, " + ") .. " + ...")
                end
                return
            end
            local Name = SpecialKeysInput[Input.UserInputType]
            if not Name and Input.UserInputType == Enum.UserInputType.Keyboard then Name = Input.KeyCode.Name end
            if not Name or not Allowed(Name, KeyPicker.Whitelisted, KeyPicker.Blacklisted) then return end
            local Active = {}
            for _, Modifier in GetActiveModifiers() do
                if not Allowed(Modifier, KeyPicker.WhitelistedModifiers, KeyPicker.BlacklistedModifiers) then return end
                table.insert(Active, Modifier)
            end
            Picking = false
            Library.PickingKeybind = nil
            KeyPicker.Toggled = false
            KeyPicker:SetValue({ Name, KeyPicker.Mode, Active })
        end
        KeyPicker.CancelPicking = CancelCapture
        Picker.MouseButton1Click:Connect(function()
            if Library.PickingKeybind and Library.PickingKeybind ~= KeyPicker then Library.PickingKeybind.CancelPicking() end
            if Picking then CancelCapture(); return end
            if ParentObj.Disabled or Library.Unloaded then return end
            Picking = true
            Library.PickingKeybind = KeyPicker
            CapturedModifiers = {}
            LastModifier = nil
            KeyPicker:Display("...")
        end)
        Picker.Destroying:Once(function() Picking = false; if Library.PickingKeybind == KeyPicker then Library.PickingKeybind = nil end end)

        Picker.MouseButton2Click:Connect(function()
            if not ParentObj.Disabled and not KeyPicker.Destroyed then MenuTable:Toggle() end
        end)

        Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded or KeyPicker.Destroyed then return end
            if Picking then Capture(Input); return end
            if ParentObj.Disabled or (Library.ActiveDialog and not Picker:IsDescendantOf(Library.ActiveDialog.Holder)) then return end

            if
                KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or UserInputService:GetFocusedTextBox()
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if KeyPicker.Mode == "Toggle" then
                if HoldingKey then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            elseif KeyPicker.Mode == "Press" then
                if HoldingKey then
                    KeyPicker:DoClick()
                end
            end

            if KeyPicker.Mode == "Hold" then
                local State = KeyPicker:GetState()
                if State ~= KeyPicker.Toggled then KeyPicker.Toggled = State; KeyPicker:DoClick() end
            end
            KeyPicker:Update()
        end), Picker)

        Library:GiveSignal(UserInputService.InputEnded:Connect(function(Input)
            if Library.Unloaded or KeyPicker.Destroyed then return end
            if Picking then
                if LastModifier == Input.KeyCode.Name and Allowed(LastModifier, KeyPicker.Whitelisted, KeyPicker.Blacklisted) then
                    Picking = false
                    Library.PickingKeybind = nil
                    KeyPicker:SetValue({ LastModifier, KeyPicker.Mode, {} })
                end
                return
            end

            if
                KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
            then
                return
            end

            if KeyPicker.Mode == "Hold" then
                local State = KeyPicker:GetState()
                if State ~= KeyPicker.Toggled then KeyPicker.Toggled = State; KeyPicker:DoClick() end
            end
            KeyPicker:Update()
        end), Picker)

        local ValidDefault = KeyPicker.Value == "None" or SpecialKeys[KeyPicker.Value] ~= nil
        if not ValidDefault then local Ok, Key = pcall(function() return Enum.KeyCode[KeyPicker.Value] end); ValidDefault = Ok and Key ~= nil end
        if not ValidDefault then KeyPicker.Value = "Unknown" end
        KeyPicker.ParentObj = ParentObj
        KeyPicker.Holder = Picker
        KeyPicker.KeybindHolder = KeybindsToggle.Holder
        KeyPicker.KeybindToggle = KeybindsToggle
        KeyPicker.DisplayValue = #KeyPicker.Modifiers > 0 and (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value) or KeyPicker.Value
        KeyPicker:Update()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})
        KeyPicker.Idx = Idx

        Options[Idx] = Library:TrackElement(KeyPicker, Groupbox)

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

        local ParentObj = self
        local Groupbox = ParentObj.Groupbox
        local ToggleLabel = ParentObj.TextLabel

        local ColorPicker = {
            Value = Info.Default,

            Transparency = Info.Transparency or 0,
            Title = Info.Title,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Type = "ColorPicker",
        }
        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = ColorPicker.Value:ToHSV()

        local Holder = New("TextButton", {
            BackgroundColor3 = ColorPicker.Value,
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value),
            BorderSizePixel = 1,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = ToggleLabel,
        })

        local HolderTransparency = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - ColorPicker.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Size = UDim2.fromScale(1, 1),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = Holder,
        })

        --// Color Menu \\--
        local ColorMenu = Library:AddContextMenu(
            Holder,
            UDim2.fromOffset(Info.Transparency and 256 or 234, 0),
            function()
                return { 0.5, Holder.AbsoluteSize.Y + 1.5 }
            end,
            1,
            nil,
            (Groupbox and Groupbox.IsDialog) and 9010 or nil
        )
        ColorMenu.List.Padding = UDim.new(0, 8)
        ColorPicker.ColorMenu = ColorMenu

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 6),
            Parent = ColorMenu.Menu,
        })

        if typeof(ColorPicker.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = ColorPicker.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ColorMenu.Menu,
            })
        end

        local ColorHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            Parent = ColorHolder,
        })

        --// Sat Map
        local SatVipMap = New("ImageButton", {
            BackgroundColor3 = ColorPicker.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(200, 200),
            Parent = ColorHolder,
        })

        local SatVibCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = SatVipMap,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SatVibCursor,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Parent = SatVibCursor,
        })

        --// Hue
        local HueSelector = New("TextButton", {
            Size = UDim2.fromOffset(16, 200),
            Text = "",
            Parent = ColorHolder,
        })
        New("UIGradient", {
            Color = ColorSequence.new(HueSequenceTable),
            Rotation = 90,
            Parent = HueSelector,
        })

        local HueCursor = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, ColorPicker.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = HueSelector,
        })

        --// Alpha
        local TransparencySelector, TransparencyColor, TransparencyCursor
        if Info.Transparency then
            TransparencySelector = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(16, 200),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = ColorHolder,
            })

            TransparencyColor = New("Frame", {
                BackgroundColor3 = ColorPicker.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = TransparencySelector,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
                Parent = TransparencyColor,
            })

            TransparencyCursor = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, ColorPicker.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = TransparencySelector,
            })
        end

        local InfoHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ColorMenu.Menu,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 8),
            Parent = InfoHolder,
        })

        local HueBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = InfoHolder,
        })

        local RgbBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = InfoHolder,
        })

        --// Context Menu \\--
        local ContextMenu = Library:AddContextMenu(Holder, UDim2.fromOffset(93, 0), function()
            return { Holder.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, nil, (Groupbox and Groupbox.IsDialog) and 9010 or nil)
        ColorPicker.ContextMenu = ContextMenu
        do
            local function CreateButton(Text, Func)
                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 21),
                    Text = Text,
                    TextSize = 14,
                    Parent = ContextMenu.Menu,
                })

                Button.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Func)
                    ContextMenu:Close()
                end)
            end

            CreateButton("Copy color", function()
                Library.CopiedColor = { ColorPicker.Value, ColorPicker.Transparency }
            end)

            ColorPicker.SetValueRGB = function(...) end --// make luau lsp shut up
            CreateButton("Paste color", function()
                if Library.CopiedColor then ColorPicker:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2]) end
            end)

            if setclipboard then
                CreateButton("Copy Hex", function()
                    setclipboard(tostring(ColorPicker.Value:ToHex()))
                end)
                CreateButton("Copy RGB", function()
                    setclipboard(table.concat({
                        math.floor(ColorPicker.Value.R * 255),
                        math.floor(ColorPicker.Value.G * 255),
                        math.floor(ColorPicker.Value.B * 255),
                    }, ", "))
                end)
            end
        end

        --// End \\--

        function ColorPicker:SetHSVFromRGB(Color)
            ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
        end

        function ColorPicker:Display()
            if Library.Unloaded then
                return
            end

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib)

            Holder.BackgroundColor3 = ColorPicker.Value
            Holder.BorderColor3 = Library:GetDarkerColor(ColorPicker.Value)
            HolderTransparency.ImageTransparency = (1 - ColorPicker.Transparency)

            SatVipMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1)
            if TransparencyColor then
                TransparencyColor.BackgroundColor3 = ColorPicker.Value
            end

            SatVibCursor.Position = UDim2.fromScale(ColorPicker.Sat, 1 - ColorPicker.Vib)
            HueCursor.Position = UDim2.fromScale(0.5, ColorPicker.Hue)
            if TransparencyCursor then
                TransparencyCursor.Position = UDim2.fromScale(0.5, ColorPicker.Transparency)
            end

            HueBox.Text = "#" .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({
                math.floor(ColorPicker.Value.R * 255),
                math.floor(ColorPicker.Value.G * 255),
                math.floor(ColorPicker.Value.B * 255),
            }, ", ")
        end

        function ColorPicker:Update()
            ColorPicker:Display()

            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value)
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value)
            Library:NotifyOptionChanged(ColorPicker)
        end

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func
        end

        function ColorPicker:SetValue(HSV, Transparency)
            if ColorPicker.Destroyed or Library.Unloaded then return end
            if typeof(HSV) == "Color3" then
                ColorPicker:SetValueRGB(HSV, Transparency)
                return
            end

            assert(typeof(HSV) == "table" and IsFinite(HSV[1]) and IsFinite(HSV[2]) and IsFinite(HSV[3]), "Expected finite HSV components")
            local Color = Color3.fromHSV(HSV[1] % 1, math.clamp(HSV[2], 0, 1), math.clamp(HSV[3], 0, 1))
            if Info.Transparency ~= nil and Transparency ~= nil then
                assert(IsFinite(Transparency), "Transparency must be finite")
                ColorPicker.Transparency = math.clamp(Transparency, 0, 1)
            end
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        function ColorPicker:SetValueRGB(Color, Transparency)
            if ColorPicker.Destroyed or Library.Unloaded then return end
            assert(typeof(Color) == "Color3", "Expected Color3")
            if Info.Transparency ~= nil and Transparency ~= nil then
                assert(IsFinite(Transparency), "Transparency must be finite")
                ColorPicker.Transparency = math.clamp(Transparency, 0, 1)
            end
            ColorPicker:SetHSVFromRGB(Color)
            ColorPicker:Update()
        end

        Holder.MouseButton1Click:Connect(ColorMenu.Toggle)
        Holder.MouseButton2Click:Connect(ContextMenu.Toggle)

        SatVipMap.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and Holder.Parent and not Library.Unloaded do
                local MinX = SatVipMap.AbsolutePosition.X
                local MaxX = MinX + SatVipMap.AbsoluteSize.X
                local LocationX = math.clamp(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.X or Mouse.X, MinX, MaxX)

                local MinY = SatVipMap.AbsolutePosition.Y
                local MaxY = MinY + SatVipMap.AbsoluteSize.Y
                local LocationY = math.clamp(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.Y or Mouse.Y, MinY, MaxY)

                local OldSat = ColorPicker.Sat
                local OldVib = ColorPicker.Vib
                ColorPicker.Sat = (LocationX - MinX) / (MaxX - MinX)
                ColorPicker.Vib = 1 - ((LocationY - MinY) / (MaxY - MinY))

                if ColorPicker.Sat ~= OldSat or ColorPicker.Vib ~= OldVib then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        HueSelector.InputBegan:Connect(function(Input: InputObject)
            while IsDragInput(Input) and Holder.Parent and not Library.Unloaded do
                local Min = HueSelector.AbsolutePosition.Y
                local Max = Min + HueSelector.AbsoluteSize.Y
                local Location = math.clamp(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.Y or Mouse.Y, Min, Max)

                local OldHue = ColorPicker.Hue
                ColorPicker.Hue = (Location - Min) / (Max - Min)

                if ColorPicker.Hue ~= OldHue then
                    ColorPicker:Update()
                end

                RunService.RenderStepped:Wait()
            end
        end)
        if TransparencySelector then
            TransparencySelector.InputBegan:Connect(function(Input: InputObject)
                while IsDragInput(Input) and Holder.Parent and not Library.Unloaded do
                    local Min = TransparencySelector.AbsolutePosition.Y
                    local Max = TransparencySelector.AbsolutePosition.Y + TransparencySelector.AbsoluteSize.Y
                    local Location = math.clamp(Input.UserInputType == Enum.UserInputType.Touch and Input.Position.Y or Mouse.Y, Min, Max)

                    local OldTransparency = ColorPicker.Transparency
                    ColorPicker.Transparency = (Location - Min) / (Max - Min)

                    if ColorPicker.Transparency ~= OldTransparency then
                        ColorPicker:Update()
                    end

                    RunService.RenderStepped:Wait()
                end
            end)
        end

        HueBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local Success, Color = pcall(Color3.fromHex, HueBox.Text)
            if Success and typeof(Color) == "Color3" then
                ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color:ToHSV()
            end

            ColorPicker:Update()
        end)
        RgbBox.FocusLost:Connect(function(Enter)
            if not Enter then
                return
            end

            local R, G, B = RgbBox.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if R and G and B then
                ColorPicker:SetHSVFromRGB(Color3.fromRGB(R, G, B))
            end

            ColorPicker:Update()
        end)

        ColorPicker:Display()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, ColorPicker)
        end

        ColorPicker.ParentObj = ParentObj
        ColorPicker.Holder = Holder
        ColorPicker.DefaultTransparency = ColorPicker.Transparency
        ColorPicker.Default = ColorPicker.Value
        ColorPicker.Idx = Idx

        Options[Idx] = Library:TrackElement(ColorPicker, Groupbox)

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
        local Text
        local MarginTop = 0
        local MarginBottom = 0
        local AccentColor = false

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
            AccentColor = Params.AccentColor or false
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            
            local BoldFont = Font.new(Library.Scheme.Font.Family, Enum.FontWeight.Bold)

            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = string.upper(Text),
                TextSize = 13,
                FontFace = BoldFont,
                TextTransparency = AccentColor and 0 or 0.35,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            
            if Library.Registry[TextLabel] then
                Library.Registry[TextLabel].FontFace = nil
            end

            if AccentColor then
                TextLabel.TextColor3 = Library.Scheme.AccentColor
                Library.Registry[TextLabel].TextColor3 = "AccentColor"
            end

            local X, _ = Library:GetTextBounds(string.upper(Text), BoldFont, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            local SizeX = X // 2 + 12

            
            local LeftLine = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = AccentColor and Library.Scheme.AccentColor or "MainColor",
                BackgroundTransparency = AccentColor and 0.7 or 0,
                BorderColor3 = AccentColor and Library.Scheme.AccentColor or "OutlineColor",
                BorderSizePixel = AccentColor and 0 or 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            if AccentColor then
                Library.Registry[LeftLine] = { BackgroundColor3 = "AccentColor", BorderColor3 = "AccentColor" }
            end

            
            local RightLine = New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = AccentColor and Library.Scheme.AccentColor or "MainColor",
                BackgroundTransparency = AccentColor and 0.7 or 0,
                BorderColor3 = AccentColor and Library.Scheme.AccentColor or "OutlineColor",
                BorderSizePixel = AccentColor and 0 or 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            if AccentColor then
                Library.Registry[RightLine] = { BackgroundColor3 = "AccentColor", BorderColor3 = "AccentColor" }
            end
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        table.insert(Groupbox.Elements, {
            Holder = Holder,
            Type = "Divider",
        })
    end

    function Funcs:AddLabel(...)
        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = Params.Visible ~= false
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Visible = Label.Visible,
            Parent = Container,
        })

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetSize(Size: number)
            assert(IsFinite(Size) and Size > 0, "Label size must be positive")
            TextLabel.TextSize = Size
            Label:SetText(Label.Text)
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            if Label.DoesWrap then
                local _, Y =
                    Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
                TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
            end

            Groupbox:Resize()
        end

        if Label.DoesWrap then
            local _, Y =
                Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)

            local Last = TextLabel.AbsoluteSize
            TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                local _, Y =
                    Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
                TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)

                Last = TextLabel.AbsoluteSize
                Groupbox:Resize()
            end)
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        Label.Groupbox = Groupbox
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Idx = Data.Idx
        Label.Holder = TextLabel
        Library:TrackElement(Label, Groupbox)
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        return Label
    end

    function Funcs:AddButton(...)
        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = Params.Visible ~= false
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Tween = nil,
            Type = "Button",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = 0.4,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            return Base, Stroke
        end

        local function InitEvents(Button)
            Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
            end)
            Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
            end)

            Button.Base.MouseButton1Click:Connect(function()
                if Library.Unloaded or Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    Button.Base.Text = "Are you sure?"
                    Button.Base.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Base].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Base.Text = Button.Text
                    Button.Base.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Base].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Clicked and not Library.Unloaded and not Button.Disabled and Button.Base.Parent then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,

                Tween = nil,
                Type = "SubButton",
            }

            SubButton.Idx = Info.Idx
            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            SubButton.Holder = SubButton.Base
            Library:TrackElement(SubButton, Groupbox)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor
                SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Holder.Visible = Button.Visible or SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Base.Text = Text
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            if SubButton.Risky then
                SubButton.Base.TextColor3 = Library.Scheme.RedColor
                Library.Registry[SubButton.Base].TextColor3 = "RedColor"
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Button.Base.Visible = Button.Visible
            Holder.Visible = Button.Visible or (Button.SubButton and Button.SubButton.Visible) or false
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Base.Text = Text
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        if Button.Risky then
            Button.Base.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Button.Base].TextColor3 = "RedColor"
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Idx = Info.Idx
        Button.Holder = Holder
        Library:TrackElement(Button, Groupbox)
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Addons = {},

            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            Image = CheckIcon and CheckIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:SetValue(Value)
            assert(typeof(Value) == "boolean", "Toggle value must be boolean")
            if Toggle.Destroyed or Library.Unloaded or Toggle.Value == Value then return false end
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()
            if not Toggle.Disabled then
                Library:SafeCallback(Toggle.Callback, Toggle.Value)
                Library:SafeCallback(Toggle.Changed, Toggle.Value)
            Library:NotifyOptionChanged(Toggle)
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end)

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        Toggle.Groupbox = Groupbox
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value
        Toggle.Idx = Idx

        Toggles[Idx] = Library:TrackElement(Toggle, Groupbox)

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,
            Addons = {},

            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:SetValue(Value)
            assert(typeof(Value) == "boolean", "Toggle value must be boolean")
            if Toggle.Destroyed or Library.Unloaded or Toggle.Value == Value then return false end
            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()
            if not Toggle.Disabled then
                Library:SafeCallback(Toggle.Callback, Toggle.Value)
                Library:SafeCallback(Toggle.Changed, Toggle.Value)
            Library:NotifyOptionChanged(Toggle)
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end)

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        Toggle.Groupbox = Groupbox
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value
        Toggle.Idx = Idx

        Toggles[Idx] = Library:TrackElement(Toggle, Groupbox)

        return Toggle
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
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

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

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
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

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Input.VerifyValue) == "function" and Text ~= Input.EmptyReset then
                local Ok, Accepted = pcall(Input.VerifyValue, Text)
                if not Ok or Accepted ~= true then Text = Input.EmptyReset end
            end
            if Text == Input.Value then Box.Text = Text; return end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Library:SafeCallback(Input.Callback, Input.Value)
                Library:SafeCallback(Input.Changed, Input.Value)
            Library:NotifyOptionChanged(Input)
            end
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

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

        Groupbox:Resize()

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
        Info.Default = math.clamp(Round(tonumber(Info.Default) or Info.Min, Info.Rounding), Info.Min, Info.Max)

        local Groupbox = self
        local Container = Groupbox.Container

        local Slider = {
            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Compact and 13 or 31),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        if not Info.Compact then
            SliderLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = Slider.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 13),
            Text = "",
            Parent = Holder,
        })

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            Parent = Bar,
        })

        local DisplayLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            Parent = Bar,
        })
        New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = "DarkColor",
            LineJoinMode = Enum.LineJoinMode.Miter,
            Parent = DisplayLabel,
        })

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or 0

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local CustomDisplayText = nil
            if Info.FormatDisplayValue then
                CustomDisplayText = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if CustomDisplayText then
                DisplayLabel.Text = tostring(CustomDisplayText)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local X = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            Fill.Size = UDim2.fromScale(X, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(IsFinite(Value) and Value > Slider.Min, "Max must be finite and greater than Min")
            Slider.Max = Value
            Slider:SetValue(Slider.Value)
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(IsFinite(Value) and Value < Slider.Max, "Min must be finite and less than Max")
            Slider.Min = Value
            Slider:SetValue(Slider.Value)
            Slider:Display()
        end

        function Slider:SetValue(Value)
            local Num = tonumber(Value)
            if not IsFinite(Num) or Slider.Destroyed or Library.Unloaded then return false end
            Num = math.clamp(Round(Num, Slider.Rounding), Slider.Min, Slider.Max)
            if Num == Slider.Value then return false end
            Slider.Value = Num
            Slider:Display()
            if not Slider.Disabled then
                Library:SafeCallback(Slider.Callback, Num)
                Library:SafeCallback(Slider.Changed, Num)
            Library:NotifyOptionChanged(Slider)
            end
            return true
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        Bar.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) or Slider.Disabled then return end
            local Sides = (Groupbox.Tab and Groupbox.Tab.Sides) or Groupbox.Sides or {}
            local Previous = {}
            for _, Side in Sides do Previous[Side] = Side.ScrollingEnabled; Side.ScrollingEnabled = false end
            local Ok, Err = pcall(function()
                while IsDragInput(Input) and Holder.Parent and not Library.Unloaded and not Slider.Disabled do
                    local X = Input.UserInputType == Enum.UserInputType.Touch and Input.Position.X or Mouse.X
                    local Width = Bar.AbsoluteSize.X
                    if Width > 0 then
                        local Scale = math.clamp((X - Bar.AbsolutePosition.X) / Width, 0, 1)
                        Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * Scale)
                    end
                    RunService.RenderStepped:Wait()
                end
            end)
            for Side, Enabled in Previous do if Side.Parent then Side.ScrollingEnabled = Enabled end end
            if not Ok then warn(Err) end
        end)

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value
        Slider.Idx = Idx

        Options[Idx] = Library:TrackElement(Slider, Groupbox)

        return Slider
    end

    function Funcs:AddDropdown(Idx, Info)
        Info = Library:Validate(Info, Templates.Dropdown)
        local Groupbox = self
        local Priority = Info.Priority == true
        local Multi = Info.Multi == true and not Priority
        if Info.SpecialType == "Player" then
            Info.Values = GetPlayers(Info.ExcludeLocalPlayer)
            Info.AllowNull = true
        elseif Info.SpecialType == "Team" then
            Info.Values = GetTeams()
            Info.AllowNull = true
        end
        local function Unique(Values)
            assert(typeof(Values) == "table", "Dropdown values must be an array")
            local Result, Seen = {}, {}
            for _, Value in ipairs(Values) do
                assert(typeof(Value) ~= "number" or IsFinite(Value), "Dropdown values must be finite")
                if not Seen[Value] then Seen[Value] = true; table.insert(Result, Value) end
            end
            return Result
        end
        local Dropdown = {
            Idx = Idx, Type = Priority and "PriorityDropdown" or "Dropdown", Priority = Priority,
            Text = typeof(Info.Text) == "string" and Info.Text or nil,
            Values = Unique(Info.Values), DisabledValues = Unique(Info.DisabledValues), Multi = Multi,
            Value = (Multi or Priority) and {} or nil,
            DefaultValues = table.clone(Info.Values),
            FormatListValue = Info.FormatListValue, Callback = Info.Callback, Changed = Info.Changed,
            Tooltip = Info.Tooltip, DisabledTooltip = Info.DisabledTooltip,
            Disabled = Info.Disabled == true, Visible = Info.Visible ~= false,
            SpecialType = Info.SpecialType, ExcludeLocalPlayer = Info.ExcludeLocalPlayer,
            Expandable = Info.Expandable == true,
            ExpandColumns = math.clamp(math.floor(tonumber(Info.ExpandColumns) or 2), 1, 6),
        }
        local Holder = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, Dropdown.Text and 39 or 24), Visible = Dropdown.Visible, Parent = Groupbox.Container })
        Dropdown.Holder = Holder
        local Label = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Text = Dropdown.Text or "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Visible = Dropdown.Text ~= nil, Parent = Holder })
        local Display = New("TextButton", { Active = not Dropdown.Disabled, AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor", BorderSizePixel = 1, Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 24), Text = "", Parent = Holder })
        local DisplayLabel = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, Dropdown.Expandable and -54 or -30, 1, 0), Text = "---", TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = Display })
        local Arrow = New("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0), Size = UDim2.fromOffset(16, 16), Image = ArrowIcon and ArrowIcon.Url or "", ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero, ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero, ImageColor3 = "FontColor", ImageTransparency = 0.4, Parent = Display })
        local ExpandButton = New("TextButton", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Position = UDim2.new(1, -22, 0.5, 0), Size = UDim2.fromOffset(24, 24), Text = "+", TextSize = 16, Visible = Dropdown.Expandable, Parent = Display })
        local SearchBox
        local ExpandedBackdrop, ExpandedList, ExpandedSearch, ExpandedCount
        local ItemsFrame, ResultLabel
        local Menu = Library:AddContextMenu(Display, UDim2.fromOffset(160, 0), function()
            return { 0, Display.AbsoluteSize.Y + 3 }
        end, 2, function(Active)
            Arrow.Rotation = Active and 180 or 0
            DisplayLabel.Visible = not (Active and SearchBox)
            if SearchBox then SearchBox.Visible = Active; if not Active then SearchBox.Text = "" end end
        end, Groupbox.IsDialog and 9010 or nil)
        Dropdown.Menu = Menu
        if Info.Searchable then
            SearchBox = New("TextBox", { BackgroundTransparency = 1, ClearTextOnFocus = false, PlaceholderText = "Search...", Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -34, 1, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Visible = false, Parent = Display })
        end
        Dropdown.SearchBox = SearchBox
        local function Format(Value, Formatter)
            if typeof(Formatter) == "function" then
                local Ok, Text = pcall(Formatter, Value)
                if Ok and Text ~= nil then return tostring(Text) end
            end
            return tostring(Value)
        end
        local function Same(Left, Right)
            if typeof(Left) ~= "table" or typeof(Right) ~= "table" then return Left == Right end
            for Key, Value in Left do if Right[Key] ~= Value then return false end end
            for Key, Value in Right do if Left[Key] ~= Value then return false end end
            return true
        end
        local function Normalize(Value)
            if Priority then
                local Order, Seen = {}, {}
                for _, Item in typeof(Value) == "table" and Value or {} do
                    if table.find(Dropdown.Values, Item) and not Seen[Item] then Seen[Item] = true; table.insert(Order, Item) end
                end
                for _, Item in Dropdown.Values do if not Seen[Item] then Seen[Item] = true; table.insert(Order, Item) end end
                return Order
            elseif Multi then
                local Selected = {}
                if typeof(Value) == "string" then Value = Value ~= "" and { Value } or {} end
                if Value ~= nil and typeof(Value) ~= "table" then return nil end
                for Key, Item in Value or {} do
                    local Candidate = typeof(Item) == "boolean" and Key or Item
                    if Item ~= false and table.find(Dropdown.Values, Candidate) then Selected[Candidate] = true end
                end
                return Selected
            end
            if Value ~= nil and not table.find(Dropdown.Values, Value) then return Dropdown.Value end
            return Value
        end
        local function CountSelected()
            if Priority then return #Dropdown.Value end
            if Multi then return GetTableSize(Dropdown.Value) end
            return Dropdown.Value ~= nil and 1 or 0
        end
        local function Emit()
            Library:UpdateDependencyBoxes()
            if not Dropdown.Disabled then
                Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
                Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
                Library:NotifyOptionChanged(Dropdown)
            end
        end
        function Dropdown:Display()
            if Dropdown.Destroyed or Library.Unloaded then return end
            local First
            if Priority then First = Dropdown.Value[1]
            elseif Multi then
                for _, Value in Dropdown.Values do if Dropdown.Value[Value] then First = Value; break end end
            else First = Dropdown.Value end
            local Count = CountSelected()
            local Text = First ~= nil and Format(First, Info.FormatDisplayValue) or "---"
            if Count > 1 then Text ..= " +" .. tostring(Count - 1) end
            DisplayLabel.Text = Text
        end
        function Dropdown:UpdateColors()
            if Dropdown.Destroyed or Library.Unloaded then return end
            Label.TextTransparency = Dropdown.Disabled and 0.65 or 0
            DisplayLabel.TextTransparency = Dropdown.Disabled and 0.65 or 0
            Arrow.ImageTransparency = Dropdown.Disabled and 0.75 or 0.4
            ExpandButton.TextTransparency = Dropdown.Disabled and 0.65 or 0
            Display.Active = not Dropdown.Disabled
        end
        local function Results(Filter)
            local Rows = {}
            for Rank, Value in Priority and Dropdown.Value or Dropdown.Values do
                local Text = Format(Value, Info.FormatListValue)
                local Score = SearchScore(Text, Filter)
                if Score > 0 then table.insert(Rows, { Value = Value, Text = Text, Rank = Rank, Score = Score }) end
            end
            if not Priority and Filter ~= "" then
                table.sort(Rows, function(A, B) if A.Score == B.Score then return A.Rank < B.Rank end; return A.Score > B.Score end)
            end
            return Rows
        end
        local function Render(Parent, Filter, CountLabel)
            for _, Child in Parent:GetChildren() do if Child:IsA("GuiObject") then Child:Destroy() end end
            local Rows = Results(Filter)
            CountLabel.Text = #Rows == 0 and "No results" or string.format("%d result%s%s", #Rows, #Rows == 1 and "" or "s", Multi and (" · " .. CountSelected() .. " selected") or "")
            for Index, Entry in Rows do
                local Value = Entry.Value
                local Disabled = Dropdown.Disabled or table.find(Dropdown.DisabledValues, Value) ~= nil
                local Selected = not Priority and (Multi and Dropdown.Value[Value] == true or (not Multi and Dropdown.Value == Value))
                local Row = New("TextButton", { BackgroundColor3 = Selected and "AccentColor" or "MainColor", BackgroundTransparency = Selected and 0.8 or 1, Size = UDim2.new(1, 0, 0, 24), Text = "", LayoutOrder = Index, Active = not Disabled, Parent = Parent })
                New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, Priority and -60 or -16, 1, 0), Text = (Priority and (Entry.Rank .. ". ") or "") .. Entry.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, TextTransparency = Disabled and 0.65 or (Selected and 0 or 0.2), Parent = Row })
                Row.MouseEnter:Connect(function() if not Disabled then Row.BackgroundTransparency = Selected and 0.7 or 0.3 end end)
                Row.MouseLeave:Connect(function() Row.BackgroundTransparency = Selected and 0.8 or 1 end)
                if Priority then
                    for _, Move in { { "^", -1, -48 }, { "v", 1, -24 } } do
                        local Button = New("TextButton", { BackgroundTransparency = 1, Position = UDim2.new(1, Move[3], 0, 0), Size = UDim2.fromOffset(24, 24), Text = Move[1], TextSize = 14, TextTransparency = Disabled and 0.65 or 0, Parent = Row })
                        Button.MouseButton1Click:Connect(function() if not Disabled then Dropdown:Move(Value, Move[2]) end end)
                    end
                else
                    Row.MouseButton1Click:Connect(function()
                        if Dropdown.Destroyed or Dropdown.Disabled or table.find(Dropdown.DisabledValues, Value) then return end
                        if Multi then
                            local Next = table.clone(Dropdown.Value)
                            Next[Value] = not Next[Value] and true or nil
                            Dropdown:SetValue(Next)
                        else
                            local Next = Value
                            if Dropdown.Value == Value and Info.AllowNull then Next = nil end
                            Dropdown:SetValue(Next)
                            Dropdown:Collapse()
                        end
                    end)
                end
            end
            return #Rows
        end
        function Dropdown:RecalculateListSize(Count)
            Count = Count or #Results(SearchBox and SearchBox.Text:lower() or "")
            local VisibleRows = math.clamp(math.floor(tonumber(Info.MaxVisibleDropdownItems) or 8), 1, 30)
            local Height = math.min(Count, VisibleRows) * 24 + 22 + (Multi and Info.SelectAllButtons ~= false and 26 or 0)
            Menu:SetSize(function()
                local View = ScreenGui.AbsoluteSize / Library.DPIScale
                return UDim2.fromOffset(math.min(math.max(100, Display.AbsoluteSize.X / Library.DPIScale), math.max(24, View.X - 16)), math.min(Height, math.max(24, View.Y - 16)))
            end)
        end
        function Dropdown:BuildDropdownList()
            if Dropdown.Destroyed or Library.Unloaded then return end
            if ItemsFrame then
                local Count = Render(ItemsFrame, SearchBox and SearchBox.Text:lower() or "", ResultLabel)
                Dropdown:RecalculateListSize(Count)
            end
            if ExpandedList then Render(ExpandedList, ExpandedSearch.Text:lower(), ExpandedCount) end
        end
        function Dropdown:SetValue(Value)
            if Dropdown.Destroyed or Library.Unloaded then return false end
            local Next = Normalize(Value)
            if Multi and not Next then return false end
            local Empty = Multi and next(Next) == nil or (not Multi and not Priority and Next == nil)
            if Empty and not Info.AllowNull and CountSelected() > 0 then return false end
            if Same(Next, Dropdown.Value) then return false end
            Dropdown.Value = Next
            if Priority then Dropdown.OrderedValue = Next end
            Dropdown:Display()
            Dropdown:BuildDropdownList()
            Emit()
            return true
        end
        function Dropdown:SetValues(Values)
            local Previous = Dropdown.Value
            Dropdown.Values = Unique(Values or {})
            if not Multi and not Priority and Previous ~= nil and not table.find(Dropdown.Values, Previous) then
                Dropdown.Value = nil
            else Dropdown.Value = Normalize(Previous) end
            if Priority then Dropdown.OrderedValue = Dropdown.Value end
            Dropdown:Display(); Dropdown:BuildDropdownList()
            if not Same(Previous, Dropdown.Value) then Emit() end
        end
        function Dropdown:AddValues(Values)
            local Next = table.clone(Dropdown.Values)
            if typeof(Values) ~= "table" then Values = { Values } end
            for _, Value in Values do table.insert(Next, Value) end
            Dropdown:SetValues(Next)
        end
        function Dropdown:GetValue()
            return typeof(Dropdown.Value) == "table" and table.clone(Dropdown.Value) or Dropdown.Value
        end
        function Dropdown:GetActiveValues()
            if not Multi then return CountSelected() end
            local Active = {}
            for _, Value in Dropdown.Values do if Dropdown.Value[Value] then table.insert(Active, Value) end end
            return Active
        end
        function Dropdown:Move(Value, Offset)
            if not Priority or Dropdown.Disabled or not IsFinite(Offset) then return false end
            local Index = table.find(Dropdown.Value, Value)
            if not Index or table.find(Dropdown.DisabledValues, Value) then return false end
            local Target = math.clamp(Index + math.floor(Offset), 1, #Dropdown.Value)
            if Target == Index or table.find(Dropdown.DisabledValues, Dropdown.Value[Target]) then return false end
            local Order = table.clone(Dropdown.Value)
            table.remove(Order, Index); table.insert(Order, Target, Value)
            return Dropdown:SetValue(Order)
        end
        local function Bulk(Action, Filter)
            if not Multi or Dropdown.Disabled or Dropdown.Destroyed then return false end
            Filter = tostring(Filter or (ExpandedSearch and ExpandedSearch.Text) or (SearchBox and SearchBox.Text) or ""):lower()
            local Next = table.clone(Dropdown.Value)
            for _, Entry in Results(Filter) do
                local Value = Entry.Value
                if not table.find(Dropdown.DisabledValues, Value) then
                    if Action == "select" then Next[Value] = true
                    elseif Action == "clear" then Next[Value] = nil
                    else Next[Value] = not Next[Value] and true or nil end
                end
            end
            return Dropdown:SetValue(Next)
        end
        function Dropdown:SelectAll(Filter) return Bulk("select", Filter) end
        function Dropdown:DeselectAll(Filter) return Bulk("clear", Filter) end
        function Dropdown:InvertSelection(Filter) return Bulk("invert", Filter) end
        local function AddToolbar(Parent, FilterGetter)
            if not Multi or Info.SelectAllButtons == false then return end
            local Toolbar = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = -2, Parent = Parent })
            New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 3), Parent = Toolbar })
            for _, Action in { { "Select", "select" }, { "Clear", "clear" }, { "Invert", "invert" } } do
                local Button = New("TextButton", { BackgroundColor3 = "MainColor", Size = UDim2.new(0.33, -2, 1, 0), Text = Action[1], TextSize = 12, Parent = Toolbar })
                Button.MouseButton1Click:Connect(function() Bulk(Action[2], FilterGetter()) end)
            end
        end
        AddToolbar(Menu.Menu, function() return SearchBox and SearchBox.Text or "" end)
        ResultLabel = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), TextSize = 12, TextTransparency = 0.4, LayoutOrder = -1, Parent = Menu.Menu })
        ItemsFrame = New("Frame", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = Menu.Menu })
        New("UIListLayout", { Parent = ItemsFrame })
        function Dropdown:Collapse()
            if Library.ActiveExpandedDropdown == Dropdown then Library.ActiveExpandedDropdown = nil end
            if ExpandedBackdrop then ExpandedBackdrop:Destroy() end
            ExpandedBackdrop, ExpandedList, ExpandedSearch, ExpandedCount = nil, nil, nil, nil
            Menu:Close()
        end
        function Dropdown:IsExpanded() return ExpandedBackdrop ~= nil end
        function Dropdown:Expand()
            if not Dropdown.Expandable or Dropdown.Disabled or not Dropdown.Visible or Dropdown.Destroyed or Library.Unloaded then return false end
            if ExpandedBackdrop then return true end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            Menu:Close()
            Library.ActiveExpandedDropdown = Dropdown
            local Z = Groupbox.IsDialog and 9020 or 200
            ExpandedBackdrop = New("TextButton", { BackgroundColor3 = "DarkColor", BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = Z, Parent = ScreenGui })
            local View = ScreenGui.AbsoluteSize / Library.DPIScale
            local Panel = New("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "BackgroundColor", Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(math.max(140, math.min(640, View.X - 24)), math.max(140, math.min(440, View.Y - 24))), Text = "", ZIndex = Z + 1, Parent = ExpandedBackdrop })
            table.insert(Library.Scales, New("UIScale", { Scale = Library.DPIScale, Parent = Panel }))
            Library:AddOutline(Panel)
            New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Panel })
            ExpandedSearch = New("TextBox", { BackgroundColor3 = "MainColor", ClearTextOnFocus = false, PlaceholderText = "Search...", Position = UDim2.fromOffset(8, 8), Size = UDim2.new(1, -48, 0, 28), TextSize = 14, Parent = Panel })
            local Close = New("TextButton", { BackgroundTransparency = 1, Position = UDim2.new(1, -36, 0, 8), Size = UDim2.fromOffset(28, 28), Text = "×", TextSize = 18, Parent = Panel })
            local Header = New("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 40), Size = UDim2.new(1, -16, 0, 50), Parent = Panel })
            New("UIListLayout", { Parent = Header })
            AddToolbar(Header, function() return ExpandedSearch and ExpandedSearch.Text or "" end)
            ExpandedCount = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), TextSize = 12, TextTransparency = 0.4, Parent = Header })
            local Top = Multi and Info.SelectAllButtons ~= false and 90 or 66
            ExpandedList = New("ScrollingFrame", { AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.fromScale(0, 0), BackgroundTransparency = 1, Position = UDim2.fromOffset(8, Top), Size = UDim2.new(1, -16, 1, -Top - 8), ScrollBarThickness = 3, ScrollBarImageColor3 = "AccentColor", Parent = Panel })
            local Columns = Priority and 1 or Dropdown.ExpandColumns
            New("UIGridLayout", { CellPadding = UDim2.fromOffset(4, 4), CellSize = UDim2.new(1 / Columns, -4, 0, 26), SortOrder = Enum.SortOrder.LayoutOrder, Parent = ExpandedList })
            ExpandedBackdrop.MouseButton1Click:Connect(function() Dropdown:Collapse() end)
            Close.MouseButton1Click:Connect(function() Dropdown:Collapse() end)
            ExpandedSearch:GetPropertyChangedSignal("Text"):Connect(function() Dropdown:BuildDropdownList() end)
            Dropdown:BuildDropdownList()
            return true
        end
        function Dropdown:ToggleExpanded()
            if Dropdown:IsExpanded() then Dropdown:Collapse(); return false end
            return Dropdown:Expand()
        end
        function Dropdown:SetDisabledValues(Values) Dropdown.DisabledValues = Unique(Values or {}); Dropdown:BuildDropdownList() end
        function Dropdown:AddDisabledValues(Values)
            local Next = table.clone(Dropdown.DisabledValues)
            for _, Value in typeof(Values) == "table" and Values or { Values } do table.insert(Next, Value) end
            Dropdown:SetDisabledValues(Next)
        end
        function Dropdown:SetDisabled(Value)
            Dropdown.Disabled = Value == true
            if Dropdown.TooltipTable then Dropdown.TooltipTable.Disabled = Dropdown.Disabled end
            Dropdown:Collapse(); Dropdown:UpdateColors(); Dropdown:BuildDropdownList()
        end
        function Dropdown:SetVisible(Value)
            Dropdown.Visible = Value == true; Holder.Visible = Dropdown.Visible
            if not Dropdown.Visible then Dropdown:Collapse() end
            Groupbox:Resize()
        end
        function Dropdown:SetText(Text)
            Dropdown.Text = Text
            Label.Text = Text or ""; Label.Visible = Text ~= nil
            Holder.Size = UDim2.new(1, 0, 0, Text and 39 or 24)
            Groupbox:Resize()
        end
        function Dropdown:OnChanged(Callback) Dropdown.Changed = Callback end
        function Dropdown:Destroy()
            Library:DestroyElement(Dropdown)
            local Index = table.find(Groupbox.Elements, Dropdown)
            if Index then table.remove(Groupbox.Elements, Index) end
            Groupbox:Resize()
        end
        Display.MouseButton1Click:Connect(function()
            if not Dropdown.Disabled and not Dropdown.Destroyed then
                if Dropdown:IsExpanded() then Dropdown:Collapse() else Menu:Toggle() end
            end
        end)
        ExpandButton.MouseButton1Click:Connect(function() Dropdown:Expand() end)
        if SearchBox then SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Dropdown:BuildDropdownList() end) end
        Holder.Destroying:Once(function() Dropdown:Collapse(); Menu.Menu:Destroy() end)
        if typeof(Info.Tooltip) == "string" or typeof(Info.DisabledTooltip) == "string" then
            Dropdown.TooltipTable = Library:AddTooltip(Info.Tooltip, Info.DisabledTooltip, Display)
            Dropdown.TooltipTable.Disabled = Dropdown.Disabled
        end
        local Default = Info.Default
        if not Priority then
            if typeof(Default) == "number" then Default = Dropdown.Values[Default] end
            if typeof(Default) == "table" then
                -- Legacy Default tables are arrays of values, never boolean selection sets.
                local Values = {}
                for _, Value in ipairs(Default) do if table.find(Dropdown.Values, Value) then table.insert(Values, Value) end end
                Default = Multi and Values or Values[1]
            end
        end
        Dropdown.Value = Normalize(Default)
        if Multi and Dropdown.Value == nil then Dropdown.Value = {} end
        Dropdown.OrderedValue = Priority and Dropdown.Value or nil
        Dropdown.Default = Priority and table.clone(Dropdown.Value) or {}
        if not Priority then
            for Index, Value in Dropdown.Values do
                if (Multi and Dropdown.Value[Value]) or (not Multi and Dropdown.Value == Value) then table.insert(Dropdown.Default, Index) end
            end
        end
        Dropdown:Display(); Dropdown:UpdateColors(); Dropdown:BuildDropdownList()
        table.insert(Groupbox.Elements, Dropdown)
        Options[Idx] = Library:TrackElement(Dropdown, Groupbox)
        Groupbox:Resize()
        return Dropdown
    end

    function Funcs:AddPriorityDropdown(Idx, Info)
        Info = typeof(Info) == "table" and table.clone(Info) or {}
        Info.Priority = true
        return self:AddDropdown(Idx, Info)
    end

    function Funcs:AddPlayerInfo(Idx, Info)
        Info = typeof(Idx) == "table" and Idx or Info or {}
        local Groupbox = self
        local Player = Info.Player or LocalPlayer
        local UserId = Info.UserId or (typeof(Player) == "Instance" and Player:IsA("Player") and Player.UserId) or LocalPlayer.UserId
        local Height = Info.Height or (Info.Compact and 42 or 64)
        local Holder = New("Frame", { BackgroundColor3 = "MainColor", Size = UDim2.new(1, 0, 0, Height), Visible = Info.Visible ~= false, Parent = Groupbox.Container })
        New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Holder })
        local Avatar = New("ImageLabel", { BackgroundColor3 = "OutlineColor", Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(Height - 12, Height - 12), Parent = Holder })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
        local Title = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Height + 2, 7), Size = UDim2.new(1, -Height - 8, 0, 18), RichText = false, Text = tostring(Info.Title or (typeof(Player) == "Instance" and Player.DisplayName or tostring(UserId))), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Holder })
        local Description = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Height + 2, 25), Size = UDim2.new(1, -Height - 8, 1, -28), RichText = false, Text = tostring(Info.Description or ""), TextSize = 12, TextTransparency = 0.4, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Holder })
        local Card = { Idx = typeof(Idx) ~= "table" and Idx or nil, Type = "PlayerInfo", Text = Title.Text, Holder = Holder, Avatar = Avatar, Title = Title, Description = Description, Visible = Holder.Visible }
        function Card:SetVisible(Visible) Card.Visible = Visible; Holder.Visible = Visible; Groupbox:Resize() end
        function Card:SetText(Text) Card.Text = tostring(Text or ""); Title.Text = Card.Text end
        function Card:SetDescription(Text) Description.Text = tostring(Text or "") end
        function Card:Destroy()
            local Index = table.find(Groupbox.Elements, Card)
            if Index then table.remove(Groupbox.Elements, Index) end
            if Holder.Parent then Holder:Destroy() end
            Groupbox:Resize()
        end
        task.spawn(function() local Ok, Content = pcall(Players.GetUserThumbnailAsync, Players, UserId, Info.ThumbnailType or Enum.ThumbnailType.HeadShot, Info.ThumbnailSize or Enum.ThumbnailSize.Size100x100); if Ok and Holder.Parent and not Library.Unloaded then Avatar.Image = Content end end)
        table.insert(Groupbox.Elements, Card)
        Groupbox:Resize()
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
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

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
            for Side, Enabled in ScrollState do if Side.Parent then Side.ScrollingEnabled = Enabled end end
            table.clear(ScrollState)
        end
        Holder.Destroying:Once(RestoreScrolling)
        ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in (Groupbox.Tab and Groupbox.Tab.Sides) or {} do
                if ScrollState[Side] == nil then ScrollState[Side] = Side.ScrollingEnabled end
                Side.ScrollingEnabled = false
            end
        end)

        ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            RestoreScrolling()
        end)

        ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = true
                LastMousePos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch and not Pinching then
                Dragging = true
                LastMousePos = input.Position
            end
        end)

        Library:GiveSignal(UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = false
            elseif input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end), Holder)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = Viewport.Object:GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end), Holder)

        ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end)

        Library:GiveSignal(UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end), Holder)

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
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

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
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

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
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

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

        local Groupbox = self
        local Container = Groupbox.Container

        local List = {
            Text = typeof(Info.Text) == "string" and Info.Text or nil,
            Value = Info.Multi and {} or nil,
            Items = {},
            Multi = Info.Multi,
            MaxHeight = Info.MaxHeight,
            EmptyText = Info.EmptyText,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "List",
            Idx = Idx,
        }

        local ItemRows = {}

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = List.Visible,
            Parent = Container,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Holder,
        })

        if List.Text then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 15),
                Text = List.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = 1,
                Parent = Holder,
            })
        end

        local ListFrame = New("ScrollingFrame", {
            BackgroundColor3 = "MainColor",
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, Info.MaxHeight),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = "AccentColor",
            ScrollingDirection = Enum.ScrollingDirection.Y,
            LayoutOrder = 2,
            Parent = Holder,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = ListFrame,
            })
        )
        Library:AddOutline(ListFrame)
        local _ListLayout = New("UIListLayout", {
            Padding = UDim.new(0, 1),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ListFrame,
        })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            Parent = ListFrame,
        })

        local EmptyLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Text = List.EmptyText,
            TextSize = 13,
            TextTransparency = 0.5,
            TextXAlignment = Enum.TextXAlignment.Center,
            Visible = true,
            Parent = ListFrame,
        })

        local function NormalizeItems(Items)
            assert(typeof(Items) == "table", "List items must be a table")
            local Result, Seen = {}, {}
            for Index, Item in ipairs(Items) do
                local Entry
                if typeof(Item) == "string" then Entry = { Key = Index, Display = Item }
                elseif typeof(Item) == "table" then
                    Entry = table.clone(Item)
                    Entry.Key = Entry.Key ~= nil and Entry.Key or Index
                    Entry.Display = tostring(Entry.Display or Entry.Key)
                else error("List items must be strings or tables") end
                assert((typeof(Entry.Key) == "string" or IsFinite(Entry.Key)) and not Seen[Entry.Key], "List keys must be unique strings or finite numbers")
                Seen[Entry.Key] = true
                table.insert(Result, Entry)
            end
            return Result
        end

        local function IsSelected(key)
            if List.Multi then
                return List.Value and List.Value[key] == true
            else
                return List.Value == key
            end
        end

        local function UpdateRowHighlight(key)
            local row = ItemRows[key]
            if not row then return end
            local selected = IsSelected(key)
            local TargetBg = selected and Library.Scheme.AccentColor or Library.Scheme.MainColor
            local TargetText = selected and Library.Scheme.BackgroundColor or Library.Scheme.FontColor
            TweenService:Create(row.Button, Library.TweenInfo, { BackgroundColor3 = TargetBg }):Play()
            TweenService:Create(row.Label, Library.TweenInfo, { TextColor3 = TargetText }):Play()
        end

        local function SelectItem(key)
            if List.Disabled then return end
            if List.Multi then
                if not List.Value then List.Value = {} end
                if List.Value[key] then
                    List.Value[key] = nil
                else
                    List.Value[key] = true
                end
                UpdateRowHighlight(key)
            else
                local prevKey = List.Value
                List.Value = key
                if prevKey ~= nil and ItemRows[prevKey] then
                    UpdateRowHighlight(prevKey)
                end
                UpdateRowHighlight(key)
            end

            local selectedItem = nil
            local selectedIndex = nil
            for i, item in List.Items do
                if item.Key == key then
                    selectedItem = item
                    selectedIndex = i
                    break
                end
            end

            Library:SafeCallback(List.Callback, selectedItem, selectedIndex)
            Library:SafeCallback(List.Changed, List.Value)
        end

        local function RenderItems()
            for _, row in ItemRows do
                row.Button:Destroy()
            end
            table.clear(ItemRows)

            EmptyLabel.Visible = #List.Items == 0
            EmptyLabel.Text = List.EmptyText

            for i, item in List.Items do
                local selected = IsSelected(item.Key)
                local BgColor = selected and Library.Scheme.AccentColor or Library.Scheme.MainColor
                local TxtColor = selected and Library.Scheme.BackgroundColor or Library.Scheme.FontColor

                local RowBtn = New("TextButton", {
                    BackgroundColor3 = function() return IsSelected(item.Key) and Library.Scheme.AccentColor or Library.Scheme.MainColor end,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    Parent = ListFrame,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, math.max(Library.CornerRadius - 1, 2)),
                        Parent = RowBtn,
                    })
                )

                local RowLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -12, 1, 0),
                    Position = UDim2.fromOffset(8, 0),
                    Text = item.Display,
                    TextSize = 13,
                    TextColor3 = function() return IsSelected(item.Key) and Library.Scheme.BackgroundColor or Library.Scheme.FontColor end,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = RowBtn,
                })

                local HoverColor = Library:GetBetterColor(BgColor, 10)

                RowBtn.MouseEnter:Connect(function()
                    if List.Disabled then return end
                    local currentSelected = IsSelected(item.Key)
                    local baseBg = currentSelected and Library.Scheme.AccentColor or Library.Scheme.MainColor
                    TweenService:Create(RowBtn, Library.TweenInfo, {
                        BackgroundColor3 = Library:GetBetterColor(baseBg, 10)
                    }):Play()
                end)
                RowBtn.MouseLeave:Connect(function()
                    if List.Disabled then return end
                    local currentSelected = IsSelected(item.Key)
                    local baseBg = currentSelected and Library.Scheme.AccentColor or Library.Scheme.MainColor
                    TweenService:Create(RowBtn, Library.TweenInfo, {
                        BackgroundColor3 = baseBg
                    }):Play()
                end)

                RowBtn.MouseButton1Click:Connect(function()
                    SelectItem(item.Key)
                end)

                ItemRows[item.Key] = { Button = RowBtn, Label = RowLabel }
            end
        end

        function List:SetItems(items)
            List.Items = NormalizeItems(items)
            if List.Multi then
                List.Value = {}
            else
                List.Value = nil
            end
            RenderItems()
        end

        function List:AddItem(Item)
            local Items = table.clone(List.Items)
            if typeof(Item) == "string" then
                local Key = #Items + 1
                local Used = {}
                for _, Entry in Items do Used[Entry.Key] = true end
                while Used[Key] do Key += 1 end
                Item = { Key = Key, Display = Item }
            end
            table.insert(Items, Item)
            List.Items = NormalizeItems(Items)
            RenderItems()
            Groupbox:Resize()
        end

        function List:RemoveItem(keyOrIndex)
            local Target
            for i, item in List.Items do if item.Key == keyOrIndex then Target = i; break end end
            Target = Target or (typeof(keyOrIndex) == "number" and keyOrIndex)
            for i, item in List.Items do
                if i == Target then
                    if List.Multi then
                        if List.Value then List.Value[item.Key] = nil end
                    elseif List.Value == item.Key then
                        List.Value = nil
                    end
                    table.remove(List.Items, i)
                    RenderItems()
                    return true
                end
            end
            return false
        end

        function List:GetSelected()
            if List.Multi then
                local selected = {}
                if List.Value then
                    for _, item in List.Items do
                        if List.Value[item.Key] then
                            table.insert(selected, item)
                        end
                    end
                end
                return selected
            else
                for _, item in List.Items do
                    if item.Key == List.Value then
                        return item
                    end
                end
                return nil
            end
        end

        function List:SetSelected(keyOrIndex)
            local function Resolve(Key)
                for _, Item in List.Items do if Item.Key == Key then return Key end end
                if typeof(Key) == "number" and List.Items[Key] then return List.Items[Key].Key end
                return nil
            end
            if List.Multi then
                local Next = typeof(keyOrIndex) == "table" and {} or table.clone(List.Value or {})
                for _, Key in typeof(keyOrIndex) == "table" and keyOrIndex or { keyOrIndex } do
                    local Resolved = Resolve(Key)
                    if Resolved ~= nil then Next[Resolved] = true end
                end
                List.Value = Next
            else List.Value = Resolve(keyOrIndex) end
            RenderItems()
        end

        function List:ClearSelection()
            if List.Multi then
                List.Value = {}
            else
                List.Value = nil
            end
            RenderItems()
        end

        function List:GetItems()
            local Copy = {}
            for Index, Item in List.Items do Copy[Index] = table.clone(Item) end
            return Copy
        end

        function List:SetText(text)
            List.Text = text
            for _, child in Holder:GetChildren() do
                if child:IsA("TextLabel") and child.LayoutOrder == 1 then
                    child.Text = text
                    break
                end
            end
        end

        function List:SetVisible(visible)
            List.Visible = visible
            Holder.Visible = visible
            Groupbox:Resize()
        end

        function List:SetDisabled(disabled)
            List.Disabled = disabled
            ListFrame.ScrollBarImageTransparency = disabled and 0.5 or 0
        end

        function List:OnChanged(callback)
            List.Changed = callback
        end

        Holder:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() if Holder.Parent then Groupbox:Resize() end end)

        -- Initialize with provided items
        List.Items = NormalizeItems(Info.Items)
        RenderItems()

        List.Holder = Holder
        table.insert(Groupbox.Elements, List)

        Options[Idx] = Library:TrackElement(List, Groupbox)

        return List
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
        local Container = Groupbox.Container

        if Groupbox.TitleLine then
            Groupbox.TitleLine.Visible = false
        end

        -- Outer wrapper in the parent groupbox's list
        local TabboxWrapper = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = UDim2.fromScale(1, 0),
            Parent = Container,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius),
                Parent = TabboxWrapper,
            })
        )
        Library:AddOutline(TabboxWrapper)

        -- Tab button row inside the styled container
        local TabButtonRow = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Parent = TabboxWrapper,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 0),
            Parent = TabButtonRow,
        })

        local InnerTabbox = {
            ActiveTab = nil,
            Tabs = {},
            Groupbox = Groupbox,
            BoxHolder = TabboxWrapper,
        }

        table.insert(Groupbox.InnerTabboxes, InnerTabbox)

        local TotalButtons = 0
        local InnerTabTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        function InnerTabbox:AddTab(Name, IconName)
            TotalButtons = TotalButtons + 1

            local BoxIcon = Library:GetCustomIcon(IconName)

            -- Icon button for this tab
            local Button = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 34),
                Text = "",
                Parent = TabButtonRow,
            })

            local ButtonIcon
            if BoxIcon then
                ButtonIcon = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = BoxIcon.Url,
                    ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                    ImageRectOffset = BoxIcon.ImageRectOffset,
                    ImageRectSize = BoxIcon.ImageRectSize,
                    ImageTransparency = 0.5,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(20, 20),
                    Parent = Button,
                })
            end

            -- Accent indicator bar at the bottom
            local Indicator = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 1),
                BackgroundColor3 = "AccentColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 1, 0),
                Size = UDim2.new(0.6, 0, 0, 2),
                Parent = Button,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = Indicator,
                })
            )

            -- Content container for this tab's elements (inside the styled wrapper)
            local TabContainer = New("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, 37),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                Parent = TabboxWrapper,
            })
            local TabList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = TabContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 5),
                Parent = TabContainer,
            })

            local Tab = {
                Name = Name,
                ButtonHolder = Button,
                Container = TabContainer,

                Tab = Groupbox.Tab or Groupbox,
                IsDialog = Groupbox.IsDialog,
                Elements = {},
                DependencyBoxes = {},
                InnerTabboxes = {},
            }

            function Tab:Show()
                if InnerTabbox.ActiveTab then
                    InnerTabbox.ActiveTab:Hide()
                end

                if ButtonIcon then
                    TweenService:Create(ButtonIcon, InnerTabTweenInfo, { ImageTransparency = 0 }):Play()
                end
                TweenService:Create(Indicator, InnerTabTweenInfo, { BackgroundTransparency = 0, Size = UDim2.new(0.6, 0, 0, 2) }):Play()
                TabContainer.Visible = true

                InnerTabbox.ActiveTab = Tab
                Tab:Resize()
            end

            function Tab:Hide()
                if ButtonIcon then
                    TweenService:Create(ButtonIcon, InnerTabTweenInfo, { ImageTransparency = 0.5 }):Play()
                end
                TweenService:Create(Indicator, InnerTabTweenInfo, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2) }):Play()
                TabContainer.Visible = false

                InnerTabbox.ActiveTab = nil
            end

            function Tab:Resize()
                if InnerTabbox.ActiveTab ~= Tab then
                    return
                end

                local ContentHeight = TabList.AbsoluteContentSize.Y / Library.DPIScale + 11
                TabContainer.Size = UDim2.new(1, 0, 0, ContentHeight)
                TabboxWrapper.Size = UDim2.new(1, 0, 0, 37 + ContentHeight)
                Groupbox:Resize()
            end

            -- Auto-show first tab
            if not InnerTabbox.ActiveTab then
                Tab:Show()
            end

            Button.MouseButton1Click:Connect(Tab.Show)
            Library:AddTooltip(Name or "", "", Button)

            setmetatable(Tab, BaseGroupbox)

            InnerTabbox.Tabs[Name] = Tab

            return Tab
        end

        return InnerTabbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
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
    local Frame = New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = "BackgroundColor", Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(420, 180), ZIndex = 100, Parent = ScreenGui })
    Library:AddOutline(Frame)
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Frame })
    local Title = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -28, 0, 25), RichText = false, Text = Info.Title or "Unsupported executor", TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101, Parent = Frame })
    local Description = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 48), Size = UDim2.new(1, -28, 1, -108), RichText = false, Text = Info.Description or ("This script does not support " .. Executor .. "."), TextSize = 14, TextTransparency = 0.35, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 101, Parent = Frame })
    local Languages = typeof(Info.Languages) == "table" and Info.Languages or {}
    if #Languages == 0 then
        Languages = {
            { Name = "English", Title = Info.Title or "Unsupported executor", Description = Info.Description or ("This script does not support " .. Executor .. ".") },
            { Name = "Espanol", Title = Info.Title or "Ejecutor no compatible", Description = Info.Description or ("Este script no es compatible con " .. Executor .. ".") },
            { Name = "Portugues", Title = Info.Title or "Executor nao suportado", Description = Info.Description or ("Este script nao suporta " .. Executor .. ".") },
        }
    end
    local Initial = Languages[1]
    Title.Text = tostring(Initial.Title or Info.Title or "Unsupported executor")
    Description.Text = tostring(Initial.Description or Info.Description or ("This script does not support " .. Executor .. "."))
    local LanguageIndex = 1
    local Language = New("TextButton", { BackgroundColor3 = "MainColor", Position = UDim2.new(0, 14, 1, -30), Size = UDim2.fromOffset(140, 20), Text = "Language: " .. tostring(Languages[1].Name or "English"), TextSize = 12, ZIndex = 101, Parent = Frame })
    New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0, 164, 1, -30), Size = UDim2.new(1, -178, 0, 20), RichText = false, Text = tostring(Info.Footer or ""), TextSize = 12, TextTransparency = 0.45, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 101, Parent = Frame })
    Language.MouseButton1Click:Connect(function()
        LanguageIndex = LanguageIndex % #Languages + 1
        local Entry = Languages[LanguageIndex]
        Title.Text = tostring(Entry.Title or Info.Title or "Unsupported executor")
        Description.Text = tostring(Entry.Description or Info.Description or ("This script does not support " .. Executor .. "."))
        Language.Text = "Language: " .. tostring(Entry.Name or LanguageIndex)
    end)
    local Screen = { Frame = Frame, Title = Title, Description = Description, Executor = Executor }
    function Screen:Destroy() if Frame.Parent then Frame:Destroy() end end
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
        local MaxWidth = math.max(96, math.min(300, ScreenGui.AbsoluteSize.X / Library.DPIScale - 16))
        local Left = IconLabel and 40 or 10
        local Right = Data.Closable and 32 or 10
        local Width = math.max(1, MaxWidth - Left - Right)
        local Y, TextWidth = 8, 40
        if Title then
            local X, Height = Library:GetTextBounds(Data.Title or "", Title.FontFace, 15, Width)
            Title.Position = UDim2.fromOffset(Left, Y)
            Title.Size = UDim2.fromOffset(Width, Height)
            Y += Height + 4
            TextWidth = math.max(TextWidth, X)
        end
        local X, Height = Library:GetTextBounds(Data.Description, Description.FontFace, 14, Width)
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
                TweenService:Create(Holder, Library.NotifyTweenInfo, { Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, 0) or UDim2.new(1, 8, 0, 0) }):Play()
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
        CloseButton = New("TextButton", { AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1, Position = UDim2.new(1, -4, 0, 4), Size = UDim2.fromOffset(24, 24), Text = "×", TextSize = 18, TextTransparency = 0.35, Parent = Holder })
        CloseButton.MouseButton1Click:Connect(function() Data:Destroy("user") end)
    end
    local Timed = not Data.Persist and not Data.Steps and typeof(Data.Time) == "number"
    local Track = New("Frame", { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = "OutlineColor", Position = UDim2.new(0, 10, 1, -7), Size = UDim2.new(1, -20, 0, 2), Visible = Timed or Data.Steps ~= nil, Parent = Holder })
    Progress = New("Frame", { BackgroundColor3 = "AccentColor", Size = UDim2.fromScale(Data.Steps and 0 or 1, 1), Parent = Track })
    Data:Resize()
    Library.Notifications[Fake] = Data
    table.insert(Library.NotifyOrder, Fake)
    Library:UpdateNotificationPositions()
    TweenService:Create(Holder, Library.NotifyTweenInfo, { Position = UDim2.fromOffset(0, 0) }):Play()
    if typeof(Data.Time) == "Instance" then
        -- Time can observe an external lifetime, but a notification never owns that Instance.
        LifetimeConnection = Data.Time.Destroying:Connect(function() Data:Destroy("script") end)
    elseif Timed then
        Data.TimerThread = task.delay(Library.NotifyTweenInfo.Time, function()
            if Data.Destroyed then return end
            Data.TimerTween = TweenService:Create(Progress, TweenInfo.new(Data.Time, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(0, 1) })
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

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = math.max(1, (ViewportSize.X - 32) / Library.DPIScale)
    local MaxY = math.max(1, (ViewportSize.Y - 32) / Library.DPIScale)

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Library.OriginalMinSize

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font)
    end
    WindowInfo.CornerRadius = math.clamp(WindowInfo.CornerRadius, 0, 20)
    
    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(48, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(48, WindowInfo.CompactWidthActivation)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch
    Library.FuzzySearch = WindowInfo.FuzzySearch ~= false
    Library.SearchValues = WindowInfo.SearchValues ~= false

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local BottomBackground
    local FooterLabel

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)

        
        -- Keep one subtle themed border rather than six overlapping glow layers.
        New("UIStroke", { Color = "AccentColor", Thickness = 1, Transparency = 0.65, Parent = MainFrame })

        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
        })

        if WindowInfo.BackgroundImage then
            BackgroundImage = New("ImageLabel", {
                Image = WindowInfo.BackgroundImage,
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromScale(1, 1),
                ScaleType = Enum.ScaleType.Stretch,
                ZIndex = 999,
                BackgroundTransparency = 1,
                ImageTransparency = 0.75,
                Parent = MainFrame,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = BackgroundImage,
                })
            )
        end

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end
        Library.LayoutMain = MainFrame
        Library.LayoutDefault = { Position = MainFrame.Position, Size = MainFrame.Size }

        --// Top Bar \\-
        local TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true)

        --// Title
        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            WindowIcon = New("ImageLabel", {
                Image = if tonumber(WindowInfo.Icon)
                    then string.format("rbxassetid://%d", WindowInfo.Icon)
                    else WindowInfo.Icon,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            TitleHolder.AbsoluteSize.X - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        --// Top Right Bar
        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -49, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 57 - 1, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search",
            Size = WindowInfo.SearchbarSize,
            TextScaled = true,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Shrink,
            Parent = SearchBox,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = SearchBox,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            New("ImageLabel", {
                Image = SearchIcon.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = SearchIcon.ImageRectOffset,
                ImageRectSize = SearchIcon.ImageRectSize,
                ImageTransparency = 0.5,
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = SearchBox,
            })
        end

        local HistoryButton = New("ImageButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = MoveIcon and MoveIcon.Url or "",
                ImageColor3 = "AccentColor",
                ImageRectOffset = MoveIcon and MoveIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = MoveIcon and MoveIcon.ImageRectSize or Vector2.zero,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
        HistoryButton.Visible = not WindowInfo.DisableNotificationBell
        local HistoryPanel = New("Frame", {
            AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "BackgroundColor", Position = UDim2.new(1, -8, 0, 48),
            Size = UDim2.fromOffset(math.min(360, math.max(220, WindowInfo.Size.X.Offset - 16)), 260), Visible = false, ZIndex = 50, Parent = MainFrame,
        })
        Library.HistoryPanel = HistoryPanel
        Library:AddOutline(HistoryPanel)
        New("UICorner", { CornerRadius = UDim.new(0, WindowInfo.CornerRadius), Parent = HistoryPanel })
        local ClearHistory = New("TextButton", { BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 4), Size = UDim2.fromOffset(60, 22), Text = "Clear all", TextSize = 13, ZIndex = 51, Parent = HistoryPanel })
        local HistorySearch = New("TextBox", { BackgroundColor3 = "MainColor", PlaceholderText = "Search history", Position = UDim2.fromOffset(74, 4), Size = UDim2.new(1, -82, 0, 22), TextSize = 12, ZIndex = 51, Parent = HistoryPanel })
        local HistoryList = New("ScrollingFrame", { AutomaticCanvasSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, CanvasSize = UDim2.fromScale(0, 0), Position = UDim2.fromOffset(6, 30), ScrollBarThickness = 3, Size = UDim2.new(1, -12, 1, -36), ZIndex = 51, Parent = HistoryPanel })
        local HistoryLayout = New("UIListLayout", { Padding = UDim.new(0, 4), Parent = HistoryList })
        local Badge = New("TextLabel", { AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = "AccentColor", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(16, 16), Text = "", TextSize = 11, Visible = false, ZIndex = 52, Parent = HistoryButton })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Badge })
        function Library:RefreshNotificationHistory()
            Badge.Visible = Library.NotificationUnread > 0
            Badge.Text = Library.NotificationUnread > 9 and "9+" or tostring(Library.NotificationUnread)
            if not HistoryPanel.Visible then return end
            for _, Child in HistoryList:GetChildren() do if Child:IsA("TextButton") then Child:Destroy() end end
            for _, Entry in Library.NotificationHistory do
                local Filter = HistorySearch.Text:lower()
                if Filter ~= "" and not Entry.Text:lower():find(Filter, 1, true) then continue end
                local Text = Entry.Text .. (Entry.Count > 1 and string.format("  x%d", Entry.Count) or "")
                local Row = New("TextButton", { AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = "MainColor", Size = UDim2.new(1, -4, 0, 28), Text = Text, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 51, Parent = HistoryList })
                New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = Row })
                local Expanded = false
                Row.MouseButton1Click:Connect(function()
                    if Expanded then return end
                    Expanded = true
                    Row.Size = UDim2.new(1, -4, 0, 54)
                    Row.Text = Entry.Text
                    local Copy = New("TextButton", { AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = "BackgroundColor", Position = UDim2.new(1, -4, 1, -3), Size = UDim2.fromOffset(42, 17), Text = "Copy", TextSize = 11, ZIndex = 52, Parent = Row })
                    Copy.MouseButton1Click:Connect(function()
                    local Plain = Entry.Text:gsub("<[^>]->", "")
                    Plain = Plain:gsub("&lt;", "<"):gsub("&gt;", ">")
                    Plain = Plain:gsub("&quot;", '"'):gsub("&apos;", "'"):gsub("&amp;", "&")
                    pcall(function() if setclipboard then setclipboard(Plain) end end)
                    end)
                end)
            end
        end
        function Library:GetNotificationHistory()
            local Copy = {}
            for Index, Entry in Library.NotificationHistory do Copy[Index] = table.clone(Entry) end
            return Copy
        end
        function Library:GetNotificationUnread() return Library.NotificationUnread end
        function Library:GetNotificationBellEnabled() return Library.NotificationBellEnabled end
        function Library:SetNotificationBellEnabled(Enabled)
            Library.NotificationBellEnabled = Enabled ~= false
            WindowInfo.DisableNotificationBell = not Library.NotificationBellEnabled
            HistoryButton.Visible = Library.NotificationBellEnabled
        end
        function Library:ClearNotificationHistory() table.clear(Library.NotificationHistory); Library.NotificationUnread = 0; Library:RefreshNotificationHistory() end
        function Library:ToggleNotificationHistory(Value)
            if typeof(Value) == "boolean" then
                HistoryPanel.Visible = Value
            else
                HistoryPanel.Visible = not HistoryPanel.Visible
            end
            Library.HistoryOpen = HistoryPanel.Visible
            if HistoryPanel.Visible then Library.NotificationUnread = 0; Library:RefreshNotificationHistory() end
            return HistoryPanel.Visible
        end
        HistoryButton.MouseButton1Click:Connect(function()
            Library:ToggleNotificationHistory()
        end)
        ClearHistory.MouseButton1Click:Connect(Library.ClearNotificationHistory)
        HistorySearch:GetPropertyChangedSignal("Text"):Connect(Library.RefreshNotificationHistory)
        Library:RefreshNotificationHistory()
        Library.NotificationBellEnabled = not WindowInfo.DisableNotificationBell

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20 + WindowInfo.CornerRadius),
            Parent = MainFrame
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BottomBackground,
            })
        )

        --// Footer
        FooterLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = WindowInfo.Footer,
            TextSize = 14,
            TextTransparency = 0.5,
            Parent = BottomBar,
        })

        --// Resize Button
        if WindowInfo.Resizable then
            ResizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = BottomBar,
            })

            Library:MakeResizable(MainFrame, ResizeButton, function()
                for _, Tab in Library.Tabs do
                    Tab:Resize(true)
                end
                Library:LayoutChanged()
            end)
        end

        if ResizeButton then New("ImageLabel", {
            Image = ResizeIcon and ResizeIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ResizeIcon and ResizeIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ResizeIcon and ResizeIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = ResizeButton,
        }) end

        --// Tabs \\--
        Tabs = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = "BackgroundColor",
            CanvasSize = UDim2.fromScale(0, 0),
            Position = UDim2.fromOffset(0, 49),
            ScrollBarThickness = 0,
            Size = UDim2.new(0, InitialLeftWidth, 1, -70),
            Parent = MainFrame,
        })
        New("UIListLayout", {
            Parent = Tabs,
        })

        --// Container \\--
        Container = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
            end,
            Name = "Container",
            Position = UDim2.new(1, 0, 0, 49),
            Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
            Parent = MainFrame,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
            PaddingTop = UDim.new(0, 0),
            Parent = Container,
        })
    end

    --// Window Table \\--
    local Window = {}

    function Window:ChangeTitle(title)
        assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

        WindowTitle.Text = title
        WindowInfo.Title = title
    end

    if WindowInfo.BackgroundImage then
        function Window:SetBackgroundImage(Image: string)
            assert(typeof(Image) == "string", "Expected string for Image got: " .. typeof(Image))
    
            BackgroundImage.Image = Image
            WindowInfo.BackgroundImage = Image
        end
    end

    function Window:SetFooter(footer: string)
        assert(typeof(footer) == "string", "Expected string for footer got: " .. typeof(footer))

        FooterLabel.Text = footer
        WindowInfo.Footer = footer
    end

    function Window:SetCornerRadius(Radius: number)
        assert(typeof(Radius) == "number", "Expected number for Radius got: " .. typeof(Radius))
        assert(IsFinite(Radius), "Corner radius must be finite")
        Radius = math.clamp(Radius, 0, 20)

        for _, UICorner in Library.Corners do
            if UICorner.CornerRadius.Scale > 0 then continue end
            if Library.CornerRadius > 0 and UICorner.CornerRadius.Offset == Library.CornerRadius / 2 then
                UICorner.CornerRadius = UDim.new(0, Radius / 2)
            else
                UICorner.CornerRadius = UDim.new(0, Radius)
            end
        end

        Library.CornerRadius = Radius
        WindowInfo.CornerRadius = Radius

        if ResizeButton then ResizeButton.Position = UDim2.new(1, -Radius / 4, 0, 0) end
        BottomBackground.Size = UDim2.new(1, 0, 0, 20 + Radius)

        for _, Tab in Library.Tabs do
            if Tab.IsKeyTab then
                continue
            end

            for _, Tabbox in Tab.Tabboxes do
                Tabbox:UpdateCorners()
            end
        end
    end

    local function ApplyCompact()
        IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
        if WindowInfo.DisableCompactingSnap then
            IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
        end

        WindowTitle.Visible = not IsCompact
        if not WindowInfo.Icon then
            WindowIcon.Visible = IsCompact
        end

        for _, Button in Library.TabButtons do
            Button.Label.Visible = not IsCompact or not Button.Icon or not Button.Icon.Visible
            Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
            Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
            Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
            if Button.Icon then Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY end
        end
    end

    function Window:IsSidebarCompacted()
        return IsCompact
    end

    function Window:SetCompact(State)
        Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
    end

    function Window:GetSidebarWidth()
        return Tabs.Size.X.Offset
    end

    function Window:SetSidebarWidth(Width)
        assert(IsFinite(Width), "Sidebar width must be finite")
        local maxAllowedWidth = math.max(48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)
        Width = math.clamp(Width, 48, maxAllowedWidth)

        DividerLine.Position = UDim2.fromOffset(Width, 0)

        TitleHolder.Size = UDim2.new(0, Width, 1, 0)
        RightWrapper.Size = UDim2.new(1, -Width - 57 - 1, 1, -16)
        Tabs.Size = UDim2.new(0, Width, 1, -70)
        Container.Size = UDim2.new(1, -Width - 1, 1, -70)

        if WindowInfo.EnableCompacting then
            ApplyCompact()
        end
        if not IsCompact then
            LastExpandedWidth = Width
        end
    end

    function Window:ApplyLayout()
        if Library.Unloaded then return end
        Window:SetSidebarWidth(Window:GetSidebarWidth())
        for _, Tab in Library.Tabs do Tab:Resize(true) end
        if Library.HistoryPanel then
            Library.HistoryPanel.Size = UDim2.fromOffset(math.max(100, math.min(360, MainFrame.AbsoluteSize.X / Library.DPIScale - 16)), math.max(80, math.min(260, MainFrame.AbsoluteSize.Y / Library.DPIScale - 64)))
        end
    end
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Window:ApplyLayout() end)
    Library:GiveSignal(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not Library.Unloaded then Library:SnapFrame(MainFrame); Window:ApplyLayout() end
    end), MainFrame)

    function Window:ShowTabInfo(Name, Description)
        CurrentTabLabel.Text = Name
        CurrentTabDescription.Text = Description

        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(0.5, 1)
        end
        CurrentTabInfo.Visible = true
    end
    function Window:HideTabInfo()
        CurrentTabInfo.Visible = false
        if IsDefaultSearchbarSize then
            SearchBox.Size = UDim2.fromScale(1, 1)
        end
    end

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

        local TabButton: TextButton
        local TabLabel
        local TabIcon

        local TabContainer
        local TabLeft
        local TabRight
        local TabAccent

        Icon = Library:GetCustomIcon(Icon)
        do
            TabButton = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                Parent = Tabs,
            })
            New("UICorner", { CornerRadius = UDim.new(0, WindowInfo.CornerRadius), Parent = TabButton })
            TabAccent = New("Frame", { BackgroundColor3 = "AccentColor", BackgroundTransparency = 1, Position = UDim2.fromOffset(3, 6), Size = UDim2.fromOffset(3, 28), Parent = TabButton })
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
                    ScaleType = Enum.ScaleType.Fit,
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
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = SingleColumn and UDim2.new(1, 0, 1, 0) or UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabLeft,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabLeft,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabLeft,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabLeft,
                })
            end

            TabRight = New("ScrollingFrame", {
                AnchorPoint = Vector2.new(1, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromScale(1, 0),
                ScrollBarImageTransparency = 1,
                ScrollBarThickness = 0,
                Size = UDim2.new(0.5, -3, 1, 0),
                Parent = TabContainer,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = TabRight,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
                Parent = TabRight,
            })
            do
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = -1,
                    Parent = TabRight,
                })
                New("Frame", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = TabRight,
                })
            end
        end

        --// Warning Box \\--
        local WarningBoxHolder = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 7),
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
                ScrollBarThickness = 3,
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
                TextColor3 = Color3.fromRGB(255, 50, 50),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = WarningBoxScrollingFrame,
            })

            WarningStroke = New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
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

            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = WarningText,
            })
        end

        --// Tab Table \\--
        local Tab = {
            Name = Name,
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
                Title = "WARNING",
                Text = "",
            },
        }

        function Tab:SetActivity(Activity: any)
            Activity = typeof(Activity) == "table" and Activity or {}
            local Count = tonumber(Activity.enabled) or 0
            Count = (Count == Count and math.abs(Count) < 1000000) and math.max(0, math.floor(Count)) or 0
            Tab.Activity = { enabled = Count, error = Activity.error == true }
            if not Tab.ActivityBadge then
                Tab.ActivityBadge = New("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = "AccentColor", Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(16, 16), TextSize = 10, Parent = TabButton })
                New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Tab.ActivityBadge })
            end
            Tab.ActivityBadge.Visible = Count > 0 or Tab.Activity.error
            Tab.ActivityBadge.BackgroundColor3 = Tab.Activity.error and Library.Scheme.RedColor or Library.Scheme.AccentColor
            Tab.ActivityBadge.Text = Tab.Activity.error and "!" or (Count > 9 and "9+" or tostring(Count))
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
                or Color3.fromRGB(127, 0, 0)

            WarningBoxShadowOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor
                or Color3.fromRGB(85, 0, 0)
            WarningBoxOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                or Color3.fromRGB(255, 50, 50)

            WarningTitle.TextColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor
                or Color3.fromRGB(255, 50, 50)
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
                return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
            end

            Library.Registry[WarningBoxShadowOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
            end

            Library.Registry[WarningBoxOutline].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
            end

            Library.Registry[WarningTitle].TextColor3 = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
            end

            Library.Registry[WarningStroke].Color = function()
                return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
            end
        end

        function Tab:RefreshSides()
            if Tab.PlayerInfo and Tab.PlayerInfo.Holder.Parent then
                Tab.PlayerInfo.Holder.Position = UDim2.fromOffset(4, (WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0) + 4)
            end
            local Offset = (WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0) + (Tab.PlayerInfoHeight or 0)
            for _, Side in Tab.Sides do
                Side.Position = UDim2.new(Side.Position.X.Scale, 0, 0, Offset)
                Side.Size = Tab.SingleColumn and UDim2.new(1, 0, 1, -Offset) or UDim2.new(0.5, -3, 1, -Offset)
            end
        end

        function Tab:Resize(ResizeWarningBox: boolean?)
            if ResizeWarningBox then
                local MaximumSize = math.floor(TabContainer.AbsoluteSize.Y / 3.25)
                local _, YText = Library:GetTextBounds(
                    WarningText.Text,
                    Library.Scheme.Font,
                    WarningText.TextSize,
                    WarningText.AbsoluteSize.X
                )

                local YBox = 24 + YText
                if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                    YBox = MaximumSize
                else
                    WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                end

                WarningText.Size = UDim2.new(1, -4, 0, YText)
                WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
            end

            Tab:RefreshSides()
        end

        function Tab:AddGroupbox(Info)
            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = (Tab.SingleColumn or Info.Side == 1) and TabLeft or TabRight,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local GroupboxHolder
            local GroupboxLabel
            local GroupboxTitleLine

            local GroupboxContainer
            local GroupboxList
            local MinimizeBtn

            do
                GroupboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = GroupboxHolder,
                    })
                )
                Library:AddOutline(GroupboxHolder)

                GroupboxTitleLine = Library:MakeLine(GroupboxHolder, {
                    Position = UDim2.fromOffset(0, 34),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local BoxIcon = Library:GetCustomIcon(Info.IconName)
                if BoxIcon then
                    New("ImageLabel", {
                        Image = BoxIcon.Url,
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageRectOffset = BoxIcon.ImageRectOffset,
                        ImageRectSize = BoxIcon.ImageRectSize,
                        Position = UDim2.fromOffset(6, 6),
                        Size = UDim2.fromOffset(22, 22),
                        Parent = GroupboxHolder,
                    })
                end

                GroupboxLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(BoxIcon and 24 or 0, 0),
                    Size = UDim2.new(1, -(BoxIcon and 56 or 32), 0, 34),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Text = Info.Name,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = GroupboxHolder,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    Parent = GroupboxLabel,
                })

                local ChevronIcon = Library:GetIcon("chevron-down") or ArrowIcon
                MinimizeBtn = New("ImageButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -8, 0, 17),
                    Size = UDim2.fromOffset(22, 22),
                    Image = ChevronIcon and ChevronIcon.Url or "",
                    ImageRectOffset = ChevronIcon and ChevronIcon.ImageRectOffset or Vector2.zero,
                    ImageRectSize = ChevronIcon and ChevronIcon.ImageRectSize or Vector2.zero,
                    ImageColor3 = "FontColor",
                    ImageTransparency = 0.15,
                    Parent = GroupboxHolder,
                })

                GroupboxContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 35),
                    Size = UDim2.new(1, 0, 1, -35),
                    Parent = GroupboxHolder,
                })

                GroupboxList = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = GroupboxContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = GroupboxContainer,
                })
            end

            local MinimizeTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local Groupbox = {
                Name = Info.Name,
                BoxHolder = BoxHolder,
                Holder = GroupboxHolder,
                Container = GroupboxContainer,
                TitleLine = GroupboxTitleLine,

                Tab = Tab,
                DependencyBoxes = {},
                Elements = {},
                InnerTabboxes = {},

                Minimized = false,
                Visible = true,
            }
            function Groupbox:Resize()
                if Groupbox.Minimized then
                    return
                end
                GroupboxHolder.Size = UDim2.new(1, 0, 0, (GroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 49)
            end

            function Groupbox:SetMinimized(Minimized)
                Minimized = Minimized == true
                if Groupbox.Minimized == Minimized then return end
                Groupbox.Minimized = Minimized
                GroupboxContainer.Visible = not Minimized
                if Groupbox.TitleLine and Groupbox.TitleLine.Parent then Groupbox.TitleLine.Visible = not Minimized and #Groupbox.InnerTabboxes == 0 end
                StopTween(Groupbox.MinimizeTween)
                local Height = Minimized and 34 or GroupboxList.AbsoluteContentSize.Y / Library.DPIScale + 49
                Groupbox.MinimizeTween = TweenService:Create(GroupboxHolder, MinimizeTweenInfo, { Size = UDim2.new(1, 0, 0, Height) })
                Groupbox.MinimizeTween:Play()
                TweenService:Create(MinimizeBtn, MinimizeTweenInfo, { Rotation = Minimized and 180 or 0, ImageTransparency = Minimized and 0 or 0.35 }):Play()
            end
            MinimizeBtn.MouseButton1Click:Connect(function() Groupbox:SetMinimized(not Groupbox.Minimized) end)
            GroupboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if GroupboxHolder.Parent and not Groupbox.Minimized then Groupbox:Resize() end
            end)

            function Groupbox:SetVisible(Visible: boolean)
                Groupbox.Visible = Visible
                Groupbox.BoxHolder.Visible = Visible
                Groupbox:Resize()

                if Visible == true and Library.Searching then
                    Library:UpdateSearch(Library.SearchText)
                end
            end

            function Groupbox:Show()
                Groupbox:SetVisible(true)
            end

            function Groupbox:Hide()
                Groupbox:SetVisible(false)
            end

            setmetatable(Groupbox, BaseGroupbox)

            Groupbox:Resize()
            Tab.Groupboxes[Info.Name] = Groupbox

            if Info.Visible == false then
                Groupbox:Hide()
            end

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
            if Tab.PlayerInfo then Tab.PlayerInfo:Destroy() end
            local Height = Info.Height or (Info.Compact and 46 or 68)
            local Card = New("Frame", { BackgroundColor3 = "MainColor", Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 0, Height - 4), Parent = TabContainer })
            New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Card })
            local UserId = Info.UserId or (typeof(Info.Player) == "Instance" and Info.Player:IsA("Player") and Info.Player.UserId) or LocalPlayer.UserId
            local Avatar = New("ImageLabel", { BackgroundColor3 = "OutlineColor", Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(Height - 16, Height - 16), Parent = Card })
            New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Avatar })
            local Title = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Height, 8), Size = UDim2.new(1, -Height - 8, 0, 18), RichText = false, Text = tostring(Info.Title or (typeof(Info.Player) == "Instance" and Info.Player.DisplayName or LocalPlayer.DisplayName)), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, Parent = Card })
            local Description = New("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(Height, 27), Size = UDim2.new(1, -Height - 8, 1, -31), RichText = false, Text = tostring(Info.Description or ""), TextSize = 12, TextTransparency = 0.4, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = Card })
            local Result = { Text = tostring(Info.Title or ""), Holder = Card, Avatar = Avatar, Title = Title, Description = Description, Type = "PlayerInfo" }
            function Result:SetText(Text) Result.Text = tostring(Text or ""); Title.Text = Result.Text end
            function Result:SetDescription(Text) Description.Text = tostring(Text or "") end
            function Result:SetVisible(Visible) Card.Visible = Visible ~= false; if Tab.PlayerInfo == Result then Tab.PlayerInfoHeight = Card.Visible and Height or 0; Tab:RefreshSides() end end
            function Result:Destroy() if Card.Parent then Card:Destroy() end; if Tab.PlayerInfo == Result then Tab.PlayerInfoHeight = 0; Tab.PlayerInfo = nil; Tab:RefreshSides() end end
            Card.Visible = Info.Visible ~= false
            Tab.PlayerInfo, Tab.PlayerInfoHeight = Result, (if Card.Visible then Height else 0)
            Tab:RefreshSides()
            task.spawn(function() local Ok, Image = pcall(Players.GetUserThumbnailAsync, Players, UserId, Info.ThumbnailType or Enum.ThumbnailType.HeadShot, Info.ThumbnailSize or Enum.ThumbnailSize.Size100x100); if Ok and Card.Parent and not Library.Unloaded then Avatar.Image = Image end end)
            return Result
        end

        function Tab:AddTabbox(Info)
            local BoxHolder = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Parent = (Tab.SingleColumn or Info.Side == 1) and TabLeft or TabRight,
            })
            New("UIListLayout", {
                Padding = UDim.new(0, 6),
                Parent = BoxHolder,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4),
                Parent = BoxHolder,
            })

            local TabboxHolder
            local TabboxButtons

            do
                TabboxHolder = New("Frame", {
                    BackgroundColor3 = "BackgroundColor",
                    Size = UDim2.fromScale(1, 0),
                    Parent = BoxHolder,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = TabboxHolder,
                    })
                )
                Library:AddOutline(TabboxHolder)

                TabboxButtons = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 34),
                    Parent = TabboxHolder,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Parent = TabboxButtons,
                })
            end

            local TotalButtons, TotalTabs = 0, 1
            local Tabbox = {
                Name = Info.Name,
                ActiveTab = nil,

                BoxHolder = BoxHolder,
                Holder = TabboxHolder,
                Tabs = {}
            }
            function Tabbox:UpdateCorners()
                for _, Tab in Tabbox.Tabs do
                    Tab:UpdateCorners()
                end
            end

            function Tabbox:AddTab(Name, IconName)
                local TabIndex = TotalTabs

                TotalButtons = TotalButtons + 1
                TotalTabs = TotalTabs + 1

                local BoxIcon = Library:GetCustomIcon(IconName)

                local Button = New("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 34),
                    Text = "",
                    Parent = TabboxButtons,
                })

                local ButtonContent = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(0, 16),
                    Parent = Button,
                })
                New("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 8),
                    Parent = ButtonContent,
                })

                local ButtonIcon
                if BoxIcon then
                    ButtonIcon = New("ImageLabel", {
                        Image = BoxIcon.Url,
                        ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                        ImageRectOffset = BoxIcon.ImageRectOffset,
                        ImageRectSize = BoxIcon.ImageRectSize,
                        ImageTransparency = 0.5,
                        Size = UDim2.fromOffset(16, 16),
                        Parent = ButtonContent,
                    })
                end

                local ButtonLabel = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(0, 16),
                    Text = Name,
                    TextSize = 15,
                    TextTransparency = 0.5,
                    Parent = ButtonContent,
                })

                -- Accent indicator bar at the bottom of the button
                local Indicator = New("Frame", {
                    AnchorPoint = Vector2.new(0.5, 1),
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 1, -1),
                    Size = UDim2.new(0.5, 0, 0, 2),
                    Parent = Button,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Parent = Indicator,
                    })
                )

                local Line = Library:MakeLine(Button, {
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 1),
                    Size = UDim2.new(1, 0, 0, 1),
                })

                local Container = New("Frame", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 35),
                    Size = UDim2.new(1, 0, 1, -35),
                    Visible = false,
                    Parent = TabboxHolder,
                })
                local List = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    Parent = Container,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 7),
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 7),
                    Parent = Container,
                })

                local TabTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                local Tab = {
                    Name = Name,
                    ButtonHolder = Button,
                    Container = Container,

                    ButtonCovers = {
                        BottomCover = Indicator,
                        LeftCover = Indicator,
                        RightCover = Indicator
                    },

                    Tab = Tab,
                    Elements = {},
                    DependencyBoxes = {},
                    InnerTabboxes = {},
                }

                function Tab:Show()
                    if Tabbox.ActiveTab then
                        Tabbox.ActiveTab:Hide()
                    end

                    TweenService:Create(ButtonLabel, TabTweenInfo, { TextTransparency = 0 }):Play()
                    if ButtonIcon then
                        TweenService:Create(ButtonIcon, TabTweenInfo, { ImageTransparency = 0 }):Play()
                    end
                    -- Show accent indicator
                    TweenService:Create(Indicator, TabTweenInfo, { BackgroundTransparency = 0, Size = UDim2.new(0.5, 0, 0, 2) }):Play()
                    Line.Visible = false

                    Container.Visible = true

                    Tabbox.ActiveTab = Tab
                    Tab:Resize()
                end

                function Tab:Hide()
                    TweenService:Create(ButtonLabel, TabTweenInfo, { TextTransparency = 0.5 }):Play()
                    if ButtonIcon then
                        TweenService:Create(ButtonIcon, TabTweenInfo, { ImageTransparency = 0.5 }):Play()
                    end
                    -- Hide accent indicator
                    TweenService:Create(Indicator, TabTweenInfo, { BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 2) }):Play()
                    Line.Visible = true
                    Container.Visible = false

                    Tabbox.ActiveTab = nil
                end

                function Tab:Resize()
                    if Tabbox.ActiveTab ~= Tab then
                        return
                    end

                    TabboxHolder.Size = UDim2.new(1, 0, 0, (List.AbsoluteContentSize.Y / Library.DPIScale) + 49)
                end

                function Tab:UpdateCorners()
                    -- No-op: corner covers no longer needed
                end

                --// Execution \\--
                if not Tabbox.ActiveTab then
                    Tab:Show()
                end

                Button.MouseButton1Click:Connect(Tab.Show)

                setmetatable(Tab, BaseGroupbox)

                Tabbox.Tabs[Name] = Tab
                Tabbox:UpdateCorners()

                return Tab
            end

            if Info.Name then
                Tab.Tabboxes[Info.Name] = Tabbox
            else
                table.insert(Tab.Tabboxes, Tabbox)
            end

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

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
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

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            TweenService:Create(TabAccent, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            TabContainer.Visible = true
            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            if Library.ActiveTab == Tab and CurrentMenu then CurrentMenu:Close() end
            if Library.ActiveTab == Tab and Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(TabAccent, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
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
        TabButton.MouseButton1Click:Connect(Tab.Show)
        Library:AddTooltip(Name or "", "", TabButton)

        Library.Tabs[Name] = Tab

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

            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0.75, 0, 0, 21),
                Parent = TabContainer,
            })

            local Box = New("TextBox", {
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                PlaceholderText = "Key",
                Size = UDim2.new(1, -71, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                Parent = Box,
            })

            local Button = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 63, 1, 0),
                Text = "Execute",
                TextSize = 14,
                Parent = Holder,
            })

            Button.InputBegan:Connect(function(Input)
                if not IsClickInput(Input) then
                    return
                end

                if not Library:MouseIsOverFrame(Button, Input.Position) then
                    return
                end

                Callback(Box.Text)
            end)
        end

        function Tab:RefreshSides() end
        function Tab:Resize() end
        function Tab:UpdateCorners() end

        function Tab:Hover(Hovering)
            if Library.ActiveTab == Tab then
                return
            end

            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = Hovering and 0.25 or 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
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

            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 0,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
                    ImageTransparency = 0,
                }):Play()
            end
            TabContainer.Visible = true

            if Description then
                Window:ShowTabInfo(Name, Description)
            end

            Tab:RefreshSides()

            Library.ActiveTab = Tab

            if Library.Searching then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function Tab:Hide()
            if Library.ActiveTab == Tab and CurrentMenu then CurrentMenu:Close() end
            if Library.ActiveTab == Tab and Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            TweenService:Create(TabButton, Library.TweenInfo, {
                BackgroundTransparency = 1,
            }):Play()
            TweenService:Create(TabLabel, Library.TweenInfo, {
                TextTransparency = 0.5,
            }):Play()
            if TabIcon then
                TweenService:Create(TabIcon, Library.TweenInfo, {
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
        TabButton.MouseButton1Click:Connect(Tab.Show)
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
        local ContentLayout = New("UIListLayout", { Padding = UDim.new(0, 8), Parent = Content })
        local Separator = New("Frame", { BackgroundColor3 = "OutlineColor", Size = UDim2.new(1, -28, 0, 1), Parent = Surface })
        local Footer = New("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -28, 0, 28), Parent = Surface })
        local FooterLayout = New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Wraps = true, Padding = UDim.new(0, 6), Parent = Footer })
        local FooterButtons = {}
        local Dialog = {
            Idx = Idx, Elements = {}, DependencyBoxes = {}, DependencyGroupboxes = {}, InnerTabboxes = {},
            Holder = Overlay, BoxHolder = Content, Container = Content, Sides = { Body },
            Visible = false, Destroyed = false, IsDialog = true, Generation = 0,
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
            local Available = MainFrame.AbsoluteSize / Library.DPIScale
            local Width = math.max(100, math.min(tonumber(Info.Width) or 400, Available.X - 24))
            local MaxHeight = math.max(80, Available.Y - 24)
            local _, TitleHeight = Library:GetTextBounds(Title.Text, Title.FontFace, 18, math.max(1, Width - 28 - (Icon and 24 or 0)))
            local _, DescHeight = Library:GetTextBounds(Description.Text, Description.FontFace, 14, math.max(1, Width - 28))
            if Description.Text == "" then DescHeight = 0 end
            Title.Size = UDim2.new(1, Icon and -24 or 0, 0, TitleHeight)
            Description.Position = UDim2.fromOffset(0, TitleHeight + 6)
            Description.Size = UDim2.new(1, 0, 0, DescHeight)
            Description.Visible = DescHeight > 0
            local HeaderHeight = TitleHeight + (DescHeight > 0 and DescHeight + 6 or 0)
            Header.Size = UDim2.new(1, -28, 0, HeaderHeight)
            local HasButtons = next(FooterButtons) ~= nil
            Footer.Visible = HasButtons; Separator.Visible = HasButtons
            local FooterHeight = HasButtons and math.max(28, FooterLayout.AbsoluteContentSize.Y / Dpi) or 0
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
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueResize)
        FooterLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueResize)
        Library:GiveSignal(MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(QueueResize), Overlay)
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
            if not Dialog.Visible or Dialog.Destroyed then return false end
            Dialog.Visible = false
            Dialog.Generation += 1
            local Generation = Dialog.Generation
            if Library.ActiveDialog == Dialog then Library.ActiveDialog = nil end
            if CurrentMenu and CurrentMenu.Holder:IsDescendantOf(Overlay) then CurrentMenu:Close() end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse() end
            for _, Button in FooterButtons do StopWait(Button) end
            TweenService:Create(Overlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            TweenService:Create(Scale, Library.TweenInfo, { Scale = 0.98 }):Play()
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
            Library.ActiveDialog = Dialog
            Overlay.Visible = true
            Overlay.BackgroundTransparency = 1
            Scale.Scale = 0.98
            TweenService:Create(Overlay, Library.TweenInfo, { BackgroundTransparency = 0.45 }):Play()
            TweenService:Create(Scale, Library.TweenInfo, { Scale = 1 }):Play()
            Dialog:Resize()
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
                local Width = Library:GetTextBounds(Button.Label.Text, Button.Label.FontFace, 14, 240)
                Button.Container.Size = UDim2.fromOffset(Width + 24, 28)
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
            local Button = { Variant = ButtonInfo.Variant or "Primary", Disabled = ButtonInfo.Disabled == true, Busy = false, Waiting = false, WaitTime = IsFinite(ButtonInfo.WaitTime) and math.max(0, ButtonInfo.WaitTime) or 0 }
            Button.Container = New("TextButton", { BackgroundColor3 = "MainColor", Size = UDim2.fromOffset(80, 28), LayoutOrder = ButtonInfo.Order or 0, Text = "", Parent = Footer })
            Button.Label = New("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = tostring(ButtonInfo.Title or Key), TextSize = 14, Parent = Button.Container })
            local Stroke = New("UIStroke", { Color = "OutlineColor", Parent = Button.Container })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Button.Container }))
            Button.Progress = New("Frame", { BackgroundColor3 = "AccentColor", Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(0, 0, 0, 2), Visible = false, Parent = Button.Container })
            local function Background()
                if Button.Variant == "Primary" then return Library.Scheme.FontColor end
                if Button.Variant == "Destructive" then return Library.Scheme.RedColor end
                if Button.Variant == "Ghost" then return Library.Scheme.BackgroundColor end
                return Library.Scheme.MainColor
            end
            local function Foreground()
                if Button.Variant == "Primary" then return Library.Scheme.BackgroundColor end
                if Button.Variant == "Destructive" then return Library.Scheme.WhiteColor end
                return Library.Scheme.FontColor
            end
            Library:AddToRegistry(Button.Container, { BackgroundColor3 = Background })
            Library:AddToRegistry(Button.Label, { TextColor3 = Foreground, FontFace = "Font" })
            function Button:Display()
                if Dialog.Destroyed or not Button.Container.Parent then return end
                local Disabled = Button.Disabled or Button.Waiting or Button.Busy
                Button.Container.Active = not Disabled
                Button.Container.BackgroundColor3 = Background()
                Button.Container.BackgroundTransparency = Disabled and 0.5 or 0
                Button.Label.TextColor3 = Foreground()
                Button.Label.TextTransparency = Disabled and 0.5 or 0
                Stroke.Transparency = Disabled and 0.5 or 0
            end
            function Button:StartWait()
                StopWait(Button)
                Button.Waiting = Button.WaitTime > 0
                Button.Progress.Visible = Button.Waiting
                Button.Progress.Size = UDim2.new(0, 0, 0, 2)
                Button:Display()
                if not Button.Waiting then return end
                local Generation = Dialog.Generation
                Button.TimerTween = TweenService:Create(Button.Progress, TweenInfo.new(Button.WaitTime, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 0, 2) })
                Button.TimerTween:Play()
                Button.Timer = task.delay(Button.WaitTime, function()
                    Button.Timer = nil
                    if Dialog.Destroyed or not Dialog.Visible or Dialog.Generation ~= Generation or FooterButtons[Key] ~= Button then return end
                    Button.Waiting = false; Button.Progress.Visible = false; Button:Display()
                end)
            end
            Button.Container.MouseEnter:Connect(function()
                if not Button.Disabled and not Button.Waiting and not Button.Busy then Button.Container.BackgroundColor3 = Library:GetBetterColor(Background(), 6) end
            end)
            Button.Container.MouseLeave:Connect(function() Button:Display() end)
            Button.Container.MouseButton1Click:Connect(function()
                if Dialog.Destroyed or not Dialog.Visible or Button.Disabled or Button.Waiting or Button.Busy then return end
                local Generation = Dialog.Generation
                Button.Busy = true; Button:Display()
                local Ok, Result = true, nil
                if typeof(ButtonInfo.Callback) == "function" then Ok, Result = pcall(ButtonInfo.Callback, Dialog) end
                Button.Busy = false; Button:Display()
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
        Overlay.MouseButton1Click:Connect(function() if Info.OutsideClickDismiss then Dialog:Dismiss() end end)
        for Key, ButtonInfo in Info.FooterButtons do Dialog:AddFooterButton((typeof(Key) == "number" and ButtonInfo.Id) or Key, ButtonInfo) end
        setmetatable(Dialog, BaseGroupbox)
        Library.Dialogues[Idx] = Dialog
        Dialog:Resize()
        if not Info.StartHidden then Dialog:Show() end
        return Dialog
    end

    function Library:Toggle(Value: boolean?)
        if typeof(Value) == "boolean" then
            Library.Toggled = Value
        else
            Library.Toggled = not Library.Toggled
        end

        if Library.Unloaded then return end
        MainFrame.Visible = Library.Toggled
        if Library.Toggled and Library.HistoryOpen then
            Library.NotificationUnread = 0
            Library:RefreshNotificationHistory()
        end

        if WindowInfo.UnlockMouseWhileOpen then
            ModalElement.Modal = Library.Toggled
        end

        if not Library.Toggled then
            if Library.ActiveExpandedDropdown then
                Library.ActiveExpandedDropdown:Collapse()
            end
            TooltipLabel.Visible = false
            Library.CantDragForced = false
            Library:SetSnapGuides(nil, false)
            if CurrentMenu then CurrentMenu:Close() end

            for _, Option in Library.Options do
                if Option.Type == "ColorPicker" then
                    Option.ColorMenu:Close()
                    Option.ContextMenu:Close()
                elseif Option.Type == "Dropdown" or Option.Type == "PriorityDropdown" or Option.Type == "KeyPicker" then
                    Option.Menu:Close()
                end
            end
        end
    end

    if WindowInfo.EnableSidebarResize then
        local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
        local StartPos, StartWidth
        local Dragging = false
        local Changed

        local SidebarGrabber = New("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(0, 8, 1, 0),
            Text = "",
            Parent = DividerLine,
        })
        SidebarGrabber.MouseEnter:Connect(function()
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
            }):Play()
        end)
        SidebarGrabber.MouseLeave:Connect(function()
            if Dragging then
                return
            end
            TweenService:Create(DividerLine, Library.TweenInfo, {
                BackgroundColor3 = Library.Scheme.OutlineColor,
            }):Play()
        end)

        SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            Library.CantDragForced = true

            StartPos = Input.Position
            StartWidth = Window:GetSidebarWidth()
            Dragging = true

            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                Library.CantDragForced = false
                TweenService:Create(DividerLine, Library.TweenInfo, {
                    BackgroundColor3 = Library.Scheme.OutlineColor,
                }):Play()

                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)

        Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
            if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                Library.CantDragForced = false
                Dragging = false
                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end

                return
            end

            if Dragging and IsHoverInput(Input) then
                local Delta = Input.Position - StartPos
                local Width = StartWidth + Delta.X / Library.DPIScale

                if WindowInfo.DisableCompactingSnap then
                    Window:SetSidebarWidth(Width)
                    return
                end

                if Width > Threshold then
                    Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                else
                    Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                end
            end
        end))
    end
    if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
        Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
    end
    if WindowInfo.AutoShow then
        task.defer(function() if not Library.Unloaded then Library:Toggle(true) end end)
    end

do
        local ToggleBtnTexture = "rbxassetid://72530843154458"
        
        local ToggleBtnSize = 56   
        local ToggleBtnIconSize = 45

        local ToggleBtnFrame = New("ImageButton", {
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = "BackgroundColor",
            Position = UDim2.new(0.5, 0, 0, 6),
            Size = UDim2.fromOffset(ToggleBtnSize, ToggleBtnSize),
            AutoButtonColor = false,
            ZIndex = 10,
            Visible = WindowInfo.ShowToggleButton ~= false,
            Parent = ScreenGui,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ToggleBtnFrame,
        })

        local ToggleBtnOutline = New("UIStroke", {
            Color = Library.Toggled and "AccentColor" or "OutlineColor",
            Thickness = Library.Toggled and 1.5 or 1,
            ZIndex = 2,
            Parent = ToggleBtnFrame,
        })
        New("UIStroke", {
            Color = "DarkColor",
            Thickness = 1.5,
            ZIndex = 1,
            Parent = ToggleBtnFrame,
        })

        local ToggleBtnIcon = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = ToggleBtnTexture,
            ImageColor3 = Color3.new(1, 1, 1),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(ToggleBtnIconSize, ToggleBtnIconSize),
            ZIndex = 10,
            Parent = ToggleBtnFrame,
        })

        local ToggleBtnAnimInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local ToggleBtnFadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local function UpdateToggleButton(SkipAnim)
            local IsOpen = Library.Toggled


            Library.Registry[ToggleBtnOutline].Color = IsOpen and "AccentColor" or "OutlineColor"
            local TargetOutlineColor = GetSchemeValue(IsOpen and "AccentColor" or "OutlineColor")

            if SkipAnim then
                ToggleBtnOutline.Color = TargetOutlineColor
                ToggleBtnOutline.Thickness = IsOpen and 1.5 or 1
            else
                
                TweenService:Create(ToggleBtnOutline, ToggleBtnFadeInfo, {
                    Color = TargetOutlineColor,
                    Thickness = IsOpen and 1.5 or 1,
                }):Play()

                ToggleBtnIcon.Rotation = 0
                ToggleBtnIcon.Size = UDim2.fromOffset(ToggleBtnIconSize - 3, ToggleBtnIconSize - 3)
                TweenService:Create(ToggleBtnIcon, ToggleBtnAnimInfo, {
                    Rotation = 0,
                    Size = UDim2.fromOffset(ToggleBtnIconSize, ToggleBtnIconSize),
                }):Play()
            end
        end

        ToggleBtnFrame.InputBegan:Connect(function(Input: InputObject)
            if not IsClickInput(Input) then
                return
            end

            local Start = os.clock()

            local Changed
            Changed = Input.Changed:Connect(function()
                if Input.UserInputState ~= Enum.UserInputState.End then
                    return
                end

                if os.clock() - Start < 0.25 then
                    Library:Toggle()
                end

                if Changed and Changed.Connected then
                    Changed:Disconnect()
                    Changed = nil
                end
            end)
        end)
        Library:MakeDraggable(ToggleBtnFrame, ToggleBtnFrame, true)

        local OrigToggle = Library.Toggle
        function Library:Toggle(Value)
            OrigToggle(Library, Value)
            UpdateToggleButton(false) 
        end
        
        UpdateToggleButton(true)
    end

    if Library.IsMobile then
        local LockButton = Library:AddDraggableButton("Lock", function(self)
            Library.CantDragForced = not Library.CantDragForced
            self:SetText(Library.CantDragForced and "Unlock" or "Lock")
        end, true, true)

        if WindowInfo.MobileButtonsSide == "Right" then
            LockButton.Button.Position = UDim2.new(1, -6, 0, 46)
            LockButton.Button.AnchorPoint = Vector2.new(1, 0)
        else
            LockButton.Button.Position = UDim2.fromOffset(6, 46)
        end
    end

    --// Execution \\--
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Library:UpdateSearch(SearchBox.Text)
    end)

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Escape then
            if Library.PickingKeybind then Library.PickingKeybind.CancelPicking(); return end
            if Library.ActiveExpandedDropdown then Library.ActiveExpandedDropdown:Collapse(); return end
            if Library.ActiveDialog then Library.ActiveDialog:Dismiss(); return end
            if Library.HistoryOpen then Library:ToggleNotificationHistory(false); return end
            if CurrentMenu then CurrentMenu:Close(); return end
        end
        if UserInputService:GetFocusedTextBox() then return end

        if Input.KeyCode == Enum.KeyCode.RightAlt and Library.ToggleNotificationHistory then
            Library:ToggleNotificationHistory()
            return
        end
        if Input.KeyCode == Enum.KeyCode.Escape and Library.ActiveExpandedDropdown then
            Library.ActiveExpandedDropdown:Collapse()
            return
        end

        if Library.PickingKeybind then return end
        local Bind = Library.ToggleKeybind
        local Matches = Input.KeyCode == Bind
        if typeof(Bind) == "table" and Bind.Type == "KeyPicker" then
            local MouseKeys = { MB1 = Enum.UserInputType.MouseButton1, MB2 = Enum.UserInputType.MouseButton2, MB3 = Enum.UserInputType.MouseButton3 }
            Matches = (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Bind.Value) or MouseKeys[Bind.Value] == Input.UserInputType
            local ModifierKeys = { LAlt = Enum.KeyCode.LeftAlt, RAlt = Enum.KeyCode.RightAlt, LCtrl = Enum.KeyCode.LeftControl, RCtrl = Enum.KeyCode.RightControl, LShift = Enum.KeyCode.LeftShift, RShift = Enum.KeyCode.RightShift, Tab = Enum.KeyCode.Tab, CapsLock = Enum.KeyCode.CapsLock }
            for _, Name in Bind.Modifiers or {} do
                local Key = ModifierKeys[Name]
                if not Key or not UserInputService:IsKeyDown(Key) then Matches = false; break end
            end
        end
        if Matches then Library:Toggle() end
    end))

    Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
        Library.IsRobloxFocused = true
    end))
    Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
        Library.IsRobloxFocused = false
        if Library.PickingKeybind then Library.PickingKeybind.CancelPicking() end
        for _, Option in Options do
            if Option.Type == "KeyPicker" and Option.Mode == "Hold" and Option.Toggled then
                Option.Toggled = false; Option:DoClick(); Option:Update()
            end
        end
    end))

    Library.Window = Window
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
