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
const int cGaiaBaseGateHealth = 500;
const int cGaiaBaseWallHealth = 5000;
const int cBaseJailWallHealth = 100000;
const float cBaseHumanLOS = 10.0;
const float cHumanWallHealthMultiplier = 2.0;

const int VOTE_DURATION_MS = 60000;
int g_dayDurationMS = 120000;
int g_nightDurationMS = 240000;
bool g_isNight = false;
bool g_dayCycleActive = false;
int g_phaseEndTimeMS = 0;
int g_dayNumber = 1;
int g_daysToSurvive = 7;
int bloodMoonCycle = 7;

const int cTrashZombieSpawnTimer = 6000;
const float cBaseZombieLifespan = 60.0;
const float dailyZombiePermaHPBuffPercent = 1.00;
const float dailyZombiePermaLifespanBuff = 5.0;
const int maxZombiePopulation = cNumberPlayers * 10;

vector g_bspZombieSpawnLocation = cInvalidVector;
int[] g_humanSpawnPoints = default;
int[] g_humanUnitIDs = default;
int[] g_zombieUnitIDs = default;
int g_humanUnitCount = 0;
int g_zombieUnitCount = 0;

const float trashZombieKillRewardWood = 2.0;
const float trashZombieKillRewardGold = 1.0;
const float zombieBaseWoodCost = 2.0;
const float zombieBaseGoldCost = 2.0;
const float baseWellOfUrdWoodCost = 45.0;

const float humanBuildingsKillRewardWood = 4.0;
const float humanBuildingsKillRewardGold = 2.0;
const float humanBaseWoodCost = 2.0;
const float humanBaseGoldCost = 2.0;

const float g_alphaSensitivity = 2.5; // Responsiveness weight for zombie performance adjustments
const float g_exponentK = 0.75; // Sub-linear team size exponent
const float g_targetZombieDestruction = 0.25;
const float g_minDailyBuff = 1.01;
const float g_maxDailyBuff = 1.25;

const int woodEvery20Seconds = 10;
const int goldEvery20Seconds = 1;

int[] g_humanInteractableTypes = default;
int[] g_humanInteractableObjects = default;
int[] g_treasureChestObjects = default;
int[] g_humanUnitTypes = default;
int[] g_zombieUnitTypes = default;
int[] g_placeHolderUnitTypes = default;
int[] g_lootDrops = default;
int[] g_upgradeableHumanBuildings = default;
int[] g_trashZombieTypes = default;

int[] g_otherHumanBuildings = default;
int[] g_otherZombieTypes = default;

int[] g_purchaseableT1ZombieTypes = default;
int[] g_purchaseableT2ZombieTypes = default;
int[] g_purchaseableT3ZombieTypes = default;
int[] g_purchaseableT4ZombieTypes = default;

int[] g_purchaseableT1GodPowers = default;
int[] g_purchaseableT2GodPowers = default;
int[] g_purchaseableT3GodPowers = default;
int[] g_purchaseableT4GodPowers = default;

string[] g_purchaseableT1GodPowerIcons = default;
string[] g_purchaseableT2GodPowerIcons = default;
string[] g_purchaseableT3GodPowerIcons = default;
string[] g_purchaseableT4GodPowerIcons = default;

int[] g_bossTileIds = default;
int[] g_bossTileUnitTypes = default;

