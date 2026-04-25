if RequiredScript == "lib/units/weapons/weapongadgetbase" then
	
	Hooks:PostHook(WeaponGadgetBase,"init","lasersplus_gadget_init",function(self,unit)
		self._lp_data = self._lp_data or nil
		self._lp_user_type = self._lp_user_type or nil
		self._lp_key = self._lp_key or "lp_listener_gadget_" .. string.match(tostring(self),"0.*")
	end)

	-- custom func
	-- set the type of unit using this gadget (player, teammate heister, or sniper);
	-- world does not use gadgets at all, so that is handled elsewhere 
	-- sentries do, but they have their user_type set externally from the sentry weapon base,
	-- according to the state/theme of the sentry
	function WeaponGadgetBase:set_lasersplus_type(user_type,peer_id)

		if user_type ~= self._lp_user_type and self.GADGET_TYPE then
			if self._lp_listener_hook_id then 
				Hooks:Remove(self._lp_listener_hook_id,self._lp_key)
			end
			self._lp_listener_hook_id = "OnLasersPlusSettingChanged_" .. user_type .. "_" .. tostring(self.GADGET_TYPE)
		end
		
		self:_set_lasersplus_type(user_type)
		
		if peer_id and user_type == "team" then 
			self:set_lasersplus_peerid(peer_id)
		end
	end

	function WeaponGadgetBase:_set_lasersplus_type(user_type)
		self._lp_user_type = user_type
	end
	
	function WeaponGadgetBase:set_lasersplus_peerid(peer_id)
		self._lp_peerid = peer_id
	end
	

	function WeaponGadgetBase:setup_lp_strobe_data(template_data)
		local strobe_count = 0
		local init_color = template_data.color
		if template_data.strobe_data then
			local frames = template_data.strobe_data.colors
			-- assume that there are at least two frames;
			-- this is also checked on strobe unpacking in LasersPlus:StringToStrobe()
			init_color = frames[1].color
			strobe_count = #frames
		end
		self._lp_data = {
			settings = template_data,
			t = 0,
			next_frame_t = 0,
			index = 0,
			speed = 1,
			strobe_count = strobe_count,
			prev_color = init_color
		}
	end

	-- custom func
	function WeaponGadgetBase:get_lasersplus_type()
		return self._lp_user_type
	end

	Hooks:PreHook(WeaponGadgetBase,"destroy","lasersplus_gadget_destroy",function(self,unit)
		if self._lp_listener_hook_id and self._lp_key then
			Hooks:Remove(self._lp_listener_hook_id,self._lp_key)
			self._lp_listener_hook_id = nil
		end
	end)

