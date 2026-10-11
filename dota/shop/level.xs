const int MAX_SHOP_LEVEL = 10;
class ShopLevel {
    int m_tier1Chance = 0;
    int m_tier2Chance = 0;
    int m_tier3Chance = 0;
    int m_tier4Chance = 0;
    int m_tier5Chance = 0;
    int m_expNeeded = 0;
};

ShopLevel[] g_shopLevels = default;

ShopLevel createShopLevel(int t1 = 0, int t2 = 0, int t3 = 0, int t4 = 0, int t5 = 0, int exp = 0) {
    ShopLevel lvl;
    lvl.m_tier1Chance = t1;
    lvl.m_tier2Chance = t2;
    lvl.m_tier3Chance = t3;
    lvl.m_tier4Chance = t4;
    lvl.m_tier5Chance = t5;
    lvl.m_expNeeded = exp;
    return(lvl);
}

void initializeShopLevels(){
    g_shopLevels.add(createShopLevel(100,  0,  0,  0,  0,  15));
    g_shopLevels.add(createShopLevel( 80, 20,  0,  0,  0,  20));
    g_shopLevels.add(createShopLevel( 65, 35,  0,  0,  0,  25));
    g_shopLevels.add(createShopLevel( 50, 45,  5,  0,  0,  30));
    g_shopLevels.add(createShopLevel( 43, 40, 17,  0,  0,  35));
    g_shopLevels.add(createShopLevel( 30, 38, 25,  7,  0,  40));
    g_shopLevels.add(createShopLevel( 20, 30, 35, 15,  0,  45));
    g_shopLevels.add(createShopLevel( 12, 18, 40, 25,  5,  50));
    g_shopLevels.add(createShopLevel(  4,  8, 35, 38, 15,  55));
    g_shopLevels.add(createShopLevel(  2,  3, 25, 45, 25,  60));
    g_shopLevels.add(createShopLevel(  1,  2, 12, 55, 30,   0));
}

int getRandomTier(int shopLevel = 0) {
    // Clamp to the highest valid tier entry. The displayed shop level can reach MAX_SHOP_LEVEL,
    int level = shopLevel;
    if (g_shopLevels.size() <= 0) return(4);
    if (level < 0) level = 0;
    if (level >= g_shopLevels.size()) level = g_shopLevels.size() - 1;

    ShopLevel chances = g_shopLevels[level];

    int roll = xsRandInt(1, 100);

    int cumulative = chances.m_tier1Chance;
    if (roll <= cumulative) return(0);

    cumulative = cumulative + chances.m_tier2Chance;
    if (roll <= cumulative) return(1);

    cumulative = cumulative + chances.m_tier3Chance;
    if (roll <= cumulative) return(2);

    cumulative = cumulative + chances.m_tier4Chance;
    if (roll <= cumulative) return(3);

    return(4);
}