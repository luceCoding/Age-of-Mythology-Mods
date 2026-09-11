include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";
include "data/cardParameters.xs";

IntToIntHashMap ShopTypeToUnitIDMap;

class Shop {
    DeckData[] m_decks = default;
    DrawData[] m_currDraws = default;
    BenchData[] m_benches = default;
    int[] m_totalShopExp = default;
    int[] m_currShopLevel = default;
    int[] m_shopTypeOpened = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_currDraws = new DrawData(cNumberPlayers - 1);
        m_benches = new BenchData(cNumberPlayers - 1);
        g_selectedUUIDs = new int(cNumberPlayers - 1, -1);
        m_totalShopExp = new int(cNumberPlayers - 1, 0);
        m_currShopLevel = new int(cNumberPlayers - 1, 0);
        m_shopTypeOpened = new int(cNumberPlayers - 1, DEFAULT_SHOP_TYPE);
    }

    int getDrawCost(int p = 0){
        return (m_currShopLevel[p] * 10) + 10;
    }

    int getBuyXPCost(int p = 0){
        return getDrawCost(p) * BUY_XP_COST_MULTIPLIER;
    }

    void addCardIntoDeck(ref CardData card, int deckIndex = -1){
        if (deckIndex < 0 || deckIndex >= TOTAL_AGES) {
            CardParameters params = card.getCardParameters();
            deckIndex = params.getAge();
        }

        DeckData deck = m_decks[deckIndex];
        deck.addCard(card);
        m_decks[deckIndex] = deck;
    }

    int getCost(ref CardData card, int p = 0){
        CardParameters params = card.getCardParameters();
        int cost = estimateCardValue(card);
        if (card.isIdentified() == false){
            cost = UNIDENTIFIED_CARD_BASE_COST;
        }
        int shopType = m_shopTypeOpened[p];
        switch(shopType){
            case SHOP_TYPE_SHRINE: cost = g_shrineShopCost;
            case SHOP_TYPE_TEMPLE: cost = g_templeShopCost;
            case SHOP_TYPE_FORGE: cost = g_forgeShopCost;
            case SHOP_TYPE_ARMORY: cost = g_armoryShopCost;
        }
        return cost;
    }

    void renderCard(ref CardData currCard,
                    int p = 0, float posX = 0.0, float posY = 0.0, 
                    bool isBench = false){
        int additionalSize = 0;
        float additionalYOffset = 0;
        int uuid = currCard.getUuid();
        int selectedUUID = g_selectedUUIDs[p];
        bool isSelected = uuid == selectedUUID;
        float iconMultiplier = 1.0;
        if (isSelected){
            iconMultiplier = 1.25;
        }

        CardParameters params = currCard.getCardParameters();
        Parameters cardParams = cardParameterstoParametersCopy(params);
        cardParams.ints[0] = uuid;
        int mainIconSize = 128.0 * iconMultiplier;

        int rarity = -1;
        if (currCard.isIdentified()){
            rarity = currCard.getRarity();
        }
        int uiRarityElement = -1;
        switch(rarity){
            case 0: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unit.png", mainIconSize));
            case 1: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_special.png", mainIconSize));
            case 2: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unitcmd.png", mainIconSize));
            case 3: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_myth.png", mainIconSize));
            case 4: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_tech.png", mainIconSize));
            default: uiRarityElement = minimapSafeDisplay(p, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_cmd.png", mainIconSize));
        }

        string iconPath = "resources/front_end/Lobby/Icon_Godicon_Random.png";
        if (currCard.isIdentified()){
            iconPath = params.getIconPath();
        }
        int uiMainIconElement = minimapSafeClickable(p, 
                            posX, posY + 0.008 * iconMultiplier, 0.1, 0.12,
                            getIconPathFormat(iconPath, 112.0 * iconMultiplier),
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_selectedUUIDs[p] = parameters.ints[0];
                refreshShop(p);
            }, uiRarityElement
        );

        // Locked Icon
        float lockedPosX = posX;
        float lockedPoxY = posY + 0.025 * iconMultiplier;
        if (currCard.isLocked()){
            minimapSafeDisplay(p, lockedPosX, lockedPoxY, getIconPathFormat("resources/in_game/hud/Icon_Delete.png", 64 * iconMultiplier));
        }

        // Cost
        if ((m_shopTypeOpened[p] != SHOP_TYPE_SHRINE) 
            || (currCard.isIdentified() == false && (m_shopTypeOpened[p] == SHOP_TYPE_SHRINE || m_shopTypeOpened[p] != DEFAULT_SHOP_TYPE)))
        {
            int cost = getCost(currCard, p);
            if (isBench && m_shopTypeOpened[p] == DEFAULT_SHOP_TYPE){
                cost = cost * SELL_MULTIPLIER;
            }
            string costText = getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " <color=0.729,0.557,0.137,0,0,0>" + cost + "</color>";
            minimapSafeDisplay(p, posX, posY + 0.13 * iconMultiplier, costText);
        }

        if (currCard.isIdentified() == false){return;}

        // Upgrade Icon
        float miniIconYOffset = 0.03;
        int miniIconSize = 32.0 * iconMultiplier;
        float leftPosX = posX - 0.055 * iconMultiplier;
        float leftPosY = posY + 0.08 * iconMultiplier;
        float width = 0.025;
        float height = 0.025;

        int[] upgrades = currCard.getUpgrades();
        for (int i = 0; i < upgrades.size(); i++) {
            if (i == 3){
                leftPosX = leftPosX + miniIconYOffset * iconMultiplier;
                leftPosY = posY + 0.08 * iconMultiplier;
            }
            int upgrade = upgrades[i];
            int uiIconBackgroundElement = minimapSafeDisplay(p, leftPosX, leftPosY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", miniIconSize), uiMainIconElement);
            switch(upgrade){
                case UPGRADE_HACK_ARMOR: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, getIconPathFormat("resources/in_game/stat_hack_armor.png", miniIconSize), "Upgrade: Hack Armor", "", uiIconBackgroundElement);
                case UPGRADE_PIERCE_ARMOR: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                                       getIconPathFormat("resources/in_game/stat_pierce_armor.png", miniIconSize), "Upgrade: Pierce Armor", "", uiIconBackgroundElement);
                case UPGRADE_CRUSH_ARMOR: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, getIconPathFormat("resources/in_game/stat_crush_armor.png", miniIconSize), "Upgrade: Crush Armor", "", uiIconBackgroundElement);
                case UPGRADE_HITPOINTS: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, getIconPathFormat("resources/in_game/stat_hp.png", miniIconSize), "Upgrade: Health", "", uiIconBackgroundElement);
                case UPGRADE_SHIELDS: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, getIconPathFormat("resources/in_game/stat_shield.png", miniIconSize), "Upgrade: Shields", "", uiIconBackgroundElement);
                case UPGRADE_SPEED: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, getIconPathFormat("resources/in_game/stat_speed.png", miniIconSize), "Upgrade: Speed", "", uiIconBackgroundElement);
                case UPGRADE_HP_REGEN: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                                   getIconPathFormat("resources/in_game/stat_hp_regen.png", miniIconSize), "Upgrade: Health Regeneration", "", uiIconBackgroundElement);
                case UPGRADE_HACK_ATTACK: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                                      getIconPathFormat("resources/in_game/stat_hack_dmg.png", miniIconSize), "Upgrade: Hack Damage", "", uiIconBackgroundElement);
                case UPGRADE_PIERCE_ATTACK: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                                        getIconPathFormat("resources/in_game/stat_pierce_dmg.png", miniIconSize), "Upgrade: Pierce Damage", "", uiIconBackgroundElement);
                case UPGRADE_CRUSH_ATTACK: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                                       getIconPathFormat("resources/in_game/stat_crush_dmg.png", miniIconSize), "Upgrade: Crush Damage", "", uiIconBackgroundElement);
                case UPGRADE_ROF: minimapSafeDisplayWithHover(p, leftPosX, leftPosY, width, height, 
                                                              getIconPathFormat("resources/in_game/stat_rof.png", miniIconSize), "Upgrade: Rate of Fire", "", uiIconBackgroundElement);
            }
            leftPosY = leftPosY - miniIconYOffset * iconMultiplier; 
        }

        // Synergies
        float rightPosX = posX + 0.055 * iconMultiplier;
        float rightPosY = posY + 0.08 * iconMultiplier;
        int count = 0;

        for (int SYNERGY_INDEX = 0; SYNERGY_INDEX < MAX_SYNERGIES; SYNERGY_INDEX++){
            if (params.isASynergy(SYNERGY_INDEX)){
                if (count == 3){
                    rightPosX = rightPosX - miniIconYOffset * iconMultiplier;
                    rightPosY = posY + 0.08 * iconMultiplier;
                }
                renderSynergyIcon(p, rightPosX, rightPosY, 0.025, 0.025, miniIconSize, SYNERGY_INDEX, true, "", uiMainIconElement);
                rightPosY = rightPosY - miniIconYOffset * iconMultiplier;
                count = count + 1;
            }
        }

        // Title
        string title = params.getTitle();
        title = getDisplayName(rarity, title);
        minimapSafeDisplay(p, posX, posY + 0.116 * iconMultiplier, title);

        // Deployed Icon
        if (isBench && currCard.isDeployed()){
            minimapSafeDisplay(p, posX, posY + 0.03, getIconPathFormat("resources/in_game/gamepad_contextual/cur_attac_building.png", 64 * iconMultiplier), uiMainIconElement);
        }
    }

    CardData drawFromDeck(int d = 0){
        DeckData deck = m_decks[d];
        CardData drawnCard = deck.drawRandomCard();
        m_decks[d] = deck;
        return drawnCard;
    }

    bool addCardIntoDraw(ref DrawData currDraw, ref CardData card){
        if (card.isNull() == false){
            return currDraw.addCard(card);
        }
        return false;
    }

    void addCardToDeck(ref CardData card, int d = 0){
        DeckData deck = m_decks[d];
        deck.addCard(card);
        m_decks[d] = deck;
    }

    void draw(int p = 0) {
        int lockedCount = 0;
        DrawData currDraw = m_currDraws[p];

        // 1. Check if all slots are locked BEFORE charging the player
        for (int i = 0; i < currDraw.getSize(); i++) {
            CardData currCard = currDraw.getCard(i);
            if (currCard.isNull() == false) {
                if (currCard.isLocked()) {
                    lockedCount = lockedCount + 1;
                }
            }
        }

        // Abort early if all available card slots are locked
        if (lockedCount >= config_MAX_DRAWN_CARDS) {return;}

        // 2. Charge the player only after passing validation
        if (purchase(getDrawCost(p), p) == false) {return;}

        // 3. Remove non-locked cards and add them back to deck
        for (int i = currDraw.getSize() - 1; i >= 0; i--) {
            CardData currCard = currDraw.getCard(i);
            if (currCard.isNull() || currCard.isLocked()) {
                continue;
            }
            CardData removedCard = currDraw.removeCard(i);
            m_currDraws[p] = currDraw;
            if (removedCard.getUuid() == g_selectedUUIDs[p]) {
                g_selectedUUIDs[p] = -1; // Deselect card
            }
            if (removedCard.isNull() == false) {
                addCardIntoDeck(removedCard, removedCard.getDeckIndex());
            }
        }

        // 4. Draw new cards for available slots
        int numberOfCardsToDraw = config_MAX_DRAWN_CARDS - lockedCount;
        int cardsDrew = 0;

        while (cardsDrew < numberOfCardsToDraw) {
            int tier = getRandomTier(m_currShopLevel[p]);
            CardData drawnCard = drawFromDeck(tier);
            if (addCardIntoDraw(currDraw, drawnCard) == false){
                addCardToDeck(drawnCard, tier);
            }
            else {
                cardsDrew = cardsDrew + 1;
            }
        }
        trSoundsetPlayPlayer(p, "AotgNextPage");
        m_currDraws[p] = currDraw;
        refreshShop(p);
    }

    void buy(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        if (bench.getNumberOfCardsHeld() < MAX_CARDS_IN_BENCH){
            DrawData currDraw = m_currDraws[p];

            CardData card = currDraw.getCardByUUID(uuid);
            if (card.isNull() == true){return;}
            int cost = getCost(card, p);
            if (purchase(cost, p) == false){return;}

            CardData removedCard = currDraw.removeCardByUUID(uuid);
            m_currDraws[p] = currDraw;
            if (removedCard.isNull() == false){
                removedCard.unlockCard();
                bench.addCard(removedCard);
                g_selectedUUIDs[p] = -1; // Deselect card
                trSoundsetPlayPlayer(p, "StorehouseSelect");
                m_benches[p] = bench;
                refreshShop(p);
            }
        }
        else {
            trChatSendToPlayer(p, p, "Max card limit of " + MAX_CARDS_IN_BENCH + " reached.");
            trSoundsetPlayPlayer(p, "PopCapHit");
        }
    }

    void lock(int p = 0, int uuid = -1){
        DrawData currDraw = m_currDraws[p];
        for(int i = 0; i < currDraw.getSize(); i++) {
            CardData currCard = currDraw.getCard(i);
            if (currCard.getUuid() != -1 && currCard.getUuid() == uuid){
                currCard.toggleLock();
                trSoundsetPlayPlayer(p, "TradingPostSelect");
                currDraw.m_cardArray[i] = currCard;
                refreshShop(p);
            }
        }
        m_currDraws[p] = currDraw;
    }

    void buyXP(int p = 0){
        if (purchase(getBuyXPCost(p), p) == false) {return;}

        int currShopLevel = m_currShopLevel[p];
        // Block buying XP if already at max level
        if (currShopLevel >= MAX_SHOP_LEVEL) {
            return;
        }
        m_totalShopExp[p] = m_totalShopExp[p] + 5;
        if (currShopLevel < g_shopLevels.size()){
            ShopLevel level = g_shopLevels[currShopLevel];

            if (m_totalShopExp[p] >= level.m_expNeeded){
                m_currShopLevel[p] = m_currShopLevel[p] + 1;
                m_totalShopExp[p] = 0;
                trSoundsetPlayPlayer(p, "AotgBlessingRewardReceivedDivine");
                refreshShop(p);
                return;
            }
        }
        trSoundsetPlayPlayer(p, "AotgNodeSelectAvailable");
        refreshShop(p);
    }

    CardData copyCard(CardData copiedCard){
        copiedCard.m_uuid = g_uuid.getNextUUID();
        return copiedCard;
    }

    void sell(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        CardData removedCard = bench.removeCardByUUID(uuid);
        if (removedCard.isNull() == false){
            int goldAmount = getCost(removedCard, p);

            if (removedCard.isOsirisPieceBoxCard() == false){
                int rarity = removedCard.getRarity();
                while(removedCard.getRarity() > 0){
                    removedCard.decreaseRarityByOne(p);
                }
                removedCard.setRarity(TIER_COMMON);
                int cardCount = rarity + 1;
                for (int i = 0; i < cardCount - 1; i++){
                    CardData copiedCard = copyCard(removedCard);
                    copiedCard.splitUpgradeSubset(i);
                    addCardIntoDeck(copiedCard, copiedCard.getDeckIndex());
                }
                removedCard.splitUpgradeSubset(cardCount - 1);
            }

            addCardIntoDeck(removedCard, removedCard.getDeckIndex());
            trPlayerGrantResources(p, "Gold", goldAmount * SELL_MULTIPLIER);
            trSoundsetPlayPlayer(p, "TributeReceived");
            g_selectedUUIDs[p] = -1; // Deselect card
        }
        m_benches[p] = bench;
        refreshShop(p);
    }

    void deploy(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.deployCard(uuid);
        m_benches[p] = bench;
        refreshShop(p);
    }

    void withdraw(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.withdrawCard(uuid);
        m_benches[p] = bench;
        refreshShop(p);
    }

    void identify(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.identifyCard(uuid, p);
        m_benches[p] = bench;
        refreshShop(p);
    }

    void rerollRarity(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.rerollRarity(uuid, p);
        m_benches[p] = bench;
        refreshShop(p);
    }

    void addSocket(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.addSocket(uuid, p);
        m_benches[p] = bench;
        refreshShop(p);
    }

    void rerollUpgrade(int p = 0, int uuid = -1, int upgradeIndex = 0){
        BenchData bench = m_benches[p];
        bench.rerollUpgrade(uuid, p, upgradeIndex);
        m_benches[p] = bench;
        refreshShop(p);
    }
};

