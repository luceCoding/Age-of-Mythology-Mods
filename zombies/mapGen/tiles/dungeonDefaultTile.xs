const int cOpenTileWeight = 192;
const int cSingleWallTileWeight = 256;
const int ctBoneWallTileWeight = 32;
const int cCornerWeight = 64;
const int cLargeOpenTileWeight = 16;
const int cCrossTileWeight = 32;

Tile[] createDungeonDefaultTileTypes() {
    Tile[] tileTypes = new Tile(0);

    {
        Tile openTile;
        openTile.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, -1, -1);
        openTile.setPassability(
            true, true, true,
            true, true, true,
            true, true, true);
        openTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketTypeAny, cSocketTypeAny,
            cOpenTileWeight);
        tileTypes.add(openTile);
    }

    {
        Tile trapTile;
        trapTile.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, cUnitTypeStatueChimera, -1);
        trapTile.setPassability(
            true, true, true,
            true, true, true,
            true, true, true);
        trapTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketWall, cSocketTypeAny, 
            cOpenTileWeight * 0.05);
        tileTypes.add(trapTile);
        // Tile rotatedTile = rotateMapTileClockwise(trapTile); // TODO: Fix heading for cUnitTypeQiLin
        // tileTypes.add(rotatedTile);
    }

    {
        Tile placeholderTile;
        placeholderTile.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, cUnitTypeCinematicBlockArea, -1);
        placeholderTile.setPassability(
            true, true, true,
            true, true, true,
            true, true, true);
        placeholderTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketWall, cSocketTypeAny, 
            cSingleWallTileWeight * 0.15);
        tileTypes.add(placeholderTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedTile = rotateMapTileClockwise(placeholderTile);
            tileTypes.add(rotatedTile);
            placeholderTile = rotatedTile;
        }
    }

    {
        Tile singleWallTile;
        singleWallTile.setUnits(
            -1, -1, -1,
            cDefaultcUnitTypeWall, cDefaultcUnitTypeWall2, cDefaultcUnitTypeWall,
            -1, -1, -1);
        singleWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, true, true);
        singleWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketOpen, cSocketTypeWallOrEntrance, cSingleWallTileWeight);
        tileTypes.add(singleWallTile);
        Tile rotatedTile = rotateMapTileClockwise(singleWallTile);
        tileTypes.add(rotatedTile);
    }

    {
        Tile tBoneWallTile;
        tBoneWallTile.setUnits(
            -1, -1, -1,
            cDefaultcUnitTypeWall, cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
            -1, cDefaultcUnitTypeWall, -1);
        tBoneWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, false, true);
        tBoneWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, ctBoneWallTileWeight);
        tileTypes.add(tBoneWallTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedTile = rotateMapTileClockwise(tBoneWallTile);
            tileTypes.add(rotatedTile);
            tBoneWallTile = rotatedTile;
        }
    }

    {
        Tile cornerTile;
        cornerTile.setUnits(
            -1, -1, -1,
            -1, cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
            -1, cDefaultcUnitTypeWall, -1);
        cornerTile.setPassability(
            true, true, true,
            true, false, false,
            true, false, true);
        cornerTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketOpen, cCornerWeight);
        tileTypes.add(cornerTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedTile = rotateMapTileClockwise(cornerTile);
            tileTypes.add(rotatedTile);
            cornerTile = rotatedTile;
        }
    }

    {
        Tile largeOpenTile;
        largeOpenTile.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, -1, -1);
        largeOpenTile.setPassability(
            true, true, true,
            true, true, true,
            true, true, true);
        largeOpenTile.setSocketsAndWeight(
            cSocketOpen, cSocketOpen, cSocketOpen, cSocketOpen,
            cLargeOpenTileWeight);
        tileTypes.add(largeOpenTile);
    }

    {
        Tile crossTile;
        crossTile.setUnits(
            -1, cDefaultcUnitTypeWall, -1,
            cDefaultcUnitTypeWall, cDefaultcUnitTypeWall, cDefaultcUnitTypeWall,
            -1, cDefaultcUnitTypeWall, -1);
        crossTile.setPassability(
            true, false, true,
            false, false, false,
            true, false, true);
        crossTile.setSocketsAndWeight(
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, cCrossTileWeight);
        tileTypes.add(crossTile);
    }

    {
        for (int i = 0; i < g_humanInteractableTypes.size(); i = i + 1) {
            int interactableType = g_humanInteractableTypes[i];
            Tile interactableTile;
            interactableTile.setUnits(
                -1, -1, -1,
                -1, interactableType, -1,
                -1, -1, -1);
            interactableTile.setPassability(
                true, true, true,
                true, false, true,
                true, true, true);
            interactableTile.setSocketsAndWeight(
                cSocketInteractable, cSocketInteractable,
                cSocketInteractable, cSocketInteractable, i + 1);
            interactableTile.setPlayerUnit(4, cHumanAIPlayer);
            tileTypes.add(interactableTile);
            for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
                Tile rotatedTile = rotateMapTileClockwise(interactableTile);
                tileTypes.add(rotatedTile);
                interactableTile = rotatedTile;
            }
        }
    }

    return tileTypes;
}