int[] g_finalTeam = default;

void initializeTeams(){
    int maxHumanPlayer = cNumberPlayers - 2;
    if (maxHumanPlayer < 1) return;

    int aiA = cNumberPlayers - 1;
    int aiB = cNumberPlayers;

    g_finalTeam = new int(cNumberPlayers + 1, 0);

    // Treat connected human alliances as groups so an existing team stays together when possible.
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
                                if (trPlayerGetDiplomacy(member, other) == "Ally" ||
                                    trPlayerGetDiplomacy(other, member) == "Ally") {
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

    int[] groupSize = new int(totalGroups + 1, 0);
    for (int p = 1; p <= maxHumanPlayer; p++) {
        int g = groupID[p];
        if (g > 0 && g <= totalGroups) {
            groupSize[g] = groupSize[g] + 1;
        }
    }

    // Preserve a balanced lobby setup only when it really represents two complete teams,
    // with one AI allied to each side.
    int aiATeamGroup = 0;
    int aiBTeamGroup = 0;
    bool aiMappingValid = true;
    for (int p = 1; p <= maxHumanPlayer; p++) {
        bool aiAAlly = (trPlayerGetDiplomacy(p, aiA) == "Ally" &&
            trPlayerGetDiplomacy(aiA, p) == "Ally");
        bool aiBAlly = (trPlayerGetDiplomacy(p, aiB) == "Ally" &&
            trPlayerGetDiplomacy(aiB, p) == "Ally");
        bool aiAEnemy = (trPlayerGetDiplomacy(p, aiA) == "Enemy" &&
            trPlayerGetDiplomacy(aiA, p) == "Enemy");
        bool aiBEnemy = (trPlayerGetDiplomacy(p, aiB) == "Enemy" &&
            trPlayerGetDiplomacy(aiB, p) == "Enemy");

        if (aiAAlly) {
            if (aiATeamGroup == 0) {
                aiATeamGroup = groupID[p];
            } else if (aiATeamGroup != groupID[p]) {
                aiMappingValid = false;
            }
        } else if (aiAEnemy == false) {
            aiMappingValid = false;
        }

        if (aiBAlly) {
            if (aiBTeamGroup == 0) {
                aiBTeamGroup = groupID[p];
            } else if (aiBTeamGroup != groupID[p]) {
                aiMappingValid = false;
            }
        } else if (aiBEnemy == false) {
            aiMappingValid = false;
        }
    }

    bool correctlySeparated = (totalGroups == 2 &&
        aiMappingValid &&
        aiATeamGroup > 0 &&
        aiBTeamGroup > 0 &&
        aiATeamGroup != aiBTeamGroup &&
        trPlayerGetDiplomacy(aiA, aiB) == "Enemy" &&
        trPlayerGetDiplomacy(aiB, aiA) == "Enemy");

    if (correctlySeparated) {
        for (int p1 = 1; p1 <= maxHumanPlayer; p1++) {
            for (int p2 = p1 + 1; p2 <= maxHumanPlayer; p2++) {
                bool shouldBeAllies = (groupID[p1] == groupID[p2]);
                bool areMutualAllies = (trPlayerGetDiplomacy(p1, p2) == "Ally" &&
                    trPlayerGetDiplomacy(p2, p1) == "Ally");
                bool areMutualEnemies = (trPlayerGetDiplomacy(p1, p2) == "Enemy" &&
                    trPlayerGetDiplomacy(p2, p1) == "Enemy");
                if ((shouldBeAllies && areMutualAllies == false) ||
                    (shouldBeAllies == false && areMutualEnemies == false)) {
                    correctlySeparated = false;
                }
            }
        }
    }

    if (correctlySeparated &&
        (groupSize[aiATeamGroup] - groupSize[aiBTeamGroup] <= 1) &&
        (groupSize[aiBTeamGroup] - groupSize[aiATeamGroup] <= 1)) {
        for (int p = 1; p <= maxHumanPlayer; p++) {
            g_finalTeam[p] = (groupID[p] == aiATeamGroup) ? 1 : 2;
        }
        g_finalTeam[aiA] = 1;
        g_finalTeam[aiB] = 2;
        return;
    }

    // Use an exact subset-sum split to keep alliance groups together whenever possible.
    int targetTeam1Size = maxHumanPlayer / 2;
    int[] canMakeSize = new int(targetTeam1Size + 1, 0);
    int[] previousGroup = new int(targetTeam1Size + 1, -1);
    int[] previousSize = new int(targetTeam1Size + 1, -1);
    canMakeSize[0] = 1;

    for (int g = 1; g <= totalGroups; g++) {
        for (int size = targetTeam1Size; size >= groupSize[g]; size = size - 1) {
            if (canMakeSize[size] == 0 && canMakeSize[size - groupSize[g]] == 1) {
                canMakeSize[size] = 1;
                previousGroup[size] = g;
                previousSize[size] = size - groupSize[g];
            }
        }
    }

    if (canMakeSize[targetTeam1Size] == 1) {
        int size = targetTeam1Size;
        while (size > 0) {
            int g = previousGroup[size];
            if (g <= 0) break;
            for (int p = 1; p <= maxHumanPlayer; p++) {
                if (groupID[p] == g) {
                    g_finalTeam[p] = 1;
                }
            }
            size = previousSize[size];
        }
        for (int p = 1; p <= maxHumanPlayer; p++) {
            if (g_finalTeam[p] == 0) {
                g_finalTeam[p] = 2;
            }
        }
    } else {
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

    g_finalTeam[aiA] = 1;
    g_finalTeam[aiB] = 2;

    // Apply the resolved team assignment to player diplomacy.
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

    trPlayerSetDiplomacy(aiA, aiB, "Enemy", true);
    trPlayerSetDiplomacy(aiA, 0, "Ally", true);
    trPlayerSetDiplomacy(aiB, 0, "Ally", true);
}

int[] getPlayersInTeam(int team = 0){
    int[] playersInTeam = new int(0, 0);
    for (int p = 1; p <= cNumberPlayers; p++){
        if (g_finalTeam[p] == team){
            playersInTeam.add(p);
        }
    }
    return playersInTeam;
}

int getTeamsAIPlayer(int team = 0){
    if (team == 1){
        return cNumberPlayers - 1;
    }
    else if (team == 2){
        return cNumberPlayers;
    }
    return 0;
}