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