CREATE TABLE IF NOT EXISTS MAM_Candidates (Kind TEXT NOT NULL, Value TEXT NOT NULL, H INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (Kind, Value));
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'CIV', CivilizationType FROM Civilizations
WHERE CivilizationType NOT LIKE 'CIVILIZATION_MAM_%' AND CivilizationType NOT LIKE '%RANDOM%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'CIV', CivilizationType FROM CivilizationTraits
WHERE CivilizationType NOT LIKE 'CIVILIZATION_MAM_%' AND CivilizationType NOT LIKE '%RANDOM%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'LEADER', LeaderType FROM Leaders
WHERE LeaderType NOT LIKE 'LEADER_MAM_%' AND LeaderType NOT LIKE '%RANDOM%' AND LeaderType NOT LIKE '%DEFAULT%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'LEADER', LeaderType FROM LeaderTraits
WHERE LeaderType NOT LIKE 'LEADER_MAM_%' AND LeaderType NOT LIKE '%RANDOM%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'COSM_LEADER', LeaderType FROM Leaders
WHERE LeaderType NOT LIKE 'LEADER_MAM_%' AND LeaderType NOT LIKE '%RANDOM%' AND LeaderType NOT LIKE '%DEFAULT%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'COSM_CIV', CivilizationType FROM Civilizations
WHERE CivilizationType NOT LIKE 'CIVILIZATION_MAM_%' AND CivilizationType NOT LIKE '%RANDOM%';
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'UNIT', UnitType FROM Units WHERE TraitType IS NOT NULL;
INSERT OR IGNORE INTO MAM_Candidates (Kind, Value)
SELECT 'DISTRICT', DistrictType FROM Districts WHERE TraitType IS NOT NULL
UNION SELECT 'DISTRICT', BuildingType FROM Buildings WHERE TraitType IS NOT NULL
UNION SELECT 'DISTRICT', ImprovementType FROM Improvements WHERE TraitType IS NOT NULL;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 1, 1))) % 16777213 WHERE length(Value) >= 1;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 2, 1))) % 16777213 WHERE length(Value) >= 2;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 3, 1))) % 16777213 WHERE length(Value) >= 3;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 4, 1))) % 16777213 WHERE length(Value) >= 4;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 5, 1))) % 16777213 WHERE length(Value) >= 5;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 6, 1))) % 16777213 WHERE length(Value) >= 6;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 7, 1))) % 16777213 WHERE length(Value) >= 7;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 8, 1))) % 16777213 WHERE length(Value) >= 8;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 9, 1))) % 16777213 WHERE length(Value) >= 9;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 10, 1))) % 16777213 WHERE length(Value) >= 10;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 11, 1))) % 16777213 WHERE length(Value) >= 11;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 12, 1))) % 16777213 WHERE length(Value) >= 12;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 13, 1))) % 16777213 WHERE length(Value) >= 13;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 14, 1))) % 16777213 WHERE length(Value) >= 14;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 15, 1))) % 16777213 WHERE length(Value) >= 15;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 16, 1))) % 16777213 WHERE length(Value) >= 16;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 17, 1))) % 16777213 WHERE length(Value) >= 17;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 18, 1))) % 16777213 WHERE length(Value) >= 18;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 19, 1))) % 16777213 WHERE length(Value) >= 19;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 20, 1))) % 16777213 WHERE length(Value) >= 20;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 21, 1))) % 16777213 WHERE length(Value) >= 21;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 22, 1))) % 16777213 WHERE length(Value) >= 22;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 23, 1))) % 16777213 WHERE length(Value) >= 23;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 24, 1))) % 16777213 WHERE length(Value) >= 24;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 25, 1))) % 16777213 WHERE length(Value) >= 25;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 26, 1))) % 16777213 WHERE length(Value) >= 26;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 27, 1))) % 16777213 WHERE length(Value) >= 27;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 28, 1))) % 16777213 WHERE length(Value) >= 28;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 29, 1))) % 16777213 WHERE length(Value) >= 29;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 30, 1))) % 16777213 WHERE length(Value) >= 30;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 31, 1))) % 16777213 WHERE length(Value) >= 31;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 32, 1))) % 16777213 WHERE length(Value) >= 32;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 33, 1))) % 16777213 WHERE length(Value) >= 33;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 34, 1))) % 16777213 WHERE length(Value) >= 34;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 35, 1))) % 16777213 WHERE length(Value) >= 35;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 36, 1))) % 16777213 WHERE length(Value) >= 36;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 37, 1))) % 16777213 WHERE length(Value) >= 37;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 38, 1))) % 16777213 WHERE length(Value) >= 38;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 39, 1))) % 16777213 WHERE length(Value) >= 39;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 40, 1))) % 16777213 WHERE length(Value) >= 40;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 41, 1))) % 16777213 WHERE length(Value) >= 41;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 42, 1))) % 16777213 WHERE length(Value) >= 42;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 43, 1))) % 16777213 WHERE length(Value) >= 43;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 44, 1))) % 16777213 WHERE length(Value) >= 44;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 45, 1))) % 16777213 WHERE length(Value) >= 45;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 46, 1))) % 16777213 WHERE length(Value) >= 46;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 47, 1))) % 16777213 WHERE length(Value) >= 47;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 48, 1))) % 16777213 WHERE length(Value) >= 48;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 49, 1))) % 16777213 WHERE length(Value) >= 49;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 50, 1))) % 16777213 WHERE length(Value) >= 50;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 51, 1))) % 16777213 WHERE length(Value) >= 51;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 52, 1))) % 16777213 WHERE length(Value) >= 52;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 53, 1))) % 16777213 WHERE length(Value) >= 53;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 54, 1))) % 16777213 WHERE length(Value) >= 54;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 55, 1))) % 16777213 WHERE length(Value) >= 55;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 56, 1))) % 16777213 WHERE length(Value) >= 56;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 57, 1))) % 16777213 WHERE length(Value) >= 57;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 58, 1))) % 16777213 WHERE length(Value) >= 58;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 59, 1))) % 16777213 WHERE length(Value) >= 59;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 60, 1))) % 16777213 WHERE length(Value) >= 60;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 61, 1))) % 16777213 WHERE length(Value) >= 61;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 62, 1))) % 16777213 WHERE length(Value) >= 62;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 63, 1))) % 16777213 WHERE length(Value) >= 63;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 64, 1))) % 16777213 WHERE length(Value) >= 64;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 65, 1))) % 16777213 WHERE length(Value) >= 65;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 66, 1))) % 16777213 WHERE length(Value) >= 66;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 67, 1))) % 16777213 WHERE length(Value) >= 67;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 68, 1))) % 16777213 WHERE length(Value) >= 68;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 69, 1))) % 16777213 WHERE length(Value) >= 69;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 70, 1))) % 16777213 WHERE length(Value) >= 70;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 71, 1))) % 16777213 WHERE length(Value) >= 71;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 72, 1))) % 16777213 WHERE length(Value) >= 72;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 73, 1))) % 16777213 WHERE length(Value) >= 73;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 74, 1))) % 16777213 WHERE length(Value) >= 74;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 75, 1))) % 16777213 WHERE length(Value) >= 75;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 76, 1))) % 16777213 WHERE length(Value) >= 76;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 77, 1))) % 16777213 WHERE length(Value) >= 77;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 78, 1))) % 16777213 WHERE length(Value) >= 78;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 79, 1))) % 16777213 WHERE length(Value) >= 79;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 80, 1))) % 16777213 WHERE length(Value) >= 80;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 81, 1))) % 16777213 WHERE length(Value) >= 81;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 82, 1))) % 16777213 WHERE length(Value) >= 82;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 83, 1))) % 16777213 WHERE length(Value) >= 83;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 84, 1))) % 16777213 WHERE length(Value) >= 84;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 85, 1))) % 16777213 WHERE length(Value) >= 85;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 86, 1))) % 16777213 WHERE length(Value) >= 86;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 87, 1))) % 16777213 WHERE length(Value) >= 87;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 88, 1))) % 16777213 WHERE length(Value) >= 88;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 89, 1))) % 16777213 WHERE length(Value) >= 89;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 90, 1))) % 16777213 WHERE length(Value) >= 90;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 91, 1))) % 16777213 WHERE length(Value) >= 91;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 92, 1))) % 16777213 WHERE length(Value) >= 92;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 93, 1))) % 16777213 WHERE length(Value) >= 93;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 94, 1))) % 16777213 WHERE length(Value) >= 94;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 95, 1))) % 16777213 WHERE length(Value) >= 95;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 96, 1))) % 16777213 WHERE length(Value) >= 96;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 97, 1))) % 16777213 WHERE length(Value) >= 97;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 98, 1))) % 16777213 WHERE length(Value) >= 98;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 99, 1))) % 16777213 WHERE length(Value) >= 99;
UPDATE MAM_Candidates SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 100, 1))) % 16777213 WHERE length(Value) >= 100;

