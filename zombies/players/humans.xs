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

    float spawnRadius = 10.0;
    int spawnIndex = 0;

    // 2. Spawn units in a circle
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] != 1 || kbPlayerIsHuman(p) == false) {
            continue;
        }

        // Calculate evenly spaced angle for this unit
        float angle = (cTwoPi * xsIntToFloat(spawnIndex)) / xsIntToFloat(totalHumans);
        float offsetX = spawnRadius * cosDeg(angle);
        float offsetZ = spawnRadius * sinDeg(angle);

        int unitType = g_humanUnitTypes[spawnIndex % g_humanUnitTypes.size()];
        int unitID = trUnitCreateForced(
            kbProtoUnitGetName(unitType),
            g_bspHumanSpawnLocation.x + offsetX,
            g_bspHumanSpawnLocation.y,
            g_bspHumanSpawnLocation.z + offsetZ,
            0, p);
            
        g_humanUnitIDs.add(unitID);
        g_humanUnitCount = g_humanUnitCount + 1;
        spawnIndex = spawnIndex + 1;
    }
}