include("TeamSupport");
include("DiplomacyRibbonSupport");
include("MAM_Common");

LeaderIcon = {
	playerID = -1,
	TEAM_RIBBON_PREFIX	= "ICON_TEAM_RIBBON_"
}


function LeaderIcon:GetInstance(instanceManager:table, uiNewParent:table)
	local instance:table = instanceManager:GetInstance(uiNewParent);
	return LeaderIcon:AttachInstance(instance);
end

function LeaderIcon:AttachInstance( instance:table )
	if instance == nil then
		UI.DataError("NIL instance passed into LeaderIcon:AttachInstance.  Setting the value to the ContextPtr's 'Controls'.");
		instance = Controls;

	end
	setmetatable(instance, {__index = self });
	self.Controls = instance;
	self:Reset();
	return instance;
end



local function MAM_GetDisplayInfo(playerID:number)
	if playerID == nil or playerID < 0 or not MAM_IsConstructorPlayer(playerID) then
		return false, false, nil, nil;
	end
	local canSee:boolean = MAM_CanLocalSee(playerID);
	return true, canSee, MAM_ResolveCosmeticLeader(playerID), MAM_ResolveCosmeticCiv(playerID);
end

local function MAM_SetCivIndicator(self, playerID:number, civType:string)
	local backColor, frontColor = UI.GetPlayerColors( playerID );
	self.Controls.CivIndicator:SetHide(false);
	if backColor then self.Controls.CivIndicator:SetColor(backColor); end
	self.Controls.CivIcon:SetHide(false);
	if frontColor then self.Controls.CivIcon:SetColor(frontColor); end
	self.Controls.CivIcon:SetIcon(MAM_ResolveOfficialCivIcon(civType));
end

function LeaderIcon:UpdateIcon(iconName: string, playerID: number, isUniqueLeader: boolean, ttDetails: string)
	LeaderIcon.playerID = playerID;

	local pPlayerConfig:table = PlayerConfigurations[playerID];
	local localPlayerID:number = Game.GetLocalPlayer();

	local isConstructor:boolean, canSee:boolean, cosmLeader:string, cosmCiv:string = MAM_GetDisplayInfo(playerID);
	if isConstructor and canSee then
		iconName = MAM_ResolveOfficialLeaderIcon(cosmLeader);
	end

	if isConstructor then
		if canSee then
			MAM_SetCivIndicator(self, playerID, cosmCiv);
		else
			self.Controls.CivIcon:SetHide(true);
			self.Controls.CivIndicator:SetHide(true);
		end
	elseif isUniqueLeader == false and (playerID == localPlayerID or (localPlayerID >= 0 and Players[localPlayerID] ~= nil and Players[localPlayerID]:GetDiplomacy():HasMet(playerID))) then
		local backColor, frontColor  = UI.GetPlayerColors( playerID );
		self.Controls.CivIndicator:SetHide(false);
		self.Controls.CivIndicator:SetColor(backColor);
		self.Controls.CivIcon:SetHide(false);
		self.Controls.CivIcon:SetColor(frontColor);
		self.Controls.CivIcon:SetIcon("ICON_"..pPlayerConfig:GetCivilizationTypeName());
	else
		self.Controls.CivIcon:SetHide(true);
		self.Controls.CivIndicator:SetHide(true);
	end
	self.Controls.Portrait:SetIcon(iconName);
	self.Controls.YouIndicator:SetHide(playerID ~= localPlayerID);

	local tooltip:string = self:GetToolTipString(playerID);
	if (ttDetails ~= nil and ttDetails ~= "") then
		tooltip = tooltip .. "[NEWLINE]" .. ttDetails;
	end
	self.Controls.Portrait:SetToolTipString(tooltip);

	self:UpdateTeamAndRelationship(playerID);
end

