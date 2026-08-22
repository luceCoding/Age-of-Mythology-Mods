void spawnSymmetricObjectives() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    Vector center = Vector(mapX * 0.5, configMapBaseHeight, mapZ * 0.5);

    // Offsets scaled to map size:
    // A = distance towards Team 1 / Team 2 along the lane axis
    // B = distance deep into Top / Bottom jungle
    float A = mapX * 0.09; 
    float B = mapX * 0.13; 

    vector[] spots = new vector(4, cInvalidVector);

    // 1. Top-Left Red Circle (Team 1 Upper Jungle)
    spots[0] = center + Vector(-A + B, 0.0, A + B);

    // 2. Bottom-Right Red Circle (Team 2 Lower Jungle - Mirrored Pair 1)
    spots[1] = center + Vector(A - B, 0.0, -A - B);

    // 3. Top-Right Red Circle (Team 2 Upper Jungle)
    spots[2] = center + Vector(A + B, 0.0, -A + B);

    // 4. Bottom-Left Red Circle (Team 1 Lower Jungle - Mirrored Pair 2)
    spots[3] = center + Vector(-A - B, 0.0, A - B);

    int offset = xsRandInt(0, g_shopTypes.size()-1);
    for (int k = 0; k < g_shopTypes.size(); k++) {
        int buildingIdx = (k + offset) % g_shopTypes.size();
        Vector v = spots[k];
        int unidId = trUnitCreateForced(g_shopTypes[buildingIdx], v.x, configMapBaseHeight, v.z, 0.0, 0);
        selectSingle(unidId);
        trUnitSetScale(0.75, 0.75, 0.75);
        ShopTypeToUnitIDMap.put(buildingIdx, unidId);
    }
}