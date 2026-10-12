const int configMapTileX = 256;
const int configMapTileZ = 256;
const int configMapBaseHeight = 4;

const int cZombieAIPlayer = cNumberPlayers;
const int cHumanAIPlayer = cNumberPlayers - 1;

int[] g_humanInteractableTypes = default;

void initializeGlobals(){
    // Lowest weight for first interactable, higher for later ones to make them rarer
    g_humanInteractableTypes.add(cUnitTypeLighthouse);
    g_humanInteractableTypes.add(cUnitTypeToriiGate);
    g_humanInteractableTypes.add(cUnitTypeTemple);
    g_humanInteractableTypes.add(cUnitTypeSiegeWorks);
    g_humanInteractableTypes.add(cUnitTypeDwarvenArmory);
    g_humanInteractableTypes.add(cUnitTypeArmory);
}