const int VOTE_ROLE_HUMAN = 1;
const int VOTE_ROLE_ZOMBIE = 2;
const string VOTE_HUMAN_ICON = "resources/atlantean/player_color/units/villager_atlantean_hero_icon.png";
const string VOTE_ZOMBIE_ICON = "resources/egyptian/static_color/god_powers/ancestors_icon.png";

// ==========================================
// UI LAYOUT CONFIGURATION CONSTANTS
// ==========================================
const float UI_MASTER_Y_OFFSET = -0.05;        // Move ENTIRE UI up (+) or down (-)

const float UI_COUNTDOWN_Y = -0.5;            // Countdown banner Y position (moves with master offset)
const float UI_TOP_OFFSET = 0.45;             // Nav tabs Y offset
const float UI_ROLE_ICON_Y = 0.22;            // Role selection icon Y
const float UI_ROLE_TITLE_Y_NORMAL = 0.30;    // Unselected role text Y
const float UI_ROLE_TITLE_Y_SELECTED = 0.32;   // Selected role text Y
const float UI_ROLE_HORIZONTAL_SPREAD = 0.28;   // Distance of role columns from center

const float UI_SETTINGS_HEADER_Y = 0.34;      // Settings main header Y
const float UI_SETTINGS_ROW_START_Y = 0.27;   // First settings row Y
const float UI_SETTINGS_ROW_STEP = 0.15;      // Vertical gap between settings rows
const float UI_BUTTON_TO_VOTE_SPACING = 0.05; // Gap between setting button & tally
const float UI_SETTING_OPTION_SPACING = 0.18; // Horizontal gap between option buttons
const float UI_TAB_X_OFFSET = 0.12;           // Horizontal tab offset

int[] g_votePlayers = default;
int[] g_voteSelections = default;
bool g_voteActive = false;
bool g_roleVoteComplete = false;
int g_voteEndTimeMS = 0;

const int VOTE_PAGE_ROLE = 0;
const int VOTE_PAGE_SETTINGS = 1;
const int VOTE_SETTING_DAYS = 0;
const int VOTE_SETTING_MOON = 1;
const int VOTE_SETTING_DAY_LENGTH = 2;
const int VOTE_SETTING_NIGHT_LENGTH = 3;
const int VOTE_SETTING_COUNT = 4;

int[] g_votePages = default;
int[] g_voteDaysSelections = default;
int[] g_voteMoonSelections = default;
int[] g_voteDayLengthSelections = default;
int[] g_voteNightLengthSelections = default;
int[] g_voteDaysOptions = default;
int[] g_voteMoonOptions = default;
int[] g_voteDayLengthOptions = default;
int[] g_voteNightLengthOptions = default;

bool isHumanVotePlayer(int p = 1) {
    return kbPlayerIsHuman(p);
}

int getVoteSettingOptionCount(int setting = 0) {
    if (setting == VOTE_SETTING_DAYS) {
        return g_voteDaysOptions.size();
    }
    if (setting == VOTE_SETTING_MOON) {
        return g_voteMoonOptions.size();
    }
    if (setting == VOTE_SETTING_DAY_LENGTH) {
        return g_voteDayLengthOptions.size();
    }
    return g_voteNightLengthOptions.size();
}

int getVoteSettingOption(int setting = 0, int index = 0) {
    if (setting == VOTE_SETTING_DAYS) {
        return g_voteDaysOptions[index];
    }
    if (setting == VOTE_SETTING_MOON) {
        return g_voteMoonOptions[index];
    }
    if (setting == VOTE_SETTING_DAY_LENGTH) {
        return g_voteDayLengthOptions[index];
    }
    return g_voteNightLengthOptions[index];
}

int getVoteSettingSelection(int setting = 0, int player = 1) {
    if (setting == VOTE_SETTING_DAYS) {
        return g_voteDaysSelections[player];
    }
    if (setting == VOTE_SETTING_MOON) {
        return g_voteMoonSelections[player];
    }
    if (setting == VOTE_SETTING_DAY_LENGTH) {
        return g_voteDayLengthSelections[player];
    }
    return g_voteNightLengthSelections[player];
}

void setVoteSettingSelection(int setting = 0, int player = 1, int value = 0) {
    if (setting == VOTE_SETTING_DAYS) {
        g_voteDaysSelections[player] = value;
    } else if (setting == VOTE_SETTING_MOON) {
        g_voteMoonSelections[player] = value;
    } else if (setting == VOTE_SETTING_DAY_LENGTH) {
        g_voteDayLengthSelections[player] = value;
    } else {
        g_voteNightLengthSelections[player] = value;
    }
}

string formatVoteSeconds(int totalSeconds = 0) {
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds - (minutes * 60);
    string secondsText = "" + seconds;
    if (seconds < 10) {
        secondsText = "0" + secondsText;
    }
    return "" + minutes + ":" + secondsText;
}