Shop g_shop;

void renderDraws(int p = 1) {
    DrawData currDraw = g_shop.m_currDraws[p];
    CardData[] currCards = currDraw.m_cardArray;
    int cardCount = currCards.size();

    if (cardCount == 0) return;

    float offsetX = 0.165;
    float posY = -0.4;
    float posX = -((cardCount - 1) * offsetX) / 2.0;

    for (int i = 0; i < cardCount; i++) {
        CardData currCard = currCards[i];
        if (currCard.isNull()) {
            posX = posX + offsetX;
            continue;
        }

        g_shop.renderCard(currCard, p, posX, posY);
        if (currCard.getUuid() == g_selectedUUIDs[p]) {
            CardParameters params = currCard.getCardParameters();
            int cost = params.getCost() * 0.75;
            float btnPosY = posY - 0.1; 

            Parameters cardParams = cardParameterstoParametersCopy(params);
            int uuid = currCard.getUuid();
            cardParams.ints[0] = uuid;

            minimapSafeClickable(p, 
                                posX - 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.buy(p, parameters.ints[0]);
                }
            );
            minimapSafeClickable(p, 
                                posX + 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.lock(p, parameters.ints[0]);
                }
            );
            createButton(p, posX - 0.06, btnPosY, "BUY");
            createButton(p, posX + 0.06, btnPosY, "(UN)LOCK");
        }
        posX = posX + offsetX;
    }
}

void createShopCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if (currCard.getUuid() != g_selectedUUIDs[p]) { return; }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    Parameters cardParams = cardParameterstoParametersCopy(params);
    int uuid = currCard.getUuid();
    cardParams.ints[0] = uuid;

    if (currCard.isDeployed()){
        minimapSafeClickable(p, 
                            posX, btnPosY + 0.035, 0.1, 0.055,
                            "",
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_shop.withdraw(p, parameters.ints[0]);
            }
        );
        createButton(p, posX, btnPosY, "WITHDRAW");
    }
    else {
        float sellPosX = currCard.isIdentified() ? (posX - 0.06) : posX;
        minimapSafeClickable(p, 
                            sellPosX, btnPosY + 0.035, 0.1, 0.055,
                            "",
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_shop.sell(p, parameters.ints[0]);
            }
        );
        createButton(p, sellPosX, btnPosY, "SELL");
        if (currCard.isIdentified()){
            minimapSafeClickable(p, 
                                posX + 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.deploy(p, parameters.ints[0]);
                }
            );
            createButton(p, posX + 0.06, btnPosY, "DEPLOY");
        }
    }
}

mutable void createShrineCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createArmoryCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createTempleCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createForgeCardButtons(ref CardData currCard, int p = 0, ref float posX, ref float posY){}