CREATE TABLE IF NOT EXISTS MAM_SlotPicks (
  Slot INTEGER NOT NULL, Kind TEXT NOT NULL, Value TEXT NOT NULL,
  CivType TEXT NOT NULL, LeaderType TEXT NOT NULL, PRIMARY KEY (Slot, Kind));
INSERT OR REPLACE INTO MAM_SlotPicks (Slot, Kind, Value, CivType, LeaderType)
SELECT b.Slot, b.Kind, c.Value, 'CIVILIZATION_MAM_P' || b.Slot, 'LEADER_MAM_P' || b.Slot
FROM (SELECT Slot, Kind, SUM(1 << Bit) AS H FROM MAM_SlotBits GROUP BY Slot, Kind) b
JOIN MAM_Candidates c ON c.Kind = b.Kind AND c.H = b.H
WHERE 'LEADER_MAM_P' || b.Slot IN (SELECT LeaderType FROM Leaders)
  AND (SELECT COUNT(*) FROM MAM_Candidates c2 WHERE c2.Kind = b.Kind AND c2.H = b.H) = 1;
INSERT OR IGNORE INTO CivilizationTraits (CivilizationType, TraitType)
SELECT p.CivType, ct.TraitType FROM MAM_SlotPicks p JOIN CivilizationTraits ct ON ct.CivilizationType = p.Value
WHERE p.Kind = 'CIV'
  AND ct.TraitType IN (SELECT TraitType FROM Traits WHERE InternalOnly IS NOT 1)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Units WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Districts WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Buildings WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Improvements WHERE TraitType IS NOT NULL);

