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
    xsDisableSelf();
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
    }
}

rule FIRE_AFTER_1_SECOND_TRIGGER
highFrequency
active
{
   if ((((xsGetTime() - (cActivationTime / 1000)) >= 1) != false))
   {
        trSoundPlayFN("music\battle\rot_loaf.wav", -1, "","");
        for(int p = 1; p < cNumberPlayers; p++) {
            UiSystem system = uiSystemArray[p];
            system.setCameraPosition(vector(0.5 * kbGetMapXSize(), -10100.0, 0.5 * kbGetMapZSize()), 100.0, 45.0, 89.0, 45.0);
            system.enter(p != 1, true, 1000);
            if(trCurrentPlayer() == p){
                setUiVisible(false);
                trSetObscuredUnits(false);
            }
            system.addDisplay(0.0, 0.0, "please wait...", true);
            uiSystemArray[p] = system;
        }
        xsDisableSelf();
   }
}