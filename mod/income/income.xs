float g_team1_gold_offset = 0;
float g_team2_gold_offset = 0;
float g_team1_gold = 0;
float g_team2_gold = 0;

class IncomeHandler {
    int[] m_goldUnitIDs = default;
    int m_goldSize = 0; // Tracks active gold units without shrinking/reallocating the array

    void addGold(int unitId = -1){
        if (m_goldSize < m_goldUnitIDs.size()) {
            m_goldUnitIDs[m_goldSize] = unitId;
        } else {
            m_goldUnitIDs.add(unitId);
        }
        m_goldSize++;
    }

    float getComebackMultiplier(int team = 0){
        float leadingGold = 0.0;
        float trailingGold = 0.0;

        if (g_team1_gold > g_team2_gold) {
            if (team != 2) { return 1.0; }
            leadingGold = g_team1_gold;
            trailingGold = g_team2_gold;
        } else if (g_team2_gold > g_team1_gold) {
            if (team != 1) { return 1.0; }
            leadingGold = g_team2_gold;
            trailingGold = g_team1_gold;
        } else {
            return 1.0;
        }

        if (leadingGold <= 0.0) { return 1.0; }

        float goldDifference = (leadingGold - trailingGold) / leadingGold;
        if (goldDifference < CATCHUP_GOLD_MIN_DIFFERENCE) { return 1.0; }
        if (goldDifference >= CATCHUP_GOLD_MAX_DIFFERENCE) {
            return CATCHUP_GOLD_MAX_MULTIPLIER;
        }

        float progress = (goldDifference - CATCHUP_GOLD_MIN_DIFFERENCE) /
            (CATCHUP_GOLD_MAX_DIFFERENCE - CATCHUP_GOLD_MIN_DIFFERENCE);
        return CATCHUP_GOLD_BASE_MULTIPLIER +
            progress * (CATCHUP_GOLD_MAX_MULTIPLIER - CATCHUP_GOLD_BASE_MULTIPLIER);
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
                if ((kbUnitTypeCountInArea(kbUnitTypeGetName(UNIT_TYPE_UNIT), p, cUnitStateAlive, goldUnitId, 1.5) >= 1)){
                    int goldAmount = INITIAL_GOLD_REWARD + getMinsPastSinceStart();
                    if (owner == 0) {goldAmount = goldAmount * 2;}

                    // Catch up mechanic
                    int pTeam = g_finalTeam[p];
                    float comebackMultiplier = getComebackMultiplier(pTeam);
                    goldAmount = goldAmount * comebackMultiplier;

                    // 1. Grant the full gold amount to the collecting player
                    trPlayerGrantResources(p, "gold", goldAmount);
                    trSoundsetPlayPlayer(p, "TributeReceived");
                    
                    int sharedAmount = goldAmount * SHARED_GOLD_COEFFICIENT; // Shared gold

                    // 2. Loop to find and reward teammates
                    for(int ally = 1; ally <= cNumberPlayers - 2; ally++) {
                        if (ally == p) { continue; } // Skip the player who picked it up
                        
                        if (g_finalTeam[ally] == pTeam) {
                            trPlayerGrantResources(ally, "gold", sharedAmount);
                        }
                    }

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

    void playerSells(int p = 0, int amount = 0){
        int goldAmount = amount * SELL_MULTIPLIER;
        trPlayerGrantResources(p, "Gold", goldAmount);
        if (g_finalTeam[p] == 1) {
            g_team1_gold_offset += goldAmount;
        } else if (g_finalTeam[p] == 2) {
            g_team2_gold_offset += goldAmount;
        }
    }

    void playerBuys(int p = 0, int amount = 0){
        trPlayerGrantResources(p, "Gold", -amount);
    }
};

IncomeHandler g_IncomeHandler;

void startIncome(){

    // Check gold pickups
    midFreqScheduler.add(503, [](int iterations = 1) -> bool {
        g_IncomeHandler.processGold();
        return true;
    });

    // Increase gold kill bounties over time
    lowFreqScheduler.add(60013, [](int iterations = 1) -> bool {

        CardParameters[] params = g_protoIDToCardParametersMap.getValues();
        for (int i = 0; i < params.size(); i++) {
            CardParameters param = params[i];
            string targetProto = kbProtoUnitGetName(param.getProtoID());
            for (int p = 1; p <= cNumberPlayers-2; p++){
                trModifyProtounitResource(targetProto, "Gold", p, cXSPUResourceEffectKillReward, 1, cXSRelativityAbsolute);
            }
        }

        for (int i = 0; i < g_creepCampTypes.size(); i++) {
            string creepCampType = g_creepCampTypes[i];
            trModifyProtounitResource(creepCampType, "Gold", 0, cXSPUResourceEffectKillReward, i+1, cXSRelativityAbsolute);
        }

        for (int i = 0; i < g_waveTypes.size(); i++) {
            string waveType = g_waveTypes[i];
            trModifyProtounitResource(waveType, "Gold", cNumberPlayers, cXSPUResourceEffectKillReward, 1, cXSRelativityAbsolute);
            trModifyProtounitResource(waveType, "Gold", cNumberPlayers-1, cXSPUResourceEffectKillReward, 1, cXSRelativityAbsolute);
        }

        trModifyProtounitResource(kbProtoUnitGetName(TOP_BOSS_PROTO), "Gold", 0, cXSPUResourceEffectKillReward, 5, cXSRelativityAbsolute);
        trModifyProtounitResource(kbProtoUnitGetName(BOT_BOSS_PROTO), "Gold", 0, cXSPUResourceEffectKillReward, 5, cXSRelativityAbsolute);

        return true;
    });

    for (int p = 0; p <= cNumberPlayers; p++){
        g_OnCreationListener.register(p, cUnitTypeGoldPile, false, [](int unitId = -1) -> void {
                g_IncomeHandler.addGold(unitId);
                selectSingle(unitId);
                trUnitSetScale(0.5, 0.5, 0.5);
            }
        );
    }

    for(int p = 1; p <= cNumberPlayers - 2; p++) {
        if (g_finalTeam[p] == 1){
            g_team1_gold_offset = g_team1_gold_offset + kbGetStatValueFloat(p, cStatTypeResourceCount, 0) + STARTING_GOLD;
        }
        else {
            g_team2_gold_offset = g_team2_gold_offset + kbGetStatValueFloat(p, cStatTypeResourceCount, 0) + STARTING_GOLD;
        }
        int food = kbGetResourceAmount(p, kbGetResourceID("Food"));
        int wood = kbGetResourceAmount(p, kbGetResourceID("Wood"));
        int gold = kbGetResourceAmount(p, kbGetResourceID("Gold"));
        int favor = kbGetResourceAmount(p, kbGetResourceID("Favor"));
        trPlayerGrantResources(p, "Food", -food);
        trPlayerGrantResources(p, "Wood", -wood);
        trPlayerGrantResources(p, "Gold", -gold);
        trPlayerGrantResources(p, "Favor", -favor);
        trPlayerGrantResources(p, "Gold", STARTING_GOLD);
    }

    trCounterAddTime("title", -999999, 0, "--Total Gold Collected--");
    trCounterAddTime("t1", -999999, 0, "Team 1: 0");
    trCounterAddTime("t2", -999999, 0, "Team 2: 0");

    lowFreqScheduler.add(7000, [](int iterations = 1) -> bool {
        float g_team1_gold_count = 0.0;
        float g_team2_gold_count = 0.0;
        for(int p = 1; p <= cNumberPlayers - 2; p++) {
            if (g_finalTeam[p] == 1){
                g_team1_gold_count = g_team1_gold_count + kbGetStatValueFloat(p, cStatTypeResourceCount, 0);
            }
            else {
                g_team2_gold_count = g_team2_gold_count + kbGetStatValueFloat(p, cStatTypeResourceCount, 0);
            }
        }
        g_team1_gold = g_team1_gold_count - g_team1_gold_offset;
        g_team2_gold = g_team2_gold_count - g_team2_gold_offset;
        trCounterAbort("t1");
        trCounterAbort("t2");
        string team1Label = "Team 1";
        string team2Label = "Team 2";
        float team1ComebackMultiplier = g_IncomeHandler.getComebackMultiplier(1);
        if (team1ComebackMultiplier > 1.0) {
            int team1ComebackPercent = ((team1ComebackMultiplier - 1.0) * 100.0) + 0.5;
            team1Label = team1Label + "(+" + team1ComebackPercent + "% Gold)";
        }
        float team2ComebackMultiplier = g_IncomeHandler.getComebackMultiplier(2);
        if (team2ComebackMultiplier > 1.0) {
            int team2ComebackPercent = ((team2ComebackMultiplier - 1.0) * 100.0) + 0.5;
            team2Label = team2Label + "(+" + team2ComebackPercent + "% Gold)";
        }
        trCounterAddTime("t1", -999999, 0, team1Label + ": " + xsFloatToInt(g_team1_gold));
        trCounterAddTime("t2", -999999, 0, team2Label + ": " + xsFloatToInt(g_team2_gold));
        return true;
    });
}