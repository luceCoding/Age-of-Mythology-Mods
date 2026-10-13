const float cBSPCellSpacing = 3.0;
const int cBSPMinimumLeafSize = 16;
const int cBSPMinimumCorridorWidth = 3;
const int cBSPMaximumCorridorWidth = 3;
const int cBSPMinimumRoomInset = 1;
const int cBSPMaximumRoomInset = 3;
const int cBSPDefaultMaxRegions = configMapTileX / 4;
const int cBSPMaxHallwaysPerRoom = 4;
const int cBSPMaxRoomCenterOffset = 0;
const int cBSPMapEdgePadding = 0;
const int cBSPMapDataFloor = 2;
const int cBSPMapDataHallway = 3;

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
    int partitionIndex = -1;
    int roomX = 0;
    int roomZ = 0;
    int roomLeft = 0;
    int roomTop = 0;
    int roomRight = 0;
    int roomBottom = 0;

    void setBounds(int cellX = 0, int cellZ = 0,
                   int cellWidth = 0, int cellHeight = 0,
                   int cellPartitionIndex = -1) {
        x = cellX;
        z = cellZ;
        width = cellWidth;
        height = cellHeight;
        partitionIndex = cellPartitionIndex;
    }
};

class BSPPartition {
    int x = 0;
    int z = 0;
    int width = 0;
    int height = 0;
    int parentIndex = -1;
    int leftChildIndex = -1;
    int rightChildIndex = -1;

    void setBounds(int partitionX = 0, int partitionZ = 0,
                   int partitionWidth = 0, int partitionHeight = 0,
                   int partitionParentIndex = -1) {
        x = partitionX;
        z = partitionZ;
        width = partitionWidth;
        height = partitionHeight;
        parentIndex = partitionParentIndex;
    }
};

Cell[] g_bspCells = default;
BSPPartition[] g_bspPartitions = default;
int g_bspGridWidth = 0;
int g_bspGridHeight = 0;
int g_bspMaxHallwaysPerRoom = cBSPMaxHallwaysPerRoom;

class Hallway {
    int startX = 0;
    int startZ = 0;
    int endX = 0;
    int endZ = 0;
    int width = cBSPMinimumCorridorWidth;
    bool horizontalFirst = true;

    int getFirstSegmentLength() {
        if (horizontalFirst) {
            int length = endX - startX;
            if (length < 0) length = -length;
            return length;
        }
        int length = endZ - startZ;
        if (length < 0) length = -length;
        return length;
    }

    int getTotalLength() {
        int firstLength = getFirstSegmentLength();
        int secondLength = 0;
        if (horizontalFirst) {
            secondLength = endZ - startZ;
        } else {
            secondLength = endX - startX;
        }
        if (secondLength < 0) secondLength = -secondLength;
        return firstLength + secondLength;
    }

    int getXAtPathStep(int pathStep = 0) {
        int firstLength = getFirstSegmentLength();
        if (horizontalFirst) {
            if (pathStep <= firstLength) {
                int directionX = 1;
                if (endX < startX) directionX = -1;
                return startX + (directionX * pathStep);
            }
            return endX;
        }
        if (pathStep <= firstLength) return startX;
        int directionX = 1;
        if (endX < startX) directionX = -1;
        return startX + (directionX * (pathStep - firstLength));
    }

    int getZAtPathStep(int pathStep = 0) {
        int firstLength = getFirstSegmentLength();
        if (horizontalFirst) {
            if (pathStep <= firstLength) return startZ;
            int directionZ = 1;
            if (endZ < startZ) directionZ = -1;
            return startZ + (directionZ * (pathStep - firstLength));
        }
        if (pathStep <= firstLength) {
            int directionZ = 1;
            if (endZ < startZ) directionZ = -1;
            return startZ + (directionZ * pathStep);
        }
        return endZ;
    }

