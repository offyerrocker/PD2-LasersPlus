local mvec_temp1 = Vector3()
local mvec_temp2 = Vector3()
local mvec_temp3 = Vector3()
local mvec_prev_pos = Vector3()
local mvec_mover_to_ghost = Vector3()

local ids_hdr_post_processor = Idstring("hdr_post_processor")
local ids_hdr_post_composite = Idstring("post_DOF")
local ids_radial_offset = Idstring("radial_offset")
local ids_dof_settings = Idstring("settings")
local ids_contrast = Idstring("contrast")
local ids_chromatic = Idstring("chromatic_amount")


Hooks:PostHook(PlayerMenu, "_setup_draw", "LasersPlus_VRHandLaserSetup", function(self)


	self._lp_user_type = "own"
	self._lp_peer_id = managers.network:session():local_peer():id()
	self._lp_gadget_type = "laser"
	self._lp_gadget_params = LasersPlus:GetOwnLaserParams()
	
	self._brush_laser = Draw:brush(Color(self._lp_gadget_params.color))
	self._brush_laser:set_blend_mode("opacity_add")
	self._brush_laser:set_render_template(Idstring("LineObject"))
	
	Hooks:Add("LasersPlus_OnSettingsChanged","LasersPlus_OnSettingsChangedListener_VRHandMenuState",function(gadget_type,user_type,setting,value)
		if gadget_type == self._lp_gadget_type then 
			if user_type == self._lp_user_type then 
				self._lp_gadget_params[setting] = value
				if setting == "color" then 
					self._brush_laser = Draw:brush(Color(value))
					self._brush_laser:set_blend_mode("opacity_add")
					self._brush_laser:set_render_template(Idstring("LineObject"))
				end
			end
		end
	end)
end)

Hooks:PostHook(PlayerMenu, "update", "LasersPlus_VRLaserHandUpdate", function(self, t, dt)
--[[
	local color = Color(0.05, 0, 1, 0)
	if LasersPlus:IsOwnLaserInvisible() then
		color = LasersPlus.col_invisible --no idea why you'd do this but okay
	end
	if LasersPlus:IsOwnLaserVanilla() then
		self._brush_laser = Draw:brush(Color(0.05, 0, 1, 0)) --this isn't set in tweak data so...  yeah
		self._brush_laser_dot = Draw:brush(Color(1, 0, 1, 0))
		return
	end
	if LasersPlus:IsOwnLaserCustom() then
		color = LasersPlus:GetOwnLaserColor()
	end
	if LasersPlus:IsMasterLaserStrobeEnabled() and LasersPlus:IsOwnLaserStrobeEnabled() then 
		color = LasersPlus:StrobeStep(LasersPlus:GetOwnLaserStrobe(),0.5)
		self._brush_warp = Draw:brush(color)--Color(0.07, 0, 0.60784, 0.81176))
	end
	self._brush_laser = Draw:brush(color) --set_color()?
	self._brush_laser_dot = Draw:brush(color)
	--]]
end)


Hooks:Register("PlayerMenu_laser_ray")
local orig_laser_ray
PlayerMenu._orig_laser_ray = orig_laser_ray
function PlayerMenu:_laser_ray(visible, from, to,...)
	local params = self._lp_gadget_params or {
		color =  Color(0,0.2,0),
		alpha = 0.4,
		thickness = 0.5
	}
	
	local dot_radius = 1
	
	if self._is_start_menu then
		if visible then
			self._brush_laser:cylinder(from, to, self._lp_laser_cylinder_radius)
			self._brush_laser_dot:sphere(to, dot_radius)
		end
	else
		local ray_obj = self._laser_ray_obj
		local dot_obj = self._laser_dot_obj

		if visible then
			--todo get brush color
			ray_obj:cylinder(from, to, self._lp_laser_cylinder_radius, 20, Color(0.05, 0, 1, 0))
			dot_obj:sphere(to, 1, dot_radius, Color(1, 0, 1, 0))
		end

		ray_obj:set_visibility(visible)
		dot_obj:set_visibility(visible)
	end
	Hooks:Call("PlayerMenu_laser_ray",self,visible,from,to,...)
end