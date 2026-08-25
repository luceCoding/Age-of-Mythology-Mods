class CapturePoint {
    int m_maxTimer = 10;
    int m_captureTimer = 10;
    int m_captureableUnitId = -1;
    int m_shopType = -1;
    float m_radius = 12.0;
    int m_lastOwner = -1;
    bool m_commandsRemoved = false; 

    void init(int unitId = -1, int shopType = -1, int captureSeconds = 10, float radius = 10.0){
        m_captureableUnitId = unitId;
        m_shopType = shopType;
        m_maxTimer = captureSeconds;
        m_captureTimer = captureSeconds;
        m_radius = radius;
        m_commandsRemoved = false;
    }

    bool isOwnerNearby(int unitId = -1, float radius = 10.0) {
        int owner = kbUnitGetPlayerID(unitId);
        if (owner <= 0) return false; 
        
        return (kbUnitTypeCountInArea("Unit", owner, cUnitStateAlive, unitId, radius) > 0);
    }

    int getEnemiesNearby(int unitId = -1, float radius = 10.0) {
        int owner = kbUnitGetPlayerID(unitId);
        int enemyCount = 0;

        for (int p = 1; p <= cNumberPlayers; p++) {
            if (p == owner) continue;
            if (owner != 0 && g_finalTeam[owner] == g_finalTeam[p]) continue;

            int unitsNear = kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, unitId, radius);
            if (unitsNear > 0) {
                enemyCount = enemyCount + unitsNear;
            }
        }
        return enemyCount;
    }

    int getTeammatesNearby(int unitId = -1, float radius = 10.0) {
        int owner = kbUnitGetPlayerID(unitId);
        if (owner <= 0) return 0; 
        
        int teamCount = 0;

        for (int p = 1; p <= cNumberPlayers; p++) {
            if (p == owner) continue;
            if (g_finalTeam[owner] != g_finalTeam[p]) continue;

            int unitsNear = kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, unitId, radius);
            if (unitsNear > 0) {
                teamCount = teamCount + unitsNear;
            }
        }
        return teamCount;
    }

    bool isContested(int unitId = -1, float radius = 10.0) {
        int owner = kbUnitGetPlayerID(unitId);
        int capturingTeam = -1;

        for (int p = 1; p <= cNumberPlayers; p++) {
            if (p == owner) continue;
            
            if (kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, unitId, radius) > 0) {
                int pTeam = g_finalTeam[p];
                
                if (capturingTeam == -1) {
                    capturingTeam = pTeam;
                } else if (capturingTeam != pTeam) {
                    return true; 
                }
            }
        }
        return false;
    }

    int getDominantPlayer(int unitId = -1, float radius = 10.0, bool isEnemySearch = true) {
        int owner = kbUnitGetPlayerID(unitId);
        int maxUnits = 0;
        int dominantPlayer = -1;

        for (int p = 1; p <= cNumberPlayers; p++) {
            if (p == owner) continue;

            bool isAlly = false;
            if (owner > 0 && g_finalTeam[owner] == g_finalTeam[p]) {
                isAlly = true;
            }

            if (isEnemySearch == true && isAlly == true) continue;
            if (isEnemySearch == false && isAlly == false) continue;

            int count = kbUnitTypeCountInArea("Unit", p, cUnitStateAlive, unitId, radius);
            if (count > maxUnits) {
                maxUnits = count;
                dominantPlayer = p;
            }
        }
        return dominantPlayer;
    }

    void showWorldSpacePrompt(string msg = ""){
        if (g_shop.m_shopTypeOpened[trCurrentPlayer()] == SHOP_TYPE_CLOSED){
            trWorldSpacePrompt(""+m_captureableUnitId, m_captureableUnitId, false, msg, vector(0,0,0), "vfx_top", true);
        }
    }

    void processCapturePoint(){
        if (m_captureableUnitId < 0) return;

        bool ownerPresent = isOwnerNearby(m_captureableUnitId, m_radius);
        int enemyCount = getEnemiesNearby(m_captureableUnitId, m_radius);
        bool contested = isContested(m_captureableUnitId, m_radius);
        int owner = kbUnitGetPlayerID(m_captureableUnitId);

        // 1. CAPTURING: Owner absent, enemy present, and point is uncontested by rival teams
        if (ownerPresent == false && enemyCount > 0 && contested == false) {
            m_captureTimer = m_captureTimer - 1;
            
            showWorldSpacePrompt("Capturing..." + m_captureTimer + "s");
            closeShop(owner, m_shopType);
            removeShopCommands(owner, g_shopTypes[m_shopType]);
            m_commandsRemoved = true; 
            
            if (m_captureTimer <= 0) {
                int newOwner = getDominantPlayer(m_captureableUnitId, m_radius, true);
                if (newOwner != -1) {
                    selectSingle(m_captureableUnitId);
                    trUnitConvert(newOwner);
                }
                m_captureTimer = m_maxTimer;
            }
            return;
        }

        // 2. CONTESTED / ATTEMPTING TO CAPTURE WHILE BLOCKED: Freeze timer state
        if (contested == true || (enemyCount > 0 && ownerPresent == true)) {
            showWorldSpacePrompt("Contested...");
            closeShop(owner, m_shopType);
            removeShopCommands(owner, g_shopTypes[m_shopType]);
            m_commandsRemoved = true; 
            return; 
        }

        int teamCount = getTeammatesNearby(m_captureableUnitId, m_radius);
        // 3. RECOVERY / DAMAGED STATE: No enemies present, but timer is damaged. 
        if (enemyCount == 0 && m_captureTimer < m_maxTimer) {
            // Recover ONLY if the owner (or an ally) is standing on the point
            if (ownerPresent == true || teamCount > 0) {
                m_captureTimer = m_captureTimer + 1;
                
                if (m_captureTimer < m_maxTimer) {
                    showWorldSpacePrompt("Recovering..." + m_captureTimer + "s");
                    return; // Wait until fully recovered before handing commands back
                }
            } else {
                // If abandoned, the timer stays frozen where the enemy left it
                showWorldSpacePrompt("Abandoned...(" + m_captureTimer + "s)");
                return;
            }
        }

        // 4. IDLE / FULLY RECOVERED / TEAMMATE SWAP
        if (m_captureTimer >= m_maxTimer) {
            
            // Teammate Takeover: Owner gone, no enemies, but ally is present.
            if (ownerPresent == false && enemyCount == 0 && teamCount > 0) {
                int newTeammateOwner = getDominantPlayer(m_captureableUnitId, m_radius, false);
                if (newTeammateOwner != -1) {
                    // Close shop and strip commands from the old owner before converting
                    closeShop(owner, m_shopType);
                    removeShopCommands(owner, g_shopTypes[m_shopType]);
                    
                    selectSingle(m_captureableUnitId);
                    trUnitConvert(newTeammateOwner);
                    owner = newTeammateOwner; 
                    m_commandsRemoved = true; // Trigger command re-addition for the new teammate
                }
            }

            // Restore if the owner changed OR if the owner repelled an attack and fully recovered
            if ((owner != 0 && m_lastOwner != -1 && owner != m_lastOwner) || m_commandsRemoved == true) {
                showWorldSpacePrompt("Captured");
                
                switch(m_shopType){
                    case SHOP_TYPE_FORGE: addForgeCommands();
                    case SHOP_TYPE_ARMORY: addArmoryCommands();
                    case SHOP_TYPE_TEMPLE: addTempleCommands();
                    case SHOP_TYPE_SHRINE: addShrineCommands();
                }
                m_commandsRemoved = false; 
            }
            else if (owner == m_lastOwner && m_commandsRemoved == false) {
                trWorldSpacePromptHide(""+m_captureableUnitId);
            }
        }
        
        m_lastOwner = owner;
    }
};

