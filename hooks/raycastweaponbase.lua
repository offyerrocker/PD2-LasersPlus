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
	
elseif RequiredScript == "lib/units/weapons/newraycastweaponbase" then
	
	Hooks:PostHook(NewRaycastWeaponBase,"clbk_assembly_complete","lasersplus_onweaponassemblycomplete",function(self,clbk,parts,blueprint)
		self._lp_unit_user_type = self._lp_unit_user_type or "user" -- assume that any weapon using this class is the local player
		self:set_gadget_lp_user_type(self._lp_unit_user_type)
	--	Print("clbk ssembly complete",self._lp_unit_user_type)
	end)
	
	-- multigadget/overload
	--[[
	Hooks:PostHook(NewRaycastWeaponBase,"_refresh_gadget_list","lasersplus_populate_gadgets",function(self)
		-- disable cycling to second-sight type gadgets
		-- (not strictly necessary anymore since ovk switched second sights to a new category with new behavior)
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
	end)
	--]]
	
	if LasersPlus.settings.feature_state_gadget_multigadget ~= 1 then
		local orig_toggle_gadget = Hooks:GetFunction(NewRaycastWeaponBase,"toggle_gadget")
		Hooks:OverrideFunction(NewRaycastWeaponBase,"toggle_gadget",function(self, current_state,...)
			if not self._enabled then 
				return false
			end
			
			local gadget_mode = LasersPlus.settings.feature_state_gadget_multigadget
			
			local gadgets = self._gadgets
			local num_combos = 0
			if gadget_mode == 1 then
				-- vanilla
				return orig_toggle_gadget(self,current_state,...)
			elseif gadget_mode == 2 then
				-- multiple (all combos)
				-- skip set_gadget_on()
				
				num_combos = 2 ^ #gadgets
			elseif gadget_mode == 3 then
				-- gadget overload (binary, all or none)
				-- skip set_gadget_on()
				num_combos = 2
			end
			
			local gadget_on = self._gadget_on or 0
			if gadgets then 
				gadget_on = (gadget_on + 1) % num_combos
--				LasersPlus:Print("Current gadget state:",gadget_on,"/",num_combos)
--				Console:SetTracker(string.format("%i / %i",gadget_on,num_combos),1)
				self:set_gadget_on(gadget_on,false,gadgets,current_state)
				return true
			end
			
			return false
		end)
		
		local orig_set_gadget_on = Hooks:GetFunction(NewRaycastWeaponBase,"set_gadget_on")
		Hooks:OverrideFunction(NewRaycastWeaponBase,"set_gadget_on",function(self, gadget_on, ignore_enable, gadgets, current_state,...)
			if self._lp_unit_user_type == "user" then
				if not ignore_enable and not self._enabled then
					return
				end
				
				if not self._assembly_complete then
					return
				end
				
				self._gadget_on = gadget_on or self._gadget_on
				gadget_on = gadget_on or self._gadget_on or 0
				
				gadgets = gadgets or self._gadgets
				
				if LasersPlus.settings.feature_state_gadget_multigadget == 1 then
					-- vanilla
					return orig_set_gadget_on(self, gadget_on, ignore_enable, gadgets, current_state,...)
				elseif LasersPlus.settings.feature_state_gadget_multigadget == 2 then
					-- multi cycle
					local gadget
					for i,id in ipairs(gadgets) do 
						gadget = self._parts[id]
						if gadget and alive(gadget.unit) then
							gadget.unit:base():set_state(bit.band(2^(i-1),gadget_on) ~= 0, self._sound_fire, current_state)
--							Console:SetTracker(string.format("%s: %s %i",id,gadget_on ~= 0,gadget_on),1+i)
							
						end
					end
				elseif LasersPlus.settings.feature_state_gadget_multigadget == 3 then
					-- everything
					local gadget
					for i,id in ipairs(gadgets) do 
						gadget = self._parts[id]
						if gadget and alive(gadget.unit) then
							gadget.unit:base():set_state(gadget_on ~= 0, self._sound_fire, current_state)
						end
					end
				end
			else
				return orig_set_gadget_on(self, gadget_on, ignore_enable, gadgets, current_state,...)
			end
		end)
	end
end
