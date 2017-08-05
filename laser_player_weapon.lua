--This mod is not affiliated or involved in any way with RoosterTeeth
--Seriously you guys I just wanted to make a bad play on words

_G.LaserTeam = _G.LaserTeam or {}
local Lasers = Lasers or _G.LaserTeam
Lasers._path = ModPath
Lasers._data_path = Lasers._data_path or SavePath .. "nnlasers.txt"
Lasers._data = Lasers._data or Lasers.settings or {}



Lasers:Load()
--[[
if RequiredScript == "lib/units/weapons/weaponlaser" then

	local init_original = Lasers.init
	
	Lasers.DEFINITIONS = {
			default = {      --Player
					color = Color(CustomLaser._data.slider_r_value, CustomLaser._data.slider_g_value, CustomLaser._data.slider_b_value),
					alpha = CustomLaser._data.slider_a_value,
			},
			cop_sniper = {  --Enemy snipers
					color = Color(CustomLaser._data.slider_sniper_r_value, CustomLaser._data.slider_sniper_g_value, CustomLaser._data.slider_sniper_b_value),
					alpha = CustomLaser._data.slider_sniper_a_value,
			},
			player = {     --Team mates
					color = Color(0, 1, 0),
					alpha = 0.25,
			},
			turret_module_active = {        --SWAT turret standard
					color = Color(1, 0, 0),
					alpha = 0.15,
			},
			turret_module_rearming = {      --SWAT turret reloading
					color = Color(1, 1, 0),
					alpha = 0.11,
			},
			turret_module_mad = {   --SWAT turret jammed
					color = Color(0, 1, 0),
					alpha = 0.15,
			},
	}
   
	function Lasers:init(...)
			init_original(self, ...)
			self:init_themes()
			self:set_color_by_theme(self._theme_type)

	end
	
	
	
	
end
]]--

-- Lasers

Lasers.LuaNetID = "nncpl"
--"new networked custom player lasers" in order to keep it unlikely for another mod to share its id

Lasers.LegacyID = "gmcpwl"
--legacy support for the 0.00000002% of players still using GoonMod somehow

Lasers.GradientTypeID = "nncpl_gr_v1"
--for advanced users- creates a gradient between two or more colors. 

Lasers._WorldOpacity = 0.6
--default opacity for lasers

--********************************************************************
--_G.LaserTeam = _G.LaserTeam or {}
--local Lasers = Lasers or _G.LaserTeam
--	Lasers._path = Lasers._path or ModPath
--	Lasers._data_path = Lasers._data_path or SavePath .. "nnlasers.txt"

