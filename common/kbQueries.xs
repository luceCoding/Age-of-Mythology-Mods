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