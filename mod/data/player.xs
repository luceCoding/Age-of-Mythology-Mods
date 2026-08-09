include "bench.xs";
include "card.xs";
include "cardParameters.xs";

class PlayerData {
    int m_playerShopId = -1;
    CardData[] m_deployedCards = default;

    void setShopId(int shopId = -1){
        m_playerShopId = shopId;
    }

    int getPlayerShopID(){
        return m_playerShopId;
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

    void deployCard(ref CardData card, int p = 0){
        if (card.isNull()) return;
        if (isDeployed(card)) return;
        CardParameters params = card.getCardParameters();
        string protoName = params.getProtoUnit();
        vector position = trUnitGetPosition(m_playerShopId);
        trUnitCreate(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), p, false);
        m_deployedCards.add(card);
        log(3, "Player " + p + " deployed " + protoName + " to shop " + m_playerShopId);
    }
};

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers + 1);
}