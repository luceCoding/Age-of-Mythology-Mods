// Counts human players on team 1 who are not defeated/resigned and whose human unit is still alive.
int countLivingHumanPlayers(){
    int count = 0;
    for (int i = 0; i < g_humanUnitIDs.size(); i++){
        int unitId = g_humanUnitIDs[i];
        int p = kbUnitGetPlayerID(unitId);
        if (g_finalTeams[p] != 1 || trPlayerIsDefeatedOrResigned(p)){
            continue;
        }
        selectSingle(unitId);
        if (trUnitDead() == false){
            count++;
        }
    }
    return count;
}

void addTrainBuilding(string targetProto = "", int cUnitType = -1, int p = -1, int row = 0, int col = 0, int buildLimit = 1){
    trProtounitAddTrain(targetProto, p, kbProtoUnitGetName(cUnitType), row, col);
    trModifyProtounitActionUnitType(targetProto, "Build", kbUnitTypeGetName(cUnitTypeBuilding), p, cXSActionProtoEffectWorkRate, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitType), p, cXSProtoEffectBuildLimit, buildLimit, cXSRelativityAssign);
    trUnforbidProtounit(p, kbProtoUnitGetName(cUnitType));
}

void applyForAllZombies(int p = -1, int zombieType = -1){
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(zombieType), kbUnitTypeGetName(cUnitTypeLogicalTypeValidShiftingSandsTarget), true);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(zombieType), kbUnitTypeGetName(cUnitTypeAbstractSiegeShip), true);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(zombieType), kbUnitTypeGetName(cUnitTypeLogicalTypeDivineImmunity), false);
    trProtoUnitSetFlag(p, kbProtoUnitGetName(zombieType), "KnockoutDeath", false);
    trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Wood", p, cXSPUResourceEffectKillReward, trashZombieKillRewardWood, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Gold", p, cXSPUResourceEffectKillReward, trashZombieKillRewardGold, cXSRelativityAssign);
    trProtoUnitActionSetEnabled(kbProtoUnitGetName(zombieType), p, "Pickup", false);
}

