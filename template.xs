//// mod/globals.xs
//// common/nottud.xs
//// common/collections/hashMap.xs

void generate()
{
    // mod/globals.xs
    // mod/mutables.xs
    // common/logs.xs
    // common/uuid.xs
    // common/math.xs
    // common/strings.xs

    rmSetProgress(0.0);

    rmSetMapSize(configMapTileX, configMapTileZ);
    rmInitializeLand(cTerrainDefault, 5.00);

    rmTriggerAddScriptLine("class IntUnitDeletionTracker {");
        rmTriggerAddScriptLine("int[] controlUnits = default;");
        rmTriggerAddScriptLine("int[] units = default;");
    rmTriggerAddScriptLine("};");

    createTypedScheduler("scheduler", buildStringTypeArray());
    createTypedScheduler("schedulerWithIntInt", buildStringTypeArray("Int", "Int"));
    createTypedScheduler("schedulerWithIntUnitDeletionTracker", buildStringTypeArray("IntUnitDeletionTracker"));
    createTypedUnitScheduler("unitScheduler", buildStringTypeArray());
    createTypedUnitScheduler("unitSchedulerWithVector", buildStringTypeArray("Vector"));

    defineHashMapDefinition("string", "float", "0.0", "");
    defineHashMapDefinition("string", "int", "-1", "");
    defineHashMapDefinition("int", "int", "cMinInt", "");

    // common/ui/ui1.xs
    //// common/ui/ui2.xs
    // common/ui/ui3.xs
    // common/ui/ui4.xs
    
    // common/attachment/attachments.xs
    // common/search.xs
    // common/terrain.xs
    // common/sound.xs
    // common/unitCache.xs
    
    // mod/common/rng.xs
    
    // mod/shop/level.xs
    // mod/data/cardParameters.xs

    defineHashMapDefinition("string", "CardParameters", "", "");

    // mod/map/teams.xs

    // mod/data/utils.xs
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
    // mod/shop/respawn.xs

    // mod/map/utils.xs
    // mod/map/lane.xs
    // mod/map/base.xs
    // mod/map/objectives.xs
    // mod/map/units.xs
    // mod/map/roads.xs
    // mod/map/trees.xs
    // mod/map/creepCamp.xs
    // mod/map/camps.xs
    // mod/map/capture.xs
    // mod/map/boss.xs
    // mod/map/colosseum.xs
    // mod/map/cave.xs

    // mod/income/income.xs

    // mod/factory/deckFactory.xs
    // mod/factory/synergyFactory.xs

    // mod/map/postBalance.xs

    // mod/victory/victory.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}