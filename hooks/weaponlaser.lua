--[[
Hooks:PostHook(WeaponLaser,"init","lasersplus_laser_init",function(self,unit)

	local function f_setup(template_data)
		if template_data and template_data.mode ~= 1 then
			if template_data.color then
				if template_data.alpha then
					self:set_color(template_data.color:with_alpha(template_data.alpha))
				else
					self:set_color(template_data.color)
				end
			end
			
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
		else
			self._lp_data = nil
		end
	end
	
	Hooks:Add("OnLasersPlusSettingChanged_Laser",self._lp_key,function(template_data)
		if alive(self._light) then
			f_setup(template_data)
		end
	end)
--	local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
--	f_setup(template_data)
end)
--]]

Hooks:PreHook(WeaponLaser,"destroy","lasersplus_gadget_destroy",function(self,unit)
	if self._lp_key then
		Hooks:Remove("OnLasersPlusSettingChanged_Laser",self._lp_key)
	end
end)

Hooks:PreHook(WeaponLaser,"update","lasersplus_laser_update",function(self,unit,t,dt)
	if self._lp_data then
		local color = LasersPlus.UpdateGadget(self._lp_data,t,dt)
		if color then 
			self:set_color(color)
		end
	end
end)

function WeaponLaser:set_lasersplus_type(user_type,...)
	WeaponLaser.super.set_lasersplus_type(self,user_type,...)
	local function f_setup(template_data)
		if alive(self._light) then
			if template_data and template_data.mode ~= 1 then
				if template_data.color then
					if template_data.alpha then
						self:set_color(template_data.color:with_alpha(template_data.alpha))
					else
						self:set_color(template_data.color)
					end
				end
				
				self:setup_lp_strobe_data(template_data)
			else
				self._lp_data = nil
			end
		end
	end
	
	Hooks:Add("OnLasersPlusSettingChanged_Laser",self._lp_key,f_setup)
	local template_data = LasersPlus:GetGadgetTemplate(self.GADGET_TYPE,user_type)
	f_setup(template_data)
end