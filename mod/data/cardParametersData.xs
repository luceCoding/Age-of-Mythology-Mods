include "card.xs";
include "deck.xs";
include "cardParameters.xs";

const int MAX_CARD_COPIES = 7;

void addCardIntoDeck(int cType = -1, int age = 0, int cost = 1,
                    string protoName = "", string titleText = "", string hoverText = "", string iconPath = ""){
    CardParameters params;
    params.setCardParameters(cType, age, cost, protoName, titleText, hoverText, iconPath);
    cTypeToCardParametersMap.put(cType, params);
    for(int i = 0; i < MAX_CARD_COPIES; i++) {
        CardData card;
        card.setCard(params, i);
        g_shop.addCardIntoDeck(card);
    }
}

void initializeCardParametersMap(){
    // Age 1 Units
    addCardIntoDeck(cUnitTypeMilitia, 0, 1,
                    "Militia", "Militia", "Militia",
                    "resources\\greek\\player_color\\units\\militia_icon.png"
                    );
    addCardIntoDeck(cUnitTypePriest, 0, 2,
                    "Priest", "Priest", "Priest",
                    "resources\\egyptian\\player_color\\units\\priest_icon.png"
                    );
    addCardIntoDeck(cUnitTypePharaoh, 0, 3,
                    "Pharaoh", "Pharaoh", "Pharaoh",
                    "resources\\egyptian\\player_color\\units\\pharaoh_icon.png"
                    );
    addCardIntoDeck(cUnitTypeOracle, 0, 1,
                    "Oracle", "Oracle", "Oracle",
                    "resources\\atlantean\\player_color\\units\\oracle_icon.png"
                    );
    addCardIntoDeck(cUnitTypePioneer, 0, 2,
                    "Pioneer", "Pioneer", "Pioneer",
                    "resources\\chinese\\player_color\\units\\pioneer_icon.png"
                    );
    addCardIntoDeck(cUnitTypeMiko, 0, 2,
                    "Miko", "Miko", "Miko",
                    "resources\\japanese\\player_color\\units\\miko_icon.png"
                    );
    addCardIntoDeck(cUnitTypeQuimichinSpy, 0, 2,
                    "QuimichinSpy", "Quimichin Spy", "Quimichin Spy",
                    "resources\\aztec\\player_color\\units\\quimchin_spy_icon.png"
                    );
}