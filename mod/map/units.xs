include "../mod/data/player.xs";

void createStartingUnits(){
    float midX = configMapTileX / 2;
    float midZ = configMapTileZ / 2;
    for(int p = 1; p < cNumberPlayers + 1; p++) {
        PlayerData player = g_PlayerDataArray[p];
        int shopId = trUnitCreateForced("Market", midX, configMapBaseHeight, midZ, xsRandFloat(0.0, 360.0), p);
        player.init(p, shopId);
        midZ = midZ - 50;
        g_PlayerDataArray[p] = player;
    }
}