
include( "InputSupport" );
include( "InstanceManager" );
include( "SupportFunctions" );
include( "Civ6Common" );
include( "Colors") ;
include( "MAM_Common" );

local m_actionHotkeyStartGame		:number = Input.GetActionId("StartGame");
local m_actionHotkeyStartGameAlt	:number = Input.GetActionId("StartGameAlt");




local DARKEN_AMOUNT			:number = -25;
local MIN_BLACK_Y			:number = 2;
local SIZE_BUILDING_ICON	:number = 32;
local SIZE_CIV_LOGO_ICON	:number = 256;
local SIZE_UNIT_ICON		:number = 32;
local TIMEOUT_LOAD			:number = 1000;


local m_isLoadComplete				:boolean = false;
local m_isResyncLoad				:boolean = false;
local m_isTraitsFullDescriptions	:boolean = false;

local function MAM_TraceLoadTypes(where)
end




function OnActivateButtonClicked()
	Controls.BackgroundImage:UnloadTexture();
	Controls.Portrait:UnloadTexture();
	Events.LoadScreenClose();
	UI.PlaySound("STOP_SPEECH_DAWNOFMAN");
	UI.StartStopMenuMusic(false);
	UI.PlaySound("Game_Begin_Button_Click");
	UI.PlaySound("Set_View_3D");
	UIManager:DequeuePopup( ContextPtr );

	Input.SetActiveContext( InputContext.World );

	if(UILens.IsPlayerLensSetToActive()) then
		UILens.SetActive("Default");
	end

    UI.SetExitOnClose(false);

	if(GameConfiguration.IsPlayByCloud()) then
		local kandoConnected = FiraxisLive.IsFiraxisLiveLoggedIn();
		if(kandoConnected) then
			FiraxisLive.CheckForCloudNotifications();
		end
	end
end

function OnInput( uiMsg, wParam, lParam )
    if uiMsg == KeyEvents.KeyUp then
        if wParam == Keys.VK_ESCAPE then
			if m_isLoadComplete then
				OnActivateButtonClicked();
				return true;
			end
        end
    end
    return false;
end

function OnInputActionTriggered( actionId:number )
	if	actionId == m_actionHotkeyStartGame		or
		actionId == m_actionHotkeyStartGameAlt	then
		if m_isLoadComplete then
			OnActivateButtonClicked();
		end
	end

end

function RegisterButtonCallbacks()
	Controls.ActivateButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end );
	Controls.ActivateButton:RegisterCallback( Mouse.eLClick, OnActivateButtonClicked );
	Controls.StartLabelButton:RegisterCallback( Mouse.eLClick, OnActivateButtonClicked );
end

function ClearButtonCallbacks()
	Controls.ActivateButton:ClearCallback( Mouse.eLClick );
	Controls.ActivateButton:ClearCallback( Mouse.eMouseEnter );
	Controls.StartLabelButton:ClearCallback( Mouse.eLClick );
end

function OnShow()
	m_isLoadComplete	= false;
	m_isResyncLoad		= UI.IsResyncLoadInProgress();

	UIManager:SetUICursor( 1 );
	Controls.FadeAnim:SetToBeginning();
	Controls.ActivateButton:SetHide(true);
	Controls.LoadingContainer:SetHide(false);

	Controls.BackgroundImage:SetHide(true);
	Controls.Banner:SetHide(true);
	Controls.Portrait:SetHide(true);
	ClearButtonCallbacks();

	LuaEvents.Lower_State_Transition("LoadScreen");
end

function OnHide()
	UIManager:SetUICursor( 0 );
end

function OnInit( isReload:boolean )
	if isReload then
		OnShow();
		OnLoadScreenContentReady();
		OnLoadGameViewStateDone();
	end
end

