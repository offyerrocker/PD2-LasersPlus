--This mod is not affiliated or involved in any way with RoosterTeeth
--Seriously you guys I just wanted to make a bad play on words

_G.LaserTeam = _G.LaserTeam or {}
local Lasers = Lasers or _G.LaserTeam
Lasers._path = ModPath
Lasers._data_path = Lasers._data_path or SavePath .. "nnlasers.txt"
Lasers._data = Lasers._data or Lasers.settings or {}

-- hidden settings not found in user-accessible settings menu

Lasers.LuaNetID = "nncpl"
--"new networked custom player lasers"
--borderline absurd acronym in order to keep it unlikely for another mod to share its id

Lasers.LegacyID = "gmcpwl"
--legacy support for the 0.00000002% of players still using GoonMod somehow

Lasers.LuaNetID_gradient = "nncpl_gr_v1" 
--"new networked custom player lasers- gradient - version one"
--for advanced users- creates a gradient between two or more colors. 

Lasers.DefaultOpacity = 0.5
--default opacity for lasers

Lasers.update_interval = 2 --default rate of update on lasers. lower looks better. greatly affects performance! set to 0 for maximum performance (unlimited)
Lasers.default_gradient_speed = 20 --rate of laser change between color locations- higher is faster. no additional effect on performance.

Lasers.lowquality_gradients = false --local option, does not affect what others see. instant switch instead of slow gradients

Lasers.debugLogsEnabled = false

Lasers.dev_gradient = true
--enables sending of gradient info through networks, and viewing of others' gradient lasers 

Lasers.last_grad = Color(0,0,0):with_alpha(0)

Lasers.legacy_clients = Lasers.legacy_clients or {}

Lasers.SavedTeamColors = Lasers.SavedTeamColors or {}

Lasers.networked_gradients = Lasers.networked_gradients or {
	[1] = {
		active = false,
		colors = {},
		locations = {}
	},
	[2] = {
		active = false,
		colors = {},
		locations = {}
	},
	[3] = {
		active = false,
		colors = {},
		locations = {}
	},
	[4] = {
		active = false,
		colors = {},
		locations = {}
	}
	
}
--done dissect colour_to_string and rebuild for tables
Lasers.rainbow = {
	colors = {
		[1] = Color(1,0,0):with_alpha(DefaultOpacity),
		[2] = Color(0,1,0):with_alpha(DefaultOpacity),
		[3] = Color(0,0,1):with_alpha(DefaultOpacity)
	},
	locations = {
		[1] = 0,
		[2] = 33,
		[3] = 66	
	
	}
}

Lasers.example_gradient = Lasers.example_gradient or {
	colors = {
		[1] = Color(1,0,0):with_alpha(0.3),
		[2] = Color(0,1,0):with_alpha(0.3),
		[3] = Color(0,0,1):with_alpha(0.3)
	},
	locations = {
		[1] = 0,
		[2] = 33,
		[3] = 66	
	
	}
}
--Lasers._networked_gradient_string = "r:{1}|g:{2}|b:{3}|a:{4}/"
--Lasers._networked_gradient_string = "col[n]/col[n+1]... \"

function Lasers:GradientTableToString(gradient_table)
--splits a table's contents into a string
	local g_colors = gradient_table.colors
	local g_locations = gradient_table.locations
	local col_sep = "%$" --color separator; this is dumb
	local loc_sep = "^" --location separator; these are dumb
	local loc_bgn = "l:"
	local data_string = "" --formerly c: but not necessary anymore
	local this_col,this_loc --and that's when i realised loc/col are mirrored
	for k,v in ipairs(g_colors) do 
		this_col = LuaNetworking:ColourToString(v) --takes the current color from the table
		data_string = data_string .. this_col .. col_sep
	end
	data_string = data_string .. loc_bgn
	
	for k,v in ipairs(g_locations) do
		this_loc = v
		data_string = data_string .. this_loc .. loc_sep
	end
	--todo add idiot-proofing for malformed gradient tables
	log("NNL: New gradient string created, called [" .. data_string .. "]")
	return data_string
