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
    int[] m_unitIds = default;

    void init(int placeHolderUnitId = -1, int respawnTime = 30, string protoUnit = "", int count = 1, float initialSpawnDelay = 0.0, float unitScale = 1.0, bool incrementCamp = true){
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
    }

    bool areAllDead(){
        if (m_unitSize == 0) { return true; }
        for (int i = 0; i < m_unitSize; i++){
            selectSingle(m_unitIds[i]);
            if (trUnitDead() == false){
                return false;
            }
        }
        return true;
    }

    void spawnUnits(){
        m_unitSize = 0;
        for (int i = 0; i < m_count; i++){
            int newUnitId = trUnitCreate(m_protoUnit, m_campPosition.x, configMapBaseHeight, m_campPosition.z, xsRandInt(0, 360), 0);
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