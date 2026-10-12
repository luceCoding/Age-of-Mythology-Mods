class Tile {
    int topLeftUnit = -1;
    int topCenterUnit = -1;
    int topRightUnit = -1;
    int middleLeftUnit = -1;
    int centerUnit = -1;
    int middleRightUnit = -1;
    int bottomLeftUnit = -1;
    int bottomCenterUnit = -1;
    int bottomRightUnit = -1;
    int topLeftPlayer = 0;
    int topCenterPlayer = 0;
    int topRightPlayer = 0;
    int middleLeftPlayer = 0;
    int centerPlayer = 0;
    int middleRightPlayer = 0;
    int bottomLeftPlayer = 0;
    int bottomCenterPlayer = 0;
    int bottomRightPlayer = 0;
    bool topLeftPassable = false;
    bool topCenterPassable = false;
    bool topRightPassable = false;
    bool middleLeftPassable = false;
    bool centerPassable = false;
    bool middleRightPassable = false;
    bool bottomLeftPassable = false;
    bool bottomCenterPassable = false;
    bool bottomRightPassable = false;
    int northSocket = 0;
    int eastSocket = 0;
    int southSocket = 0;
    int westSocket = 0;
    int weight = 1;
    int rotation = 0;

    void setUnits(int topLeft = -1, int topCenter = -1, int topRight = -1,
                  int middleLeft = -1, int center = -1, int middleRight = -1,
                  int bottomLeft = -1, int bottomCenter = -1, int bottomRight = -1) {
        topLeftUnit = topLeft;
        topCenterUnit = topCenter;
        topRightUnit = topRight;
        middleLeftUnit = middleLeft;
        centerUnit = center;
        middleRightUnit = middleRight;
        bottomLeftUnit = bottomLeft;
        bottomCenterUnit = bottomCenter;
        bottomRightUnit = bottomRight;
    }

    void setPlayerUnit(int position = 0, int player = 0) {
        if (position == 0) topLeftPlayer = player;
        if (position == 1) topCenterPlayer = player;
        if (position == 2) topRightPlayer = player;
        if (position == 3) middleLeftPlayer = player;
        if (position == 4) centerPlayer = player;
        if (position == 5) middleRightPlayer = player;
        if (position == 6) bottomLeftPlayer = player;
        if (position == 7) bottomCenterPlayer = player;
        if (position == 8) bottomRightPlayer = player;
    }

    void setPassability(bool topLeft = false, bool topCenter = false, bool topRight = false,
                        bool middleLeft = false, bool center = false, bool middleRight = false,
                        bool bottomLeft = false, bool bottomCenter = false, bool bottomRight = false) {
        topLeftPassable = topLeft;
        topCenterPassable = topCenter;
        topRightPassable = topRight;
        middleLeftPassable = middleLeft;
        centerPassable = center;
        middleRightPassable = middleRight;
        bottomLeftPassable = bottomLeft;
        bottomCenterPassable = bottomCenter;
        bottomRightPassable = bottomRight;
    }

    void setSocketsAndWeight(int northSocketValue = 0, int eastSocketValue = 0,
                             int southSocketValue = 0, int westSocketValue = 0,
                             int tileWeight = 1) {
        northSocket = northSocketValue;
        eastSocket = eastSocketValue;
        southSocket = southSocketValue;
        westSocket = westSocketValue;
        weight = tileWeight;
    }

    int getUnitAt(int position = 0) {
        if (position == 0) return topLeftUnit;
        if (position == 1) return topCenterUnit;
        if (position == 2) return topRightUnit;
        if (position == 3) return middleLeftUnit;
        if (position == 4) return centerUnit;
        if (position == 5) return middleRightUnit;
        if (position == 6) return bottomLeftUnit;
        if (position == 7) return bottomCenterUnit;
        if (position == 8) return bottomRightUnit;
        return -1;
    }

    int getPlayerUnitAt(int position = 0) {
        if (position == 0) return topLeftPlayer;
        if (position == 1) return topCenterPlayer;
        if (position == 2) return topRightPlayer;
        if (position == 3) return middleLeftPlayer;
        if (position == 4) return centerPlayer;
        if (position == 5) return middleRightPlayer;
        if (position == 6) return bottomLeftPlayer;
        if (position == 7) return bottomCenterPlayer;
        if (position == 8) return bottomRightPlayer;
        return 0;
    }

    bool isPassableAt(int position = 0) {
        if (position == 0) return topLeftPassable;
        if (position == 1) return topCenterPassable;
        if (position == 2) return topRightPassable;
        if (position == 3) return middleLeftPassable;
        if (position == 4) return centerPassable;
        if (position == 5) return middleRightPassable;
        if (position == 6) return bottomLeftPassable;
        if (position == 7) return bottomCenterPassable;
        if (position == 8) return bottomRightPassable;
        return false;
    }

    int getSocket(int direction = cSocketNorth) {
        if (direction == cSocketNorth) return northSocket;
        if (direction == cSocketEast) return eastSocket;
        if (direction == cSocketSouth) return southSocket;
        if (direction == cSocketWest) return westSocket;
        return -1;
    }
};

Tile rotateMapTileClockwise(ref Tile source) {
    Tile tile;
    tile.setUnits(
        source.getUnitAt(6), source.getUnitAt(3), source.getUnitAt(0),
        source.getUnitAt(7), source.getUnitAt(4), source.getUnitAt(1),
        source.getUnitAt(8), source.getUnitAt(5), source.getUnitAt(2));
    tile.setPlayerUnit(0, source.getPlayerUnitAt(6));
    tile.setPlayerUnit(1, source.getPlayerUnitAt(3));
    tile.setPlayerUnit(2, source.getPlayerUnitAt(0));
    tile.setPlayerUnit(3, source.getPlayerUnitAt(7));
    tile.setPlayerUnit(4, source.getPlayerUnitAt(4));
    tile.setPlayerUnit(5, source.getPlayerUnitAt(1));
    tile.setPlayerUnit(6, source.getPlayerUnitAt(8));
    tile.setPlayerUnit(7, source.getPlayerUnitAt(5));
    tile.setPlayerUnit(8, source.getPlayerUnitAt(2));
    tile.setPassability(
        source.isPassableAt(6), source.isPassableAt(3), source.isPassableAt(0),
        source.isPassableAt(7), source.isPassableAt(4), source.isPassableAt(1),
        source.isPassableAt(8), source.isPassableAt(5), source.isPassableAt(2));
    tile.setSocketsAndWeight(
        source.getSocket(cSocketWest), source.getSocket(cSocketNorth),
        source.getSocket(cSocketEast), source.getSocket(cSocketSouth), source.weight);
    tile.rotation = (source.rotation + 1) % 4;
    return tile;
}
