int[] g_pendingArchetypes = default;

void refreshArchetypeUI(int p = 1){
    if (uiSystemActiveArray[p] == false) {return;}
    enterUiSystem(p);
    if(trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    renderArchetypes(p);
    postEnterUiSystem(p);
}

void closeArchetypeUI(int p = 1){
    if (uiSystemActiveArray[p] == false) {return;}
    int archetype = g_pendingArchetypes[p];
    exitUiSystem(p, true);
    if (trCurrentPlayer() == p){
        setUiVisible(true);
        trSetObscuredUnits(true);
    }
    if (archetype >= ARCHETYPE_MISCHIEF && archetype <= ARCHETYPE_EVASION &&
        archetype != getPlayerArchetype(p)){
        Archetype selectedArchetype = g_archetypes[archetype];
        selectedArchetype.setup(p);
        g_archetypes[archetype] = selectedArchetype;
    }
}

void renderArchetypes(int p = 1){
    int archetypeCount = ARCHETYPE_EVASION - ARCHETYPE_MISCHIEF + 1;
    float iconSize = 0.06;
    float selectedScale = 1.2;
    float spacing = 0.14;
    float startX = -((archetypeCount - 1) * spacing) / 2.0;
    float posY = 0.05;

    minimapSafeDisplay(p, 0.0, 0.18, "Choose your starting god power");

    for (int i = ARCHETYPE_MISCHIEF; i <= ARCHETYPE_EVASION; i++){
        Archetype archetypeObj = g_archetypes[i];
        bool isSelected = g_pendingArchetypes[p] == i;
        float scale = isSelected ? selectedScale : 1.0;
        int iconPixels = isSelected ? 64 * scale : 64;
        float posX = startX + ((i - ARCHETYPE_MISCHIEF) * spacing);

        Parameters parameters = createParameters();
        parameters.ints.add(i);
        minimapSafeClickableWithHover(
            p,
            posX,
            posY,
            iconSize * scale,
            iconSize * scale,
            getIconPathFormat(archetypeObj.getIcon(), iconPixels),
            archetypeObj.getTitle(),
            archetypeObj.getRollover(),
            parameters,
            [](int p = 1, ref Parameters parameters) -> void {
                int archetype = parameters.ints[0];
                if (archetype < ARCHETYPE_MISCHIEF || archetype > ARCHETYPE_EVASION){ return; }
                g_pendingArchetypes[p] = archetype;
                refreshArchetypeUI(p);
            }
        );
        minimapSafeDisplay(p, posX, posY + 0.07 * scale, toForwardSlash(archetypeObj.getTitle()));
    }

    createButton(p, 0.0, -0.25, EXIT_BUTTON_TEXT);
    minimapSafeClickable(
        p,
        0.0, -0.25 + 0.035, 0.1, 0.055,
        "",
        EMPTY_PARAMETERS,
        [](int p = 1, ref Parameters parameters) -> void {
            closeArchetypeUI(p);
        }
    );
}

void openArchetypeUI(int p = 1){
    if (g_pendingArchetypes.size() != cNumberPlayers + 1){
        g_pendingArchetypes = new int(cNumberPlayers + 1, ARCHETYPE_MISCHIEF);
    }
    g_pendingArchetypes[p] = getPlayerArchetype(p);
    enterUiSystem(p);
    if (trCurrentPlayer() == p){
        setUiVisible(false);
        trSetObscuredUnits(false);
    }
    renderArchetypes(p);
    postEnterUiSystem(p);
}
