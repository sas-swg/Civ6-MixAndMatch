if MAM_COMMON_LOADED then return; end
MAM_COMMON_LOADED = true;

local MAM_SLOT_KEYS = {
	CIV         = "MAM_CIV_ABILITY",
	LEADER      = "MAM_LEADER_ABILITY",
	UNIT        = "MAM_UNIQUE_UNIT",
	DISTRICT    = "MAM_UNIQUE_DISTRICT",
	COSM_CIV    = "MAM_COSMETIC_CIV",
	COSM_LEADER = "MAM_COSMETIC_LEADER",
	MYSTERY     = "MAM_IS_MYSTERY",
};

function MAM_IsConstructorLeader(leaderType)
	return type(leaderType) == "string" and string.find(leaderType, "^LEADER_MAM_") ~= nil;
end

function MAM_IsConstructorCiv(civType)
	return type(civType) == "string" and string.find(civType, "^CIVILIZATION_MAM_") ~= nil;
end

function MAM_IsConstructorPlayer(playerID)
	if playerID == nil or playerID < 0 then return false; end
	local cfg = PlayerConfigurations[playerID];
	return cfg ~= nil and MAM_IsConstructorLeader(cfg:GetLeaderTypeName());
end

local function IsUnset(v)
	return v == nil or v == "" or v == "NONE" or v == "RANDOM";
end

function MAM_GetChoice(playerID, key)
	local v = nil;
	if playerID ~= nil and playerID >= 0 then
		v = GameConfiguration.GetValue("MAM_P" .. tostring(playerID) .. "_" .. key);
		if IsUnset(v) then
			local cfg = PlayerConfigurations[playerID];
			local cfgKey = MAM_SLOT_KEYS[key];
			if cfg and cfgKey then
				v = cfg:GetValue(cfgKey);
			end
		end
	end
	if IsUnset(v) then return "NONE"; end
	return v;
end

function MAM_IsMystery(playerID)
	return MAM_GetChoice(playerID, "MYSTERY") == "TRUE";
end

function MAM_ResolveCosmeticLeader(playerID)
	local cfg = PlayerConfigurations[playerID];
	if cfg == nil then return "LEADER_TRAJAN"; end
	local leaderName = cfg:GetLeaderTypeName();
	if not MAM_IsConstructorLeader(leaderName) then
		return leaderName;
	end
	local cosm = MAM_GetChoice(playerID, "COSM_LEADER");
	if (cosm == "NONE" or MAM_IsConstructorLeader(cosm)) and not MAM_IsMystery(playerID) then
		cosm = MAM_GetChoice(playerID, "LEADER");
	end
	if (cosm == "NONE" or MAM_IsConstructorLeader(cosm)) and not MAM_IsMystery(playerID) then
		local civ = MAM_GetChoice(playerID, "CIV");
		if civ ~= "NONE" and not MAM_IsConstructorCiv(civ) and GameInfo.CivilizationLeaders then
			for row in GameInfo.CivilizationLeaders() do
				if row.CivilizationType == civ and row.LeaderType and GameInfo.Leaders[row.LeaderType] then
					cosm = row.LeaderType;
					break;
				end
			end
		end
	end
	if cosm == "NONE" or MAM_IsConstructorLeader(cosm) or GameInfo.Leaders[cosm] == nil then
		cosm = "LEADER_TRAJAN";
	end
	return cosm;
end

