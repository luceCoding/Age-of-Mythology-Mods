include "lib/rm_core.xs";
include "card.xs"

class BenchData {
    int m_currMaxBenchSize = 3;
    CardData[] m_cardArray = default;

    bool addCard(ref CardData card){
        if (m_cardArray.size() >= m_currMaxBenchSize){
            return false;
        }
        m_cardArray.add(card);
        return true;
    }

    void incrementMaxHandSize(){
        m_currMaxBenchSize = m_currMaxBenchSize + 1;
    }
};