const int cMapDataEmpty = 0;

class Map {
    int width = 0;
    int height = 0;
    float cellSpacing = 0.0;
    float originX = 0.0;
    float originZ = 0.0;
    float baseHeight = 0.0;
    int[] unitTypes = default;
    int[] rotations = default;
    int[] owners = default;
    int[] data = default;
    bool[] passable = default;
    bool[] reserved = default;
    float[] heights = default;

    bool initialize(int mapWidth = 0, int mapHeight = 0,
                    float mapCellSpacing = 0.0, float mapOriginX = 0.0,
                    float mapOriginZ = 0.0, float mapBaseHeight = 0.0) {
        if (mapWidth <= 0 || mapHeight <= 0 || mapCellSpacing <= 0.0) {
            return false;
        }

        width = mapWidth;
        height = mapHeight;
        cellSpacing = mapCellSpacing;
        originX = mapOriginX;
        originZ = mapOriginZ;
        baseHeight = mapBaseHeight;
        int cellCount = width * height;
        unitTypes = new int(cellCount, -1);
        rotations = new int(cellCount, 0);
        owners = new int(cellCount, 0);
        data = new int(cellCount, cMapDataEmpty);
        passable = new bool(cellCount, false);
        reserved = new bool(cellCount, false);
        heights = new float(cellCount, baseHeight);
        return true;
    }

    int getCellIndex(int x = 0, int z = 0) {
        if (x < 0 || x >= width || z < 0 || z >= height) return -1;
        return (z * width) + x;
    }

    bool setUnitAt(int x = 0, int z = 0, int unitType = -1,
                   int rotation = 0, int owner = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        unitTypes[index] = unitType;
        rotations[index] = rotation;
        owners[index] = owner;
        return true;
    }

    int getUnitTypeAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return -1;
        return unitTypes[index];
    }

    int getRotationAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return 0;
        return rotations[index];
    }

    int getOwnerAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return 0;
        return owners[index];
    }

    bool setPassableAt(int x = 0, int z = 0, bool isPassable = false) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        passable[index] = isPassable;
        return true;
    }

    bool setReservedAt(int x = 0, int z = 0, bool isReserved = false) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        reserved[index] = isReserved;
        return true;
    }

    bool isReservedAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        return reserved[index];
    }

    bool isPassableAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        return passable[index];
    }

    bool setDataAt(int x = 0, int z = 0, int cellData = cMapDataEmpty) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        data[index] = cellData;
        return true;
    }

    int getDataAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return cMapDataEmpty;
        return data[index];
    }

    bool setHeightAt(int x = 0, int z = 0, float cellHeight = 0.0) {
        int index = getCellIndex(x, z);
        if (index < 0) return false;
        heights[index] = cellHeight;
        return true;
    }

    float getHeightAt(int x = 0, int z = 0) {
        int index = getCellIndex(x, z);
        if (index < 0) return baseHeight;
        return heights[index];
    }

    void placeRegion(int left = 0, int top = 0,
                     int right = 0, int bottom = 0) {
        if (left < 0) left = 0;
        if (top < 0) top = 0;
        if (right > width) right = width;
        if (bottom > height) bottom = height;

        for (int z = top; z < bottom; z = z + 1) {
            for (int x = left; x < right; x = x + 1) {
                int index = getCellIndex(x, z);
                int unitType = unitTypes[index];
                if (unitType < 0) continue;

                float worldX = originX + (xsIntToFloat(x) * cellSpacing)
                    + (cellSpacing * 0.5);
                float worldZ = originZ + (xsIntToFloat(z) * cellSpacing)
                    + (cellSpacing * 0.5);
                trUnitCreateForced(
                    kbProtoUnitGetName(unitType), worldX, heights[index],
                    worldZ, xsIntToFloat(rotations[index]), owners[index]);
            }
        }
    }

    void placeAll() {
        placeRegion(0, 0, width, height);
    }
};

Map g_generatedMap;
