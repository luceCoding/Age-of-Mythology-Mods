int COMMAND_TYPE = cUnitTypeLegendHero;
string COMMAND_TYPE_NAME = "LegendHero";

// Allocates a plant for the command, registers it, and returns the plant type used.
int addCommand(int p = 1, int targetProtoType = -1, int row = 0, int col = 0,
                    float initialCost = 0.0,
                    string resource = "", string name = "", string description = "", string icon = "", 
                    void(int) event = [](int unitId = -1) -> void {}) {

    int plantType = g_PlantAllocator.allocate(p, targetProtoType);
    if (plantType == -1) {
        return -1;
    }
    string plantName = kbProtoUnitGetName(plantType);

    // Register event handler directly with the event manager
    if (p != 0 || p != cHumanAIPlayer){
        g_OnCreationListener.register(p, plantType, true, event);
    }

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
    trProtounitAddTrain(kbProtoUnitGetName(targetProtoType), p, plantName, row, col);
    trModifyProtounitResource(plantName, "Food", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(plantName, "Wood", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(plantName, "Gold", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(plantName, "Favor", p, cXSPUResourceEffectCost, 0, cXSRelativityAssign);
    trModifyProtounitResource(plantName, resource, p, cXSPUResourceEffectCost, initialCost, cXSRelativityAssign);
    trModifyProtounitData(plantName, p, cXSProtoEffectBuildLimit, 1, cXSRelativityAssign);
    return plantType;
}