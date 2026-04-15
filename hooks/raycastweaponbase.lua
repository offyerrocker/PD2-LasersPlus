-- NewRaycastWeaponBase and NPCRaycastWeaponBase are child classes of RaycastWeaponBase,
-- so they're grouped up in this same file for organization/readability

if RequiredScript == "lib/units/weapons/raycastweaponbase" then

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
	
elseif RequiredScript == "lib/units/weapons/newraycastweaponbase" then
	
	
	
	Hooks:PostHook(NewRaycastWeaponBase,"clbk_assembly_complete","lasersplus_onweaponassemblycomplete",function(self,clbk,parts,blueprint)
		self._lp_unit_user_type = self._lp_unit_user_type or "user" -- assume that any weapon using this class is the local player
		self:set_gadget_lp_user_type(self._lp_unit_user_type)
	--	Print("clbk ssembly complete",self._lp_unit_user_type)
	end)
	
elseif RequiredScript == "lib/units/weapons/npcraycastweaponbase" then
	
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
	
end
