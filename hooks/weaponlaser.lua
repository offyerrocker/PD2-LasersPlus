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


Hooks:PreHook(WeaponLaser,"update","lasersplus_laser_update",function (...) LasersPlus.UpdateGadget(...) end)
--Hooks:PreHook(WeaponLaser,"update","lasersplus_laser_update",LasersPlus.UpdateGadget)
