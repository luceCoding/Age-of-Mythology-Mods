//// mod/config.xs
//// common/nottud.xs

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

    // mod/data/cardParameters.xs
    defineMapDefinition("string", "CardParameters", "", "ProtoNameToCardParameters");

    // mod/data/card.xs
    // mod/data/player.xs
    // mod/data/bench.xs
    // mod/data/deck.xs
    // mod/data/draw.xs

    // mod/shop/shop.xs
    // mod/data/cardParametersData.xs

    // mod/map/units.xs
    // mod/shop/commands.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}