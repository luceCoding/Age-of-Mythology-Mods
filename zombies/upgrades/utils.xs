void registerRemovalOfRelicMisc(int p = -1){
    g_OnCreationListener.register(p, cUnitTypeRelicMonkey, true, [](int unitId = -1) -> void {});
    g_OnCreationListener.register(p, cUnitTypePegasus, true, [](int unitId = -1) -> void {});
    g_OnCreationListener.register(p, cUnitTypeRelicGoldenLion, true, [](int unitId = -1) -> void {});
}