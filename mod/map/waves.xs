// ==========================================
// GLOBAL VECTOR WAYPOINT STORAGE
// ==========================================
vector[] g_T1ToT2TopLane = default; 
vector[] g_T1ToT2MidLane = default; 
vector[] g_T1ToT2BotLane = default; 

// (Optional) You can still keep spawn variables if you need them for instant lookup, 
// but they are now safely embedded at index 0 and 8 of the arrays.
vector g_t1TopSpawn = cInvalidVector;
vector g_t1MidSpawn = cInvalidVector;
vector g_t1BotSpawn = cInvalidVector;
vector g_t2TopSpawn = cInvalidVector;
vector g_t2MidSpawn = cInvalidVector;
vector g_t2BotSpawn = cInvalidVector;

LaneManager g_T1TopLane;
LaneManager g_T1MidLane;
LaneManager g_T1BotLane;

LaneManager g_T2TopLane;
LaneManager g_T2MidLane;
LaneManager g_T2BotLane;

// ==========================================
// HELPER FUNCTIONS
// ==========================================
int spawnBuilding(string protoName = "", float x = 0.0, float h = 0.0, float z = 0.0, float heading = 0.0, int player = 0, float scale = 0.0) {
    int unitId = trUnitCreateForced(protoName, x, h, z, heading, player);
    if (scale != 1.0) {
        trUnitSelectClear();
        trUnitSelectByID(unitId);
        trUnitSetScale(scale, scale, scale);
    }
    return unitId;
}

