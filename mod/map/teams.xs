int[] g_finalTeam = default;

void initializeTeams(){
    int[] initialTeam = new int(cNumberPlayers, 1);
    g_finalTeam = new int(cNumberPlayers, 1);

    int maxHumanPlayer = cNumberPlayers - 2;
    if (maxHumanPlayer < 1) return;

    int aiTeamA = cNumberPlayers - 1;
    int aiTeamB = cNumberPlayers;

    int teamACount = 0;
    int teamBCount = 0;

    // 1. Snapshot initial human team state relative to Player 1
    for (int p = 1; p <= maxHumanPlayer; p = p + 1) {
        if (p == 1 || trPlayerGetDiplomacy(p, 1) == "Ally") {
            initialTeam[p] = 1; // Group 1 (Allies with P1)
            teamACount = teamACount + 1;
        } else {
            initialTeam[p] = 2; // Group 2 (Enemies with P1)
            teamBCount = teamBCount + 1;
        }
    }

    int totalHumans = maxHumanPlayer;
    int targetTeamA = totalHumans / 2; // Target capacity for Team A

    // 2. Determine if starting layout is already balanced
    int diff = teamACount - teamBCount;
    if (diff < 0) diff = 0 - diff;

    bool isAlreadyBalanced = (diff <= 1) && (teamACount > 0) && (teamBCount > 0);

    if (isAlreadyBalanced) {
        for (int p = 1; p <= maxHumanPlayer; p = p + 1) {
            g_finalTeam[p] = initialTeam[p];
        }
    } else {
        // 3. Rebalance: Fill Team A to capacity, send rest to Team B
        int currentTeamA = 0;

        // Pass 1: Keep Player 1 & pre-made allies together on Team A
        for (int p = 1; p <= maxHumanPlayer; p = p + 1) {
            if (initialTeam[p] == 1) {
                if (currentTeamA < targetTeamA) {
                    g_finalTeam[p] = 1;
                    currentTeamA = currentTeamA + 1;
                } else {
                    g_finalTeam[p] = 2;
                }
            }
        }

        // Pass 2: Fill remaining Team A slots with enemies/FFA players
        for (int p = 1; p <= maxHumanPlayer; p = p + 1) {
            if (initialTeam[p] == 2) {
                if (currentTeamA < targetTeamA) {
                    g_finalTeam[p] = 1;
                    currentTeamA = currentTeamA + 1;
                } else {
                    g_finalTeam[p] = 2;
                }
            }
        }
    }

    // 4. Set mutual diplomacy between humans (p2 starts at p1 + 1)
    for (int p1 = 1; p1 <= maxHumanPlayer; p1 = p1 + 1) {
        for (int p2 = p1 + 1; p2 <= maxHumanPlayer; p2 = p2 + 1) {
            if (g_finalTeam[p1] == g_finalTeam[p2]) {
                trPlayerSetDiplomacy(p1, p2, "Ally", true);
            } else {
                trPlayerSetDiplomacy(p1, p2, "Enemy", true);
            }
        }

        // 5. Set mutual diplomacy with AI commanders
        if (g_finalTeam[p1] == 1) {
            trPlayerSetDiplomacy(p1, aiTeamA, "Ally", true);
            trPlayerSetDiplomacy(p1, aiTeamB, "Enemy", true);
        } else {
            trPlayerSetDiplomacy(p1, aiTeamA, "Enemy", true);
            trPlayerSetDiplomacy(p1, aiTeamB, "Ally", true);
        }
    }

    // 6. Mutual enemy stance between AI A and AI B
    trPlayerSetDiplomacy(aiTeamA, aiTeamB, "Enemy", true);
}