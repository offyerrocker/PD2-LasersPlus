Hooks:PostHook(WeaponGadgetBase,"init","lasersplus_gadget_init",function(self,unit)
	self._lp_data = self._lp_data or nil
	self._lp_user_type = self._lp_user_type or nil
	self._lp_key = self._lp_key or "lp_listener_gadget_" .. string.match(tostring(self),"0.*")
end)

-- custom func
-- set the type of unit using this gadget (player, teammate heister, or sniper);
-- other types (sentry and world) do not use gadgets at all, so that is handled elsewhere 
function WeaponGadgetBase:set_lasersplus_type(user_type)
	self:_set_lasersplus_type(user_type)
--	self._lp_strobe = LasersPlus:GetStrobeData(user_type)
end

function WeaponGadgetBase:_set_lasersplus_type(user_type)
	self._lp_user_type = user_type
end


function WeaponGadgetBase:setup_lp_strobe_data(template_data)
	local strobe_count = 0
	local init_color = template_data.color
	if template_data.strobe_data then
		local frames = template_data.strobe_data.colors
		-- assume that there are at least two frames;
		-- this is also checked on strobe unpacking in LasersPlus:StringToStrobe()
		init_color = frames[1].color
		strobe_count = #frames
	end
	self._lp_data = {
		settings = template_data,
		t = 0,
		next_frame_t = 0,
		index = 0,
		speed = 1,
		strobe_count = strobe_count,
		prev_color = init_color
	}
end

-- custom func
function WeaponGadgetBase:get_lasersplus_type()
	return self._lp_user_type
end