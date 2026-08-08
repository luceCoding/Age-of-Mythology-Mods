include "lib/rm_core.xs";

int g_uuidCardCounter = 0;
IntToCardParameterscTypeToCardParametersMap cTypeToCardParametersMap;

class CardData {

    bool m_isLocked = false;
    int m_cType = -1;
    int m_count = 1;
    int m_uuid = -1;
    int m_suit = -1;

    void setCard(ref CardParameters params, int suit = -1){
        m_cType = params.getcType();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_suit = suit;
    }

    CardParameters getCardParameters(){
        return cTypeToCardParametersMap.get(m_cType);
    }

    int getUuid(){
        return m_uuid;
    }

    int getSuit(){
        return m_suit;
    }

    void lockCard(){
        m_isLocked = true;
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