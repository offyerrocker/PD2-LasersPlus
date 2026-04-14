Hooks:PostHook(WeaponLaser,"init","lasersplus_laser_init",function(self,unit)
	Hooks:Add("OnLasersPlusSettingChanged_Laser",self._lp_key,function(template_data)
		if alive(self._light) then
			if template_data.color then
				if template_data.alpha then
					self:set_color(template_data.color:with_alpha(template_data.alpha))
				else
					self:set_color(template_data.color)
				end
			end
		end
	end)
end)

Hooks:PreHook(WeaponLaser,"destroy","lasersplus_gadget_destroy",function(self,unit)
	if self._lp_key then
		Hooks:Remove("OnLasersPlusSettingChanged_Laser",self._lp_key)
	end
end)

function WeaponLaser:set_lasersplus_type(user_type,...)
	WeaponLaser.super.set_lasersplus_type(self,user_type,...)
	
--	local user_type = self._lp_user_type
	
	local template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
--	if LasersPlus:IsUserTypeEnabled("laser",self._lp_user_type) then
	if template_data and template_data.mode ~= 1 then
		if template_data.color then 
			self:set_color(template_data.color)
		end
		--[[
		self._lp_data = {
			index = 0, -- current strobe frame
			speed = 2,
			settings = template_data
		}
		--]]
	else
		self._lp_data = nil
	end
end

Hooks:PostHook(WeaponLaser,"update","lasersplus_laser_update",LasersPlus.UpdateGadget)
