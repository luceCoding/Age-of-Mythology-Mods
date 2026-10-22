class BuildingTracker
{
   int m_maxPlayers = cNumberPlayers+1;
   int m_maxBuildingsPerPlayer = 1024;
   int[] m_counts = default;
   int[] m_deadCounts = default; // Cumulative buildings lost per player
   int[] m_unitIds = default;

   void ensureInitialised(){
      if (m_counts.size() == 0) {
         m_counts = new int(m_maxPlayers, 0);
         m_deadCounts = new int(m_maxPlayers, 0);
         m_unitIds = new int(m_maxPlayers * m_maxBuildingsPerPlayer, -1);
      }
   }

   // Removes dead buildings by overwriting them with the last tracked building (pop and swap).
   void pruneDeadBuildings(int p = -1){
      int count = m_counts[p];
      int base = p * m_maxBuildingsPerPlayer;
      int i = 0;
      while (i < count) {
         selectSingle(m_unitIds[base + i]);
         if (trUnitDead()) {
            count = count - 1;
            m_unitIds[base + i] = m_unitIds[base + count];
            m_unitIds[base + count] = -1;
            m_deadCounts[p] = m_deadCounts[p] + 1;
         } else {
            i = i + 1;
         }
      }
      m_counts[p] = count;
   }

   void resetDeadPlayerBuildingCount(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return;
      }
      m_deadCounts[p] = 0;
   }

   // Total buildings of this player that have died, including ones not yet pruned.
   int getDeadPlayerBuildingCount(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return 0;
      }
      pruneDeadBuildings(p);
      return m_deadCounts[p];
   }

   void addBuilding(int unitId = -1){
      ensureInitialised();
      int p = kbUnitGetPlayerID(unitId);
      if (p < 0 || p >= m_maxPlayers) {
         return;
      }
      if (m_counts[p] >= m_maxBuildingsPerPlayer) {
         pruneDeadBuildings(p);
         if (m_counts[p] >= m_maxBuildingsPerPlayer) {
            errorLog("Building tracker is full for player " + p);
            return;
         }
      }
      m_unitIds[p * m_maxBuildingsPerPlayer + m_counts[p]] = unitId;
      m_counts[p] = m_counts[p] + 1;
   }

   int getAlivePlayerBuildingCount(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return 0;
      }
      pruneDeadBuildings(p);
      return m_counts[p];
   }

   int getRandomPlayerBuildingId(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return -1;
      }
      int base = p * m_maxBuildingsPerPlayer;
      while (m_counts[p] > 0) {
         int index = xsRandInt(0, m_counts[p] - 1);
         int unitId = m_unitIds[base + index];
         selectSingle(unitId);
         if (trUnitDead() == false) {
            return unitId;
         }
         m_counts[p] = m_counts[p] - 1;
         m_deadCounts[p] = m_deadCounts[p] + 1;
         m_unitIds[base + index] = m_unitIds[base + m_counts[p]];
         m_unitIds[base + m_counts[p]] = -1;
      }
      return -1;
   }

   int[] getAllPlayerBuildings(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return new int(0, -1);
      }
      pruneDeadBuildings(p);
      int count = m_counts[p];
      int[] buildings = new int(count, -1);
      for (int i = 0; i < count; i++) {
         buildings[i] = m_unitIds[p * m_maxBuildingsPerPlayer + i];
      }
      return buildings;
   }

   // Stops tracking every building of this player.
   void removeAllPlayerBuildings(int p = -1){
      ensureInitialised();
      if (p < 0 || p >= m_maxPlayers) {
         return;
      }
      m_counts[p] = 0;
   }
};

BuildingTracker g_towerTracker;
BuildingTracker g_wallTracker;

void registerBuildingTracker(){
   for (int p = 1; p < cNumberPlayers; p++) {
      if (g_finalTeams[p] == 2) continue;
      for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++){
         int buildingType = g_upgradeableHumanBuildings[i];
         if (buildingType >= cUnitTypeWallShort && buildingType <= cUnitTypeWallGate) {
            g_OnCreationListener.register(p, buildingType, false, [](int unitId = -1) -> void {
                  g_wallTracker.addBuilding(unitId);
               }
            );
         }
         else {
            g_OnCreationListener.register(p, buildingType, false, [](int unitId = -1) -> void {
                  g_towerTracker.addBuilding(unitId);
               }
            );
         }
      }
      g_OnCreationListener.register(p, cUnitTypeSentinel, false, [](int unitId = -1) -> void {
            g_towerTracker.addBuilding(unitId);
         }
      );
   }
}