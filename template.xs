//// mod/globals.xs
//// common/nottud.xs
//// common/collections/hashMap.xs
//// common/collections/hashSet.xs

void generate()
{
    rmSetProgress(0.0);

    rmSetMapSize(configMapTileX, configMapTileZ);
    rmInitializeLand(cTerrainDefault, 5.00);

    rmTriggerAddScriptLine("class IntUnitDeletionTracker {");
        rmTriggerAddScriptLine("int[] controlUnits = default;");
        rmTriggerAddScriptLine("int[] units = default;");
    rmTriggerAddScriptLine("};");

    createTypedScheduler("scheduler", buildStringTypeArray());
    createTypedScheduler("schedulerWithIntUnitDeletionTracker", buildStringTypeArray("IntUnitDeletionTracker"));
    createTypedUnitScheduler("unitScheduler", buildStringTypeArray());

    // mod/globals.xs
    // common/logs.xs
    // common/math.xs
    // common/ui.xs
    // common/search.xs
    
    // mod/common/rng.xs

    // mod/shop/level.xs
    // mod/data/cardParameters.xs

    defineHashMapDefinition("string", "CardParameters", "", "");
    defineHashMapDefinition("string", "int", "0", "");

    // mod/data/card.xs
    // mod/data/buffs.xs
    // mod/data/synergies.xs
    // mod/data/player.xs
    // mod/data/bench.xs
    // mod/data/deck.xs
    // mod/data/draw.xs

    // mod/shop/utils.xs
    // mod/shop/shop.xs
    // mod/shop/armory.xs
    // mod/shop/forge.xs
    // mod/shop/shrine.xs
    // mod/shop/temple.xs
    // mod/shop/refresh.xs
    // mod/shop/commands.xs
    // mod/data/cardParametersData.xs

    // mod/map/utils.xs
    // mod/map/lane.xs
    // mod/map/base.xs
    // mod/map/objectives.xs
    // mod/map/teams.xs
    // mod/map/units.xs
    // mod/map/terrain.xs
    // mod/map/camps.xs

    // mod/income/income.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}