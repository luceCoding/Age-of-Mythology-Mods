int[] g_playerArchetypes = default;

class Archetype {
    int m_archetype = -1;
    string m_title = "";
    string m_icon = "";
    string m_rollover = "";

    void setArchetype(int archetype = -1){
        m_archetype = archetype;
        m_title = "";
        m_icon = "";
        m_rollover = "";

        switch(archetype){
            case ARCHETYPE_MISCHIEF: {
                m_title = GP_MIMIC_DISPLAY;
                m_icon = "resources\atlantean\static_color\abilities\promethean_ability_icon.png";
                m_rollover = GP_MIMIC_ROLLOVER;
                break;
            }
            case ARCHETYPE_DEFENSE: {
                m_title = GP_BRONZE_DISPLAY;
                m_icon = "resources\greek\static_color\god_powers\bronze_icon.png";
                m_rollover = GP_BRONZE_ROLLOVER;
                break;
            }
            case ARCHETYPE_HEALTH: {
                m_title = GP_RESTORATION_DISPLAY;
                m_icon = "resources\greek\static_color\god_powers\restoration_icon.png";
                m_rollover = GP_RESTORATION_ROLLOVER;
                break;
            }
            case ARCHETYPE_WAR: {
                m_title = GP_ENRAGE_DISPLAY;
                m_icon = "resources\greek\static_color\technologies\monstrous_rage_icon.png";
                m_rollover = GP_ENRAGE_ROLLOVER;
                break;
            }
            case ARCHETYPE_EVASION: {
                m_title = GP_EVASION_DISPLAY;
                m_icon = "resources\japanese\static_color\abilities\shinobi_ability_smoke_bomb_icon.png";
                m_rollover = GP_EVASION_ROLLOVER;
                break;
            }
        }
    }

    int getArchetype(){
        return m_archetype;
    }

    string getTitle(){
        return m_title;
    }

    string getIcon(){
        return toForwardSlash(m_icon);
    }

    string getRollover(){
        return m_rollover;
    }

