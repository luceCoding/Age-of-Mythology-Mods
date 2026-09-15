class YSearch {
    void init() {
        trSetAutoResetRecentUnits(false);
    }

    void process(void(int) handler = [](int unitId = 0) -> void {}) {
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