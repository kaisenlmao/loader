local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = clonefunction or copyfunction

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local request = request or http_request or (syn and syn.request) or (http and http.request)
local setclipboard = setclipboard or toclipboard or set_clipboard

local function CloneExecutorFunction(func)
    if typeof(func) ~= "function" then
        return nil
    end

    if typeof(clonefunction) ~= "function" then
        return func
    end

    local success, cloned = pcall(clonefunction, func)
    if success and typeof(cloned) == "function" then
        return cloned
    end

    return func
end

local makefolder = CloneExecutorFunction(makefolder)
local writefile = CloneExecutorFunction(writefile)
local readfile = CloneExecutorFunction(readfile)
local delfile = CloneExecutorFunction(delfile)
local isfolder = CloneExecutorFunction(isfolder)
local isfile = CloneExecutorFunction(isfile)
local listfiles = CloneExecutorFunction(listfiles)

local function SafeIsFolder(folder)
    if typeof(isfolder) ~= "function" then
        return false
    end

    local success, result = pcall(isfolder, folder)
    return success and result == true
end

local function SafeIsFile(file)
    if typeof(isfile) ~= "function" then
        return false
    end

    local success, result = pcall(isfile, file)
    return success and result == true
end

local function SafeListFiles(folder)
    if typeof(listfiles) ~= "function" then
        return {}
    end

    local success, result = pcall(listfiles, folder)
    if success and typeof(result) == "table" then
        return result
    end

    return {}
end

local function SafeMakeFolder(folder)
    if typeof(makefolder) ~= "function" then
        return false, "makefolder is unavailable"
    end

    local success, err = pcall(makefolder, folder)
    if not success then
        return false, tostring(err)
    end

    return true
end

