class Director {
    // --- Configurable Tuning Parameters ---
    float m_targetDestruction   = 0.35;  // Target daily tower destruction ratio (35%)
    
    // Configurable Daily Multiplier Clamps
    float m_minDailyFactor      = 1.0;  // Max daily nerf
    float m_maxDailyFactor      = 2.0;  // Max daily buff

    float m_lastDailyFactor     = 1.00;  // Calculated relative factor for the upcoming day

    void setDailyFactorClamps(float minFactor = 1.00, float maxFactor = 1.50) {
        m_minDailyFactor = minFactor;
        m_maxDailyFactor = maxFactor;
    }

    void setTargetDestruction(float target = 0.35) {
        m_targetDestruction = target;
    }

    int getTotalHumanAliveBuildings() {
        int total = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue; // Skip Zombie team
            total = total + g_buildingTracker.getAlivePlayerBuildingCount(p);
        }
        // log(-1, "Total human alive buildings: " + total);
        return total;
    }

    int getTotalHumanDeadBuildingsToday() {
        int total = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue;
            total = total + g_buildingTracker.getDeadPlayerBuildingCount(p);
        }
        // log(-1, "Total human dead buildings today: " + total);
        return total;
    }

    void resetHumanDeadBuildingsToday() {
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) continue;
            g_buildingTracker.resetDeadPlayerBuildingCount(p);
        }
    }

    int getHumanPlayerCount() {
        int count = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 1 && kbPlayerIsHuman(p)) {
                count = count + 1;
            }
        }
        if (count <= 0) return 1;
        return count;
    }

    int getZombiePlayerCount() {
        int count = 0;
        for (int p = 1; p < cNumberPlayers; p++) {
            if (g_finalTeams[p] == 2) {
                count = count + 1;
            }
        }
        if (count <= 0) return 1;
        return count;
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
        float rawFactor = 1.0 + (g_alphaSensitivity * delta);

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
        return getGenericTeamScale(zombies, humans, g_exponentK);
    }
};

Director g_director;