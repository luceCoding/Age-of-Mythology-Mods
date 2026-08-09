include "../mod/data/player.xs";

void createStartingUnits(){
    float midX = configMapTileX / 2;
    float midZ = configMapTileZ / 2;
    for(int p = 1; p < cNumberPlayers + 1; p++) {
        int shopId = trUnitCreateForced("Market", midX, configMapBaseHeight, midZ, xsRandFloat(0.0, 360.0), p);
        BenchData bench = g_shop.m_benches[p];
        bench.init(p, shopId);
        midZ = midZ - 50;
        g_shop.m_benches[p] = bench;
    }
}