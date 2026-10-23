void initializeHumans(){
    if (g_humanUnitTypes.size() == 0) {
        errorLog("Cannot spawn the human players: no human unit types are configured.");
        return;
    }

    int totalHumans = 0;
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] == 1 && kbPlayerIsHuman(p) == true) {
            totalHumans = totalHumans + 1;
        }
    }

    if (totalHumans == 0) {
        return;
    }

    for (int p = 1; p < cNumberPlayers; p++) {
        if (g_finalTeams[p] != 1 || kbPlayerIsHuman(p) == false) {
            continue;
        }

        trPlayerGrantResources(p, "Wood", cStartingWood);
        trPlayerGrantResources(p, "Gold", cStartingGold);

        int rdmSpawnPointID = xsRandInt(0, g_humanSpawnPoints.size() - 1);
        vector v = kbUnitGetTruePosition(g_humanSpawnPoints[rdmSpawnPointID]);

        int unitType = g_humanUnitTypes[0];
        int unitID = trUnitCreateForced(
            kbProtoUnitGetName(unitType),
            v.x,
            v.y,
            v.z,
            0, p);

        g_humanUnitIDs.add(unitID);
        g_humanUnitCount = g_humanUnitCount + 1;
        if (trCurrentPlayer() == p){
            cameraLookAt(v, 60.0, 45.0, 45.0);
        }

        registerZombieRespawn(p);
    }
}

void convertBuildingsToHumanAI(int p = 0){
    int[] playerTowers = g_towerTracker.getAllPlayerBuildings(p);
    int time = 250;
    for (int i = 0; i < playerTowers.size(); i++) {
        int buildingID = playerTowers[i];
        midFreqSchedulerWithInt.add(time, buildingID, [](int iteration = 0, int buildingId = 0) -> bool {
            selectSingle(buildingId);
            trUnitConvert(cHumanAIPlayer);
            return false;
        });
        time = time + 250;
    }
    int[] playerWalls = g_wallTracker.getAllPlayerBuildings(p);
    for (int i = 0; i < playerWalls.size(); i++) {
        int buildingID = playerWalls[i];
        midFreqSchedulerWithInt.add(time, buildingID, [](int iteration = 0, int buildingId = 0) -> bool {
            selectSingle(buildingId);
            trUnitConvert(cHumanAIPlayer);
            return false;
        });
        time = time + 250;
    }
}

void disableAttackForHumanBuildings(int p = 0){
    for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        int buildingType = g_upgradeableHumanBuildings[i];
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "HandAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "RangedAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "LightningAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "BeamAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "MonolithStrike", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "HasLOS", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "Invulnerable", false);
    }
    for (int i = 0; i < g_otherHumanBuildings.size(); i++) {
        int buildingType = g_otherHumanBuildings[i];
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "HandAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "RangedAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "LightningAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "BeamAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "MonolithStrike", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "HasLOS", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "Invulnerable", false);
    }
}