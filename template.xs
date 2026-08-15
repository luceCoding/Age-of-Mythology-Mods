//// mod/config.xs
//// common/nottud.xs
//// common/collections/hashmap.xs

void generate()
{
    rmSetProgress(0.0);

    rmSetMapSize(configMapTileX, configMapTileZ);
    rmInitializeLand(cTerrainDefault, 5.00);

    // common/logs.xs
    // mod/config.xs
    // common/ui.xs
    // common/search.xs
    
    // mod/common/rng.xs

    // mod/data/globals.xs

    // mod/shop/level.xs
    // mod/data/cardParameters.xs

    defineHashMapDefinition("string", "CardParameters", "", "");
    defineHashMapDefinition("int", "int", "", "");
    defineHashMapDefinition("string", "int", "0", "");

    // mod/data/card.xs
    // mod/data/buffs.xs
    // mod/data/synergies.xs
    // mod/data/player.xs
    // mod/data/bench.xs
    // mod/data/deck.xs
    // mod/data/draw.xs

    // mod/shop/shop.xs
    // mod/data/cardParametersData.xs

    // mod/map/teams.xs
    // mod/map/units.xs
    // mod/shop/commands.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}