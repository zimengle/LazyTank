-- Variables

LZT_VERSION = .97;

LZT_EVENTS= {"ADDON_LOADED",
		"VARIABLES_LOADED",
		"LEARNED_SPELL_IN_TAB",
		"SPELLS_CHANGED",
		"PLAYER_TARGET_CHANGED",
		"PLAYER_ENTERING_WORLD",
		"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF",
		"CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF",
		"CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF",
		"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE",
		"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",
		"CHAT_MSG_SPELL_SELF_DAMAGE",
		"PLAYER_REGEN_DISABLED",
		"PLAYER_REGEN_ENABLED"
};
BINDING_HEADER_LZT_TITLE = "LazyTank 快捷键绑定";
BINDING_NAME_LZT_HATE = "一键拉怪";
BINDING_NAME_LZT_TOP = "一键嘲讽";
BINDING_NAME_LZT_ZERK = "反恐";

LZT_VARS_LOADED = false;
LZT_COLORS={};
LZT_COLORS.RED = "|cffff0000";
LZT_COLORS.GREEN = "|cff00ff00";
LZT_COLORS.BLUE = "|cff0000ff";
LZT_COLORS.MAGENTA = "|cffff00ff";
LZT_COLORS.YELLOW = "|cffffff00";
LZT_COLORS.CYAN = "|cff00ffff";
LZT_COLORS.WHITE = "|cffffffff";

LZT_OPTIONS={};
LZT_OPTIONS.BSHOUT = false;
LZT_OPTIONS.SHIELDBLOCK = true;
LZT_OPTIONS.VAELTANK = false;
LZT_OPTIONS.PARANOID = false;
LZT_OPTIONS.PARANOIATHRESHOLD = 20;
LZT_OPTIONS.DEMOSHOUT = false;
LZT_OPTIONS.THUNDERCLAP = false;
LZT_OPTIONS.HEROICSTRIKE = false;
LZT_OPTIONS.SHIELDSLAM = false;
LZT_OPTIONS.BLOODRAGE = false;
LZT_OPTIONS.RAGEDUMP = true;
LZT_OPTIONS.SUNDERTHRESHOLD = 19;
LZT_OPTIONS.HSTHRESHOLD = 19;
LZT_OPTIONS.SHIELDSLAMTHRESHOLD = 24;
LZT_OPTIONS.SHIELDBLOCKTHRESHOLD = 14;
LZT_OPTIONS.RAGEDUMPTHRESHOLD = 60;
LZT_OPTIONS.USEPOT = false;
LZT_OPTIONS.SHIELDWALL = false;

LZT_SPELL = {};
LZT_SPELL.SUNDER = "破甲攻击";
LZT_SPELL.REVENGE = "复仇";
LZT_SPELL.SHIELDBLOCK = "盾牌格挡";
LZT_SPELL.SHIELDBASH = "盾击";
LZT_SPELL.HEROICSTRIKE = "英勇打击";
LZT_SPELL.BATTLESHOUT = "战斗怒吼";
LZT_SPELL.SHIELDSLAM = "盾牌猛击";
LZT_SPELL.DEMOSHOUT = "挫志怒吼";
LZT_SPELL.THUNDERCLAP = "雷霆一击";
LZT_SPELL.EXECUTE = "斩杀";
LZT_SPELL.SHIELDWALL = "盾墙";
LZT_SPELL.BERSERKERRAGE = "狂暴之怒";
LZT_SPELL.BSTANCE = "战斗姿态";
LZT_SPELL.DSTANCE = "防御姿态";
LZT_SPELL.ZSTANCE = "狂暴姿态";
LZT_SPELL.BLOODRAGE = "血性狂暴";
LZT_SPELL.ATTACK = "攻击";
LZT_SPELL.LASTSTAND = "破釜沉舟";
LZT_SPELL.CHAOFENG = "嘲讽";
LZT_SPELL.CHENGJIETONGJI = "惩戒痛击";
LZT_SPELL.TIAOZHANNUHOU = "挑战怒吼";


local function SpellId(spellname)
	local id = 1
	for i = 1, GetNumSpellTabs() do
		local _, _, _, numSpells = GetSpellTabInfo(i)
		for j = 1, numSpells do
			local spellName = GetSpellName(id, BOOKTYPE_SPELL)
			if spellName == spellname then
				return id
			end
			id = id + 1
		end
	end
	return nil
end

local function SpellReadyIn(spellname)
	local id = SpellId(spellname)
	if id then
		local start, duration = GetSpellCooldown(id, 0)
		if start == 0 and duration == 0 and FuryLastSpellCast + 1 <= GetTime() then
			return 0
		end
		local remaining = duration - (GetTime() - start)
		if remaining >= 0 then
			return remaining
		end
	end
	return 86400
end

