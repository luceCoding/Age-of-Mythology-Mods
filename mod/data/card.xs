include "lib/rm_core.xs";

int g_uuidCardCounter = 0;

class CardData {

    bool m_locked = false;
    int m_cType = -1;
    int m_count = 1;
    int m_uuid = -1;

    void setCard(ref CardParameters params){
        m_cType = params.getcType();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
    }

    int getUuid(){
        return m_uuid;
    }

    bool isNull(){
        return m_uuid == -1;
    }
};