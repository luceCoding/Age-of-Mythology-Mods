class PlayerCommands {
int[] plantArray = default;
void(int, vector)[] applyArray = default;
};

PlayerCommands[] playerCommandsArray = default;
string[] plantNames = default;
int COMMAND_TYPE = cUnitTypeLegendHero;
string COMMAND_TYPE_NAME = "LegendHero";

string preparePlant(int p = 1, int plantType = -1, 
                    string name = "", string description = "", string icon = "", 
                    void(int, vector) apply = [](int pToUse = 1, vector v = cInvalidVector) -> void {}){
    PlayerCommands playerCommands = playerCommandsArray[p];
    playerCommands.plantArray.add(plantType);
    playerCommands.applyArray.add(apply);
    playerCommandsArray[p] = playerCommands;
    string plantName = kbProtoUnitGetName(plantType);
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

void addRecallCommand(int p = 0, string protoUnit = ""){
    string plantName = preparePlant(p, cUnitTypePlantEgyptianBush, 
                                    "Recall",
                                    "Teleport back to your card shop.",
                                    "resources\atlantean\static_color\god_powers\vortex_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                        BenchData bench = g_shop.m_benches[p];
                                        int[] unitIds = bench.getDeployedUnitIDs();
                                        int[] closestUnitIds = new int(0, -1);
                                        for (int i = 0; i < unitIds.size(); i++){
                                            if (kbUnitGetDistanceToPoint(unitIds[i], v) <= 1.5){
                                                closestUnitIds.add(unitIds[i]);
                                            }
                                        }
                                        if (closestUnitIds.size() == 1){
                                            int unitId = closestUnitIds[0];
                                            int shopId = bench.getPlayerShopID();
                                            vector shopVector = kbUnitGetPosition(shopId);
                                            selectSingle(unitId);
                                            vector v2 = kbUnitGetTruePosition(unitId);
                                            trUnitApplyEffect(cOnHitEffectStun, 10.0);
                                            trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXVortexFinish), v2.x, v2.y, v2.z, -1, 0);
                                            setUnitCacheValue(unitId, kbUnitGetStatFloat(unitId, cUnitStatCurrHP));
                                            playUnitSound(unitId, "VortexBirth", SOUND_SET);
                                            unitSchedulerWithVector.add(unitId, 500, shopVector, [](int unitId = 0, int iteration = 0, vector shopVector = cInvalidVector) -> bool {
                                                float currHP = kbUnitGetStatFloat(unitId, cUnitStatCurrHP);
                                                if (currHP < getUnitCacheValue(unitId)){
                                                    selectSingle(unitId);
                                                    vector v = kbUnitGetTruePosition(unitId);
                                                    trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXArkantosGodIn), v.x, v.y, v.z, -1, 0);
                                                    playUnitSound(unitId, "AotgLegendDeath", SOUND_SET);
                                                    setUnitCacheValue(unitId, 0);
                                                    return false;
                                                }
                                                setUnitCacheValue(unitId, currHP);
                                                if (iteration == 6 || iteration == 12 || iteration == 15 ){
                                                    vector v = kbUnitGetTruePosition(unitId);
                                                    trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVFXVortexFinish), v.x, v.y, v.z, -1, 0);
                                                }
                                                if (iteration >= 20){
                                                    selectSingle(unitId);
                                                    trUnitReposition(shopVector.x, shopVector.y, shopVector.z, false, true);
                                                    playUnitSound(unitId, "VortexLift", SOUND_SET);
                                                    setUnitCacheValue(unitId, 0);
                                                    return false;
                                                }
                                                return true;
                                            });
                                        }
                                        else if (closestUnitIds.size() >= 2 && trCurrentPlayer() == p){
                                            for (int i = 0; i < closestUnitIds.size(); i++){
                                                selectSingle(closestUnitIds[i]);
                                                trUnitHighlight(5.0, true);
                                            }
                                            trChatSendToPlayer(p, p, "Unit must be away from other units to recall.");
                                            trSoundsetPlayPlayer(p, "PopCapHit");
                                        }
                                    }
                                    );
    trProtounitAddTrain(protoUnit, p, plantName, 3, 5);
    setUpUnitCache(kbProtoUnitGetID(protoUnit), p, cResourceFavor);
}

void addMarketCommands(){
    for(int p = 1; p <= cNumberPlayers-2; p++) {
        string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                        "Open shop",
                                        "Purchase cards.",
                                        "resources\shared\static_color\buildings\market_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                                                openShop(p);
                                                            }
                                        );
        trProtounitAddTrain("Market", p, plantName, 0, 0);
    }
}

void addForgeCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekShrub, 
                                    "Open forge",
                                    "Add sockets to your cards.",
                                    "resources\nature\relics\relic_anvil_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                                            openForge(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 1);
    trSoundsetPlayPlayer(p, "ArmorySelect");
}

void removeForgeCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekShrub));
}

void addArmoryCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekGrass, 
                                    "Open armory",
                                    "Add upgrades to your cards.",
                                    "resources\nature\relics\relic_jewelry_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                                            openArmory(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 2);
    trSoundsetPlayPlayer(p, "ArmorySelect");
}

void removeArmoryCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekGrass));
}

void addTempleCommands(int p = -1){
    return; // TODO: Disabled for now
    string plantName = preparePlant(p, cUnitTypePlantGreekWeeds, 
                                    "Open temple",
                                    "Reroll rarities for your cards.",
                                    "resources\nature\relics\relic_ankh_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                                            openTemple(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 3);
    trSoundsetPlayPlayer(p, "TempleSelect");
}

void removeTempleCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekWeeds));
}

void addShrineCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekFern, 
                                    "Open library",
                                    "Identify cards.",
                                    "resources\nature\relics\relic_scroll_icon.png",
                                    [](int p = 1, vector v = cInvalidVector) -> void {
                                                            openShrine(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 4);
    trSoundsetPlayPlayer(p, "ShrineSelect");
}

void removeShrineCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekFern));
}

void initPlayerCommands(){
    trSetMilitaryAutoTrain(false);
    playerCommandsArray.resize(cNumberPlayers + 1);
    addMarketCommands();
}