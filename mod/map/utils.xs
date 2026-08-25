void setAsCardUnit(string protoName = "", int p = 0){
    trProtounitModifySpawnData(protoName, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trProtoUnitActionSetEnabled(protoName, p, "Build", false);
    trProtoUnitActionSetEnabled(protoName, p, "Repair", false);
    trProtoUnitSetFlag(p, protoName, "KnockoutDeath", false);
    trProtoUnitSetFlag(p, protoName, "Invulnerable", false);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeDivineImmunity", false);
    trModifyProtounitData(protoName, p, puFIELD_HP_REGEN, 0.2, relativityABSOLUTE);
}

void setAsPlaceholder(string unitType = "", int p = 0){
    trModifyProtounitData(unitType, p, puFIELD_OBSTRUCTION_X, 0.0, relativityASSIGN);
    trModifyProtounitData(unitType, p, puFIELD_OBSTRUCTION_Z, 0.0, relativityASSIGN);
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
    trModifyProtounitData(shopUnitType, p, puFIELD_OBSTRUCTION_X, 2.5, relativityASSIGN);
    trModifyProtounitData(shopUnitType, p, puFIELD_OBSTRUCTION_Z, 2.5, relativityASSIGN);
    trModifyProtounitData(shopUnitType, p, puFIELD_LOS, SHARED_SHOP_CAPTURE_RADIUS, relativityASSIGN);
    trProtoUnitSetFlag(p, shopUnitType, "ObscuredByUnits", true);
    trProtoUnitSetFlag(p, shopUnitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(shopUnitType, p, "", "ui\minimap\minimap_highlighted_item");
}

void setupAsTower(string unitType = "", int p = 0){
    trProtoUnitSetFlag(p, unitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(unitType, p, "", "ui\minimap\minimap_village_center");
    trModifyProtounitData(unitType, p, 5, 0, 1); // Max contained
    trModifyProtounitData(unitType, p, puFIELD_LOS, 18, relativityASSIGN);
}

void setupCreepWaveUnit(string unitType = "", int p = 0){
    trProtounitModifySpawnData(unitType, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trModifyProtounitData(unitType, p, puFIELD_SPEED, 4, relativityASSIGN);
    trModifyProtounitData(unitType, p, puFIELD_LOS, 15, relativityASSIGN);
}