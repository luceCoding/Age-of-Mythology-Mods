const float cBSPCellSpacing = 3.0;
const int cBSPMinimumLeafSize = 16;
const int cBSPMinimumCorridorWidth = 2;
const int cBSPMaximumCorridorWidth = 5;
const int cBSPMinimumRoomInset = 1;
const int cBSPMaximumRoomInset = 3;
const int cBSPDefaultMaxRegions = configMapTileX / 4;
const int cBSPMaxHallwaysPerRoom = 4;
const int cBSPMaxRoomCenterOffset = cBSPMinimumLeafSize / 2;
const int cBSPMapEdgePadding = 0;
const int cBSPMapDataFloor = 1;
const int cBSPMapDataHallway = 2;

void carveBSPFloorCell(ref Map map, int x = 0, int z = 0) {
    map.setPassableAt(x, z, true);
    map.setDataAt(x, z, cBSPMapDataFloor);
}

void carveBSPHallwayFloorCell(ref Map map, int x = 0, int z = 0) {
    int cellIndex = map.getCellIndex(x, z);
    if (cellIndex < 0) return;
    map.setPassableAt(x, z, true);
    map.setDataAt(x, z, cBSPMapDataHallway);
    map.setReservedAt(x, z, true);
}

void carveBSPHallwaySegment(ref Map map,
                            int startX = 0, int startZ = 0,
                            int endX = 0, int endZ = 0, bool horizontal = true,
                            int corridorWidth = cBSPMinimumCorridorWidth) {
    int minimumOffset = -(corridorWidth / 2);
    int maximumOffset = minimumOffset + corridorWidth - 1;
    if (horizontal) {
        int lowX = startX;
        int highX = endX;
        if (lowX > highX) {
            lowX = endX;
            highX = startX;
        }

        for (int x = lowX; x <= highX; x = x + 1) {
            for (int offset = minimumOffset;
                 offset <= maximumOffset; offset = offset + 1) {
                carveBSPHallwayFloorCell(map, x, startZ + offset);
            }
        }
    } else {
        int lowZ = startZ;
        int highZ = endZ;
        if (lowZ > highZ) {
            lowZ = endZ;
            highZ = startZ;
        }

        for (int z = lowZ; z <= highZ; z = z + 1) {
            for (int offset = minimumOffset;
                 offset <= maximumOffset; offset = offset + 1) {
                carveBSPHallwayFloorCell(map, startX + offset, z);
            }
        }
    }
}

class Cell {
    int x = 0;
    int z = 0;
    int width = 0;
    int height = 0;
    int roomX = 0;
    int roomZ = 0;
    int roomLeft = 0;
    int roomTop = 0;
    int roomRight = 0;
    int roomBottom = 0;

    void setBounds(int cellX = 0, int cellZ = 0,
                   int cellWidth = 0, int cellHeight = 0) {
        x = cellX;
        z = cellZ;
        width = cellWidth;
        height = cellHeight;
    }
};

Cell[] g_bspCells = default;
int g_bspGridWidth = 0;
int g_bspGridHeight = 0;

class Hallway {
    int startX = 0;
    int startZ = 0;
    int endX = 0;
    int endZ = 0;
    int width = cBSPMinimumCorridorWidth;
    bool horizontalFirst = true;

    void carve(ref Map map) {
        if (horizontalFirst) {
            carveBSPHallwaySegment(
                map,
                startX, startZ, endX, startZ, true, width);
            carveBSPHallwaySegment(
                map,
                endX, startZ, endX, endZ, false, width);
        } else {
            carveBSPHallwaySegment(
                map,
                startX, startZ, startX, endZ, false, width);
            carveBSPHallwaySegment(
                map,
                startX, endZ, endX, endZ, true, width);
        }
    }
};

Cell createBSPCell(int x = 0, int z = 0, int width = 0, int height = 0) {
    Cell cell;
    cell.setBounds(x, z, width, height);
    return cell;
}

