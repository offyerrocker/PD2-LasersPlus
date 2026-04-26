LasersPlus = LasersPlus or {}
LasersPlus._mod_path = LasersPlusCore.GetPath and LasersPlusCore:GetPath() or ModPath
LasersPlus._default_localization_path = LasersPlus._mod_path .. "localization/english.json"

LasersPlus.LASERSPLUS_SAVEFILE_VERSION = "v3"
LasersPlus._save_directory = LasersPlus._save_directory or SavePath
LasersPlus._legacy_settings_path = LasersPlus._save_directory .. "lp3_settings.json"
LasersPlus._converted_legacy_settings_path = LasersPlus._save_directory .. "OLD_lp3_settings.json"
LasersPlus._settings_path = LasersPlus._save_directory .. "lasersplus_settings.json"
LasersPlus.STROBE_NETWORKING_STRING_TEMPLATE = "$DURATION:$COLORS"

LasersPlus._config_path = LasersPlus._save_directory .. "lasersplus_extra_config.ini"
LasersPlus._util_LIP = LasersPlus._util_LIP or dofile(LasersPlus._mod_path .. "req/LIP.lua")

LasersPlus.NETWORK_EVENT_IDS = {
	LASERSPLUS_SYNC_GADGET_ALL	 = "LasersPlus_sync_gadgets"
--	,LASERSPLUS_SYNC_GADGET_LASER = "LasersPlus_sync_laser",
--	LASERSPLUS_SYNC_GADGET_FLASH = "LasersPlus_sync_flash"
}

LasersPlus.default_settings = {
	version = "v3",
	
--the remaining following settings control laser and flashlight appearances
--display modes are standardized to the following:
--* 1: vanilla. this laser or flashlight is not changed from whatever color it would be normally.
--* 2: custom. this laser or flashlight will use the specific color or strobe of your choice.
--* 3: (only for player/teammate lasers/flashlights) the laser or flashlight is colored according to which player color they are-
--	eg. player 1 is green, player 2 is blue, player 3 is red, player 4 is yellow
	
	feature_enabled_gadget_network_sync = true,
	feature_enabled_laser_override = true, -- if true, allows changing laser beam and dot width, but requires overriding laser update (possibly incompatible with other mods)
	feature_enabled_flashlight_override = true, -- if true, allows changing flashlight glow opacity, but requires overriding flashlight set_color (possibly incompatible with other mods)
	
	
	feature_enabled_laser_accurate = false, -- if true, weapon laser more closely follows the crosshair (weapon position)
	
	feature_enabled_laser_redfilter = true,
	feature_enabled_qol_defaultgadget = true,
	feature_enabled_qol_blackmarket_colorpicker = true,
	
	feature_state_gadget_multigadget = 2,
	
	qol_defaultgadget_sight_color = 1,
	qol_defaultgadget_sight_type = 1,
	
	user_laser_color = "00ff00",
	user_laser_alpha = 0.7,
	user_laser_display_mode = 2,
	user_laser_radius = 0.25,
	user_laser_strobe_enabled = false,
	user_laser_strobe_string = "#3:0,ff0000;0.33,00ff00;0.66,0000ff",
	
	user_flash_color = "dbddff",
	user_flash_alpha = 1,
	user_flash_display_mode = 2,
	user_flash_range = 10,
	user_flash_angle = 60,
	user_flash_strobe_enabled = false,
	user_flash_strobe_string ="#1:0,ff0000;0.1667,ffff00;0.3333,00ff00;0.5,00ffff;0.6667,0000ff;0.8333,ff00ff",
	
	team_laser_color = "00ff00",
	team_laser_alpha = 0.5,
	team_laser_display_mode = 1,
	team_laser_radius = 0.5,
	team_laser_strobe_enabled = false,
	team_laser_strobe_string = "#0.5:0,ff0000;0.1667,ffff00;0.3333,00ff00;0.5,00ffff;0.6667,0000ff;0.8333,ff00ff",
	
	team_flash_color = "ffffff",
	team_flash_alpha = 1,
	team_flash_display_mode = 1,
	team_flash_range = 10,
	team_flash_angle = 60,
	team_flash_strobe_enabled = false,
	team_flash_strobe_string = "#1:0,ff0000;0.1667,ffff00;0.3333,00ff00;0.5,00ffff;0.6667,0000ff;0.8333,ff00ff",
	
	enemy_laser_color = "ff0000",
	enemy_laser_alpha = 0.7,
	enemy_laser_display_mode = 2,
	enemy_laser_radius = 0.5,
	enemy_laser_strobe_enabled = true,
	enemy_laser_strobe_string = "#0.5:0,ff0000;0.5,ff4700",
	
	enemy_flash_color = "ffffff",
	enemy_flash_alpha = 1,
	enemy_flash_range = 10,
	enemy_flash_display_mode = 1,
	enemy_flash_angle = 60,
	enemy_flash_strobe_enabled = false,
	enemy_flash_strobe_string = "#1:0,ff0000;0.1667,ffff00;0.3333,00ff00;0.5,00ffff;0.6667,0000ff;0.8333,ff00ff",
	
	world_laser_color = "ff0000",
	world_laser_alpha = 1,
	world_laser_display_mode = 2,
	world_laser_radius = 0.25,
	world_laser_strobe_enabled = true,
	world_laser_strobe_string = "#1:0,ff0000;0.1667,ffff00;0.3333,00ff00;0.5,00ffff;0.6667,0000ff;0.8333,ff00ff",
	
	
	turretatt_laser_color = "ff0000",
	turretatt_laser_alpha = 0.7,
	turretatt_laser_mode = 2,
	turretatt_laser_radius = 0.5,
	turretatt_laser_strobe_enabled = true,
	turretatt_laser_strobe_string = "#0.5:0,ff0000;0.5,ff2853",
	
	turretrld_laser_color = "faff00",
	turretrld_laser_alpha = 0.3,
	turretrld_laser_mode = 2,
	turretrld_laser_radius = 0.5,
	turretrld_laser_strobe_enabled = false,
	turretrld_laser_strobe_string = "#1:0,ff0000;0.5,979a00",
	
	turretmad_laser_color = "00ffff",
	turretmad_laser_alpha = 0.7,
	turretmad_laser_mode = 2,
	turretmad_laser_radius = 0.5,
	turretmad_laser_strobe_enabled = true,
	turretmad_laser_strobe_string = "#0.5:0,00ffff;0.5,00ff94"
	
}
LasersPlus.settings = table.deep_map_copy(LasersPlus.default_settings)

