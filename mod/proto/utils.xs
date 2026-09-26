void setupForAllUnits(string protoName = "", int p = 0){
    trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectKillReward, INITIAL_GOLD_REWARD, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);

    // For Kronos
    trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Food", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Wood", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Gold", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectResourceReturn, 0, cXSRelativityAssign);
    trModifyProtounitResource(protoName, "Favor", p, cXSPUResourceEffectResourceReturnRate, 0, cXSRelativityAssign);

    trProtounitModifySpawnData(protoName, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
}

void setAsCardUnit(string protoName = "", int p = 0){
    setupForAllUnits(protoName, p);
    //trProtoUnitActionSetEnabled(protoName, p, "Repair", false);
    trProtoUnitSetFlag(p, protoName, "KnockoutDeath", false);
    trProtoUnitSetFlag(p, protoName, "Invulnerable", false);
    trProtoUnitSetFlag(p, protoName, "NotKBTracked", false);
    trProtoUnitSetFlag(p, protoName, "KBTracked", true);
    trProtoUnitSetFlag(p, protoName, "Deleteable", false);
    trProtounitRemoveCommand(protoName, p, "Delete");
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeDivineImmunity", false);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidBoltTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidFrostTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidTraitorTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeAffectedByRestoration", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeEarthquakeAttack", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeParticipatesInBattlecries", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidMeteorTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidTornadoAttack", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeHealed", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidShiftingSandsTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidBloodPactTarget", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeValidShockwaveTarget", true);
    trProtoUnitSetUnitType(p, protoName, "TradeUnit", true); // For abilities
    trModifyProtounitData(protoName, p, cXSProtoEffectUnitRegenRate, 0.2, cXSRelativityAssign);
    trModifyProtounitData(protoName, p, cXSProtoEffectShieldRegenRate, 0.4, cXSRelativityAssign);
    trModifyProtounitData(protoName, p, cXSProtoEffectLifespan, -1, cXSRelativityAssign);
    addRecallCommand(p, protoName);
}

void setAsPlaceholder(string unitType = "", int p = 0){
    trModifyProtounitData(unitType, p, cXSProtoEffectObstructionRadiusX, 0.0, cXSRelativityAssign);
    trModifyProtounitData(unitType, p, cXSProtoEffectObstructionRadiusZ, 0.0, cXSRelativityAssign);
    trProtoUnitSetFlag(p, unitType, "Invulnerable", true);
    trProtoUnitSetFlag(p, unitType, "ForceToNature", false);
    trProtoUnitSetFlag(p, unitType, "CollidesWithProjectiles", false);
    trProtoUnitSetFlag(p, unitType, "NonAutoFormedUnit", false);
    trProtoUnitSetFlag(p, unitType, "StartOnNoUpdate", false);
    trProtoUnitSetUnitType(p, unitType, "NatureClass", false);
    trProtoUnitSetFlag(p, unitType, "CorpseDecays", true);
    trProtoUnitSetFlag(p, unitType, "DoNotShowOnMiniMap", true);
}

