void scheduleDelete(int unitId = -1, int timeMs = 0){
    lowFreqSchedulerWithIntInt.add(timeMs, unitId, 0, [](int iteration = 0, int unitId = 0, int _ = 0) -> bool {
        selectSingle(unitId);
        trUnitDestroy();
        return false;
    });
}

// Allows multiple pseudo attachments for attacks using only one universal attachment.
class AttachmentManager {
    int m_cUnitTypeAttackAttachment = -1; // Reserve this unit type for attachments ONLY!

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
        applyProtoActionSpecialEffectProtoUnitToTarget(kbProtoUnitGetName(cUnitTypeProtoUnit), p, cOnHitEffectAttach, targetType, m_cUnitTypeAttackAttachment, 1.0, 0.0);
    }

    void addOnHitAttachment(int p = 0, int cUnitTypeAttachment = -1, int eventType = cSpawnEventTypeDead, float chance = -1, float duration = 0.0){
        trProtounitModifySpawnData(kbProtoUnitGetName(m_cUnitTypeAttackAttachment), p, kbProtoUnitGetName(cUnitTypeAttachment), eventType, 1.0, cXSRelativityAbsolute, chance, duration);
        setForAllAttachements(p, kbProtoUnitGetName(cUnitTypeAttachment));
    }

    void removeOnHitAttachment(int p = 0, int cUnitTypeAttachment = -1, int eventType = cSpawnEventTypeDead, float chance = -1, float duration = 0.0){
        trProtounitModifySpawnData(kbProtoUnitGetName(m_cUnitTypeAttackAttachment), p, kbProtoUnitGetName(cUnitTypeAttachment), eventType, -1.0, cXSRelativityAbsolute, chance, duration);
    }

};

AttachmentManager g_AttachmentManager;

void attachTempUnit(int unitID = 0, int cAttachmentUnitType = 0, int durationMs = 0, int p = 0){
    selectSingle(unitID);
    trUnitApplyEffectProtoUnit(cOnHitEffectAttach, durationMs / 1000.0, p, kbProtoUnitGetName(cAttachmentUnitType));
}