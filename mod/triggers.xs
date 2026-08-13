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
    trExecuteOnAI(cNumberPlayers, "scenarioDisableAI()");
    trAISetAttackResponseDistance(cNumberPlayers, 36.0);
    trDisablePopCapNotifications(true);
    trDisableConquestCheck(true);
    trSetCommunityObjectivesVisibility(false);
    initialiseUiSystem(false);
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
    initPlayerData();
    initializeCardParametersMap();
    createStartingUnits();
    initPlayerCommands();
    xsDisableSelf();
}

rule FIRE_AFTER_1_SECOND_TRIGGER
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 1) != false))
   {
        for(int p = 1; p <= cNumberPlayers; p = p + 1){
            openShop(p);
        }
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