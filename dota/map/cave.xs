void buildCornerCave(vector centerPos = cInvalidVector) {
    float mapMaxX = configMapTileX * 2.0;
    float mapMaxZ = configMapTileZ * 2.0;
    float margin = 2.0; // Keep slightly inside the absolute edge

    // ------------------------------------------
    // TERRAIN TERRACES (Cave Interior)
    // ------------------------------------------
    paintCircle(centerPos, 35.0, g_colosseumRoadTypes[2]);
    paintCircle(centerPos, 32.0, g_colosseumRoadTypes[3]);

    // ------------------------------------------
    // PERIMETER CAVE WALLS & DOOR
    // ------------------------------------------
    int wallSegments = 12;
    float wallAngleStep = cTwoPi / wallSegments;
    float wallCos = cos(wallAngleStep);
    float wallSin = sin(wallAngleStep);
    
    vector wallDir = vector(0, 0, 35.0);

    for (int w = 1; w <= wallSegments; w++) {
        wallDir = rotationMatrix(wallDir, wallCos, wallSin);
        vector wallSpawn = centerPos + wallDir;
        
        // Check if spawn coordinates are within map bounds
        if (wallSpawn.x >= margin && wallSpawn.x <= (mapMaxX - margin) &&
            wallSpawn.z >= margin && wallSpawn.z <= (mapMaxZ - margin)) {
            
            // Use the great cave door for the first segment, and cave walls for the rest
            string wallProto = kbProtoUnitGetName(cUnitTypeCaveWall);
            
            int wallId = trUnitCreateForcedVector(wallProto, wallSpawn, 360 - (360.0 / wallSegments) * w);
            selectSingle(wallId);
            trUnitSetScale(0.75, 0.75, 0.75);
        }
    }
}

void createCornerCaves() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h = configMapBaseHeight;
    float cornerMargin = 0.08; 

    // Calculate corner position
    vector topCornerPos = vector(mapX * (1.0 - cornerMargin), h, mapZ * (1.0 - cornerMargin));

    // Build Cave structure
    buildCornerCave(topCornerPos);
}