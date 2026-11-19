IntToIntcMinIntHashMap cPlantToCooldownHashMap;
IntToIntcMinIntHashMap cPlantToUnitTypeHashMap;
IntToIntcMinIntHashMap g_unitTypeToCostHashMap;

int getCommadCostKey(int p = 1, int protoId = -1) {
    return p * cNumberProtoUnits + protoId;
}

int addCommandWrapper(int p = 1, int targetProtoType = -1, int row = 0, int col = 0,
                    float initialCost = 0.0,
                    string resource = "", string name = "", string description = "", string icon = "", 
                    void(int) event = [](int unitId = -1) -> void {}) {
                        int plantType = addCommand(p, targetProtoType, row, col, initialCost, resource, name, description, icon, event);
                        g_unitTypeToCostHashMap.put(getCommadCostKey(p, plantType), initialCost);
                        return plantType;
                    }

// Raises the stored cost of the command for this player and applies it to the protounit.
void increaseCommandCost(int unitId = -1, float increment = 1.0) {
    int p = kbUnitGetPlayerID(unitId);
    int protoId = kbUnitGetProtoUnitID(unitId);
    int key = getCommadCostKey(p, protoId);
    int newCost = g_unitTypeToCostHashMap.get(key) + increment;
    g_unitTypeToCostHashMap.put(key, newCost);
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

void addArmoryCommands(){
    for (int p = 1; p <= cNumberPlayers; p++) {
        addCommandWrapper(p, cUnitTypeArmory, 0, 0, pow(humanBaseGoldCost, 1), "Gold",
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
        addCommandWrapper(p, cUnitTypeArmory, 0, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "-2% Rate of Fire for All Buildings",
                    "-2% Rate of Fire for All Buildings",
                    "resources\\in_game\\stat_rof.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectROF, 0.98, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeArmory, 0, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Range for All Buildings",
                    "+5% Range for All Buildings",
                    "resources\\in_game\\stat_range.png",
                    [](int unitId = -1) -> void {
                        applyActionUpgradeToAllHumanBuildings(unitId, cXSActionEffectRange, 1.05, cXSRelativityPercent);
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectLOS, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeArmory, 1, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Hack Armor for All Buildings",
                    "+5% Hack Armor for All Buildings",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeArmory, 1, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Pierce Armor for All Buildings",
                    "+5% Pierce Armor for All Buildings",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeArmory, 1, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Crush Armor for All Buildings",
                    "+5% Crush Armor for All Buildings",
                    "resources\\in_game\\stat_crush_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectArmorCrush, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeArmory, 1, 3, pow(humanBaseGoldCost, 1), "Gold",
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
        addCommandWrapper(p, cUnitTypeSiegeWorks, 0, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+1 Watch Tower",
                    "Standard defensive tower. Does not increase in cost. Does not increase in cost with each purchase.",
                    "resources\\shared\\static_color\\buildings\\sentry_tower_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSentryTower));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 0.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 0, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+1 Smoke Trap",
                    "Reduces enemy visibility and speed. Does not increase in cost with each purchase.",
                    "resources\\aztec\\static_color\\buildings\\smoke_trap_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSmokeTrap));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSmokeTrap), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 0.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 0, 2, pow(humanBaseGoldCost, 2), "Gold",
                    "+1 Laser Tower",
                    "Good against walls and buildings. Increases in cost with each purchase.",
                    "resources\\atlantean\\static_color\\buildings\\mirror_tower_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeMirrorTower));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMirrorTower), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 1, 0, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Sky Passage",
                    "Allows units to travel between sky passages. Increases in cost with each purchase.",
                    "resources\\atlantean\\static_color\\buildings\\sky_passage_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSkyPassage));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSkyPassage), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 1, 1, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Spike Trap",
                    "Damages and stuns nearby enemies. Increases in cost with each purchase.",
                    "resources\\aztec\\static_color\\buildings\\spike_trap_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSpikeTrap));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSpikeTrap), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 1, 2, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Rock Tower",
                    "High health defensive melee tower, applies taunt to nearby enemies. Increases in cost with each purchase.",
                    "resources\\norse_freyr\\player_color\\units\\rock_giant_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeRockGiant));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 1, 3, pow(humanBaseGoldCost, 3), "Gold",
                    "+1 Flame Tower",
                    "Short ranged AOE tower, applies burning onto its targets. Increases in cost with each purchase.",
                    "resources\\japanese\\player_color\\units\\wanyudo_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWanyudo));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWanyudo), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 2, 0, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 Frost fort",
                    "Long ranged fort, applies freeze onto its targets. Increases in cost with each purchase.",
                    "resources\\norse_freyr\\static_color\\buildings\\asgardian_hill_fort_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeHillFort));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeHillFort), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 2, 1, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 Lightning tower",
                    "Good against myth units, attacks bounce up to three times. Increases in cost with each purchase.",
                    "resources\\spc\\static_color\\buildings\\statue_major_god_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeStatueOfLightning));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 2, 2, pow(humanBaseGoldCost, 4), "Gold",
                    "+1 Ward tower",
                    "Blocks god powers. Increases in cost with each purchase.",
                    "resources\\egyptian\\static_color\\buildings\\monument_to_villagers_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeMonumentToVillagers));
                        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToVillagers), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeSiegeWorks, 3, 0, pow(humanBaseGoldCost, 5), "Gold",
                    "+1 Water tower",
                    "Moderate ranged tower, applies AOE stun onto its targets. Increases in cost with each purchase.",
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
        addCommandWrapper(p, cUnitTypeEconomicGuild, 0, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Build Speed for self",
                    "+5% Build Speed for self",
                    "resources\\shared/hud\\command\\military_camp_build_right_icon.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanBuildings(unitId, cXSProtoEffectBuildPoints, 0.95, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeEconomicGuild, 0, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Movement Speed for self",
                    "+5% Movement Speed for self",
                    "resources\\in_game\\stat_speed.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectSpeed, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 2.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeEconomicGuild, 0, 2, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Health for self",
                    "+5% Health for self",
                    "resources\\in_game\\stat_hp.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectHitpoints, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeEconomicGuild, 1, 0, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Hack Armor for self",
                    "+5% Hack Armor for self",
                    "resources\\in_game\\stat_hack_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorHack, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeEconomicGuild, 1, 1, pow(humanBaseGoldCost, 1), "Gold",
                    "+5% Pierce Armor for self",
                    "+5% Pierce Armor for self",
                    "resources\\in_game\\stat_pierce_armor.png",
                    [](int unitId = -1) -> void {
                        applyDataUpgradeToAllHumanTypes(unitId, cXSProtoEffectArmorPierce, 1.05, cXSRelativityPercent);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        addCommandWrapper(p, cUnitTypeEconomicGuild, 1, 2, pow(humanBaseGoldCost, 1), "Gold",
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
        int plantType = addCommandWrapper(p, building, row, i, initialCost, "Gold",
                    "+1 " + powerName + " God Power", gpData.description, gpData.icon,
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        int key = getCommadCostKey(p, kbUnitGetProtoUnitID(unitId));
                        int power = cPlantToUnitTypeHashMap.get(key);
                        trGodPowerGrant(p, kbGodPowerGetName(power), 1, cPlantToCooldownHashMap.get(key));
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        if (plantType != -1) {
            int key = getCommadCostKey(p, plantType);
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
        int plantType = addCommandWrapper(p, cUnitTypeDwarvenArmory, row, i, unitData.initialCost, "Gold",
                    unitData.name,
                    unitData.description,
                    unitData.icon,
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        int key = getCommadCostKey(p, kbUnitGetProtoUnitID(unitId));
                        string zombieName = kbProtoUnitGetName(cPlantToUnitTypeHashMap.get(key));
                        trUnforbidProtounit(p, zombieName);
                        trModifyProtounitData(zombieName, p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
                        increaseCommandCost(unitId, 1.0);
                    }
                );
        if (plantType != -1) {
            cPlantToUnitTypeHashMap.put(getCommadCostKey(p, plantType), zombieType);
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