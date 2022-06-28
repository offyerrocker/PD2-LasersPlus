	
Hooks:PostHook(BlackMarketGui,"_buy_mod_callback","LasersPlus_BlackMarketGui_post_buy_mod_callback",function(self,data)
	local id = data.name
	local slot = data.slot
	local category = data.category
	local factory = tweak_data.weapon.factory.parts[id]

	if factory then
		if factory.texture_switch then
			local default
			if LasersPlus:IsQOLDefaultSightEnabled() then
				default = tostring(LasersPlus:GetSightColorIndex()) .. " " .. tostring(LasersPlus:GetSightTextureIndex())
			else
				default = tweak_data.gui.part_texture_switches[data.name] or tweak_data.gui.default_part_texture_switch
			end
			managers.blackmarket:set_part_texture_switch(category, slot, id, default)
		else
			local override_laser = LasersPlus:IsQOLDefaultLaserColorEnabled()
			local override_flashlight = LasersPlus:IsQOLDefaultFlashlightColorEnabled()
			if override_laser or override_flashlight then 
				local part_colors = managers.blackmarket:get_part_custom_colors(data.category,data.slot,data.name,false)
				if part_colors then 
					local laser_color = part_colors.laser
					if override_laser and laser_color then 
						part_colors.laser = Color(LasersPlus.settings.own_laser_color_string)
--						LasersPlus:log("New override laser color: " .. tostring(ColorPicker.color_to_hex(part_colors.laser)),{color=part_colors.laser})
					end
					
					local flashlight_color = part_colors.flashlight
					if override_flashlight and flashlight_color then 
						part_colors.flashlight = Color(LasersPlus.settings.own_flashlight_color_string)
--						LasersPlus:log("New override flashlight color: " .. tostring(ColorPicker.color_to_hex(part_colors.flashlight)),{color=part_colors.flashlight})
					end
					managers.blackmarket:set_part_custom_colors(data.category,data.slot,data.name,part_colors)
				else
					LasersPlus:log("BlackMarketGui:_buy_mod_callback(): No part by name " .. tostring(id))
				end
			end
		end
		
	end
end)