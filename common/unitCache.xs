void setUpUnitCache(int protoUnitID = -1, int p = 0, int resourceID = cResourceFavor){
    trModifyProtounitResource(kbProtoUnitGetName(protoUnitID), kbGetResourceName(resourceID), p, cXSPUResourceEffectCarryCapacity, cMaxInt, cXSRelativityAssign);
}

void setUnitCacheValue(int unitID = -1, float value = 0, int resourceID = cResourceFavor){
    selectSingle(unitID);
    trUnitModifyResourceInventory(resourceID, value, cXSRelativityAssign);
}

float getUnitCacheValue(int unitID = -1, int resourceID = cResourceFavor){
    return kbUnitGetResourceAmount(unitID, resourceID);
}