-- can be changed via the ini file;
-- they need to be explicitly stored as a string by prefixing with a non-digit character,
-- in case the R value of the color starts with a decimal digit

LasersPlus.default_config = { 
	redfilter_threshold = 0.66,
	PeerColors = {
		"#c2fc97",
		"#78b7cc",
		"#b26859",
		"#cca166"
	},
	Palettes = {
		"#ff0000",
		"#ffff00",
		"#00ff00",
		"#00ffff",
		"#0000ff",
		"#880000",
		"#888800",
		"#008800",
		"#008888",
		"#000088",
		"#ff8800",
		"#88ff00",
		"#00ff88",
		"#0088ff",
		"#8800ff",
		"#884400",
		"#448800",
		"#008844",
		"#004488",
		"#440088",
		"#ffffff",
		"#bbbbbb",
		"#888888",
		"#444444",
		"#000000"
	}
}

LasersPlus.config = table.deep_map_copy(LasersPlus.default_config)

LasersPlus.SORT_CONFIG = {
	"redfilter_threshold",
	"PeerColors",
	"Palettes"
}

LasersPlus._cached_template_string_laser = LasersPlus._cached_template_string_laser or nil
LasersPlus._cached_template_string_flash = LasersPlus._cached_template_string_flash or nil

-- misnomer as world and sentry lasers aren't literally set up with gadgets,
-- and in fact don't even have flashlights,
-- but i need to categorize them somehow;
-- these basically just hold settings in processed/userdata form.
-- note that each one is explicitly NOT identical, though they are similar.
-- eg. world has no radius option
LasersPlus._gadget_templates = {
	laser = {
		user = {},
		team = {},
		enemy = {},
		world = {},
		turretatt = {},
		turretrld = {},
		turretmad = {}
	},
	flashlight = {
		user = {},
		team = {},
		enemy = {}
--,		world = {},
--		turr_att = {},
--		turr_rld = {},
--		turr_mad = {}
	}
}

-- previously, this was a lookup table by peer
-- then by steamid, but uh. epic games. so.
LasersPlus._gadget_colors_by_user = {
	--[[
	[user_id] = {
		laser_color = "ffd700",
		laser_w = 0,
		flash_color = "ffffff"
		
	}
	
	--]]
}

LasersPlus.LASER_THEMES_LOOKUP = {
	turret_module_active = "turretatt",
	turret_module_rearming = "turretrld",
	turret_module_mad = "turretmad"
}


-- ===================================== Utils ==========================================

function LasersPlus.color_to_hex(color)
	return string.format("%02x%02x%02x", math.min(math.max(color.r * 255,0),0xff),math.min(math.max(color.g * 255,0),0xff),math.min(math.max(color.b * 255,0),0xff))
end

-- only used for local storage, not for networking/syncing
function LasersPlus.serialize_color(color)
	return string.format("#%s",LasersPlus.color_to_hex(color))
end

function LasersPlus.parse_serialized_color(str)
	return string.match(str,"%x+")
end

function LasersPlus.deserialize_color(str)
	return Color(LasersPlus.parse_serialized_color(str))
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
function LasersPlus:StringToStrobe(s)
	local FALLBACK_DURATION = 4
	
	local d1 = string.split(string.match(s,"%d.*"),":")
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
		str = s,
		duration = duration,
		colors = colors
	}
end

function LasersPlus:GetUserTypeByTheme(mode)
	return mode and self.LASER_THEMES_LOOKUP[mode]
end

function LasersPlus:Print(...)
	if _G.Print then
		_G.Print("LasersPlus]",...)
	end
	log("[LasersPlus]",...)
end

-- ===================================== Settings Getters ==========================================

function LasersPlus:IsGadgetNetworkSyncEnabled()
	return self.settings.feature_enabled_gadget_network_sync
end

function LasersPlus:IsLaserRedFilterEnabled()
	return self.settings.feature_enabled_laser_redfilter
end


-- combined getter for feature: default sight gadget, default laser/flashlight color
function LasersPlus:IsQOLDefaultGadgetEnabled()
	return self.settings.feature_enabled_qol_defaultgadget
end

function LasersPlus:GetSightTextureIndex()
	return self.settings.qol_defaultgadget_sight_type
end
function LasersPlus:GetSightColorIndex()
	return self.settings.qol_defaultgadget_sight_color
end


-- ===================================== Templates/Management ==========================================

-- hooked to both laser and flashlight
function LasersPlus.UpdateGadget(lp_data,t,dt)
	-- update strobe
	if lp_data and lp_data.settings and lp_data.settings.strobe_enabled and lp_data.settings.strobe_data then 
		local _t = lp_data.t + dt * lp_data.speed
		lp_data.t = _t
		
