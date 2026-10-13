const int VOTE_ROLE_HUMAN = 1;
const int VOTE_ROLE_ZOMBIE = 2;
const int VOTE_DURATION_MS = 60000;
const string VOTE_HUMAN_ICON = "resources/atlantean/player_color/units/villager_atlantean_hero_icon.png";
const string VOTE_ZOMBIE_ICON = "resources/egyptian/static_color/god_powers/ancestors_icon.png";

int[] g_votePlayers = default;
int[] g_voteSelections = default;
bool g_voteActive = false;
bool g_roleVoteComplete = false;
int g_voteEndTimeMS = 0;

bool isHumanVotePlayer(int p = 1) {
    return kbPlayerIsHuman(p);
}

int getVoteCount(int role = VOTE_ROLE_HUMAN) {
    int count = 0;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        int player = g_votePlayers[i];
        if (isHumanVotePlayer(player) && g_voteSelections[player] == role) {
            count = count + 1;
        }
    }
    return count;
}

string getVoteCountdown(int p = 1, ref Parameters parameters) {
    int remainingMS = g_voteEndTimeMS - xsGetTimeMS();
    if (remainingMS <= 0) {
        return "Starting..." + minimapSafeSuffix(0.39);
    }
    int secondsRemaining = (remainingMS + 999) / 1000;
    return "Voting closes in " + secondsRemaining + " seconds" + minimapSafeSuffix(0.39);
}

string getVoteCountDisplay(int p = 1, ref Parameters parameters) {
    int role = parameters.ints[0];
    if (role == VOTE_ROLE_HUMAN) {
        return "TEAM 1 HUMANS: " + getVoteCount(role) + minimapSafeSuffix(0.085);
    }
    return "TEAM 2 ZOMBIES: " + getVoteCount(role) + minimapSafeSuffix(0.085);
}

void refreshVoteUI(int p = 1) {
    if (g_voteActive == false || p == cHumanAIPlayer) {
        return;
    }

    bool wasActive = uiSystemActiveArray[p];
    enterUiSystem(p);
    if (wasActive == false && trCurrentPlayer() == p) {
        setUiVisible(false);
        trSetObscuredUnits(false);
    }

    //minimapSafeDisplay(p, 0.0, 0.46, "CHOOSE YOUR ROLE");

    Parameters countdownParameters = createParameters();
    uiSystemAddDisplayDynamic(
        p, 0.0, -0.5, 250, getVoteCountdown, countdownParameters);

    minimapSafeDisplay(p, 0.0, 0.34,
        "CHOOSE YOUR ROLE");

    for (int role = VOTE_ROLE_HUMAN; role <= VOTE_ROLE_ZOMBIE; role++) {
        float roleX = (role == VOTE_ROLE_HUMAN) ? -0.28 : 0.28;
        bool isSelected = (g_voteSelections[p] == role);
        string roleIcon = (role == VOTE_ROLE_HUMAN)
            ? VOTE_HUMAN_ICON : VOTE_ZOMBIE_ICON;
        string roleName = (role == VOTE_ROLE_HUMAN) ? "HUMAN" : "ZOMBIE";
        int iconPixels = isSelected ? 88 : 72;
        float titleY = 0.30;
        if (isSelected) {
            titleY = 0.32;
        }

        Parameters roleParameters = createParameters();
        roleParameters.ints.add(role);
        minimapSafeClickableWithHover(
            p, roleX, 0.22, 0.10, 0.10,
            getIconPathFormat(roleIcon, iconPixels),
            roleName,
            (role == VOTE_ROLE_HUMAN)
                ? "Join Team 1 as a human."
                : "Join Team 2 as a zombie.",
            roleParameters,
            [](int player = 1, ref Parameters parameters) -> void {
                if (g_voteActive == false) {
                    return;
                }

                int selectedRole = parameters.ints[0];
                g_voteSelections[player] = selectedRole;
                for (int i = 0; i < g_votePlayers.size(); i++) {
                    refreshVoteUI(g_votePlayers[i]);
                }
            }
        );
        minimapSafeDisplay(p, roleX, titleY, roleName);

        Parameters countParameters = createParameters();
        countParameters.ints.add(role);
        uiSystemAddDisplayDynamic(
            p, roleX, -0.5, 250, getVoteCountDisplay, countParameters);
    }

    int rosterSize = 1;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        if (isHumanVotePlayer(g_votePlayers[i])) {
            rosterSize = rosterSize + 1;
        }
    }
    float rowSpacing = min(0.075, 0.42 / xsIntToFloat(rosterSize));
    int humanRows = 0;
    int zombieRows = 0;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        int player = g_votePlayers[i];
        if (isHumanVotePlayer(player) == false) {
            continue;
        }
        int role = g_voteSelections[player];
        float roleX = (role == VOTE_ROLE_HUMAN) ? -0.28 : 0.28;
        int row = (role == VOTE_ROLE_HUMAN) ? humanRows : zombieRows;
        float rowY = 0.025 - (xsIntToFloat(row) * rowSpacing);
        string roleIcon = (role == VOTE_ROLE_HUMAN)
            ? VOTE_HUMAN_ICON : VOTE_ZOMBIE_ICON;
        minimapSafeDisplay(
            p, roleX, rowY,
            getIconPathFormat(roleIcon, 32) + " " + kbPlayerGetName(player));

        if (role == VOTE_ROLE_HUMAN) {
            humanRows = humanRows + 1;
        } else {
            zombieRows = zombieRows + 1;
        }
    }

    // float aiRowY = 0.025 - (xsIntToFloat(humanRows) * rowSpacing);
    // minimapSafeDisplay(
    //     p, -0.28, aiRowY,
    //     getIconPathFormat(VOTE_HUMAN_ICON, 32) + " HUMAN AI (TEAM 1)");

    postEnterUiSystem(p);
}