UPDATE Civilizations
SET Name = (SELECT c.Name FROM Civilizations c JOIN MAM_SlotPicks p ON c.CivilizationType = p.Value WHERE p.CivType = Civilizations.CivilizationType AND p.Kind = 'CIV'),
    Description = (SELECT c.Description FROM Civilizations c JOIN MAM_SlotPicks p ON c.CivilizationType = p.Value WHERE p.CivType = Civilizations.CivilizationType AND p.Kind = 'CIV'),
    Adjective = (SELECT c.Adjective FROM Civilizations c JOIN MAM_SlotPicks p ON c.CivilizationType = p.Value WHERE p.CivType = Civilizations.CivilizationType AND p.Kind = 'CIV'),
    Ethnicity = (SELECT c.Ethnicity FROM Civilizations c JOIN MAM_SlotPicks p ON c.CivilizationType = p.Value WHERE p.CivType = Civilizations.CivilizationType AND p.Kind = 'CIV')
WHERE CivilizationType IN (SELECT CivType FROM MAM_SlotPicks WHERE Kind = 'CIV');

UPDATE Leaders
SET Name = (SELECT l.Name FROM Leaders l JOIN MAM_SlotPicks p ON l.LeaderType = p.Value WHERE p.LeaderType = Leaders.LeaderType AND p.Kind = 'LEADER')
WHERE LeaderType IN (SELECT LeaderType FROM MAM_SlotPicks WHERE Kind = 'LEADER');

