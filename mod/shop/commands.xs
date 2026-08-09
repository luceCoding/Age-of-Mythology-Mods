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

void initPlayerCommands(int p = 1){
    playerCommandsArray.resize(cNumberPlayers + 1);
    string plantName = preparePlant(p, cUnitTypePlantGreekBush, 
                                    "Open shop",
                                    "Use your gold to purchase cards at the shop.",
                                    "shared\static_color\technologies\advanced_fortifications_icon.png",
                                    [](int p = 1) -> void {
                                                            openShop(p);
                                                            log(3, "WTF");
                                                        }
                                    );
    trProtounitAddTrain("Market", p, plantName, 0, 3);
}