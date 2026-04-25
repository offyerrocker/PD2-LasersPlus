	
Hooks:PostHook(BlackMarketGui,"_buy_mod_callback","LasersPlus_BlackMarketGui_post_buy_mod_callback",function(self,data)
	local id = data.name
	local slot = data.slot
	local category = data.category
	local factory = tweak_data.weapon.factory.parts[id]
	if factory then
		local qol_enabled = LasersPlus:IsQOLDefaultGadgetEnabled()
		if factory.texture_switch then
			if qol_enabled then
				local data_string = tostring(LasersPlus:GetSightColorIndex()) .. " " .. tostring(LasersPlus:GetSightTextureIndex())
				managers.blackmarket:set_part_texture_switch(category, slot, id, data_string)
				self:reload()
			end
		else
			local override_laser = qol_enabled
			local override_flashlight = qol_enabled
			if override_laser or override_flashlight then 
				local part_colors = managers.blackmarket:get_part_custom_colors(data.category,data.slot,data.name,false)
				if part_colors then 
					local laser_color = part_colors.laser
					if override_laser and laser_color then 
						part_colors.laser = Color(LasersPlus.settings.user_laser_color)
					end
					
					local flashlight_color = part_colors.flashlight
					if override_flashlight and flashlight_color then 
						part_colors.flashlight = Color(LasersPlus.settings.user_flash_color)
					end
					managers.blackmarket:set_part_custom_colors(data.category,data.slot,data.name,part_colors)
					self:reload()
				end
			end
		end
		
	end
end)