void carveBSPHallwayBetween(ref Map map,
                            ref Cell fromCell, ref Cell toCell) {
    int deltaX = toCell.roomX - fromCell.roomX;
    int deltaZ = toCell.roomZ - fromCell.roomZ;
    Hallway hallway;
    hallway.horizontalFirst = xsRandInt(0, 1) == 0;
    if (deltaX == 0) hallway.horizontalFirst = false;
    if (deltaZ == 0) hallway.horizontalFirst = true;

    hallway.startX = fromCell.roomX;
    hallway.startZ = fromCell.roomZ;
    hallway.endX = toCell.roomX;
    hallway.endZ = toCell.roomZ;
    if (hallway.horizontalFirst) {
        if (deltaX > 0) {
            hallway.startX = fromCell.roomRight - 1;
            hallway.endX = toCell.roomLeft;
        } else {
            hallway.startX = fromCell.roomLeft;
            hallway.endX = toCell.roomRight - 1;
        }
        if (deltaZ != 0) {
            if (deltaZ > 0) {
                hallway.endZ = toCell.roomTop;
            } else {
                hallway.endZ = toCell.roomBottom - 1;
            }
        }
    } else {
        if (deltaZ > 0) {
            hallway.startZ = fromCell.roomBottom - 1;
            hallway.endZ = toCell.roomTop;
        } else {
            hallway.startZ = fromCell.roomTop;
            hallway.endZ = toCell.roomBottom - 1;
        }
        if (deltaX != 0) {
            if (deltaX > 0) {
                hallway.endX = toCell.roomLeft;
            } else {
                hallway.endX = toCell.roomRight - 1;
            }
        }
    }
    hallway.width = xsRandInt(
        cBSPMinimumCorridorWidth, cBSPMaximumCorridorWidth);
    hallway.carve(map);
}

bool canSplitBSPCell(ref Cell cell) {
    return cell.width >= cBSPMinimumLeafSize * 2
        || cell.height >= cBSPMinimumLeafSize * 2;
}

void carveBSPRoom(ref Cell cell, ref Map map) {
    int smallestSide = cell.width;
    if (cell.height < smallestSide) smallestSide = cell.height;
    int maximumInset = xsFloatToInt((smallestSide - 6) / 2.0);
    if (maximumInset > cBSPMaximumRoomInset) {
        maximumInset = cBSPMaximumRoomInset;
    }

    int insetX = xsRandInt(cBSPMinimumRoomInset, maximumInset);
    int insetZ = xsRandInt(cBSPMinimumRoomInset, maximumInset);
    int roomLeft = cell.x + insetX;
    int roomTop = cell.z + insetZ;
    int roomRight = cell.x + cell.width - insetX;
    int roomBottom = cell.z + cell.height - insetZ;

    int roomWidth = roomRight - roomLeft;
    int roomHeight = roomBottom - roomTop;
    int minOffsetX = cell.x + 2 - roomLeft;
    int maxOffsetX = cell.x + cell.width - 2 - roomWidth - roomLeft;
    int minOffsetZ = cell.z + 2 - roomTop;
    int maxOffsetZ = cell.z + cell.height - 2 - roomHeight - roomTop;
    if (minOffsetX < (-cBSPMaxRoomCenterOffset)) {
        minOffsetX = (-cBSPMaxRoomCenterOffset);
    }
    if (maxOffsetX > cBSPMaxRoomCenterOffset) {
        maxOffsetX = cBSPMaxRoomCenterOffset;
    }
    if (minOffsetZ < (-cBSPMaxRoomCenterOffset)) {
        minOffsetZ = (-cBSPMaxRoomCenterOffset);
    }
    if (maxOffsetZ > cBSPMaxRoomCenterOffset) {
        maxOffsetZ = cBSPMaxRoomCenterOffset;
    }
    int offsetX = xsRandInt(minOffsetX, maxOffsetX);
    int offsetZ = xsRandInt(minOffsetZ, maxOffsetZ);
    roomLeft = roomLeft + offsetX;
    roomRight = roomRight + offsetX;
    roomTop = roomTop + offsetZ;
    roomBottom = roomBottom + offsetZ;

    cell.roomLeft = roomLeft;
    cell.roomTop = roomTop;
    cell.roomRight = roomRight;
    cell.roomBottom = roomBottom;
    cell.roomX = (roomLeft + roomRight - 1) / 2;
    cell.roomZ = (roomTop + roomBottom - 1) / 2;
    for (int z = roomTop; z < roomBottom; z = z + 1) {
        for (int x = roomLeft; x < roomRight; x = x + 1) {
            carveBSPFloorCell(map, x, z);
        }
    }
}

