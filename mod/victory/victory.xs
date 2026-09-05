bool isTeamStillActive(int team = 1){
    for (int p = 1; p <= cNumberPlayers - 2; p++){
        if (trPlayerIsDefeatedOrResigned(p) == false && g_finalTeam[p] == team){
            return true;
        }
    }
    return false;
}

void setTeamAsWinner(int team = 0){
    int[] winners = new int(0, 0);
    for (int p = 1; p <= cNumberPlayers; p++) {
        if (g_finalTeam[p] == team) {
            winners.add(p);
        }
    }
    trSetVictoryPlayers(winners);
    trEndGame();
}

void startTeamResignedCheck(){
    scheduler.add(3001, [](int iterations = 1) -> bool {
        if (isTeamStillActive(1) == false){
            setTeamAsWinner(2);
        }
        if (isTeamStillActive(2) == false){
            setTeamAsWinner(1);
        }
        return true;
    });
}