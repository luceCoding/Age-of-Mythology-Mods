void addTrainBuilding(string targetProto = "", int cUnitType = -1, int p = -1, int row = 0, int col = 0, int buildLimit = 1){
    trProtounitAddTrain(targetProto, p, kbProtoUnitGetName(cUnitType), row, col);
    trModifyProtounitActionUnitType(targetProto, "Build", kbUnitTypeGetName(cUnitTypeBuilding), p, cXSActionProtoEffectWorkRate, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitType), p, cXSProtoEffectBuildLimit, buildLimit, cXSRelativityAssign);
    trUnforbidProtounit(p, kbProtoUnitGetName(cUnitType));
}

void setupZombiesPost(){

    float scaleFactor = g_director.getTeamSizeScale(g_zombieUnitCount, g_humanUnitCount);

    for (int p = 1; p <= cNumberPlayers-1; p++){

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWellOfUrd), "AbstractTemple", true);
        trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Unit", p, cXSPUUnitTypeEffectAddNotContainType, 0.0, cXSRelativityAssign);
        trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "LogicalTypePickable", p, cXSPUUnitTypeEffectAddContainType, g_trashZombieTypes.size()-1, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectMaxContained, g_trashZombieTypes.size()-1, cXSRelativityAssign);
        trProtounitAddCommand(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, "Delete", 3, 5);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeWellOfUrd), "Deleteable", true);

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeDwarvenArmory), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost * 1.25, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeDwarvenArmory), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMonumentToGods), "Wood", p, cXSPUResourceEffectCost, baseWellOfUrdWoodCost * 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToGods), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);

        for (int i = 0; i < g_zombieUnitTypes.size(); i++) {
            int zombieType = g_zombieUnitTypes[i];
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeWellOfUrd, p, 0, 2, 0);
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeDwarvenArmory, p, 0, 3, 1);
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeMonumentToGods, p, 0, 4, 1);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopCapAddition, maxZombiePopulation, cXSRelativityAssign);
            trProtounitModifySpawnData(kbProtoUnitGetName(zombieType), p, kbProtoUnitGetName(cUnitTypeSkeleton), 0, 1.0, cXSRelativityAssign, -1, -1);
            trProtoUnitSetFlag(p, kbProtoUnitGetName(zombieType), "KnockoutDeath", false);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Gold", p, cXSPUResourceEffectKillReward, 10, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, g_humanUnitCount+1, cXSRelativityPercent);
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectRange, 10.0, cXSRelativityAssign);
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(zombieType), p, "RangedAttackMyth", false);
        }

        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int zombieType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopulationCount, 0, cXSRelativityAssign);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Wood", p, cXSPUResourceEffectKillReward, trashZombieKillRewardWood, cXSRelativityAssign);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Gold", p, cXSPUResourceEffectKillReward, trashZombieKillRewardGold, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cBaseZombieLifespan, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
        }
        for (int i = 0; i < g_purchaseableT1ZombieTypes.size(); i++) {
            int zombieType = g_purchaseableT1ZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cBaseZombieLifespan, cXSRelativityAssign);
        }
        for (int i = 0; i < g_purchaseableT2ZombieTypes.size(); i++) {
            int zombieType = g_purchaseableT2ZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cBaseZombieLifespan, cXSRelativityAssign);
        }
        for (int i = 0; i < g_purchaseableT3ZombieTypes.size(); i++) {
            int zombieType = g_purchaseableT3ZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cBaseZombieLifespan, cXSRelativityAssign);
        }
        for (int i = 0; i < g_purchaseableT4ZombieTypes.size(); i++) {
            int zombieType = g_purchaseableT4ZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, scaleFactor, cXSRelativityPercent);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, cBaseZombieLifespan, cXSRelativityAssign);
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

void permaDailyBuffZombies(){

    float finalHPBuff = g_director.processEndOfDay();

    for (int p = 1; p < cNumberPlayers; p++) {
        if (g_finalTeams[p] == 2){
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
            for (int i = 0; i < g_trashZombieTypes.size(); i++) {
                int zombieType = g_trashZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 5.0, cXSRelativityAbsolute);
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
            for (int i = 0; i < g_purchaseableT1ZombieTypes.size(); i++) {
                int zombieType = g_purchaseableT1ZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 5.0, cXSRelativityAbsolute);
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
            for (int i = 0; i < g_purchaseableT2ZombieTypes.size(); i++) {
                int zombieType = g_purchaseableT2ZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 5.0, cXSRelativityAbsolute);
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
            for (int i = 0; i < g_purchaseableT3ZombieTypes.size(); i++) {
                int zombieType = g_purchaseableT3ZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 5.0, cXSRelativityAbsolute);
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
            for (int i = 0; i < g_purchaseableT4ZombieTypes.size(); i++) {
                int zombieType = g_purchaseableT4ZombieTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectLifespan, 5.0, cXSRelativityAbsolute);
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
            }
            for (int i = 0; i < g_zombieUnitTypes.size(); i++) {
                int zombieType = g_zombieUnitTypes[i];
                trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, finalHPBuff, cXSRelativityPercent);
                trModifyProtounitAction(kbProtoUnitGetName(zombieType), "HandAttack", p, cXSActionEffectDamageDivine, max(1, g_humanUnitCount), cXSRelativityAbsolute);
                trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageDivine, max(1, g_humanUnitCount), cXSRelativityAbsolute);
            }
        }
    }
}

