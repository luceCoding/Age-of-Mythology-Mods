class Director {
    // --- Configurable Tuning Parameters ---
    float m_alphaSensitivity    = 0.4;
    float m_exponentK           = 0.70;
    float m_targetDestruction   = 0.2;
    
    // Configurable Daily Multiplier Clamps
    float m_minDailyFactor      = 1.0;  // Max daily nerf
    float m_maxDailyFactor      = 1.5;  // Max daily buff

    float m_lastDailyFactor     = 1.00;  // Calculated relative factor for the upcoming day

    void initialize(float alphaSensitivity = 0.4, float exponentK = 0.70, float targetDestruction = 0.2, float minDailyFactor = 1.0, float maxDailyFactor = 1.5) {
        m_alphaSensitivity = alphaSensitivity;
        m_exponentK = exponentK;
        m_targetDestruction = targetDestruction;
        m_minDailyFactor = minDailyFactor;
        m_maxDailyFactor = maxDailyFactor;
    }

    int getTotalHumanAliveBuildings() {
        int total = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue; // Skip Zombie team
            total = total + g_towerTracker.getAlivePlayerBuildingCount(p);
        }
        return total;
    }

    int getTotalHumanDeadBuildingsToday() {
        int total = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue;
            total = total + g_towerTracker.getDeadPlayerBuildingCount(p);
        }
        return total;
    }

    void resetHumanDeadBuildingsToday() {
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue;
            g_towerTracker.resetDeadPlayerBuildingCount(p);
        }
    }

    int getHumanPlayerCount() {
        int count = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 1 && kbPlayerIsHuman(p) && trPlayerIsDefeatedOrResigned(p) == false) {
                count = count + 1;
            }
        }
        if (count <= 0) return 1;
        return count;
    }

    int getZombiePlayerCount() {
        int count = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2 && kbPlayerIsHuman(p) && trPlayerIsDefeatedOrResigned(p) == false) {
                count = count + 1;
            }
        }
        if (count <= 0) return 1;
        return count;
    }

    float getTeamSizeScale(int myTeamSize = 1, int opposingTeamSize = 1) {
        return getGenericTeamScale(myTeamSize, opposingTeamSize, m_exponentK);
    }

    // Evaluated at Midnight/Dawn: Uses your tracker's alive and dead building counts
    float processEndOfDay() {
        int aliveCount = getTotalHumanAliveBuildings();
        int deadCount  = getTotalHumanDeadBuildingsToday();
        int totalCapacity = aliveCount + deadCount;

        if (totalCapacity <= 0) {
            m_lastDailyFactor = 1.0;
            resetHumanDeadBuildingsToday();
            return m_lastDailyFactor;
        }

        // Actual Destruction = Dead Today / Total Capacity Today
        float actualDestruction = (1.0 * deadCount) / (1.0 * totalCapacity);
        float delta = m_targetDestruction - actualDestruction;

        // Raw factor calculation
        float rawFactor = 1.0 + (m_alphaSensitivity * delta);

        // Clamp daily factor
        if (rawFactor < m_minDailyFactor) rawFactor = m_minDailyFactor;
        if (rawFactor > m_maxDailyFactor) rawFactor = m_maxDailyFactor;

        m_lastDailyFactor = rawFactor;

        // Reset cumulative dead counters in the building tracker for the new day
        resetHumanDeadBuildingsToday();

        return m_lastDailyFactor;
    }

    // Returns the relative float multiplier (e.g., 1.10 for +10% HP)
    float getDailyHealthFactor() {
        return m_lastDailyFactor;
    }

    // Baseline Asymmetry Scale for new spawns or income
    float getZombieAsymmetryScale() {
        int zombies = getZombiePlayerCount();
        int humans = getHumanPlayerCount();
        return getTeamSizeScale(zombies, humans);
    }
};

Director g_director;