int getSettingVoteCount(int setting = 0, int value = 0) {
    int count = 0;
    for (int i = 0; i < g_votePlayers.size(); i++) {
        int player = g_votePlayers[i];
        if (isHumanVotePlayer(player) && getVoteSettingSelection(setting, player) == value) {
            count = count + 1;
        }
    }
    return count;
}

int resolveSettingVote(int setting = 0, int fallback = 0) {
    int optionCount = getVoteSettingOptionCount(setting);
    int best = 0;
    for (int i = 0; i < optionCount; i++) {
        best = max(best, getSettingVoteCount(setting, getVoteSettingOption(setting, i)));
    }
    if (best == 0) {
        return fallback;
    }
    int[] tied = new int(0, 0);
    for (int i = 0; i < optionCount; i++) {
        int option = getVoteSettingOption(setting, i);
        if (getSettingVoteCount(setting, option) == best) {
            tied.add(option);
        }
    }
    return tied[xsRandInt(0, tied.size() - 1)];
}

string getSettingTallyDisplay(int p = 1, ref Parameters parameters) {
    int count = getSettingVoteCount(parameters.ints[0], parameters.ints[1]);
    return "Votes: " + count + minimapSafeSuffix(xsIntToFloat(parameters.ints[2]) / 1000.0);
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

void drawVoteButton(int p = 1, float x = 0.0, float y = 0.0, string text = "", int iconPixels = 128) {
    minimapSafeDisplay(p, x, y - 0.05,
        getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", iconPixels));
    minimapSafeDisplay(p, x, y, text);
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

    // Countdown Banner linked with Master Y Offset
    Parameters countdownParameters = createParameters();
    uiSystemAddDisplayDynamic(
        p, 0.0, UI_COUNTDOWN_Y + UI_MASTER_Y_OFFSET, 250, getVoteCountdown, countdownParameters);

    // Draw Tab Switchers at top
    float tabY = UI_TOP_OFFSET + UI_MASTER_Y_OFFSET;
    for (int page = VOTE_PAGE_ROLE; page <= VOTE_PAGE_SETTINGS; page++) {
        float tabX = (page == VOTE_PAGE_ROLE) ? -UI_TAB_X_OFFSET : UI_TAB_X_OFFSET;
        string tabName = "GAME\nSETTINGS";
        if (page == VOTE_PAGE_ROLE) {
            tabName = "ROLE";
        }
        string tabLabel = tabName;
        if (g_votePages[p] == page) {
            tabLabel = "[ " + tabName + " ]";
        }
        Parameters tabParameters = createParameters();
        tabParameters.ints.add(page);
        drawVoteButton(p, tabX, tabY, tabLabel, 128);
        minimapSafeClickableWithHover(
            p, tabX, tabY - 0.015, 0.25, 0.05, "", tabName,
            "Switch to the " + tabName + " voting screen.",
            tabParameters,
            [](int player = 1, ref Parameters parameters) -> void {
                if (g_voteActive == false) {
                    return;
                }
                g_votePages[player] = parameters.ints[0];
                refreshVoteUI(player);
            }
        );
    }

    // Settings Page Layout
    if (g_votePages[p] == VOTE_PAGE_SETTINGS) {
        minimapSafeDisplay(p, 0.0, UI_SETTINGS_HEADER_Y + UI_MASTER_Y_OFFSET, "GAME SETTINGS");
        for (int setting = VOTE_SETTING_DAYS; setting <= VOTE_SETTING_NIGHT_LENGTH; setting++) {
            int optionCount = getVoteSettingOptionCount(setting);
            float headerY = (UI_SETTINGS_ROW_START_Y - (UI_SETTINGS_ROW_STEP * xsIntToFloat(setting))) + UI_MASTER_Y_OFFSET;
            string header = "BLOOD MOON EVERY (DAYS)";
            if (setting == VOTE_SETTING_DAYS) {
                header = "DAYS TO SURVIVE";
            } else if (setting == VOTE_SETTING_DAY_LENGTH) {
                header = "DAY DURATION";
            } else if (setting == VOTE_SETTING_NIGHT_LENGTH) {
                header = "NIGHT DURATION";
            }
            float buttonY = headerY - UI_BUTTON_TO_VOTE_SPACING;
            float tallyY = buttonY - UI_BUTTON_TO_VOTE_SPACING;
            minimapSafeDisplay(p, 0.0, headerY, header);
            float startX = -0.5 * UI_SETTING_OPTION_SPACING * xsIntToFloat(optionCount - 1);
            for (int i = 0; i < optionCount; i++) {
                int value = getVoteSettingOption(setting, i);
                float optionX = startX + UI_SETTING_OPTION_SPACING * xsIntToFloat(i);
                string valueText = "" + value;
                string hoverText = "Vote for a blood moon every " + valueText + " days.";
                string hoverName = valueText + " days";
                if (setting == VOTE_SETTING_DAYS) {
                    hoverText = "Vote to survive " + valueText + " days to win.";
                } else if (setting == VOTE_SETTING_DAY_LENGTH) {
                    valueText = formatVoteSeconds(value);
                    hoverName = valueText;
                    hoverText = "Vote for each day to last " + valueText + ".";
                } else if (setting == VOTE_SETTING_NIGHT_LENGTH) {
                    valueText = formatVoteSeconds(value);
                    hoverName = valueText;
                    hoverText = "Vote for each night to last " + valueText + ".";
                }
                string optionText = valueText;
                if (getVoteSettingSelection(setting, p) == value) {
                    optionText = "[ " + valueText + " ]";
                }
                Parameters optionParameters = createParameters();
                optionParameters.ints.add(setting);
                optionParameters.ints.add(value);
                drawVoteButton(p, optionX, buttonY, optionText, 96);
                minimapSafeClickableWithHover(
                    p, optionX, buttonY - 0.015, 0.10, 0.05, "",
                    hoverName, hoverText,
                    optionParameters,
                    [](int player = 1, ref Parameters parameters) -> void {
                        if (g_voteActive == false) {
                            return;
                        }
                        setVoteSettingSelection(parameters.ints[0], player, parameters.ints[1]);
                        refreshVoteUI(player);
                    }
                );
                Parameters tallyParameters = createParameters();
                tallyParameters.ints.add(setting);
                tallyParameters.ints.add(value);
                tallyParameters.ints.add(xsFloatToInt(tallyY * 1000.0));
                uiSystemAddDisplayDynamic(
                    p, optionX, -0.5, 250, getSettingTallyDisplay, tallyParameters);
            }
        }
        postEnterUiSystem(p);
        return;
    }

    // Role Selection Page Layout
    minimapSafeDisplay(p, 0.0, UI_SETTINGS_HEADER_Y + UI_MASTER_Y_OFFSET, "CHOOSE YOUR ROLE");

    for (int role = VOTE_ROLE_HUMAN; role <= VOTE_ROLE_ZOMBIE; role++) {
        float roleX = (role == VOTE_ROLE_HUMAN) ? -UI_ROLE_HORIZONTAL_SPREAD : UI_ROLE_HORIZONTAL_SPREAD;
        bool isSelected = (g_voteSelections[p] == role);
        string roleIcon = (role == VOTE_ROLE_HUMAN)
            ? VOTE_HUMAN_ICON : VOTE_ZOMBIE_ICON;
        string roleName = (role == VOTE_ROLE_HUMAN) ? "HUMAN" : "ZOMBIE";
        int iconPixels = isSelected ? 88 : 72;
        float iconY = UI_ROLE_ICON_Y + UI_MASTER_Y_OFFSET;
        float titleY = (isSelected ? UI_ROLE_TITLE_Y_SELECTED : UI_ROLE_TITLE_Y_NORMAL) + UI_MASTER_Y_OFFSET;

        Parameters roleParameters = createParameters();
        roleParameters.ints.add(role);
        minimapSafeClickableWithHover(
            p, roleX, iconY, 0.10, 0.10,
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
        float roleX = (role == VOTE_ROLE_HUMAN) ? -UI_ROLE_HORIZONTAL_SPREAD : UI_ROLE_HORIZONTAL_SPREAD;
        int row = (role == VOTE_ROLE_HUMAN) ? humanRows : zombieRows;
        float rowY = (0.025 - (xsIntToFloat(row) * rowSpacing)) + UI_MASTER_Y_OFFSET;
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

    g_daysToSurvive = resolveSettingVote(VOTE_SETTING_DAYS, g_daysToSurvive);
    bloodMoonCycle = resolveSettingVote(VOTE_SETTING_MOON, bloodMoonCycle);
    g_dayDurationMS = resolveSettingVote(VOTE_SETTING_DAY_LENGTH, g_dayDurationMS / 1000) * 1000;
    g_nightDurationMS = resolveSettingVote(VOTE_SETTING_NIGHT_LENGTH, g_nightDurationMS / 1000) * 1000;
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
    g_votePages = new int(cNumberPlayers + 1, VOTE_PAGE_ROLE);
    g_voteDaysSelections = new int(cNumberPlayers + 1, g_daysToSurvive);
    g_voteMoonSelections = new int(cNumberPlayers + 1, bloodMoonCycle);
    g_voteDaysOptions = new int(0, 0);
    g_voteDaysOptions.add(7);
    g_voteDaysOptions.add(10);
    g_voteDaysOptions.add(14);
    g_voteMoonOptions = new int(0, 0);
    g_voteMoonOptions.add(3);
    g_voteMoonOptions.add(5);
    g_voteMoonOptions.add(7);
    g_voteMoonOptions.add(10);
    g_voteDayLengthSelections = new int(cNumberPlayers + 1, g_dayDurationMS / 1000);
    g_voteNightLengthSelections = new int(cNumberPlayers + 1, g_nightDurationMS / 1000);
    g_voteDayLengthOptions = new int(0, 0);
    g_voteDayLengthOptions.add(120);
    g_voteDayLengthOptions.add(90);
    g_voteDayLengthOptions.add(60);
    g_voteNightLengthOptions = new int(0, 0);
    g_voteNightLengthOptions.add(240);
    g_voteNightLengthOptions.add(210);
    g_voteNightLengthOptions.add(180);
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