if RequiredScript == "lib/managers/menumanager" then 

	Lasers.default_settings = Lasers.default_settings or {
	
--Player/self
		own_red = 0.9,
		own_green = 0.2,
		own_blue = 0.15,
		own_alpha = 0.08,
		
--team/other players
		team_red = 0.8,
		team_green = 0.1,
		team_blue = 0.25,
		team_alpha = 0.04,
		
--police snipers
		snpr_red = 1,
		snpr_green = 0.2,
		snpr_blue = 0.2,
		snpr_alpha = 0.5,
				
--world lasers/vault lasers (go bank, big bank, murky station, golden grin etc)
		wl_red = 0.8,
		wl_green = 0.5,
		wl_blue = 0.15,
		wl_alpha = 0.8,

--swat turrets
	--turret normal attack
		turr_att_red = 1,
		turr_att_green = 0.4,
		turr_att_blue = 0.1,
		turr_att_alpha = 0.4,
	--turret reloading
		turr_rld_red = 0.7,
		turr_rld_green = 0.7,
		turr_rld_blue = 0.4,
		turr_rld_alpha = 0.25,
	--turret ecm (friendly)
		turr_ecm_red = 0.2,
		turr_ecm_green = 0.8,
		turr_ecm_blue = 1,
		turr_ecm_alpha = 0.4,

--NL view settings
	--team laser display mode
		--[[
		1 : Custom (User-set)
		2 : Uniform (Same as Peer Color - ie. Green if Host, Blue if P2, Red if P3, Yellow if P4)
		3 : Networked (Uses the other client's laser color through Lua Networking. Cool, right?)
		4 : Turned Off
		;)  ^ classy amirite
		--]]
		display_team_lasers = 3,
	--network my lasers, on by default. Why else would you have downloaded this mod?
		networked_lasers = "enabled"
	}
		
	Lasers.settings = Lasers.settings or Lasers.default_settings
	
	Lasers._data = Lasers._data or Lasers.settings or {}

	function Lasers:Load()
		self.settings = self.settings or self.default_settings
		
		local file = io.open(self._data_path, "r")
		if (file) then
			for k, v in pairs(json.decode(file:read("*all"))) do
				self.settings[k] = v
			end
		end
	end
	
	function Lasers:Save()
		local file = io.open(self._data_path,"w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end
	
	function Lasers:getCompleteTable()
		local tbl = {}
		for i, v in pairs (Lasers.settings) do
			if not i == nil then
				tbl[i] = v + 1
			end
		end
		return tbl
	end
	
	function Lasers:Reset()
		Lasers.settings = Lasers.default_settings
		--i might be going to programmer's hell for this
	end

	--[[
	function setPR (this, item)
		if not Lasers.settings[own_red] then 
			Lasers:Load()
		end
	end
	--]]

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NewNetworkedLasers", function( loc )
		loc:load_localization_file( Lasers._path .. "en.txt")
	end)
	
	Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_NewNetworkedLasers", function(menu_manager)
	
		MenuCallbackHandler.callback_own_r_slider = function(self,item)
			Lasers.settings.own_red = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_own_g_slider = function(self,item)
			Lasers.settings.own_green = item:value()
			Lasers:Save()
		end
	
		MenuCallbackHandler.callback_own_b_slider = function(self,item)
			Lasers.settings.own_blue = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_own_a_slider = function(self,item)
			Lasers.settings.own_alpha = item:value()
			Lasers:Save()
		end
		
		
		
		
		MenuCallbackHandler.callback_team_r_slider = function(self,item)
			Lasers.settings.team_red = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_team_g_slider = function(self,item)
			Lasers.settings.team_green = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_team_b_slider = function(self,item)
			Lasers.settings.team_blue = item:value()		
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_team_a_slider = function(self,item)
			Lasers.settings.alpha = item:value()
			Lasers:Save()
		end

		
		
		
		MenuCallbackHandler.callback_snpr_r_slider = function(self,item)
			Lasers.settings.snpr_red = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_snpr_g_slider = function(self,item)
			Lasers.settings.snpr_green = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_snpr_b_slider = function(self,item)
			Lasers.settings.snpr_blue = item:value()
			Lasers:Save()
		end

		MenuCallbackHandler.callback_snpr_a_slider = function(self,item)
			Lasers.settings.snpr_alpha = item:value()
			Lasers:Save()
		end
		
		
		
		
		
		MenuCallbackHandler.callback_wl_r_slider = function(self,item)
			Lasers.settings.wl_red = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_wl_g_slider = function(self,item)
			Lasers.settings.wl_green = item:value()
			Lasers:Save()
		end

		MenuCallbackHandler.callback_wl_b_slider = function(self,item)
			Lasers.settings.wl_blue = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_wl_a_slider = function(self,item)
			Lasers.settings.wl_alpha = item:value()
			Lasers:Save()
		end
		
		
		
		
		MenuCallbackHandler.callback_turr_att_r_slider = function(self,item)
			Lasers.settings.turr_att_red = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_att_g_slider = function(self,item)
			Lasers.settings.turr_att_green = item:value()
			Lasers:Save()
		end

		MenuCallbackHandler.callback_turr_att_b_slider = function(self,item)
			Lasers.settings.turr_att_blue = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_att_a_slider = function(self,item)
			Lasers.settings.turr_att_alpha = item:value()
			Lasers:Save()
		end

		
		
		
		MenuCallbackHandler.callback_turr_rld_r_slider = function(self,item)
			Lasers.settings.turr_rld_red = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_rld_g_slider = function(self,item)
			Lasers.settings.turr_rld_green = item:value()
			Lasers:Save()
		end

		MenuCallbackHandler.callback_turr_rld_b_slider = function(self,item)
			Lasers.settings.turr_rld_blue = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_rld_a_slider = function(self,item)
			Lasers.settings.turr_rld_alpha = item:value()
			Lasers:Save()
		end
		
		
		
		
		MenuCallbackHandler.callback_turr_ecm_r_slider = function(self,item)
			Lasers.settings.turr_ecm_red = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_ecm_g_slider = function(self,item)
			Lasers.settings.turr_ecm_green = item:value()
			Lasers:Save()
		end

		MenuCallbackHandler.callback_turr_ecm_b_slider = function(self,item)
			Lasers.settings.turr_ecm_blue = item:value()
			Lasers:Save()
		end
				
		MenuCallbackHandler.callback_turr_ecm_a_slider = function(self,item)
			Lasers.settings.turr_ecm_alpha = item:value()
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_team_lasers_display_multiplechoice = function(self,item)
			Lasers.settings.display_team_lasers = tonumber(item:value())
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_networked_lasers_toggle = function(self,item)
			local value = item:value() == "enabled" and true or false
			Lasers.settings.networked_lasers = value
			Lasers:Save()
		end
		
		MenuCallbackHandler.callback_nnl_close = function(this)
			Lasers:Save()
		end
		
		Lasers:Load()
		MenuHelper:LoadFromJsonFile(Lasers._path .. "options.txt", Lasers, Lasers.settings)
