void setupHumansPost(){
    for (int p = 1; p < cHumanAIPlayer; p++) {

        if (g_finalTeams[p] != 1) { continue; }

        for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++){
            int buildingType = g_upgradeableHumanBuildings[i];
            if (i <= 4){ // Only Walls
                trProtoUnitSetUnitType(p, kbProtoUnitGetName(buildingType), kbUnitTypeGetName(cUnitTypeLogicalTypeTartarianGateValidOverlapPlacement), true);
            }
            else {
                trProtoUnitSetUnitType(p, kbProtoUnitGetName(buildingType), kbUnitTypeGetName(cUnitTypeLogicalTypeTartarianGateValidOverlapPlacement), false);
            }
        }

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeLightningStrike), "HandAttack", p, cXSActionEffectDamageDivine, 2.0, cXSRelativityBasePercent);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", p, cXSActionEffectDamageCrush, 1000, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", kbUnitTypeGetName(cUnitTypeBuilding), p, cXSActionProtoEffectDamageBonus, 3.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", kbUnitTypeGetName(cDefaultcUnitTypeWall), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", kbUnitTypeGetName(cDefaultcUnitTypeWall2), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", kbUnitTypeGetName(cDefaultcUnitTypeGate), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);
        trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeDivineSlashDamage), "HandAttack", kbUnitTypeGetName(cDefaultcUnitTypeGate2), p, cXSActionProtoEffectDamageBonus, 10.0, cXSRelativityAssign);

        // trPlayerEnableTimeshift(p, true);

        // for (int i = 0; i < g_humanInteractableTypes.size(); i++) {
        //     int interactableType = g_humanInteractableTypes[i];
        //     trModifyProtounitResource(kbProtoUnitGetName(interactableType), "Food", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
        //     trModifyProtounitResource(kbProtoUnitGetName(interactableType), "Wood", p, cXSPUResourceEffectCost, pow(humanBaseWoodCost, 3), cXSRelativityAssign);
        //     trModifyProtounitResource(kbProtoUnitGetName(interactableType), "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
        //     trModifyProtounitResource(kbProtoUnitGetName(interactableType), "Gold", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
        //     trPlayerTimeshiftAddEntry(p, kbProtoUnitGetName(interactableType), 0.5, 0.25);
        // }

        // for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        //     int buildingType = g_upgradeableHumanBuildings[i];
        //     trPlayerTimeshiftAddEntry(p, kbProtoUnitGetName(buildingType), 0.5, 2.0);
        // }
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSmokeTrap), p, cXSProtoEffectHitpoints, 600.0 * 0.25, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSpikeTrap), p, cXSProtoEffectHitpoints, 600.0 * 0.5, cXSRelativityAssign);

        for (int i = 0; i < g_humanT1GodPowers.size(); i++) {
            GodPowerData godPower = g_humanT1GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_humanT2GodPowers.size(); i++) {
            GodPowerData godPower = g_humanT2GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_humanT3GodPowers.size(); i++) {
            GodPowerData godPower = g_humanT3GodPowers[i];
            godPower.redefineGodPower(p);
        }
        for (int i = 0; i < g_humanT4GodPowers.size(); i++) {
            GodPowerData godPower = g_humanT4GodPowers[i];
            godPower.redefineGodPower(p);
        }
        
    }
}

void initializeHumans(){
    if (g_humanUnitTypes.size() == 0) {
        errorLog("Cannot spawn the human players: no human unit types are configured.");
        return;
    }

    int totalHumans = 0;
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (g_finalTeams[p] == 1 && kbPlayerIsHuman(p) == true) {
            totalHumans = totalHumans + 1;
        }
    }

    if (totalHumans == 0) {
        return;
    }

    for (int p = 1; p < cNumberPlayers; p++) {
        if (g_finalTeams[p] != 1 || kbPlayerIsHuman(p) == false) {
            continue;
        }

        trPlayerGrantResources(p, "Wood", cStartingWood);
        trPlayerGrantResources(p, "Gold", cStartingGold);

        int rdmSpawnPointID = xsRandInt(0, g_humanSpawnPoints.size() - 1);
        vector v = kbUnitGetTruePosition(g_humanSpawnPoints[rdmSpawnPointID]);

        int unitType = g_humanUnitTypes[0];
        int unitID = trUnitCreateForced(
            kbProtoUnitGetName(unitType),
            v.x,
            v.y,
            v.z,
            0, p);

        g_humanUnitIDs.add(unitID);
        g_humanUnitCount = g_humanUnitCount + 1;
        if (trCurrentPlayer() == p){
            cameraLookAt(v, 60.0, 45.0, 45.0);
        }

        registerZombieRespawn(p);
    }
}

void disableAttackForHumanBuildings(int p = 0){
    for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++) {
        int buildingType = g_upgradeableHumanBuildings[i];
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "HandAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "RangedAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "LightningAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "BeamAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "MonolithStrike", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "HasLOS", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "Invulnerable", false);
    }
    for (int i = 0; i < g_otherHumanBuildings.size(); i++) {
        int buildingType = g_otherHumanBuildings[i];
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "HandAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "RangedAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "LightningAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "BeamAttack", false);
        trProtoUnitActionSetEnabled(kbProtoUnitGetName(buildingType), p, "MonolithStrike", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "HasLOS", false);
        trProtoUnitSetFlag(p, kbProtoUnitGetName(buildingType), "Invulnerable", false);
    }
}