const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction
const int BUFF_TYPE_PROTO_ACTION_UNIT_TYPE = 2; // trModifyProtounitActionUnitType

string[] g_allProtounits = default;

class Buff {
    bool m_init = false;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = -1;
    string[] m_unitTypes = default;
    int[] m_synergyTypes = default;

    void setBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffAction(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffActionUnitType(int[] synergyTypes = default, string[] unitTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION_UNIT_TYPE;
        m_synergyTypes = synergyTypes;
        m_unitTypes = unitTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    bool isEmpty() {
        return m_init == false;
    }

    void _executeCommand(string targetProto = "", int p = -1, float deltaVal = 0.0) {
        if (m_buffType == BUFF_TYPE_PROTO_DATA) {
            trModifyProtounitData(targetProto, p, m_puField, deltaVal, m_relativity);
        } 
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION) {
            trModifyProtounitAction(targetProto, "HandAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "RangedAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "BuildingAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "AntiWallAttack", p, m_puField, deltaVal, m_relativity);
        } 
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
            for (int u = 0; u < m_unitTypes.size(); u++) {
                string unitTypeName = m_unitTypes[u];
                trModifyProtounitActionUnitType(targetProto, "HandAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "RangedAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "BuildingAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "AntiWallAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
            }
        }
    }

    void applyBuff(int p = 0) {
        if (isEmpty()) { return; }

        CardParameters[] params = ProtoNameToCardParametersMap.getValues();
        for (int i = 0; i < params.size(); i++) {
            CardParameters param = params[i];
            if (m_synergyTypes.size() == 0){ // Apply to all
                _executeCommand(param.getProtoUnit(), p, m_delta);
                log(3, "Buffed all");
            }
            else{
                for (int j = 0; j < m_synergyTypes.size(); j++) {
                    int synergyType = m_synergyTypes[j];
                    if (param.isASynergy(synergyType)){
                        _executeCommand(param.getProtoUnit(), p, m_delta);
                        log(3, "Buffed " + synergyType);
                        break;
                    }
                }
            }
        }
    }

    void resetBuff(int p = 0) {
        if (isEmpty()) { return; }

        float invDelta = m_delta;
        if (m_relativity == relativityABSOLUTE) {
            invDelta = -m_delta;
        } else {
            invDelta = 1.0 - (m_delta - 1.0);
        }

        CardParameters[] params = ProtoNameToCardParametersMap.getValues();
        for (int i = 0; i < params.size(); i++) {
            CardParameters param = params[i];
            if (m_synergyTypes.size() == 0){ // Apply to all
                _executeCommand(param.getProtoUnit(), p, invDelta);
            }
            else{
                for (int j = 0; j < m_synergyTypes.size(); j++) {
                    int synergyType = m_synergyTypes[j];
                    if (param.isASynergy(synergyType)){
                        _executeCommand(param.getProtoUnit(), p, invDelta);
                        break;
                    }
                }
            }
        }
    }

    string getDescription() {
        if (isEmpty()) {
            return "Empty Buff";
        }

        string fieldName = "Unknown Stat";

        // 1. Map the protounit field to a readable UI name
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
            fieldName = "Bonus Damage";
        } else {
            switch (m_buffType) {
                case BUFF_TYPE_PROTO_DATA: {
                    switch (m_puField) {
                        case puFIELD_HACK_ARMOR: fieldName = "Hack Armor";
                        case puFIELD_PIERCE_ARMOR: fieldName = "Pierce Armor";
                        case puFIELD_CRUSH_ARMOR: fieldName = "Crush Armor";
                        case puFIELD_HITPOINTS: fieldName = "Max HP";
                        case puFIELD_SPEED: fieldName = "Movement Speed";
                        case puFIELD_RECHARGE: fieldName = "Recharge Rate";
                        case puFIELD_HP_REGEN: fieldName = "HP Regen";
                        case puFIELD_SHIELDS: fieldName = "Shields";
                        case puFIELD_ACTION_ALL_DMG: fieldName = "All Damage";
                        case puFIELD_ACTION_DIVINE: fieldName = "Divine Damage";
                    }
                }
                case BUFF_TYPE_PROTO_ACTION: {
                    switch (m_puField) {
                        case puFIELD_ACTION_HACK: fieldName = "Hack Damage";
                        case puFIELD_ACTION_PIERCE: fieldName = "Pierce Damage";
                        case puFIELD_ACTION_CRUSH: fieldName = "Crush Damage";
                        case puFIELD_ACTION_RANGE: fieldName = "Attack Range";
                        case puFIELD_ACTION_RATE_OF_FIRE: fieldName = "Rate of Fire";
                        case puFIELD_ACTION_DMG_AREA: fieldName = "Area Damage";
                        case puFIELD_ACTION_N_PROJECTILES: fieldName = "Projectiles";
                        case puFIELD_ACTION_ALL_DMG: fieldName = "All Damage";
                        case puFIELD_ACTION_DIVINE: fieldName = "Divine Damage";
                    }
                }
            }
        }

        // 2. Format the value based on relativity (Absolute vs Percent)    
        string valStr = "";
        if (m_relativity == relativityABSOLUTE) {
            if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
                int pct = (m_delta * 100.0) + 0.5;
                if (pct > 0) {
                    valStr = "+" + pct + "%";
                } else {
                    valStr = "" + pct + "%";
                }
            } 
            else if (m_puField == puFIELD_HP_REGEN || m_puField == puFIELD_SHIELDS) {   
                // Format decimal stats like HP regen and shields with tenths precision (+0.1)
                int tenthDelta = (m_delta * 10.0) + 0.5;
                string sign = "";
                if (tenthDelta > 0) {
                    sign = "+";
                }
                int wholePart = tenthDelta / 10;
                int decPart = tenthDelta % 10;
                if (decPart < 0) { decPart = -decPart; }
                valStr = sign + wholePart + "." + decPart;
            }
            else if (m_puField == puFIELD_RECHARGE) {
                // Force absolute recharge flat time to display as a reduction (-s)
                int intDelta = m_delta;
                if (intDelta > 0) {
                    valStr = "-" + intDelta + "s";
                } else {
                    valStr = "" + intDelta + "s"; 
                }
            }
            else {
                int intDelta = m_delta;
                if (m_delta > 0.0 && m_delta < 1.0) {
                    intDelta = (m_delta * 100.0) + 0.5;
                }

                if (intDelta > 0) {
                    valStr = "+" + intDelta;
                } else {
                    valStr = "" + intDelta;
                }
            }
        } else {
            // Handle percentage-based relativity cleanly with rounding
            int pct = 0;
            if (m_puField == puFIELD_ACTION_RATE_OF_FIRE && m_delta > 0.0 && m_delta < 1.0) {
                float speedIncrease = 1.0 - m_delta;
                pct = (speedIncrease * 100.0) + 0.5; 
            } else if (m_delta > -1.0 && m_delta < 1.0) {
                pct = (m_delta * 100.0) + 0.5;
            } else {
                pct = ((m_delta - 1.0) * 100.0) + 0.5; 
            }

            // Force recharge percentage reductions to display with a minus sign (-%)
            if (m_puField == puFIELD_RECHARGE) {
                if (pct > 0) {
                    valStr = "-" + pct + "%";
                } else {
                    valStr = "" + pct + "%";
                }
            } else {
                if (pct > 0) {
                    valStr = "+" + pct + "%";
                } else {
                    valStr = "" + pct + "%";
                }
            }
        }

        // 3. Format target unit types if it's a unit-type action buff, otherwise format synergies
        string targetStr = "";
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE && m_unitTypes.size() > 0) {
            targetStr = "vs ";
            for (int u = 0; u < m_unitTypes.size(); u++) {
                if (u > 0) {
                    targetStr = targetStr + ", ";
                }
                
                string rawName = m_unitTypes[u];
                string friendlyName = rawName;
                
                if (xsStringContains(rawName, "Infantry")) {
                    friendlyName = "Infantry";
                } else if (xsStringContains(rawName, "Cavalry")) {
                    friendlyName = "Cavalry";
                } else if (xsStringContains(rawName, "Archer")) {
                    friendlyName = "Archers";
                } else if (xsStringContains(rawName, "MythUnit")) {
                    friendlyName = "Myth Units";
                } else if (xsStringContains(rawName, "Hero")) {
                    friendlyName = "Heroes";
                } else if (xsStringContains(rawName, "Siege")) {
                    friendlyName = "Siege";
                }
                
                targetStr = targetStr + friendlyName;
            }
        } else {
            if (m_synergyTypes.size() == 0) {
                targetStr = "for All Units";
            } else {
                targetStr = "for ";
                for (int i = 0; i < m_synergyTypes.size(); i++) {
                    int sType = m_synergyTypes[i];
                    string sName = "Unknown";
                    
                    switch (sType) {
                        case SYNERGY_INDEX_INFANTRY: sName = "Infantry";
                        case SYNERGY_INDEX_RANGED: sName = "Ranged";
                        case SYNERGY_INDEX_CAVALRY: sName = "Cavalry";
                        case SYNERGY_INDEX_MYTH: sName = "Myth Units";
                        case SYNERGY_INDEX_HERO: sName = "Heroes";
                        case SYNERGY_INDEX_HEALER: sName = "Healers";
                        case SYNERGY_INDEX_SIEGE: sName = "Siege";
                        case SYNERGY_INDEX_BUILDING: sName = "Buildings";
                        case SYNERGY_INDEX_SOLDIER: sName = "Soldiers";
                    }
                    
                    if (i > 0) { 
                        targetStr = targetStr + ", "; 
                    }
                    targetStr = targetStr + sName;
                }
            }
        }

        return valStr + " " + fieldName + " " + targetStr;
    }
};

Buff createBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffData(synergyTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffAction(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffAction(synergyTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffActionUnitType(int[] synergyTypes = default, string[] unitTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffActionUnitType(synergyTypes, unitTypes, puField, delta, relativity);
    return buff;
}