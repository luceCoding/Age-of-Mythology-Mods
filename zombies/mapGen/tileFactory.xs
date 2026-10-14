const int numberOfTileSets = 2;
const int cDungeonDefaultRoomTileSetWeight = 100;
const int cDungeonGraveyardTileSetWeight = 5;

const int cDungeonDefaultRoomTileSetMinimumRooms = 0;
const int cDungeonTombTileSetMinimumRooms = 1;
const int cDungeonDefaultRoomTileSetMaximumRooms = cMaxInt;
const int cDungeonTombTileSetMaximumRooms = 1;

const float cDungeonTileSize = 9.0;
const int cDungeonConnectivityAttempts = 1000;
const int cDungeonMinimumReachablePercent = 80;
const int cBSPRoomWFCAttempts = 20;

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

int getDungeonRoomTileSetMinimumRooms(int tileSetIndex = 0) {
    if (tileSetIndex == 0) return cDungeonDefaultRoomTileSetMinimumRooms;
    if (tileSetIndex == 1) return cDungeonTombTileSetMinimumRooms;
    return 0;
}

int getDungeonRoomTileSetMaximumRooms(int tileSetIndex = 0) {
    if (tileSetIndex == 0) return cDungeonDefaultRoomTileSetMaximumRooms;
    if (tileSetIndex == 1) return cDungeonTombTileSetMaximumRooms;
    return 0;
}

Tile[] createDungeonRoomTileSet(int tileSetIndex = 0) {
    if (tileSetIndex == 0) return createDungeonDefaultTileTypes();
    if (tileSetIndex == 1) return createTombTileTypes();
    return new Tile(0);
}

int chooseDungeonRoomTileSet(ref int[] roomCounts) {
    int totalWeight = 0;
    for (int tileSetIndex = 0; tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int weight = getDungeonRoomTileSetWeight(tileSetIndex);
        int maximumRooms = getDungeonRoomTileSetMaximumRooms(tileSetIndex);
        if (weight > 0 && roomCounts[tileSetIndex] < maximumRooms) {
            totalWeight = totalWeight + weight;
        }
    }
    if (totalWeight <= 0) {
        errorLog("No dungeon tile sets have remaining room capacity and positive weight.");
        return -1;
    }

    int roll = xsRandInt(1, totalWeight);
    int cumulativeWeight = 0;
    for (int tileSetIndex = 0; tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int weight = getDungeonRoomTileSetWeight(tileSetIndex);
        int maximumRooms = getDungeonRoomTileSetMaximumRooms(tileSetIndex);
        if (weight <= 0 || roomCounts[tileSetIndex] >= maximumRooms) continue;
        cumulativeWeight = cumulativeWeight + weight;
        if (roll <= cumulativeWeight) return tileSetIndex;
    }
    return -1;
}

void writeTileToMap(ref Map map, ref Tile tile,
                    int startX = 0, int startZ = 0,
                    bool placeUnitsOnReservedCells = false) {
    int headingRotation = (4 - tile.rotation) % 4;
    int heading = headingRotation * 90;
    for (int position = 0; position < 9; position = position + 1) {
        int unitType = tile.getUnitAt(position);
        int column = position % 3;
        int row = position / 3;
        int x = startX + column;
        int z = startZ + row;
        bool isReserved = map.isReservedAt(x, z);
        if (isReserved
            && (placeUnitsOnReservedCells == false || unitType < 0)) {
            continue;
        }

        if (isReserved == false) {
            map.setPassableAt(x, z, tile.isPassableAt(position));
        }
        if (unitType < 0) continue;
        map.setUnitAt(x, z, unitType, heading, tile.getPlayerUnitAt(position));
    }
}

bool tileContainsEntranceSocket(ref Map map, int startX = 0, int startZ = 0) {
    for (int z = startZ; z < startZ + 3; z = z + 1) {
        for (int x = startX; x < startX + 3; x = x + 1) {
            if (map.getDataAt(x, z) == cMapDataEntranceSocket) return true;
        }
    }
    return false;
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
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall);
    solidWallTile.setPassability(
        false, false, false, false, false, false, false, false, false);
    solidWallTile.setSocketsAndWeight(
        cSocketWall, cSocketWall, cSocketWall, cSocketWall, 1);
    return solidWallTile;
}

int getRoomCenterTileIndex(ref Tile[] tileTypes) {
    int centerTileIndex = 0;
    bool foundCenterTile = false;
    for (int tileIndex = 0; tileIndex < tileTypes.size();
         tileIndex = tileIndex + 1) {
        Tile tile = tileTypes[tileIndex];
        if (tile.forceAtRoomCenter == false) continue;
        if (foundCenterTile) {
            errorLog("A room tile set cannot have multiple center-forced tiles.");
            return -1;
        }
        centerTileIndex = tileIndex;
        foundCenterTile = true;
    }
    return centerTileIndex;
}

