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

void addMarketCommands(){
    for(int p = 1; p <= cNumberPlayers-2; p++) {
        string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                        "Open shop",
                                        "Purchase cards.",
                                        "resources\shared\static_color\buildings\market_icon.png",
                                        [](int p = 1) -> void {
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
                                    [](int p = 1) -> void {
                                                            openForge(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 1);
}

void removeForgeCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekShrub));
}

void addArmoryCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekGrass, 
                                    "Open armory",
                                    "Add upgrades to your cards.",
                                    "resources\nature\relics\relic_jewelry_icon.png",
                                    [](int p = 1) -> void {
                                                            openArmory(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 2);
}

void removeArmoryCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekGrass));
}

void addTempleCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekWeeds, 
                                    "Open temple",
                                    "Reroll rarities for your cards.",
                                    "resources\nature\relics\relic_ankh_icon.png",
                                    [](int p = 1) -> void {
                                                            openTemple(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 3);
}

void removeTempleCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekWeeds));
}

void addShrineCommands(int p = -1){
    string plantName = preparePlant(p, cUnitTypePlantGreekFern, 
                                    "Open library",
                                    "Identify cards.",
                                    "resources\nature\relics\relic_scroll_icon.png",
                                    [](int p = 1) -> void {
                                                            openShrine(p);
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 4);
}

void removeShrineCommands(int p = -1){
    trProtounitRemoveTrain("Market", p, kbProtoUnitGetName(cUnitTypePlantGreekFern));
}

void initPlayerCommands(){
    trSetMilitaryAutoTrain(false);
    playerCommandsArray.resize(cNumberPlayers + 1);
    addMarketCommands();
}