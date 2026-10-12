class WaveFunctionCollapse {
    int m_width = 0;
    int m_height = 0;
    int m_tileCount = 0;
    int m_boundarySocket = -1;
    bool m_configured = false;
    Tile[] m_tiles = default;
    bool[] m_possible = default;
    int[] m_optionCounts = default;
    int[] m_map = default;
    int[] m_queue = default;

    int getCellIndex(int x = 0, int y = 0) {
        return y * m_width + x;
    }

    int getOptionIndex(int cell = 0, int tileIndex = 0) {
        return cell * m_tileCount + tileIndex;
    }

    int getTileSocket(int tileIndex = 0, int direction = cSocketNorth) {
        Tile tile = m_tiles[tileIndex];
        return tile.getSocket(direction);
    }

    int getNeighbor(int cell = 0, int direction = cSocketNorth) {
        int x = cell % m_width;
        int y = cell / m_width;

        if (direction == cSocketNorth) {
            if (y == 0) return -1;
            return getCellIndex(x, y - 1);
        }
        if (direction == cSocketEast) {
            if (x >= m_width - 1) return -1;
            return getCellIndex(x + 1, y);
        }
        if (direction == cSocketSouth) {
            if (y >= m_height - 1) return -1;
            return getCellIndex(x, y + 1);
        }
        if (direction == cSocketWest) {
            if (x == 0) return -1;
            return getCellIndex(x - 1, y);
        }
        return -1;
    }

    bool isBoundaryCompatible(int cell = 0, int tileIndex = 0) {
        if (m_boundarySocket < 0) return true;

        for (int direction = cSocketNorth; direction <= cSocketWest;
             direction = direction + 1) {
            if (getNeighbor(cell, direction) == -1
                && getTileSocket(tileIndex, direction) != m_boundarySocket) {
                return false;
            }
        }
        return true;
    }

    bool configure(int width = 0, int height = 0, ref Tile[] tileTypes,
                   int boundarySocket = -1) {
        m_configured = false;
        if (width <= 0 || height <= 0 || tileTypes.size() == 0) return false;

        for (int tileIndex = 0; tileIndex < tileTypes.size();
             tileIndex = tileIndex + 1) {
            Tile tile = tileTypes[tileIndex];
            if (tile.weight <= 0) return false;
        }

        m_width = width;
        m_height = height;
        m_tileCount = tileTypes.size();
        m_boundarySocket = boundarySocket;
        m_tiles = tileTypes;
        m_possible = new bool(m_width * m_height * m_tileCount, false);
        m_optionCounts = new int(m_width * m_height, 0);
        m_map = new int(m_width * m_height, -1);
        m_configured = true;
        return true;
    }

    bool resetPossibilities() {
        for (int cell = 0; cell < m_width * m_height; cell = cell + 1) {
            m_optionCounts[cell] = 0;
            for (int tileIndex = 0; tileIndex < m_tileCount;
                 tileIndex = tileIndex + 1) {
                bool allowed = isBoundaryCompatible(cell, tileIndex);
                int optionIndex = getOptionIndex(cell, tileIndex);
                m_possible[optionIndex] = allowed;
                if (allowed) { m_optionCounts[cell] = m_optionCounts[cell] + 1; }
            }
            if (m_optionCounts[cell] == 0) return false;
        }
        return true;
    }

    bool runPropagation() {
        int queuePosition = 0;
        while (queuePosition < m_queue.size()) {
            int cell = m_queue[queuePosition];
            queuePosition = queuePosition + 1;

            for (int direction = cSocketNorth; direction <= cSocketWest;
                 direction = direction + 1) {
                int neighbor = getNeighbor(cell, direction);
                if (neighbor == -1) continue;

                bool changed = false;
                for (int neighborTile = 0; neighborTile < m_tileCount;
                     neighborTile = neighborTile + 1) {
                    int neighborOption = getOptionIndex(neighbor, neighborTile);
                    if (m_possible[neighborOption] == false) continue;

                    bool hasSupport = false;
                    for (int cellTile = 0; cellTile < m_tileCount;
                         cellTile = cellTile + 1) {
                        int cellOption = getOptionIndex(cell, cellTile);
                        if (m_possible[cellOption] == false) continue;

                        if (socketsMatch(
                                getTileSocket(cellTile, direction),
                                getTileSocket(
                                    neighborTile, getOppositeSocketDirection(direction)))) {
                            hasSupport = true;
                            break;
                        }
                    }

                    if (hasSupport == false) {
                        m_possible[neighborOption] = false;
                        m_optionCounts[neighbor] = m_optionCounts[neighbor] - 1;
                        changed = true;
                    }
                }

                if (m_optionCounts[neighbor] == 0) return false;
                if (changed) m_queue.add(neighbor);
            }
        }
        return true;
    }

    bool propagateFrom(int cell = 0) {
        m_queue = new int(0, -1);
        m_queue.add(cell);
        return runPropagation();
    }

    bool propagateAll() {
        m_queue = new int(0, -1);
        for (int cell = 0; cell < m_width * m_height; cell = cell + 1) {
            m_queue.add(cell);
        }
        return runPropagation();
    }

    int findCellWithFewestOptions() {
        int selectedCell = -1;
        int lowestOptionCount = m_tileCount + 1;
        int tiedCells = 0;

        for (int cell = 0; cell < m_width * m_height; cell = cell + 1) {
            int optionCount = m_optionCounts[cell];
            if (optionCount <= 1) continue;

            if (optionCount < lowestOptionCount) {
                selectedCell = cell;
                lowestOptionCount = optionCount;
                tiedCells = 1;
            } else if (optionCount == lowestOptionCount) {
                if (xsRandInt(0, tiedCells) == 0) selectedCell = cell;
                tiedCells = tiedCells + 1;
            }
        }
        return selectedCell;
    }

    int chooseWeightedTile(int cell = 0) {
        float totalWeight = 0.0;
        int lastAvailableTile = -1;
        for (int tileIndex = 0; tileIndex < m_tileCount;
             tileIndex = tileIndex + 1) {
            int optionIndex = getOptionIndex(cell, tileIndex);
            if (m_possible[optionIndex]) {
                Tile tile = m_tiles[tileIndex];
                totalWeight = totalWeight + xsIntToFloat(tile.weight);
                lastAvailableTile = tileIndex;
            }
        }

        if (totalWeight <= 0.0) return -1;
        float roll = xsRandFloat(0.0, totalWeight);
        float cumulativeWeight = 0.0;

        for (int tileIndex = 0; tileIndex < m_tileCount;
             tileIndex = tileIndex + 1) {
            int optionIndex = getOptionIndex(cell, tileIndex);
            if (m_possible[optionIndex] == false) continue;
            Tile tile = m_tiles[tileIndex];
            cumulativeWeight = cumulativeWeight + xsIntToFloat(tile.weight);
            if (roll < cumulativeWeight) return tileIndex;
        }
        return lastAvailableTile;
    }

    bool solve(int maxAttempts = 10) {
        if (m_configured == false || maxAttempts <= 0) return false;

        for (int cell = 0; cell < m_map.size(); cell = cell + 1) {
            m_map[cell] = -1;
        }

        for (int attempt = 0; attempt < maxAttempts; attempt = attempt + 1) {
            if (resetPossibilities() == false || propagateAll() == false) return false;

            bool contradiction = false;
            while (true) {
                int cell = findCellWithFewestOptions();
                if (cell == -1) break;

                int selectedTile = chooseWeightedTile(cell);
                if (selectedTile == -1) {
                    contradiction = true;
                    break;
                }

                for (int tileIndex = 0; tileIndex < m_tileCount;
                     tileIndex = tileIndex + 1) {
                    int optionIndex = getOptionIndex(cell, tileIndex);
                    bool keep = tileIndex == selectedTile;
                    if (m_possible[optionIndex] && keep == false) {
                        m_possible[optionIndex] = false;
                        m_optionCounts[cell] = m_optionCounts[cell] - 1;
                    }
                }

                if (propagateFrom(cell) == false) {
                    contradiction = true;
                    break;
                }
            }

            if (contradiction) continue;

            for (int cell = 0; cell < m_width * m_height; cell = cell + 1) {
                m_map[cell] = -1;
                for (int tileIndex = 0; tileIndex < m_tileCount;
                     tileIndex = tileIndex + 1) {
                    int optionIndex = getOptionIndex(cell, tileIndex);
                    if (m_possible[optionIndex]) {
                        m_map[cell] = tileIndex;
                        break;
                    }
                }
                if (m_map[cell] == -1) {
                    contradiction = true;
                    break;
                }
            }
            if (contradiction == false) return true;
        }

        return false;
    }

    int getTileIndexAt(int x = 0, int y = 0) {
        if (m_configured == false || x < 0 || y < 0 || x >= m_width || y >= m_height) {
            return -1;
        }
        int cell = getCellIndex(x, y);
        return m_map[cell];
    }

    int[] getMap() {
        return m_map;
    }
};