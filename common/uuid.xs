class UUID {
    int m_uuid_count = cMinInt;

    int getNextUUID() {
        m_uuid_count++;
        return m_uuid_count;
    }
};

const int NullUUID = cMinInt;
UUID g_uuid;