elseif RequiredScript == "lib/units/weapons/weaponlaser" then
	if LasersPlus.settings.feature_enabled_laser_override then
		local mvec1 = Vector3()
		local mvec2 = Vector3()
		local mvec_l_dir = Vector3() -- that's the lowercase letter "L", not a 1. ask me how i know. hint: it rhymes with "schmaccess schmiolation" 
		Hooks:OverrideFunction(WeaponLaser,"update",function(self,unit,t,dt)
					
			local beam_width = self._is_npc and 0.5 or 0.25
			local light_glow_mul = 0.1
			local light_mul = 1
			local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,self._lp_user_type)
			-- apply regardless of display mode setting
			if template_data then
			--if template_data.mode ~= 1 then
				beam_width = template_data.radius or beam_width
				--light_glow_mul = template_data.dot_intensity
				--light_mul = template_data.beam_intensity
			end
			
			if self._lp_data then
				local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
				if color then 
					self:set_color(color)
				end
			end
			
			local ray_distance -- used to calculate how large and how intense to draw the light dot
			local has_ray -- determines whether to draw light dot on a raycasted surface
			
			-- set the beam's drawn starter position and angle (vanilla code)
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
			
			-- get the modded final position
			local use_accurate_laser = LasersPlus.settings.feature_enabled_laser_accurate
			if use_accurate_laser and self._lp_user_type == "user" then
				
				local player = managers.player:local_player()
				local mov_ext = alive(player) and player:movement()
				local state = mov_ext and mov_ext:current_state()
				if state then
					local fwd_ray = state._fwd_ray
					if fwd_ray then
						-- indicate that we already have a ray,
						-- so no need to cast another
						has_ray = true
					
						-- final ray position
						mvector3.set(to,fwd_ray.position)
						
						-- set the new beam direction (from gadget position to fwd_ray position)
						mvector3.set(mvec_l_dir, to)
						mvector3.subtract(mvec_l_dir, from)
						mvector3.normalize(mvec_l_dir)
						
						-- cheat the math a little bit for performance reasons
						-- by using the distance of the actual ray,
						-- instead of the distance of the visual ray
						-- (sqrt operations? in THIS economy??)
						ray_distance = fwd_ray.distance
					else
						-- skip trying to raycast
						has_ray = false
						
						-- nothing for the ray to hit,
						-- so just find the max position to draw the light at
						-- (not that it matters since it won't be visible)
						mvector3.set(mvec_l_dir,state._cam_fwd or state:get_fire_weapon_direction())
						mvector3.set(to, mvec_l_dir)
						mvector3.multiply(to, self._max_distance)
						mvector3.add(to, mov_ext:m_head_pos() or state:get_fire_weapon_position())
					end
					
					--[[
					-- (not working) attempt to align laser dot to accurate screen position
					if has_ray then 
						local obj_rot = obj:rotation()
						--tmp_vec = tmp_vec + obj_rotation():z()
						local obj = self._laser_obj
						rot = Rotation(rot:yaw() + obj_rot:z(),rot:pitch() - obj_rot:pitch(),rot:roll() + obj_rot:roll())
						
						local rot = mov_ext:m_head_rot()
						--local rot = Rotation()
						--local tmp_vec = to - from
						--mrotation.set_look_at(rot,tmp_vec,math.UP)
						self._light:set_rotation(rot)
						self._light_glow:set_rotation(rot)
					end
					--]]
					
				end
			end
			
			-- equivalent to vanilla ray method
			if has_ray == nil then
				
				mvector3.set(to, mvec_l_dir)
				mvector3.multiply(to, self._max_distance)
				mvector3.add(to, from)
				
				local ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask, self._ray_ignore_units and "ignore_unit" or nil, self._ray_ignore_units)
				
				if ray then
					has_ray = true
					
					ray_distance = ray.distance
					mvector3.set(to,ray.position)
				end
			end
			
			if has_ray then
				-- successful ray collision;
				-- draw the lights at their collided end positions
				if not self._is_npc then
					self._light:set_spot_angle_end(self._spot_angle_end)

					self._spot_angle_end = math.lerp(1, 18, ray_distance / self._max_distance)

					self._light_glow:set_spot_angle_end(math.lerp(8, 80, ray_distance / self._max_distance))

					local scale = (math.clamp(ray_distance, self._max_distance - self._scale_distance, self._max_distance) - (self._max_distance - self._scale_distance)) / self._scale_distance
					scale = 1 - scale

					self._light:set_multiplier(scale * light_mul)
					self._light_glow:set_multiplier(scale * light_glow_mul)
				end
				
				self._brush:cylinder(from, to, beam_width)
				
				local pos = mvec1
				
				mvector3.set(pos, mvec_l_dir)
				mvector3.multiply(pos, 50)
				mvector3.negate(pos)
				mvector3.add(pos, to)
				
				self._light:set_final_position(pos)
				self._light_glow:set_final_position(pos)
			else
				-- no ray;
				-- draw the lights at their max end distance or whatever
				self._light:set_final_position(to)
				self._light_glow:set_final_position(to)
				self._brush:cylinder(from, to, beam_width)
			end
		end)
	else
		Hooks:PreHook(WeaponLaser,"update","lasersplus_laser_update",function(self,unit,t,dt)
			if self._lp_data then
				local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
				if color then 
					self:set_color(color)
				end
			end
		end)
	end

	function WeaponLaser:set_lasersplus_type(user_type,...)
		WeaponLaser.super.set_lasersplus_type(self,user_type,...)
		local function f_setup(template_data,_user_type,peer_id)
			if (_user_type == true or _user_type == self._lp_user_type) and (_user_type ~= "team" or self._is_npc or peer_id == true or peer_id == self._lp_peerid) then
				if alive(self._light) then
					if template_data and template_data.mode ~= 1 then
						local color
						if self._lp_peerid and template_data.mode == 3 then
							color = LasersPlus:GetPeerColor(self._lp_peerid)
						else
							color = template_data.color
						end
						
						if color then
							if template_data.alpha then
								self:set_color(color:with_alpha(template_data.alpha))
							else
								self:set_color(color)
							end
						end
						
						self:setup_lp_strobe_data(template_data)
					else
						self._lp_data = nil
					end
				end
			end
		end
		if self._lp_listener_hook_id then 
			Hooks:Add(self._lp_listener_hook_id,self._lp_key,f_setup)
		end
		local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
		f_setup(template_data,true,true)
	end
	