    int getRotationAtPathStep(int pathStep = 0) {
        int firstLength = getFirstSegmentLength();
        bool horizontalSegment = horizontalFirst;
        if (pathStep > firstLength && horizontalFirst) {
            horizontalSegment = false;
        }
        if (pathStep > firstLength && horizontalFirst == false) {
            horizontalSegment = true;
        }
        if (horizontalSegment) return 90;
        return 0;
    }

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

Hallway[] g_bspHallways = default;

Cell createBSPCell(int x = 0, int z = 0, int width = 0, int height = 0,
                   int partitionIndex = -1) {
    Cell cell;
    cell.setBounds(x, z, width, height, partitionIndex);
    return cell;
}

BSPPartition createBSPPartition(int x = 0, int z = 0,
                                int width = 0, int height = 0,
                                int parentIndex = -1) {
    BSPPartition partition;
    partition.setBounds(x, z, width, height, parentIndex);
    return partition;
}

void configureBSPHallway(ref Hallway hallway, ref Cell fromCell,
                         ref Cell toCell, bool horizontalFirst = true) {
    int deltaX = toCell.roomX - fromCell.roomX;
    int deltaZ = toCell.roomZ - fromCell.roomZ;
    hallway.horizontalFirst = horizontalFirst;
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
}

bool isBSPHallwayCellClear(ref Map map, ref Cell fromCell, ref Cell toCell,
                           int x = 0, int z = 0) {
    if (map.getCellIndex(x, z) < 0) return false;
    int cellData = map.getDataAt(x, z);
    if (cellData != cBSPMapDataFloor) {
        return cellData == cMapDataEmpty
            || cellData == cBSPMapDataHallway;
    }

    bool insideFromRoom = x >= fromCell.roomLeft && x < fromCell.roomRight
        && z >= fromCell.roomTop && z < fromCell.roomBottom;
    bool insideToRoom = x >= toCell.roomLeft && x < toCell.roomRight
        && z >= toCell.roomTop && z < toCell.roomBottom;
    return insideFromRoom || insideToRoom;
}

bool isBSPHallwaySegmentClear(ref Map map,
                              ref Cell fromCell, ref Cell toCell,
                              int startX = 0, int startZ = 0,
                              int endX = 0, int endZ = 0,
                              bool horizontal = true, int corridorWidth = 1) {
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
                if (isBSPHallwayCellClear(
                        map, fromCell, toCell, x, startZ + offset) == false) {
                    return false;
                }
            }
        }
        return true;
    }

    int lowZ = startZ;
    int highZ = endZ;
    if (lowZ > highZ) {
        lowZ = endZ;
        highZ = startZ;
    }
    for (int z = lowZ; z <= highZ; z = z + 1) {
        for (int offset = minimumOffset;
             offset <= maximumOffset; offset = offset + 1) {
            if (isBSPHallwayCellClear(
                    map, fromCell, toCell, startX + offset, z) == false) {
                return false;
            }
        }
    }
    return true;
}

bool isBSPHallwayRouteClear(ref Map map, ref Hallway hallway,
                            ref Cell fromCell, ref Cell toCell) {
    if (hallway.horizontalFirst) {
        return isBSPHallwaySegmentClear(
                   map, fromCell, toCell,
                   hallway.startX, hallway.startZ,
                   hallway.endX, hallway.startZ, true, hallway.width)
            && isBSPHallwaySegmentClear(
                   map, fromCell, toCell,
                   hallway.endX, hallway.startZ,
                   hallway.endX, hallway.endZ, false, hallway.width);
    }
    return isBSPHallwaySegmentClear(
               map, fromCell, toCell,
               hallway.startX, hallway.startZ,
               hallway.startX, hallway.endZ, false, hallway.width)
        && isBSPHallwaySegmentClear(
               map, fromCell, toCell,
               hallway.startX, hallway.endZ,
               hallway.endX, hallway.endZ, true, hallway.width);
}

bool canConnectBSPRooms(ref Map map, ref Cell fromCell, ref Cell toCell) {
    Hallway hallway;
    hallway.width = cBSPMaximumCorridorWidth;
    configureBSPHallway(
        hallway, fromCell, toCell, xsRandInt(0, 1) == 0);
    if (isBSPHallwayRouteClear(map, hallway, fromCell, toCell)) return true;
    configureBSPHallway(
        hallway, fromCell, toCell, hallway.horizontalFirst == false);
    return isBSPHallwayRouteClear(map, hallway, fromCell, toCell);
}

