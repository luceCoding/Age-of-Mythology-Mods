// Hands out plant protounits as command carriers.
// Each player gets their own sequence; releasing a player's plants lets zombie commands reuse the same set.
// Primary range: cUnitTypePlantGreekBush..cUnitTypePlantAtlanteanFern
class PlantAllocator {
    int m_maxPlants = 0;
    int[] m_counts = default;
    int[] m_targets = default; // Building each allocated plant was added to, indexed by p * m_maxPlants + slot

    void ensureInitialised() {
        if (m_counts.size() == 0) {
            m_maxPlants = cUnitTypePlantAtlanteanFern - cUnitTypePlantGreekBush + 1;
            m_counts = new int(cNumberPlayers + 1, 0);
            m_targets = new int((cNumberPlayers + 1) * m_maxPlants, -1);
        }
    }

    int allocate(int p = 1, int targetProtoType = -1) {
        ensureInitialised();
        int slot = m_counts[p];
        if (slot >= m_maxPlants) {
            errorLog("No free command plants left for player " + p);
            return -1;
        }
        m_targets[p * m_maxPlants + slot] = targetProtoType;
        m_counts[p] = slot + 1;
        return cUnitTypePlantGreekBush + slot;
    }

    // Removes the listeners and train slots of every plant allocated to this player and frees them.
    void releaseAll(int p = 1) {
        ensureInitialised();
        for (int slot = 0; slot < m_counts[p]; slot++) {
            int plantType = cUnitTypePlantGreekBush + slot;
            g_OnCreationListener.deregisterAll(p, plantType);
            trProtounitRemoveTrain(kbProtoUnitGetName(m_targets[p * m_maxPlants + slot]), p, kbProtoUnitGetName(plantType));
        }
        m_counts[p] = 0;
    }
};

PlantAllocator g_PlantAllocator;