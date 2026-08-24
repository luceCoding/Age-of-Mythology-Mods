class SynergyData {

    string m_icon = "";
    string m_rolloverName = "";
    string m_rolloverDescription = "";
    Buff[] m_buffs = default;

    string getDescription(){
        string description = "";
        bool firstBuff = true;

        for (int i = 0; i < m_buffs.size(); i++){
            Buff buff = m_buffs[i];
            if (buff.isEmpty() == false) {
                if (firstBuff == false) {
                    description = description + "\n";
                }
                description = description + i + ": " + buff.getDescription();
                firstBuff = false;
            }
        }
        return description;
    }
};

SynergyData[] g_synergies = default;

void renderSynergyIcon(int p = 0, float posX = 0.0, ref float posY, float posYOffset = 0.0, float width = 0.0, float height = 0.0, 
                       int iconSize = 32, int synergyIndex = 0,
                       bool showBackground = true,
                       string content = "", int uiElementTopOf = -1
                       ){
    SynergyData synergy = g_synergies[synergyIndex];
    int uiBackgroundElement = uiElementTopOf;
    if (showBackground){
        uiBackgroundElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", iconSize), uiBackgroundElement);
    }
    minimapSafeDisplayWithHover(p, posX, posY, width, height, getIconPathFormat(synergy.m_icon, iconSize) + content, 
                                synergy.m_rolloverName,
                                synergy.getDescription(), uiBackgroundElement);
    posY = posY - posYOffset;
}