void spawnBossTileUnits() {
    for (int i = 0; i < g_bossTileIds.size(); i++) {
        int unitId = g_bossTileIds[i];
        vector position = kbUnitGetTruePosition(unitId);
        int unitType = g_bossTileUnitTypes[xsRandInt(0, min(g_bossTileUnitTypes.size() - 1, g_dayNumber))];
        trUnitCreate(kbProtoUnitGetName(unitType), position.x, position.y, position.z, xsRandFloat(0, 359), 0, true);
    }
}

void applyDayNightLighting(int transitionSeconds = 0) {
    if (g_isNight) {
        trSetLighting("night", transitionSeconds);
        trChatSend(0, "Night is upon us!\n" + toForwardSlash(displayCompensatedIcon(128, 128, "resources/egyptian/static_color/god_powers/eclipse_icon.png")));
        buffZombies();
    } else {
        trSetLighting("default", transitionSeconds);
        trChatSend(0, "Day is upon us!\n" + toForwardSlash(displayCompensatedIcon(128, 128, "resources/chinese/static_color/technologies/chasing_the_sun_icon.png")));
        debuffZombies();
        spawnBossTileUnits();
    }
}

int getCurrentPhaseDurationMS() {
    return g_isNight ? g_nightDurationMS : g_dayDurationMS;
}

// Counts down natively from the phase length to 0; restarted on every phase change.
void updateDayNightCounter() {
    trCounterAbort("dayNight");
    string counterText = "Day " + g_dayNumber + " - Night begins in";
    if (g_isNight) {
        counterText = "Day " + g_dayNumber + " - Day begins in";
    }
    trCounterAddTime("dayNight", getCurrentPhaseDurationMS() / 1000, 0, counterText);
}

// Starts the cycle using g_dayDurationMS and g_nightDurationMS. Call once.
void startDayAndNightCycle(bool startAtNight = false) {
    if (g_dayCycleActive) {
        return;
    }
    g_isNight = startAtNight;
    g_dayNumber = 1;
    g_dayCycleActive = true;
    g_phaseEndTimeMS = xsGetTimeMS() + getCurrentPhaseDurationMS();
    applyDayNightLighting();
    updateDayNightCounter();
    lowFreqScheduler.add(1000, [](int iteration = 1) -> bool {
        if (g_dayCycleActive == false) {
            return false;
        }
        if (xsGetTimeMS() >= g_phaseEndTimeMS) {
            g_isNight = (g_isNight == false);
            if (g_isNight == false) {
                g_dayNumber = g_dayNumber + 1;
            }
            g_phaseEndTimeMS = g_phaseEndTimeMS + getCurrentPhaseDurationMS();
            // Fade across the entire new phase.
            applyDayNightLighting(getCurrentPhaseDurationMS() / 1000);
            updateDayNightCounter();
        }
        return true;
    });
}

void stopDayAndNightCycle() {
    g_dayCycleActive = false;
}