IntToIntcMinIntHashMap cUnitTypeToCostHashMap;

int COMMAND_TYPE = cUnitTypeLegendHero;
string COMMAND_TYPE_NAME = "LegendHero";

int getCostKey(int p = 1, int protoId = -1) {
    return p * cNumberProtoUnits + protoId;
}

// Raises the stored cost of the command for this player and applies it to the protounit.
void increaseCommandCost(int unitId = -1, float increment = 1.0) {
    int p = kbUnitGetPlayerID(unitId);
    int protoId = kbUnitGetProtoUnitID(unitId);
    int key = getCostKey(p, protoId);
    int newCost = cUnitTypeToCostHashMap.get(key) + increment;
    cUnitTypeToCostHashMap.put(key, newCost);
    trModifyProtounitResource(kbProtoUnitGetName(protoId), "Gold", p, cXSPUResourceEffectCost, newCost, cXSRelativityAssign);
}

void applyActionUpgradeToAllHumanBuildings(int unitId = -1, int actionEffect = cXSActionEffectDamagePierce, float delta = 1.0, int relativity = cXSRelativityAbsolute) {
    int p = kbUnitGetPlayerID(unitId);
    for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        int buildingType = g_upgradeableHumanBuildings[i];
        trModifyProtounitAction(kbProtoUnitGetName(buildingType), "HandAttack", p, actionEffect, delta, relativity);
        trModifyProtounitAction(kbProtoUnitGetName(buildingType), "RangedAttack", p, actionEffect, delta, relativity);
        trModifyProtounitAction(kbProtoUnitGetName(buildingType), "LightningAttack", p, actionEffect, delta, relativity);
    }
}

void applyDataUpgradeToAllHumanBuildings(int unitId = -1, int puField = cXSProtoEffectHitpoints, float delta = 1.0, int relativity = cXSRelativityAbsolute) {
    int p = kbUnitGetPlayerID(unitId);
    for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        int buildingType = g_upgradeableHumanBuildings[i];
        trModifyProtounitData(kbProtoUnitGetName(buildingType), p, puField, delta, relativity);
    }
}

void applyDataUpgradeToAllHumanTypes(int unitId = -1, int puField = cXSProtoEffectHitpoints, float delta = 1.0, int relativity = cXSRelativityAbsolute) {
    int p = kbUnitGetPlayerID(unitId);
    for (int i = 0; i < g_humanUnitTypes.size(); i++) {
        int unitType = g_humanUnitTypes[i];
        trModifyProtounitData(kbProtoUnitGetName(unitType), p, puField, delta, relativity);
    }
}

string addCommand(int p = 1, int plantType = -1, int targetProtoType = -1, int row = 0, int col = 0, int initialCost = 0,
                    string resource = "", string name = "", string description = "", string icon = "", 
                    void(int) event = [](int unitId = -1) -> void {}) {

    string plantName = kbProtoUnitGetName(plantType);

    // Register event handler directly with the event manager
    if (p != 0 || p != cHumanAIPlayer){
        g_OnCreationListener.register(p, plantType, true, event);
    }

    // Configure Protounit
    trProtoUnitSetFlag(p, plantName, "OnlyInEditor", true);
    trProtoUnitSetFlag(p, plantName, "ShowOnMinimap", false);
    trProtoUnitSetFlag(p, plantName, "StartOnNoUpdate", true);
    trProtoUnitSetFlag(p, plantName, "PlaceAnywhere", true);
    trProtoUnitSetFlag(p, plantName, "Immoveable", false);
    trProtoUnitSetFlag(p, plantName, "ForceToNature", false);
    trProtoUnitSetFlag(p, plantName, "DoNotQueue", true);
    trProtoUnitSetFlag(p, plantName, "AllowOverPopCap", true);
    trProtoUnitSetFlag(p, plantName, "AlwaysAllowOverPopCap", true);
    trProtoUnitSetFlag(p, plantName, "Invulnerable", true);
    trUnforbidProtounit(p, plantName);
    trModifyProtounitData(plantName, p, cXSProtoEffectTrainPoints, 0.01, cXSRelativityAssign);
    trProtoUnitSetUnitType(p, plantName, COMMAND_TYPE_NAME, true);
    trProtoUnitChangeName(plantName, p, name, description, description);
    trProtoUnitSetIcon(plantName, p, icon);
    trProtounitAddTrain(kbProtoUnitGetName(targetProtoType), p, plantName, row, col);
    trModifyProtounitResource(plantName, resource, p, cXSPUResourceEffectCost, initialCost, cXSRelativityAssign);
    cUnitTypeToCostHashMap.put(getCostKey(p, plantType), initialCost);
    return plantName;
}

