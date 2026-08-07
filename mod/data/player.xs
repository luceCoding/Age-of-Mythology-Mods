include "lib/rm_core.xs";

class PlayerData {
    int m_playerUnitID = -1;
    int m_playerProtounitID = -1;
    BenchData m_bench;
};

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers);
}