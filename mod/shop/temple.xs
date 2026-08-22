void renderTemple(int p = 1){
    renderBench(p, SHOP_TYPE_TEMPLE);
    renderExitButton(p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    minimapSafeDisplay(p, drawPosx - 0.015, drawPosYStart + 0.1, 
                        getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled);

    g_shopNeedsRefresh[p] = false;
}

void createTempleCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.isNull() || (currCard.getUuid() == g_selectedUUIDs[p]) == false || currCard.isIdentified() == false) { return; }
    if (currCard.isDeployed()) {
        trChatSendToPlayer(p, p, "Unit must be withdrawn first to be rerolled.");
        trUnitSelectClear();
        trUnitSelectByID(currCard.getDeployedUnitID());
        trUnitHighlight(8.0, true);
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
            g_shop.rerollRarity(p, parameters.ints[0]);
        }
    );
    minimapSafeDisplay(p, posX, btnPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
    minimapSafeDisplay(p, posX, btnPosY + 0.035, "REROLL\nRARITY");
}

void openTemple(int p = 1){
    enterUiSystem(p);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    g_selectedUUIDs[p] = -1; // Deselect card
    g_shop.m_shopTypeOpened[p] = SHOP_TYPE_TEMPLE;
    renderTemple(p);
    postEnterUiSystem(p);
    if (trCurrentPlayer() == p){
        trSoundPlayPaused("ui\latch.wav");
    }
}