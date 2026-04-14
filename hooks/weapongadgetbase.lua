Hooks:PostHook(WeaponGadgetBase,"init","lasersplus_gadget_init",function(self,unit)
	self._lp_data = self._lp_data or nil
	self._lp_strobe_t = self._lp_strobe_t or 0
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


-- custom func
function WeaponGadgetBase:get_lasersplus_type()
	return self._lp_user_type
end

function WeaponGadgetBase:set_lasersplus_type(user_type)
	if self.GADGET_TYPE == "laser" or self.GADGET_TYPE == "flashlight" then
		local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
	--	if LasersPlus:IsUserTypeEnabled("laser",self._lp_user_type) then
		if template_data and template_data.mode ~= 1 then
			if template_data.color then 
				self:set_color(template_data.color)
			end
			
			local strobe_count = 0
			local next_frame
			if template_data.strobe_data then
				local frames = template_data.strobe_data.colors
				-- assume that there are at least two frames;
				-- this is also checked on strobe unpacking in LasersPlus:StringToStrobe()
				next_frame = frames[2]
				strobe_count = #frames
			end
			self._lp_data = {
				settings = template_data,
				next_frame_t = 0,
				index = 0,
				speed = 1,
				strobe_count = strobe_count,
				prev_color = Color.green
			}
		else
			self._lp_data = nil
		end
	end
end

--[[
function WeaponLaser:set_lasersplus_type(user_type,...)
	WeaponLaser.super.set_lasersplus_type(self,user_type,...)
	
--	local user_type = self._lp_user_type
	
	local template_data = LasersPlus:GetGadgetTemplate("laser",user_type)
--	if LasersPlus:IsUserTypeEnabled("laser",self._lp_user_type) then
	if template_data and template_data.mode ~= 1 then
		if template_data.color then 
			self:set_color(template_data.color)
		end
		
		local strobe_count = template_data and template_data.strobe_data and #template_data.strobe_data.colors or 0
		self._lp_data = {
			settings = template_data,
			last_index = -1,
			speed = 1,
			strobe_count = strobe_count,
			next_frame = nil
		}
	else
		self._lp_data = nil
	end
end
function WeaponFlashLight:set_lasersplus_type(user_type,...)
	WeaponFlashLight.super.set_lasersplus_type(self,user_type,...)
	
--	local user_type = self._lp_user_type
	
	local template_data = LasersPlus:GetGadgetTemplate("flashlight",user_type)
	if template_data and template_data.mode ~= 1 then
		if template_data.color then 
			self:set_color(template_data.color)
		end
		
		local strobe_count = template_data and template_data.strobe_data and #template_data.strobe_data.colors or 0
		self._lp_data = {
			settings = template_data,
			last_index = -1,
			speed = 1,
			strobe_count = strobe_count,
			next_frame = 0
		}
	else
		self._lp_data = nil
	end
end

--]]