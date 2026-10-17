Tile[] createBossTileTypes() {
    Tile[] tileTypes = createDungeonDefaultTileTypes();

    Tile bossTile;
    bossTile.setUnits(
        -1, -1, -1,
        -1, cUnitTypeSentinelBase, -1,
        -1, -1, -1);
    bossTile.setPassability(
        true, true, true,
        true, true, true,
        true, true, true);
    bossTile.setSocketsAndWeight(
        cSocketOpen, cSocketOpen, cSocketOpen, cSocketOpen,
        1);
    bossTile.setForceAtRoomCenter();
    bossTile.setOnlyOncePerRoom();
    tileTypes.add(bossTile);

    return tileTypes;
}