    void setupAsMischiefArchetype(int p = -1){
        setArchetype(ARCHETYPE_MISCHIEF);
        trGodPowerRedefine(p, "Spy", m_icon, m_title, m_rollover);
        trGodPowerGrantAtSlot(p, "Spy", cMaxInt, 0, MIMIC_COOLDOWN, false, true);

        g_OnCreationListener.register(p, cUnitTypeSpyEye, true, [](int unitId = -1) -> void {
                int owner = kbUnitGetPlayerID(unitId);
                vector v = kbUnitGetTruePosition(unitId);
                int[] enemyPlayers = getPlayersInTeam((g_finalTeam[owner] == 1) ? 2 : 1);
                for (int i = 0; i < enemyPlayers.size(); i++){
                    int p2 = enemyPlayers[i];
                    int[] unitIds = getUnitsInArea(v, 0.5, p2, cUnitTypeMilitaryUnit, cUnitStateAlive);
                    if (unitIds.size() > 0) { 
                        int unitID = unitIds[0];
                        string protoName = kbProtoUnitGetName(kbUnitGetProtoUnitID(unitID));
                        selectSingle(unitID);
                        int cloneId = trUnitCreate(protoName, v.x, v.y, v.z, xsRandInt(0, 359), owner);
                        selectSingle(cloneId);
                        trUnitApplyEffectProtoUnit(cOnHitEffectAttach, cMaxFloat, owner, kbProtoUnitGetName(cUnitTypeVFXFoxCharm));
                        playUnitSound(cloneId, "ConvertFinished", SOUND_SET);
                        lowFreqSchedulerWithIntInt.add(1000, cloneId, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                            selectSingle(unitID);
                            trDamageUnitPercent(1);
                            return trUnitAlive();
                        });
                        break;
                    }
                }
                return;
            }
        );
    }

    void setupAsDefenseArchetype(int p = -1){
        setArchetype(ARCHETYPE_DEFENSE);
        trGodPowerRedefine(p, "SolarShield", m_icon, m_title, m_rollover);
        trGodPowerGrantAtSlot(p, "SolarShield", cMaxInt, 0, BRONZE_COOLDOWN, false, true);

        g_OnCreationListener.register(p, cUnitTypeVFXSolarShield, true, [](int unitId = -1) -> void {
                int owner = kbUnitGetPlayerID(unitId);
                vector v = kbUnitGetTruePosition(unitId);
                int[] allyPlayers = getPlayersInTeam(g_finalTeam[owner]);
                for (int i = 0; i < allyPlayers.size(); i++){
                    int p2 = allyPlayers[i];
                    applyToUnitsInArea(v, 0.5, p2, cUnitTypeMilitaryUnit, cUnitStateAlive,
                        [](int unitID = -1) -> void {
                            string protoName = kbProtoUnitGetName(kbUnitGetProtoUnitID(unitID));
                            selectSingle(unitID);
                            trUnitMutate(protoName, false);
                            trUnitAddModifier(cModifyTypeArmor, cXSDamageTypeHack, 1.35, BRONZE_MS_TIME / 1000);
                            trUnitAddModifier(cModifyTypeArmor, cXSDamageTypePierce, 1.35, BRONZE_MS_TIME / 1000);
                            trUnitAddModifier(cModifyTypeArmor, cXSDamageTypeCrush, 1.35, BRONZE_MS_TIME / 1000);
                            trUnitSetShading(cShaderBronze, 100.0);
                            playUnitSound(unitID, "BronzeBirth", SOUND_SET);
                            lowFreqSchedulerWithIntInt.add(BRONZE_MS_TIME, unitID, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                                selectSingle(unitID);
                                trUnitSetShading(cShaderBronze, 0);
                                return false;
                            });
                        }
                    );
                }
                return;
            }
        );
    }

    void setupAsHealthArchetype(int p = -1){
        setArchetype(ARCHETYPE_HEALTH);
        trGodPowerRedefine(p, "SolarShield", m_icon, m_title, m_rollover);
        trGodPowerGrantAtSlot(p, "SolarShield", cMaxInt, 0, HEALTH_COOLDOWN, false, true);

        g_OnCreationListener.register(p, cUnitTypeVFXSolarShield, true, [](int unitId = -1) -> void {
                int owner = kbUnitGetPlayerID(unitId);
                vector v = kbUnitGetTruePosition(unitId);
                int[] allyPlayers = getPlayersInTeam(g_finalTeam[owner]);
                for (int i = 0; i < allyPlayers.size(); i++){
                    int p2 = allyPlayers[i];
                    applyToUnitsInArea(v, 0.5, p2, cUnitTypeMilitaryUnit, cUnitStateAlive,
                        [](int unitID = -1) -> void {
                            string protoName = kbProtoUnitGetName(kbUnitGetProtoUnitID(unitID));
                            int owner = kbUnitGetPlayerID(unitID);
                            selectSingle(unitID);
                            trUnitMutate(protoName, false);
                            playUnitSound(unitID, "RestorationBirth", SOUND_SET);
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, 20.0, owner, kbProtoUnitGetName(cUnitTypeVFXHealing));
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, 20.0, owner, kbProtoUnitGetName(cUnitTypeVFXHeavenLight));
                            lowFreqSchedulerWithIntInt.add(1000, unitID, 0, [](int iteration = 0, int unitID = 0, int _ = 0) -> bool {
                                selectSingle(unitID);
                                trHealUnitPercent(1.0);
                                if (iteration >= 20){ return false; }
                                return trUnitAlive();
                            });
                        }
                    );
                }
                return;
            }
        );
    }

    void setupAsWarArchetype(int p = -1){
        setArchetype(ARCHETYPE_WAR);
        trGodPowerRedefine(p, "SolarShield", m_icon, m_title, m_rollover);
        trGodPowerGrantAtSlot(p, "SolarShield", cMaxInt, 0, ENRAGE_COOLDOWN, false, true);

        g_OnCreationListener.register(p, cUnitTypeVFXSolarShield, true, [](int unitId = -1) -> void {
                int owner = kbUnitGetPlayerID(unitId);
                vector v = kbUnitGetTruePosition(unitId);
                int[] allyPlayers = getPlayersInTeam(g_finalTeam[owner]);
                for (int i = 0; i < allyPlayers.size(); i++){
                    int p2 = allyPlayers[i];
                    applyToUnitsInArea(v, 0.5, p2, cUnitTypeMilitaryUnit, cUnitStateAlive,
                        [](int unitID = -1) -> void {
                            string protoName = kbProtoUnitGetName(kbUnitGetProtoUnitID(unitID));
                            int owner = kbUnitGetPlayerID(unitID);
                            selectSingle(unitID);
                            trUnitMutate(protoName, false);
                            playUnitSound(unitID, "GreatHuntBirth", SOUND_SET);
                            trUnitAddModifier(cModifyTypeSpeed, cXSDamageTypeNone, 1.2, RAGE_SEC_TIME);
                            trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeHack, 1.2, RAGE_SEC_TIME);
                            trUnitAddModifier(cModifyTypeDamage, cXSDamageTypePierce, 1.2, RAGE_SEC_TIME);
                            trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeCrush, 1.2, RAGE_SEC_TIME);
                            trUnitAddModifier(cModifyTypeDamage, cXSDamageTypeDivine, 1.2, RAGE_SEC_TIME);
                            trUnitAddModifier(cModifyTypeROF, cXSDamageTypeNone, 1.2, RAGE_SEC_TIME);
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, RAGE_SEC_TIME, owner, kbProtoUnitGetName(cUnitTypeVFXMictlansDescent));
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, RAGE_SEC_TIME, owner, kbProtoUnitGetName(cUnitTypeVFXArtifactGlowRed));
                        }
                    );
                }
                return;
            }
        );
    }

    void setupAsEvasionArchetype(int p = -1){
        setArchetype(ARCHETYPE_EVASION);
        trGodPowerRedefine(p, "SolarShield", m_icon, m_title, m_rollover);
        trGodPowerGrantAtSlot(p, "SolarShield", cMaxInt, 0, EVASION_COOLDOWN, false, true);

        g_OnCreationListener.register(p, cUnitTypeVFXSolarShield, true, [](int unitId = -1) -> void {
                int owner = kbUnitGetPlayerID(unitId);
                vector v = kbUnitGetTruePosition(unitId);
                int[] allyPlayers = getPlayersInTeam(g_finalTeam[owner]);
                for (int i = 0; i < allyPlayers.size(); i++){
                    int p2 = allyPlayers[i];
                    applyToUnitsInArea(v, 0.5, p2, cUnitTypeMilitaryUnit, cUnitStateAlive,
                        [](int unitID = -1) -> void {
                            string protoName = kbProtoUnitGetName(kbUnitGetProtoUnitID(unitID));
                            int owner = kbUnitGetPlayerID(unitID);
                            selectSingle(unitID);
                            trUnitMutate(protoName, false);
                            playUnitSound(unitID, "GoshinbokuBirth", SOUND_SET);
                            trUnitAddModifier(cModifyTypeDodgeChance, -1, EVASION_DODGE_CHANCE, EVASION_SEC_TIME);
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, EVASION_SEC_TIME, owner, kbProtoUnitGetName(cUnitTypeVFXRampage));
                            trUnitApplyEffectProtoUnit(cOnHitEffectAttach, EVASION_SEC_TIME, owner, kbProtoUnitGetName(cUnitTypeVFXStealthEye));
                        }
                    );
                }
                return;
            }
        );
    }

    void setup(int p = -1){
        if (m_archetype < ARCHETYPE_MISCHIEF || m_archetype > ARCHETYPE_EVASION){ return; }
        g_playerArchetypes[p] = m_archetype;
        switch(m_archetype){
            case ARCHETYPE_MISCHIEF: { setupAsMischiefArchetype(p); break; }
            case ARCHETYPE_DEFENSE: { setupAsDefenseArchetype(p); break; }
            case ARCHETYPE_HEALTH: { setupAsHealthArchetype(p); break; }
            case ARCHETYPE_WAR: { setupAsWarArchetype(p); break; }
            case ARCHETYPE_EVASION: { setupAsEvasionArchetype(p); break; }
        }
    }
};