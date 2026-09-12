const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction
const int BUFF_TYPE_PROTO_ACTION_UNIT_TYPE = 2; // trModifyProtounitActionUnitType
const int BUFF_TYPE_PROTO_ACTION_SPECIAL = 3; // trProtounitActionSpecialEffect
const int BUFF_TYPE_PROTO_ACTION_SPAWN = 4; // trProtounitModifySpawnData

string[] g_allProtounits = default;

StringToFloatHashMap g_buffToCounterMap;
string getBuffToCounterKey(int p = 0, int synergyIndex = -1, int buffType = BUFF_TYPE_PROTO_DATA, string tag = ""){
    return ""+p+""+synergyIndex+""+buffType+""+tag;
}

class Buff {
    int m_synergyIndex = -1;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = cXSRelativityAbsolute;

    string m_unitType = ""; // For targeting a single unit type
    string m_attachProtoUnit = ""; // For attaching VFXs

    // Fields for trProtounitActionSpecialEffect
    int m_effectField = -1;
    float m_duration = 0.0;
    int m_dmgType = 0;

    // Fields for trProtounitModifySpawnData
    int m_spawnProtoID = -1;
    int m_eventType = -1;
    float m_chance = -1.0;
    float m_lifespan = -1.0;

    string[] m_unitTypes = default;
    int[] m_synergyTypes = default;

    void setBuffData(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_synergyIndex = synergyIndex;
    }

    void setBuffAction(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_synergyIndex = synergyIndex;
    }

    void setBuffActionUnitType(int synergyIndex = -1, int[] synergyTypes = default, string[] unitTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION_UNIT_TYPE;
        m_synergyTypes = synergyTypes;
        m_unitTypes = unitTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_synergyIndex = synergyIndex;
    }

    void setBuffSpecialAction(int synergyIndex = -1, int[] synergyTypes = default, int effectField = -1, int dmgType = -1, float duration = 0.0, float delta = 0.0, string attachProtoUnit = "") {
        m_buffType = BUFF_TYPE_PROTO_ACTION_SPECIAL;
        m_synergyTypes = synergyTypes;
        m_effectField = effectField;
        m_dmgType = dmgType;
        m_duration = duration;
        m_delta = delta;
        m_attachProtoUnit = attachProtoUnit;
        m_synergyIndex = synergyIndex;
    }

    void setBuffSpawnAction(int synergyIndex = -1, int[] synergyTypes = default, int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0){
        m_buffType = BUFF_TYPE_PROTO_ACTION_SPAWN;
        m_synergyTypes = synergyTypes;
        m_spawnProtoID = spawnProtoID;
        m_eventType = eventType;
        m_delta = delta;
        m_relativity = relativity;
        m_chance = chance;
        m_lifespan = lifespan;
        m_synergyIndex = synergyIndex;
    }

    bool isEmpty() {
        return m_synergyIndex < 0;
    }

