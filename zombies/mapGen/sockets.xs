const int cSocketNorth = 0;
const int cSocketEast = 1;
const int cSocketSouth = 2;
const int cSocketWest = 3;

// Bitwise Socket Flags (Powers of 2)
const int cSocketNone    = 0;       // 0000
const int cSocketWall    = 1;       // 0001
const int cSocketOpen    = 2;       // 0010

const int cSocketInteractableNorth = 4;
const int cSocketInteractableEast = 8;
const int cSocketInteractableSouth = 16;
const int cSocketInteractableWest = 32;
const int cSocketInteractableAny = cSocketInteractableNorth
                                 | cSocketInteractableEast
                                 | cSocketInteractableSouth
                                 | cSocketInteractableWest;

const int cSocketTypeAny = cSocketOpen | cSocketWall;

int getSocketWithInteractableAccess(int socket = 0) {
    if ((socket & cSocketOpen) != 0) return socket | cSocketInteractableAny;
    return socket;
}

int rotateSocketClockwise(int socket = 0) {
    int rotatedSocket = socket & (cSocketOpen | cSocketWall);
    if ((socket & cSocketInteractableNorth) != 0) {
        rotatedSocket = rotatedSocket | cSocketInteractableEast;
    }
    if ((socket & cSocketInteractableEast) != 0) {
        rotatedSocket = rotatedSocket | cSocketInteractableSouth;
    }
    if ((socket & cSocketInteractableSouth) != 0) {
        rotatedSocket = rotatedSocket | cSocketInteractableWest;
    }
    if ((socket & cSocketInteractableWest) != 0) {
        rotatedSocket = rotatedSocket | cSocketInteractableNorth;
    }
    return rotatedSocket;
}

int getOppositeSocketDirection(int direction = cSocketNorth) {
    return (direction + 2) % 4;
}

bool socketsMatch(int firstSocket = 0, int secondSocket = 0) {
    return (firstSocket & secondSocket) != 0;
}