void setupAsBreakableLoot(string lootUnitType = "", string placeholderUnitType = "", float respawnSecs = -1.0){
    setAsPlaceholder(placeholderUnitType, 0);
    trProtoUnitSetFlag(0, placeholderUnitType, "OnlyInEditor", true);
    trProtoUnitChangeName(lootUnitType, 0, "Loot", "Gold Loot", "Gold Loot");
    trProtoUnitSetUnitType(0, lootUnitType, "LogicalTypeHandUnitsAttack", true);
    trProtoUnitSetUnitType(0, lootUnitType, "LogicalTypeRangedUnitsAttack", true);
    trProtoUnitSetUnitType(0, lootUnitType, "Unit", true);
    trProtoUnitMovementType(lootUnitType, 0, "air");
    trProtounitModifySpawnData(lootUnitType, 0, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN+10);
    trProtounitModifySpawnData(lootUnitType, 0, placeholderUnitType, 1, 1.0, 1, -1, respawnSecs);
    trProtounitModifySpawnData(placeholderUnitType, 0, lootUnitType, 0, 1.0, 1, -1, -1);
    trProtoUnitSetFlag(0, lootUnitType, "ObscuredByUnits", true);
    trProtoUnitSetFlag(0, lootUnitType, "NotSelectable", false);
    trProtoUnitSetFlag(0, lootUnitType, "Selectable", true);
    trProtoUnitSetFlag(0, lootUnitType, "Invulnerable", false);
    trProtoUnitSetFlag(0, lootUnitType, "DoNotShowOnMiniMap", false);
    trProtoUnitSetFlag(0, lootUnitType, "ShowOnMiniMap", true);
    trProtoUnitSetFlag(0, lootUnitType, "CorpseDecays", true);
    trProtoUnitSetFlag(0, lootUnitType, "NonAutoFormedUnit", false);
    trProtoUnitSetFlag(0, lootUnitType, "AutoFormedUnit", true);
    trProtoUnitSetFlag(0, lootUnitType, "NonCollideable", false);
    trProtoUnitSetFlag(0, lootUnitType, "Collideable", true);
    trProtoUnitSetFlag(0, lootUnitType, "Immoveable", true);
    trProtoUnitSetFlag(0, lootUnitType, "NoUnitAI", false);
    trProtoUnitSetFlag(0, lootUnitType, "CollidesWithProjectiles", true);
    trModifyProtounitData(lootUnitType, 0, cXSProtoEffectArmorHack, 0, cXSRelativityAssign);
    trModifyProtounitData(lootUnitType, 0, cXSProtoEffectArmorPierce, 0, cXSRelativityAssign);
    trModifyProtounitData(lootUnitType, 0, cXSProtoEffectArmorCrush, 0, cXSRelativityAssign);
    trModifyProtounitData(lootUnitType, 0, cXSProtoEffectObstructionRadiusX, 0, cXSRelativityAssign);
    trModifyProtounitData(lootUnitType, 0, cXSProtoEffectObstructionRadiusZ, 0, cXSRelativityAssign);

    // Workaround fix to the unit display
    g_OnCreationListener.register(0, kbProtoUnitGetID(lootUnitType), false, [](int unitId = -1) -> void {
            trProtoUnitSetIcon(kbProtoUnitGetName(kbUnitGetProtoUnitID(unitId)), 0, "resources\nature\relics\relic_coins_icon.png", "ui\minimap\minimap_gold");
            trProtoUnitChangeName(kbProtoUnitGetName(kbUnitGetProtoUnitID(unitId)), 0, "Loot", "Gold Loot", "Gold Loot");
            selectSingle(unitId);
            trUnitSetScale(1.5, 1.5, 1.5);
        }
    );

    g_OnCreationListener.register(0, kbProtoUnitGetID(placeholderUnitType), false, [](int unitId = -1) -> void {
            scheduleDelete(unitId, (LOOT_SPAWN_TIME+2)*1000);
        }
    );
}

void setupAsSharedShop(string shopUnitType = "", int p = 0){
    trModifyProtounitData(shopUnitType, p, cXSProtoEffectObstructionRadiusX, 2.5, cXSRelativityAssign);
    trModifyProtounitData(shopUnitType, p, cXSProtoEffectObstructionRadiusZ, 2.5, cXSRelativityAssign);
    trModifyProtounitData(shopUnitType, p, cXSProtoEffectLOS, SHARED_SHOP_CAPTURE_RADIUS, cXSRelativityAssign);
    trProtoUnitSetFlag(p, shopUnitType, "ObscuredByUnits", true);
    trProtoUnitSetFlag(p, shopUnitType, "VisibleUnderFog", true);
    trProtoUnitSetUnitType(p, shopUnitType, "TradeableTo", true);
    trModifyProtounitActionUnitType("CaravanGreek", "Trade", shopUnitType, p, 1, 1.0, 1);
    trModifyProtounitActionUnitType("PiXiu", "Trade", shopUnitType, p, 1, (1.0 * 1.25), 1);
    trProtoUnitSetIcon(shopUnitType, p, "", "ui\minimap\minimap_highlighted_item");
}

void setupAsTower(string unitType = "", int p = 0){
    setupForAllUnits(unitType, p);
    trProtoUnitSetFlag(p, unitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(unitType, p, "", "ui\minimap\minimap_village_center");
    trModifyProtounitData(unitType, p, 5, 0, 1); // Max contained
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 18, cXSRelativityAssign);
}

void setupCreepWaveUnit(string unitType = "", int p = 0){
    setupForAllUnits(unitType, p);
    trModifyProtounitData(unitType, p, cXSProtoEffectSpeed, 4, cXSRelativityAssign);
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 15, cXSRelativityAssign);
    trModifyProtounitData(unitType, p, cXSProtoEffectShieldRegenRate, 0.2, cXSRelativityAbsolute);
}

