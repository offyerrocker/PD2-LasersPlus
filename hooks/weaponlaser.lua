do return end

Hooks:PostHook(WeaponLaser,"init","WeaponLaserInit_lasersplus",function(self,unit)
--	LasersPlus:RegisterLaser(unit,"generic",{})
	log(">>>>WeaponLaser init")
	log(tostring(unit))
--	log(debug.traceback())
	log("<<<<WeaponLaser init")
end)


Hooks:PostHook(WeaponLaser,"set_color","WeaponLaserSetColor_lasersplus",function(self,color)
--	LasersPlus:RegisterLaser(unit,"generic",{})
	log(">>>>WeaponLaser set_color " .. tostring(ColorPicker.color_to_hex(color)))
	log(tostring(self._unit))
--	log(debug.traceback())
	log("<<<<WeaponLaser set_color ")
end)



--[[

--if true, makes sniper/npc lasers affected by this change
local AFFECT_NPC = false
--(does not affect world lasers like vault lasers)



Hooks:PostHook(WeaponLaser,"init","blacklaserblacklaserblacklaser",function(self,unit)
	self._brush = Draw:brush(self._themes[self._theme_type].brush)
	--exclude "VertexColor" as an argument to the constructor to overwrite "opacity_add" as the blend mode
end)

if not AFFECT_NPC then 
	Hooks:PostHook(WeaponLaser,"set_npc","noblacklasernoblacklaser",function(self)
		--recreate the brush as normal
		self._brush = Draw:brush(self._themes[self._theme_type].brush, "VertexColor")
	end)
end

--]]