--[[
todo:
legacy settings import
	- color from rgb to hex
	- blackmarket qol split into separate settings
	- strobe enabled changed to use default strobe types
	- strobe/quality/override speed?
strobes library/navigation?
laser thiccness

on player connect, send/save laser info

--]]

LasersPlus = {}
LasersPlus._mod_path = LasersPlus.GetPath and LasersPlus:GetPath() or ModPath
LasersPlus._settings_save_path = SavePath .. "lasersplus_settings.json"
LasersPlus._strobes_save_path = SavePath .. "lasersplus_strobes.json"
LasersPlus._legacy_settings_save_path = SavePath .. "lasersplus.json"
LasersPlus._menu_path = LasersPlus._mod_path .. "menu/options.json"
LasersPlus._default_localization_path = LasersPlus._mod_path .. "localization/english.json"
LasersPlus.url_colorpicker = "https://modwork.shop/29641"

LasersPlus.LuaNetID = "lasersplus_v3"
--these aren't used
LasersPlus.LegacyID = "nncpl"
LasersPlus.LegacyID2 = "gmcpwlc"
LasersPlus.LegacyID3 = "nncpl_gr_v1"
LasersPlus.LuaNetID4 = "lasersplus"

LaserPlus.DEFAULT_VALUES = {
	laser_strobe = "strobe_lasersplus_rainbow",
	flashlight_strobe = "strobe_lasersplus_flicker_yellow"
}
LasersPlus.DEFAULT_STROBES = {
	strobe_lasersplus_rainbow = {
		name = "menu_strobe_lasersplus_rainbow",
		speed = 1,
		colors = {
		
		}
	},
	strobe_lasersplus_flicker_yellow = {
		name = "menu_strobe_lasersplus_flicker_yellow",
		speed = 1,
		colors = {
		
		}
	}
}


LasersPlus.processed_strobes = {}
LasersPlus.strobe_menu_indices = {}


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


	own_laser_display_mode = 3,
	own_flashlight_display_mode = 2,
	team_laser_display_mode = 3,
	team_flashlight_display_mode = 2,
	cop_flashlight_display_mode = 2,
	world_display_mode = 3,
	turret_display_mode = 3,
	sniper_display_mode = 3,
--display modes are standardized to the following:
--* 1: invisible. this laser or flashlight is not shown to you.
--* 2: vanilla. this laser or flashlight is not changed from whatever color it would be normally.
--* 3: custom. this laser or flashlight will use the specific color or strobe of your choice.
--* 4: (only for teammate lasers/flashlights) the laser or flashlight is colored according to which player color they are-
--	eg. player 1 is green, player 2 is blue, player 3 is red, player 4 is yellow
	
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
 
	disabled_sight_cycle = false
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
	own_laser_color = "ffffff",
	own_laser_alpha = 1,
	own_laser_thickness = 0.5,
	
	own_flash_color = "ffffff",
	own_flash_alpha = 1,
	
	team_laser_color = "ffffff",
	team_laser_alpha = 1,
	team_laser_thickness = 0.25,
	
	team_flash_color = "ffffff",
	team_flash_alpha = 1,
	
	npc_laser_color = "ffffff",
	npc_laser_alpha = 1,
	npc_laser_thickness = 0.25,
	
	npc_flash_color = "ffffff",
	npc_flash_alpha = 1,
	npc_laser_thickness = 0.25,
	
	wl_laser_color = "ffffff",
	wl_laser_alpha = 1,
	wl_laser_thickness = 0.25,
	
	turr_att_laser_color = "ffffff",
	turr_att_laser_alpha = 1,
	turr_att_laser_thickness = 1,
	
	turr_rld_laser_color = "ffffff",
	turr_rld_laser_alpha = 1,
	turr_rld_laser_thickness = 1,
	
	turr_mad_laser_color = "ffffff",
	turr_mad_laser_alpha = 1
	turr_mad_laser_thickness = 1
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
			wl_laser_color = Color.white,
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
			local color_to_hex = (ColorPicker and ColorPicker.color_to_hex) or (BeardLib and Color.to_hex)
			LasersPlus.settings[k] = color_to_hex(v)
		end
		
		LasersPlus:SaveSettings()
	else
		LasersPlus:Log("ERROR: Legacy Settings file found at \"" .. tostring(LasersPlus._legacy_settings_save_path) .. "\", but reading failed.")
	end
	--queue prompt here
end



-- ===================================== UTILS ==========================================


function LasersPlus.ShowMissingColorPickerDependencyPrompt()
	QuickMenu:new(managers.localization:text("menu_lasersplus_prompt_missing_colorpicker_title"),string.gsub(managers.localization:text("menu_lasersplus_prompt_missing_colorpicker_desc"),"$URL",LasersPlus.url_colorpicker),{
		text = managers.localization:text("menu_ok")
	},true)
end

-- ===================================== SETTINGS GETTERS ==========================================

--Enables the whole mod's effects
function LasersPlus:IsEnabled()
	return self.settings.enabled_mod_master
end

-- ===================================== SETTINGS SETTERS ==========================================


-- ===================================== PROCESSING ==========================================

function LasersPlus:UnpackStrobes()
	--self.settings.custom_strobes
	--self.processed_strobes
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