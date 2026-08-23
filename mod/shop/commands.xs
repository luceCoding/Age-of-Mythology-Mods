class PlayerCommands {
int[] plantArray = default;
void(int)[] applyArray = default;
};

PlayerCommands[] playerCommandsArray = default;
string[] plantNames = default;
int COMMAND_TYPE = cUnitTypeLegendHero;
string COMMAND_TYPE_NAME = "LegendHero";

string preparePlant(int p = 1, int plantType = -1, 
                    string name = "", string description = "", string icon = "", 
                    void(int) apply = [](int pToUse = 1) -> void {}){
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
    trUnforbidProtounit(p, plantName);
    trModifyProtounitData(plantName, p, cXSProtoEffectTrainPoints, 0.01, cXSRelativityAssign);
    trProtoUnitSetUnitType(p, plantName, COMMAND_TYPE_NAME, true);
    trProtoUnitChangeName(plantName, p, name, description, description);
    trProtoUnitSetIcon(plantName, p, icon);
    return plantName;
}

void removeShopCommands(int p = 0, string shopType = ""){
    for(int i = 0; i < plantNames.size(); i++) {
        string plantName = plantNames[i];
        trProtounitRemoveTrain(shopType, p, plantName);
    }
}

void addMarketCommands(){
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                        "Open shop",
                                        "Purchase cards.",
                                        "resources\shared\static_color\buildings\market_icon.png",
                                        [](int p = 1) -> void {
                                                                openShop(p);
                                                            }
                                        );
        trProtounitAddTrain("Market", p, plantName, 0, 5);
    }
}

void addForgeCommands(){
    int plantType = cUnitTypePlantGreekShrub;
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, plantType, 
                                        "Open forge",
                                        "Add sockets to your cards.",
                                        "resources\nature\relics\relic_anvil_icon.png",
                                        [](int p = 1) -> void {
                                                                openForge(p);
                                                            }
                                        );
        trProtounitAddTrain("DwarvenForge", p, plantName, 0, 5);
    }
    plantNames.add(kbProtoUnitGetName(plantType));
}

void addArmoryCommands(){
    int plantType = cUnitTypePlantGreekGrass;
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, plantType, 
                                        "Open armory",
                                        "Add upgrades to your cards.",
                                        "resources\nature\relics\relic_jewelry_icon.png",
                                        [](int p = 1) -> void {
                                                                openArmory(p);
                                                            }
                                        );
        trProtounitAddTrain("DwarvenArmory", p, plantName, 0, 5);
    }
    plantNames.add(kbProtoUnitGetName(plantType));
}

void addTempleCommands(){
    int plantType = cUnitTypePlantGreekWeeds;
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, plantType, 
                                        "Open temple",
                                        "Reroll rarities for your cards.",
                                        "resources\nature\relics\relic_ankh_icon.png",
                                        [](int p = 1) -> void {
                                                                openTemple(p);
                                                            }
                                        );
        trProtounitAddTrain("TempleOfTheGods", p, plantName, 0, 5);
    }
    plantNames.add(kbProtoUnitGetName(plantType));
}

void addShrineCommands(){
    int plantType = cUnitTypePlantGreekFern;
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, plantType, 
                                        "Open library",
                                        "Identify cards.",
                                        "resources\nature\relics\relic_scroll_icon.png",
                                        [](int p = 1) -> void {
                                                                openShrine(p);
                                                            }
                                        );
        trProtounitAddTrain("ShrineJapanese", p, plantName, 0, 5);
    }
    plantNames.add(kbProtoUnitGetName(plantType));
}

void initPlayerCommands(){
    playerCommandsArray.resize(cNumberPlayers + 1);
    addMarketCommands();
}