local function GetDistance()
	if not UnitCanAttack("player", "target") then
		return 100 -- invalid target
	end
	if yard05 and IsActionInRange(yard05) == 1 then
		return 5 -- 0 - 5
	end
	if yard10 and IsActionInRange(yard10) == 1 then
		if yard08 and IsActionInRange(yard08) == 0 then
			return 7 -- 6 - 7
		end
		return 10 -- 8 - 10
	end
	if yard25 and IsActionInRange(yard25) == 1 then
		return 25 -- 11 - 25
	end
	if yard30 and IsActionInRange(yard30) == 1 then
		return 30 -- 26 - 30
	end
	return 100 -- 31 - <na>
end
local function ActiveStance()
	--Detect the active stance
	for i = 1, 3 do
		local _, _, active = GetShapeshiftFormInfo(i)
		if active then
			return i
		end
	end
	return nil
end

local function HasDebuff(unit, texturename, amount)
	local id = 1
	while UnitDebuff(unit, id) do
		local debuffTexture,debuffAmount = UnitDebuff(unit, id)
		if string.find(debuffTexture, texturename) then
			if (amount or 1) <= debuffAmount then
				return true
			else
				return false
			end
		end
		id = id + 1
	end
	return nil
end

function TopPull()
	if GetDistance() == 5 and SpellReadyIn(LZT_SPELL.CHAOFENG) == 0 then
		if ActiveStance() ~= 2 then
			CastShapeshiftForm(2)
		end
		CastSpellByName(LZT_SPELL.CHAOFENG)
	elseif not HasDebuff("target","Reincarnation") and GetDistance() == 5 and UnitMana("player") >= 10 and SpellReadyIn(LZT_SPELL.CHENGJIETONGJI) == 0 then
		if ActiveStance() ~= 1 then
			CastShapeshiftForm(1)
		end
		CastSpellByName(LZT_SPELL.CHENGJIETONGJI)

	--[[elseif not HasDebuff("target","PunishingBlow") and not HasDebuff("target","Reincarnation") and GetDistance() == 5 and UnitMana("player") >= 3 and SpellReadyIn(LZT_SPELL.TIAOZHANNUHOU) == 0 then
		if ActiveStance() ~= 2 then
			CastShapeshiftForm(2)
		end
		CastSpellByName(LZT_SPELL.TIAOZHANNUHOU)]]
    else
        CastShapeshiftForm(2)
	end
end


LZT_ID = {};
LZT_ID.SUNDER = nil;
LZT_ID.REVENGE = nil;
LZT_ID.SHIELDBLOCK = nil;
LZT_ID.SHIELDBASH = nil;
LZT_ID.HEROICSTRIKE = nil;
LZT_ID.BATTLESHOUT = nil;
LZT_ID.SHIELDSLAM = nil;
LZT_ID.DEMOSHOUT = nil;
LZT_ID.THUNDERCLAP = nil;
LZT_ID.EXECUTE = nil;
LZT_ID.SHIELDWALL = nil;
LZT_ID.BERSERKERRAGE = nil;
LZT_ID.BLOODRAGE = nil;
LZT_ID.ATTACK = nil;
LZT_ID.LASTSTAND = nil;

LZT_ACTION = {};
LZT_ACTION.SUNDER = nil;
LZT_ACTION.REVENGE = nil;
LZT_ACTION.SHIELDBLOCK = nil;
LZT_ACTION.SHIELDBASH = nil;
LZT_ACTION.HEROICSTRIKE = nil;
LZT_ACTION.BATTLESHOUT = nil;
LZT_ACTION.SHIELDSLAM = nil;
LZT_ACTION.DEMOSHOUT = nil;
LZT_ACTION.THUNDERCLAP = nil;
LZT_ACTION.SHIELDWALL = nil;
LZT_ACTION.BERSERKERRAGE = nil;
LZT_ACTION.BLOODRAGE = nil;
LZT_ACTION.ATTACK = nil;
LZT_ACTION.LASTSTAND = nil;

LZT_TEXTURE = {};
LZT_TEXTURE.SUNDER = [[Interface\Icons\Ability_Warrior_Sunder]];
LZT_TEXTURE.REVENGE = [[Interface\Icons\Ability_Warrior_Revenge]];
LZT_TEXTURE.SHIELDBLOCK = [[Interface\Icons\Ability_Defend]];
LZT_TEXTURE.SHIELDBASH = [[Interface\Icons\Ability_Warrior_ShieldBash]];
LZT_TEXTURE.HEROICSTRIKE = [[Interface\Icons\Ability_Rogue_Ambush]];
LZT_TEXTURE.BATTLESHOUT = [[Interface\Icons\Ability_Warrior_BattleShout]];
LZT_TEXTURE.SHIELDSLAM = [[Interface\Icons\INV_Shield_05]];
LZT_TEXTURE.DEMOSHOUT = [[Interface\Icons\Ability_Warrior_WarCry]];
LZT_TEXTURE.THUNDERCLAP = [[Interface\Icons\Spell_Nature_ThunderClap]];
LZT_TEXTURE.SHIELDWALL = [[Interface\Icons\Ability_Warrior_ShieldWall]];
LZT_TEXTURE.BERSERKERRAGE = [[Interface\Icons\Spell_Nature_AncestralGuardian]];
LZT_TEXTURE.BLOODRAGE = [[Interface\Icons\Ability_Racial_BloodRage]];
LZT_TEXTURE.ATTACK = nil;
LZT_TEXTURE.LASTSTAND = [[Interface\Icons\Spell_Holy_AshesToAshes]];

