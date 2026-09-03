include "lib/rm_core.xs";

class CardParameters {

    Parameters m_params;
    int m_uuid = cMinInt;
    bool[] m_unitTypes = default;

    string getProtoUnit(){
        if (m_params.strings.size() < 1){
            return "";
        }
        return m_params.strings[1];
    }

    bool isUnitType(string unitType = ""){
        xsSetContextPlayer(0);
        int unitID = trUnitCreateForced(getProtoUnit(), 0, 0, 0, -1, 0, false);
        if (unitID < 0) {
            errorLog(getProtoUnit() + " failed to spawn");
            return false;
        }
        selectSingle(unitID);
        if (kbProtoUnitIsType(kbUnitGetProtoUnitID(unitID), kbGetUnitTypeID(unitType)) != false){
            trUnitDestroy(false);
            log(3, "Is " + unitType + " unit type.");
            return true;
        }
        trUnitDestroy(false);
        log(3, "Should never see this message except at the start of the game.");
        return false;
    }

    void setCardParameters(int age = 0, int protoID = -1, int cost = -1){
        Parameters params = createParameters();
        params.ints.add(-1); // placeholder for data
        params.ints.add(age);
        if (cost < 0){
            cost = kbProtoUnitGetCostTotal(protoID);
        }
        params.ints.add(cost);
        params.strings.add(""); // placeholder for data
        params.strings.add(kbProtoUnitGetName(protoID));
        params.strings.add(toForwardSlash(kbProtoUnitGetIconPath(0, protoID)));
        params.strings.add(kbProtoUnitGetDisplayName(0, protoID));
        m_params = params;
        m_uuid = g_uuid.getNextUUID();

        m_unitTypes = new bool(MAX_UNIT_TYPES, false);
        m_unitTypes[0] = isUnitType(UNIT_TYPE_INFANTRY);
        m_unitTypes[1] = isUnitType(UNIT_TYPE_ARCHER);
        m_unitTypes[2] = isUnitType(UNIT_TYPE_CAVALRY);
        m_unitTypes[3] = isUnitType(UNIT_TYPE_MYTH);
        m_unitTypes[4] = isUnitType(UNIT_TYPE_HERO);
        m_unitTypes[5] = isUnitType(UNIT_TYPE_HEALER);
        m_unitTypes[6] = isUnitType(UNIT_TYPE_SIEGE);
        m_unitTypes[7] = isUnitType(UNIT_TYPE_BUILDING);
        m_unitTypes[8] = isUnitType(UNIT_TYPE_SOLDIER);
        m_unitTypes[9] = isUnitType(UNIT_TYPE_RANGED);
        m_unitTypes[10] = isUnitType(UNIT_TYPE_MYTH_SIEGE);
        m_unitTypes[11] = isUnitType(UNIT_TYPE_MYTH_RANGED);
        m_unitTypes[12] = isUnitType(UNIT_TYPE_MYTH_CAVALRY);
    }

    int getIntData(){
        if (m_params.ints.size() < 0){
            return -1;
        }
        return m_params.ints[0];
    }

    int getAge(){
        if (m_params.ints.size() < 1){
            return 0;
        }
        return m_params.ints[1];
    }

    int getCost(){
        if (m_params.ints.size() < 2){
            return 999;
        }
        return m_params.ints[2];
    }

    string getStringData(){
        if (m_params.strings.size() < 0){
            return "";
        }
        return m_params.strings[0];
    }

    string getIconPath(){
        if (m_params.strings.size() < 2){
            return "";
        }
        return m_params.strings[2];
    }

    string getTitle(){
        if (m_params.strings.size() < 3){
            return "";
        }
        return m_params.strings[3];
    }

    bool isInfantry(){ return m_unitTypes[0];}
    bool isArcher(){ return (m_unitTypes[1] || m_unitTypes[9] || m_unitTypes[11]);}
    bool isCavalry(){ return m_unitTypes[2] || m_unitTypes[12];}
    bool isMythUnit(){ return m_unitTypes[3] || m_unitTypes[10] || m_unitTypes[11] || m_unitTypes[12];}
    bool isHero(){ return m_unitTypes[4];}
    bool isHealer(){ return m_unitTypes[5];}
    bool isSiege(){ return (m_unitTypes[6] || m_unitTypes[10]);}
    bool isBuilding(){ return m_unitTypes[7];}
    bool isSoldier(){ return m_unitTypes[8];}

    bool isGreek() { return xsStringFindFirst(getIconPath(), "greek", 0, false) != -1; }
    bool isNorse() { return xsStringFindFirst(getIconPath(), "norse", 0, false) != -1; }
    bool isEgyptian() { return xsStringFindFirst(getIconPath(), "egypt", 0, false) != -1; }
    bool isAtlantean() { return xsStringFindFirst(getIconPath(), "atlantean", 0, false) != -1; }
    bool isChinese() { return xsStringFindFirst(getIconPath(), "chinese", 0, false) != -1; }
    bool isJapanese() { return xsStringFindFirst(getIconPath(), "japan", 0, false) != -1; }
    bool isAztec() { return xsStringFindFirst(getIconPath(), "aztec", 0, false) != -1; }

    bool isASynergy(int synergy = -1){
        switch(synergy){
            case SYNERGY_INDEX_INFANTRY: return isInfantry();
            case SYNERGY_INDEX_RANGED: return isArcher();
            case SYNERGY_INDEX_CAVALRY: return isCavalry();
            case SYNERGY_INDEX_MYTH: return isMythUnit();
            case SYNERGY_INDEX_HERO: return isHero();
            case SYNERGY_INDEX_HEALER: return isHealer();
            case SYNERGY_INDEX_SIEGE: return isSiege();
            case SYNERGY_INDEX_BUILDING: return isBuilding();
            case SYNERGY_INDEX_SOLDIER: return isSoldier();
        }
        return false;
    }
};

Parameters cardParameterstoParametersCopy(ref CardParameters params){
    Parameters cardParams = createParameters();
    for(int j = 0; j < params.m_params.ints.size(); j++) {
        cardParams.ints.add(params.m_params.ints[j]);
    }
    for(int j = 0; j < params.m_params.strings.size(); j++) {
        cardParams.strings.add(params.m_params.strings[j]);
    }
    return cardParams;
}