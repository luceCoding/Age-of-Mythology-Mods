void openShopType(int p = 1, int shopType = DEFAULT_SHOP_TYPE){
    enterUiSystem(p);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    g_selectedUUIDs[p] = -1;
    g_shop.m_shopTypeOpened[p] = shopType;
    switch(shopType){
        case SHOP_TYPE_SHRINE: renderShrine(p);
        case SHOP_TYPE_TEMPLE: renderTemple(p);
        case SHOP_TYPE_FORGE: renderForge(p);
        case SHOP_TYPE_ARMORY: renderArmory(p);
        default: renderShop(p);
    }
    hideWorldPrompts(p);
    postEnterUiSystem(p);
    if (trCurrentPlayer() == p){
        trSoundPlayPaused("ui\latch.wav");
    }
}

void openShop(int p = 1){
    openShopType(p, DEFAULT_SHOP_TYPE);
}

void refreshShop(int p = 1){
    if (uiSystemActiveArray[p] == false) {return;}
    enterUiSystem(p);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    switch(g_shop.m_shopTypeOpened[p]){
        case SHOP_TYPE_SHRINE: renderShrine(p);
        case SHOP_TYPE_TEMPLE: renderTemple(p);
        case SHOP_TYPE_FORGE: renderForge(p);
        case SHOP_TYPE_ARMORY: renderArmory(p);
        default: renderShop(p);
    }
    postEnterUiSystem(p);
}