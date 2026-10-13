void finishGameMapGeneration() {
    initializeZombies();
    initializeHumans();
}

int g_mapGenerationPhase = 0;

void startMapGeneration(){
    preModifyPlayerData();
    if (beginBSPMapGeneration(cBSPDefaultMaxRegions) == false) {
        errorLog("BSP map generation failed.");
        return;
    }
    g_mapGenerationPhase = 0;
    highFreqScheduler.add(500, [](int iterations = 1) -> bool {
        if (g_mapGenerationPhase == 0) {
            if (stepBSPMapGeneration() == false) {
                errorLog("BSP room generation failed.");
                return false;
            }
            if (g_bspGenerationComplete == false) return true;
            if (beginWaveFunctionCollapseToBSPRooms(g_bspCells) == false) {
                return false;
            }
            g_mapGenerationPhase = 1;
            return true;
        }

        if (g_bspTileGenerationComplete == false) {
            if (generateNextBSPRoomLayout(
                    g_bspCells, g_bspHallwayCells, g_bspGridWidth) == false) {
                return false;
            }
            if (g_bspTileGenerationComplete == false) return true;
        }

        finishGameMapGeneration();
        return false;
    });
}

void startGame() {
    startRoleVote();
}

rule FIRE_FIRST_IMMEDIATELY_TRIGGER
runImmediately
highFrequency
active
{
    for (int p=1; p <= cNumberPlayers; p++){
        if (kbPlayerIsHuman(p) == false) {
            trExecuteOnAI(p, "scenarioDisableAI()");
        }
    }
    trSetCanSeeAllyLOSInFFA(true);
    trDisablePopCapNotifications(true);
    trDisableConquestCheck(true);
    trSetCommunityObjectivesVisibility(false);
    initialiseUiSystems(false);
    performProportionCalculation();
    initializeGlobals();
    initializeSocketAdjacencyTable();
    g_OnCreationListener.init();
    //g_AttachmentManager.init();
    highFreqScheduler.add(50, [](int iterations = 1) -> bool {
        g_OnCreationListener.process();
        return true;
    });
    xsDisableSelf();
}

rule START_MAP_AFTER_ROLE_VOTE
highFrequency
active
{
    if (g_roleVoteComplete) {
        startMapGeneration();
        startInteractables();
        xsDisableSelf();
    }
}