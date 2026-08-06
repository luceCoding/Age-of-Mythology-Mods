include "lib/rm_core.xs";

class CardParameters {

    Parameters m_params;

    void setCardParameters(int cType = -1, int age = 0, 
                           string titleText = "", string hoverText = "", string iconPath = ""){
        Parameters params = createParameters();
        params.ints.add(cType);
        params.ints.add(age);
        params.strings.add(iconPath);
        params.strings.add(titleText);
        params.strings.add(hoverText);
        m_params = params;
    }

    int getcType(){
        if (m_params.ints.size() == 0){
            return -1;
        }
        return m_params.ints[0];
    }

    string getIconPath(){
        if (m_params.strings.size() == 0){
            return "";
        }
        return m_params.strings[0];
    }
};