UPDATE Leaders
SET Name = (SELECT l.Name FROM Leaders l JOIN MAM_SlotPicks p ON l.LeaderType = p.Value WHERE p.LeaderType = Leaders.LeaderType AND p.Kind = 'COSM_LEADER')
WHERE LeaderType IN (SELECT LeaderType FROM MAM_SlotPicks WHERE Kind = 'COSM_LEADER');

UPDATE LoadingInfo
SET ForegroundImage = (
  SELECT COALESCE(
    (SELECT l.ForegroundImage FROM LoadingInfo l WHERE l.LeaderType = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER'))),
    COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER')) || '_NEUTRAL'
  )
),
BackgroundImage = (
  SELECT COALESCE(
    (SELECT l.BackgroundImage FROM LoadingInfo l WHERE l.LeaderType = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER'))),
    (SELECT d.BackgroundImage FROM DiplomacyInfo d WHERE d.Type = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER'))),
    COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER')) || '_BACKGROUND'
  )
),
LeaderText = (
  SELECT COALESCE(
    (SELECT l.LeaderText FROM LoadingInfo l WHERE l.LeaderType = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = LoadingInfo.LeaderType AND p.Kind = 'LEADER'))),
    LoadingInfo.LeaderText
  )
)
WHERE LeaderType IN (SELECT LeaderType FROM MAM_SlotPicks WHERE Kind IN ('LEADER', 'COSM_LEADER'));

UPDATE DiplomacyInfo
SET BackgroundImage = (
  SELECT COALESCE(
    (SELECT d.BackgroundImage FROM DiplomacyInfo d WHERE d.Type = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'LEADER'))),
    (SELECT l.BackgroundImage FROM LoadingInfo l WHERE l.LeaderType = COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'LEADER'))),
    COALESCE(
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'COSM_LEADER'),
      (SELECT p.Value FROM MAM_SlotPicks p WHERE p.LeaderType = DiplomacyInfo.Type AND p.Kind = 'LEADER')) || '_BACKGROUND'
  )
)
WHERE Type IN (SELECT LeaderType FROM MAM_SlotPicks WHERE Kind IN ('LEADER', 'COSM_LEADER'));

UPDATE CivilizationLeaders
SET CapitalName = (SELECT cl.CapitalName FROM CivilizationLeaders cl JOIN MAM_SlotPicks p ON cl.CivilizationType = p.Value WHERE p.CivType = CivilizationLeaders.CivilizationType AND p.Kind = 'CIV')
WHERE CivilizationType IN (SELECT CivType FROM MAM_SlotPicks WHERE Kind = 'CIV')
  AND EXISTS (SELECT 1 FROM CivilizationLeaders cl JOIN MAM_SlotPicks p ON cl.CivilizationType = p.Value WHERE p.CivType = CivilizationLeaders.CivilizationType AND p.Kind = 'CIV');

INSERT OR IGNORE INTO CityNames (CivilizationType, CityName)
SELECT p.CivType, cn.CityName FROM MAM_SlotPicks p JOIN CityNames cn ON cn.CivilizationType = p.Value
WHERE p.Kind = 'CIV';

INSERT OR IGNORE INTO CivilizationCitizenNames (CivilizationType, CitizenName, Female)
SELECT p.CivType, ccn.CitizenName, ccn.Female FROM MAM_SlotPicks p JOIN CivilizationCitizenNames ccn ON ccn.CivilizationType = p.Value
WHERE p.Kind = 'CIV';

