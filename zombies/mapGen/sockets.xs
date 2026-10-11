const int cSocketNorth = 0;
const int cSocketEast = 1;
const int cSocketSouth = 2;
const int cSocketWest = 3;

// Bitwise Socket Flags (Powers of 2)
const int cSocketNone    = 0;       // 0000
const int cSocketWall    = 1;       // 0001
const int cSocketHallway = 2;       // 0010
const int cSocketOpen    = 4;       // 0100

const int cSocketTypeOpen = cSocketHallway | cSocketOpen;
const int cSocketTypeWall = cSocketWall;
const int cSocketTypeOpenOrWall = cSocketWall | cSocketOpen;
const int cSocketTypeHallwayOrOpenOrWall = cSocketOpen | cSocketHallway | cSocketWall;

int getOppositeSocketDirection(int direction = cSocketNorth) {
    return (direction + 2) % 4;
}

bool socketsMatch(int firstSocket = 0, int secondSocket = 0) {
    return (firstSocket & secondSocket) != 0;
}