void createShops(){
    int team1Placed = 0;
    int team2Placed = 0;
    
    // 1 tile = 2 meters in the AoM engine
    float mapMeterX = configMapTileX * 2.0;
    float mapMeterZ = configMapTileZ * 2.0;
    
    // Map edge margins
    float marginX = mapMeterX * 0.025;
    float marginZ = mapMeterZ * 0.025;
    
    // Cluster radius (distance from the center of the cluster to the outer markets)
    float R = 7.0; 
    
    // Cluster Centers (Pushed inward by R so the outer units stay in bounds)
    // Team 1 (Left Corner): X near 0, Z near max
    float t1CenterX = marginX + R;
    float t1CenterZ = (mapMeterZ - marginZ) - R;
    
    // Team 2 (Right Corner): X near max, Z near 0
    float t2CenterX = (mapMeterX - marginX) - R;
    float t2CenterZ = marginZ + R;

    int maxHumanPlayer = cNumberPlayers - 2;

    for(int p = 1; p <= maxHumanPlayer; p = p + 1) {
        float spawnX = 0.0;
        float spawnZ = 0.0;
        float offsetX = 0.0;
        float offsetZ = 0.0;
        
        int placed = 0;

        // Determine which team's cluster we are adding to
        if (g_finalTeam[p] == 1) {
            placed = team1Placed;
            team1Placed = team1Placed + 1;
        } else if (g_finalTeam[p] == 2) {
            placed = team2Placed;
            team2Placed = team2Placed + 1;
        } else {
            continue; // Skip if no team is assigned somehow
        }

        // Hardcoded radial offsets to form a box, with the 5th in the center
        if (placed == 0) {
            offsetX = 0.0 - R; 
            offsetZ = R;       // Top-Left of cluster
        } else if (placed == 1) {
            offsetX = R; 
            offsetZ = R;       // Top-Right of cluster
        } else if (placed == 2) {
            offsetX = 0.0 - R; 
            offsetZ = 0.0 - R; // Bottom-Left of cluster
        } else if (placed == 3) {
            offsetX = R; 
            offsetZ = 0.0 - R; // Bottom-Right of cluster
        } else if (placed == 4) {
            offsetX = 0.0; 
            offsetZ = 0.0;     // 5th Player goes dead center
        } else {
            // Fallback just in case you ever increase max players beyond 5v5
            offsetX = R + (placed * 5.0);
            offsetZ = 0.0;
        }

        // Apply the calculated offsets to the respective team's center
        if (g_finalTeam[p] == 1) {
            spawnX = t1CenterX + offsetX;
            spawnZ = t1CenterZ + offsetZ;
        } else if (g_finalTeam[p] == 2) {
            spawnX = t2CenterX + offsetX;
            spawnZ = t2CenterZ + offsetZ;
        }

        // Spawn the market
        int shopId = trUnitCreateForced("Market", spawnX, configMapBaseHeight, spawnZ, xsRandFloat(0.0, 360.0), p);
        trUnitSelectClear();
        trUnitSelectByID(shopId);
        trUnitSetScale(0.5, 0.5, 0.5);

        BenchData bench = g_shop.m_benches[p];
        bench.init(p, shopId);
        g_shop.m_benches[p] = bench;
    }
}

void modifyPlayerData(){
    for(int p = 1; p <= cNumberPlayers - 2; p++) {
        trModifyProtounitData("Market", p, 23, 0.5, 3); // Obstruction Radius X
        trModifyProtounitData("Market", p, 24, 0.5, 3); // Obstruction Radius Z
    }
}