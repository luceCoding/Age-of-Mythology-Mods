void paintRoadSegmentOrganic(
    vector start = cInvalidVector, 
    vector end = cInvalidVector, 
    float radius = 5.0, 
    string[] terrainNames = default, 
    float maxJitter = 2.0
) {
    float dist = xsVectorLength(end - start);
    if (dist <= 0.0) return;

    vector dir = (end - start) * (1.0 / dist);

    float stepSize = radius * 0.4;
    int steps = (dist / stepSize);
    if (steps <= 0) steps = 1;

    for (int i = 0; i <= steps; i++) {
        float progress = i / steps;
        float endpointFade = 4.0 * progress * (1.0 - progress);

        float offsetX = xsRandFloat(-maxJitter, maxJitter) * endpointFade;
        float offsetZ = xsRandFloat(-maxJitter, maxJitter) * endpointFade;
        float curRadius = radius + (xsRandFloat(-0.75, 0.75) * endpointFade);

        vector curr = start + (dir * (i * stepSize));
        curr.x = curr.x + offsetX;
        curr.z = curr.z + offsetZ;

        string selectedTerrain = "Greek Road 1";
        if (terrainNames.size() > 0) {
            selectedTerrain = terrainNames[xsRandInt(0, terrainNames.size() - 1)];
        }
        trPaintTerrainCircularBySubtypeName(selectedTerrain, curr, curRadius, false);
    }
}

void applyRoadSegmentPatches(
    vector start = cInvalidVector, 
    vector end = cInvalidVector, 
    float radius = 5.0, 
    string[] patchTerrainNames = default, 
    float maxJitter = 2.0, 
    float patchChance = 0.45
) {
    float dist = xsVectorLength(end - start);
    if (dist <= 0.0) return;

    vector dir = (end - start) * (1.0 / dist);
    vector perp = vector(-dir.z, 0.0, dir.x);

    float stepSize = radius * 0.4;
    int steps = (dist / stepSize);
    if (steps <= 0) steps = 1;

    for (int i = 0; i <= steps; i++) {
        if (patchTerrainNames.size() > 0 && xsRandFloat(0.0, 1.0) < patchChance) {
            float progress = i / steps;
            float endpointFade = 4.0 * progress * (1.0 - progress);

            float offsetX = xsRandFloat(-maxJitter, maxJitter) * endpointFade;
            float offsetZ = xsRandFloat(-maxJitter, maxJitter) * endpointFade;
            float curRadius = radius + (xsRandFloat(-0.75, 0.75) * endpointFade);

            vector curr = start + (dir * (i * stepSize));
            curr.x = curr.x + offsetX;
            curr.z = curr.z + offsetZ;

            string patchTerrain = patchTerrainNames[xsRandInt(0, patchTerrainNames.size() - 1)];
            
            float patchScatter = xsRandFloat(-curRadius * 0.65, curRadius * 0.65);
            vector patchPos = curr + (perp * patchScatter);
            
            float patchRadius = max(curRadius * xsRandFloat(0.25, 0.45), 5.0);
            
            trPaintTerrainCircularBySubtypeName(patchTerrain, patchPos, patchRadius, false);
        }
    }
}

void paintAllLanesCircular(float roadRadius = 8.0) {
    // Primary road textures
    string[] roadTerrains = new string(1, "");
    roadTerrains[0] = "Greek Road 1";

    // Patchy spot textures (overgrowth, dirt, cracks)
    string[] patchTerrains = new string(3, "");
    patchTerrains[0] = "Greek Road 1";
    patchTerrains[1] = "Greek Road 2";
    patchTerrains[2] = "Greek Road 3";

    // Pass 1: Paint all base roads completely
    for (int i = 0; i < 7; i++) {
        paintRoadSegmentOrganic(g_T1ToT2MidLane[i], g_T1ToT2MidLane[i+1], roadRadius, roadTerrains, 5.0);
        paintRoadSegmentOrganic(g_T1ToT2TopLane[i], g_T1ToT2TopLane[i+1], roadRadius, roadTerrains, 5.0);
        paintRoadSegmentOrganic(g_T1ToT2BotLane[i], g_T1ToT2BotLane[i+1], roadRadius, roadTerrains, 5.0);
    }

    // Pass 2: Layer patches on top of the finished base roads
    for (int j = 0; j < 7; j++) {
        applyRoadSegmentPatches(g_T1ToT2MidLane[j], g_T1ToT2MidLane[j+1], roadRadius, patchTerrains, roadRadius + 4.0, 0.60);
        applyRoadSegmentPatches(g_T1ToT2TopLane[j], g_T1ToT2TopLane[j+1], roadRadius, patchTerrains, roadRadius + 4.0, 0.60);
        applyRoadSegmentPatches(g_T1ToT2BotLane[j], g_T1ToT2BotLane[j+1], roadRadius, patchTerrains, roadRadius + 4.0, 0.60);
    }
}