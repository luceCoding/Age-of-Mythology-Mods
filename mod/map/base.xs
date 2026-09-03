// ==========================================
// HELPER FUNCTIONS
// ==========================================
int spawnUnit(string protoName = "", float x = 0.0, float h = 0.0, float z = 0.0, float heading = 0.0, int player = 0, float scale = 1.0) {
    int unitId = trUnitCreateForced(protoName, x, h, z, heading, player);
    if (scale != 1.0) {
        selectSingle(unitId);
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
    string unitBarracks = "MilitaryAcademy";

    float fortressScale = 1.25;
    float towerScale    = 1.25;
    float barracksScale = 1.0;

    float team1DefaultAngle = 315.0;
    float team2DefaultAngle = 135.0;

    float fortOffset     = 0.09;
    float sideEdgeMargin = 0.11;

    float sideT3Step = 0.25; float sideT2Step = 0.45; float sideT1Step = 0.65;
    float midT3Step  = 0.225; float midT2Step  = 0.325; float midT1Step  = 0.425;

    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;
    float h    = configMapBaseHeight;

    // --- Base & Tower Coordinates ---
    float t1FortX = mapX * fortOffset;           float t1FortZ = mapZ * (1.0 - fortOffset);
    float t2FortX = mapX * (1.0 - fortOffset);   float t2FortZ = mapZ * fortOffset;

    // Team 1
    float t1TopT3X = mapX * sideT3Step;     float t1TopT3Z = mapZ * (1.0 - sideEdgeMargin);
    float t1TopT2X = mapX * sideT2Step;     float t1TopT2Z = mapZ * (1.0 - sideEdgeMargin);
    float t1TopT1X = mapX * sideT1Step;     float t1TopT1Z = mapZ * (1.0 - sideEdgeMargin);

    float t1MidT3X = mapX * midT3Step;       float t1MidT3Z = mapZ * (1.0 - midT3Step);
    float t1MidT2X = mapX * midT2Step;       float t1MidT2Z = mapZ * (1.0 - midT2Step);
    float t1MidT1X = mapX * midT1Step;       float t1MidT1Z = mapZ * (1.0 - midT1Step);

    float t1BotT3X = mapX * sideEdgeMargin; float t1BotT3Z = mapZ * (1.0 - sideT3Step);
    float t1BotT2X = mapX * sideEdgeMargin; float t1BotT2Z = mapZ * (1.0 - sideT2Step);
    float t1BotT1X = mapX * sideEdgeMargin; float t1BotT1Z = mapZ * (1.0 - sideT1Step);

    // Team 2
    float t2TopT3X = mapX * (1.0 - sideEdgeMargin); float t2TopT3Z = mapZ * sideT3Step;
    float t2TopT2X = mapX * (1.0 - sideEdgeMargin); float t2TopT2Z = mapZ * sideT2Step;
    float t2TopT1X = mapX * (1.0 - sideEdgeMargin); float t2TopT1Z = mapZ * sideT1Step;

    float t2MidT3X = mapX * (1.0 - midT3Step);       float t2MidT3Z = mapZ * midT3Step;
    float t2MidT2X = mapX * (1.0 - midT2Step);       float t2MidT2Z = mapZ * midT2Step;
    float t2MidT1X = mapX * (1.0 - midT1Step);       float t2MidT1Z = mapZ * midT1Step;

    float t2BotT3X = mapX * (1.0 - sideT3Step);     float t2BotT3Z = mapZ * sideEdgeMargin;
    float t2BotT2X = mapX * (1.0 - sideT2Step);     float t2BotT2Z = mapZ * sideEdgeMargin;
    float t2BotT1X = mapX * (1.0 - sideT1Step);     float t2BotT1Z = mapZ * sideEdgeMargin;

    // --- Calculate Accurate Lane-Facing Headings ---
    // Team 1 Headings
    float t1TopHeading = atan2Deg(t1TopT2Z - t1TopT3Z, t1TopT2X - t1TopT3X) - 90.0;
    float t1MidHeading = atan2Deg(t1MidT2Z - t1MidT3Z, t1MidT2X - t1MidT3X);
    float t1BotHeading = atan2Deg(t1BotT2Z - t1BotT3Z, t1BotT2X - t1BotT3X) + 90.0;

    // Team 2 Headings (Mirrored for top and bottom)
    float t2TopHeading = atan2Deg(t2TopT2Z - t2TopT3Z, t2TopT2X - t2TopT3X) + 90.0;
    float t2MidHeading = atan2Deg(t2MidT2Z - t2MidT3Z, t2MidT2X - t2MidT3X);
    float t2BotHeading = atan2Deg(t2BotT2Z - t2BotT3Z, t2BotT2X - t2BotT3X) - 90.0;

    // --- Spawn Buildings ---
    spawnUnit(unitFortress, t1FortX, h, t1FortZ, team1DefaultAngle, aiTeamA, fortressScale);
    spawnUnit(unitFortress, t2FortX, h, t2FortZ, team2DefaultAngle, aiTeamB, fortressScale);

    // Team 1 Towers
    spawnUnit(unitT3Tower, t1TopT3X, h, t1TopT3Z, t1TopHeading, aiTeamA, towerScale);
    spawnUnit(unitT2Tower, t1TopT2X, h, t1TopT2Z, team1DefaultAngle, aiTeamA, towerScale);
    spawnUnit(unitT1Tower, t1TopT1X, h, t1TopT1Z, team1DefaultAngle, aiTeamA, towerScale);

    spawnUnit(unitT3Tower, t1MidT3X, h, t1MidT3Z, t1MidHeading, aiTeamA, towerScale);
    spawnUnit(unitT2Tower, t1MidT2X, h, t1MidT2Z, team1DefaultAngle, aiTeamA, towerScale);
    spawnUnit(unitT1Tower, t1MidT1X, h, t1MidT1Z, team1DefaultAngle, aiTeamA, towerScale);

    spawnUnit(unitT3Tower, t1BotT3X, h, t1BotT3Z, t1BotHeading, aiTeamA, towerScale);
    spawnUnit(unitT2Tower, t1BotT2X, h, t1BotT2Z, team1DefaultAngle, aiTeamA, towerScale);
    spawnUnit(unitT1Tower, t1BotT1X, h, t1BotT1Z, team1DefaultAngle, aiTeamA, towerScale);

    // Team 2 Towers
    spawnUnit(unitT3Tower, t2TopT3X, h, t2TopT3Z, t2TopHeading, aiTeamB, towerScale);
    spawnUnit(unitT2Tower, t2TopT2X, h, t2TopT2Z, team2DefaultAngle, aiTeamB, towerScale);
    spawnUnit(unitT1Tower, t2TopT1X, h, t2TopT1Z, team2DefaultAngle, aiTeamB, towerScale);

    spawnUnit(unitT3Tower, t2MidT3X, h, t2MidT3Z, t2MidHeading, aiTeamB, towerScale);
    spawnUnit(unitT2Tower, t2MidT2X, h, t2MidT2Z, team2DefaultAngle, aiTeamB, towerScale);
    spawnUnit(unitT1Tower, t2MidT1X, h, t2MidT1Z, team2DefaultAngle, aiTeamB, towerScale);

    spawnUnit(unitT3Tower, t2BotT3X, h, t2BotT3Z, t2BotHeading, aiTeamB, towerScale);
    spawnUnit(unitT2Tower, t2BotT2X, h, t2BotT2Z, team2DefaultAngle, aiTeamB, towerScale);
    spawnUnit(unitT1Tower, t2BotT1X, h, t2BotT1Z, team2DefaultAngle, aiTeamB, towerScale);

    // --- Barracks Behind T3 Towers (Facing Down Lane) ---
    float barracksPushFactor = 0.8; 

    // Team 1 Barracks (Captured IDs)
    g_t1TopBarracksID = spawnUnit(unitBarracks, t1FortX + (t1TopT3X - t1FortX) * barracksPushFactor, h, t1FortZ + (t1TopT3Z - t1FortZ) * barracksPushFactor, t1TopHeading, aiTeamA, barracksScale);
    g_t1MidBarracksID = spawnUnit(unitBarracks, t1FortX + (t1MidT3X - t1FortX) * barracksPushFactor, h, t1FortZ + (t1MidT3Z - t1FortZ) * barracksPushFactor, t1MidHeading, aiTeamA, barracksScale);
    g_t1BotBarracksID = spawnUnit(unitBarracks, t1FortX + (t1BotT3X - t1FortX) * barracksPushFactor, h, t1FortZ + (t1BotT3Z - t1FortZ) * barracksPushFactor, t1BotHeading, aiTeamA, barracksScale);

    // Team 2 Barracks (Captured IDs)
    g_t2TopBarracksID = spawnUnit(unitBarracks, t2FortX + (t2TopT3X - t2FortX) * barracksPushFactor, h, t2FortZ + (t2TopT3Z - t2FortZ) * barracksPushFactor, t2TopHeading, aiTeamB, barracksScale);
    g_t2MidBarracksID = spawnUnit(unitBarracks, t2FortX + (t2MidT3X - t2FortX) * barracksPushFactor, h, t2FortZ + (t2MidT3Z - t2FortZ) * barracksPushFactor, t2MidHeading, aiTeamB, barracksScale);
    g_t2BotBarracksID = spawnUnit(unitBarracks, t2FortX + (t2BotT3X - t2FortX) * barracksPushFactor, h, t2FortZ + (t2BotT3Z - t2FortZ) * barracksPushFactor, t2BotHeading, aiTeamB, barracksScale);

    // --- POPULATE GLOBAL VECTORS ---
    g_T1ToT2TopLane = new vector(8, cInvalidVector);
    g_T1ToT2MidLane = new vector(8, cInvalidVector);
    g_T1ToT2BotLane = new vector(8, cInvalidVector);

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

// ==========================================
// ARC WALL HELPER (Pure Degree-Based)
// ==========================================
void spawnArcSegment(float cx = 0.0, float cz = 0.0, float radius = 0.0, float startAngleDeg = 0.0, float endAngleDeg = 0.0, int player = 0) {
    string wallProto = "WallOfAtlantisConnector";
    
    float angleDiff = endAngleDeg - startAngleDeg;
    
    float absDiff = angleDiff;
    if (absDiff < 0.0) {
        absDiff = 0.0 - absDiff;
    }
    
    // Arc length in meters = radius * angleInRadians
    float arcLength = radius * (absDiff * 0.0174532925);
    
    float stepSize = 3.0; // Spacing between wall connectors
    int steps = arcLength / stepSize;
    if (steps <= 0) steps = 1;

    float stepDeg = angleDiff / steps;

    for (int i = 0; i <= steps; i++) {
        float currentAngleDeg = startAngleDeg + (i * stepDeg);
        
        // cosDeg and sinDeg accept degrees directly
        float x = cx + (radius * cosDeg(currentAngleDeg));
        float z = cz + (radius * sinDeg(currentAngleDeg));

        int wallId = trUnitCreateForced(wallProto, x, configMapBaseHeight, z, 0.0, player);
        selectSingle(wallId);
        trUnitSetScale(1.2, 1.2, 1.2);
    }
}

// ==========================================
// BASE OUTERWALL GENERATOR
// ==========================================
void createBaseOuterwalls() {
    
    float mapX = configMapTileX * 2.0;
    float mapZ = configMapTileZ * 2.0;

    float fortOffset = 0.13;
    
    // Base Fortresses
    float t1FortX = mapX * fortOffset;          float t1FortZ = mapZ * (1.0 - fortOffset);
    float t2FortX = mapX * (1.0 - fortOffset);  float t2FortZ = mapZ * fortOffset;

    // ------------------------------------------
    // TUNING CONTROLS
    // ------------------------------------------
    float baseRadius = 59; // Distance from Fortress to Outer Wall (meters)
    float gapAngle   = 20; // Width of the gap at each lane exit (degrees)
    float halfGap    = gapAngle * 0.5;

    // TEAM 1 (Primary Base Orientations)
    float t1StartAngle = -135.0; // Bottom boundary
    float t1EndAngle   = 45.0;   // Top boundary
    float sideT3Step = 0.325;
    float midT3Step = 0.275;
    float sideEdgeMargin = 0.11;

    // Exact T3 Tower coordinates
    float t1TopT3X = mapX * sideT3Step;     float t1TopT3Z = mapZ * (1.0 - sideEdgeMargin);
    float t1MidT3X = mapX * midT3Step;      float t1MidT3Z = mapZ * (1.0 - midT3Step);
    float t1BotT3X = mapX * sideEdgeMargin; float t1BotT3Z = mapZ * (1.0 - sideT3Step);

    // Calculate exact lane gate angles relative to Fort 1
    float a1Bot = atan2Deg(t1BotT3Z - t1FortZ, t1BotT3X - t1FortX);
    float a1Mid = atan2Deg(t1MidT3Z - t1FortZ, t1MidT3X - t1FortX);
    float a1Top = atan2Deg(t1TopT3Z - t1FortZ, t1TopT3X - t1FortX);

    // 180 Semicircle facing map center (-135 to +45)
    spawnArcSegment(t1FortX, t1FortZ, baseRadius, t1StartAngle, a1Bot - halfGap, aiTeamA);
    spawnArcSegment(t1FortX, t1FortZ, baseRadius, a1Bot + halfGap, a1Mid - halfGap, aiTeamA);
    spawnArcSegment(t1FortX, t1FortZ, baseRadius, a1Mid + halfGap, a1Top - halfGap, aiTeamA);
    spawnArcSegment(t1FortX, t1FortZ, baseRadius, a1Top + halfGap, t1EndAngle, aiTeamA);

    // TEAM 2
    float t2StartAngle = t1StartAngle + 180.0;
    float t2EndAngle   = t1EndAngle + 180.0;

    float t2TopT3X = mapX * (1.0 - sideEdgeMargin); float t2TopT3Z = mapZ * sideT3Step;
    float t2MidT3X = mapX * (1.0 - midT3Step);      float t2MidT3Z = mapZ * midT3Step;
    float t2BotT3X = mapX * (1.0 - sideT3Step);     float t2BotT3Z = mapZ * sideEdgeMargin;

    // Calculate exact lane gate angles relative to Fort 2
    float a2Top = atan2Deg(t2TopT3Z - t2FortZ, t2TopT3X - t2FortX);
    float a2Mid = atan2Deg(t2MidT3Z - t2FortZ, t2MidT3X - t2FortX);
    float a2Bot = atan2Deg(t2BotT3Z - t2FortZ, t2BotT3X - t2FortX);

    // Normalize negative angles to positive [0, 360] for sequential arc step
    if (a2Top < 0.0) a2Top = a2Top + 360.0;
    if (a2Mid < 0.0) a2Mid = a2Mid + 360.0;
    if (a2Bot < 0.0) a2Bot = a2Bot + 360.0;

    // 180 Semicircle facing map center (45 to 225)
    spawnArcSegment(t2FortX, t2FortZ, baseRadius, t2StartAngle, a2Top - halfGap, aiTeamB);
    spawnArcSegment(t2FortX, t2FortZ, baseRadius, a2Top + halfGap, a2Mid - halfGap, aiTeamB);
    spawnArcSegment(t2FortX, t2FortZ, baseRadius, a2Mid + halfGap, a2Bot - halfGap, aiTeamB);
    spawnArcSegment(t2FortX, t2FortZ, baseRadius, a2Bot + halfGap, t2EndAngle, aiTeamB);
}