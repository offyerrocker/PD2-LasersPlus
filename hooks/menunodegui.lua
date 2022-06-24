Hooks:PostHook(MenuNodeGui,"_setup_item_rows","LasersPlus_MenuNodeGui_setup_item_rows",function(self,node,...)
	
	LasersPlus:CreateMenuPreviews()
	
	--check legacy save files
	if SystemFS and SystemFS:exists( Application:nice_path( legacy_save_path, false )) then 
		local legacy_save_path = LasersPlus._legacy_save_path
		
		if not LasersPlus.has_shown_legacy_save_check then
			QuickMenu:new(
				managers.localization:text("menu_lasersplus_legacysave_title"),
				managers.localization:text("menu_lasersplus_legacysave_desc"),
				{
					{
						text = managers.localization:text("menu_lasersplus_legacysave_import_and_delete"), --import settings and delete legacy save file afterward
						callback = function()
							
							
						end
					},
					{
						text = managers.localization:text("menu_lasersplus_legacysave_import_and_archive"), --import settings and write in an "is_imported" flag so that the save data is ignored on subsequent loads
						callback = function()
						end
					},
					{
						text = managers.localization:text("menu_lasersplus_legacysave_archive"), --do not import; write in an "is_imported" flag so that the save data is ignored on subsequent loads
						callback = function()
						
						end
					},
					{
						text = managers.localization:text("menu_lasersplus_legacysave_not_now"), --ask me next load
						is_cancel_button = true
					}
				}
			,true)
			
			LasersPlus.has_shown_legacy_save_check = true
		end
	end
	
end)
