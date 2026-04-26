
-- warning: here be dragons

Hooks:Add("MenuManagerInitialize", "LasersPlus_MenuManagerInitialize", function(menu_manager)
	LasersPlus:LoadSettings()
	LasersPlus:SetupAllGadgetTemplates()
	
	LasersPlus:CreateColorpicker()
	
	--ze placeholders, zhey do nothing
	-- (they are load-bearing though)
	MenuCallbackHandler.callback_lasersplus_header_dummy = function() end
	MenuCallbackHandler.callback_lasersplus_menu_user_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_team_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_enemy_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_world_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_turret_focused = function(self,focused)
	end
	MenuCallbackHandler.callback_lasersplus_menu_qol_focused = function(self,focused)
	end
	
	
	
	
	
	MenuCallbackHandler.callback_lasersplus_gadget_network_sync = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_gadget_network_sync",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_lasersplus_laser_redfilter = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_laser_redfilter",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_lasersplus_qol_defaultgadget = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_qol_defaultgadget",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	
	MenuCallbackHandler.callback_lasersplus_qol_blackmarket_colorpicker = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_qol_blackmarket_colorpicker",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_lasersplus_qol_defaultgadget_reticle_texture = function(self,item)
		LasersPlus:ChangeSetting("qol_defaultgadget_sight_type",tonumber(item:value()))
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_lasersplus_qol_defaultgadget_reticle_color = function(self,item)
		LasersPlus:ChangeSetting("qol_defaultgadget_sight_color",tonumber(item:value()))
		LasersPlus:SaveSettings()
	end
	
	MenuCallbackHandler.callback_lasersplus_gadget_multigadget_mode = function(self,item)
		LasersPlus:ChangeSetting("feature_state_gadget_multigadget",tonumber(item:value()))
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_gadget_info_multigadget = function(self,item)
		QuickMenu:new(managers.localization:text("loc_lasersplus_dialog_gadget_multigadget_title"),managers.localization:text("loc_lasersplus_dialog_gadget_multigadget_desc",{
			BTN_GADGET = managers.localization:btn_macro("weapon_gadget", true)
		}),{
			{
				text = managers.localization:text("dialog_ok"),
				is_cancel_button = true,
				is_focused_button = true
			}
		},true)
	end
	
	MenuCallbackHandler.callback_lasersplus_laser_accurate = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_laser_accurate",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	
	MenuCallbackHandler.callback_lasersplus_laser_update_override = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_laser_override",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	MenuCallbackHandler.callback_lasersplus_flash_update_override = function(self,item)
		LasersPlus:ChangeSetting("feature_enabled_flashlight_override",item:value() == "on")
		LasersPlus:SaveSettings()
	end
	
	
end)


local submenus = {
	lasersplus_menu_general = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_general_title",
		desc = "loc_lasersplus_menu_general_desc",
		back_callback = nil,
		focus_changed_callback = nil
	},
	lasersplus_menu_user = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_user_title",
		desc = "loc_lasersplus_menu_user_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_user_focused"
	},
	lasersplus_menu_team = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_team_title",
		desc = "loc_lasersplus_menu_team_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_team_focused"
	},
	lasersplus_menu_enemy = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_enemy_title",
		desc = "loc_lasersplus_menu_enemy_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_enemy_focused"
	},
	lasersplus_menu_world = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_world_title",
		desc = "loc_lasersplus_menu_world_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_world_focused"
	},
	lasersplus_menu_lasers_turret = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_turret_title",
		desc = "loc_lasersplus_menu_turret_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_turret_focused"
	},
	lasersplus_menu_qol = {
		parent_menu_id = "lasersplus_menu_main",
		title = "loc_lasersplus_menu_qol_title",
		desc = "loc_lasersplus_menu_qol_desc",
		back_callback = nil,
		focus_changed_callback = "callback_lasersplus_menu_qol_focused"
	}
}

