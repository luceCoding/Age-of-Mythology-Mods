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

void applyProtoActionToAllCards(int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i = 0; i < params.size(); i++) {
        CardParameters param = params[i];
        string targetProto = param.getProtoUnit();
        trModifyProtounitAction(targetProto, "HandAttack", p, puField, deltaVal, relativity);
        trModifyProtounitAction(targetProto, "RangedAttack", p, puField, deltaVal, relativity);
        trModifyProtounitAction(targetProto, "RangedAttackFlying", p, puField, deltaVal, relativity);
        trModifyProtounitAction(targetProto, "BuildingAttack", p, puField, deltaVal, relativity);
        trModifyProtounitAction(targetProto, "AntiWallAttack", p, puField, deltaVal, relativity);
        trModifyProtounitAction(targetProto, "LightningAttack", p, puField, deltaVal, relativity);
    }
}