bool carveBSPHallwayBetween(ref Map map,
                            ref Cell fromCell, ref Cell toCell) {
    Hallway hallway;
    hallway.width = xsRandInt(
        cBSPMinimumCorridorWidth, cBSPMaximumCorridorWidth);
    configureBSPHallway(
        hallway, fromCell, toCell, xsRandInt(0, 1) == 0);
    if (isBSPHallwayRouteClear(map, hallway, fromCell, toCell) == false) {
        configureBSPHallway(
            hallway, fromCell, toCell, hallway.horizontalFirst == false);
        if (isBSPHallwayRouteClear(map, hallway, fromCell, toCell) == false) {
            return false;
        }
    }
    hallway.carve(map);
    g_bspHallways.add(hallway);
    return true;
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
            map.setUnitAt(x, z, cDefaultcUnitTypeWall, 0, 0);
            map.setHeightAt(x, z, configMapBaseHeight);
        }
    }
}

void placeBSPHallwayDebugMarkers(ref Map map) {
    for (int z = 0; z < map.height; z = z + 1) {
        for (int x = 0; x < map.width; x = x + 1) {
            if (map.getDataAt(x, z) != cBSPMapDataHallway) continue;
            map.setUnitAt(x, z, cUnitTypeObelisk, 0, 0);
            map.placeRegion(x, z, x + 1, z + 1);
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
                    map.setDataAt(x, z, cMapDataEntranceSocket);
                    map.setPassableAt(x, z, true);
                    map.setReservedAt(x, z, true);
                }
            }
        }
    }
}

bool hasBSPHallwayGatePosts(ref Map map, ref Hallway hallway,
                            int x = 0, int z = 0, int rotation = 0) {
    int minimumOffset = -(hallway.width / 2);
    int maximumOffset = minimumOffset + hallway.width - 1;
    if (rotation == 90) {
        return map.getUnitTypeAt(x, z + minimumOffset - 1)
                == cDefaultcUnitTypeWall
            && map.getUnitTypeAt(x, z + maximumOffset + 1)
                == cDefaultcUnitTypeWall;
    }
    return map.getUnitTypeAt(x + minimumOffset - 1, z)
            == cDefaultcUnitTypeWall
        && map.getUnitTypeAt(x + maximumOffset + 1, z)
            == cDefaultcUnitTypeWall;
}

bool placeBSPHallwayGate(ref Map map, ref Hallway hallway) {
    int totalLength = hallway.getTotalLength();
    int firstLength = hallway.getFirstSegmentLength();
    int availablePositions = 0;
    for (int pathStep = 1; pathStep < totalLength; pathStep = pathStep + 1) {
        if (firstLength > 0 && firstLength < totalLength
            && pathStep == firstLength) continue;
        int x = hallway.getXAtPathStep(pathStep);
        int z = hallway.getZAtPathStep(pathStep);
        int rotation = hallway.getRotationAtPathStep(pathStep);
        if (map.getDataAt(x, z) == cBSPMapDataHallway
            && map.getUnitTypeAt(x, z) < 0
            && hasBSPHallwayGatePosts(map, hallway, x, z, rotation)) {
            availablePositions = availablePositions + 1;
        }
    }
    if (availablePositions == 0) return true;

    int selectedPosition = xsRandInt(0, availablePositions - 1);
    int currentPosition = 0;
    for (int selectedStep = 1; selectedStep < totalLength;
         selectedStep = selectedStep + 1) {
        if (firstLength > 0 && firstLength < totalLength
            && selectedStep == firstLength) continue;
        int x = hallway.getXAtPathStep(selectedStep);
        int z = hallway.getZAtPathStep(selectedStep);
        int rotation = hallway.getRotationAtPathStep(selectedStep);
        if (map.getDataAt(x, z) != cBSPMapDataHallway) continue;
        if (map.getUnitTypeAt(x, z) >= 0) continue;
        if (hasBSPHallwayGatePosts(map, hallway, x, z, rotation) == false) {
            continue;
        }
        if (currentPosition == selectedPosition) {
            int gateType = cDefaultcUnitTypeGate;
            if (hallway.width > 3) gateType = cDefaultcUnitTypeGate2;
            float lateralOffset = 0.0;
            if (hallway.width % 2 == 0) {
                lateralOffset = -0.5 * map.cellSpacing;
            }
            float gateOffsetX = 0.0;
            float gateOffsetZ = 0.0;
            if (rotation == 90) {
                gateOffsetZ = lateralOffset;
            } else {
                gateOffsetX = lateralOffset;
            }
            if (map.setUnitAt(
                    x, z, gateType, rotation, 0,
                    gateOffsetX, gateOffsetZ) == false) {
                return false;
            }
            map.placeRegion(x, z, x + 1, z + 1);
            return true;
        }
        currentPosition = currentPosition + 1;
    }
    return false;
}

