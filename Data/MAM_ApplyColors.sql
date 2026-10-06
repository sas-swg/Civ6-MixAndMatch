CREATE TABLE IF NOT EXISTS MAM_SlotBits (Slot INTEGER NOT NULL, Kind TEXT NOT NULL, Bit INTEGER NOT NULL, PRIMARY KEY (Slot, Kind, Bit));
CREATE TABLE IF NOT EXISTS MAM_ColorCand (Value TEXT NOT NULL PRIMARY KEY, H INTEGER NOT NULL DEFAULT 0);
DELETE FROM MAM_ColorCand;
INSERT OR IGNORE INTO MAM_ColorCand (Value)
SELECT Type FROM PlayerColors WHERE Type LIKE 'LEADER_%' AND Type NOT LIKE 'LEADER_MAM_%';
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 1, 1))) % 16777213 WHERE length(Value) >= 1;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 2, 1))) % 16777213 WHERE length(Value) >= 2;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 3, 1))) % 16777213 WHERE length(Value) >= 3;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 4, 1))) % 16777213 WHERE length(Value) >= 4;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 5, 1))) % 16777213 WHERE length(Value) >= 5;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 6, 1))) % 16777213 WHERE length(Value) >= 6;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 7, 1))) % 16777213 WHERE length(Value) >= 7;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 8, 1))) % 16777213 WHERE length(Value) >= 8;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 9, 1))) % 16777213 WHERE length(Value) >= 9;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 10, 1))) % 16777213 WHERE length(Value) >= 10;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 11, 1))) % 16777213 WHERE length(Value) >= 11;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 12, 1))) % 16777213 WHERE length(Value) >= 12;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 13, 1))) % 16777213 WHERE length(Value) >= 13;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 14, 1))) % 16777213 WHERE length(Value) >= 14;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 15, 1))) % 16777213 WHERE length(Value) >= 15;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 16, 1))) % 16777213 WHERE length(Value) >= 16;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 17, 1))) % 16777213 WHERE length(Value) >= 17;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 18, 1))) % 16777213 WHERE length(Value) >= 18;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 19, 1))) % 16777213 WHERE length(Value) >= 19;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 20, 1))) % 16777213 WHERE length(Value) >= 20;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 21, 1))) % 16777213 WHERE length(Value) >= 21;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 22, 1))) % 16777213 WHERE length(Value) >= 22;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 23, 1))) % 16777213 WHERE length(Value) >= 23;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 24, 1))) % 16777213 WHERE length(Value) >= 24;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 25, 1))) % 16777213 WHERE length(Value) >= 25;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 26, 1))) % 16777213 WHERE length(Value) >= 26;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 27, 1))) % 16777213 WHERE length(Value) >= 27;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 28, 1))) % 16777213 WHERE length(Value) >= 28;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 29, 1))) % 16777213 WHERE length(Value) >= 29;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 30, 1))) % 16777213 WHERE length(Value) >= 30;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 31, 1))) % 16777213 WHERE length(Value) >= 31;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 32, 1))) % 16777213 WHERE length(Value) >= 32;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 33, 1))) % 16777213 WHERE length(Value) >= 33;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 34, 1))) % 16777213 WHERE length(Value) >= 34;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 35, 1))) % 16777213 WHERE length(Value) >= 35;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 36, 1))) % 16777213 WHERE length(Value) >= 36;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 37, 1))) % 16777213 WHERE length(Value) >= 37;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 38, 1))) % 16777213 WHERE length(Value) >= 38;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 39, 1))) % 16777213 WHERE length(Value) >= 39;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 40, 1))) % 16777213 WHERE length(Value) >= 40;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 41, 1))) % 16777213 WHERE length(Value) >= 41;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 42, 1))) % 16777213 WHERE length(Value) >= 42;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 43, 1))) % 16777213 WHERE length(Value) >= 43;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 44, 1))) % 16777213 WHERE length(Value) >= 44;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 45, 1))) % 16777213 WHERE length(Value) >= 45;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 46, 1))) % 16777213 WHERE length(Value) >= 46;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 47, 1))) % 16777213 WHERE length(Value) >= 47;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 48, 1))) % 16777213 WHERE length(Value) >= 48;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 49, 1))) % 16777213 WHERE length(Value) >= 49;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 50, 1))) % 16777213 WHERE length(Value) >= 50;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 51, 1))) % 16777213 WHERE length(Value) >= 51;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 52, 1))) % 16777213 WHERE length(Value) >= 52;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 53, 1))) % 16777213 WHERE length(Value) >= 53;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 54, 1))) % 16777213 WHERE length(Value) >= 54;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 55, 1))) % 16777213 WHERE length(Value) >= 55;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 56, 1))) % 16777213 WHERE length(Value) >= 56;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 57, 1))) % 16777213 WHERE length(Value) >= 57;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 58, 1))) % 16777213 WHERE length(Value) >= 58;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 59, 1))) % 16777213 WHERE length(Value) >= 59;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 60, 1))) % 16777213 WHERE length(Value) >= 60;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 61, 1))) % 16777213 WHERE length(Value) >= 61;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 62, 1))) % 16777213 WHERE length(Value) >= 62;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 63, 1))) % 16777213 WHERE length(Value) >= 63;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 64, 1))) % 16777213 WHERE length(Value) >= 64;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 65, 1))) % 16777213 WHERE length(Value) >= 65;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 66, 1))) % 16777213 WHERE length(Value) >= 66;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 67, 1))) % 16777213 WHERE length(Value) >= 67;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 68, 1))) % 16777213 WHERE length(Value) >= 68;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 69, 1))) % 16777213 WHERE length(Value) >= 69;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 70, 1))) % 16777213 WHERE length(Value) >= 70;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 71, 1))) % 16777213 WHERE length(Value) >= 71;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 72, 1))) % 16777213 WHERE length(Value) >= 72;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 73, 1))) % 16777213 WHERE length(Value) >= 73;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 74, 1))) % 16777213 WHERE length(Value) >= 74;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 75, 1))) % 16777213 WHERE length(Value) >= 75;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 76, 1))) % 16777213 WHERE length(Value) >= 76;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 77, 1))) % 16777213 WHERE length(Value) >= 77;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 78, 1))) % 16777213 WHERE length(Value) >= 78;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 79, 1))) % 16777213 WHERE length(Value) >= 79;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 80, 1))) % 16777213 WHERE length(Value) >= 80;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 81, 1))) % 16777213 WHERE length(Value) >= 81;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 82, 1))) % 16777213 WHERE length(Value) >= 82;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 83, 1))) % 16777213 WHERE length(Value) >= 83;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 84, 1))) % 16777213 WHERE length(Value) >= 84;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 85, 1))) % 16777213 WHERE length(Value) >= 85;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 86, 1))) % 16777213 WHERE length(Value) >= 86;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 87, 1))) % 16777213 WHERE length(Value) >= 87;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 88, 1))) % 16777213 WHERE length(Value) >= 88;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 89, 1))) % 16777213 WHERE length(Value) >= 89;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 90, 1))) % 16777213 WHERE length(Value) >= 90;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 91, 1))) % 16777213 WHERE length(Value) >= 91;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 92, 1))) % 16777213 WHERE length(Value) >= 92;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 93, 1))) % 16777213 WHERE length(Value) >= 93;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 94, 1))) % 16777213 WHERE length(Value) >= 94;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 95, 1))) % 16777213 WHERE length(Value) >= 95;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 96, 1))) % 16777213 WHERE length(Value) >= 96;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 97, 1))) % 16777213 WHERE length(Value) >= 97;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 98, 1))) % 16777213 WHERE length(Value) >= 98;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 99, 1))) % 16777213 WHERE length(Value) >= 99;
UPDATE MAM_ColorCand SET H = (H * 31 + instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_abcdefghijklmnopqrstuvwxyz', substr(Value, 100, 1))) % 16777213 WHERE length(Value) >= 100;
CREATE TABLE IF NOT EXISTS MAM_ColorPicks (Slot INTEGER NOT NULL, Kind TEXT NOT NULL, Value TEXT NOT NULL, PRIMARY KEY (Slot, Kind));
INSERT OR REPLACE INTO MAM_ColorPicks (Slot, Kind, Value)
SELECT b.Slot, b.Kind, c.Value
FROM (SELECT Slot, Kind, SUM(1 << Bit) AS H FROM MAM_SlotBits WHERE Kind IN ('LEADER', 'COSM_LEADER') GROUP BY Slot, Kind) b
JOIN MAM_ColorCand c ON c.H = b.H
WHERE (SELECT COUNT(*) FROM MAM_ColorCand c2 WHERE c2.H = b.H) = 1;
INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor, Alt1PrimaryColor, Alt1SecondaryColor, Alt2PrimaryColor, Alt2SecondaryColor, Alt3PrimaryColor, Alt3SecondaryColor)
SELECT s.LeaderType, pc.Usage, pc.PrimaryColor, pc.SecondaryColor, pc.Alt1PrimaryColor, pc.Alt1SecondaryColor, pc.Alt2PrimaryColor, pc.Alt2SecondaryColor, pc.Alt3PrimaryColor, pc.Alt3SecondaryColor
FROM (
  SELECT 'LEADER_MAM_P' || p.Slot AS LeaderType,
         COALESCE(MAX(CASE WHEN p.Kind = 'COSM_LEADER' THEN p.Value END),
                  CASE WHEN EXISTS (SELECT 1 FROM MAM_SlotBits sb WHERE sb.Slot = p.Slot AND sb.Kind = 'COSM_LEADER') THEN NULL
                       ELSE MAX(CASE WHEN p.Kind = 'LEADER' THEN p.Value END) END) AS Src
  FROM MAM_ColorPicks p GROUP BY p.Slot
) s JOIN PlayerColors pc ON pc.Type = s.Src
WHERE s.LeaderType IN (SELECT Type FROM PlayerColors);
