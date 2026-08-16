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