function OnLoadScreenContentReady()
	MAM_TraceLoadTypes("content ready");

	if (GameConfiguration:IsWorldBuilderEditor()) then
		return;
	end

	if Controls.FeaturesStack then
		Controls.FeaturesStack:DestroyAllChildren();
	end

	local localPlayer	:number = Network.GetLocalPlayerID();
	if GameConfiguration.IsHotseat() then

		local maxPlayers :number = MapConfiguration.GetMaxMajorPlayers();
		for playerID = 0, maxPlayers-1,1 do
			local pPlayerConfig :table	= PlayerConfigurations[playerID];
			local slotStatus	:number = pPlayerConfig:GetSlotStatus();
			if slotStatus == SlotStatus.SS_TAKEN then
				localPlayer = playerID;
				break;
			end
		end
	end

	if localPlayer == nil or localPlayer < 0 then
		localPlayer = 0;
	end

	local primaryColor, secondaryColor  = UI.GetPlayerColors( localPlayer );

	if primaryColor == nil then
		primaryColor = UI.GetColorValueFromHexLiteral(0xff99aaaa);
		UI.DataError("NIL primary color; likely player object not ready... using default color.");
	end
	if secondaryColor == nil then
		secondaryColor = UI.GetColorValueFromHexLiteral(0xffaa9999);
		UI.DataError("NIL secondary color; likely player object not ready... using default color.");
	end

	local backColor						= UI.DarkenLightenColor(primaryColor, DARKEN_AMOUNT, 255);
	Controls.Banner:SetColor(backColor);
	local playerConfig		:table = PlayerConfigurations[localPlayer];
	if playerConfig == nil then
		UI.DataError("Received NIL playerConfig for player #"..tostring(localPlayer));
	else
		local backgroundTexture:string;
		local leaderType:string = playerConfig:GetLeaderTypeName();
		local civType:string = playerConfig:GetCivilizationTypeName();

		local isConstructor:boolean = MAM_IsConstructorLeader(leaderType);
		local cosmLeader:string = leaderType;
		local cosmCiv:string = civType;

		if isConstructor then
			cosmLeader = MAM_ResolveCosmeticLeader(localPlayer);
			cosmCiv = MAM_ResolveCosmeticCiv(localPlayer);
		end

		local loadingInfo:table = GameInfo.LoadingInfo[cosmLeader];
		if loadingInfo and loadingInfo.BackgroundImage then
			backgroundTexture = loadingInfo.BackgroundImage;
		else
			backgroundTexture = cosmLeader .. "_BACKGROUND";
		end
		Controls.BackgroundImage:SetTexture( backgroundTexture );
		if (not Controls.BackgroundImage:HasTexture()) then
			Controls.BackgroundImage:SetTexture("LEADER_TRAJAN_BACKGROUND");
		end

		if (Controls.Background:GetSizeY() < 768) then
			Controls.Banner:SetSizeY(920);
			Controls.MainStack:SetOffsetY(20);
		else
			Controls.Banner:SetSizeY(987);
			Controls.MainStack:SetOffsetY(0);
		end

		local LEADER_CONTAINER_X = 512;
		local offsetX = math.floor((Controls.Portrait:GetSizeX() - LEADER_CONTAINER_X)/2);
		if (offsetX > 0) then
			Controls.Portrait:SetOffsetX(offsetX);
		else
			Controls.Portrait:SetOffsetX(0);
		end

		local portraitName:string;
		if loadingInfo and loadingInfo.ForegroundImage then
			portraitName = loadingInfo.ForegroundImage;
		else
			portraitName = cosmLeader .. "_NEUTRAL";
		end
		Controls.Portrait:SetTexture( portraitName );
		if (not Controls.Portrait:HasTexture()) then
			Controls.Portrait:SetTexture("LEADER_TRAJAN_NEUTRAL");
		end

		if isConstructor then
			local cInfo = GameInfo.Civilizations[cosmCiv];
			local cDesc = (cInfo and cInfo.Description) or cosmCiv;
			Controls.CivName:SetText( Locale.ToUpper( Locale.Lookup(cDesc)) );
		else
			Controls.CivName:SetText( Locale.ToUpper( Locale.Lookup(playerConfig:GetCivilizationDescription())) );
		end

		local eraInfoText;
		local leaderInfoText;

		local startEra = GameInfo.Eras[ GameConfiguration.GetStartEra() ];
		if (GameConfiguration.IsSavedGame()) then
			local metaData = UI.GetSaveGameMetaData();
			if(metaData and #metaData == 1) then
				local item = metaData[1];
				local saveEra = GameInfo.Eras[ item.HostEra ];
				if(saveEra) then
					startEra = saveEra;
				end
			end
		end

		if (startEra ~= nil) then
			eraInfoText = startEra.Description;
		end

		local challengeName;
		local challengeInfoText;

		local isChallengeActive = Challenges.IsChallengeActive();
		if isChallengeActive then
			challengeName = Challenges.GetLocalizedChallengeNameText();
			challengeInfoText = Challenges.GetLocalizedChallengeLoadingScreenDescriptionText();
		end

		local kLeader	:table = GameInfo.Leaders[cosmLeader];
		local leaderName;
		if kLeader ~= nil then
			leaderName = Locale.ToUpper(Locale.Lookup( kLeader.Name ));

			local details = "LOC_LOADING_INFO_" .. cosmLeader;
			if(Locale.HasTextKey(details)) then
				leaderInfoText = details;
			end
		else
			UI.DataError("No leader in DB by leaderType '"..cosmLeader.."'");
		end

		if(challengeName) then
			Controls.LeaderName:SetText(challengeName);
		elseif(leaderName) then
			Controls.LeaderName:SetText(leaderName);
		else
			UI.DataError("No proper text for the LeaderName field");
		end
		if(loadingInfo) then
			if(loadingInfo.EraText) then
				eraInfoText = loadingInfo.EraText;
			end

			if(loadingInfo.LeaderText) then
				leaderInfoText = loadingInfo.LeaderText;
			end
		end

		if (eraInfoText) then
			Controls.EraInfo:LocalizeAndSetText(eraInfoText);
			Controls.EraInfo:SetHide(false);
		else
			Controls.EraInfo:SetHide(true);
		end

		if(challengeInfoText) then
			Controls.LeaderInfo:SetText(challengeInfoText);
			Controls.LeaderInfo:SetHide(false);
		elseif(leaderInfoText) then
			Controls.LeaderInfo:LocalizeAndSetText(leaderInfoText);
			Controls.LeaderInfo:SetHide(false);
		else
			Controls.LeaderInfo:SetHide(true);
		end

		local iconName	:string = MAM_ResolveOfficialCivIcon(cosmCiv);
		Controls.LogoContainer:SetColor(primaryColor);
		Controls.Logo:SetColor(secondaryColor);
		Controls.Logo:SetIcon(iconName);

		Controls.Logo:SetHide(false);
		Controls.BackgroundImage:SetHide(false);
		Controls.Banner:SetHide(false);
		Controls.Portrait:SetHide(false);

		local ribbonRunsPastCenter:number = 80;
		local screenWidth, screenHeight = UIManager:GetScreenSizeVal();
		local backgroundWidth, backgroundHeight = Controls.BackgroundImage:GetSizeVal();
		local minWidth = math.min(backgroundWidth, screenWidth);
		Controls.PortraitContainer:SetSizeX( (minWidth*0.5) - ribbonRunsPastCenter );

		local leaderID = playerConfig:GetLeaderTypeID();
		local bPlayDOM = true;

		if(loadingInfo) then
			bPlayDOM = loadingInfo.PlayDawnOfManAudio;
		end

		if (m_isResyncLoad) then
			bPlayDOM = false;
		end

		if bPlayDOM then
			local dawnOfManLeaderID = leaderID;
			local dawnOfManEraHash = startEra.Hash;

			if(loadingInfo and loadingInfo.DawnOfManLeaderId) then
				dawnOfManLeaderID = loadingInfo.DawnOfManLeaderId;
			end

			if(loadingInfo and loadingInfo.DawnOfManEraId) then
				dawnOfManEraHash = DB.MakeHash(loadingInfo.DawnOfManEraId);
			end

			if (Challenges.IsChallengeActive()) then
				dawnOfManLeaderID = -1;
			end

			UI.SetSoundSwitchValue("Leader_Screen_Civilization", UI.GetCivilizationSoundSwitchValueByLeader(dawnOfManLeaderID));
			UI.SetSoundSwitchValue("Civilization", UI.GetCivilizationSoundSwitchValueByLeader(dawnOfManLeaderID));
			UI.SetSoundSwitchValue("Era_DawnOfMan", UI.GetEraSoundSwitchValue(dawnOfManEraHash));
			UI.PlaySound("Play_DawnOfMan_Speech");
		end

		local uniqueAbilities = {};
		local uniqueUnits = {};
		local uniqueBuildings = {};

		if isConstructor then
			local curCivAbil = MAM_GetChoice(localPlayer, "CIV");
			local curLeadAbil = MAM_GetChoice(localPlayer, "LEADER");
			local curUnit = MAM_GetChoice(localPlayer, "UNIT");
			local curDistrict = MAM_GetChoice(localPlayer, "DISTRICT");

			local seenAbilKey = {};

			if curCivAbil and curCivAbil ~= "NONE" then
				local civAbils, _, _ = GetCivilizationUniqueTraits( curCivAbil );
				if civAbils and #civAbils > 0 then
					for _, ab in ipairs(civAbils) do
						local k = ab.TraitType or ab.Name;
						if k and not seenAbilKey[k] then
							seenAbilKey[k] = true;
							table.insert(uniqueAbilities, ab);
						end
					end
				else
					local cRow = GameInfo.Civilizations[curCivAbil];
					if cRow and not seenAbilKey[cRow.Name] then
						seenAbilKey[cRow.Name] = true;
						table.insert(uniqueAbilities, { Name = cRow.Name, Description = cRow.Description });
					end
				end
			end

			if curLeadAbil and curLeadAbil ~= "NONE" then
				local leadAbils, _, _ = GetLeaderUniqueTraits( curLeadAbil );
				if leadAbils and #leadAbils > 0 then
					for _, ab in ipairs(leadAbils) do
						local k = ab.TraitType or ab.Name;
						if k and not seenAbilKey[k] then
							seenAbilKey[k] = true;
							table.insert(uniqueAbilities, ab);
						end
					end
				else
					local lRow = GameInfo.Leaders[curLeadAbil];
					if lRow and not seenAbilKey[lRow.Name] then
						seenAbilKey[lRow.Name] = true;
						table.insert(uniqueAbilities, { Name = lRow.Name, Description = lRow.Description });
					end
				end
			end

			if curUnit and curUnit ~= "NONE" then
				local uRow = GameInfo.Units[curUnit];
				if uRow then
					table.insert(uniqueUnits, {
						Type = uRow.UnitType,
						Name = uRow.Name,
						Description = uRow.Description
					});
				end
			end

			if curDistrict and curDistrict ~= "NONE" then
				local dRow = GameInfo.Districts[curDistrict];
				local bRow = (dRow == nil) and GameInfo.Buildings[curDistrict] or nil;
				local iRow = (dRow == nil and bRow == nil) and GameInfo.Improvements[curDistrict] or nil;
				local target = dRow or bRow or iRow;
				if target then
					table.insert(uniqueBuildings, {
						Type = target.DistrictType or target.BuildingType or target.ImprovementType,
						Name = target.Name,
						Description = target.Description
					});
				end
			end
		else
			uniqueAbilities, uniqueUnits, uniqueBuildings = GetLeaderUniqueTraits( leaderType );
			local CivUniqueAbilities, CivUniqueUnits, CivUniqueBuildings = GetCivilizationUniqueTraits( civType );
			for i,v in ipairs(CivUniqueAbilities)	do table.insert(uniqueAbilities, v) end
			for i,v in ipairs(CivUniqueUnits)		do table.insert(uniqueUnits, v)		end
			for i,v in ipairs(CivUniqueBuildings)	do table.insert(uniqueBuildings, v)	end
		end

		if isConstructor and #uniqueAbilities == 0 and #uniqueUnits == 0 and #uniqueBuildings == 0 then
			local instance:table = {};
			ContextPtr:BuildInstanceForControl("TextInfoInstance", instance, Controls.FeaturesStack );
			instance.Header:SetText( Locale.ToUpper(Locale.Lookup("LOC_MAM_UI_CLEAR_ALL")) );
			instance.Description:SetText( Locale.Lookup("LOC_MAM_UI_CLEAR_ALL_DESC") );
		end

		local seenTextKeys = {};
		for _, item in ipairs(uniqueAbilities) do
			local rawName = item.Name or "";
			local rawDesc = item.Description or "";
			local nameStr = (rawName ~= "" and rawName ~= "NONE") and Locale.Lookup(rawName) or "";
			local descStr = (rawDesc ~= "" and rawDesc ~= "NONE") and Locale.Lookup(rawDesc) or "";
			local textKey = nameStr .. "::" .. descStr;
			if textKey ~= "::" and not seenTextKeys[textKey] then
				seenTextKeys[textKey] = true;
				local instance:table = {};
				ContextPtr:BuildInstanceForControl("TextInfoInstance", instance, Controls.FeaturesStack );
				if nameStr ~= "" then
					instance.Header:SetText( Locale.ToUpper(nameStr) );
					instance.Header:SetShow(true);
				else
					instance.Header:SetShow(false);
				end

				if descStr ~= "" then
					instance.Description:SetText( descStr );
					instance.Description:SetShow(true);
				else
					instance.Description:SetShow(false);
				end
			end
		end

		local size:number = SIZE_BUILDING_ICON;
		local seenUnits = {};
		for _, item in ipairs(uniqueUnits) do
			if item and item.Type and not seenUnits[item.Type] then
				seenUnits[item.Type] = true;
				local instance:table = {};
				ContextPtr:BuildInstanceForControl("IconInfoInstance", instance, Controls.FeaturesStack );
				local iconAtlas = "ICON_"..item.Type;
				instance.Icon:SetIcon(iconAtlas);
				instance.TextStack:SetOffsetX( size + 4 );
				local headerText:string = Locale.ToUpper(Locale.Lookup( item.Name ));
				instance.Header:SetText( headerText );
				instance.Description:SetText(Locale.Lookup(item.Description));
			end
		end

		local seenBuildings = {};
		for _, item in ipairs(uniqueBuildings) do
			if item and item.Type and not seenBuildings[item.Type] then
				seenBuildings[item.Type] = true;
				local instance:table = {};
				ContextPtr:BuildInstanceForControl("IconInfoInstance", instance, Controls.FeaturesStack );
				instance.Icon:SetSizeVal(38,38);
				local iconAtlas = "ICON_"..item.Type;
				instance.Icon:SetIcon(iconAtlas);
				instance.TextStack:SetOffsetX( size + 4 );
				local headerText:string = Locale.ToUpper(Locale.Lookup( item.Name ));
				instance.Header:SetText( headerText );
				instance.Description:SetText(Locale.Lookup(item.Description));
			end
		end
	end
end

function OnBeforeMultiplayerInviteProcessing()
	UIManager:DequeuePopup( ContextPtr );
end

function OnLoadGameViewStateDone()
	m_isLoadComplete = true;
	print("OnLoadGameViewStateDone");
	UIManager:SetUICursor( 0 );
	if m_isResyncLoad or GameConfiguration.IsAnyMultiplayer() or GameConfiguration:IsWorldBuilderEditor() then
		OnActivateButtonClicked();
	else
		local strGameButtonName;


		if (GameConfiguration.IsSavedGame()) then
			strGameButtonName = Locale.Lookup("LOC_CONTINUE_GAME");
		else
			strGameButtonName = Locale.Lookup("LOC_BEGIN_GAME");
		end

		Controls.StartLabelButton:SetText(strGameButtonName);
		Controls.ActivateButton:SetHide(false);
		Controls.LoadingContainer:SetHide(true);
		Controls.FadeAnim:SetToBeginning();
		Controls.FadeAnim:Play();
		UI.PlaySound("Game_Begin_Button_Appear");
		Input.SetActiveContext( InputContext.Ready );

		local bAuto = Automation.IsAutoStartEnabled() or (GameConfiguration and GameConfiguration.GetValue("MAM_AUTO_TEST") == 1);
		if bAuto then
			OnActivateButtonClicked();
		end
	end
	RegisterButtonCallbacks();

	ContextPtr:SetInputHandler( OnInput );
	Events.InputActionTriggered.Add( OnInputActionTriggered );
end


function Initialize()
	MAM_TraceLoadTypes("init");

	Input.SetActiveContext( InputContext.Loading );

	ContextPtr:SetInitHandler( OnInit );
	ContextPtr:SetShowHandler( OnShow );
	ContextPtr:SetHideHandler( OnHide );

	Events.LoadScreenContentReady.Add( OnLoadScreenContentReady );
	Events.LoadGameViewStateDone.Add( OnLoadGameViewStateDone );
	Events.BeforeMultiplayerInviteProcessing.Add( OnBeforeMultiplayerInviteProcessing );

    UI.SetExitOnClose(true);
end
Initialize();
