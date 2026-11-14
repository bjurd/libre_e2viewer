--- @class gmod_wire_expression2 : Entity
--- @field GetGateName fun(self: gmod_wire_expression2): string

util.AddNetworkString("libre_e2viewer")

net.Receive("libre_e2viewer", function(_, Player)
	if not Player:IsAdmin() then return end

	local Requested = net.ReadEntity()

	if Requested:IsValid() then
		--- @diagnostic disable-next-line
		WireLib.Expression2Download(Player, Requested, nil, true)
		return
	end

	local Chips = ents.FindByClass("gmod_wire_expression2")
	local Count = #Chips

	net.Start("libre_e2viewer")
	net.WriteUInt(Count, 32)

	for i = 1, Count do
		local Chip = Chips[i] --[[@as gmod_wire_expression2]]
		local Owner = Chip:GetCreator()

		if not Owner:IsPlayer() then
			Player:PrintMessage(HUD_PRINTTALK, Format("Chip #%d has no owner! This should never happen", i))

			net.WriteString("UNKNOWN")
		else
			--- @cast Owner Player
			net.WriteString(Owner:SteamID())
		end

		net.WriteString(Chip:GetGateName())
		net.WriteEntity(Chip)
	end

	net.Send(Player)
end)
