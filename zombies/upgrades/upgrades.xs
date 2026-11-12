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
        trModifyProtounitAction(kbProtoUnitGetName(buildingType), "BeamAttack", p, actionEffect, delta, relativity);
        trModifyProtounitAction(kbProtoUnitGetName(buildingType), "MonolithStrike", p, actionEffect, delta, relativity);
    }
}

void applyDataUpgradeToAllHumanBuildings(int unitId = -1, int puField = cXSProtoEffectHitpoints, float delta = 1.0, int relativity = cXSRelativityAbsolute) {
    int p = kbUnitGetPlayerID(unitId);
    for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        int buildingType = g_upgradeableHumanBuildings[i];
        trModifyProtounitData(kbProtoUnitGetName(buildingType), p, puField, delta, relativity);
    }
    if (puField == cXSProtoEffectLOS){
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToVillagers), p, cXSProtoEffectGodPowerBlockRadius, delta, cXSRelativityPercent);
    }
}

void applyDataUpgradeToAllHumanTypes(int unitId = -1, int puField = cXSProtoEffectHitpoints, float delta = 1.0, int relativity = cXSRelativityAbsolute) {
    int p = kbUnitGetPlayerID(unitId);
    for (int i = 0; i < g_humanUnitTypes.size(); i++) {
        int unitType = g_humanUnitTypes[i];
        trModifyProtounitData(kbProtoUnitGetName(unitType), p, puField, delta, relativity);
    }
}

// Hands out plant protounits (cUnitTypePlantGreekBush..cUnitTypePlantAtlanteanFern) as command carriers.
// Each player gets their own sequence; releasing a player's plants lets zombie commands reuse the same set.
class PlantAllocator {
    int m_maxPlants = 0;
    int[] m_counts = default;
    int[] m_targets = default; // Building each allocated plant was added to, indexed by p * m_maxPlants + slot

    void ensureInitialised() {
        if (m_counts.size() == 0) {
            m_maxPlants = cUnitTypePlantAtlanteanFern - cUnitTypePlantGreekBush + 1;
            m_counts = new int(cNumberPlayers + 1, 0);
            m_targets = new int((cNumberPlayers + 1) * m_maxPlants, -1);
        }
    }

    int allocate(int p = 1, int targetProtoType = -1) {
        ensureInitialised();
        int slot = m_counts[p];
        if (slot >= m_maxPlants) {
            errorLog("No free command plants left for player " + p);
            return -1;
        }
        m_targets[p * m_maxPlants + slot] = targetProtoType;
        m_counts[p] = slot + 1;
        return cUnitTypePlantGreekBush + slot;
    }

    // Removes the listeners and train slots of every plant allocated to this player and frees them.
    void releaseAll(int p = 1) {
        ensureInitialised();
        for (int slot = 0; slot < m_counts[p]; slot++) {
            int plantType = cUnitTypePlantGreekBush + slot;
            g_OnCreationListener.deregisterAll(p, plantType);
            trProtounitRemoveTrain(kbProtoUnitGetName(m_targets[p * m_maxPlants + slot]), p, kbProtoUnitGetName(plantType));
        }
        m_counts[p] = 0;
    }
};

PlantAllocator g_PlantAllocator;

// Allocates a plant for the command, registers it, and returns the plant type used.
int addCommand(int p = 1, int targetProtoType = -1, int row = 0, int col = 0,
                    float initialCost = 0.0,
                    string resource = "", string name = "", string description = "", string icon = "", 
                    void(int) event = [](int unitId = -1) -> void {}) {

    int plantType = g_PlantAllocator.allocate(p, targetProtoType);
    if (plantType == -1) {
        return -1;
    }
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
    trModifyProtounitData(plantName, p, cXSProtoEffectBuildLimit, 1, cXSRelativityAssign);
    cUnitTypeToCostHashMap.put(getCostKey(p, plantType), initialCost);
    return plantType;
}

