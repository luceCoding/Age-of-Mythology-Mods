void spawnSymmetricObjectives() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    Vector center = Vector(mapX * 0.5, configMapBaseHeight, mapZ * 0.5);

    // Offsets scaled to map size:
    // A = distance towards Team 1 / Team 2 along the lane axis
    // B = distance deep into Top / Bottom jungle
    float A = mapX * 0.125; 
    float B = mapX * 0.14; 

    vector[] spots = new vector(4, cInvalidVector);

    // 1. Top-Left Red Circle (Team 1 Upper Jungle)
    spots[0] = center + Vector(-A + B, 0.0, A + B);

    // 2. Bottom-Right Red Circle (Team 2 Lower Jungle - Mirrored Pair 1)
    spots[1] = center + Vector(A - B, 0.0, -A - B);

    // 3. Top-Right Red Circle (Team 2 Upper Jungle)
    spots[2] = center + Vector(A + B, 0.0, -A + B);

    // 4. Bottom-Left Red Circle (Team 1 Lower Jungle - Mirrored Pair 2)
    spots[3] = center + Vector(-A - B, 0.0, A - B);

    string[] buildings = new string(4, "");
    buildings[0] = "DwarvenForge";
    buildings[1] = "DwarvenArmory";
    buildings[2] = "TempleOfTheGods";
    buildings[3] = "ShrineJapanese";

    int offset = xsRandInt(4);
    for (int k = 0; k < buildings.size(); k++) {
        int buildingIdx = (k + offset) % buildings.size();
        Vector v = spots[k];
        trUnitCreateForced(buildings[buildingIdx], v.x, configMapBaseHeight, v.z, 0.0, 0);
    }
}