-- Control Variables

LZT_SunderToggle = 0;
LZT_DemoUp = 0;
LZT_Toggle = 0;
LZT_BSUp = 0;
LZT_ClapOn = 0;
LZT_Generated = 0;
LZT_ParanoiaTrigger = 0;
LZT_SunderTrigger = 0;
LZT_ZerkerTrigger = 0;
LZT_SunderTimer = 0;
LZT_ZerkerTimer = 0;
LZT_Sunder5 = 0;
LZT_Zerk5 = 0;
LZT_LGGSlot = nil;
LZT_PotBag = nil;
LZT_PotSlot = nil;
LZT_ParanoiaTimer = 0;
LZT_HealthPercentage = 0;
LZT_StoneBag = nil;
LZT_StoneSlot = nil;

-- On Load Processing

function LZT_OnLoad()
	LZTAm(LZT_COLORS.YELLOW.."LazyTank v"..LZT_VERSION..":"..LZT_COLORS.CYAN.." 插件加载, /lzt help 设置");
	LZTAm(LZT_COLORS.YELLOW.."by Q猫汉化"..LZT_COLORS.RED.." <Paradosi>, Kargath/US");
	if ( UnitClass("player") == "战士") then
		SlashCmdList["LZT"] = LZT_Command;
		SLASH_LZT1 = "/lzt";
		SLASH_LZT2 = "/lazytank";
		LZT_Register();
		if (UnitFactionGroup("player") == "Alliance") then
			LZTAm(LZT_COLORS.RED.."Don't you already have EZ-Mode?");
		else LZTAm(LZT_COLORS.RED.."For the Horde!");
		end;
	else
		LZTAm(LZT_COLORS.RED.."NOT THE MAMA!");	
	end;
end;

-- Register Events

function LZT_Register()

	for index,value in LZT_EVENTS do
		this:RegisterEvent(value);
	end;
end;

-- Event Processing

function LZT_OnEvent(event)
	if event=="PLAYER_TARGET_CHANGED" then 
		LZT_SunderToggle = 1;
		LZT_DemoUp = 0;
		LZT_Toggle = 0;
		LZT_BSUp = 0;
	end;	
	if event=="PLAYER_REGEN_DISABLED" then
		LZTGenerateID();
		LZTGenActionID();
	end;
	if event=="PLAYER_REGEN_ENABLED" then
		LZT_Generated = 0;
	end;
end;

-- Chat Frame Function