void onDayStartZombies(){
}

void onNightStartZombies(){
    if (g_dayNumber > 1){
        permaDailyBuffZombies();
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
    int p = kbUnitGetPlayerID(unitID);
    vector zombiePos = kbUnitGetTruePosition(unitID);
    int minionType = g_trashZombieTypes[minionTier];
    return trUnitCreate(kbProtoUnitGetName(minionType), zombiePos.x, zombiePos.y, zombiePos.z, xsRandInt(0, 359), p);
}

void orderToAutoAttackUnit(int minionId = -1, int unitId = -1){
    if (minionId == -1 || unitId == -1) { return; }
    vector unitPos = kbUnitGetTruePosition(unitId);
    selectSingle(minionId);
    trUnitMoveToPoint(unitPos.x, unitPos.y, unitPos.z, -1, true, false, 1.0);
}

// Counts real players still on team 1 (humans) who are not defeated.
int countLivingHumanPlayers(){
    int count = 0;
    for (int p = 1; p <= cNumberPlayers - 1; p++){
        if (g_finalTeams[p] == 1 && kbPlayerIsHuman(p) == true && trPlayerIsDefeatedOrResigned(p) == false){
            count++;
        }
    }
    return count;
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

// When a player's unit dies (leaving a skeleton), infect them if human, then respawn them as a zombie.
void registerZombieRespawn(int player = -1){
    g_OnCreationListener.register(player, cUnitTypeSkeleton, false, [](int unitId = -1) -> void {
            if (countLivingHumanPlayers() <= 1) {
                endGameAllWin();
                return;
            }
            int p = kbUnitGetPlayerID(unitId);
            if (trPlayerIsDefeatedOrResigned(p)){
                return;
            }
            if (g_finalTeams[p] == 1){
                trChatSend(0, kbPlayerGetName(p) + " has been infected!\n" + toForwardSlash(displayCompensatedIcon(128, 128, "resources/egyptian/static_color/abilities/mummy_ability_icon.png")));
                convertBuildingsToHumanAI(p);
                switchPlayerToZombieTeam(p);
                g_humanUnitCount = g_humanUnitCount - 1;
                g_zombieUnitCount = g_zombieUnitCount + 1;
                convertCommandsToZombie(p);
                addWellOfUrdCommands(p);
            }
            spawnZombieLord(p, g_bspZombieSpawnLocation);
        }
    );
}

void initializeZombies(){

    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_zombieUnitTypes.size(); i = i + 1) {
            int zombieType = g_zombieUnitTypes[i];
            g_OnCreationListener.register(p, zombieType, false, [](int unitId = -1) -> void {
                lowFreqSchedulerWithIntInt.add(cTrashZombieSpawnTimer, unitId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                    if (g_isNight == false) {
                        return true;
                    }

                    int p = kbUnitGetPlayerID(unitID);
                    selectSingle(unitID);
                    if (trUnitDead() || trPlayerIsDefeatedOrResigned(p)) {
                        return false;
                    }

                    int buildingId = getRandomAliveBuilding();
                    int minionId = createTrashMinion(unitID);
                    orderToAutoAttackUnit(minionId, buildingId);
                    return true;
                });
            });
        }
        g_OnCreationListener.register(p, cUnitTypeWellOfUrd, false, [](int unitId = -1) -> void {
            lowFreqSchedulerWithIntInt.add(cTrashZombieSpawnTimer, unitId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                if (g_isNight == false) {
                    return true;
                }
                selectSingle(unitID);
                if (trUnitPercentComplete() < 100){
                    return true;
                }

                int p = kbUnitGetPlayerID(unitID);
                if (trUnitDead() || trPlayerIsDefeatedOrResigned(p)) {
                    return false;
                }

                int buildingId = getRandomAliveBuilding();
                int minionId = createTrashMinion(unitID, kbUnitGetNumberContained(unitID));
                orderToAutoAttackUnit(minionId, buildingId);
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
            0.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x + sideOffset,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + 9.0,
            0.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x - 9.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, cHumanAIPlayer);
        trUnitCreateForced(
            kbProtoUnitGetName(cUnitTypeRugs),
            g_bspZombieSpawnLocation.x + 9.0,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + sideOffset,
            90.0, cHumanAIPlayer);
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