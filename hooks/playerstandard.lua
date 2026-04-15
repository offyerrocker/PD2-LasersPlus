Hooks:PostHook(PlayerStandard,"_toggle_gadget","lp_playerstandard_toggle_gadget",function(self,weap_base)
	if LasersPlus:IsGadgetNetworkSyncEnabled() then
		LasersPlus:SyncTemplatesToPeers()
	end
end)