include "card.xs";
include "deck.xs";
include "cardParameters.xs";

const int MAX_CARD_COPIES = 4;

void addCardIntoDeck(int age = 0, int cost = 1,
                    string protoName = "", string titleText = "", string hoverText = "", string iconPath = ""){
    CardParameters params;
    params.setCardParameters(age, cost, protoName, titleText, hoverText, iconPath);
    ProtoNameToCardParametersMap.put(protoName, params);
    for(int i = 0; i < MAX_CARD_COPIES; i++) {
        CardData card;
        switch(i){
            case 1: card.setCard(params, UPGRADE_HACK_ARMOR);
            case 2: card.setCard(params, UPGRADE_PIERCE_ARMOR);
            case 3: card.setCard(params, UPGRADE_SHIELDS);
            default: card.setCard(params, UPGRADE_HITPOINTS);
        }
        card.rerollRarity(0);
        g_shop.addCardIntoDeck(card);
    }
}

void initializeCardParametersMap(){
    // Age 1 Units
    addCardIntoDeck(0, 1,
                    "Militia", "Militia", "Militia",
                    "resources\\greek\\player_color\\units\\militia_icon.png"
                    );
    addCardIntoDeck(0, 100,
                    "Priest", "Priest", "Priest",
                    "resources\\egyptian\\player_color\\units\\priest_icon.png"
                    );
    addCardIntoDeck(0, 120,
                    "Pharaoh", "Pharaoh", "Pharaoh",
                    "resources\\egyptian\\player_color\\units\\pharaoh_icon.png"
                    );
    addCardIntoDeck(0, 100,
                    "OracleHero", "Oracle Hero", "Oracle Hero",
                    "resources\\atlantean\\player_color\\units\\oracle_icon.png"
                    );
    addCardIntoDeck(0, 105,
                    "Pioneer", "Pioneer", "Pioneer",
                    "resources\\chinese\\player_color\\units\\pioneer_icon.png"
                    );
    addCardIntoDeck(0, 50,
                    "Miko", "Miko", "Miko",
                    "resources\\japanese\\player_color\\units\\miko_icon.png"
                    );
    addCardIntoDeck(0, 45,
                    "QuimichinSpy", "Quimichin Spy", "Quimichin Spy",
                    "resources\\aztec\\player_color\\units\\quimchin_spy_icon.png"
                    );
    addCardIntoDeck(0, 33,
                    "Kitsune", "Kitsune", "Kitsune",
                    "resources\\japanese\\player_color\\units\\kitsune_icon.png"
                    );

    addCardIntoDeck(1, 100,
                    "Anubite", "Anubite", "Anubite",
                    "resources\\egyptian\\player_color\\units\\anubite_icon.png"
                    );
    addCardIntoDeck(1, 194,
                    "Minotaur", "Minotaur", "Minotaur",
                    "resources\\greek\\player_color\\units\\minotaur_icon.png"
                    );
    addCardIntoDeck(1, 194,
                    "Centaur", "Centaur", "Centaur",
                    "resources\\greek\\player_color\\units\\centaur_icon.png"
                    );
    addCardIntoDeck(1, 165,
                    "Wadjet", "Wadjet", "Wadjet",
                    "resources\\egyptian\\player_color\\units\\wadjet_icon.png"
                    );

    addCardIntoDeck(1, 90,
                    "Hoplite", "Hoplite", "Hoplite",
                    "resources\\greek\\player_color\\units\\hoplite_icon.png"
                    );
    addCardIntoDeck(1, 75,
                    "Spearman", "Spearman", "Spearman",
                    "resources\\egyptian\\player_color\\units\\spearman_icon.png"
                    );
    addCardIntoDeck(1, 70,
                    "Axeman", "Axeman", "Axeman",
                    "resources\\egyptian\\player_color\\units\\axeman_icon.png"
                    );

    addCardIntoDeck(1, 80,
                    "Toxotes", "Toxotes", "Toxotes",
                    "resources\\greek\\player_color\\units\\toxotes_icon.png"
                    );
    addCardIntoDeck(1, 70,
                    "Slinger", "Slinger", "Slinger",
                    "resources\\egyptian\\player_color\\units\\slinger_icon.png"
                    );

    addCardIntoDeck(2, 270,
                    "Behemoth", "Behemoth", "Behemoth",
                    "resources\\atlantean\\player_color\\units\\behemoth_icon.png"
                    );
    addCardIntoDeck(2, 275,
                    "Petrobolos", "Petrobolos", "Petrobolos",
                    "resources\\greek\\player_color\\units\\petrobolos_icon.png"
                    );
    addCardIntoDeck(2, 300,
                    "SiegeCrossbow", "Siege Crossbow", "Siege Crossbow",
                    "resources\\chinese\\player_color\\units\\siege_crossbow_icon.png"
                    );
    addCardIntoDeck(2, 95,
                    "Peltast", "Peltast", "Peltast",
                    "resources\\greek\\player_color\\units\\peltast_icon.png"
                    );
    addCardIntoDeck(2, 276,
                    "Hydra", "Hydra", "Hydra",
                    "resources\\greek\\player_color\\units\\hydra_icon.png"
                    );

    addCardIntoDeck(3, 380,
                    "Colossus", "Colossus", "Colossus",
                    "resources\\greek\\player_color\\units\\colossus_icon.png"
                    );
    addCardIntoDeck(3, 300,
                    "Ballista", "Ballista", "Ballista",
                    "resources\\norse\\player_color\\units\\ballista_icon.png"
                    );

    addCardIntoDeck(4, 500,
                    "SonOfOsiris", "SonOfOsiris", "SonOfOsiris",
                    "resources/egyptian/player_color/units/son_of_osiris_icon.png"
                    );
}