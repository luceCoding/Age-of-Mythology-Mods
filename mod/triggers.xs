include "../common/ui.xs";
include "config.xs";
include "data/player.xs"
include "common/ui.xs"

void startGame(){
    initializeGlobals();
    initializeTeams();

    preModifyPlayerData();

    createAIBases();
    createBaseOuterwalls();
    spawnSymmetricObjectives();

    g_shop.init();
    initializeCardParametersMap();
    initializeShopLevels();
    initializeSynergies();

    createShops();
    initPlayerCommands();
    trHideScoreboard();

    startShopTimers();
    startIncome();
    paintAllLanesCircular();
    generateAllCamps();
    startCapturePoints();

    postModifyPlayerData();
}

rule FIRE_FIRST_IMMEDIATELY_TRIGGER
runImmediately
highFrequency
active
{
    trSetCanSeeAllyLOSInFFA(true);
    for (int p=1; p <= cNumberPlayers; p++){
        if (!(kbPlayerIsHuman(p))){
            trExecuteOnAI(p, "scenarioDisableAI()");
        }
    }
    //trAISetAttackResponseDistance(cNumberPlayers, 36.0);
    trDisablePopCapNotifications(true);
    trDisableConquestCheck(true);
    trSetCommunityObjectivesVisibility(false);
    initialiseUiSystems(false);
    performProportionCalculation();
    xsDisableSelf();
}

rule FIRE_AFTER_30_SECONDS_TRIGGER
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 30) != false))
   {
        startLanes();
        xsDisableSelf();
   }
}

rule _Search
highFrequency
active
runImmediately
{
    if (Search_conditionToRun(Search_lastTime)) {
        ySearch.process([](int unitId = 0) -> void {
            xsSetContextPlayer(-1);
            int protoUnit = kbUnitGetProtoUnitID(unitId);
            int owner = kbUnitGetPlayerID(unitId);
            xsSetContextPlayer(owner);

            if (kbProtoUnitIsType(protoUnit, COMMAND_TYPE)) {
                selectSingle(unitId);
                trUnitDestroy();
                PlayerCommands playerCommands = playerCommandsArray[owner];
                for (int i = 0; i < playerCommands.plantArray.size(); i++) {
                    if (playerCommands.plantArray[i] == protoUnit) {
                        void(int) apply = playerCommands.applyArray[i];
                        apply(owner);
                    }
                }
                return;
            }

            switch(protoUnit){
                case 741: { // GoldPile
                    g_IncomeHandler.addGold(unitId);
                    if (owner != 0){
                        trUnitSetScale(0.5, 0.5, 0.5);
                    }
                }
                case cUnitTypeFlyingPurpleHippo: {
                    int losingTeam = g_finalTeam[owner];
                    for (int p = 1; p <= cNumberPlayers; p++) {
                        if (g_finalTeam[p] == losingTeam) {
                            trPlayerSetDefeated(p);
                        } else {
                            trPlayerSetWon(p, false);
                        }
                    }
                    trEndGame();
                }
            }
        });
        Search_lastTime = xsGetTimeMS();
    }
}

rule DEV_MODE
highFrequency
active
{
    if(kbPlayerGetName(1) == "ItzJover" && trChatHistoryContains("devmode")){
        trPlayerGrantResources(1, "Gold", 99999);
        xsDisableSelf();
    }
}