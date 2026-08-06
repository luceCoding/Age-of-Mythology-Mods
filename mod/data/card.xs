include "lib/rm_core.xs";

int g_uuidCounter = 0;

class CardData {

    bool m_locked = false;
    int m_cType = -1;
    int m_count = 1;
    int m_uuid = -1;

    void setCard(ref CardParameters params){
        m_cType = params.getcType();
        m_uuid = g_uuidCounter;
        g_uuidCounter = g_uuidCounter + 1;
    }

    bool isNull(){
        return m_uuid == -1;
    }
};