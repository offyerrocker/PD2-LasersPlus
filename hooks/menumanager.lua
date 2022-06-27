--[[
	todo:
	-convert old save data
	-strobes
		-can be used for flashlights or lasers
		-dynamically populate
	- general settings
		- master enable
		-flashlight and laser syncing
	-settings/menus
		QOL settings
			red laser filter
			sight gadget keybind
				- disable normal cycle to gadgets
				- toggle keybind
			default sight reticle/color
				-dynamically populate 
			
		laser customization
			-vr laser
			-glow/thickness options
		flashlight customization
			-flashlight range/angle
--]]


LasersPlus = LasersPlus or {}
LasersPlus._core = LasersPlus._core or LasersPlusCore
if LasersPlus._core then 
	LasersPlus._path = LasersPlus._core:GetPath()
else
	LasersPlus._path = ModPath
end
LasersPlus._data_path = SavePath .. "lasersplus_save.txt"
LasersPlus._menu_path = LasersPlus._path .. "menu/"
LasersPlus._legacy_save_path = SavePath .. "lasersplus.txt"
LasersPlus._default_localization_filepath = LasersPlus._path .. "localization/en.json"
LasersPlus.has_shown_legacy_save_check = false

LasersPlus.hook_id_prefix = "lasersplus_listener_"
LasersPlus.hook_ids = {
	laser = {
		own = "lasersplus_laser_own_",
		team = "lasersplus_laser_team_",
		cop = "lasersplus_laser_cop_",
		world = "lasersplus_laser_world_",
		swatturret = "lasersplus_laser_swatturret_",
		sentrygun = "lasersplus_laser_sentrygun_"
	},
	flashlight = {
		own = "lasersplus_flashlight_own_",
		team = "lasersplus_flashlight_team_",
		cop = "lasersplus_flashlight_cop_"
	}
}

LasersPlus.preview_square_size = 24
LasersPlus.preview_square_placement = {
	laser = {
		own = {
			setting_name = "own_laser_color_string",
			x = 750,
			y = 69
		},
		team = {
			setting_name = "team_laser_color_string",
			x = 750,
			y = 70
		},
		peer1 = {
			setting_name = "peer1_laser_color_string",
			x = 750,
			y = 64
		},
		peer2 = {
			setting_name = "peer2_laser_color_string",
			x = 750,
			y = 96
		},
		peer3 = {
			setting_name = "peer3_laser_color_string",
			x = 750,
			y = 128
		},
		peer4 = {
			setting_name = "peer4_laser_color_string",
			x = 750,
			y = 156
		},
		cop = {
			setting_name = "cop_laser_color_string",
			x = 750,
			y = 69
		},
		world = {
			setting_name = "world_laser_color_string",
			x = 750,
			y = 69
		},
		swatturret_att = {
			setting_name = "swatturret_att_laser_color_string",
			x = 750,
			y = 95-26
		},
		swatturret_rld = {
			setting_name = "swatturret_rld_laser_color_string",
			x = 750,
			y = 95
		},
		swatturret_mad = {
			setting_name = "swatturret_mad_laser_color_string",
			x = 750,
			y = 95+26
		},
		sentrygun_auto = {
			setting_name = "sentrygun_auto_laser_color_string",
			x = 750,
			y = 95-26
		},
		sentrygun_ap = {
			setting_name = "sentrygun_ap_laser_color_string",
			x = 750,
			y = 95
		},
		sentrygun_off = {
			setting_name = "sentrygun_off_laser_color_string",
			x = 750,
			y = 95+26
		}
	},
	reticle = {
		--setting name is not needed
		x = 700,
		y = 32,
		size = 64
	}
}

LasersPlus._menu_preview_objects = {
	colors = {},
	reticles = {}
}

LasersPlus.strobe_interpolation = {
	LINEAR = 1,
	QUAD = 2,
	CUBIC = 3,
	SINE = 4
}
LasersPlus.default_strobes = {
	rainbow = {
		name_id = "lasersplus_strobe_rainbow",
		duration = 10,
		manual = false,
		interpolation = "linear",
		colors = {
			"ff0000", --red
			"ff4400", --yellow (really more orange but the yellow shows up easily in interpolation due to the blend mode)
			"00ff00", --green
			"00ffff", --cyan
			"0000ff", --blue
			"8000ff" --purple
		}
	},
	cmy = {
		name_id = "lasersplus_strobe_cmy",
		duration = 2,
		manual = false,
		interpolation = "linear",
		colors = {
			"ffff00",
			"00ffff",
			"ff00ff"
		}
	},
	siren = {
		name_id = "lasersplus_strobe_siren",
		duration = 2,
		manual = false,
		interpolation = "cubic",
		colors = {
			"ff0000",
			"ffffff",
			"0000ff",
			"ffffff",
		}
	},
	hazy_flame = {
		name_id = "lasersplus_strobe_hazy_flame",
		duration = 1,
		manual = false,
		interpolation = "quad",
		colors = {
			"ff0000",
			"fb401a"
		}
	}
}
Hooks:Register("LasersPlus_LoadCustomStrobes")
Hooks:Add("LasersPlus_LoadCustomStrobes","LasersPlus_LoadRainbowStrobeExample",function(strobes_table,processed_strobes_table)
	local strobe_name = "cmy"
	local duration = 5
	local quality = 60
	local total_frames = duration * quality
	local colors = {}
	local p1 = 0
	local p2 = math.deg(math.pi * 2/3)
	local p3 = math.deg(math.pi * 4/3)
	local p4 = 2 --math.deg(math.pi)
	for i=1,total_frames do 
		local prog = 1 - (i / total_frames) * p4
		
		
		local r = math.sin(135 * prog + 0) / 2 + 0.5
        local g = math.sin(140 * prog + 60) / 2 + 0.5
        local b = math.sin(145 * prog + 120) / 2 + 0.5
		
		colors[i] = Color(r,g,b)
	end
	
	processed_strobes_table[strobe_name] = colors
end)
LasersPlus.strobe_ids = {} --used for multiplechoice menu generation
LasersPlus.strobes = {}
LasersPlus.processed_strobes = {} --generated from strobes post-load

LasersPlus.registered_gadgets = {
	laser = {},
	flashlight = {}
}
LasersPlus.strobe_default_max_colors = 15
LasersPlus.strobe_separator_char = "/"
LasersPlus.default_palettes = {
	"de901f",
	"cdde1f",
	"6dde1f",
	"de301f",
	"de1f6d",
	"1f7ade",
	"241fde",
	"831fde",
	"1fdade",
	"1fde83",
	"de1fa3",
	"de1f43",
	"de5a1f",
	"ba1fde",
	"5a1fde",
	"1fde22",
	"1fde82",
	"1fdbde",
	"7cde1f",
	"dbde1f",
	"1fdede",
	"1f7fde",
	"1f1fde",
	"1fde7f",
	"1fde1f"
}