--		Console:SetTracker(string.format("upd t %0.2f",_t,lp_data.next_frame_t),1)
		local strobe_data = lp_data.settings.strobe_data
		local duration = strobe_data.duration
		local frames = strobe_data.colors
		
		if _t >= lp_data.next_frame_t then
			
			local last_frame = frames[1 + lp_data.index]
			lp_data.prev_color = last_frame.color
			
			local index = (lp_data.index + 1) % lp_data.strobe_count
			lp_data.index = index
			local frame = frames[1 + index]
			
			local frame_duration = duration * ((frame.position - last_frame.position) % 1)
			lp_data.next_frame_t = lp_data.next_frame_t + frame_duration
			lp_data.frame_duration = frame_duration
		end
		
		local frame = frames[lp_data.index + 1]
		if frame then
			local prev_color = lp_data.prev_color
			local col_d = frame.color - prev_color
			
			-- todo nonlinear interpolation?
			-- quadratic/sin?
			local lerp = 1 - (lp_data.next_frame_t - _t) / lp_data.frame_duration
			
			local color = prev_color + col_d * lerp
--			Console:SetTracker(string.format("upd t %0.2f %i lerp %0.2f / frame_duration %0.2f",_t,lp_data.index,lerp,lp_data.frame_duration),1)

			local alpha = lp_data.settings.alpha
			if alpha then
				--self:set_color(color:with_alpha(alpha))
				return color:with_alpha(alpha)
			else
				return color
				--self:set_color(color)
			end
		end
		
	end
end


function LasersPlus:GetGadgetTemplate(gadget_type,user_type)
	return self._gadget_templates[gadget_type][user_type]
end

function LasersPlus:SetupAllGadgetTemplates()
	self:SetupUserGadgetTemplates()
	self:SetupTeamGadgetTemplates()
	self:SetupEnemyGadgetTemplates()
	self:SetupWorldGadgetTemplates()
	self:SetupTurretActiveGadgetTemplates()
	self:SetupTurretRearmingGadgetTemplates()
	self:SetupTurretMadGadgetTemplates()
end

function LasersPlus:SetupUserGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.user.color = Color(self.settings.user_laser_color)
	laser_templates.user.alpha = self.settings.user_laser_alpha
	laser_templates.user.radius = self.settings.user_laser_radius
	laser_templates.user.mode = self.settings.user_laser_display_mode
	laser_templates.user.strobe_enabled = self.settings.user_laser_strobe_enabled
	laser_templates.user.strobe_data = self:StringToStrobe(self.settings.user_laser_strobe_string)
	
	local flash_templates = self._gadget_templates.flashlight
	flash_templates.user.color = Color(self.settings.user_flash_color)
	flash_templates.user.alpha = self.settings.user_flash_alpha
	flash_templates.user.range = self.settings.user_flash_range
	flash_templates.user.angle = self.settings.user_flash_angle
	flash_templates.user.mode = self.settings.user_flash_display_mode
	flash_templates.user.strobe_enabled = self.settings.user_flash_strobe_enabled
	flash_templates.user.strobe_data = self:StringToStrobe(self.settings.user_flash_strobe_string)
end
function LasersPlus:SetupTeamGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.team.color = Color(self.settings.team_laser_color)
	laser_templates.team.alpha = self.settings.team_laser_alpha
	laser_templates.team.mode = self.settings.team_laser_display_mode
	laser_templates.team.radius = self.settings.team_laser_radius
	laser_templates.team.strobe_enabled = self.settings.team_laser_strobe_enabled
	laser_templates.team.strobe_data = self:StringToStrobe(self.settings.team_laser_strobe_string)
	
	local flash_templates = self._gadget_templates.flashlight
	flash_templates.team.color = Color(self.settings.team_flash_color)
	flash_templates.team.alpha = self.settings.team_flash_alpha
	flash_templates.team.range = self.settings.team_flash_range
	flash_templates.team.angle = self.settings.team_flash_angle
	flash_templates.team.strobe_enabled = self.settings.team_flash_strobe_enabled
	flash_templates.team.strobe_data = self:StringToStrobe(self.settings.team_flash_strobe_string)
end
function LasersPlus:SetupEnemyGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.enemy.color = Color(self.settings.enemy_laser_color)
	laser_templates.enemy.alpha = self.settings.enemy_laser_alpha
	laser_templates.enemy.mode = self.settings.enemy_laser_display_mode
	laser_templates.enemy.radius = self.settings.enemy_laser_radius
	laser_templates.enemy.strobe_enabled = self.settings.enemy_laser_strobe_enabled
	laser_templates.enemy.strobe_data = self:StringToStrobe(self.settings.enemy_laser_strobe_string)
	
	local flash_templates = self._gadget_templates.flashlight
	flash_templates.enemy.color = Color(self.settings.enemy_flash_color)
	flash_templates.enemy.alpha = self.settings.enemy_flash_alpha
	flash_templates.enemy.range = self.settings.enemy_flash_range
	flash_templates.enemy.angle = self.settings.enemy_flash_angle
	flash_templates.enemy.strobe_enabled = self.settings.enemy_flash_strobe_enabled
	flash_templates.enemy.strobe_data = self:StringToStrobe(self.settings.enemy_flash_strobe_string)
end
function LasersPlus:SetupWorldGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.world.color = Color(self.settings.world_laser_color)
	laser_templates.world.alpha = self.settings.world_laser_alpha
	laser_templates.world.mode = self.settings.world_laser_display_mode
	laser_templates.world.radius = self.settings.world_laser_radius
	laser_templates.world.strobe_enabled = self.settings.world_laser_strobe_enabled
	laser_templates.world.strobe_data = self:StringToStrobe(self.settings.world_laser_strobe_string)
