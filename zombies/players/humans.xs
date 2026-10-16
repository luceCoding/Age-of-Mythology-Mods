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

    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] != 1 || kbPlayerIsHuman(p) == false) {
            continue;
        }

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
    }
}