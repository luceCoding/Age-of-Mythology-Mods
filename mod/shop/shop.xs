include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";

const int TOTAL_AGES = 5;
int[] g_selectedUUIDs = default;
bool[] g_shopNeedsRefresh = default;

class Shop {
    DeckData[] m_decks = default;
    DrawData[] m_currDraws = default;
    BenchData[] m_benches = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_currDraws = new DrawData(cNumberPlayers);
        m_benches = new BenchData(cNumberPlayers);
        g_selectedUUIDs = new int(cNumberPlayers, -1);
        g_shopNeedsRefresh = new bool(cNumberPlayers, false);
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
            bool hasAddedCard = currDraw.addCard(drawnCard);
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
        float iconMultiper = 1.0;
        if (uuid == selectedUUID){
            iconMultiper = 1.25;
        }

        CardParameters params = currCard.getCardParameters();
        string iconPath = params.getIconPath();
        Parameters cardParams = createParametersCopy(params);
        cardParams.ints[0] = uuid;
        minimapSafeClickable(system, 
                            posX, posY, 0.1, 0.12,
                            getIconPathFormat(iconPath, 128.0 * iconMultiper),
                            cardParams,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_selectedUUIDs[p] = parameters.ints[0];
                g_shopNeedsRefresh[p] = true;
                log(3, "Player " + p + " clicked " + parameters.strings[2] + " " + parameters.ints[0]);
            }
        );

        // Age Icon
        int age = params.getAge();
        float agePosX = posX - 0.045 * iconMultiper;
        float agePoxY = posY + 0.09 * iconMultiper;
        int miniIconSize = 32.0 * iconMultiper;
        switch(age){
            case 0: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age1Small.png", miniIconSize));
            case 1: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age2Small.png", miniIconSize));
            case 2: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age3Small.png", miniIconSize));
            case 3: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age4Small.png", miniIconSize));
            case 4: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age5Small.png", miniIconSize));
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
        if (!(isBench)) {
            int cost = params.getCost();
            minimapSafeDisplay(system, posX, posY - 0.0275, cost + getIconPathFormat("resources/spectator/resource_icons/gold.png", 32));
        }

        // Title
        string title = params.getTitle();
        minimapSafeDisplay(system, posX, posY + 0.12 * iconMultiper, title);
    }

    void renderDraws(ref UiSystem system, int p = 1){
        float offsetX = 0.15;
        DrawData currDraw = m_currDraws[p];
        float posX = -((config_MAX_DRAWN_CARDS - 1) * offsetX) / 2.0;
        float posY = -0.35;
        CardData[] currCards = currDraw.m_cardArray;
        for(int i = 0; i < currCards.size(); i++) {
            CardData currCard = currCards[i];
            renderCard(system, currCard, p, posX, posY);
            posX = posX + offsetX;
        }
    }

    void renderBench(ref UiSystem system, int p = 1) {
        BenchData bench = m_benches[p];
        CardData[] currCards = bench.getCards();
        int totalCards = currCards.size();

        if (totalCards == 0) return;

        // Configurable layout parameters
        float offsetX = 0.15;
        float offsetY = 0.20;
        int maxCardsPerRow = 6;
        int maxRows = 3;

        // Determine row count dynamically (capped at 3)
        int numRows = (totalCards + maxCardsPerRow - 1) / maxCardsPerRow; // Ceiling division
        if (numRows > maxRows) numRows = maxRows;

        // Base cards per row (distributes remainders evenly across upper rows)
        int cardsPerRow = (totalCards + numRows - 1) / numRows;

        // Calculate vertical starting position (top row) to keep rows centered around Y = 0.0
        float startY = ((numRows - 1) * offsetY) / 2.0;

        for (int i = 0; i < totalCards; i++) {
            CardData currCard = currCards[i];

            // Determine row index (0 = top, 1 = middle, 2 = bottom) and index within that row
            int rowIndex = i / cardsPerRow;
            int indexInRow = i % cardsPerRow;

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

            renderCard(system, currCard, p, posX, posY + 0.1, true);
        }

        log(3, "Bench " + totalCards);
    }

    void draw(int p = 0){
        DrawData currDraw = m_currDraws[p];
        while(currDraw.getSize() > 0) {
            CardData removedCard = currDraw.removeCard(0);
            if (removedCard.getUuid() == g_selectedUUIDs[p]){
                g_selectedUUIDs[p] = -1; // Deselect card
            }
            if (removedCard.isNull() == false) {
                addCardIntoDeck(removedCard);
            }
        }
        for(int i = 0; i < config_MAX_DRAWN_CARDS; i++) {
            drawFromDeck(0, p);
        }
    }

    void buy(int p = 0){
        BenchData bench = m_benches[p];
        if (bench.getNumberOfCardsHeld() < MAX_CARDS_IN_BENCH){
            DrawData currDraw = m_currDraws[p];
            CardData removedCard = currDraw.removeCardByUUID(g_selectedUUIDs[p]);
            if (removedCard.isNull() == false){
                    bench.addCard(removedCard);
                    g_selectedUUIDs[p] = -1; // Deselect card
            }
        }
        g_shopNeedsRefresh[p] = true;
    }

    void sell(int p = 0){

    }

    void buyXP(int p = 0){

    }
};

Shop g_shop;

void renderShop(ref UiSystem system, int p = 1){
    g_shop.renderDraws(system, p);
    g_shop.renderBench(system, p);

    string[] buttonNames = new string(0, "");
    buttonNames.add("BUY");
    buttonNames.add("SELL");
    buttonNames.add("DRAW");
    buttonNames.add("BUY XP");
    float drawPosx = -0.5;
    float drawPosY = -0.25;
    float yOffset = 0.075;
    for(int i = 0; i < 4; i++) {
        // Render draw button
        minimapSafeDisplay(system, drawPosx, drawPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
        minimapSafeDisplay(system, drawPosx, drawPosY + 0.05, buttonNames[i]);
        drawPosY = drawPosY - yOffset;
    }

    drawPosx = -0.5;
    drawPosY = -0.25;
    yOffset = 0.075;
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.buy(p);
        }
    );
    drawPosY = drawPosY - yOffset;
    minimapSafeClickable(system, 
                        drawPosx, drawPosY + 0.035, 0.1, 0.055,
                        "",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.sell(p);
        }
    );
    drawPosY = drawPosY - yOffset;
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

    g_shopNeedsRefresh[p] = false;
}

void openShop(int p = 1){
    UiSystem system = uiSystemArray[p];
    system.enter(false, true, 1000);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    renderShop(system, 1);
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
        renderShop(system, 1);
        uiSystemArray[p] = system;
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