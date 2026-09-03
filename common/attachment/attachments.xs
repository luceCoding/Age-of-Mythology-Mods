void scheduleDelete(int unitId = -1, int timeMs = 0){
    unitScheduler.add(unitId, timeMs, [](int unitId = 0, int iteration = 0) -> bool {
        trUnitDestroy();
        return false;
    });
}

class AttachmentManager {
    int m_size = 0; // Tracks active items without shrinking arrays
    int m_walkAnimationID = -1;
    int[] m_attachmentIds = default;
    int[] m_attachmentTargetIds = default;

    void add(int attachmentId = -1, int targetId = -1) {
        if (m_walkAnimationID == -1){
            m_walkAnimationID = kbGetAnimationID("Walk");
        }
        // Reuse existing slots if we have unallocated/freed capacity
        if (m_size < m_attachmentIds.size()) {
            m_attachmentIds[m_size] = attachmentId;
            m_attachmentTargetIds[m_size] = targetId;
        } else {
            // Otherwise grow the array if we've hit peak capacity
            m_attachmentIds.add(attachmentId);
            m_attachmentTargetIds.add(targetId);
        }
        m_size++;
    }

    bool remove(int index = -1) {
        if (index < 0 || index >= m_size) return false;

        m_size--; // Reduce active count

        // If we didn't remove the very last active element, swap the last active one into this slot
        if (index < m_size) {
            m_attachmentIds[index] = m_attachmentIds[m_size];
            m_attachmentTargetIds[index] = m_attachmentTargetIds[m_size];
        }

        return true;
    }

    void process() {
        // Only loop through active elements up to m_size
        for (int i = 0; i < m_size; i++) {
            int attachmentTargetId = m_attachmentTargetIds[i];
            int attachmentId = m_attachmentIds[i];
            
            selectSingle(attachmentTargetId);
            if (trUnitDead()) {
                selectSingle(attachmentId);
                trUnitDestroy();
                remove(i);
                i--; // Step back to evaluate the swapped-in element
                continue;
            } 
            else {
                selectSingle(attachmentId);
                if (trUnitDead()){
                    remove(i);
                    i--; // Step back to evaluate the swapped-in element
                    continue;
                }
                else if (kbUnitGetCurAnimationID(attachmentTargetId) == m_walkAnimationID){
                    vector targetLoc = trUnitGetPosition(attachmentTargetId);
                    trUnitReposition(targetLoc.x, targetLoc.y, targetLoc.z, false, true);
                }
            }
        }
    }
};

AttachmentManager g_AttachmentManager;

int attachTempUnit(int unitID = 0, int cAttachmentUnitType = 0, int durationMs = 0, int heading = cMaxInt, int p = 0, bool skipBirth = false){
    selectSingle(unitID);
    vector v = trUnitGetPosition(unitID);
    int attachmentID = trUnitCreateForced(kbProtoUnitGetName(cAttachmentUnitType), v.x, v.y, v.z, (heading == cMaxInt) ? xsRandInt(0, 359) : heading, p, skipBirth);
    scheduleDelete(attachmentID, durationMs);
    g_AttachmentManager.add(attachmentID, unitID);
    return attachmentID;
}