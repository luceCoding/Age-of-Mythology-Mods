const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction

string[] g_allProtounits = default;

class Buff {
    bool m_init = false;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = -1;
    int[] m_synergyTypes = default;

    void setBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffDataForAll(int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
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

    void setBuffActionForAll(int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION;
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
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION) {
            trModifyProtounitAction(targetProto, "HandAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "RangedAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "BuildingAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "AntiWallAttack", p, m_puField, deltaVal, m_relativity);
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
                }
            }
        }

        // 2. Format the value based on relativity (Absolute vs Percent)
        string valStr = "";
        if (m_relativity == relativityABSOLUTE) {
            
            // XS automatically truncates the float here, dropping the .000000
            int intDelta = m_delta; 

            if (intDelta > 0) {
                valStr = "+" + intDelta;
            } else {
                valStr = "" + intDelta;
            }
        } else {
            // Percent calculation (e.g., 1.1 becomes +10%, 0.9 becomes -10%)
            float pctFloat = (m_delta - 1.0) * 100.0;
            int pct = pctFloat; // Truncates here as well

            if (pct > 0) {
                valStr = "+" + pct + "%";
            } else {
                valStr = "" + pct + "%";
            }
        }

        // 3. Format the target synergies
        string targetStr = "";
        if (m_synergyTypes.size() == 0) {
            targetStr = "All Units";
        } else {
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

        return valStr + " " + fieldName + " for " + targetStr;
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