void spawnTreeCoveForUnit(
    int campUnitID = -1, 
    float coveRadius = 10.0, 
    float arcDegrees = 180.0, 
    int treeCount = 12, 
    string[] treeTypes = default
) {
    if (campUnitID < 0) return;

    selectSingle(campUnitID);
    vector campPos = trUnitGetPosition(campUnitID);
    if (campPos == cInvalidVector) return;

    // Map bounds
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    // Pick a random arc center angle from 0.0 to 360.0 degrees
    float randomAngleDeg = xsRandFloat(0.0, 360.0);
    float halfArcDeg = arcDegrees * 0.5;
    float startAngleDeg = randomAngleDeg - halfArcDeg;

    float stepsFloat = 1.0 * treeCount;
    if (stepsFloat <= 0.0) stepsFloat = 1.0;
    float stepSizeDeg = arcDegrees / stepsFloat;

    for (int i = 0; i <= treeCount; i = i + 1) {
        float currentAngleDeg = startAngleDeg + (1.0 * i * stepSizeDeg);

        // Calculate base offset relative to unit
        float offsetX = coveRadius * cosDeg(currentAngleDeg);
        float offsetZ = coveRadius * sinDeg(currentAngleDeg);

        // Side 1: Primary Camp Cove
        float treeX1 = campPos.x + offsetX + xsRandFloat(-1.25, 1.25);
        float treeZ1 = campPos.z + offsetZ + xsRandFloat(-1.25, 1.25);

        string treeName1 = "Tree Oak";
        if (treeTypes.size() > 0) {
            treeName1 = treeTypes[xsRandInt(0, treeTypes.size() - 1)];
        }
        trUnitCreate(treeName1, treeX1, configMapBaseHeight, treeZ1, xsRandInt(0, 359), 0);

        // Side 2: Mirrored Camp Cove (Rotated 180 degrees across Map Center)
        float baseTreeX2 = mapX - (campPos.x + offsetX);
        float baseTreeZ2 = mapZ - (campPos.z + offsetZ);

        float treeX2 = baseTreeX2 + xsRandFloat(-1.25, 1.25);
        float treeZ2 = baseTreeZ2 + xsRandFloat(-1.25, 1.25);

        string treeName2 = "TreeOak";
        if (treeTypes.size() > 0) {
            treeName2 = treeTypes[xsRandInt(0, treeTypes.size() - 1)];
        }
        trUnitCreate(treeName2, treeX2, configMapBaseHeight, treeZ2, xsRandInt(0, 359), 0);
    }
}