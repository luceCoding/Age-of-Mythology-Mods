void renderArmory(int p = 1){
    renderBench(p, SHOP_TYPE_ARMORY);
    renderExitButton(p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    minimapSafeDisplay(p, drawPosx - 0.015, drawPosYStart + 0.1, 
                        getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled);
}

void createArmoryCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.isNull() || (currCard.getUuid() == g_selectedUUIDs[p]) == false || currCard.isIdentified() == false) { return; }
    if (currCard.isDeployed()) {
        trChatSendToPlayer(p, p, "Unit must be withdrawn first to be upgraded.");
        selectSingle();
        trUnitHighlight(8.0, true);
        trSoundsetPlayPlayer(p, "PopCapHit");
        return;
    }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    int count = currCard.getNumberOfSockets();
    if (count > 0) {
        float spacingX = 0.12; // Horizontal distance between button centers
        float startX = posX - (((count - 1) * spacingX) * 0.5);

        for (int i = 0; i < count; i++) {
            float currentX = startX + (i * spacingX);
            Parameters cardParams = createParametersCopy(params);
            int uuid = currCard.getUuid();
            cardParams.ints[0] = uuid;
            cardParams.ints[1] = i;
            minimapSafeClickable(p, 
                                currentX, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                                    g_shop.rerollUpgrade(p, parameters.ints[0], parameters.ints[1]);
                                }
            );
            createButton(p, currentX, btnPosY, "UPGRADE " + (i + 1));
        }
    }
}

void openArmory(int p = 1){
    openShopType(p, SHOP_TYPE_ARMORY);
}