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
    float cornerMargin = 0.09; 

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
    int topBossPlaceholderID = spawnUnit(TOP_BOSS_PLACEHOLDER_PROTO, topCornerX, h, topCornerZ, xsRandFloat(0, 360), 0, 1.5);
    int botBossPlaceholderID = spawnUnit(BOT_BOSS_PLACEHOLDER_PROTO, botCornerX, h, botCornerZ, xsRandFloat(0, 360), 0, 1.5);

    g_topBossCamp.init(topBossPlaceholderID, BOSS_SPAWN_TIME, TOP_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);
    g_botBossCamp.init(botBossPlaceholderID, BOSS_SPAWN_TIME, BOT_BOSS_PROTO, 1, BOSS_SPAWN_TIME + 60, 2.0, false);

    // --- TOP BOSS PIT (Single Ring, Tight Jitter) ---
    for (int i = 0; i < steps; i++) {
        float currentAngle = i * stepDeg;
        
        // Micro-adjustment (only +/- 0.3 meters) so it stays on a single track
        float currentRadius = baseRadius + ((i % 3 - 1) * 0.3);

        float x = topCornerX + (currentRadius * cosDeg(currentAngle));
        float z = topCornerZ + (currentRadius * sinDeg(currentAngle));

        spawnUnit(torchProto, x, h, z, xsRandFloat(0, 360), 0);
    }

    // --- BOTTOM BOSS PIT (Single Ring, Tight Jitter) ---
    for (int j = 0; j < steps; j++) {
        float currentAngle = j * stepDeg;
        
        float currentRadius = baseRadius + ((j % 3 - 1) * 0.3);

        float x = botCornerX + (currentRadius * cosDeg(currentAngle));
        float z = botCornerZ + (currentRadius * sinDeg(currentAngle));

        spawnUnit(torchProto, x, h, z, xsRandFloat(0, 360), 0);
    }
}

void startBoss(){
    scheduler.add(60000, [](int iterations = 1) -> bool {
        trModifyProtounitData(TOP_BOSS_PROTO, 0, cXSProtoEffectUnitRegenRate, 1, cXSRelativityAbsolute);
        trModifyProtounitData(BOT_BOSS_PROTO, 0, cXSProtoEffectUnitRegenRate, 1, cXSRelativityAbsolute);
        trModifyProtounitResource(TOP_BOSS_PROTO, "Gold", 0, cXSPUResourceEffectKillReward, 100, cXSRelativityAbsolute);
        trModifyProtounitResource(BOT_BOSS_PROTO, "Gold", 0, cXSPUResourceEffectKillReward, 100, cXSRelativityAbsolute);
        return true;
    });

    scheduler.add(1051, [](int iterations = 1) -> bool {
        g_topBossCamp.processCamp();
        g_botBossCamp.processCamp();
        return true;
    });
}