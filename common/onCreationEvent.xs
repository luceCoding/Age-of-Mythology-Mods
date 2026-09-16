class OnCreationEventManager {

    int m_size = 0;
    void(int)[] m_events = default;
    int[] m_keys = default;
    IntToIntHashMap cUnitTypeToIndex;

    void init() {
        trSetAutoResetRecentUnits(false);
    }

    int makeKey(int p = 0, int cUnitType = -1) {
        int typeId = (cUnitType == -1) ? cNumberProtoUnits : cUnitType;
        return (p * (cNumberProtoUnits + 1)) + typeId;
    }

    void process() {
        int[] recent = trGetRecentUnits();
        trResetRecentUnits();

        for (int i = 0; i < recent.size(); i++) {
            int unitId = recent[i];
            int p = kbUnitGetPlayerID(unitId);
            int cUnitType = kbUnitGetProtoUnitID(unitId);

            if (cUnitType <= cUnitTypeMoveTo || cUnitType == cUnitTypeAttackRevealer || cUnitType == cUnitTypeCrate || cUnitType == cUnitTypeCrateSmall){ continue; }

            int key = makeKey(p, cUnitType);
            int index = cUnitTypeToIndex.get(key);
            if (index != cMinInt) {
                void(int) event = m_events[index];
                event(unitId);
            }

            int wildcardKey = makeKey(p, -1);
            int wildcardIndex = cUnitTypeToIndex.get(wildcardKey);
            if (wildcardIndex != cMinInt) {
                void(int) wildcardEvent = m_events[wildcardIndex];
                wildcardEvent(unitId);
            }
        }
    }

    void register(int p = 0, int cUnitType = -1, void(int) event = [](int unitId = -1) -> void {}) {
        int key = makeKey(p, cUnitType);
        int existingIdx = cUnitTypeToIndex.get(key);
        if (existingIdx != cMinInt) {
            m_events[existingIdx] = event;
            return;
        }

        if (m_size < m_events.size()) {
            m_events[m_size] = event;
            m_keys[m_size] = key;
        } else {
            m_events.add(event);
            m_keys.add(key);
        }

        if (cUnitType != -1) {
            string protoName = kbProtoUnitGetName(cUnitType);
            trProtoUnitSetFlag(p, protoName, "NotKBTracked", false);
            trProtoUnitSetFlag(p, protoName, "KBTracked", true);
        }

        cUnitTypeToIndex.put(key, m_size);
        m_size++;
    }

    void deregister(int p = 0, int cUnitType = -1) {
        int key = makeKey(p, cUnitType);

        int targetIdx = cUnitTypeToIndex.get(key);
        if (targetIdx == cMinInt) { return; }

        int lastIdx = m_size - 1;
        if (targetIdx != lastIdx) {
            int lastKey = m_keys[lastIdx];
            m_events[targetIdx] = m_events[lastIdx];
            m_keys[targetIdx] = lastKey;
            cUnitTypeToIndex.put(lastKey, targetIdx);
        }

        cUnitTypeToIndex.remove(key);
        m_size--;

        m_events[m_size] = [](int unitId = -1) -> void {};
        m_keys[m_size] = cMinInt;

        //if (cUnitType != -1) {
        //    string protoName = kbProtoUnitGetName(cUnitType);
        //    trProtoUnitSetFlag(p, protoName, "KBTracked", false);
        //    trProtoUnitSetFlag(p, protoName, "NotKBTracked", true);
        //}
    }
};

OnCreationEventManager g_OnCreationEventManager;