function LZTAm(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end;

-- LazyTank Help
function LZT_Help()
	LZTAm(LZT_COLORS.YELLOW.."LazyTank v"..LZT_VERSION..":"..LZT_COLORS.CYAN.." Help 列表");
	LZTAm(LZT_COLORS.YELLOW.."by Q猫汉化"..LZT_COLORS.RED.." <Paradosi>, Kargath/US");
	LZTAm(LZT_COLORS.CYAN.."  /lzt hate: "..LZT_COLORS.YELLOW.." 执行最佳可用威胁技能");
	LZTAm(LZT_COLORS.CYAN.."  /lzt top: "..LZT_COLORS.YELLOW.." 一键嘲讽");
	LZTAm(LZT_COLORS.CYAN.."  /lzt zerk: "..LZT_COLORS.YELLOW.." 执行反恐");
	LZTAm(LZT_COLORS.CYAN.."  /lzt shout {on|off}: "..LZT_COLORS.YELLOW.." 切换开启战斗怒吼");
	LZTAm(LZT_COLORS.CYAN.."  /lzt block {on|off}: "..LZT_COLORS.YELLOW.." 切换开启盾牌格挡");
	LZTAm(LZT_COLORS.CYAN.."  /lzt execute {on|off}: "..LZT_COLORS.YELLOW.." 切换坦克斩杀");
	LZTAm(LZT_COLORS.CYAN.."  /lzt paranoid {on|off}: "..LZT_COLORS.YELLOW.." 切换开启自救");
	LZTAm(LZT_COLORS.CYAN.."  /lzt thunderclap {on|off}: "..LZT_COLORS.YELLOW.."切换开启雷霆一击");
	LZTAm(LZT_COLORS.CYAN.."  /lzt demoshout {on|off}: "..LZT_COLORS.YELLOW.." 切换开启挫志怒吼");
	LZTAm(LZT_COLORS.CYAN.."  /lzt brage {on|off}: "..LZT_COLORS.YELLOW.." 切换触发血性狂暴");
	LZTAm(LZT_COLORS.CYAN.."  /lzt dump {on|off}: "..LZT_COLORS.YELLOW.." 切换英勇打击泄怒");
	LZTAm(LZT_COLORS.CYAN.."  /lzt decrement: "..LZT_COLORS.YELLOW.." 降低自救门槛 5%");
	LZTAm(LZT_COLORS.CYAN.."  /lzt increment: "..LZT_COLORS.YELLOW.." 增加自救门槛 5%");
end;



-- Command Parsing Loop

function LZT_Command(cmd)
	if LZT_Generated == 0 then
		LZTGenerateID();
		LZTGenActionID();
		LZT_Generated = 1;
	end;
	if (cmd == "shout off") then 
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用战斗怒吼");
			LZT_OPTIONS.BSHOUT = false;
	elseif (cmd == "top") then

		TopPull()

	elseif (cmd == "shout on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用战斗怒吼");
			LZT_OPTIONS.BSHOUT = true;
	elseif (cmd == "block off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用盾牌格挡");
			LZT_OPTIONS.SHIELDBLOCK = false;
	elseif (cmd == "block on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用盾牌格挡");
			LZT_OPTIONS.SHIELDBLOCK = true;
	elseif (cmd == "execute off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用坦克斩杀");
			LZT_OPTIONS.VAELTANK = false;
	elseif (cmd == "execute on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用坦克斩杀");
			LZT_OPTIONS.VAELTANK = true;
	elseif (cmd == "paranoid off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用 自救");
			LZT_OPTIONS.PARANOID = false;
	elseif (cmd == "paranoid on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用 自救: 目前的门槛 "..LZT_OPTIONS.PARANOIATHRESHOLD.."%");
			LZT_OPTIONS.PARANOID = true;
	elseif (cmd == "thunderclap off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用雷霆一击");
			LZT_OPTIONS.THUNDERCLAP = false;
	elseif (cmd == "thunderclap on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用雷霆一击");
			LZT_OPTIONS.THUNDERCLAP = true;
	elseif (cmd == "demoshout off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用挫志怒吼");
			LZT_OPTIONS.DEMOSHOUT = false;
	elseif (cmd == "demoshout on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用挫志怒吼");
			LZT_OPTIONS.DEMOSHOUT = true;
	elseif (cmd == "dump on") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."启用英勇打击泄怒");
			LZT_OPTIONS.RAGEDUMP = true;
	elseif (cmd == "dump off") then
			LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用英勇打击泄怒");
			LZT_OPTIONS.RAGEDUMP = false;
	elseif (cmd == "help") then
		LZT_Help();
	elseif (cmd == "hate") then
		HateMonger();
	elseif (cmd == "status") then
		LZTStatus();
	elseif (cmd == "zerk") then
		ZerkerRage();
	elseif (cmd == "brage on") then
		LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."开启血性狂暴");
		LZT_OPTIONS.BLOODRAGE = true;
	elseif (cmd == "brage off") then
		LZTAm(LZT_COLORS.CYAN.."LazyTank: "..LZT_COLORS.YELLOW.."禁用血性狂暴");
		LZT_OPTIONS.BLOODRAGE = false;
	elseif (cmd == "increment") then
		LZT_OPTIONS.PARANOIATHRESHOLD = LZT_OPTIONS.PARANOIATHRESHOLD + 5;
		LZTAm(LZT_COLORS.CYAN.."自救门槛提示: "..LZT_COLORS.YELLOW.."自救的门槛现在是 "..LZT_OPTIONS.PARANOIATHRESHOLD.."%");
	elseif (cmd == "decrement") then
		LZT_OPTIONS.PARANOIATHRESHOLD = LZT_OPTIONS.PARANOIATHRESHOLD - 5;
		LZTAm(LZT_COLORS.CYAN.."自救门槛提示: "..LZT_COLORS.YELLOW.."自救的门槛现在是 "..LZT_OPTIONS.PARANOIATHRESHOLD.."%");
	else LZTAm("Invalid Command - uze /lzt help for proper syntax");
	end;

end;

-- Generate Slot ID's

function LZTGenerateID()
	LZT_GetAttackTexture();
	local id = nil;
	for id = 1, 120 do
		local spellname = nil;
		spellname = GetSpellName(id,"Spell");
			if (spellname == LZT_SPELL.SUNDER) then 
				LZT_ID.SUNDER = id;			
			elseif (spellname == LZT_SPELL.REVENGE) then
				LZT_ID.REVENGE = id;
			elseif (spellname == LZT_SPELL.SHIELDBLOCK) then
				LZT_ID.SHIELDBLOCK = id;
			elseif (spellname == LZT_SPELL.SHIELDBASH) then
				LZT_ID.SHIELDBASH = id;
			elseif (spellname == LZT_SPELL.HEROICSTRIKE) then
				LZT_ID.HEROICSTRIKE = id;
			elseif (spellname == LZT_SPELL.BATTLESHOUT) then
				LZT_ID.BATTLESHOUT = id;
   			elseif (spellname == LZT_SPELL.SHIELDSLAM) then
 				LZT_ID.SHIELDSLAM = id;
			elseif (spellname == LZT_SPELL.DEMOSHOUT) then
				LZT_ID.DEMOSHOUT = id;
			elseif (spellname == LZT_SPELL.THUNDERCLAP) then
				LZT_ID.THUNDERCLAP = id;
			elseif (spellname == LZT_SPELL.EXECUTE) then
				LZT_ID.EXECUTE = id;
			elseif (spellname == LZT_SPELL.SHIELDWALL) then
				LZT_ID.SHIELDWALL = id;
			elseif (spellname == LZT_SPELL.BERSERKERRAGE) then
				LZT_ID.BERSERKERRAGE = id;
			elseif (spellname == LZT_SPELL.BLOODRAGE) then
				LZT_ID.BLOODRAGE = id;
			elseif (spellname == LZT_SPELL.ATTACK) then
				LZT_ID.ATTACK = id;
			elseif (spellname == LZT_SPELL.LASTSTAND) then
				LZT_ID.LASTSTAND = id;
			end;			
		end;
