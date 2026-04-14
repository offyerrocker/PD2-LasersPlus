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
--		Print("Add unit!",self._lp_unit_type,new_unit)
		weap_base:set_lp_user_type(self._lp_unit_type)
	end
end)