INSERT OR IGNORE INTO StartBiasRivers (CivilizationType, Tier)
SELECT p.CivType, b.Tier FROM MAM_SlotPicks p JOIN StartBiasRivers b ON b.CivilizationType = p.Value WHERE p.Kind = 'CIV';
INSERT OR IGNORE INTO StartBiasFeatures (CivilizationType, FeatureType, Tier)
SELECT p.CivType, b.FeatureType, b.Tier FROM MAM_SlotPicks p JOIN StartBiasFeatures b ON b.CivilizationType = p.Value
WHERE p.Kind = 'CIV' AND b.FeatureType IN (SELECT FeatureType FROM Features);
INSERT OR IGNORE INTO StartBiasTerrains (CivilizationType, TerrainType, Tier)
SELECT p.CivType, b.TerrainType, b.Tier FROM MAM_SlotPicks p JOIN StartBiasTerrains b ON b.CivilizationType = p.Value
WHERE p.Kind = 'CIV' AND b.TerrainType IN (SELECT TerrainType FROM Terrains);
INSERT OR IGNORE INTO StartBiasResources (CivilizationType, ResourceType, Tier)
SELECT p.CivType, b.ResourceType, b.Tier FROM MAM_SlotPicks p JOIN StartBiasResources b ON b.CivilizationType = p.Value
WHERE p.Kind = 'CIV' AND b.ResourceType IN (SELECT ResourceType FROM Resources);
INSERT OR IGNORE INTO LeaderTraits (LeaderType, TraitType)
SELECT p.LeaderType, lt.TraitType FROM MAM_SlotPicks p JOIN LeaderTraits lt ON lt.LeaderType = p.Value
WHERE p.Kind = 'LEADER'
  AND lt.TraitType IN (SELECT TraitType FROM Traits WHERE InternalOnly IS NOT 1)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Units WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Districts WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Buildings WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Improvements WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM AgendaTraits WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT LIKE '%_MAJOR_CIV%'
  AND lt.TraitType NOT LIKE '%_AGENDA%'
  AND lt.TraitType NOT LIKE '%_PREFERENCE%'
  AND lt.TraitType NOT LIKE '%AGGRESSIVE_MILITARY%'
  AND lt.TraitType NOT LIKE '%_EXPANSIONIST%'
  AND lt.TraitType NOT LIKE '%_PURSUE_DIPLOMATIC_VICTORY%';

DELETE FROM HistoricalAgendas
WHERE LeaderType IN (SELECT p.LeaderType FROM MAM_SlotPicks p
                     WHERE p.Kind = 'LEADER'
                       AND EXISTS (SELECT 1 FROM HistoricalAgendas h WHERE h.LeaderType = p.Value));
INSERT OR IGNORE INTO HistoricalAgendas (LeaderType, AgendaType)
SELECT p.LeaderType, h.AgendaType FROM MAM_SlotPicks p JOIN HistoricalAgendas h ON h.LeaderType = p.Value
WHERE p.Kind = 'LEADER';
CREATE TABLE IF NOT EXISTS MAM_AllItems (Value TEXT NOT NULL, Kind TEXT NOT NULL, TraitType TEXT NOT NULL, PRIMARY KEY (Value, Kind));
INSERT OR IGNORE INTO MAM_AllItems (Value, Kind, TraitType)
SELECT UnitType, 'UNIT', TraitType FROM Units WHERE TraitType IS NOT NULL
UNION SELECT DistrictType, 'DISTRICT', TraitType FROM Districts WHERE TraitType IS NOT NULL
UNION SELECT BuildingType, 'DISTRICT', TraitType FROM Buildings WHERE TraitType IS NOT NULL
UNION SELECT ImprovementType, 'DISTRICT', TraitType FROM Improvements WHERE TraitType IS NOT NULL;

CREATE TABLE IF NOT EXISTS MAM_ItemTraits (Value TEXT NOT NULL PRIMARY KEY, OldTrait TEXT NOT NULL, Shared INTEGER NOT NULL);
INSERT OR IGNORE INTO MAM_ItemTraits (Value, OldTrait, Shared)
SELECT a.Value, a.TraitType, (SELECT COUNT(*) FROM MAM_AllItems a2 WHERE a2.TraitType = a.TraitType)
FROM MAM_AllItems a
WHERE a.TraitType IN (SELECT TraitType FROM Traits)
  AND EXISTS (SELECT 1 FROM MAM_SlotPicks p WHERE p.Value = a.Value AND p.Kind = a.Kind);
