void protoApplyAutoGather(int p = 0, int unitType = -1, float foodTrickle = 0.0, float woodTrickle = 0.0, float goldTrickle = 0.0, float favorTrickle = 0.0, int relativity = cXSRelativityAssign){
    trProtounitAssignAction(kbProtoUnitGetName(unitType), kbProtoUnitGetName(cUnitTypePlentyVaultKOTH), "AutoGather", p);
    trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "AutoGather", "Food", p, cXSActionProtoEffectWorkRate, foodTrickle, relativity);
    trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "AutoGather", "Wood", p, cXSActionProtoEffectWorkRate, woodTrickle, relativity);
    trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "AutoGather", "Gold", p, cXSActionProtoEffectWorkRate, goldTrickle, relativity);
    trModifyProtounitActionUnitType(kbProtoUnitGetName(unitType), "AutoGather", "Favor", p, cXSActionProtoEffectWorkRate, favorTrickle, relativity);
}