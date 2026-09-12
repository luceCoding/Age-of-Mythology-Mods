void initializeSynergies(){
    string[] icons = new string(MAX_SYNERGIES, "");
    icons[SYNERGY_INDEX_INFANTRY] = "resources/in_game/gamepad_quick_select/Icon_MeleeUnit.png";
    icons[SYNERGY_INDEX_RANGED] = "resources/in_game/gamepad_quick_select/Icon_RangedUnit.png";
    icons[SYNERGY_INDEX_CAVALRY] = "resources/in_game/gamepad_quick_select/Icon_CavalryUnit.png";
    icons[SYNERGY_INDEX_MYTH] = "resources/in_game/gamepad_quick_select/Icon_MythNavy.png";
    icons[SYNERGY_INDEX_HERO] = "resources/in_game/gamepad_quick_select/Icon_Heroes.png";
    icons[SYNERGY_INDEX_HEALER] = "resources/in_game/Gamepad_Radial_Menu/icon_radial_add.png";
    icons[SYNERGY_INDEX_SIEGE] = "resources/in_game/gamepad_quick_select/Icon_SiegeUnit.png";
    icons[SYNERGY_INDEX_SOLDIER] = "resources/in_game/gamepad_quick_select/Icon_Villager.png";
    icons[SYNERGY_INDEX_FROST] = "resources/norse/static_color/god_powers/frost_icon.png";
    icons[SYNERGY_INDEX_UNDEAD] = "resources/egyptian/static_color/god_powers/ancestors_icon.png";
    icons[SYNERGY_INDEX_POISON] = "resources/aztec/static_color/technologies/sting_of_yappan_icon.png";
    icons[SYNERGY_INDEX_FIRE] = "resources/achievements/achievement_set_the_world_on_fire.png";

    string[] rolloverNames = new string(MAX_SYNERGIES, "");
    rolloverNames[SYNERGY_INDEX_INFANTRY] = "Synergy: Infantry";
    rolloverNames[SYNERGY_INDEX_RANGED] = "Synergy: Ranged";
    rolloverNames[SYNERGY_INDEX_CAVALRY] = "Synergy: Cavalry";
    rolloverNames[SYNERGY_INDEX_MYTH] = "Synergy: Myth Unit";
    rolloverNames[SYNERGY_INDEX_HERO] = "Synergy: Hero";
    rolloverNames[SYNERGY_INDEX_HEALER] = "Synergy: Healer";
    rolloverNames[SYNERGY_INDEX_SIEGE] = "Synergy: Siege";
    rolloverNames[SYNERGY_INDEX_SOLDIER] = "Synergy: Soldier";
    rolloverNames[SYNERGY_INDEX_FROST] = "Synergy: Frost";
    rolloverNames[SYNERGY_INDEX_UNDEAD] = "Synergy: Undead";
    rolloverNames[SYNERGY_INDEX_POISON] = "Synergy: Poisonous";
    rolloverNames[SYNERGY_INDEX_FIRE] = "Synergy: Fire";

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
        synergy.m_buffs[2] = createBuffData(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSProtoEffectArmorHack, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSActionEffectDamageHack, 2, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffData(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSProtoEffectMaxShieldPoints, 25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSProtoEffectArmorHack, 0.15, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffAction(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSActionEffectDamageHack, 4, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffData(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSProtoEffectMaxShieldPoints, 50, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffAction(SYNERGY_INDEX_INFANTRY, emptySynergyType, cXSActionEffectDamageHack, 8, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_INFANTRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_RANGED];
        synergy.m_buffs[2] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectDamagePierce, 2, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectRange, 1, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectROF, 0.9, cXSRelativityBasePercent);
        synergy.m_buffs[6] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectDamagePierce, 4, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectRange, 1, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectROF, 0.85, cXSRelativityBasePercent);
        synergy.m_buffs[12] = createBuffAction(SYNERGY_INDEX_RANGED, emptySynergyType, cXSActionEffectDamagePierce, 8, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_RANGED] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_CAVALRY];
        synergy.m_buffs[2] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectArmorPierce, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectSpeed, 1.1, cXSRelativityBasePercent);
        synergy.m_buffs[5] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectHitpoints, 50, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectArmorPierce, 0.15, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectSpeed, 1.15, cXSRelativityBasePercent);
        synergy.m_buffs[10] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectHitpoints, 100, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffData(SYNERGY_INDEX_CAVALRY, emptySynergyType, cXSProtoEffectSpeed, 1.20, cXSRelativityBasePercent);
        g_synergies[SYNERGY_INDEX_CAVALRY] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HEALER];
        synergy.m_buffs[2] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectUnitRegenRate, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[3] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.1, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectUnitRegenRate, 0.2, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.2, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectUnitRegenRate, 0.3, cXSRelativityAbsolute);
        synergy.m_buffs[7] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.3, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectUnitRegenRate, 0.5, cXSRelativityAbsolute);
        synergy.m_buffs[9] = createBuffData(SYNERGY_INDEX_HEALER, emptySynergyType, cXSProtoEffectMaxShieldPoints, 0.5, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_HEALER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SIEGE];
        synergy.m_buffs[2] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectDamageCrush, 5, cXSRelativityAbsolute);
        synergy.m_buffs[4] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectDamageArea, 1, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectDamagePierce, 4, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectDamageCrush, 10, cXSRelativityAbsolute);
        synergy.m_buffs[8] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectDamageArea, 1, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffAction(SYNERGY_INDEX_SIEGE, emptySynergyType, cXSActionEffectNumProjectiles, 1, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_SIEGE] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_SOLDIER];
        synergy.m_buffs[5] = createBuffDataSingle(SYNERGY_INDEX_SOLDIER, UNIT_TYPE_SOLDIER, cXSProtoEffectHitpoints, 25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffSpecialAction(SYNERGY_INDEX_SOLDIER, emptySynergyType, cOnHitEffectLifesteal, -1, 1.0, 0.1);
        synergy.m_buffs[10] = createBuffDataSingle(SYNERGY_INDEX_SOLDIER, UNIT_TYPE_SOLDIER, cXSProtoEffectHitpoints, 50, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffSpecialAction(SYNERGY_INDEX_SOLDIER, emptySynergyType, cOnHitEffectLifesteal, -1, 1.0, 0.25);
        synergy.m_buffs[15] = createBuffDataSingle(SYNERGY_INDEX_SOLDIER, UNIT_TYPE_SOLDIER, cXSProtoEffectHitpoints, 75, cXSRelativityAbsolute);
        synergy.m_buffs[18] = createBuffSpecialAction(SYNERGY_INDEX_SOLDIER, emptySynergyType, cOnHitEffectLifesteal, -1, 1.0, 0.5);
        synergy.m_buffs[20] = createBuffDataSingle(SYNERGY_INDEX_SOLDIER, UNIT_TYPE_SOLDIER, cXSProtoEffectHitpoints, 100, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_SOLDIER] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_MYTH];
        synergy.m_buffs[5] = createBuffDataSingle(SYNERGY_INDEX_MYTH, UNIT_TYPE_MYTH, cXSProtoEffectHitpoints, 25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffData(SYNERGY_INDEX_MYTH, emptySynergyType, cXSProtoEffectRechargeTime, 2, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffDataSingle(SYNERGY_INDEX_MYTH, UNIT_TYPE_MYTH, cXSProtoEffectHitpoints, 50, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffData(SYNERGY_INDEX_MYTH, emptySynergyType, cXSProtoEffectRechargeTime, 3, cXSRelativityAbsolute);
        synergy.m_buffs[15] = createBuffDataSingle(SYNERGY_INDEX_MYTH, UNIT_TYPE_MYTH, cXSProtoEffectHitpoints, 75, cXSRelativityAbsolute);
        synergy.m_buffs[18] = createBuffData(SYNERGY_INDEX_MYTH, emptySynergyType, cXSProtoEffectRechargeTime, 4, cXSRelativityAbsolute);
        synergy.m_buffs[20] = createBuffDataSingle(SYNERGY_INDEX_MYTH, UNIT_TYPE_MYTH, cXSProtoEffectHitpoints, 100, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_MYTH] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_HERO];
        synergy.m_buffs[5] = createBuffDataSingle(SYNERGY_INDEX_HERO, UNIT_TYPE_HERO, cXSProtoEffectHitpoints, 25, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffAction(SYNERGY_INDEX_HERO, emptySynergyType, cXSActionEffectDamageDivine, 2, cXSRelativityAbsolute);
        synergy.m_buffs[10] = createBuffDataSingle(SYNERGY_INDEX_HERO, UNIT_TYPE_HERO, cXSProtoEffectHitpoints, 50, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffAction(SYNERGY_INDEX_HERO, emptySynergyType, cXSActionEffectDamageDivine, 3, cXSRelativityAbsolute);
        synergy.m_buffs[15] = createBuffDataSingle(SYNERGY_INDEX_HERO, UNIT_TYPE_HERO, cXSProtoEffectHitpoints, 75, cXSRelativityAbsolute);
        synergy.m_buffs[18] = createBuffAction(SYNERGY_INDEX_HERO, emptySynergyType, cXSActionEffectDamageDivine, 4, cXSRelativityAbsolute);
        synergy.m_buffs[20] = createBuffDataSingle(SYNERGY_INDEX_HERO, UNIT_TYPE_HERO, cXSProtoEffectHitpoints, 100, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_HERO] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_FROST];
        synergy.m_buffs[6] = createBuffSpecialAction(SYNERGY_INDEX_FROST, emptySynergyType, cOnHitEffectProgFreezeSpeed, xsFloatToInt(1 * 1000.0), 1.0, 0.1, "VFXCold");
        synergy.m_buffs[12] = createBuffSpecialAction(SYNERGY_INDEX_FROST, emptySynergyType, cOnHitEffectProgFreezeSpeed, xsFloatToInt(2 * 1000.0), 1.0, 0.1, "VFXCold");
        synergy.m_buffs[18] = createBuffSpecialAction(SYNERGY_INDEX_FROST, emptySynergyType, cOnHitEffectProgFreezeSpeed, xsFloatToInt(3 * 1000.0), 1.0, 0.1, "VFXCold");
        g_synergies[SYNERGY_INDEX_FROST] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_UNDEAD];
        synergy.m_buffs[2] = createBuffSpawnAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeMinion, cSpawnEventTypeDead, 1.0, cXSRelativityAbsolute);
        synergy.m_buffs[3] = createBuffSpecialAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cOnHitEffectReincarnation, -1, 0, 1.0, "Minion");
        synergy.m_buffs[4] = createBuffSpawnAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeMinion, cSpawnEventTypeDead, 2.0, cXSRelativityAbsolute);
        synergy.m_buffs[5] = createBuffSpecialAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cOnHitEffectReincarnation, -1, 0, 2.0, "Minion");
        synergy.m_buffs[6] = createBuffSpawnAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeTlacanexquimilliSPC, cSpawnEventTypeDead, 1.0, cXSRelativityAbsolute);
        synergy.m_buffs[7] = createBuffSpecialAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cOnHitEffectReincarnation, -1, 0, 1.0, "TlacanexquimilliSPC");
        synergy.m_buffs[8] = createBuffSpawnAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeTartarianSpawn, cSpawnEventTypeDead, 1.0, cXSRelativityAbsolute);
        synergy.m_buffs[9] = createBuffSpecialAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeTartarianSpawn, -1, 0, 1.0, "TartarianSpawn");
        synergy.m_buffs[10] = createBuffSpawnAction(SYNERGY_INDEX_UNDEAD, emptySynergyType, cUnitTypeTartarianSpawn, cSpawnEventTypeDead, 1.0, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_UNDEAD] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_POISON];
        synergy.m_buffs[3] = createBuffSpecialAction(SYNERGY_INDEX_POISON, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypeHack, 10.0, 0.5, "VFXPoison");
        synergy.m_buffs[5] = createBuffSpawnActionSingle(SYNERGY_INDEX_POISON, UNIT_TYPE_UNIT, cUnitTypeArgusAcidBlobDamage, cSpawnEventTypeDead, 1.0, cXSRelativityAbsolute);
        synergy.m_buffs[6] = createBuffSpecialAction(SYNERGY_INDEX_POISON, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypeHack, 10.0, 1, "VFXPoison");
        synergy.m_buffs[9] = createBuffSpecialAction(SYNERGY_INDEX_POISON, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypeHack, 10.0, 2, "VFXPoison");
        synergy.m_buffs[10] = createBuffActionSingle(SYNERGY_INDEX_POISON, "ArgusAcidBlobDamage", cXSActionEffectDamageHack, 50, cXSRelativityAbsolute);
        synergy.m_buffs[12] = createBuffSpecialAction(SYNERGY_INDEX_POISON, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypeHack, 10.0, 4, "VFXPoison");
        g_synergies[SYNERGY_INDEX_POISON] = synergy;
    }

    {
        SynergyData synergy = g_synergies[SYNERGY_INDEX_FIRE];
        synergy.m_buffs[2] = createBuffSpecialAction(SYNERGY_INDEX_FIRE, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypePierce, 5.0, 0.75, "VFXScorchingFeathers");
        synergy.m_buffs[4] = createBuffSpawnActionSingle(SYNERGY_INDEX_FIRE, "VFXScorchingFeathers", cUnitTypeVFXArrowSignal, cSpawnEventTypeBirth, 1.0, cXSRelativityAbsolute, 0.05);
        synergy.m_buffs[6] = createBuffSpecialAction(SYNERGY_INDEX_FIRE, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypePierce, 5.0, 1.5, "VFXScorchingFeathers");
        synergy.m_buffs[8] = createBuffSpawnActionSingle(SYNERGY_INDEX_FIRE, "SkylanternFireAreaGround", cUnitTypeVFXFireAshesCS, cSpawnEventTypeBirth, 1.0, cXSRelativityAbsolute, 1.0);
        synergy.m_buffs[10] = createBuffSpecialAction(SYNERGY_INDEX_FIRE, emptySynergyType, cOnHitEffectDamageOverTime, cXSDamageTypePierce, 5.0, 3.5, "VFXBlazingPrairieUnitFire");
        synergy.m_buffs[12] = createBuffActionSingle(SYNERGY_INDEX_POISON, "MeteorSPC", cXSActionEffectDamagePierce, 100, cXSRelativityAbsolute);
        g_synergies[SYNERGY_INDEX_FIRE] = synergy;
    }
}