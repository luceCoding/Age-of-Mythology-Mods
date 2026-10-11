void spawnSymmetricObjectives() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    Vector center = Vector(mapX * 0.5, configMapBaseHeight, mapZ * 0.5);

    float A = mapX * 0.12; 
    float B = mapX * 0.12; 

    // --- Vertical Bias Control ---
    // Positive values (> 0.0) shift objectives toward the top of the map.
    // Negative values (< 0.0) shift objectives toward the bottom of the map.
    // E.g., mapZ * 0.05 shifts it upward by 5% of the map's height.
    float verticalBias = 0.05; 

    // Arrange spots sequentially in a circle with the vertical bias applied to the Z-axis
    vector[] spots = new vector(4, cInvalidVector);
    spots[0] = center + Vector(-A + B, 0.0, (A + B) + verticalBias);   // Top-Left
    spots[1] = center + Vector(A + B, 0.0, (-A + B) + verticalBias);   // Top-Right
    spots[2] = center + Vector(A - B, 0.0, (-A - B) + verticalBias);   // Bottom-Right
    spots[3] = center + Vector(-A - B, 0.0, (A - B) + verticalBias);   // Bottom-Left

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