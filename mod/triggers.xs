include "../common/ui.xs";
include "config.xs";
include "data/player.xs"
include "common/ui.xs"

void startGame(){
    initializeGlobals();
    initializeTeams();

    preModifyPlayerData();

    createAIBases();
    createBossPits();
    createCornerColosseums();
    createCornerCaves();
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
    postApplyBalancePatch();

    __worldSmooth(0, 0, __getMapSizeTilesX(), __getMapSizeTilesZ(), false, 2);
    updateTerrainObstructions();
    
    startBoss();
    startTeamResignedCheck();

    trPlayerSetName(cNumberPlayers-1, "ItzJover1");
    trPlayerSetName(cNumberPlayers, "ItzJover2");
    trChatSend(cNumberPlayers, "Welcome to Deck of the Ages!");
    trChatSend(cNumberPlayers, "This mod is currently a pre-alpha build and is under development. Everything is subject to change.");
    trChatSend(cNumberPlayers, "Created by ItzJover.");

    for (int p=1; p <= cNumberPlayers-2; p++){
        if (trCurrentPlayer() == p){
            BenchData bench = g_shop.m_benches[trCurrentPlayer()];
            int shopId = bench.m_playerShopId;
            cameraLookAt(trUnitGetPosition(shopId), 60.0, 45.0, 45.0);
        }
    }
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
            selectSingle(unitId);
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
                    setTeamAsWinner((g_finalTeam[owner] == 1) ? 2 : 1);
                }
                default: {
                    if (owner == 0 || owner == cNumberPlayers - 1 || owner == cNumberPlayers - 2) {
                        if (kbUnitIsType(unitId, cUnitTypeLogicalTypeHandUnitsAutoAttack) || kbUnitIsType(unitId, cUnitTypeLogicalTypeRangedUnitsAutoAttack)){
                            trUnitSetStance("Defensive");
                        }
                    }
                }
            }
        });
        Search_lastTime = xsGetTimeMS();
    }
}

rule _Attachments
highFrequency
active
runImmediately
{
    g_AttachmentManager.process();
}

rule SUDDEN_DEATH
highFrequency
active
{
    if (xsGetTimeMS() - cActivationTime >= SUDDEN_DEATH_MS) {
        scheduler.add(ADD_OSIRIS_CARD_INTERVAL_MS, [](int iterations = 1) -> bool {
            addOsirisCardIntoDeck();
            return true;
        });
        xsDisableSelf();
    }
}

rule DEV_MODE
highFrequency
active
{
    if(kbPlayerGetName(1) == "ItzJover" && trChatHistoryContains("devmode")){
        trCreateRevealer(1, "default", vector(0, configMapBaseHeight, 0), 9999, false);
        trPlayerGrantResources(1, "Gold", 99999);
        trGodPowerGrant(1, "MeteorSPC", 99, 0, false, false);
        xsDisableSelf();
    }
}