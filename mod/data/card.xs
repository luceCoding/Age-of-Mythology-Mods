include "cardParameters.xs";
include "rng.xs";

class CardData {

    bool m_isLocked = false;
    bool m_isDeployed = false;
    bool m_isIdentified = true;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = cMinInt;
    int m_rarity = 0;
    int m_luckBonus = 0;
    int m_deckIndex = -1;
    int m_deployedUnitId = -1;
    int timeTillRespawn = 0;
    int[] m_upgrades = default;

    void setCard(ref CardParameters params, int upgrade = -1, bool addSockets = true){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuid.getNextUUID();
        m_deckIndex = params.getAge();
        m_isIdentified = xsRandBool(0.85);
        if (upgrade != -1){
            m_upgrades = new int(0, -1);
            m_upgrades.add(upgrade);
        }
        if (addSockets){
            if (xsRandInt(0, 6) == 0){
                m_upgrades.add(-1);
            }
        }
    }

    CardParameters getCardParameters(){
        return g_protoNameToCardParametersMap.get(m_protoName);
    }

    int rerollRarity(int luckBonus = 0){
        m_luckBonus = m_luckBonus + 5;
        m_rarity = rollLootTierWeighted(luckBonus + m_luckBonus);
        return m_rarity;
    }

    int rerollUpgrade(int upgradeSlot = 0){
        if (upgradeSlot > m_upgrades.size()) {return -1;}
        int rngUpgrade = xsRandInt(0, 10);
        switch(rngUpgrade){
            case 0: {m_upgrades[upgradeSlot] = UPGRADE_HACK_ARMOR; return UPGRADE_HACK_ARMOR;}
            case 1: {m_upgrades[upgradeSlot] = UPGRADE_PIERCE_ARMOR; return UPGRADE_PIERCE_ARMOR;}
            case 2: {m_upgrades[upgradeSlot] = UPGRADE_CRUSH_ARMOR; return UPGRADE_CRUSH_ARMOR;}
            case 3: {m_upgrades[upgradeSlot] = UPGRADE_HITPOINTS; return UPGRADE_HITPOINTS;}
            case 4: {m_upgrades[upgradeSlot] = UPGRADE_SHIELDS; return UPGRADE_SHIELDS;}
            case 5: {m_upgrades[upgradeSlot] = UPGRADE_SPEED; return UPGRADE_SPEED;}
            case 6: {m_upgrades[upgradeSlot] = UPGRADE_HP_REGEN; return UPGRADE_HP_REGEN;}
            case 7: {m_upgrades[upgradeSlot] = UPGRADE_HACK_ATTACK; return UPGRADE_HACK_ATTACK;}
            case 8: {m_upgrades[upgradeSlot] = UPGRADE_PIERCE_ATTACK; return UPGRADE_PIERCE_ATTACK;}
            case 9: {m_upgrades[upgradeSlot] = UPGRADE_CRUSH_ATTACK; return UPGRADE_CRUSH_ATTACK;}
            case 10: {m_upgrades[upgradeSlot] = UPGRADE_ROF; return UPGRADE_ROF;}
        }
        return -1;
    }

