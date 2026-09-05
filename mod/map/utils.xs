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
    //trProtoUnitActionSetEnabled(protoName, p, "Build", false);
    trProtoUnitActionSetEnabled(protoName, p, "Repair", false);
    trProtoUnitSetFlag(p, protoName, "KnockoutDeath", false);
    trProtoUnitSetFlag(p, protoName, "Invulnerable", false);
    trProtoUnitSetFlag(p, protoName, "NotKBTracked", false);
    trProtoUnitSetFlag(p, protoName, "KBTracked", true);
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
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeHandUnitsAutoAttack", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeRangedUnitsAutoAttack", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeHandUnitsAttack", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeRangedUnitsAttack", true);
    trProtoUnitSetUnitType(p, protoName, "TradeUnit", true); // For abilities
    trModifyProtounitData(protoName, p, cXSProtoEffectUnitRegenRate, 0.2, cXSRelativityAssign);
    trModifyProtounitData(protoName, p, cXSProtoEffectShieldRegenRate, 0.4, cXSRelativityAssign);
    trModifyProtounitData(protoName, p, cXSProtoEffectLifespan, -1, cXSRelativityAssign);

    setupForAllUnits(protoName, p);
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

void setupAutoRespawn(string campUnitType = "", string placeholderUnitType = "", float respawnSecs = -1.0){
    setAsPlaceholder(placeholderUnitType, 0);
    trProtoUnitMovementType(campUnitType, 0, "air");
    trProtounitModifySpawnData(campUnitType, 0, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trProtounitModifySpawnData(campUnitType, 0, placeholderUnitType, 1, 1.0, 1, -1, respawnSecs);
    trProtounitModifySpawnData(placeholderUnitType, 0, campUnitType, 0, 1.0, 1, -1, -1);
    trProtoUnitSetFlag(0, campUnitType, "ObscuredByUnits", true);
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
    trProtoUnitSetFlag(p, unitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(unitType, p, "", "ui\minimap\minimap_village_center");
    trModifyProtounitData(unitType, p, 5, 0, 1); // Max contained
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 18, cXSRelativityAssign);

    setupForAllUnits(unitType, p);
}

void setupCreepWaveUnit(string unitType = "", int p = 0){
    trModifyProtounitData(unitType, p, cXSProtoEffectSpeed, 4, cXSRelativityAssign);
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 15, cXSRelativityAssign);

    setupForAllUnits(unitType, p);
}

void setupBoss(string protoName = "", float killReward = 0.0){
    trModifyProtounitData(protoName, 0, cXSProtoEffectHitpoints, 5000, cXSRelativityAssign);
    trProtoUnitSetUnitType(0, protoName, "MythUnit", false);
    trModifyProtounitActionUnitType(protoName, "HandAttack", "Hero", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trModifyProtounitActionUnitType(protoName, "RangedAttack", "MythUnit", 0, cXSActionProtoEffectDamageBonus, 1, cXSRelativityAssign);
    trProtoUnitSetIcon(protoName, 0, "", "ui\minimap\minimap_titan_gate");
    trProtounitModifySpawnData(protoName, 0, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trModifyProtounitResource(protoName, "Gold", 0, cXSPUResourceEffectKillReward, 0, cXSRelativityAssign);
    trProtoUnitMovementType(protoName, 0, "land");
    trModifyProtounitResource(protoName, "Wood", 0, cXSPUResourceEffectKillReward, killReward, cXSRelativityAbsolute);
    trModifyProtounitData(protoName, 0, cXSProtoEffectLOS, 8, cXSRelativityAssign);
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
    trModifyProtounitResource("SmokeTrap", "Wood", p, cXSPUResourceEffectCost, 0, 1);
    trModifyProtounitResource("SmokeTrap", "Gold", p, cXSPUResourceEffectCost, 20, 1);
    trModifyProtounitResource("SpikeTrap", "Wood", p, cXSPUResourceEffectCost, 0, 1);
    trModifyProtounitResource("SpikeTrap", "Gold", p, cXSPUResourceEffectCost, 50, 1);
    trModifyProtounitResource("SentryTower", "Wood", p, cXSPUResourceEffectCost, 0, 1);
    trModifyProtounitResource("SentryTower", "Gold", p, cXSPUResourceEffectCost, 250, 1);
    //trTechModifyCost(cTechWatchTower, p, cResourceWood, 0, cXSRelativityAssign);
    //trTechModifyCost(cTechWatchTower, p, cResourceGold, 400, cXSRelativityAssign);
}

int getMinsPastSinceStart(){
    return ((xsGetTimeMS() - g_timeMSGameStarted) / 60000);
}