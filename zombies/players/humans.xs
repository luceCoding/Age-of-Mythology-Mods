void initializeHumans(){
    int tempID = trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVillagerAtlanteanHero), g_bspHumanSpawnLocation.x, g_bspHumanSpawnLocation.y, g_bspHumanSpawnLocation.z, 0, 1);
    int tempID2 = trUnitCreateForced(kbProtoUnitGetName(cUnitTypeVillagerAtlanteanHero), g_bspHumanSpawnLocation.x, g_bspHumanSpawnLocation.y, g_bspHumanSpawnLocation.z, 0, 2);
    g_humanUnitIDs.add(tempID);
    g_humanUnitIDs.add(tempID2);
    g_humanUnitCount = g_humanUnitCount + 2;
}