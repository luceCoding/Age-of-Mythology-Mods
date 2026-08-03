include "lib/rm_core.xs";

void generate()
{
    rmSetProgress(0.0);
    rmSetMapSize(82,82);
    rmInitializeLand(cTerrainDefault, 5.00);

    // mod/config.xs
    // mod/utils/map.xs
    // common/ui.xs
    // mod/data/card.xs
    // mod/data/hand.xs
    // mod/data/deck.xs
    // mod/data/player.xs
    // mod/triggers.xs

    rmSetProgress(1.0);
}