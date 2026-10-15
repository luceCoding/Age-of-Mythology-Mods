void processHumanInteractables(){
    for (int i = 0; i < g_humanInteractableObjects.size(); i++){
        int interactableId = g_humanInteractableObjects[i];
        int numberContained = kbUnitGetNumberContained(interactableId);
        int owner = kbUnitGetPlayerID(interactableId);
        if (numberContained > 0 && owner == cHumanAIPlayer) {
            vector v = kbUnitGetTruePosition(interactableId);
            for (int p = 1; p < cNumberPlayers; p++){
                int numberOfUnits = kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, interactableId, 1.0);
                if (numberOfUnits > 0){
                    selectSingle(interactableId);
                    trUnitConvert(p);
                    break;
                }
            }
        }
        else if (numberContained == 0 && owner != cHumanAIPlayer && kbUnitTypeCountInArea("Unit", owner, cUnitStateAlive, interactableId, 5.0) == 0){
            selectSingle(interactableId);
            trUnitConvert(cHumanAIPlayer);
        }
    }
}

void processTreasureChests(){
    for (int i = 0; i < g_treasureChestObjects.size(); i++){
        int interactableId = g_treasureChestObjects[i];
        int numberContained = kbUnitGetNumberContained(interactableId);
        if (numberContained > 0) {
            selectSingle(interactableId);
            trUnitSetAnimationPath("Opening","spc\buildings\props\osiris_piece_box\anim\osiris_piece_box_opening", false, -1, false);
            lowFreqSchedulerWithIntInt.add(2000, interactableId, 0, [](int iteration = 0, int unitId = 0, int _ = 0) -> bool {
                selectSingle(unitId);
                trUnitChangeProtoUnit(kbProtoUnitGetName(cUnitTypeVFXOsirisAnkh));
                playUnitSound(unitId, "AotgBlessingRewardReceivedEternal", SOUND_SET);
                lowFreqSchedulerWithIntInt.add(1000, unitId, 0, [](int iteration = 0, int unitId = 0, int _ = 0) -> bool {
                    vector v = kbUnitGetTruePosition(unitId);
                    int numPiles = 10;
                    for (int g = 0; g < numPiles; g++) {
                        float angle = (360.0 * xsIntToFloat(g)) / xsIntToFloat(numPiles);
                        float spawnRadius = xsRandFloat(0, 3.0); // Distance from the chest
                        float offsetX = spawnRadius * cosDeg(angle);
                        float offsetZ = spawnRadius * sinDeg(angle);
                        trUnitCreateForced(kbProtoUnitGetName(cUnitTypeGoldPile), v.x + offsetX, v.y, v.z + offsetZ, xsRandInt(0, 359), 0);
                    }
                    selectSingle(unitId);
                    trUnitDestroy();
                    return false;
                });
                return false;
            });
            g_treasureChestObjects.removeIndex(i);
            break;
        }
    }
}

void startInteractables(){
    lowFreqScheduler.add(1000, [](int iterations = 1) -> bool {
        processHumanInteractables();
        processTreasureChests();
        return true;
    });
}