function LeaderIcon:UpdateIconSimple(iconName: string, playerID: number, isUniqueLeader: boolean, ttDetails: string)

	LeaderIcon.playerID = playerID;

	local localPlayerID:number = Game.GetLocalPlayer();
	local isConstructor:boolean, canSee:boolean, cosmLeader:string, cosmCiv:string = MAM_GetDisplayInfo(playerID);
	if isConstructor and canSee then
		iconName = MAM_ResolveOfficialLeaderIcon(cosmLeader);
	end

	self.Controls.Portrait:SetIcon(iconName);
	self.Controls.YouIndicator:SetHide(playerID ~= localPlayerID);

	if isConstructor then
		if canSee then
			MAM_SetCivIndicator(self, playerID, cosmCiv);
		else
			self.Controls.CivIcon:SetHide(true);
			self.Controls.CivIndicator:SetHide(true);
		end
	elseif isUniqueLeader == false and (playerID ~= -1 and localPlayerID >= 0 and Players[localPlayerID] ~= nil and Players[localPlayerID]:GetDiplomacy():HasMet(playerID)) then
		local backColor, frontColor = UI.GetPlayerColors( playerID );
		self.Controls.CivIndicator:SetHide(false);
		self.Controls.CivIndicator:SetColor(backColor);
		self.Controls.CivIcon:SetHide(false);
		self.Controls.CivIcon:SetColor(frontColor);
		self.Controls.CivIcon:SetIcon(MAM_ResolveOfficialCivIcon(PlayerConfigurations[playerID]:GetCivilizationTypeName()));
	else
		self.Controls.CivIcon:SetHide(true);
		self.Controls.CivIndicator:SetHide(true);
	end

	if playerID < 0 then
		self.Controls.TeamRibbon:SetHide(true);
		self.Controls.Relationship:SetHide(true);
		self.Controls.Portrait:SetToolTipString("");
		return;
	end

	local tooltip:string = self:GetToolTipString(playerID);
	if (ttDetails ~= nil and ttDetails ~= "") then
		tooltip = tooltip .. "[NEWLINE]" .. ttDetails;
	end
	self.Controls.Portrait:SetToolTipString(tooltip);

	self:UpdateTeamAndRelationship(playerID);
end

function LeaderIcon:UpdateTeamAndRelationship( playerID: number)

	local localPlayerID	:number = Game.GetLocalPlayer();
	if localPlayerID == PlayerTypes.NONE or playerID == PlayerTypes.OBSERVER then return; end

	if GameCapabilities.HasCapability("CAPABILITY_DISPLAY_HUD_RIBBON_RELATIONSHIPS") == false then
		self.Controls.Relationship:SetHide( true );
		return;
	end
	if playerID < 0 then
		UI.DataError("Invalid playerID="..tostring(playerID).." to check against for UpdateTeamAndRelationship().");
		return;
	end

	local pPlayer		:table = Players[playerID];
	local pPlayerConfig	:table = PlayerConfigurations[playerID];
	local isHuman		:boolean = pPlayerConfig:IsHuman();
	local isSelf		:boolean = (playerID == localPlayerID);
	local isMet			:boolean = Players[localPlayerID]:GetDiplomacy():HasMet(playerID);

	local isTeamRibbonHidden:boolean = true;
	if(isSelf or isMet) then
		local teamID:number = pPlayerConfig:GetTeam();
		if #Teams[teamID] > 1 then
			local teamRibbonName:string = self.TEAM_RIBBON_PREFIX .. tostring(teamID);
			self.Controls.TeamRibbon:SetIcon(teamRibbonName);
			self.Controls.TeamRibbon:SetColor(GetTeamColor(teamID));
			isTeamRibbonHidden = false;
		end
	end
	self.Controls.TeamRibbon:SetHide(isTeamRibbonHidden);

	local eRelationship :number = pPlayer:GetDiplomaticAI():GetDiplomaticStateIndex(localPlayerID);
	local relationType	:string = GameInfo.DiplomaticStates[eRelationship].StateType;
	local isValid		:boolean= (isHuman and Relationship.IsValidWithHuman( relationType )) or (not isHuman and Relationship.IsValidWithAI( relationType ));
	if isValid then
		self.Controls.Relationship:SetVisState(eRelationship);
		if (GameInfo.DiplomaticStates[eRelationship].Hash ~= DiplomaticStates.NEUTRAL) then
			self.Controls.Relationship:SetToolTipString(Locale.Lookup(GameInfo.DiplomaticStates[eRelationship].Name));
		end
	end
	self.Controls.Relationship:SetHide( not isValid );
end

function LeaderIcon:Reset()
	if self.Controls == nil then
		UI.DataError("Attempting to call Reset() on a nil LeaderIcon.");
		return;
	end
	self.Controls.TeamRibbon:SetHide(true);
 	self.Controls.Relationship:SetHide(true);
 	self.Controls.YouIndicator:SetHide(true);
end

function LeaderIcon:RegisterCallback(event: number, func: ifunction)
	self.Controls.SelectButton:RegisterCallback(event, func);
