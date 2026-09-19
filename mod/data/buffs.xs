const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction
const int BUFF_TYPE_PROTO_ACTION_UNIT_TYPE = 2; // trModifyProtounitActionUnitType
const int BUFF_TYPE_PROTO_ACTION_SPECIAL = 3; // trProtounitActionSpecialEffect
const int BUFF_TYPE_PROTO_ACTION_SPAWN = 4; // trProtounitModifySpawnData
const int BUFF_TYPE_LAMBDA_ONLY = 5;
const int BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO = 6;

string[] g_allProtounits = default;

StringToFloatHashMap g_buffToCounterMap;

string getBuffToCounterKey(int p = 0, int synergyIndex = -1, int buffType = BUFF_TYPE_PROTO_DATA, string tag = ""){
    return "" + p + "_" + synergyIndex + "_" + buffType + "_" + tag;
}

class Buff {
    int m_synergyIndex = -1;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = cXSRelativityAbsolute;

    string m_unitType = ""; // For targeting a single unit type
    string m_withProtoUnitType = "";

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

    // Template string field (e.g., "{val} {stat} {target}" or "{target} gain {val} {stat}")
    string m_descTemplate = "";

    // Optional Callback Function Handle
    void(string, int, float) m_callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {};

    void setCallback(void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
        m_callback = callback;
    }

    void setTemplate(string templateStr = "") {
        m_descTemplate = templateStr;
    }

    void setBuffLambdaOnly(int synergyIndex = -1, int[] synergyTypes = default) {
        m_buffType = BUFF_TYPE_LAMBDA_ONLY;
        m_synergyTypes = synergyTypes;
        m_delta = 1.0;
        m_synergyIndex = synergyIndex;
    }

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

    void setBuffSpecialAction(int synergyIndex = -1, int[] synergyTypes = default, int effectField = -1, int dmgType = -1, float duration = 0.0, float delta = 0.0) {
        m_buffType = BUFF_TYPE_PROTO_ACTION_SPECIAL;
        m_synergyTypes = synergyTypes;
        m_effectField = effectField;
        m_dmgType = dmgType;
        m_duration = duration;
        m_delta = delta;
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

    void setBuffSpecialActionWithProto(int synergyIndex = -1, int[] synergyTypes = default, int effectField = cOnHitEffectAttach, int withProtoUnitType = -1, float duration = 0.0) {
        m_buffType = BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO;
        m_synergyTypes = synergyTypes;
        m_effectField = effectField;
        m_withProtoUnitType = kbProtoUnitGetName(withProtoUnitType);
        m_duration = duration;
        m_synergyIndex = synergyIndex;
    }

    bool isEmpty() {
        return m_synergyIndex < 0;
    }

    void _executeCommand(string targetProto = "", int p = -1, float delta = 0.0) {
        switch(m_buffType){
            case BUFF_TYPE_LAMBDA_ONLY: {
                // Skips protounit engine modifications; executes only m_callback below
                break;
            }
            case BUFF_TYPE_PROTO_DATA: { 
                trModifyProtounitData(targetProto, p, m_puField, delta, m_relativity); 
            }
            case BUFF_TYPE_PROTO_ACTION: { 
                applyProtoActionToTarget(targetProto, p, m_puField, delta, m_relativity); 
            }
            case BUFF_TYPE_PROTO_ACTION_SPECIAL: { 
                applyProtoActionSpecialEffectToTarget(targetProto, p, m_effectField, "All", 
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType")),
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration")), 
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value")));
            }
            case BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO: {
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, "All", m_withProtoUnitType,
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration")), 0.0);
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, kbProtoUnitGetName(cUnitTypeBuilding), m_withProtoUnitType, 0.0, 0.0);
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, kbProtoUnitGetName(cUnitTypeSkyLantern), m_withProtoUnitType, 0.0, 0.0);
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, kbProtoUnitGetName(cUnitTypeMinionReincarnated), m_withProtoUnitType, 0.0, 0.0);
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, kbProtoUnitGetName(cUnitTypeTlacanexquimilli), m_withProtoUnitType, 0.0, 0.0);
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, kbProtoUnitGetName(cUnitTypeTartarianSpawn),, m_withProtoUnitType, 0.0, 0.0);
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