void removeDuplicateRoomTiles(ref int[] tileMap, ref Tile[] tileTypes,
                              int centerMapIndex = -1) {
    for (int tileIndex = 0; tileIndex < tileTypes.size();
         tileIndex = tileIndex + 1) {
        Tile tile = tileTypes[tileIndex];
        if (tile.onlyOncePerRoom == false) continue;

        int keptMapIndex = -1;
        if (centerMapIndex >= 0 && tileMap[centerMapIndex] == tileIndex) {
            keptMapIndex = centerMapIndex;
        }
        for (int mapIndex = 0; mapIndex < tileMap.size();
             mapIndex = mapIndex + 1) {
            if (mapIndex == keptMapIndex || tileMap[mapIndex] != tileIndex) {
                continue;
            }
            if (keptMapIndex < 0) {
                keptMapIndex = mapIndex;
            } else {
                tileMap[mapIndex] = 0;
            }
        }
    }
}

bool generateRoomLayout(ref Map map,
                        ref Tile[] tileTypes, ref Tile[] validationTileTypes,
                        int roomLeft = 0, int roomTop = 0,
                        int roomRight = 0, int roomBottom = 0,
                        int roomCenterX = 0, int roomCenterZ = 0,
                        int solidWallTileIndex = -1) {
    int roomWidth = roomRight - roomLeft;
    int roomHeight = roomBottom - roomTop;
    int tilesWide = roomWidth / 3;
    int tilesHigh = roomHeight / 3;
    if (tilesWide <= 0 || tilesHigh <= 0) return false;
    int requestedCenterTileIndex = getRoomCenterTileIndex(tileTypes);
    if (requestedCenterTileIndex < 0) return false;

    int coveredWidth = tilesWide * 3;
    int coveredHeight = tilesHigh * 3;
    int startGridX = roomLeft + ((roomWidth - coveredWidth) / 2);
    int startGridZ = roomTop + ((roomHeight - coveredHeight) / 2);
    int centerX = (roomCenterX - startGridX) / 3;
    int centerY = (roomCenterZ - startGridZ) / 3;
    if (centerX < 0) centerX = 0;
    if (centerX >= tilesWide) centerX = tilesWide - 1;
    if (centerY < 0) centerY = 0;
    if (centerY >= tilesHigh) centerY = tilesHigh - 1;
    int centerMapIndex = (centerY * tilesWide) + centerX;

    WaveFunctionCollapse solver;
    if (solver.configure(
            tilesWide, tilesHigh, tileTypes, cSocketRoomEdge,
            centerMapIndex, requestedCenterTileIndex) == false) {
        return false;
    }
    int[] tileMap = new int(tilesWide * tilesHigh, -1);
    bool layoutFound = false;

    for (int attempt = 0; attempt < cBSPRoomWFCAttempts;
         attempt = attempt + 1) {
        if (solver.solve(100) == false) continue;

        for (int y = 0; y < tilesHigh; y = y + 1) {
            for (int x = 0; x < tilesWide; x = x + 1) {
                int mapIndex = (y * tilesWide) + x;
                int tileGridX = startGridX + (x * 3);
                int tileGridZ = startGridZ + (y * 3);
                if (tileContainsEntranceSocket(map, tileGridX, tileGridZ)) {
                    tileMap[mapIndex] = 0;
                } else {
                    tileMap[mapIndex] = solver.getTileIndexAt(x, y);
                }
            }
        }

        tileMap[centerMapIndex] = requestedCenterTileIndex;
        removeDuplicateRoomTiles(tileMap, tileTypes, centerMapIndex);

        if (filterDungeonLayoutConnectivity(
                tileMap, validationTileTypes,
                tilesWide, tilesHigh, solidWallTileIndex)) {
            if (tileMap[centerMapIndex] != requestedCenterTileIndex) continue;
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
        tileMap[centerMapIndex] = requestedCenterTileIndex;
        removeDuplicateRoomTiles(tileMap, tileTypes, centerMapIndex);
        if (filterDungeonLayoutConnectivity(
                tileMap, validationTileTypes,
                tilesWide, tilesHigh, solidWallTileIndex) == false
            || tileMap[centerMapIndex] != requestedCenterTileIndex) {
            errorLog("Requested BSP room center tile does not preserve room connectivity.");
            return false;
        }
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
            bool isForcedCenterTile = mapIndex == centerMapIndex
                && tile.forceAtRoomCenter;
            writeTileToMap(
                map, tile, tileGridX, tileGridZ, isForcedCenterTile);
        }
    }
    return true;
}

int g_bspTileRoomIndex = 0;
int[] g_bspTileSetByRoom = default;
bool g_bspTileGenerationComplete = false;