end

function LeaderIcon:GetToolTipString(playerID:number)

	local result:string = "";
	local pPlayerConfig:table = PlayerConfigurations[playerID];
	local localPlayerID:number = Game.GetLocalPlayer();

	if pPlayerConfig and pPlayerConfig:GetLeaderTypeName() then
		local isHuman		:boolean = pPlayerConfig:IsHuman();
		local leaderDesc	:string = pPlayerConfig:GetLeaderName();
		local civDesc		:string = pPlayerConfig:GetCivilizationDescription();

		local mamDetails:string = nil;
		local isConstructor:boolean, canSee:boolean, cosmLeader:string, cosmCiv:string = MAM_GetDisplayInfo(playerID);
		if isConstructor and canSee then
			local cRow = GameInfo.Civilizations[cosmCiv];
			local lRow = GameInfo.Leaders[cosmLeader];
			if lRow then leaderDesc = lRow.Name; end
			if cRow then civDesc = cRow.Description; end

			if playerID == localPlayerID or not MAM_IsMystery(playerID) then
				local details = {};
				local curCiv  = MAM_GetChoice(playerID, "CIV");
				local curLead = MAM_GetChoice(playerID, "LEADER");
				local curUnit = MAM_GetChoice(playerID, "UNIT");
				local curDist = MAM_GetChoice(playerID, "DISTRICT");
				local cInfo = (curCiv ~= "NONE") and GameInfo.Civilizations[curCiv] or nil;
				if cInfo then table.insert(details, "[ICON_Bullet] " .. Locale.Lookup("LOC_MAM_UI_CIV_HEADER") .. ": " .. Locale.Lookup(cInfo.Name)); end
				local lInfo = (curLead ~= "NONE") and GameInfo.Leaders[curLead] or nil;
				if lInfo then table.insert(details, "[ICON_Bullet] " .. Locale.Lookup("LOC_MAM_UI_LEADER_HEADER") .. ": " .. Locale.Lookup(lInfo.Name)); end
				local uInfo = (curUnit ~= "NONE") and GameInfo.Units[curUnit] or nil;
				if uInfo then table.insert(details, "[ICON_Bullet] " .. Locale.Lookup("LOC_MAM_UI_UNIT_HEADER") .. ": " .. Locale.Lookup(uInfo.Name)); end
				local dInfo = nil;
				if curDist ~= "NONE" then
					dInfo = GameInfo.Districts[curDist] or GameInfo.Buildings[curDist] or GameInfo.Improvements[curDist];
				end
				if dInfo then table.insert(details, "[ICON_Bullet] " .. Locale.Lookup("LOC_MAM_UI_DISTRICT_HEADER") .. ": " .. Locale.Lookup(dInfo.Name)); end
				if #details > 0 then
					mamDetails = table.concat(details, "[NEWLINE]");
				end
			end
		end

		if localPlayerID==PlayerTypes.NONE or localPlayerID==PlayerTypes.OBSERVER  then
			return "";
		end

		if GameConfiguration.IsAnyMultiplayer() and isHuman then
			if(playerID ~= localPlayerID and not Players[localPlayerID]:GetDiplomacy():HasMet(playerID)) then
				result = Locale.Lookup("LOC_DIPLOPANEL_UNMET_PLAYER") .. " (" .. pPlayerConfig:GetPlayerName() .. ")";
			else
				result = Locale.Lookup("LOC_DIPLOMACY_DEAL_PLAYER_PANEL_TITLE", leaderDesc, civDesc) .. " (" .. pPlayerConfig:GetPlayerName() .. ")";
			end
		else
			if(playerID ~= localPlayerID and not Players[localPlayerID]:GetDiplomacy():HasMet(playerID)) then
				result = Locale.Lookup("LOC_DIPLOPANEL_UNMET_PLAYER");
			else
				result = Locale.Lookup("LOC_DIPLOMACY_DEAL_PLAYER_PANEL_TITLE", leaderDesc, civDesc);
			end
		end

		if mamDetails then
			result = result .. "[NEWLINE]--------------------------------[NEWLINE]" .. mamDetails;
		end
	end

	return result;
end

function LeaderIcon:AppendTooltip( extraText:string )
	if extraText == nil or extraText == "" then return; end
	local tooltip:string = self:GetToolTipString(self.playerID) .. "[NEWLINE]" .. extraText;
	self.Controls.Portrait:SetToolTipString(tooltip);
end