end

function Lasers:StringToGradientTable(gradient_string)
--given a formatted gradient-string and a criminal number, unpacks the gradient and writes it directly to the storage table
--does not return a value
	local gradient_data = {
		colors = {},
		locations = {}
	}

	local split_gradient = string.split( gradient_string, "l:")
--	log("NNL: total gradient_string is " .. gradient_string)
	local colors = string.split( split_gradient[1], "%$")
	local locations = string.split( split_gradient[2], "%^")
	
	for k,v in ipairs(colors) do
		--log("NNL: color " .. k .. " is " .. v)
		gradient_data.colors[k] = LuaNetworking:StringToColour(v)
--		Lasers.networked_gradients[peerid].colors[k] = LuaNetworking:StringToColour(v)
	end
	
	for k,v in ipairs(locations) do 
		log("NNL: location " .. k .. " is " .. v)
		gradient_data.locations[k] = LuaNetworking:StringToColour(v)
--		Lasers.networked_gradients[peerid].locations[k] = LuaNetworking:StringToColour(k)
	end
	return gradient_data
--	Lasers.networked_gradients[peerid].active = true
end
	

--[[
# # NEW: Custom laser gradients ##
* Below, in the table "my_gradient" you can set your own color-changing preset. Lasers are always rendered as a line of one color, not a "true" gradient,
however the color can shift over time.
* This system uses a system approximately equivalent to the 'color stops' system used by applications or programs such as 
CSS gradients, or Adobe Photoshop's gradients tool.
* However, the 'locations' measure duration of that color instead of physical length in a gradient. Experiment some for yourself.
****** Here's a brief guide to color stops: https://www.quirksmode.org/css/images/colorstops.html ******
* Although there's no upper limit to the number of colors you can have,
successive locations should always be greater than the last.
* For the sake of stability, I would suggest no more than 10 locations, though you can have as few as two (2). 
* You should also have exactly as many locations as you do colors.
* If you have an inequal amount of colors to lasers,
you may experience bugs or crashes.
* Colors should ideally include the alpha level 
by using "with_alpha" at the end of your color. 
* Ideally, your locations should be within 0-100, and may cause bugs if not obeying these guidelines.

# TL;DR:
* Set colors in R/G/B format like shown in "example_gradient."
* Set locations, or at what time the gradient displays after the previous one.
--]]
Lasers.my_gradient = Lasers.my_gradient or {
	colors = {
		[1] = Color(1,0,0):with_alpha(0.7),
		[2] = Color(0,1,0):with_alpha(0.7),
		[3] = Color(0,0,1):with_alpha(0.7)
	},
	locations = {
		[1] = 0,
		[2] = 33,
		[3] = 66
	}
	
} or Lasers.example_gradient

Lasers.DefaultTeamColors = Lasers.DefaultTeamColors or {
	[1] = Color("29ce31"):with_alpha(DefaultOpacity),--Color("00ffdd"),
	[2] = Color("00eae8"):with_alpha(DefaultOpacity),
	[3] = Color("f99d1c"):with_alpha(DefaultOpacity),
	[4] = Color("ebe818"):with_alpha(DefaultOpacity),
	[5] = Color("ffffff"):with_alpha(1)
}

--********************************************************************

function nnl_log (message)
	if Lasers.debugLogsEnabled then
		log(message)
	end
end

function Lasers:IsEnabled()
	--remnant of goonmod
	return true
end

function Lasers:IsRainbow()
	return false
end

function Lasers:GetPlayerLaserColor()
	Lasers:Load()
	return Color(Lasers.settings.own_red,Lasers.settings.own_green,Lasers.settings.own_blue):with_alpha(Lasers.settings.own_alpha) or Color(1,1,1):with_alpha(1)
