const int configMapTileX = 159;
const int configMapTileZ = 159;
const int configMapBaseHeight = 4;

const int cHumanAIPlayer = cNumberPlayers;

const int cDefaultcUnitTypeWall = cUnitTypeWallConnector;
const int cDefaultcUnitTypeWall2 = cUnitTypeWallShort;
const int cDefaultcUnitTypeGate = cUnitTypeWallGate;
const int cDefaultcUnitTypeGate2 = cUnitTypeWallGate;

const int cStartingWood = 50;
const int cStartingGold = 10;
const int cGaiaBaseGateHealth = 100;
const int cGaiaBaseWallHealth = 1000;
const float cBaseHumanLOS = 10.0;

int g_dayDurationMS = 120000;
int g_nightDurationMS = 240000;
bool g_isNight = false;
bool g_dayCycleActive = false;
int g_phaseEndTimeMS = 0;
int g_dayNumber = 1;

const int maxZombiePopulation = cNumberPlayers * 10;

vector g_bspZombieSpawnLocation = cInvalidVector;
int[] g_humanSpawnPoints = default;
int[] g_humanUnitIDs = default;
int[] g_zombieUnitIDs = default;
int g_humanUnitCount = 0;
int g_zombieUnitCount = 0;

int[] g_humanInteractableTypes = default;
int[] g_humanInteractableObjects = default;
int[] g_treasureChestObjects = default;
int[] g_humanUnitTypes = default;
int[] g_zombieUnitTypes = default;
int[] g_placeHolderUnitTypes = default;
int[] g_lootDrops = default;
int[] g_upgradeableHumanBuildings = default;
int[] g_trashZombieTypes = default;
int[] g_purchaseableZombieTypes = default;

int[] g_bossTileIds = default;
int[] g_bossTileUnitTypes = default;

void initializeGlobals(){
    // Lowest weight for first interactable, higher for later ones to make them rarer
    g_humanInteractableTypes.add(cUnitTypeLighthouse);
    g_humanInteractableTypes.add(cUnitTypeToriiGate);
    g_humanInteractableTypes.add(cUnitTypeTemple);
    g_humanInteractableTypes.add(cUnitTypeSiegeWorks);
    g_humanInteractableTypes.add(cUnitTypeArmory);
    g_humanInteractableTypes.add(cUnitTypeEconomicGuild);

    g_humanUnitTypes.add(cUnitTypeVillagerAtlanteanHero);

    g_zombieUnitTypes.add(cUnitTypeSetna);

    g_placeHolderUnitTypes.add(cUnitTypeBonePileSmallWhite);
    g_placeHolderUnitTypes.add(cUnitTypeBonePileMediumWhite);
    g_placeHolderUnitTypes.add(cUnitTypeSpiderEgg);
    g_placeHolderUnitTypes.add(cUnitTypeCracks);
    g_placeHolderUnitTypes.add(cUnitTypeGoldPile);
    g_placeHolderUnitTypes.add(cUnitTypeRelic);
    g_placeHolderUnitTypes.add(cUnitTypeCocoon);
    g_placeHolderUnitTypes.add(cUnitTypeTreeHades);
    g_placeHolderUnitTypes.add(cUnitTypeWoodPileLarge);
    g_placeHolderUnitTypes.add(cUnitTypeOsirisPieceBox);
    g_placeHolderUnitTypes.add(cUnitTypeObsidianShard);
    g_placeHolderUnitTypes.add(cUnitTypeMinion);
    g_placeHolderUnitTypes.add(cUnitTypeCanopicJars);

    g_lootDrops.add(cUnitTypeWoodPileLarge);
    g_lootDrops.add(cUnitTypeGoldPile);

    g_upgradeableHumanBuildings.add(cUnitTypeWallShort);
    g_upgradeableHumanBuildings.add(cUnitTypeWallMedium);
    g_upgradeableHumanBuildings.add(cUnitTypeWallLong);
    g_upgradeableHumanBuildings.add(cUnitTypeWallConnector);
    g_upgradeableHumanBuildings.add(cUnitTypeWallGate);
    g_upgradeableHumanBuildings.add(cUnitTypeObelisk);
    g_upgradeableHumanBuildings.add(cUnitTypeSmokeTrap);
    g_upgradeableHumanBuildings.add(cUnitTypeSkyPassage);
    g_upgradeableHumanBuildings.add(cUnitTypeSentryTower);
    g_upgradeableHumanBuildings.add(cUnitTypeRockGiant);
    g_upgradeableHumanBuildings.add(cUnitTypeSpikeTrap);
    g_upgradeableHumanBuildings.add(cUnitTypeMonolithOfTlaloc);
    g_upgradeableHumanBuildings.add(cUnitTypeStatueOfLightning);

    g_trashZombieTypes.add(cUnitTypeMinionReincarnated);
    g_trashZombieTypes.add(cUnitTypeTlacanexquimilliSPC);
    g_trashZombieTypes.add(cUnitTypeTartarianSpawn);
    g_trashZombieTypes.add(cUnitTypeTzitzimitl);
    g_trashZombieTypes.add(cUnitTypeMummy);

    g_purchaseableZombieTypes.add(cUnitTypeAnubite);
    g_purchaseableZombieTypes.add(cUnitTypeScarab);

    g_bossTileUnitTypes.add(cUnitTypeSphinx);
    g_bossTileUnitTypes.add(cUnitTypeTroll);
    g_bossTileUnitTypes.add(cUnitTypeCentimanus);
    g_bossTileUnitTypes.add(cUnitTypeNemeanLion);
    g_bossTileUnitTypes.add(cUnitTypeHydra);
    g_bossTileUnitTypes.add(cUnitTypeChimera);
}