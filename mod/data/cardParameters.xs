include "lib/rm_core.xs";

class CardParameters {

    int m_uuid = cMinInt;
    Parameters m_params;
    bool[] m_unitTypes = default;

    int getProtoID(){
        if (m_params.ints.size() < 4){
            return -1;
        }
        return m_params.ints[3];
    }

    bool isUnitType(int unitType = -1){
        xsSetContextPlayer(0);
        int protoID = getProtoID();
        return kbProtoUnitIsType(protoID, unitType);
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
            return -1;
        }
        return m_params.ints[2];
    }

    int getProtoID(){
        if (m_params.ints.size() < 3){
            return -1;
        }
        return m_params.ints[3];
    }

    string getStringData(){
        return "";
    }

    string getIconPath(){
        return toForwardSlash(kbProtoUnitGetIconPath(0, getProtoID()));
    }

    string getTitle(){
        return kbProtoUnitGetDisplayName(0, getProtoID());
    }

    float getInitalMaxHP(){
        if (m_params.floats.size() < 0){
            return 0.0;
        }
        return m_params.floats[0];
    }

    bool getUnitTypeFlag(int index = -1){
        if (index < 0 || index >= MAX_CARD_UNIT_TYPES){
            return false;
        }
        if (m_unitTypes.size() != MAX_CARD_UNIT_TYPES){
            if (m_params.ints.size() < 4 || m_params.ints[3] < 0){
                return false;
            }
            setCardParameters(getAge(), m_params.ints[3], getCost());
        }
        return m_unitTypes[index];
    }

    bool isInfantry(){ return getUnitTypeFlag(0);}
    bool isArcher(){ return (getUnitTypeFlag(1) || getUnitTypeFlag(9) || getUnitTypeFlag(11));}
    bool isCavalry(){ return getUnitTypeFlag(2) || getUnitTypeFlag(12);}
    bool isMythUnit(){ return getUnitTypeFlag(3) || getUnitTypeFlag(10) || getUnitTypeFlag(11) || getUnitTypeFlag(12);}
    bool isHero(){ return getUnitTypeFlag(4);}
    bool isHealer(){ return getUnitTypeFlag(5);}
    bool isSiege(){ return (getUnitTypeFlag(6) || getUnitTypeFlag(10));}
    bool isBuilding(){ return getUnitTypeFlag(7);}
    bool isSoldier(){ return getUnitTypeFlag(8);}
    bool isFrost(){ return getUnitTypeFlag(13);}
    bool isUndead(){ return getUnitTypeFlag(14);}
    bool isPoison(){ return getUnitTypeFlag(15);}
    bool isFire(){ return getUnitTypeFlag(16);}
    bool isLightning(){ return getUnitTypeFlag(17);}
    bool isBuilder(){ return getUnitTypeFlag(18);}
    bool isWilderness(){ return getUnitTypeFlag(19);}
    bool isSand(){ return getUnitTypeFlag(20);}

    bool isGreek() { return xsStringFindFirst(getIconPath(), "greek", 0, false) != -1; }
    bool isNorse() { return xsStringFindFirst(getIconPath(), "norse", 0, false) != -1; }
    bool isEgyptian() { return xsStringFindFirst(getIconPath(), "egypt", 0, false) != -1; }
    bool isAtlantean() { return xsStringFindFirst(getIconPath(), "atlantean", 0, false) != -1; }
    bool isChinese() { return xsStringFindFirst(getIconPath(), "chinese", 0, false) != -1; }
    bool isJapanese() { return xsStringFindFirst(getIconPath(), "japan", 0, false) != -1; }
    bool isAztec() { return xsStringFindFirst(getIconPath(), "aztec", 0, false) != -1; }

    bool isASynergy(int synergy = -1) {
        switch(synergy) {
            case SYNERGY_INDEX_INFANTRY: { return isInfantry(); }
            case SYNERGY_INDEX_RANGED: { return isArcher(); }
            case SYNERGY_INDEX_CAVALRY: { return isCavalry(); }
            case SYNERGY_INDEX_MYTH: { return isMythUnit(); }
            case SYNERGY_INDEX_HERO: { return isHero(); }
            case SYNERGY_INDEX_HEALER: { return isHealer(); }
            case SYNERGY_INDEX_SIEGE: { return isSiege(); }
            case SYNERGY_INDEX_SOLDIER: { return isSoldier(); }
            case SYNERGY_INDEX_FROST: { return isFrost(); }
            case SYNERGY_INDEX_UNDEAD: { return isUndead(); }
            case SYNERGY_INDEX_POISON: { return isPoison(); }
            case SYNERGY_INDEX_FIRE: { return isFire(); }
            case SYNERGY_INDEX_LIGHTNING: { return isLightning(); }
            case SYNERGY_INDEX_BUILDER: { return isBuilder(); }
            case SYNERGY_INDEX_WILDERNESS: { return isWilderness(); }
            case SYNERGY_INDEX_SAND: { return isSand(); }
        }
        return false;
    }

    bool isUnitUndeadType(int protoID = -1){
        switch(protoID){
            case cUnitTypeTzitzimitl: { return true; }
            case cUnitTypeOnmoraki: { return true; }
            case cUnitTypeShinigami: { return true; }
            case cUnitTypeSoulGuide: { return true; }
            case cUnitTypeAnubite: { return true; }
            case cUnitTypeDraugr: { return true; }
            case cUnitTypeEinheri: { return true; }
            case cUnitTypeShadeSPC: { return true; }
            case cUnitTypeMummy: { return true; }
            case cUnitTypeMictlantecuhtli: { return true; }
            case cUnitTypeHadesShade: { return true; }
            case cUnitTypeUmibozu: { return true; }
        }
        return false;
    }

    bool isUnitPoisonType(int protoID = -1){
        switch(protoID){
            case cUnitTypeScorpionMan: { return true; }
            case cUnitTypeWadjet: { return true; }
            case cUnitTypeScarab: { return true; }
            case cUnitTypeArgus: { return true; }
            case cUnitTypeFafnir: { return true; }
            case cUnitTypeMaquizcoatl: { return true; }
            case cUnitTypeXuanWu: { return true; }
            case cUnitTypePopocatepetl: { return true; }
            case cUnitTypeJorogumo: { return true; }
            case cUnitTypeMagumo: { return true; }
            case cUnitTypeMedusa: { return true; }
            case cUnitTypeChimera: { return true; }
            case cUnitTypePerseus: { return true; }
        }
        return isAztec() && isSoldier();
    }

    bool isUnitFrostType(int protoID = -1){
        switch(protoID){
            case cUnitTypeKingFolstag: { return true; }
            case cUnitTypeYukiOnna: { return true; }
            case cUnitTypeFireGiant: { return false; }
            case cUnitTypeFafnir: { return false; }
            case cUnitTypeGauntletLegendHalogi: { return false; }
            case cUnitTypePolaris: { return true; }
        }
        return isNorse();
    }

    bool isUnitFireType(int protoID = -1){
        switch(protoID){
            case cUnitTypeFireGiant: { return true; }
            case cUnitTypeNidhogg: { return true; }
            case cUnitTypeZhuQue: { return true; }
            case cUnitTypeQiLin: { return true; }
            case cUnitTypeWanyudo: { return true; }
            case cUnitTypeAsura: { return true; }
            case cUnitTypeFafnir: { return true; }
            case cUnitTypePhoenix: { return true; }
            case cUnitTypeFireSiphon: { return true; }
            case cUnitTypeChimera: { return true; }
            case cUnitTypeTeixiptlaHuitz: { return true; }
            case cUnitTypeSuperTeixiptlaHuitz: { return true; }
            case cUnitTypeGauntletLegendHalogi: { return true; }
        }
        return isChinese() & isArcher();
    }

    bool isUnitLightningType(int protoID = -1){
        switch(protoID){
            case cUnitTypeLykaonWolf: { return false; }
            case cUnitTypeSonOfOsiris: { return true; }
            case cUnitTypeArkantosGod: { return true; }
            case cUnitTypeYingLong: { return true; }
            case cUnitTypeManOWar: { return true; }
            case cUnitTypeTeixiptlaQuetz: { return true; }
            case cUnitTypeSuperTeixiptlaQuetz: { return true; }
            case cUnitTypeJunkozosen: { return true; }
            case cUnitTypeShinigami: { return true; }
            case cUnitTypeCirce: { return true; }
            case cUnitTypeRaiju: { return true; }
            case cUnitTypeHarumotoBlessed: { return true; }
        }
        return (isGreek() || isJapanese()) & (isInfantry() || isCavalry()) & isArcher() == false;
    }

    bool isUnitBuilderType(int protoID = -1){
        int[] actions = kbProtoUnitGetActionIDs(0, protoID);
        for (int i = 0; i < actions.size(); i++){
            if (actions[i] == cActionTypeBuild){
                return true;
            }
        }
        return protoID == cUnitTypeLykaonWolf;
    }

    bool isUnitWildernessType(int protoID = -1){
        switch(protoID){
            case cUnitTypeHamadryad: { return true; }
            case cUnitTypeFenrisWolfBrood: { return true; }
            case cUnitTypeRockGiant: { return true; }
            case cUnitTypeMountainGiant: { return true; }
            case cUnitTypeWadjet: { return true; }
            case cUnitTypeScarab: { return true; }
            case cUnitTypeLykaonWolf: { return true; }
            case cUnitTypeNemeanLion: { return true; }
            case cUnitTypeKamaitachi: { return true; }
            case cUnitTypeAyotochtli: { return true; }
            case cUnitTypeCentzonTotochtin: { return true; }
            case cUnitTypeJaguarRider: { return true; }
            case cUnitTypeQuimichinSpy: { return true; }
            case cUnitTypeStymphalianBird: { return true; }
            case cUnitTypeBehemoth: { return true; }
            case cUnitTypeCentaur: { return true; }
            case cUnitTypeMinotaur: { return true; }
            case cUnitTypeDryad: { return true; }
            case cUnitTypeChiron: { return true; }
            case cUnitTypeSatyr: { return true; }
            case cUnitTypeKamos: { return true; }
            case cUnitTypeIztaccihuatl: { return true; }
            case cUnitTypeOrnlu: { return true; }
            case cUnitTypePolaris: { return true; }
            case cUnitTypeKitsune: { return true; }
            case cUnitTypeMaquizcoatl: { return true; }
            case cUnitTypeRaiju: { return true; }
        }
        return false;
    }

    bool isUnitSandType(int protoID = -1){
        switch(protoID){
            case cUnitTypeSphinx: { return true; }
            case cUnitTypeAvenger: { return true; }
            case cUnitTypePetsuchos: { return true; }
            case cUnitTypeMummy: { return true; }
            case cUnitTypeGuardian: { return true; }
        }
        return isEgyptian() && (isSoldier() || isHero() || isSiege());
    }

    void setCardParameters(int age = 0, int protoID = -1, int cost = -1){
        Parameters params = createParameters();
        params.ints.add(-1); // placeholder for data
        params.ints.add(age);
        if (cost < 0){
            cost = kbProtoUnitGetCostTotal(protoID);
        }
        params.ints.add(cost);
        params.ints.add(protoID);
        params.floats.add(kbPlayerGetProtoStatFloat(1, protoID, cProtoStatMaxHP));

        m_params = params;
        m_uuid = g_uuid.getNextUUID();

        m_unitTypes = new bool(MAX_CARD_UNIT_TYPES, false);
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
        m_unitTypes[13] = isUnitFrostType(protoID);
        m_unitTypes[14] = isUnitUndeadType(protoID);
        m_unitTypes[15] = isUnitPoisonType(protoID);
        m_unitTypes[16] = isUnitFireType(protoID);
        m_unitTypes[17] = isUnitLightningType(protoID);
        m_unitTypes[18] = isUnitBuilderType(protoID);
        m_unitTypes[19] = isUnitWildernessType(protoID);
        m_unitTypes[20] = isUnitSandType(protoID);
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