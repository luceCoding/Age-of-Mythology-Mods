class TrainableUnitData {
    int unitType = -1;
    string name = "";
    string description = "";
    string icon = "";
    float initialCost = 0.0;
};

TrainableUnitData createTrainableUnitData(int unitType = -1, float initialCost = 0.0) {
    TrainableUnitData data;
    data.unitType = unitType;
    data.name = "+1 " + kbProtoUnitGetName(unitType);
    data.description = data.name;
    data.icon = kbProtoUnitGetIconPath(0, unitType);
    data.initialCost = initialCost;
    return data;
}