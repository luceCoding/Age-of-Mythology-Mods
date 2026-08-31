const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction
const int BUFF_TYPE_PROTO_ACTION_UNIT_TYPE = 2; // trModifyProtounitActionUnitType
const int BUFF_TYPE_PROTO_ACTION_SPECIAL = 3; // trProtounitActionSpecialEffect

string[] g_allProtounits = default;
float[] g_special_action_counter = default;

class Buff {
    bool m_init = false;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = -1;
    string[] m_unitTypes = default;
    int[] m_synergyTypes = default;

    // Fields specifically for trProtounitActionSpecialEffect
    int m_effectField = -1;
    float m_duration = 0.0;

    void setBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
        if (g_special_action_counter.size() == 0){
            g_special_action_counter = new float(cNumberPlayers+1, 0.0);
        }
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

    void setBuffSpecialAction(int[] synergyTypes = default, int effectField = -1, float duration = 0.0, float deltaVal = 0.0) {
        m_buffType = BUFF_TYPE_PROTO_ACTION_SPECIAL;
        m_synergyTypes = synergyTypes;
        m_effectField = effectField;
        m_duration = duration;
        m_delta = deltaVal;
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
            trModifyProtounitAction(targetProto, "LightningAttack", p, m_puField, deltaVal, m_relativity);
        } 
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
            for (int u = 0; u < m_unitTypes.size(); u++) {
                string unitTypeName = m_unitTypes[u];
                trModifyProtounitActionUnitType(targetProto, "HandAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "RangedAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "BuildingAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "AntiWallAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
                trModifyProtounitActionUnitType(targetProto, "LightningAttack", unitTypeName, p, m_puField, deltaVal, m_relativity);
            }
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            trProtounitActionSpecialEffect(targetProto, "HandAttack", p, m_effectField, "All", -1, m_duration, g_special_action_counter[p]);
            trProtounitActionSpecialEffect(targetProto, "RangedAttack", p, m_effectField, "All", -1, m_duration, g_special_action_counter[p]);
            trProtounitActionSpecialEffect(targetProto, "BuildingAttack", p, m_effectField, "All", -1, m_duration, g_special_action_counter[p]);
            trProtounitActionSpecialEffect(targetProto, "AntiWallAttack", p, m_effectField, "All", -1, m_duration, g_special_action_counter[p]);
            trProtounitActionSpecialEffect(targetProto, "LightningAttack", p, m_effectField, "All", -1, m_duration, g_special_action_counter[p]);
        }
    }

    void applyBuff(int p = 0) {
        if (isEmpty()) { return; }

        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL){
            g_special_action_counter[p] = g_special_action_counter[p] + m_delta;
        }

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
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            invDelta = -m_delta;
        } else if (m_relativity == cXSRelativityAbsolute) {
            invDelta = -m_delta;
        } else {
            invDelta = 1.0 - (m_delta - 1.0);
        }

        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL){
            g_special_action_counter[p] = g_special_action_counter[p] + invDelta;
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
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            switch (m_effectField) {
                case cOnHitEffectStun: fieldName = "Stun";
                case cOnHitEffectSnare: fieldName = "Snare";
                case cOnHitEffectDamageOverTime: fieldName = "Damage over Time";
                case cOnHitEffectLifesteal: fieldName = "Lifesteal";
                case cOnHitEffectThrow: fieldName = "Throw";
            }
        } else {
            switch (m_buffType) {
                case BUFF_TYPE_PROTO_DATA: {
                    switch (m_puField) {
                        case cXSProtoEffectArmorHack: fieldName = "Hack Armor";
                        case cXSProtoEffectArmorPierce: fieldName = "Pierce Armor";
                        case cXSProtoEffectArmorCrush: fieldName = "Crush Armor";
                        case cXSProtoEffectHitpoints: fieldName = "Max HP";
                        case cXSProtoEffectSpeed: fieldName = "Movement Speed";
                        case cXSProtoEffectRechargeTime: fieldName = "Recharge Rate";
                        case cXSProtoEffectUnitRegenRate: fieldName = "HP Regen";
                        case cXSProtoEffectMaxShieldPoints: fieldName = "Shields";
                        case cXSActionEffectDamageAll: fieldName = "All Damage";
                        case cXSActionEffectDamageDivine: fieldName = "Divine Damage";
                    }
                }
                case BUFF_TYPE_PROTO_ACTION: {
                    switch (m_puField) {
                        case cXSActionEffectDamageHack: fieldName = "Hack Damage";
                        case cXSActionEffectDamagePierce: fieldName = "Pierce Damage";
                        case cXSActionEffectDamageCrush: fieldName = "Crush Damage";
                        case cXSActionEffectRange: fieldName = "Attack Range";
                        case cXSActionEffectROF: fieldName = "Rate of Fire";
                        case cXSActionEffectDamageArea: fieldName = "Area Damage";
                        case cXSActionEffectNumProjectiles: fieldName = "Projectiles";
                        case cXSActionEffectDamageAll: fieldName = "All Damage";
                        case cXSActionEffectDamageDivine: fieldName = "Divine Damage";
                    }
                }
            }
        }

        // 2. Format the value based on relativity / type    
        string valStr = "";
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            if (m_effectField == cOnHitEffectLifesteal) {
                int pct = (m_delta * 100.0) + 0.5;
                if (pct > 0) {
                    valStr = "+" + pct + "%";
                } else {
                    valStr = "" + pct + "%";
                }
            } else {
                int intDelta = m_delta;
                if (intDelta > 0) {
                    valStr = "+" + intDelta;
                } else {
                    valStr = "" + intDelta;
                }
            }
        } else if (m_relativity == cXSRelativityAbsolute) {
            if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
                int pct = (m_delta * 100.0) + 0.5;
                if (pct > 0) {
                    valStr = "+" + pct + "%";
                } else {
                    valStr = "" + pct + "%";
                }
            } 
            else if (m_puField == cXSProtoEffectUnitRegenRate || m_puField == cXSProtoEffectMaxShieldPoints) {   
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
            else if (m_puField == cXSProtoEffectRechargeTime) {
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
            int pct = 0;
            if (m_puField == cXSActionEffectROF && m_delta > 0.0 && m_delta < 1.0) {
                float speedIncrease = 1.0 - m_delta;
                pct = (speedIncrease * 100.0) + 0.5; 
            } else if (m_delta > -1.0 && m_delta < 1.0) {
                pct = (m_delta * 100.0) + 0.5;
            } else {
                pct = ((m_delta - 1.0) * 100.0) + 0.5; 
            }

            if (m_puField == cXSProtoEffectRechargeTime) {
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

        // 3. Format target unit types or synergies
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

Buff createBuffSpecialAction(int[] synergyTypes = default, int effectField = -1, float duration = 0.0, float deltaVal = 0.0){
    Buff buff;
    buff.setBuffSpecialAction(synergyTypes, effectField, duration, deltaVal);
    return buff;
}