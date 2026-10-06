include( "InstanceManager" );
include( "SupportFunctions" );
include( "MAM_Common" );

local m_kBackgroundLayersIM :table   = InstanceManager:new( "Layer",  "Background_Anim", Controls.Backgrounds );
local m_uiBackgroundLayers :table   = {};
local m_isViewInitialized  :boolean = false;
local m_oldLeaderName       :string  = "";
local g_MAM_CurrentScenePlayerID :number = -1;

local PARALLAX_DISTANCE     :number  = 100;
local m_isTutorial          :boolean = false;
local TUTORIAL_ID           :string  = "17462E0F-1EE1-4819-AAAA-052B5896B02A";


local function MAM_PlayerFromLeaderType(leaderName:string)
	local pid = type(leaderName) == "string" and string.match(leaderName, "^LEADER_MAM_P(%d+)$") or nil;
	if pid then return tonumber(pid); end
	return nil;
end

function Parallax(distance: number)
	SizeBackgrounds();
	local numLayers = table.count(m_uiBackgroundLayers);
	if numLayers == 0 then return; end
	local spacing = distance / numLayers;
	for layer = numLayers, 1, -1 do
		if (layer == numLayers) then
			m_uiBackgroundLayers[layer].Background_Anim:SetAnchor("C,C");
			m_uiBackgroundLayers[layer].Background_Image:SetAnchor("C,C");
			m_uiBackgroundLayers[layer].Background_Anim:ReprocessAnchoring();
			m_uiBackgroundLayers[layer].Background_Image:ReprocessAnchoring();
		else
			m_uiBackgroundLayers[layer].Background_Anim:SetBeginVal(-distance, 0);
			m_uiBackgroundLayers[layer].Background_Anim:SetEndVal(0, 0);
		end
		m_uiBackgroundLayers[layer].Background_Anim:SetSpeed(.2);
		m_uiBackgroundLayers[layer].Background_Anim:SetToBeginning();
		m_uiBackgroundLayers[layer].Background_Anim:Play();
		distance = distance - spacing;
	end
end

function GenerateLayers(selectedPlayerID:number)
	if (selectedPlayerID ~= nil and selectedPlayerID >= 0) then
		g_MAM_CurrentScenePlayerID = selectedPlayerID;
	end
	local playerConfig = PlayerConfigurations[selectedPlayerID];
	if (playerConfig ~= nil) then
		m_uiBackgroundLayers = {};
		m_kBackgroundLayersIM:ResetInstances();

		local leaderName = MAM_ResolveCosmeticLeader(selectedPlayerID);
		local unloadTextures : boolean = (m_oldLeaderName ~= leaderName);
		m_oldLeaderName = leaderName;

		local diplomacyInfo = GameInfo.DiplomacyInfo[leaderName];
		if diplomacyInfo and diplomacyInfo.BackgroundImage then
			local layer:table = CreateBackgroundLayer(diplomacyInfo.BackgroundImage, unloadTextures);
			table.insert(m_uiBackgroundLayers, layer);
		else
			local leaderRow = GameInfo.Leaders[leaderName];
			local numLayers = (leaderRow and leaderRow.SceneLayers) or 0;
			local baseName = string.gsub(leaderName, "LEADER_", "");

			if (numLayers == 0) then
				baseName = "TRAJAN";
				numLayers = 4;
			end

			for i=1, numLayers, 1 do
				local layer:table = CreateBackgroundLayer(baseName .. "_" .. i, unloadTextures);
				table.insert(m_uiBackgroundLayers, layer);
			end
		end
	end
end

function CreateBackgroundLayer(texture:string, unloadTextures:boolean)
	local instance:table = m_kBackgroundLayersIM:GetInstance();
	if (unloadTextures) then
		instance.Background_Image:UnloadTexture();
	end
	instance.Background_Image:SetTexture(texture);
	return instance;
end

function SizeBackgrounds()
	local numLayers = table.count(m_uiBackgroundLayers);
	for layer = 1, numLayers, 1 do
		if (false and layer ~= numLayers) then
			m_uiBackgroundLayers[layer].Background_Anim:SetParentRelativeSizeY(-200);
			m_uiBackgroundLayers[layer].Background_Anim:ReprocessAnchoring();
			m_uiBackgroundLayers[layer].Background_Image:SetParentRelativeSizeY(-200);
			m_uiBackgroundLayers[layer].Background_Image:ReprocessAnchoring();
		end
	end
end

function OnLeaderSelect(selectedPlayerID)
	if (selectedPlayerID ~= nil and selectedPlayerID >= 0) then
		g_MAM_CurrentScenePlayerID = selectedPlayerID;
	end
	GenerateLayers(selectedPlayerID);
	Parallax(PARALLAX_DISTANCE);
