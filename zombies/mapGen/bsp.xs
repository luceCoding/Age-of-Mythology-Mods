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

void carveBSPFloorCell(ref bool[] floors, int gridWidth = 0,
                       int gridHeight = 0, int x = 0, int z = 0) {
    if (x < 0 || x >= gridWidth || z < 0 || z >= gridHeight) return;
    int floorIndex = (z * gridWidth) + x;
    floors[floorIndex] = true;
}

void carveBSPHallwaySegment(ref bool[] floors, int gridWidth = 0,
                            int gridHeight = 0, int startX = 0, int startZ = 0,
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
                carveBSPFloorCell(floors, gridWidth, gridHeight, x, startZ + offset);
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
                carveBSPFloorCell(floors, gridWidth, gridHeight, startX + offset, z);
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

    void setBounds(int cellX = 0, int cellZ = 0,
                   int cellWidth = 0, int cellHeight = 0) {
        x = cellX;
        z = cellZ;
        width = cellWidth;
        height = cellHeight;
    }
};

class Hallway {
    int startX = 0;
    int startZ = 0;
    int endX = 0;
    int endZ = 0;
    int width = cBSPMinimumCorridorWidth;
    bool horizontalFirst = true;

    void carve(ref bool[] floors, int gridWidth = 0, int gridHeight = 0) {
        if (horizontalFirst) {
            carveBSPHallwaySegment(
                floors, gridWidth, gridHeight, startX, startZ, endX, startZ,
                true, width);
            carveBSPHallwaySegment(
                floors, gridWidth, gridHeight, endX, startZ, endX, endZ,
                false, width);
        } else {
            carveBSPHallwaySegment(
                floors, gridWidth, gridHeight, startX, startZ, startX, endZ,
                false, width);
            carveBSPHallwaySegment(
                floors, gridWidth, gridHeight, startX, endZ, endX, endZ,
                true, width);
        }
    }
};

Cell createBSPCell(int x = 0, int z = 0, int width = 0, int height = 0) {
    Cell cell;
    cell.setBounds(x, z, width, height);
    return cell;
}

void carveBSPHallwayBetween(ref bool[] floors, int gridWidth = 0,
                            int gridHeight = 0, int startX = 0, int startZ = 0,
                            int endX = 0, int endZ = 0) {
    Hallway hallway;
    hallway.startX = startX;
    hallway.startZ = startZ;
    hallway.endX = endX;
    hallway.endZ = endZ;
    hallway.width = xsRandInt(
        cBSPMinimumCorridorWidth, cBSPMaximumCorridorWidth);
    hallway.horizontalFirst = xsRandInt(0, 1) == 0;
    hallway.carve(floors, gridWidth, gridHeight);
}

bool canSplitBSPCell(ref Cell cell) {
    return cell.width >= cBSPMinimumLeafSize * 2
        || cell.height >= cBSPMinimumLeafSize * 2;
}

void carveBSPRoom(ref Cell cell, ref bool[] floors,
                  int gridWidth = 0, int gridHeight = 0) {
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

    cell.roomX = (roomLeft + roomRight - 1) / 2;
    cell.roomZ = (roomTop + roomBottom - 1) / 2;
    for (int z = roomTop; z < roomBottom; z = z + 1) {
        for (int x = roomLeft; x < roomRight; x = x + 1) {
            carveBSPFloorCell(floors, gridWidth, gridHeight, x, z);
        }
    }
}

void placeBSPWalls(ref bool[] floors, int gridWidth = 0, int gridHeight = 0) {
    for (int z = 0; z < gridHeight; z = z + 1) {
        for (int x = 0; x < gridWidth; x = x + 1) {
            int cellIndex = (z * gridWidth) + x;
            if (floors[cellIndex]) continue;

            float worldX = (xsIntToFloat(x) * cBSPCellSpacing) + 1.5;
            float worldZ = (xsIntToFloat(z) * cBSPCellSpacing) + 1.5;
            trUnitCreateForced(
                kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector),
                worldX, configMapBaseHeight, worldZ, 0.0, 0);
        }
    }
}

