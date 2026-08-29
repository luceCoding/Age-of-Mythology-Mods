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

    addCardIntoDeck(0, 25,
                    "Militia", "Militia", "Militia",
                    "resources/greek/player_color/units/militia_icon.png"
                    );
    addCardIntoDeck(0, 100,
                    "Priest", "Priest", "Priest",
                    "resources/egyptian/player_color/units/priest_icon.png"
                    );
    addCardIntoDeck(0, 120,
                    "Pharaoh", "Pharaoh", "Pharaoh",
                    "resources/egyptian/player_color/units/pharaoh_icon.png"
                    );
    addCardIntoDeck(0, 100,
                    "OracleHero", "Oracle Hero", "Oracle Hero",
                    "resources/atlantean/player_color/units/oracle_icon.png"
                    );
    addCardIntoDeck(0, 105,
                    "Pioneer", "Pioneer", "Pioneer",
                    "resources/chinese/player_color/units/pioneer_icon.png"
                    );
    addCardIntoDeck(0, 50,
                    "Miko", "Miko", "Miko",
                    "resources/japanese/player_color/units/miko_icon.png"
                    );
    addCardIntoDeck(0, 45,
                    "QuimichinSpy", "Quimichin Spy", "Quimichin Spy",
                    "resources/aztec/player_color/units/quimchin_spy_icon.png"
                    );
    addCardIntoDeck(0, 33,
                    "Kitsune", "Kitsune", "Kitsune",
                    "resources/japanese/player_color/units/kitsune_icon.png"
                    );
    addCardIntoDeck(0, 80,
                    "Berserk", "Berserk", "Berserk",
                    "resources/norse/player_color/units/berserk_icon.png"
                    );
    addCardIntoDeck(0, 120,
                    "Hersir", "Hersir", "Hersir",
                    "resources/norse/player_color/units/hersir_icon.png"
                    );
    addCardIntoDeck(0, 100,
                    "WarriorPriest", "Warrior Priest", "WarriorPriest",
                    "resources/aztec/player_color/units/warrior_priest_icon.png"
                    );
    addCardIntoDeck(0, 75,
                    "Spearman", "Spearman", "Spearman",
                    "resources/egyptian/player_color/units/spearman_icon.png"
                    );
    addCardIntoDeck(0, 70,
                    "Axeman", "Axeman", "Axeman",
                    "resources/egyptian/player_color/units/axeman_icon.png"
                    );
    addCardIntoDeck(0, 70,
                    "Slinger", "Slinger", "Slinger",
                    "resources/egyptian/player_color/units/slinger_icon.png"
                    );

    addCardIntoDeck(1, 125,
                    "CaravanGreek", "Caravan", "Caravan",
                    "resources/greek/player_color/units/caravan_greek_icon.png"
                    );
    addCardIntoDeck(2, 205,
                    "PiXiu", "PiXiu", "PiXiu",
                    "resources/chinese/player_color/units/pixiu_icon.png"
                    );

    addCardIntoDeck(1, 70,
                    "TlamanihSpearman", "Tlamanih Spearman", "Tlamanih Spearman",
                    "resources/aztec/player_color/units/tlamanih_spearman_icon.png"
                    );
    addCardIntoDeck(1, 80,
                    "TequihuaArcher", "Tequihua Archer", "Tequihua Archer",
                    "resources/aztec/player_color/units/tequihua_archer_icon.png"
                    );
    addCardIntoDeck(1, 90,
                    "CoyoteWarrior", "Coyote Warrior", "Coyote Warrior",
                    "resources/aztec/player_color/units/coyote_warrior_icon.png"
                    );
    addCardIntoDeck(1, 130,
                    "OcelotlWarrior", "Ocelotl Warrior", "Ocelotl Warrior",
                    "resources/aztec/player_color/units/ocelotl_warrior_icon.png"
                    );

    addCardIntoDeck(1, 90,
                    "Hoplite", "Hoplite", "Hoplite",
                    "resources/greek/player_color/units/hoplite_icon.png"
                    );
    addCardIntoDeck(1, 80,
                    "Toxotes", "Toxotes", "Toxotes",
                    "resources/greek/player_color/units/toxotes_icon.png"
                    );
    addCardIntoDeck(1, 120,
                    "Hippeus", "Hippeus", "Hippeus",
                    "resources/greek/player_color/units/hippeus_icon.png"
                    );
    addCardIntoDeck(1, 100,
                    "ShadeSPC", "Suicide Shade", "Suicide Shade",
                    "resources/spc/player_color/units/shade_spc_icon.png"
                    );
    addCardIntoDeck(1, 194,
                    "Minotaur", "Minotaur", "Minotaur",
                    "resources/greek/player_color/units/minotaur_icon.png"
                    );
    addCardIntoDeck(1, 194,
                    "Centaur", "Centaur", "Centaur",
                    "resources/greek/player_color/units/centaur_icon.png"
                    );

    addCardIntoDeck(1, 165,
                    "Wadjet", "Wadjet", "Wadjet",
                    "resources/egyptian/player_color/units/wadjet_icon.png"
                    );
    addCardIntoDeck(1, 100,
                    "Anubite", "Anubite", "Anubite",
                    "resources/egyptian/player_color/units/anubite_icon.png"
                    );

    addCardIntoDeck(1, 95,
                    "Hirdman", "Hirdman", "Hirdman",
                    "resources/norse/player_color/units/hirdman_icon.png"
                    );
    addCardIntoDeck(1, 90,
                    "ThrowingAxeman", "Throwing Axeman", "Throwing Axeman",
                    "resources/norse/player_color/units/throwing_axeman_icon.png"
                    );
    addCardIntoDeck(1, 90,
                    "RaidingCavalry", "Raiding Cavalry", "Raiding Cavalry",
                    "resources/norse/player_color/units/raiding_cavalry_icon.png"
                    );
    addCardIntoDeck(1, 218,
                    "Valkyrie", "Valkyrie", "Valkyrie",
                    "resources/norse/player_color/units/valkyrie_icon.png"
                    );
    addCardIntoDeck(1, 165,
                    "Einheri", "Einheri", "Einheri",
                    "resources/norse/player_color/units/einheri_icon.png"
                    );
    addCardIntoDeck(1, 175,
                    "Troll", "Troll", "Troll",
                    "resources/norse/player_color/units/troll_icon.png"
                    );
    addCardIntoDeck(1, 214,
                    "Draugr", "Draugr", "Draugr",
                    "resources/norse_freyr/player_color/units/draugr_icon.png"
                    );

    addCardIntoDeck(1, 95,
                    "Katapeltes", "Katapeltes", "Katapeltes",
                    "resources/atlantean/player_color/units/katapeltes_icon.png"
                    );
    addCardIntoDeck(1, 85,
                    "Turma", "Turma", "Turma",
                    "resources/atlantean/player_color/units/turma_icon.png"
                    );
    addCardIntoDeck(1, 215,
                    "Cheiroballista", "Cheiroballista", "Cheiroballista",
                    "resources/atlantean/player_color/units/cheiroballista_icon.png"
                    );
    addCardIntoDeck(1, 137,
                    "Caladria", "Caladria", "Caladria",
                    "resources/atlantean/player_color/units/caladria_icon.png"
                    );
    addCardIntoDeck(1, 96,
                    "Automaton", "Automaton", "Automaton",
                    "resources/atlantean/player_color/units/automaton_icon.png"
                    );
    addCardIntoDeck(1, 137,
                    "Servant", "Servant", "Servant",
                    "resources/atlantean/player_color/units/servant_icon.png"
                    );

    addCardIntoDeck(1, 85,
                    "FireArcher", "Fire Archer", "Fire Archer",
                    "resources/chinese/player_color/units/fire_archer_icon.png"
                    );
    addCardIntoDeck(1, 85,
                    "DaoSwordsman", "Dao Swordsman", "Dao Swordsman",
                    "resources/chinese/player_color/units/dao_swordsman_icon.png"
                    );
    addCardIntoDeck(1, 85,
                    "GeHalberdier", "GeHalberdier", "GeHalberdier",
                    "resources/chinese/player_color/units/ge_halberdier_icon.png"
                    );
    addCardIntoDeck(1, 85,
                    "WuzuJavelineer", "Wuzu Javelineer", "Wuzu Javelineer",
                    "resources/chinese/player_color/units/wuzu_javelineer_icon.png"
                    );

    addCardIntoDeck(1, 80,
                    "YariSpearman", "Yari Spearman", "Yari Spearman",
                    "resources/japanese/player_color/units/yari_spearman_icon.png"
                    );
    addCardIntoDeck(1, 90,
                    "YumiArcher", "Yumi Archer", "Yumi Archer",
                    "resources/japanese/player_color/units/yumi_archer_icon.png"
                    );
    addCardIntoDeck(1, 115,
                    "NaginataRider", "Naginata Rider", "Naginata Rider",
                    "resources/japanese/player_color/units/naginata_rider_icon.png"
                    );
    addCardIntoDeck(1, 180,
                    "Samurai", "Samurai", "Samurai",
                    "resources/japanese/player_color/units/samurai_icon.png"
                    );
    addCardIntoDeck(1, 112,
                    "Bushi", "Bushi", "Bushi",
                    "resources/japanese/player_color/units/bushi_icon.png"
                    );
    addCardIntoDeck(1, 224,
                    "OnnaMusha", "Onna Musha", "Onna Musha",
                    "resources/japanese/player_color/units/onna_musha_icon.png"
                    );

    addCardIntoDeck(2, 125,
                    "EagleWarrior", "Eagle Warrior", "Eagle Warrior",
                    "resources/aztec/player_color/units/eagle_warrior_icon.png"
                    );
    addCardIntoDeck(2, 200,
                    "Otontin", "Otontin Smasher", "Otontin Smasher",
                    "resources/aztec/player_color/units/otontin_icon.png"
                    );
    addCardIntoDeck(2, 135,
                    "ShornOne", "Shorn One", "Shorn One",
                    "resources/aztec/player_color/units/shorn_one_icon.png"
                    );

    addCardIntoDeck(2, 140,
                    "ChariotArcher", "Chariot Archer", "Chariot Archer",
                    "resources/egyptian/player_color/units/chariot_archer_icon.png"
                    );
    addCardIntoDeck(2, 120,
                    "CamelRider", "Camel Rider", "Camel Rider",
                    "resources/egyptian/player_color/units/camel_rider_icon.png"
                    );
    addCardIntoDeck(2, 250,
                    "WarElephant", "War Elephant", "War Elephant",
                    "resources/egyptian/player_color/units/war_elephant_icon.png"
                    );

    addCardIntoDeck(2, 162,
                    "Daimyo", "Daimyo", "Daimyo",
                    "resources/japanese/player_color/units/daimyo_icon.png"
                    );
    addCardIntoDeck(2, 150,
                    "Shinobi", "Shinobi", "Shinobi",
                    "resources/japanese/player_color/units/shinobi_icon.png"
                    );
    addCardIntoDeck(2, 275,
                    "Oyumi", "Oyumi", "Oyumi",
                    "resources/japanese/player_color/units/oyumi_icon.png"
                    );

    addCardIntoDeck(2, 120,
                    "Godi", "Godi", "Godi",
                    "resources/norse/player_color/units/godi_icon.png"
                    );
    addCardIntoDeck(2, 130,
                    "Jarl", "Jarl", "Jarl",
                    "resources/norse/player_color/units/jarl_icon.png"
                    );
    addCardIntoDeck(2, 115,
                    "Huskarl", "Huskarl", "Huskarl",
                    "resources/norse/player_color/units/huskarl_icon.png"
                    );
    addCardIntoDeck(2, 250,
                    "PortableRam", "Portable Ram", "Portable Ram",
                    "resources/norse/player_color/units/portable_ram_icon.png"
                    );
    addCardIntoDeck(2, 277,
                    "BattleBoar", "Battle Boar", "Battle Boar",
                    "resources/norse/player_color/units/battle_boar_icon.png"
                    );
    addCardIntoDeck(2, 222,
                    "FrostGiant", "Frost Giant", "Frost Giant",
                    "resources/norse/player_color/units/frost_giant_icon.png"
                    );

    addCardIntoDeck(2, 130,
                    "Destroyer", "Destroyer", "Destroyer",
                    "resources/atlantean/player_color/units/destroyer_icon.png"
                    );
    addCardIntoDeck(2, 95,
                    "Arcus", "Arcus", "Arcus",
                    "resources/atlantean/player_color/units/arcus_icon.png"
                    );
    addCardIntoDeck(2, 115,
                    "Contarius", "Contarius", "Contarius",
                    "resources/atlantean/player_color/units/contarius_icon.png"
                    );

    addCardIntoDeck(2, 270,
                    "Behemoth", "Behemoth", "Behemoth",
                    "resources/atlantean/player_color/units/behemoth_icon.png"
                    );

    addCardIntoDeck(2, 275,
                    "Petrobolos", "Petrobolos", "Petrobolos",
                    "resources/greek/player_color/units/petrobolos_icon.png"
                    );
                
    addCardIntoDeck(2, 300,
                    "SiegeCrossbow", "Siege Crossbow", "Siege Crossbow",
                    "resources/chinese/player_color/units/siege_crossbow_icon.png"
                    );

    //addCardIntoDeck(2, 354,
    //                "Icarus", "Icarus", "Icarus",
    //                "resources/greek/player_color/units/icarus_icon.png"
    //                );
    addCardIntoDeck(2, 110,
                    "Prodromos", "Prodromos", "Prodromos",
                    "resources/greek/player_color/units/prodromos_icon.png"
                    );
    addCardIntoDeck(2, 95,
                    "Peltast", "Peltast", "Peltast",
                    "resources/greek/player_color/units/peltast_icon.png"
                    );
    addCardIntoDeck(2, 85,
                    "Hypaspist", "Hypaspist", "Hypaspist",
                    "resources/greek/player_color/units/hypaspist_icon.png"
                    );
    addCardIntoDeck(2, 276,
                    "Hydra", "Hydra", "Hydra",
                    "resources/greek/player_color/units/hydra_icon.png"
                    );

    addCardIntoDeck(2, 300,
                    "CangJie", "CangJie", "CangJie",
                    "resources/spc/player_color/units/cangjie_icon.png"
                    );
    addCardIntoDeck(2, 250,
                    "Sage", "Sage", "Sage",
                    "resources/chinese/player_color/units/sage_icon.png"
                    );
    addCardIntoDeck(2, 145,
                    "ChuKoNu", "ChuKoNu", "ChuKoNu",
                    "resources/chinese/player_color/units/chu_ko_nu_icon.png"
                    );
    addCardIntoDeck(2, 130,
                    "WhiteHorseCavalry", "White Horse Cavalry", "White Horse Cavalry",
                    "resources/chinese/player_color/units/white_horse_cavalry_icon.png"
                    );
    addCardIntoDeck(2, 299,
                    "TaoWu", "TaoWu", "TaoWu",
                    "resources/chinese/player_color/units/taowu_icon.png"
                    );

    addCardIntoDeck(2, 120,
                    "YumiHorseArcher", "Yumi Horse Archer", "Yumi Horse Archer",
                    "resources/japanese/player_color/units/yumi_horse_archer_icon.png"
                    );

    addCardIntoDeck(2, 130,
                    "Tanuki", "Tanuki", "Tanuki",
                    "resources/japanese/player_color/units/tanuki_icon.png"
                    );

    addCardIntoDeck(3, 500,
                    "Reginleif", "Reginleif", "Reginleif",
                    "resources/spc/player_color/units/reginleif_icon.png"
                    );

    addCardIntoDeck(3, 150,
                    "JaguarRider", "Jaguar Rider", "Jaguar Rider",
                    "resources/aztec/player_color/units/jaguar_rider_icon.png"
                    );

    addCardIntoDeck(3, 130,
                    "Fanatic", "Fanatic", "Fanatic",
                    "resources/atlantean/player_color/units/fanatic_icon.png"
                    );

    addCardIntoDeck(3, 508,
                    "LiJing", "LiJing", "LiJing",
                    "resources/chinese/player_color/units/li_jing_icon.png"
                    );
    addCardIntoDeck(3, 508,
                    "WenZhong", "WenZhong", "WenZhong",
                    "resources/chinese/player_color/units/wen_zhong_icon.png"
                    );
    addCardIntoDeck(3, 508,
                    "YangJian", "Yang Jian", "Yang Jian",
                    "resources/chinese/player_color/units/yang_jian_icon.png"
                    );

    addCardIntoDeck(3, 145,
                    "TigerCavalry", "Tiger Cavalry", "Tiger Cavalry",
                    "resources/chinese/player_color/units/tiger_cavalry_icon.png"
                    );
    addCardIntoDeck(3, 430,
                    "Asura", "Asura", "Asura",
                    "resources/japanese/player_color/units/asura_icon.png"
                    );

    addCardIntoDeck(3, 160,
                    "AmazonArcher", "Amazon Archer", "Amazon Archer",
                    "resources/greek/player_color/units/amazonarcher_icon.png"
                    );
    addCardIntoDeck(3, 160,
                    "Gastraphetoros", "Gastraphetoros", "Gastraphetoros",
                    "resources/greek/player_color/units/gastraphetoros_icon.png"
                    );
    addCardIntoDeck(3, 140,
                    "Hetairos", "Hetairos", "Hetairos",
                    "resources/greek/player_color/units/hetairos_icon.png"
                    );
    addCardIntoDeck(3, 120,
                    "Myrmidon", "Myrmidon", "Myrmidon",
                    "resources/greek/player_color/units/myrmidon_icon.png"
                    );
    addCardIntoDeck(3, 406,
                    "Perseus", "Perseus", "Perseus",
                    "resources/greek/player_color/units/perseus_icon.png"
                    );
    addCardIntoDeck(3, 406,
                    "Polyphemus", "Polyphemus", "Polyphemus",
                    "resources/greek/player_color/units/polyphemus_icon.png"
                    );
    addCardIntoDeck(3, 406,
                    "Bellerophon", "Bellerophon", "Bellerophon",
                    "resources/greek/player_color/units/bellerophon_icon.png"
                    );
    addCardIntoDeck(3, 380,
                    "Colossus", "Colossus", "Colossus",
                    "resources/greek/player_color/units/colossus_icon.png"
                    );
    addCardIntoDeck(3, 500,
                    "Helepolis", "Helepolis", "Helepolis",
                    "resources/greek/player_color/units/helepolis_icon.png"
                    );

    addCardIntoDeck(3, 300,
                    "Ballista", "Ballista", "Ballista",
                    "resources/norse/player_color/units/ballista_icon.png"
                    );
    addCardIntoDeck(3, 300,
                    "Mummy", "Mummy", "Mummy",
                    "resources/egyptian/player_color/units/mummy_icon.png"
                    );
    addCardIntoDeck(3, 248,
                    "HunDun", "HunDun", "HunDun",
                    "resources/chinese/player_color/units/hundun_icon.png"
                    );
    addCardIntoDeck(3, 255,
                    "Onmyoji", "Onmyoji", "Onmyoji",
                    "resources/japanese/player_color/units/onmyoji_icon.png"
                    );
    addCardIntoDeck(3, 180,
                    "SamuraiHatamoto", "Hatamoto Samurai", "Hatamoto Samurai",
                    "resources/japanese/player_color/units/samurai_icon.png"
                    );

    addCardIntoDeck(4, 550,
                    "SonOfOsiris", "Son Of Osiris", "Son Of Osiris",
                    "resources/egyptian/player_color/units/son_of_osiris_icon.png"
                    );
    addCardIntoDeck(4, 450,
                    "Arkantos", "Arkantos", "Arkantos",
                    "resources/spc/player_color/units/arkantos_icon.png"
                    );
    addCardIntoDeck(4, 750,
                    "Nidhogg", "Nidhogg", "Nidhogg",
                    "resources/norse/player_color/units/nidhogg_icon.png"
                    );
    addCardIntoDeck(4, 750,
                    "YingLong", "Ying Long", "Ying Long",
                    "resources/chinese/player_color/units/yinglong_icon.png"
                    );
    addCardIntoDeck(4, 600,
                    "SiegeCrossbowSPC", "Giant Siege Crossbow", "Giant Siege Crossbow",
                    "resources/chinese/player_color/units/siege_crossbow_icon.png"
                    );
    addCardIntoDeck(4, 650,
                    "LivingPoseidonStatue", "Living Poseidon Statue", "Living Poseidon Statue",
                    "resources/spc/player_color/units/living_poseidon_statue_icon.png"
                    );
    addCardIntoDeck(4, 450,
                    "Yasuko", "Yasuko", "Yasuko",
                    "resources/spc/player_color/units/yasuko_icon.png"
                    );
}