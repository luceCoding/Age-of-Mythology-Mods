class RespawnManager {
    int[] m_unitIDs = default;
    int[] m_cardUUIDs = default;
    int[] m_owners = default;
    bool[] m_isRespawning = default;

    IntToIntHashMap m_unitIDToIndex;
    int[] m_unitsLostCache = default;
    bool m_initialized = false;

    void init() {
        if (m_initialized) return;
        
        int totalSlots = cNumberPlayers * MAX_CARDS_IN_BENCH;
        m_unitIDs = new int(totalSlots, -1);
        m_cardUUIDs = new int(totalSlots, -1);
        m_owners = new int(totalSlots, 0);
        m_isRespawning = new bool(totalSlots, false);

        m_unitsLostCache = new int(cNumberPlayers, 0);
        
        for (int p = 1; p <= cNumberPlayers - 2; p++) {
            m_unitsLostCache[p] = kbGetStatValueInt(p, cStatTypeUnitsLost);
        }
        m_initialized = true;
    }

    void add(int unitID = -1, int cardUUID = -1, int owner = 0){
        if (unitID < 0 || owner > cNumberPlayers - 2) return;
        if (m_initialized == false) init();
        
        // Prevent duplicate entries
        if (m_unitIDToIndex.get(unitID) >= 0) return;

        int baseIndex = owner * MAX_CARDS_IN_BENCH;
        int endIndex = baseIndex + MAX_CARDS_IN_BENCH;

        // Find the first available slot in the owner's block
        for (int i = baseIndex; i < endIndex; i++) {
            if (m_unitIDs[i] < 0) {
                m_unitIDs[i] = unitID;
                m_cardUUIDs[i] = cardUUID;
                m_owners[i] = owner;
                m_isRespawning[i] = false;

                m_unitIDToIndex.put(unitID, i);
                return;
            }
        }
    }

    void removeByIndex(int index = -1){
        if (index < 0 || index >= m_unitIDs.size()) return;

        int removedUnitID = m_unitIDs[index];
        if (removedUnitID < 0) return;

        m_unitIDs[index] = -1;
        m_cardUUIDs[index] = -1;
        m_owners[index] = 0;
        m_isRespawning[index] = false;

        m_unitIDToIndex.remove(removedUnitID);
    }

    void removeByUnitID(int unitID = -1){
        int index = m_unitIDToIndex.get(unitID);
        if (index >= 0) {
            removeByIndex(index);
        }
    }

    void removeByCardUUID(int cardUUID = -1){
        for (int i = 0; i < m_unitIDs.size(); i++) {
            if (m_cardUUIDs[i] == cardUUID) {
                removeByIndex(i);
                return;
            }
        }
    }

    bool isRespawningByIndex(int index = -1){
        if (index < 0 || index >= m_unitIDs.size()) return false;
        return m_isRespawning[index];
    }

    bool isRespawningByUnitID(int unitID = -1){
        int index = m_unitIDToIndex.get(unitID);
        if (index >= 0) {
            return m_isRespawning[index];
        }
        return false;
    }

    void respawn(int index = 0){
        if (index < 0 || index >= m_unitIDs.size()) return;

        int unitID = m_unitIDs[index];
        int cardUUID = m_cardUUIDs[index];
        int owner = m_owners[index];

        if (owner > cNumberPlayers - 2) {
            removeByIndex(index);
            return;
        }

        m_isRespawning[index] = true;

        // Calculate dynamic respawn delay
        int respawnTimeMS = RESPAWN_TIME_MS_BASE + (((xsGetTimeMS() - g_timeMSGameStarted) / 60000) * RESPAWN_TIME_ADDITIONAL_MS);

        // Schedule unit revival
        schedulerWithIntInt.add(respawnTimeMS, owner, cardUUID, [](int iterations = 1, int p = 0, int cardUUID = 0) -> bool {
            if (p > cNumberPlayers - 2) return false;

            BenchData bench = g_shop.m_benches[p];
            int cIndex = g_CardUUIDToIndex.get(cardUUID);
            if (cIndex < 0 || cIndex >= bench.getNumberOfCardsHeld()) return false;

            CardData deadCard = bench.m_cardArray[cIndex];
            if (deadCard.isNull() || deadCard.getUuid() != cardUUID) return false;
            if (deadCard.isDeployed() == false) return false;

            if (bench.spawnCard(deadCard, false)) {
                trSoundsetPlayPlayer(p, "HeroRevive");
                bench.m_cardArray[cIndex] = deadCard;
                g_shop.m_benches[p] = bench;

                // Re-register the newly spawned unit back into the tracker
                addToRespawn(deadCard, p);
            }
            return false;
        });

        // Untrack from active polling while revive timer counts down
        removeByIndex(index);
    }

    void process(){
        if (m_initialized == false) init();

        // Check player stats and iterate only dirty player blocks
        for (int p = 1; p <= cNumberPlayers - 2; p++) {
            int currentStat = kbGetStatValueInt(p, cStatTypeUnitsLost);
            
            // SKIP ENTIRE PLAYER BLOCK if unit count hasn't changed
            if (currentStat == m_unitsLostCache[p]) continue;

            int baseIndex = p * MAX_CARDS_IN_BENCH;
            int endIndex = baseIndex + MAX_CARDS_IN_BENCH;

            // Poll units assigned specifically to player p
            for (int i = baseIndex; i < endIndex; i++) {
                if (m_unitIDs[i] < 0 || m_isRespawning[i]) continue;
                
                selectSingle(m_unitIDs[i]);
                if (trUnitDead()){
                    respawn(i);
                }
            }

            m_unitsLostCache[p] = currentStat;
        }
    }
};

RespawnManager g_RespawnManager;

void addToRespawn(ref CardData card, int p = 0) { 
    if (card.isDeployed() == false || p > cNumberPlayers - 2) { return ;}
    g_RespawnManager.add(card.getDeployedUnitID(), card.getUuid(), p); 
}

void removeFromRespawn(ref CardData card) { 
    g_RespawnManager.removeByUnitID(card.getDeployedUnitID());
}

void startRespawn(){
    g_RespawnManager.init();

    // Shop respawner loop
    scheduler.add(2003, [](int iterations = 1) -> bool {
        g_RespawnManager.process();
        return true;
    });
}