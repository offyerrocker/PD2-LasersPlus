
Hooks:PostHook(SentryGunWeapon, "init", "LasersPlus_SentryGunWeapon_init_1", function(self, unit)
    self._laser_align = self._laser_align or self._unit:get_object(Idstring("fire"))
end)

Hooks:PostHook(SentryGunWeapon, "_init", "LasersPlus_SentryGunWeapon_init_2", function(self, unit)
    self._laser_align = self._laser_align or self._unit:get_object(Idstring("fire"))
end)

Hooks:PreHook(SentryGunWeapon,"_set_laser_state","LasersPlus_SentryGunWeapon_set_laser_state",function(self,state)
	if not state then 
		if alive(self._laser_unit) then 
			LasersPlus:UnregisterGadget("laser",self._laser_unit)
		end
	end
end)

Hooks:PostHook(SentryGunWeapon,"_set_laser_state","LasersPlus_SentryGunWeapon_set_laser_state",function(self,state)
	if state then 
		if alive(self._laser_unit) then 
			
			local source = "swatturret"
			local peer_id,is_ai
			local natural_color = WeaponLaser._themes.turret_module_active.brush
			local natural_alpha = natural_color.a or 0.15
			
			
			if self._owner then 
				source,peer_id,is_ai = LasersPlus:GetUserUnitData(self._owner)
				if source == "own" then 
					source = "sentrygun"
					natural_color = Color(0,0,0):with_alpha(0)
					natural_alpha = 0
				elseif peer_id then 
					source = "sentrygun"
					natural_color = Color(0,0,0):with_alpha(0)
					natural_alpha = 0
				end
			end
			
			LasersPlus:RegisterGadget("laser",self._laser_unit,{
				source = source,
				is_ai = is_ai,
				natural_color = natural_color,
				natural_alpha = natural_alpha,
				parent_unit = self._unit,
				peer_id = peer_id
			})
		end
	end
end)
