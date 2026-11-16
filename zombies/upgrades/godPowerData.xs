class GodPowerData {
    int protoPower = -1;
    string name = "";
    string description = "";
    string icon = "";
    int cooldown = -1;

    void redefineGodPower(int p = -1){
        trGodPowerRedefine(p, kbGodPowerGetName(protoPower), icon, name, description);
    }
};

GodPowerData createGodPowerData(int protoPower = -1, string name = "", string description = "", string icon = "", int cooldown = -1) {
    GodPowerData data;
    data.protoPower = protoPower;
    data.name = name;
    data.description = description;
    data.icon = icon;
    data.cooldown = cooldown;
    return data;
}