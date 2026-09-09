const int aiTeamA = cNumberPlayers - 1;
const int aiTeamB = cNumberPlayers;
int g_t1FortressId = -1;
int g_t2FortressId = -1;

// ==========================================
// INVULNERABILITY & TOWER STATUS HELPERS
// ==========================================
bool isUnitDead(int unitId = -1) {
    if (unitId < 0) { return true; }
    selectSingle(unitId);
    return trUnitDead();
}

void setUnitInvulnerable(int unitId = -1, bool isInvulnerable = false) {
    if (unitId >= 0) {
        selectSingle(unitId);
        trUnitMakeInvulnerable(isInvulnerable);
    }
}

class LaneManager {
    int m_unitSize = 0; // Tracks active units without shrinking/reallocating parallel arrays
    int m_barracksUnitID = -1;
    int m_fortressUnitID = -1;
    vector[] m_waypoints = default;
    int[] m_unitIds = default;
    int[] m_unitTargetIndices = default;
    int[] m_towerUnitIDs = default;

    // Track whether invulnerability has already been stripped to avoid redundant native calls
    bool m_t2Vulnerable = false;
    bool m_t3Vulnerable = false;
    bool m_barracksVulnerable = false;

    void init(){
        m_waypoints = new vector(0, cInvalidVector);
        m_towerUnitIDs = new int(3, -1);
        m_unitSize = 0;
        m_barracksUnitID = -1;
        m_fortressUnitID = -1;
        m_t2Vulnerable = false;
        m_t3Vulnerable = false;
        m_barracksVulnerable = false;
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

    void addTower(int index = 0, int unitId = -1){
        if (index < 0) {
            return;
        }

        // Dynamically grow the tower array if the index exceeds current capacity
        while (index >= m_towerUnitIDs.size()) {
            m_towerUnitIDs.add(-1);
        }

        m_towerUnitIDs[index] = unitId;
    }

    void addBarracks(int unitId = -1) {
        m_barracksUnitID = unitId;
    }

    void addFortress(int unitId = -1) {
        m_fortressUnitID = unitId;
    }

    bool isT1Dead() {
        if (m_towerUnitIDs.size() > 2) {
            return isUnitDead(m_towerUnitIDs[2]);
        }
        return true;
    }

    bool isT2Dead() {
        if (m_towerUnitIDs.size() > 1) {
            return isUnitDead(m_towerUnitIDs[1]);
        }
        return true;
    }

    bool isT3Dead() {
        if (m_towerUnitIDs.size() > 0) {
            return isUnitDead(m_towerUnitIDs[0]);
        }
        return true;
    }

    bool isBarracksDead() {
        return isUnitDead(m_barracksUnitID);
    }

    bool isFortressDead() {
        return isUnitDead(m_fortressUnitID);
    }

    // Evaluates sequential invulnerability rules for this lane
    void updateInvulnerability() {
        // Rule 1: Turn off T2 invulnerability if T1 tower is dead
        if (!m_t2Vulnerable && isT1Dead()) {
            if (m_towerUnitIDs.size() > 1) {
                setUnitInvulnerable(m_towerUnitIDs[1], false);
                m_t2Vulnerable = true;
            }
        }

        // Rule 2: Turn off T3 invulnerability if T2 tower is dead
        if (!m_t3Vulnerable && isT2Dead()) {
            if (m_towerUnitIDs.size() > 0) {
                setUnitInvulnerable(m_towerUnitIDs[0], false);
                m_t3Vulnerable = true;
            }
        }

        // Rule 3: Turn off Barracks invulnerability if T3 tower is dead
        if (!m_barracksVulnerable && isT3Dead()) {
            setUnitInvulnerable(m_barracksUnitID, false);
            m_barracksVulnerable = true;
        }
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
// GLOBAL FORTRESS INVULNERABILITY CHECKER
// ==========================================
void updateTeamFortressInvulnerability(ref LaneManager topLane, ref LaneManager midLane, ref LaneManager botLane, int fortressUnitId = -1) {
    // Turn off fortress invulnerability if any of the T3 towers across its lanes are dead
    if (topLane.isT3Dead() || midLane.isT3Dead() || botLane.isT3Dead()) {
        setUnitInvulnerable(fortressUnitId, false);
    }
}

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
    float rdmOffset = 2.0;
    
    // Base wave units: 2 Hoplites (Index 0), 2 Hippeus (Index 1), 1 Toxotes (Index 2)
    int numHoplites = 2;
    int numHippeus = 2;
    int numToxotes = 1;

    // If opposing barracks is destroyed, increase standard composition for this wave
    if (hasBonusUnits) {
        numHoplites = numHoplites + 1;
        numHippeus = numHippeus + 1;
        numToxotes = numToxotes + 1;
    }

    // Spawn Hoplites (g_waveTypes[0])
    for (int i = 0; i < numHoplites; i++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId = trUnitCreate(g_waveTypes[0], spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId);
    }

    // Spawn Hippeus (g_waveTypes[1])
    for (int j = 0; j < numHippeus; j++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId2 = trUnitCreate(g_waveTypes[1], spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId2);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId2);
    }

    // Spawn Toxotes (g_waveTypes[2])
    for (int k = 0; k < numToxotes; k++) {
        float rdmOffsetX = xsRandFloat(-rdmOffset, rdmOffset);
        float rdmOffsetZ = xsRandFloat(-rdmOffset, rdmOffset);
        int unitId3 = trUnitCreate(g_waveTypes[2], spawnPos.x + offsetX + rdmOffsetX, spawnPos.y, spawnPos.z + offsetZ + rdmOffsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(unitId3);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(unitId3);
    }

    // Hero / Myth Wave check (Every 5 waves or triggered by super bonus)
    if (g_laneCounter % HERO_WAVE == 0 || hasSuperBonus) {
        // Spawns Cyclops (Index 3) and Heracles (Index 4)
        for (int h = 3; h <= 4; h++) {
            int heroId = trUnitCreate(g_waveTypes[h], spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 359), player);
            selectSingle(heroId);
            trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
            laneManager.addUnit(heroId);
        }
    }

    // Super Bonus spawns Colossus (Index 5)
    if (hasSuperBonus) {
        int colossusId = trUnitCreate(g_waveTypes[5], spawnPos.x + offsetX, spawnPos.y, spawnPos.z + offsetZ, xsRandFloat(0.0, 359), player);
        selectSingle(colossusId);
        trUnitMoveToPoint(destPos.x, destPos.y, destPos.z, -1, true);
        laneManager.addUnit(colossusId);
    }
}

// ==========================================
// WAVE EXECUTION & TRIGGER LOOP
// ==========================================
void spawnLane(){
    // Check if opposing barracks are destroyed for each lane using LaneManager's internal states
    bool t1TopBonus = g_T2TopLane.isBarracksDead();
    bool t1MidBonus = g_T2MidLane.isBarracksDead();
    bool t1BotBonus = g_T2BotLane.isBarracksDead();

    bool t2TopBonus = g_T1TopLane.isBarracksDead();
    bool t2MidBonus = g_T1MidLane.isBarracksDead();
    bool t2BotBonus = g_T1BotLane.isBarracksDead();

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

// ==========================================
// INVULNERABILITY SCHEDULERS
// ==========================================
void setupInvulnerabilityTriggers() {
    // 1. Team 1 Top Lane Invulnerability Progression
    scheduler.add(3011, [](int iterations = 1) -> bool {
        g_T1TopLane.updateInvulnerability();
        // Return false to stop looping once T3 and Barracks are vulnerable/dead
        if (g_T1TopLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 2. Team 1 Mid Lane Invulnerability Progression
    scheduler.add(3019, [](int iterations = 1) -> bool {
        g_T1MidLane.updateInvulnerability();
        if (g_T1MidLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 3. Team 1 Bot Lane Invulnerability Progression
    scheduler.add(3023, [](int iterations = 1) -> bool {
        g_T1BotLane.updateInvulnerability();
        if (g_T1BotLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 4. Team 2 Top Lane Invulnerability Progression
    scheduler.add(3037, [](int iterations = 1) -> bool {
        g_T2TopLane.updateInvulnerability();
        if (g_T2TopLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 5. Team 2 Mid Lane Invulnerability Progression
    scheduler.add(3041, [](int iterations = 1) -> bool {
        g_T2MidLane.updateInvulnerability();
        if (g_T2MidLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 6. Team 2 Bot Lane Invulnerability Progression
    scheduler.add(3049, [](int iterations = 1) -> bool {
        g_T2BotLane.updateInvulnerability();
        if (g_T2BotLane.m_barracksVulnerable) {
            return false;
        }
        return true;
    });

    // 7. Team 1 Fortress Invulnerability Check
    scheduler.add(3061, [](int iterations = 1) -> bool {
        updateTeamFortressInvulnerability(g_T1TopLane, g_T1MidLane, g_T1BotLane, g_t1FortressId);
        // If any T3 tower is dead, the fortress drops invulnerability and we can stop checking
        if (g_T1TopLane.isT3Dead() || g_T1MidLane.isT3Dead() || g_T1BotLane.isT3Dead()) {
            return false;
        }
        return true;
    });

    // 8. Team 2 Fortress Invulnerability Check
    scheduler.add(3067, [](int iterations = 1) -> bool {
        updateTeamFortressInvulnerability(g_T2TopLane, g_T2MidLane, g_T2BotLane, g_t2FortressId);
        if (g_T2TopLane.isT3Dead() || g_T2MidLane.isT3Dead() || g_T2BotLane.isT3Dead()) {
            return false;
        }
        return true;
    });
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

    setupInvulnerabilityTriggers();

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