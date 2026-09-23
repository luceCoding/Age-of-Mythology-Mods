class OnCreationListener {

    int m_size = 0;
    void(int)[] m_events = default;
    int[] m_keys = default;
    bool[] m_deleteUnits = default; // Track auto-delete setting per slot
    
    IntToIntHashMap cUnitTypeToIndex;
    IntToIntHashMap cUnitTypeCountMap; // BaseKey -> Registered Lambda Count

    void init() {
        trSetAutoResetRecentUnits(false);
    }

    // Unique base key per (player, cUnitType)
    int makeBaseKey(int p = 0, int cUnitType = -1) {
        return (p * cNumberProtoUnits) + cUnitType;
    }

    // Compound sub-key for each individual lambda slot (supports up to 1000 lambdas per unit type)
    int makeSubKey(int baseKey = 0, int subIndex = 0) {
        return (baseKey * 1000) + subIndex;
    }

    void process() {
        int[] recent = trGetRecentUnits();
        trResetRecentUnits();

        for (int i = 0; i < recent.size(); i++) {
            int unitId = recent[i];
            int p = kbUnitGetPlayerID(unitId);
            int cUnitType = kbUnitGetProtoUnitID(unitId);

            if (cUnitType <= cUnitTypeMoveTo || cUnitType == cUnitTypeAttackRevealer || cUnitType == cUnitTypeCrate || cUnitType == cUnitTypeCrateSmall) { 
                continue; 
            }

            int baseKey = makeBaseKey(p, cUnitType);
            int count = cUnitTypeCountMap.get(baseKey);

            // Execute all lambdas registered for this (p, cUnitType)
            if (count != cMinInt && count > 0) {
                bool shouldDelete = false;

                for (int k = 0; k < count; k++) {
                    int subKey = makeSubKey(baseKey, k);
                    int index = cUnitTypeToIndex.get(subKey);
                    if (index != cMinInt) {
                        void(int) event = m_events[index];
                        event(unitId);

                        if (m_deleteUnits[index]) {
                            shouldDelete = true;
                        }
                    }
                }

                // Delete the unit after running all callbacks
                if (shouldDelete) {
                    selectSingle(unitId);
                    trUnitDestroy();
                }
            }
        }
    }

    // Internal helper for swap-pop removal in 1D arrays
    void _removeSubKeySlot(int subKey = 0) {
        int targetIdx = cUnitTypeToIndex.get(subKey);
        if (targetIdx == cMinInt) { return; }

        int lastIdx = m_size - 1;
        if (targetIdx != lastIdx) {
            int lastKey = m_keys[lastIdx];
            m_events[targetIdx] = m_events[lastIdx];
            m_keys[targetIdx] = lastKey;
            m_deleteUnits[targetIdx] = m_deleteUnits[lastIdx];
            cUnitTypeToIndex.put(lastKey, targetIdx);
        }

        cUnitTypeToIndex.remove(subKey);
        m_size--;

        m_events[m_size] = [](int unitId = -1) -> void {};
        m_keys[m_size] = cMinInt;
        m_deleteUnits[m_size] = false;
    }

    // Automatically assigns subIndex based on current count
    int register(int p = 0, int cUnitType = -1, bool deleteUnit = false, void(int) event = [](int unitId = -1) -> void {}) {
        if (cUnitType == -1) { return -1; }
        
        int baseKey = makeBaseKey(p, cUnitType);
        int count = cUnitTypeCountMap.get(baseKey);
        if (count == cMinInt) { count = 0; }

        int subKey = makeSubKey(baseKey, count);

        // Add to 1D arrays
        if (m_size < m_events.size()) {
            m_events[m_size] = event;
            m_keys[m_size] = subKey;
            m_deleteUnits[m_size] = deleteUnit;
        } else {
            m_events.add(event);
            m_keys.add(subKey);
            m_deleteUnits.add(deleteUnit);
        }

        // Enable KB Tracking flags on first registration
        if (count == 0) {
            string protoName = kbProtoUnitGetName(cUnitType);
            trProtoUnitSetFlag(p, protoName, "NotKBTracked", false);
            trProtoUnitSetFlag(p, protoName, "KBTracked", true);
            trProtoUnitSetFlag(p, protoName, "ForceToNature", false);
        }

        cUnitTypeToIndex.put(subKey, m_size);
        cUnitTypeCountMap.put(baseKey, count + 1);
        m_size++;

        return count; // Returns the subIndex slot assigned
    }

    // Option A: Removes ALL lambdas registered for this (p, cUnitType)
    void deregisterAll(int p = 0, int cUnitType = -1) {
        if (cUnitType == -1) { return; }
        
        int baseKey = makeBaseKey(p, cUnitType);
        int count = cUnitTypeCountMap.get(baseKey);
        if (count == cMinInt || count <= 0) { return; }

        // Remove from back to front to safely swap-pop
        for (int k = count - 1; k >= 0; k--) {
            int subKey = makeSubKey(baseKey, k);
            _removeSubKeySlot(subKey);
        }

        cUnitTypeCountMap.remove(baseKey);
    }

    // Option B: Deregisters a SPECIFIC lambda slot (if passing targetSubIndex)
    void deregister(int p = 0, int cUnitType = -1, int targetSubIndex = -1) {
        if (cUnitType == -1) { return; }
        if (targetSubIndex < 0) {
            deregisterAll(p, cUnitType);
            return;
        }

        int baseKey = makeBaseKey(p, cUnitType);
        int count = cUnitTypeCountMap.get(baseKey);
        if (count == cMinInt || targetSubIndex >= count) { return; }

        int targetSubKey = makeSubKey(baseKey, targetSubIndex);
        _removeSubKeySlot(targetSubKey);

        // If last element was removed, fix the last subKey index mapping
        if (targetSubIndex < count - 1) {
            int lastSubKey = makeSubKey(baseKey, count - 1);
            int targetIdx = cUnitTypeToIndex.get(lastSubKey);
            
            // Relabel last slot to target slot position to preserve linear bounds
            m_keys[targetIdx] = targetSubKey;
            cUnitTypeToIndex.put(targetSubKey, targetIdx);
            cUnitTypeToIndex.remove(lastSubKey);
        }

        if (count - 1 <= 0) {
            cUnitTypeCountMap.remove(baseKey);
        } else {
            cUnitTypeCountMap.put(baseKey, count - 1);
        }
    }
};

OnCreationListener g_OnCreationListener;