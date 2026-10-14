// Universal pickup manager.
// register(...) a pickup unit type; any unit created of that type (and owner) is tracked.
// process() must be called periodically; when a unit of pickerType owned by pickerPlayer
// is within `radius` of a tracked pickup, the callback fires with (pickupUnitId, pickerPlayer).
// Placeholder redefined after g_PickupManager exists (XS has no forward lookup).
mutable void onPickupCreated(int unitId = -1) { return; }

class PickupManager {

    // Rules (parallel arrays, slot index == rule id; removed rules are tombstoned)
    int m_ruleSize = 0;
    int[] m_ruleOwner = default;
    int[] m_rulePickupType = default;
    int[] m_rulePickerPlayer = default; // -1 = any player except the pickup's owner
    int[] m_rulePickerType = default;
    float[] m_ruleRadius = default;
    bool[] m_ruleDestroy = default;
    bool[] m_ruleActive = default;
    void(int, int)[] m_ruleCallback = default;

    // Tracked pickup units (swap-pop)
    int m_trackedSize = 0;
    int[] m_trackedUnitIDs = default;

    // Each pickup unit is tracked once; its rules are looked up by (owner, type) when processed.
    void onCreated(int unitId = -1) {
        if (m_trackedSize < m_trackedUnitIDs.size()) {
            m_trackedUnitIDs[m_trackedSize] = unitId;
        } else {
            m_trackedUnitIDs.add(unitId);
        }
        m_trackedSize++;
    }

    // Returns the rule id (use with deregister).
    int register(int owner = 0, int pickupType = -1, int pickerPlayer = -1, int pickerType = -1, float radius = 1.0,
        bool destroyOnPickup = true, void(int, int) callback = [](int unitId = -1, int picker = 0) -> void {}) {
        if (pickupType == -1 || pickerType == -1) { return -1; }

        trProtoUnitSetFlag(0, kbProtoUnitGetName(pickupType), "KBTracked", true);
        trProtoUnitSetFlag(0, kbProtoUnitGetName(pickupType), "ForceToNature", false);

        int id = m_ruleSize;
        if (id < m_ruleOwner.size()) {
            m_ruleOwner[id] = owner;
            m_rulePickupType[id] = pickupType;
            m_rulePickerPlayer[id] = pickerPlayer;
            m_rulePickerType[id] = pickerType;
            m_ruleRadius[id] = radius;
            m_ruleDestroy[id] = destroyOnPickup;
            m_ruleActive[id] = true;
            m_ruleCallback[id] = callback;
        } else {
            m_ruleOwner.add(owner);
            m_rulePickupType.add(pickupType);
            m_rulePickerPlayer.add(pickerPlayer);
            m_rulePickerType.add(pickerType);
            m_ruleRadius.add(radius);
            m_ruleDestroy.add(destroyOnPickup);
            m_ruleActive.add(true);
            m_ruleCallback.add(callback);
        }
        m_ruleSize++;

        // Hook creation once per (owner, pickupType); onCreated() handles every matching rule.
        bool hooked = false;
        for (int r = 0; r < id; r++) {
            if (m_ruleOwner[r] == owner && m_rulePickupType[r] == pickupType) { hooked = true; break; }
        }
        if (hooked == false) {
            g_OnCreationListener.register(owner, pickupType, false, [](int unitId = -1) -> void {
                onPickupCreated(unitId);
            });
        }
        return id;
    }

    // Stops tracking for this rule (already-tracked units are dropped on next process()).
    void deregister(int ruleId = -1) {
        if (ruleId < 0 || ruleId >= m_ruleSize) { return; }
        m_ruleActive[ruleId] = false;
    }

    void removeTracked(int index = 0) {
        m_trackedSize--;
        if (index < m_trackedSize) {
            m_trackedUnitIDs[index] = m_trackedUnitIDs[m_trackedSize];
        }
    }

    void process() {
        for (int i = 0; i < m_trackedSize; i++) {
            int unitId = m_trackedUnitIDs[i];
            selectSingle(unitId);
            if (trUnitDead() == true) {
                removeTracked(i);
                i--;
                continue;
            }

            int owner = kbUnitGetPlayerID(unitId);
            int pickupType = kbUnitGetProtoUnitID(unitId);
            bool destroyed = false;
            bool anyActive = false;

            for (int r = 0; r < m_ruleSize; r++) {
                if (m_ruleActive[r] == false || m_ruleOwner[r] != owner || m_rulePickupType[r] != pickupType) { continue; }
                anyActive = true;

                string pickerName = kbUnitTypeGetName(m_rulePickerType[r]);
                int firstP = m_rulePickerPlayer[r];
                int lastP = m_rulePickerPlayer[r];
                if (firstP == -1) {
                    firstP = 1;
                    lastP = cNumberPlayers - 2;
                }

                for (int p = firstP; p <= lastP; p++) {
                    if (m_rulePickerPlayer[r] == -1 && p == owner) { continue; }
                    if (kbUnitTypeCountInArea(pickerName, p, cUnitStateAlive, unitId, m_ruleRadius[r]) < 1) { continue; }

                    void(int, int) callback = m_ruleCallback[r];
                    callback(unitId, p);
                    if (m_ruleDestroy[r]) { destroyed = true; }
                    break;
                }

                // First rule that consumes the pickup claims it; remaining rules are skipped.
                if (destroyed) { break; }
            }

            if (destroyed) {
                selectSingle(unitId);
                trUnitDestroy();
            }
            if (destroyed || anyActive == false) {
                removeTracked(i);
                i--;
            }
        }
    }
};

PickupManager g_PickupManager;

void onPickupCreated(int unitId = -1) {
    g_PickupManager.onCreated(unitId);
}
