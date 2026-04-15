Hooks:PostHook(ElementLaserTrigger,"init","LasersPlus_ElementLaserTrigger_init",function(self,...)
	self._lp_key = self._lp_key or "lp_listener_gadget_" .. string.match(tostring(self),"0.*")
end)

Hooks:PostHook(ElementLaserTrigger,"add_callback","LasersPlus_ElementLaserTrigger_add_callback",function(self,...)
	local function f_setup(template_data)
		if alive(self._brush) then
			if template_data and template_data.mode ~= 1 then
				if template_data.color then
					if template_data.alpha then
						self._brush:set_color(template_data.color:with_alpha(template_data.alpha))
					else
						self._brush:set_color(template_data.color)
					end
				end
				
				local strobe_count = 0
				local init_color = template_data.color
				if template_data.strobe_data then
					local frames = template_data.strobe_data.colors
					init_color = frames[1].color
					-- assume that there are at least two frames;
					-- this is also checked on strobe unpacking in LasersPlus:StringToStrobe()
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
			else
				self._brush:set_color(Color(0.15, unpack(self.COLORS[self._values.color])))
				self._lp_data = nil
			end
		end
	end
	
	Hooks:Add("OnLasersPlusSettingChanged_World",self._lp_key,f_setup)
	
	local template_data = LasersPlus:GetGadgetTemplate("laser","world")
	f_setup(template_data)
end)

Hooks:PostHook(ElementLaserTrigger,"remove_callback","LasersPlus_ElementLaserTrigger_remove_callback",function(self,...)
	Hooks:Remove("OnLasersPlusSettingChanged_World",self._lp_key)
end)

Hooks:PostHook(ElementLaserTrigger,"update_laser_draw","lasersplus_upd_worldlasers",function(self,t,dt,...)
	if self._lp_data then 
		local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
		if color then 
			self._brush:set_color(color)
		end
	end
	
end)

--[[
local orig_update = Hooks:GetFunction(ElementLaserTrigger,"update_laser_draw")
Hooks:OverrideFunction(ElementLaserTrigger,"update_laser_draw",function(self,t,dt,...)
	if not self._lp_data then 
		return orig_update(self,t,dt,...)
	end
	
	if #self._connections == 0 then
		return
	end

	if self:_check_delayed_remove(t, dt) then
		return
	end

	for _, connection in ipairs(self._connections) do
		if connection.enabled then
			-- only change is here,
			-- to allow changing the brush size
			self._brush:cylinder(connection.from.pos, connection.to.pos, self._lp_data.radius)
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

				self._connections[self._cycle_order[index] ].enabled = true
			end

			self._cycle_index = (self._values.cycle_type == "pop" and index or self._cycle_index) + 1

			if self._cycle_index > #self._cycle_order then
				self._cycle_index = 1
			end
		end
	end
end
--]]