void refreshShop(int p = 1){
    if (g_shopNeedsRefresh[p] == true){
        UiSystem system = uiSystemArray[p];
        if (system.uiActive == false) {return;}
        system.enter(false, true, 503);
        if(trCurrentPlayer() == p){
            setUiVisible(false);
            trSetObscuredUnits(false);
        }
        int shopType = g_shop.m_shopTypeOpened[p];
        switch(shopType){
            case SHOP_TYPE_SHRINE: renderShrine(system, p);
            case SHOP_TYPE_TEMPLE: renderTemple(system, p);
            case SHOP_TYPE_FORGE: renderForge(system, p);
            case SHOP_TYPE_ARMORY: renderArmory(system, p);
            default: renderShop(system, p);
        }
        uiSystemArray[p] = system;
    }
}