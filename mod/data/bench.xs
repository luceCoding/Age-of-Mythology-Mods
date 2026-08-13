include "lib/rm_core.xs";
include "card.xs"

IntToIntHashMap CardUUIDToUnitIDMap;
StringToIntHashMap g_synergyHashMap;

class BenchData {
    int m_player = -1;
    int m_playerShopId = -1;
    int[] m_synergies = default;
    CardData[] m_cardArray = default;

    void init(int p = -1, int shopId = -1){
        m_player = p;
        m_playerShopId = shopId;
        m_synergies = new int(8, 0);
    }
    
    int getPlayerShopID(){
        return m_playerShopId;
    }

    bool addCard(ref CardData card){
        m_cardArray.add(card);
        log(3, "Added card to bench " + card.getUuid());
        return true;
    }

    CardData getCardWithUUID(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.getUuid() == uuid){
                return card;
            }
        }
        CardData emptyCard;
        return emptyCard;
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

    void addSynergy(CardData card, int p = 0){
        String key = card.getProtoName() + p;
        int count = g_synergyHashMap.get(key);
        if (count == 0){
            CardParameters params = card.getCardParameters();
            if (params.isInfantry()){m_synergies[0] = m_synergies[0] + 1;}
            if (params.isArcher()){m_synergies[1] = m_synergies[1] + 1;}
            if (params.isCavalry()){m_synergies[2] = m_synergies[2] + 1;}
            if (params.isMythUnit()){m_synergies[3] = m_synergies[3] + 1;}
            if (params.isHero()){m_synergies[4] = m_synergies[4] + 1;}
            if (params.isHealer()){m_synergies[5] = m_synergies[5] + 1;}
            if (params.isSiege()){m_synergies[6] = m_synergies[6] + 1;}
            if (params.isBuilding()){m_synergies[7] = m_synergies[7] + 1;}
        }
        g_synergyHashMap.put(key, count + 1);
    }

    void removeSynergy(CardData card, int p = 0){
        String key = card.getProtoName() + p;
        int count = g_synergyHashMap.get(key);
        count = count - 1;
        g_synergyHashMap.put(key, count);
        if (count == 0){
            CardParameters params = card.getCardParameters();
            if (params.isInfantry()){m_synergies[0] = m_synergies[0] - 1;}
            if (params.isArcher()){m_synergies[1] = m_synergies[1] - 1;}
            if (params.isCavalry()){m_synergies[2] = m_synergies[2] - 1;}
            if (params.isMythUnit()){m_synergies[3] = m_synergies[3] - 1;}
            if (params.isHero()){m_synergies[4] = m_synergies[4] - 1;}
            if (params.isHealer()){m_synergies[5] = m_synergies[5] - 1;}
            if (params.isSiege()){m_synergies[6] = m_synergies[6] - 1;}
            if (params.isBuilding()){m_synergies[7] = m_synergies[7] - 1;}
        }
    }

    void deployCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData card = m_cardArray[i];
            if (card.isNull() || card.isDeployed() || card.getUuid() != uuid) continue;
            CardParameters params = card.getCardParameters();
            string protoName = params.getProtoUnit();
            vector position = trUnitGetPosition(m_playerShopId);
            int unitID = trUnitCreate(protoName, position.x, position.y, position.z, xsRandFloat(0.0, 360.0), m_player, false);
            CardUUIDToUnitIDMap.put(card.getUuid(), unitID);
            card.applySuitBonus(m_player);
            card.deploy();
            addSynergy(card, m_player);
            m_cardArray[i] = card;
            log(3, "Player " + m_player + " deployed " + protoName + " to shop " + m_playerShopId);
        }
    }

    bool withdrawCard(int uuid = -1){
        for(int i = 0; i < m_cardArray.size(); i++) {
            CardData cardToWithdraw = m_cardArray[i];
            if (!(cardToWithdraw.isNull()) && cardToWithdraw.isDeployed() && uuid == cardToWithdraw.getUuid()){
                int unitID = CardUUIDToUnitIDMap.get(uuid);
                xsSetContextPlayer(m_player);
                trUnitSelectClear();
                trUnitSelectByID(unitID);
                if (trUnitDead() == false){
                    vector shopLocation = kbUnitGetPosition(m_playerShopId);
                    float distance = kbUnitGetDistanceToPoint(unitID, shopLocation);
                    if (distance <= 10){
                        trUnitDestroy(true);
                        trUnitSelectClear();
                        cardToWithdraw.resetSuitBonus(m_player);
                        cardToWithdraw.withdraw();
                        removeSynergy(cardToWithdraw, m_player);
                        m_cardArray[i] = cardToWithdraw;
                        log(3, "Player " + m_player + " withdrew to shop " + m_playerShopId);
                        return true;
                    }
                    else {
                        trChatSendToPlayer(m_player, m_player, "Unit must be nearby your shop before it can be withdrawn.");
                    }
                }
                else {
                    trChatSendToPlayer(m_player, m_player, "Unit must be alive before it can be withdrawn.");
                }
            }
        }
        trUnitSelectClear();
        return false;
    }

    void renderSynergyIcon2(ref UiSystem system, float posX = 0.0, ref float posY, float posYOffset = 0.0, float width = 0.0, float height = 0.0, 
                           int index = 0, 
                           string iconPath = "", string rolloverName = "", string rolloverDesc = ""){
        if (m_synergies[index] == 0){return;}
        minimapSafeDisplay(system, posX - 0.01, posY, getIconPathFormat("resources/spectator/timeline/tim_playericon.png", 32));
        minimapSafeDisplayWithHover(system, posX, posY, width, height, getIconPathFormat(iconPath, 32) + ": " + m_synergies[index], 
                                    rolloverName,
                                    rolloverDesc);
        posY = posY - posYOffset;
    }

    void renderSynergies(ref UiSystem system, float posX = 0.0, float posY = 0.0, int p = 1) {
        float width = 0.025;
        float height = 0.0275;
        float posYOffset = 0.035;

        // 1. Initialize index map array [0, 1, 2, 3, 4, 5, 6, 7]
        int[] sortedIndices = new int(8, 0);
        for (int i = 0; i < sortedIndices.size(); i++) {
            sortedIndices[i] = i;
        }

        // 2. Bubble sort indices based on values in m_synergies (Descending)
        for (int i = 0; i < sortedIndices.size()-1; i++) {
            for (int j = 0; j < 7 - i; j++) {
                int idxA = sortedIndices[j];
                int idxB = sortedIndices[j + 1];

                if (m_synergies[idxA] < m_synergies[idxB]) {
                    sortedIndices[j] = idxB;
                    sortedIndices[j + 1] = idxA;
                }
            }
        }

        // 3. Render using sorted indices (renderSynergyIcon will naturally skip count == 0)
        for (int i = 0; i < sortedIndices.size(); i++) {
            int idx = sortedIndices[i];
            if (m_synergies[idx] > 0) {
                SynergyData synergy = g_synergyIcons[idx];
                minimapSafeDisplay(system, posX + 0.0825, posY + 0.005, m_synergies[idx] + " : 2 > 3 > 4 > 5");
                renderSynergyIcon(system, posX, posY, posYOffset, width, height, 32, idx);
            }
        }
    }
};