void addArmoryCommands(){
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypePlantGreekBush, cUnitTypeArmory, 0, 0, 1, "Gold",
                    "+5% Attack for All Buildings",
                    "+5% Attack for All Buildings",
                    "resources\\in_game\\stat_pierce_dmg.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageHack, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamagePierce, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageCrush, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageDivine, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantGreekShrub, cUnitTypeArmory, 0, 1, 1, "Gold",
                    "-5% Rate of Fire for All Buildings",
                    "-5% Rate of Fire for All Buildings",
                    "resources\\in_game\\stat_rof.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectROF, 0.95, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantGreekGrass, cUnitTypeArmory, 0, 2, 1, "Gold",
                    "+1 Range for All Buildings",
                    "+1 Range for All Buildings",
                    "resources\\in_game\\stat_range.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectRange, 1.0);
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectLOS, 1.0);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantGreekWeeds, cUnitTypeArmory, 1, 0, 1, "Gold",
                    "+5% Hack Armor for All Buildings",
                    "+5% Hack Armor for All Buildings",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantGreekFern, cUnitTypeArmory, 1, 1, 1, "Gold",
                    "+5% Pierce Armor for All Buildings",
                    "+5% Pierce Armor for All Buildings",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantEgyptianBush, cUnitTypeArmory, 1, 2, 1, "Gold",
                    "+5% Crush Armor for All Buildings",
                    "+5% Crush Armor for All Buildings",
                    "resources\\in_game\\stat_crush_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorCrush, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantEgyptianShrub, cUnitTypeArmory, 1, 3, 1, "Gold",
                    "+5% Health for All Buildings",
                    "+5% Health for All Buildings",
                    "resources\\in_game\\stat_hp.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectHitpoints, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