elseif RequiredScript == "lib/units/weapons/weaponflashlight" then
	
	Hooks:PostHook(WeaponFlashLight,"update","lasersplus_flashlight_update",function(self,unit,t,dt)
		if self._lp_data then
			local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
			if color then 
				self:set_color(color)
			end
		end
	end)

	function WeaponFlashLight:set_lasersplus_type(user_type,...)
		WeaponFlashLight.super.set_lasersplus_type(self,user_type,...)
		local function f_setup(template_data,_user_type,peer_id)
			if (_user_type == true or _user_type == self._lp_user_type) and (_user_type ~= "team" or self._is_npc or peer_id == true or peer_id == self._lp_peerid) then
				if alive(self._light) then
					if template_data and template_data.mode ~= 1 then
						
						if template_data.angle then 
							self._light:set_spot_angle_end(template_data.angle)
						end
						if template_data.range then
							self._light:set_far_range(template_data.range * 100)
						end
						
						if template_data.color then 
							self:set_color(template_data.color)
						elseif template_data.alpha and LasersPlus.settings.feature_enabled_flashlight_override then
							-- apply opacity change by setting the color
							self:set_color(self._light:color())
						end
						
						-- self._light:set_multiplier(self._current_light_multiplier)
						self:setup_lp_strobe_data(template_data)
					else
						self._lp_data = nil
					end
				end
			end
		end
		
		Hooks:Add(self._lp_listener_hook_id,self._lp_key,f_setup)
		local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
		f_setup(template_data,true,true)
	end
	
	if LasersPlus.settings.feature_enabled_flashlight_override then 
		-- override allow setting the glow effect opacity
		-- (aka fake volumetric light fog)
		Hooks:OverrideFunction(WeaponFlashLight,"set_color",function(self,color)
			if self:is_haunted() then
				return
			end

			if not color then
				return
			end

			local opacity_ids = Idstring("opacity")
			local col_vec = Vector3(color.r, color.g, color.b)

			self._light:set_color(col_vec)

			local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,self._lp_user_type)
			
			if self._is_npc then
				local glow_alpha = template_data and template_data.alpha or WeaponFlashLight.NPC_GLOW_OPACITY_MAX
				local cone_alpha = template_data and template_data.alpha or WeaponFlashLight.NPC_CONE_OPACITY_MAX
				
				
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera r"), opacity_ids, opacity_ids, color.r * glow_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera g"), opacity_ids, opacity_ids, color.g * glow_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera b"), opacity_ids, opacity_ids, color.b * glow_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone r"), opacity_ids, opacity_ids, color.r * cone_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone g"), opacity_ids, opacity_ids, color.g * cone_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone b"), opacity_ids, opacity_ids, color.b * cone_alpha)
			else
				local glow_alpha = template_data and template_data.alpha or WeaponFlashLight.EFFECT_OPACITY_MAX
				
				local r_ids = Idstring("red")
				local g_ids = Idstring("green")
				local b_ids = Idstring("blue")

				World:effect_manager():set_simulator_var_float(self._light_effect, r_ids, r_ids, opacity_ids, color.r * glow_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, g_ids, g_ids, opacity_ids, color.g * glow_alpha)
				World:effect_manager():set_simulator_var_float(self._light_effect, b_ids, b_ids, opacity_ids, color.b * glow_alpha)
			end
		end)
	end
	
end





