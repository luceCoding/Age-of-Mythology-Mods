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
const float cBaseHumanBuildPoints = 5.0;

const int VOTE_DURATION_MS = 60000;
int g_dayDurationMS = 90000;
int g_nightDurationMS = 240000;
bool g_isNight = false;
bool g_dayCycleActive = false;
int g_phaseEndTimeMS = 0;
int g_dayNumber = 1;
int g_daysToSurvive = 7;
int bloodMoonCycle = 7;

const int cTrashZombieSpawnTimer = 6000;
// const float cBaseZombieLifespan = 60.0;
const float dailyZombiePermaHPBuffPercent = 1.00;
const float dailyZombiePermaLifespanBuff = 5.0;

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
const float g_exponentK = 0.7; // Sub-linear team size exponent
const float g_firstTrashZombieScaleFactor = 1.25;
const float g_targetZombieDestruction = 0.2;
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

int[] g_purchaseableZombieTypes = default;

GodPowerData[] g_humanT1GodPowers = default;
GodPowerData[] g_humanT2GodPowers = default;
GodPowerData[] g_humanT3GodPowers = default;
GodPowerData[] g_humanT4GodPowers = default;

GodPowerData[] g_zombieT1GodPowers = default;
GodPowerData[] g_zombieT2GodPowers = default;
GodPowerData[] g_zombieT3GodPowers = default;
GodPowerData[] g_zombieT4GodPowers = default;

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

    g_placeHolderUnitTypes.add(cUnitTypeGoldPile);
    g_placeHolderUnitTypes.add(cUnitTypeGoldPile);
    g_placeHolderUnitTypes.add(cUnitTypeBonePileSmallWhite);
    g_placeHolderUnitTypes.add(cUnitTypeBonePileMediumWhite);
    g_placeHolderUnitTypes.add(cUnitTypeSpiderEgg);
    g_placeHolderUnitTypes.add(cUnitTypeCracks);
    g_placeHolderUnitTypes.add(cUnitTypeCocoon);
    g_placeHolderUnitTypes.add(cUnitTypeTreeHades);
    g_placeHolderUnitTypes.add(cUnitTypeObsidianShard);
    g_placeHolderUnitTypes.add(cUnitTypeMinion);
    g_placeHolderUnitTypes.add(cUnitTypeHadesShade);
    g_placeHolderUnitTypes.add(cUnitTypeCanopicJars);
    g_placeHolderUnitTypes.add(cUnitTypeOsirisPieceBox);

    g_lootDrops.add(cUnitTypeGoldPile);
    g_lootDrops.add(cUnitTypeGoldPile);
    g_lootDrops.add(cUnitTypeGoldPile);
    g_lootDrops.add(cUnitTypeGoldPile);
    g_lootDrops.add(cUnitTypeGoldPile);
    g_lootDrops.add(cUnitTypeWoodPileLarge);

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

    g_trashZombieTypes.add(cUnitTypeMinion);
    g_trashZombieTypes.add(cUnitTypeTlacanexquimilliSPC);
    g_trashZombieTypes.add(cUnitTypeTartarianSpawn);
    g_trashZombieTypes.add(cUnitTypeTzitzimitl);
    g_trashZombieTypes.add(cUnitTypeMummy);

    g_purchaseableZombieTypes.add(cUnitTypeFireArcher);
    g_purchaseableZombieTypes.add(cUnitTypeHuskarl);
    g_purchaseableZombieTypes.add(cUnitTypeDestroyer);
    g_purchaseableZombieTypes.add(cUnitTypeShinobi);
    g_purchaseableZombieTypes.add(cUnitTypeOtontin);
    g_purchaseableZombieTypes.add(cUnitTypeGastraphetoros);

    g_purchaseableZombieTypes.add(cUnitTypeAnubite);
    g_purchaseableZombieTypes.add(cUnitTypeCyclops);
    g_purchaseableZombieTypes.add(cUnitTypeScarab);
    g_purchaseableZombieTypes.add(cUnitTypeMountainGiant);
    g_purchaseableZombieTypes.add(cUnitTypePetsuchos);

    g_purchaseableZombieTypes.add(cUnitTypeColossus);
    g_purchaseableZombieTypes.add(cUnitTypeFireGiant);
    g_purchaseableZombieTypes.add(cUnitTypeOnmyoji);
    g_purchaseableZombieTypes.add(cUnitTypeQuinametzin);

    g_purchaseableZombieTypes.add(cUnitTypeQiongQi);
    g_purchaseableZombieTypes.add(cUnitTypeOnmoraki);
    g_purchaseableZombieTypes.add(cUnitTypePolyphemus);
    g_purchaseableZombieTypes.add(cUnitTypeNidhogg);
    g_purchaseableZombieTypes.add(cUnitTypeMictlantecuhtli);

    g_bossTileUnitTypes.add(cUnitTypeSphinx);
    g_bossTileUnitTypes.add(cUnitTypeTroll);
    g_bossTileUnitTypes.add(cUnitTypeCentimanus);
    g_bossTileUnitTypes.add(cUnitTypeNemeanLion);
    g_bossTileUnitTypes.add(cUnitTypeHydra);
    g_bossTileUnitTypes.add(cUnitTypeChimera);

    g_otherZombieTypes.add(cUnitTypeCarnivora);
    g_otherZombieTypes.add(cUnitTypeInfestedDen);
    g_otherZombieTypes.add(cUnitTypeLargeScorpion);

    g_humanT1GodPowers.add(createGodPowerData(
                            cProtoPowerSentinel,
                            "Sentinel",
                            "Summons five stone guardians",
                            "resources\greek\static_color\god_powers\sentinel_icon.png",
                            60)
                        );

    g_humanT1GodPowers.add(createGodPowerData(
                            cProtoPowerSolarShield,
                            "Solar Shield",
                            "Targeted unit becomes temporarily nearly invulnerable and heals rapidly",
                            "resources\japanese\static_color\god_powers\solar_shield_icon.png",
                            60)
                        );

    g_humanT1GodPowers.add(createGodPowerData(
                            cProtoPowerTailwind,
                            "Tailwind",
                            "Improves the speed of ally units in an area",
                            "aztec\static_color\god_powers\tailwind_icon.png",
                            60)
                        );

    g_humanT1GodPowers.add(createGodPowerData(
                            cProtoPowerLullaby,
                            "Lullaby",
                            "Puts units to sleep",
                            "aztec\static_color\god_powers\lullaby_icon.png",
                            60)
                        );

    g_humanT2GodPowers.add(createGodPowerData(
                            cProtoPowerRestoration,
                            "Restoration",
                            "Heals friendly units and buildings",
                            "resources\greek\static_color\god_powers\restoration_icon.png",
                            120)
                        );

    g_humanT2GodPowers.add(createGodPowerData(
                            cProtoPowerBronze,
                            "Bronze",
                            "Increases the armor of ally units and buildings",
                            "resources\greek\static_color\god_powers\bronze_icon.png",
                            120)
                        );

    g_humanT2GodPowers.add(createGodPowerData(
                            cProtoPowerVanish,
                            "Vanish",
                            "Makes units invisible",
                            "resources\chinese\static_color\god_powers\vanish_icon.png",
                            120)
                        );

    g_humanT2GodPowers.add(createGodPowerData(
                            cProtoPowerForestProtection,
                            "Forest Protection",
                            "Protects a building by rooting nearby enemies in place and healing allies",
                            "chinese\static_color\god_powers\forest_protection_icon.png",
                            120)
                        );

    g_humanT2GodPowers.add(createGodPowerData(
                            cProtoPowerDivineSlash,
                            "Divine Slash",
                            "Damages enemy units and buildings in a line",
                            "resources\japanese\static_color\god_powers\divine_slash_icon.png",
                            120)
                        );

    g_humanT3GodPowers.add(createGodPowerData(
                            cProtoPowerUnderworldPassage,
                            "Underworld Passage",
                            "Allows rapid movement of troops from one spot to another",
                            "resources\greek\static_color\god_powers\underworld_passage_icon.png",
                            180)
                        );

    g_humanT3GodPowers.add(createGodPowerData(
                            cProtoPowerThunderBurst,
                            "Thunder Burst",
                            "Creates expanding shockwaves that damage and throw enemy units within range",
                            "japanese\static_color\god_powers\thunder_burst_icon.png",
                            180)
                        );

    g_humanT4GodPowers.add(createGodPowerData(
                            cProtoPowerLightningStorm,
                            "Lightning Storm",
                            "Many thunderbolts strike enemies in an area",
                            "resources\greek\static_color\god_powers\lightning_storm_icon.png",
                            240)
                        );

    g_humanT4GodPowers.add(createGodPowerData(
                            cProtoPowerPurge,
                            "Purge",
                            "Kills units of a type in an area",
                            "aztec\static_color\god_powers\purge_icon.png",
                            240)
                        );

    g_zombieT1GodPowers.add(createGodPowerData(
                            cProtoPowerCarnivora,
                            "Zombie Carnivora",
                            "Summon a Zombie Carnivora which deals moderate crush damage",
                            "resources\atlantean\player_color\units\carnivora_icon.png",
                            60)
                        );

    g_zombieT1GodPowers.add(createGodPowerData(
                            cProtoPowerDeconstruction,
                            "Wall Deconstruction",
                            "Deconstructs enemy walls and gates",
                            "atlantean\static_color\god_powers\deconstruction_icon.png",
                            60)
                        );

    g_zombieT1GodPowers.add(createGodPowerData(
                            cProtoPowerInfestation,
                            "Zombie Infestation",
                            "Summon a permanent Infested Nest which periodically spawns Large Scorpions",
                            "resources\aztec\static_color\god_powers\infestation_icon.png",
                            60)
                        );

    g_zombieT1GodPowers.add(createGodPowerData(
                            cProtoPowerWither,
                            "",
                            "Slows enemies and destroys Berry Bushes, trees, and Farms in the target area and prevents building construction",
                            "resources\greek_demeter\static_color\god_powers\wither_icon.png",
                            60)
                        );

    g_zombieT2GodPowers.add(createGodPowerData(
                            cProtoPowerDroughtLand,
                            "Drought Land",
                            "Makes enemy buildings and land units vulnerable and prevents building construction",
                            "resources\chinese\static_color\god_powers\drought_land_icon.png",
                            120)
                        );

    // g_zombieT2GodPowers.add(createGodPowerData(
    //                         cProtoPowerAncestors,
    //                         "Ancestors",
    //                         "Summons minions",
    //                         "resources\egyptian\static_color\god_powers\ancestors_icon.png",
    //                         120)
    //                     );

    g_zombieT2GodPowers.add(createGodPowerData(
                            cProtoPowerEclipse,
                            "Eclipse",
                            "Buffs myth units damage, abilities, speed and armor for a duration",
                            "resources\egyptian\static_color\god_powers\eclipse_icon.png",
                            120)
                        );

    g_zombieT2GodPowers.add(createGodPowerData(
                            cProtoPowerMeteorSPC,
                            "Comet",
                            "Rain down a single meteor that does bonus damage to walls",
                            "resources\egyptian\static_color\god_powers\meteor_icon.png",
                            120)
                        );

    g_zombieT3GodPowers.add(createGodPowerData(
                            cProtoPowerSmitingGust,
                            "Smiting Gust",
                            "Blows away units in the chosen direction",
                            "resources\japanese\static_color\god_powers\smiting_gust_icon.png",
                            180)
                        );

    g_zombieT4GodPowers.add(createGodPowerData(
                            cProtoPowerVolcano,
                            "Volcano",
                            "Summons a volcano that destroys walls and bombards enemies",
                            "resources\aztec\static_color\god_powers\volcano_icon.png",
                            240)
                        );
}