end;

-- Generate Action ID's
function LZTGenActionID()
	LZT_OPTIONS.SHIELDSLAM = false;
	local icon = nil;
	local i = nil;
	for i = 1,120 do
		if HasAction(i) and not GetActionText(i) then
			icon = GetActionTexture(i);
			if (icon==LZT_TEXTURE.SUNDER) then
				LZT_ACTION.SUNDER = i;
			elseif (icon==LZT_TEXTURE.REVENGE) then
				LZT_ACTION.REVENGE = i;
			elseif (icon==LZT_TEXTURE.SHIELDBLOCK) then
				LZT_ACTION.SHIELDBLOCK = i;
			elseif (icon==LZT_TEXTURE.SHIELDBASH) then
				LZT_ACTION.SHIELDBASH = i;
			elseif (icon==LZT_TEXTURE.HEROICSTRIKE) then
				LZT_ACTION.HEROICSTRIKE = i;
			elseif (icon==LZT_TEXTURE.BATTLESHOUT) then
				LZT_ACTION.BATTLESHOUT = i;
			elseif (icon==LZT_TEXTURE.DEMOSHOUT) then
				LZT_ACTION.DEMOSHOUT = i;
			elseif (icon==LZT_TEXTURE.THUNDERCLAP) then
				LZT_ACTION.THUNDERCLAP = i;
			elseif (icon==LZT_TEXTURE.SHIELDWALL) then
				LZT_ACTION.SHIELDWALL = i;
			elseif (icon==LZT_TEXTURE.SHIELDSLAM) then
				LZT_ACTION.SHIELDSLAM = i;
				LZT_OPTIONS.SHIELDSLAM = true;
			elseif (icon==LZT_TEXTURE.BERSERKERRAGE) then
				LZT_ACTION.BERSERKERRAGE = i;
			elseif (icon==LZT_TEXTURE.BLOODRAGE) then
				LZT_ACTION.BLOODRAGE = i;
			elseif (icon==LZT_TEXTURE.ATTACK) then
				LZT_ACTION.ATTACK = i;
			elseif (icon==LZT_TEXTURE.LASTSTAND) then
				LZT_ACTION.LASTSTAND = i;
			end;
		end;
	end;
end;

-- Main Hate Loop

