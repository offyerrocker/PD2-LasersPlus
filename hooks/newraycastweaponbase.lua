local orig = Hooks:GetFunction(NewRaycastWeaponBase,"set_gadget_color")
Hooks:OverrideFunction(NewRaycastWeaponBase,"set_gadget_color",function(self,color,...)
	if not LasersPlus:IsEnabled() then
		return orig(self,color,...)
	end
	
	do return end
	
	if not self._enabled then
		return
	end

	if not self._assembly_complete then
		return
	end

	local gadgets = self._gadgets

	if gadgets then
		local gadget,gadget_base = nil,nil

		for i, id in ipairs(gadgets) do
			gadget = self._parts[id]

			gadget_base = gadget and alive(gadget.unit) and gadget.unit:base()
			if gadget_base and gadget_base.set_color then
				local alpha = gadget_base.GADGET_TYPE == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1

				gadget_base:set_color(color:with_alpha(alpha))
			end
		end
	end
	
	return orig(self,color,...)
end)

Hooks:PostHook(NewRaycastWeaponBase,"clbk_assembly_complete","lasersplus_onweaponassemblycomplete",function(self,clbk,parts,blueprint)
	self:set_gadget_lp_user_type(self._lp_unit_user_type)
	Print("clbk ssembly complete",self._lp_unit_user_type)
end)


-- custom func
function NewRaycastWeaponBase:set_lp_user_type(user_type)
	self._lp_unit_user_type = user_type
	if self._assembly_complete then
		self:set_gadget_lp_user_type(user_type)
		Print("Assembly complete",user_type)
	end
end

function NewRaycastWeaponBase:set_gadget_lp_user_type(user_type)
	Print("set_gadget_lp_user_type() start",user_type)
	if user_type then
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