void closeVoteUI(int p = 1) {
    if (uiSystemActiveArray[p] == false) {
        return;
    }
    exitUiSystem(p, true);
    if (trCurrentPlayer() == p) {
        setUiVisible(true);
        trSetObscuredUnits(true);
    }
}

void finishRoleVote() {
    if (g_voteActive == false) {
        return;
    }
    g_voteActive = false;

    for (int i = 0; i < g_votePlayers.size(); i++) {
        closeVoteUI(g_votePlayers[i]);
    }

    int activeVoterCount = 0;
    int activeZombieCount = 0;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        int player = g_votePlayers[i];
        if (isHumanVotePlayer(player)) {
            activeVoterCount = activeVoterCount + 1;
            if (g_voteSelections[player] == VOTE_ROLE_ZOMBIE) {
                activeZombieCount = activeZombieCount + 1;
            }
        }
    }
    if (activeVoterCount == 0) {
        errorLog("Cannot start the game: no human players remain after the team vote.");
        return;
    }
    if (activeZombieCount == 0) {
        int randomVoterIndex = xsRandInt(0, g_votePlayers.size() - 1);
        int randomlySelectedZombie = g_votePlayers[randomVoterIndex];
        g_voteSelections[randomlySelectedZombie] = VOTE_ROLE_ZOMBIE;
        trChatSendToPlayer(
            randomlySelectedZombie, randomlySelectedZombie,
            "You were randomly assigned to Team 2 so it has at least one zombie player.");
    }

    setTeams(g_voteSelections);
    g_roleVoteComplete = true;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        trChatSendToPlayer(
            g_votePlayers[i], g_votePlayers[i],
            "Team vote complete. Starting the game.");
    }
}

void startRoleVote() {
    if (g_voteActive) {
        return;
    }

    g_votePlayers = new int(0, 0);
    for (int p = 1; p < cHumanAIPlayer; p++) {
        if (isHumanVotePlayer(p)) {
            g_votePlayers.add(p);
        }
    }

    if (g_votePlayers.size() == 0) {
        errorLog("Cannot start the team vote: no human players are available.");
        return;
    }

    g_voteSelections = new int(cNumberPlayers + 1, VOTE_ROLE_HUMAN);
    int lastVoterIndex = g_votePlayers.size() - 1;
    int initialZombiePlayer = g_votePlayers[lastVoterIndex];
    g_voteSelections[initialZombiePlayer] = VOTE_ROLE_ZOMBIE;
    g_voteEndTimeMS = xsGetTimeMS() + VOTE_DURATION_MS;
    g_voteActive = true;

    for (int i = 0; i < g_votePlayers.size(); i++) {
        refreshVoteUI(g_votePlayers[i]);
    }

    highFreqScheduler.add(1000, [](int iteration = 1) -> bool {
        if (g_voteActive == false) {
            return false;
        }
        if (xsGetTimeMS() < g_voteEndTimeMS) {
            return true;
        }
        finishRoleVote();
        return false;
    });
}