bool placeBSPHallwayGates(ref Map map) {
    for (int hallwayIndex = 0; hallwayIndex < g_bspHallways.size();
         hallwayIndex = hallwayIndex + 1) {
        Hallway hallway = g_bspHallways[hallwayIndex];
        if (placeBSPHallwayGate(map, hallway) == false) return false;
    }
    return true;
}

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

        int leftPartitionIndex = g_bspPartitions.size();
        int rightPartitionIndex = leftPartitionIndex + 1;
        BSPPartition parentPartition = g_bspPartitions[cell.partitionIndex];
        if (splitWidth) {
            int splitAt = xsRandInt(
                cBSPMinimumLeafSize, cell.width - cBSPMinimumLeafSize);
            BSPPartition leftPartition = createBSPPartition(
                cell.x, cell.z, splitAt, cell.height, cell.partitionIndex);
            BSPPartition rightPartition = createBSPPartition(
                cell.x + splitAt, cell.z, cell.width - splitAt,
                cell.height, cell.partitionIndex);
            g_bspPartitions.add(leftPartition);
            g_bspPartitions.add(rightPartition);
            parentPartition.leftChildIndex = leftPartitionIndex;
            parentPartition.rightChildIndex = rightPartitionIndex;
            nextLeaves.add(createBSPCell(
                cell.x, cell.z, splitAt, cell.height, leftPartitionIndex));
            nextLeaves.add(createBSPCell(
                cell.x + splitAt, cell.z,
                cell.width - splitAt, cell.height, rightPartitionIndex));
        } else {
            int splitAt = xsRandInt(
                cBSPMinimumLeafSize, cell.height - cBSPMinimumLeafSize);
            BSPPartition leftPartition = createBSPPartition(
                cell.x, cell.z, cell.width, splitAt, cell.partitionIndex);
            BSPPartition rightPartition = createBSPPartition(
                cell.x, cell.z + splitAt, cell.width,
                cell.height - splitAt, cell.partitionIndex);
            g_bspPartitions.add(leftPartition);
            g_bspPartitions.add(rightPartition);
            parentPartition.leftChildIndex = leftPartitionIndex;
            parentPartition.rightChildIndex = rightPartitionIndex;
            nextLeaves.add(createBSPCell(
                cell.x, cell.z, cell.width, splitAt, leftPartitionIndex));
            nextLeaves.add(createBSPCell(
                cell.x, cell.z + splitAt,
                cell.width, cell.height - splitAt, rightPartitionIndex));
        }
        g_bspPartitions[cell.partitionIndex] = parentPartition;
    }
    g_bspCells = nextLeaves;
    return true;
}

