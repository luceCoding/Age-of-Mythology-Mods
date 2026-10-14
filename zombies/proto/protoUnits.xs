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
    for (int p = 1; p <= cNumberPlayers; p++){
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
    //trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWallJail), cHumanAIPlayer, cXSProtoEffectLifespan, 90, cXSRelativityAssign);

    // Gaia Only

    trProtoUnitSetFlag(0, kbProtoUnitGetName(cUnitTypeGoldPile), "Collideable", false);
    trProtounitModifySpawnData(kbProtoUnitGetName(cUnitTypeSpiderEgg), 0, kbProtoUnitGetName(cUnitTypeGoldPile), 0, 1.0, cXSRelativityAssign, -1, -1);

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
            vector v = kbUnitGetTruePosition(unitId);
            int nJars = xsRandInt(0, 3);
            for (int i = 0; i < nJars; i++){
                float jitterX = xsRandFloat(1, 3.0);
                float jitterZ = xsRandFloat(1, 3.0);
                trUnitCreate(kbProtoUnitGetName(cUnitTypeCanopicJars), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
            }
            if (xsRandInt(0, 5) == 0) { trUnitSetAnimationPath("Opening","spc\buildings\props\osiris_piece_box\anim\osiris_piece_box_opening",false,-1,false); }
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
    for (int i = 1; i <= cNumberPlayers; i++){
        g_PickupManager.register(0, cUnitTypeGoldPile, i, g_humanUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            int owner = kbUnitGetPlayerID(unitId);
            trPlayerGrantResources(picker, "Gold", 1);
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
        g_PickupManager.register(0, cUnitTypeGoldPile, i, g_zombieUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            int owner = kbUnitGetPlayerID(unitId);
            trPlayerGrantResources(picker, "Gold", 1);
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
    }
}