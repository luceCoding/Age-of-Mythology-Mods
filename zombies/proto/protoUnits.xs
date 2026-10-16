void initializeBuildingForGarrison(int p = 0, int cUnitTypeBuildingType = -1){
    string building = kbProtoUnitGetName(cUnitTypeBuildingType);

    if (p == cHumanAIPlayer){
        trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
        trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
        trProtoUnitSetFlag(p, building, "HideGarrisonFlag", true);
        trProtoUnitSetFlag(p, building, "HasLOS", false);
        //trProtoUnitSetFlag(p, building, "KnockoutDeath", true);
        trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
        trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
        trProtoUnitSetFlag(p, building, "PrayableTo", false);
        trModifyProtounitUnitType(building, "LogicalTypePickable", p, cXSPUUnitTypeEffectAddContainType, 0.0, cXSRelativityAssign);
        trModifyProtounitUnitType(building, "Unit", p, cXSPUUnitTypeEffectAddContainType, 1.0, cXSRelativityAssign);
        trModifyProtounitData(building, p, cXSProtoEffectMaxContained, 1.0, cXSRelativityAssign);
    }
    trModifyProtounitData(building, p, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
    trModifyProtounitData(building, p, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
    trProtounitRemoveCommand(building, p, "Delete");
    trProtounitRemoveCommand(building, p, "Eject");
    trProtounitRemoveCommand(building, p, "SetGatherPoint");
    trProtounitRemoveCommand(building, p, "FlareAtUnit");
    trProtounitRemoveCommand(building, p, "SetVillagerToGather");
    trModifyProtounitResource(building, "Gold", p, cXSPUResourceEffectKillReward, 10, cXSRelativityAssign);
}

void preModifyPlayerData(){

    // All players
    for(int p = 0; p <= cNumberPlayers; p++) {
        for (int cUnitType = 0; cUnitType < cNumberProtoUnits; cUnitType++) {
            string protoName = kbProtoUnitGetName(cUnitType);
            trForbidProtounit(p, protoName);
            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectKillReward, -1, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectKillReward, -1, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectKillReward, -1, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectKillReward, -1, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
            trModifyProtounitData(protoName, p, cXSProtoEffectBuildLimit, -1, cXSRelativityAssign);

            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
            trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
        }

        for (int cTech = 0; cTech < cNumberTechs; cTech++) {
            trTechSetStatus(p, cTech, cTechStatusUnobtainable);
        }

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperWeapons);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperArmor);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechCopperShields);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechBallistics);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechBurningPitch);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechFlintWeapons);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechFeatheredArmor);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeArmory), cTechFeatheredShields);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeEconomicGuild), cTechPlow);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeEconomicGuild), cTechHuntingEquipment);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeTemple), cTechOmniscience);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSiegeWorks), cTechDraftHorses);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSiegeWorks), cTechEngineers);

        g_OnCreationListener.register(p, cUnitTypeTonalli, true, [](int unitId = -1) -> void {});

        for (int i = 0; i < g_humanInteractableTypes.size(); i++){
            //if (interactableType == cUnitTypeToriiGate) continue;
            initializeBuildingForGarrison(p, g_humanInteractableTypes[i]);
        }

    }

    // All real players
    for (int p = 1; p <= cNumberPlayers-1; p++){

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeObelisk), cTechSignalFires);

        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechSignalFires);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechCrenellations);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechBoilingOil);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechGuardTower);
        trTechRemove(p, kbProtoUnitGetName(cUnitTypeSentryTower), cTechTemiminaloyanTrials);

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
        trTechSetStatus(p, cTechTzompantliWatchTower, cTechStatusActive);

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

        for (int i = 0; i < g_humanUnitTypes.size(); i++){
            int unitType = g_humanUnitTypes[i];
            trProtoUnitActionSetEnabled(kbProtoUnitGetName(unitType), p, "Pickup", true);
            trModifyProtounitData(kbProtoUnitGetName(unitType), p, cXSProtoEffectLOS, cBaseHumanLOS, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(unitType), p, cXSProtoEffectHitpoints, 2.0, cXSRelativityPercent);

            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeSmokeTrap), 0, 0);
            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeSpikeTrap), 0, 1);
            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeSkyPassage), 0, 2);
            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeObelisk), 0, 5);

            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeRockGiant), 1, 0);
            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeStatueOfLightning), 2, 3);
            trProtounitAddTrain(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), 2, 4);
            trProtounitModifySpawnData(kbProtoUnitGetName(unitType), p, kbProtoUnitGetName(cUnitTypeSkeleton), 0, 1.0, cXSRelativityAssign, -1, -1);
            trProtoUnitSetIcon(kbProtoUnitGetName(unitType), p, "", "ui\minimap\minimap_hero_spc");
            trProtoUnitSetFlag(p, kbProtoUnitGetName(unitType), "Deleteable", false);
        }

        for (int i = 0; i < g_upgradeableHumanBuildings.size(); i++){
            int unitType = g_upgradeableHumanBuildings[i];
            trModifyProtounitResource(kbProtoUnitGetName(unitType), "Wood", p, cXSPUResourceEffectKillReward, 1, cXSRelativityAssign);
            trModifyProtounitResource(kbProtoUnitGetName(unitType), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(unitType), p, cXSProtoEffectPopulationCount, 0, cXSRelativityAssign);
            trModifyProtounitData(kbProtoUnitGetName(unitType), p, cXSProtoEffectPopCapAddition, 0, cXSRelativityAssign);
            trProtoUnitSetUnitType(p, kbProtoUnitGetName(unitType), kbUnitTypeGetName(cUnitTypeLogicalTypeValidSentinelTarget), true);
            trProtoUnitSetUnitType(p, kbProtoUnitGetName(unitType), kbUnitTypeGetName(cUnitTypeAbstractWarship), true);

            // trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "HandAttack", kbProtoUnitGetName(cDefaultcUnitTypeWall), p, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAssign);
            // trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "RangedAttack", kbProtoUnitGetName(cDefaultcUnitTypeWall), p, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAssign);
            // trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "LightningAttack", kbProtoUnitGetName(cDefaultcUnitTypeWall), p, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAssign);
        }

        // Buildings
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectBuildPoints, 20.0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeSentryTower), "RangedAttack", p, cXSActionEffectMinRange, 0.0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeSentryTower), "RangedAttack", p, cXSActionEffectRange, cBaseHumanLOS, cXSRelativityAssign);

        trProtounitActionSetFlag(p, kbProtoUnitGetName(cUnitTypeSmokeTrap), "HandAttack", "SelfDestruct", false);
        trProtounitActionSetFlag(p, kbProtoUnitGetName(cUnitTypeSpikeTrap), "HandAttack", "SelfDestruct", false);

        trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeRockGiant), "RotateInPlace", true);
        trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeRockGiant), kbUnitTypeGetName(cUnitTypeBuilding), true);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectBuildPoints, 30.0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectSpeed, 0.0, cXSRelativityAssign);

        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeSmokeTrap));
        trUnforbidProtounit(p, kbProtoUnitGetName(cUnitTypeObelisk));
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeObelisk), p, cXSProtoEffectLOS, 25.0, cXSRelativityAssign);

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), "MonolithStrike", p, cXSActionEffectRange, cBaseHumanLOS * 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), p, cXSProtoEffectLOS, cBaseHumanLOS * 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), p, cXSProtoEffectBuildPoints, 45.0, cXSRelativityAssign);

        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeStatueOfLightning), "LightningAttack", p, cXSActionEffectRange, cBaseHumanLOS * 1.75, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectLOS, cBaseHumanLOS * 1.75, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectBuildPoints, 60.0, cXSRelativityAssign);
        trModifyProtounitAction(kbProtoUnitGetName(cUnitTypeStatueOfLightning), "LightningAttack", p, cXSActionEffectDamageDivine, 50.0, cXSRelativityAssign);

        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSmokeTrap), "Wood", p, cXSPUResourceEffectCost, 1, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSentryTower), "Wood", p, cXSPUResourceEffectCost, 2, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSkyPassage), "Wood", p, cXSPUResourceEffectCost, 4, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSpikeTrap), "Wood", p, cXSPUResourceEffectCost, 4, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeRockGiant), "Wood", p, cXSPUResourceEffectCost, 4, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), "Wood", p, cXSPUResourceEffectCost, 8, cXSRelativityAssign);
        trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeStatueOfLightning), "Wood", p, cXSPUResourceEffectCost, 16, cXSRelativityAssign);

        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSentryTower), p, cXSProtoEffectBuildLimit, 30, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSmokeTrap), p, cXSProtoEffectBuildLimit, 3, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSkyPassage), p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeRockGiant), p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeSpikeTrap), p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(cUnitTypeStatueOfLightning), p, cXSProtoEffectBuildLimit, 0, cXSRelativityAssign);
    }

    setPickups();
    setupZombies();

    // Human AI Only
    for (int i = 0; i < g_humanInteractableTypes.size(); i++){
        int interactableType = g_humanInteractableTypes[i];
        g_OnCreationListener.register(cHumanAIPlayer, interactableType, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                if (kbUnitGetProtoUnitID(unitId) != cUnitTypeToriiGate){
                    trUnitSetScale(0.5, 0.5, 0.5);
                }
                g_humanInteractableObjects.add(unitId);
            }
        );
    }

    trProtoUnitSetFlag(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "HasLOS", false);
    trModifyProtounitUnitType(kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "LogicalTypePickable", cHumanAIPlayer, cXSPUUnitTypeEffectAddContainType, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeOsirisPieceBox), cHumanAIPlayer, cXSProtoEffectMaxContained, 1.0, cXSRelativityAssign);
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeOsirisPieceBox), "AbstractTemple", true);

    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);

    // Gaia Only
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeYanFeifengTomb), "Collideable", false);
    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeYanFeifengTomb), "Invulnerable", true);
    g_OnCreationListener.register(0, cUnitTypeYanFeifengTomb, false, [](int unitId = -1) -> void {
            vector v = kbUnitGetTruePosition(unitId);
            g_bspZombieSpawnLocation = v;
        }
    );
    g_OnCreationListener.register(0, cUnitTypeRugs, false, [](int unitId = -1) -> void {
            g_humanSpawnPoints.add(unitId);
        }
    );

    // trModifyProtounitData(kbProtoUnitGetName(cUnitTypeTaproot), 0, cXSProtoEffectHitpoints, 10, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMinion), 0, cXSProtoEffectLifespan, cMaxFloat, cXSRelativityAssign);

    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusX, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectArmorCrush, 0.25, cXSRelativityAssign);
    g_OnCreationListener.register(0, cDefaultcUnitTypeWall, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
            trUnitSetShading(cShaderBurning, xsRandFloat(75.0, 100.0));
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

    for (int p = 1; p <= cNumberPlayers; p++){
        trTechSetStatus(p, cTechRelicFeatherOfJingwei, cTechStatusActive);
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

    // A unit with 0 hitpoints is destroyed on creation, so keep at least 1x scaling.
    int healthScale = (g_humanUnitCount > 0) ? g_humanUnitCount : 1;
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * healthScale, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeWall2), 0, cXSProtoEffectHitpoints, cGaiaBaseWallHealth * healthScale, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeGate), 0, cXSProtoEffectHitpoints, cGaiaBaseGateHealth * healthScale, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cDefaultcUnitTypeGate2), 0, cXSProtoEffectHitpoints, cGaiaBaseGateHealth * healthScale, cXSRelativityAssign);

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallJail), cHumanAIPlayer, cXSProtoEffectHitpoints, 1 + (2500 * g_zombieUnitCount), cXSRelativityAssign);
}