--		MenuHelper:LoadFromJsonFile(LaserTeam._path .. "options.txt", LaserTeam, LaserTeam:getCompleteTable())
		
	end )
--********************************************************************
--settings:
--[[
Lasers.settings = {
	laser_team_mode = 0,
	--uniform, peer, team, default
	--same as player, same as peer color, same as "team" setting, vanilla game setting
	
	networked_lasers = true,
	--overrides laser_team_mode except for players who either 1) don't have the mod, or 2) disabled networked lasers themselves
	
	--player laser values
	player_r = 0.1,
	player_g = 1,
	player_b = 0.25,
	player_a = 0.065,
	
	--team laser values- if you want to change the defaults per-player, change the "DefaultTeamColors" table below, set "laser_team_mode" to "peer," disable "networked_lasers"
	team_r = 0.2,
	team_g = 1,
	team_b = 0.4,
	team_a = 0.04,
	redblue = Color(1,1,1):with_alpha(0.5)
	--lasers for: world, sniper, turret active, turret disabled/reloading, and turret ecmed should be updated by theme until i add networked npc lasers
}
--]]
else 

--[[ Options
GoonBase.Options.WeaponLasers 				= GoonBase.Options.WeaponLasers or {}
GoonBase.Options.WeaponLasers.Enabled 		= GoonBase.Options.WeaponLasers.Enabled
GoonBase.Options.WeaponLasers.RH 			= GoonBase.Options.WeaponLasers.RH or 0.0
GoonBase.Options.WeaponLasers.GS 			= GoonBase.Options.WeaponLasers.GS or 0.75
GoonBase.Options.WeaponLasers.BV 			= GoonBase.Options.WeaponLasers.BV or 0.0
GoonBase.Options.WeaponLasers.UseHSV 		= GoonBase.Options.WeaponLasers.UseHSV
GoonBase.Options.WeaponLasers.UseRainbow 	= GoonBase.Options.WeaponLasers.UseRainbow
GoonBase.Options.WeaponLasers.RainbowSpeed 	= GoonBase.Options.WeaponLasers.RainbowSpeed or 1
GoonBase.Options.WeaponLasers.TeamLasers 	= GoonBase.Options.WeaponLasers.TeamLasers or 3
if GoonBase.Options.WeaponLasers.Enabled == nil then
	GoonBase.Options.WeaponLasers.Enabled = true
end
if GoonBase.Options.WeaponLasers.UseHSV == nil then
	GoonBase.Options.WeaponLasers.UseHSV = false
end
if GoonBase.Options.WeaponLasers.UseRainbow == nil then
	GoonBase.Options.WeaponLasers.UseRainbow = false
end
]]


Lasers.Color = {
	Color.green:with_alpha(0.05) or Color.red:with_alpha(Lasers._WorldOpacity)
}--dead bit of useless code


Lasers.SavedTeamColors = Lasers.SavedTeamColors or {}

