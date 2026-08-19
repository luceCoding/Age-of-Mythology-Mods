include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";
include "data/cardParameters.xs";

const int TOTAL_AGES = 5;
const float SELL_MULTIPLIER = 0.8;
const float UI_LEFT_BUFFER = 50;

const int SHOP_TYPE_SHRINE = 1;
const int SHOP_TYPE_TEMPLE = 2;
const int SHOP_TYPE_FORGE = 3;
const int SHOP_TYPE_ARMORY = 4;

void createButton(ref UiSystem system, float drawPosx = 0.0, float drawPosY = 0.0, string buttonName = ""){
    minimapSafeDisplay(system, drawPosx, drawPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
    minimapSafeDisplay(system, drawPosx, drawPosY + 0.05, buttonName);
}

bool purchase(int goldAmount = 0, int p = 0){
    if (((kbGetResourceAmount(p, kbGetResourceID("Gold")) >= goldAmount) != false)){
        trPlayerGrantResources(p, "Gold", -goldAmount);
        return true;
    }
    trSoundsetPlayPlayer(1, "PopCapHit");
    return false;
}

class Shop {
    DeckData[] m_decks = default;
    DrawData[] m_currDraws = default;
    BenchData[] m_benches = default;
    int[] m_totalShopExp = default;
    int[] m_currShopLevel = default;
    int[] m_shopTypeOpened = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_currDraws = new DrawData(cNumberPlayers + 1);
        m_benches = new BenchData(cNumberPlayers + 1);
        g_selectedUUIDs = new int(cNumberPlayers + 1, -1);
        g_shopNeedsRefresh = new bool(cNumberPlayers + 1, false);
        m_totalShopExp = new int(cNumberPlayers + 1, 0);
        m_currShopLevel = new int(cNumberPlayers + 1, 0);
        m_shopTypeOpened = new int(cNumberPlayers + 1, 0);
    }

    int getDrawCost(int p = 0){
        return m_currShopLevel[p] + 10;
    }

    int getBuyXPCost(int p = 0){
        return getDrawCost(p) * 2;
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

    bool drawFromDeck(int d = 0, int p = 0){
        DeckData deck = m_decks[d];
        DrawData currDraw = m_currDraws[p];
        CardData drawnCard = deck.drawRandomCard();
        if (drawnCard.isNull() == false){
            bool hasAddedCard = currDraw.addCard(drawnCard, p);
            if (hasAddedCard == false){
                deck.addCard(drawnCard);
                m_decks[d] = deck;
                log(3, "Failed to draw a card for player " + p);
                return false;
            }
            else {
                m_decks[d] = deck;
                m_currDraws[p] = currDraw;
                g_shopNeedsRefresh[p] = true;
                log(3, "Drew a card for player " + p);
                return true;
            }
        }
        return false;
    }

    int getCost(ref CardData card, int p = 0){
        CardParameters params = card.getCardParameters();
        int cost = params.getCost();
        if (card.isIdentified() == false){
            cost = 10;
        }
        if (m_shopTypeOpened[p] == SHOP_TYPE_SHRINE){
            cost = g_shrineShopCost;
        }
        return cost;
    }

    void renderCard(ref UiSystem system, ref CardData currCard,
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
        Parameters cardParams = createParametersCopy(params);
        cardParams.ints[0] = uuid;
        int mainIconSize = 128.0 * iconMultiplier;

        int rarity = -1;
        if (currCard.isIdentified()){
            rarity = currCard.getRarity();
        }
        switch(rarity){
            case 0: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unit.png", mainIconSize));
            case 1: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_special.png", mainIconSize));
            case 2: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unitcmd.png", mainIconSize));
            case 3: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_myth.png", mainIconSize));
            case 4: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_tech.png", mainIconSize));
            default: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_cmd.png", mainIconSize));
        }

        string iconPath = "resources/front_end/Lobby/Icon_Godicon_Random.png";
        if (currCard.isIdentified()){
            iconPath = params.getIconPath();
        }
        minimapSafeClickable(system, 
                            posX, posY + 0.008 * iconMultiplier, 0.1, 0.12,
                            getIconPathFormat(iconPath, 112.0 * iconMultiplier),
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_selectedUUIDs[p] = parameters.ints[0];
                g_shopNeedsRefresh[p] = true;
                log(3, "Player " + p + " clicked " + parameters.strings[3] + " " + parameters.ints[0]);
            }
        );

        // Locked Icon
        float lockedPosX = posX;
        float lockedPoxY = posY + 0.025 * iconMultiplier;
        if (currCard.isLocked()){
            minimapSafeDisplay(system, lockedPosX, lockedPoxY, getIconPathFormat("resources/in_game/hud/Icon_Delete.png", 64 * iconMultiplier));
        }

        // Cost
        if (currCard.isIdentified() && m_shopTypeOpened[p] == SHOP_TYPE_SHRINE) {return;}
        int cost = getCost(currCard, p);
        if (isBench && m_shopTypeOpened[p] == 0){
            cost = cost * SELL_MULTIPLIER;
        }
        string costText = getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " <color=0.729,0.557,0.137>" + cost + "</color>";
        minimapSafeDisplay(system, posX, posY + 0.13 * iconMultiplier, costText);

        if (currCard.isIdentified() == false){return;}

        // Suit Icon
        int miniIconSize = 32.0 * iconMultiplier;
        int suit = currCard.getSuit();
        float leftPosX = posX - 0.055 * iconMultiplier;
        float leftPosY = posY + 0.08 * iconMultiplier;
        float width = 0.025;
        float height = 0.025;
        minimapSafeDisplay(system, leftPosX, leftPosY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", miniIconSize));
        switch(suit){
            case 0: minimapSafeDisplayWithHover(system, leftPosX, leftPosY, width, height, 
                                                getIconPathFormat("resources/in_game/stat_hack_armor.png", miniIconSize), "Upgrade: Hack Armor", "");
            case 1: minimapSafeDisplayWithHover(system, leftPosX, leftPosY, width, height, 
                                                getIconPathFormat("resources/in_game/stat_hack_dmg.png", miniIconSize), "Upgrade: Attack", "");
            case 2: minimapSafeDisplayWithHover(system, leftPosX, leftPosY, width, height, 
                                                getIconPathFormat("resources/in_game/stat_hp.png", miniIconSize), "Upgrade: Health", "");
            case 3: minimapSafeDisplayWithHover(system, leftPosX, leftPosY, width, height, 
                                                getIconPathFormat("resources/in_game/stat_pierce_armor.png", miniIconSize), "Upgrade: Pierce Armor", "");
        }

        // Synergies
        float miniIconYOffset = 0.03;
        float rightPosX = posX + 0.055 * iconMultiplier;
        float rightPosY = leftPosY;

        if (params.isInfantry()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 0);}
        if (params.isArcher()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 1);}
        if (params.isCavalry()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 2);}
        if (params.isMythUnit()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 3);}
        if (params.isHero()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 4);}
        if (params.isHealer()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 5);}
        if (params.isSiege()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 6);}
        //if (params.isBuilding()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 7);}
        if (params.isSoldier()){renderSynergyIcon(system, rightPosX, rightPosY, miniIconYOffset * iconMultiplier, 0.025, 0.025, miniIconSize, 8);}

        // Title
        string title = params.getTitle();
        // Color Tier
        switch(rarity){
            case 1: title = "<color=0.10,0.58,0.37>" + title + "</color>";
            case 2: title = "<color=0.15,0.32,0.49>" + title + "</color>";
            case 3: title = "<color=0.60,0.00,0.73>" + title + "</color>";
            case 4: title = "<color=0.71,0.58,0.00>" + title + "</color>";
        }
        minimapSafeDisplay(system, posX, posY + 0.116 * iconMultiplier, title);

        // Deployed Icon
        if (isBench && currCard.isDeployed()){
            minimapSafeDisplay(system, posX, posY + 0.03, getIconPathFormat("resources/in_game/gamepad_contextual/cur_attac_building.png", 64 * iconMultiplier));
        }
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
            bool drew = drawFromDeck(tier, p);
            if (drew) {
                cardsDrew = cardsDrew + 1;
            }
        }
        trSoundsetPlayPlayer(p, "AotgNextPage");
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
            if (removedCard.isNull() == false){
                removedCard.unlockCard();
                bench.addCard(removedCard);
                trSoundsetPlayPlayer(1, "StorehouseSelect");
                g_selectedUUIDs[p] = -1; // Deselect card
                g_shopNeedsRefresh[p] = true;
            }
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
                g_shopNeedsRefresh[p] = true;
            }
        }
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
                g_shopNeedsRefresh[p] = true;
                return;
            }
        }
        trSoundsetPlayPlayer(p, "AotgNodeSelectAvailable");
        g_shopNeedsRefresh[p] = true;
    }

    void sell(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        CardData removedCard = bench.removeCardByUUID(uuid);
        if (removedCard.isNull() == false){
            int goldAmount = getCost(removedCard, p);
            addCardIntoDeck(removedCard);
            trPlayerGrantResources(p, "Gold", goldAmount * SELL_MULTIPLIER);
            trSoundsetPlayPlayer(p, "TributeReceived");
            g_selectedUUIDs[p] = -1; // Deselect card
            g_shopNeedsRefresh[p] = true;
        }
    }

    void deploy(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.deployCard(uuid);
        g_shopNeedsRefresh[p] = true;
    }

    void withdraw(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.withdrawCard(uuid);
        g_shopNeedsRefresh[p] = true;
    }

    void identify(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        bench.identifyCard(uuid, p);
        g_shopNeedsRefresh[p] = true;
    }
};

