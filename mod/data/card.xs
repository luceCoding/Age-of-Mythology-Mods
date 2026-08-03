include "lib/rm_core.xs";

const int CARD_TYPE_GOD_POWER = 0;
const int CARD_TYPE_UNIT = 1;
const int CARD_TYPE_TECH = 2;

const int CARD_TIER_DARK_AGE = 0;
const int CARD_TIER_CLASSICAL_AGE = 1;
const int CARD_TIER_HEROIC_AGE = 2;
const int CARD_TIER_MYTHIC_AGE = 3;
const int CARD_TIER_WONDER_AGE = 4;

class CardData {

    int m_cardType = -1;
    string m_protoGodPowerName = "";
    int m_ID = -1;
    int m_tier = 0;
    int m_count = 1;

    void setCardAsGodPower(string protoGodPowerName = "", int tier = 0, int count = 1){
        m_protoGodPowerName = protoGodPowerName;
        m_cardType = CARD_TYPE_GOD_POWER;
        m_tier = tier;
        m_count = 1;
    }

    void setCardAsUnit(int protounitID = -1, int tier = 0, int count = 1){
        m_ID = protounitID;
        m_cardType = CARD_TYPE_UNIT;
        m_tier = tier;
        m_count = 1;
    }

    void setCardAsTech(int techID = -1, int tier = 0, int count = 1){
        m_ID = techID;
        m_cardType = CARD_TYPE_TECH;
        m_tier = tier;
        m_count = 1;
    }
};