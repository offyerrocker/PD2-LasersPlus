LasersPlus = LasersPlus or {}
LasersPlus._core = LasersPlus._core or LasersPlusCore
if LasersPlus._core then 
	LasersPlus._path = LasersPlus._core:GetPath()
else
	LasersPlus._path = ModPath
end
LasersPlus._data_path = SavePath .. "lasersplus_save.txt"
LasersPlus._legacy_save_path = SavePath .. "lasersplus.txt"
LasersPlus._default_localization_filepath = LasersPlus._path .. "localization/en.json"
LasersPlus.has_shown_legacy_save_check = false

LasersPlus.hook_ids = {
	changed = "lasersplus_on_gadget_changed"
}
for _,hook_id in pairs(LasersPlus.hook_ids) do 
	Hooks:Register(hook_id)
end

LasersPlus.default_strobes = {
	rainbow = {}
}
LasersPlus.strobes = {} --populated with list of ids such as "rainbow" on load
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
	generic_laser_alpha = 0.7,
	generic_flashlight_color_string = "f0f2d7", --yellow tint
	generic_flashlight_alpha = 0.9,
	
	own_laser_color_string = "ff9200", --global override for all own weapons
	own_laser_color_mode = 2,
		--1: vanilla
		--2: static (own_laser_color_string)
		--3: peer
		--4: strobe
		--5: invisible
	own_laser_alpha = 0.8,
	own_laser_alpha_mode = 1, -- 1 = vanilla, 2 = custom
	
	own_laser_glow_alpha = 1,
		--glow effect for player lasers
	own_laser_strobe_id = "rainbow",
	
	own_flashlight_color_string = "dfe8f4", -- blue tint
	own_flashlight_alpha = 0.9,
	own_flashlight_alpha_mode = 1,
	own_flashlight_strobe_id = "rainbow",
	
	team_laser_color_string = "00ff00",
	team_laser_color_mode = 1,
		--1: vanilla
		--2: static (team_laser_color_string)
		--3: peer
		--4: strobe
		--5: invisible
	team_laser_strobe_id = "rainbow",
	
	team_laser_alpha_mode = 1,
	team_laser_alpha = 0.7,
	
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
	cop_laser_color_mode = 1,
		--1: vanilla
		--2: static (cop_laser_color_string)
		--3: strobe
		--4: invisible
	cop_laser_color_string = "fb401a", -- red-orange
	cop_laser_strobe_id = "rainbow",
	cop_laser_alpha_mode = 1,
		--1: vanilla
		--2: custom
	cop_laser_alpha = 0.9,
--	cop_flashlight_color_string = "e6bfb8", --baked into the asset iirc, can't be changed through lua
--	cop_flashlight_color_mode = 1,
	
	
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
	world_laser_alpha = 0.9,
	
	
	
	
	
	swatturret_laser_color_mode = 1,
		--1: vanilla
		--2: static (solid color, dependent on turret mode)
		--3: strobe
		--4: invisible
	swatturret_mad_laser_color_string = "00ffff", --ecm swat turret color (cyan)
	swatturret_mad_laser_strobe_id = "rainbow",
	swatturret_att_laser_color_string = "ff0000", --attack swat turret color (red)
	swatturret_att_laser_strobe_id = "rainbow",
	swatturret_rld_laser_color_string = "ffff00", --reload swat turret color (yellow)
	swatturret_rld_laser_strobe_id = "rainbow",
	swatturret_laser_alpha_mode = 1,
		--1: vanilla
		--2: custom
	swatturret_laser_alpha = 0.8,
	
	sentrygun_laser_color_mode = 1,
		--1: vanilla
		--2: static (solid color, dependent on sentrygun normal/ap ammo)
		--3: peer (uses the peer color of player who owns it)
		--4: strobe
		--5: invisible
	sentrygun_auto_laser_color_string = "00ffff", --player sentrygun autofire color (cyan)
	sentrygun_auto_laser_strobe_id = "rainbow",
	sentrygun_ap_laser_color_string = "00ff00", --player sentrygun ap color (green)
	sentrygun_ap_laser_strobe_id = "rainbow",
	sentrygun_laser_alpha_mode = 1,
	sentrygun_laser_alpha = 0.8
}
LasersPlus.settings = LasersPlus.settings or table.deep_map_copy(LasersPlus.default_settings)

--read <2.86 save
--import settings
--give option to delete previous (else save is_converted flag)


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
	return _G.Log(...) or log(...)
end

-- ***** Settings Getters *****