LasersPlus.default_settings = {
	generic_laser_color_string = "00ff00", --green
	generic_laser_alpha_value = 0.7,
	generic_flashlight_color_string = "f0f2d7", --yellow tint
	generic_flashlight_alpha_value = 0.9,
	
	own_laser_color_string = "ff9200", --global override for all own weapons
	own_laser_color_mode = 4,
		--1: vanilla
		--2: static (own_laser_color_string)
		--3: peer
		--4: strobe
		--5: invisible
	own_laser_alpha_value = 0.8,
	own_laser_alpha_mode = 1, -- 1 = vanilla, 2 = custom
	
	own_laser_thickness_mode = 1, --1 = vanilla, 2 = custom
	own_laser_thickness_value = 0.5,
	
	own_laser_strobe_id = "rainbow",
	
	own_flashlight_color_string = "dfe8f4", -- blue tint
	own_flashlight_alpha_value = 0.9,
	own_flashlight_alpha_mode = 1,
	own_flashlight_strobe_id = "rainbow",
	
	team_laser_color_string = "0044ff",
	team_laser_color_mode = 1,
		--1: vanilla
		--2: static (team_laser_color_string)
		--3: peer
		--4: strobe
		--5: invisible
	team_laser_strobe_id = "rainbow",
	team_laser_thickness_mode = 1,
	team_laser_thickness_value = 0.25,
	
	team_laser_alpha_mode = 1,
	team_laser_alpha_value = 0.7,
	
	--peer colors use teammate alpha values
	peer1_laser_color_string = "c2fc97",
	peer1_flashlight_color_string = "cbe6b8", --same as laser color but with brightness=.9,sat=.2 
	
	peer2_laser_color_string = "78b7cc",
	peer2_flashlight_color_string = "b8dae6",
	
	peer3_laser_color_string = "b26859",
	peer3_flashlight_color_string = "e6bfb8",
	
	peer4_laser_color_string = "cca166",
	peer4_flashlight_color_string = "e6d2b8",
	
--	ai_laser_color_string = "00ffff", --cyan
--	ai_flashlight_color_string = "b8dde6",
	
	
	--says "cop" but really it's for snipers specifically
	cop_laser_color_mode = 3,
		--1: vanilla
		--2: static (cop_laser_color_string)
		--3: strobe
		--4: invisible
	cop_laser_color_string = "fb401a", -- red-orange
	cop_laser_strobe_id = "hazy_flame",
	cop_laser_alpha_mode = 1,
		--1: vanilla
		--2: custom
	cop_laser_alpha_value = 0.9,
--	cop_flashlight_color_string = "e6bfb8", --baked into the asset iirc, can't be changed through lua
--	cop_flashlight_color_mode = 1,
	cop_laser_thickness_mode = 1,
	cop_laser_thickness_value = 0.25,
	
	
	world_laser_color_mode = 1,
		--1: vanilla
		--2: static (world_laser_color_string)
		--3: strobe
		--4: invisible (oh god why)
	world_laser_color_string = "ffd600",
	world_laser_strobe_id = "rainbow",
	world_laser_alpha_mode = 1,
		--1: vanilla
		--2: custom
	world_laser_alpha_value = 0.9,
	world_laser_thickness_mode = 1,
	world_laser_thickness_value = 0.25,
	
	
	
	
	
	swatturret_laser_color_mode = 1,
		--1: vanilla
		--2: static (solid color, dependent on turret mode)
		--3: strobe
		--4: invisible
	swatturret_att_laser_color_string = "ff0000", --attack swat turret color (red)
	swatturret_att_laser_strobe_id = "rainbow",
	swatturret_mad_laser_color_string = "00ffff", --ecm swat turret color (cyan)
	swatturret_mad_laser_strobe_id = "rainbow",
	swatturret_rld_laser_color_string = "ffff00", --reload swat turret color (yellow)
	swatturret_rld_laser_strobe_id = "rainbow",
	swatturret_laser_alpha_mode = 1,
		--1: vanilla
		--2: custom
	swatturret_laser_alpha_value = 0.8,
	
	swatturret_laser_thickness_mode = 1,
	swatturret_laser_thickness_value = 0.25,
	
	sentrygun_laser_color_mode = 1,
		--1: vanilla
		--2: static (solid color, dependent on sentrygun normal/ap ammo)
		--3: peer (uses the peer color of player who owns it)
		--4: strobe
		--5: invisible
	sentrygun_auto_laser_color_string = "197fff", --player sentrygun autofire color (cyan)
	sentrygun_auto_laser_strobe_id = "rainbow",
	sentrygun_ap_laser_color_string = "19ff19", --player sentrygun ap color (green)
	sentrygun_ap_laser_strobe_id = "rainbow",
	sentrygun_off_laser_color_string = "ff1919",
	sentrygun_off_laser_strobe_id = "rainbow",
	sentrygun_laser_alpha_mode = 1,
	sentrygun_laser_alpha_value = 0.8,
	
	sentrygun_laser_thickness_mode = 1,
	sentrygun_laser_thickness_value = 0.25,
	
	
	networking_enabled = true,
	
	redfilter_ratio = 0.66,
	redfilter_enabled = true,
	
	sight_override_enabled = true,
	sight_color_index = 2,
	sight_texture_index = 1,
	
	multigadget_switch_enabled = true,
	multigadget_nosightcycle_enabled = true, --if true, sight gadgets are excluded from the normal sight rotation
	
	
	palettes = table.deep_map_copy(LasersPlus.default_palettes)
}
LasersPlus.settings = LasersPlus.settings or table.deep_map_copy(LasersPlus.default_settings)


-- ***** Utils *****

--simplified table.concat(), except it also tostrings each argument and preserves nil arguments
function LasersPlus.table_concat(tbl,div)
	div = tostring(div or ",")
	if type(tbl) ~= "table" then 
		return "(concat error: non-table value)"
	end
	local str
	for k,v in pairs(tbl) do
		str = str and (str .. div .. tostring(v)) or tostring(v)
	end
	return str or ""
end

function LasersPlus:log(...)
	if _G.Log then
		return _G.Log(...)
	else
		return log(...)
	end
end

-- ***** Settings *****

function LasersPlus:IsQOLSightSwitchEnabled()
	return self.settings.sight_override_enabled
end

function LasersPlus:GetSightTextureIndex()
	return self.settings.sight_texture_index
end

function LasersPlus:GetSightColorIndex()
	return self.settings.sight_color_index
end

function LasersPlus:IsQOLRedFilterEnabled()
	return self.settings.redfilter_enabled
end

function LasersPlus:GetRedFilterRatio()
	return self.settings.redfilter_ratio
end

function LasersPlus:IsQOLMultiGadgetSwitchEnabled()
	return self.settings.multigadget_switch_enabled
end

function LasersPlus:IsQOLMultiGadgetSightCycleEnabled()
	return self.settings.multigadget_nosightcycle_enabled
end

