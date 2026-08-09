include "bench.xs";
include "card.xs";
include "cardParameters.xs";

class PlayerData {
    int m_player = -1;
    int m_luckBonus = 0;

    int getLuckBonus(){
        return m_luckBonus;
    }
};

PlayerData[] g_PlayerDataArray = default;

void initPlayerData(){
    g_PlayerDataArray = new PlayerData(cNumberPlayers + 1);
    for (int p = 0; p <= cNumberPlayers; p++) {
        trPlayerModifyData(p, 0, -1, 5, 0); // Add 5 population
    }
}