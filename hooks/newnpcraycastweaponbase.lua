
Hooks:PostHook(NewNPCRaycastWeaponBase,"assemble","lasersplus_onnpcweaponassemblycomplete",function(self,factory_id)
	self:set_gadget_lp_user_type(self._lp_unit_user_type)
	Print("clbk ssembly complete",self._lp_unit_user_type)
end)


function NewNPCRaycastWeaponBase:assemble(factory_id)
	NewNPCRaycastWeaponBase.super:assemble(factory_id)

	self._ammo_data = managers.weapon_factory:get_ammo_data_from_weapon(self._factory_id, self._blueprint) or {}
	local ammo_muzzle_effect = self._ammo_data and self._ammo_data.muzzleflash

	if ammo_muzzle_effect then
		self._muzzle_effect = ammo_muzzle_effect
		self._muzzle_effect_table = {
			force_synch = false,
			effect = self._muzzle_effect,
			parent = self._obj_fire
		}
	end
end