Lasers.networked_gradients = Lasers.networked_gradients or {}
--[[currently, only supports 2 colors and no additional positions
--format: 
p1 = {
	colors = {
		[1] = Color(1,0,0):with_alpha(1),
		[2] = Color(0,0,1):with_alpha(1),
		[3] = color(1,1,1):with_alpha(1)
	},
	locations = {
		[1] = 0,
		[2] = 50,
		[3] = 100
	
	
	}
}


old:
{
	[1] = {
		color1 = Color(1,0,0):with_alpha(1),
		color2 = Color(0,0,1):with_alpha(1),
		pos1 = 0,
		pos2 = 1
	},
	[2] = {
		color1 = Color(0,1,0):with_alpha(1),
		color2 = Color(1,0,0):with_alpha(1),
		pos1 = 0,
		pos2 = 1
	},
	[3] = {
		color1 = Color(1,1,0):with_alpha(1),
		color2 = Color(1,0,1):with_alpha(1),
		pos1 = 0,
		pos2 = 1
	},
	[4] = {
		color1 = Color(1,0.6,0):with_alpha(1),
		color2 = Color(0,0,1):with_alpha(1),
		pos1 = 0,
		pos2 = 1
	}
}
--]]
Lasers.DefaultTeamColors = Lasers.DefaultTeamColors or {
	[1] = Color("29ce31"):with_alpha(_WorldOpacity),--Color("00ffdd"),
	[2] = Color("00eae8"):with_alpha(_WorldOpacity),
	[3] = Color("f99d1c"):with_alpha(_WorldOpacity),
	[4] = Color("ebe818"):with_alpha(_WorldOpacity),
	[5] = Color("ffffff"):with_alpha(1)
}



function Lasers:IsEnabled()
	return true
end

function Lasers:IsRainbow()
	return false
end

function Lasers:RainbowSpeed()
	return 1
end
--[[	
		Lasers.DefaultTeamColors[LuaNetworking:LocalPeerID()] = GetPlayerLaserColor() 
		--!
		log("NEW NETWORKED LASERS: LocalPeer is this:" .. LuaNetworking:LocalPeerID())
--]]

function Lasers:GetPlayerLaserColor()
--	if not Lasers.settings.own_red then
		Lasers:Load()
--	end
	return Color(Lasers.settings.own_red,Lasers.settings.own_green,Lasers.settings.own_blue):with_alpha(Lasers.settings.own_alpha) or Color(1,1,1):with_alpha(1)
end

function Lasers:GetTeamLaserColor()
	Lasers:Load()
	return Color(Lasers.settings.team_red,Lasers.settings.team_green,Lasers.settings.team_blue):with_alpha(Lasers.settings.team_alpha) or Color(1,1,1):with_alpha(1)
end

function Lasers:GetPeerColor(criminal_name)
--		if Lasers:AreTeamLasersUnique() then
	local id = managers.criminals:character_color_id_by_name( criminal_name )
	if id == 1 then id = id + 1 end
	local color = Lasers.DefaultTeamColors[ id or 5 ]:with_alpha(Lasers.DefaultTeamColors[ id or 5 ].alpha or Lasers._WorldOpacity)
--			log("NNL: id = " .. id)
	color = color or Color(1,1,1):with_alpha(1)
	Lasers:SetColourOfLaser( laser, unit, t, dt, color )
	return
--	return Lasers.DefaultTeamColors[peernum] or Color(1,1,1):with_alpha(1)
end

function Lasers:IsTeamCustom()
	return Lasers.settings.display_team_lasers == 1
end

function Lasers:IsTeamUniform()
	return Lasers.settings.display_team_lasers == 2
end

function Lasers:IsTeamGradient() --fix this. currently not called
	return Lasers.settings.display_team_lasers == 3
end

function Lasers:IsTeamNetworked()
	return Lasers.settings.networked_lasers -- formerly Lasers.settings.display_team_lasers == 3
end
--make this a toggle instead of overriding, replace with gradient

function Lasers:IsTeamDisabled()
	return Lasers.settings.display_team_lasers == 4
end



function Lasers:GetColor(alpha)
	return Lasers.DefaultTeamColors[LuaNetworking:LocalPeerID()]:with_alpha(0.07) --Lasers.Color:GetColor( alpha )
end


