int g_mapGenerationPhase = 0;

void startMapGeneration(){
    preModifyPlayerData();
    if (beginBSPMapGeneration(
            g_generatedMap, cBSPDefaultMaxRegions) == false) {
        errorLog("BSP map generation failed.");
        return;
    }
    g_mapGenerationPhase = 0;
    highFreqScheduler.add(500, [](int iterations = 1) -> bool {
        if (g_mapGenerationPhase == 0) {
            if (stepBSPMapGeneration(g_generatedMap) == false) {
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
                    g_bspCells, g_generatedMap) == false) {
                return false;
            }
            if (g_bspTileGenerationComplete == false) return true;
        }

        //placeBSPHallwayDebugMarkers(g_generatedMap);
        return false;
    });
}

void startGame() {
    trChatSend(cNumberPlayers, "This mod is currently a pre-alpha build and is under development. Everything is subject to change.");
    trChatSend(cNumberPlayers, "Created by ItzJover.");
    trPlayerSetDiplomacy(0, cHumanAIPlayer, "Ally", true);
    startMapGeneration();
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
    highFreqScheduler.add(50, [](int iterations = 1) -> bool {
        g_OnCreationListener.process();
        return true;
    });
    lowFreqScheduler.add(1000, [](int iterations = 1) -> bool {
        g_PickupManager.process();
        return true;
    });
    xsDisableSelf();
}

rule START_MAP_AFTER_ROLE_VOTE
highFrequency
active
{
    if (g_roleVoteComplete) {
        startInteractables();
        addAllCommands();
        initializeZombies();
        initializeHumans();
        postModifyPlayerData();
        startDayAndNightCycle(false);
        xsDisableSelf();
    }
}

rule DEV_MODE
highFrequency
active
{
    if(kbPlayerGetName(1) == "ItzJover" && trChatHistoryContains("devmode", 1)){
        for (int p = 1; p <= cNumberPlayers; p++){
            trCreateRevealer(p, "default", vector(0, configMapBaseHeight, 0), 9999, false);
            trPlayerGrantResources(p, "Gold", 99999);
            trPlayerGrantResources(p, "Wood", 99999);
            trGodPowerGrant(p, "MeteorSPC", 99, 0, false, false);
            trModifyProtounitAction("MeteorSPC", "HandAttack", p, cXSActionEffectDamageDivine, 99999, cXSRelativityAssign);
            trGodPowerGrant(p, "ShiftingSands", 99, 0, false, false);
        }
        xsDisableSelf();
    }
    if (kbPlayerGetName(1) != "ItzJover"){
        xsDisableSelf();
    }
    if ((((xsGetTime() - (cActivationTime / 1000)) >= 120) != false))
    {
        xsDisableSelf();
    }
}