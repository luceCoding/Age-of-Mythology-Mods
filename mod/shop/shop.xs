include "data/deck.xs";
include "data/draw.xs";
include "data/bench.xs";
include "data/card.xs";

const int TOTAL_AGES = 5;
IntToCardParameterscTypeToCardParametersMap cTypeToCardParametersMap;

class Shop {
    DeckData[] m_decks = default;
    BenchData[] m_benches = default;
    DrawData[] m_currDraws = default;
    bool[] m_needsRefresh = default;

    void init(){
        m_decks = new DeckData(TOTAL_AGES);
        m_benches = new BenchData(cNumberPlayers);
        m_currDraws = new DrawData(cNumberPlayers);
        m_needsRefresh = new bool(cNumberPlayers, false);
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
        float startX = -0.5;
        float XOffset = 0.25;
        DrawData currDraw = m_currDraws[p];
        CardData[] currCards = currDraw.m_cardArray;
        for(int i = 0; i < currCards.size(); i++) {
            CardData currCard = currCards[i];
            int cType = currCard.m_cType;
            CardParameters params = cTypeToCardParametersMap.get(cType);
            string iconPath = params.getIconPath();
            minimapSafeClickable(system, 
                                startX, 0.2, 0.1, 0.1,
                                "<icon=(128)(" + iconPath + ")>",
                                params.m_params,
                                [](int p = 1, ref Parameters parameters) -> void {
                    trChatSend(1, "Clicked " + parameters.strings[1]);
                }
            );
            startX = startX + XOffset;
        }
    }
};

Shop g_shop;

void renderShop(ref UiSystem system, int p = 1){
    g_shop.renderDraws(system, p);
    // Render draw button
    minimapSafeClickable(system, 
                        0, 0, 0.1, 0.1,
                        "<icon=(128)(egyptian\\player_color\\units\\mummy_icon.png)>",
                        EMPTY_PARAMETERS,
                        [](int p = 1, ref Parameters parameters) -> void {
            g_shop.drawFromDeck(0, p);
            g_shop.m_needsRefresh[p] = true;
        }
    );
    g_shop.m_needsRefresh[p] = false;
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
    if (g_shop.m_needsRefresh[p] == true){
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