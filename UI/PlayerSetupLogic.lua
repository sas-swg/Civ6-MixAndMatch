include( "InstanceManager" );
include( "GameSetupLogic" );
include( "SupportFunctions" );
include( "Civ6Common" );

g_PlayerParameters = {};

local m_MAM_View = "OVERVIEW";
local m_MAM_LastTooltipControls = nil;
local m_MAM_BasicTooltipControls = nil;
local m_MAM_AdvancedTooltipControls = nil;
local m_MAM_LastInfo = nil;
local m_MAM_ButtonIMs = {};
local m_MAM_WindowClosed = false;
g_MAM_ConfiguringPlayerId = nil;
g_MAM_CurrentLobbyPlayerId = nil;
g_MAM_RowPid = nil;
g_MAM_InTooltip = false;

MAM_MAX_SLOTS = 12;
MAM_SLOT_KEYS = {
	CIV         = "MAM_CIV_ABILITY",
	LEADER      = "MAM_LEADER_ABILITY",
	UNIT        = "MAM_UNIQUE_UNIT",
	DISTRICT    = "MAM_UNIQUE_DISTRICT",
	COSM_CIV    = "MAM_COSMETIC_CIV",
	COSM_LEADER = "MAM_COSMETIC_LEADER",
	MYSTERY     = "MAM_IS_MYSTERY",
};
local MAM_SLOT_KEY_ORDER = { "CIV", "LEADER", "UNIT", "DISTRICT", "COSM_CIV", "COSM_LEADER", "MYSTERY" };

function MAM_IsBaseConstructorLeader(l)
	if type(l) == "table" then l = l.Value; end
	return l == "LEADER_MAM_BLANK" or l == "LEADER_MAM_RANDOM";
end

function MAM_IsSlotLeader(l)
	if type(l) == "table" then l = l.Value; end
	return type(l) == "string" and string.find(l, "^LEADER_MAM_P%d+$") ~= nil;
end

function MAM_IsMAMLeader(l)
	if type(l) == "table" then l = l.Value; end
	return MAM_IsBaseConstructorLeader(l) or MAM_IsSlotLeader(l);
end

function MAM_SlotIndexFromLeader(l)
	if type(l) == "table" then l = l.Value; end
	if type(l) == "string" then
		local numStr = string.match(l, "^LEADER_MAM_P(%d+)$");
		if numStr then return tonumber(numStr); end
	end
	return nil;
end

function MAM_Trace(msg)
end
function MAM_TraceTypes(where)
end

function MAM_IsMAMCiv(c)
	return type(c) == "string" and string.find(c, "^CIVILIZATION_MAM_") ~= nil;
end

function MAM_LeaderOf(cfg)
	if cfg == nil then return nil; end
	local l = cfg:GetLeaderTypeName();
	if MAM_IsSlotLeader(l) then
		if cfg:GetValue("MAM_BASE_LEADER") == "LEADER_MAM_RANDOM" then
			return "LEADER_MAM_RANDOM";
		end
		return "LEADER_MAM_BLANK";
	end
	return l;
end

function MAM_IsAnyMP()
	return (GameConfiguration.IsAnyMultiplayer and GameConfiguration.IsAnyMultiplayer()) or false;
end

function MAM_IsHotseat()
	return (GameConfiguration.IsHotseat and GameConfiguration.IsHotseat()) or false;
end

function MAM_CanWriteGameConfig()
	if (not MAM_IsAnyMP()) or MAM_IsHotseat() then
		return true;
	end
	return (Network.IsGameHost ~= nil and Network.IsGameHost()) or false;
end

g_MAM_ConfigDirty = false;

function MAM_AnyHumanReady()
	local ids = GameConfiguration.GetParticipatingPlayerIDs and GameConfiguration.GetParticipatingPlayerIDs() or {};
	for _, pid in ipairs(ids) do
		local c = PlayerConfigurations[pid];
		if c ~= nil and c:GetSlotStatus() == SlotStatus.SS_TAKEN and c.GetReady and c:GetReady() then
			return true;
		end
	end
	return false;
end

function MAM_SendGameConfig(bForce)
	if not bForce and not g_MAM_Launching then
		g_MAM_ConfigDirty = true;
		return;
	end
	g_MAM_ConfigDirty = false;
	if MAM_IsAnyMP() and not MAM_IsHotseat() and Network.BroadcastGameConfig then
		Network.BroadcastGameConfig();
	end
end

function MAM_SlotConfigId(pid, key)
	return "MAM_P" .. tostring(pid) .. "_" .. key;
end

function MAM_ApplySlotTypes(pid, baseLeader)
	local cfg = PlayerConfigurations[pid];
	if cfg == nil or pid == nil or pid < 0 then return false; end
	baseLeader = baseLeader or MAM_LeaderOf(cfg);
	if not MAM_IsBaseConstructorLeader(baseLeader) then return false; end
	if pid >= MAM_MAX_SLOTS then
		print("[MAM] Player " .. tostring(pid) .. " is outside the Constructor slot range (0.." .. tostring(MAM_MAX_SLOTS - 1) .. "); abilities cannot be applied.");
		return false;
	end
	local slotLeader = "LEADER_MAM_P" .. tostring(pid);
	local slotCiv = "CIVILIZATION_MAM_P" .. tostring(pid);
	local changed = false;
	local ok, err = pcall(function()
		local lock = g_MAM_SlotLockOverride or (g_MAM_Launching and "LAUNCH" or "READY");
		if cfg:GetValue("MAM_SLOT_LOCK") ~= lock then
			cfg:SetValue("MAM_SLOT_LOCK", lock);
			changed = true;
		end
		if cfg:GetValue("MAM_BASE_LEADER") ~= baseLeader then
			cfg:SetValue("MAM_BASE_LEADER", baseLeader);
			changed = true;
		end
		if cfg:GetLeaderTypeName() ~= slotLeader then
			cfg:SetLeaderTypeName(slotLeader);
			changed = true;
		end
		if cfg:GetCivilizationTypeName() ~= slotCiv then
			if cfg.SetCivilizationTypeName then
				cfg:SetCivilizationTypeName(slotCiv);
			else
				cfg:SetValue("CIVILIZATION_TYPE_NAME", slotCiv);
			end
			changed = true;
		end
		local chosenLeader = cfg:GetValue("MAM_COSMETIC_LEADER");
		if chosenLeader == nil or chosenLeader == "" or chosenLeader == "NONE" or chosenLeader == "RANDOM" or MAM_IsConstructorLeader(chosenLeader) then
			chosenLeader = cfg:GetValue("MAM_LEADER_ABILITY");
		end
		if chosenLeader ~= nil and chosenLeader ~= "" and chosenLeader ~= "NONE" and chosenLeader ~= "RANDOM" and not MAM_IsConstructorLeader(chosenLeader) then
			local lRow = CachedQuery("SELECT LeaderName FROM Players WHERE LeaderType = ? LIMIT 1", chosenLeader);
			if lRow and lRow[1] and lRow[1].LeaderName and cfg.SetLeaderName then
				cfg:SetLeaderName(lRow[1].LeaderName);
			end
		end
	end);
	if not ok then
		print("[MAM] Could not assign constructor slot types for player " .. tostring(pid) .. ": " .. tostring(err));
		return false;
	end
	if changed then
		MAM_Trace(string.format("Slot assigned: player %d -> %s / %s (now %s / %s, lock %s)", pid, slotLeader, slotCiv,
			tostring(cfg:GetLeaderTypeName()), tostring(cfg:GetCivilizationTypeName()), tostring(cfg:GetValue("MAM_SLOT_LOCK"))));
	end
	return changed;
end

function MAM_AssignSlotsNow(reason)
	local ids = GameConfiguration.GetParticipatingPlayerIDs and GameConfiguration.GetParticipatingPlayerIDs() or {};
	for _, pid in ipairs(ids) do
		local cfg = PlayerConfigurations[pid];
		if cfg ~= nil and MAM_IsBaseConstructorLeader(MAM_LeaderOf(cfg)) and MAM_CanEditPlayerSlot(pid) then
			if MAM_ApplySlotTypes(pid) then
				if Network and Network.BroadcastPlayerInfo then pcall(Network.BroadcastPlayerInfo, pid); end
			end
		end
	end
end

local MAM_HASH_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz";
local MAM_HASH_MOD = 16777213;
local MAM_HASH_BITS = 24;
local MAM_HASH_MAXLEN = 100;
local MAM_BIT_KIND_ORDER = { "CIV", "LEADER", "UNIT", "DISTRICT", "COSM_LEADER" };

function MAM_HashType(value)
	if value == nil or value == "" or value == "NONE" then return 0; end
	local h = 0;
	local n = math.min(string.len(value), MAM_HASH_MAXLEN);
	for i = 1, n do
		local c = string.find(MAM_HASH_ALPHABET, string.sub(value, i, i), 1, true) or 0;
		h = (h * 31 + c) % MAM_HASH_MOD;
	end
	return h;
end

g_MAM_Launching = false;
g_MAM_LaunchPrepared = false;

g_MAM_ReadyLockPid = nil;

function MAM_ApplyLocalSlotOnReady()
	if not (MAM_IsAnyMP() and not MAM_IsHotseat() and not MAM_CanWriteGameConfig()) then return false; end
	local pid = MAM_GetLocalPlayerId();
	if pid == nil or pid < 0 then return false; end
	local cfg = PlayerConfigurations[pid];
	if cfg == nil then return false; end
	local base = MAM_LeaderOf(cfg);
	if not MAM_IsBaseConstructorLeader(base) then
		g_MAM_ReadyLockPid = nil;
		return false;
	end
	g_MAM_ReadyLockPid = pid;
	if MAM_ApplySlotTypes(pid, base) and Network and Network.BroadcastPlayerInfo then
		pcall(Network.BroadcastPlayerInfo, pid);
	end
	return true;
end

function MAM_IsHiddenContext()
	local ok, hidden = pcall(function() return ContextPtr ~= nil and ContextPtr.IsHidden ~= nil and ContextPtr:IsHidden(); end);
	return ok and hidden == true;
end

function MAM_RevertSlotTypes(pid, bForce)
	if g_MAM_Launching then return false; end
	if pid ~= nil and pid == g_MAM_ReadyLockPid then return false; end
	local cfg = PlayerConfigurations[pid];
	if cfg == nil or not MAM_IsSlotLeader(cfg:GetLeaderTypeName()) then return false; end
	if not bForce then
		if MAM_IsHiddenContext() then return false; end
		local lock = cfg:GetValue("MAM_SLOT_LOCK");
		if lock == "LAUNCH" then return false; end
		if lock == "READY" and cfg.GetReady and cfg:GetReady() then return false; end
	end
	pcall(function() cfg:SetValue("MAM_SLOT_LOCK", "NONE"); end);
	MAM_Trace(string.format("Player %d: slot type reverted to the Constructor entry (%s)", pid, bForce and "lobby opened" or "lobby change"));
	if not MAM_CanEditPlayerSlot(pid) then return false; end
	local base = MAM_LeaderOf(cfg);
	local civ = (base == "LEADER_MAM_RANDOM") and "CIVILIZATION_MAM_RANDOM" or "CIVILIZATION_MAM_BLANK";
	local ok = pcall(function()
		cfg:SetLeaderTypeName(base);
		if cfg.SetCivilizationTypeName then
			cfg:SetCivilizationTypeName(civ);
		else
			cfg:SetValue("CIVILIZATION_TYPE_NAME", civ);
		end
	end);
	return ok;
end

function MAM_PublishSlot(pid)
	if pid == nil or pid < 0 or pid >= MAM_MAX_SLOTS then return false; end
	if not MAM_CanWriteGameConfig() then return false; end
	local cfg = PlayerConfigurations[pid];
	local isMAM = (cfg ~= nil and MAM_IsMAMLeader(cfg:GetLeaderTypeName()));
	if isMAM and cfg.IsParticipant and not cfg:IsParticipant() then
		isMAM = false;
	end
	local changed = false;
	for _, k in ipairs(MAM_SLOT_KEY_ORDER) do
		local v = "NONE";
		if isMAM then
			v = cfg:GetValue(MAM_SLOT_KEYS[k]);
			if v == nil or v == "" or v == "RANDOM" then v = "NONE"; end
		end
		local id = MAM_SlotConfigId(pid, k);
		if GameConfiguration.GetValue(id) ~= v then
			GameConfiguration.SetValue(id, v);
			changed = true;
		end
	end
	for _, k in ipairs(MAM_BIT_KIND_ORDER) do
		local idx = 0;
		if isMAM then
			idx = MAM_HashType(GameConfiguration.GetValue(MAM_SlotConfigId(pid, k)));
		end
		for b = 0, MAM_HASH_BITS - 1 do
			local bitVal = (math.floor(idx / (2 ^ b)) % 2 == 1) and "1" or "0";
			local id = MAM_SlotConfigId(pid, k) .. "_B" .. tostring(b);
			if GameConfiguration.GetValue(id) ~= bitVal then
				GameConfiguration.SetValue(id, bitVal);
				changed = true;
			end
		end
	end
	if changed then g_MAM_ConfigDirty = true; end
	return changed;
end

function MAM_PublishAllSlots(bDeferBroadcast)
	if not MAM_CanWriteGameConfig() then return false; end
	local changed = false;
	local pids = GameConfiguration.GetParticipatingPlayerIDs and GameConfiguration.GetParticipatingPlayerIDs() or {};
	for _, pid in ipairs(pids) do
		if pid >= 0 and pid < MAM_MAX_SLOTS then
			if MAM_PublishSlot(pid) then changed = true; end
		end
	end
	if changed and not bDeferBroadcast and g_MAM_Launching and MAM_IsAnyMP() and Network.BroadcastGameConfig then
		MAM_SendGameConfig(true);
	end
	return changed;
end

local MAM_RULESET_DOMAINS = {
	RULESET_STANDARD    = "Players:StandardPlayers",
	RULESET_EXPANSION_1 = "Players:Expansion1_Players",
	RULESET_EXPANSION_2 = "Players:Expansion2_Players",
};
local m_MAM_ItemCache = {};
local MAM_CancelPendingCard;

local function MAM_GetCurDomains()
	local rs = GameConfiguration.GetRuleSet and GameConfiguration.GetRuleSet() or nil;
	if rs == nil or rs == "" then
		if GameConfiguration.GetValue then rs = GameConfiguration.GetValue("RULESET"); end
	end
	if rs == nil or rs == "" then
		if MapConfiguration and MapConfiguration.GetValue then rs = MapConfiguration.GetValue("RULESET"); end
	end
	local primary = nil;
	if rs then
		local ok, rows = pcall(CachedQuery,
			"SELECT Domain FROM RulesetDomainOverrides WHERE Ruleset = ? AND ParameterId = 'PlayerLeader' LIMIT 1", rs);
		if ok and rows and #rows > 0 and rows[1].Domain then
			primary = rows[1].Domain;
		elseif MAM_RULESET_DOMAINS[rs] then
			primary = MAM_RULESET_DOMAINS[rs];
		end
	end
	if primary == nil then
		local ok, rows = pcall(CachedQuery, "SELECT 1 AS X FROM Players WHERE Domain = 'Players:Expansion2_Players' LIMIT 1");
		if ok and rows and #rows > 0 then
			primary = "Players:Expansion2_Players";
		else
			primary = "Players:StandardPlayers";
		end
	end
	local doms = { [primary] = true };
	if primary == "Players:Expansion2_Players" then
		doms["Players:Expansion1_Players"] = true;
		doms["Players:StandardPlayers"] = true;
	elseif primary == "Players:Expansion1_Players" then
		doms["Players:StandardPlayers"] = true;
	end
	return doms, primary;
end

local function MAM_PlayersDomain()
	local _, primary = MAM_GetCurDomains();
	return primary;
end

local MAM_ITEM_QUERIES = {
	MAM_CivAbilities =
		"SELECT CivilizationType AS Value, CivilizationName AS Name, CivilizationAbilityDescription AS Description, CivilizationAbilityName AS AbilityName, CivilizationIcon AS Icon, Domain FROM Players " ..
		"WHERE CivilizationType IS NOT NULL AND CivilizationType NOT LIKE 'CIVILIZATION_MAM_%' AND CivilizationType NOT LIKE '%RANDOM%' " ..
		"AND CivilizationAbilityName IS NOT NULL AND CivilizationAbilityName <> '' AND CivilizationAbilityName <> 'NONE' AND CivilizationAbilityName <> 'LOC_BLANK_STRING'",
	MAM_LeaderAbilities =
		"SELECT LeaderType AS Value, LeaderName AS Name, LeaderAbilityDescription AS Description, LeaderAbilityName AS AbilityName, LeaderIcon AS Icon, Domain FROM Players " ..
		"WHERE LeaderType IS NOT NULL AND LeaderType NOT LIKE 'LEADER_MAM_%' AND LeaderType NOT LIKE '%RANDOM%' " ..
		"AND LeaderAbilityName IS NOT NULL AND LeaderAbilityName <> '' AND LeaderAbilityName <> 'NONE' AND LeaderAbilityName <> 'LOC_BLANK_STRING'",
	MAM_UniqueUnits =
		"SELECT Type AS Value, Name, Description, Icon, Domain FROM PlayerItems WHERE Type LIKE 'UNIT%' AND Type NOT IN ('UNIT_SETTLER', 'UNIT_BUILDER', 'UNIT_SPY', 'UNIT_ARCHAEOLOGIST', 'UNIT_NATURALIST', 'UNIT_ROCK_BAND')",
	MAM_UniqueDistricts =
		"SELECT Type AS Value, Name, Description, Icon, Domain FROM PlayerItems " ..
		"WHERE (Type LIKE 'DISTRICT%' OR Type LIKE 'BUILDING%' OR Type LIKE 'IMPROVEMENT%')",
};

local m_MAM_LastAllRulesetsState = nil;
function MAM_AllRulesetsEnabled()
	local v = GameConfiguration.GetValue("MAM_ALL_RULESETS");
	if v == nil then v = GameConfiguration.GetValue("MAM_AllRulesets"); end
	if v == nil and MapConfiguration then v = MapConfiguration.GetValue("MAM_ALL_RULESETS"); end
	if v == nil and MapConfiguration then v = MapConfiguration.GetValue("MAM_AllRulesets"); end
	local enabled = true;
	if v == false or v == 0 or v == "0" or v == "false" or v == 0.0 then
		enabled = false;
	end
	if m_MAM_LastAllRulesetsState ~= enabled then
		m_MAM_LastAllRulesetsState = enabled;
		m_MAM_ItemCache = {};
	end
	return enabled;
end

