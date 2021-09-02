--[[
todo:
ProcessStrobe()
legacy settings import
	- color from rgb to hex
	- blackmarket qol split into separate settings
	- strobe enabled changed to use default strobe types
	- strobe/quality/override speed?
	- additional strobe addons in saves
strobes library/navigation?

on player connect, send/save laser info

--]]

LasersPlus = {}
LasersPlus._mod_path = LasersPlus.GetPath and LasersPlus:GetPath() or ModPath
LasersPlus._settings_save_path = SavePath .. "lp3_settings.json"
LasersPlus._strobes_save_path = SavePath .. "lp3_strobes.json"
LasersPlus._legacy_settings_save_path = SavePath .. "lasersplus.json"
LasersPlus._menu_path = LasersPlus._mod_path .. "menu/options.json"
LasersPlus._default_localization_path = LasersPlus._mod_path .. "localization/english.json"
LasersPlus.url_colorpicker = "https://modwork.shop/29641"
LasersPlus.STROBE_NETWORKING_STRING_TEMPLATE = "$DURATION:$COLORS"

LasersPlus.LuaNetID = "lasersplus_v3"
--these aren't used
LasersPlus.LegacyID = "nncpl"
LasersPlus.LegacyID2 = "gmcpwlc"
LasersPlus.LegacyID3 = "nncpl_gr_v1"
LasersPlus.LuaNetID4 = "lasersplus"

LasersPlus.DEFAULT_VALUES = {
	laser_strobe = "strobe_lasersplus_rainbow",
	flashlight_strobe = "strobe_lasersplus_flicker_yellow"
}

LasersPlus.DEFAULT_STROBES = {
	strobe_lasersplus_rainbow = {
		name = "menu_strobe_lasersplus_rainbow",
		duration = 1,
		colors = {
			{
				position = 0/6,
				color = "ff0000",
			},
			{
				position = 1/6,
				color = "ffff00",
			},
			{
				position = 2/6,
				color = "00ff00",
			},
			{
				position = 3/6,
				color = "00ffff",
			},
			{
				position = 4/6,
				color = "0000ff",
			},
			{
				position = 5/6,
				color = "ff00ff",
			},
		}
	},
	strobe_lasersplus_flicker_yellow = {
		name = "menu_strobe_lasersplus_flicker_yellow",
		speed = 1,
		colors = {
			{
				position = 0,
				color = "ff0000"
			},
			{
				position = 1,
				color = "0000ff"
			}
		}
	}
}

LasersPlus.DISPLAY_MODES = {
	DISABLED = 1,
	UNCHANGED = 2,
	CUSTOM = 3,
	PEER = 4
}

LasersPlus.processed_strobes = {}
LasersPlus.strobe_menu_indices = {}
LasersPlus._laser_weapons_lookup = {}
LasersPlus._laser_units_lookup = {}

