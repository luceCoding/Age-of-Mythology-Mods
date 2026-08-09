include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";

const int TOTAL_AGES = 5;
const float SELL_MULTIPLIER = 0.8;
int[] g_selectedUUIDs = default;
bool[] g_shopNeedsRefresh = default;

void createButton(ref UiSystem system, float drawPosx = 0.0, float drawPosY = 0.0, string buttonName = ""){
    minimapSafeDisplay(system, drawPosx, drawPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
    minimapSafeDisplay(system, drawPosx, drawPosY + 0.05, buttonName);
}

class Shop {
    DeckData[] m_decks = default;
    DrawData[] m_currDraws = default;
    BenchData[] m_benches = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_currDraws = new DrawData(cNumberPlayers + 1);
        m_benches = new BenchData(cNumberPlayers + 1);
        g_selectedUUIDs = new int(cNumberPlayers + 1, -1);
        g_shopNeedsRefresh = new bool(cNumberPlayers + 1, false);
    }

    void addCardIntoDeck(ref CardData card){
        CardParameters params = card.getCardParameters();
        int age = params.getAge();
        DeckData deck = m_decks[age];
        deck.addCard(card);
        m_decks[age] = deck;
    }

    void drawFromDeck(int d = 0, int p = 0){
        DeckData deck = m_decks[d];
        DrawData currDraw = m_currDraws[p];
        CardData drawnCard = deck.drawRandomCard();
        if (drawnCard.isNull() == false){
            bool hasAddedCard = currDraw.addCard(drawnCard, p);
            if (hasAddedCard == false){
                deck.addCard(drawnCard);
                m_decks[d] = deck;
                log(3, "Failed to draw a card for player " + p);
            }
            else {
                m_decks[d] = deck;
                m_currDraws[p] = currDraw;
                g_shopNeedsRefresh[p] = true;
                log(3, "Drew a card for player " + p);
            }
        }
    }

    void renderCard(ref UiSystem system, ref CardData currCard,
                    int p = 0, float posX = 0.0, float posY = 0.0, 
                    bool isBench = false){
        // Main Icon
        int additionalSize = 0;
        float additionalYOffset = 0;
        int uuid = currCard.getUuid();
        int selectedUUID = g_selectedUUIDs[p];
        bool isSelected = uuid == selectedUUID;
        float iconMultiper = 1.0;
        if (isSelected){
            iconMultiper = 1.25;
        }

        CardParameters params = currCard.getCardParameters();
        string iconPath = params.getIconPath();
        Parameters cardParams = createParametersCopy(params);
        cardParams.ints[0] = uuid;

        int rarity = currCard.getRarity();
        switch(rarity){
            case 1: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_special.png", 128.0 * iconMultiper));
            case 2: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unitcmd.png", 128.0 * iconMultiper));
            case 3: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_myth.png", 128.0 * iconMultiper));
            case 4: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_tech.png", 128.0 * iconMultiper));
            default: minimapSafeDisplay(system, posX, posY, getIconPathFormat("resources/in_game/hud/icon_frame_unit.png", 128.0 * iconMultiper));
        }

        minimapSafeClickable(system, 
                            posX, posY + 0.008 * iconMultiper, 0.1, 0.12,
                            getIconPathFormat(iconPath, 112.0 * iconMultiper),
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_selectedUUIDs[p] = parameters.ints[0];
                g_shopNeedsRefresh[p] = true;
                log(3, "Player " + p + " clicked " + parameters.strings[3] + " " + parameters.ints[0]);
            }
        );

        // Locked Icon
        float lockedPosX = posX;
        float lockedPoxY = posY + 0.025 * iconMultiper;
        if (currCard.isLocked()){
            minimapSafeDisplay(system, lockedPosX, lockedPoxY, getIconPathFormat("resources/in_game/hud/Icon_Delete.png", 64 * iconMultiper));
        }

        // Age Icon
        int age = params.getAge();
        float agePosX = posX - 0.045 * iconMultiper;
        float agePoxY = posY + 0.09 * iconMultiper;
        int miniIconSize = 32.0 * iconMultiper;
        switch(age){
            case 1: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age2Small.png", miniIconSize));
            case 2: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age3Small.png", miniIconSize));
            case 3: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age4Small.png", miniIconSize));
            case 4: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age5Small.png", miniIconSize));
            default: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age1Small.png", miniIconSize));
        }

        // Suit Icon
        int suit = currCard.getSuit();
        float suitPosX = agePosX;
        float suitPoxY = agePoxY - 0.03 * iconMultiper;
        minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", miniIconSize));
        switch(suit){
            case 0: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_hack_armor.png", miniIconSize));
            case 1: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_hack_dmg.png", miniIconSize));
            case 2: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_hp.png", miniIconSize));
            case 3: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_hp_regen.png", miniIconSize));
            case 4: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_pierce_armor.png", miniIconSize));
            case 5: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_shield.png", miniIconSize));
            case 6: minimapSafeDisplay(system, suitPosX, suitPoxY, getIconPathFormat("resources/in_game/stat_speed.png", miniIconSize));
        }

        // Cost
        int cost = params.getCost();
        if (isBench) {
            cost = cost * SELL_MULTIPLIER;
        }
        minimapSafeDisplay(system, posX + 0.045 * iconMultiper, posY, getIconPathFormat("resources/spectator/resource_icons/gold.png", miniIconSize * 1.2));
        if (isSelected){
            minimapSafeDisplay(system, posX + 0.045 * iconMultiper, posY + (0.0075 * iconMultiper) , getIconPathFormat("resources/spectator/timeline/tim_playericon.png", miniIconSize / 2));
        }
        else{
            minimapSafeDisplay(system, posX + 0.045 * iconMultiper, posY + (0.005 * iconMultiper) , getIconPathFormat("resources/spectator/timeline/tim_playericon.png", miniIconSize / 2));
        }
        minimapSafeDisplay(system, posX + 0.045 * iconMultiper, posY + 0.01 * iconMultiper, "" + cost);

        // Title
        string title = params.getTitle();
        {minimapSafeDisplay(system, posX, posY + 0.12 * iconMultiper, title);}
    }

    void draw(int p = 0){
        DrawData currDraw = m_currDraws[p];
        for(int i = currDraw.getSize() - 1; i >= 0; i--) {
            CardData currCard = currDraw.getCard(i);
            if (currCard.isNull() || currCard.isLocked()){
                continue;
            }

            CardData removedCard = currDraw.removeCard(i);
            if (removedCard.getUuid() == g_selectedUUIDs[p]){
                g_selectedUUIDs[p] = -1; // Deselect card
            }
            if (removedCard.isNull() == false) {
                addCardIntoDeck(removedCard);
            }
        }

        int emptySlots = 0;
        for(int i = 0; i < currDraw.getSize(); i++) {
            CardData currCard = currDraw.getCard(i);
            if (currCard.isNull()){
                emptySlots = emptySlots + 1;
            }
        }

        for(int i = 0; i < emptySlots; i++) {
            drawFromDeck(0, p);
        }
    }

    void buy(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        if (bench.getNumberOfCardsHeld() < MAX_CARDS_IN_BENCH){
            DrawData currDraw = m_currDraws[p];
            CardData removedCard = currDraw.removeCardByUUID(uuid);
            if (removedCard.isNull() == false){
                removedCard.unlockCard();
                bench.addCard(removedCard);
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
                currDraw.m_cardArray[i] = currCard;
                g_shopNeedsRefresh[p] = true;
            }
        }
    }

    void buyXP(int p = 0){

    }

    void sell(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        CardData removedCard = bench.removeCardByUUID(uuid);
        if (removedCard.isNull() == false){
                addCardIntoDeck(removedCard);
                g_selectedUUIDs[p] = -1; // Deselect card
                g_shopNeedsRefresh[p] = true;
        }
    }

    void deploy(int p = 0, int uuid = -1){
        BenchData bench = m_benches[p];
        CardData card = bench.getCardWithUUID(uuid);
        if (card.isNull()) return;
        PlayerData player = g_PlayerDataArray[p];
        player.deployCard(card);
        g_PlayerDataArray[p] = player;
        g_shopNeedsRefresh[p] = true;
    }

    void withdraw(int p = 0, int uuid = -1){
        g_shopNeedsRefresh[p] = true;
    }
};

