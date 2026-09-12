StringToCardParametersHashMap g_protoNameToCardParametersMap;

string getDisplayName(int rarity = 0, ref string name){
    string displayName = name;
    switch(rarity){
        case 1: displayName = "<color=0.10,0.58,0.37,0,0,0>" + name + "</color>";
        case 2: displayName = "<color=0.15,0.32,0.49,0,0,0>" + name + "</color>";
        case 3: displayName = "<color=0.60,0.00,0.73,0,0,0>" + name + "</color>";
        case 4: displayName = "<color=0.71,0.58,0.00,0,0,0>" + name + "</color>";
        default: displayName = "<color=1,1,1,0,0,0>" + name + "</color>";
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

void enableProtoActionAttach(string targetProto = "", int p = 0){
    trProtounitActionSpecialEffectActive(targetProto, "HandAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "ChargedHandAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "RangedAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "RangedAttackFlying", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "RangedAttackMyth", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "FlyingUnitAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "JumpAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "BuildingAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "AntiWallAttack", p, cOnHitEffectAttach, "All", -1, true);
    trProtounitActionSpecialEffectActive(targetProto, "LightningAttack", p, cOnHitEffectAttach, "All", -1, true);
}

void applyProtoActionToTarget(string targetProto = "", int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    trModifyProtounitAction(targetProto, "HandAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "ChargedHandAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "RangedAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "RangedAttackFlying", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "RangedAttackMyth", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "FlyingUnitAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "JumpAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "BuildingAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "AntiWallAttack", p, puField, deltaVal, relativity);
    trModifyProtounitAction(targetProto, "LightningAttack", p, puField, deltaVal, relativity);
}

void applyProtoActionUnitTypeToTarget(string targetProto = "", string unitType = "", int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    trModifyProtounitActionUnitType(targetProto, "HandAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "ChargedHandAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "RangedAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "RangedAttackFlying", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "RangedAttackMyth", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "FlyingUnitAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "JumpAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "BuildingAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "AntiWallAttack", unitType, p, puField, deltaVal, relativity);
    trModifyProtounitActionUnitType(targetProto, "LightningAttack", unitType, p, puField, deltaVal, relativity);
}

void applyProtoActionSpecialEffectToTarget(string targetProto = "", int p = 0, int effectField = cOnHitEffectStun, string targetType = "All", int dmgType = -1, float duration = 0.0, float value = 0.0){
    if (effectField == cOnHitEffectAttach){
        enableProtoActionAttach(targetProto, p);
    }
    trProtounitActionSpecialEffect(targetProto, "HandAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "ChargedHandAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "RangedAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "RangedAttackFlying", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "RangedAttackMyth", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "FlyingUnitAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "JumpAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "BuildingAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "AntiWallAttack", p, effectField, targetType, dmgType, duration, value);
    trProtounitActionSpecialEffect(targetProto, "LightningAttack", p, effectField, targetType, dmgType, duration, value);
}

void applyProtoActionSpecialEffectProtoUnitToTarget(string targetProto = "", int p = 0, int effectField = cOnHitEffectStun, string targetType = "All", string protoUnitType = "", float duration = 1.0, float value = 0.0){
    if (effectField == cOnHitEffectAttach){
        enableProtoActionAttach(targetProto, p);
    }
    trProtounitActionSpecialEffectProtoUnit(targetProto, "HandAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "ChargedHandAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "RangedAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "RangedAttackFlying", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "RangedAttackMyth", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "FlyingUnitAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "JumpAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "BuildingAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "AntiWallAttack", p, effectField, targetType, protoUnitType, duration, value);
    trProtounitActionSpecialEffectProtoUnit(targetProto, "LightningAttack", p, effectField, targetType, protoUnitType, duration, value);
}

void applyProtoActionSpawnToTarget(string targetProto = "", int p = 0, int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0){
    trProtounitModifySpawnData(targetProto, p, kbProtoUnitGetName(spawnProtoID), eventType, delta, relativity, chance, lifespan);
}

void applyProtoActionToAllCards(int p = 0, int puField = 0, float deltaVal = 0.0, int relativity = 0){
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i = 0; i < params.size(); i++) {
        CardParameters param = params[i];
        string targetProto = param.getProtoUnit();
        applyProtoActionToTarget(targetProto, p, puField, deltaVal, relativity);
    }
}