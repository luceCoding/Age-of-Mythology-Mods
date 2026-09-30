int[] generateCamps(string creepName = "", int targetTotalCamps = 20, 
                    float clearanceRadius = 25.0, float roadAvoidanceRadius = 10.0) {

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    int targetPairs = targetTotalCamps / 2;
    float minInterCampDist = 27.0;
    float minBaseDist = 45.0;
    float mapMargin = 8.0;

    vector team1Base = g_T1ToT2TopLane[0]; 
    vector team2Base = g_T1ToT2TopLane[7]; 

    vector[] spawnedCamps = new vector(targetTotalCamps, cInvalidVector);
    int spawnedCount = 0;

    int targetPairsPlaced = 0;
    int maxAttempts = 2000;
    int attempts = 0;

    int[] creepIds = new int(0, -1);

    while (targetPairsPlaced < targetPairs && attempts < maxAttempts) {
        attempts++;

        float p1X = 0.0;
        float p1Z = 0.0;

        // Force every 3rd attempt to sample directly inside the Top/Bottom central corridor
        if (attempts % 3 == 0 || (targetPairsPlaced == 0 && attempts < 300)) {
            // Along the main top-to-bottom diagonal (X = Z)
            float centerProgress = xsRandFloat(0.70, 0.82); 
            
            // Perpendicular width offset across the X=Z diagonal (+/- 8% of map width)
            float widthOffset = xsRandFloat(-0.08, 0.08); 

            p1X = (centerProgress + widthOffset) * mapX;
            p1Z = (centerProgress - widthOffset) * mapZ;
        } else {
            // Standard uniform sampling across full map
            p1X = xsRandFloat(mapMargin, mapX - mapMargin);
            p1Z = xsRandFloat(mapMargin, mapZ - mapMargin);
        }

        vector p1 = vector(p1X, configMapBaseHeight, p1Z);
        // p2 automatically mirrors into the Bottom Red Corridor (Z between 17% and 28%)
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
        if (isAnyTerrainNear(p1.x, p1.z, roadAvoidanceRadius, g_roadTypes) ||
            isAnyTerrainNear(p2.x, p2.z, roadAvoidanceRadius, g_roadTypes) ||
            isAnyTerrainNear(p1.x, p1.z, roadAvoidanceRadius, g_colosseumRoadTypes) ||
            isAnyTerrainNear(p2.x, p2.z, roadAvoidanceRadius, g_colosseumRoadTypes)) {
            continue;
        }

        // 5. Verify AI/Building Clearance
        if (isAreaClearOf("Building", p1.x, p1.z, clearanceRadius) && isAreaClearOf("Building", p2.x, p2.z, clearanceRadius)) {
            int unitId1 = trUnitCreateForced(creepName, p1.x, configMapBaseHeight, p1.z, -1, 0);
            int unitId2 = trUnitCreateForced(creepName, p2.x, configMapBaseHeight, p2.z, -1, 0);
            creepIds.add(unitId1);
            creepIds.add(unitId2);

            float rdmRadius = xsRandFloat(10.0, 12.0);
            int nTrees = xsRandInt(15, 30);
            float rdmArc = xsRandFloat(200.0, 300.0);
            spawnTreeCoveForUnit(unitId1, rdmRadius, rdmArc, nTrees, g_treeTypes);

            spawnedCamps[spawnedCount] = p1;
            spawnedCount++;
            spawnedCamps[spawnedCount] = p2;
            spawnedCount++;
            
            targetPairsPlaced++;
        }
    }
    return creepIds;
}

CreepCamp[] g_creepCamps = default;
CreepCamp creepCampClassInstanceWorkaround(){
    CreepCamp creepCamp;
    return creepCamp;
}

void generateAllCamps(){
    int[] t3CreepCamp = generateCamps(g_creepCampPlaceholderTypes[2], 4, 25.0, 15.0);
    for(int i = 0; i < t3CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t3CreepCamp[i], T3_CAMP_SPAWN_TIME, g_creepCampTypes[2], 1, 5, T3_CAMP_SPAWN_TIME + 60, 1.25);
        g_creepCamps.add(creepCamp);
    }
    int[] t2CreepCamp = generateCamps(g_creepCampPlaceholderTypes[1], 8, 25.0, 12.5);
    for(int i = 0; i < t2CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t2CreepCamp[i], T2_CAMP_SPAWN_TIME, g_creepCampTypes[1], 1, 5, T2_CAMP_SPAWN_TIME + 60, 1.25);
        g_creepCamps.add(creepCamp);
    }
    int[] t1CreepCamp = generateCamps(g_creepCampPlaceholderTypes[0], 10, 25.0, 10.0);
    for(int i = 0; i < t1CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t1CreepCamp[i], T1_CAMP_SPAWN_TIME, g_creepCampTypes[0], 1, 5, T1_CAMP_SPAWN_TIME + 60, 1.25);
        g_creepCamps.add(creepCamp);
    }

    lowFreqScheduler.add(1013, [](int iterations = 1) -> bool {
        for(int i = 0; i < g_creepCamps.size(); i++){
            CreepCamp creepCamp = g_creepCamps[i];
            creepCamp.processCamp();
            g_creepCamps[i] = creepCamp;
        }
        return true;
    });

    generateCamps("Storehouse", 24, 20.0, 12.0);
}