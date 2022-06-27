

local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec_l_dir = Vector3()

local orig_weaponlaser_update = WeaponLaser.update
function WeaponLaser:update(unit,t,dt,...)
	local gadget_data = LasersPlus:GetGadgetData("laser",self._unit)
	
	if not gadget_data then 
		return orig_weaponlaser_update(self,unit,t,dt,...)
	end
	
	local beam_thickness = self._is_npc and 0.5 or 0.25
	local alpha
	if gadget_data.source == "own" then 
		--TODO grab these from gadget table
		if LasersPlus.settings.own_laser_thickness_mode == 2 then
			beam_thickness = LasersPlus.settings.own_laser_thickness_value or beam_thickness
		end
		if LasersPlus.setting.own_laser_alpha_mode == 2 then 
			alpha = LasersPlus.settings.own_laser_alpha_value
		else
			alpha = gadget_data.natural_alpha
		end
	elseif gadget_data.source == "team" then 
		if LasersPlus.settings.team_laser_thickness_mode == 2 then
			beam_thickness = LasersPlus.settings.team_laser_thickness_value or beam_thickness
		end
		if LasersPlus.setting.team_laser_alpha_mode == 2 then 
			alpha = LasersPlus.settings.team_laser_alpha_value
		else
			alpha = gadget_data.natural_alpha
		end
	elseif gadget_data.source == "sentrygun" then 
		if LasersPlus.settings.sentrygun_laser_thickness_mode == 2 then
			beam_thickness = LasersPlus.settings.sentrygun_laser_thickness_value or beam_thickness
		end
		if LasersPlus.setting.sentrygun_laser_alpha_mode == 2 then 
			alpha = LasersPlus.settings.sentrygun_laser_alpha_value
		else
			alpha = gadget_data.natural_alpha
		end
	elseif gadget_data.source == "swatturret" then 
		if LasersPlus.settings.swatturret_laser_thickness_mode == 2 then
			beam_thickness = LasersPlus.settings.swatturret_laser_thickness_value or beam_thickness
		end
		if LasersPlus.setting.swatturret_laser_alpha_mode == 2 then 
			alpha = LasersPlus.settings.swatturret_laser_alpha_value
		else
			alpha = gadget_data.natural_alpha
		end
	end
	
	if gadget_data.strobe_table then
		
		local strobe_index = gadget_data.strobe_index or 1
		strobe_index = strobe_index + 1 -- + dt
		if strobe_index > #gadget_data.strobe_table then 
			strobe_index = 1
		end
		gadget_data.strobe_index = strobe_index
		local new_color = gadget_data.strobe_table[strobe_index] --math.floor this index if using time-based strobes
		if new_color then 
			
			self._light:set_color(new_color)
			
			if alpha then 
				new_color = new_color:with_alpha(alpha)
			end
			self._brush:set_color(new_color)
			
--			Console:SetTrackerValue("trackera",tostring(strobe_index))
--			Console:SetTrackerColor("trackera",new_color)
--		else
--			LasersPlus:log("No color for index " .. tostring(strobe_index))
		end
	end 
	
	local rotation = self._custom_rotation or self._laser_obj:rotation()

	mrotation.y(rotation, mvec_l_dir)

	local from = mvec1

	if self._custom_position then
		mvector3.set(from, self._laser_obj:local_position())
		mvector3.rotate_with(from, rotation)
		mvector3.add(from, self._custom_position)
	else
		mvector3.set(from, self._laser_obj:position())
	end

	local to = mvec2

	mvector3.set(to, mvec_l_dir)
	mvector3.multiply(to, self._max_distance)
	mvector3.add(to, from)

	local ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask, self._ray_ignore_units and "ignore_unit" or nil, self._ray_ignore_units)
	if ray then
		if not self._is_npc then
			self._light:set_spot_angle_end(self._spot_angle_end)

			self._spot_angle_end = math.lerp(1, 18, ray.distance / self._max_distance)

			self._light_glow:set_spot_angle_end(math.lerp(8, 80, ray.distance / self._max_distance))

			local scale = (math.clamp(ray.distance, self._max_distance - self._scale_distance, self._max_distance) - (self._max_distance - self._scale_distance)) / self._scale_distance
			scale = 1 - scale

			self._light:set_multiplier(scale)
			self._light_glow:set_multiplier(scale * 0.1)
		end

		self._brush:cylinder(ray.position, from, beam_thickness)

		local pos = mvec1

		mvector3.set(pos, mvec_l_dir)
		mvector3.multiply(pos, 50)
		mvector3.negate(pos)
		mvector3.add(pos, ray.position)
		self._light:set_final_position(pos)
		self._light_glow:set_final_position(pos)
	else
		self._light:set_final_position(to)
		self._light_glow:set_final_position(to)
		self._brush:cylinder(from, to, beam_thickness)
	end

	self._custom_position = nil
	self._custom_rotation = nil
end


do return end

Hooks:PostHook(WeaponLaser,"init","WeaponLaserInit_lasersplus",function(self,unit)
--	LasersPlus:RegisterLaser(unit,"generic",{})
	log(">>>>WeaponLaser init")
	log(tostring(unit))
--	log(debug.traceback())
	log("<<<<WeaponLaser init")
end)


Hooks:PostHook(WeaponLaser,"set_color","WeaponLaserSetColor_lasersplus",function(self,color)
--	LasersPlus:RegisterLaser(unit,"generic",{})
	log(">>>>WeaponLaser set_color " .. tostring(ColorPicker.color_to_hex(color)))
	log(tostring(self._unit))
--	log(debug.traceback())
	log("<<<<WeaponLaser set_color ")
end)



--[[

--if true, makes sniper/npc lasers affected by this change
local AFFECT_NPC = false
--(does not affect world lasers like vault lasers)



Hooks:PostHook(WeaponLaser,"init","blacklaserblacklaserblacklaser",function(self,unit)
	self._brush = Draw:brush(self._themes[self._theme_type].brush)
	--exclude "VertexColor" as an argument to the constructor to overwrite "opacity_add" as the blend mode
end)

if not AFFECT_NPC then 
	Hooks:PostHook(WeaponLaser,"set_npc","noblacklasernoblacklaser",function(self)
		--recreate the brush as normal
		self._brush = Draw:brush(self._themes[self._theme_type].brush, "VertexColor")
	end)
end

--]]