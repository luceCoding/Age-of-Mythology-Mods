const int configMapTileX = 160;
const int configMapTileZ = 160;
//// common/nottud.xs
//// common/schedulers.xs
//// common/collections/hashMap.xs
//// common/collections/hashSet.xs

void generate()
{
    // common/utils.xs
    // dota/globals.xs
    // dota/localization/english.xs
    // dota/mutables.xs
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
    createTypedScheduler("highFreqScheduler", buildStringTypeArray(), 25, 32);
    createTypedScheduler("highFreqSchedulerWithIntUnitDeletionTracker", buildStringTypeArray("IntUnitDeletionTracker"), 25, 2);

    createTypedScheduler("midFreqScheduler", buildStringTypeArray(), 500, 2);
    createTypedUnitScheduler("midFreqSchedulerWithVector", buildStringTypeArray("Vector"), 500, 2);

    createTypedScheduler("lowFreqScheduler", buildStringTypeArray(), 1000, 256);
    createTypedScheduler("lowFreqSchedulerWithIntInt", buildStringTypeArray("Int", "Int"), 1000, 256);

    defineHashMapDefinition("string", "float", "0.0", "");
    defineHashMapDefinition("int", "int", "-1", "NegOne");
    defineHashMapDefinition("int", "int", "cMinInt", "cMinInt");
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
    
    // dota/common/rng.xs
    
    // dota/shop/level.xs
    // dota/data/cardParameters.xs

    defineHashMapDefinition("int", "CardParameters", "", "");

    // dota/map/teams.xs

    // dota/data/utils.xs
    // dota/data/card.xs
    // dota/data/buffs.xs
    // dota/data/synergies.xs
    // dota/data/player.xs
    // dota/data/bench.xs
    // dota/data/deck.xs
    // dota/data/draw.xs

    // dota/proto/utils.xs
    // dota/income/income.xs

    // dota/shop/utils.xs
    // dota/shop/shop.xs
    // dota/shop/armory.xs
    // dota/shop/forge.xs
    // dota/shop/shrine.xs
    // dota/shop/temple.xs
    // dota/shop/refresh.xs
    // dota/shop/commands.xs
    // dota/shop/respawn.xs

    // dota/map/utils.xs
    // common/attachment/attachments.xs
    // dota/map/lane.xs
    // dota/map/base.xs
    // dota/map/objectives.xs

    // dota/proto/protoUnits.xs

    // dota/map/roads.xs
    // dota/map/trees.xs
    // dota/map/creepCamp.xs
    // dota/map/camps.xs
    // dota/map/capture.xs
    // dota/map/boss.xs
    // dota/map/colosseum.xs
    // dota/map/cave.xs

    // dota/factory/utils.xs
    // dota/factory/deckFactory.xs
    // dota/factory/synergyFactory.xs

    // dota/proto/postBalance.xs

    // dota/victory/victory.xs

    // dota/archetype/archetype.xs
    // dota/archetype/utils.xs
    // dota/archetype/archetypeUI.xs

    // dota/triggers.xs

    rmSetProgress(1.0);
}