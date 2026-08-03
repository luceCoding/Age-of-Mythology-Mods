include "lib/rm_core.xs";
include "hand.xs"

class PlayerData {
    int m_playerUnitID = -1;
    int m_playerProtounitID = -1;
    HandData m_playerHandData;
};

PlayerData[] PlayerDataArray = default;

void initPlayerData(){
    PlayerDataArray.resize(cNumberPlayers + 1);
    for(int p = 0; p < cNumberPlayers; p++){
        PlayerData pd = PlayerDataArray[p];
    }
}