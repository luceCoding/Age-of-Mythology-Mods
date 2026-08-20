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
    trExecuteOnAI(cNumberPlayers-1, "scenarioDisableAI()");
    trExecuteOnAI(cNumberPlayers, "scenarioDisableAI()");
    //trAISetAttackResponseDistance(cNumberPlayers, 36.0);
    trDisablePopCapNotifications(true);
    trDisableConquestCheck(true);
    trSetCommunityObjectivesVisibility(false);
    initialiseUiSystem(false);
    performProportionCalculation();
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
            }

            switch(protoUnit){
                case 741: { // GoldPile
                    g_IncomeHandler.addGold(unitId);
                    if (owner != 0){
                        trUnitSetScale(0.5, 0.5, 0.5);
                        if (trPlayerGetDiplomacy(owner, cNumberPlayers-1) == "enemy"){
                            trUnitSetShading(2, 100);
                        }
                    }
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
    for(int p = 1; p <= cNumberPlayers; p = p + 1){
        trCreateRevealer(p, "default", vector(0, configMapBaseHeight, 0), 9999, false);
    }
    initializeCardParametersMap();
    spawnSymmetricObjectives();
    modifyPlayerData();
    createShops();
    initPlayerCommands();
    xsDisableSelf();
}

rule GAME_STARTS
highFrequency
active
{
    g_timeMSGameStarted = xsGetTimeMS();
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 1) != false))
   {
        startRespawner();
        startSchedulers();
        paintAllLanesCircular();

        //generateCreepCamps("Argus", 4, 25.0, 20.0);
        //generateCreepCamps("Dryad", 6, 25.0, 20.0);
        //generateCreepCamps("Satyr", 10, 25.0, 20.0);

        generateCreepCamps("Lure", 10, 25.0, 20.0);

        generateCreepCamps("MiningCamp", 4, 25.0, 16.0);
        generateCreepCamps("MiningCampJapanese", 6, 20.0, 12.0);
        generateCreepCamps("Storehouse", 10, 15.0, 8.0);

        xsDisableSelf();
   }
}

rule FIRE_AFTER_60_SECONDS_TRIGGER
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 60000)) >= 1) != false))
   {
        startLanes();
        xsDisableSelf();
   }
}

rule LOOPING_TRIGGER
highFrequency
active
{
    for(int p = 1; p <= cNumberPlayers; p++){
        UiSystem system = uiSystemArray[p];
        UiEntry entry = system.process();
        uiSystemArray[p] = system;
        entry.handler(p, entry.parameters);
        refreshShop(p);
    }
}