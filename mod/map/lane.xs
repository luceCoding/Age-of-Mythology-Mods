const int aiTeamA = cNumberPlayers - 1;
const int aiTeamB = cNumberPlayers;

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

void spawnLaneArmy(ref LaneManager laneManager, int player = 0, vector spawnPos = cInvalidVector, vector destPos = cInvalidVector, float offsetX = 0.0, float offsetZ = 0.0) {
    string currentUnit = "";
    int nUnits = 5;
    
    if (g_laneCounter % HERO_WAVE == 0) { // Every 5 waves
        nUnits = 7; 
    }
    for (int i = 0; i < nUnits; i++) {
        if (i < 2) {
            currentUnit = "Hoplite";
        } else if (i < 4) {
            currentUnit = "Hippeus";
        } else if (i < 5) {
            currentUnit = "Toxotes";
        } else if (i < 6) {
            currentUnit = "Cyclops";
        } else {
            currentUnit = "Heracles";
        }
        int unitId = trUnitCreate(currentUnit, spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId);
    }
}

// ==========================================
// WAVE EXECUTION & TRIGGER LOOP
// ==========================================
void spawnLane(){
    // Team 1 Waves
    spawnLaneArmy(g_T1TopLane, aiTeamA, g_t1TopSpawn, g_T1ToT2TopLane[1], 7, 7);
    spawnLaneArmy(g_T1MidLane, aiTeamA, g_t1MidSpawn, g_T1ToT2MidLane[1], 7, -7);
    spawnLaneArmy(g_T1BotLane, aiTeamA, g_t1BotSpawn, g_T1ToT2BotLane[1], -7, -7);

    // Team 2 Waves
    spawnLaneArmy(g_T2TopLane, aiTeamB, g_t2TopSpawn, g_T1ToT2TopLane[6], 7, 7);
    spawnLaneArmy(g_T2MidLane, aiTeamB, g_t2MidSpawn, g_T1ToT2MidLane[6], -7, 7);
    spawnLaneArmy(g_T2BotLane, aiTeamB, g_t2BotSpawn, g_T1ToT2BotLane[6], -7, -7);
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