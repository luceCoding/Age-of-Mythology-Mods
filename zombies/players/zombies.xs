void initializeZombies(){
    //trUnitCreateForced(kbProtoUnitGetName(cUnitTypeTartarianGate), g_bspZombieSpawnLocation.x, g_bspZombieSpawnLocation.y, g_bspZombieSpawnLocation.z, 0, cZombieAIPlayer);

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

        float offsetX = (xsIntToFloat(spawnIndex % 4) - 1.5) * 2.0;
        float offsetZ = xsIntToFloat(spawnIndex / 4) * 2.0;
        int unitType = g_zombieUnitTypes[spawnIndex % g_zombieUnitTypes.size()];
        trUnitCreateForced(
            kbProtoUnitGetName(unitType),
            g_bspZombieSpawnLocation.x + offsetX,
            g_bspZombieSpawnLocation.y,
            g_bspZombieSpawnLocation.z + offsetZ,
            0, p);
        spawnIndex = spawnIndex + 1;
    }

    // lowFreqScheduler.add(1000, [](int iterations = 1) -> bool {
    //     trUnitCreate(kbProtoUnitGetName(cUnitTypeMinion), g_bspZombieSpawnLocation.x, g_bspZombieSpawnLocation.y, g_bspZombieSpawnLocation.z, 0, cZombieAIPlayer);
    //     return true;
    // });

    // g_OnCreationListener.register(cZombieAIPlayer, cUnitTypeMinion, false, [](int unitId = -1) -> void {
    //         int humanCount = g_humanUnitIDs.size();
    //         if (humanCount == 0) {
    //             return;
    //         }

    //         int rdmIdx = xsRandInt(0, humanCount - 1);
    //         int humanID = g_humanUnitIDs[rdmIdx];
    //         selectSingle(humanID);
    //         if (trUnitDead()){
    //             g_humanUnitIDs.removeIndex(rdmIdx);
    //             return;
    //         }
    //         vector v = kbUnitGetTruePosition(humanID);
    //         selectSingle(unitId);
    //         trUnitMoveToPoint(v.x, v.y, v.z, -1, true, false, 1.0);
    //     }
    // );
}