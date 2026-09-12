class NavegadorAgente {
  Coordenada proximoPasso(int atualL, int atualC, int[][] distancias, boolean[][] ocupadas) {
    int numLinhas = distancias.length;
    int numColunas = distancias[0].length;

    int[] dLinha = {-1, 1, 0, 0};
    int[] dColuna = {0, 0, -1, 1};

    int melhorDist = 999999;
    Coordenada melhorDestino = null;

    for (int i = 0; i < 4; i++) {
      int novoL = atualL + dLinha[i];
      int novoC = atualC + dColuna[i];

      if (novoL >= 0 && novoL < numLinhas && novoC >= 0 && novoC < numColunas) {
        int dist = distancias[novoL][novoC];

        if (dist >= 0 && (!ocupadas[novoL][novoC] || dist == 0)) {
          if (dist < melhorDist) {
            melhorDist = dist;
            melhorDestino = new Coordenada(novoL, novoC);
          }
        }
      }
    }

    //se todas as opções estiverem bloqueadas ele fica parado
    if (melhorDestino == null) {
      return new Coordenada(atualL, atualC);
    }

    return melhorDestino;
  }
}