        // Trigger custom callback lambda
        m_callback(targetProto, p, delta);
    }

    void applyBuff(int p = 0) {
        if (isEmpty()) { return; }

        if (m_buffType == BUFF_TYPE_LAMBDA_ONLY) {
            _executeCommand("", p, m_delta);
            return;
        }

        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL){
            float currDmgType = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"), currDmgType + m_dmgType);
            float currValue = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"), currValue + m_delta);
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"), currDuration + m_duration);
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO){
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration"), currDuration + m_duration);
        }

        if (m_unitType == ""){

            if (m_synergyTypes.size() == 0){ // Apply to all cards
                string[] protoNames = g_protoNameToCardParametersMap.getKeys();
                for (int i = 0; i < protoNames.size(); i++) {
                    _executeCommand(protoNames[i], p, m_delta);
                }
            }
            else { // Apply to only certain synergies
                CardParameters[] params = g_protoNameToCardParametersMap.getValues();
                for (int i = 0; i < params.size(); i++){
                    CardParameters param = params[i];
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

        if (m_buffType == BUFF_TYPE_LAMBDA_ONLY) {
            _executeCommand("", p, invDelta);
            return;
        }

        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL){
            float currDmgType = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType"), currDmgType + m_dmgType);
            float currValue = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value"), currValue + invDelta);
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration"), currDuration - m_duration);
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO){
            float currDuration = g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration"));
            g_buffToCounterMap.put(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration"), currDuration - m_duration);
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

    // Helper 1: Resolve readable field/stat name
    string getFieldName() {
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
            return "Bonus Damage";
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            switch (m_effectField) {
                case cOnHitEffectStun: return "stun";
                case cOnHitEffectSnare: return "snare";
                case cOnHitEffectDamageOverTime: return "DOT";
                case cOnHitEffectLifesteal: return "lifesteal";
                case cOnHitEffectThrow: return "throw";
                case cOnHitEffectProgFreezeSpeed: return "to progressive freeze";
            }
            return "Unknown Effect";
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO) {
            switch (m_effectField) {
                case cOnHitEffectReincarnation: return "on kill";
            }
            return "Unknown Effect";
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPAWN) {
            string spawnName = kbProtoUnitGetName(m_spawnProtoID);
            string eventName = "Event";
            switch (m_eventType) {
                case cSpawnEventTypeDead: return spawnName + " on death";
                case cSpawnEventTypeKilled: return spawnName + " on killed";
                case cSpawnEventTypeBirth: return spawnName + " on birth";
                case cSpawnEventTypeBuild: return spawnName + " on build";
                case cSpawnEventTypeMutate: return spawnName + " on mutate";
                case cSpawnEventTypeHit: return spawnName + " on hit";
                case cSpawnEventTypeHitGround: return spawnName + " on hit ground";
                case cSpawnEventTypeRevertToSocket: return spawnName + " on revert to socket";
                case cSpawnEventTypeHitWater: return spawnName + " on hit water";
                case cSpawnEventTypeSelfDestruct: return spawnName + " on self destruct";
            }
            return spawnName + " on " + eventName;
        } else {
            switch (m_buffType) {
                case BUFF_TYPE_PROTO_DATA: {
                    switch (m_puField) {
                        case cXSProtoEffectArmorHack: return "Hack Armor";
                        case cXSProtoEffectArmorPierce: return "Pierce Armor";
                        case cXSProtoEffectArmorCrush: return "Crush Armor";
                        case cXSProtoEffectHitpoints: return "Max HP";
                        case cXSProtoEffectSpeed: return "Movement Speed";
                        case cXSProtoEffectRechargeTime: return "Recharge Rate";
                        case cXSProtoEffectUnitRegenRate: return "HP Regen";
                        case cXSProtoEffectMaxShieldPoints: return "Shields";
                        case cXSActionEffectDamageAll: return "All Damage";
                        case cXSActionEffectDamageDivine: return "Divine Damage";
                    }
                }
                case BUFF_TYPE_PROTO_ACTION: {
                    switch (m_puField) {
                        case cXSActionEffectDamageHack: return "Hack Damage";
                        case cXSActionEffectDamagePierce: return "Pierce Damage";
                        case cXSActionEffectDamageCrush: return "Crush Damage";
                        case cXSActionEffectRange: return "Attack Range";
                        case cXSActionEffectROF: return "Rate of Fire";
                        case cXSActionEffectDamageArea: return "Area Damage";
                        case cXSActionEffectNumProjectiles: return "Projectiles";
                        case cXSActionEffectDamageAll: return "All Damage";
                        case cXSActionEffectDamageDivine: return "Divine Damage";
                        case cXSActionEffectNumBounces: return "Bounces";
                    }
                }
            }
        }
        return "Unknown Stat";
    }

    // Helper 2: Format numeric value into text string
    string getValueString() {
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            if (m_effectField == cOnHitEffectLifesteal) {
                int pct = (m_delta * 100.0) + 0.5;
                if (pct > 0) { return "+" + pct + "%"; }
                else { return "" + pct + "%"; }
            }
            else if (m_effectField == cOnHitEffectProgFreezeSpeed) {
                int seconds = m_dmgType / 1000;
                if (m_duration > 0.0 && seconds == 0) { seconds = 1; }
                if (seconds > 0) { return "+" + seconds + "s"; }
                else { return "" + seconds + "s"; }
            }
            else {
                int tenthDelta = (m_delta * 10.0) + 0.5;
                string sign = "";
                if (tenthDelta > 0) { sign = "+"; }
                int wholePart = tenthDelta / 10;
                int decPart = tenthDelta % 10;
                if (decPart < 0) { decPart = -decPart; }
                if (decPart > 0) { return sign + wholePart + "." + decPart; }
                else { return sign + wholePart; }
            }
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO) {
            return "+1 " + m_withProtoUnitType;
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPAWN) {
            int intDelta = m_delta;
            if (m_delta > 0.0) { intDelta = (m_delta + 0.5); }
            else if (m_delta < 0.0) { intDelta = (m_delta - 0.5); }

            if (intDelta > 0) { return "+" + intDelta; }
            else { return "" + intDelta; }
        }
        else if (m_relativity == cXSRelativityAbsolute) {
            if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE) {
                int pct = (m_delta * 100.0) + 0.5;
                if (pct > 0) { return "+" + pct + "%"; }
                else { return "" + pct + "%"; }
            }
            else if (m_buffType == BUFF_TYPE_PROTO_DATA && (m_puField == cXSProtoEffectUnitRegenRate || m_puField == cXSProtoEffectMaxShieldPoints)) {
                int tenthDelta = (m_delta * 10.0) + 0.5;
                string sign = "";
                if (tenthDelta > 0) { sign = "+"; }
                int wholePart = tenthDelta / 10;
                int decPart = tenthDelta % 10;
                if (decPart < 0) { decPart = -decPart; }
                return sign + wholePart + "." + decPart;
            }
            else if (m_buffType == BUFF_TYPE_PROTO_DATA && m_puField == cXSProtoEffectRechargeTime) {
                int intDelta = m_delta;
                if (intDelta > 0) { return "-" + intDelta + "s"; }
                else { return "" + intDelta + "s"; }
            }
            else {
                int intDelta = m_delta;
                if (m_delta > 0.0 && m_delta < 1.0) { intDelta = (m_delta * 100.0) + 0.5; }

                if (intDelta > 0) { return "+" + intDelta; }
                else { return "" + intDelta; }
            }
        }
        else {
            int pct = 0;
            if (m_buffType == BUFF_TYPE_PROTO_ACTION && m_puField == cXSActionEffectROF && m_delta > 0.0 && m_delta < 1.0) {
                float speedIncrease = 1.0 - m_delta;
                pct = (speedIncrease * 100.0) + 0.5;
            } else if (m_delta > -1.0 && m_delta < 1.0) {
                pct = (m_delta * 100.0) + 0.5;
            } else {
                pct = ((m_delta - 1.0) * 100.0) + 0.5;
            }

            if (m_buffType == BUFF_TYPE_PROTO_DATA && m_puField == cXSProtoEffectRechargeTime) {
                if (pct > 0) { return "-" + pct + "%"; }
                else { return "" + pct + "%"; }
            } else {
                if (pct > 0) { return "+" + pct + "%"; }
                else { return "" + pct + "%"; }
            }
        }

        return "";
    }

    // Helper 3: Resolve targeting strings
    string getTargetString() {
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE && m_unitTypes.size() > 0) {
            string targetStr = "vs ";
            for (int u = 0; u < m_unitTypes.size(); u++) {
                if (u > 0) { targetStr = targetStr + ", "; }
                
                string rawName = m_unitTypes[u];
                string friendlyName = rawName;
                
                if (xsStringContains(rawName, "Infantry")) { friendlyName = "Infantry"; }
                else if (xsStringContains(rawName, "Cavalry")) { friendlyName = "Cavalry"; }
                else if (xsStringContains(rawName, "Archer")) { friendlyName = "Archers"; }
                else if (xsStringContains(rawName, "MythUnit")) { friendlyName = "Myth Units"; }
                else if (xsStringContains(rawName, "Hero")) { friendlyName = "Heroes"; }
                else if (xsStringContains(rawName, "Siege")) { friendlyName = "Siege"; }
                
                targetStr = targetStr + friendlyName;
            }
            return targetStr;
        } else {
            if (m_unitType != ""){
                return "for all " + m_unitType + "s";
            }
            else if (m_synergyTypes.size() == 0) {
                return "for all cards";
            } else {
                string targetStr = "for ";
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
                        case SYNERGY_INDEX_LIGHTNING: sName = "Lightning"; 
                    }
                    
                    if (i > 0) { targetStr = targetStr + ", "; }
                    targetStr = targetStr + sName;
                }
                return targetStr;
            }
        }

        return "";
    }

    string getDescription(string overrideTemplate = "") {
        if (isEmpty()) { return "Empty Buff"; }

        string tmpl = overrideTemplate;
        if (tmpl == "") { tmpl = m_descTemplate; }
        if (tmpl == "") { tmpl = "{val} {stat} {target}"; } // Default fallback format

        string valStr = getValueString();
        string statStr = getFieldName();
        string targetStr = getTargetString();

        string result = tmpl;
        result = replaceText(result, "{val}", valStr);
        result = replaceText(result, "{stat}", statStr);
        result = replaceText(result, "{target}", targetStr);

        return result;
    }
};

