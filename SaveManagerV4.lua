-- Obsidian configuration persistence. No filesystem work is allowed to abort module loading.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local FileSystem = {
    isfolder = isfolder, isfile = isfile, makefolder = makefolder,
    readfile = readfile, writefile = writefile, listfiles = listfiles, delfile = delfile,
}
local SaveManager = {
    Folder = "ObsidianLibSettings", SubFolder = "", Ignore = {}, Library = nil,
    AutoSave = false, AutoSaveDelay = 1, MaxConfigBytes = 1024 * 1024,
    CustomData = {}, LastLoadedConfig = "none", LastLoadedConfigSource = "none",
    _autoSaveHooked = setmetatable({}, { __mode = "k" }), _loading = false, _loadingLayout = false,
    _dirty = false, _generation = 0,
}
local function finite(Value)
    return type(Value) == "number" and Value == Value and Value ~= math.huge and Value ~= -math.huge
end
local function scalar(Value) return type(Value) == "string" or finite(Value) end
local function copy(Value)
    if type(Value) ~= "table" then return Value end
    local Result = {}
    for Key, Item in pairs(Value) do Result[Key] = copy(Item) end
    return Result
end
local function dense(Value, Check)
    if type(Value) ~= "table" then return false end
    local Count = 0
    for Key, Item in pairs(Value) do
        if not finite(Key) or Key < 1 or Key % 1 ~= 0 or (Check and not Check(Item)) then return false end
        Count = Count + 1
    end
    for Index = 1, Count do if Value[Index] == nil then return false end end
    return true
end
local function escaped(Value)
    local Text = tostring(Value)
    Text = Text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"):gsub("'", "&apos;")
    return Text
end
local function invoke(Name, ...)
    local Function = FileSystem[Name]
    if type(Function) ~= "function" then return false, "filesystem capability unavailable: " .. Name end
    local Ok, Result = pcall(Function, ...)
    if not Ok then return false, Name .. " failed: " .. tostring(Result) end
    if Result == false and Name ~= "isfile" and Name ~= "isfolder" then return false, Name .. " failed" end
    return true, Result
end
local function validName(Name)
    if type(Name) ~= "string" or Name == "" then return false, "config name is empty" end
    if #Name > 128 then return false, "config name exceeds 128 bytes" end
    if Name:find('[%c/\\:*?"<>|]') or Name:match("^%s") or Name:match("[%s%.]$") or Name == "." or Name == ".." then
        return false, "config name contains unsupported characters or surrounding whitespace"
    end
    local Lower = Name:lower()
    if Lower == "accountconfigs" or Lower == "none" then return false, "reserved config name" end
    local Stem = Lower:match("^[^.]+") or Lower
    if Stem == "con" or Stem == "prn" or Stem == "aux" or Stem == "nul" or Stem:match("^com[1-9]$") or Stem:match("^lpt[1-9]$") then return false, "reserved filesystem name" end
    return true
end
local function validFolder(Folder, AllowEmpty)
    if type(Folder) ~= "string" or (Folder == "" and not AllowEmpty) then return false, "folder must be a relative path" end
    if Folder:find('[%c\\:*?"<>|]') or Folder:sub(1, 1) == "/" then return false, "folder must be a portable relative path" end
    for Part in Folder:gmatch("[^/]+") do
        if Part == "." or Part == ".." or Part:match("^%s") or Part:match("[%s%.]$") then return false, "invalid folder segment" end
    end
    return true
end
function SaveManager:GetCapabilities()
    local Result = {}
    for _, Name in ipairs({ "isfolder", "isfile", "makefolder", "readfile", "writefile", "listfiles", "delfile" }) do
        Result[Name] = type(FileSystem[Name]) == "function"
    end
    return Result
end
function SaveManager:_Notice(Message, Kind)
    if self.Library and not self.Library.Unloaded then
        self.Library:Notify({ Title = "Configuration", Description = escaped(Message), Type = Kind or "Info" })
    else warn("Configuration: " .. tostring(Message)) end
end
function SaveManager:_Directory()
    return self.Folder .. "/settings" .. (self.SubFolder ~= "" and ("/" .. self.SubFolder) or "")
end
function SaveManager:_ConfigPath(Name)
    local Ok, Err = validName(Name)
    if not Ok then return nil, Err end
    return self:_Directory() .. "/" .. Name .. ".json"
