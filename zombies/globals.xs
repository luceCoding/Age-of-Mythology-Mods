const int configMapTileX = 159;
const int configMapTileZ = 159;
const int configMapBaseHeight = 4;

const int cHumanAIPlayer = cNumberPlayers;

const int cDefaultcUnitTypeWall = cUnitTypeWallConnector;
const int cDefaultcUnitTypeWall2 = cUnitTypeWallShort;
const int cDefaultcUnitTypeGate = cUnitTypeWallGate;
const int cDefaultcUnitTypeGate2 = cUnitTypeWallGate;

const int cStartingWood = 100;
const int cStartingGold = 10;
const int cGaiaBaseWallHealth = 100;
const float cBaseHumanLOS = 5.0;

vector g_bspZombieSpawnLocation = cInvalidVector;
vector g_bspHumanSpawnLocation = cInvalidVector;
int[] g_humanUnitIDs = default;
int g_humanUnitCount = 0;

int[] g_humanInteractableTypes = default;
int[] g_humanInteractableObjects = default;
int[] g_treasureChestObjects = default;
int[] g_humanUnitTypes = default;
int[] g_zombieUnitTypes = default;
int[] g_placeHolderUnitTypes = default;
int[] g_lootDrops = default;

void initializeGlobals(){
    // Lowest weight for first interactable, higher for later ones to make them rarer
    g_humanInteractableTypes.add(cUnitTypeLighthouse);
    g_humanInteractableTypes.add(cUnitTypeToriiGate);
    g_humanInteractableTypes.add(cUnitTypeTemple);
    g_humanInteractableTypes.add(cUnitTypeSiegeWorks);
    g_humanInteractableTypes.add(cUnitTypeDwarvenForge);
    g_humanInteractableTypes.add(cUnitTypeArmory);

    g_humanUnitTypes.add(cUnitTypeVillagerAtlanteanHero);

    g_zombieUnitTypes.add(cUnitTypeMictlantecuhtli);

    g_placeHolderUnitTypes.add(cUnitTypeBonePileSmallWhite);
    g_placeHolderUnitTypes.add(cUnitTypeBonePileMediumWhite);
    g_placeHolderUnitTypes.add(cUnitTypeSpiderEgg);
    g_placeHolderUnitTypes.add(cUnitTypeCracks);
    g_placeHolderUnitTypes.add(cUnitTypeGoldPile);
    g_placeHolderUnitTypes.add(cUnitTypeRelic);
    g_placeHolderUnitTypes.add(cUnitTypeCocoon);
    g_placeHolderUnitTypes.add(cUnitTypeTaproot);
    g_placeHolderUnitTypes.add(cUnitTypeWoodPileLarge);
    g_placeHolderUnitTypes.add(cUnitTypeOsirisPieceBox);

    g_lootDrops.add(cUnitTypeWoodPileLarge);
    g_lootDrops.add(cUnitTypeGoldPile);
}