end

function LasersPlus:SetupTurretActiveGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.turretatt.color = Color(self.settings.turretatt_laser_color)
	laser_templates.turretatt.alpha = self.settings.turretatt_laser_alpha
	laser_templates.turretatt.mode = self.settings.turretatt_laser_mode
	laser_templates.turretatt.radius = self.settings.turretatt_laser_radius
	laser_templates.turretatt.strobe_enabled = self.settings.turretatt_laser_strobe_enabled
	laser_templates.turretatt.strobe_data = self:StringToStrobe(self.settings.turretatt_laser_strobe_string)
end
function LasersPlus:SetupTurretRearmingGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.turretrld.color = Color(self.settings.turretrld_laser_color)
	laser_templates.turretrld.alpha = self.settings.turretrld_laser_alpha
	laser_templates.turretrld.mode = self.settings.turretrld_laser_mode
	laser_templates.turretrld.radius = self.settings.turretrld_laser_radius
	laser_templates.turretrld.strobe_enabled = self.settings.turretrld_laser_strobe_enabled
	laser_templates.turretrld.strobe_data = self:StringToStrobe(self.settings.turretrld_laser_strobe_string)
end
function LasersPlus:SetupTurretMadGadgetTemplates()
	local laser_templates = self._gadget_templates.laser
	laser_templates.turretmad.color = Color(self.settings.turretmad_laser_color)
	laser_templates.turretmad.alpha = self.settings.turretmad_laser_alpha
	laser_templates.turretmad.mode = self.settings.turretmad_laser_mode
	laser_templates.turretmad.radius = self.settings.turretmad_laser_radius
	laser_templates.turretmad.strobe_enabled = self.settings.turretmad_laser_strobe_enabled
	laser_templates.turretmad.strobe_data = self:StringToStrobe(self.settings.turretmad_laser_strobe_string)
end

function LasersPlus:CheckRedLaserFilter(col) 
--returns false if contains too much red, or invalid data
--returns true if does not contain too much red, or if filter option is off
	if not col then
		return false --sanity checker? i 'ardly even know 'er
	end
	local r = col.r or col.red
	local g = col.g or col.green
	local b = col.b or col.blue
	local threshold = self.config.redfilter_threshold or self.default_config.redfilter_threshold
	if r * threshold > g + b then --if red is n% larger than green+blue
		return false
	end
	return true
	
end

-- ===================================== I/O ==========================================

