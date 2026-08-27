string getDisplayName(ref int rarity, ref string name){
    string displayName = name;
    switch(rarity){
        case 1: displayName = "<color=0.10,0.58,0.37>" + name + "</color>";
        case 2: displayName = "<color=0.15,0.32,0.49>" + name + "</color>";
        case 3: displayName = "<color=0.60,0.00,0.73>" + name + "</color>";
        case 4: displayName = "<color=0.71,0.58,0.00>" + name + "</color>";
    }
    return displayName;
}