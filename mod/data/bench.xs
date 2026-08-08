include "lib/rm_core.xs";
include "card.xs"

const int MAX_CARDS_IN_BENCH = 21;

class BenchData {
    int m_currMaxBenchSize = 3;
    CardData[] m_cardArray = default;

    bool addCard(ref CardData card){
        m_cardArray.add(card);
        log(3, "Added card to bench " + card.getUuid());
        return true;
    }

    CardData[] getCards(){
        return m_cardArray;
    }

    int getNumberOfCardsHeld(){
        return m_cardArray.size();
    }

    void incrementMaxHandSize(){
        m_currMaxBenchSize = m_currMaxBenchSize + 1;
    }
};