end

function OnSceneOpened(selectedPlayerID, liteMode)
	if(selectedPlayerID ~= nil and selectedPlayerID >= 0) then
		g_MAM_CurrentScenePlayerID = selectedPlayerID;
		GenerateLayers(selectedPlayerID);
	end
	if (ContextPtr:IsHidden()) then
		ContextPtr:SetHide(false);
		InitializeView(liteMode);
	end
end

function InitializeView(liteMode)
	if (not m_isViewInitialized) then
		m_isViewInitialized = true;
		if (m_isTutorial == false and not liteMode) then
			UIManager:DisablePopupQueue( true );
		end
	end
end

function UninitializeView()
	if (m_isViewInitialized) then
		ContextPtr:SetHide(true);
		m_isViewInitialized = false;
		g_MAM_CurrentScenePlayerID = -1;
		UIManager:DisablePopupQueue( false );
	end
end

local m_isDispatchingLeaderScreen = false;
function OnMAMShowLeaderScreen(leaderName, isLocalPlayer)
	if m_isDispatchingLeaderScreen then return; end
	if MAM_IsConstructorLeader(leaderName) then
		m_isDispatchingLeaderScreen = true;
		local localID = (Game and Game.GetLocalPlayer and Game.GetLocalPlayer()) or 0;
		local targetPid = MAM_PlayerFromLeaderType(leaderName);
		if targetPid == nil then
			targetPid = g_MAM_CurrentScenePlayerID;
		end
		if targetPid == nil or targetPid < 0 then
			if isLocalPlayer then
				targetPid = localID;
			else
				for _, p in ipairs(PlayerManager.GetWasEverAliveMajorIDs()) do
					local pConf = PlayerConfigurations[p];
					if pConf and pConf:GetLeaderTypeName() == leaderName and p ~= localID then
						targetPid = p;
						break;
					end
				end
			end
		end
		if targetPid == nil or targetPid < 0 then
			targetPid = localID;
		end
		local cosm = MAM_ResolveCosmeticLeader(targetPid);
		Events.ShowLeaderScreen(cosm, isLocalPlayer);
		m_isDispatchingLeaderScreen = false;
	end
end

function Initialize()
	SizeBackgrounds();
	LuaEvents.DiploScene_CinemaSequence.Add(OnLeaderSelect);
	LuaEvents.DiploScene_LeaderSelect.Add(OnLeaderSelect);
	LuaEvents.DiploScene_SceneClosed.Add(UninitializeView);
	LuaEvents.DiploScene_SceneOpened.Add(OnSceneOpened);
	if Events.ShowLeaderScreen then Events.ShowLeaderScreen.Add(OnMAMShowLeaderScreen); end
	UI.SetLeaderSceneControl(Controls.LeaderScene);

	local function OnMAMLeaderPopup(firstPlayer, secondPlayer)
		local localPlayerID = (Game and Game.GetLocalPlayer and Game.GetLocalPlayer()) or 0;
		if localPlayerID == firstPlayer then
			g_MAM_CurrentScenePlayerID = secondPlayer;
		elseif localPlayerID == secondPlayer then
			g_MAM_CurrentScenePlayerID = firstPlayer;
		else
			g_MAM_CurrentScenePlayerID = firstPlayer;
		end
	end
	if Events.LeaderPopup then Events.LeaderPopup.Add(OnMAMLeaderPopup); end
	if Events.DiplomacyMeet then Events.DiplomacyMeet.Add(OnMAMLeaderPopup); end

	local function OnMAMWarLeader(actingPlayer, reactingPlayer)
		if actingPlayer ~= nil and actingPlayer >= 0 then
			g_MAM_CurrentScenePlayerID = actingPlayer;
		end
	end
	if Events.DiplomacyDeclareWar then Events.DiplomacyDeclareWar.Add(OnMAMWarLeader); end
	if Events.DiplomacyRefusePeace then Events.DiplomacyRefusePeace.Add(OnMAMWarLeader); end

	if LuaEvents.CityBannerManager_TalkToLeader then
		LuaEvents.CityBannerManager_TalkToLeader.Add(function(playerID)
			if playerID ~= nil and playerID >= 0 then
				g_MAM_CurrentScenePlayerID = playerID;
			end
		end);
	end

	LuaEvents.MAM_SetCurrentScenePlayerID.Add(function(playerID)
		if playerID ~= nil and playerID >= 0 then
			g_MAM_CurrentScenePlayerID = playerID;
		end
	end);

	local mods = Modding.GetActiveMods();
	if (mods ~= nil) then
		for i,v in ipairs(mods) do
			if v.Id == TUTORIAL_ID then
				m_isTutorial = true;
				break;
			end
		end
	end
end
Initialize();
