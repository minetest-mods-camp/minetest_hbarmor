hbarmor = {}

-- HUD statbar values
hbarmor.armor = {}

-- Stores if player's HUD bar has been initialized so far.
hbarmor.player_active = {}

-- HUD item ids
local armor_hud = {}

hbarmor.tick = 0.1

--load custom settings
local set = io.open(minetest.get_modpath("hbarmor").."/hbarmor.conf", "r")
if set then 
	dofile(minetest.get_modpath("hbarmor").."/hbarmor.conf")
	set:close()
end

local must_hide = function(playername, arm)
	return ((not armor.def[playername].count or armor.def[playername].count == 0) and arm == 0)
end

local arm_printable = function(arm)
	return math.ceil(math.floor(arm+0.5))
end

local function custom_hud(player)
	local name = player:get_player_name()

	if minetest.setting_getbool("enable_damage") then
		local arm = tonumber(hbarmor.armor[name])
		if not arm then arm = 0 end
		local hide = must_hide(name, arm)
		hb.init_hudbar(player, "armor", arm_printable(arm), nil, hide)
	end
end

--register and define armor HUD bar
hb.register_hudbar("armor", 0xFFFFFF, "Armor", { icon = "hbarmor_icon.png", bar = "hbarmor_bar.png" }, 0, 100, true, "%s: %d%%")

dofile(minetest.get_modpath("hbarmor").."/armor.lua")


-- update hud elemtens if value has changed
local function update_hud(player)
	local name = player:get_player_name()
 --armor
	local arm = tonumber(hbarmor.armor[name])
	if not arm then
		arm = 0
		hbarmor.armor[name] = 0
	end
	-- hide armor bar completely when there is none
	if must_hide(name, arm) then
		hb.hide_hudbar(player, "armor")
	else
		hb.change_hudbar(player, "armor", arm_printable(arm))
		hb.unhide_hudbar(player, "armor")
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	hbarmor.armor[name] = 0
	custom_hud(player)
	hbarmor.player_active[name] = true
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	hbarmor.player_active[name] = false
end)

local main_timer = 0
local timer = 0
minetest.register_globalstep(function(dtime)
	main_timer = main_timer + dtime
	timer = timer + dtime
	if main_timer > hbarmor.tick or timer > 4 then
		if minetest.setting_getbool("enable_damage") then
			if main_timer > hbarmor.tick then main_timer = 0 end
			for _,player in ipairs(minetest.get_connected_players()) do
				local name = player:get_player_name()
				if hbarmor.player_active[name] == true then
					hbarmor.get_armor(player)

					-- update all hud elements
					update_hud(player)
				end
			end
		end
	end
	if timer > 4 then timer = 0 end
end)