    void applyUpgrade(ref int p, ref int puFIELD, int sign = 1){
        float absDelta = 2.0 * (1.0 + m_rarity) * sign;

        switch(puFIELD){
            case UPGRADE_HACK_ARMOR: 
                trModifyProtounitData(m_protoName, p, cXSProtoEffectArmorHack, absDelta / 100.0 * 2, cXSRelativityAbsolute);
            case UPGRADE_PIERCE_ARMOR: 
                trModifyProtounitData(m_protoName, p, cXSProtoEffectArmorPierce, absDelta / 100.0 * 2, cXSRelativityAbsolute);
            case UPGRADE_CRUSH_ARMOR: 
                trModifyProtounitData(m_protoName, p, cXSProtoEffectArmorCrush, absDelta / 100.0 * 2, cXSRelativityAbsolute);
            case UPGRADE_HITPOINTS: {
                absDelta = 20 * (1.0 + m_rarity) * sign;
                trModifyProtounitData(m_protoName, p, cXSProtoEffectHitpoints, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_SHIELDS: {
                absDelta = 10 * (1.0 + m_rarity) * sign;
                trModifyProtounitData(m_protoName, p, cXSProtoEffectMaxShieldPoints, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_SPEED: {
                float pctDelta = (sign > 0) ? (1.0 + (0.05 * (m_rarity + 1))) : (1.0 - (0.05 * (m_rarity + 1)));
                trModifyProtounitData(m_protoName, p, cXSProtoEffectSpeed, pctDelta, cXSRelativityBasePercent);
            }
            case UPGRADE_HP_REGEN: 
                trModifyProtounitData(m_protoName, p, cXSProtoEffectUnitRegenRate, 0.1 * absDelta, cXSRelativityAbsolute);
            case UPGRADE_HACK_ATTACK: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "BuildingAttack", p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "AntiWallAttack", p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "LightningAttack", p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_PIERCE_ATTACK: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "BuildingAttack", p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "AntiWallAttack", p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "LightningAttack", p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_CRUSH_ATTACK: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "BuildingAttack", p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "AntiWallAttack", p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
                trModifyProtounitAction(m_protoName, "LightningAttack", p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_ROF: {
                float pctDelta = (sign > 0) ? (1.0 - (0.05 * (m_rarity + 1))) : (1.0 + (0.05 * (m_rarity + 1)));
                trModifyProtounitAction(m_protoName, "HandAttack", p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
                trModifyProtounitAction(m_protoName, "BuildingAttack", p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
                trModifyProtounitAction(m_protoName, "AntiWallAttack", p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
                trModifyProtounitAction(m_protoName, "LightningAttack", p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
            }
        }
    }

    void applyUpgrades(int p = 0){
        for (int i = 0; i < m_upgrades.size(); i++){
            int upgrade = m_upgrades[i];
            applyUpgrade(p, upgrade, 1);
        }
    }

    void resetUpgrades(int p = 0){
        for (int i = 0; i < m_upgrades.size(); i++){
            int upgrade = m_upgrades[i];
            applyUpgrade(p, upgrade, -1);
        }
    }

    void applyOneUpgrade(int p = 0, int upgradeIdx = 0){
        int upgrade = m_upgrades[upgradeIdx];
        applyUpgrade(p, upgrade, 1);
    }

    void resetOneUpgrade(int p = 0, int upgradeIdx = 0){
        int upgrade = m_upgrades[upgradeIdx];
        applyUpgrade(p, upgrade, -1);
    }

    string getProtoName(){
        return m_protoName;
    }

    void setRarity(int rarity = -1){
        m_rarity = rarity;
    }

    int getRarity(){
        return m_rarity;
    }

    int getUuid(){
        return m_uuid;
    }

    int getDeckIndex(){
        return m_deckIndex;
    }

    void toggleLock(){
        m_isLocked = !m_isLocked;
    }

    void unlockCard(){
        m_isLocked = false;
    }

    bool isLocked(){
        return m_isLocked;
    }

    void deploy(int unitId = -1){
        m_isDeployed = true;
        m_deployedUnitId = unitId;
        int owner = kbUnitGetPlayerID(unitId);
        selectSingle(unitId);
        int topBossBuffDurationLeft = g_TopBossBuffMsEnd[owner] - xsGetTimeMS();
        if (topBossBuffDurationLeft > 0){
            attachTopBossBuff(unitId, topBossBuffDurationLeft, owner);
        }
        int botBossBuffDurationLeft = g_BotBossBuffMsEnd[kbUnitGetPlayerID(unitId)] - xsGetTimeMS();
        if (botBossBuffDurationLeft > 0){
            attachBotBossBuff(unitId, botBossBuffDurationLeft, owner);
        }
    }

    int getDeployedUnitID(){
        return m_deployedUnitId;
    }

    void withdraw(){
        m_isDeployed = false;
    }

    bool isDeployed(){
        return m_isDeployed;
    }

    bool isNull(){
        return m_uuid == cMinInt;
    }

    bool isIdentified(){
        return m_isIdentified;
    }

    void identify(){
        m_isIdentified = true;
    }

    int[] getUpgrades(){
        return m_upgrades;
    }

    bool addSocket(){
        if (m_upgrades.size() < MAX_SOCKETS_PER_CARD){
            m_upgrades.add(-1);
            return true;
        }
        return false;
    }

    bool canSocket(){
        return m_upgrades.size() < MAX_SOCKETS_PER_CARD;
    }

    int getNumberOfSockets(){
        return m_upgrades.size();
    }

    int getNumberOfUpgrades(){
        int count = 0;
        for (int i=0; i < m_upgrades.size(); i++){
            int upgrade = m_upgrades[i];
            if (upgrade != -1){
                count = count + 1;
            }
        }
        return count;
    }

    bool isOsirisPieceBoxCard(){
        return kbProtoUnitGetID(m_protoName) == cUnitTypeOsirisPieceBox;
    }
};