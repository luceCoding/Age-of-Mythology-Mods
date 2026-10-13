int[] g_finalTeams = default;

void setTeams(){
    g_finalTeams = new int(0, cNumberPlayers + 1);
    g_finalTeams[cHumanAIPlayer] = 1;
    g_finalTeams[cZombieAIPlayer] = 2;
}