function MAM_ResolveCosmeticCiv(playerID)
	local cfg = PlayerConfigurations[playerID];
	if cfg == nil then return "CIVILIZATION_ROME"; end
	local civName = cfg:GetCivilizationTypeName();
	if not (MAM_IsConstructorCiv(civName) or MAM_IsConstructorLeader(cfg:GetLeaderTypeName())) then
		return civName;
	end
	local cosm = MAM_GetChoice(playerID, "COSM_CIV");
	if (cosm == "NONE" or MAM_IsConstructorCiv(cosm)) and not MAM_IsMystery(playerID) then
		cosm = MAM_GetChoice(playerID, "CIV");
	end
	if (cosm == "NONE" or MAM_IsConstructorCiv(cosm)) and not MAM_IsMystery(playerID) then
		local leader = MAM_GetChoice(playerID, "LEADER");
		if leader ~= "NONE" and not MAM_IsConstructorLeader(leader) and GameInfo.CivilizationLeaders then
			for row in GameInfo.CivilizationLeaders() do
				if row.LeaderType == leader and row.CivilizationType and GameInfo.Civilizations[row.CivilizationType] then
					cosm = row.CivilizationType;
					break;
				end
			end
		end
	end
	if cosm == "NONE" or MAM_IsConstructorCiv(cosm) or GameInfo.Civilizations[cosm] == nil then
		cosm = "CIVILIZATION_ROME";
	end
	return cosm;
end

function MAM_CanLocalSee(playerID)
	local localID = Game.GetLocalPlayer();
	if localID == nil or localID < 0 then return false; end
	if playerID == localID then return true; end
	local pLocal = Players[localID];
	if pLocal == nil or pLocal:GetDiplomacy() == nil then return false; end
	return pLocal:GetDiplomacy():HasMet(playerID);
end

function MAM_ResolveOfficialCiv(civType)
	if civType == "CIVILIZATION_MIXMATCH_WARMACHINE_GERMANY" then return "CIVILIZATION_GERMANY";
	elseif civType == "CIVILIZATION_MIXMATCH_WARMACHINE_FRANCE" then return "CIVILIZATION_FRANCE";
	elseif civType == "CIVILIZATION_MIXMATCH_RADZIWILL" or civType == "CIVILIZATION_MIXMATCH_POTOCKI" or civType == "CIVILIZATION_MIXMATCH_OSTROGSKI" then return "CIVILIZATION_POLAND";
	elseif civType == "CIVILIZATION_MIXMATCH_DENMARK" then return "CIVILIZATION_NORWAY";
	elseif civType == "CIVILIZATION_MIXMATCH_QUEENSLAND" or civType == "CIVILIZATION_MIXMATCH_WESTERN_AUSTRALIA" then return "CIVILIZATION_AUSTRALIA";
	elseif civType == "CIVILIZATION_PERSIA" then return "CIVILIZATION_PERSIA";
	end
	return civType;
end

function MAM_ResolveOfficialLeader(leaderType)
	if leaderType == "LEADER_MIXMATCH_WARMACHINE_GERMANY" then return "LEADER_BARBAROSSA";
	elseif leaderType == "LEADER_MIXMATCH_WARMACHINE_FRANCE" then return "LEADER_CATHERINE_DE_MEDICI";
	elseif leaderType == "LEADER_MIXMATCH_RADZIWILL" or leaderType == "LEADER_MIXMATCH_POTOCKI" or leaderType == "LEADER_MIXMATCH_OSTROGSKI" then return "LEADER_JADWIGA";
	elseif leaderType == "LEADER_MIXMATCH_CNUT" or leaderType == "LEADER_MIXMATCH_OLOF" or leaderType == "LEADER_MIXMATCH_HARDRADA_SCENARIO" then return "LEADER_HARDRADA";
	elseif leaderType == "LEADER_MIXMATCH_QUEENSLAND" or leaderType == "LEADER_MIXMATCH_WESTERN_AUSTRALIA" then return "LEADER_JOHN_CURTIN";
	elseif leaderType == "LEADER_MIXMATCH_DARIUS_III" then return "LEADER_CYRUS";
	end
	return leaderType;
end

function MAM_ResolveOfficialCivIcon(civType)
	local official = MAM_ResolveOfficialCiv(civType);
	if type(official) == "string" and string.sub(official, 1, 5) == "ICON_" then return official; end
	return "ICON_" .. tostring(official);
end

function MAM_ResolveOfficialLeaderIcon(leaderType)
	local official = MAM_ResolveOfficialLeader(leaderType);
	if type(official) == "string" and string.sub(official, 1, 5) == "ICON_" then return official; end
	return "ICON_" .. tostring(official);
end
