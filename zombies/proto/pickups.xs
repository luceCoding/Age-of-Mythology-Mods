void handlePickup(int pickupId = -1, int pickerId = -1){
    int picker = kbUnitGetPlayerID(pickerId);
    int pickupType = kbUnitGetProtoUnitID(pickupId);
    if (pickupType == cUnitTypeGoldPile) {
        trPlayerGrantResources(picker, "Gold", xsRandInt(1, cNumberPlayers));
    } else if (pickupType == cUnitTypeWoodPileLarge) {
        trPlayerGrantResources(picker, "Wood", xsRandInt(10, 10+cNumberPlayers));
    }
    trSoundsetPlayPlayer(picker, "TributeReceived");
}

void registerPickupPicker(int unitId = -1){
    g_PickupManager.registerPicker(unitId, 0.5, true, handlePickup);
}

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
                trUnitCreateForced(kbProtoUnitGetName(cUnitTypeCanopicJars), v.x + jitterX, v.y, v.z + jitterZ, xsRandFloat(0, 359), 0, true);
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
    trProtounitModifySpawnData(kbProtoUnitGetName(cUnitTypeObsidianShard), 0, kbProtoUnitGetName(cUnitTypeGoldPile), 0, 1.0, cXSRelativityAssign, -1, -1);

    for (int i = 0; i < g_bossTileUnitTypes.size(); i++){
        int unitType = g_bossTileUnitTypes[i];
        trProtounitModifySpawnData(kbProtoUnitGetName(unitType), 0, kbProtoUnitGetName(cUnitTypeRelic), 0, 1.0, cXSRelativityAssign, -1, -1);
        trProtounitModifySpawnData(kbProtoUnitGetName(unitType), 0, kbProtoUnitGetName(cUnitTypeGoldPile), 0, 1.0, cXSRelativityAssign, -1, -1);
        trModifyProtounitData(kbProtoUnitGetName(unitType), 0, cXSProtoEffectHitpoints, (cNumberPlayers / 3), cXSRelativityPercent);
    }

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
            onPickupCreated(unitId);
        }
    );

    g_OnCreationListener.register(0, cUnitTypeGoldPile, false, [](int unitId = -1) -> void {
            onPickupCreated(unitId);
        }
    );

    // Any human or zombie unit created for any player becomes a picker automatically.
    for (int p = 1; p <= cNumberPlayers-1; p++){
        for (int h = 0; h < g_humanUnitTypes.size(); h++){
            g_OnCreationListener.register(p, g_humanUnitTypes[h], false, [](int unitId = -1) -> void {
                registerPickupPicker(unitId);
            });
        }
        for (int z = 0; z < g_zombieUnitTypes.size(); z++){
            g_OnCreationListener.register(p, g_zombieUnitTypes[z], false, [](int unitId = -1) -> void {
                registerPickupPicker(unitId);
            });
        }
    }
}