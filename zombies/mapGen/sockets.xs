const int cSocketNorth = 0;
const int cSocketEast = 1;
const int cSocketSouth = 2;
const int cSocketWest = 3;

const int cSocketNone = 0;
const int cSocketRoomEdge = 1;
const int cSocketOpen = 2;
const int cSocketWall = 3;
const int cSocketTypeAny = 4;
const int cSocketInteractable = 5;
const int cSocketDecoration = 6;
const int cSocketTomb = 7;
const int cSocketObelisk = 8;
const int cSocketTypeCount = 9;

int[] g_socketAdjacencyTable = default;

void allowSocketAdjacency(int firstSocket = 0, int secondSocket = 0) {
    int firstIndex = (firstSocket * cSocketTypeCount) + secondSocket;
    int secondIndex = (secondSocket * cSocketTypeCount) + firstSocket;
    g_socketAdjacencyTable[firstIndex] = 1;
    g_socketAdjacencyTable[secondIndex] = 1;
}

void initializeSocketAdjacencyTable() {
    g_socketAdjacencyTable = new int(cSocketTypeCount * cSocketTypeCount, 0);

    allowSocketAdjacency(cSocketOpen, cSocketOpen);
    allowSocketAdjacency(cSocketOpen, cSocketWall);
    allowSocketAdjacency(cSocketOpen, cSocketTypeAny);
    allowSocketAdjacency(cSocketOpen, cSocketInteractable);
    allowSocketAdjacency(cSocketOpen, cSocketDecoration);

    allowSocketAdjacency(cSocketWall, cSocketWall);
    allowSocketAdjacency(cSocketWall, cSocketTypeAny);
    allowSocketAdjacency(cSocketWall, cSocketDecoration);
    allowSocketAdjacency(cSocketWall, cSocketInteractable);

    allowSocketAdjacency(cSocketTypeAny, cSocketTypeAny);
    allowSocketAdjacency(cSocketTypeAny, cSocketOpen);
    allowSocketAdjacency(cSocketTypeAny, cSocketWall);
    allowSocketAdjacency(cSocketTypeAny, cSocketInteractable);

    allowSocketAdjacency(cSocketTomb, cSocketObelisk);

    // Edges facing outside the room may be anything except an obelisk edge.
    for (int socket = 0; socket < cSocketTypeCount; socket = socket + 1) {
        if (socket == cSocketObelisk) continue;
        allowSocketAdjacency(cSocketRoomEdge, socket);
    }
}

int getOppositeSocketDirection(int direction = cSocketNorth) {
    return (direction + 2) % 4;
}

bool socketsMatch(int firstSocket = cSocketNone, int secondSocket = cSocketNone) {
    if (firstSocket < 0 || firstSocket >= cSocketTypeCount) return false;
    if (secondSocket < 0 || secondSocket >= cSocketTypeCount) return false;

    int adjacencyIndex = (firstSocket * cSocketTypeCount) + secondSocket;
    return g_socketAdjacencyTable[adjacencyIndex] == 1;
}