// ==========================================
// MAP SETUP & WAYPOINT POPULATION
// ==========================================
void createAIBases(){
    // --- Config & Proportions ---
    string unitFortress = "Fortress";
    string unitT1Tower  = "SentryTower";
    string unitT2Tower  = "MirrorTower";
    string unitT3Tower  = "StatueOfLightning";

    float fortressScale = 1.0;
    float towerScale    = 1.2;

    float team1Angle = 315.0;
    float team2Angle = 135.0;

    float fortOffset     = 0.13;
    float sideEdgeMargin = 0.05;

    float sideT3Step = 0.25; float sideT2Step = 0.45; float sideT1Step = 0.65;
    float midT3Step  = 0.225; float midT2Step  = 0.325; float midT1Step  = 0.425;

    int aiTeamA = cNumberPlayers - 1;
    int aiTeamB = cNumberPlayers;

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h    = configMapBaseHeight;

    // --- Base & Tower Coordinates ---
    float t1FortX = mapX * fortOffset;          float t1FortZ = mapZ * (1.0 - fortOffset);
    float t2FortX = mapX * (1.0 - fortOffset);  float t2FortZ = mapZ * fortOffset;

    // Team 1
    float t1TopT3X = mapX * sideT3Step;     float t1TopT3Z = mapZ * (1.0 - sideEdgeMargin);
    float t1TopT2X = mapX * sideT2Step;     float t1TopT2Z = mapZ * (1.0 - sideEdgeMargin);
    float t1TopT1X = mapX * sideT1Step;     float t1TopT1Z = mapZ * (1.0 - sideEdgeMargin);

    float t1MidT3X = mapX * midT3Step;      float t1MidT3Z = mapZ * (1.0 - midT3Step);
    float t1MidT2X = mapX * midT2Step;      float t1MidT2Z = mapZ * (1.0 - midT2Step);
    float t1MidT1X = mapX * midT1Step;      float t1MidT1Z = mapZ * (1.0 - midT1Step);

    float t1BotT3X = mapX * sideEdgeMargin; float t1BotT3Z = mapZ * (1.0 - sideT3Step);
    float t1BotT2X = mapX * sideEdgeMargin; float t1BotT2Z = mapZ * (1.0 - sideT2Step);
    float t1BotT1X = mapX * sideEdgeMargin; float t1BotT1Z = mapZ * (1.0 - sideT1Step);

    // Team 2
    float t2TopT3X = mapX * (1.0 - sideEdgeMargin); float t2TopT3Z = mapZ * sideT3Step;
    float t2TopT2X = mapX * (1.0 - sideEdgeMargin); float t2TopT2Z = mapZ * sideT2Step;
    float t2TopT1X = mapX * (1.0 - sideEdgeMargin); float t2TopT1Z = mapZ * sideT1Step;

    float t2MidT3X = mapX * (1.0 - midT3Step);      float t2MidT3Z = mapZ * midT3Step;
    float t2MidT2X = mapX * (1.0 - midT2Step);      float t2MidT2Z = mapZ * midT2Step;
    float t2MidT1X = mapX * (1.0 - midT1Step);      float t2MidT1Z = mapZ * midT1Step;

    float t2BotT3X = mapX * (1.0 - sideT3Step);     float t2BotT3Z = mapZ * sideEdgeMargin;
    float t2BotT2X = mapX * (1.0 - sideT2Step);     float t2BotT2Z = mapZ * sideEdgeMargin;
    float t2BotT1X = mapX * (1.0 - sideT1Step);     float t2BotT1Z = mapZ * sideEdgeMargin;

    // Junctions
    float topCornerX = mapX * (1.0 - sideEdgeMargin); float topCornerZ = mapZ * (1.0 - sideEdgeMargin);
    float botCornerX = mapX * sideEdgeMargin;         float botCornerZ = mapZ * sideEdgeMargin;
    float centerRiverX = mapX * 0.5;                  float centerRiverZ = mapZ * 0.5;

    // --- Spawn Buildings ---
    spawnBuilding(unitFortress, t1FortX, h, t1FortZ, team1Angle, aiTeamA, fortressScale);
    spawnBuilding(unitFortress, t2FortX, h, t2FortZ, team2Angle, aiTeamB, fortressScale);

    // Team 1 Towers
    spawnBuilding(unitT3Tower, t1TopT3X, h, t1TopT3Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT2Tower, t1TopT2X, h, t1TopT2Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT1Tower, t1TopT1X, h, t1TopT1Z, team1Angle, aiTeamA, towerScale);

    spawnBuilding(unitT3Tower, t1MidT3X, h, t1MidT3Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT2Tower, t1MidT2X, h, t1MidT2Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT1Tower, t1MidT1X, h, t1MidT1Z, team1Angle, aiTeamA, towerScale);

    spawnBuilding(unitT3Tower, t1BotT3X, h, t1BotT3Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT2Tower, t1BotT2X, h, t1BotT2Z, team1Angle, aiTeamA, towerScale);
    spawnBuilding(unitT1Tower, t1BotT1X, h, t1BotT1Z, team1Angle, aiTeamA, towerScale);

    // Team 2 Towers
    spawnBuilding(unitT3Tower, t2TopT3X, h, t2TopT3Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT2Tower, t2TopT2X, h, t2TopT2Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT1Tower, t2TopT1X, h, t2TopT1Z, team2Angle, aiTeamB, towerScale);

    spawnBuilding(unitT3Tower, t2MidT3X, h, t2MidT3Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT2Tower, t2MidT2X, h, t2MidT2Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT1Tower, t2MidT1X, h, t2MidT1Z, team2Angle, aiTeamB, towerScale);

    spawnBuilding(unitT3Tower, t2BotT3X, h, t2BotT3Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT2Tower, t2BotT2X, h, t2BotT2Z, team2Angle, aiTeamB, towerScale);
    spawnBuilding(unitT1Tower, t2BotT1X, h, t2BotT1Z, team2Angle, aiTeamB, towerScale);

    // --- POPULATE GLOBAL VECTORS ---
    // Arrays now hold 8 waypoints (Corners removed)
    g_T1ToT2TopLane = new vector(8, cInvalidVector);
    g_T1ToT2MidLane = new vector(8, cInvalidVector);
    g_T1ToT2BotLane = new vector(8, cInvalidVector);

    // Populate Spawns
    vector t1FortVec = vector(t1FortX, h, t1FortZ);
    vector t2FortVec = vector(t2FortX, h, t2FortZ);
    
    g_t1TopSpawn = t1FortVec; g_t1MidSpawn = t1FortVec; g_t1BotSpawn = t1FortVec;
    g_t2TopSpawn = t2FortVec; g_t2MidSpawn = t2FortVec; g_t2BotSpawn = t2FortVec;

    // Team 1 to Team 2 Top Lane (Indices 0 to 7)
    vector top0 = t1FortVec;                     g_T1ToT2TopLane[0] = top0;
    vector top1 = vector(t1TopT3X, h, t1TopT3Z); g_T1ToT2TopLane[1] = top1; g_T1TopLane.addPoint(top1);
    vector top2 = vector(t1TopT2X, h, t1TopT2Z); g_T1ToT2TopLane[2] = top2; g_T1TopLane.addPoint(top2);
    vector top3 = vector(t1TopT1X, h, t1TopT1Z); g_T1ToT2TopLane[3] = top3; g_T1TopLane.addPoint(top3);
    
    vector top4 = vector(t2TopT1X, h, t2TopT1Z); g_T1ToT2TopLane[4] = top4; g_T1TopLane.addPoint(top4);
    vector top5 = vector(t2TopT2X, h, t2TopT2Z); g_T1ToT2TopLane[5] = top5; g_T1TopLane.addPoint(top5);
    vector top6 = vector(t2TopT3X, h, t2TopT3Z); g_T1ToT2TopLane[6] = top6; g_T1TopLane.addPoint(top6);
    vector top7 = t2FortVec;                     g_T1ToT2TopLane[7] = top7; g_T1TopLane.addPoint(top7);

    g_T2TopLane.addPoint(top6);
    g_T2TopLane.addPoint(top5);
    g_T2TopLane.addPoint(top4);
    g_T2TopLane.addPoint(top3);
    g_T2TopLane.addPoint(top2);
    g_T2TopLane.addPoint(top1);
    g_T2TopLane.addPoint(top0);

    // Team 1 to Team 2 Mid Lane (Indices 0 to 7)
    vector mid0 = t1FortVec;                     g_T1ToT2MidLane[0] = mid0;
    vector mid1 = vector(t1MidT3X, h, t1MidT3Z); g_T1ToT2MidLane[1] = mid1; g_T1MidLane.addPoint(mid1);
    vector mid2 = vector(t1MidT2X, h, t1MidT2Z); g_T1ToT2MidLane[2] = mid2; g_T1MidLane.addPoint(mid2);
    vector mid3 = vector(t1MidT1X, h, t1MidT1Z); g_T1ToT2MidLane[3] = mid3; g_T1MidLane.addPoint(mid3);
    
    vector mid4 = vector(t2MidT1X, h, t2MidT1Z); g_T1ToT2MidLane[4] = mid4; g_T1MidLane.addPoint(mid4);
    vector mid5 = vector(t2MidT2X, h, t2MidT2Z); g_T1ToT2MidLane[5] = mid5; g_T1MidLane.addPoint(mid5);
    vector mid6 = vector(t2MidT3X, h, t2MidT3Z); g_T1ToT2MidLane[6] = mid6; g_T1MidLane.addPoint(mid6);
    vector mid7 = t2FortVec;                     g_T1ToT2MidLane[7] = mid7; g_T1MidLane.addPoint(mid7);

    g_T2MidLane.addPoint(mid6);
    g_T2MidLane.addPoint(mid5);
    g_T2MidLane.addPoint(mid4);
    g_T2MidLane.addPoint(mid3);
    g_T2MidLane.addPoint(mid2);
    g_T2MidLane.addPoint(mid1);
    g_T2MidLane.addPoint(mid0);

    // Team 1 to Team 2 Bot Lane (Indices 0 to 7)
    vector bot0 = t1FortVec;                     g_T1ToT2BotLane[0] = bot0;
    vector bot1 = vector(t1BotT3X, h, t1BotT3Z); g_T1ToT2BotLane[1] = bot1; g_T1BotLane.addPoint(bot1);
    vector bot2 = vector(t1BotT2X, h, t1BotT2Z); g_T1ToT2BotLane[2] = bot2; g_T1BotLane.addPoint(bot2);
    vector bot3 = vector(t1BotT1X, h, t1BotT1Z); g_T1ToT2BotLane[3] = bot3; g_T1BotLane.addPoint(bot3);
    
    vector bot4 = vector(t2BotT1X, h, t2BotT1Z); g_T1ToT2BotLane[4] = bot4; g_T1BotLane.addPoint(bot4);
    vector bot5 = vector(t2BotT2X, h, t2BotT2Z); g_T1ToT2BotLane[5] = bot5; g_T1BotLane.addPoint(bot5);
    vector bot6 = vector(t2BotT3X, h, t2BotT3Z); g_T1ToT2BotLane[6] = bot6; g_T1BotLane.addPoint(bot6);
    vector bot7 = t2FortVec;                     g_T1ToT2BotLane[7] = bot7; g_T1BotLane.addPoint(bot7);

    g_T2BotLane.addPoint(bot6);
    g_T2BotLane.addPoint(bot5);
    g_T2BotLane.addPoint(bot4);
    g_T2BotLane.addPoint(bot3);
    g_T2BotLane.addPoint(bot2);
    g_T2BotLane.addPoint(bot1);
    g_T2BotLane.addPoint(bot0);
}

