class YSearch {
    bool initialised = false;

    void initialise() {
        trSetAutoResetRecentUnits(false);
        initialised = true;
    }

    void process(void(int) handler = [](int unitId = 0) -> void {}) {
        if (!initialised) {
            initialise();
        }
        int[] recent = trGetRecentUnits();
        trResetRecentUnits();
        for (int i = 0; i < recent.size(); i++) {
            trUnitSelectClear();
            trUnitSelectByID(recent[i]);
            handler(recent[i]);
        }
    }
};

YSearch ySearch;

int Search_lastTime = 0;
bool Search_conditionToRun(int lastTime = 0) {
return true;
}