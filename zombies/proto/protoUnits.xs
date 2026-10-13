void initializeBuildingForGarrison(int p = 0, int cUnitTypeBuildingType = -1){
    string building = kbProtoUnitGetName(cUnitTypeBuildingType);
    trProtoUnitSetFlag(p, building, "InitialGarrisonOnly", false);
    trProtoUnitSetFlag(p, building, "AllowAutoGarrison", true);
    trProtoUnitSetFlag(p, building, "HideGarrisonFlag", true);
    trModifyProtounitUnitType(building, "Unit", p, cXSPUUnitTypeEffectAddContainType, 1.0, 1);
    trModifyProtounitData(building, p, cXSProtoEffectMaxContained, 1000.0, cXSRelativityAssign);
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
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
        trProtoUnitSetFlag(cHumanAIPlayer, kbProtoUnitGetName(interactableType), "HasLOS", false);
        g_OnCreationListener.register(cHumanAIPlayer, interactableType, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                trUnitSetScale(0.5, 0.5, 0.5);
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