void placeBSPRoomWalls(ref Cell cell, ref Map map) {
    int right = cell.x + cell.width;
    int bottom = cell.z + cell.height;
    for (int z = cell.z; z < bottom; z = z + 1) {
        for (int x = cell.x; x < right; x = x + 1) {
            int cellData = map.getDataAt(x, z);
            if (cellData != cMapDataEmpty) continue;
            map.setUnitAt(x, z, defaultcUnitTypeWall, 0, 0);
            map.setHeightAt(x, z, configMapBaseHeight);
        }
    }
}

void placeBSPHallwayDebugMarkers(ref Map map) {
    for (int z = 0; z < map.height; z = z + 1) {
        for (int x = 0; x < map.width; x = x + 1) {
            if (map.getDataAt(x, z) != cBSPMapDataHallway) continue;
            map.setUnitAt(x, z, cUnitTypeObelisk, 0, 0);
        }
    }
}

void clearBSPHallwayCellsInsideRooms(ref Map map, ref Cell[] cells) {
    for (int roomIndex = 0; roomIndex < cells.size();
         roomIndex = roomIndex + 1) {
        Cell cell = cells[roomIndex];
        for (int z = cell.roomTop; z < cell.roomBottom; z = z + 1) {
            for (int x = cell.roomLeft; x < cell.roomRight; x = x + 1) {
                if (map.getDataAt(x, z) == cBSPMapDataHallway) {
                    map.setDataAt(x, z, cBSPMapDataFloor);
                    map.setReservedAt(x, z, false);
                }
            }
        }
    }
}

int g_bspMaxHallwaysPerRoom = cBSPMaxHallwaysPerRoom;
int g_bspRoomCarveIndex = 0;
bool g_bspGenerationComplete = false;

bool splitNextBSPRegion() {
    int[] splittableLeaves = new int(0, -1);
    for (int index = 0; index < g_bspCells.size();
         index = index + 1) {
        Cell cell = g_bspCells[index];
        if (canSplitBSPCell(cell)) splittableLeaves.add(index);
    }
    if (splittableLeaves.size() == 0) return false;

    int selectedLeafChoice = xsRandInt(0, splittableLeaves.size() - 1);
    int selected = splittableLeaves[selectedLeafChoice];
    Cell cell = g_bspCells[selected];
    bool splitWidth = cell.width >= cBSPMinimumLeafSize * 2;
    if (cell.height >= cBSPMinimumLeafSize * 2
        && cell.width >= cBSPMinimumLeafSize * 2) {
        splitWidth = cell.width > cell.height;
        if (cell.width == cell.height) splitWidth = xsRandInt(0, 1) == 0;
    } else if (cell.height >= cBSPMinimumLeafSize * 2) {
        splitWidth = false;
    }

    Cell[] nextLeaves = new Cell(0);
    for (int index = 0; index < g_bspCells.size(); index = index + 1) {
        if (index != selected) {
            Cell retainedCell = g_bspCells[index];
            nextLeaves.add(retainedCell);
            continue;
        }

        if (splitWidth) {
            int splitAt = xsRandInt(
                cBSPMinimumLeafSize, cell.width - cBSPMinimumLeafSize);
            nextLeaves.add(createBSPCell(
                cell.x, cell.z, splitAt, cell.height));
            nextLeaves.add(createBSPCell(
                cell.x + splitAt, cell.z,
                cell.width - splitAt, cell.height));
        } else {
            int splitAt = xsRandInt(
                cBSPMinimumLeafSize, cell.height - cBSPMinimumLeafSize);
            nextLeaves.add(createBSPCell(
                cell.x, cell.z, cell.width, splitAt));
            nextLeaves.add(createBSPCell(
                cell.x, cell.z + splitAt,
                cell.width, cell.height - splitAt));
        }
    }
    g_bspCells = nextLeaves;
    return true;
}

