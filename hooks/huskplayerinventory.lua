Hooks:PostHook(HuskPlayerInventory,"sync_weapon_gadget_color","LasersPlus_HuskPlayerInventory_sync_weapon_gadget_color",function(self,color)
	--local redfilter_ratio = LasersPlus:GetRedFilterRatio()
	--
	
	local equipped_unit = self:equipped_unit()
	if alive(equipped_unit) then 
		local gadget_base = equipped_unit:base()
		if gadget_base then 
			local gadget_type = gadget_base.GADGET_TYPE
			
			--just in case ovk adds new color-able gadget types
			if gadget_type == "laser" then 
				LasersPlus:SetGadgetParams("laser",equipped_unit,{
					unit = equipped_unit,
					natural_color = color
				},
				true)
			elseif gadget_type == "flashlight" then 
				LasersPlus:SetGadgetParams("laser",equipped_unit,{
					unit = equipped_unit,
					natural_color = color
				},
				true)
			end
		end
	end
end)