function MAM_QueryItems(domain, currentOnly)
	local curDoms, primary = MAM_GetCurDomains();
	local allRs = (not currentOnly) and MAM_AllRulesetsEnabled();
	local cacheKey = tostring(domain) .. "|" .. tostring(primary) .. "|" .. (allRs and "ALL" or "CUR");
	if m_MAM_ItemCache[cacheKey] then return m_MAM_ItemCache[cacheKey]; end
	local q = MAM_ITEM_QUERIES[domain];
	if q == nil then return {}; end

	local rows = {};
	local domList = {};
	for d, _ in pairs(curDoms) do
		table.insert(domList, "'" .. d .. "'");
	end
	local inClause = table.concat(domList, ", ");
	local ok, baseRows = pcall(CachedQuery, q .. " AND Domain IN (" .. inClause .. ")");
	if ok and baseRows then
		for _, r in ipairs(baseRows) do table.insert(rows, r); end
	end

	if allRs then
		if domain == "MAM_CivAbilities" then
			local scenCivs = "'CIVILIZATION_MIXMATCH_WARMACHINE_GERMANY', 'CIVILIZATION_MIXMATCH_WARMACHINE_FRANCE', 'CIVILIZATION_MIXMATCH_RADZIWILL', 'CIVILIZATION_MIXMATCH_POTOCKI', 'CIVILIZATION_MIXMATCH_OSTROGSKI', 'CIVILIZATION_MIXMATCH_DENMARK', 'CIVILIZATION_MIXMATCH_QUEENSLAND', 'CIVILIZATION_MIXMATCH_WESTERN_AUSTRALIA'";
			local okS, sRows = pcall(CachedQuery, q .. " AND CivilizationType IN (" .. scenCivs .. ")");
			if okS and sRows then
				for _, r in ipairs(sRows) do table.insert(rows, r); end
			end
			local okE, eRows = pcall(CachedQuery, q .. " AND Domain NOT IN ('Players:MAM_Slots', 'Players:StandardPlayers', 'Players:Expansion1_Players', 'Players:Expansion2_Players', 'WarMachineScenario_Players', 'PolandScenario_Players', 'VikingScenario_Players', 'AustraliaScenario_Players', 'AlexanderScenario_Players', 'BlackDeathScenario_Players', 'Players:PiratesScenarioPlayers', 'Players:CivRoyaleScenarioPlayers', 'Players:Indonesia_KhmerScenario_Players', 'NubiaScenario_Players')");
			if okE and eRows then
				for _, r in ipairs(eRows) do table.insert(rows, r); end
			end
		elseif domain == "MAM_LeaderAbilities" then
			local scenLeaders = "'LEADER_MIXMATCH_WARMACHINE_GERMANY', 'LEADER_MIXMATCH_WARMACHINE_FRANCE', 'LEADER_MIXMATCH_RADZIWILL', 'LEADER_MIXMATCH_POTOCKI', 'LEADER_MIXMATCH_OSTROGSKI', 'LEADER_MIXMATCH_CNUT', 'LEADER_MIXMATCH_OLOF', 'LEADER_MIXMATCH_HARDRADA_SCENARIO', 'LEADER_MIXMATCH_QUEENSLAND', 'LEADER_MIXMATCH_WESTERN_AUSTRALIA', 'LEADER_MIXMATCH_DARIUS_III'";
			local okS, sRows = pcall(CachedQuery, q .. " AND LeaderType IN (" .. scenLeaders .. ")");
			if okS and sRows then
				for _, r in ipairs(sRows) do table.insert(rows, r); end
			end
			local okE, eRows = pcall(CachedQuery, q .. " AND Domain NOT IN ('Players:MAM_Slots', 'Players:StandardPlayers', 'Players:Expansion1_Players', 'Players:Expansion2_Players', 'WarMachineScenario_Players', 'PolandScenario_Players', 'VikingScenario_Players', 'AustraliaScenario_Players', 'AlexanderScenario_Players', 'BlackDeathScenario_Players', 'Players:PiratesScenarioPlayers', 'Players:CivRoyaleScenarioPlayers', 'Players:Indonesia_KhmerScenario_Players', 'NubiaScenario_Players')");
			if okE and eRows then
				for _, r in ipairs(eRows) do table.insert(rows, r); end
			end
		else
			local okE, eRows = pcall(CachedQuery, q .. " AND Domain NOT IN ('Players:MAM_Slots', 'Players:StandardPlayers', 'Players:Expansion1_Players', 'Players:Expansion2_Players', 'BlackDeathScenario_Players', 'Players:PiratesScenarioPlayers', 'Players:CivRoyaleScenarioPlayers', 'Players:Indonesia_KhmerScenario_Players', 'NubiaScenario_Players')");
			if okE and eRows then
				for _, r in ipairs(eRows) do table.insert(rows, r); end
			end
		end
	end

	if #rows == 0 then return {}; end

	local byValue, order = {}, {};
	local function Valid(t) return t ~= nil and t ~= "" and t ~= "NONE"; end

	local function MAM_DomainPriority(dom)
		if dom == primary then return 100;
		elseif dom == "Players:Expansion2_Players" then return 50;
		elseif dom == "Players:Expansion1_Players" then return 25;
		elseif dom == "Players:StandardPlayers" then return 10;
		else return 1; end
	end

	for _, r in ipairs(rows) do
		if r ~= nil and Valid(r.Value) and Valid(r.Name) then
			local isCur = (curDoms[r.Domain] == true);
			local dp = MAM_DomainPriority(r.Domain);
			local score = (Valid(r.Description) and 4 or 0) + (Valid(r.AbilityName) and 2 or 0) + dp;
			local cur = byValue[r.Value];
			if cur == nil then
				table.insert(order, r.Value);
				byValue[r.Value] = {
					Value = r.Value, Name = r.Name,
					AbilityName = Valid(r.AbilityName) and r.AbilityName or nil,
					RawDescription = Valid(r.Description) and r.Description or nil,
					Icon = Valid(r.Icon) and r.Icon or ("ICON_" .. r.Value), score = score,
					Domain = r.Domain,
					OtherRuleset = (allRs and not isCur) or nil,
				};
			elseif score > cur.score then
				byValue[r.Value] = {
					Value = r.Value, Name = r.Name,
					AbilityName = Valid(r.AbilityName) and r.AbilityName or nil,
					RawDescription = Valid(r.Description) and r.Description or nil,
					Icon = Valid(r.Icon) and r.Icon or ("ICON_" .. r.Value), score = score,
					Domain = r.Domain,
					OtherRuleset = (allRs and not isCur and cur.OtherRuleset) or nil,
				};
			elseif isCur then
				byValue[r.Value].OtherRuleset = nil;
			end
		end
	end

	for _, it in pairs(byValue) do
		if it.RawDescription then
			it.Description = it.RawDescription;
		elseif it.AbilityName then
			it.Description = it.AbilityName;
		else
			it.Description = "LOC_MAM_UI_NO_DESC";
		end
	end
	local items = {};
	for _, v in ipairs(order) do
		local it = byValue[v];
		if it then
			it.SortName = Locale.Lookup(it.Name);
			table.insert(items, it);
		end
	end
	table.sort(items, function(x, y)
		if x.SortName == y.SortName then return x.Value < y.Value; end
		return x.SortName < y.SortName;
	end);
	for i, it in ipairs(items) do it.SortIndex = i; end
	m_MAM_ItemCache[cacheKey] = items;
	return items;
end

function MAM_PreloadItemCaches()
	pcall(function()
		MAM_QueryItems("MAM_CivAbilities");
		MAM_QueryItems("MAM_LeaderAbilities");
		MAM_QueryItems("MAM_UniqueUnits");
		MAM_QueryItems("MAM_UniqueDistricts");
	end);
end
pcall(MAM_PreloadItemCaches);

local function MAM_InstallFilterValuesHook()
	if SetupParameters and SetupParameters.Parameter_FilterValues and not g_MAM_FilterValuesHooked then
		g_MAM_FilterValuesHooked = true;
		local _orig_Parameter_FilterValues = SetupParameters.Parameter_FilterValues;
		function SetupParameters:Parameter_FilterValues(parameter, values)
			local result = _orig_Parameter_FilterValues(self, parameter, values);
			if (parameter and parameter.ParameterId == "PlayerLeader" and result) then
				for _, v in ipairs(result) do
					if (v.Value == "LEADER_MAM_BLANK" or v.Value == "LEADER_MAM_RANDOM") then
						if (v.Invalid and (v.InvalidReason == "LOC_SETUP_ERROR_NO_DUPLICATE_LEADERS" or v.InvalidReason == "LOC_SETUP_ERROR_NO_DUPLICATE_CIVILIZATIONS")) then
							v.Invalid = false;
							v.InvalidReason = nil;
						end
					end
				end
			end
			return result;
		end
	end
end
MAM_InstallFilterValuesHook();
local m_currentInfo = {
		CivilizationIcon = "ICON_CIVILIZATION_UNKNOWN",
		LeaderIcon = "ICON_LEADER_DEFAULT",
		CivilizationName = "LOC_RANDOM_CIVILIZATION",
		LeaderName = "LOC_RANDOM_LEADER"
	};

local m_tooltipControls = {};
local m_teamColors = {};

function Player_ReadParameterValues(o, parameter)
	if(parameter.ParameterId == "PlayerLeader") then
		local playerConfig = PlayerConfigurations[o.PlayerId];
		if(playerConfig) then

			local value = playerConfig:GetLeaderTypeID();
			if MAM_IsSlotLeader(playerConfig:GetLeaderTypeName()) then
				value = MAM_LeaderOf(playerConfig);
			elseif(value ~= -1) then
				value = MAM_LeaderOf(playerConfig);
			else
				local pool_id:number = playerConfig:GetLeaderRandomPoolID();
				if pool_id == LeaderRandomPoolTypes.LEADER_RANDOM_POOL_1 then
					value = "RANDOM_POOL1";
				elseif pool_id == LeaderRandomPoolTypes.LEADER_RANDOM_POOL_2 then
					value = "RANDOM_POOL2";
				else
					value = "RANDOM";
				end
			end

			return value;
		end
	else
		return SetupParameters.Config_ReadParameterValues(o, parameter);
	end
end

function Player_WriteParameterValues(o, parameter)

	if(parameter.ParameterId == "PlayerLeader" and o:Config_CanWriteParameter(parameter)) then
		local playerConfig = PlayerConfigurations[o.PlayerId];
		if(playerConfig) then
			if parameter.Value ~= nil and MAM_IsSlotLeader(playerConfig:GetLeaderTypeName())
				and parameter.Value.Value == MAM_LeaderOf(playerConfig) then
				return true;
			end
			if parameter.Value ~= nil and MAM_IsSlotLeader(playerConfig:GetLeaderTypeName()) then
				MAM_Trace(string.format("PlayerLeader write: player %d %s -> %s", o.PlayerId, tostring(playerConfig:GetLeaderTypeName()), tostring(parameter.Value.Value)));
			end
			if(parameter.Value ~= nil) then
				local value = parameter.Value.Value;
				local targetPid = (MAM_GetTargetPlayerId and MAM_GetTargetPlayerId()) or -1;
				local localPid = (MAM_GetLocalPlayerId and MAM_GetLocalPlayerId()) or 0;
				local wasConstructor = MAM_IsBaseConstructorLeader(MAM_LeaderOf(playerConfig));

				if(value == -1 or value == "RANDOM") then
					playerConfig:SetLeaderName(nil);
					playerConfig:SetLeaderTypeName(nil);
					playerConfig:SetLeaderRandomPoolID(LeaderRandomPoolTypes.LEADER_RANDOM_POOL_DEFAULT);
					if o.PlayerId == targetPid and wasConstructor then
						if MAM_CloseWindow then MAM_CloseWindow(); else m_MAM_WindowClosed = true; end
					end
				elseif(value == "RANDOM_POOL1") then
					playerConfig:SetLeaderName(nil);
					playerConfig:SetLeaderTypeName(nil);
					playerConfig:SetLeaderRandomPoolID(LeaderRandomPoolTypes.LEADER_RANDOM_POOL_1);
					if o.PlayerId == targetPid and wasConstructor then
						if MAM_CloseWindow then MAM_CloseWindow(); else m_MAM_WindowClosed = true; end
					end
				elseif(value == "RANDOM_POOL2") then
					playerConfig:SetLeaderName(nil);
					playerConfig:SetLeaderTypeName(nil);
					playerConfig:SetLeaderRandomPoolID(LeaderRandomPoolTypes.LEADER_RANDOM_POOL_2);
					if o.PlayerId == targetPid and wasConstructor then
						if MAM_CloseWindow then MAM_CloseWindow(); else m_MAM_WindowClosed = true; end
					end
				else
					local leaderType:string = parameter.Value.Value;
					local prevLeader = MAM_LeaderOf(playerConfig);

					playerConfig:SetLeaderName(parameter.Value.RawName or parameter.Value.Name);

					playerConfig:SetLeaderTypeName(leaderType);

					if leaderType == "LEADER_MAM_RANDOM" then
						local isNewChoice = (prevLeader ~= leaderType);
						if isNewChoice and o.PlayerId == MAM_GetLocalPlayerId() then
							g_MAM_ConfiguringPlayerId = o.PlayerId;
							m_MAM_WindowClosed = false;
						end
						local curCiv = playerConfig:GetValue("MAM_CIV_ABILITY");
						local needRoll = (prevLeader ~= "LEADER_MAM_RANDOM") or curCiv == nil or curCiv == "" or curCiv == "NONE" or curCiv == "RANDOM";
						if needRoll and MAM_RollRandomAll then
							MAM_RollRandomAll(o.PlayerId, true);
						end
						if isNewChoice and (o.PlayerId == MAM_GetLocalPlayerId()) and GetPlayerInfo then
							local pInfo = GetPlayerInfo(parameter.Value.Domain, leaderType, o.PlayerId);
							m_currentInfo = pInfo;
							m_MAM_LastInfo = pInfo;
							if DisplayCivLeaderToolTip and m_MAM_LastTooltipControls then
								MAM_ShowCardNow(pInfo, m_MAM_LastTooltipControls, false);
							end
						end
					elseif leaderType == "LEADER_MAM_BLANK" then
						local isNewChoice = (prevLeader ~= leaderType);
						if isNewChoice and o.PlayerId == MAM_GetLocalPlayerId() then
							g_MAM_ConfiguringPlayerId = o.PlayerId;
							m_MAM_WindowClosed = false;
						end
						if isNewChoice and (o.PlayerId == MAM_GetLocalPlayerId()) and GetPlayerInfo then
							local pInfo = GetPlayerInfo(parameter.Value.Domain, leaderType, o.PlayerId);
							m_currentInfo = pInfo;
							m_MAM_LastInfo = pInfo;
							if DisplayCivLeaderToolTip and m_MAM_LastTooltipControls then
								MAM_ShowCardNow(pInfo, m_MAM_LastTooltipControls, false);
							end
						end
					else
						if o.PlayerId == targetPid and wasConstructor then
							if MAM_CloseWindow then MAM_CloseWindow(); else m_MAM_WindowClosed = true; end
						end
					end
				end
			else
				playerConfig:SetLeaderName(nil);
				playerConfig:SetLeaderTypeName(nil);
			end

			o:Config_WriteAuxParameterValues(parameter);

			if parameter.Value ~= nil and MAM_IsBaseConstructorLeader(parameter.Value.Value) then
				playerConfig:SetValue("MAM_BASE_LEADER", parameter.Value.Value);
				MAM_PublishSlot(o.PlayerId);
			end
			Network.BroadcastPlayerInfo(o.PlayerId);
			return true;
		end
	else
		local result = SetupParameters.Config_WriteParameterValues(o, parameter);
		if(result and o.PlayerId ~= nil) then
			Network.BroadcastPlayerInfo(o.PlayerId);
		end
		return result;
	end
end


function Player_UI_CreateParameter(o, parameter)
end


function Player_UI_DestroyParameter(o, parameter)
end


function CreatePlayerParameters(playerId, bHeadless)
	SetupParameters_Log("Creating player parameters for Player " .. tonumber(playerId));

	local playerConfig = PlayerConfigurations[playerId];

	local parameters = SetupParameters.new(playerId);
	parameters.Parameter_GetRelevant = GetRelevantParameters;
	parameters.Config_EndWrite = Parameters_Config_EndWrite;

	parameters.Config_ReadParameterValues = Player_ReadParameterValues;
	parameters.Config_WriteParameterValues = Player_WriteParameterValues;


	if(bHeadless) then
		parameters.UpdateVisualization = function() end
	end
	parameters.UI_CreateParameter = (bHeadless ~= true) and Player_UI_CreateParameter;
	parameters.UI_DestroyParameter = (bHeadless ~= true) and Player_UI_DestroyParameter;
	if (bHeadless ~= true) and UI_SetParameterPossibleValues then
		local _origSetPossVal = UI_SetParameterPossibleValues;
		parameters.UI_SetParameterPossibleValues = function(o, parameter)
			local prevRow = g_MAM_RowPid;
			local prevCur = g_MAM_CurrentLobbyPlayerId;
			g_MAM_RowPid = playerId;
			g_MAM_CurrentLobbyPlayerId = playerId;
			local res = _origSetPossVal(o, parameter);
			g_MAM_RowPid = prevRow;
			g_MAM_CurrentLobbyPlayerId = prevCur;
			return res;
		end;
	else
		parameters.UI_SetParameterPossibleValues = (bHeadless ~= true) and UI_SetParameterPossibleValues;
	end
	if (bHeadless ~= true) and UI_SetParameterValue then
		local _origSetVal = UI_SetParameterValue;
		parameters.UI_SetParameterValue = function(o, parameter)
			local prevRow = g_MAM_RowPid;
			local prevCur = g_MAM_CurrentLobbyPlayerId;
			g_MAM_RowPid = playerId;
			g_MAM_CurrentLobbyPlayerId = playerId;
			local res = _origSetVal(o, parameter);
			g_MAM_RowPid = prevRow;
			g_MAM_CurrentLobbyPlayerId = prevCur;
			return res;
		end;
	else
		parameters.UI_SetParameterValue = (bHeadless ~= true) and UI_SetParameterValue;
	end
	parameters.UI_SetParameterEnabled = (bHeadless ~= true) and UI_SetParameterEnabled;
	parameters.UI_SetParameterVisible = (bHeadless ~= true) and UI_SetParameterVisible;

	parameters:Initialize();

	if parameters.UpdateVisualization then
		local _origUpdateVis = parameters.UpdateVisualization;
		parameters.UpdateVisualization = function(self, ...)
			local prevRow = g_MAM_RowPid;
			local prevCur = g_MAM_CurrentLobbyPlayerId;
			g_MAM_RowPid = playerId;
			g_MAM_CurrentLobbyPlayerId = playerId;
			local res = _origUpdateVis(self, ...);
			g_MAM_RowPid = prevRow;
			g_MAM_CurrentLobbyPlayerId = prevCur;
			return res;
		end
	end

	table.insert(g_PlayerParameters, {playerId, parameters});
	table.sort(g_PlayerParameters, function(a,b)
		return a[1] < b[1];
	end);

	return parameters;
end

function MAM_ApplyPlayerRowIcons(playerId, instance)
	pcall(function()
		local pConfig = PlayerConfigurations[playerId];
		local lType = pConfig and (pConfig:GetLeaderTypeName() or MAM_LeaderOf(pConfig));
		if lType and MAM_IsMAMLeader(lType) then
			local domain = MAM_IsSlotLeader(lType) and "Players:MAM_Slots" or "Players:StandardPlayers";
			local icons = GetPlayerIcons(domain, lType, playerId);
			local lIcon = instance and (instance["LeaderIcon"] or (instance.PlayerPullDown and (instance.PlayerPullDown.LeaderIcon or (instance.PlayerPullDown.GetButton and instance.PlayerPullDown:GetButton().LeaderIcon))));
			if lIcon and icons and icons.LeaderIcon then
				lIcon:SetIcon(icons.LeaderIcon);
			end
			local civIcon = instance and instance["CivIcon"];
			local civIconBG = instance and instance["IconBG"];
			if civIcon and icons and icons.CivIcon then
				civIcon:SetIcon(icons.CivIcon);
			end
			if civIconBG and icons and icons.PlayerColor then
				local colorAlternate = 0;
				local params = GetPlayerParameters(playerId);
				if params and params.Parameters and params.Parameters["PlayerColorAlternate"] then
					colorAlternate = params.Parameters["PlayerColorAlternate"].Value or 0;
				end
				local backColor, frontColor = UI.GetPlayerColorValues(icons.PlayerColor, colorAlternate);
				if backColor and frontColor and backColor ~= 0 and frontColor ~= 0 then
					civIcon:SetColor(frontColor);
					civIconBG:SetColor(backColor);
					civIconBG:SetHide(false);
					civIcon:SetHide(false);
				end
			end
		end
	end);
end

function MAM_BindPlayerLeaderControls(playerId, instance)
	pcall(function()
		MAM_ApplyPlayerRowIcons(playerId, instance);
		local pulldown = instance and (instance.PlayerPullDown or instance.PlayerLeaderPullDown);
		local button = pulldown and pulldown.GetButton and pulldown:GetButton();
		local function WireHover(vVal, vDom)
			if button == nil then return; end
			button:RegisterCallback(Mouse.eMouseEnter, function()
				local pConfig = PlayerConfigurations[playerId];
				local lType = pConfig and (pConfig:GetLeaderTypeName() or MAM_LeaderOf(pConfig)) or vVal or "LEADER_MAM_BLANK";
				local domain = vDom or (MAM_IsSlotLeader(lType) and "Players:MAM_Slots" or "Players:StandardPlayers");
				local info = GetPlayerInfo(domain, lType, playerId);
				if info == nil then info = { LeaderType = lType, TargetPlayerId = playerId }; end
				info.TargetPlayerId = playerId;
				if MAM_IsMAMLeader(lType) then
					m_currentInfo = info;
					g_MAM_ConfiguringPlayerId = playerId;
				end
				if m_MAM_LastTooltipControls then
					DisplayCivLeaderToolTip(info, m_MAM_LastTooltipControls, false);
				end
			end);
			button:RegisterCallback(Mouse.eMouseExit, function()
				MAM_CancelPendingCard();
			end);
		end
		WireHover();
		local params = GetPlayerParameters(playerId);
		local ctrlList = params and params.Controls and params.Controls["PlayerLeader"];
		if ctrlList then
			for _, entry in ipairs(ctrlList) do
				if entry and entry.UpdateValue and not entry.m_MAM_BoundPid then
					entry.m_MAM_BoundPid = playerId;
					local origUV = entry.UpdateValue;
					entry.UpdateValue = function(v, p)
						local pr = g_MAM_RowPid;
						local pc = g_MAM_CurrentLobbyPlayerId;
						g_MAM_RowPid = playerId;
						g_MAM_CurrentLobbyPlayerId = playerId;
						local r = origUV(v, p);
						MAM_ApplyPlayerRowIcons(playerId, instance);
						WireHover(v and v.Value, v and v.Domain);
						g_MAM_RowPid = pr;
						g_MAM_CurrentLobbyPlayerId = pc;
						return r;
					end
				end
			end
		end
	end);
