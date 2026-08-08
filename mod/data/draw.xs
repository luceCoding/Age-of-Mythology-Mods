include "lib/rm_core.xs";
include "card.xs";

class DrawData {
    CardData[] m_cardArray = default;

    int getSize(){
        return m_cardArray.size();
    }

    bool addCard(ref CardData card){
        if (m_cardArray.size() >= config_MAX_DRAWN_CARDS){
            return false;
        }
        m_cardArray.add(card);
        log(3, "Added card to draw " + card.getUuid() + ", size: " + m_cardArray.size());
        return true;
    }

    CardData removeCard(int index = 0){
        int currentSize = m_cardArray.size();
        
        if (index < 0 || index >= currentSize) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData removedCard = m_cardArray[index];
        int lastIndex = currentSize - 1;

        // Fast Removal: Overwrite drawn index with the last card
        m_cardArray[index] = m_cardArray[lastIndex];

        // Pop the last card off the deck
        m_cardArray.resize(lastIndex);
        log(3, "Removed card from draw " + removedCard.getUuid() + ", size: " + m_cardArray.size());
        return removedCard;
    }

    CardData removeCardByUUID(int uuid = -1){        
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                int lastIndex = m_cardArray.size() - 1;
                
                // Overwrite with last element and shrink array
                m_cardArray[i] = m_cardArray[lastIndex];
                m_cardArray.resize(lastIndex);
                
                log(3, "Removed card from draw " + currCard.getUuid() + ", size: " + m_cardArray.size());
                return currCard;
            }
        }
        
        CardData emptyCard;
        return emptyCard;
    }
};