include "cardParameters.xs";

int g_uuidCardCounter = 0;
StringToCardParametersProtoNameToCardParametersMap ProtoNameToCardParametersMap;

class CardData {

    bool m_isLocked = false;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = -1;
    int m_suit = -1;

    void setCard(ref CardParameters params, int suit = -1){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_suit = suit;
    }

    CardParameters getCardParameters(){
        return ProtoNameToCardParametersMap.get(m_protoName);
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