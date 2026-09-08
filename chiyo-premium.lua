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
			game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Chiyo Premium", Text = "Already running in this server.", Duration = 4 })
		end)
		return
	end
end

if not game:IsLoaded() then game.Loaded:Wait() end

local GAMES = {
	[103754275310547] = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[86076978383613]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[93825215891304]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[95512431395349]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[139842844647383] = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
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

	[18335956021]  = { "grand blue", "https://api.luarmor.net/files/v3/loaders/1fb2da056ac8c871119d0bd58500629b.lua" },

	[80877167393789]  = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[128314954869462] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[117381420723145] = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },

	[89469502395769]  = { "kick a lucky block", "https://api.luarmor.net/files/v3/loaders/137b76b52f8f3234db2bda640e3011a8.lua" },

	[116497287371701] = { "karinderya", "https://api.luarmor.net/files/v3/loaders/8390ffc46357d1321c3122ed2cd9ad69.lua" },

	[77649408247578]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },
	[85776757589518]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },
	[115445507767090] = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },

	[119114794144012] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/153f463fb18832c79b697d80463f8edc.lua" },
	[140409475718339] = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/153f463fb18832c79b697d80463f8edc.lua" },

	[85967844112283]  = { "last stop", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },
	[122776220269735] = { "last stop", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },

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

	[84515722934860]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },

	[117311404196294] = { "runaways", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },
	[118418618261207] = { "runaways", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },

	[74102906764176]  = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/df230805784849c4ee2dd9790ce3bf0f.lua" },

	[118635363908336] = { "grand blue", "https://api.luarmor.net/files/v3/loaders/1fb2da056ac8c871119d0bd58500629b.lua" },

	[99108783264633]  = { "build a base rng", "https://api.luarmor.net/files/v3/loaders/8a79f287291004efa1558612b10a7387.lua" },

	[126870639873289] = { "jump for animals", "https://api.luarmor.net/files/v3/loaders/3be50428e6ad8a1f7be774c8704966cc.lua" },

	[133188236593503] = { "magic loot", "https://api.luarmor.net/files/v3/loaders/7f3dc0d8adb6c6283364da22589103e5.lua" },

	[108307565942574] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/df230805784849c4ee2dd9790ce3bf0f.lua" },

	[122951224417794] = { "unscathed", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },

	[107778070777162] = { "steal an egg", "https://api.luarmor.net/files/v3/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },

	[125039473548047] = { "anime card farm", "https://api.luarmor.net/files/v3/loaders/4dd148e162d371b86cfceb1d94ffefa3.lua" },

	[94640181989498] = { "grow a chicken fighter", "https://api.luarmor.net/files/v3/loaders/793f4a31e8f6cbd08d14f72536225100.lua" },
}

