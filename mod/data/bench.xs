include "lib/rm_core.xs";
include "card.xs"

const int MAX_CARDS_IN_BENCH = 21;

class BenchData {
    int m_player = -1;
    int m_playerShopId = -1;
    int m_currMaxBenchSize = 3;
    CardData[] m_cardArray = default;
    CardData[] m_deployedCards = default;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
    }
    
    int getPlayerShopID(){
        return m_playerShopId;
    }

    bool addCard(ref CardData card){
        m_cardArray.add(card);
        log(3, "Added card to bench " + card.getUuid());
        return true;
    }

    CardData getCardWithUUID(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.getUuid() == uuid){
                return card;
            }
        }
        CardData emptyCard;
        return emptyCard;
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

    bool isDeployed(ref CardData cardToCheck){
        int uuid = cardToCheck.getUuid();
        for (int i = 0; i < m_deployedCards.size(); i++) {
            CardData card = m_deployedCards[i];
            if (uuid == card.getUuid()) {
                return true;
            }
        }
        return false;
    }

    void deployCard(ref CardData card){
        if (card.isNull()) return;
        if (isDeployed(card)) return;
        CardParameters params = card.getCardParameters();
        string protoName = params.getProtoUnit();
        vector position = trUnitGetPosition(m_playerShopId);
        trUnitCreate(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), m_player, false);
        m_deployedCards.add(card);
        log(3, "Player " + m_player + " deployed " + protoName + " to shop " + m_playerShopId);
    }
};