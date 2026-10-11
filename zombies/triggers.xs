void startGame(){ 
    preModifyPlayerData();
    generateDungeonMap();
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
    //initialiseUiSystems(false);
    //performProportionCalculation();
    //g_OnCreationListener.init();
    //g_AttachmentManager.init();
    //highFreqScheduler.add(50, [](int iterations = 1) -> bool {
    //    g_OnCreationListener.process();
    //    return true;
    //});
    startGame();
    xsDisableSelf();
}