end
function SaveManager:GetPaths()
    local Result, Seen = {}, {}
    local function Add(Path)
        local Current = ""
        for Part in Path:gmatch("[^/]+") do
            Current = Current == "" and Part or Current .. "/" .. Part
            if not Seen[Current] then Seen[Current] = true; Result[#Result + 1] = Current end
        end
    end
    Add(self.Folder); Add(self.Folder .. "/themes"); Add(self:_Directory())
    return Result
end
function SaveManager:BuildFolderTree()
    local Ok, Err = validFolder(self.Folder, false)
    if not Ok then return false, Err end
    Ok, Err = validFolder(self.SubFolder, true)
    if not Ok then return false, Err end
    for _, Path in ipairs(self:GetPaths()) do
        local Checked, Exists = invoke("isfolder", Path)
        if not Checked then return false, Exists end
        if type(Exists) ~= "boolean" then return false, "isfolder returned an invalid result" end
        if not Exists then
            local Created, Error = invoke("makefolder", Path)
            if not Created then return false, Error end
        end
    end
    return true
end
function SaveManager:CheckFolderTree() return self:BuildFolderTree() end
function SaveManager:CheckSubFolder(Create)
    if self.SubFolder == "" then return false end
    if Create then
        local Ok, Err = self:BuildFolderTree()
        if not Ok then return false, Err end
    end
    return true
end
function SaveManager:SetFolder(Folder)
    local Ok, Err = validFolder(Folder, false)
    if not Ok then return false, Err end
    self:_CancelAutoSave(); self._dirty = false
    self.Folder = Folder:gsub("/+", "/"):gsub("/$", "")
    local Built, Error = self:BuildFolderTree()
    self:_RefreshStatus()
    return Built, Error
end
function SaveManager:SetSubFolder(Folder)
    local Ok, Err = validFolder(Folder, true)
    if not Ok then return false, Err end
    self:_CancelAutoSave(); self._dirty = false
    self.SubFolder = Folder:gsub("/+", "/"):gsub("/$", "")
    local Built, Error = self:BuildFolderTree()
    self:_RefreshStatus()
    return Built, Error
end
function SaveManager:_Read(Path)
    local Ok, Exists = invoke("isfile", Path)
    if not Ok then return false, Exists end
    if type(Exists) ~= "boolean" then return false, "isfile returned an invalid result" end
    if not Exists then return false, "invalid file" end
    local Read, Raw = invoke("readfile", Path)
    if not Read then return false, Raw end
    if type(Raw) ~= "string" then return false, "readfile returned non-string data" end
    if #Raw > self.MaxConfigBytes then return false, "file exceeds MaxConfigBytes" end
    return true, Raw
end
function SaveManager:_DeleteFile(Path, MissingOK)
    local Checked, Exists = invoke("isfile", Path)
    if not Checked then return false, Exists end
    if not Exists then if MissingOK then return true end; return false, "invalid file" end
    local Ok, Err = invoke("delfile", Path)
    if not Ok then return false, Err end
    local Verified, StillExists = invoke("isfile", Path)
    if not Verified then return false, StillExists end
    if StillExists then return false, "delete verification failed" end
    return true
end
function SaveManager:_Write(Path, Text)
    if type(Text) ~= "string" or #Text > self.MaxConfigBytes then return false, "data exceeds MaxConfigBytes or is not a string" end
    local Ready, Error = self:BuildFolderTree()
    if not Ready then return false, Error end
    local Checked, Exists = invoke("isfile", Path)
    if not Checked then return false, Exists end
    local Previous
    if Exists then
        local Read, Raw = self:_Read(Path)
        if not Read then return false, Raw end
        Previous = Raw
    end
    local function WriteChecked(Target, Value)
        local Wrote, Err = invoke("writefile", Target, Value)
        if not Wrote then return false, Err end
        local Read, Raw = self:_Read(Target)
        if not Read or Raw ~= Value then return false, "write verification failed for " .. Target end
        return true
    end
    local Temp = Path .. ".tmp"
    local Staged, Err = WriteChecked(Temp, Text)
    if not Staged then self:_DeleteFile(Temp, true); return false, Err end
    if Previous then
        local BackedUp, BackupError = WriteChecked(Path .. ".bak", Previous)
        if not BackedUp then self:_DeleteFile(Temp, true); return false, "backup failed: " .. tostring(BackupError) end
    end
    local Wrote, WriteError = WriteChecked(Path, Text)
    self:_DeleteFile(Temp, true)
    if not Wrote then
        if Previous then
            local Restored = WriteChecked(Path, Previous)
            if not Restored then return false, tostring(WriteError) .. "; restore failed, previous data remains in .bak" end
        else self:_DeleteFile(Path, true) end
        return false, WriteError
    end
    return true
end
function SaveManager:SetIgnoreIndexes(Indexes)
    for _, Index in ipairs(Indexes) do self.Ignore[Index] = true end
end
function SaveManager:IgnoreThemeSettings()
    self:SetIgnoreIndexes({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace", "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName" })
end
function SaveManager:RegisterCustomData(Key, Save, Load, Validate)
    assert(type(Key) == "string" and Key ~= "", "Custom data requires a nonempty key")
    assert(type(Save) == "function" and type(Load) == "function", "Custom data requires save and load callbacks")
    assert(Validate == nil or type(Validate) == "function", "Custom validator must be a function")
    self.CustomData[Key] = { Save = Save, Load = Load, Validate = Validate }
end
local function option(Index) return SaveManager.Library.Options[Index] end
local function encodeChoice(Value)
    if typeof(Value) == "Instance" then return Value.Name end
    return Value
end
local function decodeChoice(Object, Value)
    if Object.SpecialType then
        for _, Candidate in ipairs(Object.Values) do if encodeChoice(Candidate) == Value then return Candidate end end
        return nil
    end
    return Value
end
SaveManager.Parser = {
    Toggle = {
        Save = function(Index, Object) return { type = "Toggle", idx = Index, value = Object.Value } end,
        Load = function(Index, Data) local Object = SaveManager.Library.Toggles[Index]; if Object and Object.Value ~= Data.value then Object:SetValue(Data.value) end end,
    },
    Slider = {
        Save = function(Index, Object) return { type = "Slider", idx = Index, value = tostring(Object.Value) } end,
        Load = function(Index, Data) local Object = option(Index); if Object and Object.Value ~= tonumber(Data.value) then Object:SetValue(Data.value) end end,
    },
    Input = {
        Save = function(Index, Object) return { type = "Input", idx = Index, text = Object.Value } end,
        Load = function(Index, Data) local Object = option(Index); if Object and Object.Value ~= Data.text then Object:SetValue(Data.text) end end,
    },
    ColorPicker = {
        Save = function(Index, Object) return { type = "ColorPicker", idx = Index, value = Object.Value:ToHex(), transparency = Object.Transparency } end,
        Load = function(Index, Data) local Object = option(Index); if Object then Object:SetValueRGB(Color3.fromHex(Data.value), Data.transparency) end end,
    },
    KeyPicker = {
        Save = function(Index, Object) return { type = "KeyPicker", idx = Index, key = Object.Value, mode = Object.Mode, modifiers = copy(Object.Modifiers or {}) } end,
        Load = function(Index, Data) local Object = option(Index); if Object then Object:SetValue({ Data.key, Data.mode, Data.modifiers }) end end,
    },
    Dropdown = {
        Save = function(Index, Object)
            local Value = Object.Value
            if Object.Multi then
                Value = {}
                for _, Candidate in ipairs(Object.Values) do if Object.Value[Candidate] then Value[#Value + 1] = encodeChoice(Candidate) end end
            else Value = encodeChoice(Value) end
            return { type = "Dropdown", idx = Index, value = Value, multi = Object.Multi, special = Object.SpecialType }
        end,
        Load = function(Index, Data)
            local Object = option(Index)
            if not Object then return end
            local Value = Data.value
            if Object.SpecialType then
                if Object.Multi then
                    local Selected = {}
                    if type(Value) == "string" then Value = { Value } end
                    for Key, Item in pairs(Value or {}) do
                        local Candidate = type(Item) == "boolean" and Key or Item
                        local Resolved = decodeChoice(Object, Candidate)
                        if Item ~= false and Resolved then Selected[Resolved] = true end
                    end
                    Value = Selected
                else Value = decodeChoice(Object, Value) end
            end
            Object:SetValue(Value)
        end,
    },
    PriorityDropdown = {
        Save = function(Index, Object) return { type = "PriorityDropdown", idx = Index, order = Object:GetValue() } end,
        Load = function(Index, Data) local Object = option(Index); if Object then Object:SetValue(Data.order) end end,
    },
}
function SaveManager:_ValidateConfig(Data)
    if type(Data) ~= "table" or not dense(Data.objects) then return false, "invalid config root or objects array" end
    if Data.version ~= nil and Data.version ~= 1 then return false, "unsupported config version" end
    if #Data.objects > 10000 then return false, "too many config records" end
    if Data.custom ~= nil and type(Data.custom) ~= "table" then return false, "invalid custom data" end
    local Seen = {}
    for _, Record in ipairs(Data.objects) do
        if type(Record) ~= "table" or type(Record.type) ~= "string" or not scalar(Record.idx) then return false, "invalid config record" end
        local Kind = Record.type
        local Key = type(Record.idx) .. ":" .. tostring(Record.idx)
        if self.Parser[Kind] then
            if Seen[Key] then return false, "duplicate config index: " .. tostring(Record.idx) end
            Seen[Key] = true
        end
        local Target
        if self.Library then
            Target = Kind == "Toggle" and self.Library.Toggles[Record.idx] or self.Library.Options[Record.idx]
        end
        if self.Parser[Kind] and Target and Target.Type ~= Kind and not self.Ignore[Record.idx] then return false, "control type mismatch: " .. tostring(Record.idx) end
        if Kind == "Toggle" and type(Record.value) ~= "boolean" then return false, "invalid toggle value"
        elseif Kind == "Slider" and not ((type(Record.value) == "string" or type(Record.value) == "number") and finite(tonumber(Record.value))) then return false, "invalid slider value"
        elseif Kind == "Input" and type(Record.text) ~= "string" then return false, "invalid input value"
        elseif Kind == "ColorPicker" then
            if type(Record.value) ~= "string" or not Record.value:match("^%x%x%x%x%x%x$") then return false, "invalid color value" end
            if Record.transparency ~= nil and not (finite(Record.transparency) and Record.transparency >= 0 and Record.transparency <= 1) then return false, "invalid transparency" end
        elseif Kind == "KeyPicker" then
            if type(Record.key) ~= "string" or (Record.mode ~= nil and Record.mode ~= "Always" and Record.mode ~= "Toggle" and Record.mode ~= "Hold" and Record.mode ~= "Press") then return false, "invalid keybind value" end
            if Record.modifiers ~= nil and not dense(Record.modifiers, function(Value) return type(Value) == "string" end) then return false, "invalid keybind modifiers" end
            if Record.key ~= "None" and Record.key ~= "Unknown" and Record.key ~= "MB1" and Record.key ~= "MB2" and Record.key ~= "MB3" then
                local Ok, KeyCode = pcall(function() return Enum.KeyCode[Record.key] end)
                if not Ok or KeyCode == nil then return false, "unknown keybind key" end
            end
        elseif Kind == "PriorityDropdown" and not dense(Record.order, scalar) then return false, "invalid priority order"
        elseif Kind == "Dropdown" then
            if Record.multi ~= nil and type(Record.multi) ~= "boolean" then return false, "invalid dropdown multi flag" end
            if Target and Record.multi ~= nil and Target.Multi ~= Record.multi then return false, "dropdown mode mismatch" end
            if (Target and Target.Multi) or Record.multi == true then
                local Value = Record.value
                if type(Value) ~= "string" and not dense(Value, scalar) then
                    if type(Value) ~= "table" then return false, "invalid multiselect value" end
                    for Key2, Active in pairs(Value) do if not scalar(Key2) or type(Active) ~= "boolean" then return false, "invalid multiselect map" end end
                end
            elseif Record.value ~= nil and not scalar(Record.value) and type(Record.value) ~= "boolean" then return false, "invalid dropdown value" end
        end
    end
    for Key, Handler in pairs(self.CustomData) do
        if Data.custom and Data.custom[Key] ~= nil and Handler.Validate then
            local Ran, Valid, Error = pcall(Handler.Validate, Data.custom[Key])
            if not Ran or Valid ~= true then return false, "invalid custom data " .. Key .. ": " .. tostring(Error or Valid) end
        end
    end
    return true
end
function SaveManager:_Serialize(Redact)
    if not self.Library then return false, "library is not configured" end
    local Data = { version = 1, objects = {} }
    local function Collect(Registry)
        local Keys = {}
        for Index, Object in pairs(Registry) do if not self.Ignore[Index] and Object.Type and self.Parser[Object.Type] then Keys[#Keys + 1] = Index end end
        table.sort(Keys, function(A, B) return (type(A) .. tostring(A)) < (type(B) .. tostring(B)) end)
        for _, Index in ipairs(Keys) do
            local Object = Registry[Index]
            local Ok, Record = pcall(self.Parser[Object.Type].Save, Index, Object)
            if not Ok or type(Record) ~= "table" then return false, "failed to serialize " .. tostring(Index) .. ": " .. tostring(Record) end
            if Redact and Record.type == "Input" then
                local Lower = tostring(Record.text):lower()
                if Lower:find("discord%.com/api/webhooks/") or Lower:find("discordapp%.com/api/webhooks/") or Lower:find("hooks%.slack%.com/") then Record.text = "" end
            end
            Data.objects[#Data.objects + 1] = Record
        end
        return true
    end
    -- Options load before toggles so enable callbacks observe the restored settings.
    local Ok, Err = Collect(self.Library.Options)
    if not Ok then return false, Err end
    Ok, Err = Collect(self.Library.Toggles)
    if not Ok then return false, Err end
    if next(self.CustomData) then
        Data.custom = {}
        for Key, Handler in pairs(self.CustomData) do
            local Ran, Value = pcall(Handler.Save)
            if not Ran then return false, "failed to serialize custom data " .. Key .. ": " .. tostring(Value) end
            Data.custom[Key] = Value
        end
    end
    local Valid, Error = self:_ValidateConfig(Data)
    if not Valid then return false, Error end
    local Encoded, Text = pcall(HttpService.JSONEncode, HttpService, Data)
    if not Encoded then return false, "failed to encode data: " .. tostring(Text) end
    if #Text > self.MaxConfigBytes then return false, "config exceeds MaxConfigBytes" end
    return true, Text
end
function SaveManager:Save(Name)
    local Path, Err = self:_ConfigPath(Name)
    if not Path then return false, Err end
    local Ok, Text = self:_Serialize(false)
    if not Ok then return false, Text end
    return self:_Write(Path, Text)
end
function SaveManager:Export(Redact) return self:_Serialize(Redact ~= false) end
function SaveManager:_LoadCustomData(Custom)
    if not Custom then return true end
    local Keys = {}
    for Key in pairs(self.CustomData) do Keys[#Keys + 1] = Key end
    table.sort(Keys)
    for _, Key in ipairs(Keys) do
        if Custom[Key] ~= nil then
            local Ok, Result = pcall(self.CustomData[Key].Load, Custom[Key])
            if not Ok or Result == false then return false, "failed to load custom data: " .. Key .. (not Ok and (" (" .. tostring(Result) .. ")") or "") end
        end
    end
    return true
end
function SaveManager:_ApplyConfig(Data)
    if not self.Library then return false, "library is not configured" end
    if self._loading then return false, "a config is already loading" end
    local Valid, Error = self:_ValidateConfig(Data)
    if not Valid then return false, Error end
    self:_CancelAutoSave()
    self._loading, self._loadingLayout = true, true
    local Ok, Result, Err = pcall(function()
        for _, TogglePass in ipairs({ false, true }) do
            for _, Record in ipairs(Data.objects) do
                local Parser = self.Parser[Record.type]
                if Parser and not self.Ignore[Record.idx] and (Record.type == "Toggle") == TogglePass then
                    local Ran, Failure = pcall(Parser.Load, Record.idx, Record)
                    if not Ran then return false, "failed to load " .. tostring(Record.idx) .. ": " .. tostring(Failure) end
                end
            end
        end
        return self:_LoadCustomData(Data.custom)
    end)
    self._loading, self._loadingLayout, self._dirty = false, false, false
    if not Ok then return false, tostring(Result) end
    return Result, Err
end
function SaveManager:Load(Name, Source)
    local Path, Err = self:_ConfigPath(Name)
    if not Path then return false, Err end
    local Read, Raw = self:_Read(Path)
    if not Read then return false, Raw end
    local Ok, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
    if not Ok then return false, "decode error" end
    local Applied, Error = self:_ApplyConfig(Data)
    if not Applied then return false, Error end
    self:_SetLastLoadedConfig(Name, Source or "manual")
    return true
end
function SaveManager:Import(Raw)
    if type(Raw) ~= "string" or Raw:match("^%s*$") then return false, "import data is empty" end
    Raw = Raw:match("^%s*(.-)%s*$")
    if Raw:match("^https?://") then
        local Request = request or http_request or (syn and syn.request)
        if type(Request) ~= "function" then return false, "HTTP request capability unavailable" end
        local Ok, Response = pcall(Request, { Url = Raw, Method = "GET" })
        if not Ok or type(Response) ~= "table" or type(Response.Body) ~= "string" then return false, "failed to fetch config URL" end
        local Status = tonumber(Response.StatusCode)
        if Response.Success == false or (Status and (Status < 200 or Status >= 300)) or (not Status and Response.Success ~= true) then return false, "config URL returned an unsuccessful status" end
        Raw = Response.Body
    end
    if #Raw > self.MaxConfigBytes then return false, "import exceeds MaxConfigBytes" end
    local Ok, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
    if not Ok then return false, "invalid config JSON" end
    local Applied, Err = self:_ApplyConfig(Data)
    if not Applied then return false, Err end
    self:_SetLastLoadedConfig("Imported config", "import")
    return true
end
function SaveManager:RefreshConfigList()
    local Ready, Error = self:BuildFolderTree()
    if not Ready then return {}, Error end
    local Ok, Files = invoke("listfiles", self:_Directory())
    if not Ok or type(Files) ~= "table" then return {}, "failed to list configuration files" end
    local Names, Seen = {}, {}
    for _, File in ipairs(Files) do
        if type(File) == "string" then
            local Leaf = File:gsub("\\", "/"):match("([^/]+)$")
            local Name = Leaf and Leaf:match("^(.*)%.json$")
            if Name and validName(Name) and not Seen[Name] then Seen[Name] = true; Names[#Names + 1] = Name end
        end
    end
    table.sort(Names, function(A, B) if A:lower() == B:lower() then return A < B end; return A:lower() < B:lower() end)
    return Names
end
function SaveManager:GetAutoloadConfig()
    local Ok, Name = self:_Read(self:_Directory() .. "/autoload.txt")
    if not Ok then return "none", Name ~= "invalid file" and Name or nil end
    local Valid, Error = validName(Name)
    if not Valid then return "none", "invalid autoload marker: " .. tostring(Error) end
    local Path = self:_ConfigPath(Name)
    local Checked, Exists = invoke("isfile", Path)
    if not Checked then return "none", Exists end
    if type(Exists) ~= "boolean" then return "none", "isfile returned an invalid result" end
    if not Exists then return "none", "autoload profile does not exist: " .. Name end
    return Name
end
function SaveManager:SaveAutoloadConfig(Name)
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Checked, Exists = invoke("isfile", Path)
    if not Checked or not Exists then return false, "autoload config does not exist" end
    local Ok, Err = self:_Write(self:_Directory() .. "/autoload.txt", Name)
    if Ok then self:_RefreshStatus(); if self._dirty then self:_QueueAutoSave() end end
    return Ok, Err
end
function SaveManager:DeleteAutoLoadConfig()
    self:_CancelAutoSave()
    local Ok, Err = self:_DeleteFile(self:_Directory() .. "/autoload.txt", true)
    if Ok then self:_RefreshStatus() end
    return Ok, Err
end
function SaveManager:GetAutoSaveState()
    local Ok, Value = self:_Read(self:_Directory() .. "/autosave.txt")
    if not Ok then return false, Value ~= "invalid file" and Value or nil end
    if Value ~= "true" and Value ~= "false" then return false, "invalid autosave preference" end
    return Value == "true"
end
function SaveManager:SaveAutoSaveState(Enabled) return self:_Write(self:_Directory() .. "/autosave.txt", Enabled and "true" or "false") end
function SaveManager:_GetAccountConfigsPath() return self:_Directory() .. "/accountconfigs.json" end
function SaveManager:GetAccountConfigs()
    local Ok, Raw = self:_Read(self:_GetAccountConfigsPath())
    if not Ok then return {}, Raw ~= "invalid file" and Raw or nil end
    local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
    if not Decoded or type(Data) ~= "table" then return {}, "invalid account config data" end
    for Account, Name in pairs(Data) do
        if type(Account) ~= "string" or Account == "" or not validName(Name) then return {}, "invalid account assignment" end
    end
    return Data
end
function SaveManager:SaveAccountConfigs(Data)
    if type(Data) ~= "table" then return false, "account configs must be a table" end
    for Account, Name in pairs(Data) do
        if type(Account) ~= "string" or Account == "" or not validName(Name) then return false, "invalid account assignment" end
    end
    local Ok, Raw = pcall(HttpService.JSONEncode, HttpService, Data)
    if not Ok then return false, "failed to encode account configs" end
    local Saved, Err = self:_Write(self:_GetAccountConfigsPath(), Raw)
    if Saved then self:_RefreshStatus() end
    return Saved, Err
end
function SaveManager:GetAccountConfig()
    local Data, Err = self:GetAccountConfigs()
    local Player = Players.LocalPlayer
    return Player and Data[Player.Name] or nil, Err
end
function SaveManager:_BuildAccountListItems(Data)
    local Items = {}
    for Account, Name in pairs(Data) do Items[#Items + 1] = { Key = Account, Display = Account .. " → " .. Name } end
    table.sort(Items, function(A, B) return A.Key:lower() < B.Key:lower() end)
    return Items
end
function SaveManager:LoadAutoloadConfig()
    local Account, Error = self:GetAccountConfig()
    if Error then return false, Error end
    local Name, Source = Account, "account"
    if not Name then
        Name, Error = self:GetAutoloadConfig()
        Source = "autoload"
        if Error then self:_Notice(Error, "Error"); return false, Error end
    end
    if Name == "none" then return true end
    local Ok, Err = self:Load(Name, Source)
    if not Ok then self:_Notice("Failed to load " .. Source .. " config: " .. tostring(Err), "Error"); return false, Err end
    self:_Notice("Loaded " .. Name .. " (" .. Source .. ")")
    return true
end
function SaveManager:Delete(Name)
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Autoload = self:GetAutoloadConfig()
    local Deleted, Err = self:_DeleteFile(Path, false)
    if not Deleted then return false, Err end
    self:_CancelAutoSave()
    local Warnings = {}
    if Autoload == Name then local Ok, Failure = self:DeleteAutoLoadConfig(); if not Ok then Warnings[#Warnings + 1] = tostring(Failure) end end
    local Accounts, AccountError = self:GetAccountConfigs()
    if AccountError then Warnings[#Warnings + 1] = AccountError else
        local Changed = false
        for Account, Config in pairs(Accounts) do if Config == Name then Accounts[Account] = nil; Changed = true end end
        if Changed then local Ok, Failure = self:SaveAccountConfigs(Accounts); if not Ok then Warnings[#Warnings + 1] = tostring(Failure) end end
    end
    if self.LastLoadedConfig == Name then self:_SetLastLoadedConfig("none", "none") end
    self:_RefreshStatus()
    return true, #Warnings > 0 and ("Config deleted; reference cleanup failed: " .. table.concat(Warnings, "; ")) or nil
end
function SaveManager:_CancelAutoSave()
    self._generation = self._generation + 1
    if self._autoSaveThread then pcall(task.cancel, self._autoSaveThread); self._autoSaveThread = nil end
end
function SaveManager:_QueueAutoSave()
    if not self.AutoSave or not self.Library or self.Library.Unloaded or self._loading or self._loadingLayout then return end
    self._dirty = true
    self:_CancelAutoSave()
    local Destination, DestinationError = self:GetAutoloadConfig()
    if DestinationError then
        if self._lastAutoSaveError ~= DestinationError then self._lastAutoSaveError = DestinationError; self:_Notice(DestinationError, "Error") end
        return
    end
    if Destination == "none" then return end
    local Generation, Library = self._generation, self.Library
    self._autoSaveThread = task.delay(self.AutoSaveDelay, function()
        self._autoSaveThread = nil
        if Generation ~= self._generation or Library ~= self.Library or Library.Unloaded or not self.AutoSave then return end
        self:FlushAutoSave()
    end)
end
function SaveManager:FlushAutoSave()
    self:_CancelAutoSave()
    if not self._dirty or not self.AutoSave or self._loading then return true end
    local Name, DestinationError = self:GetAutoloadConfig()
    if DestinationError then return false, DestinationError end
    if Name == "none" then return false, "set an autoload config before enabling autosave" end
    local Ok, Err = self:Save(Name)
    if Ok then self._dirty = false; self._lastAutoSaveError = nil
    elseif self._lastAutoSaveError ~= Err then self._lastAutoSaveError = Err; self:_Notice("Auto save failed: " .. tostring(Err), "Error") end
    return Ok, Err
end
function SaveManager:SetAutoSave(Enabled, Persist)
    Enabled = Enabled == true
    if Persist ~= false then local Ok, Err = self:SaveAutoSaveState(Enabled); if not Ok then return false, Err end end
    self.AutoSave = Enabled
    if Enabled then self:SetupAutoSave() else self:_CancelAutoSave(); self._dirty = false end
    self:_RefreshStatus()
    return true
end
function SaveManager:_HookElement(Index, Element)
    if self._autoSaveHooked[Element] or self.Ignore[Index] or not self.Parser[Element.Type] then return end
    local Previous, Library = Element.Changed, self.Library
    local Wrapper = function(...)
        if Previous then Library:SafeCallback(Previous, ...) end
        if self.Library == Library then self:_QueueAutoSave() end
    end
    self._autoSaveHooked[Element] = { Previous = Previous, Wrapper = Wrapper }
    Element.Changed = Wrapper
end
function SaveManager:SetupAutoSave()
    if not self.Library then return false, "library is not configured" end
    if self._optionConnection then return true end
    if type(self.Library.OnOptionChanged) == "function" then
        local Library = self.Library
        self._optionConnection = Library:OnOptionChanged(function(Element)
            if self.Library == Library and not self.Ignore[Element.Idx] and self.Parser[Element.Type] then self:_QueueAutoSave() end
        end)
    else
        -- Compatibility fallback for older libraries. Re-run after adding controls there.
        for Index, Element in pairs(self.Library.Options) do self:_HookElement(Index, Element) end
        for Index, Element in pairs(self.Library.Toggles) do self:_HookElement(Index, Element) end
    end
    return true
end
function SaveManager:_DetachLibrary()
    self:_CancelAutoSave()
    if self._optionConnection then self._optionConnection:Disconnect(); self._optionConnection = nil end
    if self._layoutHookedLibrary and self._layoutHookedLibrary.OnLayoutChanged == self._layoutCallback then self._layoutHookedLibrary.OnLayoutChanged = self._layoutPreviousCallback end
    for Element, Hook in pairs(self._autoSaveHooked) do if Element.Changed == Hook.Wrapper then Element.Changed = Hook.Previous end end
    self._autoSaveHooked = setmetatable({}, { __mode = "k" })
    self._layoutHookedLibrary, self._layoutCallback, self._layoutPreviousCallback = nil, nil, nil
end
function SaveManager:SetLibrary(Library)
    assert(type(Library) == "table" and type(Library.Options) == "table" and type(Library.Toggles) == "table", "Expected an Obsidian library")
    if self.Library == Library and self._layoutHookedLibrary == Library then return end
    self:_DetachLibrary()
    self.Library, self._dirty = Library, false
    self.LastLoadedConfigLabel, self.AutoloadConfigLabel, self.AutoSaveLabel, self.AccountConfigLabel = nil, nil, nil, nil
    self.LastLoadedConfig, self.LastLoadedConfigSource = "none", "none"
    self._layoutHookedLibrary = Library
    local Previous = Library.OnLayoutChanged
    self._layoutPreviousCallback = Previous
    self._layoutCallback = function(...)
        if Previous then Library:SafeCallback(Previous, ...) end
        if self.Library == Library and not Library.LayoutRestoring then self:_QueueAutoSave() end
    end
    Library.OnLayoutChanged = self._layoutCallback
    self.CustomData.LibraryLayout = nil
    if type(Library.GetLayout) == "function" and type(Library.SetLayout) == "function" then
        self:RegisterCustomData("LibraryLayout", function() return Library:GetLayout() end,
            function(Data) return Library:SetLayout(Data) end,
            function(Data) if type(Library.ValidateLayout) == "function" then return Library:ValidateLayout(Data) end; return type(Data) == "table" end)
    end
    Library:OnUnload(function()
        if self.Library ~= Library then return end
        self:FlushAutoSave()
        self:_DetachLibrary()
    end)
    if self.AutoSave then self:SetupAutoSave() end
end
function SaveManager:_SetLastLoadedConfig(Name, Source)
    self.LastLoadedConfig, self.LastLoadedConfigSource = tostring(Name), tostring(Source or "manual")
    self:_RefreshStatus()
end
function SaveManager:_RefreshStatus()
    if self.Library and self.Library.Unloaded then return end
    if self.LastLoadedConfigLabel then self.LastLoadedConfigLabel:SetText("<font color='#9AA0A6'>Last loaded:</font> <font color='#8FD0FF'>" .. escaped(self.LastLoadedConfig) .. "</font> <font color='#9AA0A6'>— " .. escaped(self.LastLoadedConfigSource) .. "</font>") end
    local Autoload, AutoloadError = self:GetAutoloadConfig()
    if self.AutoloadConfigLabel then self.AutoloadConfigLabel:SetText("Autoload: " .. (AutoloadError and escaped(AutoloadError) or escaped(Autoload))) end
    if self.AutoSaveLabel then self.AutoSaveLabel:SetText("Auto save: " .. (self.AutoSave and (Autoload ~= "none" and escaped(Autoload) or "no destination — set autoload") or "disabled")) end
    if self.AccountConfigLabel then self.AccountConfigLabel:SetText("Account config: " .. escaped(self:GetAccountConfig() or "none")) end
end

function SaveManager:BuildConfigSection(Tab)
    assert(self.Library, "Must call SaveManager:SetLibrary first")
    local Library = self.Library
    local Options = Library.Options
    local Section = Tab:AddRightGroupbox("Configuration", "folder-cog")
    self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_ImportData", "SaveManager_AutoSave", "SaveManager_AccName", "SaveManager_AccConfig", "SaveManager_AccList" })
    local function Report(Ok, Error, Message)
        if not Ok then self:_Notice(tostring(Error), "Error"); return false end
        self:_Notice(Message, "Success")
        if Error then self:_Notice(Error, "Warning") end
        return true
    end
    local function Selected() return Options.SaveManager_ConfigList.Value end
    local SelectionButtons = {}
    local function UpdateSelection()
        local Disabled = Selected() == nil
        for _, Button in ipairs(SelectionButtons) do Button:SetDisabled(Disabled) end
    end
    local function Refresh(Keep)
        local Names, Error = self:RefreshConfigList()
        Options.SaveManager_ConfigList:SetValues(Names)
        if Keep then Options.SaveManager_ConfigList:SetValue(Keep) end
        UpdateSelection()
        self:_RefreshStatus()
        if Error then self:_Notice(Error, "Error") end
    end
    Section:AddDivider({ Text = "Profiles" })
    Section:AddInput("SaveManager_ConfigName", { Text = "Config name", ClearTextOnFocus = false, Placeholder = "Name a new profile", MaxLength = 128 })
    Section:AddButton("Create config", function()
        local Name = Options.SaveManager_ConfigName.Value
        local Path, Error = self:_ConfigPath(Name)
        if not Path then self:_Notice(Error, "Error"); return end
        local Checked, Exists = invoke("isfile", Path)
        if not Checked then self:_Notice(Exists, "Error"); return end
        if Exists then self:_Notice("That profile already exists. Select it and use Overwrite config.", "Warning"); return end
        local Ok, Err = self:Save(Name)
        if Report(Ok, Err, "Created " .. Name) then Refresh(Name) end
    end)
    Section:AddDropdown("SaveManager_ConfigList", {
        Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true, Searchable = true,
        Callback = UpdateSelection,
    })
    local function SelectionButton(Text, Callback, Risky)
        local Button = Section:AddButton({ Text = Text, Func = Callback, Disabled = true, Risky = Risky == true, DisabledTooltip = "Select a config first" })
        SelectionButtons[#SelectionButtons + 1] = Button
        return Button
    end
    SelectionButton("Load config", function()
        local Name = Selected()
        if not Name then return end
        local Ok, Err = self:Load(Name)
        Report(Ok, Err, "Loaded " .. Name)
    end)
    SelectionButton("Overwrite config", function()
        local Name = Selected()
        if not Name then return end
        Library:Confirm({ Title = "Overwrite config?", Description = "Replace the saved settings in " .. escaped(Name) .. " with the current settings?", ConfirmText = "Overwrite", Callback = function(Confirmed)
            if not Confirmed then return end
            local Ok, Err = self:Save(Name)
            Report(Ok, Err, "Saved " .. Name)
        end })
    end)
    SelectionButton("Delete config", function()
        local Name = Selected()
        if not Name then return end
        Library:Confirm({ Title = "Delete config?", Description = "Delete " .. escaped(Name) .. " and remove its automatic-loading assignments?", ConfirmText = "Delete", ConfirmVariant = "Destructive", Callback = function(Confirmed)
            if not Confirmed then return end
            local Ok, Err = self:Delete(Name)
            if Report(Ok, Err, "Deleted " .. Name) then Refresh() end
        end })
    end, true)
    Section:AddButton("Refresh list", function() Refresh(Selected()) end)
    self.LastLoadedConfigLabel = Section:AddLabel("", true)
    Section:AddDivider({ Text = "Automatic loading" })
    SelectionButton("Set as autoload", function()
        local Name = Selected()
        if not Name then return end
        local Ok, Err = self:SaveAutoloadConfig(Name)
        Report(Ok, Err, "Autoload set to " .. Name)
    end)
    Section:AddButton("Reset autoload", function()
        local Ok, Err = self:DeleteAutoLoadConfig()
        Report(Ok, Err, "Autoload cleared")
    end)
    self.AutoloadConfigLabel = Section:AddLabel("", true)
    self.AutoSaveLabel = Section:AddLabel("", true)
    local PreferenceError
    self.AutoSave, PreferenceError = self:GetAutoSaveState()
    if PreferenceError then self:_Notice(PreferenceError, "Error") end
    local UpdatingAutoSave = false
    Section:AddToggle("SaveManager_AutoSave", {
        Text = "Auto Save Config", Default = self.AutoSave,
        Tooltip = "Saves to the autoload profile, not the last manually loaded or account profile.",
        Callback = function(Value)
            if UpdatingAutoSave then return end
            local Ok, Err = self:SetAutoSave(Value)
            if not Ok then
                UpdatingAutoSave = true
                Library.Toggles.SaveManager_AutoSave:SetValue(self.AutoSave)
                UpdatingAutoSave = false
                self:_Notice(Err, "Error")
            end
        end,
    })
    if self.AutoSave then self:SetupAutoSave() end
    self.AccountConfigLabel = Section:AddLabel("", true)
    local AccountData, AccountReadError = self:GetAccountConfigs()
    local Dialog
    local function RefreshAccounts()
        local Data, Error = self:GetAccountConfigs()
        AccountReadError = Error
        if Error then self:_Notice(Error, "Error"); return false end
        AccountData = Data
        Options.SaveManager_AccList:SetItems(self:_BuildAccountListItems(Data))
        Options.SaveManager_AccConfig:SetValues(self:RefreshConfigList())
        return true
    end
    Dialog = Library.Window:AddDialog("SaveManager_AccountConfigs", {
        Title = "Account Configs", Description = "Account assignments take priority over autoload. Use exact usernames.",
        Width = 400, MaxHeight = 300, StartHidden = true, AutoDismiss = false,
        FooterButtons = {
            Close = { Title = "Close", Variant = "Ghost", Order = 1, Callback = function() Dialog:Dismiss() end },
            Remove = { Title = "Remove", Variant = "Destructive", Order = 2, Disabled = true, Callback = function()
                local Item = Options.SaveManager_AccList:GetSelected()
                if not Item then return false end
                local Current, Error = self:GetAccountConfigs()
                if Error then self:_Notice(Error, "Error"); return false end
                Current[Item.Key] = nil
                local Ok, Err = self:SaveAccountConfigs(Current)
                if Report(Ok, Err, "Removed assignment for " .. Item.Key) then RefreshAccounts(); Dialog:SetButtonDisabled("Remove", true) end
                return false
            end },
            Save = { Title = "Assign", Variant = "Primary", Order = 3, Callback = function()
                local Account = Options.SaveManager_AccName.Value
                local Config = Options.SaveManager_AccConfig.Value
                if not Account or not Account:match("%S") or Account:find("%s") then self:_Notice("Enter an exact username without spaces.", "Error"); return false end
                if not Config then self:_Notice("Select a config first.", "Error"); return false end
                local Current, Error = self:GetAccountConfigs()
                if Error then self:_Notice(Error, "Error"); return false end
                Current[Account] = Config
                local Ok, Err = self:SaveAccountConfigs(Current)
                if Report(Ok, Err, "Assigned " .. Config .. " to " .. Account) then RefreshAccounts() end
                return false
            end },
        },
    })
    Dialog:AddList("SaveManager_AccList", { Text = "Assigned accounts", Items = self:_BuildAccountListItems(AccountData), MaxHeight = 120, EmptyText = "No account assignments", Callback = function(Item)
        Options.SaveManager_AccName:SetValue(Item.Key)
        Options.SaveManager_AccConfig:SetValue(AccountData[Item.Key])
        Dialog:SetButtonDisabled("Remove", false)
    end })
    Dialog:AddInput("SaveManager_AccName", { Text = "Account name", Default = Players.LocalPlayer and Players.LocalPlayer.Name or "", ClearTextOnFocus = false, Placeholder = "Exact username" })
    Dialog:AddDropdown("SaveManager_AccConfig", { Text = "Config to load", Values = self:RefreshConfigList(), AllowNull = true, Searchable = true })
    Section:AddButton("Account configs", function() RefreshAccounts(); Dialog:SetButtonDisabled("Remove", true); Dialog:Show() end)
    Section:AddDivider({ Text = "Layout and transfer" })
    Section:AddButton("Reset layout", function() Library:ResetLayout() end)
    Section:AddButton("Export config", function()
        local Ok, Text = self:Export()
        if not Ok then self:_Notice(Text, "Error"); return end
        if type(setclipboard) ~= "function" then self:_Notice("Clipboard capability unavailable.", "Error"); return end
        local Copied, Error = pcall(setclipboard, Text)
        Report(Copied, not Copied and tostring(Error) or nil, "Config exported to clipboard")
    end)
    Section:AddInput("SaveManager_ImportData", { Text = "Import Config", ClearTextOnFocus = false, Placeholder = "Paste config JSON or an HTTP(S) URL" })
    Section:AddButton("Import config", function()
        local Raw = Options.SaveManager_ImportData.Value
        Library:Confirm({ Title = "Import config?", Description = "Apply these settings to the current UI? Importing does not create a saved profile.", ConfirmText = "Import", Callback = function(Confirmed)
            if not Confirmed then return end
            local Ok, Err = self:Import(Raw)
            Report(Ok, Err, "Config imported")
        end })
    end)
    self:_RefreshStatus()
    UpdateSelection()
    return Section
end

local Initialized, InitializationError = SaveManager:BuildFolderTree()
if not Initialized then SaveManager.InitializationError = InitializationError end
return SaveManager
