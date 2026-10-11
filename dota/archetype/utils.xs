// cUnitTypeVFXSolarShield for ally unit targeting
// cUnitTypeSpyEye for enemy unit targeting

Archetype[] g_archetypes = default;

void setPlayerArchetype(int p = -1, int archetype = -1){
    g_playerArchetypes[p] = archetype;
}

int getPlayerArchetype(int p = -1){
    return g_playerArchetypes[p];
}

string getPlayerArchetypeTitle(int p = -1){
    int archetype = getPlayerArchetype(p);
    if (archetype < ARCHETYPE_MISCHIEF || archetype > ARCHETYPE_EVASION){ return ""; }
    Archetype archetypeObj = g_archetypes[archetype];
    return archetypeObj.getTitle();
}

string getPlayerArchetypeIcon(int p = -1){
    int archetype = getPlayerArchetype(p);
    if (archetype < ARCHETYPE_MISCHIEF || archetype > ARCHETYPE_EVASION){ return ""; }
    Archetype archetypeObj = g_archetypes[archetype];
    return archetypeObj.getIcon();
}

string getPlayerArchetypeRollover(int p = -1){
    int archetype = getPlayerArchetype(p);
    if (archetype < ARCHETYPE_MISCHIEF || archetype > ARCHETYPE_EVASION){ return ""; }
    Archetype archetypeObj = g_archetypes[archetype];
    return archetypeObj.getRollover();
}

void initializeArchetypes(){
    int MAX_ARCHETYPES = ARCHETYPE_EVASION + 1;
    g_archetypes = new Archetype(MAX_ARCHETYPES);
    g_playerArchetypes = new int(cNumberPlayers + 1, -1);
    for (int i = ARCHETYPE_MISCHIEF; i < MAX_ARCHETYPES; i++){
        Archetype archetypeObj;
        archetypeObj.setArchetype(i);
        g_archetypes[i] = archetypeObj;
    }
}