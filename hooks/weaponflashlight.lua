-- todo figure out alpha glow treatment
Hooks:PostHook(WeaponFlashlight,"init","lasersplus_flashlight_init",function(self,unit)
	Hooks:Add("OnLasersPlusSettingChanged_Flashlight",self._lp_key,function(template_data)
		if alive(self._light) then 
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
			
		end
		-- self._light:set_multiplier(self._current_light_multiplier)
	end)
end)

Hooks:PreHook(WeaponFlashlight,"destroy","lasersplus_gadget_destroy",function(self,unit)
	if self._lp_key then
		Hooks:Remove("OnLasersPlusSettingChanged_Flashlight",self._lp_key)
	end
end)

Hooks:PostHook(WeaponFlashLight,"update","lasersplus_flashlight_update",function(self,unit,t,dt)
	local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
	if color then 
		self:set_color(color)
	end
end)




--[[
Hooks:PostHook(WeaponFlashLight,"update","lasersplus_flashlight_update",function(self,unit,t,dt)
	local user_type = self._lp_user_type
	if user_type then
		local strobe = false
		if user_type == "user" then
			if LasersPlus:GetUserDisplayMode() < 3 then
				return
			end
			strobe = LasersPlus:GetUserLaserStrobeEnabled()
		elseif user_type == "team" then
			if LasersPlus:GetTeamDisplayMode() < 3 then
				return
			end
			strobe = LasersPlus:GetTeamLaserStrobeEnabled()
		elseif user_type == "enemy" then
			if LasersPlus:GetEnemyDisplayMode() < 3 then
				return
			end
			strobe = LasersPlus:GetEnemyLaserStrobeEnabled()
		end
		
		if strobe then
			-- update strobe
		end
	end
end)
--]]