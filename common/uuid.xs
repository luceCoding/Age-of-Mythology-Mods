class UUID {
    int m_uuid_count = cMinInt;

    int getNextUUID() {
        m_uuid_count++;
        return m_uuid_count;
    }
};

UUID g_uuid;