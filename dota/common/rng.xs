include "lib/rm_core.xs";

// Define Tier Constants
extern const int TIER_COMMON    = 0;
extern const int TIER_UNCOMMON  = 1;
extern const int TIER_RARE      = 2;
extern const int TIER_EPIC      = 3;
extern const int TIER_LEGENDARY = 4;

// Base Weights (Higher = More Common)
extern const float BaseWeight1 = 1000.0; // Common
extern const float BaseWeight2 = 350.0;  // Uncommon
extern const float BaseWeight3 = 120.0;  // Rare
extern const float BaseWeight4 = 25.0;   // Epic
extern const float BaseWeight5 = 5.0;    // Legendary

// 200 luckBonus would be considered high
// Returns a tier integer (1-5) using scaled bucket weights
int rollLootTierWeighted(int luckBonus = 0)
{
    // Apply luck multiplier to higher tiers
    float w5 = BaseWeight5 * (1.0 + luckBonus);
    float w4 = BaseWeight4 * (1.0 + (luckBonus * 0.5));
    float w3 = BaseWeight3 * (1.0 + (luckBonus * 0.25));
    float w2 = BaseWeight2 * (1.0 + (luckBonus * 0.125));
    float w1 = BaseWeight1;

    // Calculate total pool weight
    float totalWeight = w1 + w2 + w3 + w4 + w5;

    // Pick a random point in the pool from 0.0 to totalWeight
    float roll = xsRandFloat(0.0, totalWeight);

    // Evaluate which "bucket" the random roll landed in
    if (roll <= w5)
    {
        return(TIER_LEGENDARY);
    }
    
    roll = roll - w5; // Subtract tier 5 weight to check next bucket
    if (roll <= w4)
    {
        return(TIER_EPIC);
    }

    roll = roll - w4;
    if (roll <= w3)
    {
        return(TIER_RARE);
    }

    roll = roll - w3;
    if (roll <= w2)
    {
        return(TIER_UNCOMMON);
    }

    // Fallback remainder belongs to Tier 1
    return(TIER_COMMON);
}