Shop g_shop;

void renderDraws(ref UiSystem system, int p = 1) {
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

        g_shop.renderCard(system, currCard, p, posX, posY);
        if (currCard.getUuid() == g_selectedUUIDs[p]) {
            CardParameters params = currCard.getCardParameters();
            int cost = params.getCost() * 0.75;
            float btnPosY = posY - 0.1; 

            Parameters cardParams = createParametersCopy(params);
            int uuid = currCard.getUuid();
            cardParams.ints[0] = uuid;

            minimapSafeClickable(system, 
                                posX - 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.buy(p, parameters.ints[0]);
                }
            );
            minimapSafeClickable(system, 
                                posX + 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.lock(p, parameters.ints[0]);
                }
            );
            createButton(system, posX - 0.06, btnPosY, "BUY");
            createButton(system, posX + 0.06, btnPosY, "(UN)LOCK");
        }
        posX = posX + offsetX;
    }
}

void createShopCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){
    if ((currCard.getUuid() == g_selectedUUIDs[p]) == false) { return; }
    CardParameters params = currCard.getCardParameters();
    float btnPosY = posY + 0.005; 

    Parameters cardParams = createParametersCopy(params);
    int uuid = currCard.getUuid();
    cardParams.ints[0] = uuid;

    if (currCard.isDeployed()){
        minimapSafeClickable(system, 
                            posX, btnPosY + 0.035, 0.1, 0.055,
                            "",
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_shop.withdraw(p, parameters.ints[0]);
            }
        );
        createButton(system, posX, btnPosY, "WITHDRAW");
    }
    else {
        minimapSafeClickable(system, 
                            posX - 0.06, btnPosY + 0.035, 0.1, 0.055,
                            "",
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_shop.sell(p, parameters.ints[0]);
            }
        );
        createButton(system, posX - 0.06, btnPosY, "SELL");
        if (currCard.isIdentified()){
            minimapSafeClickable(system, 
                                posX + 0.06, btnPosY + 0.035, 0.1, 0.055,
                                "",
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_shop.deploy(p, parameters.ints[0]);
                }
            );
            createButton(system, posX + 0.06, btnPosY, "DEPLOY");
        }
    }
}

