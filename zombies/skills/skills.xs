void addZombieAutoAttackSkill(int p =-1){
    for (int i = 0; i < g_zombieOverlordUnitTypes.size(); i++){
        int zombieType = g_zombieOverlordUnitTypes[i];
        addCommand(p, zombieType, 3, 5, 0.0,
                    "Wood",
                    "Zombie Auto Attack",
                    "Toggle whether zombies will auto attack after spawning",
                    "resources\\egyptian\\player_color\\units\\minion_icon.png",
                    [](int unitId = -1) -> void {
                        int p = kbUnitGetPlayerID(unitId);
                        g_isZombieAutoAttack[p] = !g_isZombieAutoAttack[p];
                        if (g_isZombieAutoAttack[p]){
                            trChatSendToPlayer(p, p, "Zombie Auto Attack enabled");
                        } else {
                            trChatSendToPlayer(p, p, "Zombie Auto Attack disabled");
                        }
                    }
                );
    }
}