--[[
function Lasers:AreTeamLasersOff()
	return false --GoonBase.Options.WeaponLasers.TeamLasers == 1
end

function Lasers:AreTeamLasersSameColour()
	return false --GoonBase.Options.WeaponLasers.TeamLasers == 2
end

function Lasers:AreTeamLasersNetworked()
	return true --GoonBase.Options.WeaponLasers.TeamLasers == 3
end
]]--
function Lasers:AreTeamLasersUnique()
	log("NNL: function Lasers:AreTeamLasersUnique shouldn't be called.")
	return true --GoonBase.Options.WeaponLasers.TeamLasers == 4
end


function Lasers:GetCriminalNameFromLaserUnit( laser )

	if not self._laser_units_lookup then
		self._laser_units_lookup = {}
	end

	local laser_key = nil
	if laser._unit then
		laser_key = laser._unit:key()
	end
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
			if Lasers:CheckWeaponForLasers( weapon_base, laser_key ) then
				self._laser_units_lookup[laser_key] = character.name
				return
			end

			if weapon_base._second_gun then
				if Lasers:CheckWeaponForLasers( weapon_base._second_gun:base(), laser_key ) then
					self._laser_units_lookup[laser_key] = character.name
					return
				end
			end

		end
	end

	if laser_key then
		self._laser_units_lookup[laser_key] = false
	end
	return nil

end
--[[
local t = {}                   -- table to store the indices
    local i = 0
    while true do
      i = string.find(s, "\n", i+1)    -- find 'next' newline
      if i == nil then break end
      table.insert(t, i)
    end
]]

--function Lasers:RGBAtoString(color,alpha)

function Lasers:CheckWeaponForLasers( weapon_base, key )

	if weapon_base and weapon_base._factory_id and weapon_base._blueprint then

		local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weapon_base._factory_id, weapon_base._blueprint)
		if gadgets then
			for _, i in ipairs(gadgets) do
				if not weapon_base._parts[i].unit then 
					log("NNL: No weapon part found for unit")
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

function Lasers:UpdateLaser( laser, unit, t, dt )
	if not Lasers:IsEnabled() then
		return
	end

	if laser._is_npc then

		local criminal_name = Lasers:GetCriminalNameFromLaserUnit( laser )
		if not criminal_name then
			return
		end

		
		if Lasers:IsTeamCustom() then
			--set locally by your mod options, not networked
			Lasers:SetColourOfLaser( laser, unit, t, dt, Lasers:GetTeamLaserColor())
		end
		
		if Lasers:IsTeamUniform() then 
			Lasers:SetColourOfLaser( laser, unit, t, dt, Lasers:GetPeerColor(criminal_name))
			--peer color
		end

		if Lasers:IsTeamDisabled() then
			Lasers:SetColourOfLaser( laser, unit, t, dt, Color(0,0,0):with_alpha(0))
		end
		
		
--[[		
		if Lasers:AreTeamLasersOff() then
			Lasers:SetColourOfLaser( laser, unit, t, dt, Color.green:with_alpha(0.1) )
			return
		end

		if Lasers:AreTeamLasersSameColour() then
			Lasers:SetColourOfLaser( laser, unit, t, dt )
			return
		end
--
		if Lasers:AreTeamLasersNetworked() then
			local color = Lasers.SavedTeamColors[criminal_name]
			if color then
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
			end
			return
		end
--]]		
	
		if Lasers:IsTeamNetworked() then
			--get from stored team lasers
			local color = Lasers.SavedTeamColors[criminal_name]
			log("NNL: criminal_name is " .. criminal_name)
			if color then 
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
			elseif Laser:IsTeamGradient() and Lasers.networked_gradients[1].criminal_name then 
				--do gradient calculations here
				color = "gradient" --obsolete 
				SetGradientToLaser( laser, unit, t, dt, criminal_name)
			elseif Lasers:IsTeamUniform() then 
				color = Lasers:GetPeerColor(criminal_name) 
			elseif Lasers:IsTeamCustom() then 
				color = Lasers:GetTeamLaserColor()
			elseif Laser:IsTeamDisabled() then 
				color = Color(0,0,0):with_alpha(0)
			else 
				log("NNL: Couldn't identify team laser type! How odd!")
				color = Color(1,0.6,0.8):with_alpha(1)
			end
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
				--should be doing this with "or" operator
			return 
		end
	end

	Lasers:SetColourOfLaser( laser, unit, t, dt )

end