void setupBoss(string protoName = "", string spawnProtoName = "", float killReward = 0.0){
    setupForAllUnits(protoName, 0);
    trModifyProtounitData(protoName, 0, cXSProtoEffectHitpoints, 5000, cXSRelativityAssign);
    trProtoUnitSetUnitType(0, protoName, "MythUnit", false);
    trModifyProtounitActionUnitType(protoName, "HandAttack", "Hero", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trModifyProtounitActionUnitType(protoName, "RangedAttack", "MythUnit", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trProtoUnitSetIcon(protoName, 0, "", "ui\minimap\minimap_titan_gate");
    trProtoUnitMovementType(protoName, 0, "land");
    trModifyProtounitData(protoName, 0, cXSProtoEffectLOS, GAIA_CREEP_LOS, cXSRelativityAssign);
    trProtounitModifySpawnData(protoName, 0, spawnProtoName, 0, 1.0, 1, -1, 1.0);
}

void forbidBuilding(int p = 0){
    trForbidProtounit(p, "WallConnector");
    trForbidProtounit(p, "Temple");
    trForbidProtounit(p, "Dock");
    trForbidProtounit(p, "SentryTower");
    trForbidProtounit(p, "HillFort");
    trForbidProtounit(p, "House");
    trForbidProtounit(p, "Armory");
    trForbidProtounit(p, "DwarvenArmory");
    trForbidProtounit(p, "TownCenter");
    trForbidProtounit(p, "Longhouse");
    trForbidProtounit(p, "GreatHall");
    trForbidProtounit(p, "Wonder");
    trForbidProtounit(p, "Market");
}

void modifyBuildingCosts(int p = 0){
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSmokeTrap), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSmokeTrap), "Gold", p, cXSPUResourceEffectCost, 20.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSpikeTrap), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSpikeTrap), "Gold", p, cXSPUResourceEffectCost, 50.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeFarmShennong), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeFarmShennong), "Gold", p, cXSPUResourceEffectCost, 75.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSkyPassageSPC), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSkyPassageSPC), "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSkyPassageSPC), "Gold", p, cXSPUResourceEffectCost, 33.0, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSentryTower), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeSentryTower), "Gold", p, cXSPUResourceEffectCost, 250.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMirrorTower), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMirrorTower), "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMirrorTower), "Gold", p, cXSPUResourceEffectCost, 400.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeHillFort), "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeHillFort), "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeHillFort), "Gold", p, cXSPUResourceEffectCost, 575.0 * 0.5, cXSRelativityAssign);

    trModifyProtounitResource(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), "Gold", p, cXSPUResourceEffectCost, 575.0, cXSRelativityAssign);
}

int getMinsPastSinceStart(){
    return ((xsGetTimeMS() - g_timeMSGameStarted) / 60000);
}

void applyProxyDOT(int cUnitTypeTarget = -1, int p = 0, float range = 20.0, float dot = -20.0){
    string protoUnit = kbProtoUnitGetName(cUnitTypeFafnirBoss);
    trModifyProtounitAction(protoUnit, "BillowingSmog", p, cXSActionEffectRange, range, cXSRelativityAbsolute);
    trModifyProtounitAction(protoUnit, "BillowingSmog", p, cXSActionEffectModifyRate, dot, cXSRelativityAbsolute);
    trProtounitAssignAction(kbProtoUnitGetName(cUnitTypeTarget), protoUnit, "BillowingSmog", p);
    trModifyProtounitAction(protoUnit, "BillowingSmog", p, cXSActionEffectRange, range * -1, cXSRelativityAbsolute);
    trModifyProtounitAction(protoUnit, "BillowingSmog", p, cXSActionEffectModifyRate, dot * -1, cXSRelativityAbsolute);
}

void setupForPoisonSynergy(int p = 0){
    trModifyProtounitAction("ArgusAcidBlobDamage", "SelfDestructAttack", p, cXSActionEffectDamageDivine, 0.0, cXSRelativityAssign);
    trModifyProtounitAction("ArgusAcidBlobDamage", "SelfDestructAttack", p, cXSActionEffectDamageHack, 50.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "AreaDamage", UNIT_TYPE_HERO, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "AreaDamage", UNIT_TYPE_MYTH, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "SelfDestructAttack", UNIT_TYPE_HERO, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "SelfDestructAttack", UNIT_TYPE_MYTH, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
}

void setupForFireSynergy(int p = 0){
    trTechSetStatus(p, cTechSkyFire, cTechStatusActive);
    trProtounitAddCommand("SkyLantern", p, "Delete", 3, 5);
    trProtoUnitSetUnitType(p, "SkyLantern", "LogicalTypeRangedUnitsAutoAttack", true);
    trModifyProtounitAction("MeteorSPC", "HandAttack", p, cXSActionEffectDamagePierce, 50.0, cXSRelativityAssign);
    trModifyProtounitAction("MeteorSPC", "HandAttack", p, cXSActionEffectDamageCrush, 50.0, cXSRelativityAssign);
    trModifyProtounitAction("MeteorSPC", "HandAttack", p, cXSActionEffectDamageDivine, 0.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "AreaDamage", UNIT_TYPE_HERO, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
    trModifyProtounitActionUnitType("SkylanternFireAreaGround", "AreaDamage", UNIT_TYPE_MYTH, p, cXSActionProtoEffectDamageBonus, 1.0, cXSRelativityAssign);
}

void setupForUndeadSynergy(int p = 0){  
    trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeTlacanexquimilli), "NotCommandable", false);
    trProtoUnitSetFlag(p, kbProtoUnitGetName(cUnitTypeTlacanexquimilli), "Commandable", true);

    // Do not spawn minions for the following:
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeMinionReincarnated), "MilitaryUnit", false);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeMinion), "MilitaryUnit", false);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeTlacanexquimilli), "MilitaryUnit", false);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeTartarianSpawn), "MilitaryUnit", false);
    trProtoUnitSetUnitType(p, kbProtoUnitGetName(cUnitTypeSkyLantern), "MilitaryUnit", false);
}

