include "lib/rm_core.xs";
include "card.xs"

class DeckData {
    CardData[] m_cardArray = default;
    int m_cardSize = 0; // Tracks active cards without shrinking/reallocating the array

    // Adds a card to the deck
    void addCard(ref CardData card) {
        if (m_cardSize < m_cardArray.size()) {
            m_cardArray[m_cardSize] = card;
        } else {
            m_cardArray.add(card);
        }
        m_cardSize++;
        log(3, "Added card to deck " + card.getUuid() + " size: " + m_cardSize);
    }

    // Fast removal at a specific index using logical size tracking
    CardData drawCardAtIndex(int index = 0) {
        if (index < 0 || index >= m_cardSize) {
            CardData emptyCard;
            return emptyCard;
        }

        CardData drawnCard = m_cardArray[index];
        m_cardSize--; // Reduce active count

        // Swap the last active card into the removed card's slot if it's not the last one
        if (index < m_cardSize) {
            m_cardArray[index] = m_cardArray[m_cardSize];
        }

        log(3, "Popped card from deck, size: " + m_cardSize);
        return drawnCard;
    }

    // Utility: Draw a completely random card from anywhere in the deck
    CardData drawRandomCard() {
        if (m_cardSize <= 0) {
            CardData emptyCard;
            return emptyCard;
        }

        // Pick a random index between 0 and active size - 1
        int randomIndex = xsRandInt(0, m_cardSize - 1);
        return drawCardAtIndex(randomIndex);
    }

    // Helper: Get current active deck size
    int getSize() {
        return m_cardSize;
    }
};