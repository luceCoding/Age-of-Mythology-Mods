include "../common/ui.xs";
include "config.xs";
include "data/player.xs"
include "common/ui.xs"

rule FIRST_TRIGGER
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
    xsDisableSelf();
}

rule SECOND_TRIGGER
highFrequency
active
{
    for(int p = 1; p <= cNumberPlayers; p = p + 1){
        trCreateRevealer(p, "default", vector(0, configMapBaseHeight, 0), 9999, false);
    }
    initPlayerData();
    UiSystem system = uiSystemArray[1];
    system.enter();
    if(trCurrentPlayer() == 1){
        setUiVisible(false);
    }
}