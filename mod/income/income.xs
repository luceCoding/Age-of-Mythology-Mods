class IncomeHandler {
    int[] m_goldUnitIDs = default;
    int m_goldSize = 0; // Tracks active gold units without shrinking/reallocating the array
    int team1_gold = 0;
    int team2_gold = 0;

    void addGold(int unitId = -1){
        if (m_goldSize < m_goldUnitIDs.size()) {
            m_goldUnitIDs[m_goldSize] = unitId;
        } else {
            m_goldUnitIDs.add(unitId);
        }
        m_goldSize++;
    }

    void processGold(){
        for (int i = 0; i < m_goldSize; i++) {
            int goldUnitId = m_goldUnitIDs[i];
            selectSingle(goldUnitId);
            
            // If the gold unit is dead, remove it via swap-and-pop
            if (trUnitDead() == true){
                m_goldSize--;
                if (i < m_goldSize) {
                    m_goldUnitIDs[i] = m_goldUnitIDs[m_goldSize];
                }
                i--; // Step back to check the newly swapped-in element
                continue;
            }

            int owner = kbUnitGetPlayerID(goldUnitId);
            for(int p = 1; p <= cNumberPlayers - 2; p++) {
                if (owner == p || g_finalTeam[p] == g_finalTeam[owner]) {continue;}
                if ((kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, goldUnitId, 1.5) >= 1)){
                    int goldAmount = 10 + getMinsPastSinceStart();
                    if (owner == 0) {goldAmount = goldAmount * 2;}

                    // Catch up mechanic
                    int pTeam = g_finalTeam[p];
                    if (pTeam == 1 && team2_gold > 0 && (team1_gold <= team2_gold * CATCHUP_GOLD_DIFF)) {
                        goldAmount = goldAmount * CATCHUP_GOLD_MECHANIC;
                    } else if (pTeam == 2 && team1_gold > 0 && (team2_gold <= team1_gold * CATCHUP_GOLD_DIFF)) {
                        goldAmount = goldAmount * CATCHUP_GOLD_MECHANIC;
                    }

                    // 1. Grant the full gold amount to the collecting player
                    trPlayerGrantResources(p, "gold", goldAmount);
                    
                    int totalGoldGenerated = goldAmount; // Track total wealth added to the team
                    int sharedAmount = goldAmount * SHARED_GOLD_COEFFICIENT; // Shared gold

                    // 2. Loop to find and reward teammates
                    for(int ally = 1; ally <= cNumberPlayers - 2; ally++) {
                        if (ally == p) { continue; } // Skip the player who picked it up
                        
                        if (g_finalTeam[ally] == pTeam) {
                            trPlayerGrantResources(ally, "gold", sharedAmount);
                            totalGoldGenerated = totalGoldGenerated + sharedAmount;
                        }
                    }

                    // 3. Update team trackers with the combined total wealth generated
                    if (pTeam == 1){
                        team1_gold = team1_gold + totalGoldGenerated;
                    } else {
                        team2_gold = team2_gold + totalGoldGenerated;
                    }
                    trSoundsetPlayPlayer(p, "TributeReceived");
                    trUnitDestroy();
                    
                    // Remove collected gold unit via swap-and-pop
                    m_goldSize--;
                    if (i < m_goldSize) {
                        m_goldUnitIDs[i] = m_goldUnitIDs[m_goldSize];
                    }
                    i--; // Step back to check the swapped-in element
                    
                    break;
                }
            }
        }
    }
};

IncomeHandler g_IncomeHandler;

void startIncome(){
    scheduler.add(307, [](int iterations = 1) -> bool {
        g_IncomeHandler.processGold();
        return true;
    });
}