function LasersPlus:GetGadgetColor(gadget_data)
	local source = gadget_data.source
	local gadget_type = gadget_data.gadget_type
	local peer_id = gadget_data.peer_id
	local is_ai = gadget_data.is_ai
	
	local char_id = gadget_data.char_id
	local team_id = gadget_data.team_id
	
	local color,alpha
	if gadget_type == "laser" then 
		color = Color(LasersPlus.default_settings.generic_laser_color_string)
		alpha = LasersPlus.default_settings.generic_laser_alpha
		
		if source == "own" then
			local color_mode = self.settings.own_laser_color_mode
			local alpha_mode = self.settings.own_laser_alpha_mode
			if alpha_mode == 1 then 
				alpha = gadget_data.natural_alpha or alpha
			else
				alpha = self.settings.own_laser_alpha or alpha
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
				alpha = self.settings.team_laser_alpha or alpha
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
				alpha = self.settings.cop_laser_alpha or alpha
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
				alpha = self.settings.world_laser_alpha or alpha
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
			if alpha_mode == 1 then 
				alpha = gadget_data.natural_alpha or alpha
			else
				alpha = self.settings.swatturret_laser_alpha or alpha
			end
			
			local sentry_unit
			if mad then 
				color = self.settings.swatturret_mad_laser_color_string and Color(self.settings.swatturret_mad_laser_color_string) or color
			elseif att then 
				color = self.settings.swatturret_att_laser_color_string and Color(self.settings.swatturret_att_laser_color_string) or color
			elseif rld then 
				color = self.settings.swatturret_rld_laser_color_string and Color(self.settings.swatturret_rld_laser_color_string) or color
			end
		elseif source == "sentrygun" then
			local color_mode = self.settings.sentrygun_laser_color_mode
			local alpha_mode = self.settings.sentrygun_laser_alpha_mode
			if alpha_mode == 1 then 
				alpha = gadget_data.natural_alpha or alpha
			else
				alpha = self.settings.sentrygun_laser_alpha or alpha
			end
			
			local sentry_unit
			if ap then 
				color = self.settings.sentrygun_ap_laser_color_string and Color(self.settings.sentrygun_ap_laser_color_string) or color
			else
				color = self.settings.sentrygun_auto_laser_color_string and Color(self.settings.sentrygun_auto_laser_color_string) or color
			end
		end
		
		
		
	elseif gadget_type == "flashlight" then 
		color = Color(LasersPlus.default_settings.generic_flashlight_color_string)
		alpha = LasersPlus.default_settings.generic_flashlight_alpha
	
	else
		color = Color(LasersPlus.default_settings.generic_laser_color_string)
		alpha = LasersPlus.default_settings.generic_laser_alpha
	end
	return color,alpha
end

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

-- ***** Settings Setters *****




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

function LasersPlus:SetGadgetParams(gadget_type,unit,params)
	if not alive(unit) then 
		self:log("Error: LasersPlus:SetGadgetParams(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. "): Bad unit")
		return
	end
	params = params or {}
	local unit_key = unit:key()
	local hook_id_prefix = tostring(unit_key)
	
	if not self.registered_gadgets[gadget_type] then
		self:log("Error: LasersPlus:SetGadgetParams(" .. LasersPlus.table_concat({gadget_type,unit,params},",") .. "): Bad gadget_type")
		return
	end
	
	local gadget_data = self.registered_gadgets[gadget_type][unit_key]
	if gadget_data then
		for k,v in pairs(params) do 
			gadget_data[k] = v
		end
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
	local hook_id_prefix = tostring(unit_key)
	
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
		strobe_id = 1,
		strobe_frame = 1,
		hook_id_prefix = hook_id_prefix
	}
	local setting_color,setting_alpha = self:GetGadgetColor(gadget_data)
	self.registered_gadgets[gadget_type][unit_key] = gadget_data

	local strobe_id = self:GetGadgetStrobe(gadget_data)
	if strobe_id then 
--		register updater
	end
	
	Log(gadget_type)
	Log(setting_color)
	Log(setting_alpha)
	if gadget_data.brush then 
		brush:set_color(setting_color:with_alpha(setting_alpha))
	elseif alive(unit) then
		unit:base():set_color(setting_color:with_alpha(setting_alpha))
	end
	
	Hooks:Add(self.hook_ids.changed,hook_id_prefix .. "_" .. self.hook_ids.changed,function()
		
	end)
	
end

function LasersPlus:UnregisterGadget(gadget_type,unit,unit_key)
	unit_key = unit_key or unit:key()
	if gadget_type and self.registered_gadgets[gadget_type] then
		self.registered_gadgets[gadget_type][unit_key] = nil
	end
end


-- ***** Strobes *****
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

function LasersPlus:ImportLegacySettings(legacy_data)
	
	
end

function LasersPlus:RemoveLegacySettingsFile()
	os.remove(self._legacy_save_path)
end

-- ***** I/O *****

function LasersPlus:Load()
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

-- ***** Localization and Menus *****

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_LasersPlus", function( loc )
	if not BeardLib then 
		loc:load_localization_file( LasersPlus._default_localization_filepath )
	end
end)


Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_LasersPlus", function(menu_manager)

end)