LasersPlus.default_settings = {
	enabled_mod_master = true,
	--if false, this mod does not do stuff
	--if true, this mod does stuff
	
	enabled_laser_strobes_master = true,
	--if false, this mod will not render any strobes, and will instead opt for solid-color lasers if applicable
	
	enabled_flashlight_strobes_master = false,
	--no callback yet
	
	enabled_networking = true,
--if true:
--* sends your custom laser strobe pattern to other clients
--* receives custom strobe patterns from other Lasers+ clients and displays them
--on by default


	max_red_ratio = 0.66,
	enabled_redfilter = false,
--if true:
--* using the red, green and blue value (range 0-1 inclusive ) of any incoming teammate laser (does not include own laser).
-- if the following statement is true:
--		red * 0.66 > green + blue
-- then the teammate's laser color is overridden. 


	own_laser_strobe_id = true,
	own_flashlight_strobe_id = true,
	team_laser_strobe_id = true,
	team_flashlight_strobe_id = true,
	world_strobe_id = true,
	sniper_strobe_id = true,
	turret_strobe_id = true,
	npc_flashlight_strobe_id = true,
--these ids use a lookup table against the list of customized strobes,
--similar to ACH's settings. on startup/setup, this id is checked against a list of the strobes that the player has saved,
--and reset if the strobe in question no longer exists.



	sight_override_enabled = true,
-- controls whether "change default sight reticule and gadget color" is enabled
	sight_color = 3,
	sight_type = 1,
--if enabled, uses the reticle colors/textures with these indices (list built automatically)
	
	enabled_multigadget = true,
-- controls whether "activate multiple gadgets" is enabled
 
	disabled_sight_cycle = false,
-- controls whether sight gadgets can be excluded from the 


--the following flashlight settings apply to your flashlight only
	flashlight_glow_opacity = 16,
--controls how visible the flashlight glow cone is (does not affect the functionality of the flashlight itself)
	flashlight_range = 10,
--distance after which flashlight no longer illuminates objects 
	flashlight_angle = 60,
--angle at which flashlight will successfully illuminate nearby objects
	
	flashlight_halloween_mode = false,
	--forces halloween mode, if you're into that, i guess

	custom_strobes = {
		
	},
--contains a list of strobes with which to animate lasers' or flashlights' colors over time	
--(only contains the strobes added by the player)


--the remaining following settings control laser and flashlight appearances
--display modes are standardized to the following:
--* 1: invisible. this laser or flashlight is not shown to you.
--* 2: vanilla. this laser or flashlight is not changed from whatever color it would be normally.
--* 3: custom. this laser or flashlight will use the specific color or strobe of your choice.
--* 4: (only for teammate lasers/flashlights) the laser or flashlight is colored according to which player color they are-
--	eg. player 1 is green, player 2 is blue, player 3 is red, player 4 is yellow
	own_laser_display_mode = 3,
	own_laser_color = "ffffff",
	own_laser_alpha = 0.5,
	own_laser_thickness = 0.5,
	
	own_flash_display_mode = 2,
	own_flash_color = "ffffff",
	own_flash_alpha = 1,
	
	team_laser_display_mode = 3,
	team_laser_color = "ffffff",
	team_laser_alpha = 0.5,
	team_laser_thickness = 0.25,
	
	team_flash_display_mode = 2,
	team_flash_color = "ffffff",
	team_flash_alpha = 1,
	
	npc_laser_display_mode = 3,
	npc_laser_color = "ffffff",
	npc_laser_alpha = 1,
	npc_laser_thickness = 0.25,
	
	npc_flash_display_mode = 2,
	npc_flash_color = "ffffff",
	npc_flash_alpha = 1,
	
	world_display_mode = 3,
	world_laser_color = "ffffff",
	world_laser_alpha = 1,
	world_laser_thickness = 0.25,
	
	turr_laser_display_mode = 3,
	turr_att_laser_color = "ffffff",
	turr_att_laser_alpha = 1,
	turr_att_laser_thickness = 0.25,
	
	turr_rld_laser_color = "ffffff",
	turr_rld_laser_alpha = 1,
	turr_rld_laser_thickness = 0.25,
	
	turr_mad_laser_color = "ffffff",
	turr_mad_laser_alpha = 1,
	turr_mad_laser_thickness = 0.25,
	
	peer_color_1 = "ff0000" or Color(0.19,0.93,0.31),
	peer_color_2 = "ff0000" or Color(0.2,0.3,1),
	peer_color_3 = "ff0000" or Color(1,0.15,0.35),
	peer_color_4 = "ff0000" or Color(0.85,0.55,0.1),
	peer_color_5 = "00ffff"
}

function LasersPlus:Log(...)
	if not Console then 
		return log("LasersPlus:",...)
	end
	local s = "LasersPlus:"
	local spacer = string.rep(" ",2)
	--table.concat would work but it doesn't tostring() its elements so it crashes on userdata-
	--not acceptable when working primarily with Color() objects (a userdata value)
	for _,v in ipairs({...}) do
		s = s .. spacer .. tostring(v)
	end
	Console:Log(s)
