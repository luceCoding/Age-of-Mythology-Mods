void preModifyPlayerData(){

    for (int i = 0; i < g_humanInteractableTypes.size(); i++){
        int interactableType = g_humanInteractableTypes[i];
        if (interactableType == cUnitTypeToriiGate) continue;
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
        g_OnCreationListener.register(cHumanAIPlayer, interactableType, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                trUnitSetScale(0.5, 0.5, 0.5);
            }
        );
    }

    // Gaia Only
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectObstructionRadiusX, 1, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectObstructionRadiusZ, 1, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectArmorHack, 0.5, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectArmorCrush, 0.05, cXSRelativityAssign);
    g_OnCreationListener.register(0, cUnitTypeWallOfAtlantisConnector, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
        }
    );

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisLong), 0, cXSProtoEffectObstructionRadiusX, 1, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisLong), 0, cXSProtoEffectObstructionRadiusZ, 1, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisLong), 0, cXSProtoEffectArmorHack, 0.5, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisLong), 0, cXSProtoEffectArmorCrush, 0.05, cXSRelativityAssign);
    g_OnCreationListener.register(0, cUnitTypeWallOfAtlantisLong, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(0.5, 0.75, 1.0);
        }
    );

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusX, 4, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeBoulderWall), 0, cXSProtoEffectObstructionRadiusZ, 1, cXSRelativityAssign);
}