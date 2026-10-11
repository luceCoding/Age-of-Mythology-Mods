void preModifyPlayerData(){

    for (int i = 0; i < g_humanInteractableTypes.size(); i++){
        int interactableType = g_humanInteractableTypes[i];
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusX, 1.5, cXSRelativityAssign);
        trModifyProtounitData(kbProtoUnitGetName(interactableType), cHumanAIPlayer, cXSProtoEffectObstructionRadiusZ, 1.5, cXSRelativityAssign);
        g_OnCreationListener.register(cHumanAIPlayer, interactableType, false, [](int unitId = -1) -> void {
                selectSingle(unitId);
                trUnitSetScale(0.5, 0.5, 0.5);
            }
        );
    }

    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectObstructionRadiusX, 1, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallOfAtlantisConnector), 0, cXSProtoEffectObstructionRadiusZ, 1, cXSRelativityAssign);

    g_OnCreationListener.register(0, cUnitTypeWallOfAtlantisConnector, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(1.35, 0.75, 1.35);
        }
    );
}