mutable void createShrineCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createArmoryCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createTempleCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){}
mutable void createForgeCardButtons(ref UiSystem system, ref CardData currCard, int p = 0, ref float posX, ref float posY){}

void renderBench(ref UiSystem system, int p = 1, int shopType = 0) {
    BenchData bench = g_shop.m_benches[p];
    CardData[] currCards = bench.getCards();

    float propPosX = getLeftAnchorX(UI_LEFT_BUFFER + 100, 128.0, p);
    if (shopType == 0){
        bench.renderSynergies(system, propPosX, 0.0, p);
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

        g_shop.renderCard(system, currCard, p, posX, posY + 0.1, true);

        switch(shopType){
            case SHOP_TYPE_SHRINE: createShrineCardButtons(system, currCard, p, posX, posY);
            case SHOP_TYPE_TEMPLE: createTempleCardButtons(system, currCard, p, posX, posY);
            case SHOP_TYPE_FORGE: createForgeCardButtons(system, currCard, p, posX, posY);
            case SHOP_TYPE_ARMORY: createArmoryCardButtons(system, currCard, p, posX, posY);
            default: createShopCardButtons(system, currCard, p, posX, posY);
        }
        visibleIndex = visibleIndex + 1;
    }
}

void closeShop(int p = 1){
    UiSystem system = uiSystemArray[p];
    system.exit(true);
    if(trCurrentPlayer() == p){
        setUiVisible(true);
        trSetObscuredUnits(true);
    }
    uiSystemArray[p] = system;
    trSoundsetPlayPlayer(p, "UI_Latch");
}

