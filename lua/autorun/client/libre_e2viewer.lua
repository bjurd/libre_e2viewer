--- @type DFrame
local Viewer = nil
--- @type DListView
local List = nil

local function RefreshViewer()
	net.Start("libre_e2viewer")
	net.SendToServer()
end

local function ReceiveRefresh()
	if not IsValid(List) then
		return
	end

	List:Clear()

	local Count = net.ReadUInt(32)

	for i = 1, Count do
		local SteamID = net.ReadString()
		local Chip = net.ReadString()

		local DisplayName = SteamID
		local Player = player.GetBySteamID(SteamID)

		if Player then
			--- @cast Player Player
			DisplayName = Format("%s (%s)", Player:Nick(), Player:SteamID())
		end

		List:AddLine(DisplayName, Chip)
	end
end

local function MakeViewer()
	if IsValid(Viewer) then
		Viewer:SetSize(640, 480)
		Viewer:Center()

		RefreshViewer()

		return
	end

	Viewer = vgui.Create("DFrame")
	Viewer:SetTitle("E2 Viewer")
	Viewer:SetDraggable(true)
	Viewer:SetSizable(true)

	Viewer:SetSize(640, 480)
	Viewer:Center()

	local Top = vgui.Create("EditablePanel", Viewer)
	Top:SetPaintBackgroundEnabled(false)
	Top:SetPaintBorderEnabled(false)
	Top:Dock(TOP)
	Top:SetHeight(24)

	--- @class DButton LuaLS aids
	local Refresh = vgui.Create("DButton", Top)
	Refresh:Dock(RIGHT)
	Refresh:SetWide(100)
	Refresh.DoClick = RefreshViewer

	if IsValid(List) then
		List:Remove()
	end
	List = vgui.Create("DListView", Viewer)
	List:Dock(FILL)

	List:AddColumn("Player")
	List:AddColumn("Chip")

	Viewer:MakePopup()

	RefreshViewer()
end

do
	concommand.Add("libre_e2viewer", function(Player)
		if not Player:IsAdmin() then
			Player:PrintMessage(HUD_PRINTTALK, "Admen only, fren")
			return
		end

		MakeViewer()
	end)

	net.Receive("libre_e2viewer", ReceiveRefresh)
end
