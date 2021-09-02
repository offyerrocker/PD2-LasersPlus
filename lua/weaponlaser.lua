
Hooks:PostHook(WeaponLaser,"init","lasersplus_weaponlaserinit",function(self,unit)
	local u_key_str = tostring(unit:key())
	local user_type,user_peer_id = LasersPlus.GetUserTypeFromUnit(unit)
	Log(user_type)
	Log(user_peer_id)
	self._lp_gadget_type = "laser"
	self._lp_gadget_params = {
		color = "000800",
		thickness = 0.25,
		alpha = 0.4,
		display_mode = 2
	}
	self._lp_user_type = "npc"
	
	if user_type == "own" then 
		self._lp_user_type = user_type
		self._lp_peer_id = user_peer_id
		self._lp_gadget_params = LasersPlus:GetOwnLaserParams()
	elseif user_type == "team" then 
		self._lp_user_type = user_type
		self._lp_peer_id = user_peer_id
		self._lp_gadget_params = LasersPlus:GetTeamLaserParams()
		if self._lp_gadget_params.display_mode == 4 then 
			local peer_color = LasersPlus:GetPeerColor(user_peer_id)
			if peer_color then 
				self._light:set_color(peer_color)
			end
		end
	end
	
	if self._lp_gadget_params.display_mode == 3 then 
		self._light:set_color(Color(self._lp_gadget_params.color))
		self._light_glow:set_color(Color(self._lp_gadget_params.color))
	end
	
	Hooks:Add("LasersPlus_OnSettingsChanged","LasersPlus_OnSettingsChangedListener_" .. u_key_str,function(gadget_type,user_type,setting,value)
		if gadget_type == self._lp_gadget_type then 
			if user_type == self._lp_user_type then 
				self._lp_gadget_params[setting] = value
			end
		end
	end)
	

end)

Hooks:PostHook(WeaponLaser,"update","lasersplus_weaponlaserupdate",function(self,unit)
	
end)

Hooks:PostHook(WeaponLaser,"set_npc","lasersplus_weaponlasersetnpc",function(self)
	--check laser
	
end)

Hooks:PostHook(WeaponLaser,"set_color_by_theme","lasersplus_weaponlasersetcolorbytheme",function(self,theme)

end)

Hooks:Register("WeaponLaser_check_state")
local orig_check_state = WeaponLaser._check_state
function WeaponLaser:_check_state(current_state,...)
	current_state = current_state and self._lp_gadget_params.display_mode ~= LasersPlus.DISPLAY_MODES.DISABLED
	return orig_check_state(self,current_state,...)
end
Hooks:PostHook(WeaponLaser,"_check_state","lasersplus_weaponlasercheckstate",function(self)
	
end)

Hooks:PreHook(WeaponLaser,"destroy","lasersplus_weaponlaserdestroy",function(self)
	local u_key = self._unit:key()
	local u_key_str = tostring(u_key)
	Hooks:Remove("LasersPlus_OnSettingsChangedListener_" .. u_key_str)
	LasersPlus._laser_units_lookup[u_key] = nil
end)