void setupTrainableZombies(int p = -1, ref TrainableUnitData[] trainables, float scaleFactor = 1.0) {
    for (int i = 0; i < trainables.size(); i++) {
        TrainableUnitData unitData = trainables[i];
        trModifyProtounitData(kbProtoUnitGetName(unitData.unitType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
        applyForAllZombies(p, unitData.unitType);
    }
}

void setupZombiesPost(){

    float scaleFactor = g_director.getTeamSizeScale(g_zombieUnitCount, g_humanUnitCount);

    for (int p = 1; p <= cNumberPlayers-1; p++){

        if (g_finalTeams[p] != 2) { continue; }

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWellOfUrd), "AbstractTemple", true);
        trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Unit", p, cXSPUUnitTypeEffectAddNotContainType, 0.0, cXSRelativityAssign);
        trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "LogicalTypePickable", p, cXSPUUnitTypeEffectAddContainType, g_trashZombieTypes.size()-1, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectMaxContained, g_trashZombieTypes.size()-1, cXSRelativityAssign);
        trProtounitAddCommand(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, "Delete", 3, 5);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeWellOfUrd), "Deleteable", true);
        trProtoUnitChangeName(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, "Tomb of the Dead",
            "Periodically spawns zombies. Capture relics to upgrade the tomb. Gain an extra Tomb of the Dead every night.",
            "Periodically spawns zombies. Capture relics to upgrade the tomb. Gain an extra Tomb of the Dead every night.");

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeDwarvenArmory), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost * 1.75, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeDwarvenArmory), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);
        trProtoUnitChangeName(kbProtoUnitGetName(cUnitTypeDwarvenArmory), p, "", "Used to purchase special zombies.", "Used to purchase special zombies.");

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMonumentToGods), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost * 1.75, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToGods), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);
        trProtoUnitChangeName(kbProtoUnitGetName(cUnitTypeMonumentToGods), p, "", "Used to purchase zombie god powers.", "Used to purchase zombie god powers.");

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeNidhogg), p, cXSProtoEffectHitpoints, 0.15, cXSRelativityPercent);

        trGodPowerRedefine(p, "MeteorSPC", "resources\egyptian\static_color\god_powers\meteor_icon.png", "Comet", "Rains down a single meteor. Does bonus damage to walls.");
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", p, cXSActionEffectDamageDivine, 0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", p, cXSActionEffectDamageCrush, 580, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", kbUnitTypeGetName(cUnitTypeWallShort), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", kbUnitTypeGetName(cUnitTypeWallMedium), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", kbUnitTypeGetName(cUnitTypeWallLong), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", kbUnitTypeGetName(cUnitTypeWallConnector), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", kbUnitTypeGetName(cUnitTypeWallGate), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeMeteorSPC), "HandAttack", p, cXSActionEffectDamageCrush, 0.5, cXSRelativityPercent);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeVolcanoMeteor), "HandAttack", p, cXSActionEffectDamageDivine, 0, cXSRelativityAssign);

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeUndermineDamage), "HandAttack", p, cXSActionEffectDamageCrush, 0.5, cXSRelativityBasePercent);

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeCarnivora), "HandAttack", p, cXSActionEffectDamageCrush, 25, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeCarnivora), p, cXSProtoEffectArmorPierce, 0.9, cXSRelativityAssign);

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeInfestedDen), p, cXSProtoEffectLifespan, cMaxFloat, cXSRelativityAssign);

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMictlantecuhtli), p, cXSProtoEffectTrainPoints, 45.0, cXSRelativityAssign);

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeNidhogg), p, cXSProtoEffectPopulationCount, 4.0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeNidhogg), p, cXSProtoEffectTrainPoints, 45.0, cXSRelativityAssign);

        for (int i = 0; i < g_zombieUnitTypes.size(); i++) {
            int zombieType = g_zombieUnitTypes[i];
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeWellOfUrd, p, 0, 2, 0);
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeDwarvenArmory, p, 0, 3, 1);
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeMonumentToGods, p, 0, 4, 1);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopCapAddition, g_humanUnitCount / g_zombieUnitCount * 20, cXSRelativityAssign);
            trProtounitModifySpawnData(kbProtoUnitGetName(zombieType), p, kbProtoUnitGetName(cUnitTypeCinematicBlockSpawnPoint), 0, 1.0, cXSRelativityAssign, -1, -1);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, g_humanUnitCount+1, cXSRelativityPercent);
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectRange, 10.0, cXSRelativityAssign);
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(zombieType), p, "RangedAttackMyth", false);
            applyForAllZombies(p, zombieType);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Gold", p, cXSPUResourceEffectKillReward, cNumberPlayers, cXSRelativityAssign);
            trProtoUnitSetUnitType(p, kbProtoUnitGetName(zombieType), kbUnitTypeGetName(cUnitTypeLogicalTypeValidShiftingSandsTarget), false);
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(zombieType), p, "Pickup", true);
        }

        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int zombieType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopulationCount, 0, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cMaxFloat, cXSRelativityAssign);
            if (i == 0){
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor * g_firstTrashZombieScaleFactor, cXSRelativityPercent);
            }
            else {
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            }
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageCrush, i * 2, cXSRelativityAssign);
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageCrush, i * 2, cXSRelativityAssign);
            applyForAllZombies(p, zombieType);
        }
        setupTrainableZombies(p, g_zombieT1Trainables, scaleFactor);
        setupTrainableZombies(p, g_zombieT2Trainables, scaleFactor);
        setupTrainableZombies(p, g_zombieT3Trainables, scaleFactor);
        setupTrainableZombies(p, g_zombieT4Trainables, scaleFactor);
        for (int i = 0; i < g_otherZombieTypes.size(); i++) {
            int zombieType = g_otherZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            applyForAllZombies(p, zombieType);
        }

        for (int i = 0; i < g_zombieT1GodPowers.size(); i++) {
            GodPowerData godPower = g_zombieT1GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_zombieT2GodPowers.size(); i++) {
            GodPowerData godPower = g_zombieT2GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_zombieT3GodPowers.size(); i++) {
            GodPowerData godPower = g_zombieT3GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_zombieT4GodPowers.size(); i++) {
            GodPowerData godPower = g_zombieT4GodPowers[i];
            godPower.redefineGodPower(p);
        }

    }
}

