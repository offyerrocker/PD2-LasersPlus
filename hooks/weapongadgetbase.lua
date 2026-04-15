if RequiredScript == "lib/units/weapons/weapongadgetbase" then
	
	Hooks:PostHook(WeaponGadgetBase,"init","lasersplus_gadget_init",function(self,unit)
		self._lp_data = self._lp_data or nil
		self._lp_user_type = self._lp_user_type or nil
		self._lp_key = self._lp_key or "lp_listener_gadget_" .. string.match(tostring(self),"0.*")
	end)

	-- custom func
	-- set the type of unit using this gadget (player, teammate heister, or sniper);
	-- other types (sentry and world) do not use gadgets at all, so that is handled elsewhere 
	function WeaponGadgetBase:set_lasersplus_type(user_type)
		self:_set_lasersplus_type(user_type)
	--	self._lp_strobe = LasersPlus:GetStrobeData(user_type)
	end

	function WeaponGadgetBase:_set_lasersplus_type(user_type)
		self._lp_user_type = user_type
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

elseif RequiredScript == "lib/units/weapons/weaponlaser" then
	
	Hooks:PreHook(WeaponLaser,"destroy","lasersplus_gadget_destroy",function(self,unit)
		if self._lp_key then
			Hooks:Remove("OnLasersPlusSettingChanged_Laser",self._lp_key)
		end
	end)

	Hooks:PreHook(WeaponLaser,"update","lasersplus_laser_update",function(self,unit,t,dt)
		if self._lp_data then
			local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
			if color then 
				self:set_color(color)
			end
		end
	end)

	function WeaponLaser:set_lasersplus_type(user_type,...)
		WeaponLaser.super.set_lasersplus_type(self,user_type,...)
		local function f_setup(template_data)
			if alive(self._light) then
				if template_data and template_data.mode ~= 1 then
					if template_data.color then
						if template_data.alpha then
							self:set_color(template_data.color:with_alpha(template_data.alpha))
						else
							self:set_color(template_data.color)
						end
					end
					
					self:setup_lp_strobe_data(template_data)
				else
					self._lp_data = nil
				end
			end
		end
		
		Hooks:Add("OnLasersPlusSettingChanged_Laser",self._lp_key,f_setup)
		local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
		f_setup(template_data)
	end
	
elseif RequiredScript == "lib/units/weapons/weaponflashlight" then
	
	Hooks:PreHook(WeaponFlashlight,"destroy","lasersplus_gadget_destroy",function(self,unit)
		if self._lp_key then
			Hooks:Remove("OnLasersPlusSettingChanged_Flashlight",self._lp_key)
		end
	end)

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
		local function f_setup(template_data)
			if alive(self._light) then
				if template_data and template_data.mode ~= 1 then
			
					if template_data.glow_alpha then
						--self._lp_glow_alpha = template_data.glow_alpha
					end
					
					if template_data.angle then 
						self._light:set_spot_angle_end(template_data.angle)
					end
					if template_data.range then
						self._light:set_far_range(template_data.range)
					end
					
					if template_data.color and template_data.light_alpha then 
						self:set_color(template_data.color:with_alpha(template_data.light_alpha))
					else
						self:set_color(template_data.color)
					end
					
					-- self._light:set_multiplier(self._current_light_multiplier)
					self:setup_lp_strobe_data(template_data)
				else
					self._lp_data = nil
				end
			end
		end
		
		Hooks:Add("OnLasersPlusSettingChanged_Flashlight",self._lp_key,f_setup)
		local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
		f_setup(template_data)
	end

end





