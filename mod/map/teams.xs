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
            // Transitive closure: pull in all mutual allies of anyone in this group
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

    // 3. Pack entire groups into Team 1 or Team 2 to keep counts as balanced as possible
    int[] finalGroupTeam = new int(totalGroups + 1, 1);
    int team1Size = 0;
    int team2Size = 0;

    for (int g = 1; g <= totalGroups; g++) {
        if (team1Size <= team2Size) {
            finalGroupTeam[g] = 1;
            team1Size = team1Size + groupSize[g];
        } else {
            finalGroupTeam[g] = 2;
            team2Size = team2Size + groupSize[g];
        }
    }

    // Map group decisions back to the final team array for humans
    for (int p = 1; p <= maxHumanPlayer; p++) {
        int g = groupID[p];
        g_finalTeam[p] = finalGroupTeam[g];
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