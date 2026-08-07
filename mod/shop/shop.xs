include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";

const int TOTAL_AGES = 5;
IntToCardParameterscTypeToCardParametersMap cTypeToCardParametersMap;
int[] g_selectedUUIDs = default;
bool[] g_shopNeedsRefresh = default;

class Shop {
    DeckData[] m_decks = default;
    DrawData[] m_currDraws = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_currDraws = new DrawData(cNumberPlayers);
        g_selectedUUIDs = new int(cNumberPlayers, -1);
        g_shopNeedsRefresh = new bool(cNumberPlayers, false);
    }

    void addCardIntoDeck(ref CardData card, int dIndex = 0){
        DeckData deck = m_decks[dIndex];
        deck.addCard(card);
        m_decks[dIndex] = deck;
    }

    void drawFromDeck(int d = 0, int p = 0){
        DeckData deck = m_decks[d];
        DrawData currDraw = m_currDraws[p];
        CardData drawnCard = deck.drawRandomCard();
        if (drawnCard.isNull() == false){
            bool hasAddedCard = currDraw.addCard(drawnCard);
            if (hasAddedCard == false){
                deck.addCard(drawnCard);
                m_decks[0] = deck;
                log(3, "Failed to draw a card for player " + p);
            }
            else {
                m_currDraws[p] = currDraw;
                log(3, "Drew a card for player " + p);
            }
        }
    }

    void renderDraws(ref UiSystem system, int p = 1){
        float posX = -0.3;
        float posY = -0.35;
        float offsetX = 0.15;
        DrawData currDraw = m_currDraws[p];
        CardData[] currCards = currDraw.m_cardArray;
        for(int i = 0; i < currCards.size(); i++) {
            CardData currCard = currCards[i];
            int cType = currCard.m_cType;
            CardParameters params = cTypeToCardParametersMap.get(cType);

            // Main Icon
            int additionalSize = 0;
            float additionalYOffset = 0;
            int uuid = currCard.getUuid();
            int selectedUUID = g_selectedUUIDs[p];
            if (uuid == selectedUUID){
                additionalSize = additionalSize + 25;
                additionalYOffset = 0.025;
            }

            string iconPath = params.getIconPath();
            Parameters cardParams = createParameters();
            for(int j = 0; j < params.m_params.ints.size(); j++) {
                cardParams.ints.add(params.m_params.ints[j]);
            }
            for(int j = 0; j < params.m_params.strings.size(); j++) {
                cardParams.strings.add(params.m_params.strings[j]);
            }
            cardParams.ints[0] = uuid;
            minimapSafeClickable(system, 
                                posX, posY, 0.1, 0.12,
                                getIconPathFormat(iconPath, 128 + additionalSize),
                                cardParams,
                                [](int p = 1, ref Parameters parameters) -> void {
                    g_selectedUUIDs[p] = parameters.ints[0];
                    g_shopNeedsRefresh[p] = true;
                    log(3, "Player " + p + " clicked " + parameters.strings[2] + " " + parameters.ints[0]);
                }
            );

            // Age Icon
            int age = params.getAge();
            float agePosX = posX - 0.045;
            float agePoxY = posY + 0.09;
            int ageIconSize = 32 + additionalSize;
            switch(age){
                case 0: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age1Small.png", ageIconSize));
                case 1: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age2Small.png", ageIconSize));
                case 2: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age3Small.png", ageIconSize));
                case 3: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age4Small.png", ageIconSize));
                case 4: minimapSafeDisplay(system, agePosX, agePoxY, getIconPathFormat("resources/postgame/timeline/Icon_Age5Small.png", ageIconSize));
            }

            // Cost
            int cost = params.getCost();
            minimapSafeDisplay(system, posX, posY - 0.0275, cost + getIconPathFormat("resources/spectator/resource_icons/gold.png", 32));

            // Title
            string title = params.getTitle();
            minimapSafeDisplay(system, posX, posY + 0.12 + additionalYOffset, title);

            posX = posX + offsetX;
        }
    }
};

Shop g_shop;

void renderShop(ref UiSystem system, int p = 1){
    g_shop.renderDraws(system, p);

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
        minimapSafeClickable(system, 
                            drawPosx, drawPosY + 0.035, 0.1, 0.055,
                            "",
                            EMPTY_PARAMETERS,
                            [](int p = 1, ref Parameters parameters) -> void {
                g_shop.drawFromDeck(0, p);
                g_shopNeedsRefresh[p] = true;
            }
        );
        minimapSafeDisplay(system, drawPosx, drawPosY + 0.05, buttonNames[i]);
        drawPosY = drawPosY - yOffset;
    }
    g_shopNeedsRefresh[p] = false;
    log(3, "Shop rendered for player " + p);
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