    void _executeCommand(string targetProto = "", int p = -1, float delta = 0.0) {
        switch(m_buffType){
            case BUFF_TYPE_PROTO_DATA: { trModifyProtounitData(targetProto, p, m_puField, delta, m_relativity); }
            case BUFF_TYPE_PROTO_ACTION: { applyProtoActionToTarget(targetProto, p, m_puField, delta, m_relativity); }
            case BUFF_TYPE_PROTO_ACTION_SPECIAL: { applyProtoActionSpecialEffectToTarget(targetProto, p, m_effectField, "All", 
                g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType")),
                g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration")), 
                g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value")));
            }
            case BUFF_TYPE_PROTO_ACTION_UNIT_TYPE: {
                for (int u = 0; u < m_unitTypes.size(); u++) {
                    applyProtoActionUnitTypeToTarget(targetProto, m_unitTypes[u], p, m_puField, delta, m_relativity);
                }
            }
            case BUFF_TYPE_PROTO_ACTION_SPAWN: {
                applyProtoActionSpawnToTarget(targetProto, p, m_spawnProtoID, m_eventType, delta, m_relativity, m_chance, m_lifespan);
            }
        }
        if (m_attachProtoUnit != ""){
            applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, cOnHitEffectAttach, "All", m_attachProtoUnit,
                g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration")), 0.0);
        }
    }

    void applyBuff(int p = 0) {
        if (isEmpty()) { return; }

        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL){
            float currDmgType = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"), currDmgType + m_dmgType);
            float currValue = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"), currValue + m_delta);
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"), currDuration + m_duration);
        }

        if (m_unitType == ""){
            CardParameters[] params = g_protoNameToCardParametersMap.getValues();
            for (int i = 0; i < params.size(); i++) {
                CardParameters param = params[i];
                if (m_synergyTypes.size() == 0){ // Apply to all cards
                    _executeCommand(param.getProtoUnit(), p, m_delta);
                }
                else{
                    for (int j = 0; j < m_synergyTypes.size(); j++) {
                        int synergyType = m_synergyTypes[j];
                        if (param.isASynergy(synergyType)){
                            _executeCommand(param.getProtoUnit(), p, m_delta);
                            break;
                        }
                    }
                }
            }
        }
        else { // Apply to anything, includes non-cards
            _executeCommand(m_unitType, p, m_delta);
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
            float currDmgType = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"), currDmgType + m_dmgType);
            float currValue = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"), currValue + invDelta);
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"), currDuration - m_duration);
        }

        if (m_unitType == ""){
            CardParameters[] params = g_protoNameToCardParametersMap.getValues();
            for (int i = 0; i < params.size(); i++) {
                CardParameters param = params[i];
                if (m_synergyTypes.size() == 0){ // Apply to all cards
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
        else { // Apply to anything, includes non-cards
            _executeCommand(m_unitType, p, invDelta);
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
                case cOnHitEffectDamageOverTime: fieldName = "DOT";
                case cOnHitEffectLifesteal: fieldName = "Lifesteal";
                case cOnHitEffectThrow: fieldName = "Throw";
                case cOnHitEffectProgFreezeSpeed: fieldName = "to Progressive Freeze";
            }
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPAWN) {
            string spawnName = kbProtoUnitGetName(m_spawnProtoID);
            string eventName = "UnknownEvent";
            switch (m_eventType) {
                case cSpawnEventTypeDead: eventName = "Death";
                case cSpawnEventTypeKilled: eventName = "Killed";
                case cSpawnEventTypeBirth: eventName = "Birth";
                case cSpawnEventTypeBuild: eventName = "Build";
                case cSpawnEventTypeMutate: eventName = "Mutate";
                case cSpawnEventTypeHit: eventName = "Hit";
                case cSpawnEventTypeHitGround: eventName = "Hit Ground";
                case cSpawnEventTypeRevertToSocket: eventName = "Revert to Socket";
                case cSpawnEventTypeHitWater: eventName = "Hit Water";
                case cSpawnEventTypeSelfDestruct: eventName = "Self Destruct";
            }
            fieldName = spawnName + " on " + eventName;
        } 
        else {
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
            }
            else if (m_effectField == cOnHitEffectProgFreezeSpeed) {
                int seconds = m_dmgType / 1000; 
                if (m_duration > 0.0 && seconds == 0) {
                    seconds = 1; 
                }

                if (seconds > 0) {
                    valStr = "+" + seconds + "s";
                } else {
                    valStr = "" + seconds + "s";
                }
            }
            else {
                // Handle decimals properly instead of casting to int directly
                int tenthDelta = (m_delta * 10.0) + 0.5;
                string sign = "";
                if (tenthDelta > 0) {
                    sign = "+";
                }
                int wholePart = tenthDelta / 10;
                int decPart = tenthDelta % 10;
                if (decPart < 0) { decPart = -decPart; }
                
                if (decPart > 0) {
                    valStr = sign + wholePart + "." + decPart;
                } else {
                    valStr = sign + wholePart;
                }
            }
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPAWN) {
            int intDelta = m_delta;
            if (m_delta > 0.0) {
                intDelta = (m_delta + 0.5);
            } else if (m_delta < 0.0) {
                intDelta = (m_delta - 0.5);
            }

            if (intDelta > 0) {
                valStr = "+" + intDelta;
            } else {
                valStr = "" + intDelta;
            }
        }
        else if (m_relativity == cXSRelativityAbsolute) {
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
        } 
        else {
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
            if (m_unitType != ""){
                targetStr = "for all " + m_unitType + "s";
            }
            else if (m_synergyTypes.size() == 0) {
                targetStr = "for all cards";
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
                        case SYNERGY_INDEX_SOLDIER: sName = "Soldiers";
                        case SYNERGY_INDEX_FROST: sName = "Frost";
                        case SYNERGY_INDEX_UNDEAD: sName = "Undead";
                        case SYNERGY_INDEX_POISON: sName = "Poisonous";
                        case SYNERGY_INDEX_FIRE: sName = "Fire";
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

Buff createBuffData(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffData(synergyIndex, synergyTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffAction(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffAction(synergyIndex, synergyTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffActionUnitType(int synergyIndex = -1, int[] synergyTypes = default, string[] unitTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffActionUnitType(synergyIndex, synergyTypes, unitTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffSpecialAction(int synergyIndex = -1, int[] synergyTypes = default, int effectField = -1, int dmgType = -1, float duration = 0.0, float delta = 0.0, string attachProtoUnit = ""){
    Buff buff;
    buff.setBuffSpecialAction(synergyIndex, synergyTypes, effectField, dmgType, duration, delta, attachProtoUnit);
    return buff;
}

Buff createBuffSpawnAction(int synergyIndex = -1, int[] synergyTypes = default, int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0){
    Buff buff;
    buff.setBuffSpawnAction(synergyIndex, synergyTypes, spawnProtoID, eventType, delta, relativity, chance, lifespan);
    return buff;
}

Buff createBuffActionSingle(int synergyIndex = -1, string unitType = "", int puField = -1, float delta = 0.0, int relativity = -1){
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffAction(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.m_unitType = unitType;
    return buff;
}

Buff createBuffDataSingle(int synergyIndex = -1, string unitType = "", int puField = -1, float delta = 0.0, int relativity = -1){
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffData(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.m_unitType = unitType;
    return buff;
}

Buff createBuffSpawnActionSingle(int synergyIndex = -1, string unitType = "", int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0){
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffSpawnAction(synergyIndex, synergyTypes, spawnProtoID, eventType, delta, relativity, chance, lifespan);
    buff.m_unitType = unitType;
    return buff;
}