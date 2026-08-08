include "bench.xs";

class PlayerData {
    int m_playerUnitID = -1;
    int m_playerProtounitID = -1;
};

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers + 1);
}