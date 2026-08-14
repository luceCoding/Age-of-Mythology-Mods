const int BUFF_TYPE_PROTO_DATA = 0; // trModifyProtounitData
const int BUFF_TYPE_PROTO_ACTION = 1; // trModifyProtounitAction

string[] g_allProtounits = default;

class Buff {
    bool m_init = false;
    
    int m_buffType = BUFF_TYPE_PROTO_DATA;
    int[] m_synergyTypes = default;
    int m_puField = -1;
    float m_delta = 0.0;
    int m_relativity = -1;

    void setBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffDataForAll(int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_DATA;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffAction(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION;
        m_synergyTypes = synergyTypes;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    void setBuffActionForAll(int puField = -1, float delta = 0.0, int relativity = -1) {
        m_buffType = BUFF_TYPE_PROTO_ACTION;
        m_puField = puField;
        m_delta = delta;
        m_relativity = relativity;
        m_init = true;
    }

    bool isEmpty() {
        return m_init == false;
    }

    void _executeCommand(string targetProto = "", int p = -1, float deltaVal = 0.0) {
        if (m_buffType == BUFF_TYPE_PROTO_DATA) {
            trModifyProtounitData(targetProto, p, m_puField, deltaVal, m_relativity);
        } else if (m_buffType == BUFF_TYPE_PROTO_ACTION) {
            trModifyProtounitAction(targetProto, "HandAttack", p, m_puField, deltaVal, m_relativity);
            trModifyProtounitAction(targetProto, "RangedAttack", p, m_puField, deltaVal, m_relativity);
        }
    }

    void applyBuff(int p = 0) {
        if (isEmpty()) { return; }

        CardParameters[] params = ProtoNameToCardParametersMap.getValues();
        for (int i = 0; i < params.size(); i++) {
            CardParameters param = params[i];
            if (m_synergyTypes.size() == 0){ // Apply to all
                _executeCommand(param.getProtoUnit(), p, m_delta);
            }
            else{
                for (int j = 0; j < m_synergyTypes.size(); j++) {
                    int synergyType = m_synergyTypes[j];
                    if (param.isASynergy(synergyType)){
                        _executeCommand(param.getProtoUnit(), p, m_delta);
                        break;
                    }
                }
            }
        }
    }

    void resetBuff(int p = 0) {
        if (isEmpty()) { return; }

        float invDelta = m_delta;
        if (m_relativity == relativityABSOLUTE) {
            invDelta = -m_delta;
        } else {
            invDelta = 1.0 - (m_delta - 1.0);
        }

        CardParameters[] params = ProtoNameToCardParametersMap.getValues();
        for (int i = 0; i < params.size(); i++) {
            CardParameters param = params[i];
            if (m_synergyTypes.size() == 0){ // Apply to all
                _executeCommand(param.getProtoUnit(), p, invDelta);
            }
            else{
                for (int j = 0; j < m_synergyTypes.size(); j++) {
                    int synergyType = m_synergyTypes[j];
                    if (param.isASynergy(synergyType)){
                        _executeCommand(param.getProtoUnit(), p, invDelta);
                        break;
                    }
                }
            }
        }
    }
};

Buff createBuffData(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffData(synergyTypes, puField, delta, relativity);
    return buff;
}

Buff createBuffAction(int[] synergyTypes = default, int puField = -1, float delta = 0.0, int relativity = -1){
    Buff buff;
    buff.setBuffAction(synergyTypes, puField, delta, relativity);
    return buff;
}