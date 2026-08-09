include "bench.xs";
include "card.xs";
include "cardParameters.xs";

class PlayerData {
    int m_player = -1;
    int m_playerShopId = -1;
    CardData[] m_deployedCards = default;
    int m_luckBonus = 0;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
    }

    int getLuckBonus(){
        return m_luckBonus;
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

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers + 1);
    for (int p = 0; p <= cNumberPlayers; p++) {
        trPlayerModifyData(p, 0, -1, 5, 0); // Add 5 population
    }
}