bool beginBSPMapGeneration(ref Map map,
                           int maxRegions = cBSPDefaultMaxRegions,
                           int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
    g_bspCells = new Cell(0);
    g_bspPartitions = new BSPPartition(0);
    g_bspHallways = new Hallway(0);
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
    g_bspPartitions.add(createBSPPartition(
        cBSPMapEdgePadding, cBSPMapEdgePadding,
        rootWidth, rootHeight));
    g_bspCells.add(createBSPCell(
        cBSPMapEdgePadding, cBSPMapEdgePadding,
        rootWidth, rootHeight, 0));

    g_bspGridWidth = gridWidth;
    g_bspGridHeight = gridHeight;
    g_bspMaxHallwaysPerRoom = maxHallwaysPerRoom;
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

int getBSPPartitionBranch(int roomPartitionIndex = -1,
                          int ancestorPartitionIndex = -1) {
    int currentPartitionIndex = roomPartitionIndex;
    while (currentPartitionIndex >= 0) {
        BSPPartition partition = g_bspPartitions[currentPartitionIndex];
        if (partition.parentIndex == ancestorPartitionIndex) {
            return currentPartitionIndex;
        }
        currentPartitionIndex = partition.parentIndex;
    }
    return -1;
}

bool connectBSPRooms(ref Map map) {
    int[] hallwayCounts = new int(g_bspCells.size(), 0);
    for (int partitionIndex = g_bspPartitions.size() - 1;
         partitionIndex >= 0; partitionIndex = partitionIndex - 1) {
        BSPPartition partition = g_bspPartitions[partitionIndex];
        if (partition.leftChildIndex < 0 || partition.rightChildIndex < 0) {
            continue;
        }
        int closestFrom = -1;
        int closestTo = -1;
        int closestDistance = cMaxInt;
        for (int firstRoom = 0; firstRoom < g_bspCells.size();
             firstRoom = firstRoom + 1) {
            Cell firstCell = g_bspCells[firstRoom];
            int firstBranch = getBSPPartitionBranch(
                firstCell.partitionIndex, partitionIndex);
            if (firstBranch != partition.leftChildIndex
                && firstBranch != partition.rightChildIndex) continue;
            if (hallwayCounts[firstRoom] >= g_bspMaxHallwaysPerRoom) continue;
            for (int secondRoom = 0; secondRoom < g_bspCells.size();
                 secondRoom = secondRoom + 1) {
                Cell secondCell = g_bspCells[secondRoom];
                int secondBranch = getBSPPartitionBranch(
                    secondCell.partitionIndex, partitionIndex);
                if (firstBranch == secondBranch
                    || (firstBranch != partition.leftChildIndex
                        && firstBranch != partition.rightChildIndex)
                    || (secondBranch != partition.leftChildIndex
                        && secondBranch != partition.rightChildIndex)) continue;
                if (hallwayCounts[secondRoom]
                    >= g_bspMaxHallwaysPerRoom) continue;
                if (canConnectBSPRooms(map, firstCell, secondCell) == false) {
                    continue;
                }
                int deltaX = firstCell.roomX - secondCell.roomX;
                int deltaZ = firstCell.roomZ - secondCell.roomZ;
                int distance = (deltaX * deltaX) + (deltaZ * deltaZ);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestFrom = firstRoom;
                    closestTo = secondRoom;
                }
            }
        }

        if (closestFrom < 0 || closestTo < 0) {
            errorLog(
                "BSP split has no clear room connection within the per-room hallway limit.");
            return false;
        }
        Cell fromCell = g_bspCells[closestFrom];
        Cell toCell = g_bspCells[closestTo];
        if (carveBSPHallwayBetween(map, fromCell, toCell) == false) {
            return false;
        }
        hallwayCounts[closestFrom] = hallwayCounts[closestFrom] + 1;
        hallwayCounts[closestTo] = hallwayCounts[closestTo] + 1;
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
            if (connectBSPRooms(map) == false) {
                return false;
            }
            g_bspGenerationComplete = true;
        }
        return true;
    }

    if (connectBSPRooms(map) == false) return false;
    g_bspGenerationComplete = true;
    return true;
}

bool generateBSPMap(ref Map map, int maxRegions = cBSPDefaultMaxRegions,
                    int maxHallwaysPerRoom = cBSPMaxHallwaysPerRoom) {
    if (beginBSPMapGeneration(
            map, maxRegions, maxHallwaysPerRoom) == false) {
        return false;
    }
    while (g_bspGenerationComplete == false) {
        if (stepBSPMapGeneration(map) == false) return false;
    }
    return true;
}
