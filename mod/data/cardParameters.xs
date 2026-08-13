include "lib/rm_core.xs";

class CardParameters {

    Parameters m_params;
    int[] m_unitTypes = default;

    void setCardParameters(int age = 0, int cost = 1,
                           string protounit = "", string titleText = "", string hoverText = "", string iconPath = ""){
        Parameters params = createParameters();
        params.ints.add(-1); // placeholder for data
        params.ints.add(age);
        params.ints.add(cost);
        params.strings.add(""); // placeholder for data
        params.strings.add(protounit);
        params.strings.add(iconPath);
        params.strings.add(titleText);
        params.strings.add(hoverText);
        m_params = params;
        m_unitTypes = new int(8, -1);
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

    string getProtoUnit(){
        if (m_params.strings.size() < 1){
            return "";
        }
        return m_params.strings[1];
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

    bool isUnitType(string unitType = ""){
        xsSetContextPlayer(0);
        trUnitSelectClear();
        int unitID = trUnitCreate(getProtoUnit(), 0, 0, 0, -1, 0, false);
        trUnitSelectByID(unitID);
        if (kbProtoUnitIsType(kbUnitGetProtoUnitID(unitID), kbGetUnitTypeID(unitType)) != false){
            trUnitDestroy(true);
            trUnitSelectClear();
            log(3, "Is " + unitType + " unit type.");
            return true;
        }
        trUnitDestroy(true);
        trUnitSelectClear();
        return false;
    }

    bool isUnitTypeCache(int index = 0, string unitType = ""){
        if (m_unitTypes[index] == -1){
            m_unitTypes[index] = isUnitType(unitType) ? 1 : 0;
        }
        return m_unitTypes[index] == 1;
    }

    bool isInfantry(){ return isUnitTypeCache(0, "AbstractInfantry");}
    bool isArcher(){ return isUnitTypeCache(1, "AbstractArcher");}
    bool isCavalry(){ return isUnitTypeCache(2, "AbstractCavalry");}
    bool isMythUnit(){ return isUnitTypeCache(3, "MythUnit");}
    bool isHero(){ return isUnitTypeCache(4, "Hero");}
    bool isHealer(){ return isUnitTypeCache(5, "AbstractHealer");}
    bool isSiege(){ return isUnitTypeCache(6, "AbstractSiegeWeapon");}
    bool isBuilding(){ return isUnitTypeCache(7, "isBuilding");}

    bool isGreek() { return xsStringFindFirst(getIconPath(), "greek", 0, false) != -1; }
    bool isNorse() { return xsStringFindFirst(getIconPath(), "norse", 0, false) != -1; }
    bool isEgyptian() { return xsStringFindFirst(getIconPath(), "egypt", 0, false) != -1; }
    bool isAtlantean() { return xsStringFindFirst(getIconPath(), "atlantean", 0, false) != -1; }
    bool isChinese() { return xsStringFindFirst(getIconPath(), "chinese", 0, false) != -1; }
    bool isJapanese() { return xsStringFindFirst(getIconPath(), "japan", 0, false) != -1; }
    bool isAztec() { return xsStringFindFirst(getIconPath(), "aztec", 0, false) != -1; }

};

Parameters createParametersCopy(CardParameters params){
    Parameters cardParams = createParameters();
    for(int j = 0; j < params.m_params.ints.size(); j++) {
        cardParams.ints.add(params.m_params.ints[j]);
    }
    for(int j = 0; j < params.m_params.strings.size(); j++) {
        cardParams.strings.add(params.m_params.strings[j]);
    }
    return cardParams;
}