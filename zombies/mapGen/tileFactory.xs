const float cDungeonTileSize = 9.0;
const int cDungeonWallPlayer = 0;
const int cDungeonConnectivityAttempts = 1000;
const int cDungeonMinimumReachablePercent = 80;

const int cOpenTileWeight = 14;
const int cSingleNorthWallWeight = 10;
const int cHallwayWeight = 8;
const int cTboneWallWeight = 2;

Tile[] createDungeonTileTypes() {
    Tile[] tileTypes = new Tile(0);
    Tile openTile;
    openTile.setUnits(-1, -1, -1, -1, -1, -1, -1, -1, -1);
    openTile.setPassability(true, true, true, true, true, true, true, true, true);
    openTile.setSocketsAndWeight(
        cSocketTypeOpenOrWall, cSocketTypeOpenOrWall,
        cSocketTypeOpenOrWall, cSocketTypeOpenOrWall, cOpenTileWeight);
    tileTypes.add(openTile);

    {
        Tile singleNorthWall;
        singleNorthWall.setUnits(
            cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
            -1, -1, -1,
            -1, -1, -1);
        singleNorthWall.setPassability(
            false, false, false,
            true, true, true,
            true, true, true);
        singleNorthWall.setSocketsAndWeight(
            cSocketTypeOpenOrWall, cSocketTypeOpen, cSocketTypeOpen, cSocketTypeOpen, cSingleNorthWallWeight);
        tileTypes.add(singleNorthWall);
        for (int rotation = 0; rotation < 3; rotation++) {
            Tile rotatedWall = rotateMapTileClockwise(singleNorthWall);
            tileTypes.add(rotatedWall);
            singleNorthWall = rotatedWall;
        }
    }

    {
        Tile hallway;
        hallway.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, -1, -1);
        hallway.setPassability(
            false, false, false,
            true, true, true,
            false, false, false);
        hallway.setSocketsAndWeight(
            cSocketTypeWall, cSocketTypeOpen, cSocketTypeWall, cSocketTypeOpen, cHallwayWeight);
        tileTypes.add(hallway);
        Tile rotatedWall = rotateMapTileClockwise(hallway);
        tileTypes.add(rotatedWall);
    }

    {
        Tile tboneWall;
        tboneWall.setUnits(
            cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector, cUnitTypeWallOfAtlantisConnector,
            -1, cUnitTypeWallOfAtlantisConnector, -1,
            -1, cUnitTypeWallOfAtlantisConnector, -1);
        tboneWall.setPassability(
            false, false, false,
            true, false, true,
            true, false, true);
        tboneWall.setSocketsAndWeight(
            cSocketTypeOpenOrWall, cSocketTypeOpen, cSocketTypeHallwayOrOpenOrWall, cSocketTypeOpen, cTboneWallWeight);
        tileTypes.add(tboneWall);
        for (int rotation = 0; rotation < 3; rotation++) {
            Tile rotatedWall = rotateMapTileClockwise(tboneWall);
            tileTypes.add(rotatedWall);
            tboneWall = rotatedWall;
        }
    }

    return tileTypes;
}

void placeDungeonTile(ref Tile tile, float tileX = 0.0, float tileZ = 0.0,
                      float height = 0.0) {
    float heading = tile.rotation * 90.0;
    for (int position = 0; position < 9; position++) {
        int unitType = tile.getUnitAt(position);
        if (unitType < 0) continue;

        int column = position % 3;
        int row = position / 3;
        float x = tileX + 1.5 + (column * 3.0);
        float z = tileZ + 1.5 + (row * 3.0);
        int unitId = trUnitCreateForced(kbProtoUnitGetName(unitType), x, height, z, heading, cDungeonWallPlayer);
        if (unitType == cUnitTypeWallOfAtlantisConnector) {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
        }
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

        for (int microY = 0; microY < microHeight; microY++) {
            for (int microX = 0; microX < microWidth; microX++) {
                if (isDungeonPositionPassable(tileMap, tileTypes, tilesWide, microX, microY)) {
                    int cell = (microY * microWidth) + microX;
                    if (startCell == -1) startCell = cell;
                    passableCellCount++;
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
            queuePosition++;
            int x = cell % microWidth;
            int y = cell / microWidth;

            for (int direction = cSocketNorth; direction <= cSocketWest; direction++) {
                int neighborX = x;
                int neighborY = y;
                if (direction == cSocketNorth) neighborY--;
                if (direction == cSocketEast) neighborX++;
                if (direction == cSocketSouth) neighborY++;
                if (direction == cSocketWest) neighborX--;
                if (neighborX < 0 || neighborX >= microWidth
                    || neighborY < 0 || neighborY >= microHeight) continue;

                int neighbor = (neighborY * microWidth) + neighborX;
                if (visited[neighbor]) continue;
                if (isDungeonPositionPassable(
                        tileMap, tileTypes, tilesWide, neighborX, neighborY) == false) continue;

                visited[neighbor] = true;
                queue.add(neighbor);
                reachableCellCount++;
            }
        }

        if (reachableCellCount * 100
            < originalPassableCellCount * cDungeonMinimumReachablePercent) return false;

        bool[] isolatedTiles = new bool(tilesWide * tilesHigh, false);
        bool foundIsolatedTile = false;
        for (int tileY = 0; tileY < tilesHigh; tileY++) {
            for (int tileX = 0; tileX < tilesWide; tileX++) {
                int mapIndex = (tileY * tilesWide) + tileX;
                bool hasPassablePosition = false;
                bool hasUnreachablePosition = false;

                for (int localY = 0; localY < 3; localY++) {
                    for (int localX = 0; localX < 3; localX++) {
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

        for (int mapIndex = 0; mapIndex < isolatedTiles.size(); mapIndex++) {
            if (isolatedTiles[mapIndex]) tileMap[mapIndex] = solidWallTileIndex;
        }
    }
    return false;
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
        cSocketTypeWall, cSocketTypeWall, cSocketTypeWall, cSocketTypeWall, 1);
    tileTypes.add(solidWallTile);

    bool connectedLayoutFound = false;
    int[] tileMap = new int(tilesWide * tilesHigh, -1);
    for (int attempt = 0; attempt < cDungeonConnectivityAttempts; attempt++) {
        if (solver.solve() == false) continue;
        for (int y = 0; y < tilesHigh; y++) {
            for (int x = 0; x < tilesWide; x++) {
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
    for (int y = 0; y < tilesHigh; y++) {
        for (int x = 0; x < tilesWide; x++) {
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