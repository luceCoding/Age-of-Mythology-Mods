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
    g_shopLevels.add(createShopLevel(100,  0,  0,  0,  0, 10));
    g_shopLevels.add(createShopLevel( 75, 25,  0,  0,  0, 25));
    g_shopLevels.add(createShopLevel( 55, 30, 15,  0,  0, 45));
    g_shopLevels.add(createShopLevel( 45, 33, 20,  2,  0, 70));
    g_shopLevels.add(createShopLevel( 30, 40, 25,  5,  0, 100));
    g_shopLevels.add(createShopLevel( 19, 30, 40, 10,  1, 135));
    g_shopLevels.add(createShopLevel( 15, 20, 32, 30,  3, 175));
    g_shopLevels.add(createShopLevel( 10, 17, 25, 33, 15, 220));
    g_shopLevels.add(createShopLevel(  5, 10, 20, 40, 25, 270));
    g_shopLevels.add(createShopLevel(  1,  2, 12, 50, 35, 325));
}

int getRandomTier(int shopLevel = 0) {
    // Clamp shop level directly between 0 and MAX_SHOP_LEVEL
    int level = shopLevel;
    if (level < 0) level = 0;
    if (level > MAX_SHOP_LEVEL) level = MAX_SHOP_LEVEL;

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