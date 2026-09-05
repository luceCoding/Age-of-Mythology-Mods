CreepCamp g_topBossCamp;
CreepCamp g_botBossCamp;

void buildBossPit(vector centerPos = cInvalidVector, 
                  float baseRadius = 20.0, 
                  float pitDepth = 1.5, 
                  int minEntrances = 1, int maxEntrances = 3, 
                  string floorTerrain = "", string cliffTerrain = "") {
    // ------------------------------------------
    // GRADUAL DECLINE (Smooth Terraced Basin)
    // ------------------------------------------
    int slopeSteps = 8;
    for (int s = 0; s <= slopeSteps; s++) {
        float t = xsIntToFloat(s) / xsIntToFloat(slopeSteps);
        float currentRadius = baseRadius * (1.0 - (t * 0.85)); 
        float ringDepth = pitDepth * (1.0 - t);
        
        vector ringPos = vector(centerPos.x, centerPos.y - ringDepth, centerPos.z);
        trChangeTerrainHeightCircular(ringPos, currentRadius, -ringDepth * 0.6, false);
        paintCircle(ringPos, currentRadius, floorTerrain);
    }

    // ------------------------------------------
    // CALCULATE CIRCUMFERENCE & STEPS
    // ------------------------------------------
    float stepSize = 5.0; 
    float circumference = 2.0 * cPi * baseRadius;
    int steps = xsFloatToInt(circumference / stepSize);
    if (steps <= 0) steps = 1;
    float stepDeg = 360.0 / xsIntToFloat(steps);

    // ------------------------------------------
    // SYMMETRICAL ENTRANCE GAPS
    // ------------------------------------------
    int numEntrances = minEntrances + xsRandInt(0, (maxEntrances - minEntrances));
    float entranceSpacing = 360.0 / xsIntToFloat(numEntrances);
    float startOffset = xsRandFloat(0.0, 360.0);
    float entranceWidth = 30.0; // Width of each entrance gap in degrees

    // ------------------------------------------
    // BUILD GENTLER CLIFF RING WITH GAPS
    // ------------------------------------------
    for (int i = 0; i < steps; i++) {
        float currentAngle = xsIntToFloat(i) * stepDeg;
        
        // Check if this angle falls inside any of the symmetrically spaced entrance gaps
        bool isEntrance = false;
        for (int e = 0; e < numEntrances; e++) {
            float targetAngle = startOffset + (xsIntToFloat(e) * entranceSpacing);
            
            // Normalize angle difference to [-180, 180]
            float diff = currentAngle - targetAngle;
            while (diff > 180.0) diff = diff - 360.0;
            while (diff < -180.0) diff = diff + 360.0;
            
            if (abs(diff) < (entranceWidth * 0.5)) {
                isEntrance = true;
                break;
            }
        }

        // Only build the cliff segment if it's outside an entrance gap
        if (!isEntrance) {
            int modVal = i - (3 * (i / 3));
            float currentRadius = baseRadius + (xsIntToFloat(modVal - 1) * 0.5);
            float x = centerPos.x + (currentRadius * cosDeg(currentAngle));
            float z = centerPos.z + (currentRadius * sinDeg(currentAngle));
            vector pos = vector(x, centerPos.y, z);

            trChangeTerrainHeightCircular(pos, 2.0, 1.5, false);
            paintCircle(pos, 2.0, cliffTerrain);
        }
    }
}

void createBossPits() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h = configMapBaseHeight;
    float cornerMargin = 0.35; 

    float topCornerX = mapX * (1.0 - cornerMargin);
    float topCornerZ = mapZ * (1.0 - cornerMargin);

    float botCornerX = mapX * cornerMargin;
    float botCornerZ = mapZ * cornerMargin;

    // Spawn Center Boss Structures
    int topBossPlaceholderID = spawnUnit(TOP_BOSS_PLACEHOLDER_PROTO, topCornerX, h, topCornerZ, xsRandFloat(0, 359), 0, 1.5);
    int botBossPlaceholderID = spawnUnit(BOT_BOSS_PLACEHOLDER_PROTO, botCornerX, h, botCornerZ, xsRandFloat(0, 359), 0, 1.5);

    g_topBossCamp.init(topBossPlaceholderID, BOSS_SPAWN_TIME, TOP_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);
    g_botBossCamp.init(botBossPlaceholderID, BOSS_SPAWN_TIME, BOT_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);

    buildBossPit(vector(topCornerX, h, topCornerZ), 22.0, 2.0, 2, 4, g_colosseumRoadTypes[3], g_colosseumRoadTypes[2]);
    buildBossPit(vector(botCornerX, h, botCornerZ), 22.0, 2.0, 2, 4, g_colosseumRoadTypes[1], g_colosseumRoadTypes[0]);
}

void attachTopBossBuff(int unitID = 0, int durationMs = 0, int p = 0){
    attachTempUnit(unitID, cUnitTypeVFXArtifactGlowGreen, durationMs, cMaxInt, p, false);
}

