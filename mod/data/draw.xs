include "lib/rm_core.xs";
include "card.xs";

class DrawData {
    CardData[] m_cardArray = default;

    bool addCard(ref CardData card){
        if (m_cardArray.size() >= config_MAX_DRAWN_CARDS){
            return false;
        }
        m_cardArray.add(card);
        log(3, "Added card to draw " + card.m_cType + ", size: " + m_cardArray.size());
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
        log(3, "Removed card from draw " + removedCard.m_cType + ", size: " + m_cardArray.size());
        return removedCard;
    }
};