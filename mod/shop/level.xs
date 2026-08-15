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
    g_shopLevels.add(createShopLevel(100,  0,  0,  0,  0,  10));
    g_shopLevels.add(createShopLevel( 80, 20,  0,  0,  0,  25));
    g_shopLevels.add(createShopLevel( 65, 30,  5,  0,  0,  45));
    g_shopLevels.add(createShopLevel( 50, 35, 15,  0,  0,  70));
    g_shopLevels.add(createShopLevel( 38, 35, 25,  2,  0, 100));
    g_shopLevels.add(createShopLevel( 26, 32, 35,  7,  0, 135));
    g_shopLevels.add(createShopLevel( 18, 26, 40, 15,  1, 175));
    g_shopLevels.add(createShopLevel( 12, 19, 40, 25,  4, 220));
    g_shopLevels.add(createShopLevel(  7, 12, 33, 38, 10, 270));
    g_shopLevels.add(createShopLevel(  3,  6, 25, 46, 20, 325));
    g_shopLevels.add(createShopLevel(  1,  2, 12, 50, 35,   0));
}

int getRandomTier(int shopLevel = 0) {
    // Clamp to the highest valid tier entry. The displayed shop level can reach MAX_SHOP_LEVEL,
    int level = shopLevel;
    if (g_shopLevels.size() <= 0) return(4);
    if (level < 0) level = 0;
    if (level >= g_shopLevels.size()) level = g_shopLevels.size() - 1;

    ShopLevel chances = g_shopLevels[level];
    log(3, ""+chances.m_tier5Chance);

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