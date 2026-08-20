int[] g_selectedUUIDs = default;
bool[] g_shopNeedsRefresh = default;
float g_timeMSGameStarted = 0.0;

const int MAX_SYNERGIES = 9;

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

const int relativityABSOLUTE = 0;
const int relativityASSIGN = 1;
const int relativityPERCENT = 2;
const int relativityBasePERCENT = 3;

int g_shrineShopCost = 10;
int g_templeShopCost = 10;
int g_armoryShopCost = 10;
int g_forgeShopCost = 10;