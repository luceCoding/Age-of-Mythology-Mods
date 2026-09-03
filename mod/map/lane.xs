const int aiTeamA = cNumberPlayers - 1;
const int aiTeamB = cNumberPlayers;

// ==========================================
// BARRACKS TRACKING IDs
// ==========================================
int g_t1TopBarracksID = -1;
int g_t1MidBarracksID = -1;
int g_t1BotBarracksID = -1;

int g_t2TopBarracksID = -1;
int g_t2MidBarracksID = -1;
int g_t2BotBarracksID = -1;

bool isUnitDead(int unitId = -1) {
    if (unitId < 0) { return true; }
    selectSingle(unitId);
    return trUnitDead();
}

class LaneManager {
    vector[] m_waypoints = default;
    int[] m_unitIds = default;
    int[] m_unitTargetIndices = default;
    int m_unitSize = 0; // Tracks active units without shrinking/reallocating parallel arrays

    void init(){
        m_waypoints = new vector(0, cInvalidVector);
        m_unitSize = 0;
    }

    void addPoint(vector point = cInvalidVector){
        m_waypoints.add(point);
    }

    void addUnit(int unitId = -1){
        if (m_waypoints.size() == 0){
            errorLog("LaneManager: Cannot add unit, no waypoints defined!");
            return;
        }

        // Reuse an existing slot if available, otherwise grow the array pools
        if (m_unitSize < m_unitIds.size()) {
            m_unitIds[m_unitSize] = unitId;
            m_unitTargetIndices[m_unitSize] = 0; // Start unit targeting the first waypoint
        } else {
            m_unitIds.add(unitId);
            m_unitTargetIndices.add(0);
        }
        m_unitSize++;
    }

    void moveUnits(){
        if (m_waypoints.size() == 0) {
            return;
        }

        // Only loop through active units up to m_unitSize
        for (int i = 0; i < m_unitSize; i++){
            int unitID = m_unitIds[i];
            selectSingle(unitID);
            
            // Remove dead units via swap-and-pop
            if (trUnitDead()){
                m_unitSize--; // Reduce active count
                
                // Swap the last active elements into this index if it's not the last one
                if (i < m_unitSize) {
                    m_unitIds[i] = m_unitIds[m_unitSize];
                    m_unitTargetIndices[i] = m_unitTargetIndices[m_unitSize];
                }
                
                i--; // Step back to evaluate the newly swapped-in unit
                continue;
            }

            int targetIdx = m_unitTargetIndices[i];
            // Check if unit has reached end of path
            if (targetIdx >= m_waypoints.size()){
                continue; 
            }

            vector currPoint = m_waypoints[targetIdx];
            if (trUnitDistanceToPoint(currPoint.x, currPoint.y, currPoint.z) <= 15.0){
                targetIdx = targetIdx + 1;
                m_unitTargetIndices[i] = targetIdx;

                if (targetIdx < m_waypoints.size()){
                    vector nextPoint = m_waypoints[targetIdx];
                    trUnitMoveToPoint(nextPoint.x, nextPoint.y, nextPoint.z, -1, true);
                }
            }
        }
    }
};

// ==========================================
// GLOBAL VECTOR WAYPOINT STORAGE
// ==========================================

vector[] g_T1ToT2TopLane = default; 
vector[] g_T1ToT2MidLane = default; 
vector[] g_T1ToT2BotLane = default; 

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

int g_laneCounter = 1;