void renderBench(int p = 1, int shopType = 0) {
    BenchData bench = g_shop.m_benches[p];
    CardData[] currCards = bench.getCards();

    float propPosX = getLeftAnchorX(UI_LEFT_BUFFER + 200, 128.0, p);
    if (shopType == DEFAULT_SHOP_TYPE){
        bench.renderSynergies(propPosX, 0.35, p);
    }

    int totalCards = bench.getNumberOfCardsHeld();
    if (totalCards == 0) return;

    // Configurable layout parameters
    float offsetX = 0.165;
    float offsetY = 0.225;
    int maxCardsPerRow = 6;
    int maxRows = 3;

    // Determine row count dynamically (capped at 3)
    int numRows = (totalCards + maxCardsPerRow - 1) / maxCardsPerRow; // Ceiling division
    if (numRows > maxRows) numRows = maxRows;

    // Base cards per row (distributes remainders evenly across upper rows)
    int cardsPerRow = (totalCards + numRows - 1) / numRows;

    // Calculate vertical starting position (top row) to keep rows centered around Y
    float startY = ((numRows - 1) * offsetY) / 2.0 - 0.025;

    int visibleIndex = 0;
    for (int i = 0; i < currCards.size(); i++) {
        CardData currCard = currCards[i];
        if (currCard.isNull()) {
            continue;
        }

        // Determine row index (0 = top, 1 = middle, 2 = bottom) and index within that row
        int rowIndex = visibleIndex / cardsPerRow;
        int indexInRow = visibleIndex % cardsPerRow;

        // Calculate actual card count for this specific row (handles partial bottom rows)
        int rowCardCount = cardsPerRow;
        if (rowIndex == numRows - 1) {
            rowCardCount = totalCards - (rowIndex * cardsPerRow);
        }

        // Horizontal position (centered for this row)
        float startX = -((rowCardCount - 1) * offsetX) / 2.0;
        float posX = startX + (indexInRow * offsetX);

        // Vertical position (top row is positive Y, moving down per row)
        float posY = startY - (rowIndex * offsetY);

        g_shop.renderCard(currCard, p, posX, posY + 0.1, true);

        switch(shopType){
            case DEFAULT_SHOP_TYPE: createShopCardButtons(currCard, p, posX, posY);
            case SHOP_TYPE_SHRINE: createShrineCardButtons(currCard, p, posX, posY);
            case SHOP_TYPE_TEMPLE: createTempleCardButtons(currCard, p, posX, posY);
            case SHOP_TYPE_FORGE: createForgeCardButtons(currCard, p, posX, posY);
            case SHOP_TYPE_ARMORY: createArmoryCardButtons(currCard, p, posX, posY);
            default: createShopCardButtons(currCard, p, posX, posY);
        }
        visibleIndex = visibleIndex + 1;
    }
}

