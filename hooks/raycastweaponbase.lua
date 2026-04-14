
-- custom func
function RaycastWeaponBase:set_lp_user_type(user_type)
	self._lp_unit_user_type = user_type
	if self._assembly_complete then
		self:set_gadget_lp_user_type(user_type)
		--Print("Assembly complete",user_type)
	end
end

function RaycastWeaponBase:set_gadget_lp_user_type(user_type)
--	Print("set_gadget_lp_user_type() start",user_type)
	if user_type and self._parts then
--		Print("set_gadget_lp_user_type() user type exists",user_type)
		for i,part_data in pairs(self._parts) do 
			local gadget_unit = part_data.unit
			local gadget_base = gadget_unit and alive(gadget_unit) and gadget_unit:base()
			local gadget_type = gadget_base and gadget_base.GADGET_TYPE
--			Print("set_gadget_lp_user_type() loop",i,user_type,gadget_unit,gadget_base,gadget_type)
			if gadget_type == "flashlight" or gadget_type == "laser" then
--				Print("set_gadget_lp_user_type()",user_type,i)
				gadget_base:set_lasersplus_type(user_type)
			end
		end
	end
end