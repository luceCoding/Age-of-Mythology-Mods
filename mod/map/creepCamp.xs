class CreepCamp {
    int m_count = 1;
    int m_respawnTime = 30; // Seconds delay after camp is completely cleared
    float m_initialSpawnTime = -1.0;
    float m_deathTime = -1.0; // -1.0 indicates units are currently alive
    bool m_hasSpawned = false;
    string m_protoUnit = "";
    int m_placeHolderUnitId = -1;
    vector m_campPosition = cInvalidVector;
    int[] m_unitIds = default;
    int m_unitSize = 0; // Tracks active living/spawned units for this camp

    void init(int placeHolderUnitId = -1, int respawnTime = 30, string protoUnit = "", int count = 1, float initialSpawnDelay = 0.0){
        m_campPosition = kbUnitGetTruePosition(placeHolderUnitId);

        m_respawnTime = respawnTime;
        m_initialSpawnTime = xsGetTime() + initialSpawnDelay;
        m_protoUnit = protoUnit;
        m_count = count;
        
        m_deathTime = -1.0;
        m_hasSpawned = false;
        m_placeHolderUnitId = placeHolderUnitId;
        m_unitSize = 0;
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
        m_count = m_count + 1;
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

        // 5. Timer finished: Respawn camp with increased size
        spawnUnits();
        m_deathTime = -1.0;
    }
};