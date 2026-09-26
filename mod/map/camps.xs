int[] generateCamps(string creepName = "", int targetTotalCamps = 20, 
                    float clearanceRadius = 25.0, float roadAvoidanceRadius = 10.0) {

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    int targetPairs = targetTotalCamps / 2;
    float minInterCampDist = 25.0;
    float minBaseDist = 45.0;
    float mapMargin = 8.0;

    vector team1Base = g_T1ToT2TopLane[0]; 
    vector team2Base = g_T1ToT2TopLane[7]; 

    vector[] spawnedCamps = new vector(targetTotalCamps, cInvalidVector);
    int spawnedCount = 0;

    int targetPairsPlaced = 0;
    int maxAttempts = 1000;
    int attempts = 0;

    int[] creepIds = new int(0, -1);

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

            int tempUnitId1 = trUnitCreateForced("House", p1.x, configMapBaseHeight, p1.z, -1, 0);
            int tempUnitId2 = trUnitCreateForced("House", p2.x, configMapBaseHeight, p2.z, -1, 0);
            scheduleDelete(tempUnitId1, 1000);
            scheduleDelete(tempUnitId2, 1000);

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

int[] generateVarietyCamps(ref string[] creepNames, int targetTotalCamps = 20, 
                    float clearanceRadius = 25.0, float roadAvoidanceRadius = 10.0) {

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    int targetPairs = targetTotalCamps / 2;
    float minInterCampDist = 25.0;
    float minBaseDist = 45.0;
    float mapMargin = 6.0;

    vector team1Base = g_T1ToT2TopLane[0]; 
    vector team2Base = g_T1ToT2TopLane[7]; 

    vector[] spawnedCamps = new vector(targetTotalCamps, cInvalidVector);
    int spawnedCount = 0;

    int targetPairsPlaced = 0;
    int maxAttempts = 1000;
    int attempts = 0;

    int[] creepIds = new int(0, -1);
    int creepTypeCount = creepNames.size();

    // Pre-baked offset slots for up to 6 creeps (meters relative to camp center)
    // Slot 0 = Center, Slots 1-5 = Spread around camp
    float[] slotX = new float(6, 0.0);
    float[] slotZ = new float(6, 0.0);
    slotX[0] =  0.0; slotZ[0] =  0.0; // Center
    slotX[1] =  2.5; slotZ[1] =  1.0; // Right
    slotX[2] = -2.5; slotZ[2] = -1.0; // Left
    slotX[3] =  0.8; slotZ[3] = -2.6; // Down
    slotX[4] = -0.8; slotZ[4] =  2.6; // Up
    slotX[5] =  2.2; slotZ[5] = -2.0; // Diagonal

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

        // 4. Lane Terrain Gate
        if (isAnyTerrainNear(p1.x, p1.z, roadAvoidanceRadius, g_roadTypes) ||
            isAnyTerrainNear(p2.x, p2.z, roadAvoidanceRadius, g_roadTypes) ||
            isAnyTerrainNear(p1.x, p1.z, roadAvoidanceRadius, g_colosseumRoadTypes) ||
            isAnyTerrainNear(p2.x, p2.z, roadAvoidanceRadius, g_colosseumRoadTypes)) {
            continue;
        }

        // 5. Verify AI/Building Clearance
        if (isAreaClearOf("Building", p1.x, p1.z, clearanceRadius) && isAreaClearOf("Building", p2.x, p2.z, clearanceRadius)) {
            int anchorUnitId1 = -1;

            for (int c = 0; c < creepTypeCount; c++) {
                string currentCreep = creepNames[c];
                
                // Get slot index (wraps around if more than 6 creeps)
                int slotIdx = c % 6;

                // Grab pre-defined offset + add small random jitter (+-0.6m)
                float spawnX1 = p1.x + slotX[slotIdx] + xsRandFloat(-0.6, 0.6);
                float spawnZ1 = p1.z + slotZ[slotIdx] + xsRandFloat(-0.6, 0.6);

                float spawnX2 = p2.x + slotX[slotIdx] + xsRandFloat(-0.6, 0.6);
                float spawnZ2 = p2.z + slotZ[slotIdx] + xsRandFloat(-0.6, 0.6);

                int unitId1 = trUnitCreate(currentCreep, spawnX1, configMapBaseHeight, spawnZ1, xsRandInt(1, 359), 0);
                int unitId2 = trUnitCreate(currentCreep, spawnX2, configMapBaseHeight, spawnZ2, xsRandInt(1, 359), 0);

                int tempUnitId1 = trUnitCreateForced("House", spawnX1, configMapBaseHeight, spawnZ1, -1, 0);
                int tempUnitId2 = trUnitCreateForced("House", spawnX2, configMapBaseHeight, spawnZ2, -1, 0);
                scheduleDelete(tempUnitId1, 1000);
                scheduleDelete(tempUnitId2, 1000);

                if (unitId1 != -1 && unitId2 != -1) {
                    creepIds.add(unitId1);
                    creepIds.add(unitId2);
                } else {
                    errorLog("Failed to generate creep camp: " + currentCreep);
                }

                if (c == 0) {
                    anchorUnitId1 = unitId1;
                }
            }

            if (anchorUnitId1 != -1) {
                float rdmRadius = xsRandFloat(10.0, 12.0);
                int nTrees = xsRandInt(15, 30);
                float rdmArc = xsRandFloat(200.0, 300.0);
                spawnTreeCoveForUnit(anchorUnitId1, rdmRadius, rdmArc, nTrees, g_treeTypes);
            }

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

    // Generate creep camps
    int[] t3CreepCamp = generateCamps(g_creepCampPlaceholderTypes[2], 6, 25.0, 15.0);
    for(int i = 0; i < t3CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t3CreepCamp[i], T3_CAMP_SPAWN_TIME, g_creepCampTypes[2], 1, T3_CAMP_SPAWN_TIME + 60, 1.25);
        g_creepCamps.add(creepCamp);
    }
    int[] t2CreepCamp = generateCamps(g_creepCampPlaceholderTypes[1], 8, 25.0, 15.0);
    for(int i = 0; i < t2CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t2CreepCamp[i], T2_CAMP_SPAWN_TIME, g_creepCampTypes[1], 1, T2_CAMP_SPAWN_TIME + 60, 1.25);
        g_creepCamps.add(creepCamp);
    }
    int[] t1CreepCamp = generateCamps(g_creepCampPlaceholderTypes[0], 10, 25.0, 15.0);
    for(int i = 0; i < t1CreepCamp.size(); i++){
        CreepCamp creepCamp = creepCampClassInstanceWorkaround();
        creepCamp.init(t1CreepCamp[i], T1_CAMP_SPAWN_TIME, g_creepCampTypes[0], 1, T1_CAMP_SPAWN_TIME + 60, 1.25);
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

    // Generate loot
    string[] lootCamp1 = new string(0, "");
    for (int i = 0; i < g_lootTypes.size(); i++){
        lootCamp1.add(g_lootTypes[i]);
    }
    lootCamp1.add(g_lootTypes[0]);
    generateVarietyCamps(lootCamp1, 12, 25.0, 12.0);
    lootCamp1.add(g_lootTypes[0]);
    lootCamp1.add(g_lootTypes[1]);
    generateVarietyCamps(lootCamp1, 6, 25.0, 12.0);
}