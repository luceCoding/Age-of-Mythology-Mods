const int cOpenTileWeight = 256;
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
        Tile singleWallTile;
        singleWallTile.setUnits(
            -1, -1, -1,
            defaultcUnitTypeWall, defaultcUnitTypeWall2, defaultcUnitTypeWall,
            -1, -1, -1);
        singleWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, true, true);
        singleWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketOpen, cSocketTypeWallOrEntrance, cSingleWallTileWeight);
        tileTypes.add(singleWallTile);
        Tile rotatedWall = rotateMapTileClockwise(singleWallTile);
        tileTypes.add(rotatedWall);
    }

    {
        Tile tBoneWallTile;
        tBoneWallTile.setUnits(
            -1, -1, -1,
            defaultcUnitTypeWall, defaultcUnitTypeWall, defaultcUnitTypeWall,
            -1, defaultcUnitTypeWall, -1);
        tBoneWallTile.setPassability(
            true, true, true,
            false, false, false,
            true, false, true);
        tBoneWallTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketTypeWallOrEntrance, ctBoneWallTileWeight);
        tileTypes.add(tBoneWallTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedWall = rotateMapTileClockwise(tBoneWallTile);
            tileTypes.add(rotatedWall);
            tBoneWallTile = rotatedWall;
        }
    }

    {
        Tile cornerTile;
        cornerTile.setUnits(
            -1, -1, -1,
            -1, defaultcUnitTypeWall, defaultcUnitTypeWall,
            -1, defaultcUnitTypeWall, -1);
        cornerTile.setPassability(
            true, true, true,
            true, false, false,
            true, false, true);
        cornerTile.setSocketsAndWeight(
            cSocketOpen, cSocketTypeWallOrEntrance,
            cSocketTypeWallOrEntrance, cSocketOpen, cCornerWeight);
        tileTypes.add(cornerTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedWall = rotateMapTileClockwise(cornerTile);
            tileTypes.add(rotatedWall);
            cornerTile = rotatedWall;
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
            -1, defaultcUnitTypeWall, -1,
            defaultcUnitTypeWall, defaultcUnitTypeWall, defaultcUnitTypeWall,
            -1, defaultcUnitTypeWall, -1);
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
                Tile rotatedWall = rotateMapTileClockwise(interactableTile);
                tileTypes.add(rotatedWall);
                interactableTile = rotatedWall;
            }
        }
    }

    return tileTypes;
}