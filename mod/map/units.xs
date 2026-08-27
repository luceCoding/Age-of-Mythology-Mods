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
        selectSingle(shopId);
        trUnitSetScale(0.5, 0.5, 0.5);
        trUnitChangeName("Card Shop");

        BenchData bench = g_shop.m_benches[p];
        bench.init(p, shopId);
        g_shop.m_benches[p] = bench;
    }
}

void preModifyPlayerData(){

    // All players
    for(int p = 0; p <= cNumberPlayers; p++) {
        trTechSetStatus(p, 2, 2); // Classical Ages
        trTechSetStatus(p, 90, 2);
        trTechSetStatus(p, 184, 2);
        trTechSetStatus(p, 20, 2);
        trTechSetStatus(p, 509, 2);
        trTechSetStatus(p, 626, 2);
        //trTechSetStatus(p, 275, 2); // Atlantean Age causing extra upgrades?
        trTechSetStatus(p, 751, 2);

        setAsPlaceholder("GoldPile", p);
        trProtoUnitSetFlag(p, "GoldPile", "ObscuredByUnits", true);
        trModifyProtounitData("GoldPile", p, puFIELD_LIFESPAN, GOLDPILE_LIFESPAN, relativityASSIGN);

        // Forbid
        trForbidProtounit(p, "CaravanAtlantean");
        trForbidProtounit(p, "CaravanAztec");
        trForbidProtounit(p, "CaravanChinese");
        trForbidProtounit(p, "CaravanEgyptian");
        trForbidProtounit(p, "CaravanGreek");
        trForbidProtounit(p, "CaravanJapanese");
        trForbidProtounit(p, "CaravanNorse");

        trPlayerAllowBonusUnitSpawning(p, false);
        trPlayerEnableCombatXP(p, false);
        trPlayerAllowShades(p, false);
        trPlayerAllowStartingUnitsSpawning(p, false);
        trTechSetStatus(p, cTechPharaohFirstSpawn, cTechStatusUnobtainable);
        trPlayerEnableTimeshift(p, false);
        trPlayerEnablePartisans(p, false);
        trPlayerEnableBuildingChain(p, false);
        trPlayerKillAllGodPowers(p);

        int food = kbGetResourceAmount(p, kbGetResourceID("Food"));
        int wood = kbGetResourceAmount(p, kbGetResourceID("Wood"));
        int gold = kbGetResourceAmount(p, kbGetResourceID("Gold"));
        int favor = kbGetResourceAmount(p, kbGetResourceID("Favor"));
        trPlayerGrantResources(p, "Food", -food);
        trPlayerGrantResources(p, "Wood", -wood);
        trPlayerGrantResources(p, "Gold", -gold);
        trPlayerGrantResources(p, "Favor", -favor);
        trPlayerGrantResources(p, "Gold", STARTING_GOLD);
        
        // For card synergies
        trProtoUnitSetUnitType(p, "Tanuki", "AbstractHealer", true);
    }

    // Only Humans
    for(int p = 1; p <= cNumberPlayers - 2; p++) {
        trModifyProtounitData("Market", p, puFIELD_OBSTRUCTION_X, 0.0, relativityBasePERCENT);
        trModifyProtounitData("Market", p, puFIELD_OBSTRUCTION_Z, 0.0, relativityBasePERCENT);
        trProtoUnitSetUnitType(p, "Market", "LogicalTypeBuildingThatCanBeEmpowered", false);
        trProtounitRemoveCommand("Market", p, "Delete");
        trProtounitRemoveCommand("Market", p, "MarketBuy1");
        trProtounitRemoveCommand("Market", p, "MarketBuy2");
        trProtounitRemoveCommand("Market", p, "MarketSell1");
        trProtounitRemoveCommand("Market", p, "MarketSell2");
        trProtounitRemoveTech("Market", p, 363); // Coinage
        trProtounitRemoveTech("Market", p, 582); // Silk Road
        trProtoUnitSetFlag(p, "Market", "Invulnerable", true);
        trPlayerModifyData(p, 0, -1, 999, 0); // Add population
        trForbidProtounit(p, "WallConnector");
        trTechSetStatus(p, 406, 2); // Ring of the Nibelung, gold trickle
        trTechSetStatus(p, 62, 2); //oracle tech for viewing enemy ui

        trTechRemove(p, "Armory", 383);
        trTechRemove(p, "Armory", 386);
        trTechRemove(p, "Armory", 380);
        trTechRemove(p, "Armory", 390);
        trProtounitRemoveTech("DwarvenArmory", 1, 389);
        trTechRemove(p, "Market", 361); // Tax Collectors

        // Hide teammates's gold
        if (trCurrentPlayer() == p){
            int currTeam = g_finalTeam[p];
            for (int p2 = 1; p2 <= cNumberPlayers; p2++) {
                int otherTeam = g_finalTeam[p2];
                if (currTeam == otherTeam){
                    trProtoUnitSetFlag(p2, "GoldPile", "OnlyInEditor", true);
                }
            }
        }

        string[] protoNames = ProtoNameToCardParametersMap.getKeys();
        for (int i=0; i<protoNames.size(); i++){
            setAsCardUnit(protoNames[i], p);
        }
    }

    // Last 2 AIs
    for(int p = cNumberPlayers - 1; p <= cNumberPlayers; p++) {
        trPlayerSetCiv(p, "Demeter");
        trTechSetStatus(p, 373, 2); // Watch Tower
        trTechSetStatus(p, 378, 2); // Boiling Oil

        trModifyProtounitData("SentryTower", p, puFIELD_HITPOINTS, 2000, relativityASSIGN);
        trModifyProtounitData("SentryTower", p, puFIELD_CRUSH_ARMOR, 0.3, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_DIVINE, 20, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 1, relativityASSIGN);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, puFIELD_MIN_RANGE, 0, relativityASSIGN);
        setupAsTower("SentryTower", p);

        trModifyProtounitData("MirrorTower", p, puFIELD_HITPOINTS, 4000, relativityASSIGN);
        trModifyProtounitData("MirrorTower", p, puFIELD_CRUSH_ARMOR, 0.3, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_DIVINE, 50, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_RANGE, 18, relativityASSIGN);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 1, relativityASSIGN);
        setupAsTower("MirrorTower", p);

        trModifyProtounitData("StatueOfLightning", p, puFIELD_HITPOINTS, 8000, relativityASSIGN);
        trModifyProtounitData("StatueOfLightning", p, puFIELD_CRUSH_ARMOR, 0.3, relativityASSIGN);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, puFIELD_ACTION_DIVINE, 60, relativityASSIGN);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, puFIELD_ACTION_RATE_OF_FIRE, 3, relativityASSIGN);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, puFIELD_ACTION_N_BOUNCES, 2, relativityASSIGN);
        trModifyProtounitActionUnitType("StatueOfLightning", "LightningAttack", "MythUnit", p, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 1, relativityASSIGN);
        setupAsTower("StatueOfLightning", p);

        trModifyProtounitData("Fortress", p, puFIELD_HITPOINTS, 24000, relativityASSIGN);
        trModifyProtounitData("Fortress", p, puFIELD_CRUSH_ARMOR, 0.3, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_ACTION_PIERCE, 0, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_ACTION_DIVINE, 70, relativityASSIGN);
        trModifyProtounitAction("Fortress", "RangedAttack", p, puFIELD_MIN_RANGE, 0, relativityASSIGN);
        setupAsTower("Fortress", p);
        trProtoUnitSetIcon("Fortress", p, "", "ui\minimap\minimap_wonder");
        // For win condition
        trProtounitModifySpawnData("Fortress", p, "FlyingPurpleHippo", 0, 1.0, 1, -1, -1);

        setupCreepWaveUnit("Hoplite", p);
        setupCreepWaveUnit("Hippeus", p);
        setupCreepWaveUnit("Toxotes", p);
        setupCreepWaveUnit("Cyclops", p);
        setupCreepWaveUnit("Heracles", p);
    }

    // Only Gaia
    setupAutoRespawn("Storehouse", "CinematicBlockStartPoint", T1_CRATE_SPAWN_TIME);
    setupAutoRespawn("MiningCampJapanese", "CinematicBlockEndPoint", T2_CRATE_SPAWN_TIME);
    setupAutoRespawn("MiningCamp", "CinematicBlockWaypoint", T3_CRATE_SPAWN_TIME);
    trProtoUnitSetIcon("Storehouse", 0, "", "ui\minimap\minimap_gold");
    trProtoUnitSetIcon("MiningCampJapanese", 0, "", "ui\minimap\minimap_gold");
    trProtoUnitSetIcon("MiningCamp", 0, "", "ui\minimap\minimap_gold");

    trModifyProtounitData("MiningCampJapanese", 0, puFIELD_HITPOINTS, 2, relativityBasePERCENT);
    trModifyProtounitData("MiningCampJapanese", 0, puFIELD_HACK_ARMOR, 1.3, relativityBasePERCENT);
    trModifyProtounitData("MiningCampJapanese", 0, puFIELD_CRUSH_ARMOR, 0.2, relativityABSOLUTE);

    trModifyProtounitData("MiningCamp", 0, puFIELD_HITPOINTS, 4, relativityBasePERCENT);
    trModifyProtounitData("MiningCamp", 0, puFIELD_HACK_ARMOR, 1.5, relativityBasePERCENT);
    trModifyProtounitData("MiningCamp", 0, puFIELD_CRUSH_ARMOR, 0.4, relativityABSOLUTE);

    for (int i = 0; i < g_creepCampTypes.size(); i++) {
        string creepCampTypes = g_creepCampTypes[i];
        trModifyProtounitData(creepCampTypes, 0, puFIELD_LOS, 8, relativityASSIGN);
        trProtounitModifySpawnData(creepCampTypes, 0, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
        trProtoUnitSetFlag(0, creepCampTypes, "ObscuredByUnits", true);
    }
}

void postModifyPlayerData(){
    // All Players
    for(int p = 0; p <= cNumberPlayers; p++) {

        for (int k = 0; k < g_shopTypes.size(); k++) {
            string shopType = g_shopTypes[k];
            setupAsSharedShop(shopType, p);
            int shopId = ShopTypeToUnitIDMap.get(k);
            selectSingle(shopId);
            switch(k){
                case SHOP_TYPE_FORGE: trUnitChangeName("Forge (Add Sockets)");
                case SHOP_TYPE_ARMORY: trUnitChangeName("Armory (Roll Upgrades)");
                case SHOP_TYPE_TEMPLE: trUnitChangeName("Temple (Roll Rarities)");
                case SHOP_TYPE_SHRINE: trUnitChangeName("Library (Identification)");
            }
            trProtoUnitSetFlag(p, shopType, "Invulnerable", true);
            trProtounitRemoveCommand(shopType, p, "Delete");
        }
    }

    // For humans
    for(int p = 1; p <= cNumberPlayers-2; p++) {
        string[] protoNames = ProtoNameToCardParametersMap.getKeys();
        for (int i=0; i<protoNames.size(); i++){
            setAsCardUnit(protoNames[i], p);
        }
    }
}