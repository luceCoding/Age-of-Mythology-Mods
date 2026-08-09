include "lib/rm_core.xs";
include "card.xs";
include "player.xs";

class DrawData {
    CardData[] m_cardArray = default;
    int m_cardCount = 0;

    int getSize(){
        if (m_cardArray.size() <= 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
        }
        return m_cardArray.size();
    }

    bool addCard(ref CardData card, int p = 0){
        if (m_cardArray.size() <= 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
        }

        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.isNull()){
                PlayerData player = g_PlayerDataArray[p];
                int luck = player.getLuckBonus();
                card.rerollRarity(luck);
                m_cardArray[i] = card;
                m_cardCount = m_cardCount + 1;
                log(3, "Added card to draw " + card.getUuid() + ", slot: " + i + ", size: " + m_cardCount);
                return true;
            }
        }

        return false;
    }

    CardData getCard(int index = 0){
        if (m_cardArray.size() <= 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
        }
        if (index < 0 || index >= m_cardArray.size()) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData currCard = m_cardArray[index];
        if (currCard.isNull()){
            CardData emptyCard;
            return emptyCard;
        }
        return currCard;
    }

    CardData removeCard(int index = 0){        
        if (m_cardArray.size() <= 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
        }
        if (index < 0 || index >= m_cardArray.size()) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData removedCard = m_cardArray[index];
        if (removedCard.isNull()){
            CardData emptyCard;
            return emptyCard;
        }

        CardData emptyCard;
        m_cardArray[index] = emptyCard;
        if (m_cardCount > 0){
            m_cardCount = m_cardCount - 1;
        }
        log(3, "Removed card from draw " + removedCard.getUuid() + ", slot: " + index + ", size: " + m_cardCount);
        return removedCard;
    }

    CardData removeCardByUUID(int uuid = -1){        
        if (m_cardArray.size() <= 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
        }
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                CardData removedCard = removeCard(i);
                log(3, "Removed card from draw " + removedCard.getUuid() + ", slot: " + i + ", size: " + m_cardArray.size());
                return removedCard;
            }
        }
        
        CardData emptyCard;
        return emptyCard;
    }
};