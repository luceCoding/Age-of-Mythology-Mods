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
            case 1: card.setCard(params, puFIELD_PIERCE_ARMOR);
            case 2: card.setCard(params, puFIELD_SHIELDS);
            case 3: card.setCard(params, puFIELD_HITPOINTS);
            default: card.setCard(params, puFIELD_HACK_ARMOR);
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
    addCardIntoDeck(0, 2,
                    "Priest", "Priest", "Priest",
                    "resources\\egyptian\\player_color\\units\\priest_icon.png"
                    );
    addCardIntoDeck(0, 3,
                    "Pharaoh", "Pharaoh", "Pharaoh",
                    "resources\\egyptian\\player_color\\units\\pharaoh_icon.png"
                    );
    addCardIntoDeck(0, 1,
                    "OracleHero", "Oracle Hero", "Oracle Hero",
                    "resources\\atlantean\\player_color\\units\\oracle_icon.png"
                    );
    addCardIntoDeck(0, 2,
                    "Pioneer", "Pioneer", "Pioneer",
                    "resources\\chinese\\player_color\\units\\pioneer_icon.png"
                    );
    addCardIntoDeck(0, 2,
                    "Miko", "Miko", "Miko",
                    "resources\\japanese\\player_color\\units\\miko_icon.png"
                    );
    addCardIntoDeck(0, 2,
                    "QuimichinSpy", "Quimichin Spy", "Quimichin Spy",
                    "resources\\aztec\\player_color\\units\\quimchin_spy_icon.png"
                    );
    addCardIntoDeck(0, 2,
                    "Kitsune", "Kitsune", "Kitsune",
                    "resources\\japanese\\player_color\\units\\kitsune_icon.png"
                    );

    addCardIntoDeck(1, 2,
                    "Anubite", "Anubite", "Anubite",
                    "resources\\egyptian\\player_color\\units\\anubite_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Minotaur", "Minotaur", "Minotaur",
                    "resources\\greek\\player_color\\units\\minotaur_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Centaur", "Centaur", "Centaur",
                    "resources\\greek\\player_color\\units\\centaur_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Wadjet", "Wadjet", "Wadjet",
                    "resources\\egyptian\\player_color\\units\\wadjet_icon.png"
                    );

    addCardIntoDeck(1, 2,
                    "Hoplite", "Hoplite", "Hoplite",
                    "resources\\greek\\player_color\\units\\hoplite_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Spearman", "Spearman", "Spearman",
                    "resources\\egyptian\\player_color\\units\\spearman_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Axeman", "Axeman", "Axeman",
                    "resources\\egyptian\\player_color\\units\\axeman_icon.png"
                    );

    addCardIntoDeck(1, 2,
                    "Toxotes", "Toxotes", "Toxotes",
                    "resources\\greek\\player_color\\units\\toxotes_icon.png"
                    );
    addCardIntoDeck(1, 2,
                    "Slinger", "Slinger", "Slinger",
                    "resources\\egyptian\\player_color\\units\\slinger_icon.png"
                    );

    addCardIntoDeck(2, 2,
                    "Behemoth", "Behemoth", "Behemoth",
                    "resources\\atlantean\\player_color\\units\\behemoth_icon.png"
                    );
    addCardIntoDeck(2, 2,
                    "Petrobolos", "Petrobolos", "Petrobolos",
                    "resources\\greek\\player_color\\units\\petrobolos_icon.png"
                    );
    addCardIntoDeck(2, 2,
                    "SiegeCrossbow", "Siege Crossbow", "Siege Crossbow",
                    "resources\\chinese\\player_color\\units\\siege_crossbow_icon.png"
                    );
    addCardIntoDeck(2, 2,
                    "Peltast", "Peltast", "Peltast",
                    "resources\\greek\\player_color\\units\\peltast_icon.png"
                    );

    addCardIntoDeck(3, 2,
                    "Hydra", "Hydra", "Hydra",
                    "resources\\greek\\player_color\\units\\hydra_icon.png"
                    );
    addCardIntoDeck(3, 2,
                    "Colossus", "Colossus", "Colossus",
                    "resources\\greek\\player_color\\units\\colossus_icon.png"
                    );
    addCardIntoDeck(3, 2,
                    "Ballista", "Ballista", "Ballista",
                    "resources\\norse\\player_color\\units\\ballista_icon.png"
                    );
}