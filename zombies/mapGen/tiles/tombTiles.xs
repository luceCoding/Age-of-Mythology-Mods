Tile[] createTombTileTypes() {
    Tile[] tileTypes = new Tile(0);

    {
        Tile openTile;
        openTile.setUnits(
            -1, -1, -1,
            -1, cUnitTypeOsirisPieceBox, -1,
            -1, -1, -1);
        openTile.setPassability(
            true, true, true,
            true, false, true,
            true, true, true);
        openTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketTypeAny, cSocketTypeAny,
            3);
        tileTypes.add(openTile);
    }

    {
        Tile obeliskTile;
        obeliskTile.setUnits(
            -1, -1, -1,
            -1, cUnitTypeRugs, -1,
            -1, cUnitTypeObeliskProp, -1);
        obeliskTile.setPassability(
            true, true, true,
            true, false, true,
            true, true, true);
        obeliskTile.setSocketsAndWeight(
            cSocketObelisk, cSocketTypeAny,
            cSocketTypeAny, cSocketTypeAny,
            1);
        tileTypes.add(obeliskTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            obeliskTile = rotateMapTileClockwise(obeliskTile);
            tileTypes.add(obeliskTile);
        }
    }

    {
        Tile placeholderTile;
        placeholderTile.setUnits(
            -1, -1, -1,
            -1, -1, -1,
            -1, cUnitTypeCocoon, -1);
        placeholderTile.setPassability(
            true, true, true,
            true, true, true,
            true, true, true);
        placeholderTile.setSocketsAndWeight(
            cSocketTypeAny, cSocketTypeAny, cSocketWall, cSocketTypeAny, 
            1);
        tileTypes.add(placeholderTile);
        for (int rotation = 0; rotation < 3; rotation = rotation + 1) {
            Tile rotatedTile = rotateMapTileClockwise(placeholderTile);
            tileTypes.add(rotatedTile);
            placeholderTile = rotatedTile;
        }
    }

    {
        Tile tombTile;
        tombTile.setUnits(
            -1, -1, -1,
            -1, cUnitTypeYanFeifengTomb, -1,
            -1, -1, -1);
        tombTile.setPassability(
            true, true, true,
            true, false, true,
            true, true, true);
        tombTile.setSocketsAndWeight(
            cSocketTomb, cSocketTomb, cSocketTomb, cSocketTomb,
            1);
        tombTile.setForceAtRoomCenter();
        tombTile.setOnlyOncePerRoom();
        tileTypes.add(tombTile);
    }

    return tileTypes;
}