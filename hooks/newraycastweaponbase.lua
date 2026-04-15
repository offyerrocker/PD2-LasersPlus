--[[
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
--]]

Hooks:PostHook(NewRaycastWeaponBase,"clbk_assembly_complete","lasersplus_onweaponassemblycomplete",function(self,clbk,parts,blueprint)
	self:set_gadget_lp_user_type(self._lp_unit_user_type)
--	Print("clbk ssembly complete",self._lp_unit_user_type)
end)