Buff createBuffLambdaOnly(int synergyIndex = -1, int[] synergyTypes = default,
                          string templateStr = "",
                          void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffLambdaOnly(synergyIndex, synergyTypes);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffData(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1,
                    string templateStr = "",
                    void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffData(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffAction(int synergyIndex = -1, int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1,
                      string templateStr = "",
                      void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffAction(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffActionUnitType(int synergyIndex = -1, int[] synergyTypes = default, string[] unitTypes = default, int puField = -1, float delta = 0.0, int relativity = -1,
                              string templateStr = "",
                              void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffActionUnitType(synergyIndex, synergyTypes, unitTypes, puField, delta, relativity);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffSpecialAction(int synergyIndex = -1, int[] synergyTypes = default, int effectField = -1, int dmgType = -1, float duration = 0.0, float delta = 0.0,
                             string templateStr = "",
                             void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffSpecialAction(synergyIndex, synergyTypes, effectField, dmgType, duration, delta);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffSpawnAction(int synergyIndex = -1, int[] synergyTypes = default, int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0,
                           string templateStr = "",
                           void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffSpawnAction(synergyIndex, synergyTypes, spawnProtoID, eventType, delta, relativity, chance, lifespan);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffActionSingle(int synergyIndex = -1, string unitType = "", int puField = -1, float delta = 0.0, int relativity = -1,
                            string templateStr = "",
                            void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffAction(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.m_unitType = unitType;
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffDataSingle(int synergyIndex = -1, string unitType = "", int puField = -1, float delta = 0.0, int relativity = -1,
                          string templateStr = "",
                          void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffData(synergyIndex, synergyTypes, puField, delta, relativity);
    buff.m_unitType = unitType;
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffSpawnActionSingle(int synergyIndex = -1, string unitType = "", int spawnProtoID = -1, int eventType = -1, float delta = 0.0, int relativity = cXSRelativityAbsolute, float chance = -1.0, float lifespan = -1.0,
                                 string templateStr = "",
                                 void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffSpawnAction(synergyIndex, synergyTypes, spawnProtoID, eventType, delta, relativity, chance, lifespan);
    buff.m_unitType = unitType;
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffSpecialActionWithProto(int synergyIndex = -1, int[] synergyTypes = default, int effectField = cOnHitEffectAttach, int withProtoUnit = -1, float duration = 0.0,
                                      string templateStr = "",
                                      void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    Buff buff;
    buff.setBuffSpecialActionWithProto(synergyIndex, synergyTypes, effectField, withProtoUnit, duration);
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}

Buff createBuffSpecialActionWithProtoSingle(int synergyIndex = -1, string unitType = "", int effectField = cOnHitEffectAttach, int withProtoUnit = -1, float duration = 0.0,
                                            string templateStr = "",
                                            void(string, int, float) callback = [](string protoUnit = "", int p = 0, float delta = 0.0) -> void {}) {
    int[] synergyTypes = new int(0, -1);
    Buff buff;
    buff.setBuffSpecialActionWithProto(synergyIndex, synergyTypes, effectField, withProtoUnit, duration);
    buff.m_unitType = unitType;
    buff.setTemplate(templateStr);
    buff.setCallback(callback);
    return buff;
}