void initializeGlobals(){
    // Lowest weight for first interactable, higher for later ones to make them rarer
    g_humanInteractableTypes.add(cUnitTypeLighthouse);
    g_humanInteractableTypes.add(cUnitTypeToriiGate);
    g_humanInteractableTypes.add(cUnitTypeTemple);
    g_humanInteractableTypes.add(cUnitTypeArmory);
    g_humanInteractableTypes.add(cUnitTypeSiegeWorks);
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
    // g_placeHolderUnitTypes.add(cUnitTypeWoodPileLarge);
    g_placeHolderUnitTypes.add(cUnitTypeOsirisPieceBox);
    g_placeHolderUnitTypes.add(cUnitTypeObsidianShard);
    g_placeHolderUnitTypes.add(cUnitTypeMinion);
    g_placeHolderUnitTypes.add(cUnitTypeCanopicJars);

    // g_lootDrops.add(cUnitTypeWoodPileLarge);
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
    g_upgradeableHumanBuildings.add(cUnitTypeMirrorTower);
    g_upgradeableHumanBuildings.add(cUnitTypeRockGiant);
    g_upgradeableHumanBuildings.add(cUnitTypeWanyudo);
    g_upgradeableHumanBuildings.add(cUnitTypeSpikeTrap);
    g_upgradeableHumanBuildings.add(cUnitTypeHillFort);
    g_upgradeableHumanBuildings.add(cUnitTypeMonumentToVillagers);
    g_upgradeableHumanBuildings.add(cUnitTypeMonolithOfTlaloc);
    g_upgradeableHumanBuildings.add(cUnitTypeStatueOfLightning);
    g_upgradeableHumanBuildings.add(cUnitTypeSentinel);
    g_upgradeableHumanBuildings.add(cUnitTypeEarthWall);

    g_trashZombieTypes.add(cUnitTypeMinion);
    g_trashZombieTypes.add(cUnitTypeTlacanexquimilliSPC);
    g_trashZombieTypes.add(cUnitTypeTartarianSpawn);
    g_trashZombieTypes.add(cUnitTypeTzitzimitl);
    g_trashZombieTypes.add(cUnitTypeMummy);

    g_purchaseableT1ZombieTypes.add(cUnitTypeAnubite);
    g_purchaseableT1ZombieTypes.add(cUnitTypeCyclops);
    g_purchaseableT1ZombieTypes.add(cUnitTypeEinheri);
    g_purchaseableT1ZombieTypes.add(cUnitTypeDraugr);
    g_purchaseableT1ZombieTypes.add(cUnitTypeFireArcher);
    g_purchaseableT1ZombieTypes.add(cUnitTypeQiongQi);

    g_purchaseableT2ZombieTypes.add(cUnitTypeDestroyerHero);
    g_purchaseableT2ZombieTypes.add(cUnitTypeOtontin);
    g_purchaseableT2ZombieTypes.add(cUnitTypeScarab);
    g_purchaseableT2ZombieTypes.add(cUnitTypeAyotochtli);
    g_purchaseableT2ZombieTypes.add(cUnitTypeOni);

    g_purchaseableT3ZombieTypes.add(cUnitTypeShinigami);
    g_purchaseableT3ZombieTypes.add(cUnitTypeGastraphetoros);
    g_purchaseableT3ZombieTypes.add(cUnitTypeFireGiant);
    g_purchaseableT3ZombieTypes.add(cUnitTypeColossus);
    g_purchaseableT3ZombieTypes.add(cUnitTypeOnmyoji);
    g_purchaseableT3ZombieTypes.add(cUnitTypeOnmoraki);

    g_purchaseableT4ZombieTypes.add(cUnitTypeNidhogg);
    g_purchaseableT4ZombieTypes.add(cUnitTypePolyphemus);
    // g_purchaseableT4ZombieTypes.add(cUnitTypeQuinametzin);

    g_bossTileUnitTypes.add(cUnitTypeSphinx);
    g_bossTileUnitTypes.add(cUnitTypeTroll);
    g_bossTileUnitTypes.add(cUnitTypeCentimanus);
    g_bossTileUnitTypes.add(cUnitTypeNemeanLion);
    g_bossTileUnitTypes.add(cUnitTypeHydra);
    g_bossTileUnitTypes.add(cUnitTypeChimera);

    g_purchaseableT1GodPowers.add(cProtoPowerCarnivora);
    g_purchaseableT1GodPowers.add(cProtoPowerDeconstruction);
    g_purchaseableT1GodPowers.add(cProtoPowerInfestation);
    g_purchaseableT1GodPowers.add(cProtoPowerWither);

    g_purchaseableT1GodPowerIcons.add("resources\atlantean\player_color\units\carnivora_icon.png");
    g_purchaseableT1GodPowerIcons.add("atlantean\static_color\god_powers\deconstruction_icon.png");
    g_purchaseableT1GodPowerIcons.add("resources\aztec\static_color\god_powers\infestation_icon.png");
    g_purchaseableT1GodPowerIcons.add("resources\greek_demeter\static_color\god_powers\wither_icon.png");

    g_purchaseableT2GodPowers.add(cProtoPowerDroughtLand);
    g_purchaseableT2GodPowers.add(cProtoPowerAncestors);
    g_purchaseableT2GodPowers.add(cProtoPowerEclipse);

    g_purchaseableT2GodPowerIcons.add("resources\chinese\static_color\god_powers\drought_land_icon.png");
    g_purchaseableT2GodPowerIcons.add("resources\egyptian\static_color\god_powers\ancestors_icon.png");
    g_purchaseableT2GodPowerIcons.add("resources\egyptian\static_color\god_powers\eclipse_icon.png");

    g_purchaseableT3GodPowers.add(cProtoPowerSmitingGust);

    g_purchaseableT3GodPowerIcons.add("resources\japanese\static_color\god_powers\smiting_gust_icon.png");

    g_purchaseableT4GodPowers.add(cProtoPowerMeteor);
    g_purchaseableT4GodPowers.add(cProtoPowerUndermine);
    g_purchaseableT4GodPowerIcons.add("resources\egyptian\static_color\god_powers\meteor_icon.png");
    g_purchaseableT4GodPowerIcons.add("resources\norse\static_color\god_powers\undermine_icon.png");

    g_otherZombieTypes.add(cUnitTypeCarnivora);
    g_otherZombieTypes.add(cUnitTypeInfestedDen);
    g_otherZombieTypes.add(cUnitTypeLargeScorpion);
}