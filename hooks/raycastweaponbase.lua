-- NewRaycastWeaponBase and NPCRaycastWeaponBase are child classes of RaycastWeaponBase,
-- so they're grouped up in this same file for organization/readability

if RequiredScript == "lib/units/weapons/raycastweaponbase" then

	-- custom func
	function RaycastWeaponBase:set_lp_user_type(user_type,peer_id)
		self._lp_unit_user_type = user_type
		if self._assembly_complete then
			self:set_gadget_lp_user_type(user_type,peer_id)
			--Print("Assembly complete",user_type)
		end
	end

	function RaycastWeaponBase:set_gadget_lp_user_type(user_type,peer_id)
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
					gadget_base:set_lasersplus_type(user_type,peer_id)
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
	
	--[[
	Hooks:PostHook(NewRaycastWeaponBase,"_refresh_gadget_list","lasersplus_populate_gadgets",function(self)
		if LasersPlus:IsQOLSightGadgetSwitchEnabled() then
			-- disable cycling to second-sight type gadgets
			self._lp_gadgets = {}
			for _,part_id in ipairs(self._gadgets) do 
				local part = self._parts[part_id]
				local gadget_base = alive(part.unit) and part.unit:base()
				local gadget_type = gadget_base and gadget_base.GADGET_TYPE
				if gadget_type == "laser" or gadget_type == "flashlight" then
				--if gadget_type == "second_sight" or gadget_type == "sight_gadget" then
					table.insert(self._lp_gadgets,#self._lp_gadgets+1,part_id)
				end
			end
		else
			self._lp_gadgets = self._gadgets
		end
	end)
	
	--[[
	-- multigadget
	local orig_toggle_gadget = Hooks:GetFunction(NewRaycastWeaponBase,"toggle_gadget")
	Hooks:OverrideFunction(NewRaycastWeaponBase,"toggle_gadget",function(current_state,...)
		if not LasersPlus:IsQOLMultiGadgetCycleEnabled() or not self._lp_gadgets then 
			return orig_toggle_gadget(self,current_state,...)
		end
		
		if not self._enabled then 
			return false
		end
		
		local gadgets = self._lp_gadgets
		local gadget_on = self._gadget_on or 0
		
		if gadgets then 
			gadget_on = (gadget_on + 1) % num_gadgets
			self:set_gadget_on(gadget_on,false,gadgets,current_state)
			return true
		end
		return false
	end)
--]]
	
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
