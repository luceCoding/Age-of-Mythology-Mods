const int cSocketNorth = 0;
const int cSocketEast = 1;
const int cSocketSouth = 2;
const int cSocketWest = 3;

const int cSocketNone = 0;
const int cSocketOpen = 1;
const int cSocketWall = 2;
const int cSocketEntrance = 3;
const int cSocketTypeWallOrEntrance = 4;
const int cSocketTypeAny = 5;
const int cSocketInteractable = 6;
const int cSocketDecoration = 7;
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
    allowSocketAdjacency(cSocketOpen, cSocketTypeAny);
    allowSocketAdjacency(cSocketOpen, cSocketInteractable);

    allowSocketAdjacency(cSocketWall, cSocketWall);
    allowSocketAdjacency(cSocketWall, cSocketTypeWallOrEntrance);
    //allowSocketAdjacency(cSocketWall, cSocketTypeAny);

    allowSocketAdjacency(cSocketEntrance, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketEntrance, cSocketWall);

    allowSocketAdjacency(cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance);
    allowSocketAdjacency(cSocketTypeWallOrEntrance, cSocketTypeAny);

    allowSocketAdjacency(cSocketTypeAny, cSocketTypeAny);
    allowSocketAdjacency(cSocketTypeAny, cSocketInteractable);

    allowSocketAdjacency(cSocketDecoration, cSocketDecoration);
    allowSocketAdjacency(cSocketDecoration, cSocketOpen);
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
