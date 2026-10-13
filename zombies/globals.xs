const int configMapTileX = 159;
const int configMapTileZ = 159;
const int configMapBaseHeight = 4;

const int cZombieAIPlayer = cNumberPlayers;
const int cHumanAIPlayer = cNumberPlayers - 1;

const int defaultcUnitTypeWall = cUnitTypeWallConnector;
const int defaultcUnitTypeWall2 = cUnitTypeWallShort;

vector g_bspZombieSpawnLocation = cInvalidVector;
vector g_bspHumanSpawnLocation = cInvalidVector;
int[] g_humanUnitIDs = default;
int g_humanUnitCount = 0;

int[] g_humanInteractableTypes = default;
int[] g_humanUnitTypes = default;

void initializeGlobals(){
    // Lowest weight for first interactable, higher for later ones to make them rarer
    g_humanInteractableTypes.add(cUnitTypeLighthouse);
    g_humanInteractableTypes.add(cUnitTypeToriiGate);
    g_humanInteractableTypes.add(cUnitTypeTemple);
    g_humanInteractableTypes.add(cUnitTypeSiegeWorks);
    g_humanInteractableTypes.add(cUnitTypeDwarvenArmory);
    g_humanInteractableTypes.add(cUnitTypeArmory);

    g_humanUnitTypes.add(cUnitTypeBrokk);
    g_humanUnitTypes.add(cUnitTypeEitri);
    g_humanUnitTypes.add(cUnitTypeVillagerAtlanteanHero);
}