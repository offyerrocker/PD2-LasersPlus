Hooks:PostHook(WeaponGadgetBase,"init","lasersplus_gadget_init",function(self,unit)
	self._lp_data = self._lp_data or nil
	self._lp_strobe_t = self._lp_strobe_t or 0
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


-- custom func
function WeaponGadgetBase:get_lasersplus_type()
	return self._lp_user_type
end

