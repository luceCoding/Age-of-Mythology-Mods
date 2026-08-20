include "cardParameters.xs";
include "rng.xs";

const int MAX_SOCKETS_PER_CARD = 3;
int g_uuidCardCounter = 0;
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

    void applyUpgrade(ref int p, ref int puFIELD, int sign = 1){
        float absDelta = (1.0 + m_rarity) / 100 * sign;

        switch(puFIELD){
            case puFIELD_HACK_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, absDelta, relativityABSOLUTE);
            case puFIELD_PIERCE_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, absDelta, relativityABSOLUTE);
            case puFIELD_CRUSH_ARMOR: 
                trModifyProtounitData(m_protoName, p, puFIELD_CRUSH_ARMOR, absDelta, relativityABSOLUTE);
            case puFIELD_HITPOINTS: {
                float pctDelta = (sign > 0) ? (1.0 + (0.05 * (m_rarity + 1))) : (1.0 - (0.05 * (m_rarity + 1)));
                trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, pctDelta, relativityBasePERCENT);
            }
            case puFIELD_SHIELDS: {
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELDS, 10.0 * absDelta, relativityABSOLUTE);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELD_REGEN, 0.2 * absDelta, relativityABSOLUTE);
            }
            case puFIELD_SPEED: {
                float pctDelta = (sign > 0) ? (1.0 + (0.05 * (m_rarity + 1))) : (1.0 - (0.05 * (m_rarity + 1)));
                trModifyProtounitData(m_protoName, p, puFIELD_SPEED, pctDelta, relativityBasePERCENT);
            }
            case puFIELD_HP_REGEN: 
                trModifyProtounitData(m_protoName, p, puFIELD_HP_REGEN, 0.1 * absDelta, relativityABSOLUTE);
            //case puFIELD_ACTION_HACK: {
            //    trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_HACK, absDelta, relativityABSOLUTE);
            //    trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_HACK, absDelta, relativityABSOLUTE);
            //}
            //case puFIELD_ACTION_PIERCE: {
            //    trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_PIERCE, absDelta, relativityABSOLUTE);
            //    trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_PIERCE, absDelta, relativityABSOLUTE);
            //}
            //case puFIELD_ACTION_CRUSH: {
            //   trModifyProtounitAction(m_protoName, "HandAttack", p, puFIELD_ACTION_CRUSH, absDelta, relativityABSOLUTE);
            //    trModifyProtounitAction(m_protoName, "RangedAttack", p, puFIELD_ACTION_CRUSH, absDelta, relativityABSOLUTE);
            //}
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
};