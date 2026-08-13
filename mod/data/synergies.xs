
class SynergyData {

    string m_icon = "";
    string m_rolloverName = "";
    string m_rolloverDescription = "";

};

SynergyData[] g_synergyIcons = default;

void renderSynergyIcon(ref UiSystem system, float posX = 0.0, ref float posY, float posYOffset = 0.0, float width = 0.0, float height = 0.0, 
                       int iconSize = 32, int synergyIndex = 0){
    SynergyData synergy = g_synergyIcons[synergyIndex];
    minimapSafeDisplay(system, posX - 0.001, posY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", iconSize));
    minimapSafeDisplayWithHover(system, posX, posY, width, height, getIconPathFormat(synergy.m_icon, iconSize), 
                                synergy.m_rolloverName,
                                synergy.m_rolloverDescription);
    posY = posY - posYOffset;
}

void initializeSynergies(){
    string[] icons = new string(8, "");
    icons[0] = "resources/in_game/gamepad_quick_select/Icon_MeleeUnit.png";
    icons[1] = "resources/in_game/gamepad_quick_select/Icon_RangedUnit.png";
    icons[2] = "resources/in_game/gamepad_quick_select/Icon_CavalryUnit.png";
    icons[3] = "resources/in_game/gamepad_quick_select/Icon_MythNavy.png";
    icons[4] = "resources/in_game/gamepad_quick_select/Icon_Heroes.png";
    icons[5] = "resources/in_game/Gamepad_Radial_Menu/icon_radial_add.png";
    icons[6] = "resources/in_game/gamepad_quick_select/Icon_SiegeUnit.png";
    icons[7] = "resources/in_game/gamepad_quick_select/Icon_Landmark.png";

    for (int i = 0; i < icons.size(); i++) {
        SynergyData synergy;
        synergy.m_icon = icons[i];
        synergy.m_rolloverName = "";
        synergy.m_rolloverDescription = "";
        log(3, synergy.m_icon);
        g_synergyIcons.add(synergy);
    }
}