end

function GetPlayerParameters(player_id)
	local prevCur = g_MAM_CurrentLobbyPlayerId;
	g_MAM_CurrentLobbyPlayerId = player_id;
	if MAM_InstallGameStartHooks then MAM_InstallGameStartHooks(); end
	for i, v in ipairs(g_PlayerParameters) do
		if(v[1] == player_id) then
			g_MAM_CurrentLobbyPlayerId = prevCur;
			return v[2];
		end
	end
	g_MAM_CurrentLobbyPlayerId = prevCur;
end

function RebuildPlayerParameters(bHeadless)
	g_PlayerParameters = {};

	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();
	SetupParameters_Log("There are " .. #player_ids .. " participating players.");
	for i, player_id in ipairs(player_ids) do
		CreatePlayerParameters(player_id, bHeadless);
	end
end

function RefreshPlayerParameters()
	SetupParameters_Log("Refresh Player Parameters");
	for i,v in ipairs(g_PlayerParameters) do
		v[2]:Refresh();
	end
	SetupParameters_Log("End Refresh Player Parameters");
end

function VisualizePlayerParameters()
	SetupParameters_Log("Visualizing Player Parameters");
	for i,v in ipairs(g_PlayerParameters) do
		local prevRow = g_MAM_RowPid;
		local prevCur = g_MAM_CurrentLobbyPlayerId;
		g_MAM_RowPid = v[1];
		g_MAM_CurrentLobbyPlayerId = v[1];
		v[2]:UpdateVisualization();
		g_MAM_RowPid = prevRow;
		g_MAM_CurrentLobbyPlayerId = prevCur;
	end
	SetupParameters_Log("End Visualizing Player Parameters");
end

function ReleasePlayerParameters()
	SetupParameters_Log("Releasing Player Parameters");
	for i,v in ipairs(g_PlayerParameters) do
		v[2]:Shutdown();
	end

	g_PlayerParameters = {};
end

function GetPlayerParameterError(playerId)
	local pPlayerConfig = PlayerConfigurations[playerId];
	local gameState = GameConfiguration.GetGameState();
	local isPreGame = (gameState == GameStateTypes.GAMESTATE_PREGAME);
	local max_unique_players = GameConfiguration.GetValue("MAX_UNIQUE_PLAYERS");
	local unique_leaders = GameConfiguration.GetValue("NO_DUPLICATE_LEADERS");
	local unique_civilizations = GameConfiguration.GetValue("NO_DUPLICATE_CIVILIZATIONS");
	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();
	local player_count = 0;

	for _, pid in ipairs(player_ids) do
		local pPlayerConfig = PlayerConfigurations[pid];
		if(pPlayerConfig) then
			local civLevel = pPlayerConfig:GetCivilizationLevelTypeID();
			if(civLevel == nil or civLevel == 0 or civLevel == CivilizationLevelTypes.CIVILIZATION_LEVEL_FULL_CIV) then
				player_count = player_count + 1;
			end
		end
	end

	for i, pp in ipairs(g_PlayerParameters) do
		local id = pp[1];
		if(id == playerId) then

			local p = pp[2];
			if(p and p.Parameters) then
				local playerLeader = p.Parameters["PlayerLeader"];
				if(playerLeader) then

					if(isPreGame) then
						if(max_unique_players and (unique_leaders or unique_civilizations)) then
							if(player_count > max_unique_players) then
								if not (pPlayerConfig and MAM_IsMAMLeader(pPlayerConfig:GetLeaderTypeName())) then
									print("Player Count - " .. player_count .. " Max Unique Players - " .. max_unique_players);
									return {Reason="LOC_SETUP_PLAYER_PARAMETER_ERROR"};
								end
							end
						end
					end

					local pPlayerConfig = PlayerConfigurations[playerId];
					if(pPlayerConfig ~= nil and not pPlayerConfig:IsParticipant()) then
						return nil;
					else
						if (pPlayerConfig and MAM_IsMAMLeader(pPlayerConfig:GetLeaderTypeName())) then
							if playerLeader.Error and (playerLeader.Error.Reason == "LOC_SETUP_ERROR_NO_DUPLICATE_LEADERS" or playerLeader.Error.Reason == "LOC_SETUP_ERROR_NO_DUPLICATE_CIVILIZATIONS") then
								return nil;
							end
						end
						return playerLeader.Error;
					end
				end
			end
		end
	end
end

function GetGameParametersError()
	if(g_GameParameters) then
		return g_GameParameters.Error or g_GameParameters.Stalled and "Stalled";
	end
end

function CanShowLeaderAbility(playerInfo : table)
	if (playerInfo.LeaderAbilityName and playerInfo.LeaderAbilityDescription and playerInfo.LeaderAbilityIcon) then
		return playerInfo.LeaderAbilityName ~= "NONE" and playerInfo.LeaderAbilityDescription ~= "NONE" and playerInfo.LeaderAbilityIcon ~= "NONE";
	end
	return false;
end

function CanShowCivAbility(playerInfo : table)
	if (playerInfo.CivilizationAbilityName and playerInfo.CivilizationAbilityDescription and playerInfo.CivilizationAbilityIcon) then
		return playerInfo.CivilizationAbilityName ~= "NONE" and playerInfo.CivilizationAbilityDescription ~= "NONE" and playerInfo.CivilizationAbilityIcon ~= "NONE";
	end
	return false;
end


local _PlayerInfoOverridesChanges = -1;
local _PlayerInfoOverrides = {};
local _PlayerItemOverrides = {};

function SyncPlayerOverrides()

	local changes = DB.ConfigurationChanges();
	if(changes == _PlayerInfoOverridesChanges) then
		return _PlayerInfoOverrides, _PlayerItemOverrides;
	end

	_PlayerInfoOverrides = {};
	_PlayerItemOverrides = {};

	local Query = function(query)
		local args = {};

		local parameters = query.Parameters;
		if(parameters ~= nil) then
			for i = 1, 4, 1 do
				local p = parameters[i];
				if(p ~= nil) then
					if(p.ConfigurationGroup == "Player" and p.ConfigurationId == "PLAYER_ID" and self.PlayerId) then
						args[i] = self.PlayerId;
					else
						args[i] = self:Config_Read(p.ConfigurationGroup, p.ConfigurationId);
					end
				end
			end
		end

		return CachedQuery(query.SQL, args[1], args[2], args[3], args[4]);
	end

	local CriteriaOperators = {
		["Equals"] = function(a,b) return a == b; end,
		["NotEquals"] = function(a,b) return a ~= b; end,
		["LessThan"] = function(a, b) return a < b; end,
		["LessThanEquals"] = function(a,b) return a <= b; end,
		["GreaterThan"] = function(a,b) return a > b; end,
		["GreaterThanEquals"] = function(a,b) return a >= b; end,
		["Exists"] = function(a,b) return Exists(a,b); end,
		["NotExists"] = function(a,b) return not Exists(a,b); end
	};

	local ReadConfig = function(group, id)
		if(group == "Game") then
			return GameConfiguration.GetValue(id);
		elseif(group == "Map") then
			return MapConfiguration.GetValue(id);
		elseif(group == "Player" and self.PlayerId ~= nil) then
			return PlayerConfigurations[self.PlayerId]:GetValue(id);
		end
	end

	local MeetsCriteria = function(criteria)
		if(criteria) then
			for i, v in ipairs(criteria) do
				local cmp = CriteriaOperators[v.Operator];
				if(cmp ~= nil) then
					local expected_value = v.ConfigurationValue;
					local actual_value = ReadConfig(v.ConfigurationGroup, v.ConfigurationId);

					local t = type(actual_value);
					if(t =="boolean") then

						local a = SetupParameters.Utility_ToBool(actual_value);
						local b = SetupParameters.Utility_ToBool(expected_value);
						if(not cmp(a, b)) then
							return false;
						end

					elseif(t == "number") then
						if(type(expected_value) == "string") then
							expected_value = DB.MakeHash(expected_value);
						end

						local a = tonumber(actual_value);
						local b = tonumber(expected_value);

						if(not cmp(a,b)) then
							return false;
						end
					else
						if(not cmp(actual_value, expected_value)) then
							return false;
						end
					end
				else
					SetupParameters_Log("Warning! Could not find criteria operator - " .. tostring(v.Operator));
				end
			end
		end

		return true;
	end

	local queries = {};
	for i, row in ipairs(CachedQuery("SELECT * from Queries")) do
		queries[row.QueryId] = {
			Query = row
		}
	end

	for i, row in ipairs(CachedQuery("SELECT * from QueryParameters")) do
		local query = queries[row.QueryId];
		if(query) then
			local parameters = query.Parameters;
			if(parameters == nil) then
				parameters = {};
				query.Parameters = parameters;
			end

			parameters[tonumber(row.Index)] = row;
		end
	end

	for i, row in ipairs(CachedQuery("SELECT * from QueryCriteria")) do
		local query = queries[row.QueryId];
		if(query) then
			local criteria = query.Criteria;
			if(criteria == nil) then
				criteria = {};
				query.Criteria = criteria;
			end
			table.insert(criteria, row);
		end
	end

	for _, row in ipairs(CachedQuery("SELECT * FROM PlayerInfoOverrideQueries")) do
		local q = queries[row.QueryId];
		if(q) then
			if(q.Criteria == nil or MeetsCriteria(q.Criteria)) then
				for _, v in ipairs(Query(q.Query)) do
					table.insert(_PlayerInfoOverrides, v);
				end
			end
		end
	end

	for i, row in ipairs(CachedQuery("SELECT * FROM PlayerItemOverrideQueries")) do
		local q = queries[row.QueryId];
		if(q) then
			if(q.Criteria == nil or MeetsCriteria(q.Criteria)) then
				for _, v in ipairs(Query(q.Query)) do
					print(v);
					table.insert(_PlayerItemOverrides, v);
				end
			end
		end
	end

	local sortByPriority = function(a,b) return a.Priority < b.Priority; end
	table.sort(_PlayerInfoOverrides, sortByPriority);
	table.sort(_PlayerItemOverrides, sortByPriority);

	return _PlayerInfoOverrides, _PlayerItemOverrides;
end



math.randomseed(os.time());

function ShowControl(alpha, slide)
	if(alpha and slide) then
		if (alpha:IsReversing()) then
			alpha:Reverse();
			slide:Reverse();
		elseif (alpha.IsStopped and alpha:IsStopped()) then
			alpha:Play();
			slide:Play();
		else
			alpha:SetHide(false);
			slide:SetHide(false);
			if alpha.SetToEnd then alpha:SetToEnd(); end
			if slide.SetToEnd then slide:SetToEnd(); end
		end
	end
end

function HideControl(alpha, slide)
	if(alpha and slide) then
		if (not alpha:IsReversing()) then
			alpha:Reverse();
			slide:Reverse();
		end
	end
end

function MAM_CanEditPlayerSlot(targetPid)
	if targetPid == nil then return true; end
	if GameConfiguration.IsAnyMultiplayer and not GameConfiguration.IsAnyMultiplayer() then
		return true;
	end
	if not Network.IsMultiplayer or not Network.IsMultiplayer() then
		return true;
	end
	if GameConfiguration.IsHotseat and GameConfiguration.IsHotseat() then
		return true;
	end
	local localPid = MAM_GetLocalPlayerId();
	if targetPid == localPid then
		return true;
	end
	if Network.IsGameHost == nil or Network.IsGameHost() then
		local pConfig = PlayerConfigurations[targetPid];
		if pConfig then
			local slotStatus = pConfig:GetSlotStatus();
			if slotStatus == SlotStatus.SS_COMPUTER or slotStatus == SlotStatus.SS_OPEN or slotStatus ~= SlotStatus.SS_TAKEN then
				return true;
			end
		else
			return true;
		end
	end
	return false;
end

function MAM_IsHumanSlot(pid)
	if pid == nil then return false; end
	local localPid = MAM_GetLocalPlayerId();
	if pid == 0 or (localPid ~= nil and pid == localPid) then
		return true;
	end
	return false;
end

function MAM_IsComputerSlot(pid)
	if pid == nil then return false; end
	if MAM_IsHumanSlot(pid) then
		return false;
	end
	local isMP = (Network.IsMultiplayer and Network.IsMultiplayer()) or false;
	local isHS = (GameConfiguration.IsHotseat and GameConfiguration.IsHotseat()) or false;
	if not isMP and not isHS then
		return true;
	end
	local pSlot = PlayerConfigurations[pid];
	if pSlot then
		local status = pSlot:GetSlotStatus();
		if status == SlotStatus.SS_TAKEN or status == SlotStatus.SS_OPEN then
			return false;
		end
		return status == SlotStatus.SS_COMPUTER;
	end
	return true;
end

function MAM_CloseWindow()
	m_MAM_WindowClosed = true;
	g_MAM_ConfiguringPlayerId = nil;
	m_currentInfo = {
		CivilizationIcon = "ICON_CIVILIZATION_UNKNOWN",
		LeaderIcon = "ICON_LEADER_DEFAULT",
		CivilizationName = "LOC_RANDOM_CIVILIZATION",
		LeaderName = "LOC_RANDOM_LEADER"
	};
	m_MAM_LastInfo = nil;
	m_MAM_View = "OVERVIEW";
	if MAM_CancelPendingCard then MAM_CancelPendingCard(); end
	if MAM_ResetButtons then MAM_ResetButtons(); end
	if m_MAM_BasicTooltipControls then
		MAM_ShowCardNow(nil, m_MAM_BasicTooltipControls, true, true);
	end
	if m_MAM_AdvancedTooltipControls then
		MAM_ShowCardNow(nil, m_MAM_AdvancedTooltipControls, true, true);
	end
	if m_MAM_LastTooltipControls and m_MAM_LastTooltipControls ~= m_MAM_BasicTooltipControls and m_MAM_LastTooltipControls ~= m_MAM_AdvancedTooltipControls then
		MAM_ShowCardNow(nil, m_MAM_LastTooltipControls, true, true);
	end
	if m_tooltipControls and m_tooltipControls ~= m_MAM_BasicTooltipControls and m_tooltipControls ~= m_MAM_AdvancedTooltipControls then
		MAM_ShowCardNow(nil, m_tooltipControls, true, true);
	end
end

function MAM_GetLocalPlayerId()
	if Network.IsMultiplayer and Network.IsMultiplayer() then
		local npid = Network.GetLocalPlayerID();
		if npid and npid >= 0 then
			return npid;
		end
	end
	if Game and Game.GetLocalPlayer then
		local gpid = Game.GetLocalPlayer();
		if gpid and gpid >= 0 then
			return gpid;
		end
	end
	return 0;
end

function MAM_GetTargetPlayerId()
	if g_MAM_ConfiguringPlayerId ~= nil and g_MAM_ConfiguringPlayerId >= 0 then
		return g_MAM_ConfiguringPlayerId;
	end
	return MAM_GetLocalPlayerId();
end

function MAM_GetConfig(id, specificPid)
	local targetPid = specificPid or g_MAM_RowPid or MAM_GetTargetPlayerId();
	local pConfig = PlayerConfigurations[targetPid];
	local val = pConfig and pConfig:GetValue(id);
	if val == nil or val == "" then
		val = "NONE";
	end
	return val;
end

function MAM_SetConfig(id, val, targetPidOverride)
	local targetPid = targetPidOverride or g_MAM_RowPid or MAM_GetTargetPlayerId();
	if not MAM_CanEditPlayerSlot(targetPid) then
		return false;
	end
	local pConfig = PlayerConfigurations[targetPid];
	if pConfig == nil then
		return false;
	end
	if pConfig:GetValue(id) ~= val then
		pConfig:SetValue(id, val);
		if g_MAM_BatchDepth > 0 then
			g_MAM_BatchPids[targetPid] = true;
		else
			MAM_BroadcastPlayer(targetPid);
		end
	end
	return true;
end

function MAM_BroadcastPlayer(pid)
	MAM_PublishSlot(pid);
	if Network.BroadcastPlayerInfo then
		Network.BroadcastPlayerInfo(pid);
	end
end

g_MAM_BatchDepth = 0;
g_MAM_BatchPids = {};
function MAM_BeginBatch()
	g_MAM_BatchDepth = g_MAM_BatchDepth + 1;
end
function MAM_EndBatch()
	g_MAM_BatchDepth = math.max(0, g_MAM_BatchDepth - 1);
	if g_MAM_BatchDepth > 0 then return; end
	local pids = g_MAM_BatchPids;
	g_MAM_BatchPids = {};
	for pid, _ in pairs(pids) do
		MAM_PublishSlot(pid);
	end
	if Network.BroadcastPlayerInfo then
		for pid, _ in pairs(pids) do
			Network.BroadcastPlayerInfo(pid);
		end
	end
end
function MAM_Batch(fn, ...)
	MAM_BeginBatch();
	local ok, err = pcall(fn, ...);
	MAM_EndBatch();
	if not ok then print("[MAM] " .. tostring(err)); end
end

local function MAM_IsUnset(v)
	return v == nil or v == "" or v == "NONE" or v == "RANDOM";
end

function MAM_GetCosmeticCiv(specificPid)
	local targetPid = specificPid or g_MAM_RowPid;
	if targetPid == nil or targetPid < 0 then
		if g_MAM_InTooltip then
			targetPid = MAM_GetTargetPlayerId();
		else
			targetPid = MAM_GetLocalPlayerId();
		end
	end
	local pConfig = PlayerConfigurations[targetPid];
	local val = pConfig and pConfig:GetValue("MAM_COSMETIC_CIV");
	if MAM_IsUnset(val) then
		val = pConfig and pConfig:GetValue("MAM_CIV_ABILITY");
	end
	if MAM_IsUnset(val) then
		val = "CIVILIZATION_MAM_BLANK";
	end
	return val;
end

function MAM_GetCosmeticLeader(specificPid)
	local targetPid = specificPid or g_MAM_RowPid;
	if targetPid == nil or targetPid < 0 then
		if g_MAM_InTooltip then
			targetPid = MAM_GetTargetPlayerId();
		else
			targetPid = MAM_GetLocalPlayerId();
		end
	end
	local pConfig = PlayerConfigurations[targetPid];
	local val = pConfig and pConfig:GetValue("MAM_COSMETIC_LEADER");
	if MAM_IsUnset(val) then
		val = pConfig and pConfig:GetValue("MAM_LEADER_ABILITY");
	end
	if MAM_IsUnset(val) then
		local cosmCiv = pConfig and pConfig:GetValue("MAM_COSMETIC_CIV");
		if MAM_IsUnset(cosmCiv) then
			cosmCiv = pConfig and pConfig:GetValue("MAM_CIV_ABILITY");
		end
		if not MAM_IsUnset(cosmCiv) and not MAM_IsMAMCiv(cosmCiv) then
			local lRow = CachedQuery("SELECT LeaderType FROM Players WHERE CivilizationType = ? AND LeaderType NOT LIKE 'LEADER_MAM_%' LIMIT 1", cosmCiv);
			if lRow and lRow[1] and lRow[1].LeaderType then
				val = lRow[1].LeaderType;
			end
		end
	end
	if MAM_IsUnset(val) then
		val = "LEADER_MAM_BLANK";
	end
	return val;
end

function MAM_GetUsedCivsAndLeaders(excludePlayerId)
	local usedCivs = {};
	local usedLeaders = {};
	local usedUnits = {};
	local usedDistricts = {};
	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();
	for _, pid in ipairs(player_ids) do
		if pid ~= excludePlayerId then
			local pConfig = PlayerConfigurations[pid];
			if pConfig then
				local lType = MAM_LeaderOf(pConfig);
				local cType = pConfig:GetCivilizationTypeName();
				if lType and lType ~= "" and lType ~= "RANDOM" and not MAM_IsMAMLeader(lType) then
					usedLeaders[lType] = true;
				end
				if cType and cType ~= "" and cType ~= "RANDOM" and not MAM_IsMAMCiv(cType) then
					usedCivs[cType] = true;
				end

				if MAM_IsMAMLeader(lType) then
					local function mark(map, key)
						local v = pConfig:GetValue(key);
						if not MAM_IsUnset(v) and not MAM_IsMAMLeader(v) and not MAM_IsMAMCiv(v) then
							map[v] = true;
						end
					end
					mark(usedCivs, "MAM_CIV_ABILITY");
					mark(usedLeaders, "MAM_LEADER_ABILITY");
					mark(usedCivs, "MAM_COSMETIC_CIV");
					mark(usedLeaders, "MAM_COSMETIC_LEADER");
					mark(usedUnits, "MAM_UNIQUE_UNIT");
					mark(usedDistricts, "MAM_UNIQUE_DISTRICT");
				end
			end
		end
	end
	return usedCivs, usedLeaders, usedUnits, usedDistricts;
end

function MAM_RollRandomBonus(domain, excludeMap)
	local items = MAM_QueryItems(domain, not MAM_AllRulesetsEnabled());
	if items and #items > 0 then
		local candidates = {};
		for _, item in ipairs(items) do
			local v = item.Value;
			if excludeMap == nil or not excludeMap[v] then
				table.insert(candidates, v);
			end
		end
		if #candidates == 0 then
			for _, item in ipairs(items) do
				table.insert(candidates, item.Value);
			end
		end
		return candidates[math.random(1, #candidates)];
	end
	return "NONE";
end

function MAM_RollRandomAll(forPlayerId, bSkipRefresh)
	local targetPid = forPlayerId or MAM_GetTargetPlayerId();
	if not MAM_CanEditPlayerSlot(targetPid) then
		return;
	end
	local usedCivs, usedLeaders, usedUnits, usedDistricts = MAM_GetUsedCivsAndLeaders(targetPid);

	local rolledCiv = MAM_RollRandomBonus("MAM_CivAbilities", usedCivs);
	local rolledLeader = MAM_RollRandomBonus("MAM_LeaderAbilities", usedLeaders);
	local rolledUnit = MAM_RollRandomBonus("MAM_UniqueUnits", usedUnits);
	local rolledDistrict = MAM_RollRandomBonus("MAM_UniqueDistricts", usedDistricts);

	MAM_Batch(function()
		MAM_SetConfig("MAM_CIV_ABILITY", rolledCiv, targetPid);
		MAM_SetConfig("MAM_LEADER_ABILITY", rolledLeader, targetPid);
		MAM_SetConfig("MAM_UNIQUE_UNIT", rolledUnit, targetPid);
		MAM_SetConfig("MAM_UNIQUE_DISTRICT", rolledDistrict, targetPid);
		MAM_SetConfig("MAM_COSMETIC_CIV", rolledCiv, targetPid);
		MAM_SetConfig("MAM_COSMETIC_LEADER", rolledLeader, targetPid);
		MAM_SetConfig("MAM_HAS_CUSTOM_COSM_CIV", "FALSE", targetPid);
		MAM_SetConfig("MAM_HAS_CUSTOM_COSM_LEADER", "FALSE", targetPid);
		MAM_SetConfig("MAM_IS_MYSTERY", "FALSE", targetPid);
	end);

	if not bSkipRefresh then
		if VisualizePlayerParameters then
			VisualizePlayerParameters();
		elseif GameSetup_RefreshParameters then
			GameSetup_RefreshParameters();
		end
	end
end

function MAM_ResolveRandomForPlayer(pid, usedCivs, usedLeaders, usedUnits, usedDistricts, bApplySlots)
	local pConfig = PlayerConfigurations[pid];
	if pConfig == nil then
		return;
	end
	local baseLeader = MAM_LeaderOf(pConfig);
	if not MAM_IsBaseConstructorLeader(baseLeader) then
		return;
	end
	if not MAM_CanEditPlayerSlot(pid) then
		return;
	end

	local anyChanged = false;
	local function setv(key, val)
		if pConfig:GetValue(key) ~= val then
			pConfig:SetValue(key, val);
			anyChanged = true;
		end
	end

	usedCivs = usedCivs or {};
	usedLeaders = usedLeaders or {};
	usedUnits = usedUnits or {};
	usedDistricts = usedDistricts or {};

	local isRandomLeader = (baseLeader == "LEADER_MAM_RANDOM");

	local function resolve(key, domain, usedMap)
		local cur = pConfig:GetValue(key);
		if cur == "RANDOM" or (isRandomLeader and (cur == nil or cur == "" or cur == "NONE")) then
			cur = MAM_RollRandomBonus(domain, usedMap);
			setv(key, cur);
		elseif cur == nil or cur == "" then
			cur = "NONE";
			setv(key, cur);
		end
		if cur ~= "NONE" then
			usedMap[cur] = true;
		end
		return cur;
	end

	local curCiv = resolve("MAM_CIV_ABILITY", "MAM_CivAbilities", usedCivs);
	local curLeader = resolve("MAM_LEADER_ABILITY", "MAM_LeaderAbilities", usedLeaders);
	resolve("MAM_UNIQUE_UNIT", "MAM_UniqueUnits", usedUnits);
	resolve("MAM_UNIQUE_DISTRICT", "MAM_UniqueDistricts", usedDistricts);

	local isMystery = (pConfig:GetValue("MAM_IS_MYSTERY") == "TRUE");

	local cosmCiv = pConfig:GetValue("MAM_COSMETIC_CIV");
	if MAM_IsUnset(cosmCiv) or MAM_IsMAMCiv(cosmCiv) then
		local target;
		if isMystery then
			target = MAM_RollRandomBonus("MAM_CivAbilities", {});
		elseif curCiv ~= "NONE" then
			target = curCiv;
		elseif isRandomLeader then
			target = MAM_RollRandomBonus("MAM_CivAbilities", usedCivs);
		end
		if bApplySlots or g_MAM_Launching then
			if target == nil or target == "NONE" then
				target = MAM_RollRandomBonus("MAM_CivAbilities", usedCivs);
			end
		end
		if target and target ~= "NONE" then
			setv("MAM_COSMETIC_CIV", target);
		end
	end

	local cosmLeader = pConfig:GetValue("MAM_COSMETIC_LEADER");
	if MAM_IsUnset(cosmLeader) or MAM_IsMAMLeader(cosmLeader) then
		local target;
		if isMystery then
			target = MAM_RollRandomBonus("MAM_LeaderAbilities", {});
		elseif curLeader ~= "NONE" then
			target = curLeader;
		elseif isRandomLeader then
			target = MAM_RollRandomBonus("MAM_LeaderAbilities", usedLeaders);
		end
		if (target == nil or target == "NONE") and cosmCiv and cosmCiv ~= "NONE" and not MAM_IsMAMCiv(cosmCiv) then
			local lRow = CachedQuery("SELECT LeaderType FROM Players WHERE CivilizationType = ? AND LeaderType NOT LIKE 'LEADER_MAM_%' LIMIT 1", cosmCiv);
			if lRow and lRow[1] and lRow[1].LeaderType then
				target = lRow[1].LeaderType;
			end
		end
		if bApplySlots or g_MAM_Launching then
			if target == nil or target == "NONE" then
				target = MAM_RollRandomBonus("MAM_LeaderAbilities", usedLeaders);
			end
		end
		if target and target ~= "NONE" then
			setv("MAM_COSMETIC_LEADER", target);
		end
	end

	if bApplySlots then
		if MAM_ApplySlotTypes(pid, baseLeader) then anyChanged = true; end
	end
	MAM_PublishSlot(pid);

	if anyChanged and Network.BroadcastPlayerInfo then
		Network.BroadcastPlayerInfo(pid);
	end
end

g_MAM_InResolve = false;
function MAM_ResolveRandomIfNecessary(bLaunch)
	if g_MAM_InResolve then return; end
	g_MAM_InResolve = true;
	local ok, err = pcall(MAM_ResolveRandomIfNecessary_Impl, bLaunch);
	g_MAM_InResolve = false;
	if not ok then print("[MAM] Resolve: " .. tostring(err)); end
end

function MAM_ResolveRandomIfNecessary_Impl(bLaunch)
	if bLaunch then g_MAM_Launching = true; end
	local player_ids = GameConfiguration.GetParticipatingPlayerIDs();

	local usedCivs, usedLeaders, usedUnits, usedDistricts = MAM_GetUsedCivsAndLeaders(-1);
	local localPlayerId = MAM_GetLocalPlayerId();

	MAM_ResolveRandomForPlayer(localPlayerId, usedCivs, usedLeaders, usedUnits, usedDistricts, bLaunch);

	if MAM_CanWriteGameConfig() then
		for _, pid in ipairs(player_ids) do
			if pid ~= localPlayerId then
				MAM_ResolveRandomForPlayer(pid, usedCivs, usedLeaders, usedUnits, usedDistricts, bLaunch);
			end
		end
	end

	MAM_PublishAllSlots(true);
	if bLaunch and MAM_CanWriteGameConfig() then
		MAM_SendGameConfig();
	end
end


function MAM_InstallGameStartHooks()
	pcall(function()
		if SetupSplitLeaderPulldown and SetupSplitLeaderPulldown ~= MAM_WrappedSetupSplitLeaderPulldown then
			local _origSetupSplit = SetupSplitLeaderPulldown;
			MAM_WrappedSetupSplitLeaderPulldown = function(playerId, instance, ...)
				local prevRow = g_MAM_RowPid;
				local prevCur = g_MAM_CurrentLobbyPlayerId;
				g_MAM_RowPid = playerId;
				g_MAM_CurrentLobbyPlayerId = playerId;
				local tooltipControls = nil;
				for i = 1, select("#", ...) do
					local a = select(i, ...);
					if type(a) == "table" then
						tooltipControls = a;
						break;
					end
				end
				if tooltipControls ~= nil then
					m_MAM_LastTooltipControls = tooltipControls;
				end
				local res = _origSetupSplit(playerId, instance, ...);
				g_MAM_RowPid = prevRow;
				g_MAM_CurrentLobbyPlayerId = prevCur;
				MAM_BindPlayerLeaderControls(playerId, instance);
				MAM_ApplyPlayerRowIcons(playerId, instance);

				pcall(function()
					local pConfig = PlayerConfigurations[playerId];
					local lType = pConfig and MAM_LeaderOf(pConfig);
					if lType == "LEADER_MAM_RANDOM" then
						local curCiv = pConfig:GetValue("MAM_CIV_ABILITY");
						if (curCiv == nil or curCiv == "" or curCiv == "NONE" or curCiv == "RANDOM") and MAM_CanEditPlayerSlot(playerId) then
							MAM_RollRandomAll(playerId, true);
						end
					end
					if playerId == MAM_GetLocalPlayerId() and tooltipControls ~= nil then
						if MAM_IsMAMLeader(lType) then
							local domain = MAM_IsSlotLeader(lType) and "Players:MAM_Slots" or "Players:StandardPlayers";
							local pInfo = GetPlayerInfo(domain, lType, playerId);
							if pInfo then
								pInfo.TargetPlayerId = playerId;
								m_currentInfo = pInfo;
								m_MAM_LastInfo = pInfo;
								if not m_MAM_WindowClosed then
									MAM_ShowCardNow(pInfo, tooltipControls, false);
								end
							end
						end
					end
				end);
				return res;
			end
			SetupSplitLeaderPulldown = MAM_WrappedSetupSplitLeaderPulldown;
		end
		if UpdatePlayerEntry and UpdatePlayerEntry ~= MAM_WrappedUpdatePlayerEntry then
			local _origUpdatePlayerEntry = UpdatePlayerEntry;
			MAM_WrappedUpdatePlayerEntry = function(playerID, ...)
				local prev = g_MAM_RowPid;
				local prevCur = g_MAM_CurrentLobbyPlayerId;
				g_MAM_RowPid = playerID;
				g_MAM_CurrentLobbyPlayerId = playerID;
				local pe = g_PlayerEntries and g_PlayerEntries[playerID];
				if pe then
					MAM_BindPlayerLeaderControls(playerID, pe);
				end
				local ok, err = pcall(_origUpdatePlayerEntry, playerID, ...);
				if pe then
					MAM_BindPlayerLeaderControls(playerID, pe);
					MAM_ApplyPlayerRowIcons(playerID, pe);
				end
				g_MAM_RowPid = prev;
				g_MAM_CurrentLobbyPlayerId = prevCur;
				if not ok then print("[MAM] UpdatePlayerEntry: " .. tostring(err)); end
			end
			UpdatePlayerEntry = MAM_WrappedUpdatePlayerEntry;
		end
	end);
	pcall(function()
		if Network and Network.LaunchGame and Network.LaunchGame ~= MAM_WrappedLaunchGame then
			local _origLaunchGame = Network.LaunchGame;
			MAM_WrappedLaunchGame = function(...)
				MAM_Trace("Network.LaunchGame called");
				MAM_TraceTypes("before launch");
				if not g_MAM_LaunchPrepared then
					g_MAM_LaunchPrepared = true;
					g_MAM_Launching = true;
					pcall(MAM_ResolveRandomIfNecessary, true);
					pcall(MAM_PublishAllSlots, true);
				end
				MAM_TraceTypes("after launch prep");
				return _origLaunchGame(...);
			end
			Network.LaunchGame = MAM_WrappedLaunchGame;
			MAM_Trace("LaunchGame hook " .. ((Network.LaunchGame == MAM_WrappedLaunchGame) and "installed" or "REJECTED by the game"));
		end
	end);
	pcall(function()
		if StartLaunchCountdown and StartLaunchCountdown ~= MAM_WrappedStartLaunchCountdown then
			local _origStartLaunchCountdown = StartLaunchCountdown;
			MAM_WrappedStartLaunchCountdown = function(...)
				MAM_TraceTypes("countdown start");
				g_MAM_Launching = true;
				g_MAM_SlotLockOverride = "LAUNCH";
				local okA, errA = pcall(MAM_AssignSlotsNow, "launch countdown");
				if not okA then MAM_Trace("AssignSlotsNow error: " .. tostring(errA)); end
				g_MAM_SlotLockOverride = nil;
				if not g_MAM_LaunchPrepared then
					g_MAM_LaunchPrepared = true;
					pcall(MAM_PublishAllSlots, true);
				end
				MAM_TraceTypes("countdown slots");
				return _origStartLaunchCountdown(...);
			end
			StartLaunchCountdown = MAM_WrappedStartLaunchCountdown;
			MAM_Trace("StartLaunchCountdown hook installed");
		end
	end);
	pcall(function()
		if StopCountdown and StopCountdown ~= MAM_WrappedStopCountdown then
			local _origStopCountdown = StopCountdown;
			MAM_WrappedStopCountdown = function(...)
				g_MAM_Launching = false;
g_MAM_LaunchPrepared = false;
				return _origStopCountdown(...);
			end
			StopCountdown = MAM_WrappedStopCountdown;
			MAM_Trace("StopCountdown hook installed");
		end
	end);
	pcall(function()
		if Network and Network.HostGame and Network.HostGame ~= MAM_WrappedNetworkHostGame then
			local _origNetworkHostGame = Network.HostGame;
			MAM_WrappedNetworkHostGame = function(...)
				MAM_Trace("Network.HostGame called");
				g_MAM_Launching = true;
				pcall(MAM_ResolveRandomIfNecessary, true);
				pcall(MAM_PublishAllSlots, true);
				MAM_TraceTypes("after host prep");
				return _origNetworkHostGame(...);
			end
			Network.HostGame = MAM_WrappedNetworkHostGame;
		end
	end);
	pcall(function()
		if SetLocalReady and SetLocalReady ~= MAM_WrappedSetLocalReady then
			local _origSetLocalReady = SetLocalReady;
			MAM_WrappedSetLocalReady = function(newReady, ...)
				local lp = PlayerConfigurations[MAM_GetLocalPlayerId()];
				local wasReady = (lp ~= nil and lp.GetReady ~= nil and lp:GetReady()) or false;
				MAM_Trace("SetLocalReady(" .. tostring(newReady) .. "), was " .. tostring(wasReady));
				if newReady == true and not wasReady then
					pcall(MAM_ResolveRandomIfNecessary);
					local okR, errR = pcall(MAM_ApplyLocalSlotOnReady);
					if not okR then MAM_Trace("ApplyLocalSlotOnReady error: " .. tostring(errR)); end
					MAM_TraceTypes("after Ready");
				end
				return _origSetLocalReady(newReady, ...);
			end
			SetLocalReady = MAM_WrappedSetLocalReady;
		end
	end);
	pcall(function()
		if HostGame and HostGame ~= MAM_WrappedHostGame then
			local _origHostGame = HostGame;
			MAM_WrappedHostGame = function(...)
				g_MAM_Launching = true;
				pcall(MAM_ResolveRandomIfNecessary, true);
				pcall(MAM_PublishAllSlots, true);
				return _origHostGame(...);
			end
			HostGame = MAM_WrappedHostGame;
		end
	end);
	pcall(function()
		if OnStartButton and OnStartButton ~= MAM_WrappedOnStartButton then
			local _origOnStart = OnStartButton;
			MAM_WrappedOnStartButton = function(...)
				if not g_MAM_LaunchPrepared then
					g_MAM_LaunchPrepared = true;
					g_MAM_Launching = true;
					pcall(MAM_ResolveRandomIfNecessary, true);
					pcall(MAM_PublishAllSlots, true);
				end
				return _origOnStart(...);
			end
			OnStartButton = MAM_WrappedOnStartButton;
		end
	end);
end
pcall(MAM_InstallGameStartHooks);

for pid = 0, MAM_MAX_SLOTS - 1 do
	pcall(MAM_RevertSlotTypes, pid, true);
end

Events.SystemUpdateUI.Add(function()
	pcall(MAM_InstallGameStartHooks);
end);

Events.PlayerInfoChanged.Add(function(playerID)
	MAM_TraceTypes("PlayerInfoChanged(" .. tostring(playerID) .. ")");
	local pConfig = PlayerConfigurations[playerID];
	if pConfig == nil then
		return;
	end
	local baseLeader = MAM_LeaderOf(pConfig);
	if MAM_IsBaseConstructorLeader(baseLeader) and MAM_CanEditPlayerSlot(playerID) and not MAM_IsHiddenContext() then
		if baseLeader == "LEADER_MAM_RANDOM" then
			local function NeedsRoll(c)
				if c == nil or not MAM_IsBaseConstructorLeader(MAM_LeaderOf(c)) or MAM_LeaderOf(c) ~= "LEADER_MAM_RANDOM" then return false; end
				local v = c:GetValue("MAM_CIV_ABILITY");
				return v == nil or v == "" or v == "NONE" or v == "RANDOM";
			end
			if NeedsRoll(pConfig) then
				MAM_Batch(function()
					for _, pid in ipairs(GameConfiguration.GetParticipatingPlayerIDs()) do
						if MAM_CanEditPlayerSlot(pid) and NeedsRoll(PlayerConfigurations[pid]) then
							MAM_RollRandomAll(pid, true);
						end
					end
				end);
			end
		end
		local isReadyHuman = (pConfig:GetSlotStatus() == SlotStatus.SS_TAKEN) and pConfig.GetReady and pConfig:GetReady();
		if not g_MAM_Launching and not g_MAM_InResolve and not isReadyHuman then
			g_MAM_InResolve = true;
			local ok, err = pcall(function()
				local uc, ul, uu, ud = MAM_GetUsedCivsAndLeaders(playerID);
				MAM_ResolveRandomForPlayer(playerID, uc, ul, uu, ud, false);
			end);
			g_MAM_InResolve = false;
			if not ok then print("[MAM] Lobby resolve: " .. tostring(err)); end
		end
		if MAM_RevertSlotTypes(playerID) and Network.BroadcastPlayerInfo then
			Network.BroadcastPlayerInfo(playerID);
		end
	end
	local published = MAM_PublishSlot(playerID);
	if published then
		g_MAM_ConfigDirty = true;
	end
	MAM_TraceTypes("after MAM PlayerInfoChanged(" .. tostring(playerID) .. ")");
end);
Events.GameConfigChanged.Add(function() MAM_TraceTypes("GameConfigChanged"); end);
MAM_Trace("PlayerSetupLogic loaded");
MAM_TraceTypes("load");

local function MAM_FindDomainItem(domain, val)
	if val == nil or val == "NONE" then return nil; end
	for _, it in ipairs(MAM_QueryItems(domain)) do
		if it.Value == val then return it; end
	end
	return nil;
end


local function MAM_GetButtonIM(parentStack)
	if parentStack == nil then return nil; end
	if m_MAM_ButtonIMs[parentStack] == nil then
		m_MAM_ButtonIMs[parentStack] = InstanceManager:new("ButtonParameterInstance", "ButtonRoot", parentStack);
	end
	return m_MAM_ButtonIMs[parentStack];
end

local function MAM_ResetButtons(parentStack)
	if parentStack ~= nil then
		if m_MAM_ButtonIMs[parentStack] ~= nil then
			m_MAM_ButtonIMs[parentStack]:ResetInstances();
		end
	else
		for _, im in pairs(m_MAM_ButtonIMs) do
			if im and im.ResetInstances then
				im:ResetInstances();
			end
		end
	end
end

local function MAM_AddButton(parentStack, buttonText, onClickCallback, isSelected)
	local buttonIM = MAM_GetButtonIM(parentStack);
	if buttonIM == nil then return nil; end
	local btnInst = buttonIM:GetInstance();
	if btnInst == nil then return nil; end
	if btnInst.ButtonRoot then
		btnInst.ButtonRoot:SetSizeX(320);
		btnInst.ButtonRoot:SetSizeY(30);
	end
	if btnInst.Button then
		btnInst.Button:SetAnchor("C,T");
		btnInst.Button:SetOffsetVal(0, 0);
		btnInst.Button:SetSizeX(320);
		btnInst.Button:SetSizeY(24);
		btnInst.Button:SetText(buttonText);
		if isSelected then
			btnInst.Button:SetDisabled(true);
			btnInst.Button:ClearCallback(Mouse.eLClick);
			btnInst.Button:ClearCallback(Mouse.eMouseEnter);
		else
			btnInst.Button:SetDisabled(false);
			btnInst.Button:RegisterCallback(Mouse.eLClick, function()
				UI.PlaySound("Play_UI_Click");
				if onClickCallback then
					MAM_Batch(onClickCallback);
				end
			end);
			btnInst.Button:RegisterCallback(Mouse.eMouseEnter, function()
				UI.PlaySound("Main_Menu_Mouse_Over");
			end);
		end
	end
	if btnInst.StringName then
		btnInst.StringName:SetText("");
		btnInst.StringName:SetHide(true);
	end
	return btnInst;
end

local _GetPlayerIconsCache = {};
local _GetPlayerIconsDefaultValue = {
	LeaderIcon = "ICON_LEADER_DEFAULT",
	CivIcon = "ICON_CIVILIZATION_UNKNOWN"
};

function GetPlayerIcons(domain, leader_type, specificPid)
	if (leader_type == "RANDOM_POOL1") then
		return {
			LeaderIcon = "ICON_LEADER_RANDOM_POOL_1",
			CivIcon = "ICON_CIVILIZATION_UNKNOWN"
		};
	elseif (leader_type == "RANDOM_POOL2") then
		return {
			LeaderIcon = "ICON_LEADER_RANDOM_POOL_2",
			CivIcon = "ICON_CIVILIZATION_UNKNOWN"
		};
	elseif MAM_IsMAMLeader(leader_type) then
		local slotPid = MAM_SlotIndexFromLeader(leader_type);
		local targetPid = slotPid or specificPid or g_MAM_RowPid;
		if targetPid == nil or targetPid < 0 then
			if g_MAM_InTooltip and g_MAM_ConfiguringPlayerId ~= nil and g_MAM_ConfiguringPlayerId >= 0 then
				targetPid = g_MAM_ConfiguringPlayerId;
			else
				targetPid = -1;
			end
		end
		if targetPid < 0 then
			return {
				LeaderIcon = "ICON_LEADER_DEFAULT",
				CivIcon = "ICON_CIVILIZATION_UNKNOWN",
				PlayerColor = "COLOR_MAM_PRIMARY"
			};
		end
		local cosmCiv = MAM_GetCosmeticCiv(targetPid);
		local cosmLeader = MAM_GetCosmeticLeader(targetPid);
		local civIcon = "ICON_" .. cosmCiv;
		local leaderIcon = "ICON_" .. cosmLeader;
		local playerColor = (slotPid ~= nil) and ("LEADER_MAM_P" .. tostring(slotPid)) or cosmLeader;

		local civQuery = CachedQuery("SELECT CivilizationIcon FROM Players WHERE CivilizationType = ? LIMIT 1", cosmCiv);
		if civQuery and #civQuery > 0 and civQuery[1] and civQuery[1].CivilizationIcon then
			civIcon = civQuery[1].CivilizationIcon;
		end

		local leadQuery = CachedQuery("SELECT LeaderIcon, PlayerColor FROM Players WHERE LeaderType = ? LIMIT 1", cosmLeader);
		if leadQuery and #leadQuery > 0 and leadQuery[1] then
			if leadQuery[1].LeaderIcon then leaderIcon = leadQuery[1].LeaderIcon; end
			if leadQuery[1].PlayerColor then playerColor = leadQuery[1].PlayerColor; end
		end

		return {
			LeaderIcon = leaderIcon,
			CivIcon = civIcon,
			PlayerColor = playerColor
		};
	elseif (leader_type ~= "RANDOM") then

		local changes = DB.ConfigurationChanges();
		if(changes ~= _GetPlayerIconsCache[1]) then
			_GetPlayerIconsCache = {changes};
		end

		local key = domain .. "|" .. leader_type;
		local value = _GetPlayerIconsCache[key];
		if(value) then
			return value;
		else
			local info_query = "SELECT CivilizationIcon, LeaderIcon, PlayerColor from Players where Domain = ? and LeaderType = ? LIMIT 1";
			local results = CachedQuery(info_query, domain, leader_type);
			if(results) then
				local row = results[1];

				local playerColor = row.PlayerColor or leader_type;

				local info = {
					LeaderIcon = row.LeaderIcon,
					CivIcon = row.CivilizationIcon,
					PlayerColor = playerColor
				};
				_GetPlayerIconsCache[key] = info;

				return info;
			end
		end
	end

	return _GetPlayerIconsDefaultValue;
end

function GetPlayerInfo(domain, leader_type, specificPid)
	if(leader_type ~= "RANDOM" and leader_type ~= "RANDOM_POOL1" and leader_type ~= "RANDOM_POOL2") then
		local info_query = "SELECT CivilizationIcon, LeaderIcon, LeaderName, CivilizationName, LeaderAbilityName, LeaderAbilityDescription, LeaderAbilityIcon, CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon, Portrait, PortraitBackground, PlayerColor from Players where Domain = ? and LeaderType = ? LIMIT 1";
		local item_query = "SELECT Type, Name, Description, Icon, SortIndex from PlayerItems where Domain = ? and LeaderType = ?";
		local info_results = CachedQuery(info_query, domain, leader_type);
		local item_results = CachedQuery(item_query, domain, leader_type);

		local playerInfoOverrides, playerItemOverrides = SyncPlayerOverrides();

		local filteredItems = {};
		for i,v in ipairs(playerItemOverrides) do
			if(v.Domain == domain and v.LeaderType == leader_type) then
				table.insert(filteredItems, v);
			end
		end
		if(info_results and item_results) then
			local info = {};
			info.LeaderType = leader_type;

			local abilities = {};
			for i,row in ipairs(info_results) do
				info.PlayerColor = row.PlayerColor or leader_type;
				info.CivilizationIcon= row.CivilizationIcon;
				info.LeaderIcon= row.LeaderIcon;
				info.LeaderName = row.LeaderName;
				info.CivilizationName = row.CivilizationName;
				info.Portrait = row.Portrait;
				info.PortraitBackground = row.PortraitBackground;

				abilities.LeaderAbilityName = row.LeaderAbilityName;
				abilities.LeaderAbilityDescription = row.LeaderAbilityDescription;
				abilities.LeaderAbilityIcon = row.LeaderAbilityIcon;

				abilities.CivilizationAbilityName = row.CivilizationAbilityName;
				abilities.CivilizationAbilityDescription = row.CivilizationAbilityDescription;
				abilities.CivilizationAbilityIcon = row.CivilizationAbilityIcon;
			end

			local slotPid = MAM_SlotIndexFromLeader(leader_type);
			local targetPid = slotPid or specificPid or g_MAM_RowPid;
			info.TargetPlayerId = targetPid;
			if MAM_IsMAMLeader(leader_type) then
				if targetPid == nil or targetPid < 0 then
					if g_MAM_InTooltip and g_MAM_ConfiguringPlayerId ~= nil and g_MAM_ConfiguringPlayerId >= 0 then
						targetPid = g_MAM_ConfiguringPlayerId;
					else
						targetPid = -1;
					end
				end
				info.TargetPlayerId = targetPid;
				if targetPid >= 0 then
					local cosmCiv = MAM_GetCosmeticCiv(targetPid);
					local cosmLeader = MAM_GetCosmeticLeader(targetPid);
					local lRows = CachedQuery("SELECT LeaderName, Portrait, PortraitBackground, LeaderIcon, PlayerColor FROM Players WHERE LeaderType = ? LIMIT 1", cosmLeader);
					local cRows = CachedQuery("SELECT CivilizationName, CivilizationIcon FROM Players WHERE CivilizationType = ? LIMIT 1", cosmCiv);
					if lRows and lRows[1] then
						if lRows[1].LeaderName then info.LeaderName = lRows[1].LeaderName; end
						if lRows[1].Portrait then info.Portrait = lRows[1].Portrait; end
						if lRows[1].PortraitBackground then info.PortraitBackground = lRows[1].PortraitBackground; end
						if lRows[1].LeaderIcon then info.LeaderIcon = lRows[1].LeaderIcon; end
						if lRows[1].PlayerColor then info.PlayerColor = lRows[1].PlayerColor; else info.PlayerColor = (slotPid ~= nil and ("LEADER_MAM_P" .. tostring(slotPid)) or cosmLeader); end
					else
						info.PlayerColor = (slotPid ~= nil and ("LEADER_MAM_P" .. tostring(slotPid)) or cosmLeader);
					end
					if cRows and cRows[1] then
						if cRows[1].CivilizationName then info.CivilizationName = cRows[1].CivilizationName; end
						if cRows[1].CivilizationIcon then info.CivilizationIcon = cRows[1].CivilizationIcon; end
					end
				end
			end

			for i,v in ipairs(playerInfoOverrides) do
				if(v.Domain == domain and v.LeaderType == leader_type) then
					if(v.CivilizationAbilityName) then abilities.CivilizationAbilityName = v.CivilizationAbilityName; end
					if(v.CivilizationAbilityDescription) then abilities.CivilizationAbilityDescription = v.CivilizationAbilityDescription; end
					if(v.CivilizationAbilityIcon) then abilities.CivilizationAbilityIcon = v.CivilizationAbilityIcon; end
					if(v.LeaderAbilityName) then abilities.LeaderAbilityName = v.LeaderAbilityName; end
					if(v.LeaderAbilityDescription) then abilities.LeaderAbilityDescription = v.LeaderAbilityDescription; end
					if(v.LeaderAbilityIcon) then abilities.LeaderAbilityIcon = v.LeaderAbilityIcon; end
				end
			end

			if (CanShowLeaderAbility(abilities)) then
				info.LeaderAbility = {
					Name = abilities.LeaderAbilityName,
					Description = abilities.LeaderAbilityDescription,
					Icon = abilities.LeaderAbilityIcon
				};
			end

			if (CanShowCivAbility(abilities)) then
				info.CivilizationAbility = {
					Name = abilities.CivilizationAbilityName,
					Description = abilities.CivilizationAbilityDescription,
					Icon = abilities.CivilizationAbilityIcon
				};
			end

			local uniques = {};
			for i,row in ipairs(item_results) do
				uniques[row.Type] = {
					Name = row.Name,
					Description = row.Description,
					Icon = row.Icon,
					SortIndex = row.SortIndex,
					ShouldRemove = false
				};
			end

			for i,v in ipairs(filteredItems) do
				local u = uniques[v.Type];
				if(u == nil) then
					u = {
						SortIndex = 0,
						ShouldRemove = false
					};
					uniques[v.Type] = u;
				end

				if(v.Name) then u.Name = v.Name end
				if(v.Description) then u.Description = v.Description; end
				if(v.Icon) then u.Icon = v.Icon; end
				if(v.SortIndex ~= nil) then u.SortIndex = v.SortIndex; end
				if(v.ShouldRemove ~= nil) then u.ShouldRemove = v.ShouldRemove; end
			end


			info.Uniques = {};
			for k,v in pairs(uniques) do
				if(v.ShouldRemove == false and v.Name and v.Name ~= "NONE" and v.Description and v.Description ~= "NONE" and v.Icon) then
					table.insert(info.Uniques, {
						Name = v.Name,
						Description = v.Description,
						Icon = v.Icon,
						SortIndex = v.SortIndex;
					})
				end
			end

			table.sort(info.Uniques, function(a,b) return a.SortIndex < b.SortIndex; end);

			return info;
		end
	end

	return {
		CivilizationIcon = "ICON_CIVILIZATION_UNKNOWN",
		LeaderIcon = "ICON_LEADER_DEFAULT",
		CivilizationName = "LOC_RANDOM_CIVILIZATION",
		LeaderName = "LOC_RANDOM_LEADER",
		LeaderType = leader_type,
	};
end

function GenerateToolTipFromPlayerInfo(info)
	local lines = {};
	table.insert(lines, Locale.Lookup(info.LeaderName));
	table.insert(lines, Locale.Lookup(info.CivilizationName));
	if(info.CivilizationAbility) then
		local ability = info.CivilizationAbility;
		table.insert(lines, "--------------------------------");
		table.insert(lines, Locale.Lookup(ability.Name));
		table.insert(lines, Locale.Lookup(ability.Description));
	end

	if(info.LeaderAbility) then
		local ability = info.LeaderAbility;
		table.insert(lines, "--------------------------------");
		table.insert(lines, Locale.Lookup(ability.Name));
		table.insert(lines, Locale.Lookup(ability.Description));
	end

	if(info.Uniques and #info.Uniques > 0) then
		table.insert(lines, "--------------------------------");
		for i,v in ipairs(info.Uniques) do
			table.insert(lines, Locale.Lookup(v.Name));
			table.insert(lines, Locale.Lookup(v.Description) .. "[NEWLINE]");

		end
	end
	return table.concat(lines, "[NEWLINE]");
end

function DisplayCivLeaderToolTip(info:table, tooltipControls:table, alwaysHide:boolean, bForceHide:boolean)
	g_MAM_InTooltip = true;
	local ok, err = pcall(function()
		if tooltipControls ~= nil then
			m_MAM_LastTooltipControls = tooltipControls;
			if tooltipControls.HasLeaderPlacard then
				m_MAM_BasicTooltipControls = tooltipControls;
			else
				m_MAM_AdvancedTooltipControls = tooltipControls;
			end
		end

		local isConstructor = (info and MAM_IsMAMLeader(info.LeaderType));
		if (alwaysHide or info == nil) then
			if bForceHide or m_MAM_WindowClosed or g_MAM_Launching or (tooltipControls and not tooltipControls.HasLeaderPlacard and not isConstructor) then
				if tooltipControls then
					if tooltipControls.CivLeaderAlpha then tooltipControls.CivLeaderAlpha:SetHide(true); end
					if tooltipControls.CivLeaderSlide then tooltipControls.CivLeaderSlide:SetHide(true); end
					if tooltipControls.CivToolTipAlpha then tooltipControls.CivToolTipAlpha:SetHide(true); end
					if tooltipControls.CivToolTipSlide then tooltipControls.CivToolTipSlide:SetHide(true); end
					HideControl(tooltipControls.CivLeaderAlpha, tooltipControls.CivLeaderSlide);
					HideControl(tooltipControls.CivToolTipAlpha, tooltipControls.CivToolTipSlide);
				end
				return;
			end
			return;
		end

		local slotPid = info and MAM_SlotIndexFromLeader(info.LeaderType);
		if slotPid ~= nil then
			g_MAM_ConfiguringPlayerId = slotPid;
			info.TargetPlayerId = slotPid;
		elseif info and info.TargetPlayerId ~= nil and info.TargetPlayerId >= 0 then
			g_MAM_ConfiguringPlayerId = info.TargetPlayerId;
		elseif g_MAM_RowPid ~= nil and g_MAM_RowPid >= 0 then
			g_MAM_ConfiguringPlayerId = g_MAM_RowPid;
			if info then info.TargetPlayerId = g_MAM_RowPid; end
		end

		local targetPid = slotPid or ((info and info.TargetPlayerId ~= nil and info.TargetPlayerId >= 0) and info.TargetPlayerId) or g_MAM_ConfiguringPlayerId or MAM_GetTargetPlayerId();
		if targetPid ~= nil and targetPid >= 0 then
			g_MAM_ConfiguringPlayerId = targetPid;
			if info then info.TargetPlayerId = targetPid; end
		end

		m_MAM_WindowClosed = false;

		local showLeaderPortrait = false;
		local showToolTip = false;
		if info and info.CivilizationName ~= "LOC_RANDOM_CIVILIZATION" then
			showLeaderPortrait, showToolTip = SetUniqueCivLeaderData(info, tooltipControls);
		end

		if showLeaderPortrait then
			ShowControl(tooltipControls.CivLeaderAlpha, tooltipControls.CivLeaderSlide);
		else
			HideControl(tooltipControls.CivLeaderAlpha, tooltipControls.CivLeaderSlide);
		end

		if showToolTip then
			if tooltipControls.CivToolTipAlpha then
				tooltipControls.CivToolTipAlpha:SetHide(false);
				if tooltipControls.CivToolTipAlpha.SetToEnd then
					tooltipControls.CivToolTipAlpha:SetToEnd();
				elseif tooltipControls.CivToolTipAlpha.SetProgress then
					tooltipControls.CivToolTipAlpha:SetProgress(1.0);
				end
			end
			if tooltipControls.CivToolTipSlide then
				tooltipControls.CivToolTipSlide:SetHide(false);
				if tooltipControls.CivToolTipSlide.SetToEnd then
					tooltipControls.CivToolTipSlide:SetToEnd();
				elseif tooltipControls.CivToolTipSlide.SetProgress then
					tooltipControls.CivToolTipSlide:SetProgress(1.0);
				end
			end
		else
			HideControl(tooltipControls.CivToolTipAlpha, tooltipControls.CivToolTipSlide);
		end
	end);
	g_MAM_InTooltip = false;
	if not ok then
		print("MAM ERROR in DisplayCivLeaderToolTip: " .. tostring(err));
	end
end

MAM_CARD_HOVER_DELAY = 0.4;
local MAM_DisplayCivLeaderToolTipNow = DisplayCivLeaderToolTip;
local m_MAM_CardPending = nil;
local m_MAM_CardWait = 0;

MAM_CancelPendingCard = function()
	if m_MAM_CardPending ~= nil then
		m_MAM_CardPending = nil;
		m_MAM_CardWait = 0;
	end
end

local function MAM_CardTick(dt)
	local p = m_MAM_CardPending;
	if p == nil then
		return;
	end
	m_MAM_CardWait = m_MAM_CardWait + (tonumber(dt) or 0.016);
	if m_MAM_CardWait >= MAM_CARD_HOVER_DELAY then
		local pending = p;
		MAM_CancelPendingCard();
		m_MAM_WindowClosed = false;
		m_currentInfo = pending.info;
		m_MAM_LastInfo = pending.info;
		MAM_DisplayCivLeaderToolTipNow(pending.info, pending.controls, false, false);
	end
end

function MAM_ShowCardNow(info, tooltipControls, alwaysHide, bForceHide)
	MAM_CancelPendingCard();
	MAM_DisplayCivLeaderToolTipNow(info, tooltipControls, alwaysHide, bForceHide);
end

local bMAM_ScreenButtonsHooked = false;
local m_MAM_LastCreateGameHidden = nil;

local function MAM_MasterTick(dt)
	if not bMAM_ScreenButtonsHooked then
		bMAM_ScreenButtonsHooked = true;
		if Controls then
			if Controls.AdvancedSetupButton then
				local prevAdv = OnAdvancedSetup;
				Controls.AdvancedSetupButton:RegisterCallback(Mouse.eLClick, function()
					MAM_CloseWindow();
					if OnAdvancedSetup then OnAdvancedSetup(); elseif prevAdv then prevAdv(); end
				end);
			end
			if Controls.CloseButton then
				local prevBack = OnBackButton;
				Controls.CloseButton:RegisterCallback(Mouse.eLClick, function()
					MAM_CloseWindow();
					if OnBackButton then OnBackButton(); elseif prevBack then prevBack(); end
				end);
			end
			if Controls.DefaultButton then
				local prevDef = OnDefaultButton;
				Controls.DefaultButton:RegisterCallback(Mouse.eLClick, function()
					MAM_CloseWindow();
					if OnDefaultButton then OnDefaultButton(); elseif prevDef then prevDef(); end
				end);
			end
		end
		if OnAdvancedSetup then
			local baseAdv = OnAdvancedSetup;
			OnAdvancedSetup = function(...)
				MAM_CloseWindow();
				return baseAdv(...);
			end
		end
		if OnBackButton then
			local baseBack = OnBackButton;
			OnBackButton = function(...)
				MAM_CloseWindow();
				return baseBack(...);
			end
		end
	end

	if Controls and Controls.CreateGameWindow and Controls.CreateGameWindow.IsHidden then
		local isCreateHidden = Controls.CreateGameWindow:IsHidden();
		if m_MAM_LastCreateGameHidden ~= nil and m_MAM_LastCreateGameHidden ~= isCreateHidden then
			MAM_CloseWindow();
			if not isCreateHidden then
				UpdateCivLeaderToolTip();
			end
		end
		m_MAM_LastCreateGameHidden = isCreateHidden;
	end

	if m_MAM_CardPending ~= nil then
		MAM_CardTick(dt);
	end
end

if ContextPtr and ContextPtr.SetUpdate then
	pcall(function() ContextPtr:SetUpdate(MAM_MasterTick); end);
end

function DisplayCivLeaderToolTip(info, tooltipControls, alwaysHide, bForceHide)
	local isConstructor = (info and MAM_IsMAMLeader(info.LeaderType));
	if alwaysHide then
		MAM_CancelPendingCard();
		if bForceHide or m_MAM_WindowClosed or g_MAM_Launching or (tooltipControls and not tooltipControls.HasLeaderPlacard and not isConstructor) then
			MAM_ShowCardNow(info, tooltipControls, true, true);
		end
		return;
	end
	if info == nil then
		MAM_CancelPendingCard();
		if bForceHide or m_MAM_WindowClosed or g_MAM_Launching or (tooltipControls and not tooltipControls.HasLeaderPlacard and not isConstructor) then
			MAM_ShowCardNow(info, tooltipControls, true, true);
		end
		return;
	end
	if g_MAM_DirectShow == true or MAM_CARD_HOVER_DELAY <= 0 or not (ContextPtr and ContextPtr.SetUpdate) then
		MAM_ShowCardNow(info, tooltipControls, false, false);
		return;
	end
	m_MAM_CardPending = { info = info, controls = tooltipControls };
	m_MAM_CardWait = 0;
	if ContextPtr and ContextPtr.SetUpdate then
		pcall(function() ContextPtr:SetUpdate(MAM_MasterTick); end);
	else
		MAM_ShowCardNow(info, tooltipControls, false, false);
	end
end

function UpdateCivLeaderToolTip()
	local tc = (m_MAM_BasicTooltipControls ~= nil and m_MAM_BasicTooltipControls.InfoStack ~= nil) and m_MAM_BasicTooltipControls or (m_MAM_AdvancedTooltipControls ~= nil and m_MAM_AdvancedTooltipControls.InfoStack ~= nil and m_MAM_AdvancedTooltipControls) or (m_MAM_LastTooltipControls ~= nil and m_MAM_LastTooltipControls.InfoStack ~= nil and m_MAM_LastTooltipControls) or nil;
	if m_currentInfo and m_currentInfo.LeaderType ~= nil and tc ~= nil then
		g_MAM_InTooltip = true;
		pcall(function()
			local isConstructor = MAM_IsMAMLeader(m_currentInfo.LeaderType);
			if isConstructor then
				m_MAM_WindowClosed = false;
				MAM_ShowCardNow(m_currentInfo, tc, false);
			else
				MAM_ShowCardNow(m_currentInfo, tc, false);
			end
		end);
		g_MAM_InTooltip = false;
	end
end


function SetMAMConstructorData(info:table, tooltipControls:table)
	if tooltipControls == nil then
		tooltipControls = m_MAM_LastTooltipControls;
	end
	if info == nil then
		info = m_MAM_LastInfo;
	end
	if tooltipControls == nil or info == nil or tooltipControls.InfoStack == nil then
		return false, false;
	end

	m_MAM_LastTooltipControls = tooltipControls;
	m_MAM_LastInfo = info;

	local slotPid = info and MAM_SlotIndexFromLeader(info.LeaderType);
	local targetPid = slotPid or ((info and info.TargetPlayerId ~= nil and info.TargetPlayerId >= 0) and info.TargetPlayerId) or g_MAM_ConfiguringPlayerId or MAM_GetTargetPlayerId();
	if g_MAM_ConfiguringPlayerId ~= targetPid then
		m_MAM_View = "OVERVIEW";
	end
	g_MAM_ConfiguringPlayerId = targetPid;
	if info then info.TargetPlayerId = targetPid; end
	local canEdit = MAM_CanEditPlayerSlot(targetPid);
	if not canEdit then
		m_MAM_View = "OVERVIEW";
	end

	local cosmCiv = MAM_GetCosmeticCiv(targetPid);
	local cosmLeader = MAM_GetCosmeticLeader(targetPid);

	local hasLeaderPlacard = false;
	if tooltipControls.HasLeaderPlacard then
		tooltipControls.LeaderImage:UnloadTexture();
		tooltipControls.LeaderBG:UnloadTexture();
		tooltipControls.DummyImage:UnloadTexture();

		local lRows = CachedQuery("SELECT Portrait, PortraitBackground FROM Players WHERE LeaderType = ? LIMIT 1", cosmLeader);
		local leaderPortrait = (lRows and lRows[1] and lRows[1].Portrait) or (cosmLeader .. "_NEUTRAL");
		local leaderBGImage = (lRows and lRows[1] and lRows[1].PortraitBackground) or (cosmLeader .. "_BACKGROUND");

		tooltipControls.DummyImage:SetTexture(leaderPortrait);
		tooltipControls.LeaderImage:SetTexture(leaderPortrait);
		local imageRatio = tooltipControls.DummyImage:GetSizeX() / tooltipControls.DummyImage:GetSizeY();
		if (imageRatio > .51) then
			tooltipControls.LeaderImage:SetTextureOffsetVal(30, 10);
		else
			tooltipControls.LeaderImage:SetTextureOffsetVal(10, 50);
		end

		tooltipControls.LeaderBG:SetTexture(leaderBGImage);
		hasLeaderPlacard = true;
	end

	if tooltipControls.HeaderIconIM then tooltipControls.HeaderIconIM:ResetInstances(); end
	if tooltipControls.UniqueIconIM then tooltipControls.UniqueIconIM:ResetInstances(); end
	if tooltipControls.HeaderIM then tooltipControls.HeaderIM:ResetInstances(); end
	if tooltipControls.CivHeaderIconIM then tooltipControls.CivHeaderIconIM:ResetInstances(); end
	MAM_ResetButtons(tooltipControls.InfoStack);

	MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CLOSE"), function()
		MAM_CloseWindow();
	end, false);

	if m_MAM_View == "OVERVIEW" then
		if tooltipControls.HeaderIM then
			local titleInst = tooltipControls.HeaderIM:GetInstance();
			if titleInst and titleInst.Header then
				titleInst.Header:SetText(Locale.ToUpper(Locale.Lookup("LOC_MAM_UI_TITLE")));
			end
			local hintInst = tooltipControls.HeaderIM:GetInstance();
			if hintInst and hintInst.Header then
				hintInst.Header:SetText(Locale.Lookup("LOC_MAM_UI_HINT"));
			end
		end

		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_REROLL_NOW"), function()
				MAM_RollRandomAll(targetPid);
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);

			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_MYSTERY_RANDOM"), function()
				local usedCivs, usedLeaders, usedUnits, usedDistricts = MAM_GetUsedCivsAndLeaders(targetPid);
				local rolledCiv = MAM_RollRandomBonus("MAM_CivAbilities", usedCivs);
				usedCivs[rolledCiv] = true;
				local rolledLeader = MAM_RollRandomBonus("MAM_LeaderAbilities", usedLeaders);
				usedLeaders[rolledLeader] = true;
				local rolledUnit = MAM_RollRandomBonus("MAM_UniqueUnits", usedUnits);
				usedUnits[rolledUnit] = true;
				local rolledDistrict = MAM_RollRandomBonus("MAM_UniqueDistricts", usedDistricts);
				usedDistricts[rolledDistrict] = true;

				MAM_SetConfig("MAM_CIV_ABILITY", rolledCiv, targetPid);
				MAM_SetConfig("MAM_LEADER_ABILITY", rolledLeader, targetPid);
				MAM_SetConfig("MAM_UNIQUE_UNIT", rolledUnit, targetPid);
				MAM_SetConfig("MAM_UNIQUE_DISTRICT", rolledDistrict, targetPid);
				MAM_SetConfig("MAM_COSMETIC_CIV", "CIVILIZATION_MAM_BLANK", targetPid);
				MAM_SetConfig("MAM_COSMETIC_LEADER", "LEADER_MAM_BLANK", targetPid);
				MAM_SetConfig("MAM_HAS_CUSTOM_COSM_CIV", "FALSE", targetPid);
				MAM_SetConfig("MAM_HAS_CUSTOM_COSM_LEADER", "FALSE", targetPid);
				MAM_SetConfig("MAM_IS_MYSTERY", "TRUE", targetPid);
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);

			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CLEAR_ALL"), function()
				MAM_SetConfig("MAM_CIV_ABILITY", "NONE", targetPid);
				MAM_SetConfig("MAM_LEADER_ABILITY", "NONE", targetPid);
				MAM_SetConfig("MAM_UNIQUE_UNIT", "NONE", targetPid);
				MAM_SetConfig("MAM_UNIQUE_DISTRICT", "NONE", targetPid);
				MAM_SetConfig("MAM_COSMETIC_CIV", "CIVILIZATION_MAM_BLANK", targetPid);
				MAM_SetConfig("MAM_COSMETIC_LEADER", "LEADER_MAM_BLANK", targetPid);
				MAM_SetConfig("MAM_HAS_CUSTOM_COSM_CIV", "FALSE", targetPid);
				MAM_SetConfig("MAM_HAS_CUSTOM_COSM_LEADER", "FALSE", targetPid);
				MAM_SetConfig("MAM_IS_MYSTERY", "FALSE", targetPid);
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		local isMystery = (MAM_GetConfig("MAM_IS_MYSTERY", targetPid) == "TRUE");

		local curCiv = MAM_GetConfig("MAM_CIV_ABILITY", targetPid);
		local civItem = MAM_FindDomainItem("MAM_CivAbilities", curCiv);
		local civCard = tooltipControls.CivHeaderIconIM and tooltipControls.CivHeaderIconIM:GetInstance();
		if civCard then
			if isMystery then
				civCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				civCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_CIV_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
				civCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif curCiv == "RANDOM" then
				civCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				civCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_CIV_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_RANDOM_NAME"));
				civCard.Description:LocalizeAndSetText("LOC_MAM_RANDOM_DESC");
			elseif curCiv == "NONE" then
				civCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				civCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_CIV_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				civCard.Description:LocalizeAndSetText("LOC_MAM_NONE_DESC");
			elseif civItem then
				civCard.Icon:SetIcon(civItem.Icon);
				civCard.Header:SetText(Locale.ToUpper(Locale.Lookup(civItem.Name)));
				civCard.Description:LocalizeAndSetText(civItem.Description);
				local colorRows = CachedQuery("SELECT LeaderType, PlayerColor FROM Players WHERE CivilizationType = ? LIMIT 1", curCiv);
				local playerColorName = (colorRows and colorRows[1] and (colorRows[1].PlayerColor or colorRows[1].LeaderType)) or curCiv;
				local backColor, frontColor = UI.GetPlayerColorValues(playerColorName, 0);
				if backColor and frontColor and backColor ~= 0 and frontColor ~= 0 then
					if civCard.IconBG then civCard.IconBG:SetColor(backColor); end
					if civCard.Icon then civCard.Icon:SetColor(frontColor); end
				end
			else
				civCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				civCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_CIV_HEADER"));
				civCard.Description:LocalizeAndSetText("LOC_MAM_UI_PROMPT_CIV");
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup((civItem or curCiv == "RANDOM" or isMystery) and "LOC_MAM_UI_CHANGE" or "LOC_MAM_UI_CHOOSE"), function()
				m_MAM_View = "CIV_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		local curLeader = MAM_GetConfig("MAM_LEADER_ABILITY", targetPid);
		local leaderItem = MAM_FindDomainItem("MAM_LeaderAbilities", curLeader);
		local leaderCard = tooltipControls.HeaderIconIM and tooltipControls.HeaderIconIM:GetInstance();
		if leaderCard then
			if isMystery then
				leaderCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_1");
				leaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_LEADER_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
				leaderCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif curLeader == "RANDOM" then
				leaderCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_1");
				leaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_LEADER_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_RANDOM_NAME"));
				leaderCard.Description:LocalizeAndSetText("LOC_MAM_RANDOM_DESC");
			elseif curLeader == "NONE" then
				leaderCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				leaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_LEADER_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				leaderCard.Description:LocalizeAndSetText("LOC_MAM_NONE_DESC");
			elseif leaderItem then
				leaderCard.Icon:SetIcon(leaderItem.Icon);
				leaderCard.Header:SetText(Locale.ToUpper(Locale.Lookup(leaderItem.Name)));
				leaderCard.Description:LocalizeAndSetText(leaderItem.Description);
			else
				leaderCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				leaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_LEADER_HEADER"));
				leaderCard.Description:LocalizeAndSetText("LOC_MAM_UI_PROMPT_LEADER");
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup((leaderItem or curLeader == "RANDOM" or isMystery) and "LOC_MAM_UI_CHANGE" or "LOC_MAM_UI_CHOOSE"), function()
				m_MAM_View = "LEADER_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		local curUnit = MAM_GetConfig("MAM_UNIQUE_UNIT", targetPid);
		local unitItem = MAM_FindDomainItem("MAM_UniqueUnits", curUnit);
		local unitCard = tooltipControls.UniqueIconIM and tooltipControls.UniqueIconIM:GetInstance();
		if unitCard then
			if isMystery then
				unitCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_2");
				unitCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_UNIT_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
				unitCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif curUnit == "RANDOM" then
				unitCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_2");
				unitCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_UNIT_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_RANDOM_NAME"));
				unitCard.Description:LocalizeAndSetText("LOC_MAM_RANDOM_DESC");
			elseif curUnit == "NONE" then
				unitCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				unitCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_UNIT_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				unitCard.Description:LocalizeAndSetText("LOC_MAM_NONE_DESC");
			elseif unitItem then
				unitCard.Icon:SetIcon(unitItem.Icon);
				unitCard.Header:SetText(Locale.ToUpper(Locale.Lookup(unitItem.Name)));
				unitCard.Description:LocalizeAndSetText(unitItem.Description);
			else
				unitCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				unitCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_UNIT_HEADER"));
				unitCard.Description:LocalizeAndSetText("LOC_MAM_UI_PROMPT_UNIT");
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup((unitItem or curUnit == "RANDOM" or isMystery) and "LOC_MAM_UI_CHANGE" or "LOC_MAM_UI_CHOOSE"), function()
				m_MAM_View = "UNIT_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		local curDistrict = MAM_GetConfig("MAM_UNIQUE_DISTRICT", targetPid);
		local distItem = MAM_FindDomainItem("MAM_UniqueDistricts", curDistrict);
		local distCard = tooltipControls.UniqueIconIM and tooltipControls.UniqueIconIM:GetInstance();
		if distCard then
			if isMystery then
				distCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_2");
			distCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_DISTRICT_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
			distCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif curDistrict == "RANDOM" then
				distCard.Icon:SetIcon("ICON_LEADER_RANDOM_POOL_2");
				distCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_DISTRICT_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_RANDOM_NAME"));
				distCard.Description:LocalizeAndSetText("LOC_MAM_RANDOM_DESC");
			elseif curDistrict == "NONE" then
				distCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				distCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_DISTRICT_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				distCard.Description:LocalizeAndSetText("LOC_MAM_NONE_DESC");
			elseif distItem then
				distCard.Icon:SetIcon(distItem.Icon);
				distCard.Header:SetText(Locale.ToUpper(Locale.Lookup(distItem.Name)));
				distCard.Description:LocalizeAndSetText(distItem.Description);
			else
				distCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				distCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_DISTRICT_HEADER"));
				distCard.Description:LocalizeAndSetText("LOC_MAM_UI_PROMPT_DISTRICT");
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup((distItem or curDistrict == "RANDOM" or isMystery) and "LOC_MAM_UI_CHANGE" or "LOC_MAM_UI_CHOOSE"), function()
				m_MAM_View = "DISTRICT_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		if tooltipControls.HeaderIM then
			local cosHeaderInst = tooltipControls.HeaderIM:GetInstance();
			if cosHeaderInst and cosHeaderInst.Header then
				cosHeaderInst.Header:SetText(Locale.ToUpper(Locale.Lookup("LOC_MAM_UI_COSMETIC_SECTION")));
			end
		end

		local cosmCivItem = MAM_FindDomainItem("MAM_CivAbilities", cosmCiv);
		local cosmCivCard = tooltipControls.CivHeaderIconIM and tooltipControls.CivHeaderIconIM:GetInstance();
		if cosmCivCard then
			if isMystery and MAM_GetConfig("MAM_HAS_CUSTOM_COSM_CIV", targetPid) ~= "TRUE" then
				cosmCivCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				cosmCivCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_CIV_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
				cosmCivCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif cosmCivItem then
				cosmCivCard.Icon:SetIcon(cosmCivItem.Icon);
				cosmCivCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_CIV_HEADER") .. ": " .. Locale.Lookup(cosmCivItem.Name));
				cosmCivCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_CIV_DESC");
				local colorRows = CachedQuery("SELECT LeaderType, PlayerColor FROM Players WHERE CivilizationType = ? LIMIT 1", cosmCiv);
				local playerColorName = (colorRows and colorRows[1] and (colorRows[1].PlayerColor or colorRows[1].LeaderType)) or cosmCiv;
				local backColor, frontColor = UI.GetPlayerColorValues(playerColorName, 0);
				if backColor and frontColor and backColor ~= 0 and frontColor ~= 0 then
					if cosmCivCard.IconBG then cosmCivCard.IconBG:SetColor(backColor); end
					if cosmCivCard.Icon then cosmCivCard.Icon:SetColor(frontColor); end
				end
			else
				cosmCivCard.Icon:SetIcon("ICON_CIVILIZATION_UNKNOWN");
				cosmCivCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_CIV_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				cosmCivCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_CIV_DESC");
				if cosmCivCard.IconBG then cosmCivCard.IconBG:SetColor(0xFFFFFFFF); end
				if cosmCivCard.Icon then cosmCivCard.Icon:SetColor(0xFFFFFFFF); end
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CHANGE_COSMETIC_CIV"), function()
				m_MAM_View = "CIV_COSMETIC_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		local cosmLeaderItem = MAM_FindDomainItem("MAM_LeaderAbilities", cosmLeader);
		local cosmLeaderCard = tooltipControls.HeaderIconIM and tooltipControls.HeaderIconIM:GetInstance();
		if cosmLeaderCard then
			if isMystery and MAM_GetConfig("MAM_HAS_CUSTOM_COSM_LEADER", targetPid) ~= "TRUE" then
				cosmLeaderCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				cosmLeaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_LEADER_HEADER") .. ": ❓ " .. Locale.Lookup("LOC_MAM_UI_MYSTERY_HIDDEN"));
				cosmLeaderCard.Description:LocalizeAndSetText("LOC_MAM_UI_MYSTERY_DESC");
			elseif cosmLeaderItem then
				cosmLeaderCard.Icon:SetIcon(cosmLeaderItem.Icon);
				cosmLeaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_LEADER_HEADER") .. ": " .. Locale.Lookup(cosmLeaderItem.Name));
				cosmLeaderCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_LEADER_DESC");
			else
				cosmLeaderCard.Icon:SetIcon("ICON_LEADER_DEFAULT");
				cosmLeaderCard.Header:SetText(Locale.Lookup("LOC_MAM_UI_COSMETIC_LEADER_HEADER") .. ": " .. Locale.Lookup("LOC_MAM_NONE_NAME"));
				cosmLeaderCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_LEADER_DESC");
			end
		end
		if canEdit then
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CHANGE_COSMETIC_LEADER"), function()
				m_MAM_View = "LEADER_COSMETIC_SELECT";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			end, false);
		end

		MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CLOSE"), function()
			MAM_CloseWindow();
		end, false);

	else
		local domainName, configKey, imType, headerTag, defaultIcon, isCosmetic;
		if m_MAM_View == "CIV_SELECT" then
			domainName = "MAM_CivAbilities";
			configKey = "MAM_CIV_ABILITY";
			imType = tooltipControls.CivHeaderIconIM;
			headerTag = "LOC_MAM_UI_CIV_HEADER";
			defaultIcon = "ICON_CIVILIZATION_UNKNOWN";
			isCosmetic = false;
		elseif m_MAM_View == "LEADER_SELECT" then
			domainName = "MAM_LeaderAbilities";
			configKey = "MAM_LEADER_ABILITY";
			imType = tooltipControls.HeaderIconIM;
			headerTag = "LOC_MAM_UI_LEADER_HEADER";
			defaultIcon = "ICON_LEADER_DEFAULT";
			isCosmetic = false;
		elseif m_MAM_View == "UNIT_SELECT" then
			domainName = "MAM_UniqueUnits";
			configKey = "MAM_UNIQUE_UNIT";
			imType = tooltipControls.UniqueIconIM;
			headerTag = "LOC_MAM_UI_UNIT_HEADER";
			defaultIcon = "ICON_LEADER_DEFAULT";
			isCosmetic = false;
		elseif m_MAM_View == "DISTRICT_SELECT" then
			domainName = "MAM_UniqueDistricts";
			configKey = "MAM_UNIQUE_DISTRICT";
			imType = tooltipControls.UniqueIconIM;
			headerTag = "LOC_MAM_UI_DISTRICT_HEADER";
			defaultIcon = "ICON_LEADER_DEFAULT";
			isCosmetic = false;
		elseif m_MAM_View == "CIV_COSMETIC_SELECT" then
			domainName = "MAM_CivAbilities";
			configKey = "MAM_COSMETIC_CIV";
			imType = tooltipControls.CivHeaderIconIM;
			headerTag = "LOC_MAM_UI_COSMETIC_CIV_HEADER";
			defaultIcon = "ICON_CIVILIZATION_UNKNOWN";
			isCosmetic = true;
		elseif m_MAM_View == "LEADER_COSMETIC_SELECT" then
			domainName = "MAM_LeaderAbilities";
			configKey = "MAM_COSMETIC_LEADER";
			imType = tooltipControls.HeaderIconIM;
			headerTag = "LOC_MAM_UI_COSMETIC_LEADER_HEADER";
			defaultIcon = "ICON_LEADER_DEFAULT";
			isCosmetic = true;
		end

		MAM_AddButton(tooltipControls.InfoStack, Locale.ToUpper(Locale.Lookup("LOC_MAM_UI_BACK")), function()
			m_MAM_View = "OVERVIEW";
			g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
		end, false);

		if tooltipControls.HeaderIM then
			local catInst = tooltipControls.HeaderIM:GetInstance();
			if catInst and catInst.Header then
				catInst.Header:SetText(Locale.ToUpper(Locale.Lookup(headerTag)));
			end
		end

		local curVal = MAM_GetConfig(configKey, targetPid);

		if not isCosmetic and imType then
			local noneCard = imType:GetInstance();
			if noneCard then
				noneCard.Icon:SetIcon(defaultIcon);
				noneCard.Header:SetText(Locale.Lookup("LOC_MAM_NONE_NAME"));
				noneCard.Description:LocalizeAndSetText("LOC_MAM_NONE_DESC");
			end
			local isNoneSel = (curVal == "NONE");
			MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup(isNoneSel and "LOC_MAM_UI_SELECTED" or "LOC_MAM_UI_CHOOSE"), function()
				MAM_SetConfig(configKey, "NONE", targetPid);
				MAM_SetConfig("MAM_IS_MYSTERY", "FALSE", targetPid);
				m_MAM_View = "OVERVIEW";
				g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
				if VisualizePlayerParameters then
					VisualizePlayerParameters();
				elseif GameSetup_RefreshParameters then
					GameSetup_RefreshParameters();
				end
			end, isNoneSel);
		end

		if imType then
			local randomCard = imType:GetInstance();
			if randomCard then
				randomCard.Icon:SetIcon(domainName == "MAM_CivAbilities" and "ICON_CIVILIZATION_UNKNOWN" or "ICON_LEADER_RANDOM_POOL_1");
				randomCard.Header:SetText(Locale.Lookup("LOC_MAM_RANDOM_NAME"));
				randomCard.Description:LocalizeAndSetText("LOC_MAM_RANDOM_DESC");
			end
		end
		MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CHOOSE"), function()
			local usedCivs, usedLeaders, usedUnits, usedDistricts = MAM_GetUsedCivsAndLeaders(targetPid);
			local exMap = usedCivs;
			if configKey == "MAM_LEADER_ABILITY" or configKey == "MAM_COSMETIC_LEADER" then exMap = usedLeaders;
			elseif configKey == "MAM_UNIQUE_UNIT" then exMap = usedUnits;
			elseif configKey == "MAM_UNIQUE_DISTRICT" then exMap = usedDistricts;
			end
			local rollVal = MAM_RollRandomBonus(domainName, exMap);
			MAM_SetConfig(configKey, rollVal, targetPid);
			if configKey == "MAM_CIV_ABILITY" then
				local hasCustom = MAM_GetConfig("MAM_HAS_CUSTOM_COSM_CIV", targetPid);
				if hasCustom ~= "TRUE" then
					MAM_SetConfig("MAM_COSMETIC_CIV", rollVal, targetPid);
				end
			elseif configKey == "MAM_LEADER_ABILITY" then
				local hasCustom = MAM_GetConfig("MAM_HAS_CUSTOM_COSM_LEADER", targetPid);
				if hasCustom ~= "TRUE" then
					MAM_SetConfig("MAM_COSMETIC_LEADER", rollVal, targetPid);
				end
			end
			MAM_SetConfig("MAM_IS_MYSTERY", "FALSE", targetPid);
			m_MAM_View = "OVERVIEW";
			g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
			if VisualizePlayerParameters then
				VisualizePlayerParameters();
			elseif GameSetup_RefreshParameters then
				GameSetup_RefreshParameters();
			end
		end, false);

		local items = MAM_QueryItems(domainName);
		if items then
			local PAGE = 20;
			local pages = math.max(1, math.ceil(#items / PAGE));
			m_MAM_ListPage = m_MAM_ListPage or {};
			local pageKey = tostring(m_MAM_View) .. "|" .. tostring(domainName);
			local page = m_MAM_ListPage[pageKey];
			if page == nil then
				page = 1;
				for idx, it in ipairs(items) do
					if it.Value == curVal then page = math.ceil(idx / PAGE); break; end
				end
			end
			page = math.max(1, math.min(pages, page));
			m_MAM_ListPage[pageKey] = page;
			local function AddPageNav()
				if pages <= 1 then return; end
				if page > 1 then
					MAM_AddButton(tooltipControls.InfoStack, "<  " .. tostring(page - 1) .. " / " .. tostring(pages), function()
						m_MAM_ListPage[pageKey] = page - 1;
						g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
					end, false);
				end
				if page < pages then
					MAM_AddButton(tooltipControls.InfoStack, tostring(page + 1) .. " / " .. tostring(pages) .. "  >", function()
						m_MAM_ListPage[pageKey] = page + 1;
						g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
					end, false);
				end
			end
			AddPageNav();
			local pageItems = {};
			for idx = (page - 1) * PAGE + 1, math.min(#items, page * PAGE) do
				table.insert(pageItems, items[idx]);
			end
			for _, item in ipairs(pageItems) do
				local itemCard = imType and imType:GetInstance();
				if itemCard then
					itemCard.Icon:SetIcon(item.Icon);

					if isCosmetic then
						if m_MAM_View == "CIV_COSMETIC_SELECT" then
							local civRow = CachedQuery("SELECT CivilizationName FROM Players WHERE CivilizationType = ? LIMIT 1", item.Value);
							local civNameTag = (civRow and civRow[1] and civRow[1].CivilizationName) or item.Name;
							itemCard.Header:SetText(Locale.Lookup(civNameTag));
							itemCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_CIV_DESC");
						elseif m_MAM_View == "LEADER_COSMETIC_SELECT" then
							local leadRow = CachedQuery("SELECT LeaderName FROM Players WHERE LeaderType = ? LIMIT 1", item.Value);
							local leadNameTag = (leadRow and leadRow[1] and leadRow[1].LeaderName) or item.Name;
							itemCard.Header:SetText(Locale.Lookup(leadNameTag));
							itemCard.Description:LocalizeAndSetText("LOC_MAM_UI_COSMETIC_LEADER_DESC");
						end
					else
						itemCard.Header:SetText(Locale.Lookup(item.Name));
						itemCard.Description:LocalizeAndSetText(item.Description);
					end

				if domainName == "MAM_CivAbilities" then
					local leadForCivRow = CachedQuery("SELECT LeaderType, PlayerColor FROM Players WHERE CivilizationType = ? LIMIT 1", item.Value);
					local playerColorName = (leadForCivRow and leadForCivRow[1] and (leadForCivRow[1].PlayerColor or leadForCivRow[1].LeaderType)) or item.Value;
					local backColor, frontColor = UI.GetPlayerColorValues(playerColorName, 0);
				if backColor and frontColor and backColor ~= 0 and frontColor ~= 0 then
						if itemCard.IconBG then itemCard.IconBG:SetColor(backColor); end
						if itemCard.Icon then itemCard.Icon:SetColor(frontColor); end
					end
				end
			end
				local isItemSel = (item.Value == curVal);
				local thisVal = item.Value;
				MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup(isItemSel and "LOC_MAM_UI_SELECTED" or "LOC_MAM_UI_CHOOSE"), function()
					MAM_SetConfig(configKey, thisVal, targetPid);
					if not isCosmetic then
						MAM_SetConfig("MAM_IS_MYSTERY", "FALSE", targetPid);
					end
					if configKey == "MAM_CIV_ABILITY" then
						local hasCustom = MAM_GetConfig("MAM_HAS_CUSTOM_COSM_CIV", targetPid);
						if hasCustom ~= "TRUE" then
							MAM_SetConfig("MAM_COSMETIC_CIV", thisVal, targetPid);
						end
					elseif configKey == "MAM_LEADER_ABILITY" then
						local hasCustom = MAM_GetConfig("MAM_HAS_CUSTOM_COSM_LEADER", targetPid);
						if hasCustom ~= "TRUE" then
							MAM_SetConfig("MAM_COSMETIC_LEADER", thisVal, targetPid);
						end
					elseif configKey == "MAM_COSMETIC_CIV" then
						MAM_SetConfig("MAM_HAS_CUSTOM_COSM_CIV", "TRUE", targetPid);
					elseif configKey == "MAM_COSMETIC_LEADER" then
						MAM_SetConfig("MAM_HAS_CUSTOM_COSM_LEADER", "TRUE", targetPid);
					end
					m_MAM_View = "OVERVIEW";
					g_MAM_ConfiguringPlayerId = targetPid; SetMAMConstructorData(info, tooltipControls);
					if VisualizePlayerParameters then
						VisualizePlayerParameters();
					elseif GameSetup_RefreshParameters then
						GameSetup_RefreshParameters();
					end
				end, isItemSel);
			end
			AddPageNav();
		end
	end

	if tooltipControls.InfoStack then
		tooltipControls.InfoStack:CalculateSize();
		tooltipControls.InfoStack:ReprocessAnchoring();
	end
	if tooltipControls.InfoScrollPanel then
		tooltipControls.InfoScrollPanel:CalculateSize();
		tooltipControls.InfoScrollPanel:SetScrollValue(0);
	end

	return hasLeaderPlacard, true;
end

function SetUniqueCivLeaderData(info:table, tooltipControls:table)

	if (info and MAM_IsMAMLeader(info.LeaderType)) then
		return SetMAMConstructorData(info, tooltipControls);
	end

	MAM_ResetButtons(tooltipControls.InfoStack);
	m_MAM_View = "OVERVIEW";

	local hasLeaderPlacard = false;
	local hasTooltipInfo = false;

	tooltipControls.HeaderIconIM:ResetInstances();
	tooltipControls.UniqueIconIM:ResetInstances();
	tooltipControls.HeaderIM:ResetInstances();
	tooltipControls.CivHeaderIconIM:ResetInstances();

	if not tooltipControls.HasLeaderPlacard then
		MAM_AddButton(tooltipControls.InfoStack, Locale.Lookup("LOC_MAM_UI_CLOSE"), function()
			MAM_CloseWindow();
		end, false);
	end

	if tooltipControls.HasLeaderPlacard then
		tooltipControls.LeaderImage:UnloadTexture();
		tooltipControls.LeaderBG:UnloadTexture();
		tooltipControls.DummyImage:UnloadTexture();

		local leaderPortrait:string;
		if info.Portrait then
			leaderPortrait = info.Portrait;
		else
			leaderPortrait = info.LeaderType .. "_NEUTRAL";
		end
		tooltipControls.DummyImage:SetTexture(leaderPortrait);
		tooltipControls.LeaderImage:SetTexture(leaderPortrait);
		local imageRatio = tooltipControls.DummyImage:GetSizeX()/tooltipControls.DummyImage:GetSizeY();
		if(imageRatio > .51) then
 			tooltipControls.LeaderImage:SetTextureOffsetVal(30,10)
		else
			tooltipControls.LeaderImage:SetTextureOffsetVal(10,50)
		end

		local leaderBGImage:string;
		if info.PortraitBackground then
			leaderBGImage = info.PortraitBackground;
		else
			leaderBGImage = info.LeaderType .. "_BACKGROUND";
		end
		tooltipControls.LeaderBG:SetTexture(leaderBGImage);
		hasLeaderPlacard = true;
	end

	if (info.LeaderAbility) then
		local leaderHeader = tooltipControls.HeaderIM:GetInstance();
		leaderHeader.Header:SetText(Locale.ToUpper(Locale.Lookup(info.LeaderName)));
		local leaderAbility = tooltipControls.HeaderIconIM:GetInstance();
		leaderAbility.Icon:SetIcon(info.LeaderIcon);
		leaderAbility.Header:SetText(Locale.ToUpper(Locale.Lookup(info.LeaderAbility.Name)));
		leaderAbility.Description:LocalizeAndSetText(info.LeaderAbility.Description);
	end
	if (info.CivilizationAbility) then
		local civHeader = tooltipControls.HeaderIM:GetInstance();
		civHeader.Header:SetText(Locale.ToUpper(Locale.Lookup(info.CivilizationName)));
		local civAbility = tooltipControls.CivHeaderIconIM:GetInstance();

		civAbility.Icon:SetIcon(info.CivilizationIcon);

		local backColor, frontColor = UI.GetPlayerColorValues(info.PlayerColor, info.PlayerColorIndex or 0);
		if(backColor and frontColor and backColor ~= 0 and frontColor ~= 0) then
			civAbility.Icon:SetColor(frontColor);
			civAbility.IconBG:SetColor(backColor);
		end


		civAbility.Header:SetText(Locale.ToUpper(Locale.Lookup(info.CivilizationAbility.Name)));
		civAbility.Description:LocalizeAndSetText(info.CivilizationAbility.Description);
		hasTooltipInfo = true;
	end

	if (info.Uniques) then
		for _, item in ipairs(info.Uniques) do
			local instance:table = {};
			instance = tooltipControls.UniqueIconIM:GetInstance();
			instance.Icon:SetIcon(item.Icon);
			local headerText:string = Locale.ToUpper(Locale.Lookup( item.Name ));
			instance.Header:SetText( headerText );
			instance.Description:SetText(Locale.Lookup(item.Description));
			hasTooltipInfo = true;
		end
	end

	tooltipControls.InfoStack:CalculateSize();
	tooltipControls.InfoStack:ReprocessAnchoring();
	tooltipControls.InfoScrollPanel:CalculateSize();

	return hasLeaderPlacard, hasTooltipInfo;
end

function CheckExternalEnabled(playerID:number, inputEnabled:boolean, lockCheck:boolean, parameter)
	if(not inputEnabled) then
		return false;
	end

	if(not GameConfiguration.IsAnyMultiplayer()) then
		return inputEnabled;
	end

	local pPlayerConfig = PlayerConfigurations[playerID];
	if(pPlayerConfig:GetReady()) then
		return false;
	end

	local gameInProgress:boolean = GameConfiguration.GetGameState() ~= GameStateTypes.GAMESTATE_PREGAME;
	if(gameInProgress) then
		return false;
	end

	local localPlayerID = (MAM_GetLocalPlayerId and MAM_GetLocalPlayerId()) or Network.GetLocalPlayerID();
	local localPlayerConfig = PlayerConfigurations[localPlayerID];
	local slotStatus = pPlayerConfig:GetSlotStatus();
	if(not GameConfiguration.IsHotseat()
		and playerID ~= localPlayerID
		and (not Network.IsGameHost()
			or slotStatus == SlotStatus.SS_TAKEN
			or localPlayerConfig:GetReady())) then
		return false;
	end

	if(GameConfiguration.IsMatchMaking()
		and parameter ~= nil
		and parameter.ParameterId == "PlayerDifficulty") then
		return false;
	end

	if(lockCheck and pPlayerConfig:IsLocked()) then
		return false;
	end

	return true;
end

function SetupLeaderPulldown(
	playerId:number,
	instance:table,
	pulldownControlName:string,
	civIconControlName,
	civIconBGControlName,
	leaderIconControlName,
	scrollTextControlName,
	tooltipControls:table,
	colorPullDownName,
	colorWarnName
)
	local parameters = GetPlayerParameters(playerId);
	if(parameters == nil) then
		parameters = CreatePlayerParameters(playerId);
	end

	if (tooltipControls.HasLeaderPlacard or m_tooltipControls == nil or m_tooltipControls.InfoStack == nil) then
		m_tooltipControls = tooltipControls;
	end
	if tooltipControls.HasLeaderPlacard then
		m_MAM_BasicTooltipControls = tooltipControls;
	else
		m_MAM_AdvancedTooltipControls = tooltipControls;
	end

	if(civIconControlName == nil) then
		civIconControlName = "CivIcon";
	end

	if(civIconBGControlName == nil) then
		civIconBGControlName = "CivIconBG";
	end

	if(leaderIconControlName == nil) then
		leaderIconControlName = "LeaderIcon";
	end

	if(scrollTextControlName == nil) then
		scrollTextControlName = "ScrollText";
	end
	local control = instance[pulldownControlName];
	local civIcon = instance[civIconControlName];
	local civIconBG = instance[civIconBGControlName];
	local leaderIcon = instance[leaderIconControlName];
	local scrollText = instance[scrollTextControlName];
	local instanceManager = control["InstanceManager"];
	colorPullDownName = colorPullDownName or "ColorPullDown";
	colorWarnName = colorWarnName or "WarnIcon";
	local colorControls;
	local colorControl = instance[colorPullDownName];
	local colorWarnIcon = instance[colorWarnName];
	local colorInstanceManager;
	if(colorControl) then
		colorInstanceManager = colorControl["InstanceManager"]
		if (colorInstanceManager == nil) then
			colorInstanceManager = PullDownInstanceManager:new( "InstanceOne", "Button", colorControl );
			colorControl["InstanceManager"] = colorInstanceManager;
		end

		if(colorInstanceManager) then
			colorControls = parameters.Controls["PlayerColorAlternate"];
			if(colorControls == nil) then
				colorControls = {};
				parameters.Controls["PlayerColorAlternate"] = colorControls;
			end
		end
	end

	if(colorControl) then
		colorControl:SetDisabled(true);
	end

	if(colorWarnIcon) then
		colorWarnIcon:SetHide(true);
	end
	if not instanceManager then
		instanceManager = PullDownInstanceManager:new( "InstanceOne", "Button", control );
		control["InstanceManager"] = instanceManager;
	end

	local controls = parameters.Controls["PlayerLeader"];
	if(controls == nil) then
		controls = {};
		parameters.Controls["PlayerLeader"] = controls;
	end

	m_currentInfo = {
		CivilizationIcon = "ICON_CIVILIZATION_UNKNOWN",
		LeaderIcon = "ICON_LEADER_DEFAULT",
		CivilizationName = "LOC_RANDOM_CIVILIZATION",
		LeaderName = "LOC_RANDOM_LEADER"
	};
	local useJerseySelection = (colorControls ~= nil);


	function ValuesMatch(a,b)
		local at = type(a);
		local bt = type(b);

		if(at ~= bt) then
			return false;
		elseif(at == "number") then
			return a == b;
		elseif(at == "table") then
			return a.QueryId == b.QueryId and a.QueryIndex == b.QueryIndex and a.Invalid == b.Invalid and a.InvalidReason == b.InvalidReason
		else
			return a == b;
		end
	end
	local cache = {};
	if(useJerseySelection) then
		table.insert(colorControls, {
			UpdateValue = function(v)
				local refresh = true;

				local leaderParameter = parameters.Parameters["PlayerLeader"];
				local colorIndex = v or 0;
				if(	leaderParameter and ValuesMatch(leaderParameter.Value, cache.PlayerValue) and
					ValuesMatch(colorIndex, cache.PlayerColorValue)) then
					refresh = false;
				end

				if(refresh) then
					local button = control:GetButton();
					local icons;
					if(leaderParameter.Value) then
						icons = GetPlayerIcons(leaderParameter.Value.Domain, leaderParameter.Value.Value, playerId);
					end

					local backColor, frontColor = UI.GetPlayerColorValues(icons.PlayerColor, colorIndex);
					m_teamColors[playerId] = {backColor, frontColor}
					if(backColor and frontColor and backColor ~= 0 and frontColor ~= 0) then
						civIcon:SetSizeVal(36,36);
						civIcon:SetIcon(icons.CivIcon);
        				civIcon:SetColor(frontColor);
						civIconBG:SetColor(backColor);
						civIconBG:SetHide(false);
					else
						civIcon:SetSizeVal(45,45);
						civIcon:SetIcon(icons.CivIcon, 45);
        				civIcon:SetColor(UI.GetColorValue(1,1,1,1));
						civIconBG:SetHide(true);
					end

					cache.PlayerColorValue = pcv;
				end
			end,
			UpdateValues = function(values, parameter)

				local leaderParameter = parameters.Parameters["PlayerLeader"];
				if(	leaderParameter and ValuesMatch(leaderParameter.Value, cache.PlayerValue)) then
					refresh = false;
				end
				local icons;
				if(leaderParameter.Value) then
					icons = GetPlayerIcons(leaderParameter.Value.Domain, leaderParameter.Value.Value, playerId);
				end
				local itemCount = 0;
				colorInstanceManager:ResetInstances();

				if(icons) then
					for j = 0, 3, 1 do
						local backColor, frontColor = UI.GetPlayerColorValues(icons.PlayerColor, j);
						if(backColor and frontColor and backColor ~= 0 and frontColor ~= 0) then
							local colorEntry = colorInstanceManager:GetInstance();
							itemCount = itemCount + 1;
							colorEntry.CivIcon:SetIcon(icons.CivIcon);
							colorEntry.CivIcon:SetColor(frontColor);
							colorEntry.CivIconBG:SetColor(backColor);
							colorEntry.Button:SetToolTipString(nil);
							colorEntry.Button:RegisterCallback(Mouse.eLClick, function()
								if(playerId == 0 and m_currentInfo) then
									m_currentInfo.PlayerColorIndex = j;
								end
								parameters:SetParameterValue(parameter, j);
								m_teamColors[playerId] = {backColor, frontColor}
							end);
						end
					end
				end

				colorControl:CalculateInternals();

				local notExternalEnabled = not CheckExternalEnabled(playerId, true, true, parameter);
				local singleOrEmpty = itemCount == 0 or itemCount == 1;

				colorControl:SetDisabled(notExternalEnabled or singleOrEmpty);

				if colorWarnIcon ~= nil then
					local myTeam = m_teamColors[playerId];
					local bShowWarning = false;
					for k,v in pairs(m_teamColors) do
						if(k ~= playerId) then
							 if( myTeam and v and UI.ArePlayerColorsConflicting( v, myTeam ) ) then
								bShowWarning = true;
							end
						end
					end
					colorWarnIcon:SetHide(not bShowWarning);
					if bShowWarning == true then
						colorWarnIcon:LocalizeAndSetToolTip("LOC_SETUP_PLAYER_COLOR_COLLISION");
					else
						colorWarnIcon:SetToolTipString(nil);
					end
				end
			end,
			SetEnabled = function(enabled, parameter)
				local notExternalEnabled = not CheckExternalEnabled(playerId, enabled, true, parameter);
			end
		});
	end

	table.insert(controls, {
		UpdateValue = function(v)
			local refresh = true;

			local leaderParameter = parameters.Parameters["PlayerLeader"];
			local colorParameter = parameters.Parameters["PlayerColorAlternate"];
			local colorIndex = colorParameter and colorParameter.Value or 0;

			if(	ValuesMatch(leaderParameter.Value, cache.PlayerValue) and
				ValuesMatch(colorIndex, cache.PlayerColorValue) and
				(leaderParameter.Value == nil or not MAM_IsMAMLeader(leaderParameter.Value) or (cache.MAMCosmCiv == MAM_GetCosmeticCiv(playerId) and cache.MAMCosmLeader == MAM_GetCosmeticLeader(playerId)))) then
				refresh = false;
			end

			if(playerId == MAM_GetLocalPlayerId() or playerId == 0) then
				local info = GetPlayerInfo(v.Domain, (type(v)=="table" and v.Value or v), playerId);
				if info then
					info.PlayerColorIndex = colorIndex;
					info.TargetPlayerId = playerId;
					m_currentInfo = info;
					local isConstructorVal = (v and MAM_IsMAMLeader(v));
					if tooltipControls and tooltipControls.HasLeaderPlacard then
						if isConstructorVal then
							if not m_MAM_WindowClosed then
								MAM_ShowCardNow(info, tooltipControls, false);
							end
						else
							MAM_ShowCardNow(info, tooltipControls, false);
					end
					end
				end
			end

			if(refresh) then
				local button = control:GetButton();

				if(v == nil) then
					button:LocalizeAndSetText("LOC_SETUP_ERROR_INVALID_OPTION");
					button:ClearCallback(Mouse.eMouseEnter);
					button:ClearCallback(Mouse.eMouseExit);
				else
					local caption = v.Name;
					if MAM_IsMAMLeader(v) then
						local cosmCiv = MAM_GetCosmeticCiv(playerId);
						local cosmLeader = MAM_GetCosmeticLeader(playerId);
						local pConfig = PlayerConfigurations[playerId];
						local civAbil = pConfig and pConfig:GetValue("MAM_CIV_ABILITY");
						local leadAbil = pConfig and pConfig:GetValue("MAM_LEADER_ABILITY");
						local leaderBaseName = Locale.Lookup((type(v)=="table" and v.Value or v) == "LEADER_MAM_RANDOM" and "LOC_MAM_LEADER_RANDOM_NAME" or "LOC_MAM_LEADER_NAME");
						if civAbil == "RANDOM" or leadAbil == "RANDOM" then
							caption = leaderBaseName .. ": " .. Locale.Lookup("LOC_MAM_RANDOM_NAME");
						elseif (civAbil == "NONE" or civAbil == nil or civAbil == "") and (leadAbil == "NONE" or leadAbil == nil or leadAbil == "") then
							caption = leaderBaseName .. " (" .. Locale.Lookup("LOC_MAM_NONE_NAME") .. ")";
						else
							local cNameRow = CachedQuery("SELECT CivilizationName FROM Players WHERE CivilizationType = ? LIMIT 1", cosmCiv);
							local lNameRow = CachedQuery("SELECT LeaderName FROM Players WHERE LeaderType = ? LIMIT 1", cosmLeader);
							local cName = (cNameRow and cNameRow[1] and cNameRow[1].CivilizationName) or cosmCiv;
							local lName = (lNameRow and lNameRow[1] and lNameRow[1].LeaderName) or cosmLeader;
							caption = leaderBaseName .. ": " .. Locale.Lookup(lName) .. " (" .. Locale.Lookup(cName) .. ")";
						end
						cache.MAMCosmCiv = cosmCiv;
						cache.MAMCosmLeader = cosmLeader;
					end
					if(v.Invalid) then
						local err = v.InvalidReason or "LOC_SETUP_ERROR_INVALID_OPTION";
						caption = caption .. "[NEWLINE][COLOR_RED](" .. Locale.Lookup(err) .. ")[ENDCOLOR]";
					end

					if scrollText then
						scrollText:SetText(caption);
					else
						button:SetText(caption);
					end
					local icons = GetPlayerIcons(v.Domain, v.Value, playerId);

					local backColor, frontColor = UI.GetPlayerColorValues(icons.PlayerColor, colorIndex);
					m_teamColors[playerId] = {backColor, frontColor}
					if(backColor and frontColor and backColor ~= 0 and frontColor ~= 0) then
						civIcon:SetSizeVal(36,36);
						civIcon:SetIcon(icons.CivIcon);
        				civIcon:SetColor(frontColor);
						civIconBG:SetColor(backColor);
						civIconBG:SetHide(false);
					else
						civIcon:SetSizeVal(45,45);
						civIcon:SetIcon(icons.CivIcon, 45);
        				civIcon:SetColor(UI.GetColorValue(1,1,1,1));
						civIconBG:SetHide(true);
					end
					if(leaderIcon) then
						leaderIcon:SetIcon(icons.LeaderIcon);
					end

					local domain = v.Domain;
					local value = v.Value;
					local isConstructorVal = MAM_IsMAMLeader(value);

					if(not tooltipControls.HasLeaderPlacard) then
						button:RegisterCallback( Mouse.eMouseEnter, function()
							local curVal = cache.PlayerValue or v;
							local curColor = cache.PlayerColorValue or colorIndex;
							local info = GetPlayerInfo(curVal.Domain, curVal.Value, playerId);
							if info then
								info.PlayerColorIndex = curColor;
								info.TargetPlayerId = playerId;
								if MAM_IsMAMLeader(curVal) then
									m_currentInfo = info;
									g_MAM_ConfiguringPlayerId = playerId;
								end
								DisplayCivLeaderToolTip(info, tooltipControls, false);
							end
						end);

						button:RegisterCallback( Mouse.eMouseExit, function()
							MAM_CancelPendingCard();
							if m_MAM_WindowClosed or (cache.PlayerValue and not MAM_IsMAMLeader(cache.PlayerValue)) then
								MAM_ShowCardNow(nil, tooltipControls, true, true);
							end
						end);
					end

					cache.PlayerValue = v;
					cache.PlayerColorValue = colorIndex;
				end
			end
		end,
		UpdateValues = function(values)

			local refresh = false;
			local cValues = cache.PlayerValues;
			if(cValues and #cValues == #values) then
				for i,v in ipairs(values) do
					local cv = cValues[i];
					if(not ValuesMatch(cv,v)) then
						refresh = true;
						break;
					end
				end
			else
				refresh = true;
			end

			if(refresh) then
				instanceManager:ResetInstances();

				local hasPlacard = tooltipControls.HasLeaderPlacard;
				local OnMouseExit = function()
					MAM_CancelPendingCard();
					if hasPlacard then
						MAM_ShowCardNow(m_currentInfo, tooltipControls, false);
					else
						if m_MAM_WindowClosed or (m_currentInfo and not MAM_IsMAMLeader(m_currentInfo.LeaderType)) then
							MAM_ShowCardNow(nil, tooltipControls, true, true);
					end
				end
			end;

				for i,v in ipairs(values) do
					if v ~= nil then
						local icons = GetPlayerIcons(v.Domain, v.Value, playerId);

						local entry = instanceManager:GetInstance();
						local caption = v.Name;
					if MAM_IsMAMLeader(v) then
						if (v.Invalid and (v.InvalidReason == "LOC_SETUP_ERROR_NO_DUPLICATE_LEADERS" or v.InvalidReason == "LOC_SETUP_ERROR_NO_DUPLICATE_CIVILIZATIONS")) then
							v.Invalid = false;
							v.InvalidReason = nil;
						end
						entry.Button:SetDisabled(false);
				end
						if(v.Invalid) then
							local err = v.InvalidReason or "LOC_SETUP_ERROR_INVALID_OPTION";
							caption = caption .. "[NEWLINE][COLOR_RED](" .. Locale.Lookup(err) .. ")[ENDCOLOR]";
						end

						local backColor, frontColor = UI.GetPlayerColorValues(icons.PlayerColor, 0);
						if(backColor and frontColor and backColor ~= 0 and frontColor ~= 0) then
							entry.CivIcon:SetSizeVal(36,36);
							entry.CivIcon:SetIcon(icons.CivIcon);
        					entry.CivIcon:SetColor(frontColor);
							entry.CivIconBG:SetColor(backColor);
							entry.CivIconBG:SetHide(false);
						else
							entry.CivIcon:SetSizeVal(45,45);
							entry.CivIcon:SetIcon(icons.CivIcon, 45);
        					entry.CivIcon:SetColor(UI.GetColorValue(1,1,1,1));
							entry.CivIconBG:SetHide(true);
						end
						if(entry.ScrollText ~= nil) then
							entry.ScrollText:SetText(caption);
						else
							entry.Button:SetText(caption);
						end
						entry.LeaderIcon:SetIcon(icons.LeaderIcon);

						local domain = v.Domain;
						local value = v.Value;

						entry.Button:RegisterCallback( Mouse.eMouseEnter, function()
							local info = GetPlayerInfo(domain, value, playerId);
							info.TargetPlayerId = playerId;
							DisplayCivLeaderToolTip(info, tooltipControls, false);
						end);

						entry.Button:RegisterCallback( Mouse.eMouseExit, OnMouseExit);
						entry.Button:SetToolTipString(nil);

						entry.Button:RegisterCallback(Mouse.eLClick, function()
							local parameter = parameters.Parameters["PlayerLeader"];
							parameters:SetParameterValue(parameter, v);

							if (v and MAM_IsMAMLeader(v)) then
								g_MAM_ConfiguringPlayerId = playerId;
								m_MAM_WindowClosed = false;
								if MAM_ApplySlotTypes then
									local baseL = MAM_IsSlotLeader(v) and "LEADER_MAM_BLANK" or (type(v)=="table" and v.Value or v);
									MAM_ApplySlotTypes(playerId, baseL);
									if Network and Network.BroadcastPlayerInfo then
										pcall(Network.BroadcastPlayerInfo, playerId);
									end
								end
								local pInfo = GetPlayerInfo(v.Domain, (type(v)=="table" and v.Value or v), playerId);
								if pInfo then
									pInfo.TargetPlayerId = playerId;
									m_currentInfo = pInfo;
									MAM_ShowCardNow(pInfo, tooltipControls, false);
								end
							else
								m_MAM_WindowClosed = true;
								g_MAM_ConfiguringPlayerId = nil;
								if playerId == 0 and v then
									local pInfo = GetPlayerInfo(v.Domain, (type(v)=="table" and v.Value or v), playerId);
									m_currentInfo = pInfo;
								if tooltipControls and tooltipControls.HasLeaderPlacard then
									MAM_ShowCardNow(pInfo, tooltipControls, false);
								else
									MAM_ShowCardNow(nil, tooltipControls, true, true);
								end
								else
									MAM_ShowCardNow(nil, tooltipControls, true, true);
								end
							end

							local colorParameter = parameters.Parameters["PlayerColorAlternate"];
							if(colorParameter) then
								parameters:SetParameterValue(colorParameter, 0);
							end
						end);
					end
				end
				control:CalculateInternals();
				cache.PlayerValues = values;
			end
		end,
		SetEnabled = function(enabled, parameter)
			local notExternalEnabled = not CheckExternalEnabled(playerId, enabled, true, parameter);
			local singleOrEmpty = #parameter.Values <= 1;

			control:SetDisabled(notExternalEnabled or singleOrEmpty);
		end,
	});
end

function SetupHandicapPulldown(playerId, control)
	local parameters = GetPlayerParameters(playerId);
	if(parameters == nil) then
		parameters = CreatePlayerParameters(playerId);
	end

	parameters.Controls["PlayerDifficulty"] = {
		UpdateValue = function(value)
			local button = control:GetButton();
			button:SetText( value and value.Name or nil);
		end,
		UpdateValues = function(values)
			control:ClearEntries();
			for i,v in ipairs(values) do
				local entry = {};
				control:BuildEntry( "InstanceOne", entry );
				entry.Button:SetText(v.Name);
				entry.Button:SetToolTipString(v.Description);
				entry.Button:RegisterCallback(Mouse.eLClick, function()
					local parameter = parameters.Parameters["PlayerDifficulty"];
					parameters:SetParameterValue(parameter, v);
				end);
			end
			control:CalculateInternals();
		end,
		SetEnabled = function(enabled, parameter)
			control:SetDisabled(not CheckExternalEnabled(playerId, enabled, false, parameter));
		end,
	};
end

function PlayerConfigurationValuesToUI(playerId)
	local prevCur = g_MAM_CurrentLobbyPlayerId;
	g_MAM_CurrentLobbyPlayerId = playerId;
	if MAM_InstallGameStartHooks then MAM_InstallGameStartHooks(); end
	local parameters = GetPlayerParameters(playerId);
	if(parameters == nil) then
		parameters = CreatePlayerParameters(playerId);
	end

	local prevRow = g_MAM_RowPid;
	g_MAM_RowPid = playerId;
	local pe = g_PlayerEntries and g_PlayerEntries[playerId];
	if pe and MAM_BindPlayerLeaderControls then
		MAM_BindPlayerLeaderControls(playerId, pe);
	end
	GameSetup_RefreshPlayerParameter(playerId);
	g_MAM_RowPid = prevRow;
	g_MAM_CurrentLobbyPlayerId = prevCur;
end

function UpdatePlayerEntry(playerId)
	local prevCur = g_MAM_CurrentLobbyPlayerId;
	g_MAM_CurrentLobbyPlayerId = playerId;
	local prevRow = g_MAM_RowPid;
	g_MAM_RowPid = playerId;
	local pe = g_PlayerEntries and g_PlayerEntries[playerId];
	if pe and MAM_BindPlayerLeaderControls then
		MAM_BindPlayerLeaderControls(playerId, pe);
	end
	GameSetup_RefreshPlayerParameter(playerId);
	g_MAM_RowPid = prevRow;
	g_MAM_CurrentLobbyPlayerId = prevCur;
end

g_Refreshing = false;
g_NeedsAdditionalRefresh = false;
g_RefreshCounter = 0;
MAX_REFRESH_DEPTH = 10;

function GameSetup_RefreshParameters()
	if(g_Refreshing) then
		SetupParameters_Log("An additional refresh was requested!");
		g_NeedsAdditionalRefresh = true;
	else
		g_Refreshing = true;
		g_RefreshCounter = g_RefreshCounter + 1;
		g_NeedsAdditionalRefresh = false;

		if(g_RefreshCounter > MAX_REFRESH_DEPTH) then
			SetupParameters_Log("Refreshed too many times! Setting error state and skipping to prevent hang.");
			g_RefreshCounter = 0;
			g_Refreshing = false;
			g_GameParameters.Stalled = true;

			g_GameParameters:UpdateVisualization();
			VisualizePlayerParameters();

			if(UI_PostRefreshParameters) then
				UI_PostRefreshParameters();
			end
		else
			SetupParameters_Log("Refreshing Game parameters");
			if(g_GameParameters == nil) then
				BuildGameSetup();
			else
				g_GameParameters:Refresh();
			end
			SetupParameters_Log("Refreshing Player parameters");
			RefreshPlayerParameters();
			g_GameParameters.Stalled = nil;
			g_Refreshing = false;

			if(g_NeedsAdditionalRefresh) then
				SetupParameters_Log("Refreshing parameters again due to an intermediate request.")
				return GameSetup_RefreshParameters();
			else
				SetupParameters_Log("Finished Refreshing");
				SetupParameters_Log("Visualizing parameters");
				g_RefreshCounter = 0;

				g_GameParameters:UpdateVisualization();
				VisualizePlayerParameters();

				if(UI_PostRefreshParameters) then
					UI_PostRefreshParameters();
				end
				if MAM_InstallGameStartHooks then
					MAM_InstallGameStartHooks();
				end
			end
		end
	end
end

function GameSetup_RefreshPlayerParameter(playerId)
	SetupParameters_Log("Refreshing parameters for player " .. tostring(playerId));
	local parameters = GetPlayerParameters(playerId);
	if(parameters) then

		g_Refreshing = true;
		parameters:Refresh();
		g_Refreshing = false;

		if(g_NeedsAdditionalRefresh) then
			SetupParameters_Log("Refreshing all parameters, to be sure.")
			return GameSetup_RefreshParameters();
		else
			local prevRow = g_MAM_RowPid;
			local prevCur = g_MAM_CurrentLobbyPlayerId;
			g_MAM_RowPid = playerId;
			g_MAM_CurrentLobbyPlayerId = playerId;
			parameters:UpdateVisualization();
			g_MAM_RowPid = prevRow;
			g_MAM_CurrentLobbyPlayerId = prevCur;
		end
	else
		SetupParameters_Log("Player parameters not found!");
	end
end

function GameSetup_ConfigurationChanged()
	SetupParameters_Log("Configuration Changed!");
	GameSetup_RefreshParameters();
end
