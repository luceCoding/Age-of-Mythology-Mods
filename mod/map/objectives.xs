bool isSpotClearOfAI(float x = 0.0, float z = 0.0, float clearanceRadius = 0.0) {
    // Spawn temporary lure unit to anchor spatial query
    int tempUnitId = trUnitCreateForced("CinematicBlockWaypoint", x, configMapBaseHeight, z, -1, 0);

    // Check count of alive buildings within radius
    int teamABuildings = kbUnitTypeCountInArea("Building", aiTeamA, cUnitStateAlive, tempUnitId, clearanceRadius);
    int teamBBuildings = kbUnitTypeCountInArea("Building", aiTeamB, cUnitStateAlive, tempUnitId, clearanceRadius);

    // Cleanup temporary unit
    trUnitSelectClear();
    trUnitSelectByID(tempUnitId);
    trUnitDestroy();

    if (teamABuildings > 0 || teamBBuildings > 0) {
        return false; // Spot is blocked by AI
    }
    return true; // Spot is safe
}

void spawnSymmetricNeutralBuildings() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    Vector center = Vector(mapX * 0.5, configMapBaseHeight, mapZ * 0.5);

    float clearanceRadius = 18.0 * 2;  // Minimum distance required from AI buildings
    float minInterSpotDist = 18.0 * 2; // Minimum distance between any two neutral buildings
    float minCenterDist = 18.0 * 1.5;    // Dead-zone radius from center to prevent pair self-overlap

    vector[] spots = new vector(4, cInvalidVector);

    float maxOffset = mapX * 0.275;
    if (maxOffset < 20.0) maxOffset = 20.0;

    bool validSpotFound = false;
    int attempts = 0;

    while (validSpotFound == false && attempts < 100) {
        Vector offset1 = Vector(xsRandFloat(-maxOffset, maxOffset), 0.0, xsRandFloat(-maxOffset, maxOffset));
        Vector offset2 = Vector(xsRandFloat(-maxOffset, maxOffset), 0.0, xsRandFloat(-maxOffset, maxOffset));

        // Skip pairs spawning too close to the map center
        if (xsVectorLength(offset1) < minCenterDist || xsVectorLength(offset2) < minCenterDist) {
            attempts++;
            continue;
        }

        // Set symmetric points around map center
        spots[0] = center + offset1;
        spots[1] = center - offset1;
        spots[2] = center + offset2;
        spots[3] = center - offset2;

        // 1. Check Euclidean distance across ALL unique spot combinations (0-1, 0-2, 0-3, 1-2, 1-3, 2-3)
        bool spacingOk = true;
        for (int i = 0; i < 4; i++) {
            for (int j = i + 1; j < 4; j++) {
                if (xsVectorLength(spots[i] - spots[j]) < minInterSpotDist) {
                    spacingOk = false;
                    break;
                }
            }
            if (spacingOk == false) break;
        }

        // 2. Check AI building clearance on all 4 spots
        if (spacingOk) {
            bool allClear = true;
            for (int k = 0; k < 4; k++) {
                vector v = spots[k];
                if (isSpotClearOfAI(v.x, v.z, clearanceRadius) == false) {
                    allClear = false;
                    break;
                }
            }
            if (allClear) validSpotFound = true;
        }

        attempts++;
    }

    // Fallback: Use safe default coordinates past clearance if 100 attempts fail
    if (validSpotFound == false) {
        spots[0] = Vector(105.2, configMapBaseHeight, 69.96);
        spots[1] = Vector(150.79, configMapBaseHeight, 186.0);
        spots[2] = Vector(185.0, configMapBaseHeight, 150.14);
        spots[3] = Vector(70.99, configMapBaseHeight, 105.85);
    }

    string[] buildings = new string(4, "");
    buildings[0] = "DwarvenForge";
    buildings[1] = "DwarvenArmory";
    buildings[2] = "TempleOfTheGods";
    buildings[3] = "ShrineJapanese";

    StringFisherYatesShuffle(buildings);

    // Spawn each building facing inward toward map center
    for (int k = 0; k < 4; k++) {
        vector v = spots[k];
        trUnitCreateForced(buildings[k], v.x, configMapBaseHeight, v.z, xsRandFloat(0.0, 360.0), 0);
    }
}