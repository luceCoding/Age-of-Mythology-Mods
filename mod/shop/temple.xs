Parameters getParametersCopy(){
    Parameters params;
    return params;
}

void renderPrayerBench(int p = 1) {
    int totalIcons = MAX_SYNERGIES;
    if (totalIcons <= 0) return;

    float centerX = 0.0;
    float centerY = 0.0;
    float WxH = 0.05;
    float stepX = 0.1;
    float stepY = 0.2;
    int iconSize = 64;
    int maxPerRow = 7;

    // Balance rows (e.g. 8 items -> 2 rows of 4)
    int numRows = (totalIcons + maxPerRow - 1) / maxPerRow;
    int itemsPerRow = (totalIcons + numRows - 1) / numRows;

    // Offset startY so the entire block is centered vertically around centerY (0.0)
    float startY = centerY + (xsIntToFloat(numRows - 1) * stepY * 0.5);

    for (int i = 0; i < totalIcons; i++) {
        int row = i / itemsPerRow;
        int col = i % itemsPerRow;

        // Calculate exact item count in this specific row for horizontal centering
        int remainingItems = totalIcons - (row * itemsPerRow);
        int countInThisRow = itemsPerRow;
        if (remainingItems < itemsPerRow) {
            countInThisRow = remainingItems;
        }

        // Offset startX per row so even incomplete rows center horizontally around centerX (0.0)
        float startX = centerX - (xsIntToFloat(countInThisRow - 1) * stepX * 0.5);

        float posX = startX + (xsIntToFloat(col) * stepX);
        float posY = startY - (xsIntToFloat(row) * stepY);

        float iconSelected = 1.0;
        if (g_selectedSynergy[p] == i){
            iconSelected = 1.25;
        }

        SynergyData synergy = g_synergies[i];
        string costText = getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " <color=0.729,0.557,0.137,0,0,0>" + g_synergyPityCosts[i] + "</color>";
        minimapSafeDisplay(p, posX, posY + (0.08 * iconSelected), costText);
        string title = replaceText(synergy.m_rolloverName, "Synergy: ", "");
        minimapSafeDisplay(p, posX, posY + (0.06 * iconSelected), title);
        Parameters params = getParametersCopy();
        params.ints.add(i);
        minimapSafeClickableWithHover(p, posX, posY, WxH * iconSelected, WxH * iconSelected, 
            getIconPathFormat(synergy.m_icon, iconSize * iconSelected),
            synergy.m_rolloverName,
            synergy.getDescription(), 
            params,
            [](int p = 1, ref Parameters parameters) -> void {
                g_selectedSynergy[p] = parameters.ints[0];
                refreshShop(p);
            }
        );
        if (g_selectedSynergy[p] == i){
            Parameters params2 = getParametersCopy();
            params2.ints.add(i);
            params2.strings.add(title);
            minimapSafeClickable(p, posX, posY - 0.07, WxH * 2, WxH * 1.25, 
                                "",
                                params2,
                                [](int p = 1, ref Parameters parameters) -> void {
                    if (purchase(g_synergyPityCosts[parameters.ints[0]], p)){
                        g_prayerSynergy[p] = parameters.ints[0];
                        g_synergyPityCosts[parameters.ints[0]] = g_synergyPityCosts[parameters.ints[0]] + TEMPLE_COST_INCREMENT;
                        trChatSendToPlayer(p, p, "Your pity draw is set to " + parameters.strings[0] + " synergy. Only one can be set at a given time.");
                        refreshShop(p);
                    }
                }
            );
            createButton(p, posX, posY - 0.1, "BUY PITY");
        }
    }
}

void renderTemple(int p = 1){
    renderPrayerBench(p);
    renderExitButton(p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    minimapSafeDisplay(p, drawPosx - 0.015, drawPosYStart + 0.1, 
                        getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled);
}

void createTempleCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.isNull() || (currCard.getUuid() == g_selectedUUIDs[p]) == false || currCard.isIdentified() == false) { return; }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    Parameters cardParams = cardParameterstoParametersCopy(params);
    cardParams.ints[0] = currCard.getUuid();

    minimapSafeClickable(p, 
                        posX, btnPosY + 0.035, 0.1, 0.055,
                        "",
                        cardParams,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.rerollRarity(p, parameters.ints[0]);
        }
    );
    minimapSafeDisplay(p, posX, btnPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
    minimapSafeDisplay(p, posX, btnPosY + 0.035, "REROLL\nRARITY");
}

void openTemple(int p = 1){
    openShopType(p, SHOP_TYPE_TEMPLE);
}