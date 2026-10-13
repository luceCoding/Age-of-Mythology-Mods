const int numberOfTileSets = 1;
const int cDungeonDefaultRoomTileSetWeight = 100;
const int cDungeonGraveyardTileSetWeight = 5;

const float cDungeonTileSize = 9.0;
const int cDungeonConnectivityAttempts = 1000;
const int cDungeonMinimumReachablePercent = 80;

Tile[] createDungeonTileTypes() {
    return createDungeonDefaultTileTypes();
}

int getDungeonRoomTileSetCount() {
    return numberOfTileSets;
}

int getDungeonRoomTileSetWeight(int tileSetIndex = 0) {
    if (tileSetIndex == 0) return cDungeonDefaultRoomTileSetWeight;
    if (tileSetIndex == 1) return cDungeonGraveyardTileSetWeight;
    return 0;
}

Tile[] createDungeonRoomTileSet(int tileSetIndex = 0) {
    if (tileSetIndex == 0) return createDungeonDefaultTileTypes();
    if (tileSetIndex == 1) return createGraveyardTileTypes();
    return new Tile(0);
}

int chooseDungeonRoomTileSet() {
    int totalWeight = 0;
    for (int tileSetIndex = 0; tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int weight = getDungeonRoomTileSetWeight(tileSetIndex);
        if (weight > 0) totalWeight = totalWeight + weight;
    }
    if (totalWeight <= 0) {
        errorLog("No dungeon room tile sets have a positive weight.");
        return -1;
    }

    int roll = xsRandInt(1, totalWeight);
    int cumulativeWeight = 0;
    for (int tileSetIndex = 0; tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int weight = getDungeonRoomTileSetWeight(tileSetIndex);
        if (weight <= 0) continue;
        cumulativeWeight = cumulativeWeight + weight;
        if (roll <= cumulativeWeight) return tileSetIndex;
    }
    return -1;
}

void placeDungeonTile(ref Tile tile, float tileX = 0.0, float tileZ = 0.0,
                      float height = 0.0) {
    float heading = tile.rotation * 90.0;
    for (int position = 0; position < 9; position = position + 1) {
        int unitType = tile.getUnitAt(position);
        if (unitType < 0) continue;
        int owner = tile.getPlayerUnitAt(position);

        int column = position % 3;
        int row = position / 3;
        float x = tileX + 1.5 + (column * 3.0);
        float z = tileZ + 1.5 + (row * 3.0);
        int unitId = trUnitCreateForced(kbProtoUnitGetName(unitType), x, height, z, heading, owner);
    }
}

bool isDungeonPositionPassable(ref int[] tileMap, ref Tile[] tileTypes,
                               int tilesWide = 0, int microX = 0, int microY = 0) {
    int tileX = microX / 3;
    int tileY = microY / 3;
    int mapIndex = tileY * tilesWide + tileX;
    int tileIndex = tileMap[mapIndex];
    if (tileIndex < 0 || tileIndex >= tileTypes.size()) return false;

    Tile tile = tileTypes[tileIndex];
    int localX = microX - (tileX * 3);
    int localY = microY - (tileY * 3);
    int position = (localY * 3) + localX;
    return tile.isPassableAt(position);
}

