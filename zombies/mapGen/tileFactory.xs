const float cDungeonTileSize = 9.0;
const int cDungeonConnectivityAttempts = 1000;
const int cDungeonMinimumReachablePercent = 80;

const int cOpenTileWeight = 256;
const int cSingleWallTileWeight = 512;
const int ctBoneWallTileWeight = 32;
const int cCornerWeight = 64;
const int cLargeOpenTileWeight = 16;
const int cCrossTileWeight = 32;

Tile[] createDungeonTileTypes() {
    Tile[] tileTypes = new Tile(0);

    {
        Tile openTile;
        openTile.setUnits(
            -1, -1, -1, 
            -1, -1, -1, 
            -1, -1, -1);
        openTile.setPassability(
            true, true, true, 
            true, true, true, 
            true, true, true);
        openTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketTypeAny, cSocketTypeAny,
            cOpenTileWeight);
        tileTypes.add(openTile);
    }

    {
        Tile singleWallTile;
        singleWallTile.setUnits(
            -1, -1, -1,
            cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisLong, cUnitTypeWallOfAtlantisConnector,
            -1, -1, -1);
        singleWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, true, true);
        singleWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketOpen, cSocketTypeWallOrEntrance, cSingleWallTileWeight);
        tileTypes.add(singleWallTile);
        Tile rotatedWall = rotateMapTileClockwise(singleWallTile);
        tileTypes.add(rotatedWall);
    }

    {
        Tile tBoneWallTile;
        tBoneWallTile.setUnits(
            -1, -1, -1,
            cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
            -1, cUnitTypeWallOfAtlantisConnector, -1);
        tBoneWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, false, true);
        tBoneWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, ctBoneWallTileWeight);
        tileTypes.add(tBoneWallTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedWall = rotateMapTileClockwise(tBoneWallTile);
            tileTypes.add(rotatedWall);
            tBoneWallTile = rotatedWall;
        }
    }

    {
        Tile cornerTile;
        cornerTile.setUnits(
            -1, -1, -1,
            -1, cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
            -1, cUnitTypeWallOfAtlantisConnector, -1);
        cornerTile.setPassability(
            true, true, true,
            true, false, false,
            true, false, true);
        cornerTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketOpen, cCornerWeight);
        tileTypes.add(cornerTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedWall = rotateMapTileClockwise(cornerTile);
            tileTypes.add(rotatedWall);
            cornerTile = rotatedWall;
        }
    }

    {
        Tile largeOpenTile;
        largeOpenTile.setUnits(
            -1, -1, -1, 
            -1, -1, -1, 
            -1, -1, -1);
        largeOpenTile.setPassability(
            true, true, true, 
            true, true, true, 
            true, true, true);
        largeOpenTile.setSocketsAndWeight(
            cSocketOpen, cSocketOpen, cSocketOpen, cSocketOpen, cLargeOpenTileWeight);
        tileTypes.add(largeOpenTile);
    }

    {
        Tile crossTile;
        crossTile.setUnits(
            -1, cUnitTypeWallOfAtlantisConnector, -1, 
            cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector, 
            -1, cUnitTypeWallOfAtlantisConnector, -1);
        crossTile.setPassability(
            true, false, true, 
            false, false, false, 
            true, false, true);
        crossTile.setSocketsAndWeight(
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, cCrossTileWeight);
        tileTypes.add(crossTile);
    }

    {
        for (int i = 0; i < g_humanInteractableTypes.size(); i = i + 1){
            int interactableType = g_humanInteractableTypes[i];
            Tile interactableTile;
            interactableTile.setUnits(
                -1, -1, -1,
                -1, interactableType, -1,
                -1, -1, -1);
            interactableTile.setPassability(
                true, true, true,
                true, false, true,
                true, true, true);
            interactableTile.setSocketsAndWeight(
                cSocketInteractable, cSocketInteractable,
                cSocketInteractable, cSocketInteractable, i+1);
            interactableTile.setPlayerUnit(4, cHumanAIPlayer);
            tileTypes.add(interactableTile);
            for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
                Tile rotatedWall = rotateMapTileClockwise(interactableTile);
                tileTypes.add(rotatedWall);
                interactableTile = rotatedWall;
            }
        }
    }

    return tileTypes;
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
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector);
    solidWallTile.setPassability(
        false, false, false, false, false, false, false, false, false);
    solidWallTile.setSocketsAndWeight(
        cSocketWall, cSocketWall, cSocketWall, cSocketWall, 1);
    return solidWallTile;
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
                           int gridWidth = 0) {
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

bool applyWaveFunctionCollapseToBSPRooms(ref Cell[] cells,
                                         ref bool[] hallwayCells,
                                         int gridWidth = 0) {
    Tile[] tileTypes = createDungeonTileTypes();
    Tile[] validationTileTypes = createDungeonTileTypes();
    int solidWallTileIndex = validationTileTypes.size();
    Tile solidWallTile = createDungeonSolidWallTile();
    validationTileTypes.add(solidWallTile);

    for (int roomIndex = 0; roomIndex < cells.size();
         roomIndex = roomIndex + 1) {
        Cell cell = cells[roomIndex];
        if (generateBSPRoomLayout(
                cell, hallwayCells, tileTypes, validationTileTypes,
                solidWallTileIndex, gridWidth) == false) {
            errorLog("Wave-function-collapse failed for BSP room " + roomIndex + ".");
            return false;
        }
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
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
        cUnitTypeWallOfAtlantisConnector);
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