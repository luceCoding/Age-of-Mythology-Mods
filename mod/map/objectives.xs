void spawnSymmetricObjectives() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    Vector center = Vector(mapX * 0.5, configMapBaseHeight, mapZ * 0.5);

    float A = mapX * 0.09; 
    float B = mapX * 0.13; 

    // Arrange spots sequentially in a circle: Top-Left, Top-Right, Bottom-Right, Bottom-Left
    vector[] spots = new vector(4, cInvalidVector);
    spots[0] = center + Vector(-A + B, 0.0, A + B);   // Top-Left
    spots[1] = center + Vector(A + B, 0.0, -A + B);   // Top-Right
    spots[2] = center + Vector(A - B, 0.0, -A - B);   // Bottom-Right
    spots[3] = center + Vector(-A - B, 0.0, A - B);   // Bottom-Left

    // Random rotation shift (0 to 3)
    int rot = xsRandInt(0, 3);
    // Random flip to break predictable clockwise ordering
    bool flip = (xsRandInt(0, 1) == 1); 
    for (int i = 0; i < 4; i++) {
        // Calculate the target spot index with rotation and optional direction flip
        int spotIdx = flip ? (4 + rot - i) % 4 : (rot + i) % 4;
        Vector v = spots[spotIdx];
        int unitId = trUnitCreateForced(g_shopTypes[i], v.x, configMapBaseHeight, v.z, 0.0, 0);
        selectSingle(unitId);
        trUnitSetScale(0.75, 0.75, 0.75);
        ShopTypeToUnitIDMap.put(i, unitId);
    }
}