include "cardParameters.xs";
include "rng.xs";

int g_uuidCardCounter = 0;
StringToCardParametersProtoNameToCardParametersMap ProtoNameToCardParametersMap;

const int puFIELD_HITPOINTS = 0;
const int puFIELD_SPEED = 1;
const int puFIELD_SHIELDS = 12;
const int puFIELD_HACK_ARMOR = 13;
const int puFIELD_PIERCE_ARMOR = 14;
const int puFIELD_CRUSH_ARMOR = 15;
const int puFIELD_HP_REGEN = 17;
const int puFIELD_SHIELD_REGEN = 26;

const int relativityABSOLUTE = 0;
const int relativityASSIGN = 1;
const int relativityPERCENT = 2;
const int relativityBasePERCENT = 3;

class CardData {

    bool m_isLocked = false;
    bool m_isDeployed = false;
    string m_protoName = "";
    int m_count = 1;
    int m_uuid = -1;
    int m_suit = -1;
    int m_rarity = 0;
    int m_luckBonus = 0;

    void setCard(ref CardParameters params, int suit = -1){
        m_protoName = params.getProtoUnit();
        m_uuid = g_uuidCardCounter;
        g_uuidCardCounter = g_uuidCardCounter + 1;
        m_suit = suit;
    }

    CardParameters getCardParameters(){
        return ProtoNameToCardParametersMap.get(m_protoName);
    }

    int rerollRarity(int luckBonus = 0){
        m_luckBonus = m_luckBonus + 1;
        m_rarity = rollLootTierWeighted(luckBonus + m_luckBonus);
        return m_rarity;
    }

    void applySuitBonus(int p  = 0){
        float percentDelta = 1 + (0.05 * (m_rarity + 1));
        switch(m_suit){
            case 0: trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, percentDelta, relativityBasePERCENT);
            case 1: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, 13, percentDelta, relativityBasePERCENT);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, 14, percentDelta, relativityBasePERCENT);
            }
            case 2: trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, percentDelta, relativityBasePERCENT);
            case 3: {
                trModifyProtounitData(m_protoName, p, puFIELD_HP_REGEN, 0.1 * (m_rarity + 1), relativityASSIGN);
            }
            case 4: trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, percentDelta, relativityBasePERCENT);
            case 5: {
                int absoluteShields = 10 * (m_rarity + 1);
                log(3, "" + m_rarity);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELDS, absoluteShields, relativityABSOLUTE);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELD_REGEN, 0.5, relativityASSIGN);
            }
            case 6: trModifyProtounitData(m_protoName, p, puFIELD_SPEED, percentDelta, relativityBasePERCENT);
        }
    }

    void resetSuitBonus(int p = 0) {
        // Inverts the percentage modifier (e.g., 1.10 -> 0.90)
        float inversePercentDelta = 1 - (0.05 * (m_rarity + 1));

        switch(m_suit) {
            case 0: 
                trModifyProtounitData(m_protoName, p, puFIELD_HACK_ARMOR, inversePercentDelta, relativityBasePERCENT);
            case 1: {
                trModifyProtounitAction(m_protoName, "HandAttack", p, 13, inversePercentDelta, relativityBasePERCENT);
                trModifyProtounitAction(m_protoName, "RangedAttack", p, 14, inversePercentDelta, relativityBasePERCENT);
            }
            case 2: 
                trModifyProtounitData(m_protoName, p, puFIELD_HITPOINTS, inversePercentDelta, relativityBasePERCENT);
            case 3: 
                // Reset HP regeneration back to 0
                trModifyProtounitData(m_protoName, p, puFIELD_HP_REGEN, 0.0, relativityASSIGN);
            case 4: 
                trModifyProtounitData(m_protoName, p, puFIELD_PIERCE_ARMOR, inversePercentDelta, relativityBasePERCENT);
            case 5: {
                // Subtract the added shields and reset shield regen back to 0
                int absoluteShields = -10 * (m_rarity + 1);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELDS, absoluteShields, relativityABSOLUTE);
                trModifyProtounitData(m_protoName, p, puFIELD_SHIELD_REGEN, 0.0, relativityASSIGN);
            }
            case 6: 
                trModifyProtounitData(m_protoName, p, puFIELD_SPEED, inversePercentDelta, relativityBasePERCENT);
        }
    }

    int getRarity(){
        return m_rarity;
    }

    int getUuid(){
        return m_uuid;
    }

    int getSuit(){
        return m_suit;
    }

    void toggleLock(){
        m_isLocked = !m_isLocked;
    }

    void unlockCard(){
        m_isLocked = false;
    }

    bool isLocked(){
        return m_isLocked;
    }

    void deploy(){
        m_isDeployed = true;
    }

    void withdraw(){
        m_isDeployed = false;
    }

    bool isDeployed(){
        return m_isDeployed;
    }

    bool isNull(){
        return m_uuid == -1;
    }
};