int spawnZombieLord(int p = -1, vector v = cInvalidVector){
    int zombieId = trUnitCreateForced(
        kbProtoUnitGetName(g_zombieUnitTypes[0]),
        v.x, v.y, v.z,
        0, p);
    trModifyProtounitData(kbProtoUnitGetName(g_zombieUnitTypes[0]), p, cXSProtoEffectHitpoints, 1.1, cXSRelativityPercent);
    selectSingle(zombieId);
    trUnitMakeInvulnerable(true);
    lowFreqSchedulerWithIntInt.add(120000, zombieId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
        selectSingle(unitID);
        trUnitMakeInvulnerable(false);
        return trUnitAlive();
    });
    trUnitChangeName("Zombie Overlord");
    g_zombieUnitIDs.add(zombieId);
    if (trCurrentPlayer() == p){
        cameraLookAt(v, 60.0, 45.0, 45.0);
    }
    return zombieId;
}

int createZombieLord(int p = -1, vector v = cInvalidVector){
    int zombieId = spawnZombieLord(p, v);
    convertCommandsToZombie(p);
    return zombieId;
}

void permaBuffAZombie(int zombieType = -1, int p = -1, float finalHPBuff = 0){
    // trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 10.0, cXSRelativityAbsolute);
    trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageHack, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamagePierce, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageCrush, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageDivine, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageHack, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamagePierce, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageCrush, 1.01, cXSRelativityPercent);
    trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageDivine, 1.01, cXSRelativityPercent);
}

void permaBuffTrainableZombies(int p = -1, ref TrainableUnitData[] trainables, float finalHPBuff = 0.0) {
    for (int i = 0; i < trainables.size(); i++) {
        TrainableUnitData unitData = trainables[i];
        permaBuffAZombie(unitData.unitType, p, finalHPBuff);
    }
}

void permaDailyBuffZombies(){

    float finalHPBuff = max(g_director.processEndOfDay(), 1.0 + (max(xsIntToFloat(countLivingHumanPlayers()), 1.0) / 100));
    for (int p = 1; p < cNumberPlayers; p++) {
        if (g_finalTeams[p] == 2){
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
            for (int i = 0; i < g_trashZombieTypes.size(); i++) {
                permaBuffAZombie(g_trashZombieTypes[i], p, finalHPBuff);
            }
            permaBuffTrainableZombies(p, g_zombieT1Trainables, finalHPBuff);
            permaBuffTrainableZombies(p, g_zombieT2Trainables, finalHPBuff);
            permaBuffTrainableZombies(p, g_zombieT3Trainables, finalHPBuff);
            permaBuffTrainableZombies(p, g_zombieT4Trainables, finalHPBuff);
            for (int i = 0; i < g_zombieUnitTypes.size(); i++) {
                int zombieType = g_zombieUnitTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
                trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageDivine, max(1, g_humanUnitCount), cXSRelativityAbsolute);
                trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageDivine, max(1, g_humanUnitCount), cXSRelativityAbsolute);
            }
            for (int i = 0; i < g_otherZombieTypes.size(); i++) {
                int zombieType = g_otherZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
        }
    }
}

void setTrainableZombieRegen(int p = -1, ref TrainableUnitData[] trainables, float regen = 0.0) {
    for (int i = 0; i < trainables.size(); i++) {
        TrainableUnitData unitData = trainables[i];
        trModifyProtounitData(kbProtoUnitGetName(unitData.unitType), p, cXSProtoEffectUnitRegenRate, regen, cXSRelativityAssign);
    }
}

void onDayStartZombies(){
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int zombieType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectUnitRegenRate, -g_dayNumber*2, cXSRelativityAssign);
        }
        setTrainableZombieRegen(p, g_zombieT1Trainables, -g_dayNumber*2);
        setTrainableZombieRegen(p, g_zombieT2Trainables, -g_dayNumber*2);
        setTrainableZombieRegen(p, g_zombieT3Trainables, -g_dayNumber*2);
        setTrainableZombieRegen(p, g_zombieT4Trainables, -g_dayNumber*2);
        for (int i = 0; i < g_otherZombieTypes.size(); i++) {
            int zombieType = g_otherZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectUnitRegenRate, -g_dayNumber*2, cXSRelativityAssign);
        }
    }
}

