class IncomeHandler {
    int[] m_goldUnitIDs = default;
    int team1_gold = 0;
    int team2_gold = 0;

    void addGold(int unitId = -1){
        m_goldUnitIDs.add(unitId);
    }

    void processGold(){
        for (int i = 0; i < m_goldUnitIDs.size(); i++) {
            int goldUnitId = m_goldUnitIDs[i];
            trUnitSelectClear();
            trUnitSelectByID(goldUnitId);
            if (trUnitDead() == true){
                int lastIndex = m_goldUnitIDs.size() - 1;
                m_goldUnitIDs[i] = m_goldUnitIDs[lastIndex];
                m_goldUnitIDs.resize(lastIndex, -1);
                i--;
                continue;
            }
            int owner = kbUnitGetPlayerID(goldUnitId);
            for(int p = 1; p < cNumberPlayers-2; p++) {
                if ((kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, goldUnitId, 1.5) >= 1)){
                    if (owner == p || trPlayerGetDiplomacy(p, owner) == "Ally") {continue;}
                    int goldAmount = 10 + (((xsGetTimeMS() - g_timeMSGameStarted) / 60000));
                    if (owner == 0) {goldAmount = goldAmount * 2;}

                    // Catch up mechanic
                    int pTeam = g_finalTeam[p];
                    if (pTeam == 1 && team2_gold > 0 && (team1_gold <= team2_gold * CATCHUP_GOLD_DIFF)) {
                        goldAmount = goldAmount * CATCHUP_GOLD_MECHANIC;
                    } else if (pTeam == 2 && team1_gold > 0 && (team2_gold <= team1_gold * CATCHUP_GOLD_DIFF)) {
                        goldAmount = goldAmount * CATCHUP_GOLD_MECHANIC;
                    }

                    trPlayerGrantResources(p, "gold", goldAmount);
                    if (pTeam == 1){
                        team1_gold = team1_gold + goldAmount;
                    }
                    else {
                        team2_gold = team2_gold + goldAmount;
                    }
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