IntToIntcMinIntHashMap cPlantToCooldownHashMap;
IntToIntcMinIntHashMap cUnitTypeToCostHashMap;
IntToIntcMinIntHashMap cPlantToUnitTypeHashMap;

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
        if (actionEffect != cXSActionEffectRange){
            trModifyProtounitAction(kbProtoUnitGetName(buildingType), "HandAttack", p, actionEffect, delta, relativity);
        }
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

void addWellOfUrdTierCommands(int p = -1, ref int[] zombieTypes, int row = 0, float woodCost = 1.0) {
    for (int i = 0; i < zombieTypes.size(); i++) {
        string zombieName = kbProtoUnitGetName(zombieTypes[i]);
        trProtounitAddTrain(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, zombieName, row, i);
        trModifyProtounitResource(zombieName, "Wood", p, cXSPUResourceEffectCost, woodCost, cXSRelativityAssign);
        trUnforbidProtounit(p, zombieName);
    }
}

void addWellOfUrdCommands(int p = 0) {
    addWellOfUrdTierCommands(p, g_purchaseableT1ZombieTypes, 0, 2.0);
    addWellOfUrdTierCommands(p, g_purchaseableT2ZombieTypes, 1, 4.0);
    addWellOfUrdTierCommands(p, g_purchaseableT3ZombieTypes, 2, 8.0);
}

// Each command raises the build limit of its zombie type by one.
void addZombieArmoryTierCommands(int p = -1, ref int[] zombieTypes, ref int[] plantTypes, int row = 0, int initialCost = 1) {
    for (int i = 0; i < zombieTypes.size(); i++) {
        int zombieType = zombieTypes[i];
        string zombieName = kbProtoUnitGetName(zombieType);
        trModifyProtounitData(zombieName, p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        cPlantToUnitTypeHashMap.put(plantTypes[i], zombieType);
        addCommand(p, plantTypes[i], cUnitTypeDwarvenArmory, row, i, initialCost, "Gold",
                    "+1 " + zombieName,
                    "+1 " + zombieName,
                    kbProtoUnitGetIconPath(0, zombieType),
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        string zombieName = kbProtoUnitGetName(cPlantToUnitTypeHashMap.get(kbUnitGetProtoUnitID(unitId)));
                        trUnforbidProtounit(p, zombieName);
                        trModifyProtounitData(zombieName, p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

// Removes every human command listener for this player so zombie commands can reuse the plant types.
void deregisterHumanCommands(int p = -1) {
    for (int plantType = cUnitTypePlantGreekBush; plantType <= cUnitTypePlantAtlanteanFern; plantType++) {
        g_OnCreationListener.deregisterAll(p, plantType);
    }
}

void addZombieArmoryCommands(int p = -1) {
    int[] t1Plants = new int(0, -1);
    t1Plants.add(cUnitTypePlantAtlanteanBush);
    t1Plants.add(cUnitTypePlantAtlanteanShrub);
    t1Plants.add(cUnitTypePlantAtlanteanGrass);
    t1Plants.add(cUnitTypePlantAtlanteanWeeds);

    int[] t2Plants = new int(0, -1);
    t2Plants.add(cUnitTypePlantAtlanteanFern);
    t2Plants.add(cUnitTypePlantChineseBush);
    t2Plants.add(cUnitTypePlantChineseShrub);
    t2Plants.add(cUnitTypePlantChineseGrass);
    t2Plants.add(cUnitTypePlantChineseWeeds);
    t2Plants.add(cUnitTypePlantChineseFern);

    int[] t3Plants = new int(0, -1);
    t3Plants.add(cUnitTypePlantJapaneseBush);
    t3Plants.add(cUnitTypePlantJapaneseShrub);
    t3Plants.add(cUnitTypePlantJapaneseGrass);
    t3Plants.add(cUnitTypePlantJapaneseWeeds);

    addZombieArmoryTierCommands(p, g_purchaseableT1ZombieTypes, t1Plants, 0, 1);
    addZombieArmoryTierCommands(p, g_purchaseableT2ZombieTypes, t2Plants, 1, 10);
    addZombieArmoryTierCommands(p, g_purchaseableT3ZombieTypes, t3Plants, 2, 20);
}

// Each command grants one charge of its god power; the cost rises with every purchase.
void addZombieGodPowerTierCommands(int p = -1, ref int[] powers, ref string[] icons, ref int[] plantTypes, int row = 0, int initialCost = 10, int cooldown = 60) {
    for (int i = 0; i < powers.size(); i++) {
        int power = powers[i];
        string powerName = kbGodPowerGetName(power);
        cPlantToUnitTypeHashMap.put(plantTypes[i], power);
        cPlantToCooldownHashMap.put(plantTypes[i], cooldown);
        addCommand(p, plantTypes[i], cUnitTypeMonumentToGods, row, i, initialCost, "Gold",
                    "+1 " + powerName + " God Power",
                    "+1 " + powerName + " God Power",
                    icons[i],
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        int power = cPlantToUnitTypeHashMap.get(kbUnitGetProtoUnitID(unitId));
                        trGodPowerGrant(p, kbGodPowerGetName(power), 1, cPlantToCooldownHashMap.get(kbUnitGetProtoUnitID(unitId)));
                        increaseCommandCost(unitId, 1.0);
                    }
                );
    }
}

void addZombieGodPowerCommands(int p = -1) {
    int[] t1Plants = new int(0, -1);
    t1Plants.add(cUnitTypePlantMarshBush);
    t1Plants.add(cUnitTypePlantMarshShrub);
    t1Plants.add(cUnitTypePlantMarshGrass);
    t1Plants.add(cUnitTypePlantMarshWeeds);
    t1Plants.add(cUnitTypePlantMarshFern);
    t1Plants.add(cUnitTypePlantJapaneseFern);

    int[] t2Plants = new int(0, -1);
    t2Plants.add(cUnitTypePlantSnowShrub);
    t2Plants.add(cUnitTypePlantHadesGrass);

    int[] t3Plants = new int(0, -1);
    t3Plants.add(cUnitTypePlantTundraWeeds);
    t3Plants.add(cUnitTypePlantTundraFern);

    addZombieGodPowerTierCommands(p, g_purchaseableT1GodPowers, g_purchaseableT1GodPowerIcons,     t1Plants, 0, 10, 60);
        addZombieGodPowerTierCommands(p, g_purchaseableT2GodPowers, g_purchaseableT2GodPowerIcons, t2Plants, 1, 20, 120);
        addZombieGodPowerTierCommands(p, g_purchaseableT3GodPowers, g_purchaseableT3GodPowerIcons, t3Plants, 2, 30, 180);
}

void convertCommandsToZombie(int p = -1) {
    deregisterHumanCommands(p);
    addZombieArmoryCommands(p);
    addZombieGodPowerCommands(p);
}

void addAllCommands() {
    addArmoryCommands();
    addSiegeCommands();
    addEconomicGuildCommands();
    addTempleCommands();
    //addWellOfUrdCommands();
}