Hooks:Add("MenuManagerSetupCustomMenus", "LasersPlus_MenuManagerSetupCustomMenus", function(menu_manager, nodes)
	MenuHelper:NewMenu("lasersplus_menu_main")
	
	for menu_id,menu_data in pairs(submenus) do 
		MenuHelper:NewMenu(menu_id)
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "LasersPlus_MenuManagerPopulateCustomMenus", function(menu_manager, nodes)

	-- annoyingly, menus are populated by inserting at the top index (upwards from bottom), instead of the bottom index (downwards from top)
	-- so to populate in a logical order I either need to make all these in reverse,
	-- or add them to a list structure and then iterate backwards.
	
	local queued_menus = {}
	local function add_menu_option(_type,data)
		local parent_menu_id = data.menu_id
		queued_menus[parent_menu_id] = queued_menus[parent_menu_id] or {}
		local q = queued_menus[parent_menu_id]
		table.insert(q,1,{
			data = data,
			type = _type
		})
	end
	local function execute_queued_menus()
		for _,menu_data in pairs(queued_menus) do 
			local j = 0
			for i=1,#menu_data,1 do 
--			for i=#menu_data,1,-1 do 
				local v = menu_data[i]
--				v.data.priority = i
				if not v.data.priority then
					j = j + 1
					v.data.priority = j
				end
				if v.type == "button" then
					MenuHelper:AddButton(v.data)
				elseif v.type == "toggle" then
					MenuHelper:AddToggle(v.data)
				elseif v.type == "slider" then
					MenuHelper:AddSlider(v.data)
				elseif v.type == "divider" then
					MenuHelper:AddDivider(v.data)
				elseif v.type == "keybind" then
					MenuHelper:AddKeybinding(v.data)
				elseif v.type == "multiple_choice" then
					MenuHelper:AddMultipleChoice(v.data)
				elseif v.type == "input" then
					MenuHelper:AddInput(v.data)
				else
					LasersPlus:Print("Unknown menu item type: " .. tostring(v.type))
				end
			end
		end
	end
	
	
	-- returns function, or nil if invalid args
	local function create_setting_changed_callback(user_type,gadget_type,setting_id,data_type)
		-- (re)build the setting variable name from the given arguments,
		-- return a callback function to change this setting
		return function(self,item)
			local new_template_data = {}
			if data_type == "boolean" then
				-- presumably will be MenuCallbackHandler callback
				new_template_data[setting_id] = item:value() == "on"
			elseif data_type == "number" then
				new_template_data[setting_id] = tonumber(item:value())
			end
			LasersPlus:OnTemplateChanged(gadget_type,user_type,new_template_data)
			LasersPlus:SaveSettings()
	--		LasersPlus:Print("Bad setting callback: user_type",user_type,"gadget_type",gadget_type,"setting_id",setting_id,"data_type",data_type)
	--		return nil
		end
	end
	
	local function build_laser_options(user_type,parent_menu_id,params)
		-- header
			-- lasers
		-- display mode multiplechoice
		-- strobe toggle
		-- colorpicker/rgb
		-- alpha slider
		-- radius slider
			-- flashlights
		-- display mode multiplechoice
		-- strobe toggle
		-- colorpicker/rgb
		-- alpha slider
		-- range slider
		-- angle slider
		
		if params.header_title then
			add_menu_option("button",{
				id = "lasersplus_menu_subheader_" .. user_type,
				title = params.header_title,
				desc = params.header_desc or "",
				callback = "callback_lasersplus_header_dummy",
				menu_id = parent_menu_id,
				disabled = true
			})
		end
		
-- lasers
		if params and params.laser then
			local laser_template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
			
			add_menu_option("button",{
				id = "lasersplus_menu_subheader_laser_" .. user_type,
				title = "loc_lasersplus_generic_laser_subheader_title",
				desc = "loc_lasersplus_generic_laser_subheader_desc",
				callback = "callback_lasersplus_header_dummy",
				menu_id = parent_menu_id,
				disabled = true
			})
			add_menu_option("divider",{
				id = "lasersplus_menu_divider_laser_" .. user_type,
				size = 2,
				menu_id = parent_menu_id
			})
			
			local callback_id_laser_display_mode = "callback_lasersplus_laser_display_mode_" .. user_type
			MenuCallbackHandler[callback_id_laser_display_mode] = create_setting_changed_callback(user_type,"laser","mode","number")
			add_menu_option("multiple_choice",{
				id = "lasersplus_menu_laser_display_mode_" .. user_type,
				title = "loc_lasersplus_generic_laser_display_mode_title",
				desc = "loc_lasersplus_generic_laser_display_mode_desc",
				callback = callback_id_laser_display_mode,
				items = params.laser_mode_items or {
					"loc_lasersplus_gadget_display_mode_option_vanilla",
					"loc_lasersplus_gadget_display_mode_option_customstatic"
				},
				value = laser_template_data.mode,
				menu_id = parent_menu_id
			})
			
			if _G.ColorPicker then 
				local callback_id_laser_button = "callback_lasersplus_laser_colorpicker_" .. user_type
				MenuCallbackHandler[callback_id_laser_button] = function(self)
					--LasersPlus.settings[params.setting_names]
					LasersPlus:ShowColorpicker("laser",user_type)
				end
				
				add_menu_option("button",{
					id = "lasersplus_menu_" .. user_type .. "_laser_colorpicker",
					title = params.laser_colorpicker_name or "loc_lasersplus_generic_laser_colorpicker_title",
					desc = params.laser_colorpicker_desc or "loc_lasersplus_generic_laser_colorpicker_desc",
					callback = callback_id_laser_button,
					menu_id = parent_menu_id
				})
			else
				-- r, g, b sliders
				
				local callback_id_laser_r = "callback_lasersplus_laser_colorslider_r_" .. user_type
				local callback_id_laser_g = "callback_lasersplus_laser_colorslider_g_" .. user_type
				local callback_id_laser_b = "callback_lasersplus_laser_colorslider_b_" .. user_type
				MenuCallbackHandler[callback_id_laser_r] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
					local old_color = template_data.color
					local new_color = Color(tonumber(item:value()) / 255,old_color.g,old_color.b) -- discard alpha; it isn't stored or used here anyway
					
					LasersPlus:OnTemplateChanged("laser",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				MenuCallbackHandler[callback_id_laser_g] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
					local old_color = template_data.color
					local new_color = Color(old_color.r,tonumber(item:value()) / 255,old_color.b)
					
					LasersPlus:OnTemplateChanged("laser",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				MenuCallbackHandler[callback_id_laser_b] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
					local old_color = template_data.color
					local new_color = Color(old_color.r,old_color.g,tonumber(item:value()) / 255)
					
					LasersPlus:OnTemplateChanged("laser",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_laser_r",
					title = params.laser_r_slider_name or "loc_lasersplus_generic_laser_colorslider_r_title",
					desc = params.laser_r_slider_desc or "loc_lasersplus_generic_laser_colorslider_r_desc",
					callback = callback_id_laser_r,
					value = color.r,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_laser_g",
					title = params.laser_g_slider_desc or "loc_lasersplus_generic_laser_colorslider_g_title",
					desc = params.laser_g_slider_desc or "loc_lasersplus_generic_laser_colorslider_g_desc",
					callback = callback_id_laser_g,
					value = color.g,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_laser_b",
					title = params.laser_b_slider_title or "loc_lasersplus_generic_laser_colorslider_b_title",
					desc = params.laser_b_slider_desc or "loc_lasersplus_generic_laser_colorslider_b_desc",
					callback = callback_id_laser_b,
					value = color.b,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
			end
			
			local callback_id_laser_strobe_enabled = "callback_lasersplus_laser_strobeenabled_" .. user_type
			MenuCallbackHandler[callback_id_laser_strobe_enabled] = create_setting_changed_callback(user_type,"laser","strobe_enabled","boolean")
			add_menu_option("toggle",{
				id = "lasersplus_menu_" .. user_type .. "_laser_strobeenabled",
				title = "loc_lasersplus_generic_laser_strobeenabled_title",
				desc = "loc_lasersplus_generic_laser_strobeenabled_desc",
				callback = callback_id_laser_strobe_enabled,
				value = laser_template_data.strobe_enabled,
				menu_id = parent_menu_id
			})
			
			
			local callback_id_laser_alpha = "callback_lasersplus_laser_alpha_" .. user_type
			MenuCallbackHandler[callback_id_laser_alpha] = create_setting_changed_callback(user_type,"laser","alpha","number")
			add_menu_option("slider",{
				id = "lasersplus_menu_" .. user_type .. "_laser_alpha",
				title = "loc_lasersplus_generic_laser_alpha_title",
				desc = "loc_lasersplus_generic_laser_alpha_desc",
				callback = callback_id_laser_alpha,
				value = laser_template_data.alpha,
				default_value = 1,
				min = 0,
				max = 1,
				step = 0.1,
				show_value = true,
				menu_id = parent_menu_id
			})
			
			local callback_id_laser_radius = "callback_lasersplus_laser_radius_" .. user_type
			MenuCallbackHandler[callback_id_laser_radius] = create_setting_changed_callback(user_type,"laser","radius","number")
			add_menu_option("slider",{
				id = "lasersplus_menu_" .. user_type .. "_laser_radius",
				title = "loc_lasersplus_generic_laser_radius_title",
				desc = "loc_lasersplus_generic_laser_radius_desc",
				callback = callback_id_laser_radius,
				value = laser_template_data.radius,
				default_value = 0.25,
				min = 0,
				max = 1,
				step = 0.25,
				show_value = true,
				menu_id = parent_menu_id
			})
			
			
			add_menu_option("divider",{
				id = "lasersplus_divider_2_" .. user_type,
				size = 16,
				menu_id = parent_menu_id
			})
		end
-- flashlights
		
		if params and params.flash then
			
			local flash_template_data = LasersPlus:GetGadgetTemplate("flashlight",user_type)
			
			add_menu_option("button",{
				id = "lasersplus_menu_subheader_flash_" .. user_type,
				title = "loc_lasersplus_generic_flash_subheader_title",
				desc = "loc_lasersplus_generic_flash_subheader_desc",
				callback = "callback_lasersplus_header_dummy",
				menu_id = parent_menu_id,
				disabled = true
			})
			add_menu_option("divider",{
				id = "lasersplus_menu_divider_flash_" .. user_type,
				size = 2,
				menu_id = parent_menu_id
			})
			
			local callback_id_flash_display_mode = "callback_lasersplus_flash_display_mode_" .. user_type
			MenuCallbackHandler[callback_id_flash_display_mode] = create_setting_changed_callback(user_type,"flashlight","mode","number")
			add_menu_option("multiple_choice",{
				id = "lasersplus_menu_flash_display_mode_" .. user_type,
				title = "loc_lasersplus_generic_flash_display_mode_title",
				desc = "loc_lasersplus_generic_flash_display_mode_desc",
				callback = callback_id_flash_display_mode,
				items = params.flash_mode_items or {
					"loc_lasersplus_gadget_display_mode_option_vanilla",
					"loc_lasersplus_gadget_display_mode_option_customstatic"
				},
				value = flash_template_data.mode,
				menu_id = parent_menu_id
			})
			
			if _G.ColorPicker then 
				local callback_id_flash_button = "callback_lasersplus_flash_colorpicker_" .. user_type
				MenuCallbackHandler[callback_id_flash_button] = function(self)
					--LasersPlus.settings[params.setting_names]
					LasersPlus:ShowColorpicker("flashlight",user_type)
				end
				
				add_menu_option("button",{
					id = "lasersplus_menu_" .. user_type .. "_flash_colorpicker",
					title = params.flash_colorpicker_name or "loc_lasersplus_generic_flash_colorpicker_title",
					desc = params.flash_colorpicker_desc or "loc_lasersplus_generic_flash_colorpicker_desc",
					callback = callback_id_flash_button,
					menu_id = parent_menu_id
				})
			else
				-- r, g, b sliders
				
				local callback_id_flash_r = "callback_lasersplus_flash_colorslider_r_" .. user_type
				local callback_id_flash_g = "callback_lasersplus_flash_colorslider_g_" .. user_type
				local callback_id_flash_b = "callback_lasersplus_flash_colorslider_b_" .. user_type
				MenuCallbackHandler[callback_id_flash_r] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("flashlight",user_type)
					local old_color = template_data.color
					local new_color = Color(tonumber(item:value()) / 255,old_color.g,old_color.b) -- discard alpha; it isn't stored or used here anyway
					
					LasersPlus:OnTemplateChanged("flashlight",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				MenuCallbackHandler[callback_id_flash_g] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("flashlight",user_type)
					local old_color = template_data.color
					local new_color = Color(old_color.r,tonumber(item:value()) / 255,old_color.b)
					
					LasersPlus:OnTemplateChanged("flashlight",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				MenuCallbackHandler[callback_id_flash_b] = function(self,item)
					local template_data = LasersPlus:GetGadgetTemplate("flashlight",user_type)
					local old_color = template_data.color
					local new_color = Color(old_color.r,old_color.g,tonumber(item:value()) / 255)
					
					LasersPlus:OnTemplateChanged("flashlight",user_type,{ color = new_color })
					LasersPlus:SaveSettings()
				end
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_flash_r",
					title = params.flash_r_slider_name or "loc_lasersplus_generic_flash_colorslider_r_title",
					desc = params.flash_r_slider_desc or "loc_lasersplus_generic_flash_colorslider_r_desc",
					callback = callback_id_flash_r,
					value = color.r,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_flash_g",
					title = params.flash_g_slider_name or "loc_lasersplus_generic_flash_colorslider_g_title",
					desc = params.flash_g_slider_desc or "loc_lasersplus_generic_flash_colorslider_g_desc",
					callback = callback_id_flash_g,
					value = color.g,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
				
				add_menu_option("slider",{
					id = "lasersplus_menu_" .. user_type .. "_flash_b",
					title =  params.flash_b_slider_name or "loc_lasersplus_generic_flash_colorslider_b_title",
					desc = params.flash_b_slider_desc or "loc_lasersplus_generic_flash_colorslider_b_desc",
					callback = callback_id_flash_b,
					value = color.b,
					default_value = 255,
					min = 0,
					max = 255,
					step = 16,
					show_value = true,
					menu_id = parent_menu_id
				})
			end
			
			local callback_id_flash_strobe_enabled = "callback_lasersplus_flash_strobeenabled_" .. user_type
			MenuCallbackHandler[callback_id_flash_strobe_enabled] = create_setting_changed_callback(user_type,"flashlight","strobe_enabled","boolean")
			add_menu_option("toggle",{
				id = "lasersplus_menu_" .. user_type .. "_flash_strobeenabled",
				title = "loc_lasersplus_generic_flash_strobeenabled_title",
				desc = "loc_lasersplus_generic_flash_strobeenabled_desc",
				callback = callback_id_flash_strobe_enabled,
				value = flash_template_data.strobe_enabled,
				menu_id = parent_menu_id
			})
			
			local callback_id_flash_alpha = "callback_lasersplus_flash_alpha_" .. user_type
			MenuCallbackHandler[callback_id_flash_alpha] = create_setting_changed_callback(user_type,"flashlight","alpha","number")
			add_menu_option("slider",{
				id = "lasersplus_menu_" .. user_type .. "_flash_alpha",
				title = "loc_lasersplus_generic_flash_alpha_title",
				desc = "loc_lasersplus_generic_flash_alpha_desc",
				callback = callback_id_flash_alpha,
				value = flash_template_data.alpha,
				default_value = 16,
				min = 0,
				max = 100,
				step = 10,
				show_value = true,
				menu_id = parent_menu_id
			})
			
			local callback_id_flash_range = "callback_lasersplus_flash_range_" .. user_type
			MenuCallbackHandler[callback_id_flash_range] = create_setting_changed_callback(user_type,"flashlight","range","number")
			add_menu_option("slider",{
				id = "lasersplus_menu_" .. user_type .. "_flash_range",
				title = "loc_lasersplus_generic_flash_range_title",
				desc = "loc_lasersplus_generic_flash_range_desc",
				callback = callback_id_flash_range,
				value = flash_template_data.range,
				default_value = 10,
				min = 0,
				max = 100,
				step = 10,
				show_value = true,
				menu_id = parent_menu_id
			})
			
			local callback_id_flash_angle = "callback_lasersplus_flash_angle_" .. user_type
			MenuCallbackHandler[callback_id_flash_angle] = create_setting_changed_callback(user_type,"flashlight","angle","number")
			add_menu_option("slider",{
				id = "lasersplus_menu_" .. user_type .. "_flash_angle",
				title = "loc_lasersplus_generic_flash_angle_title",
				desc = "loc_lasersplus_generic_flash_angle_desc",
				callback = callback_id_flash_angle,
				value = flash_template_data.angle,
				default_value = 60,
				min = 0,
				max = 90, -- should not go higher than 180
				step = 30,
				show_value = true,
				menu_id = parent_menu_id
			})
		end
	end
	
	-- add menu subheaders
	for menu_id,menu_data in pairs(submenus) do 
		add_menu_option("button",{
			id = menu_id .. "_header",
			title = menu_data.title,
			desc = menu_data.desc,
			callback = "callback_lasersplus_header_dummy",
			menu_id = menu_id,
			disabled = true
		})
		
		add_menu_option("divider",{
			id = menu_id .. "_divider_1",
			size = 16,
			menu_id = menu_id
		})
	end
	
	
	------------------------------------
	------------- General menu ---------
	------------------------------------
	
	add_menu_option("toggle",{
		id = "lasersplus_gadget_network_sync",
		title = "loc_lasersplus_gadget_network_sync_title",
		desc = "loc_lasersplus_gadget_network_sync_desc",
		callback = "callback_lasersplus_gadget_network_sync",
		value = LasersPlus.settings.feature_enabled_gadget_network_sync,
		menu_id = "lasersplus_menu_general"
	})
	
	add_menu_option("divider",{
		id = "lasersplus_general_divider_1",
		size = 8,
		menu_id = "lasersplus_menu_general"
	})
	
	add_menu_option("toggle",{
		id = "lasersplus_laser_update_override",
		title = "loc_lasersplus_laser_update_override_title",
		desc = "loc_lasersplus_laser_update_override_desc",
		callback = "callback_lasersplus_laser_update_override",
		value = LasersPlus.settings.feature_enabled_laser_override,
		menu_id = "lasersplus_menu_general"
	})
	
	add_menu_option("toggle",{
		id = "lasersplus_flash_update_override",
		title = "loc_lasersplus_flash_update_override_title",
		desc = "loc_lasersplus_flash_update_override_desc",
		callback = "callback_lasersplus_flash_update_override",
		value = LasersPlus.settings.feature_enabled_flashlight_override,
		menu_id = "lasersplus_menu_general"
	})
	
	
	
	
	------------------------------------
	------------- QOL menu -------------
	------------------------------------
	
	
	add_menu_option("toggle",{
		id = "lasersplus_laser_redfilter",
		title = "loc_lasersplus_laser_redfilter_title",
		desc = "loc_lasersplus_laser_redfilter_desc",
		callback = "callback_lasersplus_laser_redfilter",
		value = LasersPlus.settings.feature_enabled_laser_redfilter,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("divider",{
		id = "lasersplus_qol_divider_1",
		size = 8,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("toggle",{
		id = "lasersplus_laser_accurate",
		title = "loc_lasersplus_laser_accurate_title",
		desc = "loc_lasersplus_laser_accurate_desc",
		callback = "callback_lasersplus_laser_accurate",
		value = LasersPlus.settings.feature_enabled_laser_accurate,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("divider",{
		id = "lasersplus_qol_divider_2",
		size = 8,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("toggle",{
		id = "lasersplus_qol_blackmarket_colorpicker",
		title = "loc_lasersplus_qol_blackmarket_colorpicker_title",
		desc = "loc_lasersplus_qol_blackmarket_colorpicker_desc",
		callback = "callback_lasersplus_qol_blackmarket_colorpicker",
		value = LasersPlus.settings.feature_enabled_qol_blackmarket_colorpicker,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("divider",{
		id = "lasersplus_qol_divider_3",
		size = 8,
		menu_id = "lasersplus_menu_qol"
	})
	
	
	do 
		add_menu_option("toggle",{
			id = "lasersplus_qol_defaultgadget",
			title = "loc_lasersplus_qol_defaultgadget_title",
			desc = "loc_lasersplus_qol_defaultgadget_desc",
			callback = "callback_lasersplus_qol_defaultgadget",
			value = LasersPlus.settings.feature_enabled_qol_defaultgadget,
			menu_id = "lasersplus_menu_qol"
		})
		-- validate selections
		-- (in case user had a modded sight selected and the mod was later removed)
		if not tweak_data.gui.weapon_texture_switches.types.sight[LasersPlus.settings.qol_defaultgadget_sight_type] then
			LasersPlus.settings.qol_defaultgadget_sight_type = 1
		end
		
		if not tweak_data.gui.weapon_texture_switches.color_indexes[LasersPlus.settings.qol_defaultgadget_sight_color] then
			LasersPlus.settings.qol_defaultgadget_sight_color = 1
		end
		
		local reticle_textures = {}
		local reticle_colors = {}
		for i,texture_switch_data in ipairs(tweak_data.gui.weapon_texture_switches.types.sight) do 
			local name_id = texture_switch_data.name_id
			local texture_path = texture_switch_data.texture_path
	--		local dlc = texture_switch_data.dlc
			reticle_textures[i] = name_id
		end
		for i,color_index_data in ipairs(tweak_data.gui.weapon_texture_switches.color_indexes) do 
			local color_name = color_index_data.color
 	--		local dlc = color_index_data.dlc
			reticle_colors[i] = "menu_recticle_color_" .. tostring(color_name)
			-- yes, it's misspelled as "recticle"
		end
		
		add_menu_option("multiple_choice",{
			id = "lasersplus_qol_defaultgadget_reticle_type",
			title = "loc_lasersplus_qol_defaultgadget_reticle_type_title",
			desc = "loc_lasersplus_qol_defaultgadget_reticle_type_desc",
			callback = "callback_lasersplus_qol_defaultgadget_reticle_texture",
			items = reticle_textures,
			value = LasersPlus.settings.qol_defaultgadget_sight_type,
			menu_id = "lasersplus_menu_qol"
		})
		add_menu_option("multiple_choice",{
			id = "lasersplus_qol_defaultgadget_reticle_color",
			title = "loc_lasersplus_qol_defaultgadget_reticle_color_title",
			desc = "loc_lasersplus_qol_defaultgadget_reticle_color_desc",
			callback = "callback_lasersplus_qol_defaultgadget_reticle_color",
			items = reticle_colors,
			value = LasersPlus.settings.qol_defaultgadget_sight_color,
			menu_id = "lasersplus_menu_qol"
		})
	end

	add_menu_option("divider",{
		id = "lasersplus_qol_divider_4",
		size = 8,
		menu_id = "lasersplus_menu_qol"
	})
	
	add_menu_option("button",{
		id = "lasersplus_gadget_info_multigadget",
		title = "loc_lasersplus_button_gadget_multigadget_title",
		desc = "loc_lasersplus_button_gadget_multigadget_desc",
		callback = "callback_gadget_info_multigadget",
		menu_id = "lasersplus_menu_qol"
	})
	
	
	add_menu_option("multiple_choice",{
		id = "lasersplus_gadget_multigadget_mode",
		title = "loc_lasersplus_gadget_multigadget_mode_title",
		desc = "loc_lasersplus_gadget_multigadget_mode_desc",
		callback = "callback_lasersplus_gadget_multigadget_mode",
		items = {
			"loc_lasersplus_gadget_multigadget_mode_vanilla",
			"loc_lasersplus_gadget_multigadget_mode_multicycle",
			"loc_lasersplus_gadget_multigadget_mode_everything"
		},
		value = LasersPlus.settings.feature_state_gadget_multigadget,
		menu_id = "lasersplus_menu_qol"
	})
	
	
	
	
	
	
	------------------------------------------------------------------------
	------------- Laser/Flashlight options for each user_type --------------
	------------------------------------------------------------------------
	
	build_laser_options("user","lasersplus_menu_user",{
		laser=true,
		flash=true,
		laser_mode_items = {
			"loc_lasersplus_gadget_display_mode_option_vanilla",
			"loc_lasersplus_gadget_display_mode_option_customstatic",
			"loc_lasersplus_gadget_display_mode_option_custompeer"
		},
		flash_mode_items= {
			"loc_lasersplus_gadget_display_mode_option_vanilla",
			"loc_lasersplus_gadget_display_mode_option_customstatic",
			"loc_lasersplus_gadget_display_mode_option_custompeer"
		}
	})
	build_laser_options("team","lasersplus_menu_team",{
		laser=true,
		flash=true,
		laser_mode_items = {
			"loc_lasersplus_gadget_display_mode_option_vanilla",
			"loc_lasersplus_gadget_display_mode_option_customstatic",
			"loc_lasersplus_gadget_display_mode_option_custompeer"
		},
		flash_mode_items= {
			"loc_lasersplus_gadget_display_mode_option_vanilla",
			"loc_lasersplus_gadget_display_mode_option_customstatic",
			"loc_lasersplus_gadget_display_mode_option_custompeer"
		}
	})
	build_laser_options("enemy","lasersplus_menu_enemy",{laser=true,flash=true})
	build_laser_options("world","lasersplus_menu_world",{laser=true,flash=false})
	build_laser_options("turretatt","lasersplus_menu_lasers_turret",{
		laser=true,
		flash=false,
		header_title = "loc_lasersplus_menu_turret_subheader_att_title",
		header_desc = "loc_lasersplus_menu_turret_subheader_att_desc"
	})
	build_laser_options("turretrld","lasersplus_menu_lasers_turret",{
		laser=true,
		flash=false,
		header_title = "loc_lasersplus_menu_turret_subheader_rld_title",
		header_desc = "loc_lasersplus_menu_turret_subheader_rld_desc"
	})
	build_laser_options("turretmad","lasersplus_menu_lasers_turret",{
		laser=true,
		flash=false,
		header_title = "loc_lasersplus_menu_turret_subheader_mad_title",
		header_desc = "loc_lasersplus_menu_turret_subheader_mad_desc"
	})
	
	-- build menu options in order
	execute_queued_menus()
end)

Hooks:Add("MenuManagerBuildCustomMenus", "LasersPlus_MenuManagerBuildCustomMenus", function( menu_manager, nodes )
	nodes.lasersplus_menu_main = MenuHelper:BuildMenu(
		"lasersplus_menu_main",
		{
			area_bg = "none",
			back_callback = nil,
			focus_changed_callback = nil
		}
	)
	MenuHelper:AddMenuItem(nodes.blt_options,"lasersplus_menu_main","loc_lasersplus_menu_main_title","loc_lasersplus_menu_main_desc")
	
	
	
	
	local function add_submenu(menu_id)
		local menu_data = submenus[menu_id]
--		log("adding cb for 1",menu_data.focus_changed_callback,"2",menu_data.back_callback)
		local menu = MenuHelper:BuildMenu(
			menu_id
,			{
				area_bg = "none",
				back_callback = menu_data.back_callback or "callback_lasersplus_header_dummy",
				focus_changed_callback = menu_data.focus_changed_callback or "callback_lasersplus_header_dummy"
			}
		)
		nodes[menu_id] = menu
		MenuHelper:AddMenuItem(nodes[menu_data.parent_menu_id or "blt_options"],menu_id,menu_data.title,menu_data.desc)
		
	end
	add_submenu("lasersplus_menu_general")
	add_submenu("lasersplus_menu_qol")
	add_submenu("lasersplus_menu_user")
	add_submenu("lasersplus_menu_team")
	add_submenu("lasersplus_menu_enemy")
	add_submenu("lasersplus_menu_world")
	add_submenu("lasersplus_menu_lasers_turret")
	
end)
