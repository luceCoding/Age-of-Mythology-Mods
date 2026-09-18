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
    createHealingSprings();
    initPlayerCommands();
    trHideScoreboard();

    paintAllLanesCircular();
    generateAllCamps();

    postModifyPlayerData();
    postApplyBalancePatch();

    __worldSmooth(0, 0, __getMapSizeTilesX(), __getMapSizeTilesZ(), false, 2);
    updateTerrainObstructions();

    trPlayerSetName(getTeamsAIPlayer(1), "Team 1");
    trPlayerSetName(getTeamsAIPlayer(2), "Team 2");
    trChatSend(cNumberPlayers, "Welcome to Deck of the Ages!");
    trChatSend(cNumberPlayers, "This mod is currently a pre-alpha build and is under development. Everything is subject to change.");
    trChatSend(cNumberPlayers, "Created by ItzJover.");

    for (int p=1; p <= cNumberPlayers-2; p++){
        BenchData bench = g_shop.m_benches[trCurrentPlayer()];
        int shopId = bench.m_playerShopId;
        vector v = kbUnitGetTruePosition(shopId);
        if (trCurrentPlayer() == p){
            cameraLookAt(v, 60.0, 45.0, 45.0);
            selectSingle(shopId);
            trUnitGameSelect();
            trUnitHighlight(30.0, true);
        }
    }

    startBoss();
    startShopTimers();
    startCapturePoints();
    startIncome();
    startTeamResignedCheck();
    startRespawn();
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
    g_OnCreationListener.init();
    g_AttachmentManager.init();
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

rule LOOP
highFrequency
active
{
    g_OnCreationListener.process();
    g_AttachmentManager.process();
}

rule SUDDEN_DEATH
highFrequency
active
{
    if (xsGetTimeMS() - cActivationTime >= SUDDEN_DEATH_MS) {
        lowFreqScheduler.add(ADD_OSIRIS_CARD_INTERVAL_MS, [](int iterations = 1) -> bool {
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
    if(kbPlayerGetName(g_devIndex) == "ItzJover" && trChatHistoryContains("devmode", g_devIndex)){
        for (int p = 1; p <= cNumberPlayers; p++){
            trCreateRevealer(p, "default", vector(0, configMapBaseHeight, 0), 9999, false);
            trPlayerGrantResources(p, "Gold", 99999);
            trGodPowerGrant(p, "MeteorSPC", 99, 0, false, false);
            trModifyProtounitAction("MeteorSPC", "HandAttack", p, cXSActionEffectDamageDivine, 99999, cXSRelativityAssign);
            trGodPowerGrant(p, "Bolt", 99, 0, false, false);
            trGodPowerGrant(p, "Earthquake", 99, 0, false, false);
        }
        xsDisableSelf();
    }
    if (kbPlayerGetName(g_devIndex) != "ItzJover"){
        xsDisableSelf();
    }
    if ((((xsGetTime() - (cActivationTime / 1000)) >= 120) != false))
    {
            xsDisableSelf();
    }
}

rule DEV_SETUP
runImmediately
highFrequency
active
{
    for(int p = 1; p <= cNumberPlayers; p++){
        if (kbPlayerGetName(p) == "ItzJover"){
            g_devIndex = p;
            break;
        }
    }
    xsDisableSelf();
}