end

function Lasers:GetTeamLaserColor()
	Lasers:Load()
	return Color(Lasers.settings.team_red,Lasers.settings.team_green,Lasers.settings.team_blue):with_alpha(Lasers.settings.team_alpha) or Color(1,1,1):with_alpha(1)
end

function Lasers:GetPeerColor(criminal_name)
	local id = managers.criminals:character_color_id_by_name( criminal_name )
	if id == 1 then id = id + 1 end
	local color = Lasers.DefaultTeamColors[ id or 5 ]:with_alpha(Lasers.DefaultTeamColors[ id or 5 ].alpha or Lasers.DefaultOpacity)
	color = color or Color(1,1,1):with_alpha(1)
	Lasers:SetColourOfLaser( laser, unit, t, dt, color )
	return
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

function Lasers:CheckWeaponForLasers( weapon_base, key )

	if weapon_base and weapon_base._factory_id and weapon_base._blueprint then

		local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", weapon_base._factory_id, weapon_base._blueprint)
		if gadgets then
			for _, i in ipairs(gadgets) do
				if not weapon_base._parts[i].unit then 
					nnl_log("NNL: No weapon part found for unit")
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
--		log("NNL: Is indeed npc")	
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
			nnl_log("NNL: criminal_name is " .. criminal_name)				
			if Lasers.dev_gradient then --Laser:IsTeamGradient() then --and Lasers.networked_gradients[1].criminal_name then 
				local color = Lasers.SavedTeamColors[criminal_name]
				if color then
					log("NNL: Found saved team color gradient.")
					Lasers:SetColourOfLaser( laser, unit, t, dt, color )
					return
				end
--				log("NNL: Did not find saved team color gradient.")
			end
			if Lasers:IsTeamUniform() then 
				color = Lasers:GetPeerColor(criminal_name) 
				return
					--above function directly sets laser color, bypassing the need for setcoloroflaser or return 
			elseif Lasers:IsTeamCustom() then 
				color = Lasers:GetTeamLaserColor()
			elseif Lasers:IsTeamDisabled() then 
				color = Color(0,0,0):with_alpha(0)
			else 
				nnl_log("NNL: Couldn't identify team laser type! How odd!")
				color = Color(1,0.6,0.8):with_alpha(1)
			end
			--else if disabled setcolouroflaser default
				Lasers:SetColourOfLaser( laser, unit, t, dt, color )
				--should be doing this with "or" operator and conditions
			return 
		end
	end

--	log("NNL: This peer's name is " .. LuaNetworking:GetNameFromPeerID(criminal_name))
	if LuaNetworking:GetNameFromPeerID( criminal_name ) == "Offyerrocker" then
		local override_color = GradientStep( t, Lasers.example_gradient, speed)
		Lasers:SetColourOfLaser( laser, unit, t, dt, override_color)
		nnl_log("NNL: Found Offy!")
		return
	elseif Lasers.dev_gradient then
		log("NNL: Doing Dev_Gradient")
			Lasers:SetColourOfLaser (laser, unit, t, dt, "gradient")
		return
--		Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )
	end
--	log("NNL: Doing nothing in updatelaser")
	Lasers:SetColourOfLaser( laser, unit, t, dt )

end

function SetGradientToLaser( laser, unit, t, dt, peer )
	override_color = GradientStep( t, Lasers.networked_gradients[peer], Lasers.default_gradient_speed )
-- retrieve and send gradient information from the table, and send it to the other function
	if not override_color then
		override_color = Color(0.8,0.5,0.7):with_alpha(0.8)
		nnl_log("NNL: Couldn't create gradient!")
	end
	Lasers.networked_gradients[peer].active = true --/!\
	log("NNL: Set peer active to true")
	
	if not laser then 
		return
	end
	laser:set_color( override_color )
end

