const int SOUND_NORMAL = 0;
const int SOUND_SET = 1;
const int SOUND_DIALOG = 2;

void playSound(string sound = "", int soundType = SOUND_NORMAL){
    switch(soundType){
        case SOUND_NORMAL: trSoundPlayPaused(sound);
        case SOUND_SET: trSoundsetPlay(sound);
        case SOUND_DIALOG: trSoundPlayDialogue(0, "", "", "", sound);
    }
}

void playSoundForPlayer(int p = 0, string sound = "", int soundType = SOUND_NORMAL){
    if(p == trCurrentPlayer()){
        playSound(sound, soundType);
    }
}

void playUnitSound(int unitId = -1, string sound = "", int soundType = SOUND_NORMAL){
    int selection = trSelectionGetUnitID(0);
    selectSingle(unitId);
        if(trUnitVisibleToPlayer()){
            playSound(sound, soundType);
        }
    selectSingle(selection);
}