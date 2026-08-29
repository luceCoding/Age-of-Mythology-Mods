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
        synergy.m_buffs = new Buff(13);
        g_synergies.add(synergy);
    }

    int[] emptySynergyType = new int(0, -1);
    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_INFANTRY];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_CAVALRY);
        synergy.m_buffs[2] = createBuffData(emptySynergyType, puFIELD_HACK_ARMOR, 0.05, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, puFIELD_ACTION_HACK, 2, relativityABSOLUTE);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 25, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, puFIELD_HACK_ARMOR, 1.1, relativityBasePERCENT);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, puFIELD_ACTION_HACK, 4, relativityABSOLUTE);
        synergy.m_buffs[10] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 50, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_INFANTRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_RANGED];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_INFANTRY);
        synergy.m_buffs[2] = createBuffAction(emptySynergyType, puFIELD_ACTION_PIERCE, 2, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, puFIELD_ACTION_RANGE, 1, relativityABSOLUTE);
        synergy.m_buffs[5] = createBuffAction(emptySynergyType, puFIELD_ACTION_RATE_OF_FIRE, 0.9, relativityBasePERCENT);
        synergy.m_buffs[6] = createBuffAction(emptySynergyType, puFIELD_ACTION_PIERCE, 4, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, puFIELD_ACTION_RANGE, 1, relativityABSOLUTE);
        synergy.m_buffs[10] = createBuffAction(emptySynergyType, puFIELD_ACTION_RATE_OF_FIRE, 0.85, relativityBasePERCENT);
        g_synergies[SYNERGY_INDEX_RANGED] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_CAVALRY];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_ARCHER);
        synergy.m_buffs[2] = createBuffData(emptySynergyType, puFIELD_PIERCE_ARMOR, 0.05, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffData(emptySynergyType, puFIELD_SPEED, 1.05, relativityBasePERCENT);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, puFIELD_HITPOINTS, 1.1, relativityBasePERCENT);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, puFIELD_PIERCE_ARMOR, 1.1, relativityBasePERCENT);
        synergy.m_buffs[8] = createBuffData(emptySynergyType, puFIELD_SPEED, 1.1, relativityBasePERCENT);
        synergy.m_buffs[10] = createBuffData(emptySynergyType, puFIELD_HITPOINTS, 1.15, relativityBasePERCENT);
        g_synergies[SYNERGY_INDEX_CAVALRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HEALER];
        synergy.m_buffs[2] = createBuffData(emptySynergyType, puFIELD_HP_REGEN, 0.1, relativityABSOLUTE);
        synergy.m_buffs[3] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 0.1, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffData(emptySynergyType, puFIELD_HP_REGEN, 0.2, relativityABSOLUTE);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 0.2, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, puFIELD_HP_REGEN, 0.3, relativityABSOLUTE);
        synergy.m_buffs[7] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 0.3, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffData(emptySynergyType, puFIELD_HP_REGEN, 0.5, relativityABSOLUTE);
        synergy.m_buffs[9] = createBuffData(emptySynergyType, puFIELD_SHIELDS, 0.5, relativityABSOLUTE);
        // 10% Lifesteal
        g_synergies[SYNERGY_INDEX_HEALER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SIEGE];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_BUILDING);
        synergy.m_buffs[2] = createBuffAction(emptySynergyType, puFIELD_ACTION_CRUSH, 5, relativityABSOLUTE);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, puFIELD_ACTION_DMG_AREA, 1, relativityABSOLUTE);
        synergy.m_buffs[5] = createBuffAction(emptySynergyType, puFIELD_ACTION_N_PROJECTILES, 1, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffAction(emptySynergyType, puFIELD_ACTION_CRUSH, 10, relativityABSOLUTE);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, puFIELD_ACTION_DMG_AREA, 1, relativityABSOLUTE);
        synergy.m_buffs[10] = createBuffAction(emptySynergyType, puFIELD_ACTION_N_PROJECTILES, 1, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_SIEGE] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SOLDIER];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_HERO);
        synergy.m_buffs[3] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.1, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.25, relativityABSOLUTE);
        synergy.m_buffs[9] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.5, relativityABSOLUTE);
        synergy.m_buffs[12] = createBuffData(emptySynergyType, puFIELD_ACTION_ALL_DMG, 5, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_SOLDIER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_MYTH];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_INFANTRY);
        tempUnitTypes.add(UNIT_TYPE_ARCHER);
        tempUnitTypes.add(UNIT_TYPE_CAVALRY);
        synergy.m_buffs[3] = createBuffData(emptySynergyType, puFIELD_RECHARGE, 1, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, puFIELD_RECHARGE, 2, relativityABSOLUTE);
        synergy.m_buffs[9] = createBuffData(emptySynergyType, puFIELD_RECHARGE, 3, relativityABSOLUTE);
        synergy.m_buffs[12] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.25, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_MYTH] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HERO];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_MYTH);
        synergy.m_buffs[3] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.1, relativityABSOLUTE);
        synergy.m_buffs[6] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.25, relativityABSOLUTE);
        synergy.m_buffs[9] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, puFIELD_ACTION_UNITTYPE_DMG_BONUS, 0.5, relativityABSOLUTE);
        synergy.m_buffs[12] = createBuffAction(emptySynergyType, puFIELD_ACTION_DIVINE, 5, relativityABSOLUTE);
        g_synergies[SYNERGY_INDEX_HERO] = synergy;
    }
}