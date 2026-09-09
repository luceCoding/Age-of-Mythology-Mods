include "cardParameters.xs";
include "rng.xs";

class CardData {

    bool m_isLocked = false;
    bool m_isDeployed = false;
    bool m_isIdentified = true;
    bool m_isRespawning = false;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = cMinInt;
    int m_rarity = 0;
    int m_luckBonus = 0;
    int m_deckIndex = -1;
    int m_deployedUnitId = -1;
    int[] m_upgrades = default;

    void setCard(ref CardParameters params, int upgrade = -1, bool addSockets = true){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuid.getNextUUID();
        m_deckIndex = params.getAge();
        m_isIdentified = xsRandBool(0.85);
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

    bool isDeployed(){
        return m_isDeployed;
    }

    void applyUpgrade(ref int p, ref int puFIELD, int sign = 1){
        if (isDeployed() == false) { return; }
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
                applyProtoActionToTarget(m_protoName, p, cXSActionEffectDamageHack, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_PIERCE_ATTACK: {
                applyProtoActionToTarget(m_protoName, p, cXSActionEffectDamagePierce, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_CRUSH_ATTACK: {
                applyProtoActionToTarget(m_protoName, p, cXSActionEffectDamageCrush, absDelta, cXSRelativityAbsolute);
            }
            case UPGRADE_ROF: {
                float pctDelta = (sign > 0) ? (1.0 - (0.05 * (m_rarity + 1))) : (1.0 + (0.05 * (m_rarity + 1)));
                applyProtoActionToTarget(m_protoName, p, cXSActionEffectROF, pctDelta, cXSRelativityBasePercent);
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

    void increaseRarityBy(int rarityIncrease = 1, int p = 0){
        m_rarity = m_rarity + rarityIncrease;
        CardParameters params = getCardParameters();
        trModifyProtounitData(m_protoName, p, cXSProtoEffectHitpoints, params.getInitalMaxHP() * rarityIncrease, cXSRelativityAbsolute);
    }

    void mergeDuplicate(ref CardData duplicateCard, int p = 0){
        resetUpgrades(p);
        increaseRarityBy(duplicateCard.getRarity() + 1, p);
        for (int i = 0; i < duplicateCard.m_upgrades.size(); i++){
            int upgrade = duplicateCard.m_upgrades[i];
            m_upgrades.add(upgrade);
        }
        applyUpgrades(p);
    }

    void decreaseRarityByOne(int p = 0){
        m_rarity = m_rarity - 1;
        if (isDeployed()){
            CardParameters params = getCardParameters();
            trModifyProtounitData(m_protoName, p, cXSProtoEffectHitpoints, -params.getInitalMaxHP(), cXSRelativityAbsolute);
        }
    }

    void resetRarityHealth(int p = 0){
        CardParameters params = getCardParameters();
        trModifyProtounitData(m_protoName, p, cXSProtoEffectHitpoints, -params.getInitalMaxHP() * m_rarity, cXSRelativityAbsolute);
    }

    void applyRarityHealth(int p = 0){
        CardParameters params = getCardParameters();
        trModifyProtounitData(m_protoName, p, cXSProtoEffectHitpoints, params.getInitalMaxHP() * m_rarity, cXSRelativityAbsolute);
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
        m_deployedUnitId = -1;
    }

    void setIsRespawning(bool isRespawning = false){
        m_isRespawning = isRespawning;
    }

    bool isRespawning(){
        return m_isRespawning;
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

    void splitUpgradeSubset(int cardIndex = 0){
        int socketCount = m_upgrades.size();
        int[] originalUpgrades = m_upgrades;
        m_upgrades = new int(0, -1);
        if (cardIndex >= socketCount){
            return;
        }

        int upgradeNumber = 0;
        int selectedUpgrade = -1;
        for (int i = 0; i < originalUpgrades.size(); i++){
            if (originalUpgrades[i] == -1){
                continue;
            }
            if (upgradeNumber == cardIndex){
                selectedUpgrade = originalUpgrades[i];
                break;
            }
            upgradeNumber = upgradeNumber + 1;
        }
        m_upgrades.add(selectedUpgrade);
    }
};