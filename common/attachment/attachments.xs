void scheduleDelete(int unitId = -1, int timeMs = 0){
    lowFreqSchedulerWithIntInt.add(timeMs, unitId, 0, [](int iteration = 0, int unitId = 0, int _ = 0) -> bool {
        selectSingle(unitId);
        trUnitDestroy();
        return false;
    });
}

// Allows multiple pseudo attachments for attacks using only one universal attachment.
class AttachmentManager {
    int m_size = 0; // Tracks active items without shrinking arrays
    int m_walkAnimationID = -1;
    int m_cUnitTypeAttackAttachment = -1; // Reserve this unit type for attachments ONLY!
    int[] m_attachmentIds = default;
    int[] m_attachmentTargetIds = default;

    void setForAllAttachements(int p = 0, string attachmentName = ""){
        trProtoUnitSetFlag(p, attachmentName, "Invulnerable", true);
        trProtoUnitSetFlag(p, attachmentName, "ForceToNature", false);
        trProtoUnitSetFlag(p, attachmentName, "CollidesWithProjectiles", false);
        trProtoUnitSetFlag(p, attachmentName, "NonAutoFormedUnit", false);
        trProtoUnitSetFlag(p, attachmentName, "StartOnNoUpdate", false);
        trProtoUnitSetFlag(p, attachmentName, "DoNotShowOnMiniMap", true);
        trProtoUnitSetFlag(p, attachmentName, "CorpseDecays", true);
        trProtoUnitSetFlag(p, attachmentName, "NotSelectable", true);
        trProtoUnitSetUnitType(p, attachmentName, "NatureClass", false);
    }

    // DO NOT USE units that don't die with lifespan, cUnitTypePlants are ready to use out of the box for this purpose
    void init(int cUnitTypeAttackAttachment = cUnitTypePlantJapaneseFern){
        m_cUnitTypeAttackAttachment = cUnitTypeAttackAttachment;
        string attachmentName = kbProtoUnitGetName(m_cUnitTypeAttackAttachment);
        for (int p = 0; p <= cNumberPlayers; p++){
            setForAllAttachements(p, attachmentName);
            trProtoUnitSetFlag(p, attachmentName, "OnlyInEditor", true);
            trModifyProtounitData(attachmentName, p, cXSProtoEffectObstructionRadiusX, 0.0, cXSRelativityAssign);
            trModifyProtounitData(attachmentName, p, cXSProtoEffectObstructionRadiusZ, 0.0, cXSRelativityAssign);
        }
    }

    void registerAttachmentOntoProtoUnit(int cUnitTypeProtoUnit = -1, int p = 0, string targetType = "All"){
        applyProtoActionSpecialEffectProtoUnitToTarget(kbProtoUnitGetName(cUnitTypeProtoUnit), p, cOnHitEffectAttach, targetType, kbProtoUnitGetName(m_cUnitTypeAttackAttachment), 1.0, 0.0);
    }

    void addOnHitAttachment(int p = 0, int cUnitTypeAttachment = -1, int eventType = cSpawnEventTypeDead, float chance = -1, float duration = 0.0){
        trProtounitModifySpawnData(kbProtoUnitGetName(m_cUnitTypeAttackAttachment), p, kbProtoUnitGetName(cUnitTypeAttachment), eventType, 1.0, cXSRelativityAbsolute, chance, duration);
        setForAllAttachements(p, kbProtoUnitGetName(cUnitTypeAttachment));
    }

    void removeOnHitAttachment(int p = 0, int cUnitTypeAttachment = -1, int eventType = cSpawnEventTypeDead, float chance = -1, float duration = 0.0){
        trProtounitModifySpawnData(kbProtoUnitGetName(m_cUnitTypeAttackAttachment), p, kbProtoUnitGetName(cUnitTypeAttachment), eventType, -1.0, cXSRelativityAbsolute, chance, duration);
    }

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