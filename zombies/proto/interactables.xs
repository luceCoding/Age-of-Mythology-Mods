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

void startInteractables(){
    lowFreqScheduler.add(1000, [](int iterations = 1) -> bool {
        processHumanInteractables();
        return true;
    });
}