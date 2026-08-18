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