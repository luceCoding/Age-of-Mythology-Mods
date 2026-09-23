int COMMAND_TYPE = cUnitTypeLegendHero;
string COMMAND_TYPE_NAME = "LegendHero";

string preparePlant(int p = 1, int plantType = -1, 
                    string name = "", string description = "", string icon = "", 
                    void(int) event = [](int unitId = -1) -> void {}) {

    string plantName = kbProtoUnitGetName(plantType);

    // Register event handler directly with the event manager
    g_OnCreationListener.register(p, plantType, true, event);

    // Configure Protounit
    trProtoUnitSetFlag(p, plantName, "OnlyInEditor", true);
    trProtoUnitSetFlag(p, plantName, "ShowOnMinimap", false);
    trProtoUnitSetFlag(p, plantName, "StartOnNoUpdate", true);
    trProtoUnitSetFlag(p, plantName, "PlaceAnywhere", true);
    trProtoUnitSetFlag(p, plantName, "Immoveable", false);
    trProtoUnitSetFlag(p, plantName, "ForceToNature", false);
    trProtoUnitSetFlag(p, plantName, "DoNotQueue", true);
    trProtoUnitSetFlag(p, plantName, "AllowOverPopCap", true);
    trProtoUnitSetFlag(p, plantName, "AlwaysAllowOverPopCap", true);
    trProtoUnitSetFlag(p, plantName, "Invulnerable", true);
    trUnforbidProtounit(p, plantName);
    trModifyProtounitData(plantName, p, cXSProtoEffectTrainPoints, 0.01, cXSRelativityAssign);
    trProtoUnitSetUnitType(p, plantName, COMMAND_TYPE_NAME, true);
    trProtoUnitChangeName(plantName, p, name, description, description);
    trProtoUnitSetIcon(plantName, p, icon);

    return plantName;
}

void addRecallCommand(int p = 0, string protoUnit = "") {
    string plantName = preparePlant(p, cUnitTypePlantEgyptianBush, 
                                    "Recall (B)",
                                    "Teleport back to your card shop.",
                                    "resources\\atlantean\\static_color\\god_powers\\vortex_icon.png",
                                    [](int unitId = -1) -> void {
                                        int pPlayer = kbUnitGetPlayerID(unitId);
                                        vector v = kbUnitGetTruePosition(unitId);

                                        BenchData bench = g_shop.m_benches[pPlayer];
                                        int[] unitIds = bench.getDeployedUnitIDs();
                                        int[] closestUnitIds = new int(0, -1);

                                        for (int i = 0; i < unitIds.size(); i++) {
                                            int targetUnitID = unitIds[i];
                                            selectSingle(targetUnitID);
                                            if (trUnitDead()) { continue; }
                                            if (kbUnitGetDistanceToPoint(targetUnitID, v) <= 1.5) {
                                                closestUnitIds.add(targetUnitID);
                                            }
                                        }

                                        if (closestUnitIds.size() == 1) {
                                            int targetId = closestUnitIds[0];
                                            if (kbUnitGetIsAffectedByStatusEffect(targetId, cStatusEffectStunned)) { return; }

                                            int shopId = bench.getPlayerShopID();
                                            vector shopVector = kbUnitGetPosition(shopId);
                                            selectSingle(targetId);
                                            vector v2 = kbUnitGetTruePosition(targetId);
                                            trUnitApplyEffect(cOnHitEffectStun, RECALL_CAST_TIME);
                                            trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXVortexFinish), v2.x, v2.y, v2.z, -1, 0);
                                            setUnitCacheValue(targetId, kbUnitGetStatFloat(targetId, cUnitStatCurrHP));
                                            playUnitSound(targetId, "VortexBirth", SOUND_SET);

                                            midFreqSchedulerWithVector.add(targetId, 500, shopVector, [](int targetId = 0, int iteration = 0, vector shopVector = cInvalidVector) -> bool {
                                                float currHP = kbUnitGetStatFloat(targetId, cUnitStatCurrHP);
                                                if (currHP < getUnitCacheValue(targetId)) {
                                                    selectSingle(targetId);
                                                    vector vPos = kbUnitGetTruePosition(targetId);
                                                    trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXArkantosGodIn), vPos.x, vPos.y, vPos.z, -1, 0);
                                                    playUnitSound(targetId, "AotgLegendDeath", SOUND_SET);
                                                    setUnitCacheValue(targetId, 0);
                                                    return false;
                                                }
                                                setUnitCacheValue(targetId, currHP);
                                                if (iteration == 6 || iteration == 12 || iteration == 15) {
                                                    vector vPos = kbUnitGetTruePosition(targetId);
                                                    trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXVortexFinish), vPos.x, vPos.y, vPos.z, -1, 0);
                                                }
                                                else if (iteration >= 20) {
                                                    selectSingle(targetId);
                                                    trUnitReposition(shopVector.x, shopVector.y, shopVector.z, false, true);
                                                    playUnitSound(targetId, "VortexLift", SOUND_SET);
                                                    setUnitCacheValue(targetId, 0);
                                                    return false;
                                                }
                                                return true;
                                            });
                                        }
                                        else if (closestUnitIds.size() >= 2 && trCurrentPlayer() == pPlayer) {
                                            for (int i = 0; i < closestUnitIds.size(); i++) {
                                                selectSingle(closestUnitIds[i]);
                                                trUnitHighlight(5.0, true);
                                            }
                                            trChatSendToPlayer(pPlayer, pPlayer, "Unit must be away from other units to recall.");
                                            trSoundsetPlayPlayer(pPlayer, "PopCapHit");
                                        }
                                    }
    );

    trProtounitAddTrain(protoUnit, p, plantName, 3, 5);
    setUpUnitCache(kbProtoUnitGetID(protoUnit), p, cResourceFavor);
    trExecuteConsoleCommand("map("+quote+"B"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+648+", 1, false)"+quote+")");
}