end

LasersPlus.settings = LasersPlus.settings or {}

for k,v in pairs(LasersPlus.default_settings) do 
	LasersPlus.settings[k] = LasersPlus.settings[k] or v
end

-- ===================================== UTILS ==========================================

function LasersPlus.CheckLaser(base)
	
end

function LasersPlus:GetCustomWeaponLaserOverride(weaponlaser)
	local weapon = self:GetWeaponBaseFromLaserUnit(weaponlaser)
	if not weapon then
		return
	end
	local weapon_name = weapon:get_name_id()
	local wtd = tweak_data.weapon[weapon_name]
	if wtd then 
		if wtd.forced_laser_hex then 
			return Color(wtd.forced_laser_hex)
		elseif wtd.forced_laser then
			return LuaNetworking:StringToColour(forced_laser)
		end
		--currently i'm really regretting not making this formatted as hex to start out with
	end
	return false
end

function LasersPlus.GetUserTypeFromUnit(unit)
	local user_type = "npc"
	local wpn_base,peer_id = LasersPlus:GetWeaponBaseFromLaserUnit(unit)
	if peer_id then 
		if peer_id == managers.session:network():local_peer():id() then 
			user_type = "own"
		else
			user_type = "team"
		end
	end
	return user_type,peer_id
end

function LasersPlus:GetWeaponBaseFromLaserUnit(unit)
	local laser_key = unit:key()
	if laser_key and self._laser_weapons_lookup[laser_key] then
		return self._laser_weapons_lookup[laser_key] --if already indexed
	end
	
	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end
	local weapon_base
	for id,character in pairs(criminals_manager._characters) do
		if alive(character.unit) and character.unit:inventory() and character.unit:inventory():equipped_unit() then
			weapon_base = character.unit:inventory():equipped_unit():base()
			if self:CheckWeaponForLasers(weapon_base,laser_key) then
				self._laser_weapons_lookup[laser_key] = weapon_base
				return weapon_base,(character.peer_id ~= 0) and character.peer_id
			end
		end
	end
	return
end

function LasersPlus:CheckWeaponForLasers( weapon_base, key )
--todo get custom color table from this
	
	if weapon_base and weapon_base._factory_id and weapon_base._blueprint then

		local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weapon_base._factory_id, weapon_base._blueprint)
		if gadgets then
			for _, i in ipairs(gadgets) do
				if not weapon_base._parts[i].unit then 
					self:Log("CheckWeaponForLasers: No weapon part found for unit")
					break
				else
					local gadget_key = weapon_base._parts[i].unit:key()
					if gadget_key == key then
						return true
					end
				end
			end
		end

	end
	return false

end

--not used
function LasersPlus:GetCriminalNameFromLaserUnit( unit )
	local laser_key = unit:key()
	if laser_key and self._laser_units_lookup[laser_key] ~= nil then
		return self._laser_units_lookup[laser_key]
	end

	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end

	for id, character in pairs(criminals_manager._characters) do
		if alive(character.unit) and character.unit:inventory() and character.unit:inventory():equipped_unit() then

			local weapon_base = character.unit:inventory():equipped_unit():base()
			if self:CheckWeaponForLasers( weapon_base, laser_key ) then
				self._laser_units_lookup[laser_key] = character.name
				return character.name
			end

			if weapon_base._second_gun then
				if self:CheckWeaponForLasers( weapon_base._second_gun:base(), laser_key ) then
					self._laser_units_lookup[laser_key] = character.name
					return character.name
				end
			end

		end
	end

	self._laser_units_lookup[laser_key] = false
	return

end

function LasersPlus.ShowMissingColorPickerDependencyPrompt()
	QuickMenu:new(managers.localization:text("menu_lasersplus_prompt_missing_colorpicker_title"),string.gsub(managers.localization:text("menu_lasersplus_prompt_missing_colorpicker_desc"),"$URL",LasersPlus.url_colorpicker),{
		text = managers.localization:text("menu_ok")
	},true)
