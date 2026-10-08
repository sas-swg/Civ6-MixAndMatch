
if g_MAM_DiplomacyActionView_Loaded then
	return;
end
g_MAM_DiplomacyActionView_Loaded = true;

local bQuickDeals = false;
if Modding and Modding.IsModActive then
	bQuickDeals = Modding.IsModActive("5aceed03-8639-4a81-8cbf-03f54d543502");
end

local function SafeInclude(name)
	local ok = pcall(function() include(name); end);
	if not ok then
		ok = pcall(function() include(name .. ".lua"); end);
	end
	return ok;
end

local bLoaded = false;
if bQuickDeals then
	if SafeInclude("diplomacyactionview_qd.lua") or SafeInclude("diplomacyactionview_qd") or SafeInclude("ui/diplomacyactionview_qd") then
		if Initialize then
			bLoaded = true;
		end
	end
end

if not bLoaded then
	local files = {
		"DiplomacyActionView_Expansion2",
		"DiplomacyActionView_Expansion1",
		"DiplomacyActionView"
	};
	for _, file in ipairs(files) do
		if SafeInclude(file) and Initialize then
			bLoaded = true;
			break;
		end
	end
end

local function SetFunctionUpvalue(func, varName, value)
	if debug and debug.getupvalue and debug.setupvalue and func then
		local i = 1;
		while true do
			local name, _ = debug.getupvalue(func, i);
			if not name then break; end
			if name == varName then
				debug.setupvalue(func, i, value);
				return true;
			end
			i = i + 1;
		end
	end
	return false;
end

local function GetFunctionUpvalue(func, varName)
	if debug and debug.getupvalue and func then
		local i = 1;
		while true do
			local name, val = debug.getupvalue(func, i);
			if not name then break; end
			if name == varName then
				return val;
			end
			i = i + 1;
		end
	end
	return nil;
end

include("MAM_Common");

local m_MAM_showingLeaderName = "";
local BASE_MAM_ShowLeader = ShowLeader;
function ShowLeader(player : table)
	if player ~= nil then
		local pID = player:GetID();
		if LuaEvents.MAM_SetCurrentScenePlayerID then
			LuaEvents.MAM_SetCurrentScenePlayerID(pID);
		end
		local pConfig = PlayerConfigurations[pID];
		if pConfig ~= nil then
			local leaderName = pConfig:GetLeaderTypeName();
			if MAM_IsConstructorLeader(leaderName) then
				local cosmLeader = MAM_ResolveCosmeticLeader(pID);
				local official3D = MAM_ResolveOfficialLeader(cosmLeader);
				ms_SelectedPlayerLeaderTypeName = official3D;
				SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_SelectedPlayerLeaderTypeName", official3D);
				SetFunctionUpvalue(UpdateSelectedPlayer, "ms_SelectedPlayerLeaderTypeName", official3D);

				local curShowing = GetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_showingLeaderName") or m_MAM_showingLeaderName;
				if (official3D ~= curShowing) then
					m_MAM_showingLeaderName = official3D;
					ms_showingLeaderName = official3D;
					SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_showingLeaderName", official3D);
					SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_LastDealResponseAnimation", nil);
					SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_bLeaderShowRequested", true);
					LeaderSupport_Initialize();
					Events.ShowLeaderScreen(official3D, pID == Game.GetLocalPlayer());
					Controls.FallbackLeaderImage:SetHide(true);
					Controls.LeaderAlpha:SetToBeginning();
					Controls.LeaderAlpha:Play();
				else
					local isRequested = GetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_bLeaderShowRequested");
					if (not isRequested) then
						LeaderSupport_ClearInitialAnimationState();
						OnLeaderLoaded();
					end
				end
				return;
			end
		end
	end
	if BASE_MAM_ShowLeader then
		BASE_MAM_ShowLeader(player);
	end
end

