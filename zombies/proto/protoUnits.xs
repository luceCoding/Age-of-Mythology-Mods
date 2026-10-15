void initializeBuildingForGarrison(int p = 0, int cUnitTypeBuildingType = -1){
    string building = kbProtoUnitGetName(cUnitTypeBuildingType);
    trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
    trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
    trProtoUnitSetFlag(p, building, "HideGarrisonFlag", true);
    trModifyProtounitData(building, p, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
    trModifyProtounitData(building, p, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
    trProtoUnitSetFlag(p, building, "HasLOS", false);
    trProtoUnitSetFlag(p, building, "KnockoutDeath", true);
    trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
    trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
    trProtoUnitSetFlag(p, building, "PrayableTo", false);
    trModifyProtounitUnitType(building, "LogicalTypePickable", p, cXSPUUnitTypeEffectAddContainType, 0.0, cXSRelativityAssign);
    trModifyProtounitUnitType(building, "Unit", p, cXSPUUnitTypeEffectAddContainType, 1.0, cXSRelativityAssign);
    trModifyProtounitData(building, p, cXSProtoEffectMaxContained, 1.0, cXSRelativityAssign);
}

void preModifyPlayerData(){

    // All players
    for(int p = 0; p <= cNumberPlayers; p++) {
        for (int cUnitType = 0; cUnitType < cNumberProtoUnits; cUnitType++) {
            string protoName = kbProtoUnitGetName(cUnitType);
            trForbidProtounit(p, protoName);
            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitData(protoName, p, cXSProtoEffectBuildLimit, -1, cXSRelativityAssign);
        }

        for (int cTech = 0; cTech < cNumberTechs; cTech++) {
            trTechSetStatus(p, cTech, cTechStatusUnobtainable);
        }

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperWeapons);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperArmor);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperShields);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechBallistics);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechBurningPitch);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeTemple), cTechOmniscience);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSiegeWorks), cTechDraftHorses);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSiegeWorks), cTechEngineers);

        g_OnCreationListener.register(p, cUnitTypeTonalli, true, [](int unitId = -1) -> void {});
    }

    // All real players
    for (int p = 1; p <= cNumberPlayers; p++){

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechSignalFires);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechCrenellations);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechBoilingOil);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechGuardTower);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeWallShort), cTechStoneWall);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeWallMedium), cTechStoneWall);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeWallLong), cTechStoneWall);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeWallConnector), cTechStoneWall);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeWallGate), cTechStoneWall);

        trPlayerAllowBonusUnitSpawning(p, false);
        trPlayerEnableCombatXP(p, false);
        trPlayerAllowShades(p, false);
        trPlayerAllowStartingUnitsSpawning(p, false);
        trPlayerEnableTimeshift(p, false);
        trPlayerEnablePartisans(p, false);
        trPlayerEnableBuildingChain(p, false);
        trPlayerKillAllGodPowers(p);

        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSentryTower));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWallShort));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWallMedium));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWallLong));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWallConnector));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeWallGate));

        trTechSetStatus(p, cTechWatchTower, cTechStatusActive);

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMinion), p, cXSProtoEffectLifespan, cMaxFloat, cXSRelativityAssign);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallConnector), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallConnector), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallGate), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallGate), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallShort), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallShort), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallMedium), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallMedium), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallLong), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeWallLong), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);

        g_OnCreationListener.register(p, cUnitTypeWallLong, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                lowFreqSchedulerWithIntInt.add(500, unitId, 0, [](int iteration = 0, int unitId = 0, int _ = 0) -> bool {
                    selectSingle(unitId);
                    if (trUnitDead()){
                        return false;
                    }
                    if (trUnitPercentComplete() >= 100){
                        trUnitChangeProtoUnit(kbProtoUnitGetName(cUnitTypeWallGate));
                        return false;
                    }
                    return true;
                });
            }
        );

        // LOS
        for (int i = 0; i < g_humanUnitTypes.size(); i++){
            int unitType = g_humanUnitTypes[i];
            trModifyProtounitData(kbProtoUnitGetName(unitType), p, cXSProtoEffectLOS, cBaseHumanLOS, cXSRelativityAssign);
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(unitType), p, "Pickup", true);
        }

        // Buildings
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectLOS, cBaseHumanLOS, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectBuildPoints, 20.0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeSentryTower), "RangedAttack", p, cXSActionEffectMinRange, 0.0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeSentryTower), "RangedAttack", p, cXSActionEffectRange, cBaseHumanLOS, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSentryTower), "Gold", p, cXSPUResourceEffectKillReward, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSentryTower), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWallShort), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWallMedium), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWallLong), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWallConnector), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeWallGate), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
    }

    setPickups();

    // Human AI Only
    for (int i = 0; i < g_humanInteractableTypes.size(); i++){
        int interactableType = g_humanInteractableTypes[i];
        if (interactableType == cUnitTypeToriiGate) continue;
        g_OnCreationListener.register(cHumanAIPlayer, interactableType, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                trUnitSetScale(0.5, 0.5, 0.5);
                g_humanInteractableObjects.add(unitId);
            }
        );
        initializeBuildingForGarrison(cHumanAIPlayer, interactableType);
    }

    trProtoUnitSetFlag(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "HasLOS", false);
    trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "LogicalTypePickable", cHumanAIPlayer, cXSPUUnitTypeEffectAddContainType, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeOsirisPieceBox), cHumanAIPlayer, cXSProtoEffectMaxContained, 1.0, cXSRelativityAssign);
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "AbstractTemple", true);

    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallJail), cHumanAIPlayer, cXSProtoEffectHitpoints, 5000, cXSRelativityAssign);

    // Gaia Only
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeTaproot), 0, cXSProtoEffectHitpoints, 10, cXSRelativityAssign);

    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusX, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectArmorCrush, 0.25, cXSRelativityAssign);
    g_OnCreationListener.register(0, cDefaultcUnitTypeWall, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
            trUnitSetShading(cShaderBurning, xsRandFloat(75.0, 100.0));
        }
    );

    g_OnCreationListener.register(0, cUnitTypeYanFeifengTomb, false, [](int unitId = -1) -> void {
            vector v = kbUnitGetTruePosition(unitId);
            g_bspZombieSpawnLocation = v;
            g_bspHumanSpawnLocation = v;
        }
    );

    g_OnCreationListener.register(0, cUnitTypeObeliskProp, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetVariation(0);
            vector v = kbUnitGetTruePosition(unitId);
            int nJars = xsRandInt(1, 3);
            for (int i = 0; i < nJars; i++){
                float jitterX = xsRandFloat(1, 3.0);
                float jitterZ = xsRandFloat(1, 3.0);
                trUnitCreate(kbProtoUnitGetName(cUnitTypeCanopicJars), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
            }
        }
    );

    g_OnCreationListener.register(0, cUnitTypeOsirisPieceBox, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitConvert(cHumanAIPlayer);
            trUnitChangeName("Treasure Chest");
            vector v = kbUnitGetTruePosition(unitId);
            int nJars = xsRandInt(0, 3);
            for (int i = 0; i < nJars; i++){
                float jitterX = xsRandFloat(1, 3.0);
                float jitterZ = xsRandFloat(1, 3.0);
                trUnitCreate(kbProtoUnitGetName(cUnitTypeCanopicJars), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
            }
            if (xsRandInt(0, 3) == 0) { trUnitSetHeading(xsRandInt(0, 30)); }
            if (xsRandInt(0, 5) == 0) { trUnitDestroy(); }
        }
    );

    g_OnCreationListener.register(0, cUnitTypeCocoon, false, [](int unitId = -1) -> void {
            vector v = kbUnitGetTruePosition(unitId);
            float jitterMax = 3.0;
            int maxNumberOfSpiders = xsRandInt(1, 3);
            for (int i = 0; i < maxNumberOfSpiders; i++){
                float jitterX = xsRandFloat(0, jitterMax);
                float jitterZ = xsRandFloat(0, jitterMax);
                trUnitCreate(kbProtoUnitGetName(cUnitTypeSpiderEgg), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
            }
        }
    );

    // Placeholder decorations
    g_OnCreationListener.register(0, cUnitTypeCinematicBlockArea, true, [](int unitId = -1) -> void {
            vector v = kbUnitGetTruePosition(unitId);
            float jitterMax = 3.0;
            float jitterX = xsRandFloat(0, jitterMax);
            float jitterZ = xsRandFloat(0, jitterMax);
            int unitType = g_placeHolderUnitTypes[xsRandInt(0, g_placeHolderUnitTypes.size()-1)];
            trUnitCreate(kbProtoUnitGetName(unitType), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
        }
    );

    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeQiLin), "OnlyInEditor", true);
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeQiLin), "Immoveable", true);
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeQiLin), "Collideable", false);
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeQiLin), "CollidesWithProjectiles", false);
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeQiLin), "ShowOnMiniMap", false);
    trProtoUnitActionSetEnabled(kbProtoUnitGetName(cUnitTypeQiLin), 0, "HandAttack", false);
    trProtoUnitActionSetEnabled(kbProtoUnitGetName(cUnitTypeQiLin), 0, "AreaHeal", false);
    trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeQiLin), "ChargedRangedAttack", 0, cXSActionEffectRange, 2.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType(kbProtoUnitGetName(cUnitTypeQiLin), "ChargedRangedAttack", kbUnitTypeGetName(cUnitTypeHero), 0, cXSActionProtoEffectDamageBonus, 2.0, cXSRelativityAssign);
    g_OnCreationListener.register(0, cUnitTypeStatueChimera, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            int heading = trUnitGetHeading();
            float headingRadians = heading * cPi / 180.0;
            vector v = kbUnitGetTruePosition(unitId);
            float forwardX = sin(headingRadians) * -1.0;
            float forwardZ = cos(headingRadians) * -1.0;
            int createdUnitID = trUnitCreateForced(
                kbProtoUnitGetName(cUnitTypeQiLin),
                v.x + forwardX, v.y, v.z + forwardZ, heading, 0, true);
            selectSingle(createdUnitID);
            trUnitSetHeading(heading);
            trUnitMakeInvulnerable(true);
        }
    );

    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall2), 0, cXSProtoEffectObstructionRadiusX, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall2), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall2), 0, cXSProtoEffectArmorCrush, 0.25, cXSRelativityAssign);
    g_OnCreationListener.register(0, cDefaultcUnitTypeWall2, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.0, 0.8, 1.0);
            trUnitSetShading(cShaderBurning, xsRandFloat(50.0, 100.0));
        }
    );

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusX, 4, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    trTechSetStatus(0, cTechStoneWall, cTechStatusActive);
}

void postModifyPlayerData(){

    int nHumans = 0;
    for (int p = 1; p <= cNumberPlayers; p++){
        if (g_finalTeams[p] == 1) {
            nHumans += 1;
            trTechSetStatus(p, cTechRelicFeatherOfJingwei, cTechStatusActive);
        }
        int food = kbGetResourceAmount(p, kbGetResourceID("Food"));
        int wood = kbGetResourceAmount(p, kbGetResourceID("Wood"));
        int gold = kbGetResourceAmount(p, kbGetResourceID("Gold"));
        int favor = kbGetResourceAmount(p, kbGetResourceID("Favor"));
        trPlayerGrantResources(p, "Food", -food);
        trPlayerGrantResources(p, "Wood", -wood);
        trPlayerGrantResources(p, "Gold", -gold);
        trPlayerGrantResources(p, "Favor", -favor);
        trPlayerGrantResources(p, "Wood", cStartingWood);
        trPlayerGrantResources(p, "Gold", cStartingGold);
    }
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * nHumans, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall2), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * nHumans, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeGate), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * nHumans, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeGate2), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * nHumans, cXSRelativityAssign);
}