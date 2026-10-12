const int cSocketNorth = 0;
const int cSocketEast = 1;
const int cSocketSouth = 2;
const int cSocketWest = 3;

const int cSocketNone = 0;
const int cSocketOpen = 1;
const int cSocketWall = 2;
const int cSocketEntrance = 3;
const int cSocketTypeOpenOrWall = 4;
const int cSocketTypeWallOrEntrance = 5;
const int cSocketTypeAny = 6;
const int cSocketInteractable = 7;
const int cSocketTypeCount = 8;

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
    allowSocketAdjacency(cSocketOpen, cSocketTypeOpenOrWall);
    allowSocketAdjacency(cSocketOpen, cSocketTypeAny);
    allowSocketAdjacency(cSocketOpen, cSocketInteractable);

    allowSocketAdjacency(cSocketWall, cSocketWall);
    allowSocketAdjacency(cSocketWall, cSocketTypeOpenOrWall);
    allowSocketAdjacency(cSocketWall, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketWall, cSocketTypeAny);

    allowSocketAdjacency(cSocketEntrance, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketEntrance, cSocketWall);

    allowSocketAdjacency(cSocketTypeOpenOrWall, cSocketTypeOpenOrWall);
    allowSocketAdjacency(cSocketTypeOpenOrWall, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketTypeOpenOrWall, cSocketTypeAny);
    allowSocketAdjacency(cSocketTypeOpenOrWall, cSocketInteractable);

    allowSocketAdjacency(cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketTypeWallOrEntrance, cSocketTypeAny);

    allowSocketAdjacency(cSocketTypeAny, cSocketTypeAny);
    allowSocketAdjacency(cSocketTypeAny, cSocketInteractable);
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
