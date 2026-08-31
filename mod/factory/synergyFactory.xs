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
        synergy.m_buffs = new Buff(MAX_CARDS_IN_BENCH);
        g_synergies.add(synergy);
    }

    int[] emptySynergyType = new int(0, -1);
    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_INFANTRY];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_CAVALRY);
        synergy.m_buffs[2] = createBuffData(emptySynergyType, cXSProtoEffectArmorHack, 0.05, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, cXSActionEffectDamageHack, 2, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, cXSProtoEffectArmorHack, 1.1, cXSRelativityBasePercent);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, cXSActionEffectDamageHack, 4, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 50, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_INFANTRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_RANGED];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_INFANTRY);
        synergy.m_buffs[2] = createBuffAction(emptySynergyType, cXSActionEffectDamagePierce, 2, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, cXSActionEffectRange, 1, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffAction(emptySynergyType, cXSActionEffectROF, 0.9, cXSRelativityBasePercent);
        synergy.m_buffs[6] = createBuffAction(emptySynergyType, cXSActionEffectDamagePierce, 4, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, cXSActionEffectRange, 1, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffAction(emptySynergyType, cXSActionEffectROF, 0.85, cXSRelativityBasePercent);
        g_synergies[SYNERGY_INDEX_RANGED] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_CAVALRY];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_ARCHER);
        synergy.m_buffs[2] = createBuffData(emptySynergyType, cXSProtoEffectArmorPierce, 0.05, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffData(emptySynergyType, cXSProtoEffectSpeed, 1.05, cXSRelativityBasePercent);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, cXSProtoEffectHitpoints, 1.1, cXSRelativityBasePercent);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, cXSProtoEffectArmorPierce, 1.1, cXSRelativityBasePercent);
        synergy.m_buffs[8] = createBuffData(emptySynergyType, cXSProtoEffectSpeed, 1.1, cXSRelativityBasePercent);
        synergy.m_buffs[10] = createBuffData(emptySynergyType, cXSProtoEffectHitpoints, 1.2, cXSRelativityBasePercent);
        g_synergies[SYNERGY_INDEX_CAVALRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HEALER];
        synergy.m_buffs[2] = createBuffData(emptySynergyType, cXSProtoEffectUnitRegenRate, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[3] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffData(emptySynergyType, cXSProtoEffectUnitRegenRate, 0.2, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.2, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, cXSProtoEffectUnitRegenRate, 0.3, cXSRelativityAbsolute);
        synergy.m_buffs[7] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.3, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffData(emptySynergyType, cXSProtoEffectUnitRegenRate, 0.5, cXSRelativityAbsolute);
        synergy.m_buffs[9] = createBuffData(emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.5, cXSRelativityAbsolute);
        // 10% Lifesteal
        g_synergies[SYNERGY_INDEX_HEALER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SIEGE];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_BUILDING);
        synergy.m_buffs[2] = createBuffAction(emptySynergyType, cXSActionEffectDamageCrush, 5, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(emptySynergyType, cXSActionEffectDamageArea, 1, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffAction(emptySynergyType, cXSActionEffectNumProjectiles, 1, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffAction(emptySynergyType, cXSActionEffectDamageCrush, 10, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffAction(emptySynergyType, cXSActionEffectDamageArea, 1, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffAction(emptySynergyType, cXSActionEffectNumProjectiles, 1, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_SIEGE] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SOLDIER];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_HERO);
        synergy.m_buffs[3] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffSpecialAction(emptySynergyType, cOnHitEffectLifesteal, 1.0, 0.25);
        synergy.m_buffs[9] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.5, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffSpecialAction(emptySynergyType, cOnHitEffectLifesteal, 1.0, 0.5);
        synergy.m_buffs[15] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.75, cXSRelativityAbsolute);
        synergy.m_buffs[18] = createBuffSpecialAction(emptySynergyType, cOnHitEffectLifesteal, 1.0, 0.75);
        g_synergies[SYNERGY_INDEX_SOLDIER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_MYTH];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_INFANTRY);
        tempUnitTypes.add(UNIT_TYPE_ARCHER);
        tempUnitTypes.add(UNIT_TYPE_CAVALRY);
        synergy.m_buffs[3] = createBuffData(emptySynergyType, cXSProtoEffectRechargeTime, 1, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(emptySynergyType, cXSProtoEffectRechargeTime, 2, cXSRelativityAbsolute);
        synergy.m_buffs[9] = createBuffData(emptySynergyType, cXSProtoEffectRechargeTime, 3, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAbsolute);
        synergy.m_buffs[15] = createBuffData(emptySynergyType, cXSProtoEffectRechargeTime, 4, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_MYTH] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HERO];
        string[] tempUnitTypes = new string(0, "");
        tempUnitTypes.add(UNIT_TYPE_MYTH);
        synergy.m_buffs[3] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffAction(emptySynergyType, cXSActionEffectDamageDivine, 2, cXSRelativityAbsolute);
        synergy.m_buffs[9] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.25, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffAction(emptySynergyType, cXSActionEffectDamageDivine, 3, cXSRelativityAbsolute);
        synergy.m_buffs[15] = createBuffActionUnitType(emptySynergyType, tempUnitTypes, cXSActionProtoEffectDamageBonus, 0.5, cXSRelativityAbsolute);
        synergy.m_buffs[18] = createBuffAction(emptySynergyType, cXSActionEffectDamageDivine, 4, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_HERO] = synergy;
    }
}