function HateMonger()
	if LZT_Generated == 0 then
		LZTGenerateID();
		LZTGenActionID();
		LZT_Generated = 1;
	end;
	LZT_HealthPercentage = LZT_HealthCheck();
	if LZT_OPTIONS.PARANOID and (LZT_HealthPercentage < LZT_OPTIONS.PARANOIATHRESHOLD) then
		if LZT_ParanoiaTrigger == 0 then
			LZT_ParanoiaTrigger = 1;
			LZT_Paranoia();
		end;
	end;
	if LZT_OPTIONS.BLOODRAGE and (UnitHealth("player") > (UnitHealthMax("player") * .5)) then
		local e = GetSpellCooldown(LZT_ID.BLOODRAGE,SpellBookFrame.bookType);
		if e <= 0 then
			CastSpellByName(LZT_SPELL.BLOODRAGE);
		end;
	end;
	if LZT_OPTIONS.VAELTANK and UnitHealth("target") < 20 then
		LZTExecute();
		return;
	end;
	if (LZT_OPTIONS.THUNDERCLAP) then
		ThunderCheck();
	end;
	local _,_,c = GetShapeshiftFormInfo(2);
	if not c and UnitHealth("target") > 20 then
		CastSpellByName(LZT_SPELL.DSTANCE)
	end;
	if (LZT_OPTIONS.DEMOSHOUT) then
		DemoCheck();
	end;
	if (LZT_OPTIONS.BSHOUT) then
		BShoutCheck();
	end;
	if (UnitMana("player") > 60) and not IsCurrentAction(LZT_ACTION.HEROICSTRIKE) and LZT_OPTIONS.RAGEDUMP then
		CastSpellByName(LZT_SPELL.HEROICSTRIKE)
		return;
	end;
	local a = GetSpellCooldown(LZT_ID.REVENGE,SpellBookFrame.bookType);
	local b = GetSpellCooldown(LZT_ID.SHIELDBLOCK,SpellBookFrame.bookType);
	local d = 1;
	if LZT_OPTIONS.SHIELDSLAM then
		d = GetSpellCooldown(LZT_ID.SHIELDSLAM,SpellBookFrame.bookType);
	end;
	if a <= 0 and IsUsableAction(LZT_ACTION.REVENGE) then
		CastSpellByName(LZT_SPELL.REVENGE);
		return;
	elseif (b <= 0 and LZT_OPTIONS.SHIELDBLOCK and UnitMana("player") > 14) then 
		CastSpellByName(LZT_SPELL.SHIELDBLOCK); 
		return;
	elseif 	(d <= 0 and UnitMana("player") > 24) then
		CastSpellByName(LZT_SPELL.SHIELDSLAM);
		return;
	else
		SunderCheck(); 
		if LZT_SunderToggle == 1 then
			if UnitMana("player") > 19 and IsUsableAction(LZT_ACTION.SUNDER) then
				if IsCurrentAction(LZT_ACTION.SUNDER) then
					LZT_AttackTarget();
				else
					if KLHTM_Sunder then
						KLHTM_Sunder();
					else
						CastSpellByName(LZT_SPELL.SUNDER);
					end;
					return;
				end;
			else
				LZT_AttackTarget();
			end;
		else
			if IsCurrentAction(LZT_ACTION.HEROICSTRIKE) then
				if UnitMana("player") > 19 and IsUsableAction(LZT_ACTION.SUNDER) then
					if IsCurrentAction(LZT_ACTION.SUNDER) then
						LZT_AttackTarget();
					else
						if KLHTM_Sunder then
							KLHTM_Sunder();
						else
							CastSpellByName(LZT_SPELL.SUNDER);
						end;
						return;
					end;
				else
					LZT_AttackTarget();
				end;
			else
				if UnitMana("player") > 19 and IsUsableAction(LZT_ACTION.HEROICSTRIKE) then
					CastSpellByName(LZT_SPELL.HEROICSTRIKE);
				elseif UnitMana("player") > 19 and IsUsableAction(LZT_ACTION.SUNDER) then
					if IsCurrentAction(LZT_ACTION.SUNDER) then
						LZT_AttackTarget();
					else
						if KLHTM_Sunder then
							KLHTM_Sunder();
						else
							CastSpellByName(LZT_SPELL.SUNDER);
						end;
						return;
					end;
				else
					LZT_AttackTarget();
				end;
			end;
		end;		
	end;
end;

-- Check for # of Sunder Armor applications

function SunderCheck()
	local i = nil;
	local debuffTexture = nil;
	local debuffApplications = nil;
	for i = 1,16 do
		debuffTexture, debuffApplications = UnitDebuff("target",i);
		if debuffTexture == LZT_TEXTURE.SUNDER then
			if debuffApplications == 5 then
				if LZT_SunderToggle == 0 then
					LZT_SunderToggle = 1;
				else
					LZT_SunderToggle = 0;
				end;
			end;
		end;
	end;
end;

-- Check for Demoralizing Shout debuff

function DemoCheck()
	local i = 0;
	local debuffTexture = nil;
	local debuffApplications = nil;
	LZT_DemoUp = 0;
	for i = 1,16 do
	debuffTexture = UnitDebuff("target",i);
		if debuffTexture == LZT_TEXTURE.DEMOSHOUT then
			LZT_DemoUp = 1;
		end;
	end;
	if LZT_DemoUp == 0 then 
		for i = 1,16 do
		debuffTexture, debuffApplications = UnitDebuff("target",i);
			if debuffTexture == LZT_TEXTURE.SUNDER then
				if debuffApplications > 2 then
					CastSpellByName(LZT_SPELL.DEMOSHOUT);
				end;
			end;
		end;
	end;
end;

-- Check for Battle Shout Buff

function BShoutCheck()
	local i = 0;
	local debuffTexture = nil;
	local debuffApplications = nil;
	local buffTexture = nil;
	LZT_BSUp = 0;
	for i = 0,20 do	
		buffTexture = UnitBuff("player",i);
		if buffTexture == LZT_TEXTURE.BATTLESHOUT then
			LZT_BSUp = 1;
		end;
	end;
	if LZT_BSUp == 0 then 
		for i = 0,20 do
		debuffTexture, debuffApplications = UnitDebuff("target",i);
			if debuffTexture == LZT_TEXTURE.SUNDER then
				if debuffApplications > 2 then
					CastSpellByName(LZT_SPELL.BATTLESHOUT);
				end;
			end;
		end;
	end;
end;

-- Displays Status of Toggles

