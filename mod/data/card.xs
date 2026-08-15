include "cardParameters.xs";
include "rng.xs";

int g_uuidCardCounter = 0;
StringToCardParametersHashMap ProtoNameToCardParametersMap;

class CardData {

    bool m_isLocked = false;
    bool m_isDeployed = false;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = -1;
    int m_suit = -1;
    int m_rarity = 0;
    int m_luckBonus = 0;
    int m_deckIndex = -1;

    void setCard(ref CardParameters params, int suit = -1){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_suit = suit;
        m_deckIndex = params.getAge();
    }

    CardParameters getCardParameters(){
        return ProtoNameToCardParametersMap.get(m_protoName);
    }

    int rerollRarity(int luckBonus = 0){
        m_luckBonus = m_luckBonus + 1;
        m_rarity = rollLootTierWeighted(luckBonus + m_luckBonus);
        return m_rarity;
    }

    void applySuitBonus(int p  = 0){
        float percentDelta = 1 + (0.05 * (m_rarity + 1));
        switch(m_suit){
            case 0: trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, percentDelta, relativityBasePERCENT);
            case 1: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, 13, percentDelta, relativityBasePERCENT);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, 14, percentDelta, relativityBasePERCENT);
            }
            case 2: trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, percentDelta, relativityBasePERCENT);
            case 3: trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, percentDelta, relativityBasePERCENT);
        }
    }

    void resetSuitBonus(int p = 0) {
        // Inverts the percentage modifier (e.g., 1.10 -> 0.90)
        float inversePercentDelta = 1 - (0.05 * (m_rarity + 1));

        switch(m_suit) {
            case 0: 
                trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, inversePercentDelta, relativityBasePERCENT);
            case 1: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, 13, inversePercentDelta, relativityBasePERCENT);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, 14, inversePercentDelta, relativityBasePERCENT);
            }
            case 2: 
                trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, inversePercentDelta, relativityBasePERCENT);
            case 3: 
                trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, inversePercentDelta, relativityBasePERCENT);
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

    int getSuit(){
        return m_suit;
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

    void deploy(){
        m_isDeployed = true;
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
};