void addMarketCommands() {
    for (int p = 1; p <= cNumberPlayers - 2; p++) {
        string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                        "Open shop (Q)",
                                        "Purchase cards.",
                                        "resources\\shared\\static_color\\buildings\\market_icon.png",
                                        [](int unitId = -1) -> void {
                                            openShop(kbUnitGetPlayerID(unitId));
                                        }
        );
        trProtounitAddTrain("Market", p, plantName, 0, 0);
    }
    trExecuteConsoleCommand("map("+quote+"Q"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+643+", 1, false)"+quote+")");
}

void addForgeCommands(int p = -1) {
    string plantName = preparePlant(p, cUnitTypePlantGreekShrub, 
                                    "Open forge (W)",
                                    "Add sockets to your cards.",
                                    "resources\\nature\\relics\\relic_anvil_icon.png",
                                    [](int unitId = -1) -> void {
                                        openForge(kbUnitGetPlayerID(unitId));
                                    }
    );
    trProtounitAddTrain("Market", p, plantName, 0, 1);
    trSoundsetPlayPlayer(p, "ArmorySelect");
    trExecuteConsoleCommand("map("+quote+"W"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+644+", 1, false)"+quote+")");
}

void removeForgeCommands(int p = -1) {
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekShrub));
    g_OnCreationListener.deregister(p, cUnitTypePlantGreekShrub);
}

void addArmoryCommands(int p = -1) {
    string plantName = preparePlant(p, cUnitTypePlantGreekGrass, 
                                    "Open armory (E)",
                                    "Add upgrades to your cards.",
                                    "resources\\nature\\relics\\relic_jewelry_icon.png",
                                    [](int unitId = -1) -> void {
                                        openArmory(kbUnitGetPlayerID(unitId));
                                    }
    );
    trProtounitAddTrain("Market", p, plantName, 0, 2);
    trSoundsetPlayPlayer(p, "ArmorySelect");
    trExecuteConsoleCommand("map("+quote+"E"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+645+", 1, false)"+quote+")");
}

void removeArmoryCommands(int p = -1) {
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekGrass));
    g_OnCreationListener.deregister(p, cUnitTypePlantGreekGrass);
}

void addTempleCommands(int p = -1) {
    string plantName = preparePlant(p, cUnitTypePlantGreekWeeds, 
                                    "Open temple (R)",
                                    "Reroll rarities for your cards.",
                                    "resources\\nature\\relics\\relic_ankh_icon.png",
                                    [](int unitId = -1) -> void {
                                        openTemple(kbUnitGetPlayerID(unitId));
                                    }
    );
    trProtounitAddTrain("Market", p, plantName, 0, 3);
    trSoundsetPlayPlayer(p, "TempleSelect");
    trExecuteConsoleCommand("map("+quote+"R"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+646+", 1, false)"+quote+")");
}

void removeTempleCommands(int p = -1) {
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekWeeds));
    g_OnCreationListener.deregister(p, cUnitTypePlantGreekWeeds);
}

void addShrineCommands(int p = -1) {
    string plantName = preparePlant(p, cUnitTypePlantGreekFern, 
                                    "Open library (T)",
                                    "Identify cards.",
                                    "resources\\nature\\relics\\relic_scroll_icon.png",
                                    [](int unitId = -1) -> void {
                                        openShrine(kbUnitGetPlayerID(unitId));
                                    }
    );
    trProtounitAddTrain("Market", p, plantName, 0, 4);
    trSoundsetPlayPlayer(p, "ShrineSelect");
    trExecuteConsoleCommand("map("+quote+"T"+quote+", "+quote+"game"+quote+", "+quote+"trainInSelectedByID("+647+", 1, false)"+quote+")");
}

void removeShrineCommands(int p = -1) {
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekFern));
    g_OnCreationListener.deregister(p, cUnitTypePlantGreekFern);
}

void initPlayerCommands() {
    trSetMilitaryAutoTrain(false);
    addMarketCommands();
}