void onNightStartZombies(){
    if (g_dayNumber > 1){
        permaDailyBuffZombies();
    }
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int zombieType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectUnitRegenRate, 0, cXSRelativityAssign);
        }
        setTrainableZombieRegen(p, g_zombieT1Trainables, 0);
        setTrainableZombieRegen(p, g_zombieT2Trainables, 0);
        setTrainableZombieRegen(p, g_zombieT3Trainables, 0);
        setTrainableZombieRegen(p, g_zombieT4Trainables, 0);
        for (int i = 0; i < g_otherZombieTypes.size(); i++) {
            int zombieType = g_otherZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectUnitRegenRate, 0, cXSRelativityAssign);
        }
    }
}

// Returns a random living human unit, or -1 if none (dead ones are pruned).
int getRandomLivingHumanPlayer(){
    if (g_humanUnitIDs.size() == 0) {
        return -1;
    }
    int rdmIdx = xsRandInt(0, g_humanUnitIDs.size() - 1);
    int humanID = g_humanUnitIDs[rdmIdx];
    selectSingle(humanID);
    if (trUnitDead()){
        g_humanUnitIDs.removeIndex(rdmIdx);
        return -1;
    }
    return kbUnitGetPlayerID(humanID);
}

int getRandomAliveBuilding(){
    int p = getRandomLivingHumanPlayer();
    return g_towerTracker.getRandomPlayerBuildingId(p);
}

// Spawns a minion at the zombie unit's position, owned by the zombie's player.
int createTrashMinion(int unitID = -1, int minionTier = 0){
    if (g_isNight == false && g_dayNumber == 1) {
        return -1;
    }

    int p = kbUnitGetPlayerID(unitID);
    vector zombiePos = kbUnitGetTruePosition(unitID);
    int minionType = g_trashZombieTypes[minionTier];
    int minionId = trUnitCreate(kbProtoUnitGetName(minionType), zombiePos.x, zombiePos.y, zombiePos.z, xsRandInt(0, 359), p);
    if (g_isNight == true && (g_dayNumber % bloodMoonCycle == 0)){
        float duration = g_nightDurationMS / 1000;
        selectSingle(minionId);
        trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeHack, 2, duration);
        trUnitAddModifier(cModifyTypeDamage, cXSDamageTypePierce, 2, duration);
        trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeCrush, 2, duration);
        trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeDivine, 2, duration);
        trUnitApplyEffectProtoUnit(cOnHitEffectAttach, duration, kbUnitGetPlayerID(minionId), kbProtoUnitGetName(cUnitTypeVFXAbsorbSoulTargetRed));
    }
    return minionId;
}

void orderToAutoAttackUnit(int minionId = -1, int unitId = -1){
    if (minionId == -1 || unitId == -1) { return; }
    vector unitPos = kbUnitGetTruePosition(unitId);
    selectSingle(minionId);
    trUnitMoveToPoint(unitPos.x, unitPos.y, unitPos.z, -1, true, false, 1.0);
}

void endGameAllWin(){
    int[] winners = new int(0, -1);
    for (int p = 1; p <= cNumberPlayers - 1; p++){
        if (kbPlayerIsHuman(p) == true){
            winners.add(p);
        }
    }
    trSetVictoryPlayers(winners);
    trEndGame();
}

void endGameTeamOneWin(){
    int[] winners = new int(0, -1);
    for (int p = 1; p <= cNumberPlayers - 1; p++){
        if (g_finalTeams[p] == 1){
            winners.add(p);
        }
    }
    trSetVictoryPlayers(winners);
    trEndGame();
}

void endGameTeamTwoWin(){
    int[] winners = new int(0, -1);
    for (int p = 1; p <= cNumberPlayers - 1; p++){
        if (g_finalTeams[p] == 2){
            winners.add(p);
        }
    }
    trSetVictoryPlayers(winners);
    trEndGame();
}

