void renderArmory(ref UiSystem system, int p = 1){
    renderBench(system, p, SHOP_TYPE_ARMORY);
    renderExitButton(system, p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    minimapSafeDisplay(system, drawPosx - 0.015, drawPosYStart + 0.1, 
                        getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled);

    g_shopNeedsRefresh[p] = false;
}

void createArmoryCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.isNull() || (currCard.getUuid() == g_selectedUUIDs[p]) == false || currCard.canSocket() == false || currCard.isIdentified() == false) { return; }
    if (currCard.isDeployed()) {
        trChatSendToPlayer(p, p, "Unit must be withdrawn first to be socketed.");
        trSoundsetPlayPlayer(p, "PopCapHit");
        return;
    }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    Parameters cardParams = createParametersCopy(params);
    int uuid = currCard.getUuid();
    cardParams.ints[0] = uuid;

    minimapSafeClickable(system, 
                        posX, btnPosY + 0.035, 0.1, 0.055,
                        "",
                        cardParams,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.addSocket(p, parameters.ints[0]);
        }
    );
    createButton(system, posX, btnPosY, "ADD SOCKET");
}

void openArmory(int p = 1){
    UiSystem system = uiSystemArray[p];
    system.enter(false, true, 503);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    g_selectedUUIDs[p] = -1; // Deselect card
    g_shop.m_shopTypeOpened[p] = SHOP_TYPE_ARMORY;
    renderArmory(system, p);
    uiSystemArray[p] = system;
    trSoundsetPlayPlayer(p, "UI_Latch");
}