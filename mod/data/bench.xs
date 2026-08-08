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

    CardData removeCardByUUID(int uuid = -1){        
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                int lastIndex = m_cardArray.size() - 1;
                
                // Overwrite with last element and shrink array
                m_cardArray[i] = m_cardArray[lastIndex];
                m_cardArray.resize(lastIndex);
                
                log(3, "Removed card from bench " + currCard.getUuid() + ", size: " + m_cardArray.size());
                return currCard;
            }
        }
        
        CardData emptyCard;
        return emptyCard;
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