bool filterDungeonLayoutConnectivity(ref int[] tileMap, ref Tile[] tileTypes,
                                      int tilesWide = 0, int tilesHigh = 0,
                                      int solidWallTileIndex = -1) {
    int microWidth = tilesWide * 3;
    int microHeight = tilesHigh * 3;
    int microCellCount = microWidth * microHeight;
    int originalPassableCellCount = -1;

    while (true) {
        bool[] visited = new bool(microCellCount, false);
        int[] queue = new int(0, -1);
        int startCell = -1;
        int passableCellCount = 0;

        for (int microY = 0; microY < microHeight; microY = microY + 1) {
            for (int microX = 0; microX < microWidth; microX = microX + 1) {
                if (isDungeonPositionPassable(tileMap, tileTypes, tilesWide, microX, microY)) {
                    int cell = (microY * microWidth) + microX;
                    if (startCell == -1) startCell = cell;
                    passableCellCount = passableCellCount + 1;
                }
            }
        }

        if (startCell == -1) return false;
        if (originalPassableCellCount == -1) {
            originalPassableCellCount = passableCellCount;
        }

        visited[startCell] = true;
        queue.add(startCell);
        int reachableCellCount = 1;
        int queuePosition = 0;

        while (queuePosition < queue.size()) {
            int cell = queue[queuePosition];
            queuePosition = queuePosition + 1;
            int x = cell % microWidth;
            int y = cell / microWidth;

            for (int direction = cSocketNorth; direction <= cSocketWest;
                 direction = direction + 1) {
                int neighborX = x;
                int neighborY = y;
                if (direction == cSocketNorth) neighborY = neighborY - 1;
                if (direction == cSocketEast) neighborX = neighborX + 1;
                if (direction == cSocketSouth) neighborY = neighborY + 1;
                if (direction == cSocketWest) neighborX = neighborX - 1;
                if (neighborX < 0 || neighborX >= microWidth
                    || neighborY < 0 || neighborY >= microHeight) continue;

                int neighbor = (neighborY * microWidth) + neighborX;
                if (visited[neighbor]) continue;
                if (isDungeonPositionPassable(
                        tileMap, tileTypes, tilesWide, neighborX, neighborY) == false) continue;

                visited[neighbor] = true;
                queue.add(neighbor);
                reachableCellCount = reachableCellCount + 1;
            }
        }

        if (reachableCellCount * 100
            < originalPassableCellCount * cDungeonMinimumReachablePercent) return false;

        bool[] isolatedTiles = new bool(tilesWide * tilesHigh, false);
        bool foundIsolatedTile = false;
        for (int tileY = 0; tileY < tilesHigh; tileY = tileY + 1) {
            for (int tileX = 0; tileX < tilesWide; tileX = tileX + 1) {
                int mapIndex = (tileY * tilesWide) + tileX;
                bool hasPassablePosition = false;
                bool hasUnreachablePosition = false;

                for (int localY = 0; localY < 3; localY = localY + 1) {
                    for (int localX = 0; localX < 3; localX = localX + 1) {
                        int microX = (tileX * 3) + localX;
                        int microY = (tileY * 3) + localY;
                        if (isDungeonPositionPassable(
                                tileMap, tileTypes, tilesWide, microX, microY) == false) continue;

                        hasPassablePosition = true;
                        int cell = (microY * microWidth) + microX;
                        if (visited[cell] == false) hasUnreachablePosition = true;
                    }
                }

                if (hasPassablePosition && hasUnreachablePosition) {
                    isolatedTiles[mapIndex] = true;
                    foundIsolatedTile = true;
                }
            }
        }

        if (foundIsolatedTile == false) return true;

        for (int mapIndex = 0; mapIndex < isolatedTiles.size();
             mapIndex = mapIndex + 1) {
            if (isolatedTiles[mapIndex]) tileMap[mapIndex] = solidWallTileIndex;
        }
    }
    return false;
}

Tile createDungeonSolidWallTile() {
    Tile solidWallTile;
    solidWallTile.setUnits(
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall,
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall,
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall);
    solidWallTile.setPassability(
        false, false, false, false, false, false, false, false, false);
    solidWallTile.setSocketsAndWeight(
        cSocketWall, cSocketWall, cSocketWall, cSocketWall, 1);
    return solidWallTile;
}