bool generateBSPMap(int maxRegions = cBSPDefaultMaxRegions,
                    int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
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

    Cell[] leaves = new Cell(0);
    int rootWidth = gridWidth - (cBSPMapEdgePadding * 2);
    int rootHeight = gridHeight - (cBSPMapEdgePadding * 2);
    leaves.add(createBSPCell(
        cBSPMapEdgePadding, cBSPMapEdgePadding, rootWidth, rootHeight));

    while (leaves.size() < maxRegions) {
        int[] splittableLeaves = new int(0, -1);
        for (int index = 0; index < leaves.size(); index = index + 1) {
            Cell cell = leaves[index];
            if (canSplitBSPCell(cell)) splittableLeaves.add(index);
        }
        if (splittableLeaves.size() == 0) break;

        int selectedLeafChoice = xsRandInt(0, splittableLeaves.size() - 1);
        int selected = splittableLeaves[selectedLeafChoice];
        Cell cell = leaves[selected];
        bool splitWidth = cell.width >= cBSPMinimumLeafSize * 2;
        if (cell.height >= cBSPMinimumLeafSize * 2
            && cell.width >= cBSPMinimumLeafSize * 2) {
            splitWidth = cell.width > cell.height;
            if (cell.width == cell.height) splitWidth = xsRandInt(0, 1) == 0;
        } else if (cell.height >= cBSPMinimumLeafSize * 2) {
            splitWidth = false;
        }

        Cell[] nextLeaves = new Cell(0);
        for (int index = 0; index < leaves.size(); index = index + 1) {
            if (index != selected) {
                Cell retainedCell = leaves[index];
                nextLeaves.add(retainedCell);
                continue;
            }

            if (splitWidth) {
                int splitAt = xsRandInt(
                    cBSPMinimumLeafSize,
                    cell.width - cBSPMinimumLeafSize);
                nextLeaves.add(createBSPCell(
                    cell.x, cell.z, splitAt, cell.height));
                nextLeaves.add(createBSPCell(
                    cell.x + splitAt, cell.z,
                    cell.width - splitAt, cell.height));
            } else {
                int splitAt = xsRandInt(
                    cBSPMinimumLeafSize,
                    cell.height - cBSPMinimumLeafSize);
                nextLeaves.add(createBSPCell(
                    cell.x, cell.z, cell.width, splitAt));
                nextLeaves.add(createBSPCell(
                    cell.x, cell.z + splitAt,
                    cell.width, cell.height - splitAt));
            }
        }
        leaves = nextLeaves;
    }

    bool[] floors = new bool(gridWidth * gridHeight, false);
    for (int index = 0; index < leaves.size(); index = index + 1) {
        Cell cell = leaves[index];
        carveBSPRoom(cell, floors, gridWidth, gridHeight);
        leaves[index] = cell;
    }

    bool[] connectedRooms = new bool(leaves.size(), false);
    int[] hallwayCounts = new int(leaves.size(), 0);
    bool[] connectedPairs = new bool(leaves.size() * leaves.size(), false);
    connectedRooms[0] = true;
    int connectedCount = 1;
    while (connectedCount < leaves.size()) {
        int closestFrom = -1;
        int closestTo = -1;
        int closestDistance = cMaxInt;

        for (int from = 0; from < leaves.size(); from = from + 1) {
            if (connectedRooms[from] == false) continue;
            if (hallwayCounts[from] >= maxHallwaysPerRoom) continue;
            Cell fromCell = leaves[from];
            for (int to = 0; to < leaves.size(); to = to + 1) {
                if (connectedRooms[to]) continue;
                if (hallwayCounts[to] >= maxHallwaysPerRoom) continue;
                Cell toCell = leaves[to];
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
        Cell fromCell = leaves[closestFrom];
        Cell toCell = leaves[closestTo];
        carveBSPHallwayBetween(
            floors, gridWidth, gridHeight,
            fromCell.roomX, fromCell.roomZ, toCell.roomX, toCell.roomZ);
        int treeFromHallwayCount = hallwayCounts[closestFrom];
        int treeToHallwayCount = hallwayCounts[closestTo];
        hallwayCounts[closestFrom] = treeFromHallwayCount + 1;
        hallwayCounts[closestTo] = treeToHallwayCount + 1;
        int i = (closestFrom * leaves.size()) + closestTo;
        int j = (closestTo * leaves.size()) + closestFrom;
        connectedPairs[i] = true;
        connectedPairs[j] = true;
        connectedRooms[closestTo] = true;
        connectedCount = connectedCount + 1;
    }

    while (true) {
        int closestFrom = -1;
        int closestTo = -1;
        int closestDistance = cMaxInt;

        for (int from = 0; from < leaves.size(); from = from + 1) {
            if (hallwayCounts[from] >= maxHallwaysPerRoom) continue;
            Cell fromCell = leaves[from];
            for (int to = from + 1; to < leaves.size(); to = to + 1) {
                if (hallwayCounts[to] >= maxHallwaysPerRoom) continue;
                int existingPairIndex = (from * leaves.size()) + to;
                if (connectedPairs[existingPairIndex]) continue;

                Cell toCell = leaves[to];
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
        Cell fromCell = leaves[closestFrom];
        Cell toCell = leaves[closestTo];
        carveBSPHallwayBetween(
            floors, gridWidth, gridHeight,
            fromCell.roomX, fromCell.roomZ, toCell.roomX, toCell.roomZ);
        int extraFromHallwayCount = hallwayCounts[closestFrom];
        int extraToHallwayCount = hallwayCounts[closestTo];
        hallwayCounts[closestFrom] = extraFromHallwayCount + 1;
        hallwayCounts[closestTo] = extraToHallwayCount + 1;
        int pairIndexForward = (closestFrom * leaves.size()) + closestTo;
        int pairIndexReverse = (closestTo * leaves.size()) + closestFrom;
        connectedPairs[pairIndexForward] = true;
        connectedPairs[pairIndexReverse] = true;
    }

    placeBSPWalls(floors, gridWidth, gridHeight);
    return true;
}