void registerZombieRespawn(int player = -1){
    g_OnCreationListener.register(player, cUnitTypeCinematicBlockSpawnPoint, true, [](int unitId = -1) -> void {
            int p = kbUnitGetPlayerID(unitId);
            if (g_finalTeams[p] == 1){
                if (countLivingHumanPlayers() == 0) {
                    endGameTeamTwoWin();
                    return;
                }
                trChatSend(0, kbPlayerGetName(p) + " has been defeated!\n" + toForwardSlash(displayCompensatedIcon(128, 128, "resources/egyptian/static_color/abilities/mummy_ability_icon.png")));
                g_humanUnitCount = g_humanUnitCount - 1;
                g_zombieUnitCount = g_zombieUnitCount + 1;
                trPlayerKillAllGodPowers(p);
            }
            if (trPlayerIsDefeatedOrResigned(p)){
                return;
            }
            if (g_finalTeams[p] == 2) {
                spawnZombieLord(p, g_bspZombieSpawnLocation);
            }
        }
    );
}

void initializeZombies(){

    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_zombieUnitTypes.size(); i = i + 1) {
            int zombieType = g_zombieUnitTypes[i];
            g_OnCreationListener.register(p, zombieType, false, [](int unitId = -1) -> void {
                lowFreqSchedulerWithIntInt.add(cTrashZombieSpawnTimer, unitId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                    int p = kbUnitGetPlayerID(unitID);
                    selectSingle(unitID);
                    if (trUnitDead() || trPlayerIsDefeatedOrResigned(p)) {
                        return false;
                    }

                    int minionId = createTrashMinion(unitID);
                    if (minionId != -1){
                        int buildingId = getRandomAliveBuilding();
                        orderToAutoAttackUnit(minionId, buildingId);
                    }

                    return true;
                });
            });
        }
        g_OnCreationListener.register(p, cUnitTypeWellOfUrd, false, [](int unitId = -1) -> void {
            lowFreqSchedulerWithIntInt.add(cTrashZombieSpawnTimer, unitId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                selectSingle(unitID);
                if (trUnitPercentComplete() < 100){
                    return true;
                }

                int p = kbUnitGetPlayerID(unitID);
                if (trUnitDead() || trPlayerIsDefeatedOrResigned(p)) {
                    return false;
                }

                int minionId = createTrashMinion(unitID, kbUnitGetNumberContained(unitID));
                if (minionId != -1){
                    int buildingId = getRandomAliveBuilding();
                    orderToAutoAttackUnit(minionId, buildingId);
                }

                return true;
            });
        });
    }

    for (int sidePosition = 0; sidePosition < 2;
         sidePosition = sidePosition + 1) {
        float sideOffset = (xsIntToFloat(sidePosition) * 6.0) - 3.0;
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeWallJail),
            g_bspZombieSpawnLocation.x + sideOffset,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z - 6.0,
            0.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeWallJail),
            g_bspZombieSpawnLocation.x + sideOffset,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + 6.0,
            0.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeWallJail),
            g_bspZombieSpawnLocation.x - 6.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeWallJail),
            g_bspZombieSpawnLocation.x + 6.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x + sideOffset,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z - 9.0,
            0.0, 0);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x + sideOffset,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + 9.0,
            0.0, 0);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x - 9.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, 0);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x + 9.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, 0);
    }

    if (g_zombieUnitTypes.size() == 0) {
        errorLog("Cannot spawn the zombie players: no zombie unit types are configured.");
        return;
    }

    int spawnIndex = 0;
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] != 2 || kbPlayerIsHuman(p) == false) {
            continue;
        }
        g_zombieUnitCount = g_zombieUnitCount + 1;

        float offsetX = (xsIntToFloat(spawnIndex % 4) - 1.5) * 2.0;
        float offsetZ = xsIntToFloat(spawnIndex / 4) * 2.0;
        createZombieLord(p, vector(
            g_bspZombieSpawnLocation.x + offsetX,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + offsetZ));
        registerZombieRespawn(p);
        addWellOfUrdCommands(p);
        spawnIndex = spawnIndex + 1;
    }
}