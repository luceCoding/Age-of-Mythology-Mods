include "card.xs";
include "deck.xs";
include "cardParameters.xs";

void addCardIntoDeck(int age = 0, int protoID = -1, int cost = -1, int upgrade = -1, int rarity = -1, bool addSockets = true){
    CardParameters params;
    params.setCardParameters(age, protoID, cost);
    string protoName = kbProtoUnitGetName(protoID);
    ProtoNameToCardParametersMap.put(protoName, params);
    CardData card;
    card.setCard(params, upgrade, addSockets);
    if (rarity == -1){
        card.rerollRarity(0);
    }
    else {
        card.setRarity(rarity);
    }
    g_shop.addCardIntoDeck(card);
}

void addCardsIntoDeck(int age = 0, int protoID = -1, int cost = -1){
    int upgrade = -1;
    for(int i = 0; i < MAX_CARD_COPIES; i++) {
        switch(i){
            case 1: upgrade = UPGRADE_HACK_ARMOR;
            case 2: upgrade = UPGRADE_PIERCE_ARMOR;
            case 3: upgrade = UPGRADE_SHIELDS;
            default: upgrade = UPGRADE_HITPOINTS;
        }
        addCardIntoDeck(age, protoID, cost, upgrade, -1, true);
    }
}

void initializeCardParametersMap(){

    addCardsIntoDeck(0, cUnitTypeOrpheus);
    addCardsIntoDeck(0, cUnitTypeMilitia);
    addCardsIntoDeck(0, cUnitTypePriest);
    addCardsIntoDeck(0, cUnitTypePharaoh, 120);
    addCardsIntoDeck(0, cUnitTypeOracleHero);
    addCardsIntoDeck(0, cUnitTypePioneer);
    addCardsIntoDeck(0, cUnitTypeMiko);
    addCardsIntoDeck(0, cUnitTypeQuimichinSpy);
    addCardsIntoDeck(0, cUnitTypeKitsune);
    addCardsIntoDeck(0, cUnitTypeBerserk);
    addCardsIntoDeck(0, cUnitTypeHersir);
    addCardsIntoDeck(0, cUnitTypeWarriorPriest);
    addCardsIntoDeck(0, cUnitTypeSpearman);
    addCardsIntoDeck(0, cUnitTypeAxeman);
    addCardsIntoDeck(0, cUnitTypeSlinger);

    addCardsIntoDeck(1, cUnitTypeCaravanGreek);
    addCardsIntoDeck(2, cUnitTypePiXiu);

    addCardsIntoDeck(1, cUnitTypeTlamanihSpearman);
    addCardsIntoDeck(1, cUnitTypeTequihuaArcher);
    addCardsIntoDeck(1, cUnitTypeOcelotlWarrior);
    addCardsIntoDeck(1, cUnitTypeChaneque);
    addCardsIntoDeck(1, cUnitTypeCentzonTotochtin);
    addCardsIntoDeck(1, cUnitTypeTeixiptlaHuitz, 130);
    addCardsIntoDeck(1, cUnitTypeTeixiptlaTezca, 130);
    addCardsIntoDeck(1, cUnitTypeTeixiptlaQuetz, 130);

    addCardsIntoDeck(1, cUnitTypeHoplite);
    addCardsIntoDeck(1, cUnitTypeToxotes);
    addCardsIntoDeck(1, cUnitTypeHippeus);
    addCardsIntoDeck(1, cUnitTypeShadeSPC, 100);
    addCardsIntoDeck(1, cUnitTypeMinotaur);
    addCardsIntoDeck(1, cUnitTypeCentaur);

    addCardsIntoDeck(1, cUnitTypeWadjet);
    addCardsIntoDeck(1, cUnitTypeAnubite);

    addCardsIntoDeck(1, cUnitTypeHirdman);
    addCardsIntoDeck(1, cUnitTypeThrowingAxeman);
    addCardsIntoDeck(1, cUnitTypeRaidingCavalry);
    addCardsIntoDeck(1, cUnitTypeValkyrie);
    addCardsIntoDeck(1, cUnitTypeEinheri);
    addCardsIntoDeck(1, cUnitTypeTroll);
    addCardsIntoDeck(1, cUnitTypeDraugr);
    addCardsIntoDeck(1, cUnitTypeRaidingCavalry);

    addCardsIntoDeck(1, cUnitTypeKatapeltes);
    addCardsIntoDeck(1, cUnitTypeTurma);
    addCardsIntoDeck(1, cUnitTypeCheiroballista);
    addCardsIntoDeck(1, cUnitTypeCaladria);
    addCardsIntoDeck(1, cUnitTypeAutomaton);
    addCardsIntoDeck(1, cUnitTypeServant);

    addCardsIntoDeck(1, cUnitTypeFireArcher);
    addCardsIntoDeck(1, cUnitTypeDaoSwordsman);
    addCardsIntoDeck(1, cUnitTypeGeHalberdier);
    addCardsIntoDeck(1, cUnitTypeWuzuJavelineer);
    addCardsIntoDeck(1, cUnitTypeQiLin);

    addCardsIntoDeck(1, cUnitTypeYariSpearman);
    addCardsIntoDeck(1, cUnitTypeYumiArcher);
    addCardsIntoDeck(1, cUnitTypeNaginataRider);
    addCardsIntoDeck(1, cUnitTypeSamurai);
    addCardsIntoDeck(1, cUnitTypeBushi);
    addCardsIntoDeck(1, cUnitTypeSamurai);
    addCardsIntoDeck(1, cUnitTypeOnnaMusha);

    addCardsIntoDeck(2, cUnitTypeEagleWarrior);
    addCardsIntoDeck(2, cUnitTypeOtontin);
    addCardsIntoDeck(2, cUnitTypeShornOne);
    addCardsIntoDeck(2, cUnitTypeOnnaMusha);
    addCardsIntoDeck(2, cUnitTypeAyotochtli);

    addCardsIntoDeck(2, cUnitTypeChariotArcher);
    addCardsIntoDeck(2, cUnitTypeCamelRider);
    addCardsIntoDeck(2, cUnitTypeWarElephant);
    addCardsIntoDeck(2, cUnitTypePetsuchos);

    addCardsIntoDeck(2, cUnitTypeDaimyo);
    addCardsIntoDeck(2, cUnitTypeShinobi);
    addCardsIntoDeck(2, cUnitTypeOyumi);

    addCardsIntoDeck(2, cUnitTypeGodi);
    addCardsIntoDeck(2, cUnitTypeJarl);
    addCardsIntoDeck(2, cUnitTypeHuskarl);
    addCardsIntoDeck(2, cUnitTypePortableRam, 200);
    addCardsIntoDeck(2, cUnitTypeBattleBoar);
    addCardsIntoDeck(2, cUnitTypeFrostGiant);
    addCardsIntoDeck(2, cUnitTypeRockGiant);

    addCardsIntoDeck(2, cUnitTypeDestroyer);
    addCardsIntoDeck(2, cUnitTypeArcus);
    addCardsIntoDeck(2, cUnitTypeContarius);

    addCardsIntoDeck(2, cUnitTypeBehemoth);
    addCardsIntoDeck(2, cUnitTypePetrobolos);
                
    addCardsIntoDeck(2, cUnitTypeSiegeCrossbow);

    addCardsIntoDeck(2, cUnitTypeIcarus);
    addCardsIntoDeck(2, cUnitTypeProdromos);
    addCardsIntoDeck(2, cUnitTypePeltast);
    addCardsIntoDeck(2, cUnitTypeHypaspist);
    addCardsIntoDeck(2, cUnitTypeHydra);
    addCardsIntoDeck(2, cUnitTypeHamadryad);


    addCardsIntoDeck(2, cUnitTypeSage);
    addCardsIntoDeck(2, cUnitTypeChuKoNu);
    addCardsIntoDeck(2, cUnitTypeWhiteHorseCavalry);
    addCardsIntoDeck(2, cUnitTypeTaoWu);
    addCardsIntoDeck(2, cUnitTypeTaoTie);

    addCardsIntoDeck(2, cUnitTypeYumiHorseArcher);
    addCardsIntoDeck(2, cUnitTypeTanuki);
    addCardsIntoDeck(2, cUnitTypeShogun);

    addCardsIntoDeck(3, cUnitTypeCangJie, 600);

    addCardsIntoDeck(3, cUnitTypeJaguarRider);
    addCardsIntoDeck(3, cUnitTypeTunkuluchu);
    addCardsIntoDeck(3, cUnitTypeSuperTeixiptlaHuitz, 620);
    addCardsIntoDeck(3, cUnitTypeSuperTeixiptlaTezca, 620);
    addCardsIntoDeck(3, cUnitTypeSuperTeixiptlaQuetz, 620);

    addCardsIntoDeck(3, cUnitTypeReginleif, 600);
    addCardsIntoDeck(3, cUnitTypeFanatic);

    addCardsIntoDeck(3, cUnitTypeLiJing);
    addCardsIntoDeck(3, cUnitTypeWenZhong);
    addCardsIntoDeck(3, cUnitTypeYangJian);
    addCardsIntoDeck(3, cUnitTypeTigerCavalry);
    addCardsIntoDeck(3, cUnitTypeAsura);

    addCardsIntoDeck(3, cUnitTypeQuinametzin);
    addCardsIntoDeck(3, cUnitTypeSoulGuide);
    addCardsIntoDeck(3, cUnitTypeAmazonArcher);

    addCardsIntoDeck(3, cUnitTypeGastraphetoros);
    addCardsIntoDeck(3, cUnitTypeHetairos);
    addCardsIntoDeck(3, cUnitTypeMyrmidon);
    addCardsIntoDeck(3, cUnitTypePerseus);
    addCardsIntoDeck(3, cUnitTypePolyphemus);
    addCardsIntoDeck(3, cUnitTypeBellerophon);
    addCardsIntoDeck(3, cUnitTypeColossus);
    addCardsIntoDeck(3, cUnitTypeMedusa);
    addCardsIntoDeck(3, cUnitTypeHelepolis, 400);
    addCardsIntoDeck(3, cUnitTypeChiron);

    addCardsIntoDeck(3, cUnitTypeZhuQue);
    addCardsIntoDeck(3, cUnitTypeBallista);
    addCardsIntoDeck(3, cUnitTypeMummy);
    addCardsIntoDeck(3, cUnitTypeHunDun);
    addCardsIntoDeck(3, cUnitTypeOnmyoji);

    addCardsIntoDeck(3, cUnitTypeSamuraiHatamoto);
    addCardsIntoDeck(3, cUnitTypeArkantos, 600);

    addCardsIntoDeck(4, cUnitTypeSonOfOsiris, 750);
    addCardsIntoDeck(4, cUnitTypeNidhogg, 1000);
    addCardsIntoDeck(4, cUnitTypeYingLong, 1000);
    addCardsIntoDeck(4, cUnitTypeSiegeCrossbowSPC, 750);
    addCardsIntoDeck(4, cUnitTypeLivingPoseidonStatue, 900);
    addCardsIntoDeck(4, cUnitTypeYasuko, 750);
    addCardsIntoDeck(4, cUnitTypeArkantosGod, 1000);
    addCardsIntoDeck(4, cUnitTypeHarumotoBlessed, 800);
    addCardsIntoDeck(4, cUnitTypeGuardian, 1000);

    addCardIntoDeck(4, cUnitTypeOsirisPieceBox, 1500, -1, TIER_LEGENDARY, false);
}

void addOsirisCardIntoDeck(){
    addCardIntoDeck(4, cUnitTypeOsirisPieceBox, 1500, -1, TIER_LEGENDARY, false);
}