void setAsPlaceholder(string unitType = "", int p = 0){
    trModifyProtounitData(unitType, p, puFIELD_OBSTRUCTION_X, 0.0, relativityASSIGN);
    trModifyProtounitData(unitType, p, puFIELD_OBSTRUCTION_Z, 0.0, relativityASSIGN);
    trProtoUnitSetFlag(p, unitType, "Invulnerable", false);
    trProtoUnitSetFlag(p, unitType, "ForceToNature", false);
    trProtoUnitSetFlag(p, unitType, "CollidesWithProjectiles", false);
    trProtoUnitSetFlag(p, unitType, "NonAutoFormedUnit", false);
    trProtoUnitSetFlag(p, unitType, "StartOnNoUpdate", false);
    trProtoUnitSetUnitType(p, unitType, "NatureClass", false);
    trProtoUnitSetFlag(p, unitType, "CorpseDecays", true);
}

void setupCamp(string campUnitType = "", string placeholderUnitType = "", float respawnSecs = -1.0){
    setAsPlaceholder(placeholderUnitType, 0);
    trProtoUnitMovementType(campUnitType, 0, "air");
    trProtounitModifySpawnData(campUnitType, 0, "GoldPile", 0, 1.0, 1, -1, GOLDPILE_LIFESPAN);
    trProtounitModifySpawnData(campUnitType, 0, placeholderUnitType, 1, 1.0, 1, -1, respawnSecs);
    trProtounitModifySpawnData(placeholderUnitType, 0, campUnitType, 0, 1.0, 1, -1, -1);
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