CapturePoint g_armoryCapturePoint;
CapturePoint g_shrineCapturePoint;
CapturePoint g_templeCapturePoint;
CapturePoint g_forgeCapturePoint;

void startCapturePoints(){
    g_armoryCapturePoint.init(ShopTypeToUnitIDMap.get(SHOP_TYPE_ARMORY), SHOP_TYPE_ARMORY, SHARED_SHOP_CAPTURE_TIME, SHARED_SHOP_CAPTURE_RADIUS);
    g_shrineCapturePoint.init(ShopTypeToUnitIDMap.get(SHOP_TYPE_SHRINE), SHOP_TYPE_SHRINE, SHARED_SHOP_CAPTURE_TIME, SHARED_SHOP_CAPTURE_RADIUS);
    g_templeCapturePoint.init(ShopTypeToUnitIDMap.get(SHOP_TYPE_TEMPLE), SHOP_TYPE_TEMPLE, SHARED_SHOP_CAPTURE_TIME, SHARED_SHOP_CAPTURE_RADIUS);
    g_forgeCapturePoint.init(ShopTypeToUnitIDMap.get(SHOP_TYPE_FORGE), SHOP_TYPE_FORGE, SHARED_SHOP_CAPTURE_TIME, SHARED_SHOP_CAPTURE_RADIUS);

    scheduler.add(1013, [](int iterations = 1) -> bool {
        g_armoryCapturePoint.processCapturePoint();
        g_shrineCapturePoint.processCapturePoint();
        g_templeCapturePoint.processCapturePoint();
        g_forgeCapturePoint.processCapturePoint();
        return true;
    });
}