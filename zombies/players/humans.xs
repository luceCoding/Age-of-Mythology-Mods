void initializeHumans(){
    if (g_humanUnitTypes.size() == 0) {
        errorLog("Cannot spawn the human players: no human unit types are configured.");
        return;
    }

    int spawnIndex = 0;
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] != 1 || kbPlayerIsHuman(p) == false) {
            continue;
        }

        float offsetX = (xsIntToFloat(spawnIndex % 4) - 1.5) * 2.0;
        float offsetZ = xsIntToFloat(spawnIndex / 4) * 2.0;
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