void addArmoryCommands(){
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypeArmory, 0, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Attack for All Buildings",
                    "+5% Attack for All Buildings",
                    "resources\\in_game\\stat_pierce_dmg.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageHack, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamagePierce, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageCrush, 1.05, cXSRelativityPercent);
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectDamageDivine, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 0, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "-5% Rate of Fire for All Buildings",
                    "-5% Rate of Fire for All Buildings",
                    "resources\\in_game\\stat_rof.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectROF, 0.95, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 0, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Range for All Buildings",
                    "+5% Range for All Buildings",
                    "resources\\in_game\\stat_range.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectRange, 1.05, cXSRelativityPercent);
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectLOS, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 1, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Hack Armor for All Buildings",
                    "+5% Hack Armor for All Buildings",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 1, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Pierce Armor for All Buildings",
                    "+5% Pierce Armor for All Buildings",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 1, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Crush Armor for All Buildings",
                    "+5% Crush Armor for All Buildings",
                    "resources\\in_game\\stat_crush_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorCrush, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeArmory, 1, 3, pow(humanBaseGoldCost, 1), "Gold",
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
        addCommand(p, cUnitTypeSiegeWorks, 0, 0, pow(humanBaseGoldCost, 2), "Gold",
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
        addCommand(p, cUnitTypeSiegeWorks, 0, 1, pow(humanBaseGoldCost, 2), "Gold",
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
        addCommand(p, cUnitTypeSiegeWorks, 0, 2, pow(humanBaseGoldCost, 2), "Gold",
                    "+1 Mirror Tower",
                    "+1 Mirror Tower",
                    "resources\\atlantean\\static_color\\buildings\\mirror_tower_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeMirrorTower));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMirrorTower), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 1, 0, pow(humanBaseGoldCost, 3), "Gold",
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
        addCommand(p, cUnitTypeSiegeWorks, 1, 1, pow(humanBaseGoldCost, 3), "Gold",
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
        addCommand(p, cUnitTypeSiegeWorks, 1, 2, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Rock Tower",
                    "Highly armored tower with a taunt ability",
                    "resources\\norse_freyr\\player_color\\units\\rock_giant_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeRockGiant));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 1, 3, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Flame Tower",
                    "Breaths a short ranged aoe fire attack",
                    "resources\\japanese\\player_color\\units\\wanyudo_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWanyudo));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWanyudo), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 2, 0, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 Asgardian Hill Fort",
                    "Fortress that applies a progressive freeze",
                    "resources\\norse_freyr\\static_color\\buildings\\asgardian_hill_fort_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeHillFort));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeHillFort), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 2, 1, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 God Power Blocker",
                    "Blocks god powers in its vicinity, its range is upgradeable",
                    "resources\\egyptian\\static_color\\buildings\\monument_to_villagers_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeMonumentToVillagers));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToVillagers), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 2, 2, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 Statue of Lightning",
                    "Good against myth units",
                    "resources\\spc\\static_color\\buildings\\statue_major_god_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeStatueOfLightning));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeSiegeWorks, 3, 0, pow(humanBaseGoldCost, 5), "Gold",
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
    }
}

void addEconomicGuildCommands(){
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommand(p, cUnitTypeEconomicGuild, 0, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Build Speed for self",
                    "+5% Build Speed for self",
                    "resources\\shared/hud\\command\\military_camp_build_right_icon.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectBuildPoints, 0.95, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeEconomicGuild, 0, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Movement Speed for self",
                    "+5% Movement Speed for self",
                    "resources\\in_game\\stat_speed.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectSpeed, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommand(p, cUnitTypeEconomicGuild, 0, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Health for self",
                    "+5% Health for self",
                    "resources\\in_game\\stat_hp.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectHitpoints, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeEconomicGuild, 1, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Hack Armor for self",
                    "+5% Hack Armor for self",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeEconomicGuild, 1, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Pierce Armor for self",
                    "+5% Pierce Armor for self",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommand(p, cUnitTypeEconomicGuild, 1, 2, pow(humanBaseGoldCost, 1), "Gold",
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

void addGodPowerTierCommands(int p = -1, int building = -1, ref GodPowerData[] powers, int row = 0, int initialCost = 10) {
    for (int i = 0; i < powers.size(); i++) {
        GodPowerData gpData = powers[i];
        int protoPower = gpData.protoPower;
        string powerName = gpData.name;
        if (powerName == "") {
            powerName = kbGodPowerGetName(protoPower);
        }
        if (gpData.cooldown < 0) {
            errorLog("Missing cooldown for god power " + powerName);
            continue;
        }
        int plantType = addCommand(p, building, row, i, initialCost, "Gold",
                    "+1 " + powerName + " God Power", gpData.description, gpData.icon,
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        int key = getCostKey(p, kbUnitGetProtoUnitID(unitId));
                        int power = cPlantToUnitTypeHashMap.get(key);
                        trGodPowerGrant(p, kbGodPowerGetName(power), 1, cPlantToCooldownHashMap.get(key));
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        if (plantType != -1) {
            int key = getCostKey(p, plantType);
            cPlantToUnitTypeHashMap.put(key, protoPower);
            cPlantToCooldownHashMap.put(key, gpData.cooldown);
        }
    }
}

void addTempleCommands() {
    for (int p = 1; p <= cNumberPlayers; p++) {
        addGodPowerTierCommands(p, cUnitTypeTemple, g_humanT1GodPowers, 0, pow(humanBaseGoldCost, 3));
        addGodPowerTierCommands(p, cUnitTypeTemple, g_humanT2GodPowers, 1, pow(humanBaseGoldCost, 4));
        addGodPowerTierCommands(p, cUnitTypeTemple, g_humanT3GodPowers, 2, pow(humanBaseGoldCost, 5));
        addGodPowerTierCommands(p, cUnitTypeTemple, g_humanT4GodPowers, 3, pow(humanBaseGoldCost, 6));
    }
}

int zombieTrainableRowCapacity(int row = 0) {
    // The Well of Urd's Delete command occupies the last slot of row 3.
    if (row == 3) {
        return 5;
    }
    return 6;
}

void addWellOfUrdTierCommands(int p = -1, ref TrainableUnitData[] trainables, int row = 0, float woodCost = 1.0) {
    for (int i = 0; i < trainables.size(); i++) {
        if (i >= zombieTrainableRowCapacity(row)) {
            errorLog("Too many zombie trainables for the Well of Urd row " + row);
            break;
        }
        TrainableUnitData unitData = trainables[i];
        string zombieName = kbProtoUnitGetName(unitData.unitType);
        trProtounitAddTrain(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, zombieName, row, i);
        trModifyProtounitResource(zombieName, "Wood", p, cXSPUResourceEffectCost, woodCost, cXSRelativityAssign);
        trUnforbidProtounit(p, zombieName);
    }
}

void addWellOfUrdCommands(int p = 0) {
    addWellOfUrdTierCommands(p, g_zombieT1Trainables, 0, 0);
    addWellOfUrdTierCommands(p, g_zombieT2Trainables, 1, 0);
    addWellOfUrdTierCommands(p, g_zombieT3Trainables, 2, 0);
    addWellOfUrdTierCommands(p, g_zombieT4Trainables, 3, 0);
}

// Each command raises the build limit of its zombie type by one.
void addZombieArmoryTierCommands(int p = -1, ref TrainableUnitData[] trainables, int row = 0) {
    for (int i = 0; i < trainables.size(); i++) {
        if (i >= zombieTrainableRowCapacity(row)) {
            errorLog("Too many zombie trainables for the zombie armory row " + row);
            break;
        }
        TrainableUnitData unitData = trainables[i];
        int zombieType = unitData.unitType;
        string zombieName = kbProtoUnitGetName(zombieType);
        trModifyProtounitData(zombieName, p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        int plantType = addCommand(p, cUnitTypeDwarvenArmory, row, i, unitData.initialCost, "Gold",
                    unitData.name,
                    unitData.description,
                    unitData.icon,
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        int key = getCostKey(p, kbUnitGetProtoUnitID(unitId));
                        string zombieName = kbProtoUnitGetName(cPlantToUnitTypeHashMap.get(key));
                        trUnforbidProtounit(p, zombieName);
                        trModifyProtounitData(zombieName, p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        if (plantType != -1) {
            cPlantToUnitTypeHashMap.put(getCostKey(p, plantType), zombieType);
        }
    }
}

// Frees this player's command plants (listeners and train slots) so zombie commands can reuse them.
void deregisterHumanCommands(int p = -1) {
    g_PlantAllocator.releaseAll(p);
}

void addZombieArmoryCommands(int p = -1) {
    addZombieArmoryTierCommands(p, g_zombieT1Trainables, 0);
    addZombieArmoryTierCommands(p, g_zombieT2Trainables, 1);
    addZombieArmoryTierCommands(p, g_zombieT3Trainables, 2);
    addZombieArmoryTierCommands(p, g_zombieT4Trainables, 3);
}


void addZombieGodPowerCommands(int p = -1) {
    addGodPowerTierCommands(p, cUnitTypeMonumentToGods, g_zombieT1GodPowers, 0, pow(humanBaseGoldCost, 3));
    addGodPowerTierCommands(p, cUnitTypeMonumentToGods, g_zombieT2GodPowers, 1, pow(humanBaseGoldCost, 4));
    addGodPowerTierCommands(p, cUnitTypeMonumentToGods, g_zombieT3GodPowers, 2, pow(humanBaseGoldCost, 5));
    addGodPowerTierCommands(p, cUnitTypeMonumentToGods, g_zombieT4GodPowers, 3, pow(humanBaseGoldCost, 6));
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