function LasersPlus:LoadSettings()
	local file = io.open(self._settings_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
		file:close()
	end
end

function LasersPlus:SaveSettings()
	local file = io.open(self._settings_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

-- stores things that don't really have a menu option,
-- or don't fit the settings schema (such as palettes, which is a table of unspecified size)
-- or should otherwise be readable and editable by determined humans
function LasersPlus:LoadConfig()
	if SystemFS and SystemFS:exists( Application:nice_path( self._config_path, true )) then
		self._util_LIP:load(self._config_path)
	end
end
function LasersPlus:SaveConfig()
	self._util_LIP:save(self._config_path,self.config,self.SORT_CONFIG)
end

function LasersPlus:convert_save_data(settings_from_file)
	if settings_from_file.version == self.LASERSPLUS_SAVEFILE_VERSION then
		return settings_from_file
	else
		local old = settings_from_file
		if self.LASERSPLUS_SAVEFILE_VERSION == "v3" then
			local new_settings = table.deep_map_copy(self.default_settings)
			if not old.version then
				-- convert from 2.91 and below
				
				local function apply_float_with_fallback(value,fallback)
					value = value and tonumber(value)
					if value then 
						return value
					end
					return fallback
				end
				
				local function apply_color_with_fallback(r,g,b,fallback)
					r = r and tonumber(r)
					g = g and tonumber(g)
					b = b and tonumber(b)
					if r and g and b then 
						return string.format("%02x%02x%02x",r,g,b)
					end
					return fallback
				end
				
				local function apply_bool_with_fallback(value,fallback)
					if value ~= nil then
						return value and true or false
					end
					return fallback
				end
				
				
	-- ====================================
	-- main features/toggles
	-- ====================================
					
					-- laser strobes (all)
				new_settings.feature_enabled_laser_strobe				= apply_bool_with_fallback(old.enabled_mod_master and old.enabled_laser_strobes_master,new_settings.feature_enabled_laser_strobe)
					
					-- flashlight strobes (all)
				new_settings.feature_enabled_flash_strobe				= apply_bool_with_fallback(old.enabled_mod_master and old.enabled_flashlight_strobes_master,new_settings.feature_enabled_flash_strobe)
					
					-- peer laser/flashlight syncing
				new_settings.feature_enabled_gadget_network_sync		= apply_bool_with_fallback(old.enabled_mod_master and old.enabled_networking,new_settings.feature_enabled_gadget_network_sync)
				
					-- peer laser filtering ("No Red [Player] Lasers" integration)
				new_settings.feature_enabled_laser_redfilter			= apply_bool_with_fallback(old.enabled_mod_master and old.enabled_redfilter,new_settings.feature_enabled_laser_redfilter)
				
					-- general blackmarket qol changes 
				if old.enabled_blackmarket_qol then
					-- "Change Default Sight Reticule and Gadget Color" integration
					new_settings.feature_enabled_qol_defaultgadget = true
					
					-- written like this instead of apply_bool_with_fallback
					-- because the enabled_blackmarket_qol flag is supposed to be a category that encompasses multiple tweaks
				end
				
				new_settings.qol_defaultgadget_sight_color				= apply_bool_with_fallback(old.enabled_mod_master and old.sight_color,new_settings.blackmarket_qol_defaultgadget_sight_color)
				new_settings.qol_defaultgadget_sight_type				= apply_bool_with_fallback(old.enabled_mod_master and old.sight_type,new_settings.blackmarket_qol_defaultgadget_sight_type)
				
				if old.enabled_mod_master then 
					if old.enabled_multigadget then
						new_settings.feature_state_gadget_multigadget	= 2
					elseif old.enabled_gadget_overload then
						new_settings.feature_state_gadget_multigadget	= 3
					end
				else
					new_settings.feature_state_gadget_multigadget		= 1
				end
				
	-- ====================================
	-- individual laser/flashlight settings
	-- ====================================
				
				
				-- ------------------------------------------
					-- local player
				-- ------------------------------------------
				if old.own_laser_display_mode then
					local value = old.own_laser_display_mode
					
					if value == 1 then
						-- hidden
						new_settings.user_laser_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.user_laser_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.user_laser_display_mode = value
					elseif value == 4 then
						new_settings.user_laser_display_mode = 3 -- use "custom", enable strobe
					end
				end
				new_settings.user_laser_strobe_enabled					= apply_bool_with_fallback(old.enabled_laser_strobes_master and old.own_laser_strobe_enabled,new_settings.user_laser_strobe_enabled)
				new_settings.user_laser_color							= apply_color_with_fallback(old.own_laser_red,old.own_laser_green,old.own_laser_blue, new_settings.user_laser_color)
				new_settings.user_laser_alpha							= apply_float_with_fallback(old.own_laser_alpha, new_settings.user_laser_alpha)
				
				
				if old.own_flashlight_display_mode then
					local value = old.own_flashlight_display_mode
					if value == 1 then
						-- hidden
						new_settings.user_flash_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.user_flash_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.user_flash_display_mode = value
					elseif value == 4 then
						new_settings.user_flash_display_mode = 3 -- use "custom", enable strobe
					end
				end
				new_settings.user_flash_strobe_enabled					= apply_bool_with_fallback(old.own_flashlight_strobe_enabled,new_settings.user_flash_strobe_enabled)
				new_settings.user_flash_color							= apply_color_with_fallback(old.own_flash_red,old.own_flash_green,old.own_flash_blue, new_settings.user_flash_color)
				new_settings.user_flash_alpha							= apply_float_with_fallback(old.own_flash_alpha, new_settings.user_flash_alpha)
				
				-- ------------------------------------------
					-- teammates (peers or ai crew members if you have a bot equipment mod that lets them use gadgets)
				-- ------------------------------------------
				if old.team_laser_display_mode then
					local value = old.team_laser_display_mode
					if value == 1 then
						-- hidden
						new_settings.team_laser_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.team_laser_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.team_laser_display_mode = value
					elseif value == 4 then
						-- peer color
						new_settings.team_laser_display_mode = value
					end
				end
				
				new_settings.team_laser_strobe_enabled					= apply_bool_with_fallback(old.team_laser_strobe_enabled,new_settings.team_laser_strobe_enabled)
				new_settings.team_laser_color							= apply_color_with_fallback(old.team_laser_red,old.team_laser_green,old.team_laser_blue, new_settings.team_laser_color)
				new_settings.team_laser_alpha							= apply_float_with_fallback(old.team_laser_alpha, new_settings.team_laser_alpha)
				
				if old.team_flashlight_display_mode then
					local value = old.team_flashlight_display_mode
					if value == 1 then
						-- hidden
						new_settings.team_flash_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.team_flash_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.team_flash_display_mode = value
					end
				end
				new_settings.team_flash_strobe_enabled					= apply_bool_with_fallback(old.team_flashlight_strobe_enabled,new_settings.team_flash_strobe_enabled)
				new_settings.team_flash_color							= apply_color_with_fallback(old.team_flash_red,old.team_flash_green,old.team_flash_blue, new_settings.team_flash_color)
				new_settings.team_flash_alpha							= apply_float_with_fallback(old.team_flash_alpha, new_settings.team_flash_alpha)
				
				
				-- ------------------------------------------
					-- enemy lasers/flashlights (eg snipers, guards)
				-- ------------------------------------------
				if old.sniper_display_mode then
					local value = old.sniper_display_mode
					if value == 1 then
						-- hidden
						new_settings.enemy_laser_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.enemy_laser_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.enemy_laser_display_mode = value
					end
				end
				new_settings.enemy_laser_strobe_enabled					= apply_bool_with_fallback(old.sniper_strobe_enabled,new_settings.enemy_laser_strobe_enabled)
				new_settings.enemy_laser_color							= apply_color_with_fallback(old.snpr_red,old.snpr_green,old.snpr_blue, new_settings.enemy_laser_color)
				new_settings.enemy_laser_alpha							= apply_float_with_fallback(old.snpr_alpha, new_settings.enemy_laser_alpha)
				
				if old.cop_flashlight_display_mode then
					local value = old.cop_flashlight_display_mode
					if value == 1 then
						-- hidden
						new_settings.enemy_flash_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.enemy_flash_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.enemy_flash_display_mode = value
					end
				end
				new_settings.enemy_flash_strobe_enabled					= apply_bool_with_fallback(old.npc_flashlight_strobe_enabled,new_settings.enemy_flash_strobe_enabled)
				new_settings.enemy_flash_color							= apply_color_with_fallback(old.npc_flash_red,old.npc_flash_green,old.npc_flash_blue, new_settings.enemy_flash_color)
				new_settings.enemy_flash_alpha							= apply_float_with_fallback(old.npc_flash_alpha, new_settings.enemy_flash_alpha)
				
				
				-- ------------------------------------------
					-- enemy turret lasers
				-- ------------------------------------------
				if old.turret_display_mode then
					local value = old.turret_display_mode
					if value == 1 then
						-- hidden
						new_settings.turretatt_laser_mode = value
						new_settings.turretrld_laser_mode = value
						new_settings.turretmad_laser_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.turretatt_laser_mode = value
						new_settings.turretrld_laser_mode = value
						new_settings.turretmad_laser_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.turretatt_laser_mode = value
						new_settings.turretrld_laser_mode = value
						new_settings.turretmad_laser_mode = value
					end
				end
				
				new_settings.turretatt_laser_strobe_enabled				= apply_bool_with_fallback(old.turret_strobe_enabled,new_settings.turretatt_laser_strobe_enabled)
				new_settings.turretrld_laser_strobe_enabled				= apply_bool_with_fallback(old.turret_strobe_enabled,new_settings.turretrld_laser_strobe_enabled)
				new_settings.turretmad_laser_strobe_enabled				= apply_bool_with_fallback(old.turret_strobe_enabled,new_settings.turretmad_laser_strobe_enabled)
				
				new_settings.turretatt_laser_alpha						= apply_float_with_fallback(old.turr_att_alpha, new_settings.turretatt_laser_alpha)
				new_settings.turretrld_laser_alpha						= apply_float_with_fallback(old.turr_rld_alpha, new_settings.turretrld_laser_alpha)
				new_settings.turretmad_laser_alpha						= apply_float_with_fallback(old.turr_mad_alpha, new_settings.turretmad_laser_alpha)
				
				
				-- ------------------------------------------
					-- world lasers (eg vault lasers)
				-- ------------------------------------------
				if old.world_display_mode then
					local value = old.world_display_mode
					if value == 1 then
						-- hidden
						new_settings.world_laser_display_mode = value
					elseif value == 2 then
						-- vanilla
						new_settings.world_laser_display_mode = value
					elseif value == 3 then
						-- custom (use lasersplus settings)
						new_settings.world_laser_display_mode = value
					end
				end
				new_settings.world_laser_strobe_enabled					= apply_bool_with_fallback(old.world_strobe_enabled,new_settings.world_laser_strobe_enabled)
				new_settings.world_laser_color							= apply_color_with_fallback(old.wl_red,old.wl_green,old.wl_blue, new_settings.world_laser_color)
				new_settings.world_laser_alpha							= apply_float_with_fallback(old.wl_alpha, new_settings.world_laser_alpha)
			end
			
			return new_settings
		else
			log("ERROR: Unknown LasersPlus version",self.LASERSPLUS_SAVEFILE_VERSION)
			return table.deep_map_copy(self.default_settings)
		end
		
	end
end


-- ===================================== Networking ==========================================

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_lasersplus", function(sender, message, body)
	local EVENT_IDS = LasersPlus.NETWORK_EVENT_IDS
	
	if message == EVENT_IDS.LASERSPLUS_SYNC_GADGET_ALL then
	
		local peer = managers.network:session():peer(sender)
		if peer then 
			LasersPlus:Print("Received data from peer",sender,":",body)
			LasersPlus:StoreTeamColor(peer,body,"combined",nil)
		end
		
	--[[
	elseif message == EVENT_IDS.LASERSPLUS_SYNC_GADGET_LASER then
		
		local peer = managers.network:session():peer(sender)
		if peer then 
			LasersPlus:StoreTeamColor(peer,body,"laser",nil)
		end
		
	elseif message == EVENT_IDS.LASERSPLUS_SYNC_GADGET_FLASH then
		
		local peer = managers.network:session():peer(sender)
		if peer then 
			LasersPlus:StoreTeamColor(peer,body,"flashlight",nil)
		end
		--]]
	end
	
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

function LasersPlus:serialize_laser_template(data)
	local color_str = self.color_to_hex(data.color)
	local alpha = data.alpha
	local radius = data.radius
	local strobe_enabled = data.strobe_enabled and 1 or 0
	local strobe_str = self:StrobeToString(data.strobe_data)
	return string.format("%s,%f,%f,%i,$%s",color_str,alpha,radius,strobe_enabled,strobe_str)
end

function LasersPlus:deserialize_laser_template(str)
	if type(str) == "string" then
		local a,b = string.find(str,"$")
		if a then 
			local ss_1 = string.sub(str,1,a-1) -- substring 1 (main params)
			local ss_2 = string.sub(str,b+1,-1) -- substring 2 (strobe string)
			
			local params = string.split(ss_1,",")
			local color_str = params[1]
			local alpha = params[2] and tonumber(params[2])
			local radius = params[3] and tonumber(params[3])
			local strobe_enabled = params[4] == "1"
			local strobe_str = ss_2
			
			if alpha and radius then
				return {
					color = color_str,
					alpha = alpha,
					radius = radius,
					strobe_enabled = strobe_enabled,
					strobe_str = strobe_str
				}
			end
		end
	end
end

function LasersPlus:serialize_flash_template(data)
	local color_str = self.color_to_hex(data.color)
	local alpha = data.alpha
	local range = data.range
	local angle = data.angle
	local strobe_enabled = data.strobe_enabled and 1 or 0
	local strobe_str = self:StrobeToString(data.strobe_data)
	return string.format("%s,%f,%i,%i,%i,$%s",color_str,alpha,range,angle,strobe_enabled,strobe_str)
end

function LasersPlus:deserialize_flash_template(str)
	if type(str) == "string" then
		local a,b = string.find(str,"$")
		if a then 
			local ss_1 = string.sub(str,1,a-1) -- substring 1 (main params)
			local ss_2 = string.sub(str,b+1,-1) -- substring 2 (strobe string)
			
			local params = string.split(ss_1,",")
			local color_str = params[1]
			local alpha = params[2] and tonumber(params[2])
			local range = params[3] and tonumber(params[3])
			local angle = params[4] and tonumber(params[4])
			local strobe_enabled = params[5] == "1"
			local strobe_str = ss_2
			
			if alpha and range and angle then
				return {
					color = color_str,
					alpha = alpha,
					range = range,
					angle = angle,
					strobe_enabled = strobe_enabled,
					strobe_str = strobe_str
				}
			end
		end
	end
end

function LasersPlus:SyncTemplatesToPeers()
	local laser_body,flash_body
	
	if self._cached_template_string_laser then
		laser_body = self._cached_template_string_laser
	else
		local template_data = self:GetGadgetTemplate("laser","user")
		if template_data and template_data.mode ~= 1 then
			laser_body = self:serialize_laser_template(template_data)
		else
			laser_body = "0"
		end
		self._cached_template_string_laser = laser_body
	end
	
	if self._cached_template_string_flash then
		flash_body = self._cached_template_string_flash
	else
		local template_data = self:GetGadgetTemplate("flashlight","user")
		if template_data and template_data.mode ~= 1 then
			flash_body = self:serialize_flash_template(template_data)
		else
			flash_body = "0"
		end
		self._cached_template_string_flash = flash_body
	end
	
	if managers.network and managers.network:session() then
		local body = laser_body .. "&" .. flash_body
		
		LuaNetworking:SendToPeers(self.NETWORK_EVENT_IDS.LASERSPLUS_SYNC_GADGET_ALL,body)
	end
	--LuaNetworking:SendToPeers(self.NETWORK_EVENT_IDS.LASERSPLUS_SYNC_GADGET_LASER,laser_body)
	--LuaNetworking:SendToPeers(self.NETWORK_EVENT_IDS.LASERSPLUS_SYNC_GADGET_FLASH,flash_body)
end

function LasersPlus:GetSyncedDataByPeerId(peer_id)
	local peer = peer_id and managers.network:session():peer(peer_id)
	if peer then
		local uid = peer:user_id()
		local stored_colors = uid and LasersPlus._gadget_colors_by_user[uid]
		if stored_colors then
			return stored_colors
		end
	end
end

-- store synced LP color from LP modded teammate 
function LasersPlus:StoreTeamColor(peer,data,type_id,unit)
	local uid = peer:user_id()
	local stored_colors = LasersPlus._gadget_colors_by_user[uid]
	if not stored_colors then 
		stored_colors = {
			gadget = {}, -- manual lookup to actual gadget unit [by address from unit key]
			sync_string = nil, -- str; compared on receive from other players to prevent redundant parsing; NOTE: stored whether valid or not
			laser_color = nil, -- str
			laser_strobe = nil, -- str
			laser_alpha = nil, -- float [0-1]
			flash_color = nil, -- str
			flash_strobe = nil, -- str
			flash_alpha = nil -- float [0-1]
		}
		LasersPlus._gadget_colors_by_user[uid] = stored_colors
	end
	
	if type_id == "vanilla" then
		local gadget_base = unit and alive(unit) and unit:base()
		if gadget_base then
			local ukey = string.match(tostring(gadget_base),"0x%x+")
			stored_colors.gadget[ukey] = {
				color = string.format("%02x%02x%02x",data.r,data.g,data.b),
				alpha = math.max(data.r,data.g,data.b)/255 -- this probably shouldn't be used
			}
		end
	elseif type_id == "combined" then
		if stored_colors.sync_string ~= data then
			stored_colors.sync_string = data
			local a,b = string.find(data,"@")
			if a then
				
				local laser_ss = string.sub(data,1,a-1)
				if laser_ss and laser_ss ~= "0" and laser_ss ~= "" then
					local template_data = LasersPlus:deserialize_laser_template(laser_ss)
					if template_data and type(template_data) == "table" then
						stored_colors.laser_template = template_data
					end
				else
					stored_colors.laser_template = nil
				end
				
				local flash_ss = string.sub(data,b+1,-1)
				if flash_ss and flash_ss ~= "0" and flash_ss ~= "" then
					local template_data = LasersPlus:deserialize_flash_template(flash_ss)
					if template_data and type(template_data) == "table" then
						stored_colors.flash_template = template_data
					end
				else
					stored_colors.flash_template = nil
				end
				
			end
		end
	--[[
	elseif type_id == "laser" then -- lasersplus synced color
		
		if stored_colors.sync_string ~= data then
			local template_data = LasersPlus:deserialize_laser_template(data)
			if template_data and type(template_data) == "table" then
				stored_colors.laser_template = template_data
			end
			stored_colors.sync_string = data
		end
		
	elseif type_id == "flashlight" then -- lasersplus synced flashlight
		if stored_colors.sync_string ~= data then
			local template_data = LasersPlus:deserialize_flash_template(data)
			if template_data and type(template_data) == "table" then
				stored_colors.flash_template = template_data
			end
			stored_colors.sync_string = data
		end
		--stored_colors.flash_color = string.format("%02x%02x%02x",data.r or 1,data.g or 1,data.b or 1)
		--stored_colors.flash_color = data.color
		--stored_colors.flash_alpha = data.alpha
		--stored_colors.flash_strobe = data.strobe
--]]
	end
end

-- get lobby player color (eg. host is green, player 2 is blue, player 3 is red, player 4 is orange)
function LasersPlus:GetPeerColor(peer_id)
	local hex_code = self.config.PeerColors[peer_id]
	if hex_code then
		return self.deserialize_color(hex_code)
	else
		return tweak_data.chat_colors[peer_id]
	end
end

function LasersPlus:SetPeerColor(peer_id,color)
	if not color then return end
	self.config.PeerColors[peer_id] = self.serialize_color(color)
end

-- ===================================== Menu ==========================================



function LasersPlus:GetColorpickerPalettes()
	local result = {}
	for i,str in ipairs(self.config.Palettes) do 
		result[i] = self.parse_serialized_color(str)
	end
	return result
end

function LasersPlus:SetColorpickerPalettes(palettes)
	if type(palettes) == "table" then 
		for i,color in ipairs(palettes) do 
			self.config.Palettes[i] = self.serialize_color(color)
		end
	end
end

function LasersPlus:GetDefaultColorpickerPalettes()
	local result = {}
	for i,str in ipairs(self.default_config.Palettes) do 
		result[i] = self.deserialize_color(str)
	end
	return result
end


function LasersPlus:GetSettingPrefix(gadget_type,user_type)
	if gadget_type == "laser" then
		return user_type .. "_laser_"
	elseif gadget_type == "flashlight" then
		return user_type .. "_flash_"
	end
	
	return nil
end

function LasersPlus:ChangeSetting(key,value)
	if key and self.settings[key] ~= nil and value ~= nil then
		self.settings[key] = value
	end
end

-- There's gotta be a better way to do this /j
-- NOTE: SHOULD NOT BE CALLED FROM PEERS!
-- should only be called from the local user changing menu settings for any given user_type
function LasersPlus:OnTemplateChanged(gadget_type,user_type,new_data)
	if not new_data then return end
	
	local template_data = self:GetGadgetTemplate(gadget_type,user_type)
	
	local setting_prefix = self:GetSettingPrefix(gadget_type,user_type)
	local done_any
	
	-- these five are used for both laser and flashlight
	if new_data.color and template_data.color ~= new_data.color then
		self:ChangeSetting(setting_prefix .. "color",self.color_to_hex(new_data.color))
		template_data.color = new_data.color
		done_any = true
	end
	if new_data.alpha and template_data.alpha ~= new_data.alpha then
		self:ChangeSetting(setting_prefix .. "alpha",tonumber(new_data.alpha))
		template_data.alpha = new_data.alpha
		done_any = true
	end
	if new_data.mode and template_data.mode ~= new_data.mode then
		self:ChangeSetting(setting_prefix .. "display_mode",tonumber(new_data.mode))
		template_data.mode = new_data.mode
		done_any = true
	end
	if new_data.strobe_enabled ~= nil and template_data.strobe_enabled ~= new_data.strobe_enabled then
		self:ChangeSetting(setting_prefix .. "strobe_enabled",new_data.strobe_enabled and true or false)
		template_data.strobe_enabled = new_data.strobe_enabled
		done_any = true
	end
	if new_data.strobe_data and new_data.strobe_data.str ~= new_data.strobe_data.str then
		local strobe_data = self:StringToStrobe(new_data.strobe_data.str)
		template_data.strobe_data = strobe_data
		self:ChangeSetting(setting_prefix .. "strobe_string",new_data.strobe_data.str)
		done_any = true
	end
	
	if gadget_type == "laser" then
		if new_data.radius and template_data.radius ~= new_data.radius then
			template_data.radius = new_data.radius
			self:ChangeSetting(setting_prefix .. "radius",tonumber(new_data.radius))
			done_any = true
		end
	elseif gadget_type == "flashlight" then
		if new_data.range and template_data.range ~= new_data.range then
			template_data.range = new_data.range
			self:ChangeSetting(setting_prefix .. "range",tonumber(new_data.range))
			done_any = true
		end
		if new_data.angle and template_data.angle ~= new_data.angle then
			template_data.angle = new_data.angle
			self:ChangeSetting(setting_prefix .. "angle",tonumber(new_data.angle))
			done_any = true
		end
	end
	
	if done_any then
		local hook_id = "OnLasersPlusSettingChanged_" .. user_type .. "_" .. gadget_type
		Hooks:Call(hook_id,template_data,user_type)
		if self:IsGadgetNetworkSyncEnabled() then
			if user_type == "user" then
				if gadget_type == "laser" then
					LasersPlus._cached_template_string_laser = nil
				elseif gadget_type == "flashlight" then
					LasersPlus._cached_template_string_flash = nil
				end
				LasersPlus:SyncTemplatesToPeers()
			end
		end
	end
	
end

-- not used
function LasersPlus:RefreshPreviews(gadget_type,user_type,new_data)
	
end


function LasersPlus:CreateColorpicker()
	if _G.ColorPicker then 
		self._colorpicker = self._colorpicker or _G.ColorPicker:new("lasersplus",{},nil)
	end
end

function LasersPlus:ShowColorpicker(gadget_type,user_type)
	if ColorPicker and self._colorpicker then 
		local template_data = self:GetGadgetTemplate(gadget_type,user_type)
		
		self._colorpicker:Show({
			color = template_data.color,
			palettes = self:GetColorpickerPalettes(),
			default_palettes = self:GetDefaultColorpickerPalettes(),
			done_callback = function(new_color,palettes,success)
				self:SetColorpickerPalettes(palettes)
				if success then 
					self:OnTemplateChanged(gadget_type,user_type,{
						color = new_color
					})
					self:SaveSettings()
				end 
			end,
			changed_callback = function(new_color) 
				-- update preview
				self:RefreshPreviews(gadget_type,user_type,{color=new_color})
			end
		})
	end
end