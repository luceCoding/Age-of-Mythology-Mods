int __getMapSizeX(){
    xsSetContextPlayer(0);
    return kbGetMapXSize();
}

int __getMapSizeZ(){
    xsSetContextPlayer(0);
    return kbGetMapZSize();
}

int __getMapSizeTilesX(){
    xsSetContextPlayer(0);
    return kbGetMapXSize() / 2.0;
}

int __getMapSizeTilesZ(){
    xsSetContextPlayer(0);
    return kbGetMapZSize() / 2.0;
}

void __worldSmooth(int fromTilesX = 0, int fromTilesZ = 0, int toTilesX = 0, int toTilesZ = 0, bool outsideInfluence = false, int count = 1){
    int tilesWidth = toTilesX - fromTilesX;
    int tilesHeight = toTilesZ - fromTilesZ;
    float[] heightLowerZ = new float(1 + tilesWidth, 0.0);
    float heightLowerX = 0.0;
    vector v = cOriginVector;
    float workingHeight = 0.0;
    int mapSizeX = __getMapSizeX();
    int mapSizeZ = __getMapSizeZ();
    for(int iteration = 0; iteration < count; iteration++){
        v = vector(fromTilesX * 2.0, 0.0, max(0.0, (outsideInfluence ? fromTilesZ - 1 : fromTilesZ) * 2.0));
        for(int x = 0; x <= tilesWidth; x++){
            v.x = (x + fromTilesX) * 2.0;
            heightLowerZ[x] = trGetTerrainHeight(v);
        }
        for(int z = 0; z <= tilesHeight; z++){
            v.x = max(0.0, (outsideInfluence ? fromTilesX - 1: fromTilesX) * 2.0);
            v.z = (z + fromTilesZ) * 2.0;
            heightLowerX = trGetTerrainHeight(v);
            workingHeight = 0.0;
                for(int x = 0; x <= tilesWidth; x++){
                    workingHeight = heightLowerX;
                    v.x = (x + fromTilesX) * 2.0;
                    v.z = (z + fromTilesZ) * 2.0;
                    heightLowerX = trGetTerrainHeight(v);
                    workingHeight = workingHeight + 4.0 * heightLowerX;
                    workingHeight = workingHeight + heightLowerZ[x];
                    heightLowerZ[x] = heightLowerX;
                    v.x = min((outsideInfluence ? (x + 1 + fromTilesX) : min(x + 1 + fromTilesX, toTilesX)) * 2.0, mapSizeX);
                    workingHeight = workingHeight + trGetTerrainHeight(v);
                    v.x = (x + fromTilesX) * 2.0;
                    v.z = min((outsideInfluence ? (z + 1 + fromTilesZ) : min(z + 1 + fromTilesZ, toTilesZ)) * 2.0, mapSizeZ);
                    workingHeight = workingHeight + trGetTerrainHeight(v);
                    trChangeTerrainHeight((x + fromTilesX) * 2.0, (z + fromTilesZ) * 2.0, (x + fromTilesX) * 2.0, (z + fromTilesZ) * 2.0, workingHeight / 8.0);
            }
        }
    }
}

int trUnitCreateForcedVector(string unit = "error", vector pos = cOriginVector, float heading = 0, int player = 0, bool skip = false){
    float x = pos.x;
    float y = pos.y;
    float z = pos.z;
    int ret = trUnitCreateForced(unit, x,y,z,heading,player, skip);
    return(ret);
}

vector rotationMatrix(vector v = vector(0,0,0), float cosT = 0, float sinT = 0) {
    float x = v.x;
    float z = v.z;
    vector done = vector(x * cosT - z * sinT, 0, x * sinT + z * cosT);
    return(done);
}

int calculateTerrainTypeId(string name = ""){
    vector v = cOriginVector;
    int old = trGetTerrainType(v);
    int oldSub = trGetTerrainSubtype(v);
    trPaintTerrainBySubtypeName(name, 0, 0, 0, 0, false);
    int foundType = trGetTerrainType(v);
    trPaintTerrain(old, oldSub, 0, 0, 0, 0, false);
    return foundType;
}

int calculateSubTerrainTypeId(string name = ""){
    vector v = cOriginVector;
    int old = trGetTerrainType(v);
    int oldSub = trGetTerrainSubtype(v);
    trPaintTerrainBySubtypeName(name, 0, 0, 0, 0, false);
    int foundType = trGetTerrainSubtype(v);
    trPaintTerrain(old, oldSub, 0, 0, 0, 0, false);
    return foundType;
}

void paintCircle(vector pos = cOriginVector, float radius = 0, string terrain = ""){
    int terrainType = calculateTerrainTypeId(terrain);
    int terrainSubType = calculateSubTerrainTypeId(terrain);
    float tempMinX = max(0.0 - pos.x, 0.0 - radius);
    float tempMinZ = max(0.0 - pos.z, 0.0 - radius);
    float tempMaxX = min(800 - pos.x, radius);
    float tempMaxZ = min(800 - pos.z, radius);
    float tempRadiusCheck = radius * radius + radius;
    for(float tempZ = tempMaxZ; tempZ >= tempMinZ; tempZ = tempZ - 2.0){
        for(float tempX = tempMaxX; tempX >= tempMinX; tempX = tempX - 2.0){
            if(tempRadiusCheck >= (tempX*tempX + tempZ*tempZ)){
                trPaintTerrain(terrainType, terrainSubType, tempX + pos.x, tempZ + pos.z, tempX + pos.x, tempZ + pos.z, false);
            }
        }
    }
}

void updateTerrainObstructions(){
    int __worldMapSizeXPassibility = __getMapSizeX();
    int __worldMapSizeZPassibility = __getMapSizeZ();
    vector __worldPositionPassibility = vector(0.0, 0.0, 0.0);
    for(int z = 0; z <= __worldMapSizeXPassibility; z = z + 2) {
        __worldPositionPassibility.z = z;
        for(int x = 0; x <= __worldMapSizeZPassibility; x = x + 2) {
            __worldPositionPassibility.x = x;
            trChangeTerrainHeight(x, z, x, z, trGetTerrainHeight(__worldPositionPassibility));
        }
    }
    trPaintTerrain(trGetTerrainType(cOriginVector), trGetTerrainSubtype(cOriginVector), 0, 0, 0, 0, true);
}