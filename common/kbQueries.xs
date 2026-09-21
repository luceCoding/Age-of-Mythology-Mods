int countUnitsInArea(vector centerPos = cInvalidVector, float radius = 0.0, int playerID = 1, int cUnitType = cUnitTypeUnit, int unitState = cUnitStateAlive) {
    xsSetContextPlayer(playerID);
    int qID = kbUnitQueryCreate("area_search_query");
    kbUnitQuerySetPlayerID(qID, playerID);
    kbUnitQuerySetState(qID, unitState);
    kbUnitQuerySetPosition(qID, centerPos);
    kbUnitQuerySetMaximumDistance(qID, radius);
    kbUnitQuerySetUnitType(qID, cUnitType);
    int unitCount = kbUnitQueryExecute(qID);
    return unitCount;
}

void applyToUnitsInArea(vector centerPos = cInvalidVector, float radius = 0.0, int playerID = 1, int cUnitType = cUnitTypeUnit, int unitState = cUnitStateAlive,
                       void(int) apply = [](int unitID = -1) -> void {}) {
    if (playerID != -1){
        xsSetContextPlayer(playerID);
    }
    else {
        xsSetContextPlayer(-1);
    }
    int qID = kbUnitQueryCreate("area_search_query");
    if (playerID != -1){
        kbUnitQuerySetPlayerID(qID, playerID);
    }
    kbUnitQuerySetState(qID, unitState);
    kbUnitQuerySetPosition(qID, centerPos);
    kbUnitQuerySetMaximumDistance(qID, radius);
    kbUnitQuerySetUnitType(qID, cUnitType);
    int unitCount = kbUnitQueryExecute(qID);
    for (int i = 0; i < unitCount; i++) {
        int unitID = kbUnitQueryGetResult(qID, i);
        apply(unitID);
    }
}

void applyUptoXRandomUnitsInArea(int xCount = 0, vector centerPos = cInvalidVector, float radius = 0.0, int playerID = 1, int cUnitType = cUnitTypeUnit, int unitState = cUnitStateAlive,
                                 void(int) apply = [](int unitID = -1) -> void {}) {
    if (xCount <= 0) {
        return;
    }

    if (playerID != -1) {
        xsSetContextPlayer(playerID);
    } else {
        xsSetContextPlayer(-1);
    }

    int qID = kbUnitQueryCreate("area_search_query");
    if (playerID != -1) {
        kbUnitQuerySetPlayerID(qID, playerID);
    }
    kbUnitQuerySetState(qID, unitState);
    kbUnitQuerySetPosition(qID, centerPos);
    kbUnitQuerySetMaximumDistance(qID, radius);
    kbUnitQuerySetUnitType(qID, cUnitType);

    int unitCount = kbUnitQueryExecute(qID);
    if (unitCount <= 0) {
        return;
    }

    // Direct array allocation to store query results
    int[] units = new int(unitCount, -1);
    for (int i = 0; i < unitCount; i++) {
        units[i] = kbUnitQueryGetResult(qID, i);
    }

    // Process up to xCount or total found units, whichever is smaller
    int targetCount = xCount;
    if (targetCount > unitCount) {
        targetCount = unitCount;
    }

    // Partial Fisher-Yates shuffle to pick targetCount unique random units
    for (int i = 0; i < targetCount; i++) {
        int randIndex = xsRandInt(i, unitCount - 1);

        // Swap picked unit to current index
        int temp = units[i];
        units[i] = units[randIndex];
        units[randIndex] = temp;

        // Apply callback to the randomly selected unit
        apply(units[i]);
    }
}

void applyUptoXRandomUnitsInAreaForPlayers(int xCount = 0, vector centerPos = cInvalidVector, float radius = 0.0, 
                                           ref int[] playerIDs, int cUnitType = cUnitTypeUnit, int unitState = cUnitStateAlive,
                                           void(int) apply = [](int unitID = -1) -> void {}) {
    if (xCount <= 0 || playerIDs.size() <= 0) {
        return;
    }

    int[] allUnits = new int(0, -1);
    int playerCount = playerIDs.size();

    // Query each player and aggregate matching units into a single candidate pool
    for (int p = 0; p < playerCount; p++) {
        int pID = playerIDs[p];

        if (pID != -1) {
            xsSetContextPlayer(pID);
        } else {
            xsSetContextPlayer(-1);
        }

        int qID = kbUnitQueryCreate("area_search_query_p" + pID);
        if (pID != -1) {
            kbUnitQuerySetPlayerID(qID, pID);
        }
        kbUnitQuerySetState(qID, unitState);
        kbUnitQuerySetPosition(qID, centerPos);
        kbUnitQuerySetMaximumDistance(qID, radius);
        kbUnitQuerySetUnitType(qID, cUnitType);

        int unitCount = kbUnitQueryExecute(qID);
        for (int i = 0; i < unitCount; i++) {
            allUnits.add(kbUnitQueryGetResult(qID, i));
        }
    }

    int totalFound = allUnits.size();
    if (totalFound <= 0) {
        return;
    }

    int targetCount = xCount;
    if (targetCount > totalFound) {
        targetCount = totalFound;
    }

    // Partial Fisher-Yates shuffle across the multi-player candidate pool
    for (int i = 0; i < targetCount; i++) {
        int randIndex = xsRandInt(i, totalFound - 1);

        int temp = allUnits[i];
        allUnits[i] = allUnits[randIndex];
        allUnits[randIndex] = temp;

        apply(allUnits[i]);
    }
}

int getRandomUnitInArea(vector centerPos = cInvalidVector, float radius = 0.0, int playerID = 1, int cUnitType = cUnitTypeUnit, int unitState = cUnitStateAlive) {
    if (playerID != -1){
        xsSetContextPlayer(playerID);
    }
    else {
        xsSetContextPlayer(-1);
    }
    int qID = kbUnitQueryCreate("area_search_query");
    kbUnitQueryResetResults(qID);

    if (playerID != -1) {
        kbUnitQuerySetPlayerID(qID, playerID);
    }
    
    kbUnitQuerySetState(qID, unitState);
    kbUnitQuerySetPosition(qID, centerPos);
    kbUnitQuerySetMaximumDistance(qID, radius);
    kbUnitQuerySetUnitType(qID, cUnitType);

    int unitCount = kbUnitQueryExecute(qID);

    if (unitCount > 0) {
        int rdmIdx = xsRandInt(0, kbUnitQueryNumberResults(qID)-1);
        return kbUnitQueryGetResult(qID, rdmIdx);
    }

    return -1;
}