end

LasersPlus.color_to_hex = (ColorPicker and ColorPicker.color_to_hex) or (BeardLib and Color.to_hex)

-- ===================================== SETTINGS GETTERS ==========================================

--Enables the whole mod's effects
function LasersPlus:IsEnabled()
	return self.settings.enabled_mod_master
end

function LasersPlus:GetOwnLaserParams()
	return {
		color = self.settings.own_laser_color,
		alpha = self.settings.own_laser_alpha,
		thickness = self.settings.own_laser_thickness,
		strobe_id = nil,
		display_mode = self.settings.own_laser_display_mode
	}
end

function LasersPlus:GetOwnFlashlightParams()
	return {
		color = self.settings.own_flash_color,
		alpha = self.settings.own_flash_alpha,
		strobe_id = nil,
		
		glow_opacity = self.settings.flashlight_glow_opacity,
		range = self.settings.flashlight_range,
		angle = self.settings.flashlight_angle
	}
end

function LasersPlus:GetTeamLaserParams()
	return {
		color = self.settings.team_laser_color,
		alpha = self.settings.team_laser_alpha,
		thickness = self.settings.team_laser_thickness,
		strobe_id = nil

	}
end

function LasersPlus:GetTeamFlashlightParams()
	return {
		color = self.settings.team_flash_color,
		alpha = self.settings.team_flash_alpha,
		strobe_id = nil
	}
end

function LasersPlus:GetNPCLaserParams()
	return {
		color = self.settings.npc_laser_color,
		alpha = self.settings.npc_laser_alpha,
		thickness = self.settings.npc_laser_thickness,
		strobe_id = nil
	}
end

function LasersPlus:GetNPCFlashlightParams()
	return {
		color = self.settings.npc_flash_color,
		alpha = self.settings.npc_flash_alpha,
		strobe_id = nil
	}
end

function LasersPlus:GetWorldLaserParams()
	return {
		color = self.settings.world_laser_color,
		alpha = self.settings.world_laser_alpha,
		thickness = self.settings.world_laser_thickness,
		strobe_id = nil
	}
end

function LasersPlus:GetTurretAttLaserParams()
	return {
		color = self.settings.turr_att_laser_color,
		alpha = self.settings.turr_att_laser_alpha,
		thickness = turr_att_laser_thickness,
		strobe_id = nil
	}
end

--returns the setting for the peer color of the peer id, if it exists
function LasersPlus:GetPeerColor(peer_id)
	return self.settings["peer_color_" .. string.format("%i",peer_id)]
end

-- ===================================== SETTINGS SETTERS ==========================================


-- ===================================== PROCESSING ==========================================

function LasersPlus:GenerateStrobeFromData(strobe_data)
	table.sort(strobe_data.colors,function(a,b)
		return a.position < b.position
	end)
end

--format a strobe into a string ready to sync to other players
function LasersPlus:StrobeToString(strobe_data)
	local str = self.STROBE_NETWORKING_STRING_TEMPLATE
	str = string.gsub(str,"$DURATION",string.format("%0.4f",strobe_data.duration))
	local tbl = {}
	for i,color_data in pairs(strobe_data.colors) do 
		local hex = self.color_to_hex(color_data.color)
		local position = string.format("%0.4f",color_data.position)
		tbl[i] = position .. "," .. hex
		color_str = color_str 
	end
	local color_str = table.concat(tbl,";")
	str = string.gsub(str,"$COLORS",color_str)
	return str
end

