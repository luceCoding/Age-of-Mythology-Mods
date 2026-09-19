bool[] g_isSpawningChain = default;
int[] g_lightningMaxChains = default; // player -> maxChains limit
float[] g_lastLightningTime = default;

bool isValidPlayerIndex(int player = 0){
    return player >= 0 && player <= cNumberPlayers;
}

void createLightningShock(int unitId = -1){
    selectSingle(unitId);
    vector v = kbUnitGetTruePosition(unitId);
    int owner = kbUnitGetPlayerID(unitId);
    if (isValidPlayerIndex(owner) == false) { return; }

    for (int p = 0; p <= cNumberPlayers; p++){
        if (g_finalTeam[owner] == g_finalTeam[p]) { continue; }
        applyToUnitsInArea(v, LIGHTNING_SHOCK_RADIUS, p, cUnitTypeMilitaryUnit, cUnitStateAlive,
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
    if (isValidPlayerIndex(owner) == false) { return -1; }

    for (int targetP = 0; targetP <= cNumberPlayers; targetP++) {
        if (g_finalTeam[owner] == g_finalTeam[targetP]) { continue; }

        for (int attempt = 0; attempt < 3; attempt++) {
            int candidate = getRandomUnitInArea(currentPos, CHAIN_LIGHTNING_SEARCH_RADIUS, targetP, cUnitTypeMilitaryUnit, cUnitStateAlive);
            if (candidate == -1) { break; }

            if (hitUnits.contains(candidate) == false) {
                return candidate;
            }
        }
    }
    return -1;
}

bool applyLightningBounceImpact(int owner = 0, int targetUnitID = -1, ref vector outNewPos) {
    if (isValidPlayerIndex(owner) == false) { return false; }
    g_isSpawningChain[owner] = true;
    
    vector v = kbUnitGetTruePosition(targetUnitID);
    int secondaryID = trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXLightningCS05OP), v.x, v.y, v.z, xsRandInt(0, 359), owner, false);
    scheduleDelete(secondaryID, 5000);

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
    if (isValidPlayerIndex(owner) == false) { return; }

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