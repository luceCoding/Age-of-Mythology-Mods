const int configMapTileX = 128;
const int configMapTileZ = 128;
const int configMapBaseHeight = 4;
const float configMapWaterLevel = -2.0;
const float configMapWaterDepth = 3.0;

int[] g_selectedUUIDs = default;
float g_timeMSGameStarted = 0.0;

int g_uuidCardCounter = 0;
const int MAX_SOCKETS_PER_CARD = 3;
const int MAX_SYNERGIES = 9;
const int HERO_WAVE = 5;

const int SYNERGY_INDEX_INFANTRY = 0;
const int SYNERGY_INDEX_RANGED = 1;
const int SYNERGY_INDEX_CAVALRY = 2;
const int SYNERGY_INDEX_MYTH = 3;
const int SYNERGY_INDEX_HERO = 4;
const int SYNERGY_INDEX_HEALER = 5;
const int SYNERGY_INDEX_SIEGE = 6;
const int SYNERGY_INDEX_BUILDING = 7;
const int SYNERGY_INDEX_SOLDIER = 8;
const int SYNERGY_INDEX_FLYING = 9;
const int SYNERGY_INDEX_TITAN = 10;

const int puFIELD_HITPOINTS = 0;
const int puFIELD_SPEED = 1;
const int puFIELD_LOS = 2;
const int puFIELD_LIFESPAN = 8;
const int puFIELD_RECHARGE = 9;
const int puFIELD_SHIELDS = 12;
const int puFIELD_HACK_ARMOR = 13;
const int puFIELD_PIERCE_ARMOR = 14;
const int puFIELD_CRUSH_ARMOR = 15;
const int puFIELD_HP_REGEN = 17;
const int puFIELD_GP_BLOCK = 22;
const int puFIELD_OBSTRUCTION_X = 23;
const int puFIELD_OBSTRUCTION_Z = 24;
const int puFIELD_SHIELD_REGEN = 26;

const int puFIELD_ACTION_RANGE = 0;
const int puFIELD_MIN_RANGE = 1;
const int puFIELD_ACTION_ALL_DMG = 2;
const int puFIELD_ACTION_DMG_AREA = 3;
const int puFIELD_ACTION_RATE_OF_FIRE = 4;
const int puFIELD_ACTION_N_PROJECTILES = 8;
const int puFIELD_ACTION_HACK = 13;
const int puFIELD_ACTION_PIERCE = 14;
const int puFIELD_ACTION_CRUSH = 15;
const int puFIELD_ACTION_DIVINE = 16;
const int puFIELD_ACTION_DISPLAY_PROJ = 18;

const int puFIELD_ACTION_UNITTYPE_DMG_BONUS = 0;

const int relativityABSOLUTE = 0;
const int relativityASSIGN = 1;
const int relativityPERCENT = 2;
const int relativityBasePERCENT = 3;

const int UPGRADE_HACK_ARMOR = 0;
const int UPGRADE_PIERCE_ARMOR = 1;
const int UPGRADE_CRUSH_ARMOR = 2;
const int UPGRADE_HITPOINTS = 3;
const int UPGRADE_SHIELDS = 4;
const int UPGRADE_SPEED = 5;
const int UPGRADE_HP_REGEN = 6;
const int UPGRADE_HACK_ATTACK = 7;
const int UPGRADE_PIERCE_ATTACK = 8;
const int UPGRADE_CRUSH_ATTACK = 9;

const int TOTAL_AGES = 5;
const float SELL_MULTIPLIER = 0.8;
const float UI_LEFT_BUFFER = 50;
const int config_MAX_DRAWN_CARDS = 5;
const int MAX_CARDS_IN_BENCH = 20;

const int SHOP_TYPE_CLOSED = -2;
const int DEFAULT_SHOP_TYPE = -1;
const int SHOP_TYPE_FORGE = 0;
const int SHOP_TYPE_SHRINE = 1;
const int SHOP_TYPE_ARMORY = 2;
const int SHOP_TYPE_TEMPLE = 3;

const int SHOP_COST_REDUCTION = 5;
const int SHOP_COST_REDUCTION_MS_INTERVAL = 30000;
int g_shrineShopCost = 10;
int g_templeShopCost = 10;
int g_armoryShopCost = 10;
int g_forgeShopCost = 10;

const float GOLDPILE_LIFESPAN = 20.0;

const float T1_CRATE_SPAWN_TIME = 90.0;
const float T2_CRATE_SPAWN_TIME = 120.0;
const float T3_CRATE_SPAWN_TIME = 150.0;

const float T1_CAMP_SPAWN_TIME = 120.0;
const float T2_CAMP_SPAWN_TIME = 180.0;
const float T3_CAMP_SPAWN_TIME = 240.0;

const int STARTING_GOLD = 300;
const float CATCHUP_GOLD_DIFF = 0.9;
const float CATCHUP_GOLD_MECHANIC = 1.1;
const float SHARED_GOLD_COEFFICIENT = 0.25;

const int RESPAWN_TIME_MS_BASE = 5000;

string[] g_shopTypes = default;
string[] g_roadTypes = default;
string[] g_treeTypes = default;
string[] g_creepCampPlaceholderTypes = default;
string[] g_creepCampTypes = default;

void initializeGlobals(){
    g_shopTypes = new string(4, "");
    g_shopTypes[SHOP_TYPE_FORGE] = "DwarvenForge";
    g_shopTypes[SHOP_TYPE_ARMORY] = "DwarvenArmory";
    g_shopTypes[SHOP_TYPE_TEMPLE] = "TempleOfTheGods";
    g_shopTypes[SHOP_TYPE_SHRINE] = "ShrineJapanese";

    g_roadTypes.add("Greek Road 1"); // first element is always primary road
    g_roadTypes.add("Greek Road 2");
    g_roadTypes.add("Greek Road 3");

    g_treeTypes.add("TreeOak");
    g_treeTypes.add("TreeOakAutumn");
    g_treeTypes.add("TreeOakRound");
    g_treeTypes.add("TreePine");
    g_treeTypes.add("TreePineDead");

    g_creepCampPlaceholderTypes.add("Tent");
    g_creepCampPlaceholderTypes.add("Lure");
    g_creepCampPlaceholderTypes.add("RocTent");

    g_creepCampTypes.add("Satyr");
    g_creepCampTypes.add("NemeanLion");
    g_creepCampTypes.add("Argus");
}