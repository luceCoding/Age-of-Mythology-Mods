include "card.xs";
include "deck.xs";
include "cardParameters.xs";

void addCardIntoDeck(int cType = -1, int age = 0, 
                    string titleText = "", string hoverText = "", string iconPath = ""){
    CardParameters params;
    params.setCardParameters(cType, age, titleText, hoverText, iconPath);
    cTypeToCardParametersMap.put(cType, params);
    CardData card;
    card.setCard(params);
    g_shop.addCardIntoDeck(card, age);
}

void initializeCardParametersMap(){
    // Age 1 Units
    addCardIntoDeck(cUnitTypeMilitia, 0,
                    "Militia", "Militia",
                    "resources\\greek\\player_color\\units\\militia_icon.png"
                    );
    addCardIntoDeck(cUnitTypePriest, 0,
                    "Priest", "Priest",
                    "resources\\egyptian\\player_color\\units\\priest_icon.png"
                    );
    addCardIntoDeck(cUnitTypePharaoh, 0,
                    "Pharaoh", "Pharaoh",
                    "resources\\egyptian\\player_color\\units\\pharaoh_icon.png"
                    );
}