void setupForHealSynergy(int p = 0){
    //trProtounitActionSetFlag(p, "VFXForestProtectionArea", "AllyHealModify", "NoStack", false);
    //trProtounitAssignAction("Priest", "VFXForestProtectionArea", "AllyHealModify", p);
}

void setupForLightningSynergy(int p = 0){
}

void addTrainBuilding(string targetProto = "", int cUnitType = -1, int p = -1, int row = 0, int col = 0){
    trProtounitAddTrain(targetProto, p, kbProtoUnitGetName(cUnitType), row, col);
    //trUnforbidProtounit(p, kbProtoUnitGetName(cUnitType));
    trModifyProtounitActionUnitType(targetProto, "Build", "Building", p, cXSActionProtoEffectWorkRate, 1.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitType), p, cXSProtoEffectBuildLimit, BUILDING_BUILD_LIMIT, cXSRelativityAssign);
}

void unforbidTrainBuilding(int p = -1, int cUnitType = -1){
    trUnforbidProtounit(p, kbProtoUnitGetName(cUnitType));
}

void forbidTrainBuilding(int p = -1, int cUnitType = -1){
    trForbidProtounit(p, kbProtoUnitGetName(cUnitType));
}

void setupForBuilderSynergy(int p = 0){
    modifyBuildingCosts(p);
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i = 0; i < params.size(); i++) {
        CardParameters param = params[i];
        if (param.isASynergy(SYNERGY_INDEX_BUILDER)){
            string targetProto = param.getProtoUnit();
            addTrainBuilding(targetProto, cUnitTypeSmokeTrap, p, 0, 1);
            addTrainBuilding(targetProto, cUnitTypeSpikeTrap, p, 0, 2);
            addTrainBuilding(targetProto, cUnitTypeObelisk, p, 0, 5);
            addTrainBuilding(targetProto, cUnitTypeSkyPassageSPC, p, 0, 3);
            addTrainBuilding(targetProto, cUnitTypeFarmShennong, p, 1, 3);
            addTrainBuilding(targetProto, cUnitTypeSentryTower, p, 2, 2);
            addTrainBuilding(targetProto, cUnitTypeMirrorTower, p, 2, 4);
            addTrainBuilding(targetProto, cUnitTypeHillFort, p, 2, 3);
            addTrainBuilding(targetProto, cUnitTypeMonolithOfTlaloc, p, 2, 5);
        }
    }
    trTechSetStatus(p, cTechTzompantliWatchTower, cTechStatusActive);
    trTechSetStatus(p, cTechWatchTower, cTechStatusActive);
    trTechSetStatus(p, cTechBoilingOil, cTechStatusActive);
    trTechSetStatus(p, cTechSignalFires, cTechStatusUnobtainable);
    trTechSetStatus(p, cTechCrenellations, cTechStatusUnobtainable);
    trTechSetStatus(p, cTechMediumInfantry, cTechStatusUnobtainable);
    unforbidTrainBuilding(p, cUnitTypeSmokeTrap);
    unforbidTrainBuilding(p, cUnitTypeSpikeTrap);
    unforbidTrainBuilding(p, cUnitTypeObelisk);
    trProtounitRemoveTech(kbProtoUnitGetName(cUnitTypeSentryTower), p, cTechCrenellations);
    trProtounitRemoveTech(kbProtoUnitGetName(cTechWatchTower), p, cTechCrenellations);
    trProtounitRemoveTech(kbProtoUnitGetName(cTechGuardTower), p, cTechCrenellations);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMirrorTower), p, cXSProtoEffectBuildPoints, 90.0, cXSRelativityAssign);
    trModifyProtounitData(kbProtoUnitGetName(cUnitTypeMonolithOfTlaloc), p, cXSProtoEffectBuildPoints, 180.0, cXSRelativityAssign);
}