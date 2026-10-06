INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
SELECT Domain, 'CIVILIZATION_MAM_BLANK', 'LEADER_MAM_BLANK',
 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT',
 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_BLANK',
 0
FROM (
 SELECT 'Players:StandardPlayers' AS Domain
 UNION ALL SELECT 'Players:Expansion1_Players'
 UNION ALL SELECT 'Players:Expansion2_Players'
);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
SELECT Domain, 'CIVILIZATION_MAM_RANDOM', 'LEADER_MAM_RANDOM',
 'LOC_MAM_CIV_RANDOM_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_RANDOM_NAME', 'ICON_LEADER_DEFAULT',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_RANDOM_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_RANDOM_DESC', 'ICON_LEADER_DEFAULT',
 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_RANDOM',
 1
FROM (
 SELECT 'Players:StandardPlayers' AS Domain
 UNION ALL SELECT 'Players:Expansion1_Players'
 UNION ALL SELECT 'Players:Expansion2_Players'
);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P0', 'LEADER_MAM_P0', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P0', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P1', 'LEADER_MAM_P1', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P1', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P2', 'LEADER_MAM_P2', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P2', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P3', 'LEADER_MAM_P3', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P3', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P4', 'LEADER_MAM_P4', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P4', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P5', 'LEADER_MAM_P5', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P5', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P6', 'LEADER_MAM_P6', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P6', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P7', 'LEADER_MAM_P7', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P7', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P8', 'LEADER_MAM_P8', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P8', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P9', 'LEADER_MAM_P9', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P9', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P10', 'LEADER_MAM_P10', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P10', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('Players:MAM_Slots', 'CIVILIZATION_MAM_P11', 'LEADER_MAM_P11', 'LOC_MAM_CIV_NAME', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_LEADER_NAME', 'ICON_LEADER_DEFAULT', 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_CIVILIZATION_UNKNOWN',
 'LOC_MAM_EMPTY', 'LOC_MAM_CIV_DESC', 'ICON_LEADER_DEFAULT', 'LEADER_TRAJAN_NEUTRAL', 'LEADER_TRAJAN_BACKGROUND', 'LEADER_MAM_P11', 1000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('WarMachineScenario_Players', 'CIVILIZATION_MIXMATCH_WARMACHINE_GERMANY', 'LEADER_MIXMATCH_WARMACHINE_GERMANY', 'LOC_CIVILIZATION_WARMACHINE_SCENARIO_GERMANY_NAME', 'ICON_CIVILIZATION_GERMANY',
 'LOC_LEADER_WARMACHINE_SCENARIO_GERMANY_NAME', 'ICON_LEADER_BARBAROSSA', 'LOC_WARMACHINE_SCENARIO_GERMANY_ABILITY_NAME', 'LOC_WARMACHINE_SCENARIO_GERMANY_ABILITY_DESCRIPTION',
 'ICON_CIVILIZATION_GERMANY', 'LOC_WARMACHINE_SCENARIO_GERMANY_ABILITY_NAME', 'LOC_WARMACHINE_SCENARIO_GERMANY_ABILITY_DESCRIPTION',
 'ICON_LEADER_BARBAROSSA', 'LEADER_BARBAROSSA_NEUTRAL', 'LEADER_BARBAROSSA_BACKGROUND', 'LEADER_BARBAROSSA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('WarMachineScenario_Players', 'CIVILIZATION_MIXMATCH_WARMACHINE_FRANCE', 'LEADER_MIXMATCH_WARMACHINE_FRANCE', 'LOC_CIVILIZATION_WARMACHINE_SCENARIO_FRANCE_NAME', 'ICON_CIVILIZATION_FRANCE',
 'LOC_LEADER_WARMACHINE_SCENARIO_FRANCE_NAME', 'ICON_LEADER_CATHERINE_DE_MEDICI', 'LOC_WARMACHINE_SCENARIO_FRANCE_ABILITY_NAME', 'LOC_WARMACHINE_SCENARIO_FRANCE_ABILITY_DESCRIPTION',
 'ICON_CIVILIZATION_FRANCE', 'LOC_WARMACHINE_SCENARIO_FRANCE_ABILITY_NAME', 'LOC_WARMACHINE_SCENARIO_FRANCE_ABILITY_DESCRIPTION',
 'ICON_LEADER_CATHERINE_DE_MEDICI', 'LEADER_CATHERINE_DE_MEDICI_NEUTRAL', 'LEADER_CATHERINE_DE_MEDICI_BACKGROUND', 'LEADER_CATHERINE_DE_MEDICI', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('PolandScenario_Players', 'CIVILIZATION_MIXMATCH_RADZIWILL', 'LEADER_MIXMATCH_RADZIWILL', 'LOC_CIVILIZATION_POLAND_SCENARIO_RADZIWILL_NAME', 'ICON_CIVILIZATION_POLAND',
 'LOC_LEADER_POLAND_SCENARIO_RADZIWILL_NAME', 'ICON_LEADER_JADWIGA', 'LOC_TRAIT_LEADER_SCENARIO_RADZIWILL_NAME', 'LOC_TRAIT_LEADER_SCENARIO_RADZIWILL_DESCRIPTION',
 'ICON_CIVILIZATION_POLAND', 'LOC_TRAIT_LEADER_SCENARIO_RADZIWILL_NAME', 'LOC_TRAIT_LEADER_SCENARIO_RADZIWILL_DESCRIPTION',
 'ICON_LEADER_JADWIGA', 'LEADER_JADWIGA_NEUTRAL', 'LEADER_JADWIGA_BACKGROUND', 'LEADER_JADWIGA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('PolandScenario_Players', 'CIVILIZATION_MIXMATCH_POTOCKI', 'LEADER_MIXMATCH_POTOCKI', 'LOC_CIVILIZATION_POLAND_SCENARIO_POTOCKI_NAME', 'ICON_CIVILIZATION_POLAND',
 'LOC_LEADER_POLAND_SCENARIO_POTOCKI_NAME', 'ICON_LEADER_JADWIGA', 'LOC_TRAIT_LEADER_SCENARIO_POTOCKI_NAME', 'LOC_TRAIT_LEADER_SCENARIO_POTOCKI_DESCRIPTION',
 'ICON_CIVILIZATION_POLAND', 'LOC_TRAIT_LEADER_SCENARIO_POTOCKI_NAME', 'LOC_TRAIT_LEADER_SCENARIO_POTOCKI_DESCRIPTION',
 'ICON_LEADER_JADWIGA', 'LEADER_JADWIGA_NEUTRAL', 'LEADER_JADWIGA_BACKGROUND', 'LEADER_JADWIGA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('PolandScenario_Players', 'CIVILIZATION_MIXMATCH_OSTROGSKI', 'LEADER_MIXMATCH_OSTROGSKI', 'LOC_CIVILIZATION_POLAND_SCENARIO_OSTROGSKI_NAME', 'ICON_CIVILIZATION_POLAND',
 'LOC_LEADER_POLAND_SCENARIO_OSTROGSKI_NAME', 'ICON_LEADER_JADWIGA', 'LOC_TRAIT_LEADER_SCENARIO_OSTROGSKI_NAME', 'LOC_TRAIT_LEADER_SCENARIO_OSTROGSKI_DESCRIPTION',
 'ICON_CIVILIZATION_POLAND', 'LOC_TRAIT_LEADER_SCENARIO_OSTROGSKI_NAME', 'LOC_TRAIT_LEADER_SCENARIO_OSTROGSKI_DESCRIPTION',
 'ICON_LEADER_JADWIGA', 'LEADER_JADWIGA_NEUTRAL', 'LEADER_JADWIGA_BACKGROUND', 'LEADER_JADWIGA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('VikingScenario_Players', 'CIVILIZATION_MIXMATCH_DENMARK', 'LEADER_MIXMATCH_CNUT', 'LOC_CIVILIZATION_SCENARIO_DENMARK_NAME', 'ICON_CIVILIZATION_NORWAY',
 'LOC_LEADER_SCENARIO_CNUT_NAME', 'ICON_LEADER_HARDRADA', 'LOC_TRAIT_SCENARIO_VIKING_NAME', 'LOC_TRAIT_SCENARIO_VIKING_DESCRIPTION',
 'ICON_CIVILIZATION_NORWAY', 'LOC_TRAIT_LEADER_EXTRA_MILITARY_SLOT_NAME', 'LOC_TRAIT_LEADER_EXTRA_MILITARY_SLOT_DESCRIPTION',
 'ICON_LEADER_HARDRADA', 'LEADER_HARDRADA_NEUTRAL', 'LEADER_HARDRADA_BACKGROUND', 'LEADER_HARDRADA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('VikingScenario_Players', 'CIVILIZATION_MIXMATCH_DENMARK', 'LEADER_MIXMATCH_OLOF', 'LOC_CIVILIZATION_SCENARIO_DENMARK_NAME', 'ICON_CIVILIZATION_NORWAY',
 'LOC_LEADER_SCENARIO_OLOF_NAME', 'ICON_LEADER_HARDRADA', 'LOC_TRAIT_SCENARIO_VIKING_NAME', 'LOC_TRAIT_SCENARIO_VIKING_DESCRIPTION',
 'ICON_CIVILIZATION_NORWAY', 'LOC_TRAIT_LEADER_EXTRA_ECONOMIC_SLOT_NAME', 'LOC_TRAIT_LEADER_EXTRA_ECONOMIC_SLOT_DESCRIPTION',
 'ICON_LEADER_HARDRADA', 'LEADER_HARDRADA_NEUTRAL', 'LEADER_HARDRADA_BACKGROUND', 'LEADER_HARDRADA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('AustraliaScenario_Players', 'CIVILIZATION_MIXMATCH_QUEENSLAND', 'LEADER_MIXMATCH_QUEENSLAND', 'LOC_CIVILIZATION_AUSTRALIA_SCENARIO_QUEENSLAND_NAME', 'ICON_CIVILIZATION_AUSTRALIA',
 'LOC_LEADER_AUSTRALIA_SCENARIO_QUEENSLAND_NAME', 'ICON_LEADER_JOHN_CURTIN', 'LOC_TRAIT_CIVILIZATION_ALL_DISTRICTS_CULTURE_BOMB_NAME', 'LOC_TRAIT_CIVILIZATION_ALL_DISTRICTS_CULTURE_BOMB_DESCRIPTION',
 'ICON_CIVILIZATION_AUSTRALIA', 'LOC_LEADER_SCENARIO_QUEENSLAND_ABILITY_NAME', 'LOC_LEADER_SCENARIO_QUEENSLAND_ABILITY_DESCRIPTION',
 'ICON_LEADER_JOHN_CURTIN', 'LEADER_JOHN_CURTIN_NEUTRAL', 'LEADER_JOHN_CURTIN_BACKGROUND', 'LEADER_JOHN_CURTIN', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('AustraliaScenario_Players', 'CIVILIZATION_MIXMATCH_WESTERN_AUSTRALIA', 'LEADER_MIXMATCH_WESTERN_AUSTRALIA', 'LOC_CIVILIZATION_AUSTRALIA_SCENARIO_WESTERN_AUSTRALIA_NAME', 'ICON_CIVILIZATION_AUSTRALIA',
 'LOC_LEADER_AUSTRALIA_SCENARIO_WESTERN_AUSTRALIA_NAME', 'ICON_LEADER_JOHN_CURTIN', 'LOC_TRAIT_CIVILIZATION_ALL_DISTRICTS_CULTURE_BOMB_NAME', 'LOC_TRAIT_CIVILIZATION_ALL_DISTRICTS_CULTURE_BOMB_DESCRIPTION',
 'ICON_CIVILIZATION_AUSTRALIA', 'LOC_LEADER_SCENARIO_WESTERN_AUSTRALIA_ABILITY_NAME', 'LOC_LEADER_SCENARIO_WESTERN_AUSTRALIA_ABILITY_DESCRIPTION',
 'ICON_LEADER_JOHN_CURTIN', 'LEADER_JOHN_CURTIN_NEUTRAL', 'LEADER_JOHN_CURTIN_BACKGROUND', 'LEADER_JOHN_CURTIN', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('VikingScenario_Players', 'CIVILIZATION_MIXMATCH_DENMARK', 'LEADER_MIXMATCH_HARDRADA_SCENARIO', 'LOC_CIVILIZATION_SCENARIO_DENMARK_NAME', 'ICON_CIVILIZATION_NORWAY',
 'LOC_LEADER_HARDRADA_NAME', 'ICON_LEADER_HARDRADA', 'LOC_TRAIT_SCENARIO_VIKING_NAME', 'LOC_TRAIT_SCENARIO_VIKING_DESCRIPTION',
 'ICON_CIVILIZATION_NORWAY', 'LOC_TRAIT_LEADER_THUNDERBOLT_NAME', 'LOC_TRAIT_LEADER_FASTER_SHIPS_DESCRIPTION',
 'ICON_LEADER_HARDRADA', 'LEADER_HARDRADA_NEUTRAL', 'LEADER_HARDRADA_BACKGROUND', 'LEADER_HARDRADA', 2000);

INSERT OR REPLACE INTO Players
 (Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon,
 LeaderName, LeaderIcon, CivilizationAbilityName, CivilizationAbilityDescription,
 CivilizationAbilityIcon, LeaderAbilityName, LeaderAbilityDescription,
 LeaderAbilityIcon, Portrait, PortraitBackground, PlayerColor, SortIndex)
VALUES ('AlexanderScenario_Players', 'CIVILIZATION_PERSIA', 'LEADER_MIXMATCH_DARIUS_III', 'LOC_CIVILIZATION_PERSIA_NAME', 'ICON_CIVILIZATION_PERSIA',
 'LOC_MOD_ALEXANDER_SCENARIO_DARIUS_III_NAME', 'ICON_LEADER_CYRUS', 'LOC_TRAIT_CIVILIZATION_SATRAPIES_NAME', 'LOC_TRAIT_CIVILIZATION_SATRAPIES_DESCRIPTION',
 'ICON_CIVILIZATION_PERSIA', 'LOC_MOD_ALEXANDER_SCENARIO_DARIUS_III_TRAIT_NAME', 'LOC_MOD_ALEXANDER_SCENARIO_DARIUS_III_TRAIT_DESCRIPTION',
 'ICON_LEADER_CYRUS', 'LEADER_CYRUS_NEUTRAL', 'LEADER_CYRUS_BACKGROUND', 'LEADER_CYRUS', 2000);

DELETE FROM Parameters WHERE ParameterId = 'MAM_AllRulesets';
INSERT INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES ('MAM_AllRulesets', 'LOC_MAM_OPT_ALL_RULESETS_NAME', 'LOC_MAM_OPT_ALL_RULESETS_DESC', 'bool', 1, 'Game', 'MAM_ALL_RULESETS', 'AdvancedOptions', 2010);