void spawnLaneArmy(ref LaneManager laneManager, int player = 0, vector spawnPos = cInvalidVector, vector destPos = cInvalidVector, float offsetX = 0.0, float offsetZ = 0.0, bool hasBonusUnits = false, bool hasSuperBonus = false) {
    string currentUnit = "";
    
    // Base wave units: 2 Hoplites, 2 Hippeus, 1 Toxotes (Total = 5)
    int numHoplites = 2;
    int numHippeus = 2;
    int numToxotes = 1;
    float rdmOffset = 2.0;

    // If opposing barracks is destroyed, increase standard composition for this wave
    if (hasBonusUnits) {
        numHoplites = numHoplites + 1;
        numHippeus = numHippeus + 1;
        numToxotes = numToxotes + 1;
    }

    // Spawn Hoplites
    for (int i = 0; i < numHoplites; i++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId = trUnitCreate("Hoplite", spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId);
    }

    // Spawn Hippeus
    for (int j = 0; j < numHippeus; j++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId2 = trUnitCreate("Hippeus", spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId2);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId2);
    }

    // Spawn Toxotes
    for (int k = 0; k < numToxotes; k++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId3 = trUnitCreate("Toxotes", spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId3);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId3);
    }

    // Hero / Myth Wave check (Every 5 waves: adds Cyclops and Heracles)
    if (g_laneCounter % HERO_WAVE == 0 || hasSuperBonus) {
        string[] heroUnits = new string(2, "Cyclops");
        heroUnits[0] = "Cyclops";
        heroUnits[1] = "Heracles";

        for (int h = 0; h < 2; h++) {
            int heroId = trUnitCreate(heroUnits[h], spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 359), player);
            selectSingle(heroId);
            trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
            laneManager.addUnit(heroId);
        }
    }

    if (hasSuperBonus){
        int heroId = trUnitCreate("Colossus", spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(heroId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(heroId);
    }
}

// ==========================================
// WAVE EXECUTION & TRIGGER LOOP
// ==========================================
void spawnLane(){
    // Check if opposing barracks are destroyed for each lane
    bool t1TopBonus = isUnitDead(g_t2TopBarracksID);
    bool t1MidBonus = isUnitDead(g_t2MidBarracksID);
    bool t1BotBonus = isUnitDead(g_t2BotBarracksID);

    bool t2TopBonus = isUnitDead(g_t1TopBarracksID);
    bool t2MidBonus = isUnitDead(g_t1MidBarracksID);
    bool t2BotBonus = isUnitDead(g_t1BotBarracksID);

    bool t1SuperBonus = (t1TopBonus && t1MidBonus && t1BotBonus);
    bool t2SuperBonus = (t2TopBonus && t2MidBonus && t2BotBonus);

    // Team 1 Waves (Passes bonus flag if Team 2's corresponding barracks is dead)
    spawnLaneArmy(g_T1TopLane, aiTeamA, g_t1TopSpawn, g_T1ToT2TopLane[1], 7, 7, t1TopBonus, t1SuperBonus);
    spawnLaneArmy(g_T1MidLane, aiTeamA, g_t1MidSpawn, g_T1ToT2MidLane[1], 7, -7, t1MidBonus, t1SuperBonus);
    spawnLaneArmy(g_T1BotLane, aiTeamA, g_t1BotSpawn, g_T1ToT2BotLane[1], -7, -7, t1BotBonus, t1SuperBonus);

    // Team 2 Waves (Passes bonus flag if Team 1's corresponding barracks is dead)
    spawnLaneArmy(g_T2TopLane, aiTeamB, g_t2TopSpawn, g_T1ToT2TopLane[6], 7, 7, t2TopBonus, t2SuperBonus);
    spawnLaneArmy(g_T2MidLane, aiTeamB, g_t2MidSpawn, g_T1ToT2MidLane[6], -7, 7, t2MidBonus, t2SuperBonus);
    spawnLaneArmy(g_T2BotLane, aiTeamB, g_t2BotSpawn, g_T1ToT2BotLane[6], -7, -7, t2BotBonus, t2SuperBonus);
    
    g_laneCounter = g_laneCounter + 1;
}

void startLanes(){
    scheduler.add(30000, [](int iterations = 1) -> bool {
        spawnLane();
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

    // Medium upgrades
    scheduler.add(600000, [](int iterations = 1) -> bool {
        for (int p = cNumberPlayers-1; p <= cNumberPlayers; p++){
            trTechSetStatus(p, 394, 2); // Archers
            trTechSetStatus(p, 397, 2); // Cav
            trTechSetStatus(p, 391, 2); // Inf
        }
        return false;
    });

    // Heavy upgrades
    scheduler.add(1200000, [](int iterations = 1) -> bool {
        for (int p = cNumberPlayers-1; p <= cNumberPlayers; p++){
            trTechSetStatus(p, 395, 2);
            trTechSetStatus(p, 398, 2);
            trTechSetStatus(p, 392, 2);
        }
        return false;
    });

    // Champion upgrades
    scheduler.add(1800000, [](int iterations = 1) -> bool {
        for (int p = cNumberPlayers-1; p <= cNumberPlayers; p++){
            trTechSetStatus(p, 396, 2);
            trTechSetStatus(p, 399, 2);
            trTechSetStatus(p, 393, 2);
        }
        return false;
    });

    scheduler.add(600000, [](int iterations = 1) -> bool {
        for (int p = cNumberPlayers-1; p <= cNumberPlayers; p++){
            trTechSetStatus(p, 66, 2); // Dionysia
        }
        return true;
    });
}