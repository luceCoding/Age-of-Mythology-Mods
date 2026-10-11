const int configMapTileX = 128;
const int configMapTileZ = 128;
const int configMapBaseHeight = 4;

//// common/nottud.xs
//// common/schedulers.xs
//// common/collections/hashMap.xs
//// common/collections/hashSet.xs

void generate()
{
    // zombies/globals.xs

    // common/utils.xs
    // common/logs.xs
    // common/uuid.xs
    // common/math.xs
    // common/strings.xs

    createTypedScheduler("highFreqScheduler", buildStringTypeArray(), 25, 32);
    defineHashMapDefinition("int", "int", "cMinInt", "cMinInt");
    // common/listeners/onCreationListener.xs

    // zombies/mapGen/sockets.xs
    // zombies/mapGen/tile.xs
    // zombies/mapGen/waveFunctionCollapse.xs
    // zombies/mapGen/tileFactory.xs

    rmSetProgress(0.0);

    rmSetMapSize(configMapTileX, configMapTileZ);
    rmInitializeLand(cTerrainDefault, configMapBaseHeight);

    // zombies/proto/protoUnits.xs
    // zombies/triggers.xs

    rmSetProgress(1.0);
}