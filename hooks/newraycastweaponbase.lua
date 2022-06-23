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
							LasersPlus:SetGadgetParams(gadget_type,unit,{
								source = _source,
								peer_id = _peer_id,
								is_ai = _is_ai,
								parent_unit = _user_unit
							})
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
	
	
	
	
end)

Hooks:PreHook(NewRaycastWeaponBase,"destroy","LasersPlus_NewRaycastWeaponBase_destroy",function(self,unit)
	--LasersPlus:UnregisterLaser()
	--LasersPlus:UnregisterFlashlight()
	
end)