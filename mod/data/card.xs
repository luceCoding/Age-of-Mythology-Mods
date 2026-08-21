include "cardParameters.xs";
include "rng.xs";

StringToCardParametersHashMap ProtoNameToCardParametersMap;

class CardData {

    bool m_isLocked = false;
    bool m_isDeployed = false;
    bool m_isIdentified = true;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = -1;
    int m_rarity = 0;
    int m_luckBonus = 0;
    int m_deckIndex = -1;
    int m_deployedUnitId = -1;
    int timeTillRespawn = 0;
    int[] m_upgrades = default;

    void setCard(ref CardParameters params, int upgrade = -1){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_deckIndex = params.getAge();
        m_isIdentified = xsRandBool(0.85);
        m_upgrades = new int(0, -1);
        m_upgrades.add(upgrade);
        if (xsRandInt(0, 6) == 0){
            m_upgrades.add(-1);
        }
    }

    CardParameters getCardParameters(){
        return ProtoNameToCardParametersMap.get(m_protoName);
    }

    int rerollRarity(int luckBonus = 0){
        m_luckBonus = m_luckBonus + 5;
        m_rarity = rollLootTierWeighted(luckBonus + m_luckBonus);
        return m_rarity;
    }

    int rerollUpgrade(int upgradeSlot = 0){
        if (upgradeSlot > m_upgrades.size()) {return -1;}
        int rngUpgrade = xsRandInt(0, 9);
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
        }
        return -1;
    }

    void applyUpgrade(ref int p, ref int puFIELD, int sign = 1){
        float absDelta = (1.0 + m_rarity) * sign;

        switch(puFIELD){
            case UPGRADE_HACK_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, absDelta / 100.0, relativityABSOLUTE);
            case UPGRADE_PIERCE_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, absDelta / 100.0, relativityABSOLUTE);
            case UPGRADE_CRUSH_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_CRUSH_ARMOR, absDelta / 100.0, relativityABSOLUTE);
            case UPGRADE_HITPOINTS: {
                float pctDelta = (sign > 0) ? (1.0 + (0.05 * (m_rarity + 1))) : (1.0 - (0.05 * (m_rarity + 1)));
                trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, pctDelta, relativityBasePERCENT);
            }
            case UPGRADE_SHIELDS: {
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELDS, 5.0 * absDelta, relativityABSOLUTE);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELD_REGEN, 0.2 * absDelta, relativityABSOLUTE);
            }
            case UPGRADE_SPEED: {
                float pctDelta = (sign > 0) ? (1.0 + (0.05 * (m_rarity + 1))) : (1.0 - (0.05 * (m_rarity + 1)));
                trModifyProtounitData(m_protoName, p, puFIELD_SPEED, pctDelta, relativityBasePERCENT);
            }
            case UPGRADE_HP_REGEN: 
                trModifyProtounitData(m_protoName, p, puFIELD_HP_REGEN, 0.1 * absDelta, relativityABSOLUTE);
            case UPGRADE_HACK_ATTACK: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_HACK, absDelta, relativityABSOLUTE);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_HACK, absDelta, relativityABSOLUTE);
            }
            case UPGRADE_PIERCE_ATTACK: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_PIERCE, absDelta, relativityABSOLUTE);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_PIERCE, absDelta, relativityABSOLUTE);
            }
            case UPGRADE_CRUSH_ATTACK: {
               trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_CRUSH, absDelta, relativityABSOLUTE);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_CRUSH, absDelta, relativityABSOLUTE);
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

    string getProtoName(){
        return m_protoName;
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
        return m_uuid == -1;
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
};