Shop g_shop;

void renderDraws(ref UiSystem system, int p = 1) {
    DrawData currDraw = g_shop.m_currDraws[p];
    CardData[] currCards = currDraw.m_cardArray;
    int cardCount = currCards.size();

    if (cardCount == 0) return;

    float offsetX = 0.15;
    float posY = -0.375;
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

void renderBench(ref UiSystem system, int p = 1) {
    BenchData bench = g_shop.m_benches[p];
    CardData[] currCards = bench.getCards();
    int totalCards = bench.getNumberOfCardsHeld();

    if (totalCards == 0) return;

    // Configurable layout parameters
    float offsetX = 0.15;
    float offsetY = 0.225;
    int maxCardsPerRow = 6;
    int maxRows = 3;

    // Determine row count dynamically (capped at 3)
    int numRows = (totalCards + maxCardsPerRow - 1) / maxCardsPerRow; // Ceiling division
    if (numRows > maxRows) numRows = maxRows;

    // Base cards per row (distributes remainders evenly across upper rows)
    int cardsPerRow = (totalCards + numRows - 1) / numRows;

    // Calculate vertical starting position (top row) to keep rows centered around Y = 0.0
    float startY = ((numRows - 1) * offsetY) / 2.0;

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

        if (currCard.getUuid() == g_selectedUUIDs[p]) {
            CardParameters params = currCard.getCardParameters();
            int cost = params.getCost() * 0.75;
            float btnPosY = posY + 0.005; 

            Parameters cardParams = createParametersCopy(params);
            int uuid = currCard.getUuid();
            cardParams.ints[0] = uuid;

            PlayerData player = g_PlayerDataArray[p];
            bool isDeployed = player.isDeployed(currCard);
            if (isDeployed){
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
                minimapSafeClickable(system, 
                                    posX + 0.06, btnPosY + 0.035, 0.1, 0.055,
                                    "",
                                    cardParams,
                                    [](int p = 1, ref Parameters parameters) -> void {
                        g_shop.deploy(p, parameters.ints[0]);
                    }
                );
                createButton(system, posX - 0.06, btnPosY, "SELL");
                createButton(system, posX + 0.06, btnPosY, "DEPLOY");
            }
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
}

void renderShop(ref UiSystem system, int p = 1){
    renderDraws(system, p);
    renderBench(system, p);

    string[] buttonNames = new string(0, "");
    buttonNames.add("DRAW");
    buttonNames.add("BUY XP");
    float drawPosx = -0.5;
    float yOffset = 0.075;
    float drawPosYStart = -0.325;

    float drawPosY = drawPosYStart;
    for(int i = 0; i < buttonNames.size(); i++) {
        createButton(system, drawPosx, drawPosY, buttonNames[i]);
        drawPosY = drawPosY - yOffset;
    }

    drawPosY = drawPosYStart;
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.draw(p);
        }
    );
    drawPosY = drawPosY - yOffset;
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.buyXP(p);
        }
    );
    drawPosY = drawPosY - yOffset;

    float closeBtnPosX = drawPosx - 0.125;
    createButton(system, closeBtnPosX, drawPosYStart, "EXIT SHOP");
    minimapSafeClickable(system, 
                        closeBtnPosX, drawPosYStart + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            closeShop(p);
        }
    );

    g_shopNeedsRefresh[p] = false;
}

void openShop(int p = 1){
    UiSystem system = uiSystemArray[p];
    system.enter(false, true, 1000);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    renderShop(system, p);
    uiSystemArray[p] = system;
}

void refreshShop(int p = 1){
    if (g_shopNeedsRefresh[p] == true){
        UiSystem system = uiSystemArray[p];
        system.enter(false, true, 1000);
        if(trCurrentPlayer() == p){
            setUiVisible(false);
            trSetObscuredUnits(false);
        }
        renderShop(system, p);
        uiSystemArray[p] = system;
    }
}