--this looks a bit ugly but it's efficient enough
function LasersPlus:GetLaserColor(gadget_data)

	local source = gadget_data.source
	local peer_id = gadget_data.peer_id
	local is_ai = gadget_data.is_ai
	
	local char_id = gadget_data.char_id
	local team_id = gadget_data.team_id
	
	local color = Color(LasersPlus.default_settings.generic_laser_color_string)
	local alpha = LasersPlus.default_settings.generic_laser_alpha_value
	
	if source == "own" then
		local color_mode = self.settings.own_laser_color_mode
		local alpha_mode = self.settings.own_laser_alpha_mode
		if alpha_mode == 1 then 
			alpha = gadget_data.natural_alpha or alpha
		else
			alpha = self.settings.own_laser_alpha_value or alpha
		end
		
		if color_mode == 1 then --vanilla
			color = gadget_data.natural_color or color
		elseif color_mode == 2 then --custom solid color
			color = self.settings.own_laser_color_string and Color(self.settings.own_laser_color_string) or color
		elseif color_mode == 3 then --color by peer_id
			peer_id = peer_id or managers.network:session():local_peer():id()
			local peercolor = self.settings["peer" .. tostring(peer_id) .. "_laser_color_string"]
			color = peercolor and Color(peercolor) or color
		elseif color_mode == 4 then --strobe
		elseif color_mode == 5 then --invisible
			color = Color(0,0,0):with_alpha(0)
			alpha = 0
		end
		
		
	elseif source == "team" or is_ai then 
		local color_mode = self.settings.team_laser_color_mode
		local alpha_mode = self.settings.team_laser_alpha_mode
		
		if alpha_mode == 1 then 
			alpha = gadget_data.natural_alpha or alpha
		else
			alpha = self.settings.team_laser_alpha_value or alpha
		end
		
		if color_mode == 1 then --vanilla
			color = gadget_data.natural_color or color
		elseif color_mode == 2 then --custom solid color
			color = self.settings.team_laser_color_string and Color(self.settings.team_laser_color_string) or color
		elseif color_mode == 3 then --color by peer_id
			if peer_id then 
				local peercolor = self.settings["peer" .. tostring(peer_id) .. "_laser_color_string"]
				color = peercolor and Color(peercolor) or color
			end
		elseif color_mode == 4 then --strobe
		elseif color_mode == 5 then --invisible
			color = Color(0,0,0):with_alpha(0)
			alpha = 0
		end
		
	elseif source == "cop" then 
		
		local color_mode = self.settings.cop_laser_color_mode
		local alpha_mode = self.settings.cop_laser_alpha_mode
		if alpha_mode == 1 then 
			alpha = gadget_data.natural_alpha or alpha
		else
			alpha = self.settings.cop_laser_alpha_value or alpha
		end
		
		if color_mode == 1 then --vanilla
			color = gadget_data.natural_color or color
		elseif color_mode == 2 then --custom solid color
			color = self.settings.cop_laser_color_string and Color(self.settings.cop_laser_color_string) or color
		elseif color_mode == 3 then --strobe
		elseif color_mode == 4 then --invisible
			color = Color(0,0,0):with_alpha(0)
			alpha = 0
		end
		
		
	elseif source == "world" then 
		
		local color_mode = self.settings.world_laser_color_mode
		local alpha_mode = self.settings.world_laser_alpha_mode
		if alpha_mode == 1 then 
			alpha = gadget_data.natural_alpha or alpha
		else
			alpha = self.settings.world_laser_alpha_value or alpha
		end
		if color_mode == 1 then --vanilla
			color = gadget_data.natural_color or color
		elseif color_mode == 2 then --custom solid color
			color = self.settings.world_laser_color_string and Color(self.settings.world_laser_color_string) or color
		elseif color_mode == 3 then --strobe
		elseif color_mode == 4 then --invisible
			color = Color(0,0,0):with_alpha(0)
			alpha = 0
		end
		
	elseif source == "swatturret" then
		local color_mode = self.settings.swatturret_laser_color_mode
		local alpha_mode = self.settings.swatturret_laser_alpha_mode
		
		local sentry_unit = gadget_data.parent_unit
		local movement_ext = sentry_unit:movement()
		if movement_ext:is_activating() or movement_ext:is_inactivating() then 
			color = self.settings.swatturret_att_laser_color_string and Color(self.settings.swatturret_att_laser_color_string) or color
			--if inactive then blink
		elseif movement_ext:is_inactivated() then 
			color = Color(0,0,0):with_alpha(0)
			alpha = 0
		elseif movement_ext:rearming() then 
			color = self.settings.swatturret_rld_laser_color_string and Color(self.settings.swatturret_rld_laser_color_string) or color
		elseif movement_ext:team().foes[tweak_data.levels:get_default_team_ID("player")] then
			color = self.settings.swatturret_att_laser_color_string and Color(self.settings.swatturret_att_laser_color_string) or color
		else
			--ecm hacked
			color = self.settings.swatturret_mad_laser_color_string and Color(self.settings.swatturret_mad_laser_color_string) or color
		end
		
		if alpha_mode == 2 then 
			alpha = self.settings.swatturret_laser_alpha_value or alpha
		end
		
	elseif source == "sentrygun" then
		local color_mode = self.settings.sentrygun_laser_color_mode
		local alpha_mode = self.settings.sentrygun_laser_alpha_mode
		if alpha_mode == 1 then 
			alpha = gadget_data.natural_alpha or alpha
		else
			alpha = self.settings.sentrygun_laser_alpha_value or alpha
		end
		
		local sentry_unit = gadget_data.parent_unit
		if ap then 
			color = self.settings.sentrygun_ap_laser_color_string and Color(self.settings.sentrygun_ap_laser_color_string) or color
		else
			color = self.settings.sentrygun_auto_laser_color_string and Color(self.settings.sentrygun_auto_laser_color_string) or color
		end
	end
	
	return color,alpha
end

function LasersPlus:GetFlashlightColor(gadget_data)
	
	local source = gadget_data.source
	local peer_id = gadget_data.peer_id
	local is_ai = gadget_data.is_ai
	
	local char_id = gadget_data.char_id
	local team_id = gadget_data.team_id
	
	local color = Color(LasersPlus.default_settings.generic_flashlight_color_string)
	local alpha = LasersPlus.default_settings.generic_flashlight_alpha_value
	
	return color,alpha
end

function LasersPlus:GetGadgetColor(gadget_data)
	local gadget_type = gadget_data.gadget_type
	if gadget_type == "laser" then
		return self:GetLaserColor(gadget_data)
	elseif gadget_type == "flashlight" then 
		return self:GetFlashlightColor(gadget_data)
	else
		self:log("Error: GetGadgetColor(): Unknown gadget_type [" .. tostring(gadget_type) .. "]")
		return Color(LasersPlus.default_settings.generic_laser_color_string),LasersPlus.default_settings.generic_laser_alpha_value,true
	end
end

--returns string or nil
function LasersPlus:GetGadgetStrobe(gadget_data)	
	local source = gadget_data.source
	
	if gadget_data.gadget_type == "laser" then 
		if source == "own" then
			local color_mode = self.settings.own_laser_color_mode
			if color_mode == 4 then 
				return self.settings.own_laser_strobe_id
			end
		elseif source == "team" or is_ai then 
			local color_mode = self.settings.team_laser_color_mode
			if color_mode == 4 then 
				return self.settings.team_laser_strobe_id
			end
		elseif source == "cop" then 
			
			local color_mode = self.settings.cop_laser_color_mode
			if color_mode == 3 then 
				return self.settings.cop_laser_strobe_id
			end
		elseif source == "world" then 
			
			local color_mode = self.settings.world_laser_color_mode
			if color_mode == 3 then 
				return self.settings.world_laser_strobe_id
			end
		elseif source == "swatturret" then
			local color_mode = self.settings.swatturret_laser_color_mode
			if color_mode == 3 then 
				local sentry_unit
				if mad then 
					return self.settings.swatturret_mad_laser_strobe_id
				elseif att then 
					return self.settings.swatturret_att_laser_strobe_id
				elseif rld then 
					return self.settings.swatturret_rld_laser_strobe_id
				end
			end
		elseif source == "sentrygun" then
			local color_mode = self.settings.sentrygun_laser_color_mode
			if color_mode == 3 then 
				local sentry_unit
				if ap then 
					return self.settings.sentrygun_ap_laser_strobe_id
				else
					return self.settings.sentrygun_auto_laser_strobe_id
				end
			end
		end
	elseif gadget_data.gadget_type == "flashlight" then
		
	end
end

-- ***** Laser/Flashlight Management *****


function LasersPlus:GetUserUnitData(user_unit)
	local source,peer_id,is_ai
	if alive(user_unit) then 
		if user_unit == managers.player:local_player() then 
			--check player
			source = "own"
		else
			local character_data = managers.criminals:character_by_unit(user_unit)
			--check teammate
			if character_data then 
				source = "teammate"
				peer_id = character_data.peer_id
				is_ai = character_data.data.ai and true or false
			else
				--check enemy
				if managers.enemy:is_enemy(user_unit) then 
					source = "cop"
				end 
			end
		end
	else
		self:log("Error: LasersPlus:GetUserUnitData(" .. tostring(user_unit) .. "): Bad user_unit")
	end
	return source,peer_id,is_ai
end

