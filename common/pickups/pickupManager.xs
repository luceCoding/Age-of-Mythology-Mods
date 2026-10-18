// Universal pickup manager, searched from the picker's perspective.
// 1. registerPicker(unitId, radius, destroyOnPickup, callback) for every unit that can pick things up.
// 2. onPickupCreated(unitId) for every pickup unit that should be collectable (call it as pickups appear).
// 3. process() must be called periodically; each picker is distance-checked (trUnitDistanceToUnitID)
//    against the tracked pickups, and the callback fires with (pickupUnitId, pickerUnitId).
// Dead pickers and pickups are dropped automatically.

// Placeholder redefined after g_PickupManager exists (XS has no forward lookup).
mutable void onPickupCreated(int unitId = -1) { return; }

class PickupManager {

    // Pickers (parallel arrays, swap-pop)
    int m_pickerSize = 0;
    int[] m_pickerUnitIDs = default;
    float[] m_pickerRadius = default;
    bool[] m_pickerDestroy = default;
    void(int, int)[] m_pickerCallback = default;

    // Pickups (swap-pop)
    int m_pickupSize = 0;
    int[] m_pickupUnitIDs = default;

    void addPickup(int unitId = -1) {
        if (unitId < 0) { return; }
        if (m_pickupSize < m_pickupUnitIDs.size()) {
            m_pickupUnitIDs[m_pickupSize] = unitId;
        } else {
            m_pickupUnitIDs.add(unitId);
        }
        m_pickupSize++;
    }

    void registerPicker(int unitId = -1, float radius = 1.0, bool destroyOnPickup = true,
        void(int, int) callback = [](int pickupId = -1, int pickerId = -1) -> void {}) {
        if (unitId < 0) { return; }
        for (int i = 0; i < m_pickerSize; i++) {
            if (m_pickerUnitIDs[i] == unitId) { return; }
        }
        if (m_pickerSize < m_pickerUnitIDs.size()) {
            m_pickerUnitIDs[m_pickerSize] = unitId;
            m_pickerRadius[m_pickerSize] = radius;
            m_pickerDestroy[m_pickerSize] = destroyOnPickup;
            m_pickerCallback[m_pickerSize] = callback;
        } else {
            m_pickerUnitIDs.add(unitId);
            m_pickerRadius.add(radius);
            m_pickerDestroy.add(destroyOnPickup);
            m_pickerCallback.add(callback);
        }
        m_pickerSize++;
    }

    void removePicker(int index = 0) {
        m_pickerSize--;
        if (index < m_pickerSize) {
            m_pickerUnitIDs[index] = m_pickerUnitIDs[m_pickerSize];
            m_pickerRadius[index] = m_pickerRadius[m_pickerSize];
            m_pickerDestroy[index] = m_pickerDestroy[m_pickerSize];
            m_pickerCallback[index] = m_pickerCallback[m_pickerSize];
        }
    }

    void removePickup(int index = 0) {
        m_pickupSize--;
        if (index < m_pickupSize) {
            m_pickupUnitIDs[index] = m_pickupUnitIDs[m_pickupSize];
        }
    }

    void process() {
        for (int i = 0; i < m_pickerSize; i++) {
            int pickerId = m_pickerUnitIDs[i];
            selectSingle(pickerId);
            if (trUnitDead() == true) {
                removePicker(i);
                i--;
                continue;
            }

            float radius = m_pickerRadius[i];
            bool destroyOnPickup = m_pickerDestroy[i];
            void(int, int) callback = m_pickerCallback[i];

            for (int j = 0; j < m_pickupSize; j++) {
                int pickupId = m_pickupUnitIDs[j];
                selectSingle(pickupId);
                if (trUnitDead() == true) {
                    removePickup(j);
                    j--;
                    continue;
                }

                selectSingle(pickerId);
                if (trUnitDistanceToUnitID(pickupId) > radius) { continue; }

                callback(pickupId, pickerId);

                // Removed from tracking immediately so no other picker can claim it in the same pass.
                if (destroyOnPickup) {
                    selectSingle(pickupId);
                    trUnitDestroy();
                }
                removePickup(j);
                j--;
            }
        }
    }
};

PickupManager g_PickupManager;

void onPickupCreated(int unitId = -1) {
    g_PickupManager.addPickup(unitId);
}