INSERT OR IGNORE INTO CivilizationTraits (CivilizationType, TraitType)
SELECT p.CivType, it.OldTrait FROM MAM_SlotPicks p JOIN MAM_ItemTraits it ON it.Value = p.Value
WHERE p.Kind IN ('UNIT', 'DISTRICT') AND it.Shared = 1;
INSERT OR IGNORE INTO Types (Type, Kind)
SELECT 'TRAIT_MAM_ITEM_' || Value, 'KIND_TRAIT' FROM MAM_ItemTraits WHERE Shared > 1
UNION SELECT 'TRAIT_MAM_MODS_' || Value, 'KIND_TRAIT' FROM MAM_ItemTraits WHERE Shared > 1;
INSERT OR IGNORE INTO Traits (TraitType, Name, InternalOnly)
SELECT 'TRAIT_MAM_ITEM_' || it.Value, t.Name, 1 FROM MAM_ItemTraits it JOIN Traits t ON t.TraitType = it.OldTrait WHERE it.Shared > 1
UNION SELECT 'TRAIT_MAM_MODS_' || it.Value, t.Name, 1 FROM MAM_ItemTraits it JOIN Traits t ON t.TraitType = it.OldTrait WHERE it.Shared > 1;
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_MAM_MODS_' || it.Value, tm.ModifierId FROM MAM_ItemTraits it JOIN TraitModifiers tm ON tm.TraitType = it.OldTrait WHERE it.Shared > 1;
INSERT OR IGNORE INTO CivilizationTraits (CivilizationType, TraitType)
SELECT ct.CivilizationType, 'TRAIT_MAM_ITEM_' || it.Value FROM MAM_ItemTraits it JOIN CivilizationTraits ct ON ct.TraitType = it.OldTrait WHERE it.Shared > 1;
INSERT OR IGNORE INTO LeaderTraits (LeaderType, TraitType)
SELECT lt.LeaderType, 'TRAIT_MAM_ITEM_' || it.Value FROM MAM_ItemTraits it JOIN LeaderTraits lt ON lt.TraitType = it.OldTrait WHERE it.Shared > 1;
UPDATE Units SET TraitType = 'TRAIT_MAM_ITEM_' || UnitType WHERE UnitType IN (SELECT Value FROM MAM_ItemTraits WHERE Shared > 1);
UPDATE Districts SET TraitType = 'TRAIT_MAM_ITEM_' || DistrictType WHERE DistrictType IN (SELECT Value FROM MAM_ItemTraits WHERE Shared > 1);
UPDATE Buildings SET TraitType = 'TRAIT_MAM_ITEM_' || BuildingType WHERE BuildingType IN (SELECT Value FROM MAM_ItemTraits WHERE Shared > 1);
UPDATE Improvements SET TraitType = 'TRAIT_MAM_ITEM_' || ImprovementType WHERE ImprovementType IN (SELECT Value FROM MAM_ItemTraits WHERE Shared > 1);
INSERT OR IGNORE INTO CivilizationTraits (CivilizationType, TraitType)
SELECT p.CivType, 'TRAIT_MAM_ITEM_' || it.Value FROM MAM_SlotPicks p JOIN MAM_ItemTraits it ON it.Value = p.Value
WHERE p.Kind IN ('UNIT', 'DISTRICT') AND it.Shared > 1
UNION SELECT p.CivType, 'TRAIT_MAM_MODS_' || it.Value FROM MAM_SlotPicks p JOIN MAM_ItemTraits it ON it.Value = p.Value
WHERE p.Kind IN ('UNIT', 'DISTRICT') AND it.Shared > 1;
CREATE TABLE IF NOT EXISTS MAM_ReqRemap (RequirementId TEXT NOT NULL PRIMARY KEY, TraitType TEXT NOT NULL);
INSERT OR IGNORE INTO MAM_ReqRemap (RequirementId, TraitType)
SELECT r.RequirementId,
  (SELECT MIN(ct.TraitType) FROM CivilizationTraits ct WHERE ct.CivilizationType = ra.Value
  AND ct.TraitType IN (SELECT TraitType FROM Traits WHERE InternalOnly IS NOT 1)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Units WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Districts WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Buildings WHERE TraitType IS NOT NULL)
  AND ct.TraitType NOT IN (SELECT TraitType FROM Improvements WHERE TraitType IS NOT NULL)
     AND NOT EXISTS (SELECT 1 FROM CivilizationTraits o WHERE o.TraitType = ct.TraitType
                     AND o.CivilizationType <> ra.Value AND o.CivilizationType NOT LIKE 'CIVILIZATION_MAM_%')
     AND NOT EXISTS (SELECT 1 FROM LeaderTraits o WHERE o.TraitType = ct.TraitType AND o.LeaderType NOT LIKE 'LEADER_MAM_%'))
