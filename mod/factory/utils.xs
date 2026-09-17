bool[] g_isSpawningChain = default;
int[] g_lightningMaxChains = default; // player -> maxChains limit
float[] g_lastLightningTime = default;

void createLightningShock(int unitId = -1){
    selectSingle(unitId);
    vector v = kbUnitGetTruePosition(unitId);
    int owner = kbUnitGetPlayerID(unitId);
    for (int p = 0; p <= cNumberPlayers; p++){
        if (g_finalTeam[owner] == g_finalTeam[p]) { continue; }
        applyToUnitsInArea(v, 1, p, cUnitTypeMilitaryUnit, cUnitStateAlive,
            [](int unitID = -1) -> void {
                selectSingle(unitID);
                trUnitApplyEffect(cOnHitEffectStun, LIGHTNING_STUN_DURATION);
                // Armor debuff application
                trUnitAddModifier(cModifyTypeArmorSpecific, cXSDamageTypeHack, 0.8, LIGHTNING_STUN_DURATION);
                trUnitAddModifier(cModifyTypeArmorSpecific, cXSDamageTypePierce, 0.8, LIGHTNING_STUN_DURATION);
                trUnitAddModifier(cModifyTypeArmorSpecific, cXSDamageTypeCrush, 0.25, LIGHTNING_STUN_DURATION);
            }
        );
    }
}

int findNextLightningTarget(int owner = 0, ref vector currentPos, ref IntSet hitUnits) {
    for (int targetP = 0; targetP <= cNumberPlayers; targetP++) {
        if (g_finalTeam[owner] == g_finalTeam[targetP]) { continue; }

        for (int attempt = 0; attempt < 3; attempt++) {
            int candidate = getRandomUnitInArea(currentPos, 20.0, targetP, cUnitTypeMilitaryUnit, cUnitStateAlive);
            if (candidate == -1) { break; }

            if (hitUnits.contains(candidate) == false) {
                return candidate;
            }
        }
    }
    return -1;
}

bool applyLightningBounceImpact(int owner = 0, int targetUnitID = -1, ref vector outNewPos) {
    g_isSpawningChain[owner] = true;
    
    vector v = kbUnitGetTruePosition(targetUnitID);
    int secondaryID = trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXLightningWeaponsUnitImpact), v.x, v.y, v.z, xsRandInt(0, 359), owner, false);
    scheduleDelete(secondaryID, 5.0);

    createLightningShock(secondaryID);

    g_isSpawningChain[owner] = false;

    if (secondaryID != -1) {
        outNewPos = v;
        return true;
    }
    return false;
}

void handleLightningOnCreation(int unitId = -1) {
    int owner = kbUnitGetPlayerID(unitId);

    // Reentrancy Guard
    if (g_isSpawningChain[owner]) { return; }

    // Always fire primary shock on unit creation
    createLightningShock(unitId);
    playUnitSound(unitId, "LightningStrike", SOUND_SET);

    int extraChains = g_lightningMaxChains[owner] - 1;
    if (extraChains <= 0) { return; }

    // Cooldown Guard (10s ICD) - Controls ONLY secondary chain bounces
    float currentTime = xsGetTime();
    if ((currentTime - g_lastLightningTime[owner]) < CHAIN_LIGHTNING_COOLDOWN) {
        return; 
    }
    g_lastLightningTime[owner] = currentTime;

    // Hit tracking for current chain sequence using IntSet
    IntSet hitUnits;
    hitUnits.add(unitId);
    vector currentPos = kbUnitGetTruePosition(unitId);

    // Chain bounce loop
    for (int ch = 0; ch < extraChains; ch++) {
        int targetUnitID = findNextLightningTarget(owner, currentPos, hitUnits);
        if (targetUnitID == -1) { break; } // No un-hit targets in range

        hitUnits.add(targetUnitID);

        vector nextPos = cInvalidVector;
        if (applyLightningBounceImpact(owner, targetUnitID, nextPos) == true) {
            currentPos = nextPos;
        } else {
            break;
        }
    }
}