void setUiVisible(bool visible = true){
    if(visible){
        trExecuteConsoleCommand("gadgetReal(AGameMinimap)");
    } else {
        trExecuteConsoleCommand("gadgetUnreal(AGameMinimap)");
    }
    for(int i = 0; i <= 6; i++){
        trUIPanelVisibility(i, visible);
    }
}

void postRatioCalculation(){
    cameraTrack.create(vector(10, 4, 10), 50, 45, 45);
    cameraTrack.addWaypoint(1, vector(10, 4, 10), 50, 45, 45);
    cameraTrack.play(true, 0);
    setUiVisible(true);
    trSetObscuredUnits(true);
    scheduler.add(1000, [](int iterations = 1) -> bool {
        startGame();
        return false;
    });
}

void performProportionCalculation(){
    setUiVisible(false);
    cameraTrack.create(vector(0.5 * kbGetMapXSize(), -999.0, 0.5 * kbGetMapZSize()), 1.0, 90.0, 90.0, 1.0);
    cameraTrack.addWaypoint(100000, vector(0.5 * kbGetMapXSize(), -999.0, 0.5 * kbGetMapZSize()), 1.0, 90.0, 90.0, 1.0);
    cameraTrack.play();
    scheduler.add(2000, [](int iterations = 1) -> bool {
        float startX = 0.5 * kbGetMapXSize();
        float posZ = 0.5 * kbGetMapZSize();
        IntUnitDeletionTracker tracker;
        for(int p = 1; p <= c; p++){
            trPlayerModifyLOS(p, true, 0);
        }
        trProtoUnitSetFlag(0, UI_SYSTEM_UNIT, "VisibleUnderFog", true);
        int objectToSee = trUnitCreateForced(UI_SYSTEM_UNIT, startX, -1000.0, posZ, 0, 0, true);
        selectSingle(objectToSee);
        trUnitSetScale(0.0, 0.0, 0.0);
        int lastVisible = 0;
        for(int i = 1; i <= 100000; i++){
            trUnitReposition(startX + SHIFT_SPEED * i, -1000.0, posZ, true, true);
            if(trUnitVisibleToPlayer()){
                lastVisible = i;
            }
        }
        trUnitDestroy();
        trProtoUnitSetFlag(0, UI_SYSTEM_UNIT, "VisibleUnderFog", false);
        for(int p = 1; p <= c; p++){
            trPlayerModifyLOS(p, false, 0);
        }
        for(int p = 1; p <= c; p++){
            int controlUnitId = trUnitCreateForced(UI_SYSTEM_UNIT, 0.5 * kbGetMapXSize(), 0.0, 0.5 * kbGetMapZSize(), 0, p);
            tracker.controlUnits.add(controlUnitId);
            for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                int unitId = trUnitCreateForced(UI_SYSTEM_UNIT, 0.5 * kbGetMapXSize(), 0.0, 0.5 * kbGetMapZSize(), 0, p);
                tracker.units.add(unitId);
            }
            trUnitSelectClear();
            if(p == trCurrentPlayer()){
                trUnitSelectByID(tracker.controlUnits[p - 1]);
                bool[] binary = toBinaryBits(lastVisible);
                for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                    if(binary[i]){
                        trUnitSelectByID(tracker.units[i + (p - 1) * BINARY_CONVERSION_DIGITS]);
                    }
                }
                trUnitGameSelect(true);
                trUnitSelectClear();
                trExecuteConsoleCommand("uiDeleteSelectedUnit(true)");
            }
        }
        schedulerWithIntUnitDeletionTracker.add(0, tracker, [](int iteration = 0, ref IntUnitDeletionTracker tracker) -> bool {
            int[] controlUnits = tracker.controlUnits;
            int[] units = tracker.units;
            for(int p = 1; p <= c; p++){
                selectSingle(controlUnits[p - 1]);
                if(trUnitAlive() && trPlayerIsDefeatedOrResigned(p) == false && kbPlayerIsHuman(p)){
                    return true;
                }
            }
            playerScreenRatio.resize((c+1), 0.0);
            playerScreenIconSizeCompensationValue.resize((c+1), 0.0);
            for(int p = 1; p <= c; p++){
                if(trPlayerIsDefeatedOrResigned(p) || kbPlayerIsHuman(p) == false){
                    playerScreenRatio[p] = DEFAULT_SCREEN_RATIO;
                    playerScreenIconSizeCompensationValue[p] = 1.0;
                } else {
                    bool[] binaryBits = new bool(BINARY_CONVERSION_DIGITS, false);
                    for(int i = 0; i < BINARY_CONVERSION_DIGITS; i++){
                        int unitId = units[i + (p - 1) * BINARY_CONVERSION_DIGITS];
                        selectSingle(unitId);
                        binaryBits[i] = trUnitAlive() == false;
                        trUnitDestroy();
                    }
                    int value = fromBinaryBits(binaryBits);
                    playerScreenRatio[p] = xsIntToFloat(value) / MAGIC_RATIO_FROM_CALCULATION;
                    playerScreenIconSizeCompensationValue[p] = max(1.0, DEFAULT_SCREEN_RATIO / playerScreenRatio[p]);
                }
            }
            postRatioCalculation();
            return false;
        });
        return false;
    });
}

string getIconPathFormat(string iconPath = "", int size = 128){
    return displayCompensatedIcon(size, size, iconPath);
}