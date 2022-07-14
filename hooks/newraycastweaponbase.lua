Hooks:PostHook(NewRaycastWeaponBase,"clbk_assembly_complete","LasersPlus_NewRaycastWeaponBase_clbk_assembly_complete",function(self,clbk,parts,blueprint)
	local category = tweak_data.weapon[self._name_id].use_data.selection_index == 2 and "primaries" or "secondaries"
	local slot = managers.blackmarket:equipped_weapon_slot(category)

				
	local source,peer_id,is_ai
	local user_unit = self._setup and self._setup.user_unit
	
	for _,part_id in ipairs(blueprint) do 
		local colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id, true)
		if colors then 
			
			local mod_td = tweak_data.weapon.factory.parts[part_id]
			local part_data = parts[part_id]
			local unit = part_data.unit
			local unit_key = unit:key()
			local gadget_base = unit:base()
			if gadget_base then 
				local gadget_type = gadget_base.GADGET_TYPE
				
				if gadget_type == "laser" or gadget_type == "flashlight" then 
				
					if source == nil then 
						if user_unit then 
							source,peer_id,is_ai = LasersPlus:GetUserUnitData(user_unit)
						end
					end
					if not source then
						
						local detect_user_unit_posthook_id = "LasersPlus_NewRaycastWeaponBase_toggle_gadget" .. tostring(unit_key) 
						Hooks:PostHook(NewRaycastWeaponBase,"toggle_gadget",detect_user_unit_posthook_id,function(self)
							local _user_unit = self._setup and self._setup.user_unit
							if _user_unit then
								local _source,_peer_id,_is_ai = LasersPlus:GetUserUnitData(_user_unit)
								LasersPlus:SetGadgetParams(
									gadget_type,
									unit,
									{
										source = _source,
										peer_id = _peer_id,
										is_ai = _is_ai,
										parent_unit = _user_unit
									},
									true
								)
							end
							Hooks:RemovePostHook(detect_user_unit_posthook_id)
						end)
					--[[
						--alternate detection hook
						local detect_user_unit_posthook_id = "LasersPlus_NewRaycastWeaponBase_on_equip_" .. tostring(unit_key) 
						Hooks:PostHook(NewRaycastWeaponBase,"on_equip",detect_user_unit_posthook_id,function(self,user_unit)
							if user_unit then 
								local _source,_peer_id,_is_ai = LasersPlus:GetUserUnitData(user_unit)
								LasersPlus:SetGadgetParams(gadget_type,unit,{
									source = _source,
									peer_id = _peer_id,
									is_ai = _is_ai
								})
							end
							Hooks:RemovePostHook(detect_user_unit_posthook_id)
						end)
						--]]
					end
					local primary_color = colors[mod_td.sub_type]
					if primary_color then
						local natural_alpha = gadget_type == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1
						
						LasersPlus:RegisterGadget(gadget_type,unit,{
							source = source,
							peer_id = peer_id,
							is_ai = is_ai,
							weapon_unit = self._unit,
							natural_alpha = natural_alpha,
							natural_color = primary_color,
							parent_unit = user_unit
						})
					end
					
					if mod_td.adds then
						for _, add_part_id in ipairs(mod_td.adds) do
							local secondary_unit = parts[add_part_id] and parts[add_part_id].unit
							if secondary_unit and secondary_unit:base() then
							
								local sub_type = tweak_data.weapon.factory.parts[add_part_id].sub_type
								local secondary_gadget_type = sub_type
								
								local natural_alpha = secondary_gadget_type == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1
								local natural_color = colors[sub_type]
								
								LasersPlus:RegisterGadget(secondary_gadget_type,secondary_unit,{
									source = source,
									peer_id = peer_id,
									is_ai = is_ai,
									weapon_unit = self._unit,
									natural_alpha = natural_alpha,
									natural_color = natural_color,
									parent_unit = user_unit
								})
							end
						end
					end
					
					
				end
			end
		end
	end
	
	
	
	
end)

Hooks:PreHook(NewRaycastWeaponBase,"destroy","LasersPlus_NewRaycastWeaponBase_destroy",function(self,unit)
	--LasersPlus:UnregisterLaser()
	--LasersPlus:UnregisterFlashlight()
end)

local orig_toggle_gadget = NewRaycastWeaponBase.toggle_gadget
function NewRaycastWeaponBase:toggle_gadget(current_state,...)
	if not LasersPlus:IsQOLMultiGadgetCycleEnabled() then 
		return orig_toggle_gadget(self,current_state,...)
	end
	
	if not self._enabled then 
		return false
	end
	
	local gadgets = self._gadgets
	local gadget_on = self._gadget_on or 0
	
	local second_sight_count = 0
	
	if gadgets then 
		
		local num_gadgets = #gadgets + 1
		if LasersPlus:IsQOLSightGadgetSwitchEnabled() then 
			for _, part_id in ipairs(self._gadgets) do
				local factory_data = tweak_data.weapon.factory.parts.parts[part_id]
				if factory_data.sub_type == "second_sight" and not factory_data.is_amg_secondsight then
					num_gadgets = num_gadgets - 1
				end
			end
		end
		
		gadget_on = (gadget_on + 1) % num_gadgets
		
		self:set_gadget_on(gadget_on,false,gadgets,current_state)
		
		return true
	end
	return false
end

do return end

local orig_sort_gadgets = NewRaycastWeaponBase._refresh_gadget_list
function NewRaycastWeaponBase:_refresh_gadget_list(...)
	if not Lasers:SightCycleDisabled() then
		return orig_sort_gadgets(self,...)
	end
	
	local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("gadget", self._factory_id, self._blueprint)
	
	self._gadgets = gadgets
	if not gadgets or gadgets == 0 then
		return
	end
	
	
	for i=#self._gadgets,1,-1 do
		local gadget = gadgets[i]
		if not gadget or not alive(gadget.unit)  then 
			-- 
			--from mods like bot weapons and equipment
			table.remove(self._gadgets,i)
		end
	end
	
	local part_a, part_b = nil
	
--	local part_factory = tweak_data.weapon.factory.parts

	table.sort(gadgets, function (a, b)
		part_a = self._parts[a]
		part_b = self._parts[b]

		if not part_a then
			return false
		end

		if not part_b then
			return true
		end
		local factory_data_a = tweak_data.weapon.factory.parts.parts[a]
		local factory_data_b = tweak_data.weapon.factory.parts.parts[b]
		
		--factory_data.is_amg_secondsight
		local ap_a = part_a.unit:base().GADGET_TYPE
		local ap_b = part_b.unit:base().GADGET_TYPE
		if ap_a == "second_sight" or ap_a == "sight_gadget" then
			return false
		elseif ap_b == "second_sight" or ap_b == "sight_gadget" then 
			return true
		end
		
		local result = ap_b < ap_a
		
		return result
	end)

end