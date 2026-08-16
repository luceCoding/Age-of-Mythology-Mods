void createShops(){
    int team1Placed = 0;
    int team2Placed = 0;
    
    // 1 tile = 2 meters in the AoM engine
    float mapMeterX = configMapTileX * 2.0;
    float mapMeterZ = configMapTileZ * 2.0;
    
    // Map edge margins (keeps shops hugging the boundary)
    float marginX = mapMeterX * 0.025;
    float marginZ = mapMeterZ * 0.025;
    
    // Distance between shops along the map walls
    float wallSpacing = 10.0; 
    
    // Corner Vertices
    // Team 1 (Left Corner): X near 0, Z near max
    float t1CornerX = marginX;
    float t1CornerZ = mapMeterZ - marginZ;
    
    // Team 2 (Right Corner): X near max, Z near 0
    float t2CornerX = mapMeterX - marginX;
    float t2CornerZ = marginZ;

    int maxHumanPlayer = cNumberPlayers - 2;

    for(int p = 1; p <= maxHumanPlayer; p = p + 1) {
        float spawnX = 0.0;
        float spawnZ = 0.0;
        float offsetX = 0.0;
        float offsetZ = 0.0;
        
        int placed = 0;

        if (g_finalTeam[p] == 1) {
            placed = team1Placed;
            team1Placed = team1Placed + 1;
        } else if (g_finalTeam[p] == 2) {
            placed = team2Placed;
            team2Placed = team2Placed + 1;
        } else {
            continue;
        }

        // L-shaped wall placement (alternates stepping along adjacent walls)
        if (g_finalTeam[p] == 1) {
            if (placed == 0) {
                offsetX = 0.0; offsetZ = 0.0; // Corner vertex
            } else if (placed == 1) {
                offsetX = wallSpacing; offsetZ = 0.0; // Top wall (+X)
            } else if (placed == 2) {
                offsetX = 0.0; offsetZ = 0.0 - wallSpacing; // Left wall (-Z)
            } else if (placed == 3) {
                offsetX = wallSpacing * 2.0; offsetZ = 0.0; // Top wall (+2X)
            } else if (placed == 4) {
                offsetX = 0.0; offsetZ = 0.0 - (wallSpacing * 2.0); // Left wall (-2Z)
            } else {
                offsetX = wallSpacing * (placed - 2); offsetZ = 0.0;
            }
            
            spawnX = t1CornerX + offsetX;
            spawnZ = t1CornerZ + offsetZ;

        } else if (g_finalTeam[p] == 2) {
            if (placed == 0) {
                offsetX = 0.0; offsetZ = 0.0; // Corner vertex
            } else if (placed == 1) {
                offsetX = 0.0; offsetZ = wallSpacing; // Right wall (+Z)
            } else if (placed == 2) {
                offsetX = 0.0 - wallSpacing; offsetZ = 0.0; // Bottom wall (-X)
            } else if (placed == 3) {
                offsetX = 0.0; offsetZ = wallSpacing * 2.0; // Right wall (+2Z)
            } else if (placed == 4) {
                offsetX = 0.0 - (wallSpacing * 2.0); offsetZ = 0.0; // Bottom wall (-2X)
            } else {
                offsetX = 0.0; offsetZ = wallSpacing * (placed - 2);
            }

            spawnX = t2CornerX + offsetX;
            spawnZ = t2CornerZ + offsetZ;
        }

        // Spawn and scale market
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

    // All players
    for(int p = 0; p <= cNumberPlayers; p++) {
        trModifyProtounitData("GoldPile", p, puFIELD_OBSTRUCTION_X, 0.0, relativityASSIGN);
        trModifyProtounitData("GoldPile", p, puFIELD_OBSTRUCTION_Z, 0.0, relativityASSIGN);
        trProtoUnitSetFlag(p, "GoldPile", "ForceToNature", false);
        trProtoUnitSetFlag(p, "GoldPile", "CollidesWithProjectiles", false);
        trProtoUnitSetFlag(p, "GoldPile", "NonAutoFormedUnit", false);
        trProtoUnitSetFlag(p, "GoldPile", "StartOnNoUpdate", false);
        trProtoUnitSetUnitType(p, "GoldPile", "NatureClass", false);
        trModifyProtounitData("GoldPile", p, puFIELD_LIFESPAN, 10, relativityASSIGN);
        trProtoUnitSetFlag(p, "GoldPile", "CorpseDecays", true);
    }

    // Only Humans
    for(int p = 1; p <= cNumberPlayers - 2; p++) {
        trModifyProtounitData("Market", p, puFIELD_OBSTRUCTION_X, 0.5, 3);
        trModifyProtounitData("Market", p, puFIELD_OBSTRUCTION_Z, 0.5, 3);
    }

    // Last 2 AIs
    for(int p = cNumberPlayers - 1; p <= cNumberPlayers; p++) {
        trTechSetStatus(p, 373, 2); // Watch Tower
        trModifyProtounitData("SentryTower", p, puFIELD_HITPOINTS, 1000, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_DIVINE, 10, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 1, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_N_PROJECTILES, 1, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_DISPLAY_PROJ, 1, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_MIN_RANGE, 0, relativityASSIGN);

        trModifyProtounitData("MirrorTower", p, puFIELD_HITPOINTS, 2000, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_DIVINE, 20, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_RANGE, 18, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 1, relativityASSIGN);

        trModifyProtounitData("StatueOfLightning", p, puFIELD_HITPOINTS, 3000, relativityASSIGN);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, puFIELD_ACTION_DIVINE, 30, relativityASSIGN);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 1, relativityASSIGN);

        trModifyProtounitData("Fortress", p, puFIELD_HITPOINTS, 10000, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_ACTION_DIVINE, 40, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_MIN_RANGE, 0, relativityASSIGN);

        trProtounitModifySpawnData("Toxotes", p, "GoldPile", 0, 1.0, 1, -1, 30);
        trProtounitModifySpawnData("Hoplite", p, "GoldPile", 0, 1.0, 1, -1, 30);
        trProtounitModifySpawnData("Hippeus", p, "GoldPile", 0, 1.0, 1, -1, 30);
    }
}