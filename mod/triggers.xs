include "../common/ui.xs";
include "config.xs";
include "data/player.xs"
include "common/ui.xs"

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
    initializeGlobals();
    initializeTeams();
    createAIBases();
    createBaseOuterwalls();
    initializeShopLevels();
    initializeSynergies();
    g_shop.init();
    xsDisableSelf();
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
                    log(-1, ""+owner+" "+losingTeam);
                    for (int p = 1; p < cNumberPlayers; p++) {
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

rule FIRE_SECOND_TRIGGER
highFrequency
active
{
    initializeCardParametersMap();
    spawnSymmetricObjectives();
    modifyPlayerData();
    createShops();
    initPlayerCommands();
    trHideScoreboard();
    xsDisableSelf();
}

rule GAME_STARTS
highFrequency
active
{
    g_timeMSGameStarted = xsGetTimeMS();
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 1) != false))
   {
        startShopTimers();
        startIncome();
        paintAllLanesCircular();
        generateAllCamps();
        startCapturePoints();
        xsDisableSelf();
   }
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

rule DEV_MODE
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 60000)) >= 1) != false))
   {
        for(int p = 1; p <= cNumberPlayers; p = p + 1){
            //trCreateRevealer(p, "default", vector(0, configMapBaseHeight, 0), 9999, false);
            trPlayerGrantResources(p, "Gold", 99999);
            //trGodPowerGrant(p, "MeteorSPC", 99, 0, false, false);
        }
        xsDisableSelf();
   }
}