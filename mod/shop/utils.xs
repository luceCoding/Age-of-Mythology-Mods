void createButton(int p = 0, float drawPosx = 0.0, float drawPosY = 0.0, string buttonName = ""){
    minimapSafeDisplay(p, drawPosx, drawPosY, getIconPathFormat("resources/front_end/Ornate_Buttons/BtnOrnate_Large_On.png", 128));
    minimapSafeDisplay(p, drawPosx, drawPosY + 0.05, buttonName);
}

bool purchase(int goldAmount = 0, int p = 0){
    if (((kbGetResourceAmount(p, kbGetResourceID("Gold")) >= goldAmount) != false)){
        trPlayerGrantResources(p, "Gold", -goldAmount);
        return true;
    }
    trSoundsetPlayPlayer(p, "PopCapHit");
    return false;
}

int estimateCardValue(ref CardData card){
    CardParameters params = card.getCardParameters();
    int initalCost = params.getCost();
    int numberOfSockets = card.getNumberOfSockets();
    int rarity = card.getRarity();
    int numberOfUpgrades = card.getNumberOfUpgrades();
    return (initalCost + ((numberOfSockets-1) * 10) + ((numberOfUpgrades-1) * 10)) * (1 + (rarity*0.05));
}