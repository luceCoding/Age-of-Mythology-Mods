include "lib/rm_core.xs";
include "card.xs"

StringToIntHashMap g_synergyHashMap;

mutable bool purchase(int goldAmount = 0, int p = 0) { return false; }

class BenchData {
    int m_cardSize = 0; // Tracks active cards without shrinking/reallocating the array
    int m_player = -1;
    int m_playerShopId = -1;
    int[] m_synergyCounter = default;
    CardData[] m_cardArray = default;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
        m_synergyCounter = new int(MAX_SYNERGIES, 0);
        m_cardSize = 0;
    }
    
    int getPlayerShopID(){
        return m_playerShopId;
    }

    bool addCard(ref CardData card){
        // Reuse an existing slot if available, otherwise grow the array pool
        if (m_cardSize < m_cardArray.size()) {
            m_cardArray[m_cardSize] = card;
        } else {
            m_cardArray.add(card);
        }
        m_cardSize++;
        log(3, "Added card to bench " + card.getUuid() + ", size: " + m_cardSize);
        return true;
    }

    CardData removeCardByUUID(int uuid = -1){        
        for(int i = 0; i < m_cardSize; i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.getUuid() == uuid) {
                m_cardSize--; // Reduce active count
                
                // Swap the last active element into this slot if it's not already the last one
                if (i < m_cardSize) {
                    m_cardArray[i] = m_cardArray[m_cardSize];
                }
                
                // Clear the vacated slot to prevent ghost card rendering
                CardData nullCard;
                m_cardArray[m_cardSize] = nullCard;

                log(3, "Removed card from bench " + currCard.getUuid() + ", size: " + m_cardSize);
                return currCard;
            }
        }
        
        CardData emptyCard;
        return emptyCard;
    }

    CardData removeCardByIndex(int index = -1){ 
        // Validate index bounds
        if (index < 0 || index >= m_cardSize) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData currCard = m_cardArray[index];
        m_cardSize--; // Reduce active count
        
        // Swap the last active element into this slot if it's not already the last one
        if (index < m_cardSize) {
            m_cardArray[index] = m_cardArray[m_cardSize];
        }
        
        // Clear the vacated slot to prevent ghost card rendering
        CardData nullCard;
        m_cardArray[m_cardSize] = nullCard;

        log(3, "Removed card from index " + index + " (UUID: " + currCard.getUuid() + "), size: " + m_cardSize);
        return currCard;
    }

    void removeAllDeployedOsirisPieceCards(){        
        for(int i = 0; i < m_cardSize; i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.isOsirisPieceBoxCard() && currCard.isDeployed()) {
                selectSingle(currCard.getDeployedUnitID());
                trUnitDestroy();

                m_cardSize--; // Reduce active count

                // Swap the last active element into this slot if it's not already the last one
                if (i < m_cardSize) {
                    m_cardArray[i] = m_cardArray[m_cardSize];
                    i--; // Recheck the card moved into this slot
                }
                
                // Clear the vacated slot to prevent ghost card rendering
                CardData nullCard;
                m_cardArray[m_cardSize] = nullCard;

                log(3, "Removed osiris card from bench " + currCard.getUuid() + ", size: " + m_cardSize);
            }
        }
    }

    int getDeployedOsirisPieceBoxCardCount(){
        int count = 0;
        for(int i = 0; i < m_cardSize; i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.isOsirisPieceBoxCard() && currCard.isDeployed()) {
                count = count + 1;
            }
        }
        return count;
    }

    CardData[] getCards(){
        return m_cardArray;
    }

    int getNumberOfCardsHeld(){
        return m_cardSize;
    }

    void incrementSynergyAndApplyBuff(int index = 0, int p = 0){
        m_synergyCounter[index] = m_synergyCounter[index] + 1;
        SynergyData synergy = g_synergies[index];
        if (m_synergyCounter[index] < synergy.m_buffs.size()){
            Buff buff = synergy.m_buffs[m_synergyCounter[index]];
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
            Buff buff = synergy.m_buffs[m_synergyCounter[index]];
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
            if (params.isSoldier()){decrementSynergyAndResetBuff(SYNERGY_INDEX_SOLDIER, p);}
        }
    }

    void changeDisplayName(ref CardData card){
        string displayName = kbProtoUnitGetDisplayName(m_player, kbProtoUnitGetID(card.getProtoName()));
        displayName = getDisplayName(card.getRarity(), displayName);
        selectSingle(card.getDeployedUnitID());
        trUnitChangeName(displayName);
    }

    bool spawnCard(ref CardData card, bool applyCardHealth = true){
        CardParameters params = card.getCardParameters();
        selectSingle(m_playerShopId);
        string protoName = params.getProtoUnit();
        vector position = trUnitGetPosition(m_playerShopId);
        int unitID = trUnitCreateForced(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), m_player, false);
        if (unitID < 0) {
            errorLog("Player " + m_player + " failed to spawn " + protoName + " for card " + card.getUuid());
            return false;
        }
        card.deploy(unitID);
        card.setIsRespawning(false);
        if (applyCardHealth) {
            card.applyRarityHealth(m_player);
        }
        changeDisplayName(card);
        log(3, "Player " + m_player + " deployed " + protoName + " to shop " + m_playerShopId);
        return true;
    }

    CardData getAndUpgradeDuplicateDeployedCard(string proto = "", ref CardData duplicateCard){
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (card.isDeployed() && card.getProtoName() == proto && card.isOsirisPieceBoxCard() == false){
                card.mergeDuplicate(duplicateCard, m_player);
                m_cardArray[i] = card;
                return card;
            }
        }
        CardData EmptyCard;
        return EmptyCard;
    }

    void deployCard(int uuid = -1){
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (card.isNull() || card.isDeployed() || card.getUuid() != uuid) continue;
            if (card.isOsirisPieceBoxCard() && getDeployedOsirisPieceBoxCardCount() == OSIRIS_CARDS_NEEDED-1){
                removeAllDeployedOsirisPieceCards();
                removeCardByUUID(uuid);
                selectSingle(m_playerShopId);
                vector location = trUnitGetPosition(m_playerShopId);
                trUnitCreateForced("Osiris", location.x, location.y, location.z, xsRandFloat(0.0, 359), m_player, false);

                string playerName = kbPlayerGetName(m_player);
                string icon = "resources/talking_heads/osiris/osiris_spc_neutral.png";
                trChatSend(getTeamsAIPlayer(g_finalTeam[m_player]), playerName + " has gathered all five pieces of Osiris!\n" + displayCompensatedIcon(128, 128, icon));

                closeShop(m_player);
                trSoundPlayFN("campaign\fott\cinematics\fott20_b\lostsouls.mp3", -1, "","");
                trSetLighting("potg\potg02_end", 10);
                trMusicStop();
                trMusicPlay("music\battle\oi_that_pops!!!.wav", 5.0);
                if (trCurrentPlayer() == m_player){
                    cameraLookAt(location, 60.0, 45.0, 45.0);
                }
                return;
            }
            CardData newCard = getAndUpgradeDuplicateDeployedCard(card.getProtoName(), card);
            if (newCard.isNull() == false){
                removeCardByIndex(i);
                changeDisplayName(newCard);
                trSoundsetPlayPlayer(m_player, "AotgBlessingEquip");
                return;
            }
            if (spawnCard(card) == false) {
                addCard(card);
                return;
            }
            card.applyUpgrades(m_player);
            addSynergy(card, m_player);
            m_cardArray[i] = card;
            trSoundsetPlayPlayer(m_player, "AotgBlessingEquip");
            return;
        }
    }

    bool withdrawCard(int uuid = -1){
        for(int i = 0; i < m_cardSize; i++) {
            CardData cardToWithdraw = m_cardArray[i];
            if (uuid == cardToWithdraw.getUuid() && (!(cardToWithdraw.isNull())) && cardToWithdraw.isDeployed()){
                int unitID = cardToWithdraw.getDeployedUnitID();
                selectSingle(unitID);
                if (trUnitDead() == false){
                    vector shopLocation = kbUnitGetPosition(m_playerShopId);
                    float distance = kbUnitGetDistanceToPoint(unitID, shopLocation);
                    if (distance <= 10){
                        trUnitDestroy(true);
                        cardToWithdraw.resetRarityHealth(m_player);
                        cardToWithdraw.resetUpgrades(m_player);
                        cardToWithdraw.withdraw();
                        removeSynergy(cardToWithdraw, m_player);
                        m_cardArray[i] = cardToWithdraw;
                        trSoundsetPlayPlayer(m_player, "AotgBlessingUnequip");
                        log(3, "Player " + m_player + " withdrew to shop " + m_playerShopId);
                        return true;
                    }
                    else if (trCurrentPlayer() == m_player) {
                        trChatSendToPlayer(m_player, m_player, "Unit must be nearby your shop before it can be withdrawn.");
                        selectSingle(cardToWithdraw.getDeployedUnitID());
                        trUnitHighlight(8.0, true);
                        trSoundsetPlayPlayer(m_player, "PopCapHit");
                        return false;
                    }
                }
                else {
                    trChatSendToPlayer(m_player, m_player, "Unit must be alive before it can be withdrawn.");
                    trSoundsetPlayPlayer(m_player, "PopCapHit");
                    return false;
                }
            }
        }
        return false;
    }

    bool identifyCard(int uuid = -1, int p = 0){
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && (card.isIdentified() == false)){
                if (purchase(g_shrineShopCost, p)){
                    card.identify();
                    g_shrineShopCost = g_shrineShopCost + SHRINE_COST_INCREMENT;
                    m_cardArray[i] = card;
                    g_selectedUUIDs[p] = -1;
                    trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine");
                    log(3, "Player " + m_player + " identified a card.");
                    return true;
                }
            }
        }
        return false;
    }

    bool rerollRarity(int uuid = -1, int p = 0){
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (card.isNull() == false) && card.isIdentified()){
                if (purchase(g_templeShopCost, p)){
                    card.resetUpgrades(p); // TODO: Upgrade the difference instead of resetting everything
                    int rarity = card.rerollRarity();
                    card.applyUpgrades(p);
                    g_templeShopCost = g_templeShopCost + TEMPLE_COST_INCREMENT;
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
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && card.isIdentified()){
                if (purchase(g_forgeShopCost, p)){
                    bool hasSocketed = card.addSocket();
                    if (hasSocketed){
                        g_forgeShopCost = g_forgeShopCost + FORGE_COST_INCREMENT;
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
        for(int i = 0; i < m_cardSize; i++) {
            CardData card = m_cardArray[i];
            if (uuid == card.getUuid() && (!(card.isNull())) && card.isIdentified()){
                if (purchase(g_armoryShopCost, p)){
                    card.resetOneUpgrade(p, upgradeIdx);
                    int upgrade = card.rerollUpgrade(upgradeIdx);
                    card.applyOneUpgrade(p, upgradeIdx);
                    if (upgrade == -1){
                        errorLog("Player " + m_player + " failed to upgrade card.");
                        return false;
                    }
                    g_armoryShopCost = g_armoryShopCost + ARMORY_COST_INCREMENT;
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

    int getActiveTier(int synergyIndex = 0) {
        SynergyData synergy = g_synergies[synergyIndex];
        Buff[] buffs = synergy.m_buffs;
        int currentCount = m_synergyCounter[synergyIndex];
        int activeTierIndex = -1;
        for (int i = 0; i < buffs.size(); i++) {
            Buff buff = buffs[i];
            if (buff.isEmpty()) { continue; }
            if (i <= currentCount) {
                activeTierIndex = i;
            }
        }
        return activeTierIndex;
    }

    void renderSynergies(float posX = 0.0, float posY = 0.0, int p = 1) {
        float width = 0.1;
        float height = 0.025;
        float posYOffset = 0.0325;

        // 1. Initialize index map array for every configured synergy.
        int[] sortedIndices = new int(MAX_SYNERGIES, 0);
        for (int i = 0; i < sortedIndices.size(); i++) {
            sortedIndices[i] = i;
        }

        // 2. Bubble sort: Primary = Counter (Descending), Secondary = Active Tier (Descending)
        for (int i = 0; i < sortedIndices.size()-1; i++) {
            int j = 0;
            for (j = 0; j < sortedIndices.size() - 1 - i; j++) {
                int idxA = sortedIndices[j];
                int idxB = sortedIndices[j + 1];

                int countA = m_synergyCounter[idxA];
                int countB = m_synergyCounter[idxB];
                int tierA = getActiveTier(idxA);
                int tierB = getActiveTier(idxB);

                bool swap = false;
                if (countA < countB) {
                    swap = true;
                } else if (countA == countB) {
                    if (tierA < tierB) {
                        swap = true;
                    }
                }

                if (swap) {
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
                renderSynergyIcon(p, posX, posY, posYOffset, width, height, 32, idx, false, " " + m_synergyCounter[idx] + " : " + getSynergyText(idx));
            }
        }
    }

    int[] getDeployedUnitIDs(){
        int[] deployedUnitIDs = new int(0, -1);
        for (int i = 0; i < m_cardSize; i++){
            CardData card = m_cardArray[i];
            if (card.isDeployed()){
                deployedUnitIDs.add(card.getDeployedUnitID());
            }
        }
        return deployedUnitIDs;
    }
};