local GAMES_BY_UNIVERSE = {
	[7750955984]  = { "hunty zomby", "https://api.luarmor.net/files/v3/loaders/fb3ffcb430dff770592b1d1fc59c43c7.lua" },
	[7094518649]  = { "restaurant tycoon 3", "https://api.luarmor.net/files/v3/loaders/4c6ca668ef4a698341d0529c8b296cd1.lua" },
	[7671049560]  = { "the forge", "https://api.luarmor.net/files/v3/loaders/313f260d39974a175f95398f3fa5bd27.lua" },
	[9186719164]  = { "sailor piece", "https://api.luarmor.net/files/v3/loaders/9979d5649836f6b746df57a667c6daa9.lua" },
	[6215986499]  = { "grand blue", "https://api.luarmor.net/files/v3/loaders/1fb2da056ac8c871119d0bd58500629b.lua" },
	[9802644580]  = { "summon heroes", "https://api.luarmor.net/files/v4/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[10004244222] = { "kick a lucky block", "https://api.luarmor.net/files/v3/loaders/137b76b52f8f3234db2bda640e3011a8.lua" },
	[10648820673] = { "karinderya", "https://api.luarmor.net/files/v3/loaders/8390ffc46357d1321c3122ed2cd9ad69.lua" },
	[9931749389]  = { "dungeon quest reborn", "https://api.luarmor.net/files/v3/loaders/55b94f7aa5a16843f5f389adfb57e1e4.lua" },
	[9073513091]  = { "anime apocalypse", "https://api.luarmor.net/files/v3/loaders/153f463fb18832c79b697d80463f8edc.lua" },
	[10759337137] = { "last stop", "https://api.luarmor.net/files/v3/loaders/99c2d5c049ad70628b68e7a2d04c1133.lua" },
	[10148749921] = { "animal hospital", "https://api.luarmor.net/files/v3/loaders/fb093ba6294493572324085d2390fc9e.lua" },
	[9826885587]  = { "evomon", "https://api.luarmor.net/files/v3/loaders/299d34d8c973e9187399fb5903bc0ed2.lua" },
	[10261267004] = { "storage hunters", "https://api.luarmor.net/files/v3/loaders/0bcbe7a4389b449ffea02f6c0db4fe1c.lua" },
	[10204207151] = { "catch a brainrot", "https://api.luarmor.net/files/v3/loaders/7814ebe0326de295c9082782fcca103e.lua" },
	[10267363348] = { "drain the lake", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },
	[7613921865]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },
	[7585140258]  = { "runaways", "https://api.luarmor.net/files/v3/loaders/dfd564eb12bcbb43fec48e24395986d9.lua" },
	[10253235584] = { "build a base rng", "https://api.luarmor.net/files/v3/loaders/8a79f287291004efa1558612b10a7387.lua" },
	[10690360998] = { "jump for animals", "https://api.luarmor.net/files/v3/loaders/3be50428e6ad8a1f7be774c8704966cc.lua" },
	[10506207587] = { "magic loot", "https://api.luarmor.net/files/v3/loaders/7f3dc0d8adb6c6283364da22589103e5.lua" },
	[10153098880] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/df230805784849c4ee2dd9790ce3bf0f.lua" },
	[10440833423] = { "greedy growers", "https://api.luarmor.net/files/v3/loaders/df230805784849c4ee2dd9790ce3bf0f.lua" },
	[8959257868]  = { "unscathed", "https://api.luarmor.net/files/v3/loaders/3509d38120b35f627d9e9ed1f3c88844.lua" },
	[10563114921] = { "steal an egg", "https://api.luarmor.net/files/v3/loaders/80bcf4351bd4b2a776dc71b8502d3a1e.lua" },
	[10144587520] = { "anime card farm", "https://api.luarmor.net/files/v3/loaders/4dd148e162d371b86cfceb1d94ffefa3.lua" },
	[10338952197] = { "grow a chicken fighter", "https://api.luarmor.net/files/v3/loaders/793f4a31e8f6cbd08d14f72536225100.lua" },
}

local entry = GAMES[game.PlaceId] or GAMES_BY_UNIVERSE[game.GameId]
local loader_url = entry and entry[2]
local script_id = type(loader_url) == "string" and loader_url:match("/loaders/([%w]+)%.lua$") or nil

local LINK = "https://chiyo.dev/getkey"
local ROOT = "Chiyo/Keys"
local FILE = ROOT .. "/" .. (script_id or "default") .. ".txt"

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

local function go(k)
	set(k)
	getgenv().__chiyo_loader_url = loader_url
	getgenv().__chiyo_premium = true
	local ok = pcall(function()
		loadstring(game:HttpGet(loader_url))()
	end)
	if ok and sessions then
		sessions[game.PlaceId] = game.JobId
	end
	return ok
end

local saved_key_failed = false

if loader_url and script_id then
	local k = inline_key()
	if k then
		save(k)
		if go(k) then return end
	else
		local s = as_key(read())
		if s then
			if go(s) then return end
			saved_key_failed = true
		end
	end
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()

Library.Scheme.FontColor       = Color3.fromHex("ffffff")
Library.Scheme.MainColor       = Color3.fromHex("242424")
Library.Scheme.AccentColor     = Color3.fromHex("db4467")
Library.Scheme.BackgroundColor = Color3.fromHex("1c1c1c")
Library.Scheme.OutlineColor    = Color3.fromHex("373737")
Library:SetFont(Enum.Font.Gotham)

if saved_key_failed then
	Library:Notify({ Title = "Invalid Key", Description = "Your saved key was rejected. Enter your key below.", Time = 7 })
end

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
	save(k)
	Library:Notify({ Title = "Loading", Description = "Loading script...", Time = 3 })
	task.defer(function() Library:Unload() go(k) end)
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
