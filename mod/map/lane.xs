const int aiTeamA = cNumberPlayers - 1;
const int aiTeamB = cNumberPlayers;

class LaneManager {
    vector[] m_waypoints = default;
    int[] m_unitIds = default;
    int[] m_unitTargetIndices = default;

    void init(){
        m_waypoints = new vector(0, cInvalidVector);
    }

    void addPoint(vector point = cInvalidVector){
        m_waypoints.add(point);
    }

    void addUnit(int unitId = -1){
        if (m_waypoints.size() == 0){
            errorLog("LaneManager: Cannot add unit, no waypoints defined!");
            return;
        }
        m_unitIds.add(unitId);
        m_unitTargetIndices.add(0); // Start unit targeting the first waypoint
    }

    void moveUnits(){
        if (m_waypoints.size() == 0) {
            return;
        }

        for (int i = 0; i < m_unitIds.size(); i++){
            int unitID = m_unitIds[i];
            trUnitSelectClear();
            trUnitSelectByID(unitID);

            // Remove dead units
            if (trUnitDead()){
                int lastIndex = m_unitIds.size() - 1;
                
                // Swap-and-pop both parallel tracking arrays
                m_unitIds[i] = m_unitIds[lastIndex];
                m_unitIds.resize(lastIndex, -1);

                m_unitTargetIndices[i] = m_unitTargetIndices[lastIndex];
                m_unitTargetIndices.resize(lastIndex, 0);
                i--; // Reprocess the swapped unit at current index
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
void spawnLane(){
    
    // Team 1 Waves
    spawnLaneArmy(g_T1TopLane, aiTeamA, g_t1TopSpawn, g_T1ToT2TopLane[1], 7, 7);
    spawnLaneArmy(g_T1MidLane, aiTeamA, g_t1MidSpawn, g_T1ToT2MidLane[1], 7, -7);
    spawnLaneArmy(g_T1BotLane, aiTeamA, g_t1BotSpawn, g_T1ToT2BotLane[1], -7, -7);

    // Team 2 Waves
    spawnLaneArmy(g_T2TopLane, aiTeamB, g_t2TopSpawn, g_T1ToT2TopLane[6], 7, 7);
    spawnLaneArmy(g_T2MidLane, aiTeamB, g_t2MidSpawn, g_T1ToT2MidLane[6], -7, 7);
    spawnLaneArmy(g_T2BotLane, aiTeamB, g_t2BotSpawn, g_T1ToT2BotLane[6], -7, -7);
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
}