int[] g_finalTeam = default;

void initializeTeams(){
    int maxHumanPlayer = cNumberPlayers - 2;
    if (maxHumanPlayer < 1) return;

    int aiA = cNumberPlayers - 1;
    int aiB = cNumberPlayers;

    g_finalTeam = new int(cNumberPlayers + 1, 0);

    // 1. Group human players into pre-existing teams based on mutual diplomacy
    int[] groupID = new int(maxHumanPlayer + 1, 0);
    int nextGroup = 1;

    for (int p = 1; p <= maxHumanPlayer; p++) {
        if (groupID[p] == 0) {
            groupID[p] = nextGroup;
            bool changed = true;
            while (changed) {
                changed = false;
                for (int other = 1; other <= maxHumanPlayer; other++) {
                    if (groupID[other] == 0) {
                        bool isAlliedWithGroup = false;
                        for (int member = 1; member <= maxHumanPlayer; member++) {
                            if (groupID[member] == nextGroup) {
                                if (member == other || trPlayerGetDiplomacy(member, other) == "Ally") {
                                    isAlliedWithGroup = true;
                                    break;
                                }
                            }
                        }
                        if (isAlliedWithGroup) {
                            groupID[other] = nextGroup;
                            changed = true;
                        }
                    }
                }
            }
            nextGroup = nextGroup + 1;
        }
    }
    
    int totalGroups = nextGroup - 1;

    // 2. Calculate the size of each discovered pre-made team group
    int[] groupSize = new int(totalGroups + 1, 0);
    for (int p = 1; p <= maxHumanPlayer; p++) {
        int g = groupID[p];
        if (g > 0 && g <= totalGroups) {
            groupSize[g] = groupSize[g] + 1;
        }
    }

    // Sort groups descending by size
    int[] sortedGroupIndices = new int(totalGroups + 1, 0);
    for (int g = 1; g <= totalGroups; g++) {
        sortedGroupIndices[g] = g;
    }
    for (int i = 1; i <= totalGroups; i++) {
        for (int j = i + 1; j <= totalGroups; j++) {
            int g1 = sortedGroupIndices[i];
            int g2 = sortedGroupIndices[j];
            if (groupSize[g1] < groupSize[g2]) {
                sortedGroupIndices[i] = g2;
                sortedGroupIndices[j] = g1;
            }
        }
    }

    // 3. Check if packing groups together creates an even split
    // Total human players must be divisible by 2 for a completely even group split.
    bool canPackCleanly = (maxHumanPlayer % 2 == 0);
    if (canPackCleanly) {
        int targetPerTeam = maxHumanPlayer / 2;
        int testTeam1Size = 0;
        for (int i = 1; i <= totalGroups; i++) {
            int g = sortedGroupIndices[i];
            testTeam1Size = testTeam1Size + groupSize[g];
        }
        // If the largest group is bigger than half the lobby, clean packing is impossible anyway
        if (groupSize[sortedGroupIndices[1]] > targetPerTeam) {
            canPackCleanly = false;
        }
    }

    int[] finalGroupTeam = new int(totalGroups + 1, 1);
    
    if (canPackCleanly) {
        // Pack entire groups while keeping Team 1 and Team 2 balanced
        int team1Size = 0;
        int team2Size = 0;
        for (int i = 1; i <= totalGroups; i++) {
            int g = sortedGroupIndices[i];
            if (team1Size <= team2Size) {
                finalGroupTeam[g] = 1;
                team1Size = team1Size + groupSize[g];
            } else {
                finalGroupTeam[g] = 2;
                team2Size = team2Size + groupSize[g];
            }
        }
        // Map group decisions back to human players
        for (int p = 1; p <= maxHumanPlayer; p++) {
            int g = groupID[p];
            g_finalTeam[p] = finalGroupTeam[g];
        }
    } else {
        // Fallback: Force break apart groups to guarantee a strictly even individual split
        int team1Size = 0;
        int team2Size = 0;
        for (int p = 1; p <= maxHumanPlayer; p++) {
            if (team1Size <= team2Size) {
                g_finalTeam[p] = 1;
                team1Size = team1Size + 1;
            } else {
                g_finalTeam[p] = 2;
                team2Size = team2Size + 1;
            }
        }
    }

    // 4. Explicitly assign the last two AI players to opposing teams
    g_finalTeam[aiA] = 1;
    g_finalTeam[aiB] = 2;

    // 5. Apply mutual diplomacy between all humans
    for (int p1 = 1; p1 <= maxHumanPlayer; p1 = p1 + 1) {
        for (int p2 = p1 + 1; p2 <= maxHumanPlayer; p2 = p2 + 1) {
            if (g_finalTeam[p1] == g_finalTeam[p2]) {
                trPlayerSetDiplomacy(p1, p2, "Ally", true);
            } else {
                trPlayerSetDiplomacy(p1, p2, "Enemy", true);
            }
        }

        // Set diplomacy with AI commanders
        if (g_finalTeam[p1] == 1) {
            trPlayerSetDiplomacy(p1, aiA, "Ally", true);
            trPlayerSetDiplomacy(p1, aiB, "Enemy", true);
        } else {
            trPlayerSetDiplomacy(p1, aiA, "Enemy", true);
            trPlayerSetDiplomacy(p1, aiB, "Ally", true);
        }
    }

    // 6. Configure AI vs AI and Gaia (Player 0) relationships
    trPlayerSetDiplomacy(aiA, aiB, "Enemy", true);
    
    // Ensure AI players are enemies of Gaia (Player 0)
    trPlayerSetDiplomacy(aiA, 0, "Enemy", true);
    trPlayerSetDiplomacy(aiB, 0, "Enemy", true);
}