Hooks:PostHook(UnitNetworkHandler, "set_weapon_gadget_color", "UnitNetworkHandler_setweapongadgetcolor_lasersplus", function(self,unit,red,green,blue,sender)
	if LasersPlus:IsLaserRedFilterEnabled() then
		if not self._verify_character_and_sender(unit, sender) then
			return
		end
		
		local data = {r=red,g=green,b=blue}
		LasersPlus:StorePeerColor(self._verify_sender(sender),data,"vanilla",unit)
		
--		unit:inventory():sync_weapon_gadget_color(Color(red / 255, green / 255, blue / 255))
	end
end)
