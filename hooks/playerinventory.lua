
-- PlayerInventory is the parent class for teammate ai, human teammates, and enemies,
-- in addition to being the class for players;
-- therefore, for readability, 
-- all of the below separate hooks lead to this same file

if RequiredScript == "lib/units/beings/player/playerinventory" then

	Hooks:PostHook(PlayerInventory,"add_unit","lasersplus_on_invext_add_weapon",function(self, new_unit, equip)
		local weap_base = alive(new_unit) and new_unit:base()
		if self._lp_unit_type and weap_base and weap_base.set_lp_user_type then
			-- have to let the info propagate naturally as the load process progresses
	--		Print("Add unit!",self._lp_unit_type,new_unit)
			weap_base:set_lp_user_type(self._lp_unit_type,managers.criminals:character_peer_id_by_unit(self._unit))
		end
	end)

	-- would result in other units defaulting to player laser- this is not desired
--	Hooks:PostHook(PlayerInventory,"init","lasersplus_on_playerinventory_init",function(self, unit)
--		self._lp_unit_type = "user"
--	end)

elseif RequiredScript == "lib/units/beings/player/huskplayerinventory" then

	Hooks:PostHook(HuskPlayerInventory,"init","lasersplus_on_huskplayerinventory_init",function(self, unit)
		self._lp_unit_type = "team"
	end)
	
elseif RequiredScript ==  "lib/units/enemies/cop/copinventory" then

	Hooks:PostHook(CopInventory,"init","lasersplus_on_copinventory_init",function(self, unit)
		self._lp_unit_type = "enemy"
	end)

elseif RequiredScript == "lib/units/player_team/teamaiinventory" then

	Hooks:PostHook(TeamAIInventory,"init","lasersplus_on_teammaiinventory_init",function(self, unit)
		self._lp_unit_type = "team"
	end)

end