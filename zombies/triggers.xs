void startGame(){ 
    preModifyPlayerData();
    if (generateBSPMap(cBSPDefaultMaxRegions) == false) {
        errorLog("BSP map generation failed.");
        return;
    }
    if (applyWaveFunctionCollapseToBSPRooms(
            g_bspCells, g_bspHallwayCells, g_bspGridWidth) == false) {
        return;
    }
    finishBSPMap();
}

rule FIRE_FIRST_IMMEDIATELY_TRIGGER
runImmediately
highFrequency
active
{
    trSetCanSeeAllyLOSInFFA(true);
    for (int p=1; p <= cNumberPlayers; p++){
        if (kbPlayerIsHuman(p) == false) {
            trExecuteOnAI(p, "scenarioDisableAI()");
        }
    }
    trDisablePopCapNotifications(true);
    trDisableConquestCheck(true);
    trSetCommunityObjectivesVisibility(false);
    initializeGlobals();
    initializeSocketAdjacencyTable();
    //initialiseUiSystems(false);
    //performProportionCalculation();
    g_OnCreationListener.init();
    //g_AttachmentManager.init();
    highFreqScheduler.add(50, [](int iterations = 1) -> bool {
        g_OnCreationListener.process();
        return true;
    });
    xsDisableSelf();
}

rule FIRE_SECOND_TRIGGER
highFrequency
active
{
    startGame();
    xsDisableSelf();
}