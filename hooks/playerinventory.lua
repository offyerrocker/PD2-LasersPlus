-- PlayerInventory is the parent class for teammate ai, human teammates, and enemies,
-- in addition to being the class for players,
-- so this should cover all of those bases


-- the above cases all have their own init hooks setting their lp unit type separately,
-- but otherwise behave largely the same
Hooks:PostHook(PlayerInventory,"init","lasersplus_on_playerinventory_init",function(self, unit)
	self._lp_unit_type = "user"
end)

Hooks:PostHook(PlayerInventory,"add_unit","lasersplus_on_invext_add_weapon",function(self, new_unit, equip)
	local weap_base = alive(new_unit) and new_unit:base()
	if weap_base and weap_base.set_lp_user_type then
		-- have to let the info propagate naturally as the load process progresses
		Print("Add unit!",self._lp_unit_type,new_unit)
		weap_base:set_lp_user_type(self._lp_unit_type)
--[[
		for i,part_data in pairs(weap_base._parts) do 
			local gadget_unit = part_data.unit
			local gadget_base = gadget_unit and alive(gadget_unit) and gadget_unit:base()
			local gadget_type = gadget_base and gadget_unit.GADGET_TYPE
			if gadget_type == "flashlight" or gadget_type == "laser" then
				gadget_base:set_lasersplus_type(self._lp_unit_type or "enemy")
			end
		end
--]]
	end
end)