void reserveBSPSpawnPair(ref int[] tileMap, int tilesWide = 0,
                         int tilesHigh = 0, int startGridX = 0,
                         int startGridZ = 0) {
    bool horizontalPair = tilesWide >= 2;
    if (tilesWide < 2) horizontalPair = false;
    else if (tilesHigh >= 2) horizontalPair = xsRandInt(0, 1) == 0;

    int spawnTileX = 0;
    int spawnTileY = 0;
    int firstSpawnTileIndex = -1;
    int secondSpawnTileIndex = -1;
    float zombieWorldX = 0.0;
    float zombieWorldZ = 0.0;
    float humanWorldX = 0.0;
    float humanWorldZ = 0.0;
    if (horizontalPair) {
        spawnTileX = xsRandInt(0, tilesWide - 2);
        spawnTileY = xsRandInt(0, tilesHigh - 1);
        firstSpawnTileIndex = (spawnTileY * tilesWide) + spawnTileX;
        secondSpawnTileIndex = firstSpawnTileIndex + 1;
        zombieWorldX = xsIntToFloat(startGridX + (spawnTileX * 3))
            * cBSPCellSpacing + 4.5;
        humanWorldX = zombieWorldX + 9.0;
        zombieWorldZ = xsIntToFloat(startGridZ + (spawnTileY * 3))
            * cBSPCellSpacing + 4.5;
        humanWorldZ = zombieWorldZ;
    } else {
        spawnTileX = xsRandInt(0, tilesWide - 1);
        spawnTileY = xsRandInt(0, tilesHigh - 2);
        firstSpawnTileIndex = (spawnTileY * tilesWide) + spawnTileX;
        secondSpawnTileIndex = firstSpawnTileIndex + tilesWide;
        zombieWorldX = xsIntToFloat(startGridX + (spawnTileX * 3))
            * cBSPCellSpacing + 4.5;
        humanWorldX = zombieWorldX;
        zombieWorldZ = xsIntToFloat(startGridZ + (spawnTileY * 3))
            * cBSPCellSpacing + 4.5;
        humanWorldZ = zombieWorldZ + 9.0;
    }

    tileMap[firstSpawnTileIndex] = 0;
    tileMap[secondSpawnTileIndex] = 0;
    g_bspZombieSpawnLocation = vector(
        zombieWorldX, configMapBaseHeight, zombieWorldZ);
    g_bspHumanSpawnLocation = vector(
        humanWorldX, configMapBaseHeight, humanWorldZ);
}

void placeBSPRoomTile(ref Tile tile, ref bool[] hallwayCells,
                      int startGridX = 0, int startGridZ = 0,
                      float height = 0.0, int gridWidth = 0) {
    float heading = tile.rotation * 90.0;
    for (int position = 0; position < 9; position = position + 1) {
        int unitType = tile.getUnitAt(position);
        if (unitType < 0) continue;

        int column = position % 3;
        int row = position / 3;
        int gridX = startGridX + column;
        int gridZ = startGridZ + row;
        int gridIndex = (gridZ * gridWidth) + gridX;
        if (hallwayCells[gridIndex]) continue;

        int owner = tile.getPlayerUnitAt(position);
        float worldX = xsIntToFloat(gridX) * cBSPCellSpacing;
        float worldZ = xsIntToFloat(gridZ) * cBSPCellSpacing;
        trUnitCreateForced(
            kbProtoUnitGetName(unitType), worldX + 1.5, height,
            worldZ + 1.5, heading, owner);
    }
}

