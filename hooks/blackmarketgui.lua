local orig_customize = Hooks:GetFunction(BlackMarketGui,"open_customize_gadget_menu")
Hooks:OverrideFunction(BlackMarketGui,"open_customize_gadget_menu",function(self,data,...)
	if not (LasersPlus.settings.feature_enabled_qol_blackmarket_colorpicker and _G.ColorPicker) then
		return orig_customize(self,data,...)
	end
	local args = {...} -- it's a surprise tool that will help us later
	
	-- check if the gadget has multiple colors to customize
	local part_id = data.name
	local mod_td = tweak_data.weapon.factory.parts[part_id]
	local show_laser = mod_td.sub_type == "laser"
	local show_flashlight = mod_td.sub_type == "flashlight"
	local slot = data.slot
	local category = data.category
	
	if mod_td.adds then
		for _, part_id in ipairs(mod_td.adds) do
			local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type
			show_laser = sub_type == "laser" or show_laser
			show_flashlight = sub_type == "flashlight" or show_flashlight
		end
	end
	
	local function apply_color_to_laser(color,palettes,success)
		LasersPlus:SetColorpickerPalettes(palettes)
		LasersPlus:SaveConfig()
		
		if success and color then
			local colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id)
			colors.laser = color
			managers.blackmarket:set_part_custom_colors(category,slot,part_id,colors)
			self:reload()
		end
		
	end
	
	local function apply_color_to_flashlight(color,palettes,success)
		LasersPlus:SetColorpickerPalettes(palettes)
		LasersPlus:SaveConfig()
		
		if success and color then
			local colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id)
			colors.flashlight = color
			managers.blackmarket:set_part_custom_colors(category,slot,part_id,colors)
			self:reload()
		end
		
	end
	
	local colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id)
	
	if show_laser and show_flashlight then
		-- intermediate dialog box to choose which to customize
		
		local title = managers.localization:text("menu_lfc_dialogue_choice_title")
		local desc = managers.localization:text("menu_lfc_dialogue_choice_desc")
		QuickMenu:new(
			title,desc,{
				{
					text = managers.localization:text("menu_lfc_choice_laser"),
					callback = function()
						LasersPlus._colorpicker:Show({color = colors.laser,done_callback = apply_color_to_laser})
					end
				},
				{
					text = managers.localization:text("menu_lfc_choice_flashlight"),
					callback = function()
						LasersPlus._colorpicker:Show({color = colors.flashlight,done_callback = apply_color_to_flashlight})
					end
				},
				{
					text = managers.localization:text("menu_lfc_choice_vanilla"),
					callback = function()
						orig_customize(self,data,unpack(args))
					end
				},
				{
					text = managers.localization:text("menu_back"),
					is_cancel_button = true
				}
			}
		,true)
	elseif show_laser or show_flashlight then
		-- show colorpicker immediately
		
		local color,cb
		if show_laser then
			color = colors.laser
			cb = apply_color_to_laser
		elseif show_flashlight then
			color = colors.flashlight
			cb = apply_color_to_flashlight
		end
		LasersPlus._colorpicker:Show({color = color,done_callback = cb})
	end
end)

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