bool beginBSPMapGeneration(ref Map map,
                           int maxRegions = cBSPDefaultMaxRegions,
                           int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
    g_bspCells = new Cell(0);
    g_bspGridWidth = 0;
    g_bspGridHeight = 0;
    g_bspGenerationComplete = false;
    if (maxRegions <= 0 || maxHallwaysPerRoom <= 0) return false;
    if (cBSPMinimumCorridorWidth <= 0
        || cBSPMaximumCorridorWidth < cBSPMinimumCorridorWidth) return false;
    if (cBSPMinimumRoomInset < 0
        || cBSPMaximumRoomInset < cBSPMinimumRoomInset) return false;

    float mapWidth = configMapTileX * 2.0;
    float mapHeight = configMapTileZ * 2.0;
    int gridWidth = xsFloatToInt(mapWidth / cBSPCellSpacing);
    int gridHeight = xsFloatToInt(mapHeight / cBSPCellSpacing);
    if (cBSPMapEdgePadding < 0) return false;
    int minimumGridSize = cBSPMinimumLeafSize + (cBSPMapEdgePadding * 2);
    int minimumRoomRegionSize = 6 + (cBSPMinimumRoomInset * 2);
    if (cBSPMinimumLeafSize < minimumRoomRegionSize) return false;
    if (gridWidth < minimumGridSize || gridHeight < minimumGridSize) return false;

    int rootWidth = gridWidth - (cBSPMapEdgePadding * 2);
    int rootHeight = gridHeight - (cBSPMapEdgePadding * 2);
    g_bspCells.add(createBSPCell(
        cBSPMapEdgePadding, cBSPMapEdgePadding, rootWidth, rootHeight));

    g_bspMaxHallwaysPerRoom = maxHallwaysPerRoom;
    g_bspGridWidth = gridWidth;
    g_bspGridHeight = gridHeight;
    while (g_bspCells.size() < maxRegions) {
        if (splitNextBSPRegion() == false) break;
    }
    if (map.initialize(
            g_bspGridWidth, g_bspGridHeight, cBSPCellSpacing,
            0.0, 0.0, configMapBaseHeight) == false) {
        return false;
    }
    g_bspRoomCarveIndex = 0;
    return true;
}

