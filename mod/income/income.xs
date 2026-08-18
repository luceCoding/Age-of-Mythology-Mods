class IncomeHandler {
    int[] g_goldUnitIDs = default;

    void addGold(int unitId = -1){
        g_goldUnitIDs.add(unitId);
    }

    void processGold(){
        for (int i = 0; i < g_goldUnitIDs.size(); i++) {
            int unitId = g_goldUnitIDs[i];
            trUnitSelectClear();
            trUnitSelectByID(unitId);
            if (trUnitDead() == true){
                int lastIndex = g_goldUnitIDs.size() - 1;
                g_goldUnitIDs[i] = g_goldUnitIDs[lastIndex];
                g_goldUnitIDs.resize(lastIndex, -1);
                i--;
                continue;
            }
            int owner = kbUnitGetPlayerID(unitId);
            for(int p = 1; p < cNumberPlayers-2; p++) {
                if ((kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, unitId, 1.5) >= 1)){
                    if (trPlayerGetDiplomacy(p, owner) == "Ally") {continue;}
                    int goldAmount = 10 + (((xsGetTimeMS() - g_timeMSGameStarted) / 60000));
                    trPlayerGrantResources(p, "gold", goldAmount);
                    trSoundsetPlayPlayer(p, "TributeReceived");
                    trUnitDestroy();
                    break;
                }
            }
        }
    }
};

IncomeHandler g_IncomeHandler;

void startSchedulers(){
    scheduler.add(307, [](int iterations = 1) -> bool {
        g_IncomeHandler.processGold();
        return true;
    });
}