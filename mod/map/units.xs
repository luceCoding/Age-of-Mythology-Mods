void createStartingUnits(){
    float midX = configMapTileX / 2;
    float midZ = configMapTileZ / 2;
    for(int p = 1; p < cNumberPlayers + 1; p++) {
        PlayerData player = g_PlayerDataArray[p];
        int shopId = trUnitCreateForced("HealingSpring", midX, configMapBaseHeight, midZ, xsRandFloat(0.0, 360.0), p);
        player.setShopId(shopId);
        midZ = midZ - 50;
        g_PlayerDataArray[p] = player;
    }
}