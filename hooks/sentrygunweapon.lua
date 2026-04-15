--[[
Hooks:PostHook(SentryGunWeapon,"_set_laser_state","LasersPlus_SentryGunWeapon_set_laser_state",function(self,state)
	local laser_unit = self._laser_unit
	local gadget_base = alive(laser_unit) and laser_unit:base()
	if gadget_base then 
		gadget_base:set_lasersplus_type(nil)
	end
end)
--]]

--[[
local orig = Hooks:GetFunction(SentryGunWeapon,"update")
Hooks:OverrideFunction(SentryGunWeapon,"update",function(self,unit,t,dt,...)
	if self._lp_data then
		
	else
		return orig(self,unit,t,dt,...)
	end
end)
--]]


--[[
Hooks:PreHook(SentryGunWeapon,"destroy","lasersplus_sentryweapon_destroy",function(self,unit)
	gadget_base:set_lasersplus_type(nil)
end)
--]]

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