function GradientStep( t, gradient_table, override_speed ) --uses a preset table instead of input specific values
	local smoothness = Lasers.update_interval or 0		--frequency of laser updates, calculated per frame. the lower, the better the laser looks. affects performance!
	local colors = gradient_table.colors
	local locations = gradient_table.locations
	local speed = override_speed or Lasers.default_gradient_speed or 1
	local _t = (t * speed) % 100 --by default, 100 for location values. todo: change by max location size
	local current_location
	local color_count
	nnl_log("NNL: _t /smoothness, _t = " .. math.floor(_t % smoothness) .. "|" .. _t)
	if smoothness == 0 or ( math.floor(_t) % smoothness) == 0 then --luckily lua doesn't fall for div_by_0 errors :^)
	
		for k,v in ipairs(colors) do 
			color_count = k
		end
		if color_count <= 1 then
			nnl_log("NNL: My custom gradient is improperly formatted/has incorrect # of colors or locations!")
			return Lasers.example_gradient
		end
		--get current location based on time
		for k,v in ipairs(locations) do
			--nnl_log("NNL: v = " .. v .. ", t = " .. _t .. ", k = " .. k)
			if v > _t then --if location value is higher than time
				break
			else --could be end instead of else
				current_location = k
			end
		end
		
		if not Lasers.lowquality_gradients then 

			local col_1 = colors[current_location] or Color(0,0,0):with_alpha(1)
			local col_2 
			local color_dur
			--nnl_log("NNL: current location = " .. current_location)
			if current_location >= color_count then 
				col_2 = colors[1]
				color_dur = math.abs( locations[current_location] - locations[1] )
			else
				col_2 = colors[current_location + 1]
				color_dur = math.abs( locations[current_location] - locations[current_location + 1] )
			end
				local _t2 = ( _t ) % color_dur
			--nnl_log("NNL: Color_dur = " .. color_dur)
			col_2 = col_2 or Color(1,1,1):with_alpha(1)
			
			local r_diff = col_2.red - col_1.red
			local g_diff = col_2.green - col_1.green
			local b_diff = col_2.blue - col_1.blue
			local a_diff = col_2.alpha - col_1.alpha		
			
			--nnl_log("NNL: color_dur ratio is " .. _t2 / color_dur )
			nu_red = col_1.red + ( (r_diff * _t2) / color_dur )
			nu_green = col_1.green + ( (g_diff * _t2) / color_dur )
			nu_blue = col_1.blue + ( (b_diff * _t2) / color_dur )
			nu_alpha = col_1.alpha + ( (a_diff * _t2) / color_dur )
			local override_color = Color(nu_red,nu_green,nu_blue):with_alpha(nu_alpha) or Color(1,1,1):with_alpha(1)
			Lasers.last_grad = override_color
			--nnl_log("NNL: Col_1 = " .. LuaNetworking:ColourToString(col_1) .. "|| Col_2 = " .. LuaNetworking:ColourToString(col_2) .. "|| New_col = " .. LuaNetworking:ColourToString(override_color))
			--nnl_log("NNL: R/G/B/A diff: r " .. r_diff .. " |g " .. g_diff .. " |b " .. b_diff .. " |a " .. a_diff )
		else 
			override_color = colors[current_location] --or Color(1,1,1):with_alpha(1)
		end
	end
--	log("NNL: grad color is " .. LuaNetworking:ColourToString(override_color or Lasers.last_grad))
	return override_color or Lasers.last_grad
end

function Lasers:SetColorOfLaser( laser, unit, t, dt, override_color )
	nnl_log("NNL: Well, well, well... looks like we got a bloody YANKEE here!")
	Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )
	return
end

