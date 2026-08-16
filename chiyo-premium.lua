if getgenv().ChiyoHubExecuted then
	warn("Chiyo Hub is already running!")
	return
end
getgenv().ChiyoHubExecuted = true

if not game:IsLoaded() then game.Loaded:Wait() end

local GAMES = {
	[103754275310547] = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[86076978383613]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[119048529960596] = { "restaurant tycoon 3", "https://api.luarmor.net/files/v3/loaders/4c6ca668ef4a698341d0529c8b296cd1.lua" },
	[129009554587176] = { "the forge", "https://api.luarmor.net/files/v3/loaders/313f260d39974a175f95398f3fa5bd27.lua" },
	[76558904092080]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/313f260d39974a175f95398f3fa5bd27.lua" },
	[131884594917121] = { "the forge", "https://api.luarmor.net/files/v3/loaders/313f260d39974a175f95398f3fa5bd27.lua" },
	[74414241680540]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/313f260d39974a175f95398f3fa5bd27.lua" },

	[77747658251236]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[96767841099256]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[123955125827131] = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[138368689293913] = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[99684056491472]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[75159314259063]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[130167267952199] = { "sailor piece sea 2", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[98826438856089]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },

	[70845479499574]  = { "bite by night", "https://api.luarmor.net/files/v3/loaders/1fb2da056ac8c871119d0bd58500629b.lua" },

	[80877167393789]  = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[128314954869462] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[117381420723145] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },

	[89469502395769]  = { "kick a lucky block", "https://api.luarmor.net/files/v3/loaders/137b76b52f8f3234db2bda640e3011a8.lua" },

	[92416421522960]  = { "slime rng", "https://api.luarmor.net/files/v3/loaders/8390ffc46357d1321c3122ed2cd9ad69.lua" },

	[114204398207377] = { "survive zombie arena", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },
	[98927955463992]  = { "survive zombie arena", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },

	[119114794144012] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/153f463fb18832c79b697d80463f8edc.lua" },
	[140409475718339] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/153f463fb18832c79b697d80463f8edc.lua" },

	[97598239454123]  = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },
	[77085202503540]  = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },
	[133438856880402] = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },

	[78515283254292]  = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fb093ba6294493572324085d2390fc9e.lua" },
	[104522435597696] = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fb093ba6294493572324085d2390fc9e.lua" },

	[134381727982611] = { "evomon", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[113840348235813] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[140185916293449] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[140265303955250] = { "evomon world 2", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[124678104425908] = { "evomon", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[127024676374097] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[71906412586129]  = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },

	[98800969324557]  = { "storage hunters", "https://api.luarmor.net/files/v3/loaders/0bcbe7a4389b449ffea02f6c0db4fe1c.lua" },

	[140063367098641] = { "catch a brainrot", "https://api.luarmor.net/files/v3/loaders/7814ebe0326de295c9082782fcca103e.lua" },

	[138381251771774] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },
	[124786371598438] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },

	[84515722934860]  = { "anime expeditions", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },

	[125927821145949] = { "mine a mountain", "https://api.luarmor.net/files/v3/loaders/1fb2da056ac8c871119d0bd58500629b.lua" },

	[99108783264633]  = { "build a base rng", "https://api.luarmor.net/files/v3/loaders/8a79f287291004efa1558612b10a7387.lua" },

	[104973076655377] = { "capybaras vs plants", "https://api.luarmor.net/files/v3/loaders/3be50428e6ad8a1f7be774c8704966cc.lua" },

	[133188236593503] = { "magic loot", "https://api.luarmor.net/files/v3/loaders/7f3dc0d8adb6c6283364da22589103e5.lua" },

	[108307565942574] = { "heroes rng", "https://api.luarmor.net/files/v3/loaders/df230805784849c4ee2dd9790ce3bf0f.lua" },

	[122951224417794] = { "unscathed", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },

	[107778070777162] = { "steal an egg", "https://api.luarmor.net/files/v3/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },

	[125039473548047] = { "anime card farm", "https://api.luarmor.net/files/v3/loaders/4dd148e162d371b86cfceb1d94ffefa3.lua" },

	[94640181989498]  = { "grow a chicken fighter", "https://api.luarmor.net/files/v3/loaders/793f4a31e8f6cbd08d14f72536225100.lua" },
}

local route = GAMES[game.PlaceId]
local url = route and route[2]
local id = type(url) == "string" and url:match("/loaders/([%w]+)%.lua$") or nil

local LINK = "https://chiyo.dev/getkey"
local ROOT = "Chiyo/Keys"
local FILE = ROOT .. "/" .. (id or "default") .. ".txt"

local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = id or ""

local function notify(m)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Chiyo", Text = tostring(m), Duration = 4 })
	end)
end

local function trim(v)
	return tostring(v or ""):match("^%s*(.-)%s*$")
end

local function save(k)
	if not writefile or not makefolder then return end
	pcall(makefolder, "Chiyo")
	pcall(makefolder, ROOT)
	pcall(writefile, FILE, k)
end

local function read()
	if not readfile or not isfile or not isfile(FILE) then return nil end
	local ok, v = pcall(readfile, FILE)
	return (ok and v and v ~= "") and v or nil
