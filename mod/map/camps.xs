bool isAreaClearOf(string unitType = "Building", float x = 0.0, float z = 0.0, float clearanceRadius = 0.0) {
    int tempUnitId = trUnitCreateForced("CinematicBlockWaypoint", x, configMapBaseHeight, z, -1, 0);

    int team0Buildings = kbUnitTypeCountInArea(unitType, 0, cUnitStateAlive, tempUnitId, clearanceRadius);
    int teamABuildings = kbUnitTypeCountInArea(unitType, aiTeamA, cUnitStateAlive, tempUnitId, clearanceRadius);
    int teamBBuildings = kbUnitTypeCountInArea(unitType, aiTeamB, cUnitStateAlive, tempUnitId, clearanceRadius);

    trUnitSelectClear();
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

void generateCreepCamps(string creepName = "", int targetTotalCamps = 20, float clearanceRadius = 25.0, float roadAvoidanceRadius = 10.0, string[] roadTerrains = default) {
    roadTerrains.add("Greek Road 1");

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    int targetPairs = targetTotalCamps / 2;
    float minInterCampDist = 25.0;
    float minBaseDist = 50.0; 
    float mapMargin = 3.0;

    vector team1Base = g_t1TopSpawn;
    vector team2Base = g_t2TopSpawn;

    vector[] spawnedCamps = new vector(targetTotalCamps, cInvalidVector);
    int spawnedCount = 0;

    int targetPairsPlaced = 0;
    int maxAttempts = 300;
    int attempts = 0;

    while (targetPairsPlaced < targetPairs && attempts < maxAttempts) {
        attempts++;

        float p1X = xsRandFloat(mapMargin, mapX - mapMargin);
        float p1Z = xsRandFloat(mapMargin, mapZ - mapMargin);
        vector p1 = vector(p1X, configMapBaseHeight, p1Z);
        vector p2 = vector(mapX - p1X, configMapBaseHeight, mapZ - p1Z);

        // 1. Base Distance Gate
        if (xsVectorLength(p1 - team1Base) < minBaseDist || xsVectorLength(p1 - team2Base) < minBaseDist ||
            xsVectorLength(p2 - team1Base) < minBaseDist || xsVectorLength(p2 - team2Base) < minBaseDist) {
            continue;
        }

        // 2. Prevent camp self-overlap at center
        if (xsVectorLength(p1 - p2) < minInterCampDist) continue;

        // 3. Prevent overlap with existing camps
        bool overlapsExisting = false;
        for (int i = 0; i < spawnedCount; i++) {
            if (xsVectorLength(p1 - spawnedCamps[i]) < minInterCampDist || 
                xsVectorLength(p2 - spawnedCamps[i]) < minInterCampDist) {
                overlapsExisting = true;
                break;
            }
        }
        if (overlapsExisting) continue;

        // 4. Lane Terrain Gate using trTerrainAtPosition string matching
        if (isAnyTerrainNear(p1.x, p1.z, roadAvoidanceRadius, roadTerrains) ||
            isAnyTerrainNear(p2.x, p2.z, roadAvoidanceRadius, roadTerrains)) {
            continue;
        }

        // 5. Verify AI/Building Clearance
        if (isAreaClearOf("Building", p1.x, p1.z, clearanceRadius) && isAreaClearOf("Building", p2.x, p2.z, clearanceRadius)) {
            int unitId = trUnitCreateForced(creepName, p1.x, configMapBaseHeight, p1.z, -1, 0);
            trUnitCreateForced(creepName, p2.x, configMapBaseHeight, p2.z, -1, 0);

            float rdmRadius = xsRandFloat(10.0, 12.0);
            int nTrees = xsRandInt(15, 30);
            float rdmArc = xsRandFloat(200.0, 300.0);
            spawnTreeCoveForUnit(unitId, rdmRadius, rdmArc, nTrees, g_treeTypes);

            spawnedCamps[spawnedCount] = p1;
            spawnedCount++;
            spawnedCamps[spawnedCount] = p2;
            spawnedCount++;
            
            targetPairsPlaced++;
        }
    }
}

void generateAllCamps(){
    //generateCreepCamps("Argus", 4, 25.0, 20.0);
    //generateCreepCamps("Dryad", 6, 25.0, 20.0);
    //generateCreepCamps("Satyr", 10, 25.0, 20.0);

    generateCreepCamps("Lure", 10, 25.0, 20.0);

    generateCreepCamps("MiningCamp", 4, 25.0, 12.0);
    generateCreepCamps("MiningCampJapanese", 6, 20.0, 12.0);
    generateCreepCamps("Storehouse", 10, 15.0, 12.0);
}