void closeShop(int p = 1, int shopType = SHOP_TYPE_CLOSED){
    if (uiSystemActiveArray[p] == false) {return;}
    if (shopType != SHOP_TYPE_CLOSED && g_shop.m_shopTypeOpened[p] != shopType) {return;}
    exitUiSystem(p, true);
    if(trCurrentPlayer() == p){
        setUiVisible(true);
        trSetObscuredUnits(true);
        trSoundPlayPaused("ui\latch.wav"); //TODO: Fix looping close?
    }
    g_shop.m_shopTypeOpened[p] = SHOP_TYPE_CLOSED;
}

void renderExitButton(int p = 1, float drawPosx = 0.55, float drawPosY = -0.425) {
    float drawPosx2 = getRightAnchorX(100, 128.0, p);
    drawPosx = min(drawPosx, drawPosx2);
    createButton(p, drawPosx, drawPosY, "EXIT");
    minimapSafeClickable(p, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            closeShop(p);
        }
    );
}

void renderShop(int p = 1){
    renderDraws(p);
    renderBench(p, DEFAULT_SHOP_TYPE);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float yOffset = 0.075;
    float drawPosYStart = -0.35;

    int shopLevel = g_shop.m_currShopLevel[p];
    ShopLevel level = g_shopLevels[shopLevel];
    string shopChances = "I: " + level.m_tier1Chance + "%\n" +
                         "II: " + level.m_tier2Chance + "%\n" +
                         "III: " + level.m_tier3Chance + "%\n" +
                         "IV: " + level.m_tier4Chance + "%\n" +
                         "V: " + level.m_tier5Chance + "%";
    uiSystemAddDisplayDynamic(p, drawPosx - 0.015, drawPosYStart + 0.15, 1259, [](int p = 1, ref Parameters parameters) -> string { 
                int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
                return getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " <color=0.729,0.557,0.137,0,0,0>" + goldStockpiled + "</color>"; 
            }, EMPTY_PARAMETERS
        );
    if (shopLevel < MAX_SHOP_LEVEL && shopLevel < g_shopLevels.size()){
        minimapSafeDisplayWithHover(p, drawPosx - 0.015, drawPosYStart + 0.1, 0.075, 0.075, 
                                    "<color=1,1,1,0,0,0>" +
                                    "\nLevel: " + shopLevel + "\n" + 
                                    "XP: " + g_shop.m_totalShopExp[p] + " / " + level.m_expNeeded,
                                    "Shop Level Drop Chances" +
                                    "</color>",
                                    shopChances);
    }
    else {
        minimapSafeDisplayWithHover(p, drawPosx - 0.015, drawPosYStart + 0.1, 0.075, 0.075, 
                                    "<color=1,1,1,0,0,0>" +
                                    "\nLevel: " + MAX_SHOP_LEVEL + 
                                    "\nXP: MAX",
                                    "Shop Level Drop Chances" +
                                    "</color>",
                                    shopChances);
    }

    // Buy XP
    float drawPosY = drawPosYStart;
    createButton(p, drawPosx, drawPosY, "");
    minimapSafeClickable(p, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.buyXP(p);
        }
    );
    minimapSafeDisplay(p, drawPosx, drawPosY + 0.03,
                       "BUY XP\n" + getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + "<color=0.729,0.557,0.137>" + g_shop.getBuyXPCost(p) + "</color>");

    // Draw
    drawPosY = drawPosY - yOffset;
    createButton(p, drawPosx, drawPosY, "");
    minimapSafeClickable(p, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.draw(p);
        }
    );
    minimapSafeDisplay(p, drawPosx, drawPosY + 0.03,
                       "DRAW\n" + getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + "<color=0.729,0.557,0.137>" + g_shop.getDrawCost(p) + "</color>");

    // Exit Shop Button
    renderExitButton(p);
}

