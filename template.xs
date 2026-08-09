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

    // mod/data/cardParameters.xs
    defineMapDefinition("int", "CardParameters", "", "cTypeToCardParameters");

    // mod/data/card.xs
    // mod/data/draw.xs
    // mod/data/bench.xs
    // mod/data/deck.xs
    // mod/data/player.xs

    // mod/shop/shop.xs
    // mod/data/cardParametersData.xs

    // mod/map/units.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}