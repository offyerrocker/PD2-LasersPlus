Hooks:PostHook(SentryGunWeapon,"set_laser_enabled","lasersplus_sentryweapon_setenabled",function(self,mode,blink)
	local laser_unit = self._laser_unit
	local gadget_base = alive(laser_unit) and laser_unit:base()
	if gadget_base then 
		if mode then 
			local user_type = LasersPlus:GetUserTypeByTheme(mode)
			gadget_base:set_lasersplus_type(user_type)
		else
			gadget_base:set_lasersplus_type(nil)
		end
	end
end)