bool beginWaveFunctionCollapseToBSPRooms(ref Cell[] cells) {
    int minimumGuaranteedRooms = 0;
    int[] roomCounts = new int(getDungeonRoomTileSetCount(), 0);
    for (int tileSetIndex = 0;
         tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int minimumRooms = getDungeonRoomTileSetMinimumRooms(tileSetIndex);
        int maximumRooms = getDungeonRoomTileSetMaximumRooms(tileSetIndex);
        if (minimumRooms < 0 || maximumRooms < 0
            || minimumRooms > maximumRooms) {
            errorLog("Dungeon tile-set room limits must be nonnegative and minimum cannot exceed maximum.");
            return false;
        }
        minimumGuaranteedRooms = minimumGuaranteedRooms + minimumRooms;
    }
    if (minimumGuaranteedRooms > cells.size()) {
        errorLog("Guaranteed dungeon tile-set room counts exceed the available BSP rooms.");
        return false;
    }

    g_bspTileSetByRoom = new int(cells.size(), -1);
    int guaranteedRoomsAssigned = 0;
    for (int tileSetIndex = 0;
         tileSetIndex < getDungeonRoomTileSetCount();
         tileSetIndex = tileSetIndex + 1) {
        int minimumRooms = getDungeonRoomTileSetMinimumRooms(tileSetIndex);
        for (int guaranteedIndex = 0; guaranteedIndex < minimumRooms;
             guaranteedIndex = guaranteedIndex + 1) {
            int availableRooms = cells.size() - guaranteedRoomsAssigned;
            int roomChoice = xsRandInt(0, availableRooms - 1);
            int assignedRoomIndex = -1;
            for (int roomIndex = 0; roomIndex < cells.size();
                 roomIndex = roomIndex + 1) {
                if (g_bspTileSetByRoom[roomIndex] >= 0) continue;
                if (roomChoice == 0) {
                    assignedRoomIndex = roomIndex;
                    break;
                }
                roomChoice = roomChoice - 1;
            }
            if (assignedRoomIndex < 0) {
                errorLog("Failed to assign a guaranteed dungeon tile set.");
                return false;
            }
            g_bspTileSetByRoom[assignedRoomIndex] = tileSetIndex;
            guaranteedRoomsAssigned = guaranteedRoomsAssigned + 1;
            roomCounts[tileSetIndex] = roomCounts[tileSetIndex] + 1;
        }
    }

    for (int roomIndex = 0; roomIndex < cells.size();
         roomIndex = roomIndex + 1) {
        if (g_bspTileSetByRoom[roomIndex] >= 0) continue;
        int tileSetIndex = chooseDungeonRoomTileSet(roomCounts);
        if (tileSetIndex < 0) {
            errorLog("Dungeon tile-set maximum room counts leave rooms without an available tile set.");
            return false;
        }
        g_bspTileSetByRoom[roomIndex] = tileSetIndex;
        roomCounts[tileSetIndex] = roomCounts[tileSetIndex] + 1;
    }

    g_bspTileRoomIndex = 0;
    g_bspTileGenerationComplete = cells.size() == 0;
    return true;
}

bool generateNextBSPRoomLayout(ref Cell[] cells, ref Map map) {
    if (g_bspTileGenerationComplete) return true;

    int roomIndex = g_bspTileRoomIndex;
    Cell cell = cells[roomIndex];
    int tileSetIndex = g_bspTileSetByRoom[roomIndex];
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
    if (generateRoomLayout(
            map, tileTypes, validationTileTypes,
            cell.roomLeft, cell.roomTop, cell.roomRight, cell.roomBottom,
            cell.roomX, cell.roomZ, solidWallTileIndex) == false) {
        errorLog("Wave-function-collapse failed for BSP room " + roomIndex + ".");
        return false;
    }
    placeBSPRoomWalls(cell, map);
    map.placeRegion(
        cell.x, cell.z, cell.x + cell.width, cell.z + cell.height);

    g_bspTileRoomIndex = g_bspTileRoomIndex + 1;
    g_bspTileGenerationComplete = g_bspTileRoomIndex >= cells.size();
    if (g_bspTileGenerationComplete
        && placeBSPHallwayGates(map) == false) {
        errorLog("Failed to place BSP hallway gates.");
        return false;
    }
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
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
        cDefaultcUnitTypeWall);
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
    Map generatedMap;
    if (generatedMap.initialize(
            tilesWide * 3, tilesHigh * 3, 3.0, offsetX, offsetZ,
            configMapBaseHeight) == false) {
        return false;
    }
    for (int y = 0; y < tilesHigh; y = y + 1) {
        for (int x = 0; x < tilesWide; x = x + 1) {
            int mapIndex = (y * tilesWide) + x;
            int tileIndex = tileMap[mapIndex];
            if (tileIndex < 0) continue;

            Tile tile = tileTypes[tileIndex];
            writeTileToMap(generatedMap, tile, x * 3, y * 3);
        }
    }
    generatedMap.placeAll();
    return true;
}