FROM Requirements r JOIN RequirementArguments ra ON ra.RequirementId = r.RequirementId AND ra.Name = 'CivilizationType'
WHERE r.RequirementType = 'REQUIREMENT_PLAYER_TYPE_MATCHES'
  AND ra.Value IN (SELECT Value FROM MAM_SlotPicks WHERE Kind = 'CIV')
  AND EXISTS (SELECT 1 FROM Requirements x WHERE x.RequirementType = 'REQUIREMENT_PLAYER_HAS_CIVILIZATION_OR_LEADER_TRAIT');
INSERT OR IGNORE INTO MAM_ReqRemap (RequirementId, TraitType)
SELECT r.RequirementId,
  (SELECT MIN(lt.TraitType) FROM LeaderTraits lt WHERE lt.LeaderType = ra.Value
  AND lt.TraitType IN (SELECT TraitType FROM Traits WHERE InternalOnly IS NOT 1)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Units WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Districts WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Buildings WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM Improvements WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT IN (SELECT TraitType FROM AgendaTraits WHERE TraitType IS NOT NULL)
  AND lt.TraitType NOT LIKE '%_MAJOR_CIV%' AND lt.TraitType NOT LIKE '%_AGENDA%'
  AND lt.TraitType NOT LIKE '%_PREFERENCE%' AND lt.TraitType NOT LIKE '%AGGRESSIVE_MILITARY%'
  AND lt.TraitType NOT LIKE '%_EXPANSIONIST%' AND lt.TraitType NOT LIKE '%_PURSUE_DIPLOMATIC_VICTORY%'
     AND NOT EXISTS (SELECT 1 FROM LeaderTraits o WHERE o.TraitType = lt.TraitType
                     AND o.LeaderType <> ra.Value AND o.LeaderType NOT LIKE 'LEADER_MAM_%')
     AND NOT EXISTS (SELECT 1 FROM CivilizationTraits o WHERE o.TraitType = lt.TraitType AND o.CivilizationType NOT LIKE 'CIVILIZATION_MAM_%'))
FROM Requirements r JOIN RequirementArguments ra ON ra.RequirementId = r.RequirementId AND ra.Name = 'LeaderType'
WHERE r.RequirementType = 'REQUIREMENT_PLAYER_LEADER_TYPE_MATCHES'
  AND ra.Value IN (SELECT Value FROM MAM_SlotPicks WHERE Kind = 'LEADER')
  AND EXISTS (SELECT 1 FROM Requirements x WHERE x.RequirementType = 'REQUIREMENT_PLAYER_HAS_CIVILIZATION_OR_LEADER_TRAIT');
UPDATE Requirements SET RequirementType = 'REQUIREMENT_PLAYER_HAS_CIVILIZATION_OR_LEADER_TRAIT'
WHERE RequirementId IN (SELECT RequirementId FROM MAM_ReqRemap);
DELETE FROM RequirementArguments
WHERE RequirementId IN (SELECT RequirementId FROM MAM_ReqRemap) AND Name IN ('CivilizationType', 'LeaderType');
INSERT OR REPLACE INTO RequirementArguments (RequirementId, Name, Value)
SELECT RequirementId, 'TraitType', TraitType FROM MAM_ReqRemap;
