void setAsCardUnit(string protoName = "", int p = 0){
    trProtounitModifySpawnData(protoName, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    //trProtoUnitActionSetEnabled(protoName, p, "Build", false);
    trProtoUnitActionSetEnabled(protoName, p, "Repair", false);
    trProtoUnitSetFlag(p, protoName, "KnockoutDeath", false);
    trProtoUnitSetFlag(p, protoName, "Invulnerable", false);
    trProtoUnitSetFlag(p, protoName, "NotKBTracked", false);
    trProtoUnitSetFlag(p, protoName, "KBTracked", true);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeDivineImmunity", false);
    trModifyProtounitData(protoName, p, cXSProtoEffectUnitRegenRate, 0.2, cXSRelativityAbsolute);
    trModifyProtounitData(protoName, p, cXSProtoEffectShieldRegenRate, 0.2, cXSRelativityAbsolute);
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
    trModifyProtounitActionUnitType("CaravanGreek", "Trade", shopUnitType, p, 1, 1.1, 1);
    trModifyProtounitActionUnitType("PiXiu", "Trade", shopUnitType, p, 1, (1.1 * 1.25), 1);
    trProtoUnitSetIcon(shopUnitType, p, "", "ui\minimap\minimap_highlighted_item");
}

void setupAsTower(string unitType = "", int p = 0){
    trProtoUnitSetFlag(p, unitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(unitType, p, "", "ui\minimap\minimap_village_center");
    trModifyProtounitData(unitType, p, 5, 0, 1); // Max contained
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 18, cXSRelativityAssign);
}

void setupCreepWaveUnit(string unitType = "", int p = 0){
    trProtounitModifySpawnData(unitType, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trModifyProtounitData(unitType, p, cXSProtoEffectSpeed, 4, cXSRelativityAssign);
    trModifyProtounitData(unitType, p, cXSProtoEffectLOS, 15, cXSRelativityAssign);
}

void forbidBuilding(int p = 0){
    trForbidProtounit(p, "WallConnector");
    trForbidProtounit(p, "Temple");
    trForbidProtounit(p, "Dock");
    trForbidProtounit(p, "SentryTower");
    trForbidProtounit(p, "HillFort");
    trForbidProtounit(p, "House");
    trForbidProtounit(p, "Armory");
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