void hideWorldPrompts(int p = 1){
    if (trCurrentPlayer() != p){ return; }
    int[] shopIds = ShopTypeToUnitIDMap.getValues();
    for (int i = 0; i < shopIds.size(); i++){
        trWorldSpacePromptHide(""+shopIds[i]);
    }
}

bool respawnDeployedCards(ref BenchData bench){
    bool wasThereAChange = false;
    int currtime = xsGetTimeMS();

    for(int i = 0; i < bench.m_cardSize; i++) {
        CardData card = bench.m_cardArray[i];
        if (card.isNull() || card.isDeployed() == false || card.isRespawning()) { continue; }
        int unitId = card.getDeployedUnitID();
        selectSingle(unitId);
        if (trUnitDead()){
            card.setIsRespawning(true);
            bench.m_cardArray[i] = card;
            wasThereAChange = true;
            int respawnTimeMS = RESPAWN_TIME_MS_BASE + (((currtime - g_timeMSGameStarted) / 60000) * RESPAWN_TIME_ADDITIONAL_MS);
            schedulerWithIntInt.add(respawnTimeMS, bench.m_player, i, [](int iterations = 1, int p = 0, int cardIndex = 0) -> bool {
                BenchData bench = g_shop.m_benches[p];
                CardData deadCard = bench.m_cardArray[cardIndex];
                if (deadCard.isNull() || deadCard.isDeployed() == false || deadCard.isRespawning() == false) { return false; }
                if (bench.spawnCard(deadCard, false)) {
                    trSoundsetPlayPlayer(p, "HeroRevive");
                    bench.m_cardArray[cardIndex] = deadCard;
                    g_shop.m_benches[p] = bench;
                }
                return false;
            });
        }
    }
    return wasThereAChange;
}

