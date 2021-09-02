Hooks:Register("LasersPlus_OnSettingsChanged")

do return end







Hooks:Add("MenuManagerSetupCustomMenus", "ach_MenuManagerSetupCustomMenus", function(menu_manager, nodes)
	
	MenuHelper:NewMenu("lasersplus_mainmenu")
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "ach_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)

--for crosshairs:
	AdvancedCrosshair.hitmarker_id_by_index,hitmarker_items = AdvancedCrosshair:SortAddons(AdvancedCrosshair._hitmarker_data,"alphabetical")
	
--	local h_i = 1
	for h_i,id in ipairs(AdvancedCrosshair.hitmarker_id_by_index) do 
		if id == AdvancedCrosshair.settings.hitmarker_kill_id then
			hitmarker_kill_bitmap_index = h_i
		end
		if id == AdvancedCrosshair.settings.hitmarker_hit_id then 
			hitmarker_hit_bitmap_index = h_i
		end
--		table.insert(hitmarker_items,h_i,hitmarker_data.name_id)
--		table.insert(AdvancedCrosshair.hitmarker_id_by_index,h_i,id)
--		h_i = h_i + 1
	end
	
--hitmarker menus	
	MenuHelper:AddToggle({
		id = "ach_hitmarkers_master_enable",
		title = "menu_ach_hitmarkers_master_enable_title",
		desc = "menu_ach_hitmarkers_master_enable_desc",
		callback = "callback_ach_hitmarkers_master_enable",
		value = AdvancedCrosshair.settings.hitmarker_enabled,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 31
	})
	
	MenuHelper:AddMultipleChoice({
		id = "ach_hitmarkers_outofrange_mode",
		title = "menu_ach_hitmarkers_outofrange_mode_title",
		desc = "menu_ach_hitmarkers_outofrange_mode_desc",
		callback = "callback_ach_hitmarkers_set_outofrange_mode",
		items = {
			"menu_ach_outofrange_disabled",
			"menu_ach_outofrange_size"
--,			"menu_ach_outofrange_color",
--			"menu_ach_outofrange_alpha"
		},
		value = AdvancedCrosshair.settings.hitmarker_outofrange_mode,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 30
	})
	
	MenuHelper:AddSlider({
		id = "ach_hitmarkers_set_max_count",
		title = "menu_ach_hitmarkers_set_max_count_title",
		desc = "menu_ach_hitmarkers_set_max_count_desc",
		callback = "callback_ach_hitmarkers_set_max_count",
		value = AdvancedCrosshair.settings.hitmarker_max_count,
		default_value = AdvancedCrosshair.default_settings.hitmarker_max_count,
		min = 1,
		max = 10,
		step = 1,
		show_value = true,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 26
	})
	
	
	MenuHelper:AddDivider({
		id = "ach_hitmarkers_div_1",
		size = 16,
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 25
	})
	MenuHelper:AddButton({
		id = "ach_hitmarkers_hit_set_bodyshot_crit_color",
		title = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_title",
		desc = "menu_ach_hitmarkers_hit_set_bodyshot_crit_color_desc",
		callback = "callback_ach_hitmarkers_hit_set_bodyshot_crit_color",
		menu_id = AdvancedCrosshair.hitmarkers_menu_id,
		priority = 18
	})
	
	--set color
	local set_crosshair_color_callback_name = firemode_menu_name .. "_set_crosshair_color"
	MenuCallbackHandler[set_crosshair_color_callback_name] = function(self)
		
		AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
		
		if AdvancedCrosshair._colorpicker then
			local function clbk_colorpicker (color,palettes,success)
				--set preview color
				local preview_data = AdvancedCrosshair.crosshair_preview_data
				local parent_panel = preview_data and preview_data.panel
				local crosshair_data = preview_data and AdvancedCrosshair._crosshair_data[tostring(preview_data.crosshair_id)]
				if preview_data and crosshair_data and preview_data.parts and alive(parent_panel) then 
					for part_index,part in ipairs(preview_data.parts) do
						if not crosshair_data.parts[part_index].UNRECOLORABLE then 
							part:set_color(color)
						end
					end
				end
				
				--save color to settings
				if success then 
					crosshair_setting.color = color:to_hex()
					AdvancedCrosshair:Save()
				end
				
				--save palette swatches to settings
				if palettes then 
					AdvancedCrosshair:SetPaletteCodes(palettes)
				end
			end
			
			AdvancedCrosshair.clbk_show_colorpicker_with_callbacks(Color(crosshair_setting.color),clbk_colorpicker,clbk_colorpicker)
			
		elseif not _G.ColorPicker then
			AdvancedCrosshair.clbk_missing_colorpicker_prompt()
		end
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ach_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	local crosshairs_menu = MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_menu_id)
	nodes[AdvancedCrosshair.main_menu_id] = MenuHelper:BuildMenu(
		AdvancedCrosshair.main_menu_id,{
			area_bg = "none",
			back_callback = "callback_ach_main_close",
			focus_changed_callback = "callback_ach_main_focus"
		}
	)
	
	nodes[AdvancedCrosshair.crosshairs_categories_global_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_global_id,
		{
			area_bg = "none",
			back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_global_close,
			focus_changed_callback = "callback_ach_crosshairs_categories_global_focus"
		}
	)
	
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_global_id,"menu_ach_crosshairs_global_menu_title","menu_ach_crosshairs_global_menu_desc",2)
	MenuHelper:AddMenuItem(crosshairs_menu,AdvancedCrosshair.crosshairs_categories_submenu_id,"menu_ach_crosshairs_categories_menu_title","menu_ach_crosshairs_categories_menu_desc",1)
	for cat_menu_name,cat_menu_data in pairs(AdvancedCrosshair.customization_menus) do 
		local cat_menu = MenuHelper:GetMenu(cat_menu_name)
		local category = tostring(cat_menu_data.category_name)
		local cat_name_id = "menu_weapon_category_" .. category
		local cat_name_desc = "menu_ach_change_crosshair_weapon_category_desc"
		local i = 1
		for firemode_menu_name,firemode_menu in pairs(cat_menu_data.child_menus) do
			local firemode = tostring(firemode_menu.firemode)
			local name_id = "menu_weapon_firemode_" .. firemode
			local desc_id = cat_name_id
			local callback_category_firemode_focus_name = "callback_ach_menu_crosshairs_category_" .. category .. "_firemode_" .. firemode .. "_focus"
			MenuCallbackHandler[callback_category_firemode_focus_name] = function(self,item)
				if item == false then 
					if game_state_machine:verify_game_state(GameStateFilters.any_ingame) and managers.player and alive(managers.player:local_player()) then
						AdvancedCrosshair:CreateCrosshairs()
			--			AdvancedCrosshair.clbk_create_crosshair_preview()
					end
				elseif item == true then
					local crosshair_setting = AdvancedCrosshair.settings.crosshairs[category] and AdvancedCrosshair.settings.crosshairs[category][firemode]
					if not crosshair_setting then 
						AdvancedCrosshair:log("FATAL ERROR: Hook MenuManagerBuildCustomMenus: Invalid crosshair settings for [category " .. tostring(category) .. " | firemode " .. tostring(firemode) .. "], aborting menu generation",{color=Color.red})
						return 
					end
					AdvancedCrosshair.crosshair_preview_data = AdvancedCrosshair.crosshair_preview_data or AdvancedCrosshair.clbk_create_crosshair_preview(crosshair_setting)
				end
			end
			nodes[firemode_menu_name] = MenuHelper:BuildMenu(firemode_menu_name,
				{
					area_bg = "none",
					back_callback = MenuCallbackHandler.callback_ach_crosshairs_close,
					focus_changed_callback = callback_category_firemode_focus_name
				}
			)
			MenuHelper:AddMenuItem(cat_menu,firemode_menu_name,name_id,desc_id,i) --add each firemode menu to its weaponcategory parent menu
			i = i + 1
		end
		nodes[cat_menu_name] = MenuHelper:BuildMenu(cat_menu_name,
			{
				area_bg = "none",
				back_callback = MenuCallbackHandler.callback_ach_hitmarkers_close,
				focus_changed_callback = "callback_ach_hitmarkers_focus"
			}
		)
		nodes[AdvancedCrosshair.crosshairs_categories_submenu_id] = MenuHelper:BuildMenu(AdvancedCrosshair.crosshairs_categories_submenu_id,
			{
				area_bg = "none",
				back_callback = MenuCallbackHandler.callback_ach_crosshairs_categories_close,
				focus_changed_callback = "callback_ach_crosshairs_categories_focus"
			}
		)
		MenuHelper:AddMenuItem(MenuHelper:GetMenu(AdvancedCrosshair.crosshairs_categories_submenu_id),cat_menu_name,cat_name_id,cat_name_desc)
	end
end)

Hooks:Add("MenuManagerInitialize", "ach_initmenu", function(menu_manager)
	MenuCallbackHandler.callback_ach_reset_crosshair_settings = function(self)
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.crosshair) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_crosshair_settings_prompt_success_title"),managers.localization:text("menu_ach_reset_crosshair_settings_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
			AdvancedCrosshair:Save()
		end
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_crosshair_settings_prompt_confirm_title"),managers.localization:text("menu_ach_reset_crosshair_settings_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
	end
	if _G.ColorPicker then 
		LasersPlus._colorpicker = LasersPlus._colorpicker or ColorPicker:new("advancedcrosshairs",{},callback(LasersPlus,LasersPlus,"set_colorpicker_menu"))
	end
	
	MenuHelper:LoadFromJsonFile(LasersPlus._menu_path, LasersPlus, LasersPlus.settings)
end)

