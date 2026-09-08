local hub_env = type(getgenv) == "function" and getgenv() or nil
local sessions = nil
if hub_env then
	sessions = hub_env.__chiyo_sessions
	if type(sessions) ~= "table" then
		sessions = {}
		hub_env.__chiyo_sessions = sessions
	end
	if sessions[game.PlaceId] == game.JobId then
		pcall(function()
			game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Chiyo", Text = "Already running in this server.", Duration = 4 })
		end)
		return
	end
end

if not game:IsLoaded() then game.Loaded:Wait() end

local GAMES = {
	[103754275310547] = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[86076978383613]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[93825215891304]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[95512431395349]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[139842844647383] = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[119048529960596] = { "restaurant tycoon 3", "https://api.luarmor.net/files/v3/loaders/013565ad436685d1a3af70a26b4ee637.lua" },
	[129009554587176] = { "the forge", "https://api.luarmor.net/files/v3/loaders/bbf04acd7199b29f9f9544d56687b74b.lua" },
	[76558904092080]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/bbf04acd7199b29f9f9544d56687b74b.lua" },
	[131884594917121] = { "the forge", "https://api.luarmor.net/files/v3/loaders/bbf04acd7199b29f9f9544d56687b74b.lua" },
	[74414241680540]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/bbf04acd7199b29f9f9544d56687b74b.lua" },
	[77747658251236]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[96767841099256]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[123955125827131] = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[138368689293913] = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[99684056491472]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[75159314259063]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[130167267952199] = { "sailor piece sea 2", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[98826438856089] = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[18335956021]  = { "grand blue", "https://api.luarmor.net/files/v3/loaders/296f665b08928bd4d810161801b37acf.lua" },
	[139233844569220] = { "zoo or oof", "https://api.luarmor.net/files/v3/loaders/8a4cccba7a84d889c5426e9484ca6587.lua" },

	[80877167393789]  = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/0aa7263af1401f475f2b2d28945c0f8b.lua" },
	[128314954869462] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/0aa7263af1401f475f2b2d28945c0f8b.lua" },
	[117381420723145] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/0aa7263af1401f475f2b2d28945c0f8b.lua" },

	[89469502395769]  = { "kick a lucky block", "https://api.luarmor.net/files/v3/loaders/648494a8772b0379925af5c935c8114e.lua" },

	[92416421522960]  = { "slime rng", "https://api.luarmor.net/files/v3/loaders/d84e9eb1484f86a55e8bf8ad8dbe0d77.lua" },

	[77649408247578]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/e4a17c871207eeecd4f58fae79d9d474.lua" },
	[85776757589518]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/e4a17c871207eeecd4f58fae79d9d474.lua" },
	[115445507767090] = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/e4a17c871207eeecd4f58fae79d9d474.lua" },

	[119114794144012] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/0565e406ef13358f65bff247fabd5c65.lua" },
	[140409475718339] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/0565e406ef13358f65bff247fabd5c65.lua" },

	[97598239454123]  = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/6db88a06aec7282a5ab455917a42bfbe.lua" },
	[77085202503540]  = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/6db88a06aec7282a5ab455917a42bfbe.lua" },
	[133438856880402] = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/6db88a06aec7282a5ab455917a42bfbe.lua" },

	[78515283254292]  = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fc76ccc5977af60a03c1b318a3a0bced.lua" },
	[104522435597696] = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fc76ccc5977af60a03c1b318a3a0bced.lua" },

	[134381727982611] = { "evomon", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[113840348235813] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[140185916293449] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[140265303955250] = { "evomon world 2", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[124678104425908] = { "evomon", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[127024676374097] = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[71906412586129]  = { "build a ring farm", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },

	[98800969324557]  = { "storage hunters", "https://api.luarmor.net/files/v3/loaders/a7196291de7069f910f5b26ea3ad1aaf.lua" },

	[140063367098641] = { "catch a brainrot", "https://api.luarmor.net/files/v3/loaders/e68f71ea4150cef34b20e188c70f2e0f.lua" },

	[138381251771774] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/774e7e358882d9c55b4649af0f0a22fc.lua" },
	[124786371598438] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/774e7e358882d9c55b4649af0f0a22fc.lua" },

	[84515722934860]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/63b1f8053d24c544db6faacf6977e6cc.lua" },

	[117311404196294] = { "runaways", "https://api.luarmor.net/files/v3/loaders/63b1f8053d24c544db6faacf6977e6cc.lua" },
	[118418618261207] = { "runaways", "https://api.luarmor.net/files/v3/loaders/63b1f8053d24c544db6faacf6977e6cc.lua" },

	[74102906764176]  = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/c15214847b4bf55c68507a56ebc4646b.lua" },

	[118635363908336] = { "grand blue", "https://api.luarmor.net/files/v3/loaders/296f665b08928bd4d810161801b37acf.lua" },

	[99108783264633]  = { "build a base rng", "https://api.luarmor.net/files/v3/loaders/d5247fade99791a0e90e3275348b00bf.lua" },

	[126870639873289] = { "jump for animals", "https://api.luarmor.net/files/v3/loaders/5908510f57805eb2c203441f1cb30712.lua" },

	[133188236593503] = { "magic loot", "https://api.luarmor.net/files/v3/loaders/9e831929e8a54c724cb7ae06675bae3d.lua" },

	[108307565942574] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/c15214847b4bf55c68507a56ebc4646b.lua" },

	[122951224417794] = { "unscathed", "https://api.luarmor.net/files/v3/loaders/2fa08ba495148db9cbb27b52b5122b38.lua" },

	[107778070777162] = { "steal an egg", "https://api.luarmor.net/files/v3/loaders/836310b94f7128e39a94067b647c9618.lua" },

	[125039473548047] = { "anime card farm", "https://api.luarmor.net/files/v3/loaders/5e898dc5541aa4fd0dc154210d221c16.lua" },

	[94640181989498]  = { "grow a chicken fighter", "https://api.luarmor.net/files/v3/loaders/f92614f2d2925e409cdd22a232577ff0.lua" },
}

local GAMES_BY_UNIVERSE = {
	[7750955984]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/c9509845ca1f419a44ed41cdb5721b56.lua" },
	[7094518649]  = { "restaurant tycoon 3", "https://api.luarmor.net/files/v3/loaders/013565ad436685d1a3af70a26b4ee637.lua" },
	[7671049560]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/bbf04acd7199b29f9f9544d56687b74b.lua" },
	[9186719164]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/18226fe17f5e6ce6ab3111ccb7994daf.lua" },
	[6215986499]  = { "grand blue", "https://api.luarmor.net/files/v3/loaders/296f665b08928bd4d810161801b37acf.lua" },
	[7785400752]  = { "zoo or oof", "https://api.luarmor.net/files/v3/loaders/8a4cccba7a84d889c5426e9484ca6587.lua" },
	[9802644580]  = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/0aa7263af1401f475f2b2d28945c0f8b.lua" },
	[10004244222] = { "kick a lucky block", "https://api.luarmor.net/files/v3/loaders/648494a8772b0379925af5c935c8114e.lua" },
	[9792947201]  = { "slime rng", "https://api.luarmor.net/files/v3/loaders/d84e9eb1484f86a55e8bf8ad8dbe0d77.lua" },
	[9931749389]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/e4a17c871207eeecd4f58fae79d9d474.lua" },
	[9073513091]  = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/0565e406ef13358f65bff247fabd5c65.lua" },
	[10200395747] = { "grow a garden 2", "https://api.luarmor.net/files/v3/loaders/6db88a06aec7282a5ab455917a42bfbe.lua" },
	[10148749921] = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fc76ccc5977af60a03c1b318a3a0bced.lua" },
	[9826885587]  = { "evomon", "https://api.luarmor.net/files/v3/loaders/56cb199794326e78d8c01c4164866c5e.lua" },
	[10261267004] = { "storage hunters", "https://api.luarmor.net/files/v3/loaders/a7196291de7069f910f5b26ea3ad1aaf.lua" },
	[10204207151] = { "catch a brainrot", "https://api.luarmor.net/files/v3/loaders/e68f71ea4150cef34b20e188c70f2e0f.lua" },
	[10267363348] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/774e7e358882d9c55b4649af0f0a22fc.lua" },
	[7613921865]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/63b1f8053d24c544db6faacf6977e6cc.lua" },
	[7585140258]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/63b1f8053d24c544db6faacf6977e6cc.lua" },
	[10253235584] = { "build a base rng", "https://api.luarmor.net/files/v3/loaders/d5247fade99791a0e90e3275348b00bf.lua" },
	[10690360998] = { "jump for animals", "https://api.luarmor.net/files/v3/loaders/5908510f57805eb2c203441f1cb30712.lua" },
	[10506207587] = { "magic loot", "https://api.luarmor.net/files/v3/loaders/9e831929e8a54c724cb7ae06675bae3d.lua" },
	[10153098880] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/c15214847b4bf55c68507a56ebc4646b.lua" },
	[10440833423] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/c15214847b4bf55c68507a56ebc4646b.lua" },
	[8959257868]  = { "unscathed", "https://api.luarmor.net/files/v3/loaders/2fa08ba495148db9cbb27b52b5122b38.lua" },
	[10563114921] = { "steal an egg", "https://api.luarmor.net/files/v3/loaders/836310b94f7128e39a94067b647c9618.lua" },
	[10144587520] = { "anime card farm", "https://api.luarmor.net/files/v3/loaders/5e898dc5541aa4fd0dc154210d221c16.lua" },
	[10338952197] = { "grow a chicken fighter", "https://api.luarmor.net/files/v3/loaders/f92614f2d2925e409cdd22a232577ff0.lua" },
}

local entry = GAMES[game.PlaceId] or GAMES_BY_UNIVERSE[game.GameId]
local loader_url = entry and entry[2]
local script_id = type(loader_url) == "string" and loader_url:match("/loaders/([%w]+)%.lua$") or nil

local LINK = "https://chiyo.dev/getkey"
local ROOT = "Chiyo/Keys"
local FILE = ROOT .. "/" .. (script_id or "default") .. ".txt"

local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = script_id or ""

local function notify(m)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Chiyo", Text = tostring(m), Duration = 4 })
	end)
end

local function strip(v)
	local s = tostring(v or ""):gsub("^%s+", "")
	return (s:gsub("%s+$", ""))
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

local function as_key(v)
	if type(v) ~= "string" then return nil end
	v = strip(v)
	local quoted = v:match('^"(.*)"$') or v:match("^'(.*)'$")
	if quoted then v = strip(quoted) end
	if v ~= "" then return v end
	return nil
end

local function inline_key()
	local roblox_env = type(getrenv) == "function" and getrenv() or nil
	return as_key(script_key)
		or as_key(SCRIPT_KEY)
		or as_key(type(_G) == "table" and (_G.script_key or _G.SCRIPT_KEY))
		or as_key(hub_env and (hub_env.script_key or hub_env.SCRIPT_KEY))
		or as_key(roblox_env and (roblox_env.script_key or roblox_env.SCRIPT_KEY))
end

local function set(k)
	k = strip(k)
	if k == "" then return end
	script_key, SCRIPT_KEY = k, k
	_G.script_key, _G.SCRIPT_KEY = k, k
	if hub_env then
		hub_env.script_key, hub_env.SCRIPT_KEY = k, k
	end
end

local function check(k)
	local ok, s = pcall(api.check_key, k)
	return (ok and s and s.code) or nil, ok and s or nil
end

local function go(k)
	set(k)
	local ok = pcall(function()
		loadstring(game:HttpGet(loader_url))()
	end)
	if ok and sessions then
		sessions[game.PlaceId] = game.JobId
	end
	return ok
end

local NOTIFY_ERR = {
	KEY_EXPIRED = "Key expired. Get a new key.",
	KEY_BANNED = "Key is blacklisted.",
	KEY_HWID_LOCKED = "Key locked to a different HWID. Reset it by renewing the key.",
}

if loader_url and script_id then
	local seen, keys = {}, {}
	local function consider(v)
		v = as_key(v)
		if v and not seen[v] then
			seen[v] = true
			keys[#keys + 1] = v
		end
	end
	consider(inline_key())
	consider(read())
	for _, k in keys do
		local code = check(k)
		if code == "KEY_VALID" then
			save(k)
			if go(k) then return end
			break
		end
		local m = NOTIFY_ERR[code]
		if m then notify(m) break end
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
	if not loader_url or not script_id then
		Library:Notify({ Title = "Unsupported", Description = "This game is not supported.", Time = 5 })
		return
	end
	local k = strip(key)
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
	Title = "Chiyo",
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
		local cur = strip(input.Value)
		if cur == "" or cur == last then return end
		if pending then task.cancel(pending) end
		pending = task.delay(0.35, function()
			local stable = strip(input.Value)
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

R:AddLabel({ Text = "<font color='#db4467'><b>Upgrade to premium?</b></font>\n   Get premium from our Discord Server to support us and skip the key system.", DoesWrap = true, Size = 13 })
R:AddLabel({ Text = "<font color='#db4467'><b>How do checkpoints work?</b></font>\n   Each checkpoint gives you 12 hours of access per key.", DoesWrap = true, Size = 13 })
