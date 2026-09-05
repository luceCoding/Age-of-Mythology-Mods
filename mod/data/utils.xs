StringToCardParametersHashMap g_protoNameToCardParametersMap;

string getDisplayName(ref int rarity, ref string name){
    string displayName = name;
    switch(rarity){
        case 1: displayName = "<color=0.10,0.58,0.37>" + name + "</color>";
        case 2: displayName = "<color=0.15,0.32,0.49>" + name + "</color>";
        case 3: displayName = "<color=0.60,0.00,0.73>" + name + "</color>";
        case 4: displayName = "<color=0.71,0.58,0.00>" + name + "</color>";
    }
    return displayName;
}

void applyProtoDataToAllCards(int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i = 0; i < params.size(); i++) {
        CardParameters param = params[i];
        string targetProto = param.getProtoUnit();
        trModifyProtounitData(targetProto, p, puField, deltaVal, relativity);
    }
}

void applyProtoActionToTarget(string targetProto = "", int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    trModifyProtounitAction(targetProto, "HandAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "RangedAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "RangedAttackFlying", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "BuildingAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "AntiWallAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "LightningAttack", p, puField, deltaVal, relativity);
}

void applyProtoActionUnitTypeToTarget(string targetProto = "", string unitType = "", int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    trModifyProtounitActionUnitType(targetProto, "HandAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "RangedAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "RangedAttackFlying", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "BuildingAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "AntiWallAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "LightningAttack", unitType, p, puField, deltaVal, relativity);
}

void applyProtoActionSpecialEffectToTarget(string targetProto = "", int p = 0, int effectField = 0, float duration = 0.0, float value = 0.0){
    trProtounitActionSpecialEffect(targetProto, "HandAttack", p, effectField, "All", -1, duration, value);
    trProtounitActionSpecialEffect(targetProto, "RangedAttack", p, effectField, "All", -1, duration, value);
    trProtounitActionSpecialEffect(targetProto, "RangedAttackFlying", p, effectField, "All", -1, duration, value);
    trProtounitActionSpecialEffect(targetProto, "BuildingAttack", p, effectField, "All", -1, duration, value);
    trProtounitActionSpecialEffect(targetProto, "AntiWallAttack", p, effectField, "All", -1, duration, value);
    trProtounitActionSpecialEffect(targetProto, "LightningAttack", p, effectField, "All", -1, duration, value);
}

void applyProtoActionToAllCards(int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i = 0; i < params.size(); i++) {
        CardParameters param = params[i];
        string targetProto = param.getProtoUnit();
        applyProtoActionToTarget(targetProto, p, puField, deltaVal, relativity);
    }
}