void renderExitButton(ref UiSystem system, int p = 1, float drawPosx = 0.55, float drawPosY = -0.425) {
    float drawPosx2 = getRightAnchorX(100, 128.0, p);
    drawPosx = min(drawPosx, drawPosx2);
    createButton(system, drawPosx, drawPosY, "EXIT");
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            closeShop(p);
        }
    );
}

void renderShop(ref UiSystem system, int p = 1){
    renderDraws(system, p);
    renderBench(system, p);

    float drawPosx = getLeftAnchorX(UI_LEFT_BUFFER, 128.0, p);
    drawPosx = max(drawPosx, -0.55);
    float yOffset = 0.075;
    float drawPosYStart = -0.35;

    int goldStockpiled = kbGetResourceAmount(p, kbGetResourceID("Gold"));
    int shopLevel = g_shop.m_currShopLevel[p];
    ShopLevel level = g_shopLevels[shopLevel];
    string shopChances = "I: " + level.m_tier1Chance + "%\n" +
                         "II: " + level.m_tier2Chance + "%\n" +
                         "III: " + level.m_tier3Chance + "%\n" +
                         "IV: " + level.m_tier4Chance + "%\n" +
                         "V: " + level.m_tier5Chance + "%";
    if (shopLevel < MAX_SHOP_LEVEL && shopLevel < g_shopLevels.size()){
        minimapSafeDisplayWithHover(system, drawPosx - 0.015, drawPosYStart + 0.1, 0.075, 0.075, 
                                    getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled + 
                                    "\nLevel: " + shopLevel + "\n" + 
                                    "XP: " + g_shop.m_totalShopExp[p] + " / " + level.m_expNeeded,
                                    "Shop Level Draw Chances",
                                    shopChances);
    }
    else {
        minimapSafeDisplayWithHover(system, drawPosx - 0.015, drawPosYStart + 0.1, 0.075, 0.075, 
                                    getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + " " + goldStockpiled + 
                                    "\nLevel: " + MAX_SHOP_LEVEL + 
                                    "\nXP: MAX",
                                    "Shop Level Drop Chances",
                                    shopChances);
    }

    // Buy XP
    float drawPosY = drawPosYStart;
    createButton(system, drawPosx, drawPosY, "");
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.buyXP(p);
        }
    );
    minimapSafeDisplay(system, drawPosx, drawPosY + 0.03,
                       "BUY XP\n" + getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + "<color=0.729,0.557,0.137>" + g_shop.getBuyXPCost(p) + "</color>");

    // Draw
    drawPosY = drawPosY - yOffset;
    createButton(system, drawPosx, drawPosY, "");
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.draw(p);
        }
    );
    minimapSafeDisplay(system, drawPosx, drawPosY + 0.03,
                       "DRAW\n" + getIconPathFormat("resources/in_game/Villager_Priority/icons_off/Icon_Economic_Off.png", 32) + "<color=0.729,0.557,0.137>" + g_shop.getDrawCost(p) + "</color>");

    // Exit Shop Button
    renderExitButton(system, p);

    g_shopNeedsRefresh[p] = false;
}

void openShop(int p = 1){
    UiSystem system = uiSystemArray[p];
    system.enter(false, true, 503);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    g_shop.m_shopTypeOpened[p] = 0;
    renderShop(system, p);
    uiSystemArray[p] = system;
    trSoundsetPlayPlayer(p, "UI_Latch");
}

void startRespawner(){
    scheduler.add(1009, [](int iterations = 1) -> bool {
        for (int i = 1; i <= g_shop.m_benches.size()-2; i++){
            BenchData bench = g_shop.m_benches[i];
            bool wasRespawned = bench.respawnDeployedCards();
            if (wasRespawned){
                g_shop.m_benches[i] = bench;
            }
        }
        return true;
    });
}