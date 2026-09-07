class CreepCamp {
    int m_count = 1;
    int m_respawnTime = 30; // Seconds delay after camp is completely cleared
    float m_initialSpawnTime = -1.0;
    float m_deathTime = -1.0; // -1.0 indicates units are currently alive
    bool m_hasSpawned = false;
    string m_protoUnit = "";
    int m_placeHolderUnitId = -1;
    vector m_campPosition = cInvalidVector;
    int m_unitSize = 0; // Tracks active living/spawned units for this camp
    bool m_incrementCamp = true;
    float m_unitScale = 1.0;
    int m_idleAnimID = 0;

    float m_alertHPThresholdRatio = 0.9;
    string m_alertMsg = "";
    string m_alertSound = "";

    // Cache variables for areAllDead()
    float m_lastCheckTime = -1.0;
    bool m_cachedAreAllDead = false;

    // Camp-wide tracking flags
    bool m_isAggroed = false;
    bool m_hasAlerted = false;

    int[] m_unitIds = default;

    void init(int placeHolderUnitId = -1, int respawnTime = 30, string protoUnit = "", int count = 1,
              float initialSpawnDelay = 0.0, float unitScale = 1.0, bool incrementCamp = true,
              float alertHPThresholdRatio = 0.9, string alertMsg = "", string alertSound = ""){
        m_campPosition = kbUnitGetTruePosition(placeHolderUnitId);

        m_respawnTime = respawnTime;
        m_initialSpawnTime = xsGetTime() + initialSpawnDelay;
        m_protoUnit = protoUnit;
        m_count = count;
        
        m_deathTime = -1.0;
        m_hasSpawned = false;
        m_placeHolderUnitId = placeHolderUnitId;
        m_unitSize = 0;
        m_incrementCamp = incrementCamp;
        m_unitScale = unitScale;
        m_isAggroed = false;
        m_hasAlerted = false;

        // Reset cache on init
        m_lastCheckTime = -1.0;
        m_cachedAreAllDead = false;
        m_idleAnimID = kbGetAnimationID("Idle");

        m_alertHPThresholdRatio = alertHPThresholdRatio;
        m_alertMsg = alertMsg;
        m_alertSound = alertSound;
    }

    bool areAllDead(){
        float currentTime = xsGetTime();

        // Return cached result if called within 1 second of the last check
        if (m_lastCheckTime != -1.0 && (currentTime - m_lastCheckTime < 1.0)) {
            return m_cachedAreAllDead;
        }

        // Update last check time
        m_lastCheckTime = currentTime;

        if (m_unitSize == 0) { 
            m_cachedAreAllDead = true;
            return true; 
        }

        bool anyDamagedAndIdle = false;
        bool allFullHealthAndIdle = true;
        bool hasLivingUnits = false;

        for (int i = 0; i < m_unitSize; i++){
            selectSingle(m_unitIds[i]);
            if (trUnitDead() == false){
                hasLivingUnits = true;
                float hpRatio = kbUnitGetStatFloat(m_unitIds[i], cUnitStatHPRatio);
                
                if (hpRatio < 1.0) {
                    allFullHealthAndIdle = false;
                    // Only flag damage if the unit is also back to an idle state
                    if (kbUnitGetCurAnimationID(m_unitIds[i]) == m_idleAnimID) {
                        anyDamagedAndIdle = true;
                    }
                } else {
                    // Unit is at full HP, check if it's back to idle
                    if (kbUnitGetCurAnimationID(m_unitIds[i]) != m_idleAnimID) {
                        allFullHealthAndIdle = false;
                    }
                }
            }
        }

        // If all units are dead
        if (!hasLivingUnits) {
            m_cachedAreAllDead = true;
            return true;
        }

        // If any unit is damaged, idle, and camp isn't aggroed yet -> Aggro the ENTIRE camp ONCE
        if (anyDamagedAndIdle && (m_isAggroed == false)) {
            for (int i = 0; i < m_unitSize; i++) {
                selectSingle(m_unitIds[i]);
                if (trUnitDead() == false) {
                    trUnitSetStance("Defensive");
                }
            }
            m_isAggroed = true;
        }
        // If all living units are back to full health, idle, and camp was aggroed -> Reset stance & reset alert tracker
        else if (allFullHealthAndIdle && m_isAggroed) {
            for (int i = 0; i < m_unitSize; i++) {
                selectSingle(m_unitIds[i]);
                if (trUnitDead() == false) {
                    trUnitSetStance("No Attack");
                    trUnitMoveToPoint(m_campPosition.x, m_campPosition.y, m_campPosition.z);
                }
            }
            m_isAggroed = false;
            m_hasAlerted = false; // Reset alert so it can fire again if re-engaged later
        }

        // Handle one-time camp attack notification threshold
        if (m_isAggroed && (m_hasAlerted == false) && (m_alertMsg != "" || m_alertSound != "")) {
            float lowestHPRatio = 1.0;
            for (int i = 0; i < m_unitSize; i++) {
                selectSingle(m_unitIds[i]);
                if (trUnitDead() == false) {
                    lowestHPRatio = min(lowestHPRatio, kbUnitGetStatFloat(m_unitIds[i], cUnitStatHPRatio));
                }
            }
            
            if (lowestHPRatio < m_alertHPThresholdRatio) {
                if (m_alertMsg != "") {
                    trChatSend(cNumberPlayers, m_alertMsg);
                }
                if (m_alertSound != "") {
                    trSoundsetPlay(m_alertSound);
                }
                m_hasAlerted = true; // Lock it so it doesn't repeat this cycle
            }
        }

        m_cachedAreAllDead = false;
        return false;
    }

    void spawnUnits(){
        m_unitSize = 0;
        for (int i = 0; i < m_count; i++){
            int newUnitId = trUnitCreate(m_protoUnit, m_campPosition.x, configMapBaseHeight, m_campPosition.z, xsRandInt(0, 359), 0);
            selectSingle(newUnitId);
            trUnitSetScale(m_unitScale, m_unitScale, m_unitScale);
            if (newUnitId != -1) {
                if (m_unitSize < m_unitIds.size()) {
                    m_unitIds[m_unitSize] = newUnitId;
                } else {
                    m_unitIds.add(newUnitId);
                }
                m_unitSize++;
            }
        }
        
        // Reset state flags and invalidate cache on new spawn
        m_isAggroed = false;
        m_hasAlerted = false;
        m_lastCheckTime = -1.0;

        // Grow the camp size for the next respawn cycle
        if (m_incrementCamp){
            m_count = m_count + 1;
        }
    }

    void processCamp(){
        if (m_hasSpawned == false) {
            if (xsGetTime() < m_initialSpawnTime) {
                return;
            }

            selectSingle(m_placeHolderUnitId);
            trUnitDestroy();
            spawnUnits();
            m_hasSpawned = true;
            return;
        }

        bool cleared = areAllDead();

        // 2. If creeps are alive, keep death timestamp reset
        if (cleared == false) {
            m_deathTime = -1.0;
            return;
        }

        // 3. Mark the exact timestamp when all creeps die
        if (m_deathTime < 0.0) {
            m_deathTime = xsGetTime();
            return;
        }

        // 4. Wait until m_respawnTime seconds pass after m_deathTime
        if (xsGetTime() < (m_deathTime + m_respawnTime)) {
            return;
        }

        // 5. Timer finished: Respawn camp
        spawnUnits();
        m_deathTime = -1.0;
    }
};