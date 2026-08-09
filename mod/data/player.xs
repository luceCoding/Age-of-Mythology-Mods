include "bench.xs";

class PlayerData {
    int m_playerShopId = -1;

    void setShopId(int shopId = -1){
        m_playerShopId = shopId;
    }

    int getPlayerShopID(){
        return m_playerShopId;
    }
};

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers + 1);
}