function LZTStatus()
	LZTAm(LZT_COLORS.CYAN.."LazyTank Toggle Status");
	if LZT_OPTIONS.SHIELDSLAM then
		LZTAm(LZT_COLORS.WHITE.."盾牌猛击: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."盾牌猛击: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.BSHOUT then 
		LZTAm(LZT_COLORS.WHITE.."战斗怒吼: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."战斗怒吼: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.SHIELDBLOCK then 
		LZTAm(LZT_COLORS.WHITE.."盾牌格挡: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."盾牌格挡: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.VAELTANK then 
		LZTAm(LZT_COLORS.WHITE.."坦克斩杀: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."坦克斩杀: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.DEMOSHOUT then 
		LZTAm(LZT_COLORS.WHITE.."挫志怒吼: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."挫志怒吼: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.THUNDERCLAP then
		LZTAm(LZT_COLORS.WHITE.."雷霆一击: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."雷霆一击: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.PARANOID then
		LZTAm(LZT_COLORS.WHITE.."自救: "..LZT_COLORS.CYAN.."开启");
	else
		LZTAm(LZT_COLORS.WHITE.."自救: "..LZT_COLORS.CYAN.."禁用");
	end;
	if LZT_OPTIONS.BLOODRAGE then
		LZTAm(LZT_COLORS.WHITE.."血性狂暴: "..LZT_COLORS.CYAN.."开启");	
	else
		LZTAm(LZT_COLORS.WHITE.."血性狂暴: "..LZT_COLORS.CYAN.."禁用");
	end;	
	if LZT_OPTIONS.RAGEDUMP then
		LZTAm(LZT_COLORS.WHITE.."泄怒: "..LZT_COLORS.CYAN.."开启");	
	else
		LZTAm(LZT_COLORS.WHITE.."泄怒: "..LZT_COLORS.CYAN.."禁用");
	end;
	if KLHTM_Sunder then
		LZTAm(LZT_COLORS.WHITE.."威胁技: "..LZT_COLORS.CYAN.."禁用");
	end;
	LZTAm(LZT_COLORS.WHITE.."自救门槛: "..LZT_COLORS.CYAN..LZT_OPTIONS.PARANOIATHRESHOLD.."%");
end;

-- Check for application of Thunder Clap debuff

function ThunderCheck()
	local i = 0;
	local debuffTexture = nil;
	local debuffApplications = nil;
	LZT_ClapOn = 0;
	for i = 1,16 do
	debuffTexture = UnitDebuff("target",i);
		if debuffTexture == LZT_TEXTURE.THUNDERCLAP then
			LZT_ClapOn = 1;
		end;
	end;
	if LZT_ClapOn == 0 then 
		for i = 1,16 do
		debuffTexture, debuffApplications = UnitDebuff("target",i);
			if debuffTexture == LZT_TEXTURE.SUNDER then
				if debuffApplications > 2 then
					local _,_,a = GetShapeshiftFormInfo(1);
					if not a and UnitMana("player") > 19 then
						CastSpellByName(LZT_SPELL.BSTANCE);
					else
						CastSpellByName(LZT_SPELL.THUNDERCLAP);
					end;
				end;
			end;
		end;
	end;
end;

-- Execute Tanking Function

function LZTExecute()
if UnitHealth("target") == 0 then
	return;
end;
local _,_,a = GetShapeshiftFormInfo(1);
	if not a then
		UIErrorsFrame:AddMessage(LZT_COLORS.RED.."FINISH HIM!");
		CastSpellByName(LZT_SPELL.BSTANCE);
	else
		CastSpellByName(LZT_SPELL.EXECUTE);
	end;

end;

-- Horde Fear Ward

function ZerkerRage()
	local a = GetSpellCooldown(LZT_ID.BERSERKERRAGE,SpellBookFrame.bookType);
	if a <= 0 then
        	local _,_,c = GetShapeshiftFormInfo(3);		
		if not c then
			CastSpellByName(LZT_SPELL.ZSTANCE);
			return;
		else
			CastSpellByName(LZT_SPELL.BERSERKERRAGE);
			LZT_ZerkerTrigger = 1;
		end;
	else
		local _,_,c = GetShapeshiftFormInfo(2);		
		if not c then 
			CastSpellByName(LZT_SPELL.DSTANCE);
		else
			LZTAm(LZT_COLORS.YELLOW.."反恐提示: "..LZT_COLORS.CYAN.."狂暴之怒在CD");
		end;
	end;
end;

-- Check Players Health for Paranoia Checking

function LZT_HealthCheck()
	local a = UnitHealth("player");
	local b = UnitHealthMax("player");
	return ((a / b) * 100);
end;


-- OnUpdate Function

function LZTOnUpdate(elapsed)
	if (LZT_ZerkerTrigger == 1) then
		LZT_ZerkerTimer = LZT_ZerkerTimer + elapsed;
		if LZT_ZerkerTimer > 26 and (LZT_Zerk5 == 0) then
			LZTAm(LZT_COLORS.CYAN.."反恐提示: "..LZT_COLORS.YELLOW.."狂暴之怒 在5秒钟内可用");
			LZT_Zerk5 = 1;
		end;
		if LZT_ZerkerTimer > 31 then
			LZTAm(LZT_COLORS.CYAN.."反恐提示: "..LZT_COLORS.YELLOW.."狂暴之怒 可用");
			LZT_Zerk5 = 0;
			LZT_ZerkerTrigger = 0;
			LZT_ZerkerTimer = 0;
		end;
	end;
	if (LZT_ParanoiaTrigger == 1) then
		LZT_ParanoiaTimer = LZT_ParanoiaTimer + elapsed;
			if LZT_ParanoiaTimer > 2 then
				LZT_ParanoiaTrigger = 0;
				LZT_ParanoiaTimer = 0;
			end;
	end;	
end;

-- Get's the texture for the Mainhand weapon so it can match it to the Attack action button

function LZT_GetAttackTexture()
	local mainHandLink = GetInventoryItemLink("player",GetInventorySlotInfo("MainHandSlot"));
	if mainHandLink then 
		local _, _, itemCode = strfind(mainHandLink, "(%d+):");
		local _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemCode);
		LZT_TEXTURE.ATTACK = itemTexture;
	else
		LZTAm("受到阻滞, 尝试装备一个武器");
	end;

end;

-- Make sure autoattack is on if it's not

function LZT_AttackTarget()
	AttackTarget()
--	if not IsCurrentAction(LZT_ACTION.ATTACK) then
--		UseAction(LZT_ACTION.ATTACK)
--	else
--		return;
--	end;
end;

-- Check both trinket slots for Lifegiving Gem

function LZT_FindGem()
	LZT_LGGSlot = nil;
	for a = 13,14 do
		local name = LZT_GetItemName(a);
		if name == "生命宝石" then
			LZT_LGGSlot = a;
		end;
	end;
end;

-- Return the itemname of the slot being passed

function LZT_GetItemName(slot)
	local itemLink = GetInventoryItemLink("player",slot);
	if itemLink then
		local _,_,itemCode = strfind(itemLink, "(%d+):");
		local itemName = GetItemInfo(itemCode);	
		return itemName;
	else 
		return;
	end;
end;

-- Find Major Healing Potion in Bags

function LZT_FindHealingPot()
	LZT_PotBag = nil;
	LZT_PotSlot = nil;
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				if (string.find(GetContainerItemLink(bag,slot), "特效治疗药水")) then
					LZT_PotBag = bag;
					LZT_PotSlot = slot;
				end;
			end;
		end;
	end;
end;

-- Find Major Healthstone

function LZT_FindHealthStone()
	LZT_StoneBag = nil;
	LZT_StoneSlot = nil;
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			if (GetContainerItemLink(bag,slot)) then
				if (string.find(GetContainerItemLink(bag,slot), "特效治疗石")) then
					LZT_StoneBag = bag;
					LZT_StoneSlot = slot;
				end;
			end;
		end;
	end;
end;
 
function LZT_Paranoia()
	LZT_FindHealthStone();
	LZT_FindHealingPot();
	LZT_FindGem();
	local ls_avail = false;
	local sw_avail = false;
	local lgg_avail = false;
	local healpot_avail = false;
	local healthstone_avail = false;
	local i = 0;
	local buffTexture = nil;
	local a = GetSpellCooldown(LZT_ID.SHIELDWALL,SpellBookFrame.bookType);
	if a <= 0 then
		sw_avail = true;
	end;
	if LZT_ID.LASTSTAND then
		local b = GetSpellCooldown(LZT_ID.LASTSTAND,SpellBookFrame.bookType);
		if b <= 0 then
			ls_avail = true;
		end;
	end;
	if LZT_LGGSlot then
		local c = GetInventoryItemCooldown("player",LZT_LGGSlot);
		if c <= 0 then
			lgg_avail = true;
		end;
	end;
	if LZT_StoneBag then
		local d = GetContainerItemCooldown(LZT_StoneBag,LZT_StoneSlot);
		if d <= 0 then
			healthstone_avail = true;
		end;
	end;
	if LZT_PotBag then
		local e = GetContainerItemCooldown(LZT_PotBag,LZT_PotSlot);
		if e <= 0 then
			healpot_avail = true;
		end;
	end;
	if lgg_avail then
		UseInventoryItem(LZT_LGGSlot);
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."生命宝石");
	elseif ls_avail then
		CastSpellByName(LZT_SPELL.LASTSTAND);
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."破釜沉舟");
	elseif sw_avail then
		CastSpellByName(LZT_SPELL.SHIELDWALL);
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."墙盾");
	elseif healthstone_avail then
		UseContainerItem(LZT_stoneBag,LZT_StoneSlot,1);
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."治疗石");
	elseif healpot_avail then
		UseContainerItem(LZT_PotBag,LZT_PotSlot,1);
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."治疗药水");
	else
		LZTAm(LZT_COLORS.YELLOW.."自救提示: "..LZT_COLORS.CYAN.."什么都没有.你会死的!!!");
	end;
end;