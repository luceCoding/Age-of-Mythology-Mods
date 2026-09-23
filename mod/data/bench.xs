mutable bool purchase(int goldAmount = 0, int p = 0) { return false; }
mutable void addToRespawn(ref CardData card, int p = 0) { return; }
mutable void removeFromRespawn(ref CardData card) { return; }

IntToIntHashMap g_CardUUIDToIndex;
StringToIntHashMap g_ProtoUnitToIndex;

class BenchData {
    int m_cardSize = 0; // Tracks active cards without shrinking/reallocating the array
    int m_player = -1;
    int m_playerShopId = -1;
    int m_osirisDeployedCount = 0;
    int[] m_synergyCounter = default;
    CardData[] m_cardArray = default;

    // Cache variables
    string[] m_cachedSynergyText = default;
    bool[] m_synergyDirty = default;
    int[] m_cachedSynergyOrder = default;
    int m_cachedSynergyCount = 0;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
        m_synergyCounter = new int(MAX_SYNERGIES, 0);
        m_cachedSynergyText = new string(MAX_SYNERGIES, "");
        m_synergyDirty = new bool(MAX_SYNERGIES, true);
        m_cachedSynergyOrder = new int(MAX_SYNERGIES, -1);
        m_cachedSynergyCount = 0;
        m_cardSize = 0;
        m_osirisDeployedCount = 0;
    }
    
    int getPlayerShopID(){
        return m_playerShopId;
    }

    int findIdentifiedProtoIndex(string proto = "", int ignoreUUID = NullUUID){
        for (int i = 0; i < m_cardSize; i++) {
            CardData candidate = m_cardArray[i];
            if (candidate.isNull() == false && candidate.isIdentified() && candidate.getProtoName() == proto && candidate.getUuid() != ignoreUUID) {
                return i;
            }
        }
        return -1;
    }

    bool isThereADuplicateCard(string proto = "", int ignoreUUID = NullUUID){
        int i = g_ProtoUnitToIndex.get(proto + m_player);
        if (i >= 0 && i < m_cardSize) {
            CardData candidate = m_cardArray[i];
            if (candidate.isNull() == false && candidate.isIdentified() && candidate.getProtoName() == proto && candidate.getUuid() != ignoreUUID) {
                return true;
            }
        }

        return findIdentifiedProtoIndex(proto, ignoreUUID) >= 0;
    }

    bool addCard(ref CardData card){
        // Reuse an existing slot if available, otherwise grow the array pool
        if (m_cardSize < m_cardArray.size()) {
            m_cardArray[m_cardSize] = card;
        } else {
            m_cardArray.add(card);
        }
        g_CardUUIDToIndex.put(card.getUuid(), m_cardSize);
        if (card.isIdentified()) {
            int existingIndex = g_ProtoUnitToIndex.get(card.getProtoName() + m_player);
            if (existingIndex < 0 || existingIndex >= m_cardSize) {
                g_ProtoUnitToIndex.put(card.getProtoName() + m_player, m_cardSize);
            }
        }
        m_cardSize++;
        log(3, "Added card to bench " + card.getUuid() + ", size: " + m_cardSize);
        return true;
    }

    CardData getCardbyUUID(int uuid = NullUUID){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) {
            return EMPTY_CARD;
        }
        return m_cardArray[i];
    }

    CardData removeCardByUUID(int uuid = NullUUID){        
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) {
            return EMPTY_CARD;
        }

        CardData currCard = m_cardArray[i];
        if (currCard.getUuid() == uuid) {
            string currProto = currCard.getProtoName();
            bool currWasMapped = currCard.isIdentified() && g_ProtoUnitToIndex.get(currProto + m_player) == i;

            if (currCard.isOsirisPieceBoxCard() && currCard.isDeployed()) {
                m_osirisDeployedCount--;
            }

            m_cardSize--; // Reduce active count
            
            // Swap the last active element into this slot if it's not already the last one
            if (i < m_cardSize) {
                CardData movedCard = m_cardArray[m_cardSize];
                m_cardArray[i] = movedCard;
                g_CardUUIDToIndex.put(movedCard.getUuid(), i);
                if (movedCard.isIdentified()) {
                    string movedProto = movedCard.getProtoName();
                    if (g_ProtoUnitToIndex.get(movedProto + m_player) == m_cardSize) {
                        g_ProtoUnitToIndex.put(movedProto + m_player, i);
                    }
                }
            }
            
            // Clear the vacated slot to prevent ghost card rendering
            CardData nullCard;
            m_cardArray[m_cardSize] = nullCard;
            g_CardUUIDToIndex.remove(currCard.getUuid());
            if (currWasMapped) {
                int newIndex = findIdentifiedProtoIndex(currProto, NullUUID);
                if (newIndex >= 0) {
                    g_ProtoUnitToIndex.put(currProto + m_player, newIndex);
                } else {
                    g_ProtoUnitToIndex.remove(currProto + m_player);
                }
            }

            log(3, "Removed card from bench " + currCard.getUuid() + ", size: " + m_cardSize);
            return currCard;
        }
        
        return EMPTY_CARD;
    }

    CardData removeCardByIndex(int index = -1){ 
        // Validate index bounds
        if (index < 0 || index >= m_cardSize) {
            return EMPTY_CARD;
        }

        CardData currCard = m_cardArray[index];
        string currProto = currCard.getProtoName();
        bool currWasMapped = currCard.isIdentified() && g_ProtoUnitToIndex.get(currProto + m_player) == index;

        if (currCard.isOsirisPieceBoxCard() && currCard.isDeployed()) {
            m_osirisDeployedCount--;
        }

        m_cardSize--; // Reduce active count
        
        // Swap the last active element into this slot if it's not already the last one
        if (index < m_cardSize) {
            CardData movedCard = m_cardArray[m_cardSize];
            m_cardArray[index] = movedCard;
            g_CardUUIDToIndex.put(movedCard.getUuid(), index);
            if (movedCard.isIdentified()) {
                string movedProto = movedCard.getProtoName();
                if (g_ProtoUnitToIndex.get(movedProto + m_player) == m_cardSize) {
                    g_ProtoUnitToIndex.put(movedProto + m_player, index);
                }
            }
        }
        
        // Clear the vacated slot to prevent ghost card rendering
        CardData nullCard;
        m_cardArray[m_cardSize] = nullCard;
        g_CardUUIDToIndex.remove(currCard.getUuid());
        if (currWasMapped) {
            int newIndex = findIdentifiedProtoIndex(currProto, NullUUID);
            if (newIndex >= 0) {
                g_ProtoUnitToIndex.put(currProto + m_player, newIndex);
            } else {
                g_ProtoUnitToIndex.remove(currProto + m_player);
            }
        }

        log(3, "Removed card from index " + index + " (UUID: " + currCard.getUuid() + "), size: " + m_cardSize);
        return currCard;
    }

    void removeAllDeployedOsirisPieceCards(){        
        for (int i = 0; i < m_cardSize; i++) {
            CardData currCard = m_cardArray[i];
            if (currCard.isOsirisPieceBoxCard() && currCard.isDeployed()) {
                selectSingle(currCard.getDeployedUnitID());
                trUnitDestroy();

                string currProto = currCard.getProtoName();
                bool currWasMapped = currCard.isIdentified() && g_ProtoUnitToIndex.get(currProto + m_player) == i;

                m_cardSize--; // Reduce active count

                // Swap the last active element into this slot if it's not already the last one
                if (i < m_cardSize) {
                    CardData movedCard = m_cardArray[m_cardSize];
                    m_cardArray[i] = movedCard;
                    g_CardUUIDToIndex.put(movedCard.getUuid(), i);
                    if (movedCard.isIdentified()) {
                        string movedProto = movedCard.getProtoName();
                        if (g_ProtoUnitToIndex.get(movedProto + m_player) == m_cardSize) {
                            g_ProtoUnitToIndex.put(movedProto + m_player, i);
                        }
                    }
                }
                
                // Clear the vacated slot to prevent ghost card rendering
                CardData nullCard;
                m_cardArray[m_cardSize] = nullCard;
                g_CardUUIDToIndex.remove(currCard.getUuid());
                if (currWasMapped) {
                    int newIndex = findIdentifiedProtoIndex(currProto, NullUUID);
                    if (newIndex >= 0) {
                        g_ProtoUnitToIndex.put(currProto + m_player, newIndex);
                    } else {
                        g_ProtoUnitToIndex.remove(currProto + m_player);
                    }
                }

                log(3, "Removed osiris card from bench " + currCard.getUuid() + ", size: " + m_cardSize);
                i--; // Recheck the card moved into this slot
            }
        }
        m_osirisDeployedCount = 0;
    }

    int getDeployedOsirisPieceBoxCardCount(){
        return m_osirisDeployedCount;
    }

    CardData[] getCards(){
        return m_cardArray;
    }

    int getNumberOfCardsHeld(){
        return m_cardSize;
    }

    void addSynergy(ref CardData card, int p = 0){
        CardParameters params = card.getCardParameters();
        for (int SYNERGY_INDEX = 0; SYNERGY_INDEX < MAX_SYNERGIES; SYNERGY_INDEX++){
            if (params.isASynergy(SYNERGY_INDEX)){
                m_synergyCounter[SYNERGY_INDEX] = m_synergyCounter[SYNERGY_INDEX] + 1;
                m_synergyDirty[SYNERGY_INDEX] = true;
                SynergyData synergy = g_synergies[SYNERGY_INDEX];
                if (m_synergyCounter[SYNERGY_INDEX] < synergy.m_buffs.size()){
                    Buff buff = synergy.m_buffs[m_synergyCounter[SYNERGY_INDEX]];
                    buff.applyBuff(p);
                }
            }
        }
    }

    void removeSynergy(ref CardData card, int p = 0){
        CardParameters params = card.getCardParameters();
        for (int SYNERGY_INDEX = 0; SYNERGY_INDEX < MAX_SYNERGIES; SYNERGY_INDEX++){
            if (params.isASynergy(SYNERGY_INDEX)){
                SynergyData synergy = g_synergies[SYNERGY_INDEX];
                if (m_synergyCounter[SYNERGY_INDEX] < synergy.m_buffs.size()){
                    Buff buff = synergy.m_buffs[m_synergyCounter[SYNERGY_INDEX]];
                    buff.resetBuff(p);
                }
                m_synergyCounter[SYNERGY_INDEX] = m_synergyCounter[SYNERGY_INDEX] - 1;
                m_synergyDirty[SYNERGY_INDEX] = true;
            }
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
        if (applyCardHealth) {
            card.applyRarityHealth(m_player);
        }
        changeDisplayName(card);
        log(3, "Player " + m_player + " deployed " + protoName + " to shop " + m_playerShopId);
        return true;
    }

    CardData getAndUpgradeDuplicateDeployedCard(string proto = "", ref CardData duplicateCard){
        int i = g_ProtoUnitToIndex.get(proto + m_player);
        if (i < 0 || i >= m_cardSize) {
            i = findIdentifiedProtoIndex(proto, duplicateCard.getUuid());
        } else {
            CardData candidate = m_cardArray[i];
            if (candidate.isNull() || candidate.isIdentified() == false || candidate.getProtoName() != proto || candidate.getUuid() == duplicateCard.getUuid()) {
                i = findIdentifiedProtoIndex(proto, duplicateCard.getUuid());
            }
        }

        if (i < 0 || i >= m_cardSize) {
            return EMPTY_CARD;
        }

        CardData card = m_cardArray[i];
        if (card.isNull() == false && card.isIdentified() && card.getProtoName() == proto && card.getUuid() != duplicateCard.getUuid() && card.isOsirisPieceBoxCard() == false){
            card.mergeDuplicate(duplicateCard, m_player);
            m_cardArray[i] = card;
            g_ProtoUnitToIndex.put(proto + m_player, i);
            return card;
        }
        return EMPTY_CARD;
    }

    void deployCard(int uuid = NullUUID){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) return;

        CardData card = m_cardArray[i];
        if (card.isNull() || card.isDeployed() || card.getUuid() != uuid || card.isIdentified() == false) return;

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

        if (isThereADuplicateCard(card.getProtoName(), card.getUuid())) {
            CardData newCard = getAndUpgradeDuplicateDeployedCard(card.getProtoName(), card);
            if (newCard.isNull() == false){
                removeCardByIndex(i);
                changeDisplayName(newCard);
                trSoundsetPlayPlayer(m_player, "AotgBlessingEquip");
                return;
            }
        }

        if (spawnCard(card) == false) {
            addCard(card);
            return;
        }
        if (card.isOsirisPieceBoxCard()) {
            m_osirisDeployedCount++;
        }
        m_cardArray[i] = card;
        if (card.isIdentified() && card.isDeployed()) {
            card.applyUpgrades(m_player);
            addSynergy(card, m_player);
            addToRespawn(card, m_player);
            g_ProtoUnitToIndex.put(card.getProtoName() + m_player, i);
            trSoundsetPlayPlayer(m_player, "AotgBlessingEquip");
        }
        return;
    }

    bool withdrawCard(int uuid = NullUUID){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) return false;

        CardData cardToWithdraw = m_cardArray[i];
        if (uuid == cardToWithdraw.getUuid() && (!(cardToWithdraw.isNull())) && cardToWithdraw.isDeployed()){
            int unitID = cardToWithdraw.getDeployedUnitID();
            selectSingle(unitID);
            if (trUnitDead() == false){
                vector shopLocation = kbUnitGetPosition(m_playerShopId);
                float distance = kbUnitGetDistanceToPoint(unitID, shopLocation);
                if (distance <= 10){
                    trUnitDestroy(true);
                    removeFromRespawn(cardToWithdraw);
                    cardToWithdraw.resetRarityHealth(m_player);
                    cardToWithdraw.resetUpgrades(m_player);
                    cardToWithdraw.withdraw();
                    removeSynergy(cardToWithdraw, m_player);
                    if (cardToWithdraw.isOsirisPieceBoxCard()) {
                        m_osirisDeployedCount--;
                    }
                    if (cardToWithdraw.isIdentified() && g_ProtoUnitToIndex.get(cardToWithdraw.getProtoName() + m_player) == i) {
                        int newIndex = findIdentifiedProtoIndex(cardToWithdraw.getProtoName(), cardToWithdraw.getUuid());
                        if (newIndex >= 0) {
                            g_ProtoUnitToIndex.put(cardToWithdraw.getProtoName() + m_player, newIndex);
                        } else {
                            g_ProtoUnitToIndex.remove(cardToWithdraw.getProtoName() + m_player);
                        }
                    }
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
        return false;
    }

    bool identifyCard(int uuid = NullUUID, int p = 0){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) {
            return false;
        }

        CardData card = m_cardArray[i];
        if (uuid == card.getUuid() && (!(card.isNull())) && (card.isIdentified() == false)){
            if (purchase(g_shrineShopCost, p)){
                card.identify();
                g_shrineShopCost = g_shrineShopCost + SHRINE_COST_INCREMENT;
                m_cardArray[i] = card;
                if (card.isIdentified()) {
                    int existingIndex = g_ProtoUnitToIndex.get(card.getProtoName() + m_player);
                    CardData existingCard;

                    if (existingIndex < 0 || existingIndex >= m_cardSize) {
                        existingIndex = findIdentifiedProtoIndex(card.getProtoName(), card.getUuid());
                    } else {
                        existingCard = m_cardArray[existingIndex];
                        if (existingCard.isNull() || existingCard.isIdentified() == false || existingCard.getProtoName() != card.getProtoName() || existingCard.getUuid() == card.getUuid()) {
                            existingIndex = findIdentifiedProtoIndex(card.getProtoName(), card.getUuid());
                        }
                    }

                    if (existingIndex >= 0 && existingIndex < m_cardSize) {
                        existingCard = m_cardArray[existingIndex];
                        if (existingCard.isNull() == false && existingCard.isIdentified() && existingCard.getProtoName() == card.getProtoName() && existingCard.getUuid() != card.getUuid() && existingCard.isOsirisPieceBoxCard() == false) {
                            CardData mergedCard = getAndUpgradeDuplicateDeployedCard(card.getProtoName(), card);
                            if (mergedCard.isNull() == false) {
                                removeCardByIndex(i);
                                g_ProtoUnitToIndex.put(card.getProtoName() + m_player, existingIndex);
                                g_selectedUUIDs[p] = -1;
                                trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine");
                                trChatSendToPlayer(m_player, m_player, card.getProtoName() + " card identified and merged.");
                                log(3, "Player " + m_player + " identified and merged " + card.getProtoName());
                                return true;
                            }
                        }
                    }

                    g_ProtoUnitToIndex.put(card.getProtoName() + m_player, i);
                }
                g_selectedUUIDs[p] = -1;
                trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine");
                trChatSendToPlayer(m_player, m_player, card.getProtoName() + " card identified.");
                log(3, "Player " + m_player + " identified " + card.getProtoName());
                return true;
            }
        }
        return false;
    }

    bool rerollRarity(int uuid = NullUUID, int p = 0){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) return false;

        CardData card = m_cardArray[i];
        if (uuid == card.getUuid() && (card.isNull() == false) && card.isIdentified()){
            if (purchase(g_templeShopCost, p)){
                card.resetUpgrades(p); // TODO: Upgrade the difference instead of resetting everything
                int rarity = card.rerollRarity();
                card.applyUpgrades(p);
                g_templeShopCost = g_templeShopCost + TEMPLE_COST_INCREMENT;
                m_cardArray[i] = card;
                switch(rarity){
                    case TIER_UNCOMMON: { trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedFine"); break; }
                    case TIER_RARE: { trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedHeroic"); break; }
                    case TIER_EPIC: { trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedMythic"); break; }
                    case TIER_LEGENDARY: { trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedDivine"); break; }
                    default: trSoundsetPlayPlayer(m_player, "AotgBlessingRewardReceivedSimple");
                }
                log(3, "Player " + m_player + " rarity a card.");
                return true;
            }
        }
        return false;
    }

    bool addSocket(int uuid = NullUUID, int p = 0){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) return false;

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
        return false;
    }

    bool rerollUpgrade(int uuid = NullUUID, int p = 0, int upgradeIdx = 0){
        int i = g_CardUUIDToIndex.get(uuid);
        if (i < 0 || i >= m_cardSize) return false;

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
                log(3, "Player " + m_player + " rerolled upgrade " + upgradeIdx + " on card " + uuid + ".");
                return true;
            }
        }
        return false;
    }

    string getSynergyText(int synergyIndex = 0) {
        if (m_synergyDirty[synergyIndex] == false) {
            return m_cachedSynergyText[synergyIndex];
        }

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

        m_cachedSynergyText[synergyIndex] = text;
        m_synergyDirty[synergyIndex] = false;
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

    bool renderSynergies(float posX = 0.0, float posY = 0.0, int p = 1) {
        float width = 0.1;
        float height = 0.025;
        float posYOffset = 0.0325;

        bool hasChanged = false;
        for (int i = 0; i < MAX_SYNERGIES; i++) {
            if (m_synergyDirty[i]) {
                hasChanged = true;
                break;
            }
        }

        if (hasChanged) {
            // Collect only active synergies and pre-cache their tier levels.
            int[] activeIndices = new int(0, 0);
            int[] activeTiers = new int(0, 0);

            for (int i = 0; i < MAX_SYNERGIES; i++) {
                if (m_synergyCounter[i] > 0) {
                    activeIndices.add(i);
                    activeTiers.add(getActiveTier(i));
                } else {
                    m_synergyDirty[i] = false;
                }
            }

            int activeCount = activeIndices.size();

            // Sort active synergies only when their state changed.
            for (int i = 0; i < activeCount - 1; i++) {
                for (int j = 0; j < activeCount - 1 - i; j++) {
                    int idxA = activeIndices[j];
                    int idxB = activeIndices[j + 1];

                    int countA = m_synergyCounter[idxA];
                    int countB = m_synergyCounter[idxB];
                    int tierA = activeTiers[j];
                    int tierB = activeTiers[j + 1];

                    bool swap = false;
                    if (countA < countB) {
                        swap = true;
                    } else if (countA == countB) {
                        if (tierA < tierB) {
                            swap = true;
                        }
                    }

                    if (swap) {
                        activeIndices[j] = idxB;
                        activeIndices[j + 1] = idxA;
                        activeTiers[j] = tierB;
                        activeTiers[j + 1] = tierA;
                    }
                }
            }

            m_cachedSynergyCount = activeCount;
            for (int i = 0; i < activeCount; i++) {
                m_cachedSynergyOrder[i] = activeIndices[i];
            }
        }

        // Render using the cached sorted order.
        for (int i = 0; i < m_cachedSynergyCount; i++) {
            int idx = m_cachedSynergyOrder[i];
            renderSynergyIcon(p, posX, posY, width, height, 32, idx, false, " " + m_synergyCounter[idx] + " : " + getSynergyText(idx));
            posY = posY - posYOffset;
        }
        return hasChanged;
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