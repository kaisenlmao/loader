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
    _dirty = false, _generation = 0, _revision = 0, _projectGeneration = 0,
    _preferenceGeneration = 0, _preferencesReady = false, _preferencesWritable = true,
    _preferencesDirty = false, _policyAccepted = false, _disposed = false,
    _preservedCustom = {}, _preservedRecords = {}, StorageDescription = "filesystem",
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
    Message, Kind = tostring(Message), Kind or "Info"
    if self.Library and not self.Library.Unloaded then
        if Kind == "Info" or Kind == "Success" then
            if self.Library.Window and self.Library.Window.SetStatus then self.Library.Window:SetStatus(Message, Kind) end
        else self.Library:Notify({ Title = "Configuration", Description = escaped(Message), Type = Kind }) end
    elseif Kind == "Warning" or Kind == "Error" then warn("Configuration: " .. Message) end
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
    Add(self.Folder); Add(self.Folder .. "/themes"); Add(self:_Directory()); Add(self:_Directory() .. "/.chiyo")
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
    local Ok, Error = validFolder(Folder, false)
    if not Ok then return false, Error end
    if self._operation or self._preferenceWriting or self._loadingPreferences then return false, "cannot switch project during a persistence operation" end
    Folder = Folder:gsub("/+", "/"):gsub("/$", "")
    if self.Folder ~= Folder then self.Folder = Folder; self:_ProjectChanged() end
    local Built, Failure = self:BuildFolderTree()
    self:_RefreshStatus()
    return Built, Failure
end
function SaveManager:SetSubFolder(Folder)
    local Ok, Error = validFolder(Folder, true)
    if not Ok then return false, Error end
    if self._operation or self._preferenceWriting or self._loadingPreferences then return false, "cannot switch project during a persistence operation" end
    Folder = Folder:gsub("/+", "/"):gsub("/$", "")
    if self.SubFolder ~= Folder then self.SubFolder = Folder; self:_ProjectChanged() end
    local Built, Failure = self:BuildFolderTree()
    self:_RefreshStatus()
    return Built, Failure
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
    if self._disposed or self.Library and self.Library.Unloaded then return false, "configuration manager is unloaded" end
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
function SaveManager:_Write(Path, Text, Guard)
    if type(Text) ~= "string" or #Text > self.MaxConfigBytes then return false, "data exceeds MaxConfigBytes or is not a string" end
    local function Allowed()
        return not self._disposed and not (self.Library and self.Library.Unloaded) and (not Guard or Guard())
    end
    if not Allowed() then return false, "write cancelled before mutation" end
    for _, Capability in ipairs({ "isfile", "readfile", "writefile" }) do
        if type(FileSystem[Capability]) ~= "function" then return false, "filesystem capability unavailable: " .. Capability end
    end
    local Ready, Error = self:BuildFolderTree()
    if not Ready then return false, Error end
    local Checked, Exists = invoke("isfile", Path)
    if not Checked then return false, Exists end
    if type(Exists) ~= "boolean" then return false, "isfile returned an invalid result" end
    local Previous
    if Exists then local Read, Raw = self:_Read(Path); if not Read then return false, Raw end; Previous = Raw end
    local function WriteChecked(Target, Value)
        if not Allowed() then return false, "write cancelled; no further file mutations will be made" end
        local Wrote, Failure = invoke("writefile", Target, Value)
        if not Wrote then return false, Failure end
        if not Allowed() then return false, "write invalidated during an external filesystem call; that call cannot be recalled" end
        local Read, Raw = self:_Read(Target)
        if not Read or Raw ~= Value then return false, "write verification failed for " .. Target end
        return true
    end
    local Temp = Path .. ".tmp"
    local Staged, Failure = WriteChecked(Temp, Text)
    if not Staged then if Allowed() then self:_DeleteFile(Temp, true) end; return false, Failure end
    if Previous then
        local BackedUp, BackupError = WriteChecked(Path .. ".bak", Previous)
        if not BackedUp then if Allowed() then self:_DeleteFile(Temp, true) end; return false, "backup failed: " .. tostring(BackupError) end
    end
    local Wrote, WriteError = WriteChecked(Path, Text)
    local CleanupWarning
    if Allowed() then
        local Removed, Reason = self:_DeleteFile(Temp, true)
        if not Removed then CleanupWarning = "Saved bytes were verified, but temporary-file cleanup failed: " .. tostring(Reason) end
    end
    if not Wrote then
        if Allowed() then
            if Previous then
                local Restored = WriteChecked(Path, Previous)
                if not Restored then return false, tostring(WriteError) .. "; restore failed; prior bytes remain in .bak" end
            else self:_DeleteFile(Path, true) end
        end
        return false, WriteError
    end
    return true, CleanupWarning
end
function SaveManager:SetIgnoreIndexes(Indexes)
    for _, Index in ipairs(Indexes) do self.Ignore[Index] = true end
end
function SaveManager:IgnoreThemeSettings()
    self.IgnoreAppearanceTheme = true
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
        if Key ~= "StudioPreferences" and Key ~= "LibraryLayout" and Data.custom and Data.custom[Key] ~= nil and Handler.Validate then
            local Ran, Valid, Error = pcall(Handler.Validate, Data.custom[Key])
            if not Ran or Valid ~= true then return false, "invalid custom data " .. Key .. ": " .. tostring(Error or Valid) end
        end
    end
    return true