end

local function set(k)
	k = trim(k)
	if k == "" then return end
	script_key, SCRIPT_KEY = k, k
	_G.script_key, _G.SCRIPT_KEY = k, k
	if type(getgenv) == "function" then
		local g = getgenv()
		g.script_key, g.SCRIPT_KEY = k, k
	end
end

local function check(k)
	local ok, s = pcall(api.check_key, k)
	return (ok and s and s.code) or nil, ok and s or nil
end

local function go(k)
	set(k)
	getgenv().__chiyo_loader_url = url
	getgenv().__chiyo_premium = true
	loadstring(game:HttpGet(url))()
end

local NOTIFY_ERR = {
	KEY_EXPIRED = "Key expired. Get a new key.",
	KEY_BANNED = "Key is blacklisted.",
	KEY_HWID_LOCKED = "Key locked to a different HWID. Reset it by renewing the key.",
}

if url and id then
	local keys = {}
	local g = getgenv and getgenv().script_key
	if type(g) == "string" and g ~= "" then keys[#keys + 1] = g end
	local s = read()
	if s and s ~= g then keys[#keys + 1] = s end
	for _, k in keys do
		local code = check(k)
		if code == "KEY_VALID" then
			save(k)
			return go(k)
		end
		local m = NOTIFY_ERR[code]
		if m then notify("Chiyo: " .. m) break end
	end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

Library.Scheme.FontColor       = Color3.fromHex("ffffff")
Library.Scheme.MainColor       = Color3.fromHex("242424")
Library.Scheme.AccentColor     = Color3.fromHex("db4467")
Library.Scheme.BackgroundColor = Color3.fromHex("1c1c1c")
Library.Scheme.OutlineColor    = Color3.fromHex("373737")
Library:SetFont(Enum.Font.Gotham)

local ERR = {
	KEY_EXPIRED     = { Title = "Key Expired",  Description = "Your key has expired. Get a new one from the key link.", Time = 7 },
	KEY_BANNED      = { Title = "Key Banned",   Description = "This key has been blacklisted.", Time = 7 },
	KEY_HWID_LOCKED = { Title = "HWID Locked",  Description = "Key is linked to a different HWID. Reset it by renewing the Key.", Time = 8 },
	KEY_INCORRECT   = { Title = "Invalid Key",  Description = "Key does not exist or has been deleted.", Time = 6 },
	KEY_INVALID     = { Title = "Invalid Key",  Description = "Key format is invalid, check for extra spaces or missing characters.", Time = 6 },
}

local function verify(key)
	if not url or not id then
		Library:Notify({ Title = "Unsupported", Description = "This game is not supported.", Time = 5 })
		return
	end
	local k = trim(key)
	if k == "" then
		Library:Notify({ Title = "Key Required", Description = "Please enter a valid key.", Time = 4 })
		return
	end
	local code, s = check(k)
	if code == "KEY_VALID" then
		local d = "Key accepted. Loading script..."
		if s.data and s.data.auth_expire and s.data.auth_expire > 0 then
			local secs = math.max(0, s.data.auth_expire - os.time())
			d = string.format("Key accepted. Expires in %dh %dm. Loading...", math.floor(secs / 3600), math.floor((secs % 3600) / 60))
		end
		Library:Notify({ Title = "Success", Description = d, Time = 4 })
		save(k)
		task.defer(function() Library:Unload() go(k) end)
	elseif ERR[code] then
		Library:Notify(ERR[code])
	else
		local m = (s and s.message) or "An unknown error occurred."
		Library:Notify({ Title = "Error", Description = m .. (code and (" (" .. code .. ")") or ""), Time = 6 })
	end
end

local Window = Library:CreateWindow({
	Title = "Chiyo Premium",
	Footer = "Key System - discord.gg/chiyo",
	Size = UDim2.fromOffset(640, 240),
	Center = true,
	AutoShow = true,
	Resizable = false,
	DisableSearch = true,
	Icon = "131030095264541",
})

local Tab = Window:AddTab({ Name = "Key System", Icon = "key" })
local L  = Tab:AddLeftGroupbox("Key")
local R  = Tab:AddRightGroupbox("Information")

local input = L:AddInput("main_key_input", { Placeholder = "Enter your key here...", Finished = false })

do
	local last, pending = "", nil
	input:OnChanged(function()
		local cur = trim(input.Value)
		if cur == "" or cur == last then return end
		if pending then task.cancel(pending) end
		pending = task.delay(0.35, function()
			local stable = trim(input.Value)
			if stable == cur then last, pending = stable, nil verify(stable) end
		end)
	end)
end

L:AddButton({ Text = "Enter", Func = function() verify(input.Value) end })
L:AddButton({
	Text = "Copy Key Link",
	Func = function()
		if setclipboard then
			setclipboard(LINK)
			Library:Notify({ Title = "Link Copied", Description = "Key link copied.", Time = 4 })
		else
			Library:Notify({ Title = "Error", Description = "Your executor does not support setclipboard.", Time = 5 })
		end
	end,
})
