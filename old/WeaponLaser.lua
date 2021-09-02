Hooks:PostHook(WeaponLaser,"init","lasersplus_weaponlaserinit",function(self,unit)
	LasersPlus:RegisterLaser(unit)
end)

Hooks:PostHook(WeaponLaser,"update","lasersplus_weaponlaserupdate",function(self,unit)

end)

Hooks:PostHook(WeaponLaser,"set_npc","lasersplus_weaponlasersetnpc",function(self)

end)

Hooks:PostHook(WeaponLaser,"set_color_by_theme","lasersplus_weaponlasersetcolorbytheme",function(self,theme)

end)

Hooks:PostHook(WeaponLaser,"_check_state","lasersplus_weaponlasercheckstate",function(self)

end)



--[[

CloneClass( WeaponLaser )

Hooks:RegisterHook("WeaponLaserInit")
function WeaponLaser.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("WeaponLaserInit", self, unit)
end

Hooks:RegisterHook("WeaponLaserUpdate")
function WeaponLaser.update(self, unit, t, dt)
	self.orig.update(self, unit, t, dt)
	Hooks:Call("WeaponLaserUpdate", self, unit, t, dt)
end

Hooks:RegisterHook("WeaponLaserSetNPC")
function WeaponLaser.set_npc(self)
	self.orig.set_npc(self)
	Hooks:Call("WeaponLaserSetNPC", self)
end

Hooks:RegisterHook("WeaponLaserPostSetColorByTheme")
function WeaponLaser.set_color_by_theme(self, theme)
	self.orig.set_color_by_theme(self, theme)
	Hooks:Call("WeaponLaserPostSetColorByTheme", self, theme)
end

Hooks:RegisterHook("WeaponLaserSetOn")
Hooks:RegisterHook("WeaponLaserSetOff")
function WeaponLaser._check_state(self)
	self.orig._check_state(self)
	if self._on then
		Hooks:Call("WeaponLaserSetOn", self)
	else
		Hooks:Call("WeaponLaserSetOff", self)
	end
end



	Hooks:Add("WeaponLaserUpdate", "WeaponLaserUpdate_lasersplus", function(laser, unit, t, dt)
--[[		local col = laser._color
		if col and unit and not Lasers.teammate_vanilla_lasers[unit] then
			Lasers.teammate_vanilla_lasers[unit] = col
			--i absolutely hate that this works
			--i could probably use this for teammates too for consistency
			--but i'd prefer to keep as few per-frame calculations as possible for performance
		end--]]
		Lasers:UpdateLaser(laser, unit, t, dt)
	end)

	Hooks:Add("WeaponLaserInit", "WeaponLaserInit_lasersplus", function(laser, unit)
--		laser._max_distance = 6000
--makes laser dot tiny because it scales based on distance, don't want that
		lp_log("Generating player strobe in Init.")
		Lasers:GetOwnLaserStrobe()
		Lasers:UpdateLaser(laser, unit, 0, 0)
		laser._t = 1
	end)

	

	-- *****    Set On    *****
	Hooks:Add("WeaponLaserSetOn", "WeaponLaserSetOn_lasersplus", function(laser)
		if false then 
			Lasers:SaveGadgetVanillaColor(laser._unit,Lasers:ConvertToBLTColor(laser:color()))
			local own_strobe = Lasers:GetSavedPlayerStrobe()
			if Lasers:IsNetworkingEnabled() then
				LuaNetworking:SendToPeers( Lasers.LuaNetID, LuaNetworking:ColourToString(Lasers:GetOwnLaserColor()))
				if own_strobe then
					LuaNetworking:SendToPeers( Lasers.LuaNetID, own_strobe)
				end
			end
		end
	end)
	


--]]