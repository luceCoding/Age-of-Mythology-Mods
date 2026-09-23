const int configMapTileX = 160;
const int configMapTileZ = 160;
//// common/nottud.xs
//// common/schedulers.xs
//// common/collections/hashMap.xs
//// common/collections/hashSet.xs

void generate()
{
    // mod/globals.xs
    // mod/localization/english.xs
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

    // UI schedulers
    createTypedScheduler("highFreqScheduler", buildStringTypeArray(), 25, 2);
    createTypedScheduler("highFreqSchedulerWithIntUnitDeletionTracker", buildStringTypeArray("IntUnitDeletionTracker"), 25, 2);

    createTypedScheduler("midFreqScheduler", buildStringTypeArray(), 500, 2);
    createTypedUnitScheduler("midFreqSchedulerWithVector", buildStringTypeArray("Vector"), 500, 2);

    createTypedScheduler("lowFreqScheduler", buildStringTypeArray(), 1000, 256);
    createTypedScheduler("lowFreqSchedulerWithIntInt", buildStringTypeArray("Int", "Int"), 1000, 256);

    defineHashMapDefinition("string", "float", "0.0", "");
    defineHashMapDefinition("string", "int", "-1", "");
    defineHashMapDefinition("int", "int", "cMinInt", "");
    defineSetDefinition("int", "");

    // common/ui/ui1.xs
    createTypedScheduler("highFreqSchedulerWithParameters", buildStringTypeArray("Parameters"), 25, 2);
    //// common/ui/ui2.xs
    // common/ui/ui3.xs
    // common/ui/ui4.xs
    
    createTypedScheduler("midFreqSchedulerWithParameters", buildStringTypeArray("Parameters"), 500, 2);

    // common/listeners/onCreationListener.xs

    // common/kbQueries.xs

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
    // common/attachment/attachments.xs
    // mod/map/lane.xs
    // mod/map/base.xs
    // mod/map/objectives.xs

    // mod/proto/utils.xs
    // mod/proto/protoUnits.xs

    // mod/map/roads.xs
    // mod/map/trees.xs
    // mod/map/creepCamp.xs
    // mod/map/camps.xs
    // mod/map/capture.xs
    // mod/map/boss.xs
    // mod/map/colosseum.xs
    // mod/map/cave.xs

    // mod/income/income.xs

    // mod/factory/utils.xs
    // mod/factory/deckFactory.xs
    // mod/factory/synergyFactory.xs

    // mod/proto/postBalance.xs

    // mod/victory/victory.xs

    // mod/triggers.xs

    rmSetProgress(1.0);
}