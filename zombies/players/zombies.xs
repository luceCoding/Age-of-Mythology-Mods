void addTrainBuilding(string targetProto = "", int cUnitType = -1, int p = -1, int row = 0, int col = 0, int buildLimit = 1){
    trProtounitAddTrain(targetProto, p, kbProtoUnitGetName(cUnitType), row, col);
    trModifyProtounitActionUnitType(targetProto, "Build", kbUnitTypeGetName(cUnitTypeBuilding), p, cXSActionProtoEffectWorkRate, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitType), p, cXSProtoEffectBuildLimit, buildLimit, cXSRelativityAssign);
    trUnforbidProtounit(p, kbProtoUnitGetName(cUnitType));
}

void setupZombiesPost(){
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_zombieUnitTypes.size(); i++) {
            int zombieType = g_zombieUnitTypes[i];
            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeWellOfUrd, p, 0, 2, 1);
            trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Wood", p, cXSPUResourceEffectCost, 30, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildPoints, 30.0, cXSRelativityAssign);
            trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWellOfUrd), "AbstractTemple", true);
            trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "Unit", p, cXSPUUnitTypeEffectAddNotContainType, 0.0, cXSRelativityAssign);
            trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeWellOfUrd), "LogicalTypePickable", p, cXSPUUnitTypeEffectAddContainType, g_trashZombieTypes.size()-1, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectMaxContained, g_trashZombieTypes.size()-1, cXSRelativityAssign);

            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeDwarvenArmory, p, 0, 3, 1);
            trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeDwarvenArmory), "Wood", p, cXSPUResourceEffectCost, 100, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeDwarvenArmory), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);

            addTrainBuilding(kbProtoUnitGetName(zombieType), cUnitTypeMonumentToGods, p, 0, 4, 1);
            trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMonumentToGods), "Wood", p, cXSPUResourceEffectCost, 100, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonumentToGods), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);

            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopCapAddition, maxZombiePopulation, cXSRelativityAssign);
            trProtounitModifySpawnData(kbProtoUnitGetName(zombieType), p, kbProtoUnitGetName(cUnitTypeSkeleton), 0, 1.0, cXSRelativityAssign, -1, -1);
            trProtoUnitSetFlag(p, kbProtoUnitGetName(zombieType), "KnockoutDeath", false);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Gold", p, cXSPUResourceEffectKillReward, 10, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectHitpoints, g_humanUnitCount+1, cXSRelativityPercent);
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectDamageCrush, 5.0 * (g_humanUnitCount+1), cXSRelativityAssign);
            trModifyProtounitAction(kbProtoUnitGetName(zombieType), "RangedAttack", p, cXSActionEffectRange, 10.0, cXSRelativityAssign);
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(zombieType), p, "RangedAttackMyth", false);
        }
        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int zombieType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(zombieType), p, cXSProtoEffectPopulationCount, 0, cXSRelativityAssign);
            trModifyProtounitResource(kbProtoUnitGetName(zombieType), "Wood", p, cXSPUResourceEffectKillReward, 1, cXSRelativityAssign);
        }
    }
}

int spawnZombieLord(int p = -1, vector v = cInvalidVector){
    int zombieId = trUnitCreateForced(
        kbProtoUnitGetName(g_zombieUnitTypes[0]),
        v.x, v.y, v.z,
        0, p);
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

void dayDebuffZombies(){
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int trashType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(trashType), p, cXSProtoEffectLifespan, 30.0, cXSRelativityAssign);
        }
    }
}

void nightBuffZombies(){
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int i = 0; i < g_trashZombieTypes.size(); i++) {
            int trashType = g_trashZombieTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(trashType), p, cXSProtoEffectLifespan, cMaxFloat, cXSRelativityAssign);
        }
    }
}

void permaDailyBuffZombies(){
    for (int p = 1; p < cNumberPlayers; p++) {
        if (g_finalTeams[p] == 2){
            trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWellOfUrd), p, cXSProtoEffectBuildLimit, 1, cXSRelativityAbsolute);
            trPlayerGrantResources(p, "Gold", g_dayNumber * g_humanUnitCount);
        }
    }
}

// Returns a random living human unit, or -1 if none (dead ones are pruned).
int getRandomLivingHuman(){
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
    return humanID;
}

// Spawns a minion at the zombie unit's position, owned by the zombie's player.
int createTrashMinion(int unitID = -1, int minionTier = 0){
    int p = kbUnitGetPlayerID(unitID);
    vector zombiePos = kbUnitGetTruePosition(unitID);
    int minionType = g_trashZombieTypes[minionTier];
    return trUnitCreate(kbProtoUnitGetName(minionType), zombiePos.x, zombiePos.y, zombiePos.z, xsRandInt(0, 359), p);
}

void orderToAutoAttackHuman(int minionId = -1, int humanID = -1){
    if (minionId == -1 || humanID == -1) { return; }
    vector humanPos = kbUnitGetTruePosition(humanID);
    selectSingle(minionId);
    trUnitMoveToPoint(humanPos.x, humanPos.y, humanPos.z, -1, true, false, 1.0);
}

// When a player's unit dies (leaving a skeleton), infect them if human, then respawn them as a zombie.
void registerZombieRespawn(int player = -1){
    g_OnCreationListener.register(player, cUnitTypeSkeleton, false, [](int unitId = -1) -> void {
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

                    int humanID = getRandomLivingHuman();
                    int minionId = createTrashMinion(unitID);
                    orderToAutoAttackHuman(minionId, humanID);
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

                int humanID = getRandomLivingHuman();
                int minionId = createTrashMinion(unitID, kbUnitGetNumberContained(unitID));
                orderToAutoAttackHuman(minionId, humanID);
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