end
function SaveManager:_Serialize(Redact)
    if not self.Library then return false, "library is not configured" end
    if self._loading then return false, "cannot serialize a partially applied configuration" end
    local Data = { version = 1, objects = {}, custom = copy(self._preservedCustom or {}) }
    Data.custom.StudioPreferences, Data.custom.LibraryLayout = nil, nil
    local Included = {}
    local function Collect(Registry)
        local Keys = {}
        for Index, Object in pairs(Registry) do if not self.Ignore[Index] and not Object.Internal and not Object.Destroyed and Object.Type and self.Parser[Object.Type] then Keys[#Keys + 1] = Index end end
        table.sort(Keys, function(A, B) return (type(A) .. tostring(A)) < (type(B) .. tostring(B)) end)
        for _, Index in ipairs(Keys) do
            local Object = Registry[Index]
            local Ok, Record = pcall(self.Parser[Object.Type].Save, Index, Object)
            if not Ok or type(Record) ~= "table" then return false, "failed to serialize " .. tostring(Index) .. ": " .. tostring(Record) end
            if Redact and Record.type == "Input" then
                local Lower = tostring(Record.text):lower()
                if Object.Sensitive or Lower:find("discord%.com/api/webhooks/") or Lower:find("discordapp%.com/api/webhooks/") or Lower:find("hooks%.slack%.com/") then Record.text = "" end
            end
            Included[type(Index) .. ":" .. tostring(Index)] = true
            Data.objects[#Data.objects + 1] = Record
        end
        return true
    end
    local Ok, Error = Collect(self.Library.Options)
    if not Ok then return false, Error end
    Ok, Error = Collect(self.Library.Toggles)
    if not Ok then return false, Error end
    for _, Record in ipairs(self._preservedRecords or {}) do
        local Key = type(Record.idx) .. ":" .. tostring(Record.idx)
        if not Included[Key] and not self.Ignore[Record.idx] then Data.objects[#Data.objects + 1] = copy(Record); Included[Key] = true end
    end
    for Key, Handler in pairs(self.CustomData) do
        if Key ~= "StudioPreferences" and Key ~= "LibraryLayout" then
            local Ran, Value = pcall(Handler.Save)
            if not Ran then return false, "failed to serialize custom data " .. Key .. ": " .. tostring(Value) end
            Data.custom[Key] = Value
        end
    end
    if next(Data.custom) == nil then Data.custom = nil end
    local Valid, ValidationError = self:_ValidateConfig(Data)
    if not Valid then return false, ValidationError end
    local Encoded, Text = pcall(HttpService.JSONEncode, HttpService, Data)
    if not Encoded then return false, "failed to encode data: " .. tostring(Text) end
    if #Text > self.MaxConfigBytes then return false, "config exceeds MaxConfigBytes" end
    return true, Text
end
function SaveManager:Save(Name)
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Token, Failure = self:_BeginOperation("save")
    if not Token then return false, Failure end
    local Revision = self._revision
    local Ok, Text = self:_Serialize(false)
    if not Ok then self:_EndOperation(Token); return false, Text end
    if Revision ~= self._revision then self:_EndOperation(Token); return false, "feature settings changed during serialization; retry the save" end
    local Saved, WriteError = self:_Write(Path, Text, function() return self:_OperationValid(Token) end)
    if Saved and self:_OperationValid(Token) then
        if not self._destination then self._destination, self._savedName = Name, Name end
        if self._destination == Name and Revision == self._revision then self._dirty = false end
        self._autoSavePaused, self._lastAutoSaveError = nil, nil
        self.LastSavedConfig, self.LastSaveVerified = Name, true
        self:_Notice("Saved " .. Name .. " (read-back verified; " .. self.StorageDescription .. ")", "Success")
        if WriteError then self:_Notice(WriteError, "Warning") end
    elseif Saved then Saved, WriteError = false, "save completed after the operation was invalidated; current state was not marked clean" end
    self:_EndOperation(Token)
    if Saved and self._dirty then self:_QueueAutoSave() end
    return Saved, WriteError
end
function SaveManager:Export(Redact)
    local Token, Error = self:_BeginOperation("export")
    if not Token then return false, Error end
    local Revision = self._revision
    local Ok, Text = self:_Serialize(Redact ~= false)
    if Ok and (Revision ~= self._revision or not self:_OperationValid(Token)) then Ok, Text = false, "feature settings changed during export; retry the export" end
    self:_EndOperation(Token)
    if self._dirty then self:_QueueAutoSave() end
    return Ok, Text
end
function SaveManager:_LoadCustomData(Custom, Guard)
    if not Custom then return true end
    local Keys = {}
    for Key in pairs(self.CustomData) do if Key ~= "StudioPreferences" and Key ~= "LibraryLayout" then Keys[#Keys + 1] = Key end end
    table.sort(Keys)
    for _, Key in ipairs(Keys) do
        if Custom[Key] ~= nil then
            if Guard and not Guard() then return false, "custom data load was cancelled" end
            local Ok, Result = pcall(self.CustomData[Key].Load, Custom[Key])
            if not Ok or Result == false then return false, "failed to load custom data: " .. Key .. (not Ok and (" (" .. tostring(Result) .. ")") or "") end
        end
    end
    return true
end
function SaveManager:_ApplyConfig(Data)
    if not self.Library then return false, "library is not configured" end
    if self._loading then return false, "a configuration is already loading" end
    if self._operation and self._operation.Kind ~= "load" and self._operation.Kind ~= "import" then return false, "another persistence operation is in progress" end
    local Valid, Error = self:_ValidateConfig(Data)
    if not Valid then return false, Error end
    if self._disposed or self.Library.Unloaded then return false, "configuration manager is unloaded" end
    self:_CancelAutoSave()
    local Library = self.Library
    local Project, Token, PreviousDirty = self._projectGeneration, self._operation, self._dirty
    local PreviousDepth = Library.FeatureLoadDepth or 0
    local CallbackSequence = Library.CallbackErrorSequence or 0
    self._loading, self._loadingLayout = true, true
    Library.FeatureLoadDepth = PreviousDepth + 1
    local AppliedCount, Failure, CustomAttempted = 0, nil, false
    local function Current()
        return not self._disposed and self.Library == Library and self._projectGeneration == Project and not Library.Unloaded and (not Token or self._operation == Token)
    end
    local Ok, Result, Reason = pcall(function()
        for _, TogglePass in ipairs({ false, true }) do
            for _, Record in ipairs(Data.objects) do
                local Parser = self.Parser[Record.type]
                local Target = Record.type == "Toggle" and Library.Toggles[Record.idx] or Library.Options[Record.idx]
                if Parser and Target and not Target.Internal and not Target.Destroyed and not self.Ignore[Record.idx] and (Record.type == "Toggle") == TogglePass then
                    if not Current() then return false, "configuration load was cancelled" end
                    local Ran, LoadError = pcall(Parser.Load, Record.idx, Record)
                    AppliedCount = AppliedCount + 1
                    if not Ran then return false, "failed to apply " .. tostring(Record.idx) .. ": " .. tostring(LoadError) end
                    if (Library.CallbackErrorSequence or 0) ~= CallbackSequence then return false, "a feature callback failed: " .. tostring(Library.LastCallbackError or "see Output") end
                end
            end
        end
        if not Current() then return false, "configuration load was cancelled" end
        for Key in pairs(self.CustomData) do
            if Key ~= "StudioPreferences" and Key ~= "LibraryLayout" and Data.custom and Data.custom[Key] ~= nil then CustomAttempted = true; break end
        end
        local Loaded, LoadError = self:_LoadCustomData(Data.custom, Current)
        if (Library.CallbackErrorSequence or 0) ~= CallbackSequence then return false, "a custom feature callback failed: " .. tostring(Library.LastCallbackError or "see Output") end
        return Loaded, LoadError
    end)
    Library.FeatureLoadDepth = PreviousDepth
    self._loading, self._loadingLayout = false, false
    if not Ok then Failure = tostring(Result) elseif Result ~= true then Failure = tostring(Reason or "configuration could not be fully applied") end
    if not Current() then Failure = Failure or "configuration load was invalidated" end
    if Failure then
        self._dirty = AppliedCount > 0 or CustomAttempted or PreviousDirty
        if AppliedCount > 0 or CustomAttempted then self._revision = self._revision + 1; self._autoSavePaused = "a load partially applied; explicitly load or save a valid profile before autosave resumes" end
        self:_RefreshStatus()
        return false, Failure .. ((AppliedCount > 0 or CustomAttempted) and ("; " .. AppliedCount .. " records were attempted. External callback effects were not rolled back.") or "")
    end
    self._preservedCustom = copy(Data.custom or {})
    self._preservedCustom.StudioPreferences, self._preservedCustom.LibraryLayout = nil, nil
    self._preservedRecords = {}
    for _, Record in ipairs(Data.objects) do
        local Target = Record.type == "Toggle" and Library.Toggles[Record.idx] or Library.Options[Record.idx]
        if not self.Ignore[Record.idx] and not (Target and Target.Internal) and (not self.Parser[Record.type] or not Target) then self._preservedRecords[#self._preservedRecords + 1] = copy(Record) end
    end
    self._dirty, self._autoSavePaused = false, nil
    self._revision = self._revision + 1
    return true
end
function SaveManager:Load(Name, Source)
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Token, Failure = self:_BeginOperation("load")
    if not Token then return false, Failure end
    local Read, Raw = self:_Read(Path)
    if not Read then self:_EndOperation(Token); return false, Raw end
    local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
    if not Decoded then self:_EndOperation(Token); return false, "invalid configuration JSON" end
    if not self:_OperationValid(Token) then self:_EndOperation(Token); return false, "load was invalidated before application" end
    local Applied, ApplyError = self:_ApplyConfig(Data)
    if Applied and self:_OperationValid(Token) then
        self._destination, self._savedName = Name, nil
        self:_SetLastLoadedConfig(Name, Source or "manual")
        self:_Notice("Loaded " .. Name, "Success")
    elseif Applied then Applied, ApplyError = false, "load was invalidated; autosave destination was not changed" end
    self:_EndOperation(Token)
    return Applied, ApplyError
end
function SaveManager:Import(Raw)
    if type(Raw) ~= "string" or Raw:match("^%s*$") then return false, "import data is empty" end
    local Token, Failure = self:_BeginOperation("import")
    if not Token then return false, Failure end
    Raw = Raw:match("^%s*(.-)%s*$")
    if Raw:match("^https?://") then
        local Request = request or http_request or (syn and syn.request)
        if type(Request) ~= "function" then self:_EndOperation(Token); return false, "HTTP request capability unavailable" end
        local Ok, Response = pcall(Request, { Url = Raw, Method = "GET" })
        if not Ok or type(Response) ~= "table" or type(Response.Body) ~= "string" then self:_EndOperation(Token); return false, "failed to fetch configuration URL" end
        local Status = tonumber(Response.StatusCode)
        if Response.Success == false or Status and (Status < 200 or Status >= 300) or not Status and Response.Success ~= true then self:_EndOperation(Token); return false, "configuration URL returned an unsuccessful status" end
        Raw = Response.Body
    end
    if #Raw > self.MaxConfigBytes then self:_EndOperation(Token); return false, "import exceeds MaxConfigBytes" end
    local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
    if not Decoded then self:_EndOperation(Token); return false, "invalid configuration JSON" end
    if not self:_OperationValid(Token) then self:_EndOperation(Token); return false, "import was invalidated before application" end
    local Applied, Error = self:_ApplyConfig(Data)
    if Applied and self:_OperationValid(Token) then
        self._destination, self._savedName, self._dirty = nil, nil, true
        self:_SetLastLoadedConfig("Imported config", "import")
        self:_Notice("Imported settings applied; explicitly save a named profile before autosave can write", "Success")
    elseif Applied then Applied, Error = false, "import was invalidated; destination was not changed" end
    self:_EndOperation(Token)
    return Applied, Error
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
    if not Checked or not Exists then return false, "startup profile does not exist" end
    local Token, Failure = self:_BeginOperation("startup assignment")
    if not Token then return false, Failure end
    local Ok, Reason = self:_Write(self:_Directory() .. "/autoload.txt", Name, function() return self:_OperationValid(Token) end)
    if Ok then self._startupName = Name end
    self:_EndOperation(Token)
    return Ok, Reason
end
function SaveManager:DeleteAutoLoadConfig()
    local Token, Failure = self:_BeginOperation("remove startup assignment")
    if not Token then return false, Failure end
    local Ok, Error = self:_DeleteFile(self:_Directory() .. "/autoload.txt", true)
    if Ok then self._startupName = "none" end
    self:_EndOperation(Token)
    return Ok, Error
end
function SaveManager:GetAutoSaveState()
    local Ok, Value = self:_Read(self:_Directory() .. "/autosave.txt")
    if not Ok then return false, Value ~= "invalid file" and Value or nil end
    if Value ~= "true" and Value ~= "false" then return false, "invalid autosave preference" end
    return Value == "true"
end
function SaveManager:SaveAutoSaveState(Enabled)
    local Token, Failure = self:_BeginOperation("autosave preference")
    if not Token then return false, Failure end
    local Ok, Error = self:_Write(self:_Directory() .. "/autosave.txt", Enabled and "true" or "false", function() return self:_OperationValid(Token) end)
    self:_EndOperation(Token)
    return Ok, Error
end
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
    local Encoded, Raw = pcall(HttpService.JSONEncode, HttpService, Data)
    if not Encoded then return false, "failed to encode account assignments" end
    local Token, Failure = self:_BeginOperation("account assignments")
    if not Token then return false, Failure end
    local Ok, Error = self:_Write(self:_GetAccountConfigsPath(), Raw, function() return self:_OperationValid(Token) end)
    if Ok then local Player = Players.LocalPlayer; self._accountName = Player and Data[Player.Name] or nil end
    self:_EndOperation(Token)
    return Ok, Error
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
    if Error then self:_Notice(Error, "Error"); return false, Error end
    local Name, Source = Account, "account"
    if not Name then
        Name, Error = self:GetAutoloadConfig(); Source = "autoload"
        if Error then self:_Notice(Error, "Error"); return false, Error end
    end
    if Name == "none" then return true end
    local Ok, Failure = self:Load(Name, Source)
    if not Ok then self:_Notice("Failed to load " .. Source .. " profile: " .. tostring(Failure), "Error"); return false, Failure end
    self:_Notice("Loaded " .. Name .. " (" .. Source .. ")", "Success")
    return true
end
function SaveManager:Delete(Name)
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Token, Failure = self:_BeginOperation("delete")
    if not Token then return false, Failure end
    local Autoload = self:GetAutoloadConfig()
    if not self:_OperationValid(Token) then self:_EndOperation(Token); return false, "delete was cancelled" end
    local Deleted, DeleteError = self:_DeleteFile(Path, false)
    if not Deleted then self:_EndOperation(Token); return false, DeleteError end
    local Warnings = {}
    if not self:_OperationValid(Token) then self:_EndOperation(Token); return true, "profile deleted; reference cleanup was cancelled" end
    if self._destination == Name then self._destination, self._savedName, self._dirty = nil, nil, true end
    if self.LastLoadedConfig == Name then self:_SetLastLoadedConfig("none", "none") end
    if Autoload == Name then
        local Ok, Reason = self:_DeleteFile(self:_Directory() .. "/autoload.txt", true)
        if not Ok then Warnings[#Warnings + 1] = tostring(Reason) else self._startupName = "none" end
    end
    local Accounts, AccountError = self:GetAccountConfigs()
    if AccountError then Warnings[#Warnings + 1] = AccountError else
        local Changed = false
        for Account, Config in pairs(Accounts) do if Config == Name then Accounts[Account] = nil; Changed = true end end
        if Changed and self:_OperationValid(Token) then
            local Encoded, Raw = pcall(HttpService.JSONEncode, HttpService, Accounts)
            local Ok, Reason = false, "failed to encode account assignments"
            if Encoded then Ok, Reason = self:_Write(self:_GetAccountConfigsPath(), Raw, function() return self:_OperationValid(Token) end) end
            if not Ok then Warnings[#Warnings + 1] = tostring(Reason) end
        end
    end
    self._accountName = self:GetAccountConfig()
    self:_EndOperation(Token)
    return true, #Warnings > 0 and ("Profile deleted; reference cleanup failed: " .. table.concat(Warnings, "; ")) or nil
end
function SaveManager:_CancelAutoSave()
    self._generation = self._generation + 1
    if self._autoSaveThread then
        if self._autoSaveThread ~= coroutine.running() then pcall(task.cancel, self._autoSaveThread) end
        self._autoSaveThread = nil
    end
end
function SaveManager:_QueueAutoSave()
    self:_CancelAutoSave()
    if not self.AutoSave or not self._dirty or not self._policyAccepted or self._autoSavePaused or not self._destination or not self.Library or self.Library.Unloaded or self._disposed or self._loading or self._operation then return end
    local Generation, Project, Library, Destination = self._generation, self._projectGeneration, self.Library, self._destination
    self._autoSaveThread = task.delay(math.max(0.1, tonumber(self.AutoSaveDelay) or 1), function()
        self._autoSaveThread = nil
        if Generation ~= self._generation or Project ~= self._projectGeneration or Library ~= self.Library or Destination ~= self._destination or Library.Unloaded or self._disposed or not self.AutoSave then return end
        self:FlushAutoSave()
    end)
end
function SaveManager:FlushAutoSave()
    self:_CancelAutoSave()
    if self._disposed or self.Library and self.Library.Unloaded then return false, "configuration manager is unloaded" end
    if not self._dirty or not self.AutoSave then return true end
    if not self._policyAccepted then return false, "acknowledge the last-loaded-profile autosave policy first" end
    if self._autoSavePaused then return false, self._autoSavePaused end
    local Name = self._destination
    if not Name then return false, "no named destination; load or explicitly save a named profile" end
    if self._loading or self._operation or self._preferenceWriting then return false, "another persistence operation is in progress" end
    local Path, Error = self:_ConfigPath(Name)
    if not Path then return false, Error end
    local Checked, Exists = invoke("isfile", Path)
    if not Checked or not Exists then
        self._autoSavePaused = "autosave destination is unavailable; load or save a valid named profile"
        self:_RefreshStatus()
        return false, self._autoSavePaused
    end
    local Ok, Failure = self:Save(Name)
    if not Ok then
        if self._lastAutoSaveError ~= Failure then self._lastAutoSaveError = Failure; self:_Notice("Autosave failed: " .. tostring(Failure), "Error") end
    else self._lastAutoSaveError = nil end
    return Ok, Failure
end
function SaveManager:SetAutoSave(Enabled, Persist)
    Enabled = Enabled == true
    if self._disposed then return false, "configuration manager is unloaded" end
    if not self._preferencesReady and self.Library then self:LoadPreferences() end
    if Enabled and not self._policyAccepted then return false, "acknowledge the last-loaded-profile autosave policy in Settings > Startup" end
    if Persist ~= false then local Ok, Error = self:SaveAutoSaveState(Enabled); if not Ok then return false, Error end end
    self.AutoSave = Enabled
    self:SetupAutoSave()
    if Enabled then self:_QueueAutoSave() else self:_CancelAutoSave() end
    self:_RefreshStatus()
    return true
end
function SaveManager:_HookElement(Index, Element)
    if Element.Internal or self._autoSaveHooked[Element] or self.Ignore[Index] or not self.Parser[Element.Type] then return end
    local Previous, Library = Element.Changed, self.Library
    local Wrapper = function(...)
        if Previous then Library:SafeCallback(Previous, ...) end
        if self.Library == Library then self:MarkDirty() end
    end
    self._autoSaveHooked[Element] = { Previous = Previous, Wrapper = Wrapper }
    Element.Changed = Wrapper
end
function SaveManager:SetupAutoSave()
    if not self.Library then return false, "library is not configured" end
    if self._optionConnection then return true end
    local Observe = self.Library.OnFeatureValueChanged or self.Library.OnOptionChanged
    if type(Observe) == "function" then
        local Library = self.Library
        self._optionConnection = Observe(Library, function(Element)
            if self.Library == Library and not Element.Internal and not self.Ignore[Element.Idx] and self.Parser[Element.Type] then self:MarkDirty() end
        end)
    else
        for Index, Element in pairs(self.Library.Options) do self:_HookElement(Index, Element) end
        for Index, Element in pairs(self.Library.Toggles) do self:_HookElement(Index, Element) end
    end
    return true
end
function SaveManager:_DetachLibrary()
    self:_CancelAutoSave(); self:_CancelPreferences()
    if self._optionConnection then self._optionConnection:Disconnect(); self._optionConnection = nil end
    if self._layoutHookedLibrary and self._layoutHookedLibrary.OnLayoutChanged == self._layoutCallback then self._layoutHookedLibrary.OnLayoutChanged = self._layoutPreviousCallback end
    if self._layoutHookedLibrary and self._layoutHookedLibrary.OnAppearanceReset == self._appearanceResetCallback then self._layoutHookedLibrary.OnAppearanceReset = self._appearanceResetPrevious end
    for Element, Hook in pairs(self._autoSaveHooked) do if Element.Changed == Hook.Wrapper then Element.Changed = Hook.Previous end end
    self._autoSaveHooked = setmetatable({}, { __mode = "k" })
    self._layoutHookedLibrary, self._layoutCallback, self._layoutPreviousCallback = nil, nil, nil
end
function SaveManager:SetLibrary(Library)
    assert(type(Library) == "table" and type(Library.Options) == "table" and type(Library.Toggles) == "table", "Expected a Chiyo-compatible library")
    if self.Library == Library and self._layoutHookedLibrary == Library then return end
    self:_DetachLibrary()
    self.Library, self._dirty, self._disposed = Library, false, false
    self.LastLoadedConfigLabel, self.AutoloadConfigLabel, self.AutoSaveLabel, self.AccountConfigLabel = nil, nil, nil, nil
    self._layoutHookedLibrary = Library
    local Previous = Library.OnLayoutChanged
    self._layoutPreviousCallback = Previous
    self._layoutCallback = function(...)
        if Previous then Library:SafeCallback(Previous, ...) end
        if self.Library == Library and not Library.LayoutRestoring then self:_QueuePreferences() end
    end
    Library.OnLayoutChanged = self._layoutCallback
    self._appearanceResetPrevious = Library.OnAppearanceReset
    self._appearanceResetCallback = function()
        if self._appearanceResetPrevious then Library:SafeCallback(self._appearanceResetPrevious) end
        if self.Library == Library and not self._loadingPreferences then
            self._preferencesWritable, self._preferencesReady = true, true
            self:_QueuePreferences()
        end
    end
    Library.OnAppearanceReset = self._appearanceResetCallback
    self.CustomData.StudioPreferences, self.CustomData.LibraryLayout = nil, nil
    self:SetupAutoSave()
    Library:OnUnload(function()
        if self.Library ~= Library then return end
        self._disposed = true
        self:_DetachLibrary()
        -- No unload-time flush: stale writes and partially applied state must not escape.
    end)
    self:_ProjectChanged()
end
function SaveManager:_SetLastLoadedConfig(Name, Source)
    self.LastLoadedConfig, self.LastLoadedConfigSource = tostring(Name), tostring(Source or "manual")
    self:_RefreshStatus()
end
function SaveManager:_RefreshStatus()
    if not self.Library or self.Library.Unloaded or self._disposed then return end
    local Status = self:GetStatus()
    if self.Library.Window then
        if self.Library.Window.SetPersistenceStatus then self.Library.Window:SetPersistenceStatus(Status)
        elseif self.Library.Window.SetStatus then self.Library.Window:SetStatus((Status.Dirty and "Unsaved / " or "") .. tostring(Status.Profile or "No profile loaded")) end
    end
    if self.LastLoadedConfigLabel then self.LastLoadedConfigLabel:SetText(self.LastLoadedConfig == "none" and "No profile loaded" or ("Loaded: " .. escaped(self.LastLoadedConfig) .. " (" .. escaped(self.LastLoadedConfigSource) .. ")")) end
    if self.AutoloadConfigLabel then self.AutoloadConfigLabel:SetText("Startup profile: " .. escaped(self._startupName or "none")) end
    if self.AutoSaveLabel then self.AutoSaveLabel:SetText("Autosave: " .. escaped(Status.AutoSaveText) .. "\nDestination: " .. escaped(Status.Destination or "none")) end
    if self.AccountConfigLabel then self.AccountConfigLabel:SetText("Account startup assignment: " .. escaped(self._accountName or "none")) end
    if self.PolicyButton then self.PolicyButton:SetVisible(not self._policyAccepted) end
end

function SaveManager:BuildConfigSection(Tab)
    assert(self.Library, "Must call SaveManager:SetLibrary first")
    local Library, Options = self.Library, self.Library.Options
    if not self._preferencesReady then self:LoadPreferences() end
    local Section = Tab:AddRightGroupbox("Settings", "folder-cog")
    Section:SetDescription("Profiles store feature values. Startup assignments and autosave are separate actions. Appearance and window location are stored separately for this project.")
    self.ConfigSection = Section
    local Pages = Section:AddTabbox()
    local Profiles, Startup, Transfer = Pages:AddTab("Profiles", "folder"), Pages:AddTab("Startup", "play"), Pages:AddTab("Import/Export", "arrow-left-right")
    self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_ImportData", "SaveManager_AutoSave", "SaveManager_AccName", "SaveManager_AccConfig", "SaveManager_AccList" })
    local function Internal(Object) Object.Internal = true; return Object end
    local function Report(Ok, Error, Message)
        if not Ok then self:_Notice(tostring(Error), "Error"); return false end
        if Message then self:_Notice(Message, "Success") end
        if Error then self:_Notice(Error, "Warning") end
        return true
    end
    local function Selected() return Options.SaveManager_ConfigList and Options.SaveManager_ConfigList.Value end
    local SelectionButtons = {}
    local Hint
    local function UpdateSelection()
        local Name = Selected()
        for _, Button in ipairs(SelectionButtons) do Button:SetDisabled(Name == nil) end
        if Hint then Hint:SetText(Name and ("Selected: " .. escaped(Name) .. ". Loading is a separate action.") or "Select a profile. Browsing never loads or retargets autosave.") end
    end
    local function Refresh(Keep)
        local Names, Error = self:RefreshConfigList()
        if Options.SaveManager_ConfigList then Options.SaveManager_ConfigList:SetValues(Names); if Keep then Options.SaveManager_ConfigList:SetValue(Keep) end end
        self._startupName, self._startupError = self:GetAutoloadConfig()
        self._accountName = self:GetAccountConfig()
        UpdateSelection(); self:_RefreshStatus()
        if Error then self:_Notice(Error, "Error") end
    end
    Internal(Profiles:AddDropdown("SaveManager_ConfigList", { Text = "Saved profiles", Values = self:RefreshConfigList(), AllowNull = true, Searchable = true, Expandable = false, Placeholder = "Select a profile", EmptyText = "No saved profiles", Callback = UpdateSelection }))
    Hint = Internal(Profiles:AddLabel("Select a profile. Browsing never loads or retargets autosave.", true))
    local function SelectionButton(Text, Callback, Variant, Owner)
        local Button = Internal((Owner or Profiles):AddButton({ Text = Text, Func = Callback, Variant = Variant or "Secondary", WaitForCallback = true, Disabled = true, DisabledTooltip = "Select a saved profile first" }))
        SelectionButtons[#SelectionButtons + 1] = Button
        return Button
    end
    SelectionButton("Load profile", function()
        local Name = Selected(); if not Name then return end
        self:RequestLoad(Name)
    end, "Primary")
    SelectionButton("Overwrite profile", function()
        local Name = Selected(); if not Name then return end
        Library:Confirm({ Title = "Overwrite " .. escaped(Name) .. "?", Description = "Replace its saved feature settings with the current values?", ConfirmText = "Overwrite profile", Callback = function(Confirmed)
            if Confirmed then local Ok, Error = self:Save(Name); Report(Ok, Error) end
        end })
    end)
    SelectionButton("Delete profile", function()
        local Name = Selected(); if not Name then return end
        Library:Confirm({ Title = "Delete " .. escaped(Name) .. "?", Description = "Delete this profile and remove its startup assignments? The current feature values will not be switched off.", ConfirmText = "Delete profile", ConfirmVariant = "Destructive", Callback = function(Confirmed)
            if not Confirmed then return end
            local Ok, Error = self:Delete(Name)
            if Report(Ok, Error, "Deleted " .. Name) then Refresh() end
        end })
    end, "Destructive")
    Internal(Profiles:AddDivider({ Text = "Create a named profile" }))
    local NameField = Internal(Profiles:AddInput("SaveManager_ConfigName", { Text = "New profile name", ClearTextOnFocus = false, Placeholder = "Name the current settings", MaxLength = 128, Tooltip = "Names may use up to 128 UTF-8 bytes and cannot contain path separators or surrounding whitespace." }))
    Internal(Profiles:AddButton({ Text = "Create profile", Variant = "Primary", WaitForCallback = true, Func = function()
        local Name = NameField.Value
        local Path, Error = self:_ConfigPath(Name)
        if not Path then NameField:SetError(Error); return end
        local Checked, Exists = invoke("isfile", Path)
        if not Checked then Report(false, Exists); return end
        if Exists then NameField:SetError("That profile already exists. Select it and use Overwrite profile."); return end
        NameField:SetError(nil)
        local Ok, Failure = self:Save(Name)
        if Report(Ok, Failure, "Created " .. Name .. " (read-back verified)") then Refresh(Name) end
    end }))
    Internal(Profiles:AddButton({ Text = "Refresh profile list", WaitForCallback = true, Func = function() Refresh(Selected()) end }))
    self.LastLoadedConfigLabel = Internal(Profiles:AddLabel("", true))
    self.AutoloadConfigLabel = Internal(Startup:AddLabel("", true))
    SelectionButton("Assign selected profile at startup", function()
        local Name = Selected(); if not Name then return end
        local Ok, Error = self:SaveAutoloadConfig(Name)
        Report(Ok, Error, "Startup profile assigned: " .. Name)
    end, "Secondary", Startup)
    Internal(Startup:AddButton({ Text = "Clear startup assignment", WaitForCallback = true, Func = function()
        local Ok, Error = self:DeleteAutoLoadConfig(); Report(Ok, Error, "Startup assignment cleared")
    end }))
    self.AutoSaveLabel = Internal(Startup:AddLabel("", true))
    local UpdatingAutoSave = false
    local function UpdateAutoToggle()
        UpdatingAutoSave = true
        Library.Toggles.SaveManager_AutoSave:SetValue(self.AutoSave)
        UpdatingAutoSave = false
    end
    local function ReviewPolicy(EnableAfter)
        Library:Confirm({ Title = "Autosave destination policy", Description = "Autosave follows the most recently successfully loaded named profile, including account or startup loading. Loading Testing redirects future autosaves to Testing. Browsing or a failed load never changes the destination. Imported settings require an explicit named save. No unrelated startup profile is used as a fallback.", ConfirmText = "Accept policy", CancelText = "Keep autosave paused", Callback = function(Confirmed)
            if not Confirmed then return end
            local Ok, Error = self:AcknowledgeAutoSavePolicy(true)
            if not Report(Ok, Error, "Autosave destination policy acknowledged") then return end
            if EnableAfter then local Enabled, Failure = self:SetAutoSave(true); Report(Enabled, Failure, "Autosave enabled") end
            UpdateAutoToggle(); self:_RefreshStatus()
        end })
    end
    self.PolicyButton = Internal(Startup:AddButton({ Text = "Review autosave destination policy", Func = function() ReviewPolicy(false) end }))
    Internal(Startup:AddToggle("SaveManager_AutoSave", { Text = "Enable autosave", Default = self.AutoSave,
        Tooltip = "Writes to the last successfully loaded named profile. An explicit named save establishes a destination after import. The footer always reports the actual destination or why writes are paused.", Callback = function(Value)
            if UpdatingAutoSave then return end
            if Value and not self._policyAccepted then UpdateAutoToggle(); ReviewPolicy(true); return end
            local Ok, Error = self:SetAutoSave(Value)
            if not Ok then UpdateAutoToggle(); self:_Notice(Error, "Error") end
        end }))
    self.AccountConfigLabel = Internal(Startup:AddLabel("", true))
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
    Dialog = Library.Window:AddDialog("SaveManager_AccountConfigs", { Title = "Account startup assignments", Description = "An exact-username assignment takes precedence over the project startup profile.", Internal = true, Width = 470, MaxHeight = 360, StartHidden = true, AutoDismiss = false,
        FooterButtons = {
            Close = { Title = "Close", Variant = "Secondary", Order = 1, Callback = function() Dialog:Dismiss() end },
            Remove = { Title = "Remove assignment", Variant = "Destructive", Order = 2, Disabled = true, Callback = function()
                local Item = Options.SaveManager_AccList:GetSelected(); if not Item then return false end
                local Current, Error = self:GetAccountConfigs(); if Error then self:_Notice(Error, "Error"); return false end
                Current[Item.Key] = nil
                local Ok, Failure = self:SaveAccountConfigs(Current)
                if Report(Ok, Failure, "Removed startup assignment for " .. Item.Key) then RefreshAccounts(); Dialog:SetButtonDisabled("Remove", true) end
                return false
            end },
            Save = { Title = "Assign profile", Variant = "Primary", Order = 3, Callback = function()
                local Account, Name = Options.SaveManager_AccName.Value, Options.SaveManager_AccConfig.Value
                if not Account or not Account:match("%S") or Account:find("%s") then Options.SaveManager_AccName:SetError("Enter an exact username without spaces."); return false end
                if not Name then self:_Notice("Select a profile to assign.", "Error"); return false end
                local Current, Error = self:GetAccountConfigs(); if Error then self:_Notice(Error, "Error"); return false end
                Current[Account] = Name
                local Ok, Failure = self:SaveAccountConfigs(Current)
                if Report(Ok, Failure, "Assigned " .. Name .. " to " .. Account) then RefreshAccounts() end
                return false
            end },
        },
    })
    Internal(Dialog:AddList("SaveManager_AccList", { Text = "Assigned accounts", Items = self:_BuildAccountListItems(AccountData), MaxHeight = 140, EmptyText = "No account assignments", Callback = function(Item)
        if not Item then return end
        Options.SaveManager_AccName:SetValue(Item.Key); Options.SaveManager_AccConfig:SetValue(AccountData[Item.Key]); Dialog:SetButtonDisabled("Remove", false)
    end }))
    Internal(Dialog:AddInput("SaveManager_AccName", { Text = "Exact username", Default = Players.LocalPlayer and Players.LocalPlayer.Name or "", ClearTextOnFocus = false, Placeholder = "Username" }))
    Internal(Dialog:AddDropdown("SaveManager_AccConfig", { Text = "Startup profile for this account", Values = self:RefreshConfigList(), AllowNull = true, Searchable = true, Expandable = false }))
    Internal(Startup:AddButton({ Text = "Manage account startup assignments", WaitForCallback = true, Func = function() RefreshAccounts(); Dialog:SetButtonDisabled("Remove", true); Dialog:Show() end }))
    Internal(Transfer:AddLabel("Export contains feature settings, not appearance or window layout. Sensitive inputs are redacted by default. Custom data is not automatically redacted.", true))
    Internal(Transfer:AddButton({ Text = "Export to clipboard", WaitForCallback = true, Func = function()
        local Ok, Text = self:Export()
        if not Ok then self:_Notice(Text, "Error"); return end
        if type(setclipboard) ~= "function" then self:_Notice("Clipboard capability unavailable. SaveManager:Export() still returns the JSON string.", "Error"); return end
        local Copied, Result = pcall(setclipboard, Text)
        Report(Copied and Result ~= false, not Copied and tostring(Result) or Result == false and "clipboard operation was rejected" or nil, "Feature settings copied to clipboard")
    end }))
    Internal(Transfer:AddInput("SaveManager_ImportData", { Text = "Configuration JSON or URL", ClearTextOnFocus = false, Placeholder = "Paste JSON or an HTTP(S) URL" }))
    Internal(Transfer:AddButton({ Text = "Import settings", WaitForCallback = true, Func = function()
        local Raw = Options.SaveManager_ImportData.Value
        Library:Confirm({ Title = "Import feature settings?", Description = (self._dirty and "Apply these settings and discard unsaved changes? " or "Apply these settings? ") .. "Import does not create a named profile or reuse an unrelated autosave destination.", ConfirmText = "Import settings", Callback = function(Confirmed)
            if Confirmed then local Ok, Error = self:Import(Raw); Report(Ok, Error) end
        end })
    end }))
    self:_RefreshStatus(); UpdateSelection()
    return Section
end

function SaveManager:_BeginOperation(Kind)
    if self._disposed or self.Library and self.Library.Unloaded then return nil, "configuration manager is unloaded" end
    if self._operation or self._preferenceWriting or self._loadingPreferences then return nil, "another persistence operation is in progress" end
    self:_CancelAutoSave()
    local Token = { Kind = Kind, Project = self._projectGeneration, Library = self.Library, Directory = self:_Directory() }
    self._operation = Token
    self:_RefreshStatus()
    return Token
end

function SaveManager:_OperationValid(Token)
    return not self._disposed and self._operation == Token and Token.Project == self._projectGeneration and Token.Library == self.Library and not (self.Library and self.Library.Unloaded)
end

function SaveManager:_EndOperation(Token)
    if self._operation == Token then self._operation = nil end
    self:_RefreshStatus()
    if not self._preferencesReady then self:_SchedulePreferenceLoad()
    elseif self._preferencesDirty then self:_QueuePreferences() end
end

function SaveManager:_PreferencesPath()
    return self:_Directory() .. "/.chiyo/ui-v2.json"
end

function SaveManager:GetPreferencesPath() return self:_PreferencesPath() end

function SaveManager:_CancelPreferences()
    self._preferenceGeneration = self._preferenceGeneration + 1
    if self._preferenceThread then pcall(task.cancel, self._preferenceThread); self._preferenceThread = nil end
    if self._preferenceLoadThread then pcall(task.cancel, self._preferenceLoadThread); self._preferenceLoadThread = nil end
end

function SaveManager:_ProjectChanged()
    self:_CancelAutoSave(); self:_CancelPreferences()
    self._projectGeneration = self._projectGeneration + 1
    self._destination, self._savedName, self._autoSavePaused = nil, nil, nil
    self.LastLoadedConfig, self.LastLoadedConfigSource = "none", "none"
    self._preservedCustom, self._preservedRecords = {}, {}
    self._preferencesReady, self._preferencesWritable, self._policyAccepted = false, true, false
    self._preferencesDirty, self._lastPreferenceError = false, nil
    self._startupName, self._accountName, self._startupError = "none", nil, nil
    self:_SchedulePreferenceLoad()
    self:_RefreshStatus()
end

function SaveManager:_SchedulePreferenceLoad()
    if not self.Library or self._disposed then return end
    if self._preferenceLoadThread then pcall(task.cancel, self._preferenceLoadThread) end
    local Generation, Library = self._projectGeneration, self.Library
    self._preferenceLoadThread = task.defer(function()
        self._preferenceLoadThread = nil
        if self.Library == Library and Generation == self._projectGeneration and not Library.Unloaded and not self._disposed then self:LoadPreferences() end
    end)
end

function SaveManager:_PreferenceError(Error)
    self.PreferenceStatus = "not saved: " .. tostring(Error)
    if self._lastPreferenceError ~= Error then self._lastPreferenceError = Error; self:_Notice("UI preferences: " .. tostring(Error), "Warning") end
    self:_RefreshStatus()
end

function SaveManager:LoadPreferences()
    if not self.Library then return false, "library is not configured" end
    if self._disposed or self.Library.Unloaded then return false, "configuration manager is unloaded" end
    if self._preferencesReady then return true end
    if self._operation or self._preferenceWriting then return false, "another persistence operation is in progress" end
    local Library, Generation = self.Library, self._projectGeneration
    self._loadingPreferences = true
    local Read, Raw = self:_Read(self:_PreferencesPath())
    local Record, Error
    if Read then
        local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
        if not Decoded or type(Data) ~= "table" or Data.Version ~= 2 or type(Data.Preferences) ~= "table" or Data.Preferences.Version ~= 2 then Error = "malformed or unsupported UI preference record"
        else
            local Valid, Reason = Library:ValidatePreferences(Data.Preferences)
            if not Valid then Error = Reason
            elseif Data.AutoSavePolicy ~= nil and Data.AutoSavePolicy ~= "last-loaded-named-v1" then Error = "unknown autosave policy acknowledgement"
            else Record = Data end
        end
    elseif Raw ~= "invalid file" then Error = Raw end
    if self.Library ~= Library or Generation ~= self._projectGeneration or Library.Unloaded then self._loadingPreferences = false; return false, "project changed while reading UI preferences" end
    local Previous = Library.LayoutRestoring
    Library.LayoutRestoring = true
    if Record then
        local Applied, Failure = Library:SetPreferences(Record.Preferences)
        if not Applied then Error = Failure else self._policyAccepted = Record.AutoSavePolicy == "last-loaded-named-v1"; self.PreferenceStatus = "restored" end
    else
        -- Migration starts from approved appearance, never old profile-embedded visual data.
        if Library.ResetAppearance then Library:ResetAppearance() end
        if Library.ResetLayout then Library:ResetLayout() end
        self._policyAccepted = false
        self.PreferenceStatus = Error and ("unavailable: " .. tostring(Error)) or "new defaults; not saved yet"
    end
    Library.LayoutRestoring = Previous
    self._loadingPreferences, self._preferencesReady = false, true
    self._preferencesWritable = not Read or Error == nil
    local Desired, AutoError = self:GetAutoSaveState()
    self.AutoSave = Desired == true
    self._startupName, self._startupError = self:GetAutoloadConfig()
    self._accountName = self:GetAccountConfig()
    if Error then self:_PreferenceError(Error)
    elseif not Record then self._preferencesDirty = true; self:_QueuePreferences() end
    if AutoError then self:_Notice(AutoError, "Warning") end
    if self.AutoSave and not self._policyAccepted then self:_Notice("Autosave is paused. Review and acknowledge the last-loaded-profile destination policy in Settings > Startup before writes can resume.", "Warning") end
    self:_RefreshStatus()
    return Error == nil, Error
end

function SaveManager:SavePreferences()
    if not self.Library or not self.Library.GetPreferences then return false, "UI preference capability unavailable" end
    if not self._preferencesReady then return false, "UI preferences have not finished loading" end
    if not self._preferencesWritable then return false, "existing UI preferences are malformed; explicitly reset appearance to replace them" end
    if self._operation or self._preferenceWriting then self._preferencesDirty = true; return false, "another persistence operation is in progress" end
    if self._disposed or self.Library.Unloaded then return false, "configuration manager is unloaded" end
    local Library, Project, Revision = self.Library, self._projectGeneration, self._preferenceGeneration
    local Record = { Version = 2, Preferences = Library:GetPreferences(), AutoSavePolicy = self._policyAccepted and "last-loaded-named-v1" or nil }
    local Valid, Error = Library:ValidatePreferences(Record.Preferences)
    if not Valid then return false, Error end
    local Encoded, Raw = pcall(HttpService.JSONEncode, HttpService, Record)
    if not Encoded then return false, "failed to encode UI preferences: " .. tostring(Raw) end
    self._preferenceWriting = true
    local Ok, Failure = self:_Write(self:_PreferencesPath(), Raw, function() return self.Library == Library and self._projectGeneration == Project and not Library.Unloaded end)
    self._preferenceWriting = false
    if Ok then
        self._preferencesDirty = self._preferenceGeneration ~= Revision
        self._lastPreferenceError, self.PreferenceStatus = nil, "saved and read-back verified (" .. self.StorageDescription .. ")"
    else self:_PreferenceError(Failure) end
    self:_RefreshStatus()
    if Ok and self._preferencesDirty then self:_QueuePreferences() end
    if Ok and Failure then self:_Notice(Failure, "Warning") end
    return Ok, Failure
end

function SaveManager:_QueuePreferences()
    if not self.Library or self.Library.Unloaded or self._disposed or self._loadingPreferences or self.Library.LayoutRestoring then return end
    self._preferencesDirty = true
    if not self._preferencesReady or not self._preferencesWritable then return end
    self._preferenceGeneration = self._preferenceGeneration + 1
    if self._preferenceThread then pcall(task.cancel, self._preferenceThread) end
    local Generation, Project, Library = self._preferenceGeneration, self._projectGeneration, self.Library
    self._preferenceThread = task.delay(0.35, function()
        self._preferenceThread = nil
        if self._preferenceGeneration ~= Generation or self._projectGeneration ~= Project or self.Library ~= Library or Library.Unloaded or self._disposed then return end
        if self._operation or self._preferenceWriting then return end
        local Ok, Error = self:SavePreferences()
        if not Ok and Error then self:_PreferenceError(Error) end
    end)
end

function SaveManager:ResetPreferences()
    if not self.Library then return false, "library is not configured" end
    self._preferencesWritable, self._preferencesReady = true, true
    self._loadingPreferences = true
    self.Library:ResetAppearance()
    self._loadingPreferences = false
    self._preferencesDirty = true
    return self:SavePreferences()
end

function SaveManager:IsAutoSavePolicyAcknowledged() return self._policyAccepted == true end

function SaveManager:AcknowledgeAutoSavePolicy(Accepted)
    if Accepted ~= true then return false, "explicit acknowledgement is required" end
    if not self._preferencesReady then self:LoadPreferences() end
    local Previous = self._policyAccepted
    self._policyAccepted = true
    local Ok, Error = self:SavePreferences()
    if not Ok then self._policyAccepted = Previous; self:_RefreshStatus(); return false, Error end
    self:_RefreshStatus()
    if self.AutoSave and self._dirty then self:_QueueAutoSave() end
    return true
end

function SaveManager:GetDirty() return self._dirty == true end

function SaveManager:MarkDirty()
    if self._loading or self._loadingLayout or self._loadingPreferences or self._disposed or not self.Library or self.Library.Unloaded then return end
    self._revision, self._dirty = self._revision + 1, true
    self:_RefreshStatus()
    self:_QueueAutoSave()
end

function SaveManager:GetAutoSaveDestination() return self._destination end

function SaveManager:GetStatus()
    local Paused = self.AutoSave and (not self._policyAccepted or self._autoSavePaused ~= nil or self._destination == nil)
    local Reason = not self._policyAccepted and "policy acknowledgement required" or self._autoSavePaused or not self._destination and "a named destination is required" or nil
    return { Profile = self.LastLoadedConfig ~= "none" and self.LastLoadedConfig or self._savedName, ProfileSource = self.LastLoadedConfig ~= "none" and self.LastLoadedConfigSource or (self._savedName and "saved" or "none"), Storage = self.StorageDescription, Dirty = self._dirty, AutoSave = self.AutoSave, Destination = self._destination, Paused = Paused, PauseReason = Paused and Reason or nil,
        AutoSaveText = self.AutoSave and (Paused and ("paused: " .. tostring(Reason)) or "enabled; last-loaded named profile") or "disabled", Busy = self._operation ~= nil, Project = self:_Directory(), Preferences = self.PreferenceStatus or "not loaded" }
end

function SaveManager:RequestLoad(Name)
    if not self.Library or not self.Library.Confirm then return false, "confirmation UI is unavailable" end
    local Valid, Error = validName(Name)
    if not Valid then return false, Error end
    local function Apply()
        local Ok, Failure = self:Load(Name)
        if not Ok then self:_Notice(Failure, "Error") end
    end
    if self._dirty then
        return self.Library:Confirm({ Title = "Replace unsaved settings?", Description = "Load " .. escaped(Name) .. " and discard unsaved changes?", ConfirmText = "Load", CancelText = "Cancel", Callback = function(Confirmed) if Confirmed then Apply() end end })
    end
    Apply()
    return true
end

function SaveManager:SetFileSystem(Adapter, Description)
    if type(Adapter) ~= "table" then return false, "filesystem adapter must be a table" end
    if self._operation or self._preferenceWriting then return false, "cannot replace storage during a persistence operation" end
    local Next = {}
    for _, Name in ipairs({ "isfolder", "isfile", "makefolder", "readfile", "writefile", "listfiles", "delfile" }) do
        if Adapter[Name] ~= nil and type(Adapter[Name]) ~= "function" then return false, "invalid filesystem capability: " .. Name end
        Next[Name] = Adapter[Name]
    end
    FileSystem = Next
    self.StorageDescription = tostring(Description or "application-provided storage")
    self:_ProjectChanged()
    return true
end


local Initialized, InitializationError = SaveManager:BuildFolderTree()
if not Initialized then SaveManager.InitializationError = InitializationError end
return SaveManager
