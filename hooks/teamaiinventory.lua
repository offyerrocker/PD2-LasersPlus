Hooks:PostHook(TeamAIInventory,"init","lasersplus_on_teammaiinventory_init",function(self, unit)
	self._lp_unit_type = "team"
end)


--[[
Hooks:PostHook(TeamAIInventory,"add_unit","lasersplus_on_teamai_add_weapon",function(self, new_unit, equip)
	local weap_base = alive(new_unit) and new_unit:base()
	if weap_base then
		for i,part_data in pairs(weap_base._parts) do 
			local gadget_unit = part_data.unit
			local gadget_base = gadget_unit and alive(gadget_unit) and gadget_unit:base()
			local gadget_type = gadget_base and gadget_unit.GADGET_TYPE
			if gadget_type == "flashlight" or gadget_type == "laser" then
				gadget_base:set_lasersplus_type("team")
			end
		end
	end
end)
-- TeamAIInventory inherits from CopInventory so unfortunately it run the hook twice and be slightly inefficient
--]]