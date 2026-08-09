include "cardParameters.xs";
include "rng.xs";

int g_uuidCardCounter = 0;
StringToCardParametersProtoNameToCardParametersMap ProtoNameToCardParametersMap;

class CardData {

    bool m_isLocked = false;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = -1;
    int m_suit = -1;
    int m_rarity = 0;
    int m_luckBonus = 0;

    void setCard(ref CardParameters params, int suit = -1){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_suit = suit;
    }

    CardParameters getCardParameters(){
        return ProtoNameToCardParametersMap.get(m_protoName);
    }

    int rerollRarity(int luckBonus = 0){
        m_luckBonus = m_luckBonus + 1;
        m_rarity = rollLootTierWeighted(luckBonus + m_luckBonus);
        return m_rarity;
    }

    int getRarity(){
        return m_rarity;
    }

    int getUuid(){
        return m_uuid;
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

    bool isNull(){
        return m_uuid == -1;
    }
};