function LasersPlus:SetGadgetParams(gadget_type,unit,params,check_color)
	if not alive(unit) then 
		self:log("Error: LasersPlus:SetGadgetParams(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. "): Bad unit")
		return
	end
	params = params or {}
	local unit_key = unit:key()
	
	if not self.registered_gadgets[gadget_type] then
		self:log("Error: LasersPlus:SetGadgetParams(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. "): Bad gadget_type")
		return
	end
	
	local gadget_data = self.registered_gadgets[gadget_type][unit_key]
	if gadget_data then
		for k,v in pairs(params) do 
			gadget_data[k] = v
		end
		
		if check_color then
			--if color or alpha is manually overwritten, don't re-calculate it (at least, not here)
--			local setting_color,setting_alpha = self:GetGadgetColor(gadget_data)
--			gadget_data.color = setting_color
--			gadget_data.alpha = setting_alpha
			self:CheckGadget(gadget_data)
		end
		
		self:UnregisterGadgetListeners(gadget_data)
		self:RegisterGadgetListeners(gadget_data)
	else
		self:log("Error: LasersPlus:SetGadgetParams(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. "): Bad unit_key")
	end
end

function LasersPlus:RegisterGadget(gadget_type,unit,params)
	--unit can be nil in special cases such as elementlasertrigger (world lasers) where there is no unit involved
	
	if not self.registered_gadgets[gadget_type] then
		self:log("Error: LasersPlus:RegisterGadget(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. ") Unknown gadget_type")
		return
	end

--	if not alive(unit) then 
--		return
--	end
	
	params = params or {}
	local unit_key = params.uid or unit:key()
	local gadget_hook_id = self.hook_id_prefix .. tostring(unit_key)
	
	local update_func = nil
	
	
	local gadget_data = {
		brush = params.brush, --should only be used for world lasers or other lasers not attached to a regular unit or base class extension
		glow = params.glow, --can be used for weapons 
		unit = unit,
		weapon_unit = params.weapon_unit, --if actual weapon gadget, this is the weapon unit that the gadget is attached to
		parent_unit = params.parent_unit, --sentrygun, player user unit, etc.
		gadget_type = gadget_type,
		source = params.source, --player, teammate, cop, world, etc.
		peer_id = params.peer_id, --can be nil
		is_ai = params.is_ai, --if specifically teammate ai
		natural_color = params.natural_color,
--		update_func = update_func,
--		strobe_id = nil, --string
--		strobe_frame = nil, --int
		gadget_hook_id = gadget_hook_id
	}
	gadget_data.strobe_id = self:GetGadgetStrobe(gadget_data)
	local setting_color,setting_alpha = self:GetGadgetColor(gadget_data)
	self.registered_gadgets[gadget_type][unit_key] = gadget_data
	gadget_data.color = setting_color
	gadget_data.alpha = setting_alpha

	local strobe_id = self:GetGadgetStrobe(gadget_data)
	if strobe_id then 
--		register updater
		gadget_data.strobe_table = self.processed_strobes[strobe_id]
	end
	
	
	if gadget_data.brush then 
		gadget_data.set_color_func = function(color,alpha)
			if color then
				if alpha then 
					gadget_data.brush:set_color(color:with_alpha(alpha))
				else
					gadget_data.brush:set_color(color)
				end
			else
				--
			end
			
		end
	elseif alive(unit) then
		gadget_data.set_color_func = function(color,alpha)
			if color then
				if alpha then 
					unit:base():set_color(color:with_alpha(alpha))
				else
					unit:base():set_color(color)
				end
			elseif alpha then
				unit:base():set_color(unit:base():color():with_alpha(alpha))
			else
				
			end
		end
	end
	if gadget_data.set_color_func then 
		gadget_data.set_color_func(setting_color,setting_alpha)
	end
	self:RegisterGadgetListeners(gadget_data)
end

function LasersPlus:UnregisterGadget(gadget_type,unit,unit_key)
	unit_key = unit_key or unit:key()
	if gadget_type and self.registered_gadgets[gadget_type] then
		local gadget_data = self.registered_gadgets[gadget_type][unit_key]
		self:UnregisterGadgetListeners(gadget_data)
		self.registered_gadgets[gadget_type][unit_key] = nil
	end
end

function LasersPlus:GetGadgetData(gadget_type,unit,unit_key)
	if gadget_type and self.registered_gadgets[gadget_type] then
		unit_key = unit_key or unit:key()
		local gadget_data = self.registered_gadgets[gadget_type][unit_key]
		
		return gadget_data
	end
end

function LasersPlus:RegisterGadgetListeners(gadget_data)
	if gadget_data and gadget_data.set_color_func then 
		local hook_id = self.hook_ids[gadget_data.gadget_type][gadget_data.source]
		if hook_id then
			Hooks:Add(hook_id,gadget_data.gadget_hook_id,gadget_data.set_color_func)
		end
	end
end

function LasersPlus:UnregisterGadgetListeners(gadget_data)
	if gadget_data then
		Hooks:Remove(gadget_data.gadget_hook_id)
	end
end

-- ***** Strobes (aka Color Shift) *****
--[[
LasersPlus.processed_strobes.rainbow = LasersPlus:ProcessStrobeTable({
		duration = 4, --4 seconds
		complex = false,
		colors = {
			"ff0000",
--			"ffff00",
			"00ff00",
--			"00ffff",
			"0000ff"
--			"ff00ff"
		}
})
--]]

function LasersPlus:ProcessStrobeTable(tbl)
	local manual = tbl.manual
	if manual then 
		--custom creation
		return
	end
	local colors = tbl.colors
	local num_colors = #colors
	if num_colors < 2 then 
		--must have 2 or more colors, or else what's the point of having it be a strobe
		return
	end
	local interpolation = tbl.interpolation or "linear"
	local duration = tbl.duration 
	local quality = 60 --optimized for 60 fps
	local output = {}
	local pi = 180 --this implementation of math.sin uses degrees instead of radians

	local color_1 = tbl.colors[1]
	local color_2 = tbl.colors[2]
	local total_frames = quality * duration
--		local mod_num_colors = num_colors - 1
	local mini_duration = total_frames / num_colors
	for i=1,total_frames do 
		local prog = i/total_frames
		local color_index_1 = math.ceil(num_colors * prog)
		local color_index_2 = 1 + math.floor((color_index_1 - 0) % num_colors)
--			Log(color_index_1)
--			Log(color_index_2)
		local color_1 = Color(tbl.colors[color_index_1])
		local color_2 = Color(tbl.colors[color_index_2])
