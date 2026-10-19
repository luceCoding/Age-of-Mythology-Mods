float getHumanOverZombieScale(){
    if (g_zombieUnitCount <= 0 || g_humanUnitCount <= 0) {
        return 1;
    }
    return g_humanUnitCount / g_zombieUnitCount;
}

float getZombieOverHumanScale(){
    if (g_humanUnitCount <= 0 || g_zombieUnitCount <= 0) {
        return 1;
    }
    return g_zombieUnitCount / g_humanUnitCount;
}