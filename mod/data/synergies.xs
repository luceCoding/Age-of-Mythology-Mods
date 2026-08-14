class SynergyData {

    string m_icon = "";
    string m_rolloverName = "";
    string m_rolloverDescription = "";
    Buff[] m_buffs = default;
};

SynergyData[] g_synergies = default;

void renderSynergyIcon(ref UiSystem system, float posX = 0.0, ref float posY, float posYOffset = 0.0, float width = 0.0, float height = 0.0, 
                       int iconSize = 32, int synergyIndex = 0,
                       bool showBackground = true,
                       string content = ""
                       ){
    SynergyData synergy = g_synergies[synergyIndex];
    if (showBackground){
        minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", iconSize));
    }
    minimapSafeDisplayWithHover(system, posX, posY, width, height, getIconPathFormat(synergy.m_icon, iconSize) + content, 
                                synergy.m_rolloverName,
                                synergy.m_rolloverDescription);
    posY = posY - posYOffset;
}

void initializeSynergies(){
    string[] icons = new string(MAX_SYNERGIES, "");
    icons[SYNERGY_INDEX_INFANTRY] = "resources/in_game/gamepad_quick_select/Icon_MeleeUnit.png";
    icons[SYNERGY_INDEX_RANGED] = "resources/in_game/gamepad_quick_select/Icon_RangedUnit.png";
    icons[SYNERGY_INDEX_CAVALRY] = "resources/in_game/gamepad_quick_select/Icon_CavalryUnit.png";
    icons[SYNERGY_INDEX_MYTH] = "resources/in_game/gamepad_quick_select/Icon_MythNavy.png";
    icons[SYNERGY_INDEX_HERO] = "resources/in_game/gamepad_quick_select/Icon_Heroes.png";
    icons[SYNERGY_INDEX_HEALER] = "resources/in_game/Gamepad_Radial_Menu/icon_radial_add.png";
    icons[SYNERGY_INDEX_SIEGE] = "resources/in_game/gamepad_quick_select/Icon_SiegeUnit.png";
    icons[SYNERGY_INDEX_BUILDING] = "resources/in_game/gamepad_quick_select/Icon_Landmark.png";
    icons[SYNERGY_INDEX_SOLDIER] = "resources/in_game/gamepad_quick_select/Icon_Villager.png";

    string[] rolloverNames = new string(MAX_SYNERGIES, "");
    rolloverNames[SYNERGY_INDEX_INFANTRY] = "Synergy: Infantry";
    rolloverNames[SYNERGY_INDEX_RANGED] = "Synergy: Ranged";
    rolloverNames[SYNERGY_INDEX_CAVALRY] = "Synergy: Cavalry";
    rolloverNames[SYNERGY_INDEX_MYTH] = "Synergy: Myth Unit";
    rolloverNames[SYNERGY_INDEX_HERO] = "Synergy: Hero";
    rolloverNames[SYNERGY_INDEX_HEALER] = "Synergy: Healer";
    rolloverNames[SYNERGY_INDEX_SIEGE] = "Synergy: Siege";
    rolloverNames[SYNERGY_INDEX_BUILDING] = "Synergy: Building";
    rolloverNames[SYNERGY_INDEX_SOLDIER] = "Synergy: Soldier";

    for (int i = 0; i < icons.size(); i++) {
        SynergyData synergy;
        synergy.m_icon = icons[i];
        synergy.m_rolloverName = rolloverNames[i];
        synergy.m_rolloverDescription = "";
        synergy.m_buffs = new Buff(9);
        g_synergies.add(synergy);
    }

    int[] emptySynergyTyp = new int(0, -1);
    {
        int[] tmpSynergyType = new int(0, -1);
        tmpSynergyType.add(SYNERGY_INDEX_INFANTRY);
        SynergyData synergy = g_synergies[SYNERGY_INDEX_INFANTRY];
        synergy.m_buffs[2] = createBuffData(tmpSynergyType, puFIELD_HACK_ARMOR, 0.05, relativityABSOLUTE);
        synergy.m_buffs[3] = createBuffData(emptySynergyTyp, puFIELD_HACK_ARMOR, 0.05, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_HACK, 1, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyTyp, puFIELD_HACK_ARMOR, 1.1, relativityBasePERCENT);
        synergy.m_buffs[8] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_HACK, 2, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_INFANTRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_RANGED];
        synergy.m_buffs[2] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_PIERCE, 0.01, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_RANGE, 0.01, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_PIERCE, 0.02, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_RATE_OF_FIRE, 0.9, relativityBasePERCENT);
        g_synergies[SYNERGY_INDEX_RANGED] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_CAVALRY];
        synergy.m_buffs[2] = createBuffData(emptySynergyTyp, puFIELD_PIERCE_ARMOR, 0.05, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffData(emptySynergyTyp, puFIELD_SPEED, 0.05, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyTyp, puFIELD_PIERCE_ARMOR, 1.1, relativityBasePERCENT);
        synergy.m_buffs[8] = createBuffData(emptySynergyTyp, puFIELD_SPEED, 0.05, relativityBasePERCENT);
        g_synergies[SYNERGY_INDEX_CAVALRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_MYTH];
        synergy.m_buffs[4] = createBuffData(emptySynergyTyp, puFIELD_RECHARGE, 0.02, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffData(emptySynergyTyp, puFIELD_RECHARGE, 0.04, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_MYTH] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HEALER];
        synergy.m_buffs[2] = createBuffData(emptySynergyTyp, puFIELD_HITPOINTS, 20, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffData(emptySynergyTyp, puFIELD_HP_REGEN, 0.02, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyTyp, puFIELD_HITPOINTS, 1.1, relativityBasePERCENT);
        synergy.m_buffs[8] = createBuffData(emptySynergyTyp, puFIELD_HP_REGEN, 0.05, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_HEALER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SIEGE];
        synergy.m_buffs[2] = createBuffData(emptySynergyTyp, puFIELD_ACTION_CRUSH, 0.02, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffData(emptySynergyTyp, puFIELD_ACTION_DMG_AREA, 0.01, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyTyp, puFIELD_ACTION_CRUSH, 0.04, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffData(emptySynergyTyp, puFIELD_ACTION_DMG_AREA, 0.02, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_SIEGE] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_BUILDING];
        synergy.m_buffs[2] = createBuffData(emptySynergyTyp, puFIELD_CRUSH_ARMOR, 0.15, relativityABSOLUTE);
        synergy.m_buffs[5] = createBuffData(emptySynergyTyp,  puFIELD_GP_BLOCK, 0.25, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyTyp, puFIELD_CRUSH_ARMOR, 0.3, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffAction(emptySynergyTyp, puFIELD_ACTION_N_PROJECTILES, 1, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_BUILDING] = synergy;
    }
}