--			local color_2 = tbl.colors[1 + (color_index_1 + 1) % mod_num_colors)]
		
		local color_prog = (i - (mini_duration * (color_index_1 - 1))) / mini_duration
		if interpolation == LasersPlus.strobe_interpolation.LINEAR then 
			--all good in the neighborhood
		elseif interpolation == LasersPlus.strobe_interpolation.SINE then 
			color_prog = math.sin(color_prog * pi / 2)
		elseif interpolation == LasersPlus.strobe_interpolation.QUAD then
			color_prog = color_prog * color_prog
		elseif interpolation == LasersPlus.strobe_interpolation.CUBIC then 
			color_prog = color_prog * color_prog * color_prog
		end
		
		local new_color = color_1 + ((color_2 - color_1) * color_prog)
		--((i - (color_index_1 - 1)) / duration)
		table.insert(output,#output + 1,new_color)
	end
	return output
end

--strobe networking not yet implemented
function LasersPlus:StrobeTableToString(data)
	if not data or type(data) ~= "table" or not data.colors then
		self:log("Invalid table data!")
		return
	end 
		
	local duration = data.duration or LasersPlus.strobe_default_max_colors		
	local color_count = data.color_count or 1

	local output = "l" .. duration
	
	for k,v in ipairs(data.colors) do
		output = output .. LasersPlus.strobe_separator_char .. ColorPicker.color_to_hex(v)
	end
	
	return output
end
	
--strobe networking not yet implemented
function LasersPlus:StringToStrobeTable(data)
	local output = {
		colors = {},
		duration = LasersPlus.strobe_default_max_colors,
		color_count = 0
	}
	local split_strobe = string.split(data, LasersPlus.strobe_separator_char)
	
	output.duration = tonumber(split_strobe[1]) or output.duration
	for k,v in ipairs(split_strobe) do
		if not v then
			self:log("ERROR: Found invalid character in split string! Skipping...")
		elseif k == 1 then
--			self:log("Skipping first key.")
		elseif v then
			output.color_count = k-1
			output.colors[output.color_count] = Color(v)
		else
			self:log("ERROR: Didn't find another color to add to the new strobe table...")
		end
	end
	
	return output
end

--[[
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

--]]

-- ***** Menu/ColorPicker callbacks *****

function LasersPlus:SetColorPickerPalettes(palettes)
	for i,color in ipairs(palettes) do 
		self.settings.palettes[i] = ColorPicker.color_to_hex(color)
	end
end

function LasersPlus:GetColorPickerPalettes()
	local palettes = {}
	for i,color_string in ipairs(self.settings.palettes) do 
		palettes[i] = Color(color_string)
	end
	return palettes
end

function LasersPlus:GetDefaultColorPickerPalettes()
	local palettes = {}
	for i,color_string in ipairs(self.default_palettes) do 
		palettes[i] = Color(color_string)
	end
	return palettes
end

function LasersPlus:CreateColorPicker()
	if ColorPicker and not self._colorpicker then 
		self._colorpicker = ColorPicker:new(
			"lasersplus_colorpicker",
			{
				color = Color.white,
				palettes = self:GetColorPickerPalettes(),
				default_palettes = self:GetDefaultColorPickerPalettes(),
				done_callback = function(new_color,palettes,success)
				end,
				changed_callback = function(new_color)
				end
			},
			callback(self,self,"callback_colorpicker_created")
		)
	end
end

function LasersPlus:callback_colorpicker_created(obj)
	self._colorpicker = self._colorpicker or obj
end

function LasersPlus:callback_open_colorpicker(setting,done_cb,changed_cb)
	if ColorPicker then 
		if self._colorpicker then 
			self._colorpicker:Show({
				color = Color(self.settings[setting]),
				palettes = self:GetColorPickerPalettes(),
				default_palettes = self:GetDefaultColorPickerPalettes(),
				done_callback = function(new_color,palettes,success)
					if success then 
						self.settings[setting] = ColorPicker.color_to_hex(new_color)
						self:SetColorPickerPalettes(palettes)
						
						if done_cb then 
							done_cb(new_color,palettes,success)
						end
						
						self:Save()
					end 
				end,
				changed_callback = changed_cb
			})
		end
	else
		self:callback_show_colorpicker_prompt()
		return
	end
end


--for all specified gadgets, performs custom checks on individual gadget data 
--and apply colors/alpha appropriately
function LasersPlus:CheckGadgetsByType(gadget_type,source)
	for uid,gadget_data in pairs(self.registered_gadgets[gadget_type]) do 
		self:CheckGadget(gadget_data)
	end
end

function LasersPlus:CheckGadget(gadget_data)
	local strobe_id = self:GetGadgetStrobe(gadget_data)
	local color,alpha,is_fallback = self:GetGadgetColor(gadget_data)
	gadget_data.alpha = alpha
	gadget_data.color = color
	if not strobe_id then 
		if not is_fallback then 
			gadget_data.set_color_func(color,alpha)
		end
		gadget_data.strobe_id = nil
		gadget_data.strobe_table = nil
		gadget_data.strobe_index = nil
	else
		gadget_data.strobe_id = strobe_id
		gadget_data.strobe_index = gadget_data.strobe_index or 1
		gadget_data.strobe_table = self.processed_strobes[gadget_data.strobe_id]
	end
end

function LasersPlus:get_colorpicker_closed_callback(menu_gadget_type,menu_preview_type,...)
	return function(new_color,palettes,success)
		--check all gadgets here
		if success then
			for gadget_type,v in pairs(self.registered_gadgets) do 
				for uid,gadget_data in pairs(v) do 
					self:CheckGadget(gadget_data)
				end
			end
			
			self:SetMenuPreviewColor(menu_gadget_type,menu_preview_type,new_color)
		end
	end
end

function LasersPlus:callback_close_colorpicker(gadget_type,source,color)
	if gadget_type and source then
		self:SetMenuPreviewColor(gadget_type,source,color)
--		Hooks:Call(self.hook_ids[gadget_type][source],color)
	end
end

function LasersPlus:SetMenuPreviewColor(menu_gadget_type,menu_preview_type,color)
	if self._menu_preview_objects.colors[menu_gadget_type] then 
		local preview_square = self._menu_preview_objects.colors[menu_gadget_type][menu_preview_type]
		if preview_square and alive(preview_square) then
			preview_square:set_color(color)
		else
			self:log("Error: LasersPlus:SetMenuPreviewColor(" .. self.table_concat({menu_gadget_type,menu_preview_type,color},",") .. "): Bad preview object")
			return
		end
	end
end

function LasersPlus:CheckMenuPreviewReticleColor()

	local ws = managers.menu_component and managers.menu_component._ws
	local parent_panel = ws and ws:panel()
	if not (parent_panel and alive(parent_panel)) then 
		return
	end
	
	local panel = parent_panel:child("lasersplus_menu_previews")
	if alive(panel) then 
		local preview_reticle = panel:child("preview_reticle")
		if not alive(preview_reticle) then 
			self:log("Error: CheckMenuPreviewReticleColor(): Bad preview object")
			return
		end
		
		local selected_reticle_texture = self:GetSightTextureIndex()
		local selected_reticle_color = self:GetSightColorIndex()
		
		local weapon_texture_switches = tweak_data.gui.weapon_texture_switches
		local sight_switch_data = weapon_texture_switches.types.sight
		local suffix = sight_switch_data.suffix
		local color_index_data = weapon_texture_switches.color_indexes
		
		local reticle_switch = sight_switch_data[selected_reticle_texture] or sight_switch_data[1]
		local color_index = color_index_data[selected_reticle_color] or color_index_data[1]
		local color_name = color_index.color
		local reticle_texture = reticle_switch.texture_path
		if color_name ~= "red" then
			reticle_texture = string.gsub(reticle_texture,suffix,"_" .. color_name .. suffix)
		end
		preview_reticle:set_image(reticle_texture)
--		preview_reticle:set_size()
	end
end

function LasersPlus:SetMenuPreviewVisible(menu_gadget_type,menu_source,visible)
	if menu_gadget_type == "reticle" then 
		local preview_reticle = self._menu_preview_objects.reticles[1]
		if alive(preview_reticle) then 
			preview_reticle:set_visible(visible)
		else
			self:log("Error: SetMenuPreviewVisible(" .. self.table_concat({menu_gadget_type,menu_source,visible},",") .. "): Bad preview object")
		end
	elseif menu_gadget_type and self._menu_preview_objects.colors[menu_gadget_type] then 
		if menu_source and self._menu_preview_objects.colors[menu_gadget_type][menu_source] then 
			local preview_square = self._menu_preview_objects.colors[menu_gadget_type][menu_source] 
			if alive(preview_square) then
				preview_square:set_visible(visible)
			else
				self:log("Error: SetMenuPreviewVisible(" .. self.table_concat({menu_gadget_type,menu_source,visible},",") .. "): Bad preview object")
			end
		end
	end
end

function LasersPlus:CreateMenuPreviews()
	local ws = managers.menu_component and managers.menu_component._ws
	local parent_panel = ws and ws:panel()
	if not alive(parent_panel) then 
		self:log("Error: CreateMenuPreviews() No parent panel!")
		return
	end
	
	if not alive(parent_panel:child("lasersplus_menu_previews")) then 
		local panel = parent_panel:panel({
			name = "lasersplus_menu_previews"
		})
		
		local size = LasersPlus.preview_square_size
		
		for gadget_type,v in pairs(LasersPlus.preview_square_placement) do 
			if gadget_type == "reticle" then
				
				local selected_reticle_texture = self:GetSightTextureIndex()
				local selected_reticle_color = self:GetSightColorIndex()
				
				local weapon_texture_switches = tweak_data.gui.weapon_texture_switches
				local sight_switch_data = weapon_texture_switches.types.sight
				local suffix = sight_switch_data.suffix
				local color_index_data = weapon_texture_switches.color_indexes
				
				local reticle_switch = sight_switch_data[selected_reticle_texture] or sight_switch_data[1]
				local color_index = color_index_data[selected_reticle_color] or color_index_data[1]
				local color_name = color_index.color
				local reticle_texture = string.gsub(reticle_switch.texture_path,suffix,"_" .. color_name .. suffix)
				local reticle_preview_placement = LasersPlus.preview_square_placement.reticle
				local preview_reticle = panel:bitmap({
					name = "preview_reticle",
					texture = reticle_texture,
					visible = false,
					x = reticle_preview_placement.x,
					y = reticle_preview_placement.y,
					w = reticle_preview_placement.size,
					h = reticle_preview_placement.size,
--					blend_mode = "add",
					layer = 1
				})
				self._menu_preview_objects.reticles[1] = preview_reticle
			else
				self._menu_preview_objects.colors[gadget_type] = {}
				for source,source_data in pairs(v) do 
					local color_string = source_data.setting_name and self.settings[source_data.setting_name] or LasersPlus.default_settings.generic_laser_color_string
					local preview_square = panel:rect({
						name = source,
						x = source_data.x,
						y = source_data.y,
						w = size,
						h = size,
						visible = false,
						color = Color(color_string),
						blend_mode = "add",
						layer = 1
					})
					self._menu_preview_objects.colors[gadget_type][source] = preview_square
				end
			end
		end
	end
end

function LasersPlus:callback_show_colorpicker_prompt()
	QuickMenu:new(managers.localization:text("menu_lasersplus_missing_colorpicker_title"),string.gsub(managers.localization:text("menu_lasersplus_missing_colorpicker_desc"),"$URL","https://modworkshop.net/mod/29641"),{
		{
			text = managers.localization:text("menu_lasersplus_ok"),
			is_cancel_button = true
		}
	},true)
end

function LasersPlus:ReadLegacySettingsFile()
	local file = io.open(self._legacy_save_path,"r")
	if file then
		local legacy_data = json.decode(file:read("*all"))
		
		file:close()
		return legacy_data
	end
end

function LasersPlus:ArchiveLegacySettingsFile(to_archive)
	local file = io.open(self._legacy_save_path,"w+")
	if file then
		local legacy_data = json.decode(file:read("*all"))
		legacy_data.is_archived = true --flag that indicates that LasersPlus v3+ should not attempt to import this file
		file:write(legacy_data)
		file:close()
	end
end

--import settings from versions of LasersPlus prior to v3
function LasersPlus:ImportLegacySettings(legacy_data)
	local function rgb_to_hex_string(r,g,b)
		return string.format("%x%x%x",(r or 1) * 255,(g or 1) * 255,(b or 1) * 255)
	end
	local new_data = {}
	
	local own_laser_color_string = rgb_to_hex_string(legacy_data.own_laser_red,legacy_data.own_laser_green,legacy_data.own_laser_blue)
	local own_laser_alpha_value = legacy_data.own_laser_alpha_value
	
	
	--[[
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

	override_speed = 1,
	--higher numbers will make lasers faster, at no additional performance cost
	
	quality = 5,
	--scale of 1 to 10, which is the frame interval at which the game updates lasers
	--lower quality number is lower/worse performance, ie bad
	--higher quality number is higher/better performance, ie gud
	max_red_ratio = 0.66, --currently no menu setting for this. 0.66 is quite strict, 0.5 is probably better
	own_laser_display_mode = 3,
	own_flashlight_display_mode = 2,
	team_laser_display_mode = 3,
	team_flashlight_display_mode = 2,
	cop_flashlight_display_mode = 2,
	world_display_mode = 3,
	turret_display_mode = 3,
	sniper_display_mode = 3,

	own_laser_strobe_enabled = true,
	own_flashlight_strobe_enabled = true,
	team_laser_strobe_enabled = true,
	team_flashlight_strobe_enabled = true,
	world_strobe_enabled = true,
	sniper_strobe_enabled = true,
	turret_strobe_enabled = true,
	npc_flashlight_strobe_enabled = true,
	
	own_laser_red = 0.3,
	own_laser_green = 0.3,
	own_laser_blue = 1,
	own_laser_alpha = 1,
	
	own_flash_red = 0.01,
	own_flash_green = 0.03,
	own_flash_blue = 0.3,
	own_flash_alpha = 1,
	flashlight_glow_opacity = 16, --new: light cone effect
	flashlight_range = 10,
	flashlight_angle = 60,
	
	team_laser_red = 0.9,
	team_laser_green = 0.9,
	team_laser_blue = 0.3,
	team_laser_alpha = 0.7,
	
	team_flash_red = 0.01,
	team_flash_green = 0.03,
	team_flash_blue = 0.3,
	team_flash_alpha = 0.7,
	
	npc_flash_red = 0.01,
	npc_flash_green = 0.03,
	npc_flash_blue = 0.3,
	npc_flash_alpha = 0.7,
	
	wl_red = 1,
	wl_green = 0.2,
	wl_blue = 0,
	wl_alpha = 1,
	
	snpr_red = 1,
	snpr_green = 0,
	snpr_blue = 0.3,
	snpr_alpha = 1,

	turr_att_red = 1,
	turr_att_green = 0.3,
	turr_att_blue = 0,
	turr_att_alpha = 1,

	turr_rld_red = 0.7,
	turr_rld_green = 1,
	turr_rld_blue = 0,
	turr_rld_alpha = 1,

	turr_mad_red = 0,
	turr_mad_green = 1,
	turr_mad_blue = 1,
	turr_mad_alpha = 1,
	
	enabled_redfilter = false,
	enabled_blackmarket_qol = true,
	sight_color = 3,
	sight_type = 1,
	enabled_multigadget = true,
	disabled_sight_cycle = false
	--]]
	
	
	local own_laser_color_mode = own_laser_display_mode
	local team_laser_color_mode = team_laser_display_mode
	local world_laser_color_mode = world_laser_display_mode
	local swatturret_laser_color_mode = turret_laser_display_mode
	local cop_laser_color_mode = sniper_display_mode

	for k,v in pairs(new_settings) do 
		self.settings[k] = v
	end

end

function LasersPlus:RemoveLegacySettingsFile()
	os.remove(self._legacy_save_path)
end

-- ***** I/O *****

function LasersPlus:Load()
	do return end
	
	local file = io.open(self._data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		--if no save data exists, create it
		LasersPlus:Save()
	end
--[[
	if SystemFS:exists( Application:nice_path( SavePath .. LasersPlus.savename_3, true )) then
		os.remove( string.format("%s%s", SavePath, LasersPlus.savename_3) )
		LasersPlus:SaveStrobes(true)
	else
		LasersPlus:LoadStrobes()
	end
--]]
end

function LasersPlus:Save()
	do return end
--[[
--	local result = LasersPlus:StrobeTableToString(LasersPlus.own_laser_strobe)
--	self.settings.saved_strobe = result
	LasersPlus:SaveStrobes()
--]]
	local file = io.open(self._data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end


	
-- ***** Receive Data *****
Hooks:Add("NetworkReceivedData", "LasersPlus_NetworkReceivedData", function(sender, message, data)
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

-- ***** Localization and Menus *****

Hooks:Add("LocalizationManagerPostInit", "LasersPlus_LocalizationManagerPostInit", function( loc )
	if not BeardLib then 
		loc:load_localization_file( LasersPlus._default_localization_filepath )
	end
end)


Hooks:Add( "MenuManagerInitialize", "LasersPlus_MenuManagerInitialize", function(menu_manager)
	LasersPlus:Load()
	LasersPlus.strobes = table.deep_map_copy(LasersPlus.default_strobes) --initialize with default strobes
	Hooks:Call("LasersPlus_LoadCustomStrobes",LasersPlus.strobes,LasersPlus.processed_strobes) --add custom strobes
	for strobe_id,strobe_table in pairs(LasersPlus.strobes) do 
		table.insert(LasersPlus.strobe_ids,{strobe_id=strobe_id,name_id=strobe_table.name_id}) --generate list of strobe ids for menu selection purposes
	end
	table.sort(LasersPlus.strobe_ids,function(a,b)
		return managers.localization:text(a.name_id) < managers.localization:text(b.name_id)
	end)
	
	for strobe_id,strobe_table in pairs(LasersPlus.strobes) do
		LasersPlus.processed_strobes[strobe_id] = LasersPlus.processed_strobes[strobe_id] or LasersPlus:ProcessStrobeTable(strobe_table)
	end
	
	LasersPlus:CreateColorPicker()
	
			
	MenuCallbackHandler.callback_lasersplus_menu_main_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_main_focused = function(self,focused)
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_general_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_general_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_qol_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("reticle",nil,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_qol_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_own_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","own",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_own_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_team_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","team",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_team_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_peercolors_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_peercolors_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","peer1",focused)
		LasersPlus:SetMenuPreviewVisible("laser","peer2",focused)
		LasersPlus:SetMenuPreviewVisible("laser","peer3",focused)
		LasersPlus:SetMenuPreviewVisible("laser","peer4",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_world_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_cop_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_cop_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","cop",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_world_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","world",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_swatturret_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_swatturret_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","swatturret_att",focused)
		LasersPlus:SetMenuPreviewVisible("laser","swatturret_rld",focused)
		LasersPlus:SetMenuPreviewVisible("laser","swatturret_mad",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_focused = function(self,focused)
		LasersPlus:SetMenuPreviewVisible("laser","sentrygun_auto",focused)
		LasersPlus:SetMenuPreviewVisible("laser","sentrygun_ap",focused)
		LasersPlus:SetMenuPreviewVisible("laser","sentrygun_off",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_vr_focused = function(self,focused)
--		LasersPlus:SetMenuPreviewVisible("laser","vr",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_vr_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_focused = function(self,focused)
		--
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_own_focused = function(self,focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","own",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_own_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_team_focused = function(self,focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","team",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_team_back = function(self)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_peercolors_focused = function(self,focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","peer1",focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","peer2",focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","peer3",focused)
--		LasersPlus:SetMenuPreviewVisible("flashlight","peer4",focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_flashlights_peercolors_back = function(self)
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_qol_reticle_texture = function(self,item)
		LasersPlus.settings.sight_texture_index = item:value()
		LasersPlus:CheckMenuPreviewReticleColor()
		LasersPlus:Save()
	end
	MenuCallbackHandler.callback_lasersplus_menu_qol_reticle_color = function(self,item)
		LasersPlus.settings.sight_color_index = item:value()
		LasersPlus:CheckMenuPreviewReticleColor()
		LasersPlus:Save()
	end
	
	
	
	
	
	MenuCallbackHandler.callback_lasersplus_lasers_own_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.own_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","own")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_own_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("own_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","own"))
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_own_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.own_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","own")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_own_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.own_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","own")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_own_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.own_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_own_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.own_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_own_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.own_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","own")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_own_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	
	MenuCallbackHandler.callback_lasersplus_lasers_team_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.team_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","team")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_team_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("team_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","team"))
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_team_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.team_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","team")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_team_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.team_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","team")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_team_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.team_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_team_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.team_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_team_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.team_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","team")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_team_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_cop_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.cop_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","cop")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_cop_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("cop_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","cop"))
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_cop_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.cop_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","cop")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_cop_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.cop_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","cop")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_cop_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.cop_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_cop_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.cop_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_cop_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.cop_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","cop")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_cop_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	
	MenuCallbackHandler.callback_lasersplus_lasers_world_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.world_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","world")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_world_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("world_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","world"))
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_world_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.world_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","world")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_world_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.world_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","world")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_world_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.world_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_world_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.world_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_world_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.world_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","world")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_world_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	
	MenuCallbackHandler.callback_lasersplus_lasers_sentrygun_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.sentrygun_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","sentrygun")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_sentrygun_auto_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("sentrygun_auto_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","sentrygun_auto"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_sentrygun_ap_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("sentrygun_ap_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","sentrygun_ap"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_sentrygun_off_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("sentrygun_off_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","sentrygun_off"))
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.sentrygun_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","sentrygun")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_sentrygun_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.sentrygun_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","sentrygun")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_sentrygun_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.sentrygun_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","sentrygun")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_sentrygun_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.sentrygun_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_sentrygun_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.sentrygun_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.sentrygun_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","sentrygun")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_sentrygun_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_swatturret_color_mode = function(self,item)
		local index = item:value()
		LasersPlus.settings.swatturret_laser_color_mode = index
		LasersPlus:CheckGadgetsByType("laser","swatturret")
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_swatturret_att_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("swatturret_att_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","swatturret_att"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_swatturret_mad_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("swatturret_mad_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","swatturret_mad"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_swatturret_rld_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("swatturret_rld_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","swatturret_rld"))
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_swatturret_alpha_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.swatturret_laser_alpha_mode = mode
		LasersPlus:CheckGadgetsByType("laser","swatturret")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_swatturret_alpha_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.swatturret_laser_alpha_value = alpha
		LasersPlus:CheckGadgetsByType("laser","swatturret")
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_swatturret_thickness_mode = function(self,item)
		local mode = item:value()
		LasersPlus.settings.swatturret_laser_thickness_mode = mode
		--updated automatically in WeaponLaser:update()
	end
	
	MenuCallbackHandler.callback_lasersplus_lasers_swatturret_thickness_value = function(self,item)
		local alpha = item:value()
		LasersPlus.settings.swatturret_laser_thickness_value = alpha
		--updated automatically in WeaponLaser:update()
	end
	MenuCallbackHandler.callback_lasersplus_menu_lasers_swatturret_strobe_id = function(self,item)
		local selected_index = item:value()
		local strobe_ids = LasersPlus.strobe_ids
		local selected_strobe_data = strobe_ids[selected_index]
		local selected_strobe_id = selected_strobe_data and selected_strobe_data.strobe_id
		if selected_strobe_data then
			LasersPlus.settings.swatturret_laser_strobe_id = selected_strobe_id
			LasersPlus:CheckGadgetsByType("laser","swatturret")
			LasersPlus:Save()
		else
			LasersPlus:log("Error: MenuCallbackHandler.callback_lasersplus_menu_lasers_swatturret_strobe_id(): bad index [" .. tostring(selected_index) .. "]")
		end
	end
	
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_peer1_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("peer1_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","peer1"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_peer2_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("peer2_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","peer2"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_peer3_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("peer3_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","peer3"))
	end
	MenuCallbackHandler.callback_lasersplus_colorpicker_edit_peer4_laser_color = function(self)
		LasersPlus:callback_open_colorpicker("peer4_laser_color_string",LasersPlus:get_colorpicker_closed_callback("laser","peer4"))
	end


	
	
	MenuCallbackHandler.callback_lasersplus_general_toggle_networking = function(self,item)
		LasersPlus.settings.networking_enabled = item:value() == "on"
		LasersPlus:Save()
	end
	
	
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_main.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_general.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_qol.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_own.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_team.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_cop.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_world.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_sentrygun.json", LasersPlus, LasersPlus.settings)
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path .. "menu_lasers_swatturret.json", LasersPlus, LasersPlus.settings)
	
end)


Hooks:Add("MenuManagerSetupCustomMenus", "LasersPlus_MenuManagerSetupCustomMenus", function(menu_manager, nodes)
	MenuHelper:NewMenu("lasersplus_menu_main")
	if false then 
		
		
		MenuHelper:NewMenu("lasersplus_menu_general")
		
		MenuHelper:NewMenu("lasersplus_menu_strobes")

		MenuHelper:NewMenu("lasersplus_menu_qol")
		
		
		MenuHelper:NewMenu("lasersplus_menu_lasers")
		MenuHelper:NewMenu("lasersplus_menu_lasers_own")
		MenuHelper:NewMenu("lasersplus_menu_lasers_team")
		MenuHelper:NewMenu("lasersplus_menu_lasers_peercolors")
		MenuHelper:NewMenu("lasersplus_menu_lasers_world")
		MenuHelper:NewMenu("lasersplus_menu_lasers_swatturret")
		MenuHelper:NewMenu("lasersplus_menu_lasers_sentrygun")
		MenuHelper:NewMenu("lasersplus_menu_lasers_vr")
		
		MenuHelper:NewMenu("lasersplus_menu_flashlights")
		MenuHelper:NewMenu("lasersplus_menu_flashlights_own")
		MenuHelper:NewMenu("lasersplus_menu_flashlights_team")
		MenuHelper:NewMenu("lasersplus_menu_flashlights_peercolors")
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "LasersPlus_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)

	local selected_strobe_id = LasersPlus.settings.own_laser_strobe_id
	local selected_strobe_index = 1
	local strobes_list = {}
	for i,strobe_data in ipairs(LasersPlus.strobe_ids) do 
		if strobe_data.strobe_id == selected_strobe_id then
			selected_strobe_index = i
		end
		strobes_list[i] = strobe_data.name_id or "missing"
	end
	if #strobes_list > 0 then 
		--technically, using the provided hook, it's possible for another mod to remove all entries from the strobes list. 
		--i'm not gonna be responsible if that happens.
		MenuHelper:AddMultipleChoice({
			id = "lasersplus_menu_lasers_own_strobe_id",
			title = "lasersplus_menu_lasers_own_strobe_id_title",
			desc = "lasersplus_menu_lasers_own_strobe_id_desc",
			callback = "callback_lasersplus_menu_lasers_own_strobe_id",
			items = strobes_list,
			value = selected_strobe_index,
			menu_id = "lasersplus_menu_lasers_own",
			priority = nil
		})
	end
	
	do 
		--qol and strobe in particular need menus generated by lua since they need menus that can be dynamically populated
		--according to a potentially fluctuating table of items
		local reticle_textures = {}
		local reticle_colors = {}
		for i,texture_switch_data in ipairs(tweak_data.gui.weapon_texture_switches.types.sight) do 
			local name_id = texture_switch_data.name_id
			local texture_path = texture_switch_data.texture_path
	--		local dlc = texture_switch_data.dlc
			reticle_textures[i] = name_id
		end
		for i,color_index_data in ipairs(tweak_data.gui.weapon_texture_switches.color_indexes) do 
			local color_name = color_index_data.color
	--		local dlc = color_index_data.dlc
			reticle_colors[i] = "menu_recticle_color_" .. tostring(color_name)
		end
		
		MenuHelper:AddDivider({
			id = "lasersplus_menu_qol_div_1",
			size = 16,
			menu_id = "lasersplus_menu_qol",
			priority = 1
		})
		MenuHelper:AddMultipleChoice({
			id = "lasersplus_menu_qol_reticle_color",
			title = "lasersplus_menu_qol_reticle_color_title",
			desc = "lasersplus_menu_qol_reticle_color_desc",
			callback = "callback_lasersplus_menu_qol_reticle_color",
			items = reticle_colors,
			value = LasersPlus.settings.sight_color_index,
			menu_id = "lasersplus_menu_qol",
			priority = 2
		})
		MenuHelper:AddMultipleChoice({
			id = "lasersplus_menu_qol_reticle_texture",
			title = "lasersplus_menu_qol_reticle_texture_title",
			desc = "lasersplus_menu_qol_reticle_texture_desc",
			callback = "callback_lasersplus_menu_qol_reticle_texture",
			items = reticle_textures,
			value = LasersPlus.settings.sight_texture_index,
			menu_id = "lasersplus_menu_qol",
			priority = 3
		})
	end
	
	
	if false then 
		--populate extra multiplechoice options here
		
		--[[
		MenuHelper:AddToggle({
			id = "lasersplus_menu_general_networking",
			title = "menu_lasersplus_menu_general_networking_title",
			desc = "menu_lasersplus_menu_general_networking_desc",
			callback = "callback_lasersplus_general_toggle_networking",
			value = AdvancedCrosshair.settings.networking_enabled,
			menu_id = "lasersplus_menu_general",
			priority = 1
		})
		--]]
	end
	
end)

Hooks:Add("MenuManagerBuildCustomMenus", "LasersPlus_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	do return end
	nodes.lasersplus_menu_main = MenuHelper:BuildMenu(
		"lasersplus_menu_main",
		{
			area_bg = "none",
			back_callback = "callback_lasersplus_menu_main_back",
			focus_changed_callback = "callback_lasersplus_menu_main_focused"
		}
	)
	MenuHelper:AddMenuItem(nodes.blt_options,"lasersplus_menu_main","lasersplus_menu_main_title","lasersplus_menu_main_desc")
	
	--[[
	nodes.lasersplus_menu_qol = MenuHelper:BuildMenu(
		"lasersplus_menu_qol",
		{
			area_bg = "none",
			back_callback = "callback_lasersplus_menu_qol_back",
			focus_changed_callback = "callback_lasersplus_menu_qol_focused"
		}
	)
	--]]
end)

do return end


--[[ scraps for debugging

logall(output)


for i,v in pairs(LasersPlus.processed_strobes.rainbow) do 
	Log(tostring(v),{color=v})
end


LasersPlus:CheckGadgetsByType("laser","own")


logall(LasersPlus.processed_strobes.rainbow)

Hooks:Call(LasersPlus.hook_ids.laser.own,Color("ffff00"))

function OffyLib:Update(t,dt)
	if asldkfj then 
		Console:SetTrackerValue("trackera",tostring(asldkfj.strobe_index))
	end
end

abc = LasersPlus:ProcessStrobeTable(LasersPlus.default_strobes.rainbow)

logall(LasersPlus.processed_strobes.rainbow)


for k,v in pairs(LasersPlus.registered_gadgets.laser) do 
	asldkfj = asldkfj or v
	logall(v)
	
	
	v.unit:base()._spot_angle_end = 45
	v.unit:base()._light:set_far_range(75)
	v.unit:base()._light:set_near_range(40)
	Log(" ")
end
	
	v.unit:base()._light_glow:set_color(Color.red)
	v.unit:base()._light_glow:set_enable(true)
	v.unit:base()._light_glow:set_spot_angle_end(45)
	v.unit:base()._light_glow:set_far_range(1000)
	v.unit:base()._light_glow:set_near_range(40)
	
	self._light_glow:set_spot_angle_end(20)
	self._light_glow:set_far_range(75)
	self._light_glow:set_near_range(40)
	
	
logall(LasersPlus.processed_strobes.rainbow)


logall(LasersPlus._menu_preview_objects.colors)
Hooks:Call(LasersPlus.hook_ids.laser.own,Color.red,1)
LasersPlus:CreateMenuPreviews()

--]]
