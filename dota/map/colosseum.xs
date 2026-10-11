void buildCornerColosseum(vector centerPos = cInvalidVector) {
    float mapMaxX = configMapTileX * 2.0;
    float mapMaxZ = configMapTileZ * 2.0;
    float margin = 2.0; // Keep slightly inside the absolute edge

    // ------------------------------------------
    // TERRAIN TERRACES (Amphitheater Pit)
    // Only paint if the center/radii are safely inside
    // ------------------------------------------
    paintCircle(centerPos, 35.0, g_colosseumRoadTypes[0]);
    paintCircle(centerPos, 33.0, g_colosseumRoadTypes[1]);

    // ------------------------------------------
    // PERIMETER WALLS (With Map Boundary Check)
    // ------------------------------------------
    int wallSegments = 36; // Divisible by 3 for 2:1 short/connector ratio
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
            
            // Pattern: 2 short walls for every 1 connector
            string wallProto = (w % 3 == 0) ? kbProtoUnitGetName(cUnitTypeWallOfTroyConnector) : kbProtoUnitGetName(cUnitTypeWallOfTroyShort);
            
            int wallId = trUnitCreateForcedVector(wallProto, wallSpawn, 360 - (360.0 / wallSegments) * w);
            selectSingle(wallId);
            trUnitSetScale(1.0, 1.0, 1.0);
        }
    }
}

void createCornerColosseums() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h = configMapBaseHeight;
    float cornerMargin = 0.08; 

    // Calculate Top and Bottom corner positions
    vector botCornerPos = vector(mapX * cornerMargin, h, mapZ * cornerMargin);

    // Build Colosseum at both locations
    buildCornerColosseum(botCornerPos);
}