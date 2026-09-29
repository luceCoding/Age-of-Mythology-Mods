const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction
const int BUFF_TYPE_PROTO_ACTION_UNIT_TYPE = 2; // trModifyProtounitActionUnitType
const int BUFF_TYPE_PROTO_ACTION_SPECIAL = 3; // trProtounitActionSpecialEffect
const int BUFF_TYPE_PROTO_ACTION_SPAWN = 4; // trProtounitModifySpawnData
const int BUFF_TYPE_LAMBDA_ONLY = 5;
const int BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO = 6;

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
                break;
            }
            case BUFF_TYPE_PROTO_ACTION: { 
                applyProtoActionToTarget(targetProto, p, m_puField, delta, m_relativity);
                break;
            }
            case BUFF_TYPE_PROTO_ACTION_SPECIAL: { 
                applyProtoActionSpecialEffectToTarget(targetProto, p, m_effectField, "All", 
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "dmgType")),
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "duration")), 
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL, "value")));
                break;
            }
            case BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO: {
                applyProtoActionSpecialEffectProtoUnitToTarget(targetProto, p, m_effectField, "MilitaryUnit", m_withProtoUnitType,
                    g_buffToCounterMap.get(getBuffToCounterKey(p, m_synergyIndex, BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO, "duration")), 0.0);
                break;
            }
            case BUFF_TYPE_PROTO_ACTION_UNIT_TYPE: {
                for (int u = 0; u < m_unitTypes.size(); u++) {
                    applyProtoActionUnitTypeToTarget(targetProto, m_unitTypes[u], p, m_puField, delta, m_relativity);
                }
                break;
            }
            case BUFF_TYPE_PROTO_ACTION_SPAWN: {
                applyProtoActionSpawnToTarget(targetProto, p, m_spawnProtoID, m_eventType, delta, m_relativity, m_chance, m_lifespan);
                break;
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
                int[] protoIDs = g_protoIDToCardParametersMap.getKeys();
                for (int i = 0; i < protoIDs.size(); i++) {
                    _executeCommand(kbProtoUnitGetName(protoIDs[i]), p, m_delta);
                }
            }
            else { // Apply to only certain synergies
                CardParameters[] params = g_protoIDToCardParametersMap.getValues();
                for (int i = 0; i < params.size(); i++){
                    CardParameters param = params[i];
                    for (int j = 0; j < m_synergyTypes.size(); j++) {
                        int synergyType = m_synergyTypes[j];
                        if (param.isASynergy(synergyType)){
                            _executeCommand(kbProtoUnitGetName(param.getProtoID()), p, m_delta);
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
            CardParameters[] params = g_protoIDToCardParametersMap.getValues();
            for (int i = 0; i < params.size(); i++) {
                CardParameters param = params[i];
                if (m_synergyTypes.size() == 0){ // Apply to all cards
                    _executeCommand(kbProtoUnitGetName(param.getProtoID()), p, invDelta);
                }
                else{
                    for (int j = 0; j < m_synergyTypes.size(); j++) {
                        int synergyType = m_synergyTypes[j];
                        if (param.isASynergy(synergyType)){
                            _executeCommand(kbProtoUnitGetName(param.getProtoID()), p, invDelta);
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
            return BUFF_BONUS_DAMAGE_TEXT;
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            switch (m_effectField) {
                case cOnHitEffectStun: return BUFF_STUN_TEXT;
                case cOnHitEffectSnare: return BUFF_SNARE_TEXT;
                case cOnHitEffectDamageOverTime: return BUFF_DOT_TEXT;
                case cOnHitEffectLifesteal: return BUFF_LIFESTEAL_TEXT;
                case cOnHitEffectThrow: return BUFF_THROW_TEXT;
                case cOnHitEffectProgFreezeSpeed: return BUFF_PROGRESSIVE_FREEZE_TEXT;
            }
            return BUFF_UNKNOWN_EFFECT_TEXT;
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO) {
            switch (m_effectField) {
                case cOnHitEffectReincarnation: return BUFF_ON_KILL_TEXT;
            }
            return BUFF_UNKNOWN_EFFECT_TEXT;
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPAWN) {
            string spawnName = kbProtoUnitGetName(m_spawnProtoID);
            string eventName = BUFF_EVENT_TEXT;
            switch (m_eventType) {
                case cSpawnEventTypeDead: return spawnName + BUFF_ON_DEATH_TEXT;
                case cSpawnEventTypeKilled: return spawnName + BUFF_ON_KILLED_TEXT;
                case cSpawnEventTypeBirth: return spawnName + BUFF_ON_BIRTH_TEXT;
                case cSpawnEventTypeBuild: return spawnName + BUFF_ON_BUILD_TEXT;
                case cSpawnEventTypeMutate: return spawnName + BUFF_ON_MUTATE_TEXT;
                case cSpawnEventTypeHit: return spawnName + BUFF_ON_HIT_TEXT;
                case cSpawnEventTypeHitGround: return spawnName + BUFF_ON_HIT_GROUND_TEXT;
                case cSpawnEventTypeRevertToSocket: return spawnName + BUFF_ON_REVERT_TO_SOCKET_TEXT;
                case cSpawnEventTypeHitWater: return spawnName + BUFF_ON_HIT_WATER_TEXT;
                case cSpawnEventTypeSelfDestruct: return spawnName + BUFF_ON_SELF_DESTRUCT_TEXT;
            }
            return spawnName + BUFF_ON_PREFIX + eventName;
        } else {
            switch (m_buffType) {
                case BUFF_TYPE_PROTO_DATA: {
                    switch (m_puField) {
                        case cXSProtoEffectArmorHack: return BUFF_HACK_ARMOR_TEXT;
                        case cXSProtoEffectArmorPierce: return BUFF_PIERCE_ARMOR_TEXT;
                        case cXSProtoEffectArmorCrush: return BUFF_CRUSH_ARMOR_TEXT;
                        case cXSProtoEffectHitpoints: return BUFF_MAX_HP_TEXT;
                        case cXSProtoEffectSpeed: return BUFF_MOVEMENT_SPEED_TEXT;
                        case cXSProtoEffectRechargeTime: return BUFF_RECHARGE_RATE_TEXT;
                        case cXSProtoEffectUnitRegenRate: return BUFF_HP_REGEN_TEXT;
                        case cXSProtoEffectMaxShieldPoints: return BUFF_SHIELDS_TEXT;
                        case cXSActionEffectDamageAll: return BUFF_ALL_DAMAGE_TEXT;
                        case cXSActionEffectDamageDivine: return BUFF_DIVINE_DAMAGE_TEXT;
                    }
                }
                case BUFF_TYPE_PROTO_ACTION: {
                    switch (m_puField) {
                        case cXSActionEffectDamageHack: return BUFF_HACK_DAMAGE_TEXT;
                        case cXSActionEffectDamagePierce: return BUFF_PIERCE_DAMAGE_TEXT;
                        case cXSActionEffectDamageCrush: return BUFF_CRUSH_DAMAGE_TEXT;
                        case cXSActionEffectRange: return BUFF_ATTACK_RANGE_TEXT;
                        case cXSActionEffectROF: return BUFF_RATE_OF_FIRE_TEXT;
                        case cXSActionEffectDamageArea: return BUFF_AREA_DAMAGE_TEXT;
                        case cXSActionEffectNumProjectiles: return BUFF_PROJECTILES_TEXT;
                        case cXSActionEffectDamageAll: return BUFF_ALL_DAMAGE_TEXT;
                        case cXSActionEffectDamageDivine: return BUFF_DIVINE_DAMAGE_TEXT;
                        case cXSActionEffectNumBounces: return BUFF_BOUNCES_TEXT;
                    }
                }
            }
        }
        return BUFF_UNKNOWN_STAT_TEXT;
    }

    string formatDecimal(float value = 0.0, int maxDecimalPlaces = 2) {
        float absoluteValue = value;
        if (absoluteValue < 0.0) { absoluteValue = -absoluteValue; }

        int scale = 1;
        for (int i = 0; i < maxDecimalPlaces; i++) { scale = scale * 10; }

        int scaledValue = (absoluteValue * scale) + 0.5;
        int wholePart = scaledValue / scale;
        int fractionalPart = scaledValue % scale;
        int decimalPlaces = maxDecimalPlaces;
        bool trimTrailingZeros = true;
        while (decimalPlaces > 1 && trimTrailingZeros) {
            if (fractionalPart % 10 == 0) {
                fractionalPart = fractionalPart / 10;
                decimalPlaces = decimalPlaces - 1;
            } else {
                trimTrailingZeros = false;
            }
        }

        string sign = "";
        if (value > 0.0) { sign = "+"; }
        else if (value < 0.0) { sign = "-"; }

        string decimalPart = "" + fractionalPart;
        while (xsStringLength(decimalPart) < decimalPlaces) {
            decimalPart = "0" + decimalPart;
        }

        return sign + wholePart + "." + decimalPart;
    }

    string formatPercent(int percent = 0, bool positiveUsesMinus = false) {
        if (percent > 0) {
            if (positiveUsesMinus) { return "-" + percent + BUFF_PERCENT_SUFFIX; }
            return "+" + percent + BUFF_PERCENT_SUFFIX;
        }
        return "" + percent + BUFF_PERCENT_SUFFIX;
    }

    // Helper 2: Format numeric value into text string
    string getValueString() {
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL) {
            if (m_effectField == cOnHitEffectLifesteal) {
                int pct = (m_delta * 100.0) + 0.5;
                return formatPercent(pct);
            }
            else if (m_effectField == cOnHitEffectProgFreezeSpeed) {
                int seconds = m_dmgType / 1000;
                if (m_duration > 0.0 && seconds == 0) { seconds = 1; }
                if (seconds > 0) { return "+" + seconds + BUFF_SECONDS_SUFFIX; }
                else { return "" + seconds + BUFF_SECONDS_SUFFIX; }
            }
            else {
                return formatDecimal(m_delta, 3);
            }
        }
        else if (m_buffType == BUFF_TYPE_PROTO_ACTION_SPECIAL_WITH_PROTO) {
            return BUFF_PLUS_ONE_PREFIX + m_withProtoUnitType;
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
                return formatPercent(pct);
            }
            else if (m_buffType == BUFF_TYPE_PROTO_DATA && (m_puField == cXSProtoEffectUnitRegenRate || m_puField == cXSProtoEffectMaxShieldPoints)) {
                return formatDecimal(m_delta, 2);
            }
            else if (m_buffType == BUFF_TYPE_PROTO_DATA && m_puField == cXSProtoEffectRechargeTime) {
                int intDelta = m_delta;
                if (intDelta > 0) { return "-" + intDelta + BUFF_SECONDS_SUFFIX; }
                else { return "" + intDelta + BUFF_SECONDS_SUFFIX; }
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
                return formatPercent(pct, true);
            }
            return formatPercent(pct);
        }

        return "";
    }

    // Helper 3: Resolve targeting strings
    string getTargetString() {
        if (m_buffType == BUFF_TYPE_PROTO_ACTION_UNIT_TYPE && m_unitTypes.size() > 0) {
            string targetStr = BUFF_VS_PREFIX;
            for (int u = 0; u < m_unitTypes.size(); u++) {
                if (u > 0) { targetStr = targetStr + ", "; }
                
                string rawName = m_unitTypes[u];
                string friendlyName = rawName;
                
                if (xsStringContains(rawName, "Infantry")) { friendlyName = BUFF_INFANTRY_TEXT; }
                else if (xsStringContains(rawName, "Cavalry")) { friendlyName = BUFF_CAVALRY_TEXT; }
                else if (xsStringContains(rawName, "Archer")) { friendlyName = BUFF_ARCHERS_TEXT; }
                else if (xsStringContains(rawName, "MythUnit")) { friendlyName = BUFF_MYTH_UNITS_TEXT; }
                else if (xsStringContains(rawName, "Hero")) { friendlyName = BUFF_HEROES_TEXT; }
                else if (xsStringContains(rawName, "Siege")) { friendlyName = BUFF_SIEGE_TEXT; }
                
                targetStr = targetStr + friendlyName;
            }
            return targetStr;
        } else {
            if (m_unitType != ""){
                return BUFF_ALL_UNITS_PREFIX + m_unitType + "s";
            }
            else if (m_synergyTypes.size() == 0) {
                return BUFF_ALL_CARDS_TEXT;
            } else {
                string targetStr = BUFF_TARGET_PREFIX;
                for (int i = 0; i < m_synergyTypes.size(); i++) {
                    int sType = m_synergyTypes[i];
                    string sName = BUFF_UNKNOWN_TARGET_TEXT;
                    
                    switch (sType) {
                        case SYNERGY_INDEX_INFANTRY: sName = BUFF_INFANTRY_TEXT; 
                        case SYNERGY_INDEX_RANGED: sName = BUFF_RANGED_TEXT; 
                        case SYNERGY_INDEX_CAVALRY: sName = BUFF_CAVALRY_TEXT; 
                        case SYNERGY_INDEX_MYTH: sName = BUFF_MYTH_UNITS_TEXT; 
                        case SYNERGY_INDEX_HERO: sName = BUFF_HEROES_TEXT; 
                        case SYNERGY_INDEX_HEALER: sName = BUFF_HEALERS_TEXT; 
                        case SYNERGY_INDEX_SIEGE: sName = BUFF_SIEGE_TEXT; 
                        case SYNERGY_INDEX_SOLDIER: sName = BUFF_SOLDIERS_TEXT; 
                        case SYNERGY_INDEX_FROST: sName = BUFF_FROST_TEXT; 
                        case SYNERGY_INDEX_UNDEAD: sName = BUFF_UNDEAD_TEXT; 
                        case SYNERGY_INDEX_POISON: sName = BUFF_POISONOUS_TEXT; 
                        case SYNERGY_INDEX_FIRE: sName = BUFF_FIRE_TEXT; 
                        case SYNERGY_INDEX_LIGHTNING: sName = BUFF_LIGHTNING_TEXT; 
                        case SYNERGY_INDEX_BUILDER: sName = BUFF_BUILDER_TEXT; 
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
        if (isEmpty()) { return BUFF_EMPTY_TEXT; }

        string tmpl = overrideTemplate;
        if (tmpl == "") { tmpl = m_descTemplate; }
        if (tmpl == "") { tmpl = BUFF_DEFAULT_DESCRIPTION_TEMPLATE; } // Default fallback format

        string valStr = getValueString();
        string statStr = getFieldName();
        string targetStr = getTargetString();
        int durationSeconds = m_duration;
        string durationStr = "" + durationSeconds + BUFF_SECONDS_SUFFIX;

        string result = tmpl;
        result = replaceText(result, "{val}", valStr);
        result = replaceText(result, "{stat}", statStr);
        result = replaceText(result, "{target}", targetStr);
        result = replaceText(result, "{s}", durationStr);

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