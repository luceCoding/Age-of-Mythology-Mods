include "lib/rm_core.xs";

class CardParameters {

    Parameters m_params;

    void setCardParameters(int cType = -1, int age = 0, int cost = 1,
                           string titleText = "", string hoverText = "", string iconPath = ""){
        Parameters params = createParameters();
        params.ints.add(-1); // placeholder for data
        params.ints.add(cType);
        params.ints.add(age);
        params.ints.add(cost);
        params.strings.add(""); // placeholder for data
        params.strings.add(iconPath);
        params.strings.add(titleText);
        params.strings.add(hoverText);
        m_params = params;
    }

    int getIntData(){
        if (m_params.ints.size() < 0){
            return -1;
        }
        return m_params.ints[0];
    }

    int getcType(){
        if (m_params.ints.size() < 1){
            return -1;
        }
        return m_params.ints[1];
    }

    int getAge(){
        if (m_params.ints.size() < 2){
            return 0;
        }
        return m_params.ints[2];
    }

    int getCost(){
        if (m_params.ints.size() < 3){
            return 999;
        }
        return m_params.ints[3];
    }

    string getStringData(){
        if (m_params.strings.size() < 0){
            return "";
        }
        return m_params.strings[0];
    }

    string getTitle(){
        if (m_params.strings.size() < 2){
            return "";
        }
        return m_params.strings[2];
    }

    string getIconPath(){
        if (m_params.strings.size() < 1){
            return "";
        }
        return m_params.strings[1];
    }
};

Parameters createParametersCopy(CardParameters params){
    Parameters cardParams = createParameters();
    for(int j = 0; j < params.m_params.ints.size(); j++) {
        cardParams.ints.add(params.m_params.ints[j]);
    }
    for(int j = 0; j < params.m_params.strings.size(); j++) {
        cardParams.strings.add(params.m_params.strings[j]);
    }
    return cardParams;
}