void initializeBuildingForGarrison(int p = 0, int cUnitTypeBuildingType = -1){
    string building = kbProtoUnitGetName(cUnitTypeBuildingType);
    trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
    trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
    trProtoUnitSetFlag(p, building, "HideGarrisonFlag", true);
    trModifyProtounitData(building, cHumanAIPlayer, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
    trModifyProtounitData(building, cHumanAIPlayer, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
    trProtoUnitSetFlag(cHumanAIPlayer, building, "HasLOS", false);
    trProtoUnitSetFlag(cHumanAIPlayer, building, "KnockoutDeath", true);
    trProtoUnitSetFlag(cHumanAIPlayer, building, "InitialGarrisonOnly", false);
    trProtoUnitSetFlag(cHumanAIPlayer, building, "AllowAutoGarrison", true);
    trModifyProtounitUnitType(building, "Unit", p, cXSPUUnitTypeEffectAddContainType, 1.0, 1);
    trModifyProtounitData(building, p, cXSProtoEffectMaxContained, 1.0, cXSRelativityAssign);
}

void preModifyPlayerData(){

    // All players
    for (int p = 0; p <= cNumberPlayers; p++){
        trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeTartarianGate), "Collideable", false);
        g_OnCreationListener.register(p, cUnitTypeTartarianGate, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                trUnitSetScale(0.5, 1.0, 0.5);
            }
        );
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
    }

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
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeHandUnitsAutoAttack), true);
    trProtoUnitSetUnitType(cHumanAIPlayer, kbProtoUnitGetName(cUnitTypeWallJail), kbUnitTypeGetName(cUnitTypeLogicalTypeRangedUnitsAutoAttack), true);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallJail), cHumanAIPlayer, cXSProtoEffectHitpoints, 5000, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallJail), cHumanAIPlayer, cXSProtoEffectLifespan, 90, cXSRelativityAssign);

    // Gaia Only
    trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusX, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    // trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall), 0, cXSProtoEffectArmorHack, 0.5, cXSRelativityAssign);
    // trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall), 0, cXSProtoEffectArmorCrush, 0.05, cXSRelativityAssign);
    g_OnCreationListener.register(0, defaultcUnitTypeWall, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
            trUnitSetShading(cShaderBurning, xsRandFloat(50.0, 100.0));
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

    trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall2), 0, cXSProtoEffectObstructionRadiusX, 1.25, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall2), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    // trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall2), 0, cXSProtoEffectArmorHack, 0.5, cXSRelativityAssign);
    // trModifyProtounitData(kbProtoUnitGetName(defaultcUnitTypeWall2), 0, cXSProtoEffectArmorCrush, 0.05, cXSRelativityAssign);
    g_OnCreationListener.register(0, defaultcUnitTypeWall2, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.0, 0.8, 1.0);
            trUnitSetShading(cShaderBurning, xsRandFloat(50.0, 100.0));
        }
    );

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusX, 4, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusZ, 1.25, cXSRelativityAssign);
    trTechSetStatus(0, cTechStoneWall, cTechStatusActive);
}