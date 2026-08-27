include "lib/rm_core.xs";
include "card.xs"

StringToIntHashMap g_synergyHashMap;

mutable bool purchase(int goldAmount = 0, int p = 0) { return false; }

class BenchData {
    int m_player = -1;
    int m_playerShopId = -1;
    int[] m_synergyCounter = default;
    CardData[] m_cardArray = default;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
        m_synergyCounter = new int(MAX_SYNERGIES, 0);
    }
    
    int getPlayerShopID(){
        return m_playerShopId;
    }

    bool addCard(ref CardData card){
        m_cardArray.add(card);
        log(3, "Added card to bench " + card.getUuid());
        return true;
    }

    CardData removeCardByUUID(int uuid = -1){        
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                int lastIndex = m_cardArray.size() - 1;
                
                // Overwrite with last element and shrink array
                m_cardArray[i] = m_cardArray[lastIndex];
                m_cardArray.resize(lastIndex);

                log(3, "Removed card from bench " + currCard.getUuid() + ", size: " + m_cardArray.size());
                return currCard;
            }
        }
        
        CardData emptyCard;
        return emptyCard;
    }

    CardData[] getCards(){
        return m_cardArray;
    }

    int getNumberOfCardsHeld(){
        return m_cardArray.size();
    }

    void incrementSynergyAndApplyBuff(int index = 0, int p = 0){
        m_synergyCounter[index] = m_synergyCounter[index] + 1;
        SynergyData synergy = g_synergies[index];
        if (m_synergyCounter[index] < synergy.m_buffs.size()){
            Buff buff = synergy.m_buffs[m_synergyCounter[index]]; // Index error?
            buff.applyBuff(p);
        }
    }

    void addSynergy(ref CardData card, int p = 0){
        String key = card.getProtoName() + p;
        int count = g_synergyHashMap.get(key);
        if (count == 0){
            CardParameters params = card.getCardParameters();
            if (params.isInfantry()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_INFANTRY, p);}
            if (params.isArcher()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_RANGED, p);}
            if (params.isCavalry()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_CAVALRY, p);}
            if (params.isMythUnit()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_MYTH, p);}
            if (params.isHero()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_HERO, p);}
            if (params.isHealer()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_HEALER, p);}
            if (params.isSiege()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_SIEGE, p);}
            //if (params.isBuilding()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_BUILDING, p);}
            if (params.isSoldier()){incrementSynergyAndApplyBuff(SYNERGY_INDEX_SOLDIER, p);}
        }
        g_synergyHashMap.put(key, count + 1);
    }

    void decrementSynergyAndResetBuff(int index = 0, int p = 0){
        SynergyData synergy = g_synergies[index];
        if (m_synergyCounter[index] < synergy.m_buffs.size()){
            Buff buff = synergy.m_buffs[m_synergyCounter[index]]; // Index error?
            buff.resetBuff(p);
        }
        m_synergyCounter[index] = m_synergyCounter[index] - 1;
    }

    void removeSynergy(ref CardData card, int p = 0){
        String key = card.getProtoName() + p;
        int count = g_synergyHashMap.get(key);
        count = count - 1;
        g_synergyHashMap.put(key, count);
        if (count == 0){
            CardParameters params = card.getCardParameters();
            if (params.isInfantry()){decrementSynergyAndResetBuff(SYNERGY_INDEX_INFANTRY, p);}
            if (params.isArcher()){decrementSynergyAndResetBuff(SYNERGY_INDEX_RANGED, p);}
            if (params.isCavalry()){decrementSynergyAndResetBuff(SYNERGY_INDEX_CAVALRY, p);}
            if (params.isMythUnit()){decrementSynergyAndResetBuff(SYNERGY_INDEX_MYTH, p);}
            if (params.isHero()){decrementSynergyAndResetBuff(SYNERGY_INDEX_HERO, p);}
            if (params.isHealer()){decrementSynergyAndResetBuff(SYNERGY_INDEX_HEALER, p);}
            if (params.isSiege()){decrementSynergyAndResetBuff(SYNERGY_INDEX_SIEGE, p);}
            //if (params.isBuilding()){decrementSynergyAndResetBuff(SYNERGY_INDEX_BUILDING, p);}
            if (params.isSoldier()){decrementSynergyAndResetBuff(SYNERGY_INDEX_SOLDIER, p);}
        }
    }

    bool spawnCard(ref CardData card, int shopId = -1, int p  = 0){
        CardParameters params = card.getCardParameters();
        string protoName = params.getProtoUnit();
        vector position = trUnitGetPosition(shopId);
        int unitID = trUnitCreateForced(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), p, false);
        if (unitID < 0) {
            errorLog("Player " + p + " failed to spawn " + protoName + " for card " + card.getUuid());
            return false;
        }
        string displayName = kbProtoUnitGetDisplayName(p, kbProtoUnitGetID(card.getProtoName()));
        int rarity = card.getRarity();
        displayName = getDisplayName(rarity, displayName);
        selectSingle(unitID);
        trUnitChangeName(displayName);
        card.deploy(unitID);
        log(3, "Player " + p + " deployed " + protoName + " to shop " + shopId);
        return true;
    }

    void deployCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.isNull() || card.isDeployed() || card.getUuid() != uuid) continue;
            if (spawnCard(card, m_playerShopId, m_player) == false) {
                return;
            }
            m_cardArray[i] = card;
            card.applyUpgrades(m_player);
            addSynergy(card, m_player);
            m_cardArray[i] = card;
            trSoundsetPlayPlayer(m_player, "AotgBlessingEquip");
            return;
        }
    }

    bool respawnDeployedCards(){
        bool wasThereARespawn = false;
        int currtime = xsGetTimeMS();

        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.isNull() == true || card.isDeployed() == false) { continue; }
            
            int unitId = card.getDeployedUnitID();
            selectSingle(unitId);
            if (trUnitDead()){
                // 1. Timer hasn't been started yet: set the target timestamp
                if (card.timeTillRespawn == 0) {
                    int respawnTimeMS = RESPAWN_TIME_MS_BASE + (((currtime - g_timeMSGameStarted) / 60000) * 1000);                    
                    card.timeTillRespawn = currtime + respawnTimeMS;
                    m_cardArray[i] = card;
                    wasThereARespawn = true;
                }
                // 2. Current time reached or passed the target timestamp: Respawn!
                else if (currtime >= card.timeTillRespawn) {
                    if (spawnCard(card, m_playerShopId, m_player)) {
                        trSoundsetPlayPlayer(m_player, "HeroRevive");
                        card.timeTillRespawn = 0; // Reset timestamp so it can be used again next death
                        m_cardArray[i] = card;
                        wasThereARespawn = true;
                    }
                }
                // 3. currtime < card.timeTillRespawn: Still waiting for target time, do nothing.
            }
        }
        return wasThereARespawn;
    }

    bool withdrawCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData cardToWithdraw = m_cardArray[i];
            if (uuid == cardToWithdraw.getUuid() && (!(cardToWithdraw.isNull())) && cardToWithdraw.isDeployed()){
                int unitID = cardToWithdraw.getDeployedUnitID();
                selectSingle(unitID);
                if (trUnitDead() == false){
                    vector shopLocation = kbUnitGetPosition(m_playerShopId);
                    float distance = kbUnitGetDistanceToPoint(unitID, shopLocation);
                    if (distance <= 10){
                        trUnitDestroy(true);
                        cardToWithdraw.resetUpgrades(m_player);
                        cardToWithdraw.withdraw();
                        removeSynergy(cardToWithdraw, m_player);
                        m_cardArray[i] = cardToWithdraw;
                        trSoundsetPlayPlayer(m_player, "AotgBlessingUnequip");
                        log(3, "Player " + m_player + " withdrew to shop " + m_playerShopId);
                        return true;
                    }
                    else {
                        trChatSendToPlayer(m_player, m_player, "Unit must be nearby your shop before it can be withdrawn.");
                        selectSingle(cardToWithdraw.getDeployedUnitID());
                        trUnitHighlight(8.0, true);
                        trSoundsetPlayPlayer(m_player, "HardPopAlert");
                        return false;
                    }
                }
                else {
                    trChatSendToPlayer(m_player, m_player, "Unit must be alive before it can be withdrawn.");
                    trSoundsetPlayPlayer(m_player, "HardPopAlert");
                    return false;
                }
            }
        }
        return false;
    }

    bool identifyCard(int uuid = -1, int p = 0){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && (card.isIdentified() == false)){
                if (purchase(g_shrineShopCost, p)){
                    card.identify();
                    g_shrineShopCost = g_shrineShopCost + 10;
                    m_cardArray[i] = card;
                    trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine");
                    log(3, "Player " + m_player + " identified a card.");
                    return true;
                }
            }
        }
        return false;
    }

    bool rerollRarity(int uuid = -1, int p = 0){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (card.isNull() == false) && card.isIdentified()){
                if (purchase(g_templeShopCost, p)){
                    int rarity = card.rerollRarity();
                    g_templeShopCost = g_templeShopCost + 10;
                    m_cardArray[i] = card;
                    switch(rarity){
                        case TIER_UNCOMMON: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine");
                        case TIER_RARE: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedHeroic");
                        case TIER_EPIC: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedMythic");
                        case TIER_LEGENDARY: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedDivine");
                        default: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedSimple");
                    }
                    log(3, "Player " + m_player + " rarity a card.");
                    return true;
                }
            }
        }
        return false;
    }

    bool addSocket(int uuid = -1, int p = 0){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && card.isIdentified()){
                if (purchase(g_forgeShopCost, p)){
                    bool hasSocketed = card.addSocket();
                    if (hasSocketed){
                        g_forgeShopCost = g_forgeShopCost + 10;
                        m_cardArray[i] = card;
                        trSoundsetPlayPlayer(m_player, "ArmorySelect");
                        log(3, "Player " + m_player + " socketed a card.");
                        return true;
                    }
                }
            }
        }
        return false;
    }

    bool rerollUpgrade(int uuid = -1, int p = 0, int upgradeIdx = 0){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && card.isIdentified()){
                if (purchase(g_armoryShopCost, p)){
                    int upgrade = card.rerollUpgrade(upgradeIdx);
                    if (upgrade == -1){
                        errorLog("Player " + m_player + " failed to upgrade card.");
                        return false;
                    }
                    g_armoryShopCost = g_armoryShopCost + 10;
                    m_cardArray[i] = card;
                    trSoundsetPlayPlayer(m_player, "ArmorySelect");
                    log(3, "Player " + m_player + " socketed a card.");
                    return true;
                }
            }
        }
        return false;
    }

    string getSynergyText(int synergyIndex = 0) {
        string text = "";
        SynergyData synergy = g_synergies[synergyIndex];
        Buff[] buffs = synergy.m_buffs;
        
        int currentCount = m_synergyCounter[synergyIndex];

        // 1. Find the highest unlocked tier threshold <= currentCount
        int activeTierIndex = -1;
        for (int i = 0; i < buffs.size(); i++) {
            Buff buff = buffs[i];
            if (buff.isEmpty()) { continue; }

            if (i <= currentCount) {
                activeTierIndex = i; // Continually updates to the highest reached tier
            }
        }

        // 2. Build the formatted string
        bool isFirstItem = true;
        for (int i = 0; i < buffs.size(); i++) {
            Buff buff = buffs[i];
            if (buff.isEmpty()) { continue; }

            // Append separator between tiers
            if (isFirstItem == false) {
                text = text + " > ";
            } else {
                isFirstItem = false;
            }

            // Highlight if this specific tier index is the active threshold
            if (i == activeTierIndex) {
                // Active tier (Yellow / Gold)
                text = text + "<color=1,0.84,0>" + i + "</color>";
            } else {
                // Inactive / Unreached tier (Grey)
                text = text + "<color=0.5,0.5,0.5>" + i + "</color>";
            }
        }
        return text;
    }

    void renderSynergies(float posX = 0.0, float posY = 0.0, int p = 1) {
        float width = 0.1;
        float height = 0.025;
        float posYOffset = 0.035;

        // 1. Initialize index map array [0, 1, 2, 3, 4, 5, 6, 7]
        int[] sortedIndices = new int(8, 0);
        for (int i = 0; i < sortedIndices.size(); i++) {
            sortedIndices[i] = i;
        }

        // 2. Bubble sort indices based on values in m_synergyCounter (Descending)
        for (int i = 0; i < sortedIndices.size()-1; i++) {
            for (int j = 0; j < 7 - i; j++) {
                int idxA = sortedIndices[j];
                int idxB = sortedIndices[j + 1];

                if (m_synergyCounter[idxA] < m_synergyCounter[idxB]) {
                    sortedIndices[j] = idxB;
                    sortedIndices[j + 1] = idxA;
                }
            }
        }

        // 3. Render using sorted indices (renderSynergyIcon will naturally skip count == 0)
        for (int i = 0; i < sortedIndices.size(); i++) {
            int idx = sortedIndices[i];
            if (m_synergyCounter[idx] > 0) {
                SynergyData synergy = g_synergies[idx];
                //minimapSafeDisplay(p, posX + 0.0825, posY + 0.005, m_synergyCounter[idx] + " : " + getSynergyText(idx));
                renderSynergyIcon(p, posX, posY, posYOffset, width, height, 32, idx, false, " " + m_synergyCounter[idx] + " : " + getSynergyText(idx));
            }
        }
    }
};