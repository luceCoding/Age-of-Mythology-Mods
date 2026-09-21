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

    // Cooldown Guard - Controls ONLY secondary chain bounces
    float currentTime = xsGetTime();
    if ((currentTime - g_lastLightningTime[owner]) < CHAIN_LIGHTNING_COOLDOWN) {
        return; 
    }
    g_lastLightningTime[owner] = currentTime;
    vector currentPos = kbUnitGetTruePosition(unitId);
    int[] enemyPlayers = getPlayersInTeam((g_finalTeam[owner] == 1) ? 2 : 1);
    g_isSpawningChain[owner] = true;
    applyUptoXRandomUnitsInAreaForPlayers(extraChains, currentPos, CHAIN_LIGHTNING_SEARCH_RADIUS, enemyPlayers, cUnitTypeMilitaryUnit, cUnitStateAlive, 
        [](int unitID = -1) -> void {
            createLightningShock(unitID);
            vector v = kbUnitGetTruePosition(unitID);
            int secondaryID = trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXLightningCS05OP), v.x, v.y, v.z, xsRandInt(0, 359), 0, false);
            scheduleDelete(secondaryID, 3000);
        }
    );
    g_isSpawningChain[owner] = false;
}