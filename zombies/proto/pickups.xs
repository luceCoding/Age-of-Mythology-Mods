void setPickups(){

    for (int i = 0; i < g_lootDrops.size(); i++){
        int lootType = g_lootDrops[i];
        trProtoUnitSetFlag(0, kbProtoUnitGetName(lootType), "Collideable", false);
        trProtoUnitSetFlag(0, kbProtoUnitGetName(lootType), "Selectable", false);
        trProtoUnitSetFlag(0, kbProtoUnitGetName(lootType), "Invulnerable", true);
    }

    //trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWoodPileLarge), 0, cXSProtoEffectObstructionRadiusX, 1, cXSRelativityAssign);
    //trModifyProtounitData(kbProtoUnitGetName(cUnitTypeWoodPileLarge), 0, cXSProtoEffectObstructionRadiusZ, 1, cXSRelativityAssign);

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
            if (trUnitAlive()){
                g_treasureChestObjects.add(unitId);
            }
        }
    );

    trProtounitModifySpawnData(kbProtoUnitGetName(cUnitTypeSpiderEgg), 0, kbProtoUnitGetName(cUnitTypeCinematicBlockWaypoint), 0, 1.0, cXSRelativityAssign, -1, -1);
    trProtounitModifySpawnData(kbProtoUnitGetName(cUnitTypeMinion), 0, kbProtoUnitGetName(cUnitTypeGoldPile), 0, 1.0, cXSRelativityAssign, -1, -1);

    g_OnCreationListener.register(0, cUnitTypeCinematicBlockWaypoint, true, [](int unitId = -1) -> void {
            vector v = kbUnitGetTruePosition(unitId);
            int lootType = g_lootDrops[xsRandInt(0, g_lootDrops.size()-1)];
            int createdUnitID = trUnitCreateForced(kbProtoUnitGetName(lootType), v.x, v.y, v.z, xsRandInt(0, 359), 0);
            if (lootType == cUnitTypeWoodPileLarge){
                selectSingle(createdUnitID);
                trUnitSetScale(0.25, 0.25, 0.25);
            }
        }
    );

    g_OnCreationListener.register(0, cUnitTypeWoodPileLarge, false, [](int unitId = -1) -> void {
            selectSingle(unitId);
            trUnitSetScale(0.25, 0.25, 0.25);
        }
    );

    for (int p = 1; p <= cNumberPlayers; p++){
        g_PickupManager.register(0, cUnitTypeGoldPile, p, g_humanUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            trPlayerGrantResources(picker, "Gold", xsRandInt(1, cNumberPlayers));
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
        g_PickupManager.register(0, cUnitTypeWoodPileLarge, p, g_humanUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            trPlayerGrantResources(picker, "Wood", xsRandInt(10, 10+cNumberPlayers));
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
        g_PickupManager.register(0, cUnitTypeGoldPile, p, g_zombieUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            trPlayerGrantResources(picker, "Gold", xsRandInt(1, cNumberPlayers));
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
        g_PickupManager.register(0, cUnitTypeWoodPileLarge, p, g_zombieUnitTypes[0], 1.0, true, [](int unitId = -1, int picker = 0) -> void {
            trPlayerGrantResources(picker, "Wood", xsRandInt(10, 10+cNumberPlayers));
            trSoundsetPlayPlayer(picker, "TributeReceived");
            return;
        });
    }
}