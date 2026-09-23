const int aiTeamA = cNumberPlayers - 1;
const int aiTeamB = cNumberPlayers;

bool isAreaClearOf(string unitType = "Building", float x = 0.0, float z = 0.0, float clearanceRadius = 0.0) {
    int tempUnitId = trUnitCreateForced("CinematicBlockWaypoint", x, configMapBaseHeight, z, -1, 0);

    int team0Buildings = kbUnitTypeCountInArea(unitType, 0, cUnitStateAlive, tempUnitId, clearanceRadius);
    int teamABuildings = kbUnitTypeCountInArea(unitType, aiTeamA, cUnitStateAlive, tempUnitId, clearanceRadius);
    int teamBBuildings = kbUnitTypeCountInArea(unitType, aiTeamB, cUnitStateAlive, tempUnitId, clearanceRadius);

    selectSingle(tempUnitId);
    trUnitDestroy();

    if (team0Buildings > 0 || teamABuildings > 0 || teamBBuildings > 0) {
        return false; // Spot is blocked
    }
    return true; // Spot is clear
}

bool isAnyTerrainNear(float x = 0.0, float z = 0.0, float radius = 0.0, string[] targetTerrains = default) {
    float radiusSq = radius * radius;
    float step = 2.0;

    for (float dx = 0.0 - radius; dx <= radius; dx = dx + step) {
        for (float dz = 0.0 - radius; dz <= radius; dz = dz + step) {
            if ((dx * dx + dz * dz) <= radiusSq) {
                vector samplePos = vector(x + dx, configMapBaseHeight, z + dz);

                for (int t = 0; t < targetTerrains.size(); t++) {
                    if (trTerrainAtPosition(targetTerrains[t], samplePos)) {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}