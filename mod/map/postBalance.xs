
void applyHeroNerfAgainstSoldier(ref CardParameters params){
    if (params.isHero()){
        string protoName = params.getProtoUnit();
        for(int p = 0; p <= cNumberPlayers; p++) {
            applyProtoActionUnitTypeToTarget(protoName, UNIT_TYPE_SOLDIER, p, cXSActionProtoEffectDamageBonus, -0.25, cXSRelativityAbsolute);
        }
    }
    if (params.isSoldier()){
        string protoName = params.getProtoUnit();
        for(int p = 0; p <= cNumberPlayers; p++) {
            applyProtoActionUnitTypeToTarget(protoName, UNIT_TYPE_HERO, p, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAbsolute);
        }
    }
}

void postApplyBalancePatch(){
    CardParameters[] params = g_protoNameToCardParametersMap.getValues();
    for (int i=0; i<params.size(); i++){
        CardParameters param = params[i];
        applyHeroNerfAgainstSoldier(param);
    }
}