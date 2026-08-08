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
    g_shop.init();
    xsDisableSelf();
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
    xsDisableSelf();
}

rule FIRE_AFTER_1_SECOND_TRIGGER
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 1) != false))
   {
        openShop(1);
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