include "lib/rm_core.xs";
include "card.xs";
include "player.xs";

class DrawData {
    CardData[] m_cardArray = default;
    bool[] m_occupied = default;

    void ensureInitialised(){
        if (m_cardArray.size() == 0){
            m_cardArray = new CardData(config_MAX_DRAWN_CARDS);
            m_occupied = new bool(config_MAX_DRAWN_CARDS, false);
        }
    }

    int getSize(){
        ensureInitialised();
        return m_cardArray.size();
    }

    bool addCard(ref CardData card){
        ensureInitialised();
        for(int i = 0; i < m_cardArray.size(); i++) {
            if (m_occupied[i] == false){
                m_cardArray[i] = card;
                m_occupied[i] = true;
                g_CardUUIDToIndex.put(card.getUuid(), i);
                log(3, "Added card to draw " + card.getUuid() + ", slot: " + i);
                return true;
            }
        }

        return false;
    }

    CardData getCard(int index = 0){
        ensureInitialised();
        if (index < 0 || index >= m_cardArray.size() || m_occupied[index] == false) {
            return EMPTY_CARD;
        }

        return m_cardArray[index];
    }

    CardData removeCard(int index = 0){
        ensureInitialised();
        if (index < 0 || index >= m_cardArray.size() || m_occupied[index] == false) {
            return EMPTY_CARD;
        }

        CardData removedCard = m_cardArray[index];
        g_CardUUIDToIndex.remove(removedCard.getUuid());

        m_cardArray[index] = EMPTY_CARD;
        m_occupied[index] = false;

        log(3, "Removed card from draw " + removedCard.getUuid() + ", slot: " + index);
        return removedCard;
    }

    CardData getCardByUUID(int uuid = NullUUID){
        ensureInitialised();
        int i = g_CardUUIDToIndex.get(uuid);
        if (i >= 0 && i < m_cardArray.size() && m_occupied[i]) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                return currCard;
            }
        }
        return EMPTY_CARD;
    }

    CardData removeCardByUUID(int uuid = NullUUID){
        ensureInitialised();
        int i = g_CardUUIDToIndex.get(uuid);
        if (i >= 0 && i < m_cardArray.size() && m_occupied[i]) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                CardData removedCard = removeCard(i);
                log(3, "Removed card from draw " + removedCard.getUuid() + ", slot: " + i + ", size: " + m_cardArray.size());
                return removedCard;
            }
        }
        return EMPTY_CARD;
    }
};