--takes a string from lua networking (sent from another LasersPlus user) and parses it into an unprocessed strobe
--name is based on the peer id of the sender, so you can only store one at a time
function LasersPlus:StringToStrobe(s,name)
	local FALLBACK_DURATION = 4
	
	local d1 = string.split(s,":")
	local duration = d1[1]
	
	duration = duration and tonumber(duration) or FALLBACK_DURATION
	
	local d2 = d1[2]
	local d3 = string.split(d2,";")
	local colors = {}
	for i,d4 in pairs(d3) do 
		local color_data = string.split(d4,",")
		local position = color_data[1]
		position = position and tonumber(position) or (i / #d3)
		local new_color = {
			position = position,
			color = Color(color_data[2])
		}
		colors[#colors+1] = new_color
	end
	
	--if your strobe doesn't have at least two colors then why do you need a strobe
	if #colors < 2 then 
		return false
	end
	
	return {
		name = name,
		duration = duration,
		colors = colors
	}
end

--processes all current strobes and assigns each strobe an index for reference by the menu system
function LasersPlus:UnpackStrobes()
	local strobes_menu_indices = {}
	for id,strobe_data in pairs(self.DEFAULT_STROBES) do 
		local new_index = #strobes_menu_indices+1
		local new_strobe = self:ProcessStrobe(strobe_data)
		table.insert(strobes_menu_indices,new_index,id)
		table.insert(self.processed_strobes,new_index,new_strobe)
	end
	for id,strobe_data in pairs(self.settings.custom_strobes) do 
		local new_index = #strobes_menu_indices+1
		local new_strobe = self:ProcessStrobe(strobe_data)
		table.insert(self.processed_strobes,new_index,new_strobe)
		
	end
	--self.settings.custom_strobes
	--self.processed_strobes
end

--TODO
--processes a strobe for use by a laser
function LasersPlus:ProcessStrobe(strobe_data,quality)
	local duration = strobe_data.duration
	quality = 100
	--quality should be roughly equal to (ideally, not less than) your fps
	
	local processed_strobe = {}
	
	local col_1 = strobe_data.colors[1]
	local col_2 = strobe_data.colors[2]
	local color_index = 1
	for i = 0,quality do 
--		processed_strobe[i] = 1
	end
end

-- ===================================== I/O FUNCTIONS ==========================================

function LasersPlus:LoadStrobes()
	local file = io.open(self._strobes_save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings.custom_strobes[k] = v
		end
		file:close()
	else
		self:SaveStrobes()
	end
	self:UnpackStrobes()
end

function LasersPlus:SaveStrobes()
	local file = io.open(self._strobes_save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function LasersPlus:LoadSettings(skip_strobes)
	local file = io.open(self._settings_save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
		file:close()
	else
		LasersPlus:SaveSettings() --create data in case there's no mod save data called lasersplus.txt; saves are only generated on changing any settings otherwise
	end
	if not skip_strobes then
		self:LoadStrobes()
	end
end


function LasersPlus:SaveSettings(skip_strobes)
	local file = io.open(self._settings_save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
	if not skip_strobes then 
		self:SaveStrobes()
	end
end
	
-- *****    Receive Data    *****
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_lasersplus", function(sender, message, data)
--[[
	if message == LasersPlus.LuaNetID or message == LasersPlus.LegacyID then
		local criminals_manager = managers.criminals
		if not criminals_manager then
			return
		end
		if message == LasersPlus.LegacyID and sender then 
			lp_log("Sender with peerid [" .. sender .. "] is running legacy Networked Lasers!")
			--should we... decode it?
		elseif message == LasersPlus.LuaNetID and sender then 
			if type(data) ~= "string" then
				lp_log("Wrong data type received!")
				--this shouldn't ever happen anyway, luanetworking only sends strings
				return
			end
		end

		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		if not data then
			lp_log("Received LuaNetworking Data is nil!")
			--again, this should never happen
			return
		end
		if string.find(data, "l") then
			if char and not LasersPlus.SavedTeamStrobes[char] then
				col = LasersPlus:init_strobe(LasersPlus:StringToStrobeTable(data))
				LasersPlus.SavedTeamStrobes[char] = col
				lp_log("Saved a team strobe to the table")
				return
			end
		elseif data ~= "nil" then
			lp_log("Found networked color data.")
			col = LuaNetworking:StringToColour(data) --LuaNetworking:StringToColour(data)
			if not LasersPlus:FilterRedLasers(col) then
				col = nil
				lp_log("Blocked laser " .. tostring(data) .. " from character " .. tostring(char or "nil") .. "(contained too much red)")
			end
			return
		end
		
		if char then
			LasersPlus.SavedTeamColors[char] = col --todo save based on steamid64 instead of heister-character name
			--i dunno though this mod is already pretty bulky, i might need to be careful that this mod doesn't impact performance too much
			lp_log("Saved networked color for character " .. tostring(char)) --or cleared if col is nil
			return
		end
	end
--]]
end)

Hooks:Add("LocalizationManagerPostInit", "lasersplus_LocalizationManagerPostInit", function( loc )
	if not BeardLib then 
		loc:load_localization_file(LasersPlus._default_localization_path)
	end
end)

--import settings from versions of LasersPlus prior to v3
if SystemFS:exists( Application:nice_path( LasersPlus._legacy_settings_save_path, true )) and not SystemFS:exists( Application:nice_path( LasersPlus._settings_save_path, true )) then 
	local legacy_settings_file = io.open(LasersPlus._legacy_settings_save_path, "r")
	local legacy_settings
	if legacy_settings_file then
		legacy_settings = json.decode(legacy_settings_file:read("*all"))

		local new_color_settings = {
			own_laser_color = Color.white,
			own_flash_color = Color.white,
			team_laser_color = Color.white,
			team_flash_color = Color.white,
			npc_laser_color = Color.white,
			npc_flash_color = Color.white,
			world_laser_color = Color.white,
			turr_att_laser_color = Color.white,
			turr_rld_laser_color = Color.white,
			turr_mad_laser_color = Color.white
		}
		
		local function set_color_value(key,channel,value)
			new_color_settings[key][channel] = value
		end
		
		local legacy_keys = {
			own_laser_red = function(legacy_value,current_value)
				set_color_value("own_laser_color","r",legacy_value)
				return false
			end,
			own_laser_green = function(legacy_value,current_value)
				set_color_value("own_laser_color","g",legacy_value)
				return false
			end,
			own_laser_blue = function(legacy_value,current_value)
				set_color_value("own_laser_color","b",legacy_value)
				return false
			end,
			own_flashlight_display_mode = "own_flash_display_mode",
			team_laser_red = function(legacy_value,current_value)
				set_color_value("team_laser_color","r",legacy_value)
				return false
			end,
			team_laser_green = function(legacy_value,current_value)
				set_color_value("team_laser_color","g",legacy_value)
				return false
			end,
			team_laser_blue = function(legacy_value,current_value)
				set_color_value("team_laser_color","b",legacy_value)
				return false
			end,
			team_flashlight_display_mode = "team_flash_display_mode",
			sniper_display_mode = "npc_laser_display_mode",
			cop_flashlight_display_mode = "npc_flash_display_mode",
			snpr_laser_red = function(legacy_value,current_value)
				set_color_value("npc_laser_color","r",legacy_value)
				return false
			end,
			snpr_green = function(legacy_value,current_value)
				set_color_value("npc_laser_color","g",legacy_value)
				return false
			end,
			snpr_blue = function(legacy_value,current_value)
				set_color_value("npc_laser_color","b",legacy_value)
				return false
			end,
			snpr_alpha = "npc_laser_alpha",
			wl_red = function(legacy_value,current_value)
				set_color_value("world_laser_color","r",legacy_value)
				return false
			end,
			wl_green = function(legacy_value,current_value)
				set_color_value("world_laser_color","g",legacy_value)
				return false
			end,
			wl_blue = function(legacy_value,current_value)
				set_color_value("world_laser_color","b",legacy_value)
				return false
			end,
			wl_alpha = "world_laser_alpha",
			turret_display_mode = "turr_laser_display_mode",
			turr_att_red = function(legacy_value,current_value)
				set_color_value("turr_att_laser_color","r",legacy_value)
				return false
			end,
			turr_att_green = function(legacy_value,current_value)
				set_color_value("turr_att_laser_color","g",legacy_value)
				return false
			end,
			turr_att_blue = function(legacy_value,current_value)
				set_color_value("turr_att_laser_color","b",legacy_value)
				return false
			end,
			turr_rld_red = function(legacy_value,current_value)
				set_color_value("turr_rld_laser_color","r",legacy_value)
				return false
			end,
			turr_rld_green = function(legacy_value,current_value)
				set_color_value("turr_rld_laser_color","g",legacy_value)
				return false
			end,
			turr_rld_blue = function(legacy_value,current_value)
				set_color_value("turr_rld_laser_color","b",legacy_value)
				return false
			end,
			turr_mad_red = function(legacy_value,current_value)
				set_color_value("turr_mad_laser_color","r",legacy_value)
				return false
			end,
			turr_mad_green = function(legacy_value,current_value)
				set_color_value("turr_mad_laser_color","g",legacy_value)
				return false
			end,
			turr_mad_blue = function(legacy_value,current_value)
				set_color_value("turr_mad_laser_color","b",legacy_value)
				return false
			end,
			enabled_blackmarket_qol = function(legacy_value,current_value)
				LasersPlus.settings.sight_override_enabled = legacy_value
				return false
			end,
			
			own_laser_strobe_enabled = function(legacy_value,current_value)
				return "own_laser_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.laser_strobe or "none"
			end,
			own_flashlight_strobe_enabled = function(legacy_value,current_value)
				return "own_flashlight_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.flashlight_strobe or "none"
			end,
			
			team_laser_strobe_enabled = function(legacy_value,current_value)
				return "team_laser_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.laser_strobe or "none"
			end,
			team_flashlight_strobe_enabled = function(legacy_value,current_value)
				return "team_flashlight_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.flashlight_strobe or "none"
			end,
			
			world_strobe_enabled = function(legacy_value,current_value) 
				return "world_laser_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.laser_strobe or "none"
			end,
			sniper_strobe_enabled = function(legacy_value,current_value)
				return "npc_laser_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.flashlight_strobe or "none"
			end,
			npc_flashlight_strobe_enabled = function(legacy_value,current_value)
				return "npc_flashlight_strobe_id",legacy_value and LasersPlus.DEFAULT_VALUES.flashlight_strobe or "none"
			end,
			turret_strobe_enabled = function(legacy_value,current_value)
				if legacy_value then 
					LasersPlus.settings.turret_att_laser_strobe_id = "strobe_lasersplus_flicker_yellow"
					LasersPlus.settings.turret_mad_laser_strobe_id = "strobe_lasersplus_flicker_yellow"
					LasersPlus.settings.turret_rld_laser_strobe_id = "strobe_lasersplus_flicker_yellow"
				else
					LasersPlus.settings.turret_att_laser_strobe_id = "none"
					LasersPlus.settings.turret_mad_laser_strobe_id = "none"
					LasersPlus.settings.turret_rld_laser_strobe_id = "none"
				end
				return false
			end
		}
		
		for k,v in pairs(legacy_keys) do 
			local legacy_setting_value = legacy_settings[k]
			if (legacy_setting_value ~= nil) then 
				if type(v) == "function" then 
					local new_key,new_value = v(legacy_setting_value,LasersPlus.settings[k])
					if new_key then 
						LasersPlus.settings[new_key] = new_value
					end
				elseif v == true then
					local new_key = v
					LasersPlus.settings[new_key] = legacy_setting_value
				end
			end
		end
		for k,v in pairs(new_color_settings) do 
			LasersPlus.settings[k] = LasersPlus.color_to_hex(v)
		end
		
		LasersPlus:SaveSettings()
	else
		LasersPlus:Log("ERROR: Legacy Settings file found at \"" .. tostring(LasersPlus._legacy_settings_save_path) .. "\", but reading failed.")
	end
end