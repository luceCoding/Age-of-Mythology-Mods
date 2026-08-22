void setAsCardUnit(string protoName = "", int p = 0){
    trProtounitModifySpawnData(protoName, p, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trProtoUnitActionSetEnabled(protoName, p, "Build", false);
    trProtoUnitActionSetEnabled(protoName, p, "Repair", false);
    trProtoUnitSetFlag(p, protoName, "KnockoutDeath", false);
    trProtoUnitSetFlag(p, protoName, "Invulnerable", false);
    trProtoUnitSetUnitType(p, protoName, "LogicalTypeDivineImmunity", false);
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

void setupAsSharedShop(string shopUnitType = ""){
    trModifyProtounitData(shopUnitType, 0, puFIELD_OBSTRUCTION_X, 2.5, relativityASSIGN);
    trModifyProtounitData(shopUnitType, 0, puFIELD_OBSTRUCTION_Z, 2.5, relativityASSIGN);
    trProtoUnitSetFlag(0, shopUnitType, "ObscuredByUnits", true);
    trProtoUnitSetIcon(shopUnitType, 0, "", "ui\minimap\minimap_highlighted_item");
}

void setupAsAttackable(string unitType = "", int p = 0){
    trProtoUnitSetUnitType(p, unitType, "Building", true);
    trProtoUnitSetUnitType(p, unitType, "EmbellishmentClass", false);
    trProtoUnitSetUnitType(p, unitType, "LogicalTypeHandUnitsAttack", true);
    trProtoUnitSetUnitType(p, unitType, "LogicalTypeRangedUnitsAttack", true);

    trProtoUnitSetFlag(p, unitType, "Selectable", true);

    //trProtoUnitSetFlag(p, unitType, "StartOnNoUpdate", false);
    //trProtoUnitSetFlag(p, unitType, "AutoFormedUnit", true);
    trModifyProtounitData(unitType, p, puFIELD_HITPOINTS, 100, relativityASSIGN);
}

void setupAsTower(string unitType = "", int p = 0){
    trProtoUnitSetFlag(p, unitType, "VisibleUnderFog", true);
    trProtoUnitSetIcon(unitType, p, "", "ui\minimap\minimap_village_center");
    trModifyProtounitData(unitType, p, 5, 0, 1); // Max contained
    trModifyProtounitData(unitType, p, puFIELD_LOS, 18, relativityASSIGN);
}

void setupCreepCamp(string creepCampUnitType = "", string initialPlaceholder = "", string primaryPlaceholder = "", int respawnTime = 0){
    setAsPlaceholder(initialPlaceholder, 0);
    trProtoUnitSetFlag(0, initialPlaceholder, "NotKBTracked", false);
    trProtoUnitSetFlag(0, initialPlaceholder, "KBTracked", true);
    trProtoUnitSetUnitType(0, initialPlaceholder, "Building", true);
    trProtounitModifySpawnData(initialPlaceholder, 0, creepCampUnitType, 0, 1.0, 1, -1, -1);
    trModifyProtounitData(initialPlaceholder, 0, puFIELD_LIFESPAN, respawnTime + 60, relativityASSIGN);
    setupAutoRespawn(creepCampUnitType, primaryPlaceholder, respawnTime);
}