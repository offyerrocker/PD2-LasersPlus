--This mod is not affiliated or involved in any way with RoosterTeeth
--Seriously you guys I just wanted to make a bad play on words

_G.LaserTeam = _G.LaserTeam or {}
local Lasers = Lasers or _G.LaserTeam
Lasers._path = ModPath
Lasers._data_path = Lasers._data_path or SavePath .. "nnlasers.txt"
Lasers._data = Lasers._data or Lasers.settings or {}




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

Lasers.default_gradient_speed = 10
--default frames per laser update on gradiented lasers

--********************************************************************
--_G.LaserTeam = _G.LaserTeam or {}
--local Lasers = Lasers or _G.LaserTeam
--	Lasers._path = Lasers._path or ModPath
--	Lasers._data_path = Lasers._data_path or SavePath .. "nnlasers.txt"

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


--Lasers:Load()



Lasers.Color = {
	Color.green:with_alpha(0.05) or Color.red:with_alpha(Lasers._WorldOpacity)
}--dead bit of useless code


Lasers.SavedTeamColors = Lasers.SavedTeamColors or {}

Lasers.networked_gradients = Lasers.networked_gradients or {}

Lasers.example_gradient = Lasers.example_gradient or {

	colors = {
		[1] = Color(1,0,0):with_alpha(1),
		[2] = Color(0,1,0):with_alpha(1),
		[3] = Color(0,0,1):with_alpha(1),
		[4] = Color(1,0,1):with_alpha(1)
	},
	locations = {
		[1] = 0,
		[2] = 33,
		[3] = 66,
		[4] = 99
	
	
	}
}


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

		---!!!
		if false then 
			local override_color = GradientStep( t, Lasers.example_gradient, speed)
			Lasers:SetColourOfLaser( laser, unit, t, dt, override_color)
--			log("NNL: Did the thing. t = " .. t.. " dt= " .. dt)
			return
		end
		---!!!
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
		
		if Lasers:IsTeamNetworked() then
			--get from stored team lasers
			local color = Lasers.SavedTeamColors[criminal_name]
			log("NNL: criminal_name is " .. criminal_name)
			if color then 
				SetColourOfLaser(nil)
				--/!\ will crash! obsolete!
			
			
			
				--Lasers:SetColourOfLaser( laser, unit, t, dt, color )
			elseif Laser:IsTeamGradient() then --and Lasers.networked_gradients[1].criminal_name then 
				color = "gradient" --obsolete; do gradient calculations here
				SetGradientToLaser( laser, unit, t, dt, criminal_name)
				
				
				laser:set_color_by_theme( color )
				return
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

	override_color = GradientStep( t, Lasers.networked_gradients[criminal_name], Lasers.default_gradient_speed )
-- retrieve and send gradient information from the table, and send it to the other function
	if not override_color then
		override_color = Color(0.8,0.5,0.7):with_alpha(0.8)
		log("NNL: Couldn't create gradient!")
	end
	laser:set_color( override_color )
end

--[[
function gradient_diff(t, color_diff)
	local new_color = ((t * color_diff) / 1
	return new_color
end
--]]

function GradientStep( t, gradient_table, speed )--uses a preset table instead of input specific values
	local colors = gradient_table.colors
	local locations = gradient_table.locations
	local speed = Lasers.default_gradient_speed or 1
	local _t = t % 101 --by default, 100 for location values
	local current_location
	local color_count
	
	for k,v in ipairs(colors) do 
		color_count = k --math.max(color_count,k)
	end

	log("NNL: color count = " .. color_count)
	--get current location based on time
	for k,v in ipairs(locations) do
--		current_location = k --if needs to be the one before
		if v > _t then --if location value is higher than time
			current_location = k
			break
		end
	end
	--override:
	
	

	local col_1 = colors[current_location] or Color(0,0,0):with_alpha(1)
	local col_2 
	log("NNL: current location = " .. current_location)
	if current_location >= color_count then 
		col_2 = colors[1]
	else
		col_2 = colors[current_location + 1]
	end
	col_2 = col_2 or Color(1,1,1):with_alpha(1)
	
	local r_diff = col_2.red - col_1.red
	local g_diff = col_2.green - col_1.green
	local b_diff = col_2.blue - col_1.blue
	local a_diff = col_2.alpha - col_1.alpha		
--[[
	nu_red = col_1.red + (r_diff * _t * speed) / locations[current_location]
	nu_green = col_1.green + (g_diff * _t * speed) / locations[current_location]
	nu_blue = col_1.blue + (b_diff * _t * speed) / locations[current_location]
	nu_alpha = col_1.alpha + (a_diff * _t * speed) / locations[current_location]
]]--
	log("NNL: _t/current_location = " .. _t .. " / " .. current_location)
	current_location = 100
	nu_red = col_1.red + ( (r_diff * _t) / current_location)
	nu_green = col_1.green + ( (g_diff * _t) / current_location)
	nu_blue = col_1.blue + ( (b_diff * _t) / current_location)
	nu_alpha = col_1.alpha + ( (a_diff * _t) / current_location)



	local override_color = Color(nu_red,nu_green,nu_blue):with_alpha(nu_alpha) or Color(1,1,1):with_alpha(1)
		log("Col_1 = " .. LuaNetworking:ColourToString(col_1) .. "|| Col_2 = " .. LuaNetworking:ColourToString(col_2) .. "|| New_col = " .. LuaNetworking:ColourToString(override_color))

	--	return Color(col_1.red + ((r_diff + step) / interval), col_1.green + ((g_diff + step) / interval), col_1.blue + ((g_diff + step) / interval)):with_alpha(col_1.alpha + ((a_diff + step) / interval))
	return override_color
end

function Lasers:SetColorOfLaser( laser, unit, t, dt, override_color )
	log("NNL: Well, well, well... looks like we got a bloody YANKEE here!")
	Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )
	return
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