bool generateBSPRoomLayout(ref Cell cell, ref bool[] hallwayCells,
                           ref Tile[] tileTypes, ref Tile[] validationTileTypes,
                           int solidWallTileIndex = -1,
                           int gridWidth = 0,
                           bool reserveSpawnArea = false) {
    int roomWidth = cell.roomRight - cell.roomLeft;
    int roomHeight = cell.roomBottom - cell.roomTop;
    int tilesWide = roomWidth / 3;
    int tilesHigh = roomHeight / 3;
    if (tilesWide <= 0 || tilesHigh <= 0) return false;

    int coveredWidth = tilesWide * 3;
    int coveredHeight = tilesHigh * 3;
    int startGridX = cell.roomLeft + ((roomWidth - coveredWidth) / 2);
    int startGridZ = cell.roomTop + ((roomHeight - coveredHeight) / 2);

    WaveFunctionCollapse solver;
    if (solver.configure(tilesWide, tilesHigh, tileTypes) == false) return false;
    int[] tileMap = new int(tilesWide * tilesHigh, -1);
    bool layoutFound = false;

    for (int attempt = 0; attempt < cBSPRoomWFCAttempts;
         attempt = attempt + 1) {
        if (solver.solve(100) == false) continue;

        for (int y = 0; y < tilesHigh; y = y + 1) {
            for (int x = 0; x < tilesWide; x = x + 1) {
                int mapIndex = (y * tilesWide) + x;
                tileMap[mapIndex] = solver.getTileIndexAt(x, y);
            }
        }

        int centerX = (cell.roomX - startGridX) / 3;
        int centerY = (cell.roomZ - startGridZ) / 3;
        if (centerX < 0) centerX = 0;
        if (centerX >= tilesWide) centerX = tilesWide - 1;
        if (centerY < 0) centerY = 0;
        if (centerY >= tilesHigh) centerY = tilesHigh - 1;
        int centerMapIndex = (centerY * tilesWide) + centerX;
        tileMap[centerMapIndex] = 0;

        if (filterDungeonLayoutConnectivity(
                tileMap, validationTileTypes,
                tilesWide, tilesHigh, solidWallTileIndex)) {
            layoutFound = true;
            break;
        }
    }
    if (layoutFound == false) {
        errorLog("Wave-function-collapse exhausted retries for BSP room; using an open layout.");
        for (int mapIndex = 0; mapIndex < tileMap.size();
             mapIndex = mapIndex + 1) {
            tileMap[mapIndex] = 0;
        }
    }

    if (reserveSpawnArea) {
        reserveBSPSpawnPair(
            tileMap, tilesWide, tilesHigh, startGridX, startGridZ);
    }

    for (int y = 0; y < tilesHigh; y = y + 1) {
        for (int x = 0; x < tilesWide; x = x + 1) {
            int mapIndex = (y * tilesWide) + x;
            int tileIndex = tileMap[mapIndex];
            if (tileIndex < 0 || tileIndex >= validationTileTypes.size()) {
                return false;
            }

            Tile tile = validationTileTypes[tileIndex];
            int tileGridX = startGridX + (x * 3);
            int tileGridZ = startGridZ + (y * 3);
            placeBSPRoomTile(
                tile, hallwayCells, tileGridX, tileGridZ,
                configMapBaseHeight, gridWidth);
        }
    }
    return true;
}

int g_bspTileRoomIndex = 0;
int g_bspTileSpawnRoomIndex = -1;
bool g_bspTileGenerationComplete = false;

bool beginWaveFunctionCollapseToBSPRooms(ref Cell[] cells) {
    int[] spawnRoomIndices = new int(0, -1);
    for (int roomIndex = 0; roomIndex < cells.size();
         roomIndex = roomIndex + 1) {
        Cell cell = cells[roomIndex];
        int roomWidth = (cell.roomRight - cell.roomLeft) / 3;
        int roomHeight = (cell.roomBottom - cell.roomTop) / 3;
        if (roomWidth >= 2 || roomHeight >= 2) {
            spawnRoomIndices.add(roomIndex);
        }
    }
    if (spawnRoomIndices.size() < 2) {
        errorLog("Cannot choose separate human and zombie spawn rooms.");
        return false;
    }
    int spawnRoomChoice = xsRandInt(0, spawnRoomIndices.size() - 1);
    g_bspTileSpawnRoomIndex = spawnRoomIndices[spawnRoomChoice];
    g_bspTileRoomIndex = 0;
    g_bspTileGenerationComplete = cells.size() == 0;
    return true;
}

