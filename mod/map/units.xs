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
        trTechSetStatus(p, cTechClassicalAgeGeneral, 2); // Classical Ages
        trTechSetStatus(p, cTechClassicalAgeEgyptian, 2);
        trTechSetStatus(p, cTechClassicalAgeNorse, 2);
        trTechSetStatus(p, cTechClassicalAgeGreek, 2);
        trTechSetStatus(p, cTechClassicalAgeChinese, 2);
        trTechSetStatus(p, cTechClassicalAgeJapanese, 2);
        //trTechSetStatus(p, cTechClassicalAgeAtlantean, 2); // Atlantean Age causing extra upgrades?
        trTechSetStatus(p, cTechClassicalAgeAztec, 2);

        setAsPlaceholder("GoldPile", p);
        trProtoUnitSetFlag(p, "GoldPile", "ObscuredByUnits", true);
        trModifyProtounitData("GoldPile", p, cXSProtoEffectLifespan, GOLDPILE_LIFESPAN, cXSRelativityAssign);

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
        trProtoUnitSetUnitType(p, "Tanuki", UNIT_TYPE_HEALER, true);
        trProtoUnitSetUnitType(p, "Perseus", UNIT_TYPE_MYTH, true);
        trProtoUnitSetUnitType(p, "Shogun", UNIT_TYPE_CAVALRY, true);
        trProtoUnitSetUnitType(p, "WenZhong", UNIT_TYPE_MYTH, true);
        trProtoUnitSetUnitType(p, "Arkantos", UNIT_TYPE_SOLDIER, true);
        trProtoUnitSetUnitType(p, "Arkantos", UNIT_TYPE_INFANTRY, true);
        trProtoUnitSetUnitType(p, "ArkantosGod", UNIT_TYPE_SOLDIER, true);
        trProtoUnitSetUnitType(p, "ArkantosGod", UNIT_TYPE_INFANTRY, true);
        trProtoUnitSetUnitType(p, "Polyphemus", UNIT_TYPE_MYTH_SIEGE, true);
        trProtoUnitSetUnitType(p, "QiLin", UNIT_TYPE_HEALER, true);
        trProtoUnitSetUnitType(p, "Bellerophon", UNIT_TYPE_MYTH, true);
        trProtoUnitSetUnitType(p, "Bellerophon", UNIT_TYPE_CAVALRY, true);
        trProtoUnitSetUnitType(p, "HarumotoBlessed", UNIT_TYPE_CAVALRY, true);
        trProtoUnitSetUnitType(p, "Guardian", UNIT_TYPE_INFANTRY, true);
        trProtoUnitSetUnitType(p, "Guardian", UNIT_TYPE_SIEGE, true);
        trProtoUnitSetUnitType(p, "Automaton", UNIT_TYPE_INFANTRY, true);
        trProtoUnitSetUnitType(p, "Chiron", UNIT_TYPE_MYTH, true);
        trProtoUnitSetUnitType(p, "Chiron", UNIT_TYPE_MYTH_RANGED, true);
        trProtoUnitSetUnitType(p, "Quinametzin", UNIT_TYPE_SIEGE, true);
        trProtoUnitSetUnitType(p, "Otontin", UNIT_TYPE_SIEGE, true);
    }

    // Only Humans
    for(int p = 1; p <= cNumberPlayers - 2; p++) {
        trModifyProtounitData("Market", p, cXSProtoEffectObstructionRadiusX, 0.0, cXSRelativityBasePercent);
        trModifyProtounitData("Market", p, cXSProtoEffectObstructionRadiusZ, 0.0, cXSRelativityBasePercent);
        trProtoUnitSetUnitType(p, "Market", "LogicalTypeBuildingThatCanBeEmpowered", false);
        trProtounitRemoveCommand("Market", p, "Delete");
        trProtounitRemoveCommand("Market", p, "MarketBuy1");
        trProtounitRemoveCommand("Market", p, "MarketBuy2");
        trProtounitRemoveCommand("Market", p, "MarketSell1");
        trProtounitRemoveCommand("Market", p, "MarketSell2");
        trProtounitRemoveTech("Market", p, cTechCoinage);
        trProtounitRemoveTech("Market", p, cTechSilkRoad);
        trProtoUnitSetFlag(p, "Market", "Invulnerable", true);
        trPlayerModifyData(p, 0, -1, 999, 0); // Add population
        trTechSetStatus(p, cTechRelicRingOfNibelung, 2);
        trTechSetStatus(p, cTechOracle, 2);
        forbidBuilding(p);
        modifyBuildingCosts(p);

        trTechRemove(p, "Armory", cTechCopperArmor);
        trTechRemove(p, "Armory", cTechCopperShields);
        trTechRemove(p, "Armory", cTechCopperWeapons);
        trTechRemove(p, "Armory", cTechBallistics);
        trTechRemove(p, "DwarvenArmory", cTechBurningPitch);
        trTechRemove(p, "Market", cTechTaxCollectors);

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

        trProtoUnitMovementType("Servant", p, "land");

        trModifyProtounitAction("SiegeCrossbowSPC", "RangedAttack", p, cXSActionEffectDamagePierce, 200, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "AntiWallAttack", p, cXSActionEffectDamagePierce, 200, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "RangedAttack", p, cXSActionEffectDamageCrush, 200, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "AntiWallAttack", p, cXSActionEffectDamageCrush, 200, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "RangedAttack", p, cXSActionEffectRange, 32, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "AntiWallAttack", p, cXSActionEffectRange, 32, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "RangedAttack", p, cXSActionEffectMinRange, 8, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "AntiWallAttack", p, cXSActionEffectMinRange, 8, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "RangedAttack", p, cXSActionEffectROF, 5, cXSRelativityAssign);
        trModifyProtounitAction("SiegeCrossbowSPC", "AntiWallAttack", p, cXSActionEffectROF, 5, cXSRelativityAssign);
        trModifyProtounitData("SiegeCrossbowSPC", p, cXSProtoEffectHitpoints, 250, cXSRelativityAssign);

        trModifyProtounitAction("LivingPoseidonStatue", "HandAttack", p, cXSActionEffectDamageHack, 40, cXSRelativityAssign);
        trModifyProtounitAction("LivingPoseidonStatue", "HandAttack", p, cXSActionEffectDamageCrush, 0, cXSRelativityAssign);
        trModifyProtounitAction("LivingPoseidonStatue", "HandAttack", p, cXSActionEffectROF, 3, cXSRelativityAssign);
        trModifyProtounitAction("LivingPoseidonStatue", "HandAttack", p, cXSActionEffectDamageArea, 1, cXSRelativityAssign);
        trModifyProtounitData("LivingPoseidonStatue", p, cXSProtoEffectHitpoints, 2000, cXSRelativityAssign);
        trModifyProtounitData("LivingPoseidonStatue", p, cXSProtoEffectArmorHack, 0.5, cXSRelativityAssign);
        trModifyProtounitData("LivingPoseidonStatue", p, cXSProtoEffectArmorPierce, 0.75, cXSRelativityAssign);
        trModifyProtounitData("LivingPoseidonStatue", p, cXSProtoEffectArmorCrush, 0.25, cXSRelativityAssign);

        trModifyProtounitData("ArkantosGod", p, cXSProtoEffectHitpoints, 1000, cXSRelativityAssign);
        trModifyProtounitAction("ArkantosGod", "HandAttack", p, cXSActionEffectDamageHack, 25, cXSRelativityAssign);
        trModifyProtounitAction("ArkantosGod", "BuckAttack", p, cXSActionEffectDamageHack, 25, cXSRelativityAssign);
        trModifyProtounitData("ArkantosGod", p, cXSProtoEffectArmorHack, 0.6, cXSRelativityAssign);
        trModifyProtounitData("ArkantosGod", p, cXSProtoEffectArmorPierce, 0.6, cXSRelativityAssign);

        trModifyProtounitAction("Osiris", "LightningAttack", p, cXSActionEffectDamageDivine, 100, cXSRelativityAssign);
        trModifyProtounitData("Osiris", p, cXSProtoEffectSpeed, 3, cXSRelativityAssign);
        trProtoUnitSetFlag(p, "Osiris", "KnockoutDeath", true);
        trModifyProtounitData("OsirisPieceBox", p, cXSProtoEffectObstructionRadiusX, 0, cXSRelativityAssign);
        trModifyProtounitData("OsirisPieceBox", p, cXSProtoEffectObstructionRadiusZ, 0, cXSRelativityAssign);

        trModifyProtounitData("Nidhogg", p, cXSProtoEffectHitpoints, -1500, cXSRelativityAbsolute);
        trModifyProtounitData("Yinglong", p, cXSProtoEffectHitpoints, -1500, cXSRelativityAbsolute);

        trModifyProtounitAction("Guardian", "HandAttack", p, cXSActionEffectDamageHack, 50, cXSRelativityAssign);
        trModifyProtounitAction("Guardian", "HandAttack", p, cXSActionEffectDamageCrush, 200, cXSRelativityAssign);
        trModifyProtounitAction("Guardian", "HandAttack", p, cXSActionEffectDamageArea, 0, cXSRelativityAssign);
        trModifyProtounitAction("Guardian", "HandAttack", p, cXSActionEffectROF, 2, cXSRelativityAssign);
        trModifyProtounitAction("BoltStrike", "HandAttack", p, cXSActionEffectDamageDivine, 100, cXSRelativityAssign);
        trModifyProtounitData("Guardian", p, cXSProtoEffectHitpoints, 1500, cXSRelativityAssign);
        trModifyProtounitData("Guardian", p, cXSProtoEffectArmorHack, 0.75, cXSRelativityAssign);
        trModifyProtounitData("Guardian", p, cXSProtoEffectArmorPierce, 0.4, cXSRelativityAssign);
        trModifyProtounitData("Guardian", p, cXSProtoEffectArmorCrush, 0.4, cXSRelativityAssign);

        string[] protoNames = g_protoNameToCardParametersMap.getKeys();
        for (int i=0; i<protoNames.size(); i++){
            setAsCardUnit(protoNames[i], p);
        }
    }

    // Last 2 AIs
    for(int p = cNumberPlayers - 1; p <= cNumberPlayers; p++) {
        trPlayerSetCiv(p, "Demeter");
        trTechSetStatus(p, 373, 2); // Watch Tower
        trTechSetStatus(p, 378, 2); // Boiling Oil

        trModifyProtounitData("SentryTower", p, cXSProtoEffectHitpoints, 2000, cXSRelativityAssign);
        trModifyProtounitData("SentryTower", p, cXSProtoEffectArmorCrush, 0.3, cXSRelativityAssign);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, cXSActionEffectDamagePierce, 0, cXSRelativityAssign);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, cXSActionEffectDamageDivine, 20, cXSRelativityAssign);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, cXSActionEffectROF, 1, cXSRelativityAssign);
        trModifyProtounitAction("SentryTower", "RangedAttack", p, cXSActionEffectMinRange, 0, cXSRelativityAssign);
        setupAsTower("SentryTower", p);

        trModifyProtounitData("MirrorTower", p, cXSProtoEffectHitpoints, 4000, cXSRelativityAssign);
        trModifyProtounitData("MirrorTower", p, cXSProtoEffectArmorCrush, 0.3, cXSRelativityAssign);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, cXSActionEffectDamagePierce, 0, cXSRelativityAssign);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, cXSActionEffectDamageDivine, 50, cXSRelativityAssign);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, cXSActionEffectRange, 18, cXSRelativityAssign);
        trModifyProtounitAction("MirrorTower", "BeamAttack", p, cXSActionEffectROF, 1, cXSRelativityAssign);
        setupAsTower("MirrorTower", p);

        trModifyProtounitData("StatueOfLightning", p, cXSProtoEffectHitpoints, 8000, cXSRelativityAssign);
        trModifyProtounitData("StatueOfLightning", p, cXSProtoEffectArmorCrush, 0.3, cXSRelativityAssign);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, cXSActionEffectDamageDivine, 60, cXSRelativityAssign);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, cXSActionEffectROF, 3, cXSRelativityAssign);
        trModifyProtounitAction("StatueOfLightning", "LightningAttack", p, cXSActionEffectNumBounces, 3, cXSRelativityAssign);
        trModifyProtounitActionUnitType("StatueOfLightning", "LightningAttack", "MythUnit", p, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
        setupAsTower("StatueOfLightning", p);

        trModifyProtounitData("Fortress", p, cXSProtoEffectHitpoints, 24000, cXSRelativityAssign);
        trModifyProtounitData("Fortress", p, cXSProtoEffectArmorCrush, 0.3, cXSRelativityAssign);
        trModifyProtounitAction("Fortress", "RangedAttack", p, cXSActionEffectDamagePierce, 0, cXSRelativityAssign);
        trModifyProtounitAction("Fortress", "RangedAttack", p, cXSActionEffectDamageDivine, 50, cXSRelativityAssign);
        trModifyProtounitAction("Fortress", "RangedAttack", p, cXSActionEffectMinRange, 0, cXSRelativityAssign);
        setupAsTower("Fortress", p);
        trProtoUnitSetIcon("Fortress", p, "", "ui\minimap\minimap_wonder");
        trProtounitModifySpawnData("Fortress", p, "FlyingPurpleHippo", 0, 1.0, 1, -1, -1); // For win condition

        trModifyProtounitData("MilitaryAcademy", p, cXSProtoEffectHitpoints, 5000, cXSRelativityAssign);

        trProtoUnitSetUnitType(p, "WallOfAtlantisConnector", "LogicalTypeVillagersAttack", false);
        trProtoUnitSetUnitType(p, "WallOfAtlantisConnector", "LogicalTypeHandUnitsAttack", false);
        trProtoUnitSetUnitType(p, "WallOfAtlantisConnector", "LogicalTypeRangedUnitsAttack", false);

        for (int i=0; i < g_waveTypes.size(); i++){
            string waveType = g_waveTypes[i];
            setupCreepWaveUnit(waveType, p);
        }
    }

    // Only Gaia
    setupAutoRespawn("Storehouse", "CinematicBlockStartPoint", T1_CRATE_SPAWN_TIME);
    setupAutoRespawn("MiningCampJapanese", "CinematicBlockEndPoint", T2_CRATE_SPAWN_TIME);
    setupAutoRespawn("MiningCamp", "CinematicBlockWaypoint", T3_CRATE_SPAWN_TIME);
    trProtoUnitSetIcon("Storehouse", 0, "", "ui\minimap\minimap_gold");
    trProtoUnitSetIcon("MiningCampJapanese", 0, "", "ui\minimap\minimap_gold");
    trProtoUnitSetIcon("MiningCamp", 0, "", "ui\minimap\minimap_gold");

    trModifyProtounitData("MiningCampJapanese", 0, cXSProtoEffectHitpoints, 2, cXSRelativityBasePercent);
    trModifyProtounitData("MiningCampJapanese", 0, cXSProtoEffectArmorHack, 1.3, cXSRelativityBasePercent);
    trModifyProtounitData("MiningCampJapanese", 0, cXSProtoEffectArmorCrush, 0.2, cXSRelativityAbsolute);

    trModifyProtounitData("MiningCamp", 0, cXSProtoEffectHitpoints, 4, cXSRelativityBasePercent);
    trModifyProtounitData("MiningCamp", 0, cXSProtoEffectArmorHack, 1.5, cXSRelativityBasePercent);
    trModifyProtounitData("MiningCamp", 0, cXSProtoEffectArmorCrush, 0.4, cXSRelativityAbsolute);

    for (int i = 0; i < g_creepCampTypes.size(); i++) {
        string creepCampType = g_creepCampTypes[i];
        trModifyProtounitData(creepCampType, 0, cXSProtoEffectLOS, 8, cXSRelativityAssign);
        trProtoUnitSetFlag(0, creepCampType, "ObscuredByUnits", true);
        setupForAllUnits(creepCampType, 0);
    }

    trProtoUnitSetFlag(0, TOP_BOSS_PLACEHOLDER_PROTO, "FlareOnFullyBuilt", false);
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
        string[] protoNames = g_protoNameToCardParametersMap.getKeys();
        for (int i=0; i<protoNames.size(); i++){
            setAsCardUnit(protoNames[i], p);
        }
    }

    // Boss
    setupBoss(TOP_BOSS_PROTO, 1);
    setupBoss(BOT_BOSS_PROTO, 2);
    trModifyProtounitActionUnitType(TOP_BOSS_PROTO, "RangedAttack", "Hero", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trModifyProtounitActionUnitType(TOP_BOSS_PROTO, "BillowingSmog", "Hero", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trModifyProtounitActionUnitType(TOP_BOSS_PROTO, "RangedAttack", "MythUnit", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trModifyProtounitActionUnitType(TOP_BOSS_PROTO, "BillowingSmog", "MythUnit", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
}