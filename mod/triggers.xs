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

    startBoss();

    trPlayerSetName(cNumberPlayers-1, "ItzJover1");
    trPlayerSetName(cNumberPlayers, "ItzJover2");
    trChatSend(cNumberPlayers, "Welcome to Deck of the Ages!");
    trChatSend(cNumberPlayers, "This mod is currently a pre-alpha build and is under development. Everything is subject to change.");
    trChatSend(cNumberPlayers, "Created by ItzJover.");

    for (int p=1; p < cNumberPlayers-2; p++){
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
                case cUnitTypeOsirisPieceBox: {
                    xsSetContextPlayer(owner);
                    int __queryId = kbUnitQueryCreate("__QueryId"+g_uuid.getNextUUID());
                    kbUnitQuerySetPlayerID(__queryId, owner);
                    kbUnitQuerySetUnitType(__queryId, cUnitTypeAll);
                    kbUnitQuerySetState(__queryId, cUnitStateAny);
                    kbUnitQuerySetIgnoreKnockedOutUnits(__queryId, false);
                    kbUnitQuerySetUnitType(__queryId, kbGetUnitTypeID("OsirisPieceBox"));
                    xsSetContextPlayer(owner);
                    kbUnitQueryExecute(__queryId);
                    int[] queryTempResults = kbUnitQueryGetResults(__queryId);
                    kbUnitQueryDestroy(__queryId);
                    if (queryTempResults.size() == OSIRIS_CARDS_NEEDED){
                        for(int i = 0;  i < queryTempResults.size(); i++){
                            selectSingle(queryTempResults[i]);
                            trUnitSetAnimationPath("Opening","spc\buildings\props\osiris_piece_box\anim\osiris_piece_box_opening",false,-1,true);
                            trSoundPlayFN("campaign\fott\cinematics\fott20_b\lostsouls.mp3", -1, "","");
                            trSetLighting("potg\potg02_end", 10);
                            trMusicStop();
                            trMusicPlay("music\battle\oi_that_pops!!!.wav", 5.0);
                            if (i == queryTempResults.size()-1){
                                BenchData bench = g_shop.m_benches[owner];
                                int shopId = bench.m_playerShopId;
                                vector location = trUnitGetPosition(shopId);
                                trUnitCreateForced("Osiris", location.x, location.y, location.z, xsRandFloat(0.0, 359), owner, false);
                                closeShop(owner);
                            }
                        }
                    }
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
    if (xsGetTimeMS() - cActivationTime >= 1800000) {
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