class PlayerCommands {
int[] plantArray = default;
void(int)[] applyArray = default;
};

PlayerCommands[] playerCommandsArray = default;
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

void initPlayerCommands(){
    playerCommandsArray.resize(cNumberPlayers + 1);
    for(int p = 0; p <= cNumberPlayers; p++) {
        string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                        "Open shop",
                                        "Use your gold to purchase cards at the shop.",
                                        "resources\shared\static_color\buildings\market_icon.png",
                                        [](int p = 1) -> void {
                                                                openShop(p);
                                                            }
                                        );
        trProtounitAddTrain("Market", p, plantName, 0, 5);

        plantName = preparePlant(p, cUnitTypePlantGreekShrub, 
                                        "Open forge",
                                        "Use your gold to add sockets at the forge.",
                                        "resources\nature\relics\relic_anvil_icon.png",
                                        [](int p = 1) -> void {
                                                                openForge(p);
                                                            }
                                        );
        trProtounitAddTrain("DwarvenForge", p, plantName, 0, 5);

        plantName = preparePlant(p, cUnitTypePlantGreekGrass, 
                                        "Open armory",
                                        "Use your gold to add upgrades at the armory.",
                                        "resources\nature\relics\relic_jewelry_icon.png",
                                        [](int p = 1) -> void {
                                                                openArmory(p);
                                                            }
                                        );
        trProtounitAddTrain("DwarvenArmory", p, plantName, 0, 5);

        plantName = preparePlant(p, cUnitTypePlantGreekWeeds, 
                                        "Open forge",
                                        "Use your gold to reroll rarities at the temple.",
                                        "resources\nature\relics\relic_ankh_icon.png",
                                        [](int p = 1) -> void {
                                                                openTemple(p);
                                                            }
                                        );
        trProtounitAddTrain("TempleOfTheGods", p, plantName, 0, 5);

        plantName = preparePlant(p, cUnitTypePlantGreekFern, 
                                        "Open forge",
                                        "Use your gold to reroll rarities at the temple.",
                                        "resources\nature\relics\relic_scroll_icon.png",
                                        [](int p = 1) -> void {
                                                                openShrine(p);
                                                            }
                                        );
        trProtounitAddTrain("ShrineJapanese", p, plantName, 0, 5);
    }
}