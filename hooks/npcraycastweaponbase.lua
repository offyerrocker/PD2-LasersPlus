Hooks:PostHook(NPCRaycastWeaponBase,"set_laser_enabled","lasersplus_on_npcweapon_set_laser",function(self, unit)
	if alive(self._laser_unit) then
		local gadget_base = self._laser_unit:base()
		if gadget_base and gadget_base.set_lasersplus_type then
--			Print("NPC Set laser enabled",self._lp_unit_user_type,self._unit)
			local gadget_type = gadget_base and gadget_base.GADGET_TYPE
--			Print("set_gadget_lp_user_type() loop",i,user_type,gadget_unit,gadget_base,gadget_type)
			if gadget_type == "flashlight" or gadget_type == "laser" then
--				Print("set_gadget_lp_user_type()",user_type,i)
				gadget_base:set_lasersplus_type(self._lp_unit_user_type)
			end
		end
	end
end)