bool generateNextBSPRoomLayout(ref Cell[] cells,
                               ref bool[] hallwayCells,
                               int gridWidth = 0) {
    if (g_bspTileGenerationComplete) return true;

    int roomIndex = g_bspTileRoomIndex;
    Cell cell = cells[roomIndex];
    int tileSetIndex = chooseDungeonRoomTileSet();
    if (tileSetIndex < 0) return false;
    Tile[] tileTypes = createDungeonRoomTileSet(tileSetIndex);
    Tile[] validationTileTypes = createDungeonRoomTileSet(tileSetIndex);
    if (tileTypes.size() == 0 || validationTileTypes.size() == 0) {
        errorLog("Dungeon room tile set " + tileSetIndex + " is empty.");
        return false;
    }
    int solidWallTileIndex = validationTileTypes.size();
    Tile solidWallTile = createDungeonSolidWallTile();
    validationTileTypes.add(solidWallTile);
    if (generateBSPRoomLayout(
            cell, hallwayCells, tileTypes, validationTileTypes,
            solidWallTileIndex, gridWidth,
            roomIndex == g_bspTileSpawnRoomIndex) == false) {
        errorLog("Wave-function-collapse failed for BSP room " + roomIndex + ".");
        return false;
    }
    placeBSPRoomWalls(cell);

    g_bspTileRoomIndex = g_bspTileRoomIndex + 1;
    g_bspTileGenerationComplete = g_bspTileRoomIndex >= cells.size();
    return true;
}

bool generateDungeonMap() {
    float mapWidth = configMapTileX * 2.0;
    float mapHeight = configMapTileZ * 2.0;
    int tilesWide = xsFloatToInt(mapWidth / cDungeonTileSize);
    int tilesHigh = xsFloatToInt(mapHeight / cDungeonTileSize);
    if (tilesWide <= 0 || tilesHigh <= 0) return false;

    Tile[] tileTypes = createDungeonTileTypes();
    WaveFunctionCollapse solver;
    if (solver.configure(tilesWide, tilesHigh, tileTypes) == false) return false;

    int solidWallTileIndex = tileTypes.size();
    Tile solidWallTile;
    solidWallTile.setUnits(
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall,
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall,
        defaultcUnitTypeWall, defaultcUnitTypeWall,
        defaultcUnitTypeWall);
    solidWallTile.setPassability(false, false, false, false, false, false, false, false, false);
    solidWallTile.setSocketsAndWeight(
        cSocketWall, cSocketWall,
        cSocketWall, cSocketWall, 1);
    tileTypes.add(solidWallTile);

    bool connectedLayoutFound = false;
    int[] tileMap = new int(tilesWide * tilesHigh, -1);
    for (int attempt = 0; attempt < cDungeonConnectivityAttempts;
         attempt = attempt + 1) {
        if (solver.solve() == false) continue;
        for (int y = 0; y < tilesHigh; y = y + 1) {
            for (int x = 0; x < tilesWide; x = x + 1) {
                int mapIndex = (y * tilesWide) + x;
                tileMap[mapIndex] = solver.getTileIndexAt(x, y);
            }
        }
        if (filterDungeonLayoutConnectivity(
                tileMap, tileTypes, tilesWide, tilesHigh, solidWallTileIndex)) {
            connectedLayoutFound = true;
            log(-1, "Dungeon generation found after " + xsIntToString((attempt + 1)) + " attempts.");
            break;
        }
    }
    if (connectedLayoutFound == false) {
        errorLog("Dungeon generation failed to find a connected layout after " + cDungeonConnectivityAttempts + " attempts. Unlucky, please rehost.");
        return false;
    }

    float offsetX = (mapWidth - (tilesWide * cDungeonTileSize)) * 0.5;
    float offsetZ = (mapHeight - (tilesHigh * cDungeonTileSize)) * 0.5;
    for (int y = 0; y < tilesHigh; y = y + 1) {
        for (int x = 0; x < tilesWide; x = x + 1) {
            int mapIndex = (y * tilesWide) + x;
            int tileIndex = tileMap[mapIndex];
            if (tileIndex < 0) continue;

            float tileX = offsetX + (x * cDungeonTileSize);
            float tileZ = offsetZ + (y * cDungeonTileSize);
            Tile tile = tileTypes[tileIndex];
            placeDungeonTile(tile, tileX, tileZ, configMapBaseHeight);
        }
    }
    return true;
}