void spawnLaneArmy(ref LaneManager laneManager, int player = 0, vector spawnPos = cInvalidVector, vector destPos = cInvalidVector, float offsetX = 0.0, float offsetZ = 0.0) {
    string currentUnit = "";
    for (int i = 0; i < 6; i++) {
        if (i < 2) {
            currentUnit = "Hoplite";
        } else if (i < 4) {
            currentUnit = "Toxotes";
        } else {
            currentUnit = "Hippeus";
        }

        int uId = trUnitCreate(currentUnit, spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 360), player);
        trUnitSelectClear();
        trUnitSelectByID(uId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(uId);
    }
}

// ==========================================
// WAVE EXECUTION & TRIGGER LOOP
// ==========================================
void spawnArmyWave(){
    int aiTeamA = cNumberPlayers - 1;
    int aiTeamB = cNumberPlayers;

    // Team 1 Waves
    spawnLaneArmy(g_T1TopLane, aiTeamA, g_t1TopSpawn, g_T1ToT2TopLane[1], 7, 7);
    spawnLaneArmy(g_T1MidLane, aiTeamA, g_t1MidSpawn, g_T1ToT2MidLane[1], 7, -7);
    spawnLaneArmy(g_T1BotLane, aiTeamA, g_t1BotSpawn, g_T1ToT2BotLane[1], -7, -7);

    // Team 2 Waves
    spawnLaneArmy(g_T2TopLane, aiTeamB, g_t2TopSpawn, g_T1ToT2TopLane[6], 7, 7);
    spawnLaneArmy(g_T2MidLane, aiTeamB, g_t2MidSpawn, g_T1ToT2MidLane[6], -7, 7);
    spawnLaneArmy(g_T2BotLane, aiTeamB, g_t2BotSpawn, g_T1ToT2BotLane[6], -7, -7);
}

void startWaves(){
    scheduler.add(30000, [](int iterations = 1) -> bool {
        spawnArmyWave();
        return true;
    });
    scheduler.add(3109, [](int iterations = 1) -> bool {
        g_T1TopLane.moveUnits();
        g_T1MidLane.moveUnits();
        g_T1BotLane.moveUnits();
        g_T2TopLane.moveUnits();
        g_T2MidLane.moveUnits();
        g_T2BotLane.moveUnits();
        return true;
    });
    scheduler.add(1000, [](int iterations = 1) -> bool {
        for (int i = 1; i <= g_shop.m_benches.size()-2; i++){
            BenchData bench = g_shop.m_benches[i];
            bool wasRespawned = bench.respawnDeployedCards();
            if (wasRespawned){
                g_shop.m_benches[i] = bench;
            }
        }
        return true;
    });
}