bool connectBSPRooms(ref Map map,
                     int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
    bool[] connectedRooms = new bool(g_bspCells.size(), false);
    int[] hallwayCounts = new int(g_bspCells.size(), 0);
    bool[] connectedPairs = new bool(g_bspCells.size() * g_bspCells.size(), false);
    connectedRooms[0] = true;
    int connectedCount = 1;
    while (connectedCount < g_bspCells.size()) {
        int closestFrom = -1;
        int closestTo = -1;
        int closestDistance = cMaxInt;

        for (int from = 0; from < g_bspCells.size(); from = from + 1) {
            if (connectedRooms[from] == false) continue;
            if (hallwayCounts[from] >= maxHallwaysPerRoom) continue;
            Cell fromCell = g_bspCells[from];
            for (int to = 0; to < g_bspCells.size(); to = to + 1) {
                if (connectedRooms[to]) continue;
                if (hallwayCounts[to] >= maxHallwaysPerRoom) continue;
                Cell toCell = g_bspCells[to];
                int deltaX = fromCell.roomX - toCell.roomX;
                int deltaZ = fromCell.roomZ - toCell.roomZ;
                int distance = (deltaX * deltaX) + (deltaZ * deltaZ);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestFrom = from;
                    closestTo = to;
                }
            }
        }

        if (closestFrom < 0 || closestTo < 0) return false;
        Cell fromCell = g_bspCells[closestFrom];
        Cell toCell = g_bspCells[closestTo];
        carveBSPHallwayBetween(map, fromCell, toCell);
        int treeFromHallwayCount = hallwayCounts[closestFrom];
        int treeToHallwayCount = hallwayCounts[closestTo];
        hallwayCounts[closestFrom] = treeFromHallwayCount + 1;
        hallwayCounts[closestTo] = treeToHallwayCount + 1;
        int i = (closestFrom * g_bspCells.size()) + closestTo;
        int j = (closestTo * g_bspCells.size()) + closestFrom;
        connectedPairs[i] = true;
        connectedPairs[j] = true;
        connectedRooms[closestTo] = true;
        connectedCount = connectedCount + 1;
    }

    while (true) {
        int closestFrom = -1;
        int closestTo = -1;
        int closestDistance = cMaxInt;

        for (int from = 0; from < g_bspCells.size(); from = from + 1) {
            if (hallwayCounts[from] >= maxHallwaysPerRoom) continue;
            Cell fromCell = g_bspCells[from];
            for (int to = from + 1; to < g_bspCells.size(); to = to + 1) {
                if (hallwayCounts[to] >= maxHallwaysPerRoom) continue;
                int existingPairIndex = (from * g_bspCells.size()) + to;
                if (connectedPairs[existingPairIndex]) continue;

                Cell toCell = g_bspCells[to];
                int deltaX = fromCell.roomX - toCell.roomX;
                int deltaZ = fromCell.roomZ - toCell.roomZ;
                int distance = (deltaX * deltaX) + (deltaZ * deltaZ);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestFrom = from;
                    closestTo = to;
                }
            }
        }

        if (closestFrom < 0 || closestTo < 0) break;
        Cell fromCell = g_bspCells[closestFrom];
        Cell toCell = g_bspCells[closestTo];
        carveBSPHallwayBetween(map, fromCell, toCell);
        int extraFromHallwayCount = hallwayCounts[closestFrom];
        int extraToHallwayCount = hallwayCounts[closestTo];
        hallwayCounts[closestFrom] = extraFromHallwayCount + 1;
        hallwayCounts[closestTo] = extraToHallwayCount + 1;
        int pairIndexForward = (closestFrom * g_bspCells.size()) + closestTo;
        int pairIndexReverse = (closestTo * g_bspCells.size()) + closestFrom;
        connectedPairs[pairIndexForward] = true;
        connectedPairs[pairIndexReverse] = true;
    }

    clearBSPHallwayCellsInsideRooms(map, g_bspCells);
    return true;
}

bool stepBSPMapGeneration(ref Map map) {
    if (g_bspGenerationComplete) return true;

    if (g_bspRoomCarveIndex < g_bspCells.size()) {
        Cell cell = g_bspCells[g_bspRoomCarveIndex];
        carveBSPRoom(cell, map);
        g_bspCells[g_bspRoomCarveIndex] = cell;
        g_bspRoomCarveIndex = g_bspRoomCarveIndex + 1;
        if (g_bspRoomCarveIndex >= g_bspCells.size()) {
            if (connectBSPRooms(map, g_bspMaxHallwaysPerRoom) == false) {
                return false;
            }
            g_bspGenerationComplete = true;
        }
        return true;
    }

    if (connectBSPRooms(map, g_bspMaxHallwaysPerRoom) == false) return false;
    g_bspGenerationComplete = true;
    return true;
}

bool generateBSPMap(ref Map map, int maxRegions = cBSPDefaultMaxRegions,
                    int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
    if (beginBSPMapGeneration(map, maxRegions, maxHallwaysPerRoom) == false) {
        return false;
    }
    while (g_bspGenerationComplete == false) {
        if (stepBSPMapGeneration(map) == false) return false;
    }
    return true;
}
