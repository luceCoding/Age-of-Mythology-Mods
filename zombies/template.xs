const int configMapTileX = 159;
const int configMapTileZ = 159;
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

    createTypedScheduler("lowFreqScheduler", buildStringTypeArray(), 1000, 256);
    createTypedScheduler("lowFreqSchedulerWithIntInt", buildStringTypeArray("Int", "Int"), 1000, 256);

    // zombies/mapGen/sockets.xs
    // zombies/mapGen/tile.xs
    // zombies/mapGen/waveFunctionCollapse.xs
    // zombies/mapGen/bsp.xs
    // zombies/mapGen/tiles/dungeonDefaultTile.xs
    // zombies/mapGen/tiles/graveyardTiles.xs
    // zombies/mapGen/tileFactory.xs

    // zombies/players/humans.xs
    // zombies/players/zombies.xs
    // zombies/players/teams.xs

    rmSetProgress(0.0);

    rmSetMapSize(configMapTileX, configMapTileZ);
    rmInitializeLand(cTerrainHadesRoad2, configMapBaseHeight);

    // zombies/proto/protoUnits.xs
    // zombies/triggers.xs

    rmSetProgress(1.0);
}