function Lasers:SetColourOfLaser( laser, unit, t, dt, override_color )
	if not laser then 
		return
	end
	if override_color then
		if override_color == "gradient" then
			override_color = GradientStep( t, Lasers.my_gradient, 20)
			log("NNL: Did gradient override in setcolour.")
			laser:set_color( override_color )
			return
		elseif override_color == "rainbow" then
			log("NNL: Using rainbow color")
			override_color = Lasers:GradientStep(t, Lasers.rainbow, Lasers.default_gradient_speed)
			laser:set_color( override_color )
			return
		elseif type(override_color) == "table" then
			log("NNL: Writing color from table via Gradient_Step.")
			 new_color = Gradient_Step(t, override_color, 20)
			 laser:set_color( new_color )
		--[[
			new_gradient = Lasers:StringToGradientTable(override_color)
			new_color = GradientStep( t, new_gradient, 20 )
			laser:set_color( new_color ) 
			--]]
--			Lasers:StringToGradientTable(incoming_gradient_string)
		else
--			log("NNL: Using supplied override color with col ") --[" .. override_color .. "]") --LuaNetworking:ColourToString(override_color))
			override_color = override_color or Color(1,1,1):with_alpha(1)
			laser:set_color( override_color )

			--laser:set_color( Color(0,0,0):with_alpha(1))
			return
		end
--			laser:set_color_by_theme(override_color)
	elseif not Lasers:IsTeamGradient() then
		laser:set_color(Lasers:GetPlayerLaserColor()) --Lasers:GetColor( Lasers.DefaultOpacity ) )
--		log("NNL: No gradient? Using player color")
		return
	else
--		log("NNL: Not even team gradient? okay.")
		laser:set_color( override_color)
		--/!\ under construction! fix gradient here!
--		Lasers:GradientStep. calc gradients for team here??? i guess???
	--	laser:set_color( Lasers.Color:GetRainbowColor( t, Lasers:RainbowSpeed() ):with_alpha(Lasers.DefaultOpacity) )
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
--	^^reenable this code here 
		local my_gradient_string = Lasers:GradientTableToString(Lasers.my_gradient) or false
		log("NNL: Completed table to string conversion. Result: " .. my_gradient_string )
--	log("NNL: Completed string to table conversion. Result: " .. Lasers:StringToGradientTable(test_string) )
		if Lasers.settings.networked_lasers then
			if Lasers.dev_gradient and my_gradient_string then
				LuaNetworking:SendToPeersExcept( Lasers.legacy_clients, Lasers.LuaNetID, my_gradient_string )
			else
				LuaNetworking:SendToPeersExcept( Lasers.legacy_clients, Lasers.LuaNetID, col_str)
			end
			
			for k,v in pairs(Lasers.legacy_clients) do
				log("Sending legacy data to client: [" .. k .. "]")
				LuaNetworking:SendToPeer(k,Lasers.Lasers.LegacyID, col_str)
			end
		end
	end

end)

Hooks:Add("NetworkReceivedData", "NetworkReceivedData_", function(sender, message, data)
--	log("NNL: sender is " .. sender )
	if message == Lasers.LuaNetID or message == Lasers.LegacyID then
		log("NNL: Received data from sender.")
		local criminals_manager = managers.criminals
		if not criminals_manager then
			return
		end
		
		if message == Lasers.LegacyID and sender then 
			Lasers.legacy_clients[sender] = sender 
			log("NNL: Sender with peerid [" .. sender .. "] is running legacy Goonmod/Networked Lasers!")
		elseif message == Lasers.LuaNetID and sender then 
			Lasers.legacy_clients[sender] = nil
			log("NNL: Cleared peerid [" .. sender .. "] from legacy_clients list via Networked Lasers")
		end
		
		local char = criminals_manager:character_name_by_peer_id(sender)
		local col = data
		
		
		if string.find(data, "l:") then
			log("NNL: Successfully received and parsed data")
			col = Lasers:StringToGradientTable(data)
		elseif data ~= "gradient" then
			log("NNL: Did not find data.")
			col = LuaNetworking:StringToColour(data)
		end
--type(data) == "string" and 

		if char then
			Lasers.SavedTeamColors[char] = col
		end
	end

end)