int[] g_unitLostCache = default;

void startShopTimers(){

    g_unitLostCache = new int(cNumberPlayers-1, 0);

    // Shop respawner
    scheduler.add(2003, [](int iterations = 1) -> bool {
        for (int p = 1; p <= cNumberPlayers - 2; p++){
            int unitsLost = kbGetStatValueInt(p, cStatTypeUnitsLost);
            // Only run the heavy card-loop if the total cumulative deaths have increased 
            if (unitsLost > g_unitLostCache[p]) {
                BenchData bench = g_shop.m_benches[p];
                if (respawnDeployedCards(bench)){
                    g_shop.m_benches[p] = bench;
                }
                g_unitLostCache[p] = unitsLost;
            }
        }
        return true;
    });

    // Reduce shop costs over time
    scheduler.add(SHOP_COST_REDUCTION_MS_INTERVAL, [](int iterations = 1) -> bool {
        g_shrineShopCost = max(g_shrineShopCost - SHOP_COST_REDUCTION, 10);
        g_templeShopCost = max(g_templeShopCost - SHOP_COST_REDUCTION, 10);
        g_armoryShopCost = max(g_armoryShopCost - SHOP_COST_REDUCTION, 10);
        g_forgeShopCost = max(g_forgeShopCost - SHOP_COST_REDUCTION, 10);
        for (int p=1; p<=cNumberPlayers-2; p++){
            refreshShop(p);
        }
        return true;
    });
}