function SetGradientToLaser( laser, unit, t, dt, peer )
	
	
	
	override_color = GradientStep( sdfasdf )

	if not override_color then
		override_color = Color(0.8,0.5,0.7):with_alpha(0.8)
		log("NNL: Couldn't create gradient!")
	end
	laser:set_color( override_color )
end

function GradientStep(criminal_name)--col_1,col_2,interval,t) --colors require an alpha
--currently only supports 2 colors, and fixed locations at 0 and 100
--	color_count = table.getn(
	if not networked_gradients[criminal_name] then
		log("NNL: Invalid criminal_name while constructing gradient")
		return Color(0.8,0.3,0.7):with_alpha(1)
	end
	
	--get all colors stored in player's gradient table
	
--	for i,v in pairs(networked_gradients.colors) do
--	end
	
--networked_gradients[criminal_name][i]

	local r_diff = col_2.red - col_1.red
	local g_diff = col_2.green - col_1.green
	local b_diff = col_2.blue - col_1.blue
	local a_diff = col_2.alpha - col_1.alpha
	local step = interval % t	
	return Color(col_1.red + ((r_diff + step) / interval), col_1.green + ((g_diff + step) / interval), col_1.blue + ((g_diff + step) / interval)):with_alpha(col_1.alpha + ((a_diff + step) / interval))
end


function Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )
--	Lasers.settings.redblue = GradientStep(Color(1,0,0):with_alpha(0.25),Color(0,0,1):with_alpha(0.5),30,t) --60? dunno lol
--	log(LuaNetworking:ColourToString(Lasers.settings.redblue))
	
	if override_color then
		if override_color ~= "gradient" then
			laser:set_color( override_color )
		else
		--obsolete! 
		
		
--			if type(override_color) == "string" then
			override_color = GradientStep(color)
			--this WILL crash. do not use this.
			--converts criminal id into stored gradient received through LuaNetworking, or else uses player setting
			laser:set_color_by_theme( override_color )
--				else laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
		end
		return
	end

	
	
	if not Lasers:IsTeamGradient() then
		laser:set_color(Lasers:GetPlayerLaserColor()) --Lasers:GetColor( Lasers._WorldOpacity ) )
		return
	else
		--/!\ under construction! fix gradient here!
--		Lasers:GradientStep
	--	laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers._WorldOpacity) )
		return
	end

end


Hooks:Add("WeaponLaserInit", "WeaponLaserInit_", function(laser, unit)
	Lasers:UpdateLaser(laser, unit, 0, 0)
end)

Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_Rainbow_", function(laser, unit, t, dt)
	Lasers:UpdateLaser(laser, unit, t, dt)
end)

Hooks:Add("WeaponLaserSetOn", "WeaponLaserSetOn_", function(laser)

	if laser._is_npc then
		return
	end

	local criminals_manager = managers.criminals
	if not criminals_manager then
		return
	end

	local local_name = criminals_manager:local_character_name()
	local laser_name = Lasers:GetCriminalNameFromLaserUnit(laser)
	if laser_name == nil or local_name == laser_name then
		local col_str = LuaNetworking:ColourToString(Lasers:GetPlayerLaserColor()) --Should include alpha already, to be tested
--		if Lasers:IsRainbow() then
--			col_str = "rainbow"
--		end
		if Lasers.settings.networked_lasers then
			LuaNetworking:SendToPeers(Lasers.LuaNetID, col_str)
		end
	end

end)

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_", function(sender, message, data)

	if message == Lasers.LuaNetID or message == Lasers.LegacyID then

		local criminals_manager = managers.criminals
		if not criminals_manager then
			return
		end

		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		if data ~= "gradient" then
			col = LuaNetworking:StringToColour(data)
		end

		if char then
			Lasers.SavedTeamColors[char] = col
		end
		
	elseif message == Lasers.GradientTypeID then
			--[[
				message 1:local n = num of colors
				
				message 2: color2
				...
				message n: colorn
				
				message n+1: position 1
				...
				message 2n + 1: position n
			
			--]]
	
		local criminals_manager = managers.criminals
		if not criminals_manager then 
			return
		end
		
		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		if data ~= "none" then
			col = LuaNetworking:StringToColour(data)
		end
		
		if char then
			Lasers.SavedTeamColors[char] = col
		end
	end
	
	--else add person to legacy list once i add that

end)

end