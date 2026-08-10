include "lib/rm_core.xs";
include "card.xs"

const int MAX_CARDS_IN_BENCH = 21;
IntToIntCardUUIDToUnitIDMap CardUUIDToUnitIDMap;

class BenchData {
    int m_player = -1;
    int m_playerShopId = -1;
    CardData[] m_cardArray = default;

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

    void deployCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.isNull() || card.isDeployed() || card.getUuid() != uuid) continue;
            CardParameters params = card.getCardParameters();
            string protoName = params.getProtoUnit();
            vector position = trUnitGetPosition(m_playerShopId);
            int unitID = trUnitCreate(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), m_player, false);
            CardUUIDToUnitIDMap.put(card.getUuid(), unitID);
            card.applySuitBonus(m_player);
            card.deploy();
            m_cardArray[i] = card;
            log(3, "Player " + m_player + " deployed " + protoName + " to shop " + m_playerShopId);
        }
    }

    bool withdrawCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData cardToWithdraw = m_cardArray[i];
            if (!(cardToWithdraw.isNull()) && cardToWithdraw.isDeployed() && uuid == cardToWithdraw.getUuid()){
                int unitID = CardUUIDToUnitIDMap.get(uuid);
                trUnitSelectClear();
                trUnitSelectByID(unitID);
                if (trUnitDead() == false){
                    vector shopLocation = kbUnitGetPosition(m_playerShopId);
                    float distance = kbUnitGetDistanceToPoint(unitID, shopLocation);
                    if (distance <= 10){
                        trUnitDestroy(true);
                        trUnitSelectClear();
                        cardToWithdraw.resetSuitBonus(m_player);
                        cardToWithdraw.withdraw();
                        m_cardArray[i] = cardToWithdraw;
                        log(3, "Player " + m_player + " withdrew to shop " + m_playerShopId);
                        return true;
                    }
                    else {
                        trChatSendToPlayer(m_player, m_player, "Unit must be nearby your shop before it can be withdrawn.");
                    }
                }
                else {
                    trChatSendToPlayer(m_player, m_player, "Unit must be alive before it can be withdrawn.");
                }
            }
        }
        trUnitSelectClear();
        return false;
    }
};