void attachBotBossBuff(int unitID = 0, int durationMs = 0, int p = 0){
    attachTempUnit(unitID, cUnitTypeVFXArtifactGlowRed, durationMs, cMaxInt, p, false);
}

void attachTopBuffToAllDeployedCards(int p = 0, int durationMs = 0){
    BenchData bench = g_shop.m_benches[p];
    CardData[] cards = bench.getCards();
    for (int i = 0; i < cards.size(); i++){
        CardData card = cards[i];
        if (card.isDeployed()){
            int unitID = card.getDeployedUnitID();
            attachTopBossBuff(unitID, durationMs, p);
        }
    }
}

void attachBotBuffToAllDeployedCards(int p = 0, int durationMs = 0){
    BenchData bench = g_shop.m_benches[p];
    CardData[] cards = bench.getCards();
    for (int i = 0; i < cards.size(); i++){
        CardData card = cards[i];
        if (card.isDeployed()){
            int unitID = card.getDeployedUnitID();
            attachBotBossBuff(unitID, durationMs, p);
        }
    }
}

Parameters createParametersCopy(ref Parameters params){
    return params; // Workaround for instance bug
}

void checkTopBossBuff(){
    if (g_topBossCamp.areAllDead()){
        for (int p = 1; p < cNumberPlayers; p++){
            int woodStockpiled = kbGetResourceAmount(p, kbGetResourceID("Wood"));
            if (woodStockpiled == 1){
                float buffAmount = getMinsPastSinceStart() / 2.0;
                Parameters params;
                params.ints.add(p);
                params.floats.add(buffAmount);
                Parameters params2 = createParametersCopy(params);
                applyProtoDataToAllCards(p, cXSProtoEffectUnitRegenRate, buffAmount, cXSRelativityAbsolute);
                attachTopBuffToAllDeployedCards(p, BUFF_DURATION_MS);
                g_TopBossBuffMsEnd[p] = xsGetTimeMS() + BUFF_DURATION_MS;
                trSoundsetPlay("UI_MajorGodSelectSet");
                trPlayerGrantResources(p, "Wood", -1);
                schedulerWithParameters.add(BUFF_DURATION_MS, params2, [](int iterations = 1, ref Parameters params) -> bool {
                    applyProtoDataToAllCards(params.ints[0], cXSProtoEffectUnitRegenRate, -params.floats[0], cXSRelativityAbsolute);
                    return false;
                });
                break;
            }
        }
    }
}

void checkBotBossBuff(){
    if (g_botBossCamp.areAllDead()){
        for (int p = 1; p < cNumberPlayers; p++){
            int woodStockpiled = kbGetResourceAmount(p, kbGetResourceID("Wood"));
            if (woodStockpiled == 2){
                float buffAmount = getMinsPastSinceStart() / 2.0;
                Parameters params;
                params.ints.add(p);
                params.floats.add(buffAmount);
                Parameters params2 = createParametersCopy(params);
                applyProtoActionToAllCards(p, cXSActionEffectDamageDivine, buffAmount, cXSRelativityAbsolute);
                attachBotBuffToAllDeployedCards(p, BUFF_DURATION_MS);
                g_BotBossBuffMsEnd[p] = xsGetTimeMS() + BUFF_DURATION_MS;
                trSoundsetPlay("UI_MajorGodSelectZeus");
                trPlayerGrantResources(p, "Wood", -2);
                schedulerWithParameters.add(BUFF_DURATION_MS, params2, [](int iterations = 1, ref Parameters params) -> bool {
                    applyProtoActionToAllCards(params.ints[0], cXSActionEffectDamageDivine, -params.floats[0], cXSRelativityAbsolute);
                    return false;
                });
                break;
            }
        }
    }
}

void startBoss(){
    g_TopBossBuffMsEnd = new int(cNumberPlayers+1, -1);
    g_BotBossBuffMsEnd = new int(cNumberPlayers+1, -1);

    scheduler.add(60017, [](int iterations = 1) -> bool {
        trModifyProtounitData(TOP_BOSS_PROTO, 0, cXSProtoEffectUnitRegenRate, 1, cXSRelativityAbsolute);
        trModifyProtounitData(BOT_BOSS_PROTO, 0, cXSProtoEffectUnitRegenRate, 1, cXSRelativityAbsolute);
        trModifyProtounitResource(TOP_BOSS_PROTO, "Gold", 0, cXSPUResourceEffectKillReward, 50, cXSRelativityAbsolute);
        trModifyProtounitResource(BOT_BOSS_PROTO, "Gold", 0, cXSPUResourceEffectKillReward, 50, cXSRelativityAbsolute);
        return true;
    });

    scheduler.add(1051, [](int iterations = 1) -> bool {
        g_topBossCamp.processCamp();
        checkTopBossBuff();
        g_botBossCamp.processCamp();
        checkBotBossBuff();
        return true;
    });
}