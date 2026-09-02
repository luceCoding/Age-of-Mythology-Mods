void renderShrine(int p = 1){
    renderBench(p, SHOP_TYPE_SHRINE);
    renderExitButton(p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    minimapSafeDisplay(p, drawPosx - 0.015, drawPosYStart + 0.1, 
                        getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled);
}

void createShrineCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.isNull() || (currCard.getUuid() == g_selectedUUIDs[p]) == false) { return; }
    if (currCard.isIdentified()) {
        trChatSendToPlayer(p, p, "Card is already identified.");
        trSoundsetPlayPlayer(p, "PopCapHit");
        return;
    }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    Parameters cardParams = createParametersCopy(params);
    int uuid = currCard.getUuid();
    cardParams.ints[0] = uuid;

    minimapSafeClickable(p, 
                        posX, btnPosY + 0.035, 0.1, 0.055,
                        "",
                        cardParams,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.identify(p, parameters.ints[0]);
        }
    );
    createButton(p, posX, btnPosY, "IDENTIFY");
}

void openShrine(int p = 1){
    openShopType(p, SHOP_TYPE_SHRINE);
}