Hooks:PostHook(ElementLaserTrigger,"init","LasersPlus_ElementLaserTrigger_init",function(self,...)
	local natural_color = self.COLORS[self._values.color]
	LasersPlus:RegisterGadget("laser",nil,{
		uid = tostring(self), --should be a unique table address
		brush = self._brush,
		source = "world",
		natural_color = natural_color,
		natural_alpha = 0.15
	})
end)

Hooks:PostHook(ElementLaserTrigger,"remove_callback","LasersPlis_ElementLaserTrigger_remove_callback",function(self,...)
	
end)