local SaveManager = {} do
    SaveManager.Folder = "ObsidianLibSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.AutoSave = false
    SaveManager._autoSaveThread = nil
    SaveManager._autoSaveHooked = {}
    SaveManager.CustomData = {}
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = "Toggle", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                local numValue = tonumber(data.value)
                if object and numValue and object.Value ~= numValue then
                    object:SetValue(numValue)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = "ColorPicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if not object then return end
                if typeof(data.value) ~= "string" then return end
                local ok, color = pcall(Color3.fromHex, data.value)
                if not ok or typeof(color) ~= "Color3" then return end
                local transparency = data.transparency
                if typeof(transparency) ~= "number" then
                    transparency = nil
                end
                object:SetValueRGB(color, transparency)
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = "KeyPicker", idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == "string" then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    local function TrimString(value)
        return tostring(value):match("^%s*(.-)%s*$")
    end

    local function NormalizeConfigName(name)
        if typeof(name) ~= "string" then
            return nil, "no config file is selected"
        end

        name = TrimString(name)
        if name == "" then
            return nil, "no config file is selected"
        end
        if name:find("/", 1, true) or name:find("\\", 1, true) or name:find("..", 1, true) then
            return nil, "invalid config file name"
        end

        return name
    end

    local function Notify(self, message, time)
        if self.Library and typeof(self.Library.Notify) == "function" then
            self.Library:Notify(message, time)
        else
            warn(message)
        end
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace", 
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", 
        })
    end

    
    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end

        if createFolder == true then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
            if not SafeIsFolder(subFolder) then
                local success = SafeMakeFolder(subFolder)
                if not success then
                    return false
                end
            end
        end

        return true
    end

    function SaveManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            local path = table.concat(parts, "/", 1, idx)
            if not table.find(paths, path) then paths[#paths + 1] = path end
        end

        paths[#paths + 1] = self.Folder .. "/themes"
        paths[#paths + 1] = self.Folder .. "/settings"

        if self:CheckSubFolder(false) then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
            parts = subFolder:split("/")

            for idx = 1, #parts do
                local path = table.concat(parts, "/", 1, idx)
                if not table.find(paths, path) then paths[#paths + 1] = path end
            end
        end

        return paths
    end

    function SaveManager:GetSettingsFolder(createFolder)
        if typeof(self.SubFolder) == "string" and self.SubFolder ~= "" then
            if createFolder == true and not self:CheckSubFolder(true) then
                return nil, "failed to create settings subfolder"
            end

            return self.Folder .. "/settings/" .. self.SubFolder
        end

        return self.Folder .. "/settings"
    end

    function SaveManager:GetConfigPath(name, createFolder)
        local folder, err = self:GetSettingsFolder(createFolder)
        if not folder then
            return nil, err
        end

        return folder .. "/" .. name .. ".json"
    end

    function SaveManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if SafeIsFolder(str) then continue end

            local success, err = SafeMakeFolder(str)
            if not success then
                return false, err
            end
        end

        return true
    end

    function SaveManager:CheckFolderTree()
        local success, err = SaveManager:BuildFolderTree()
        if not success then
            return false, err or "failed to create settings folders"
        end

        task.wait(0.1)
        return true
    end

    function SaveManager:SetIgnoreIndexes(list)
        if typeof(list) ~= "table" then
            return
        end

        for _, key in list do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        assert(typeof(folder) == "string" and TrimString(folder) ~= "", "folder must be a non-empty string")

        folder = TrimString(folder):gsub("\\", "/"):gsub("/+$", "")
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        assert(typeof(folder) == "string", "subfolder must be a string")

        folder = TrimString(folder):gsub("\\", "/"):gsub("^/+", ""):gsub("/+$", "")
        assert(not folder:find("..", 1, true), "subfolder cannot contain '..'")

        self.SubFolder = folder
        self:BuildFolderTree()
    end

    function SaveManager:RegisterCustomData(key, saveFn, loadFn)
        assert(typeof(key) == "string" and key ~= "", "custom data key must be a non-empty string")
        assert(typeof(saveFn) == "function", "custom data save handler must be a function")
        assert(typeof(loadFn) == "function", "custom data load handler must be a function")

        self.CustomData[key] = { Save = saveFn, Load = loadFn }
    end

    function SaveManager:Save(name)
        local normalizedName, nameErr = NormalizeConfigName(name)
        if not normalizedName then
            return false, nameErr
        end
        if not self.Library then
            return false, "library is not set"
        end
        if typeof(writefile) ~= "function" then
            return false, "writefile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end

        local fullPath, pathErr = self:GetConfigPath(normalizedName, true)
        if not fullPath then
            return false, pathErr
        end

        local data = {
            objects = {}
        }

        for idx, toggle in self.Library.Toggles do
            if not toggle.Type then continue end
            if not self.Parser[toggle.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
        end

        for idx, option in self.Library.Options do
            if not option.Type then continue end
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end

        if next(self.CustomData) then
            data.custom = {}
            for key, handler in self.CustomData do
                local ok, val = pcall(handler.Save)
                if ok then data.custom[key] = val end
            end
        end

        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, "failed to encode data"
        end

        local ok, err = pcall(writefile, fullPath, encoded)
        if not ok then
            return false, tostring(err) or "write file error"
        end
        return true
    end

    function SaveManager:Load(name)
        local normalizedName, nameErr = NormalizeConfigName(name)
        if not normalizedName then
            return false, nameErr
        end
        if not self.Library then
            return false, "library is not set"
        end
        if typeof(readfile) ~= "function" then
            return false, "readfile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end

        local file, pathErr = self:GetConfigPath(normalizedName, true)
        if not file then
            return false, pathErr
        end

        if not SafeIsFile(file) then return false, "invalid file" end

        local readSuccess, raw = pcall(readfile, file)
        if not readSuccess then return false, "read file error" end

        local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
        if not success then return false, "decode error" end
        if typeof(decoded) ~= "table" or typeof(decoded.objects) ~= "table" then
            return false, "invalid config data"
        end

        for _, option in decoded.objects do
            if not option.type then continue end
            if not self.Parser[option.type] then continue end
            if self.Ignore[option.idx] then continue end

            task.spawn(function()
                pcall(self.Parser[option.type].Load, option.idx, option)
            end)
        end

        if typeof(decoded.custom) == "table" and next(self.CustomData) then
            for key, handler in self.CustomData do
                if decoded.custom[key] ~= nil then
                    pcall(handler.Load, decoded.custom[key])
                end
            end
        end

        return true
    end

    function SaveManager:Delete(name)
        local normalizedName, nameErr = NormalizeConfigName(name)
        if not normalizedName then
            return false, nameErr
        end
        if typeof(delfile) ~= "function" then
            return false, "delfile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end

        local file, pathErr = self:GetConfigPath(normalizedName, true)
        if not file then
            return false, pathErr
        end

        if not SafeIsFile(file) then return false, "invalid file" end

        local success = pcall(delfile, file)
        if not success then return false, "delete file error" end

        return true
    end

    function SaveManager:RefreshConfigList()
        local success, data = pcall(function()
            local folderSuccess = SaveManager:CheckFolderTree()
            if not folderSuccess then
                return {}
            end

            local out = {}
            local settingsFolder = self:GetSettingsFolder(true)
            if not settingsFolder then
                return out
            end
            local list = SafeListFiles(settingsFolder)

            for i = 1, #list do
                local file = list[i]
                local basename = tostring(file):match("([^/\\]+)$") or tostring(file)
                if basename:sub(-5) == ".json" and basename ~= "accountconfigs.json" then
                    table.insert(out, basename:sub(1, #basename - 5))
                end
            end

            table.sort(out)
            return out
        end)

        if (not success) then
            Notify(self, "Failed to load config list: " .. tostring(data))

            return {}
        end

        return data
    end

    
    function SaveManager:GetAutoloadConfig()
        local folderSuccess = SaveManager:CheckFolderTree()
        if not folderSuccess or typeof(readfile) ~= "function" then
            return "none"
        end

        local settingsFolder = self:GetSettingsFolder(true)
        if not settingsFolder then
            return "none"
        end
        local autoLoadPath = settingsFolder .. "/autoload.txt"

        if SafeIsFile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                return "none"
            end

            name = TrimString(name)
            local normalizedName = NormalizeConfigName(name)
            return if normalizedName then normalizedName else "none"
        end

        return "none"
    end

    function SaveManager:LoadAutoloadConfig()
        local folderSuccess = SaveManager:CheckFolderTree()
        if not folderSuccess then
            Notify(self, "Failed to load autoload config: settings folder unavailable")
            return
        end

        local accountConfig = self:GetAccountConfig()
        if accountConfig then
            local success, err = self:Load(accountConfig)
            if not success then
                Notify(self, "Failed to load account config: " .. err)
                return
            end

            local player = game:GetService("Players").LocalPlayer
            local playerName = player and player.Name or "unknown"
            Notify(self, string.format("Auto loaded config %q for account %q", accountConfig, playerName))
            return
        end

        if typeof(readfile) ~= "function" then
            Notify(self, "Failed to load autoload config: readfile is unavailable")
            return
        end
        local settingsFolder = self:GetSettingsFolder(true)
        if not settingsFolder then
            Notify(self, "Failed to load autoload config: settings folder unavailable")
            return
        end
        local autoLoadPath = settingsFolder .. "/autoload.txt"

        if SafeIsFile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                Notify(self, "Failed to load autoload config: read file error")
                return
            end

            name = TrimString(name)
            local normalizedName = NormalizeConfigName(name)
            if not normalizedName then
                return
            end

            local success, err = self:Load(normalizedName)
            if not success then
                Notify(self, "Failed to load autoload config: " .. err)
                return
            end

            Notify(self, string.format("Auto loaded config %q", normalizedName))
        end
    end

    function SaveManager:SaveAutoloadConfig(name)
        local normalizedName, nameErr = NormalizeConfigName(name)
        if not normalizedName then
            return false, nameErr
        end
        if typeof(writefile) ~= "function" then
            return false, "writefile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end
        local settingsFolder, settingsErr = self:GetSettingsFolder(true)
        if not settingsFolder then
            return false, settingsErr
        end
        local autoLoadPath = settingsFolder .. "/autoload.txt"

        local success = pcall(writefile, autoLoadPath, normalizedName)
        if not success then return false, "write file error" end

        return true, ""
    end

    function SaveManager:GetAutoSaveState()
        local folderSuccess = SaveManager:CheckFolderTree()
        if not folderSuccess or typeof(readfile) ~= "function" then
            return false
        end

        local settingsFolder = self:GetSettingsFolder(true)
        if not settingsFolder then
            return false
        end
        local path = settingsFolder .. "/autosave.txt"

        if SafeIsFile(path) then
            local ok, val = pcall(readfile, path)
            if ok and val == "true" then return true end
        end

        return false
    end

    function SaveManager:SaveAutoSaveState(enabled)
        if typeof(writefile) ~= "function" then
            return false, "writefile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end
        local settingsFolder, settingsErr = self:GetSettingsFolder(true)
        if not settingsFolder then
            return false, settingsErr
        end
        local path = settingsFolder .. "/autosave.txt"

        local success = pcall(writefile, path, tostring(enabled))
        if not success then return false, "write file error" end
        return true
    end

    function SaveManager:DeleteAutoLoadConfig()
        if typeof(delfile) ~= "function" then
            return false, "delfile is unavailable"
        end

        local folderSuccess, folderErr = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false, folderErr
        end
        local settingsFolder, settingsErr = self:GetSettingsFolder(true)
        if not settingsFolder then
            return false, settingsErr
        end
        local autoLoadPath = settingsFolder .. "/autoload.txt"

        if not SafeIsFile(autoLoadPath) then
            return true, ""
        end
        local success = pcall(delfile, autoLoadPath)
        if not success then return false, "delete file error" end

        return true, ""
    end

    function SaveManager:_QueueAutoSave()
        if not self.AutoSave then return end

        local name = self:GetAutoloadConfig()
        if name == "none" then return end

        if self._autoSaveThread then
            task.cancel(self._autoSaveThread)
        end

        self._autoSaveThread = task.delay(1, function()
            self._autoSaveThread = nil
            if not self.AutoSave then return end
            self:Save(name)
        end)
    end

    function SaveManager:_HookElement(idx, element)
        if self._autoSaveHooked[idx] == element then return end
        if self.Ignore[idx] then return end
        if not element.Type or not self.Parser[element.Type] then return end

        self._autoSaveHooked[idx] = element

        local prevCallback = element.Callback
        element.Callback = function(...)
            local callbackSuccess, callbackError = true, nil
            if prevCallback then
                callbackSuccess, callbackError = pcall(prevCallback, ...)
            end
            self:_QueueAutoSave()
            if not callbackSuccess then
                error(callbackError)
            end
        end

        -- KeyPicker rebinding fires ChangedCallback/Changed but not Callback,
        -- and ChangedCallback is not user-overridable, so it's a safe persistent hook point.
        if element.Type == "KeyPicker" then
            local prevChangedCallback = element.ChangedCallback
            element.ChangedCallback = function(...)
                local callbackSuccess, callbackError = true, nil
                if prevChangedCallback then
                    callbackSuccess, callbackError = pcall(prevChangedCallback, ...)
                end
                self:_QueueAutoSave()
                if not callbackSuccess then
                    error(callbackError)
                end
            end
        end
    end

    function SaveManager:SetupAutoSave()
        assert(self.Library, "Must set SaveManager.Library")

        for idx, toggle in self.Library.Toggles do
            self:_HookElement(idx, toggle)
        end
        for idx, option in self.Library.Options do
            self:_HookElement(idx, option)
        end

        -- Watch for new elements being added
        local Toggles_mt = getmetatable(self.Library.Toggles)
        if not Toggles_mt or not Toggles_mt.__autosave then
            local mt = Toggles_mt or {}
            local oldNewIndex = mt.__newindex
            mt.__autosave = true
            mt.__newindex = function(t, k, v)
                if oldNewIndex then
                    oldNewIndex(t, k, v)
                else
                    rawset(t, k, v)
                end
                if v and typeof(v) == "table" then
                    self:_HookElement(k, v)
                end
            end
            if not Toggles_mt then
                setmetatable(self.Library.Toggles, mt)
            end
        end

        local Options_mt = getmetatable(self.Library.Options)
        if not Options_mt or not Options_mt.__autosave then
            local mt = Options_mt or {}
            local oldNewIndex = mt.__newindex
            mt.__autosave = true
            mt.__newindex = function(t, k, v)
                if oldNewIndex then
                    oldNewIndex(t, k, v)
                else
                    rawset(t, k, v)
                end
                if v and typeof(v) == "table" then
                    self:_HookElement(k, v)
                end
            end
            if not Options_mt then
                setmetatable(self.Library.Options, mt)
            end
        end
    end

    function SaveManager:_GetAccountConfigsPath()
        local settingsFolder = self:GetSettingsFolder(false)
        return settingsFolder .. "/accountconfigs.json"
    end

    function SaveManager:GetAccountConfigs()
        local folderSuccess = SaveManager:CheckFolderTree()
        if not folderSuccess or typeof(readfile) ~= "function" then
            return {}
        end

        local path = self:_GetAccountConfigsPath()
        if not SafeIsFile(path) then return {} end

        local ok, raw = pcall(readfile, path)
        if not ok then return {} end

        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or typeof(data) ~= "table" then return {} end

        return data
    end

    function SaveManager:SaveAccountConfigs(data)
        if typeof(data) ~= "table" then
            return false
        end
        if typeof(writefile) ~= "function" then
            return false
        end

        local folderSuccess = SaveManager:CheckFolderTree()
        if not folderSuccess then
            return false
        end
        if not self:GetSettingsFolder(true) then
            return false
        end

        local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not ok then return false end

        local path = self:_GetAccountConfigsPath()
        local writeOk = pcall(writefile, path, encoded)
        if not writeOk then return false end
        return true
    end

    function SaveManager:GetAccountConfig()
        local configs = self:GetAccountConfigs()
        local player = game:GetService("Players").LocalPlayer
        if not player then
            return nil
        end

        local playerName = player.Name
        return configs[playerName]
    end

    function SaveManager:_BuildAccountListItems(configs)
        local items = {}
        if typeof(configs) ~= "table" then
            return items
        end

        for account, config in configs do
            table.insert(items, { Key = tostring(account), Display = tostring(account) .. " -> " .. tostring(config) })
        end
        table.sort(items, function(a, b) return a.Key < b.Key end)
        return items
    end

    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")
        assert(self.Library.Window, "Must create a Library window before building the config section")

        local section = tab:AddRightGroupbox("Configuration", "folder-cog")

        section:AddInput("SaveManager_ConfigName",    { Text = "Config name" })
        section:AddButton("Create config", function()
            local name = TrimString(self.Library.Options.SaveManager_ConfigName.Value)

            local normalizedName, nameErr = NormalizeConfigName(name)
            if not normalizedName then
                self.Library:Notify("Invalid config name: " .. nameErr, 2)
                return
            end

            local success, err = self:Save(normalizedName)
            if not success then
                self.Library:Notify("Failed to create config: " .. err)
                return
            end

            self.Library:Notify(string.format("Created config %q", normalizedName))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)


        section:AddDropdown("SaveManager_ConfigList", { Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true })
        section:AddButton("Load config", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify("Failed to load config: " .. err)
                return
            end

            self.Library:Notify(string.format("Loaded config %q", name))
        end)
        section:AddButton("Overwrite config", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                self.Library:Notify("Failed to overwrite config: " .. err)
                return
            end

            self.Library:Notify(string.format("Overwrote config %q", name))
        end)

        section:AddButton("Delete config", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Delete(name)
            if not success then
                self.Library:Notify("Failed to delete config: " .. err)
                return
            end

            self.Library:Notify(string.format("Deleted config %q", name))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddButton("Refresh list", function()
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddButton("Set as autoload", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:SaveAutoloadConfig(name)
            if not success then
                self.Library:Notify("Failed to set autoload config: " .. err)
                return
            end

            self.Library:Notify(string.format("Set %q to auto load", name))
            self.AutoloadConfigLabel:SetText("Current autoload config: " .. name)
            if self.AutoSave and self.AutoSaveLabel then
                self.AutoSaveLabel:SetText("Auto Saving: " .. name)
            end
        end)
        section:AddButton("Reset autoload", function()
            local success, err = self:DeleteAutoLoadConfig()
            if not success then
                self.Library:Notify("Failed to set autoload config: " .. err)
                return
            end

            self.Library:Notify("Set autoload to none")
            self.AutoloadConfigLabel:SetText("Current autoload config: none")
            if self.AutoSave and self.AutoSaveLabel then
                self.AutoSaveLabel:SetText("Auto Saving: none (set autoload first)")
            end
        end)

        self.AutoloadConfigLabel = section:AddLabel("Current autoload config: " .. self:GetAutoloadConfig(), true)

        self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_ImportData", "SaveManager_AutoSave", "SaveManager_AccName", "SaveManager_AccConfig", "SaveManager_AccList" })

        local savedAutoSave = self:GetAutoSaveState()
        local autoSaveConfig = self:GetAutoloadConfig()

        section:AddToggle("SaveManager_AutoSave", {
            Text = "Auto Save Config",
            Default = savedAutoSave,
            Callback = function(value)
                self.AutoSave = value
                local savedState, saveStateErr = self:SaveAutoSaveState(value)
                if not savedState then
                    self.Library:Notify("Failed to save auto-save state: " .. tostring(saveStateErr), 2)
                end
                if value then
                    self:SetupAutoSave()
                    local name = self:GetAutoloadConfig()
                    self.AutoSaveLabel:SetText("Auto Saving: " .. (if name ~= "none" then name else "none (set autoload first)"))
                else
                    self.AutoSaveLabel:SetText("Auto Saving: disabled")
                end
            end,
        })

        self.AutoSaveLabel = section:AddLabel("Auto Saving: " .. (if savedAutoSave then (if autoSaveConfig ~= "none" then autoSaveConfig else "none (set autoload first)") else "disabled"), true)

        if savedAutoSave then
            self.AutoSave = true
            self:SetupAutoSave()
        end

        do
            local Window = self.Library.Window
            local accountConfigs = self:GetAccountConfigs()
            local localPlayer = game:GetService("Players").LocalPlayer
            local playerName = localPlayer and localPlayer.Name or ""

            local Dialog
            Dialog = Window:AddDialog("SaveManager_AccountConfigs", {
                Title = "Account Configs",
                Description = "Assign a config to each account. When that account logs in, its assigned config loads automatically (overrides autoload)",
                StartHidden = true,                                 
                AutoDismiss = false,
                Width = 400,
                MaxHeight = 350,
                FooterButtons = {
                    Save = {
                        Title = "Assign",
                        Variant = "Primary",
                        Order = 3,
                        Callback = function()
                            local account = self.Library.Options.SaveManager_AccName.Value
                            local config = self.Library.Options.SaveManager_AccConfig.Value

                            if not account or account:gsub("%s", "") == "" then
                                self.Library:Notify("Account name is empty", 2)
                                return
                            end
                            if not config or config == "" then
                                self.Library:Notify("Select a config first", 2)
                                return
                            end

                            accountConfigs[account] = config
                            if not self:SaveAccountConfigs(accountConfigs) then
                                self.Library:Notify("Failed to save account configs", 2)
                                return
                            end
                            self.Library.Options.SaveManager_AccList:SetItems(self:_BuildAccountListItems(accountConfigs))
                            if account == playerName and self.AccountConfigLabel then
                                self.AccountConfigLabel:SetText("Account config: " .. config)
                            end
                            self.Library:Notify(string.format("Assigned %q -> %q", account, config))
                        end,
                    },
                    Remove = {
                        Title = "Remove",
                        Variant = "Destructive",
                        Order = 2,
                        Callback = function()
                            local sel = self.Library.Options.SaveManager_AccList:GetSelected()
                            if not sel then
                                self.Library:Notify("Select an account to remove", 2)
                                return
                            end

                            local account = sel.Key
                            accountConfigs[account] = nil
                            if not self:SaveAccountConfigs(accountConfigs) then
                                self.Library:Notify("Failed to save account configs", 2)
                                return
                            end
                            self.Library.Options.SaveManager_AccList:SetItems(self:_BuildAccountListItems(accountConfigs))
                            self.Library.Options.SaveManager_AccList:ClearSelection()
                            if account == playerName and self.AccountConfigLabel then
                                self.AccountConfigLabel:SetText("Account config: none")
                            end
                            self.Library:Notify(string.format("Removed account %q", account))
                        end,
                    },
                    Close = {
                        Title = "Close",
                        Variant = "Ghost",
                        Order = 1,
                        Callback = function()
                        Dialog:Dismiss()
                        end,
                    },
                },
            })

            Dialog:AddList("SaveManager_AccList", {
                Text = "Assigned Accounts",
                Items = self:_BuildAccountListItems(accountConfigs),
                Multi = false,
                MaxHeight = 120,
                EmptyText = "No accounts assigned yet.",
                Callback = function(item)
                    if not item then return end
                    self.Library.Options.SaveManager_AccName:SetValue(item.Key)
                end,
            })

            Dialog:AddInput("SaveManager_AccName", { Text = "Account name", Default = playerName, Placeholder = "Exact username" })
            Dialog:AddDropdown("SaveManager_AccConfig", { Text = "Config to load", Values = self:RefreshConfigList(), AllowNull = true })

            section:AddButton("Account configs", function()
                self.Library.Options.SaveManager_AccConfig:SetValues(self:RefreshConfigList())
                accountConfigs = self:GetAccountConfigs()
                self.Library.Options.SaveManager_AccList:SetItems(self:_BuildAccountListItems(accountConfigs))
                Dialog:Show()
            end)

            local currentAcc = accountConfigs[playerName]
            self.AccountConfigLabel = section:AddLabel(
                "Account config: " .. (if currentAcc then currentAcc else "none"),
                true
            )
        end

        section:AddButton("Export config", function()
            local data = {
                objects = {}
            }

            for idx, toggle in self.Library.Toggles do
                if not toggle.Type then continue end
                if not self.Parser[toggle.Type] then continue end
                if self.Ignore[idx] then continue end

                table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
            end

            for idx, option in self.Library.Options do
                if not option.Type then continue end
                if not self.Parser[option.Type] then continue end
                if self.Ignore[idx] then continue end

                table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
            end

            if next(self.CustomData) then
                data.custom = {}
                for key, handler in self.CustomData do
                    local ok, val = pcall(handler.Save)
                    if ok then data.custom[key] = val end
                end
            end

            local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
            if not success then
                self.Library:Notify("Failed to export config")
                return
            end

            if typeof(setclipboard) == "function" then
                local clipboardOk = pcall(setclipboard, encoded)
                if not clipboardOk then
                    self.Library:Notify("Failed to copy config to clipboard")
                    return
                end

                self.Library:Notify("Config exported to clipboard")
            else
                self.Library:Notify("Clipboard not supported")
            end
        end)

        section:AddInput("SaveManager_ImportData", { Text = "Import Config", Placeholder = "Paste config JSON or URL here..." })
        section:AddButton("Import config", function()
            local raw = self.Library.Options.SaveManager_ImportData.Value

            if not raw or raw:gsub("%s", "") == "" then
                self.Library:Notify("Import data is empty", 2)
                return
            end

            raw = raw:gsub("^%s+", ""):gsub("%s+$", "")

            if raw:sub(1, 4) == "http" then
                self.Library:Notify("Fetching config from URL...")
                if typeof(request) ~= "function" then
                    self.Library:Notify("HTTP request is not supported")
                    return
                end

                local ok, response = pcall(request, { Url = raw, Method = "GET" })
                local statusCode = ok and typeof(response) == "table" and tonumber(response.StatusCode) or nil
                local requestSuccess = ok
                    and typeof(response) == "table"
                    and (response.Success == true or (statusCode and statusCode >= 200 and statusCode < 300))

                if not requestSuccess then
                    local message = ok and typeof(response) == "table" and (response.StatusMessage or response.StatusCode) or response
                    self.Library:Notify("Failed to fetch URL: " .. tostring(message))
                    return
                end
                raw = response.Body or response.body
                if typeof(raw) ~= "string" then
                    self.Library:Notify("URL response did not contain config data")
                    return
                end
            end

            local success, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
            if not success or typeof(decoded) ~= "table" or typeof(decoded.objects) ~= "table" then
                self.Library:Notify("Invalid config data")
                return
            end

            for _, option in decoded.objects do
                if not option.type then continue end
                if not self.Parser[option.type] then continue end
                if self.Ignore[option.idx] then continue end

                task.spawn(function()
                    pcall(self.Parser[option.type].Load, option.idx, option)
                end)
            end

            if typeof(decoded.custom) == "table" and next(self.CustomData) then
                for key, handler in self.CustomData do
                    if decoded.custom[key] ~= nil then
                        pcall(handler.Load, decoded.custom[key])
                    end
                end
            end

            self.Library:Notify("Config imported successfully")
        end)

        self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_ImportData", "SaveManager_AutoSave", "SaveManager_AccName", "SaveManager_AccConfig", "SaveManager_AccList" })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