local BASE_MAM_UpdateSelectedPlayer = UpdateSelectedPlayer;
function UpdateSelectedPlayer(allowDeadPlayer)
	if BASE_MAM_UpdateSelectedPlayer then
		BASE_MAM_UpdateSelectedPlayer(allowDeadPlayer);
	end
	if ms_SelectedPlayer ~= nil then
		local pID = ms_SelectedPlayer:GetID();
		if LuaEvents.MAM_SetCurrentScenePlayerID then
			LuaEvents.MAM_SetCurrentScenePlayerID(pID);
		end
		local pConfig = PlayerConfigurations[pID];
		if pConfig ~= nil then
			local lType = pConfig:GetLeaderTypeName();
			if MAM_IsConstructorLeader(lType) then
				local cosmLeader = MAM_ResolveCosmeticLeader(pID);
				local cosmCiv = MAM_ResolveCosmeticCiv(pID);
				local official3D = MAM_ResolveOfficialLeader(cosmLeader);
				ms_SelectedPlayerLeaderTypeName = official3D;
				SetFunctionUpvalue(BASE_MAM_UpdateSelectedPlayer, "ms_SelectedPlayerLeaderTypeName", official3D);

				local localID = (Game and Game.GetLocalPlayer and Game.GetLocalPlayer()) or 0;
				if pID == localID then
					local lRow = GameInfo.Leaders[cosmLeader] or GameInfo.Leaders[official3D];
					local cRow = GameInfo.Civilizations[cosmCiv];
					if lRow and Controls.PlayerNameText then
						Controls.PlayerNameText:LocalizeAndSetText(Locale.ToUpper(Locale.Lookup(lRow.Name)));
					end
					if cRow and Controls.CivNameText then
						Controls.CivNameText:LocalizeAndSetText(Locale.ToUpper(Locale.Lookup(cRow.Description)));
					end
				end
			end
		end
	end
end

local BASE_MAM_PopulatePlayerPanelHeader = PopulatePlayerPanelHeader;
function PopulatePlayerPanelHeader(rootControl : table, player : table)
	if BASE_MAM_PopulatePlayerPanelHeader then
		BASE_MAM_PopulatePlayerPanelHeader(rootControl, player);
	end
	if player ~= nil and rootControl ~= nil then
		local pID = player:GetID();
		local pConfig = PlayerConfigurations[pID];
		if pConfig ~= nil then
			local lType = pConfig:GetLeaderTypeName();
			if MAM_IsConstructorLeader(lType) then
				local cosmLeader = MAM_ResolveCosmeticLeader(pID);
				local cosmCiv = MAM_ResolveCosmeticCiv(pID);
				local official3D = MAM_ResolveOfficialLeader(cosmLeader);
				local lRow = GameInfo.Leaders[cosmLeader] or GameInfo.Leaders[official3D];
				local cRow = GameInfo.Civilizations[cosmCiv];
				if lRow and rootControl.PlayerNameText then
					rootControl.PlayerNameText:LocalizeAndSetText(Locale.ToUpper(Locale.Lookup(lRow.Name)));
				end
				if cRow and rootControl.CivNameText then
					rootControl.CivNameText:LocalizeAndSetText(Locale.ToUpper(Locale.Lookup(cRow.Description)));
				end
				if rootControl.CivIcon and rootControl.CivIcon.CivIcon then
					local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas("ICON_" .. cosmCiv, rootControl.CivIcon.CivIcon:GetSizeX());
					if textureSheet and textureSheet ~= "" then
						rootControl.CivIcon.CivIcon:SetTexture(textureOffsetX, textureOffsetY, textureSheet);
					end
				end
			end
		end
	end
end

local BASE_MAM_OnDiplomacyStatement = OnDiplomacyStatement;
function OnDiplomacyStatement(fromPlayer:number, toPlayer:number, kVariants:table)
	if fromPlayer ~= nil and LuaEvents.MAM_SetCurrentScenePlayerID then
		LuaEvents.MAM_SetCurrentScenePlayerID(fromPlayer);
	end
	if BASE_MAM_OnDiplomacyStatement then
		BASE_MAM_OnDiplomacyStatement(fromPlayer, toPlayer, kVariants);
	end
	if MAM_IsConstructorLeader(ms_OtherLeaderName) then
		local localID = (Game and Game.GetLocalPlayer and Game.GetLocalPlayer()) or -1;
		local otherID = (toPlayer == localID) and fromPlayer or toPlayer;
		if otherID ~= nil and otherID >= 0 then
			local rawCosm = MAM_ResolveCosmeticLeader(otherID);
			ms_OtherLeaderName = MAM_ResolveOfficialLeader(rawCosm);
		end
	end
end


local BASE_MAM_OnHide = OnHide;
function OnHide()
	m_MAM_showingLeaderName = "";
	ms_showingLeaderName = "";
	SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_showingLeaderName", "");
	SetFunctionUpvalue(BASE_MAM_ShowLeader, "ms_bLeaderShowRequested", false);
	if BASE_MAM_OnHide then
		BASE_MAM_OnHide();
	end
end

if ContextPtr and ContextPtr.SetHideHandler then
	ContextPtr:SetHideHandler( OnHide );
end

