int[] g_finalTeams = default;

void switchPlayerToZombieTeam(int player = -1) {
    g_finalTeams[player] = 2;
    for (int other = 1; other <= cNumberPlayers; other++) {
        if (other == player || g_finalTeams[other] == 0) {
            continue;
        }
        string diplomacy = (g_finalTeams[other] == 2) ? "Ally" : "Enemy";
        trPlayerSetDiplomacy(player, other, diplomacy, true);
        trPlayerSetDiplomacy(other, player, diplomacy, true);
    }
}

void setTeams(ref int[] voteSelections){
    g_finalTeams = new int(cNumberPlayers + 1, 0);
    g_finalTeams[cHumanAIPlayer] = 1;

    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (kbPlayerIsHuman(p)) {
            g_finalTeams[p] = (voteSelections[p] == 2) ? 2 : 1;
        }
    }

    for (int p1 = 1; p1 <= cNumberPlayers; p1++) {
        if (g_finalTeams[p1] == 0) {
            continue;
        }
        for (int p2 = p1 + 1; p2 <= cNumberPlayers; p2++) {
            if (g_finalTeams[p2] == 0) {
                continue;
            }
            string diplomacy = (g_finalTeams[p1] == g_finalTeams[p2])
                ? "Ally" : "Enemy";
            trPlayerSetDiplomacy(p1, p2, diplomacy, true);
            trPlayerSetDiplomacy(p2, p1, diplomacy, true);
        }
    }
}