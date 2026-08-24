include "lib/rm_core.xs";
include "card.xs"

class DeckData {
    CardData[] m_cardArray = default;

    // Adds a card to the deck
    void addCard(ref CardData card) {
        m_cardArray.add(card);
        log(3, "Added card to deck " + card.getUuid());
    }

    // Fast removal at a specific index (Draws a specific/random card)
    CardData drawCardAtIndex(int index = 0) {
        int currentSize = m_cardArray.size();
        
        if (index < 0 || index >= currentSize) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData drawnCard = m_cardArray[index];
        int lastIndex = currentSize - 1;

        // Fast Removal: Overwrite drawn index with the last card
        m_cardArray[index] = m_cardArray[lastIndex];

        // Pop the last card off the deck
        m_cardArray.resize(lastIndex);
        log(3, "Popped card from deck, size: " + m_cardArray.size());
        return drawnCard;
    }

    // Utility: Draw a completely random card from anywhere in the deck
    CardData drawRandomCard() {
        if (m_cardArray.size() <= 0) {
            CardData emptyCard;
            return emptyCard;
        }

        // Pick a random index between 0 and size - 1
        int randomIndex = xsRandInt(0, m_cardArray.size() - 1);
        return drawCardAtIndex(randomIndex);
    }

    // Helper: Get current deck size
    int getSize() {
        return m_cardArray.size();
    }
};