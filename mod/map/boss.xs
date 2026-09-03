CreepCamp g_topBossCamp;
CreepCamp g_botBossCamp;

// ==========================================
// BOSS PIT GENERATOR (Clean Single Ring with Subtle Jitter)
// ==========================================
void createBossPits() {
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h = configMapBaseHeight;

    // ------------------------------------------
    // TUNING CONTROLS
    // ------------------------------------------
    float baseRadius = 20.0;     // Base radius of the single ring
    string torchProto = "Torch"; 
    float cornerMargin = 0.11; 

    float topCornerX = mapX * (1.0 - cornerMargin);
    float topCornerZ = mapZ * (1.0 - cornerMargin);

    float botCornerX = mapX * cornerMargin;
    float botCornerZ = mapZ * cornerMargin;

    float stepSize = 7;
    float circumference = 2.0 * cPi * baseRadius;
    int steps = circumference / stepSize;
    if (steps <= 0) steps = 1;
    float stepDeg = 360.0 / steps;

    // Spawn Center Boss Structures
    int topBossPlaceholderID = spawnUnit(TOP_BOSS_PLACEHOLDER_PROTO, topCornerX, h, topCornerZ, xsRandFloat(0, 359), 0, 1.5);
    int botBossPlaceholderID = spawnUnit(BOT_BOSS_PLACEHOLDER_PROTO, botCornerX, h, botCornerZ, xsRandFloat(0, 359), 0, 1.5);

    g_topBossCamp.init(topBossPlaceholderID, BOSS_SPAWN_TIME, TOP_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);
    g_botBossCamp.init(botBossPlaceholderID, BOSS_SPAWN_TIME, BOT_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);

    // --- TOP BOSS PIT (Single Ring, Tight Jitter) ---
    for (int i = 0; i < steps; i++) {
        float currentAngle = i * stepDeg;
        
        // Micro-adjustment (only +/- 0.3 meters) so it stays on a single track
        float currentRadius = baseRadius + ((i % 3 - 1) * 0.3);

        float x = topCornerX + (currentRadius * cosDeg(currentAngle));
        float z = topCornerZ + (currentRadius * sinDeg(currentAngle));

        spawnUnit(torchProto, x, h, z, xsRandFloat(0, 359), 0);
    }

    // --- BOTTOM BOSS PIT (Single Ring, Tight Jitter) ---
    for (int j = 0; j < steps; j++) {
        float currentAngle = j * stepDeg;
        
        float currentRadius = baseRadius + ((j % 3 - 1) * 0.3);

        float x = botCornerX + (currentRadius * cosDeg(currentAngle));
        float z = botCornerZ + (currentRadius * sinDeg(currentAngle));

        spawnUnit(torchProto, x, h, z, xsRandFloat(0, 359), 0);
    }
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