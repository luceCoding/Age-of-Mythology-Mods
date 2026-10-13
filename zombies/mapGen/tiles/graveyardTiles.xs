Tile[] createGraveyardTileTypes() {
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
            cSocketDecoration, cSocketTypeAny, cSocketDecoration, cSocketTypeAny,
            cOpenTileWeight / 4);
        tileTypes.add(tombTile);
    }

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

    return tileTypes;
}