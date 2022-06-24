Hooks:PostHook(ElementLaserTrigger,"init","LasersPlus_ElementLaserTrigger_init",function(self,...)
	local natural_color = Color(unpack(self.COLORS[self._values.color]))
	LasersPlus:RegisterGadget("laser",nil,{
		uid = tostring(self), --should be a unique table address
		brush = self._brush,
		source = "world",
		natural_color = natural_color,
		natural_alpha = 0.15
	})
end)

Hooks:PostHook(ElementLaserTrigger,"remove_callback","LasersPlus_ElementLaserTrigger_remove_callback",function(self,...)
	LasersPlus:UnregisterGadget("laser",nil,tostring(self))
end)


local orig_elementlasertrigger_update_laser_draw = ElementLaserTrigger.update_laser_draw
function ElementLaserTrigger:update_laser_draw(t,dt,...)
	
	
	local gadget_data = LasersPlus:GetGadgetData("laser",nil,tostring(self))
	if not gadget_data then
		return orig_elementlasertrigger_update_laser_draw(self,t,dt,...)
	end
	local beam_thickness
	if LasersPlus.settings.world_laser_thickness_mode == 2 then
		beam_thickness = LasersPlus.settings.world_laser_thickness_value
	end
	if LasersPlus.settings.world_laser_color_mode == 3 then 
		strobe_id = gadget_data.strobe_id
	end
	
	if strobe_id then
		local strobe_index = gadget_data.strobe_index or 1
--local strobe_data = LasersPlus._processed_strobes[strobe_index]
--		strobe_index = (strobe_index + 1) % (#strobe_data - 1)
		--do strobing
	elseif not beam_thickness then
		return orig_elementlasertrigger_update_laser_draw(self,t,dt,...)
	end
	
-----
	if #self._connections == 0 then
		return
	end

	if self:_check_delayed_remove(t, dt) then
		return
	end

	for _, connection in ipairs(self._connections) do
		if connection.enabled then
			self._brush:cylinder(connection.from.pos, connection.to.pos, beam_thickness or 0.5)
		end
	end

	if self._is_cycled then
		self._next_cycle_t = self._next_cycle_t - dt

		if self._next_cycle_t <= 0 then
			self._next_cycle_t = self._values.cycle_interval

			for i, connection in ipairs(self._connections) do
				connection.enabled = false
			end

			local index = self._cycle_index - 1

			for j = 1, self._values.cycle_active_amount do
				index = index + 1

				if index > #self._cycle_order then
					index = 1
				end

				self._connections[self._cycle_order[index]].enabled = true
			end

			self._cycle_index = (self._values.cycle_type == "pop" and index or self._cycle_index) + 1

			if self._cycle_index > #self._cycle_order then
				self._cycle_index = 1
			end
		end
	end
end