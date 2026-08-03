include "lib/rm_core.xs";
include "card.xs"

class HandData {
    int m_currMaxHandSize = 3;
    CardData[] m_cardArray = default;

    bool addCard(CardData card){
        if (m_cardArray.size() >= m_currMaxHandSize){
            return false;
        }
        m_cardArray.add(card);
        return true;
    }

    void incrementMaxHandSize(){
        m_currMaxHandSize = m_currMaxHandSize + 1;
    }
};