void addSiegeCommands() {
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypePlantEgyptianGrass, cUnitTypeSiegeWorks, 0, 0, 1, "Gold",
                    "+1 Sentry Tower",
                    "+1 Sentry Tower",
                    "resources\\shared\\static_color\\buildings\\sentry_tower_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSentryTower));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantEgyptianWeeds, cUnitTypeSiegeWorks, 0, 1, 1, "Gold",
                    "+1 Smoke Trap",
                    "+1 Smoke Trap",
                    "resources\\aztec\\static_color\\buildings\\smoke_trap_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSmokeTrap));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSmokeTrap), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantEgyptianFern, cUnitTypeSiegeWorks, 1, 0, 10, "Gold",
                    "+1 Sky Passage",
                    "+1 Sky Passage",
                    "resources\\atlantean\\static_color\\buildings\\sky_passage_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSkyPassage));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSkyPassage), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantNorseBush, cUnitTypeSiegeWorks, 1, 1, 10, "Gold",
                    "+1 Spike Trap",
                    "+1 Spike Trap",
                    "resources\\aztec\\static_color\\buildings\\spike_trap_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSpikeTrap));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSpikeTrap), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantNorseShrub, cUnitTypeSiegeWorks, 1, 2, 10, "Gold",
                    "+1 Rock Giant",
                    "+1 Rock Giant",
                    "resources\\norse_freyr\\player_color\\units\\rock_giant_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeRockGiant));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantNorseGrass, cUnitTypeSiegeWorks, 2, 0, 20, "Gold",
                    "+1 Pillar of Tlalocan",
                    "+1 Pillar of Tlalocan",
                    "resources\\aztec\\static_color\\god_powers\\pillar_of_tlalocan_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantNorseWeeds, cUnitTypeSiegeWorks, 3, 0, 30, "Gold",
                    "+1 Statue of Lightning",
                    "+1 Statue of Lightning",
                    "resources\\spc\\static_color\\buildings\\statue_major_god_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeStatueOfLightning));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

void addEconomicGuildCommands(){
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypePlantNorseFern, cUnitTypeEconomicGuild, 0, 0, 1, "Gold",
                    "+5% Build Speed for self",
                    "+5% Build Speed for self",
                    "resources\\shared/hud\\command\\military_camp_build_right_icon.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectBuildPoints, 0.95, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantSnowBush, cUnitTypeEconomicGuild, 0, 1, 1, "Gold",
                    "+5% Movement Speed for self",
                    "+5% Movement Speed for self",
                    "resources\\in_game\\stat_speed.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectSpeed, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantSnowGrass, cUnitTypeEconomicGuild, 0, 2, 1, "Gold",
                    "+5% Health for self",
                    "+5% Health for self",
                    "resources\\in_game\\stat_hp.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectHitpoints, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantSnowWeeds, cUnitTypeEconomicGuild, 1, 0, 1, "Gold",
                    "+5% Hack Armor for self",
                    "+5% Hack Armor for self",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantSnowFern, cUnitTypeEconomicGuild, 1, 1, 1, "Gold",
                    "+5% Pierce Armor for self",
                    "+5% Pierce Armor for self",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantDeadBush, cUnitTypeEconomicGuild, 1, 2, 1, "Gold",
                    "+5% Crush Armor for self",
                    "+5% Crush Armor for self",
                    "resources\\in_game\\stat_crush_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorCrush, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

void addTempleCommands() {
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypePlantDeadShrub, cUnitTypeTemple, 0, 0, 10, "Gold",
                    "+1 Sentinel God Power",
                    "+1 Sentinel God Power",
                    "resources\\greek\\static_color\\god_powers\\sentinel_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerSentinel), 1, 60);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantDeadGrass, cUnitTypeTemple, 0, 1, 10, "Gold",
                    "+1 Solar Shield God Power",
                    "+1 Solar Shield God Power",
                    "resources\\japanese\\static_color\\god_powers\\solar_shield_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerSolarShield), 1, 60);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantDeadWeeds, cUnitTypeTemple, 0, 2, 10, "Gold",
                    "+1 Tailwind God Power",
                    "+1 Tailwind God Power",
                    "aztec\\static_color\\god_powers\\tailwind_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerTailwind), 1, 60);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantDeadFern, cUnitTypeTemple, 0, 3, 10, "Gold",
                    "+1 Earth Wall God Power",
                    "+1 Earth Wall God Power",
                    "resources\\chinese\\static_color\\god_powers\\earth_wall_power_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerEarthWall), 1, 60);
                        increaseCommandCost(unitId, 1.0);
                    }
                );

        addCommand(p, cUnitTypePlantHadesBush, cUnitTypeTemple, 1, 0, 20, "Gold",
                    "+1 Restoration God Power",
                    "+1 Restoration God Power",
                    "resources\\greek\\static_color\\god_powers\\restoration_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerRestoration), 1, 120);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantHadesShrub, cUnitTypeTemple, 1, 1, 20, "Gold",
                    "+1 Bronze God Power",
                    "+1 Bronze God Power",
                    "resources\\greek\\static_color\\god_powers\\bronze_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerBronze), 1, 120);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantHadesWeeds, cUnitTypeTemple, 1, 2, 20, "Gold",
                    "+1 Vanish God Power",
                    "+1 Vanish God Power",
                    "resources\\chinese\\static_color\\god_powers\\vanish_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerVanish), 1, 120);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantHadesFern, cUnitTypeTemple, 1, 3, 20, "Gold",
                    "+1 Forest Protection God Power",
                    "+1 Forest Protection God Power",
                    "chinese\\static_color\\god_powers\\forest_protection_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerForestProtection), 1, 120);
                        increaseCommandCost(unitId, 1.0);
                    }
                );

        addCommand(p, cUnitTypePlantTundraBush, cUnitTypeTemple, 2, 0, 30, "Gold",
                    "+1 Underworld Passage God Power",
                    "+1 Underworld Passage God Power",
                    "resources\\greek\\static_color\\god_powers\\underworld_passage_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerUnderworldPassage), 1, 180);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantTundraShrub, cUnitTypeTemple, 2, 1, 30, "Gold",
                    "+1 Lullaby God Power",
                    "+1 Lullaby God Power",
                    "aztec\\static_color\\god_powers\\lullaby_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerLullaby), 1, 180);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypePlantTundraGrass, cUnitTypeTemple, 2, 2, 30, "Gold",
                    "+1 Thunder Burst God Power",
                    "+1 Thunder Burst God Power",
                    "japanese\\static_color\\god_powers\\thunder_burst_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trGodPowerGrant(p, kbGodPowerGetName(cProtoPowerThunderBurst), 1, 180);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

void addAllCommands() {
    addArmoryCommands();
    addSiegeCommands();
    addEconomicGuildCommands();
    addTempleCommands();
}